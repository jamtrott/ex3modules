#!/usr/bin/env bash
#
# Build libevent
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
#   MODULES_PREFIX=$HOME module load libevent
#
set -x -o errexit

pkg_name=libevent
pkg_version=2.1.11-stable
pkg_moduledir=${pkg_name}/gcc/${pkg_version}
pkg_description="Event notification library"
pkg_url="https://libevent.org"
src_url=https://github.com/libevent/libevent/releases/download/release-${pkg_version}/libevent-${pkg_version}.tar.gz
src_dir=${pkg_name}-${pkg_version}

# Load build-time dependencies and determine prerequisite modules
while read module; do module load ${module}; done <build_deps
pkg_prereqs=$(while read module; do echo "module load ${module}"; done <prereqs)

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

# Set up build and temporary install directories
build_dir=$(mktemp -d -t ${pkg_name}-${pkg_version}-XXXXXX)
mkdir -p ${build_dir}

# Download package
src_pkg=${build_dir}/$(basename ${src_url})
curl --fail -Lo ${src_pkg} ${src_url}

# Unpack
tar -C ${build_dir} -xzvf ${src_pkg}

# Build
pushd ${build_dir}/${src_dir}
./configure --prefix=${pkg_prefix}
make -j ${JOBS}
make verify
make install DESTDIR=${DESTDIR}
popd

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
set MSG "${pkg_name} ${pkg_version}"
EOF
