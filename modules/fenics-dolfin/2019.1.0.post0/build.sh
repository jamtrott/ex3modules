#!/usr/bin/env bash
#
# Build dolfin
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
#   MODULES_PREFIX=$HOME module load dolfin
#
set -x -o errexit

. ../../../common/module.sh

pkg_name=dolfin
pkg_version=2019.1.0.post0
pkg_moduledir="fenics-${pkg_name}/${pkg_version}"
pkg_description="C++ interface to the FEniCS computing platform for solving partial differential equations"
pkg_url="https://bitbucket.org/fenics-project/dolfin/"
src_url="https://bitbucket.org/fenics-project/dolfin/downloads/dolfin-${pkg_version}.tar.gz"
src_dir="${pkg_name}-${pkg_version}"

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

    # Build
    pushd "${pkg_build_dir}/${src_dir}"
    mkdir -p build
    pushd build
    cmake .. \
	  -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
	  -DCMAKE_INSTALL_PREFIX="${pkg_prefix}" \
	  -DBUILD_SHARED_LIBS=TRUE \
	  -DEIGEN3_INCLUDE_DIR="${EIGEN_ROOT}/include/eigen3" \
	  -DPARMETIS_DIR="${PARMETIS_ROOT}" \
	  -DSCOTCH_DIR="${SCOTCH_ROOT}" \
	  -DAMD_DIR="${SUITESPARSE_ROOT}" \
	  -DCHOLMOD_DIR="${SUITESPARSE_ROOT}" \
	  -DUMFPACK_DIR="${SUITESPARSE_ROOT}"
    make -j"${JOBS}"
    make install DESTDIR="${DESTDIR}"
    popd
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
prepend-path PKG_CONFIG_PATH \$MODULES_PREFIX${pkg_prefix}/lib/pkgconfig
prepend-path CMAKE_MODULE_PATH \$MODULES_PREFIX${pkg_prefix}/share/dolfin/cmake
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
