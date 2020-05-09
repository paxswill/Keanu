#!/usr/bin/env python3

import argparse
import configparser
import enum
import logging
import operator
import pathlib
import pprint
import sys

import jinja2


log = logging.getLogger("generate_tests")
logging.basicConfig(level=logging.INFO)


class classproperty(property):
    """A `property`, but on classes instead of instances."""

    def __get__(self, cls, owner):
        return classmethod(self.fget).__get__(None, owner)()


class SwiftArchitecture(enum.Enum):
    """An enum for CPU architectures supported by Swift."""

    ARM_32 = "arm"
    ARM_64 = "arm64"
    X86_32 = "i386"
    X86_64 = "x86_64"

    @classproperty
    def ARM(cls):
        """A set covering 32 and 64 bit ARM architectures."""
        return frozenset((cls.ARM_32, cls.ARM_64))

    @classproperty
    def X86(cls):
        """A set covering 32 and 64 bit x86 architectures."""
        return frozenset((cls.X86_32, cls.X86_64))

    @property
    def swift_condition(self):
        """The Swift conditional compilation expression for this enum value."""
        return f"arch({self.value})"


class SwiftOS(enum.Enum):
    """An enum for operating systems supported by Swift."""

    MAC = "macOS"
    IOS = "iOS"
    TV = "tvOS"
    WATCH = "watchOS"
    LINUX = "Linux"

    @classproperty
    def APPLE(cls):
        """A set covering all Apple OSes."""
        return frozenset((cls.MAC, cls.IOS, cls.TV, cls.WATCH))

    @property
    def swift_condition(self):
        """The Swift conditional compilation expression for this enum value."""
        return f"os({self.value})"


class SwiftType:
    """A Swift type to be given to templates.

    The type can also be conditioned on specific platforms or architectures.
    For example, Float80 is only available on x86 platforms.
    """

    def __init__(self, name, os=None, archs=None):
        self.name = name
        if os is not None:
            if isinstance(os, SwiftOS):
                self.os = [os]
            else:
                self.os = os
        else:
            self.os = []
        if archs is not None:
            if isinstance(archs, SwiftArchitecture):
                self.archs = [archs]
            else:
                self.archs = archs
        else:
            self.archs = []

    def __str__(self):
        return self.name

    def __repr__(self):
        args = [repr(self.name)]
        if self.os:
            args.append("os={{{}}}".format(", ".join(self.os)))
        if self.archs:
            args.append("archs={{{}}}".format(", ".join(self.archs)))
        all_args = ", ".join(args)
        return f"{self.__class__.__name__}({all_args})"

    @property
    def is_conditional(self):
        """A boolean for if this type is only available on some platforms."""
        return self.os or self.archs

    def condition(self):
        """Get the compilation condition for this type.

        If this type is not predicated on certain OSes or architectures, it
        returns the string `"true"`. Otherwise it returns a string of Swift
        conditional compilation expressions approppriate for adding after
        `#if`.
        """
        predicates = []
        swift_getter = operator.attrgetter("swift_condition")
        if self.os:
            predicates.append(" || ".join(map(swift_getter, self.os)))
        if self.archs:
            predicates.append(" || ".join(map(swift_getter, self.archs)))
        if predicates:
            return " && ".join(predicates)
        else:
            log.warning("Conditional compilation without a predicate!")
            return "true"


"""All Swift standard library number types."""
SWIFT_NUMERICS = tuple(
    [
        SwiftType(f"{sign}Int{length}")
        for length in ["", 8, 16, 32, 64]
        for sign in ["", "U"]
    ] +
    [SwiftType(floatType) for floatType in ["Float", "Double"]] +
    [SwiftType("Float80", archs=SwiftArchitecture.X86)]
)


class MatrixType(SwiftType):
    """A specialized SwiftType for Matrix types.

    The only major difference currently is it can distinguish between
    contiguous and non-contiguous Matrix types.
    """

    def __init__(self, *args, contiguous=False, **kwargs):
        self.contiguous = contiguous
        super().__init__(*args, **kwargs)


class ExtendAction(argparse.Action):
    """Compatibility shim for Python versions <3.8.

    For Python >=3.8, the string `"extend"` can be given as an action to
    argparse. For older versions this class can be given the same effect.
    """
    def __call__(self, parser, namespace, values, option_string):
        if not hasattr(namespace, self.dest):
            setattr(namespace, self.dest, [])
        container = getattr(namespace, self.dest)
        container.extend(values)


