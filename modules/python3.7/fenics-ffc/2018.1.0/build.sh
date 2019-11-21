#!/usr/bin/env bash
#
# Build fenics-ffc
#
# The following command will build the module, write a module file,
# and install them to the directory 'modules' in your home directory:
#
#   build.sh --prefix=$HOME/modules 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/modules/modulefiles
#   module load python<version>/fenics-ffc
#
set -o errexit

. ../../../../common/module.sh

# Package details
pkg_name=fenics-ffc
pkg_version=2018.1.0
PYTHON_VERSION_SHORT=3.7
pkg_moduledir="python${PYTHON_VERSION_SHORT}/${pkg_name}/${pkg_version}"
pkg_description="FEniCS Project: FEniCS Form Compiler"
pkg_url="https://bitbucket.org/fenics-project/ffc/"
src_url="https://bitbucket.org/fenics-project/ffc/downloads/ffc-${pkg_version}.tar.gz"
src_dir="ffc-${pkg_version}"

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
