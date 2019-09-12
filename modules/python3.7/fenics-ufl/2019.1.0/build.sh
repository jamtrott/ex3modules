#!/usr/bin/env bash
#
# Build fenics-ufl
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
#   MODULES_PREFIX=$HOME module load python<version>/fenics-ufl
#
set -o errexit

. ../../../../common/module.sh

# Package details
pkg_name=fenics-ufl
pkg_version=2019.1.0
PYTHON_VERSION_SHORT=3.7
pkg_moduledir="python${PYTHON_VERSION_SHORT}/${pkg_name}/${pkg_version}"
pkg_description="FEniCS Project: Unified Form Language"
pkg_url="https://bitbucket.org/fenics-project/ufl/"

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

set MODULES_PREFIX [getenv MODULES_PREFIX ""]
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path PYTHONPATH \$MODULES_PREFIX${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages
prepend-path MANPATH \$MODULES_PREFIX${pkg_prefix}/share/man
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
