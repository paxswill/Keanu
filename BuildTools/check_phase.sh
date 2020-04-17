#!/bin/sh
swift run -c release --package-path "$SRCROOT"/BuildTools --skip-update swift-format lint -r  "$SRCROOT"/Sources "$SRCROOT"/Tests "$SRCROOT"/Package.swift
