#!/usr/bin/env bash
#
# Build all missing modules
# In order to be able to determine which modules are already installed, the
# user should make sure to add the modulefiles directory in the install
# prefix directory to the modulepath.
#
# Example usage: Build and install modules and module files to the
# current user's home directory:
#
#   ./build-all-missing.sh --prefix=$HOME
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
echo $modules
for module in $modules; do
    if module is-avail "${module}"; then 
        echo "Skipping building of ${module}, since it has already been built"
    else
        ./build.sh --build-dependencies "$@" ${module}
    fi
done
