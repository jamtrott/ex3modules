# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# Makefile

# Configure paths
prefix = $(realpath .)
pkgdir = $(prefix)/pkgs
modulefilesdir = $(prefix)/modulefiles
pkgsrcdir = $(prefix)/src

# Remove `prefix' and `PREFIX' from MAKEFLAGS and MAKEOVERRIDES, so
# they are not passed to any submake.
MAKEFLAGS:=$(filter-out prefix=% PREFIX=%,$(MAKEFLAGS))
MAKEOVERRIDES:=$(filter-out prefix=% PREFIX=%,$(MAKEOVERRIDES))

# Detect architecture
ARCH ?= $(shell uname -m)
AVX512F := $(shell [ "$$(grep avx512f /proc/cpuinfo)" ] && echo true)

# Default options
HAVE_CUDA :=
HAVE_ROCM :=
ENABLE_GFORTRAN :=
CMAKE_ROOT :=
MPI_HOME :=
OPENSSL_ROOT :=
PYTHON_ROOT :=
SLURM_ROOT :=

# Programs used by makefiles
INSTALL := install
CURL := curl
curl_options := --fail --retry 5 --location

# Configure Environment Modules
ifeq ($(MODULESINIT),)
ifneq ($(MODULESHOME),)
MODULESINIT := . $(MODULESHOME)/init/$(notdir $(SHELL))
else
$(error Please set MODULESHOME to locate Environment Modules)
endif
endif
MODULE := module

#
# Preferred packages
#

# Default to using 32-bit versions of various linear algebra packages
hypre = hypre-32-2.26.0
hypre-32 = hypre-32-2.26.0
hypre-64 = hypre-64-2.26.0
metis = metis-32-5.1.0
metis-32 = metis-32-5.1.0
metis-64 = metis-64-5.1.0
mumps = mumps-32-5.5.1
mumps-32 = mumps-32-5.5.1
mumps-64 = mumps-64-5.5.1
parmetis = parmetis-32-4.0.3
parmetis-32 = parmetis-32-4.0.3
parmetis-64 = parmetis-64-4.0.3
scotch = scotch-32-6.1.3
scotch-32 = scotch-32-6.1.3
scotch-64 = scotch-64-6.1.3
suitesparse = suitesparse-32-5.12.0
suitesparse-32 = suitesparse-32-5.12.0
suitesparse-64 = suitesparse-64-5.12.0
superlu_dist = superlu_dist-32-8.1.0
superlu_dist-32 = superlu_dist-32-8.1.0
superlu_dist-64 = superlu_dist-64-8.1.0
petsc = petsc-32-3.17.4
petsc-32 = petsc-32-3.17.4
petsc-64 = petsc-64-3.17.4
mfem = mfem-4.5.2

# HDF5
hdf5 = hdf5-1.10.5
hdf5-parallel = hdf5-parallel-1.10.5

#
# CMake
#
ifeq ($(WITH_CMAKE),cmake-3.17.2)
cmake = cmake-3.17.2
CMAKE = $(pkgdir)/$(cmake)/bin/cmake
$(info Using internal CMake ($(cmake)))
else ifeq ($(WITH_CMAKE),cmake-3.22.3)
cmake = cmake-3.22.3
CMAKE = $(pkgdir)/$(cmake)/bin/cmake
$(info Using internal CMake ($(cmake)))
else ifeq ($(WITH_CMAKE),no)
CMAKE = false
$(warning Warning: CMake is disabled - some modules may not build.)
else ifneq ($(WITH_CMAKE),)
CMAKE_ROOT = $(WITH_CMAKE)
CMAKE = $(CMAKE_ROOT)/bin/cmake
$(info Using $(CMAKE) ($(shell $(CMAKE) --version | head -n 1)))
export PATH := $(CMAKE_ROOT)/bin$(if $(PATH),:$(PATH),)
export ACLOCAL_PATH := $(CMAKE_ROOT)/share/aclocal$(if $(ACLOCAL_PATH),:$(ACLOCAL_PATH),)
else ifneq ($(shell which cmake),)
CMAKE = $(shell which cmake)
$(info Using $(CMAKE) ($(shell $(CMAKE) --version | head -n 1)))
else
$(warning Warning: cmake not found - some modules may not build.)
endif


