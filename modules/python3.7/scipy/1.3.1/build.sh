#!/usr/bin/env bash
#
# Build numpy
#
# The following command will build the module, write a module file,
# and install them to the directory 'modules' in your home directory:
#
#   build.sh --prefix=$HOME/modules 2>&1 | tee build.log
#
# The module can then be loaded as follows:
#
#   module use $HOME/modules/modulefiles
#   module load python<version>/numpy
#
set -o errexit

. ../../../../common/module.sh

# Package details
pkg_name=scipy
pkg_version=1.3.1
PYTHON_VERSION_SHORT=3.7
pkg_moduledir="python${PYTHON_VERSION_SHORT}/${pkg_name}/${pkg_version}"
pkg_description="Fundamental package for scientific computing with Python"
pkg_url="https://www.scipy.org/"
src_url="https://github.com/scipy/scipy/archive/v${pkg_version}.tar.gz"
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
    pkg_src="${pkg_build_dir}/$(basename ${src_url})"
    module_build_download_package "${src_url}" "${pkg_src}"
    module_build_unpack "${pkg_src}" "${pkg_build_dir}"

    # Build
    pushd "${pkg_build_dir}/${src_dir}"

    cat >site.cfg <<EOF
[openblas]
libraries = ${BLASLIB}
library_dirs = ${OPENBLAS_LIBDIR}
include_dirs = ${OPENBLAS_INCDIR}
runtime_library_dirs = ${OPENBLAS_LIBDIR}
EOF

    # The installation directory must be added to PYTHONPATH before installing
    PYTHONPATH="${PYTHONPATH}:${DESTDIR}${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages"
    mkdir -p "${DESTDIR}${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages"
    python3 setup.py build
    python3 setup.py install \
	    --prefix="${pkg_prefix}" \
	    $(! [ -z "${DESTDIR}" ] && --root="${DESTDIR}")
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
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path PYTHONPATH \$MODULES_PREFIX${pkg_prefix}/lib/python${PYTHON_VERSION_SHORT}/site-packages
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
