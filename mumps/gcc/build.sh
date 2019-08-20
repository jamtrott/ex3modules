#!/bin/bash -xe
#
# Build <module>
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
#   MODULES_PREFIX=$HOME module load <module>
#

PKG_NAME=mumps
PKG_VERSION=5.2.1
PKG_MODULEDIR=${PKG_NAME}/gcc/${PKG_VERSION}
PKG_DESCRIPTION="MUltifrontal Massively Parallel sparse direct Solver"
PKG_URL="http://mumps.enseeiht.fr/"
SRC_URL=http://mumps.enseeiht.fr/MUMPS_${PKG_VERSION}.tar.gz
SRC_DIR=MUMPS_${PKG_VERSION}

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

# Build libraries
make alllib --jobs=1 # Parallel builds are not supported

# Install headers and libraries
mkdir -p ${DESTDIR}${PKG_PREFIX}
cp -r include ${DESTDIR}${PKG_PREFIX}
cp -r lib ${DESTDIR}${PKG_PREFIX}
mkdir -p ${DESTDIR}${PKG_PREFIX}/share
cp -r doc ${DESTDIR}${PKG_PREFIX}/share
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
setenv ${PKG_NAME^^}_ROOT \$MODULES_PREFIX${PKG_PREFIX}
setenv ${PKG_NAME^^}_INCDIR \$MODULES_PREFIX${PKG_PREFIX}/include
setenv ${PKG_NAME^^}_INCLUDEDIR \$MODULES_PREFIX${PKG_PREFIX}/include
setenv ${PKG_NAME^^}_LIBDIR \$MODULES_PREFIX${PKG_PREFIX}/lib
setenv ${PKG_NAME^^}_LIBRARYDIR \$MODULES_PREFIX${PKG_PREFIX}/lib
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${PKG_PREFIX}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${PKG_PREFIX}/include
prepend-path LIBRARY_PATH \$MODULES_PREFIX${PKG_PREFIX}/lib
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${PKG_PREFIX}/lib
set MSG "${PKG_NAME} ${PKG_VERSION}"
EOF
