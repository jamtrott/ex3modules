#!/usr/bin/env bash
#
# Build cuda-toolkit
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
#   MODULES_PREFIX=$HOME module load cuda-toolkit
#
set -o errexit

. ../../../common/module.sh

pkg_name=cuda-toolkit
pkg_version=10.1.243
pkg_moduledir="${pkg_name}/${pkg_version}"
pkg_description="Development environment for high performance GPU-accelerated applications"
pkg_url="https://developer.nvidia.com/cuda-toolkit"
src_url="http://developer.download.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.243_418.87.00_linux.run"
src_dir=

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

    # Download source
    pkg_prefix=$(module_build_prefix "${prefix}" "${pkg_moduledir}")
    pkg_build_dir=$(module_build_create_build_dir "${pkg_name}" "${pkg_version}")
    pkg_src="${pkg_build_dir}/$(basename ${src_url})"
    module_build_download_package "${src_url}" "${pkg_src}"

    # Nothing to unpack

    # Build
    pushd "${pkg_build_dir}/${src_dir}"
    mkdir -p "${pkg_prefix}"
    sh "${pkg_src}" \
       --silent \
       --toolkit \
       --toolkitpath="${pkg_prefix}" \
       --defaultroot="${pkg_prefix}"
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
setenv CUDA_ROOT \$MODULES_PREFIX${pkg_prefix}
setenv CUDA_INCDIR \$MODULES_PREFIX${pkg_prefix}/include
setenv CUDA_INCLUDEDIR \$MODULES_PREFIX${pkg_prefix}/include
setenv CUDA_LIBDIR \$MODULES_PREFIX${pkg_prefix}/lib64
setenv CUDA_LIBRARYDIR \$MODULES_PREFIX${pkg_prefix}/lib64
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib64
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib64
prepend-path PKG_CONFIG_PATH \$MODULES_PREFIX${pkg_prefix}/lib/pkgconfig
prepend-path MANPATH \$MODULES_PREFIX${pkg_prefix}/doc/man
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
