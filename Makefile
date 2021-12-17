# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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

# Options
ENABLE_CUDA :=
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

# BLAS implementations: netlib-blas, openblas, blis-generic, blis-skx,
# blis-x86_64, blis-zen, blis-zen2 and gsl.
blas = openblas-0.3.12

# PETSc implementations: petsc-default, petsc-cuda
petsc = petsc-default-3.13.2

python-version-short = 3.7

# Select default package versions
pkgs = \
	$(blas) \
	$(mpi) \
	$(petsc)

# CUDA-related packages - note CUDA toolkit 10.1.243 is only supported
# on x86_64.
ifneq ($(ENABLE_CUDA),)
pkgs := $(pkgs) \
	combblas-cuda-1.6.2 \
	cuda-toolkit-10.1.243 \
	gdrcopy-2.2 \
	hypre-cuda-2.17.0 \
	mumps-cuda-5.2.1 \
	openmpi-cuda-4.0.5 \
	parmetis-cuda-4.0.3 \
	petsc-cuda-3.13.2 \
	petsc-cuda-3.16.2 \
	scalapack-cuda-2.1.0 \
	scotch-cuda-6.0.7 \
	superlu_dist-cuda-6.4.0 \
	ucx-cuda-1.9.0
endif

#
# SLURM
#
ifeq ($(WITH_SLURM),internal)
slurm = slurm-20.02.7
else ifneq ($(WITH_SLURM),)
SLURM_ROOT = $(WITH_SLURM)
endif

ifneq ($(SLURM_ROOT),)
export PATH := $(SLURM_ROOT)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(SLURM_ROOT)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(SLURM_ROOT)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(SLURM_ROOT)/lib:$(SLURM_ROOT)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(SLURM_ROOT)/lib:$(SLURM_ROOT)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
endif

