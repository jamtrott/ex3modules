#!/bin/bash
#SBATCH --job-name="ex3-modules-build-all-x86_64-linux-gnu"
#SBATCH --account=nn2849k
#SBATCH --partition=normal
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem=20G
#SBATCH --output=jobs/%j-%x.out
#SBATCH --error=jobs/%j-%x.err

set -o errexit

module purge
module load GCCcore/7.3.0

function main()
{
    local job_name="${SLURM_JOB_NAME}"
    local job_id="${SLURM_JOB_ID}"

    local project=nn2849k
    local projectdir="/cluster/projects/${project}"

    export TMPDIR="${projectdir}/${USER}/tmp"
    mkdir -p "${TMPDIR}"

    local ex3_modules_dir="${projectdir}/${USER}/src/ex3-modules"

    local workdir="${projectdir}/${USER}/work"
    mkdir -p "${workdir}/src"
    local ex3_modules_workdir=$(
	mktemp -d "${workdir}/src/ex3-modules-${job_name}-${job_id}-XXXXXX")

    #prefix="${HOME}/modules/$(gcc -dumpmachine)/"
    #prefix="${workdir}/ex3-modules/"
    local prefix="${projectdir}/${USER}/ex3-modules/"
    local modulefilesdir=../modulefiles

    cp -R -T "${ex3_modules_dir}" "${ex3_modules_workdir}"
    pushd "${ex3_modules_workdir}"
    local version="$(git describe --no-match --always --abbrev=40 --dirty)"
    printf "Building ex3-modules (${version})\n" >&2
    ./build.sh \
	--prefix="${prefix}" \
	--modulefilesdir="${modulefilesdir}" \
	--build-dependencies=all \
	--verbose \
	$(cat slurm/saga/x86_64-linux-gnu-modules.txt)
    popd
}

main "$@"
