# modulo

Modulo's goal is to orchestrate repositories and filesystem assets for large, modular projects. For example, collections of services or libraries or components that have versioned dependencies between themselves.

Modulo manages collections of dependent, versioned repositories. It leaves build concerns to build systems (eg: Cocoa Pods, Maven), and is designed to be agnostic about source code management systems (eg: Git, Subversion).

## Relationships

Modulo understands relationships between _modules_ and _applications_. Modules may be dependent as peers, whereas an application depends on a set of modules:

```
Module -> [Module, Module, ...]
Application -> [Module, Module, ...]
```

(Note: nothing can be dependent on an application)

As an example, let's consider an application named "Fancy App" that depends on some shared components and media assets. To make it a little more complicated, one of the shared components also depends on a utility library.

In other words, there are two sets of dependencies to be managed:

```
Fancy App -> [Component A, Component B, Assets]
Component A -> [Utilities]
```

These dependencies will get arranged directory structure as such:

```
Fancy App/
    modules/
        Component A/
        Component B/
        Utilities/
        Assets/
```

Note that "Fancy App" is the root, and that all of the modules are checked out into the `modules/` directory, including the `Utilities` dependency.

To put a twist on this scenario, if you're developing on `Component A` in isolation, and you only want to check it out with it's dependencies, you would end up with a directory structure like this:

```
Component A/
Utilities/
```

... Where `Component A` and `Utilities` are peers in the file system.

## Build Dependencies

* \>= Xcode 8.1
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

### Create an application



### Create a module

### Updating dependencies
