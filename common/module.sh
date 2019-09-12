#
# Common functions for building modules
#

# Load a module's build-time dependencies
function module_load_build_deps()
{
    local build_deps="${1}"
    while read module; do
	echo "module load ${module}"
	module load "${module}"
    done <"${build_deps}"
}

# Determine a module's prerequisites
function module_prereqs()
{
    local prereqs="${1}"
    while read module; do
	printf "module load %s\n" "${module}";
    done <"${prereqs}"
}

# Print program help message
function module_build_help()
{
    local program_name="${1}"
    local pkg_name="${2}"
    local pkg_version="${3}"
    local pkg_moduledir="${4}"
    local pkg_description="${5}"
    local pkg_url="${6}"

    printf "Usage: ${program_name} [option...]\n"
    printf " Build %s %s\n\n %s\n\n %s\n\n" \
	   "${pkg_name}" "${pkg_version}" "${pkg_description}" "${pkg_url}"
    printf " Options are:\n"
    printf "  %-20s\t%s\n" "-h, --help" "display this help and exit"
    printf "  %-20s\t%s\n" "--prefix=PREFIX" "install files in PREFIX [${prefix}]"
    printf "  %-20s\t%s\n" "--modulefilesdir=DIR" "module files [PREFIX/${modulefilesdir}]"
    printf "  %-20s\t%s\n" "--verbose" "Verbose output"
}

# Parse program options for building a module
function module_build_parse_command_line_args()
{
    local program_name="${1}"
    local pkg_name="${2}"
    local pkg_version="${3}"
    local pkg_moduledir="${4}"
    local pkg_description="${5}"
    local pkg_url="${6}"

    shift 6

    # Set default options
    prefix=/cm/shared/apps
    modulefilesdir=modulefiles
    module_build_verbose=

    while [ "$#" -gt 0 ]; do
	case "${1}" in
	    -h | --help)
		module_build_help \
		    "${program_name}" \
		    "${pkg_name}" \
		    "${pkg_version}" \
		    "${pkg_moduledir}" \
		    "${pkg_description}" \
		    "${pkg_url}"
		exit 1;;
	    --prefix=*) prefix="${1#*=}"; shift 1;;
	    --modulefilesdir=*) modulefilesdir="${1#*=}"; shift 1;;
	    --verbose) module_build_verbose=1; shift 1;;
	    --) shift; break;;
	    -*) echo "unknown option: ${1}" >&2; exit 1;;
	    *) handle_argument "${1}"; shift 1;;
	esac
    done
}

# Print a module's prefix path
function module_build_prefix()
{
    local prefix="${1}"
    local moduledir="${2}"
    printf "%s/%s" "${prefix}" "${moduledir}"
}

# Create a temporary directory for building a module
function module_build_create_build_dir()
{
    local pkg_name="${1}"
    local pkg_version="${2}"
    local pkg_build_dir=$(mktemp -d -t "${pkg_name}-${pkg_version}-XXXXXX")
    mkdir -p "${pkg_build_dir}"
    printf "%s" "${pkg_build_dir}"
}

# Download a module's source package
function module_build_download_package()
{
    local src_url="${1}"
    local destination="${2}"
    [[ "${module_build_verbose}" ]] && \
	echo "curl --fail -Lo ${destination} ${src_url}"
    curl --fail -Lo "${destination}" "${src_url}"
}

# Unpack a module's source package
function module_build_unpack()
{
    local source_path="${1}"
    local pkg_build_dir="${2}"
    local tar_options="${3:--xz}"
    [[ "${module_build_verbose}" ]] && \
	echo "tar -C ${pkg_build_dir} ${tar_options} -f ${source_path}"
    tar -C "${pkg_build_dir}" "${tar_options}" -f "${source_path}"
}

# Clean up temporary build directory
function module_build_cleanup()
{
    local pkg_build_dir="${1}"
    [[ "${module_build_verbose}" ]] && \
	echo "rm -rf ${pkg_build_dir}"
    rm -rf "${pkg_build_dir}"
}

function module_build_modulefile()
{
    local prefix="${1}"
    local modulefilesdir="${2}"
    local pkg_moduledir="${3}"
    local pkg_modulefile="${DESTDIR}${prefix}/${modulefilesdir}/${pkg_moduledir}"
    mkdir -p $(dirname "${pkg_modulefile}")
    printf "%s" "${pkg_modulefile}"
}
