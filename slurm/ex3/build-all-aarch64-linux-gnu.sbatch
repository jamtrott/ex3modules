#!/bin/bash
#SBATCH --job-name="ex3-modules-build-all-aarch64-linux-gnu"
#SBATCH --partition=armq
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --output=jobs/%j-%x.out
#SBATCH --error=jobs/%j-%x.err

set -o errexit

function main()
{
    local job_name="${SLURM_JOB_NAME}"
    local job_id="${SLURM_JOB_ID}"

    export TMPDIR="/work/${USER}/tmp"
    mkdir -p "${TMPDIR}"

    local ex3_modules_dir="${HOME}/src/ex3-modules"

    local workdir="/work/${USER}"
    mkdir -p "${workdir}/src"
    local ex3_modules_workdir=$(
	mktemp -d "${workdir}/src/ex3-modules-${job_name}-${job_id}-XXXXXX")

    #prefix="${HOME}/modules/$(gcc -dumpmachine)/"
    #prefix="${workdir}/ex3-modules/"
    local prefix=/cm/shared/ex3-modules/0.4.0/apps/
    local modulefilesdir=../modulefiles

    mkdir -p "${prefix}"
    cp -R -T "${ex3_modules_dir}" "${ex3_modules_workdir}"
    pushd "${ex3_modules_workdir}"
    local version="$(git describe --no-match --always --abbrev=40 --dirty)"
    printf "Building ex3-modules (${version})\n" >&2
    ./build.sh \
	--prefix="${prefix}" \
	--modulefilesdir="${modulefilesdir}" \
	--build-dependencies=all \
	--verbose \
	$(cat slurm/ex3/aarch64-linux-gnu-modules.txt)
    popd
}

main "$@"
