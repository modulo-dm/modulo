# modulo

Modulo is a source-only dependency manager.  Its primary goal is to orchestrate repositories and filesystem assets for large, modular projects. For example, collections of services or libraries or components that have versioned dependencies between themselves.

Modulo manages collections of dependent, versioned repositories. It leaves build concerns to build systems (eg: Xcode, Xcodebuild, Maven, make, etc), and is designed to be agnostic about source code management systems (eg: Git, Subversion\*).

\* _only git is currently supported at the moment, others to follow_

## How is it different from Carthage and CocoaPods?

Modulo doesn't try to build the world for you.  It focuses solely on managing your dependencies at a file system level.  No need to worry about your dependency manager supporting the latest version of your build tools.

Modulo also makes it really easy and painless to contribute back to a dependency.  Since it's not building anything, and your dependencies are simply clones of what you specified, the workflow is fast and simple.  If you've ever tried this with Carthage and CocoaPods, it can be very frustrating, not to mention training an entire team of individuals to do it.

Modulo is more flexible.  It doesn't explicitly need support from the dependency.  A simple Git url will suffice, though more features are available if a dependency does explicitly support modulo.  Modulo can also checkout and work from branches, tags, and even specific commit hashes and switch between them very easily.

Modulo is more informative.  With the --verbose option, it informs you of exactly what it's doing underneath.  It lets you know whether dependencies were pulled in implicitly vs. explicitly.  During updates or other changes, it checks the status of your project and any dependencies and lets you know if things are awry, such as unpushed changes, uncommitted changes, etc. It will let you know of these things and stop before causing problems.

Errors and edge cases are much easier to recover from.  Following the happy path, CocoaPods and Carthage work very well.  When things get out of whack (in any number of possible ways), it's often very difficult to recover from.

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

### Install via `homebrew`

Homebrew will download and build `modulo` from source, so you'll need Xcode 8.3.3 for this to work.~~

```bash
$ brew install modulo-dm/homebrew-tap/modulo
```

### Upgrade to the latest version via `homebrew`

```bash
$ brew upgrade modulo
```

### Build it yourself, from source

Clone this repo, then ...

```bash
$ cd $repo
$ xcodebuild -project modulo.xcodeproj -scheme modulo -configuration Release SYMROOT=build
```

This will leave the modulo binary in `/tmp/modulo`

## Usage

### Getting Help

Modulo's command line interface is very much like Git.

```bash
$ modulo --help
usage: modulo <command> [<args>]

The most commonly used modulo commands are:
   init           Initialize modulo
   add            Adds a module dependency
   update         Updates module dependencies
   status         Gathers status about the module tree
   map            Displays information about dependencies
   set            Sets dependency values
```

Each command has more specific help associated with it:

```bash
$ modulo add --help
usage: modulo add [options] <repo url>

Add the given repository as a module to the current project.

In unmanaged mode, it is up to the user to manage what is checked out.
In this case, the update command will simply do a pull.

More information on version ranges can be found at https://docs.npmjs.com/misc/semver

     --help                show help for this command
     -v, --verbose         be verbose
     --version <version>   specify the version or range to use
     --unmanaged           specifies that this module will be unmanaged
     -u, --update          performs the update command after adding a module

```

### Create an application

Modulo has two modes of operation, App and Module.  Whichever you happen to be doing, it is only necessary to specify on \`init\`.

```bash
$ modulo init --app
```
This will initialize your project for Modulo.  You can now \`add\` and \`update\` any dependencies you may need.  In Application mode, all dependencies will live in a subfolder called 'modules'.  When you have done this, your file system will look something like this:

```
MyApplication\
    modules\
        mydependency1\
        mydependency2\
        someGitRepo\
```

### Create a module

When creating a module for others to use, you'll want to initialize your project in module mode.

```bash
$ modulo init --module
```
Any dependencies you add will be cloned one level up the filesystem.  Here's an example of how it might look were your project named 'MyProject':

```
work\
    MyProject\
    mydependency1\
    mydependency2\
    someGitRepo\
```

In the example above, 'MyProject' depends on the other 3 dependencies, and all live as peers on the filesystem.  This ensures that when they are used in an Application, that they are all still peers in the filesystem.

### Adding dependencies

Use the `add` command:

```bash
$ modulo add git@github.com/modulo-dm/test-checkout.git --version ">0.0.2 <=2.0.1"

Added git@github.com:modulo-dm/test-checkout.git.  Run the `update` command to complete the process.
```

You'll notice here that a semver range was used as the version.  That means that `modulo update` will get the latest tag that satisfies the specified range.  You can combine this process into a single step by specifying `--update` on the command line.

By default Modulo only works with versions or version ranges, however if you'd like to manage this yourself the `--unmanaged` flag becomes useful.

```bash
$ modulo add --unmanaged git@github.com:modulo-dm/test-init.git

Added git@github.com:modulo-dm/test-init.git.  Run the `update` command to complete the process.
```

At this point the developer would be responsible for choosing which branch/commit/tag `test-init` is set to.  The `update` command that would follow will simply perform a pull operation to bring the latest down.

### Updating dependencies

Use the `update` command.  In instances where the dependency doesn't exist on the filesystem yet, Modulo will clone it to either `.\modules` or `..\` depending on whether you're working on an application or a module.  If the dependency does exist on the filesystem, a clone will be performed.  Once either of those complete, it will checkout the version necessary.

```bash
$ modulo update --all

working on: test-init...
working on: test-dep1...
working on: test-dep2...
working on: test-init...
```

### Mapping the Dependency Tree

By using the `map` command, Modulo can help provide you with a visual view of your dependency tree.

```bash
$ modulo map
Dependencies for `test-add`:
  │
  ├─ name    : test-init
  │  explicit: true
  │  used by : test-dep2
  │
  └─ name    : test-dep1
     explicit: true
     │
     └─ name    : test-dep2
        explicit: false
        used by : test-dep1
        │
        └─ name    : test-init
           explicit: true
           used by : test-dep2
```

As you can see here, test-init is used twice within the tree.  Once by `test-add` itself, and yet again by `test-dep2`.  This also shows explicit vs. implicit dependencies.  Explicit being that `test-add` specifically requires `test-dep1` directly, whereas `test-dep2` is only present because `test-dep1` needs it.
