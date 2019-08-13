#!/bin/bash

# Package details
PKG_NAME=suitesparse
PKG_VERSION=5.4.0
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-${PKG_VERSION}.tar.gz
SRC_DIR=SuiteSparse

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load openblas/dynamic/0.3.7

# Set up build and install directories
OUT_DIR=$(mktemp -d -t ${PKG_NAME}-${PKG_VERSION}-XXXXXX)
BUILD_DIR=${OUT_DIR}/build
DESTDIR=${OUT_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${DESTDIR}

# Download package
SRC_PKG=${BUILD_DIR}/${PKG_NAME}-${PKG_VERSION}.tar.gz
curl -o ${SRC_PKG} ${SRC_URL}

# Unpack
tar -C ${BUILD_DIR} -xzvf ${SRC_PKG}

# Build
pushd ${BUILD_DIR}/${SRC_DIR}
JOBS=20 make BLAS="-L$BLASDIR -l$BLASLIB" LAPACK=""
make install BLAS="-L$BLASDIR -l$BLASLIB" LAPACK="" INSTALL=${DESTDIR}
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/bin ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/include ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/lib ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/share ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
