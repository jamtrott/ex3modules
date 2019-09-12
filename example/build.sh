#!/usr/bin/env bash
#
# Build <module>
#
# The following command will build the module, write a module file,
# and install them to the directory 'modules' in your home directory:
#
#   build.sh --prefix=$HOME/modules 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/modules/modulefiles
#   module load <module>
#
set -o errexit

. ../common/module.sh

pkg_name=<module>
pkg_version=<version>
pkg_moduledir=<moduledir> # Usually something like "${pkg_name}/${pkg_version}"
pkg_description=<description>
pkg_url=<url>
src_url=<src-url>
src_dir=<src-dir>

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
    pkg_src="${pkg_build_dir}/$(basename ${src_url})"
    module_build_download_package "${src_url}" "${pkg_src}"
    module_build_unpack "${pkg_src}" "${pkg_build_dir}"

    # Build
    pushd "${pkg_build_dir}/${src_dir}"

    ## In this section, the commands that are required to build the
    ## software package should be run.

    ## Autotools
    ## ---------
    ## For packages based on Autotools, a package is built by using
    ## the usual sequence of 'configure', 'make', and 'make install'
    ## commands.
    ##
    ## In the example below, configure is invoked with the '--prefix'
    ## option to install the package in the desired location.
    ##
    ## For packages that support parallel builds, the '-j' option can
    ## be used with make. The number of simultaneous jobs is usually
    ## specified by setting the environment variable 'JOBS'.

    # ./configure --prefix="${pkg_prefix}"
    # make -j"${JOBS}"
    # make install

    ## CMake
    ## -----
    ## For packages using cmake, the installation directory is set
    ## with the option '-DCMAKE_INSTALL_PREFIX'. Also, cmake is
    ## usually run from a dedicated build directory, as shown in the
    ## example below.

    # mkdir -p build
    # pushd build
    # cmake .. -DCMAKE_INSTALL_PREFIX="${pkg_prefix}"
    # make
    # make install
    # popd

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
setenv ${pkg_name^^}_LIBDIR \$MODULES_PREFIX${pkg_prefix}/lib
setenv ${pkg_name^^}_LIBRARYDIR \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path C_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path CPLUS_INCLUDE_PATH \$MODULES_PREFIX${pkg_prefix}/include
prepend-path LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path PKG_CONFIG_PATH \$MODULES_PREFIX${pkg_prefix}/lib/pkgconfig
prepend-path MANPATH \$MODULES_PREFIX${pkg_prefix}/share/man
prepend-path INFOPATH \$MODULES_PREFIX${pkg_prefix}/share/info
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
