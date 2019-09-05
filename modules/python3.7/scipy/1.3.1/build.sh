#!/usr/bin/env bash
#
# Build numpy
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
#   MODULES_PREFIX=$HOME module load python<version>/numpy
#
set -x -o errexit

# Load build-time dependencies and determine prerequisite modules
while read module; do module load ${module}; done <build_deps
pkg_prereqs=$(while read module; do echo "module load ${module}"; done <prereqs)

# Package details
pkg_name=scipy
pkg_version=1.3.1
pkg_moduledir=python${PYTHON_VERSION_SHORT}/${pkg_name}/${pkg_version}
pkg_description="Fundamental package for scientific computing with Python"
pkg_url="https://www.scipy.org/"

# Set default options
prefix=/cm/shared/apps
modulefilesdir=modulefiles

# Parse program options
help() {
    printf "Usage: $0 [option...]\n"
    printf " Build %s\n\n" "${pkg_name}-${pkg_version}"
    printf " Options are:\n"
    printf "  %-20s\t%s\n" "-h, --help" "display this help and exit"
    printf "  %-20s\t%s\n" "--prefix=PREFIX" "install files in PREFIX [${prefix}]"
    printf "  %-20s\t%s\n" "--modulefilesdir=DIR" "module files [PREFIX/${modulefilesdir}]"
    exit 1
}
while [ "$#" -gt 0 ]; do
    case "$1" in
	-h | --help) help; exit 0;;
	--prefix=*) prefix="${1#*=}"; shift 1;;
	--modulefilesdir=*) modulefilesdir="${1#*=}"; shift 1;;
	--) shift; break;;
	-*) echo "unknown option: $1" >&2; exit 1;;
	*) handle_argument "$1"; shift 1;;
    esac
done

# Set up installation paths
pkg_prefix=${prefix}/${pkg_moduledir}

# Install the module
python3 -m pip install --prefix=${pkg_prefix} $([ ! -z "${DESTDIR}" ] && --root="${DESTDIR}") ${pkg_name}==${pkg_version}

# Write the module file
pkg_modulefile=${DESTDIR}${prefix}/${modulefilesdir}/${pkg_moduledir}
mkdir -p $(dirname ${pkg_modulefile})
echo "Writing module file ${pkg_modulefile}"
cat >${pkg_modulefile} <<EOF
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
