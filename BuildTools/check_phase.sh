#!/bin/sh
set -e
# Provide a default value of SRCROOT if it hasn't been given
if [ "x" = "x${SRCROOT}" ]; then
    _OLD_DIR="$PWD"
	cd `dirname "${PWD}"/"$0"/`/..
    SRCROOT="$PWD"
    cd "$_OLD_DIR"
    unset _OLD_DIR
fi
"${SRCROOT}/BuildTools/run-swift-format.sh" \
    lint \
	--configuration "${SRCROOT}/.swift-format" \
    -r \
    "$SRCROOT"/Sources \
    "$SRCROOT"/Tests \
    "$SRCROOT"/Package.swift
