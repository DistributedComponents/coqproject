# coqproject.sh

This is a simple script to create a `_CoqProject` file for a
[Coq](https://coq.inria.fr) development, including external
dependencies and namespaces. The resulting file should work with
[`coq_makefile`](https://coq.inria.fr/distrib/current/refman/tools.html#Makefile),
[Proof General](https://proofgeneral.github.io), and
[CoqIDE](https://coq.inria.fr/distrib/current/refman/coqide.html).
Users can set environment variables to configure the paths to
external dependencies; see below for more details.

## Getting Started

The easiest thing is probably to run `coqproject.sh` as part of a
"configure" step before running `make`; that way, users only have to
configure paths to dependencies once. A configure script might look
like this:

```bash
DIRS=(theories)
CANARIES=("mathcomp.ssreflect.ssreflect" "Ssreflect missing")
source script/coqproject.sh
```

The configure script sources `coqproject.sh` instead of running it so
that environment variables are handled correctly (bash currently
doesn't support exporting array variables such as `DIRS` and
`CANARIES`). This script will have to be re-run any time a file is
added to the project.

A sample `Makefile` is included as well.

## Controlling `coqproject.sh`

### External dependencies

The `DEPS` variables is a list of external dependencies for the
project. For example, the following records a dependency on the library
`Verdi`:

```bash
DEPS=(Verdi)
```

Each element of the list names a dependency.  By default, each
dependency is expected to be found in Coq's global `user-contrib` directory.
To customize this location for a dependency `X`, set the environment
variable `X_PATH`. For example, if `Verdi` is located in
`/path/to/verdi`, then set:

```bash
Verdi_PATH=/path/to/verdi
```

`coqproject.sh` will exit with an error if a dependency is not found
at its indicated path.


### Subdirectories containing Coq files

The `DIRS` variable is a list of subdirectories of the project that
contain Coq source files. If `DIRS` is not set, it defaults to `(.)`,
the list containing just the current directory. For each directory `D`
in the list, `coqproject.sh` will emit a line instructing Coq to look
in that directory for source files.

For example, if a project contains two subdirectories `A` and `B`,
then setting
```bash
DIRS=(A B)
```
will do the right thing.

Dependencies in the `DEPS` variable can also be associated with
subdirectories. For example, if the dependency `Verdi` has
subdirectories `core` and `lib`, setting
```bash
Verdi_DIRS=(core lib)
```
will reflect this.

By default, files from all directories are put in the empty namespace,
but this can be customized by setting the `NAMESPACE_X` variable.

For example, if the project imports modules from the `A` subdirectory
with namespace `Foo`, but imports modules from the `B` subdirectory with
the empty namespace, then the configure script should include
```bash
NAMESPACE_A=Foo
```

Note that "." can't be part of a variable name, so it's replaced by "_".
So, to put the current directory in the namespace `Bar`, set
```bash
NAMESPACE__=Bar
```

Directories (and subdirectories) of dependencies can also be associated
with namespaces. For example, if the `lib` subdirectory of `Verdi`
should be in the `Lib` namespace, set
```bash
NAMESPACE_Verdi_lib=Lib
```

### Report missing dependencies

Some libraries are expected to always be installed globally in Coq's
`user-contrib` directory, e.g. `ssreflect`. `coqproject.sh` supports
checking for these libraries using canaries, which test whether
a given module can be imported.

The variable `CANARIES` contains a list, conceptually grouped into
pairs, where the first element of each pair is a module name, and the
second element is a message to print if the module fails to import.

For example, if a project depends on `ssreflect` being globally
installed, setting
```bash
CANARIES=("mathcomp.ssreflect.ssreflect" "Ssreflect missing")
```
will try to import `mathcomp.ssreflect.ssreflect` and report an error
if it is not found.

### Extra files

`coqproject.sh` works by searching for `.v` files in every directory
given in `DIRS`, but there may be `.v` files that do not exist at
configure time, and thus will not be found. These extra files can be
declared in the variable `EXTRA`, which is a list of files to be
added to `_CoqProject`.

For example, if a project automatically generates a file `Foo.v` that
is not present at configure time, then including
```bash
EXTRA=(GeneratedFile.v)
```
will ensure that `coq_makefile` knows about this file.
