modulo-init(1) -- Initialize a project for use with Modulo.
====

## SYNOPSIS

`modulo init` [--app]<br />
`modulo init` [--module]<br />

## DESCRIPTION

This command initializes a project/directory for use with Modulo.  A `.modulo` file is created to track dependencies, and other details.  The two modes of operation are documented below.

## OPTIONS

* `--app`:
    Initializes modulo as an application.  Any dependencies will be located in `.\modules` upon add/update.

* `--module`:
    Initializes modulo as an module.  Any dependencies will be located in `..\` upon add/update.

* `-v, --verbose`:
    Prints verbose output.  Use this to see what underlying SCM commands are being used and any other important information.

* `-h, --help`:
    Prints the help for this command.

## SEE ALSO

modulo-layout(1), modulo-add(1)

## REPORTING BUGS

Report bugs to the Github Project located at https://github.com/modulo-dm/modulo/.  You'll be able to see the status and track any issues you create.

## AUTHORS

    Brandon Sneed <brandon@redf.net>
    Peat Bakke <peat@peat.org>


