# ex3-modules
This repository contains scripts for **building and installing a variety of software packages** on systems that use [Environment Modules](http://modules.sourceforge.net/), a software packaging system that is typically used to manage software on supercomputing clusters.

For example, *ex3-modules* has been used to install software on [**eX3**](https://www.ex3.simula.no), a national Experimental Infrastructure for Exploration of Exascale Computing at Simula Research Laboratory, Norway.

Table of contents
-----------------
 * [Requirements](#requirements)
 * [Usage](#usage)
 * [Modules](#modules)

Requirements
============
This repository consists of a collection of shell scripts, and, therefore, does not require any installation.

*ex3-modules* has been tested on Ubuntu 18.04.3 LTS on `x86_64` and `aarch64`.

Usage
=====

Building modules
----------------
The example below shows how to build a module for PETSc 3.11.3, together with any modules that it depends on, and install it in `$HOME/local`:
```
./build.sh --prefix=$HOME/ex3-modules --build-dependencies petsc/3.11.3
```

For a complete list of options, run
```
./build.sh --help
```

Using modules
-------------
Once the desired packages have been installed to, for example, `$HOME/ex3-modules`, they can be made available via the modules system by running
```
module use $HOME/ex3-modules/modulefiles
```
As usual, the installed modules can now be displayed as follows:
```
$ module avail
------------------------------------------------------------------------------------------------------ $HOME/ex3-modules/modulefiles ------------------------------------------------------------------------------------------------------
binutils/2.32                 fenics/2019.1.0   hypre/2.17.0            libunwind/1.3.1  ocaml/4.08.1                parmetis/4.0.3         python3.7/breathe/4.13.1           python3.7/mpi4py/3.0.2     python3.7/sphinx/2.2.0  superlu_dist/6.1.1
boost/1.71.0                  freetype/2.10.1   iperf/2.0.13            metis/5.1.0      ocaml4.07/opam/2.0.5        patchelf/0.10          python3.7/cython/0.29.13           python3.7/mpmath/1.1.0     python3.7/sympy/1.4     ucx/1.6.0
cmake/3.15.2                  gcc/9.2.0         knem/1.1.3              mpc/1.1.0        ocaml4.08/opam/2.0.5        perf/4.19.75           python3.7/fenics-dijitso/2019.1.0  python3.7/numpy/1.17.0     qperf/0.4.11
cuda-toolkit/10.1.243         gmp/6.1.2         libevent/2.1.11-stable  mpfr/4.0.2       openblas/0.3.7              petsc/3.11.3(default)  python3.7/fenics-ffc/2019.1.0      python3.7/petsc4py/3.11.0  scalapack/2.0.2
doxygen/1.8.16                googletest/1.8.1  libffi/3.2.1            mumps/5.2.1      openmpi/4.0.1               petsc/3.11.3-cuda      python3.7/fenics-fiat/2019.1.0     python3.7/pkgconfig/1.5.1  scotch/6.0.7
eigen/3.3.7                   gsl/2.6           libpfm/4.10.1           munge/0.5.13     openssl/1.1.1c              pmix/3.1.4             python3.7/fenics-ufl/2019.1.0      python3.7/ply/3.11         slurm/19.05.2
elfutils/0.177                hdf5/1.10.5       libpng/1.6.37           numactl/2.0.13   osu-micro-benchmarks/5.6.2  pybind11/2.3.0         python3.7/fenics/2019.1.0.post0    python3.7/pytest/5.1.0     suitesparse/5.4.0
fenics-dolfin/2019.1.0.post0  hwloc/2.0.4       libtool/2.4.6           ocaml/4.07.1     parallel/20190922           python/3.7.4           python3.7/matplotlib/3.1.1         python3.7/scipy/1.3.1      superlu/5.2.1
```
The following command can now be used to load, for example, PETSc:
```
$ module load petsc/3.11.3
Loading petsc/3.11.3
  Loading requirement: boost/1.71.0 openblas/0.3.7 hwloc/2.0.4 knem/1.1.3 libevent/2.1.11-stable numactl/2.0.13 ucx/1.6.0 openmpi/4.0.1 hypre/2.17.0 metis/5.1.0 mumps/5.2.1 parmetis/4.0.3 scalapack/2.0.2 scotch/6.0.7 suitesparse/5.4.0 superlu/5.2.1
    superlu_dist/6.1.1
```

Modules
=======
See the list of [available modules](docs/modules.md).
