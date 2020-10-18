#!/bin/bash
# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Authors: James D. Trotter <james@simula.no>
#
# This script builds and installs software packages and Environment
# Modules scripts for aarch64 systems on the eX3 cluster. The build is
# performed on a dual-socket HiSilicon Kunpeng 920 node on eX3.
#
# The SLURM job must be submitted from the top-level directory of
# ex3modules, where the program `ex3modules' is located. The standard
# output and standard error streams are redirected to files in the
# directory slurm/ex3/jobs/.
#
# Example usage:
#
#  $ sbatch slurm/ex3/ex3modules_hisilicon_kunpeng_920.sbatch --prefix=/work/${USER}/ex3modules
#

#SBATCH --job-name="ex3modules_hisilicon_kunpeng_920"
#SBATCH --time=2-00:00:00
#SBATCH --partition=huaq
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=128
#SBATCH --output=slurm/ex3/jobs/%j-%x-out.txt
#SBATCH --error=slurm/ex3/jobs/%j-%x-err.txt

JOBS=$((${SLURM_NTASKS}*${SLURM_CPUS_PER_TASK}))

echo "SLURM_JOB_NAME=${SLURM_JOB_NAME}" >&2
echo "SLURM_JOB_ID=${SLURM_JOB_ID}" >&2
echo "SLURM_SUBMIT_HOST=${SLURM_SUBMIT_HOST}" >&2
echo "SLURM_NTASKS=${SLURM_NTASKS}" >&2
echo "SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}" >&2
echo "SLURM_JOB_NUM_NODES=${SLURM_JOB_NUM_NODES}" >&2
echo "SLURM_JOB_NODELIST=${SLURM_JOB_NODELIST}" >&2
echo "PWD=${PWD}" >&2
echo "PATH=${PATH}" >&2
echo "TMPDIR=${TMPDIR}" >&2
echo "SHELL=${SHELL}" >&2
echo "CC=${CC}" >&2
echo "CFLAGS=${CFLAGS}" >&2
echo "JOBS=${JOBS}" >&2
set -x
uname -a >&2
lscpu >&2
lstopo >&2
numactl --hardware >&2
numactl --show >&2
{ set +x; } 2>/dev/null

# Build ex3modules
set -x
./ex3modules -v -j${JOBS} "$@"
{ set +x; } 2>/dev/null