def get_config():
    """Build up a configuration dict.

    It starts with some basic defaults, merges in any values from a
    configuration file, then merges in any command line options. This means
    that command line options will override config file options.

    This function also handles setting the verbose flag. This flag is special
    in that it **cannot** be overridden to a false value. In other words, once
    set, it will always be set. This is to enable debug logging as early as
    possible in the execution of this script.
    """
    arg_parser = argparse.ArgumentParser()
    if sys.version_info >= (3, 8):
        extend_action = "extend"
    else:
        extend_action = ExtendAction
    arg_parser.add_argument(
        "--template-dir",
        "-t",
        dest="templates",
        type=pathlib.Path,
        action="append"
    )
    arg_parser.add_argument(
        "--template-dirs",
        "-T",
        dest="templates",
        type=pathlib.Path,
        nargs="+",
        action=extend_action
    )
    arg_parser.add_argument("--output", "-o", type=pathlib.Path, action="store")
    arg_parser.add_argument("--extension", "-x", type=str)
    arg_parser.add_argument("--config", dest="config_file", type=pathlib.Path)
    arg_parser.add_argument("--verbose", "-v", action="store_true")
    args = arg_parser.parse_args()
    # If verbose, set that flag early
    if args.verbose:
        log.level = logging.DEBUG
    # Start with some basic defaults
    resolved_config = {
        "output": pathlib.Path.cwd(),
        "extension": ".tpl",
        "verbose": False
    }
    # Merge in the config file values (if any)
    config_path = pathlib.Path.cwd() / ".gen_tests_config.ini"
    if args.config_file is not None:
        config_path = args.config_path
    log.debug("Checking path %s for config file.", config_path)
    if config_path.is_file():
        # Resolve the path so that any later manipulations of it are
        # absolute/real.
        config_path = config_path.resolve()
        config_parser = configparser.ConfigParser()
        with config_path.open() as f:
            config_parser.read_file(f)
        section_name = "keanu-tests"
        config = config_parser[section_name]
        # Like before, set verbose flag as soon as we see it
        if "verbose" in config:
            resolved_config["verbose"] = config_parser.getboolean(
                section_name,
                "verbose"
            )
            # Only enable verbose mode, don't disable it
            if resolved_config["verbose"]:
                log.level = logging.DEBUG
        # When resolving paths from a config file, use the location of the file
        # as the root for relative paths.
        def relative_to_config(path):
            if not path.is_absolute():
                new_path = (config_path.parent / path).resolve()
                log.debug("Resolving config path %s to %s", path, new_path)
                return new_path
            else:
                return path

        if "template-dirs" in config:
            template_dirs = [
                pathlib.Path(p.strip())
                for p in config["template-dirs"].split(",")
            ]
            resolved_config["templates"] = list(map(relative_to_config,
                                                    template_dirs))
        if "output" in config:
            output_path = pathlib.Path(config["output"])
            resolved_config["output"] = relative_to_config(output_path)
        if "extension" in config:
            resolved_config["extension"] = config["extension"]
    # Merge in the command line arguments
    resolved_config.update({ k: v for k, v in vars(args).items() if v})
    log.debug("Resolved configuration:\n%s", pprint.pformat(resolved_config))
    # Sanity checks
    if not resolved_config["output"].exists():
        resolved_config["output"].mkdir(parents=True)
    assert resolved_config["output"].is_dir()
    extension = resolved_config["extension"]
    # Jinja takes the extension *without* the dot
    if extension and extension.startswith("."):
        log.debug("Removing leading dot from extension.")
        resolved_config["extension"] = extension[1:]
    return resolved_config


def is_leaf_template(template, context):
    """Returns whether or not the given template is a leaf template or not.

    A leaf template is one that is intended to be rendered. This is inferred by
    checking for blocks that are empty. If any blocks render to an empty
    string, the template is considered a non-leaf template.
    """
    template_context = template.new_context(context)
    for block_name, block in template.blocks.items():
        try:
            rendered = "".join(block(template_context)).strip()
        except jinja2.UndefinedError:
            # Ignore errors due to undefined values. If a block is using a
            # variable, it'll be rendering something.
            pass
        except jinja2.TemplateError as exc:
            log.exception("Error rendering template %s", template.name)
        else:
            log.debug(
                'Rendered %s.%s: "%s"',
                template.name,
                block_name,
                rendered
            )
            if not rendered:
                return False
    return True


def leaf_templates(environment, context, extension=None):
    """Generator that yields leaf templates from the given environment."""
    list_kwargs = {}
    if extension is not None:
        list_kwargs["extensions"] = [extension]
    template_names = environment.list_templates(**list_kwargs)
    for name in template_names:
        try:
            template = environment.get_template(name)
        except jinja2.TemplateError as exc:
            log.exception("Error loading template %s", name)
        else:
            if is_leaf_template(template, context):
                yield template
            else:
                log.debug(
                    "Skipping template %s as it is not a leaf template.",
                    name
                )


def main():
    config = get_config()
    # Jinja time
    loader = jinja2.FileSystemLoader([str(p) for p in config["templates"]])
    env = jinja2.Environment(
        undefined=jinja2.StrictUndefined,
        loader=loader,
        autoescape=False,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    # Hard-coding in the types to test here. While Sourcery is an interesting
    # tool, the lack of Linux compatibility makes it unsuitable for usage in
    # this project.
    context = {
        "ScalarTypes": SWIFT_NUMERICS,
        "MatrixTypes": [
            MatrixType("BasicMatrix"),
            MatrixType("ContiguousMatrix", contiguous=True),
        ],
    }
    template_extension = config["extension"]
    for template in leaf_templates(env, context, extension=template_extension):
        dest_path = config["output"].joinpath(
            pathlib.Path(template.filename).name
        ).with_suffix("")
        log.debug("Writing render from %s to %s", template.filename, dest_path)
        try:
            rendered = template.render(context)
        except jinja2.TemplateError as exc:
            log.exception("Error rendering template %s", template.name)
        else:
            if rendered:
                with dest_path.open("w") as f:
                    f.write(rendered)
            else:
                log.info("Skipping %s, empty output", dest_path)


if __name__ == "__main__":
    main()
