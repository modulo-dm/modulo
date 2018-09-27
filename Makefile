# By default export all variables
export

.PHONY: install release debug build setup clean test

PROJECT ?= 'modulo.xcodeproj'
SCHEME  ?= 'modulo'
SYMROOT ?= 'build'
CONFIGURATION ?= 'Debug'

# Build for debugging
debug: build

test:
	xcodebuild -project $(PROJECT) -scheme ModuloKit test

# Install `modulo` to `/usr/local/bin`
install: release
	cp $(SYMROOT)/Release/modulo /usr/local/bin/

# Build for release
release: CONFIGURATION = 'Release'
release: build


# Build modulo
# This will build the `PROJECT` with the given `SCHEME`
# to the `SYMROOT` with a given `CONFIGURATION`
# Defaults for these values are
# `PROJECT` - `modulo.xcodeproj`
# `SCHEME`  - `modulo`
# `SYMROOM` - `build`
# `CONFIGURATION` - `Debug`
# 
# These can be overwritten via ENV variables.
build: setup
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIGURATION) SYMROOT=$(SYMROOT)

# Setup the environment
setup:
	mkdir -p $(SYMROOT)

clean:
	rm -rfv $(SYMROOT)
