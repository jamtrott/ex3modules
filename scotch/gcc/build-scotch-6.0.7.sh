#!/bin/bash

# Package details
PKG_NAME=scotch
PKG_VERSION=6.0.7
MODULEFILE=$(realpath ${PKG_VERSION})
SRC_URL=https://gforge.inria.fr/frs/download.php/file/38040/${PKG_NAME}_${PKG_VERSION}.tar.gz
SRC_DIR=${PKG_NAME}_${PKG_VERSION}/src

# Set up installation paths
INSTALL_DIR=/cm/shared/apps
MODULEFILES_DIR=/cm/shared/modulefiles
PKG_MODULE=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_INSTALL_DIR=${INSTALL_DIR}/${PKG_MODULE}
PKG_MODULE_DIR=$(dirname ${MODULEFILES_DIR}/${PKG_MODULE})

# Load prerequisite modules
module load openmpi/gcc/64/4.0.1

# Set up build and temporary install directories
OUT_DIR=$(mktemp -d -t ${PKG_NAME}-${PKG_VERSION}-XXXXXX)
BUILD_DIR=${OUT_DIR}/build
DESTDIR=${OUT_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${DESTDIR}

# Download package
SRC_PKG=${BUILD_DIR}/${PKG_NAME}_${PKG_VERSION}.tar.gz
curl -o ${SRC_PKG} ${SRC_URL}

# Unpack
tar -C ${BUILD_DIR} -xzvf ${SRC_PKG}

# Modify source to allow correct shared library linking
grep -lr '$(AR) $(ARFLAGS) $(@) $(^)' ${BUILD_DIR}/${SRC_DIR} | xargs sed -i 's,$(AR) $(ARFLAGS) $(@) $(^),$(AR) $(ARFLAGS) $(@) $(^) $(DYNLDFLAGS),g'
grep -lr '$(AR) $(ARFLAGS) $(@) $(?)' ${BUILD_DIR}/${SRC_DIR} | xargs sed -i 's,$(AR) $(ARFLAGS) $(@) $(?),$(AR) $(ARFLAGS) $(@) $(?) $(DYNLDFLAGS),g'

# Build
pushd ${BUILD_DIR}/${SRC_DIR}
cat > Makefile.inc <<'EOF'
EXE             =
LIB             = .so
OBJ             = .o
MAKE            = make
AR              = gcc
ARFLAGS         = -shared -o
CAT             = cat
CCS             = gcc
CCP             = mpicc
CCD             = gcc
CFLAGS          = -O3 -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_PTHREAD -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DSCOTCH_PTHREAD \
-Drestrict=__restrict -DIDXSIZE64
CLIBFLAGS       = -shared -fPIC
LDFLAGS         = -lz -lm -lrt -pthread
DYNLDFLAGS      = $(LDFLAGS)
CP              = cp
LEX             = flex -Pscotchyy -olex.yy.c
LN              = ln
MKDIR           = mkdir -p
MV              = mv
RANLIB          = echo
YACC            = bison -pscotchyy -y -b y
EOF
make scotch ptscotch esmumps ptesmumps --jobs=1 # Parallel builds not supported
make prefix=${DESTDIR} install
popd

echo "To install ${PKG_NAME}-${PKG_VERSION}:"
echo "  mkdir -p ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/bin ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/include ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/lib ${PKG_INSTALL_DIR}"
echo "  cp -r ${DESTDIR}/share ${PKG_INSTALL_DIR}"
echo "  mkdir -p ${PKG_MODULE_DIR}"
echo "  cp ${MODULEFILE} ${PKG_MODULE_DIR}"
