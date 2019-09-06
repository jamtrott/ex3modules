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
#   MODULES_PREFIX=$HOME module load python<version>/fenics
#
set -x -o errexit

. ../../../../common/module.sh

pkg_name=fenics
pkg_version=2019.1.0.post0
PYTHON_VERSION_SHORT=3.7
pkg_moduledir="python${PYTHON_VERSION_SHORT}/${pkg_name}/${pkg_version}"
pkg_description="Python interface to the FEniCS computing platform for solving partial differential equations"
pkg_url="https://bitbucket.org/fenics-project/dolfin/"
src_url="https://bitbucket.org/fenics-project/dolfin/downloads/dolfin-${pkg_version}.tar.gz"
src_dir="dolfin-${pkg_version}/python"

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
    python3 setup.py build
    PYTHONPATH="${PYTHONPATH}:${DESTDIR}${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages"
    mkdir -p "${DESTDIR}${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages"
    python3 setup.py install \
	    --prefix="${pkg_prefix}" \
	    $([ ! -z "${DESTDIR}" ] && --root="${DESTDIR}") \
	    --optimize=1 \
	    --skip-build
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
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path PYTHONPATH \$MODULES_PREFIX${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
