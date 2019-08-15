#!/bin/bash

# Package details
PKG_NAME=petsc
PKG_VERSION=3.11.3
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${PKG_VERSION}.tar.gz
SRC_DIR=${PKG_NAME}-${PKG_VERSION}

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load boost/gcc/1.70.0
module load openblas/dynamic/0.3.7
module load openmpi/gcc/64/4.0.1
module load hwloc/gcc/2.0.4
module load hypre/gcc/2.17.0
module load metis/gcc/5.1.0
module load mumps/gcc/5.2.1
module load parmetis/gcc/4.0.3
module load scalapack/gcc/2.0.2
module load scotch/gcc/6.0.7
module load suitesparse/gcc/5.4.0
module load superlu/gcc/5.2.1
module load superlu_dist/gcc/6.1.1

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
COPTFLAGS="-O3"
CXXOPTFLAGS="-O3"
FOPTFLAGS="-O3"
./configure \
    --prefix=${PKG_INSTALL_DIR} \
    --with-cxx-dialect=C++11 \
    --with-openmp=1 \
    --with-blaslapack-lib=${BLASDIR}/lib${BLASLIB}.so \
    --with-boost --with-boost-dir=${BOOST_ROOT} \
    --with-hwloc --with-hwloc-dir=${HWLOC_ROOT} \
    --with-hypre --with-hypre-dir=${HYPRE_ROOT} \
    --with-metis --with-metis-dir=${METIS_ROOT} \
    --with-mpi --with-mpi-dir=${MPI_HOME} \
    --with-mumps --with-mumps-dir=${MUMPS_ROOT} \
    --with-parmetis --with-parmetis-dir=${PARMETIS_ROOT} \
    --with-ptscotch --with-ptscotch-dir=${SCOTCH_ROOT} --with-ptscotch-libs=libz.so \
    --with-scalapack --with-scalapack-dir=${SCALAPACK_ROOT} \
    --with-suitesparse --with-suitesparse-dir=${SUITESPARSE_ROOT} \
    --with-superlu --with-superlu-dir=${SUPERLU_ROOT} \
    --with-superlu_dist --with-superlu_dist-dir=${SUPERLU_DIST_ROOT} \
    --with-x=0 \
    --with-debugging=0 \
    COPTFLAGS=${COPTFLAGS} \
    CXXOPTFLAGS=${CXXOPTFLAGS} \
    FOPTFLAGS=${FOPTFLAGS}
make -j
make install DESTDIR=${DESTDIR}
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/* ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
