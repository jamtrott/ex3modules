#!/usr/bin/env bash
#
# Build eigen
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
#   MODULES_PREFIX=$HOME module load eigen
#
set -o errexit

. ../../../../common/module.sh

pkg_name=eigen
pkg_version=3.3.7
pkg_moduledir="${pkg_name}/gcc/${pkg_version}"
pkg_description="C++ template library for linear algebra"
pkg_url="http://eigen.tuxfamily.org/index.php?title=Main_Page"
src_url="http://bitbucket.org/eigen/eigen/get/${pkg_version}.tar.gz"
src_dir="eigen-eigen-323c052e1731"

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
	  -DCMAKE_INSTALL_PREFIX="${pkg_prefix}" \
	  -DMPFR_INCLUDES="${MPFRDIR}/include" \
	  -DMPFR_LIBRARIES="${MPFRLIB}/libmpfr.so" \
	  -DGMP_INCLUDES="${GMPDIR}/include" \
	  -DGMP_LIBRARIES="${GMPLIB}/libgmp.so" \
	  -DCHOLMOD_INCLUDES="${SUITESPARSE_INCDIR}" \
	  -DCHOLMOD_LIBRARIES="${SUITESPARSE_LIBDIR}/libcholmod.so" \
	  -DUMFPACK_INCLUDES="${SUITESPARSE_INCDIR}" \
	  -DUMFPACK_LIBRARIES="${SUITESPARSE_LIBDIR}/libumfpack.so" \
	  -DSUPERLU_INCLUDES="${SUPERLU_INCDIR}" \
	  -DSUPERLU_LIBRARIES="${SUPERLU_LIBDIR}/libsuperlu.so" \
	  -DCMAKE_CXX_FLAGS="-O3"
    make
    make install DESTDIR="${DESTDIR}"
    popd
    popd

    # Write the module file
    pkg_modulefile=$(module_build_modulefile "${prefix}" "${modulefilesdir}" "${pkg_moduledir}")
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
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path PKG_CONFIG_PATH \$MODULES_PREFIX${pkg_prefix}/share/pkgconfig
prepend-path CMAKE_MODULE_PATH \$MODULES_PREFIX${pkg_prefix}/share/eigen3/cmake
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
