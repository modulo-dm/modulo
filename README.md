# modulo

Modulo manages collections of dependent, versioned Git repositories.

## Dependencies

* Xcode 8.1
* Git


## Installation

### With `homebrew`

Homebrew will download and build `modulo` from source, so you'll need Xcode 8.1 for this to work.

```bash
$ brew install modulo
```

### From Source

Clone this repo, then ...

```bash
$ cd $repo
$ xcodebuild -project modulo.xcodeproj -scheme modulo -configuration Release SYMROOT=build
```

This will leave the modulo binary in `/tmp/modulo`

## Usage

_TBD_
