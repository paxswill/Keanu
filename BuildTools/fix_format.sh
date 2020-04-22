#!/bin/sh
set -e
# Provide a default value of SRCROOT if it hasn't been given
if [ "x" = "x${SRCROOT}" ]; then
    _OLD_DIR="$PWD"
    if [ -f "$0" ]; then
        cd "`dirname "$0"`/.."
    else
        cd `dirname "${PWD}"/"$0"/`/..
    fi
    export SRCROOT="$PWD"
    cd "$_OLD_DIR"
    unset _OLD_DIR
fi
"${SRCROOT}/BuildTools/run-build-tool.sh" \
    swift-format \
    format \
	--configuration "${SRCROOT}/.swift-format" \
	-i \
    -r \
    "$SRCROOT"/Sources \
    "$SRCROOT"/Tests \
    "$SRCROOT"/Package.swift
