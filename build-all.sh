#!/usr/bin/env bash
#
# Build all modules
#
# Example usage: Build and install modules and module files to the
# current user's home directory:
#
#   ./build.sh --prefix=$HOME
#
# The newly installed modules can be made available by executing the
# following command:
#
#   module use $HOME/modulefiles
#
#
set -o errexit

build_files=$(find modules -name build.sh)
modules=$(
    for f in ${build_files}; do
	echo "${f}" | sed -e "s/^modules\///" -e "s/\/build.sh$//";
    done)

./build.sh --build-dependencies "$@" ${modules}
