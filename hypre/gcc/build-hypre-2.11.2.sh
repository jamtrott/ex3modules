#!/bin/bash

# Package details
PKG_NAME=hypre
PKG_VERSION=2.11.2
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-${PKG_VERSION}.tar.gz
SRC_DIR=${PKG_NAME}-${PKG_VERSION}/src

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load numactl/gcc/2.0.12
module load openblas/dynamic/0.3.7
module load openmpi/gcc/64/4.0.1

# Set up build and temporary install directories
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
./configure \
	    --prefix=${PKG_INSTALL_DIR} \
	    --enable-shared \
	    --with-blas-lib-dirs=${BLASDIR} --with-blas-libs=${BLASLIB} \
	    --with-lapack-lib-dirs=${BLASDIR} --with-lapack-libs=${BLASLIB} \
	    CFLAGS="-O3"
make -j 20
make install prefix=${DESTDIR}
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/include ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/lib ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
