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

# MPI implementations: openmpi, mpich and mvapich.
mpi = openmpi-4.0.5

# SLURM versions: 18.08.9, 19.05.6 and 20.02.5
slurm = slurm-20.02.5

#
# Packages
#
pkgs = \
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
	clang-11.0.0 \
	cmake-3.17.2 \
	combblas-1.6.2 \
	cpupower-4.19.75 \
	cuda-toolkit-10.1.243 \
	curl-7.69.1 \
	dealii-9.1.1 \
	doxygen-1.8.18 \
	eigen-3.3.7 \
	elfutils-0.177 \
	expat-2.2.9 \
	fenics-dolfin-2018-src-2018.1.0.post1 \
	fenics-dolfin-2018.1.0.post1 \
	fenics-dolfin-2019-src-2019.1.0.post0 \
	fenics-dolfin-2019.1.0.post0 \
	fenics-dolfinx-20200525 \
	fenics-dolfinx-src-20200525 \
	fftw-3.3.8 \
	flex-2.6.4 \
	fontconfig-2.13.91 \
	freeipmi-1.6.6 \
	freetype-2.10.1 \
	fribidi-1.0.10 \
	gcc-10.1.0 \
	gcc-9.2.0 \
	gcc-src-10.1.0 \
	gdb-9.2 \
	gengetopt-2.23 \
	gettext-0.21 \
	giflib-5.2.1 \
	glib-2.64.1 \
	gmp-6.1.2 \
	gmsh-4.7.1 \
	gnuplot-5.2.8 \
	gobject-introspection-1.64.0 \
	googletest-1.10.0 \
	gperf-3.1 \
	graphviz-2.44.0 \
	gsl-2.6 \
	harfbuzz-2.6.4 \
	hdf5-1.10.5 \
	hdf5-parallel-1.10.5 \
	hdf5-src-1.10.5 \
	hpl-2.3 \
	hwloc-2.0.4 \
	hwloc-cairo-2.0.4 \
	hwloc-src-2.0.4 \
	hypre-2.17.0 \
	iperf-2.0.13 \
	knem-1.1.4 \
	lapack-3.9.0 \
	libarchive-3.4.2 \
	libcerf-1.13 \
	libdmx-1.1.4 \
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
	libjpeg-turbo-2.0.4 \
	libnl-3.2.25 \
	libpciaccess-0.16 \
	libpfm-4.10.1 \
	libpng-1.6.37 \
	libsm-1.2.3 \
	libstdcxx-6.0.28 \
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
	meson-0.53.2 \
	metis-5.1.0 \
	mpc-1.1.0 \
	mpfr-4.0.2 \
	mpich-3.3.2 \
	mumps-5.2.1 \
	munge-0.5.13 \
	mvapich-2.3.4 \
	nasm-2.14.02 \
	ncurses-6.1 \
	netlib-blas-3.8.0 \
	ninja-1.10.0 \
	numactl-2.0.13 \
	ocaml-4.08.1 \
	openblas-0.3.12 \
	opencl-headers-2020.06.16 \
	openmpi-4.0.5 \
	openssl-1.1.1c \
	osu-micro-benchmarks-mpich-5.6.3 \
	osu-micro-benchmarks-mvapich-5.6.3 \
	osu-micro-benchmarks-openmpi-5.6.3 \
	osu-micro-benchmarks-src-5.6.3 \
	pango-1.44.7 \
	parallel-20190922 \
	parmetis-4.0.3 \
	patchelf-0.10 \
	pciutils-3.6.2 \
	pcre-8.44 \
	perf-4.19.75 \
	perl-5.30.2 \
	petsc-3.13.2 \
	pixman-0.38.4 \
	pmix-3.1.4 \
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
	python-fenics-ufl-2018.1.0 \
	python-fenics-ufl-2019.1.0 \
	python-fenics-ufl-20200512 \
	python-filelock-3.0.12 \
	python-flake8-3.8.2 \
	python-flaky-3.7.0 \
	python-freezegun-1.0.0 \
	python-h5py-2.10.0 \
	python-hypothesis-5.37.4 \
	python-idna-2.9 \
	python-imagesize-1.2.0 \
	python-importlib_metadata-1.6.0 \
	python-iniconfig-1.1.1 \
	python-ipython-7.14.0 \
	python-jinja2-2.11.2 \
	python-kiwisolver-1.2.0 \
	python-llvmlite-0.35.0 \
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
	python-pkgconfig-1.5.1 \
	python-pluggy-0.13.1 \
	python-ply-3.11 \
	python-psutil-5.7.0 \
	python-py-1.9.0 \
	python-pycodestyle-2.6.0 \
	python-pycparser-2.20 \
	python-pydocstyle-5.0.2 \
	python-pyflakes-2.2.0 \
	python-pygments-2.6.1 \
	python-pygraphviz-1.5 \
	python-pyparsing-2.4.7 \
	python-pytest-6.1.1 \
	python-pytest-cov-2.9.0 \
	python-pytest-forked-1.1.3 \
	python-pytest-xdist-1.32.0 \
	python-pytz-2020.1 \
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
	python-xarray-0.15.1 \
	python-zipp-3.3.1 \
	qperf-0.4.11 \
	rdma-core-31.0 \
	readline-8.0 \
	scalapack-2.1.0 \
	scotch-6.0.7 \
	slurm-18.08.9 \
	slurm-19.05.6 \
	slurm-20.02.5 \
	sparse-0.6.3 \
	sqlite-3.31.1 \
	suitesparse-5.7.2 \
	superlu-5.2.1 \
	superlu_dist-6.4.0 \
	texinfo-6.7 \
	ucx-1.9.0 \
	util-linux-2.34 \
	valgrind-3.16.1 \
	xcb-proto-1.14 \
	xorg-libraries-2020-03-15 \
	xorg-util-macros-1.19.2 \
	xorgproto-2019.2 \
	xtrans-1.4.0 \
	xz-5.2.5 \

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
