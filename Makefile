.PHONY: sourcery test clean watch xcode


sourcery:
	./BuildTools/run_sourcery.sh

xcode: sourcery
	swift package generate-xcodeproj --enable-code-coverage

test: sourcery
	swift test --enable-test-discovery

clean:
	rm -rf Tests/KeanuTests/Generated/

watch:
	./BuildTools/run-build-tool.sh sourcery --config ./.sourcery.yml --watch &
	swift package generate-xcodeproj --enable-code-coverage --watch &
