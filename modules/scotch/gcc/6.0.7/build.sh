#!/usr/bin/env bash
#
# Build scotch
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
#   MODULES_PREFIX=$HOME module load scotch
#
set -o errexit

. ../../../../common/module.sh

pkg_name=scotch
pkg_version=6.0.7
pkg_moduledir="${pkg_name}/gcc/${pkg_version}"
pkg_description="Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package"
pkg_url="https://www.labri.fr/perso/pelegrin/scotch/"
src_url="https://gforge.inria.fr/frs/download.php/file/38040/${pkg_name}_${pkg_version}.tar.gz"
src_dir="${pkg_name}_${pkg_version}/src"

function main()
{
    # Parse program options
    module_build_parse_command_line_args \
	"${0}" \
	"${pkg_name}" \
	"${pkg_version}" \
	"${pkg_moduledir}" \
	"${pkg_description}" \
	"${pkg_url}" \
	"$@"

    # Load build-time dependencies and determine prerequisite modules
    module_load_build_deps build_deps
    pkg_prereqs=$(module_prereqs prereqs)

    # Download and unpack source
    pkg_prefix=$(module_build_prefix "${prefix}" "${pkg_moduledir}")
    pkg_build_dir=$(module_build_create_build_dir "${pkg_name}" "${pkg_version}")
    module_build_download_package "${src_url}" "${pkg_build_dir}"
    module_build_unpack "${pkg_src}" "${pkg_build_dir}"

    # Modify source to allow correct shared library linking
    grep -lr '$(AR) $(ARFLAGS) $(@) $(^)' "${pkg_build_dir}/${src_dir}" | xargs sed -i 's,$(AR) $(ARFLAGS) $(@) $(^),$(AR) $(ARFLAGS) $(@) $(^) $(DYNLDFLAGS),g'
    grep -lr '$(AR) $(ARFLAGS) $(@) $(?)' "${pkg_build_dir}/${src_dir}" | xargs sed -i 's,$(AR) $(ARFLAGS) $(@) $(?),$(AR) $(ARFLAGS) $(@) $(?) $(DYNLDFLAGS),g'

    # Build
    pushd "${pkg_build_dir}/${src_dir}"
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
    make prefix="${DESTDIR}${pkg_prefix}" install
    popd

    # Write the module file
    pkg_modulefile="${DESTDIR}${prefix}/${modulefilesdir}/${pkg_moduledir}"
    mkdir -p $(dirname "${pkg_modulefile}")
    cat >"${pkg_modulefile}" <<EOF
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
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path MANPATH \$MODULES_PREFIX${pkg_prefix}/share/man
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
