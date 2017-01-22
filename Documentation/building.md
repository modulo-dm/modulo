## Build Dependencies

* \>= Xcode 8.1
* Git
* Ronn (sudo gem install ronn)

### Modulo binary, from Source

Clone this repo, then ...

```bash
$ cd $repo
$ xcodebuild -project modulo.xcodeproj -scheme modulo -configuration Release SYMROOT=build
```

This will leave the modulo binary in `/tmp/modulo`

### Modulo documentation, via Ronn

```bash
$ ...
```
