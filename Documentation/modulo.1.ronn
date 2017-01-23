modulo(1) -- A source-only dependency manager
====

## SYNOPSIS  

`modulo` [--version] [--help]

## DESCRIPTION  

Modulo is a source-only dependency manager. Its primary goal is to orchestrate repositories and filesystem assets for large, modular projects. For example, collections of services or libraries or components that have versioned dependencies between themselves.

Modulo manages collections of dependent, versioned repositories. It leaves build concerns to build systems (eg: Xcode, Xcodebuild, Maven, make, etc), and is designed to be agnostic about source code management systems (eg: Git, Subversion*).

A formatted and hyperlinked copy of the latest Modulo documentation can be viewed at https://github.com/modulo-dm/modulo

\* only git is currently supported at the moment, others to follow

## OPTIONS

* `--version`: 
    Prints the Modulo version number.

* `-h, --help`:
    Prints the synopsis and a list of the most commonly used commands.

## MODULO COMMANDS

We divide modulo into high level commands, each with their own `--help` information.

* `modulo-init(1)`:
    Initialize Modulo for a given project.

* `modulo-add(1)`:
    Add a dependency to a given project.

* `modulo-update(1)`:
    Update dependencies on a given project.

* `modulo-remove(1)`:
    Remove dependency from a given project.

* `modulo-status(1)`:
    Shows the overall status of a project and it's dependencies.

* `modulo-map(1)`:
    Display a map of the dependency tree for a given project.

## FILE/DIRECTORY STRUCTURE  

Please see `modulo-layout(1)`

## REPORTING BUGS  

Report bugs to the Github Project located at https://github.com/modulo-dm/modulo/.  You'll be able to see the status and track any issues you create.

## AUTHORS  

Brandon Sneed <brandon@redf.net>  
Peat Bakke <peat@peat.org>


