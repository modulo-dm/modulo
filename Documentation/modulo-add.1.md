modulo-add(1) -- Initialize a project for use with Modulo.
====

## SYNOPSIS

`modulo add` [-u] <repo_url><br />
`modulo add` --version [-u] <semver> <repo_url><br />
`modulo add` --unmanaged [-u] <repo_url><br />

## DESCRIPTION

This command adds a dependency to the current project.

No cloning of dependencies, etc. takes place here unless `--update` is specified.

## OPTIONS

* `--version` <semver>:
    This option specifies that a semver tag or range should be checked out.  Modulo treats semver as `breaking.feature.fix` since that is more meaningful to most.

    Modulo's semver implementation follows the `npm` implementation very closely.  To read more, visit:

    https://docs.npmjs.com/getting-started/semantic-versioning

* `--unmanaged`:
    This informs modulo that the user will manage branches/commits/tags on their own.  When updating, only a pull from the remote is performed.

* `-u, --update`:
    Immediately perform an `update` after adding the dependency.  This will clone if necessary, as well as perform any dependency compatibility checks.

* `-v, --verbose`:
    Prints verbose output.  Use this to see what underlying SCM commands are being used and any other important information.

* `-h, --help`:
    Prints the help for this command.

## EXAMPLES

`modulo add --version ">=1.1 < 2.0.0" --update git@github.com/something/yadda.git`

This will do the following<br />
*   Add yadda.git as a dependency.<br />
*   Clone yadda.git, because --update was specified.<br />
*   Checkout the latest tag that is greater than or equal to 1.1.0, but less than 2.0.0<br />

`modulo add --unmanaged git@github.com/something/yadda.git`

This will<br />
*   Add yadda.git as a dependency.<br />
*   Record that when performing update, this module is unmanaged, thus only doing a pull operation.<br />

## SEE ALSO

modulo-layout(1), modulo-update(1), modulo-remove(1)

## REPORTING BUGS

Report bugs to the Github Project located at https://github.com/modulo-dm/modulo/.  You'll be able to see the status and track any issues you create.

## AUTHORS

    Brandon Sneed <brandon@redf.net>
    Peat Bakke <peat@peat.org>