#
# OpenBLAS
#
ifeq ($(WITH_OPENBLAS),openblas-0.3.12)
openblas = openblas-0.3.12
blas = openblas-0.3.12
$(info Using internal OpenBLAS ($(openblas)))
else ifeq ($(WITH_OPENBLAS),openblas-0.3.21)
openblas = openblas-0.3.21
blas = openblas-0.3.21
$(info Using internal OpenBLAS ($(openblas)))
else ifeq ($(WITH_OPENBLAS),no)
$(warning Warning: OpenBLAS is disabled - some modules may not build.)
else ifneq ($(WITH_OPENBLAS),)
export OPENBLAS_ROOT = $(WITH_OPENBLAS)
$(info Using OpenBLAS from $(OPENBLAS_ROOT))
export BLASDIR := $(OPENBLAS_ROOT)/lib
export BLASLIB := openblas
export C_INCLUDE_PATH := $(OPENBLAS_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(OPENBLAS_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LD_LIBRARY_PATH := $(OPENBLAS_ROOT)/lib$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
export CMAKE_PREFIX_PATH := $(OPENBLAS_ROOT)/lib/cmake/openblas$(if $(CMAKE_PREFIX_PATH),:$(CMAKE_PREFIX_PATH),)
export PKGCONFIG_PATH := $(OPENBLAS_ROOT)/lib/pkgconfig$(if $(PKGCONFIG_PATH),:$(PKGCONFIG_PATH),)
else
$(warning Warning: using default path for OpenBLAS - some modules may not build if OpenBLAS is not found.)
endif

#
# Fortran
#
ifneq ($(ENABLE_GFORTRAN),)
gfortran = gfortran-8.4.0
$(info Using internal Fortran ($(gfortran)))
else ifneq ($(FC),)
$(info Using $(FC) ($(shell $(FC) --version | head -n 1)))
export FC
else ifneq ($(shell which f95),)
$(info Using $(shell which f95) ($(shell f95 --version | head -n 1)))
export FC := f95
else ifneq ($(shell which f77),)
$(info Using $(shell which f77) ($(shell f77 --version | head -n 1)))
export FC := f77
else
$(warning Warning: No Fortran compiler found - some modules may not build.)
endif

#
# C compiler
#
ifneq ($(CC),)
$(info Using $(CC) ($(shell $(CC) --version | head -n 1)))
export CC
else ifneq ($(shell which gcc),)
$(info Using $(shell which gcc) ($(shell gcc --version | head -n 1)))
export CC := gcc
else
$(warning Warning: No C compiler found - some modules may not build.)
endif

#
# CUDA
#
ifeq ($(WITH_CUDA),auto)
HAVE_CUDA=1
cuda-toolkit = cuda-toolkit-11.7
pkgs := $(pkgs) cuda-toolkit-11.7
$(info Using internal CUDA Toolkit ($(cuda-toolkit)))
else ifeq ($(WITH_CUDA),no)
$(warning Warning: CUDA is disabled - some modules may not build.)
else ifneq ($(WITH_CUDA),)
HAVE_CUDA=1
export CUDA_TOOLKIT_ROOT = $(WITH_CUDA)
NVCC = $(CUDA_TOOLKIT_ROOT)/bin/nvcc
$(info Using $(NVCC) ($(shell $(NVCC) --version | tail -n 1)))
export PATH := $(CUDA_TOOLKIT_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(CUDA_TOOLKIT_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(CUDA_TOOLKIT_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(CUDA_TOOLKIT_ROOT)/lib:$(CUDA_TOOLKIT_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(CUDA_TOOLKIT_ROOT)/lib:$(CUDA_TOOLKIT_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else
$(warning Warning: CUDA Toolkit not found - some modules may not build.)
endif

# CUDA-related packages
ifneq ($(HAVE_CUDA),)
pkgs := $(pkgs) \
	gdrcopy-2.3.1
endif

#
# ROCm
#
ifeq ($(WITH_ROCM),no)
$(warning Warning: ROCm is disabled - some modules may not build.)
else ifneq ($(WITH_ROCM),)
HAVE_ROCM=1
export ROCM_ROOT = $(WITH_ROCM)
export HIPCC = $(ROCM_ROOT)/bin/hipcc
$(info Using $(HIPCC) ($(shell $(HIPCC) --version | head -n 1)))
export PATH := $(ROCM_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(ROCM_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(ROCM_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(ROCM_ROOT)/lib:$(ROCM_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(ROCM_ROOT)/lib:$(ROCM_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else
$(warning Warning: ROCm not found - some modules may not build.)
endif

#
# hwloc
#
ifeq ($(WITH_HWLOC),hwloc-2.7.1)
hwloc = hwloc-2.7.1
$(info Using internal hwloc ($(hwloc)))
else ifeq ($(WITH_HWLOC),hwloc-2.4.1)
hwloc = hwloc-2.4.1
$(info Using internal hwloc ($(hwloc)))
else ifeq ($(WITH_HWLOC),no)
$(warning Warning: hwloc is disabled - some modules may not build.)
else ifneq ($(WITH_HWLOC),)
export HWLOC_ROOT = $(WITH_HWLOC)
HWLOC_INFO = $(HWLOC_ROOT)/bin/hwloc-info
$(info Using $(HWLOC_INFO) ($(shell $(HWLOC_INFO) --version | head -n 1)))
export PATH := $(HWLOC_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(HWLOC_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(HWLOC_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(HWLOC_ROOT)/lib:$(HWLOC_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(HWLOC_ROOT)/lib:$(HWLOC_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else ifneq ($(shell which hwloc-info),)
HWLOC_INFO = $(shell which hwloc-info)
$(info Using $(HWLOC_INFO) ($(shell $(HWLOC_INFO) --version | head -n 1)))
else
$(warning Warning: hwloc not found - some modules may not build.)
endif

#
# MPI
#
ifeq ($(WITH_MPI),openmpi-4.0.5)
mpi = openmpi-4.0.5
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),openmpi-4.1.4)
mpi = openmpi-4.1.4
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),mpich-3.3.2)
mpi = mpich-3.3.2
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),mvapich-2.3.4)
mpi = mpich-2.3.4
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),no)
$(warning Warning: MPI is disabled - some modules may not build.)
else ifneq ($(WITH_MPI),)
export MPI_HOME = $(WITH_MPI)
export MPICC = $(MPI_HOME)/bin/mpicc
export MPICXX = $(MPI_HOME)/bin/mpicxx
export MPIEXEC = $(MPI_HOME)/bin/mpiexec
export MPIF77 = $(MPI_HOME)/bin/mpif77
export MPIF90 = $(MPI_HOME)/bin/mpif90
export MPIFORT = $(MPI_HOME)/bin/mpifort
export MPIRUN = $(MPI_HOME)/bin/mpirun
export MPI_RUN = $(MPI_HOME)/bin/mpirun
$(info Using $(MPIRUN) ($(shell $(MPIRUN) --version | head -n 1)))
export PATH := $(MPI_HOME)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(MPI_HOME)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(MPI_HOME)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(MPI_HOME)/lib:$(MPI_HOME)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(MPI_HOME)/lib:$(MPI_HOME)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
endif

#
# OpenSSL
#
ifeq ($(WITH_OPENSSL),openssl-1.1.1c)
openssl = openssl-1.1.1c
OPENSSL = $(pkgdir)/$(openssl)/bin/openssl
$(info Using internal OpenSSL ($(openssl)))
else ifeq ($(WITH_OPENSSL),openssl-1.1.1v)
openssl = openssl-1.1.1v
OPENSSL = $(pkgdir)/$(openssl)/bin/openssl
$(info Using internal OpenSSL ($(openssl)))
else ifeq ($(WITH_OPENSSL),no)
$(warning Warning: OpenSSL is disabled - some modules may not build.)
else ifneq ($(WITH_OPENSSL),)
export OPENSSL_ROOT = $(WITH_OPENSSL)
OPENSSL = $(OPENSSL_ROOT)/bin/openssl
$(info Using $(OPENSSL) ($(shell $(OPENSSL) version | head -n 1)))
export PATH := $(OPENSSL_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(OPENSSL_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(OPENSSL_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(OPENSSL_ROOT)/lib:$(OPENSSL_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(OPENSSL_ROOT)/lib:$(OPENSSL_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else ifneq ($(shell which openssl),)
OPENSSL = $(shell which openssl)
$(info Using $(OPENSSL) ($(shell $(OPENSSL) version | head -n 1)))
else
$(warning Warning: OpenSSL not found - some modules may not build.)
endif

#
# Python
#
ifeq ($(WITH_PYTHON),python-3.7.4)
python = python-3.7.4
PYTHON = $(pkgdir)/$(python)/bin/python3
PYTHON_VERSION = 3.7.4
PYTHON_VERSION_SHORT = 3.7
$(info Using internal python ($(python)))
else ifeq ($(WITH_PYTHON),python-3.8.16)
python = python-3.8.16
PYTHON = $(pkgdir)/$(python)/bin/python3
PYTHON_VERSION = 3.8.16
PYTHON_VERSION_SHORT = 3.8
$(info Using internal python ($(python)))
else ifeq ($(WITH_PYTHON),no)
PYTHON = false
$(warning Warning: Python is disabled - some modules may not build.)
else ifneq ($(WITH_PYTHON),)
export PYTHON_ROOT = $(WITH_PYTHON)
export PYTHON = $(PYTHON_ROOT)/bin/python3
export PYTHON_VERSION = $(shell $(PYTHON) --version | awk '{ print $$2 }')
export PYTHON_VERSION_SHORT = $(shell $(PYTHON) --version | awk '{ print $$2 }' | cut -d. -f 1-2)
$(info Using $(PYTHON) ($(shell $(PYTHON) --version | head -n 1)))
export PATH := $(PYTHON_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(PYTHON_ROOT)/include/python$(PYTHON_VERSION_SHORT)$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(PYTHON_ROOT)/include/python$(PYTHON_VERSION_SHORT)$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(PYTHON_ROOT)/lib:$(PYTHON_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(PYTHON_ROOT)/lib:$(PYTHON_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else ifneq ($(shell which python3),)
PYTHON = $(shell which python3)
PYTHON_VERSION = $(shell $(PYTHON) --version | awk '{ print $$2 }')
PYTHON_VERSION_SHORT = $(shell $(PYTHON) --version | awk '{ print $$2 }' | cut -d. -f 1-2)
$(info Using $(PYTHON) ($(shell $(PYTHON) --version | head -n 1)))
else
$(warning Warning: Python not found - some modules may not build.)
endif

#
# SLURM
#
ifeq ($(WITH_SLURM),slurm-20.02.7)
slurm = slurm-20.02.7
$(info Using internal SLURM ($(slurm)))
else ifeq ($(WITH_SLURM),no)
$(warning Warning: Slurm is disabled - some modules may not build.)
else ifneq ($(WITH_SLURM),)
export SLURM_ROOT := $(WITH_SLURM)
$(info Using $(SLURM_ROOT)/bin/srun ($(shell $(SLURM_ROOT)/bin/srun --version | head -n 1)))
export PATH := $(SLURM_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(SLURM_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(SLURM_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(SLURM_ROOT)/lib:$(SLURM_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(SLURM_ROOT)/lib:$(SLURM_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else
$(warning Warning: Slurm not found - some modules may not build.)
endif

#
# zlib
#
ifeq ($(WITH_ZLIB),zlib-1.2.11)
zlib = zlib-1.2.11
$(info Using internal zlib ($(zlib)))
else ifeq ($(WITH_ZLIB),no)
$(warning Warning: zlib is disabled - some modules may not build.)
else ifneq ($(WITH_ZLIB),)
ZLIB_ROOT = $(WITH_ZLIB)
$(info Using zlib from $(ZLIB_ROOT))
export C_INCLUDE_PATH := $(ZLIB_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(ZLIB_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(ZLIB_ROOT)/lib:$(ZLIB_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(ZLIB_ROOT)/lib:$(ZLIB_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
else
$(warning Warning: using default path for zlib - some modules may not build if zlib is not found.)
endif

#
# Default packages
#
pkgs := $(pkgs) \
	autoconf-2.70 \
	automake-1.16.3 \
	binutils-2.32 \
	bison-3.7.4 \
	blis-generic-0.7.0 \
	blis-skx-0.7.0 \
	blis-src-0.7.0 \
	blis-thunderx2-0.7.0 \
	blis-x86_64-0.7.0 \
	blis-zen-0.7.0 \
	blis-zen2-0.7.0 \
	boost-1.73.0 \
	boost-mpi-1.73.0 \
	boost-python-1.73.0 \
	boost-src-1.73.0 \
	bzip2-1.0.8 \
	cairo-1.16.0 \
	cblas \
	cgal-4.12.2 \
	cgal-5.2.2 \
	clang-11.0.0 \
	cmake-3.17.2 \
	cmake-3.22.3 \
	combblas-1.6.2 \
	combblas-src-1.6.2 \
	cpupower-4.19.75 \
	curl-7.69.1 \
	dealii-9.1.1 \
	doxygen-1.8.18 \
	eigen-3.3.7 \
	elfutils-0.189 \
	expat-2.2.9 \
	exprtk-93a9f44f9 \
	fenics-dolfin-2018-src-2018.1.0.post1 \
	fenics-dolfin-2018.1.0.post1 \
	fenics-dolfin-2019-src-2019.1.0.post0 \
	fenics-dolfin-2019.1.0.post0 \
	fenics-dolfin-64-2019.1.0.post0 \
	fenics-dolfin-64-debug-2019.1.0.post0 \
	fenics-dolfin-src-2019.2.0.dev0 \
	fenics-dolfin-2019.2.0.dev0 \
	fenics-dolfinx-src-0.5.2 \
	fenics-dolfinx-32-0.5.2 \
	fenics-dolfinx-64-0.5.2 \
	fenics-dolfinx-20200525 \
	fenics-dolfinx-src-20200525 \
	fenics-mshr-2019-src-2019.1.0 \
	fenics-mshr-2019.1.0 \
	fftw-3.3.8 \
	flex-2.6.4 \
	fmt-8.0.1 \
	fontconfig-2.13.96 \
	freeipmi-1.6.6 \
	freetype-2.12.1 \
	fribidi-1.0.10 \
	gc-8.0.4 \
	gcc-10.1.0 \
	gcc-11.2.0 \
	gcc-8.4.0 \
	gcc-9.2.0 \
	gcc-src-10.1.0 \
	gcc-src-8.4.0 \
	gdb-13.2 \
	gengetopt-2.23 \
	gettext-0.21 \
	gfortran-8.4.0 \
	ghostscript-9.54.0 \
	giflib-5.2.1 \
	gklib-5.1.0 \
	glib-2.64.1 \
	gmp-6.1.2 \
	gmsh-4.11.0 \
	gmsh-4.12.1 \
	gnuplot-5.2.8 \
	gobject-introspection-1.64.0 \
	googletest-1.10.0 \
	gperf-3.1 \
	graphite2-1.3.14 \
	graphviz-2.44.0 \
	gsl-2.6 \
	harfbuzz-2.6.4 \
	harfbuzz-graphite-2.6.4 \
	harfbuzz-src-2.6.4 \
	hdf5-1.10.5 \
	hdf5-parallel-1.10.5 \
	hdf5-parallel-1.12.0 \
	hdf5-src-1.10.5 \
	hpl-2.3 \
	hunspell-1.7.0 \
	hwloc-2.4.1 \
	hwloc-2.7.1 \
	hwloc-cairo-2.7.1 \
	hwloc-src-2.4.1 \
	hwloc-src-2.7.1 \
	hypre-32-2.23.0 \
	hypre-32-2.24.0 \
	hypre-32-2.25.0 \
	hypre-32-2.25.0-gfx90a \
	hypre-32-2.26.0 \
	hypre-64-2.23.0 \
	hypre-64-2.24.0 \
	hypre-64-2.25.0 \
	hypre-64-2.26.0 \
	hypre-src-2.23.0 \
	hypre-src-2.24.0 \
	hypre-src-2.25.0 \
	hypre-src-2.26.0 \
	icu-69.1 \
	iperf-2.0.13 \
	ipopt-3.13.3 \
	itk-4.13.3 \
	knem-1.1.4 \
	kokkos-3.6.01 \
	kokkos-kernels-3.6.1 \
	lapack-3.9.0 \
	lcms2-2.12 \
	libarchive-3.4.2 \
	libatomic_ops-7.6.10 \
	libbpf-1.2.2 \
	libceed-0.11.0 \
	libcerf-1.13 \
	libcheck-0.15.2 \
	libdmx-1.1.4 \
	libdrm-2.4.107 \
	libdwarf-0.7.0 \
	libevent-2.1.12-stable \
	libfabric-1.17.0 \
	libffi-3.2.1 \
	libfontenc-1.1.4 \
	libfs-1.0.8 \
	libgccjit-10.1.0 \
	libgcrypt-1.8.7 \
	libgd-2.2.5 \
	libgpg-error-1.39 \
	libice-1.0.10 \
	libiconv-1.16 \
	libjpeg-turbo-2.0.4 \
	libnl-3.2.25 \
	libpaper-1.1.24+nmu5 \
	libpciaccess-0.16 \
	libpfm-4.10.1 \
	libpng-1.6.37 \
	libsm-1.2.3 \
	libtiff-4.1.0 \
	libtool-2.4.6 \
	libufget-1.0.3 \
	libunwind-1.3.1 \
	libwebp-1.1.0 \
	libx11-1.6.9 \
	libxau-1.0.9 \
	libxaw-1.0.13 \
	libxcb-1.15 \
	libxcomposite-0.4.5 \
	libxcursor-1.2.0 \
	libxdamage-1.1.5 \
	libxdmcp-1.1.3 \
	libxext-1.3.4 \
	libxfixes-5.0.3 \
	libxfont2-2.0.4 \
	libxft-2.3.3 \
	libxi-1.7.10 \
	libxinerama-1.1.4 \
	libxkbfile-1.1.0 \
	libxml2-2.9.12 \
	libxmu-1.1.3 \
	libxpm-3.5.13 \
	libxrandr-1.5.2 \
	libxrender-0.9.10 \
	libxres-1.2.0 \
	libxscrnsaver-1.2.3 \
	libxshmfence-1.3 \
	libxt-1.2.0 \
	libxtst-1.2.3 \
	libxv-1.0.11 \
	libxvmc-1.0.12 \
	libxxf86dga-1.1.5 \
	libxxf86vm-1.1.4 \
	linux-src-4.19.75 \
	llvm-10.0.1 \
	llvm-11.0.0 \
	llvm-openmp-11.0.0 \
	matio-1.5.17 \
	mesa-21.1.5 \
	meson-0.63.1 \
	metis-32-5.1.0 \
	metis-64-5.1.0 \
	metis-src-5.1.0 \
	mfem-4.5 \
	mfem-4.5.2 \
	mpc-1.1.0 \
	mpfr-4.0.2 \
	mpich-3.3.2 \
	mumps-32-5.5.1 \
	mumps-64-5.5.1 \
	mumps-src-5.5.1 \
	munge-0.5.13 \
	mvapich-2.3.4 \
	mysql-connector-python-8.0.23 \
	nasm-2.14.02 \
	ncurses-6.1 \
	netlib-blas-3.8.0 \
	ninja-1.10.0 \
	nspr-4.32 \
	nss-3.69 \
	numactl-2.0.13 \
	nvtop-2.0.1 \
	ocaml-4.08.1 \
	onetbb-2021.4.0 \
	onetbb-src-2021.4.0 \
	openblas-0.3.12 \
	openblas-0.3.21 \
	opencascade-7.5.0 \
	opencl-headers-2020.06.16 \
	openjpeg-2.4.0 \
	openmpi-4.0.5 \
	openmpi-4.1.4 \
	openmpi-src-4.0.5 \
	openmpi-src-4.1.4 \
	openssl-1.1.1c \
	openssl-1.1.1v \
	osu-micro-benchmarks-mpich-5.6.3 \
	osu-micro-benchmarks-mvapich-5.6.3 \
	osu-micro-benchmarks-openmpi-5.6.3 \
	osu-micro-benchmarks-src-5.6.3 \
	pahole-1.25 \
	pango-1.44.7 \
	parallel-20190922 \
	paraview-5.9.1 \
	parmetis-32-4.0.3 \
	parmetis-64-4.0.3 \
	parmetis-src-4.0.3 \
	pastix-32-6.3.2 \
	pastix-64-6.3.2 \
	pastix-src-6.3.2 \
	patchelf-0.14.3 \
	pciutils-3.6.2 \
	pcre-8.44 \
	perf-4.19.75 \
	perl-5.30.2 \
	petsc-3.13.2 \
	petsc-32-3.16.5 \
	petsc-32-3.17.4 \
	petsc-64-3.16.5 \
	petsc-64-3.17.4 \
	petsc-src-3.13.2 \
	petsc-src-3.16.5 \
	petsc-src-3.17.4 \
	pixman-0.38.4 \
	pmix-4.1.2 \
	poppler-21.04.0 \
	protobuf-cpp-3.17.0 \
	protobuf-python-3.17.0 \
	pugixml-1.11 \
	pybind11-2.8.1 \
	python-3.7.4 \
	python-3.8.16 \
	python-alabaster-0.7.12 \
	python-apipkg-1.5 \
	python-appdirs-1.4.4 \
	python-atomicwrites-1.4.0 \
	python-attrs-19.3.0 \
	python-babel-2.8.0 \
	python-breathe-4.13.1 \
	python-certifi-2020.6.20 \
	python-cffi-1.14.3 \
	python-chardet-3.0.4 \
	python-colorama-0.4.4 \
	python-coverage-5.5 \
	python-cycler-0.10.0 \
	python-cython-0.29.36 \
	python-dateutil-2.8.2 \
	python-distlib-0.3.1 \
	python-docutils-0.20.1 \
	python-exceptiongroup-1.1.0 \
	python-execnet-1.7.1 \
	python-extrap-4.0.4 \
	python-fenics-basix-0.5.0 \
	python-fenics-dijitso-2018.1.0 \
	python-fenics-dijitso-2019.1.0 \
	python-fenics-dolfin-2018.1.0.post1 \
	python-fenics-dolfin-2019.1.0.post0 \
	python-fenics-dolfin-2019.2.0.dev0 \
	python-fenics-dolfin-64-2019.1.0.post0 \
	python-fenics-dolfin-64-debug-2019.1.0.post0 \
	python-fenics-dolfinx-32-0.5.2 \
	python-fenics-dolfinx-64-0.5.2 \
	python-fenics-ffc-2018.1.0 \
	python-fenics-ffc-2019.1.0 \
	python-fenics-ffc-2019.2.0.dev0 \
	python-fenics-ffcx-0.5.0 \
	python-fenics-ffcx-20200522 \
	python-fenics-fiat-2018.1.0 \
	python-fenics-fiat-2019.1.0 \
	python-fenics-fiat-2019.2.0.dev0 \
	python-fenics-fiat-20200518 \
	python-fenics-mshr-2019.1.0 \
	python-fenics-ufl-2018.1.0 \
	python-fenics-ufl-2019.1.0 \
	python-fenics-ufl-2021.1.0 \
	python-fenics-ufl-2022.2.0 \
	python-fenics-ufl-20200512 \
	python-fenics-ufl-legacy-2022.3.0 \
	python-filelock-3.0.12 \
	python-flake8-3.8.2 \
	python-flaky-3.7.0 \
	python-freezegun-1.0.0 \
	python-future-0.18.2 \
	python-h5py-2.10.0 \
	python-hypothesis-5.37.4 \
	python-idna-2.9 \
	python-imagesize-1.2.0 \
	python-importlib_metadata-1.6.0 \
	python-iniconfig-1.1.1 \
	python-ipopt-0.3.0 \
	python-ipython-7.14.0 \
	python-jinja2-2.11.2 \
	python-kiwisolver-1.2.0 \
	python-ldrb-2022.0.0 \
	python-ldrb-2022.5.0 \
	python-llvmlite-0.35.0 \
	python-mako-1.1.4 \
	python-markupsafe-1.1.1 \
	python-marshmallow-3.17.1 \
	python-matplotlib-3.1.1 \
	python-mccabe-0.6.1 \
	python-meshio-4.3.6 \
	python-more-itertools-8.3.0 \
	python-mpi4py-3.1.4 \
	python-mpmath-1.1.0 \
	python-nose-1.3.7 \
	python-numba-0.56.4 \
	python-numpy-1.21.5 \
	python-numpy-quaternion-2021.11.4.15.26.3 \
	python-packaging-20.4 \
	python-pandas-1.0.3 \
	python-pathlib2-2.3.5 \
	python-petsc4py-3.17.2 \
	python-petsc4py-64-3.17.2 \
	python-pillow-8.1.1 \
	python-pip-23.2.1 \
	python-pkgconfig-1.5.1 \
	python-pluggy-0.13.1 \
	python-ply-3.11 \
	python-psutil-5.7.0 \
	python-py-1.9.0 \
	python-pyadjoint-2019.1.1 \
	python-pycodestyle-2.6.0 \
	python-pycparser-2.20 \
	python-pycubexr-1.2.0 \
	python-pydocstyle-5.0.2 \
	python-pyflakes-2.2.0 \
	python-pygments-2.6.1 \
	python-pygraphviz-1.5 \
	python-pyparsing-2.4.7 \
	python-pyra-pytorch-1.2.0 \
	python-pytest-7.2.2 \
	python-pytest-cov-2.12.1 \
	python-pytest-forked-1.1.3 \
	python-pytest-xdist-1.32.0 \
	python-pytz-2020.1 \
	python-requests-2.23.0 \
	python-scikit-build-0.16.6 \
	python-scipy-1.7.3 \
	python-setuptools-59.6.0 \
	python-setuptools_scm-4.1.1 \
	python-simplejson-3.17.6 \
	python-six-1.15.0 \
	python-snowballstemmer-2.0.0 \
	python-sortedcontainers-2.2.2 \
	python-sphinx-3.0.4 \
	python-sphinx_rtd_theme-0.4.3 \
	python-sphinxcontrib-applehelp-1.0.2 \
	python-sphinxcontrib-devhelp-1.0.2 \
	python-sphinxcontrib-htmlhelp-1.0.3 \
	python-sphinxcontrib-jsmath-1.0.1 \
	python-sphinxcontrib-qthelp-1.0.3 \
	python-sphinxcontrib-serializinghtml-1.1.4 \
	python-sympy-1.1 \
	python-sympy-1.4 \
	python-toml-0.10.1 \
	python-tomli-1.2.3 \
	python-tox-3.20.1 \
	python-tqdm-4.64.0 \
	python-typing_extensions-4.4.0 \
	python-urllib3-1.25.11 \
	python-virtualenv-20.0.35 \
	python-wcwidth-0.1.9 \
	python-wheel-0.37.0 \
	python-xarray-0.15.1 \
	python-zipp-3.3.1 \
	qperf-0.4.11 \
	qt5-5.15.2 \
	rdma-core-44.0 \
	readline-8.0 \
	scalapack-2.1.0 \
	scalapack-src-2.1.0 \
	scotch-32-6.1.3 \
	scotch-32-7.0.4 \
	scotch-64-6.1.3 \
	scotch-64-7.0.4 \
	scotch-src-6.1.3 \
	scotch-src-7.0.4 \
	slurm-20.02.7 \
	sparse-0.6.3 \
	sqlite-3.31.1 \
	starpu-1.4.1 \
	suitesparse-32-5.12.0 \
	suitesparse-64-5.12.0 \
	suitesparse-src-5.12.0 \
	superlu-5.2.1 \
	superlu_dist-32-6.4.0 \
	superlu_dist-32-7.2.0 \
	superlu_dist-32-8.1.0 \
	superlu_dist-64-6.4.0 \
	superlu_dist-64-7.2.0 \
	superlu_dist-64-8.1.0 \
	superlu_dist-64-8.1.2 \
	superlu_dist-src-6.4.0 \
	superlu_dist-src-7.2.0 \
	superlu_dist-src-8.1.0 \
	superlu_dist-src-8.1.2 \
	tetgen-1.6.0 \
	texinfo-6.7 \
	texlive-20210325 \
	ucx-1.12.1 \
	ucx-src-1.12.1 \
	utf8cpp-3.2.1 \
	util-linux-2.34 \
	valgrind-3.19.0 \
	virtualgl-2.6.5 \
	vmtk-1.4.0 \
	vtk8-8.1.2 \
	vtk9-9.1.0 \
	xcb-proto-1.15 \
	xcb-util-0.4.0 \
	xcb-util-image-0.4.0 \
	xcb-util-keysyms-0.4.0 \
	xcb-util-renderutil-0.3.9 \
	xcb-util-wm-0.4.1 \
	xkbcommon-1.3.0 \
	xorg-libraries-2020-03-15 \
	xorg-util-macros-1.19.2 \
	xorgproto-2019.2 \
	xtensor-0.24.2 \
	xtl-0.7.4 \
	xtrans-1.4.0 \
	xz-5.2.7 \
	zlib-1.2.11

# Sort package list and remove duplicates
uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
pkgs := $(call uniq,$(sort $(pkgs)))

makefiles = $(pkgs:%=makefiles/%.mk)
pkgsrc = $(pkgs:%=%-src)
pkgunpack = $(pkgs:%=%-unpack)
pkgpatch = $(pkgs:%=%-patch)
pkgbuild = $(pkgs:%=%-build)
pkginstall = $(pkgs:%=%-install)
pkgmodulefile = $(pkgs:%-%-modulefile)
pkgclean = $(pkgs:%=%-clean)

all: $(pkgs)
src: $(pkgsrc)
unpack: $(pkgunpack)
patch: $(pkgpatch)
build: $(pkgbuild)
install: $(pkginstall)
modulefile: $(pkgmodulefile)
clean: $(pkgclean)
	rm -rf $(modulefilesdir)
	rm -rf $(pkgdir)
	rm -rf $(pkgsrcdir)

.PHONY: all src unpack patch build install modulefile describe clean

.SILENT: list-packages
.PHONY: list-packages
list-packages:
	$(foreach pkg,$(pkgs),printf "%s\n" "$(pkg)";)

.SILENT: describe-packages
.PHONY: describe-packages
describe-packages:
	$(foreach pkg,$(pkgs),printf "%-32s\t%s\n" "$(pkg)" "$($(pkg)-description)";)

pkgdescribe = $(pkgs:%=%-describe)
.SILENT: $(pkgdescribe)
.PHONY: $(pkgdescribe)
$(pkgdescribe):
	printf "%-32s\t%s\n" "$(patsubst %-describe,%,$@)" "$($(patsubst %-describe,%,$@)-description)"

.PHONY: $(pkgs)
.PHONY: $(pkgsrc)
.PHONY: $(pkgunpack)
.PHONY: $(pkgpatch)
.PHONY: $(pkgbuild)
.PHONY: $(pkginstall)
.PHONY: $(pkgmodulefile)
.PHONY: $(pkgclean)

$(pkgsrcdir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	touch $@
$(pkgdir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	touch $@
$(modulefilesdir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	touch $@

.SECONDEXPANSION:
include $(makefiles)
