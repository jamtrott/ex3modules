#!/usr/bin/env bash
#
# Print a list of modules as a table in markdown format.
#
# Example usage:
#   ./print-modules-table.sh
#
#
set -o errexit

# Default options
modules_paths=
show_dependencies=

# Parse program options
help() {
    printf "Usage: ${0} [OPTION]... <PATH>...\n"
    printf " Print a list of modules as a table in markdown format"
    printf " Options are:\n"
    printf "  %-20s\t%s\n" "-h, --help" "display this help and exit"
    printf "  %-20s\t%s\n" "--show-dependencies" "Print each module's dependencies"
    exit 1
}


function parse_command_line_args() {
    while [ "$#" -gt 0 ]; do
	case "${1}" in
	    -h | --help) help; exit 0;;
	    --show-dependencies) show_dependencies=1; shift 1;;
	    --) shift; break;;
	    -*) echo "unknown option: ${1}" >&2; exit 1;;
	    *) modules_paths="${modules_paths} ${1}"; shift 1;;
	esac
    done

    if [ -z "${modules_paths}" ]; then
	help
    fi
}


function print_heading()
{
    if [[ -n "${show_dependencies}" ]]; then
	printf "| Package | Version | Module name | Description | Dependencies |\n"
	printf "| :---    | ---:    | :---        | :---        | :---         |\n"
    else
	printf "| Package | Version | Module name | Description |\n"
	printf "| :---    | ---:    | :---        | :---        |\n"
    fi
}


function print_module()
{
    local module_build_path="${1}"
    pushd $(dirname "${module_build_path}") > /dev/null
    . build
    if [[ -n "${show_dependencies}" ]]; then
	local pkg_build_deps=$(
	    (while read build_dep; do
		 printf "%s, " "$(echo ${build_dep} | sed 's,_,\\_,g')"
	     done <build_deps) |
		sed 's/, $//')
	printf "| [%s](%s) | %s | %s | %s | %s |\n" \
	       "${pkg_name//_/\\_}" "${pkg_url}" \
	       "${pkg_version}" \
	       "${pkg_moduledir//_/\\_}" \
	       "${pkg_description}" \
	       "${pkg_build_deps}"
    else
	printf "| [%s](%s) | %s | %s | %s |\n" \
	       "${pkg_name//_/\\_}" "${pkg_url}" \
	       "${pkg_version}" \
	       "${pkg_moduledir//_/\\_}" \
	       "${pkg_description}"
    fi
    popd > /dev/null
}


function print_modules()
{
    print_heading

    for modules_path in ${modules_paths}; do
	build_files=$(find "${modules_path}" -name build | sort)
	for module in ${build_files}; do
	    print_module "${module}"
	done
    done
}


function main()
{
    parse_command_line_args "$@"
    print_modules "${modules_path}"
}

main "$@"
