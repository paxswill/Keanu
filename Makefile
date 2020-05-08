.PHONY: gen-tests test clean watch xcode

gen-tests:
	./BuildTools/generate_tests.py

xcode: gen-tests
	swift package generate-xcodeproj --enable-code-coverage

test: gen-tests
	swift test --enable-test-discovery

clean:
	rm -rf Tests/KeanuTests/Generated/

watch:
	swift package generate-xcodeproj --enable-code-coverage --watch
