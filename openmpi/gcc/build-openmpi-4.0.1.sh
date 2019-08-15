#!/bin/bash

# Package details
PKG_NAME=openmpi
PKG_VERSION=4.0.1
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-${PKG_VERSION}.tar.bz2
SRC_DIR=${PKG_NAME}-${PKG_VERSION}

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load knem/gcc/1.1.3

# Set up build and temporary install directories
OUT_DIR=$(mktemp -d -t ${PKG_NAME}-${PKG_VERSION}-XXXXXX)
BUILD_DIR=${OUT_DIR}/build
DESTDIR=${OUT_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${DESTDIR}

# Download package
SRC_PKG=${BUILD_DIR}/${PKG_NAME}-${PKG_VERSION}.tar.bz2
curl -Lo ${SRC_PKG} ${SRC_URL}

# Unpack
tar -C ${BUILD_DIR} -xjvf ${SRC_PKG}

# Build
pushd ${BUILD_DIR}/${SRC_DIR}
./configure \
    --prefix=${PKG_INSTALL_DIR} \
    --with-mxm=/opt/mellanox/mxm \
    --with-pmi=/cm/shared/apps/slurm/18.08.4/ \
    --enable-mpi-cxx \
    --enable-mpi-fortran=all \
    --enable-mpi1-compatibility \
    --with-knem=${KNEM_ROOT}
make -j
make install DESTDIR=${DESTDIR}
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/* ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
