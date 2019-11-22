#!/usr/bin/env bash
#
# Build freetype
#
# The following command will build the module, write a module file,
# and temporarily install them to your home directory, so that you may
# test them before moving them to their final destinations:
#
#   build.sh --prefix=$HOME/modules 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/modules/modulefiles
#   module load freetype
#
set -o errexit
source build
build "$@"
