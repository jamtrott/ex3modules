#!/usr/bin/env bash
#
# Build sympy
#
# The following command will build the module, write a module file,
# and install them to the directory 'modules' in your home directory:
#
#   build.sh --prefix=$HOME/modules 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/modules/modulefiles
#   module load python<version>/sympy
#
set -o errexit

. ../../../../common/module.sh

# Package details
pkg_name=sympy
pkg_version=1.1
PYTHON_VERSION_SHORT=3.7
pkg_moduledir="python${PYTHON_VERSION_SHORT}/${pkg_name}/${pkg_version}"
pkg_description="Computer algebra system written in pure Python"
pkg_url="https://www.sympy.org/"

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

    # Download and install from pip
    pkg_prefix=$(module_build_prefix "${prefix}" "${pkg_moduledir}")
    python3 -m pip install --prefix="${pkg_prefix}" $([ ! -z "${DESTDIR}" ] && --root="${DESTDIR}") "${pkg_name}"=="${pkg_version}"

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

prepend-path PATH ${pkg_prefix}/bin
prepend-path PYTHONPATH ${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages
prepend-path MANPATH ${pkg_prefix}/share/man
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"