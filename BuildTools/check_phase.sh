#!/bin/sh
# Provide a default value of SRCROOT if it hasn't been given
if [ "x" = "x${SRCROOT}" ]; then
	_OLD_DIR="$PWD"
	cd `dirname "${PWD}"/"$0"/`/..
	SRCROOT="$PWD"
	cd "$_OLD_DIR"
	unset _OLD_DIR
fi
swift run -c release --package-path "$SRCROOT"/BuildTools --skip-update swift-format lint -r  "$SRCROOT"/Sources "$SRCROOT"/Tests "$SRCROOT"/Package.swift
