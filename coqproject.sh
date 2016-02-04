#!/bin/bash

### coqproject.sh
### Creates a _CoqProject file, including external dependencies.

## Configuration options

# External dependencies
DEPS=()

# Directories containing coq files
DIRS=(.)

# Namespaces corresponding to directories. By default, everything is in "".
# To put "theories" in the "FermatsTheorem" namespace:
# NAMESPACE_theories=FermatsTheorem

## Implementation

COQPROJECT_TMP=_CoqProject.tmp

rm -f $COQPROJECT_TMP

for dep in ${DEPS[@]}; do
    path_var="$dep"_PATH
    path=${!path_var:="../$dep"}
    if [ ! -d "$path" ]; then
        echo "$dep not found at $path."
        exit 1
    fi

    pushd "$path" > /dev/null
    path=$(pwd)
    popd > /dev/null
    echo "$dep found at $path"
    LINE="-Q $path $dep"
    echo $LINE >> $COQPROJECT_TMP
done

for dir in ${DIRS[@]}; do
    namespace_var=NAMESPACE_"$dir"
    namespace=${!namespace_var:="\"\""}
    LINE="-Q $dir $namespace"
    echo $LINE >> $COQPROJECT_TMP
done

for dir in ${DIRS[@]}; do
    echo >> $COQPROJECT_TMP
    find $dir -iname '*.v'  >> $COQPROJECT_TMP
done

mv $COQPROJECT_TMP _CoqProject
