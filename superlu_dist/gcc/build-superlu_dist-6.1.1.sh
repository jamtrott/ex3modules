#!/bin/bash

# Package details
PKG_NAME=superlu_dist
PKG_VERSION=6.1.1
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=https://github.com/xiaoyeli/superlu_dist/archive/v${PKG_VERSION}.tar.gz
SRC_DIR=${PKG_NAME}-${PKG_VERSION}

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load openblas/dynamic/0.3.7
module load openmpi/gcc/64/4.0.1
module load parmetis/gcc/4.0.3

# Set up build and install directories
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
pushd build
CC=mpicc CXX=mpicxx FC=mpifort cmake .. \
      -DCMAKE_INSTALL_PREFIX="${PKG_INSTALL_DIR}" \
      -DBUILD_SHARED_LIBS=TRUE \
      -DTPL_ENABLE_BLASLIB=OFF \
      -DTPL_BLAS_LIBRARIES="${BLASDIR}/lib${BLASLIB}.so" \
      -DTPL_LAPACK_LIBRARIES="${BLASDIR}/lib${BLASLIB}.so" \
      -DTPL_PARMETIS_INCLUDE_DIRS="${PARMETIS_INCDIR}" \
      -DTPL_PARMETIS_LIBRARIES="${PARMETIS_LIBDIR}/libparmetis.so"
make
make install DESTDIR=${DESTDIR}
popd
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/include ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/lib ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
