.PHONY: test clean

test:
	./BuildTools/run_sourcery.sh
	swift test

clean:
	rm -rf Tests/KeanuTests/Generated/
