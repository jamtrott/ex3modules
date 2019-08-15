#!/bin/bash

# Package details
PKG_NAME=eigen
PKG_VERSION=3.3.7
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=http://bitbucket.org/eigen/eigen/get/${PKG_VERSION}.tar.gz
SRC_DIR=eigen-eigen-323c052e1731

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load boost/gcc/1.70.0
module load mpfr/gcc/4.0.2
module load gmp/gcc/6.1.2
module load suitesparse/gcc/5.4.0
module load openblas/dynamic/0.3.7
module load superlu/gcc/5.2.1

# Set up build and temporary install directories
OUT_DIR=$(mktemp -d -t ${PKG_NAME}-${PKG_VERSION}-XXXXXX)
BUILD_DIR=${OUT_DIR}/build
DESTDIR=${OUT_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${DESTDIR}

# Download package
SRC_PKG=${BUILD_DIR}/${PKG_NAME}-${PKG_VERSION}.tar.gz
curl -Lo ${SRC_PKG} ${SRC_URL}

# Unpack
tar -C ${BUILD_DIR} -xzvf ${SRC_PKG}

# Build
pushd ${BUILD_DIR}/${SRC_DIR}
mkdir -p build
cd build
cmake .. \
      -DCMAKE_INSTALL_PREFIX="${PKG_INSTALL_DIR}" \
      -DMPFR_INCLUDES="${MPFRDIR}/include" \
      -DMPFR_LIBRARIES="${MPFRLIB}/libmpfr.so" \
      -DGMP_INCLUDES="${GMPDIR}/include" \
      -DGMP_LIBRARIES="${GMPLIB}/libgmp.so" \
      -DCHOLMOD_INCLUDES="${SUITESPARSE_INCDIR}" \
      -DCHOLMOD_LIBRARIES="${SUITESPARSE_LIBDIR}/libcholmod.so" \
      -DUMFPACK_INCLUDES="${SUITESPARSE_INCDIR}" \
      -DUMFPACK_LIBRARIES="${SUITESPARSE_LIBDIR}/libumfpack.so" \
      -DSUPERLU_INCLUDES="${SUPERLU_INCDIR}" \
      -DSUPERLU_LIBRARIES="${SUPERLU_LIBDIR}/libsuperlu.so" \
      -DCMAKE_CXX_FLAGS="-O3 -march=core-avx2"
make
make install DESTDIR=${DESTDIR}
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/* ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
