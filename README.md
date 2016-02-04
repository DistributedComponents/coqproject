# coqproject.sh

This is a simple script to create a _CoqProject file for a Coq
development, including external dependencies and namespaces. The
resulting file should work with `coq_makefile`, Proof General, and
CoqIde. Users can set environment variables to configure the paths to
external dependencies.

The easiest thing is probably to run `coqproject.sh` as part of a
"configure" step before running `make`; that way, users only have to
configure paths to dependencies once. Note that it will have to be
re-run any time a file is added to the project.

A sample `Makefile` is included as well.
