#!/bin/bash

### coqproject.sh
### Creates a _CoqProject file, including external dependencies.

## Configuration options
# External dependencies
# e.g. DEPS = (StructTact)

# Directories containing coq files
# e.g. DIRS=(theories)
if [ -z ${DIRS+x} ]; then DIRS=(.); fi

# Canary imports, along with error messages if imports fail
# e.g. CANARIES=("mathcomp.ssreflect.ssreflect" "Ssreflect missing")

# Namespaces corresponding to directories. By default, everything is in "".
# To put "theories" in the "FermatsTheorem" namespace:
#   NAMESPACE_theories=FermatsTheorem
# Note that "." can't be part of a variable name, so it's replaced by "_".
# So, to put the current directory in the "FermatsTheorem" namespace:
#   NAMESPACE__=FermatsTheorem

# Extra files (e.g. automatically-generated .v files that won't be
# around at configure-time)
# e.g. EXTRA=(GeneratedFile.v)
## Implementation

COQPROJECT_TMP=_CoqProject.tmp

rm -f $COQPROJECT_TMP
touch $COQPROJECT_TMP
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

COQTOP="coqtop $(cat $COQPROJECT_TMP)"
function check_canary(){
    echo "Require Import $@." | $COQTOP 2>&1 | grep -i error 1> /dev/null 2>&1 
}
i=0
len="${#CANARIES[@]}"
while [ $i -lt $len ]; do
    if check_canary ${CANARIES[$i]}; then
        echo "Error: ${CANARIES[$((i + 1))]}"
        exit 1
    fi
    let "i+=2"
done

for dir in ${DIRS[@]}; do
    namespace_var=NAMESPACE_"$dir"
    namespace_var=${namespace_var//./_}
    namespace=${!namespace_var:="\"\""}
    LINE="-Q $dir $namespace"
    echo $LINE >> $COQPROJECT_TMP
done

for dir in ${DIRS[@]}; do
    echo >> $COQPROJECT_TMP
    find $dir -iname '*.v'  >> $COQPROJECT_TMP
done

for extra in ${EXTRA[@]}; do
    if ! grep --quiet "^$extra\$" $COQPROJECT_TMP; then
        echo >> $COQPROJECT_TMP
        echo $extra >> $COQPROJECT_TMP
    fi
done


mv $COQPROJECT_TMP _CoqProject
