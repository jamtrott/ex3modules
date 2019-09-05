#!/usr/bin/env bash
#
# Build mumps
#
# The following command will build the module, write a module file,
# and temporarily install them to your home directory, so that you may
# test them before moving them to their final destinations:
#
#   DESTDIR=$HOME ./build.sh 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/$prefix/$modulefilesdir
#   MODULES_PREFIX=$HOME module load mumps
#
set -x -o errexit

pkg_name=mumps
pkg_version=5.2.1
pkg_moduledir=${pkg_name}/gcc/${pkg_version}
pkg_description="MUltifrontal Massively Parallel sparse direct Solver"
pkg_url="http://mumps.enseeiht.fr/"
src_url=http://mumps.enseeiht.fr/MUMPS_${pkg_version}.tar.gz
src_dir=MUMPS_${pkg_version}

# Load build-time dependencies and determine prerequisite modules
while read module; do module load ${module}; done <build_deps
pkg_prereqs=$(while read module; do echo "module load ${module}"; done <prereqs)

# Set default options
prefix=/cm/shared/apps
modulefilesdir=modulefiles

# Parse program options
help() {
    printf "Usage: $0 [option...]\n"
    printf " Build %s\n\n" "${pkg_name}-${pkg_version}"
    printf " Options are:\n"
    printf "  %-20s\t%s\n" "-h, --help" "display this help and exit"
    printf "  %-20s\t%s\n" "--prefix=PREFIX" "install files in PREFIX [${prefix}]"
    printf "  %-20s\t%s\n" "--modulefilesdir=DIR" "module files [PREFIX/${modulefilesdir}]"
    exit 1
}
while [ "$#" -gt 0 ]; do
    case "$1" in
	-h | --help) help; exit 0;;
	--prefix=*) prefix="${1#*=}"; shift 1;;
	--modulefilesdir=*) modulefilesdir="${1#*=}"; shift 1;;
	--) shift; break;;
	-*) echo "unknown option: $1" >&2; exit 1;;
	*) handle_argument "$1"; shift 1;;
    esac
done

# Set up installation paths
pkg_prefix=${prefix}/${pkg_moduledir}

# Set up build and temporary install directories
build_dir=$(mktemp -d -t ${pkg_name}-${pkg_version}-XXXXXX)
mkdir -p ${build_dir}

# Download package
src_pkg=${build_dir}/$(basename ${src_url})
curl --fail -Lo ${src_pkg} ${src_url}

# Unpack
tar -C ${build_dir} -xzvf ${src_pkg}

# Build
pushd ${build_dir}/${src_dir}

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
mkdir -p ${DESTDIR}${pkg_prefix}
cp -r include ${DESTDIR}${pkg_prefix}
cp -r lib ${DESTDIR}${pkg_prefix}
mkdir -p ${DESTDIR}${pkg_prefix}/share
cp -r doc ${DESTDIR}${pkg_prefix}/share
popd

# Write the module file
pkg_modulefile=${DESTDIR}${prefix}/${modulefilesdir}/${pkg_moduledir}
mkdir -p $(dirname ${pkg_modulefile})
echo "Writing module file ${pkg_modulefile}"
cat >${pkg_modulefile} <<EOF
#%Module
# ${pkg_name} ${pkg_version}

proc ModulesHelp { } {
     puts stderr "\tSets up the environment for ${pkg_name} ${pkg_version}\n"
}

module-whatis "${pkg_description}"
module-whatis "${pkg_url}"

${pkg_prereqs}

set MODULES_PREFIX [getenv MODULES_PREFIX ""]
setenv ${pkg_name^^}_ROOT \$MODULES_PREFIX${pkg_prefix}
setenv ${pkg_name^^}_INCDIR \$MODULES_PREFIX${pkg_prefix}/include
setenv ${pkg_name^^}_INCLUDEDIR \$MODULES_PREFIX${pkg_prefix}/include
setenv ${pkg_name^^}_LIBDIR \$MODULES_PREFIX${pkg_prefix}/lib
setenv ${pkg_name^^}_LIBRARYDIR \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
set MSG "${pkg_name} ${pkg_version}"
EOF