#
# MPI
#
ifeq ($(WITH_MPI),openmpi-4.0.5)
mpi = openmpi-4.0.5
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),openmpi-cuda-4.0.5)
mpi = openmpi-cuda-4.0.5
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),mpich-3.3.2)
mpi = mpich-3.3.2
$(info Using internal MPI ($(mpi)))
else ifeq ($(WITH_MPI),mvapich-2.3.4)
mpi = mpich-2.3.4
$(info Using internal MPI ($(mpi)))
else
export MPI_HOME = $(WITH_MPI)
export MPICC = $(MPI_HOME)/bin/mpicc
export MPICXX = $(MPI_HOME)/bin/mpicxx
export MPIEXEC = $(MPI_HOME)/bin/mpiexec
export MPIF77 = $(MPI_HOME)/bin/mpif77
export MPIF90 = $(MPI_HOME)/bin/mpif90
export MPIFORT = $(MPI_HOME)/bin/mpifort
export MPIRUN = $(MPI_HOME)/bin/mpirun
export MPI_RUN = $(MPI_HOME)/bin/mpirun
$(info Using MPI from $(MPI_HOME))
export PATH := $(MPI_HOME)/bin$(if $(PATH),:$(PATH),)
export C_INCLUDE_PATH := $(MPI_HOME)/include$(if $(C_INCLUDE_PATH),:$(C_INCLUDE_PATH),)
export CPLUS_INCLUDE_PATH := $(MPI_HOME)/include$(if $(CPLUS_INCLUDE_PATH),:$(CPLUS_INCLUDE_PATH),)
export LIBRARY_PATH := $(MPI_HOME)/lib:$(MPI_HOME)/lib64$(if $(LIBRARY_PATH),:$(LIBRARY_PATH),)
export LD_LIBRARY_PATH := $(MPI_HOME)/lib:$(MPI_HOME)/lib64$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
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
	combblas-1.6.2 \
	combblas-src-1.6.2 \
	cpupower-4.19.75 \
	curl-7.69.1 \
	dealii-9.1.1 \
	doxygen-1.8.18 \
	eigen-3.3.7 \
	elfutils-0.177 \
	expat-2.2.9 \
	exprtk-93a9f44f9 \
	fenics-dolfin-2018-src-2018.1.0.post1 \
	fenics-dolfin-2018.1.0.post1 \
	fenics-dolfin-2019-src-2019.1.0.post0 \
	fenics-dolfin-2019.1.0.post0 \
	fenics-mshr-2019-src-2019.1.0 \
	fenics-mshr-2019.1.0 \
	fenics-dolfinx-20200525 \
	fenics-dolfinx-src-20200525 \
	fftw-3.3.8 \
	flex-2.6.4 \
	fmt-8.0.1 \
	fontconfig-2.13.91 \
	freeipmi-1.6.6 \
	freetype-2.10.1 \
	fribidi-1.0.10 \
	gc-8.0.4 \
	gcc-10.1.0 \
	gcc-11.2.0 \
	gcc-8.4.0 \
	gcc-9.2.0 \
	gcc-src-8.4.0 \
	gcc-src-10.1.0 \
	gdb-9.2 \
	gengetopt-2.23 \
	gettext-0.21 \
	ghostscript-9.54.0 \
	giflib-5.2.1 \
	gklib-5.1.0 \
	glib-2.64.1 \
	gmp-6.1.2 \
	gmsh-4.7.1 \
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
	hdf5-src-1.10.5 \
	hpl-2.3 \
	hunspell-1.7.0 \
	hwloc-2.4.1 \
	hwloc-cairo-2.4.1 \
	hwloc-src-2.4.1 \
	hypre-2.17.0 \
	hypre-src-2.17.0 \
	icu-69.1 \
	iperf-2.0.13 \
	ipopt-3.13.3 \
	itk-4.13.3 \
	knem-1.1.4 \
	lapack-3.9.0 \
	lcms2-2.12 \
	libarchive-3.4.2 \
	libatomic_ops-7.6.10 \
	libcerf-1.13 \
	libcheck-0.15.2 \
	libdmx-1.1.4 \
	libdrm-2.4.107 \
	libevent-2.1.11-stable \
	libfabric-1.11.1 \
	libfabric-fabtests-1.11.1 \
	libffi-3.2.1 \
	libfontenc-1.1.4 \
	libfs-1.0.8 \
	libgccjit-10.1.0 \
	libgcrypt-1.8.7 \
	libgd-2.2.5 \
	libgfortran-5.0.0 \
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
	libxcb-1.14 \
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
	meson-0.53.2 \
	metis-5.1.0 \
	metis-64-5.1.0 \
	metis-src-5.1.0 \
	mpc-1.1.0 \
	mpfr-4.0.2 \
	mpich-3.3.2 \
	mumps-5.2.1 \
	mumps-src-5.2.1 \
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
	ocaml-4.08.1 \
	openblas-0.3.12 \
	opencascade-7.5.0 \
	opencl-headers-2020.06.16 \
	openjpeg-2.4.0 \
	openmpi-4.0.5 \
	openmpi-src-4.0.5 \
	openssl-1.1.1c \
	osu-micro-benchmarks-mpich-5.6.3 \
	osu-micro-benchmarks-mvapich-5.6.3 \
	osu-micro-benchmarks-openmpi-5.6.3 \
	osu-micro-benchmarks-src-5.6.3 \
	pango-1.44.7 \
	parallel-20190922 \
	paraview-5.9.1 \
	parmetis-4.0.3 \
	parmetis-64-4.0.3 \
	parmetis-src-4.0.3 \
	patchelf-0.10 \
	pciutils-3.6.2 \
	pcre-8.44 \
	perf-4.19.75 \
	perl-5.30.2 \
	petsc-3.16.2 \
	petsc-default-3.13.2 \
	petsc-src-3.13.2 \
	petsc-src-3.16.2 \
	pixman-0.38.4 \
	pmix-3.1.5 \
	poppler-21.04.0 \
	protobuf-cpp-3.17.0 \
	protobuf-python-3.17.0 \
	pugixml-1.11 \
	pybind11-2.3.0 \
	python-3.7.4 \
	python-alabaster-0.7.12 \
	python-apipkg-1.5 \
	python-appdirs-1.4.4 \
	python-atomicwrites-1.4.0 \
	python-attrs-19.3.0 \
	python-babel-2.8.0 \
	python-breathe-4.13.1 \
	python-certifi-2020.6.20 \
	python-cffi-1.14.0 \
	python-chardet-3.0.4 \
	python-colorama-0.4.4 \
	python-coverage-5.1 \
	python-cycler-0.10.0 \
	python-cython-0.29.21 \
	python-dateutil-2.0 \
	python-distlib-0.3.1 \
	python-docutils-0.16 \
	python-execnet-1.7.1 \
	python-fenics-dijitso-2018.1.0 \
	python-fenics-dijitso-2019.1.0 \
	python-fenics-dolfin-2018.1.0.post1 \
	python-fenics-dolfin-2019.1.0.post0 \
	python-fenics-ffc-2018.1.0 \
	python-fenics-ffc-2019.1.0 \
	python-fenics-ffcx-20200522 \
	python-fenics-fiat-2018.1.0 \
	python-fenics-fiat-2019.1.0 \
	python-fenics-fiat-20200518 \
	python-fenics-mshr-2019.1.0 \
	python-fenics-ufl-2018.1.0 \
	python-fenics-ufl-2019.1.0 \
	python-fenics-ufl-20200512 \
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
	python-ldrb-2021.0.2 \
	python-llvmlite-0.35.0 \
	python-mako-1.1.4 \
	python-markupsafe-1.1.1 \
	python-matplotlib-3.1.1 \
	python-mccabe-0.6.1 \
	python-meshio-4.3.6 \
	python-more-itertools-8.3.0 \
	python-mpi4py-3.0.3 \
	python-mpmath-1.1.0 \
	python-nose-1.3.7 \
	python-numba-0.52.0 \
	python-numpy-1.19.2 \
	python-packaging-20.4 \
	python-pandas-1.0.3 \
	python-pathlib2-2.3.5 \
	python-petsc4py-3.13.0 \
	python-pillow-8.1.1 \
	python-pkgconfig-1.5.1 \
	python-pluggy-0.13.1 \
	python-ply-3.11 \
	python-psutil-5.7.0 \
	python-py-1.9.0 \
	python-pyadjoint-2019.1.1 \
	python-pycodestyle-2.6.0 \
	python-pycparser-2.20 \
	python-pydocstyle-5.0.2 \
	python-pyflakes-2.2.0 \
	python-pygments-2.6.1 \
	python-pygraphviz-1.5 \
	python-pyparsing-2.4.7 \
	python-pyra-pytorch-1.2.0 \
	python-pytest-6.1.1 \
	python-pytest-cov-2.9.0 \
	python-pytest-forked-1.1.3 \
	python-pytest-xdist-1.32.0 \
	python-pytz-2020.1 \
	python-numpy-quaternion-2021.11.4.15.26.3 \
	python-requests-2.23.0 \
	python-scipy-1.5.4 \
	python-setuptools-47.1.1 \
	python-setuptools_scm-4.1.1 \
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
	python-tox-3.20.1 \
	python-urllib3-1.25.11 \
	python-virtualenv-20.0.35 \
	python-wcwidth-0.1.9 \
	python-wheel-0.37.0 \
	python-xarray-0.15.1 \
	python-zipp-3.3.1 \
	qperf-0.4.11 \
	qt5-5.15.2 \
	rdma-core-31.0 \
	readline-8.0 \
	scalapack-2.1.0 \
	scalapack-src-2.1.0 \
	scotch-6.0.7 \
	scotch-src-6.0.7 \
	slurm-20.02.7 \
	sparse-0.6.3 \
	sqlite-3.31.1 \
	suitesparse-5.7.2 \
	superlu-5.2.1 \
	superlu_dist-6.4.0 \
	superlu_dist-src-6.4.0 \
	texinfo-6.7 \
	texlive-20210325 \
	ucx-1.9.0 \
	ucx-src-1.9.0 \
	utf8cpp-3.2.1 \
	util-linux-2.34 \
	valgrind-3.16.1 \
	virtualgl-2.6.5 \
	vmtk-1.4.0 \
	vtk8-8.1.2 \
	vtk9-9.1.0 \
	xcb-proto-1.14 \
	xcb-util-0.4.0 \
	xcb-util-image-0.4.0 \
	xcb-util-keysyms-0.4.0 \
	xcb-util-renderutil-0.3.9 \
	xcb-util-wm-0.4.1 \
	xkbcommon-1.3.0 \
	xorg-libraries-2020-03-15 \
	xorg-util-macros-1.19.2 \
	xorgproto-2019.2 \
	xtrans-1.4.0 \
	xz-5.2.5

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
