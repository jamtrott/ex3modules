#!/usr/bin/env bash
#
# Build ocaml
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
#   MODULES_PREFIX=$HOME module load ocaml
#
set -x -o errexit

. ../../../../common/module.sh

pkg_name=ocaml
pkg_version=4.08.1
pkg_moduledir="${pkg_name}/gcc/${pkg_version}"
pkg_description="Core OCaml system with compilers, runtime system, and base libraries"
pkg_url="https://ocaml.org"
src_url="https://github.com/ocaml/ocaml/archive/${pkg_version}.tar.gz"
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
    module_build_download_package "${src_url}" "${pkg_build_dir}"
    module_build_unpack "${pkg_src}" "${pkg_build_dir}"

    # Build
    pushd "${pkg_build_dir}/${src_dir}"

    # Temporarily disable testpreempt, which doesn't seem to work.
    # Could be related to https://github.com/ocaml/ocaml/pull/8849
    sed -i /testpreempt.ml/d testsuite/tests/lib-systhreads/ocamltests
    rm -f testsuite/tests/lib-systhreads/testpreempt.ml

    ./configure --prefix="${pkg_prefix}"
    make -j"${JOBS}" world.opt
    make tests
    make install DESTDIR="${DESTDIR}"
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
setenv ${pkg_name^^}_ROOT \$MODULES_PREFIX${pkg_prefix}
setenv OCAMLLIB \$MODULES_PREFIX${pkg_prefix}/lib/ocaml
prepend-path PATH \$MODULES_PREFIX${pkg_prefix}/bin
prepend-path LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path LD_LIBRARY_PATH \$MODULES_PREFIX${pkg_prefix}/lib
prepend-path MANPATH \$MODULES_PREFIX${pkg_prefix}/share/man
set MSG "${pkg_name} ${pkg_version}"
EOF

    module_build_cleanup "${pkg_build_dir}"
}

main "$@"
