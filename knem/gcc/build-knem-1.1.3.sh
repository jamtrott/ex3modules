#!/bin/bash

# Package details
PKG_NAME=knem
PKG_VERSION=1.1.3
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=https://scm.gforge.inria.fr/anonscm/git/knem/knem.git
SRC_DIR=${PKG_NAME}

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Set up build and temporary install directories
OUT_DIR=$(mktemp -d -t ${PKG_NAME}-${PKG_VERSION}-XXXXXX)
BUILD_DIR=${OUT_DIR}/build
DESTDIR=${OUT_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${DESTDIR}

# Download package
git clone https://scm.gforge.inria.fr/anonscm/git/knem/knem.git ${BUILD_DIR}/${SRC_DIR}

# Build
pushd ${BUILD_DIR}/${SRC_DIR}
./autogen.sh
./configure \
    --prefix=${PKG_INSTALL_DIR}
make -j
make install DESTDIR=${DESTDIR}
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/* ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
