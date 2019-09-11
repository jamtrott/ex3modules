#!/usr/bin/env bash
#
# Build fenics
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
#   MODULES_PREFIX=$HOME module load fenics
#
set -o errexit

. ../../../common/module.sh

pkg_name=fenics
pkg_version=2019.1.0
pkg_moduledir="${pkg_name}/${pkg_version}"
pkg_description="Computing platform for solving partial differential equations"
pkg_url="https://fenicsproject.org"

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

    # Nothing to build

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

set MSG "${pkg_name} ${pkg_version}"
EOF
}

main "$@"
