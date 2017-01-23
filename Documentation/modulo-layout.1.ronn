modulo-layout(1) -- Explains the file system layout
====

## RELATIONSHIPS

Modulo understands relationships between _modules_ and _applications_. Modules may be dependent as peers, whereas an application depends on a set of modules:

    Module -> [Module, Module, ...]
    Application -> [Module, Module, ...]

(Note: nothing can be dependent on an application)

As an example, let's consider an application named "Fancy App" that depends on some shared components and media assets. To make it a little more complicated, one of the shared components also depends on a utility library.

In other words, there are two sets of dependencies to be managed:

    Fancy App -> [Component A, Component B, Assets]
    Component A -> [Utilities]

These dependencies will get arranged directory structure as such:

    Fancy App/
    modules/
    Component A/
    Component B/
    Utilities/
    Assets/

Note that "Fancy App" is the root, and that all of the modules are checked out into the `modules/` directory, including the `Utilities` dependency.

To put a twist on this scenario, if you're developing on `Component A` in isolation, and you only want to check it out with it's dependencies, you would end up with a directory structure like this:

    Component A/
    Utilities/

... Where `Component A` and `Utilities` are peers in the file system.

## SEE ALSO

modulo(1), modulo-init(1), modulo-update(1)

## REPORTING BUGS

Report bugs to the Github Project located at https://github.com/modulo-dm/modulo/.  You'll be able to see the status and track any issues you create.

## AUTHORS

    Brandon Sneed <brandon@redf.net>
    Peat Bakke <peat@peat.org>


