#!/usr/bin/env bash
#
# Build knem
#
# The following command will build the module, write a module file,
# and install them to the directory 'modules' in your home directory:
#
#   build.sh --prefix=$HOME/modules 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/modules/modulefiles
#   module load knem
#
set -o errexit

pkg_name=knem
pkg_version=1.1.3
pkg_moduledir="${pkg_name}/${pkg_version}"
pkg_description="High-Performance Intra-Node MPI Communication"
pkg_url="http://knem.gforge.inria.fr/"
src_url="https://scm.gforge.inria.fr/anonscm/git/knem/knem.git"
src_dir="${pkg_name}"

function main()
{
    . ../../../common/module.sh

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
    git clone "${src_url}" "${pkg_build_dir}/${src_dir}"

    # Build
    pushd "${pkg_build_dir}/${src_dir}"
    ./autogen.sh
    ./configure --prefix="${pkg_prefix}"
    make -j"${JOBS}"
    make install
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

setenv ${pkg_name^^}_ROOT ${pkg_prefix}
setenv ${pkg_name^^}_INCDIR ${pkg_prefix}/include
setenv ${pkg_name^^}_INCLUDEDIR ${pkg_prefix}/include
setenv ${pkg_name^^}_LIBDIR ${pkg_prefix}/lib
setenv ${pkg_name^^}_LIBRARYDIR ${pkg_prefix}/lib
prepend-path PATH ${pkg_prefix}/bin
prepend-path C_INCLUDE_PATH ${pkg_prefix}/include
prepend-path CPLUS_INCLUDE_PATH ${pkg_prefix}/include
prepend-path LIBRARY_PATH ${pkg_prefix}/lib
prepend-path LD_LIBRARY_PATH ${pkg_prefix}/lib
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
