#!/bin/bash -xe
#
# Build parmetis
#
# The following command will build the module, write a module file,
# and temporarily install them to your home directory, so that you may
# test them before moving them to their final destinations:
#
#   DESTDIR=$HOME ./build.sh 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/$PREFIX/$MODULEFILESDIR
#   MODULES_PREFIX=$HOME module load parmetis
#

PKG_NAME=parmetis
PKG_VERSION=4.0.3
PKG_MODULEDIR=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_DESCRIPTION="Parallel Graph Partitioning and Fill-reducing Matrix Ordering"
PKG_URL="http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview"
SRC_URL=http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/${PKG_NAME}-${PKG_VERSION}.tar.gz
SRC_DIR=${PKG_NAME}-${PKG_VERSION}

# Load build-time dependencies and determine prerequisite modules
while read module; do module load ${module}; done <build_deps
PKG_PREREQS=$(while read module; do echo "module load ${module}"; done <prereqs)

# Set default options
PREFIX=/cm/shared/apps
MODULEFILESDIR=modulefiles

# Parse program options
help() {
    printf "Usage: $0 [option...]\n"
    printf " Build %s\n\n" "${PKG_NAME}-${PKG_VERSION}"
    printf " Options are:\n"
    printf "  %-20s\t%s\n" "-h, --help" "display this help and exit"
    printf "  %-20s\t%s\n" "--prefix=PREFIX" "install files in PREFIX [${PREFIX}]"
    printf "  %-20s\t%s\n" "--modulefilesdir=DIR" "module files [PREFIX/${MODULEFILESDIR}]"
    exit 1
}
while [ "$#" -gt 0 ]; do
    case "$1" in
	-h | --help) help; exit 0;;
	--prefix=*) PREFIX="${1#*=}"; shift 1;;
	--modulefilesdir=*) MODULEFILESDIR="${1#*=}"; shift 1;;
	--) shift; break;;
	-*) echo "unknown option: $1" >&2; exit 1;;
	*) handle_argument "$1"; shift 1;;
    esac
done

# Set up installation paths
PKG_PREFIX=${PREFIX}/${PKG_MODULEDIR}

# Set up build and temporary install directories
BUILD_DIR=$(mktemp -d -t ${PKG_NAME}-${PKG_VERSION}-XXXXXX)
mkdir -p ${BUILD_DIR}

# Download package
SRC_PKG=${BUILD_DIR}/$(basename ${SRC_URL})
curl --fail -Lo ${SRC_PKG} ${SRC_URL}

# Unpack
tar -C ${BUILD_DIR} -xzvf ${SRC_PKG}

# Build
pushd ${BUILD_DIR}/${SRC_DIR}

make config shared=1 prefix=${PKG_PREFIX}
make
make install DESTDIR=${DESTDIR}

# Workaround for an issue that causes metis.h to not be installed
# (see http://glaros.dtc.umn.edu/gkhome/node/832).
echo "Copying ${BUILD_DIR}/${SRC_DIR}/build/Linux-x86_64/metis/include/metis.h " \
     "to ${DESTDIR}${PKG_PREFIX}/include"
cp build/Linux-x86_64/metis/include/metis.h ${DESTDIR}${PKG_PREFIX}/include

popd

# Write the module file
PKG_MODULEFILE=${DESTDIR}${PREFIX}/${MODULEFILESDIR}/${PKG_MODULEDIR}
mkdir -p $(dirname ${PKG_MODULEFILE})
echo "Writing module file ${PKG_MODULEFILE}"
cat >${PKG_MODULEFILE} <<EOF
#%Module
# ${PKG_NAME} ${PKG_VERSION}

proc ModulesHelp { } {
     puts stderr "\tSets up the environment for ${PKG_NAME} ${PKG_VERSION}\n"
}

module-whatis "${PKG_DESCRIPTION}"
module-whatis "${PKG_URL}"

${PKG_PREREQS}

set MODULES_PREFIX [getenv MODULES_PREFIX ""]
setenv $(echo "${PKG_NAME}" | tr '[a-z]' '[A-Z]')_ROOT \$MODULES_PREFIX${PKG_PREFIX}
setenv $(echo "${PKG_NAME}" | tr '[a-z]' '[A-Z]')_INCDIR \$MODULES_PREFIX${PKG_PREFIX}/include
setenv $(echo "${PKG_NAME}" | tr '[a-z]' '[A-Z]')_INCLUDEDIR \$MODULES_PREFIX${PKG_PREFIX}/include
setenv $(echo "${PKG_NAME}" | tr '[a-z]' '[A-Z]')_LIBDIR \$MODULES_PREFIX${PKG_PREFIX}/lib
setenv $(echo "${PKG_NAME}" | tr '[a-z]' '[A-Z]')_LIBRARYDIR \$MODULES_PREFIX${PKG_PREFIX}/lib
prepend-path PATH \$MODULES_PREFIX${PKG_PREFIX}/bin
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${PKG_PREFIX}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${PKG_PREFIX}/include
prepend-path LIBRARY_PATH \$MODULES_PREFIX${PKG_PREFIX}/lib
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${PKG_PREFIX}/lib
set MSG "${PKG_NAME} ${PKG_VERSION}"
EOF