#!/bin/bash

# Package details
PKG_NAME=mumps
PKG_VERSION=5.2.1
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=http://mumps.enseeiht.fr/MUMPS_${PKG_VERSION}.tar.gz
SRC_DIR=MUMPS_${PKG_VERSION}

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load openblas/dynamic/0.3.7
module load openmpi/gcc/64/4.0.1
module load numactl/gcc/2.0.12
module load metis/gcc/5.1.0
module load parmetis/gcc/4.0.3
module load scotch/gcc/6.0.7
module load scalapack/gcc/2.0.2

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

# Write Makefile.inc
cat > Makefile.inc <<'EOF'
# Begin orderings
ISCOTCH=-I${SCOTCH_INCDIR}
LSCOTCH=-L${SCOTCH_LIBDIR} -lptesmumps -lptscotch -lscotch -lptscotcherr

LPORDDIR=$(topdir)/PORD/lib/
IPORD=-I$(topdir)/PORD/include/ -isystem$(topdir)/PORD/include
LPORD=-L$(LPORDDIR) -lpord

IMETIS=-I${PARMETIS_INCDIR} -I${METIS_INCDIR}
LMETIS=-L${PARMETIS_LIBDIR} -lparmetis -L${METIS_LIBDIR} -lmetis

# Corresponding variables reused later
ORDERINGSF=-Dmetis -Dpord -Dparmetis -Dscotch -Dptscotch
ORDERINGSC=$(ORDERINGSF)

LORDERINGS=$(LMETIS) $(LPORD) $(LSCOTCH)
IORDERINGSF=$(ISCOTCH)
IORDERINGSC=$(IMETIS) $(IPORD) $(ISCOTCH)
# End orderings
################################################################################

PLAT    =
LIBEXT  = .so
OUTC    = -o
OUTF    = -o
RM = /bin/rm -f
CC = mpicc
FC = mpif90
FL = mpif90
AR = $(CC) -shared -o 
RANLIB = echo
LAPACK = -l$(BLASLIB)
SCALAP  = -lscalapack

INCPAR = # not needed with mpif90/mpicc:  -I/usr/include/openmpi

LIBPAR = $(SCALAP) $(LAPACK) # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi

INCSEQ = -I$(topdir)/libseq
LIBSEQ  = $(LAPACK) -L$(topdir)/libseq -lmpiseq

LIBBLAS = -l$(BLASLIB)
LIBOTHERS = -lpthread

#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)
CDEFS   = -DAdd_

#Begin Optimized options
OPTF    = -fPIC -O3 -fopenmp
OPTL    = -fPIC -O3 -fopenmp
OPTC    = -fPIC -O3 -fopenmp
#End Optimized options

INCS = $(INCPAR)
LIBS = $(LIBPAR)
LIBSEQNEEDED =
EOF

make alllib
mkdir -p ${DESTDIR}/${PKG_INSTALL_DIR}
cp -r include ${DESTDIR}/${PKG_INSTALL_DIR}
cp -r lib ${DESTDIR}/${PKG_INSTALL_DIR}
mkdir -p ${DESTDIR}/${PKG_INSTALL_DIR}/share
cp -r doc ${DESTDIR}/${PKG_INSTALL_DIR}/share
popd


echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/${PKG_INSTALL_DIR}/* ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
