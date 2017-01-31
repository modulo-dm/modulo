modulo-update(1) -- Update the project based on the current set of dependencies.
====

## SYNOPSIS

`modulo update` [--all]<br />
`modulo update` <dependencyname><br />

## DESCRIPTION

This command updates any previously specified dependencies.  Updates can consist of the following:

* Cloning any dependencies that don't exist in the filesystem yet.
* Performing a fetch on dependencies to get any new tags/branches/commits
* Verifying that it's safe to check out the specified tag/branch/commit.
* Checking out the specified tag/branch/commit for each dependency.

## OPTIONS

* `--all`:
This will iterate through all dependencies and perform an update.

* <dependencyname>:
Instructs Modulo to just perform an update on the specified dependency.  See `map` for a list of dependencies.

* `--meh`:
Update will perform a no-op if modulo isn't being used on this project.  Useful for build system integration.

* `-v, --verbose`:
Prints verbose output.  Use this to see what underlying SCM commands are being used and any other important information.

* `-h, --help`:
Prints the help for this command.

## SEE ALSO

modulo-layout(1), modulo-map(1)

## REPORTING BUGS

Report bugs to the Github Project located at https://github.com/modulo-dm/modulo/.  You'll be able to see the status and track any issues you create.

## AUTHORS

Brandon Sneed <brandon@redf.net><br />
Peat Bakke <peat@peat.org><br />


