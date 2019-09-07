#!/usr/bin/env bash
#
# Build opam
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
#   MODULES_PREFIX=$HOME module load opam
#
set -x -o errexit

pkg_name=opam
pkg_version=2.0.5
ocaml_version=4.08
pkg_moduledir="ocaml${ocaml_version}/${pkg_name}/${pkg_version}"
pkg_description="Source-based package manager for OCaml"
pkg_url="https://opam.ocaml.org"
src_url="https://github.com/ocaml/opam/archive/${pkg_version}.tar.gz"
src_dir="${pkg_name}-${pkg_version}"

# Load build-time dependencies and determine prerequisite modules
while read module; do module load "${module}"; done <build_deps
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
pkg_prefix="${prefix}/${pkg_moduledir}"

# Set up build and temporary install directories
build_dir="$(mktemp -d -t ${pkg_name}-${pkg_version}-XXXXXX)"
mkdir -p "${build_dir}"

# Download package
src_pkg="${build_dir}/$(basename ${src_url})"
curl --fail -Lo "${src_pkg}" "${src_url}"

# Unpack
tar -C "${build_dir}" -xzvf "${src_pkg}"

# Build
pushd "${build_dir}/${src_dir}"
./configure --prefix="${pkg_prefix}"
make lib-ext
make
make install DESTDIR="${DESTDIR}"
popd

# Write the module file
pkg_modulefile="${DESTDIR}${prefix}/${modulefilesdir}/${pkg_moduledir}"
mkdir -p $(dirname "${pkg_modulefile}")
echo "Writing module file ${pkg_modulefile}"
cat >"${pkg_modulefile}" <<EOF
#%Module
# ${pkg_name} ${pkg_version}

proc ModulesHelp { } {
     puts stderr "\tSets up the environment for ${pkg_name} ${pkg_version}\n"
}

module-whatis "${pkg_description}"
module-whatis "${pkg_url}"

${pkg_prereqs}

set HOME [getenv HOME ""]
set MODULES_PREFIX [getenv MODULES_PREFIX ""]
setenv ${pkg_name^^}_ROOT \$MODULES_PREFIX${pkg_prefix}
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path PATH \$HOME/.opam/ocaml-system/bin
prepend-path MANPATH \$MODULES_PREFIX${pkg_prefix}/share/man
prepend-path MANPATH \$HOME/.opam/ocaml-system/man
prepend-path CAML_LD_LIBRARY_PATH \$HOME/.opam/ocaml-system/lib/stublibs
setenv OPAM_SWITCH_PREFIX \$HOME/.opam/ocaml-system
setenv OCAML_TOPLEVEL_PATH \$HOME/.opam/ocaml-system/lib/toplevel
set MSG "${pkg_name} ${pkg_version}"
EOF
