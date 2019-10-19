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
elfutils/0.177                hdf5/1.10.5       libpng/1.6.37           numactl/2.0.12   osu-micro-benchmarks/5.6.2  pybind11/2.3.0         python3.7/fenics/2019.1.0.post0    python3.7/pytest/5.1.0     suitesparse/5.4.0
fenics-dolfin/2019.1.0.post0  hwloc/2.0.4       libtool/2.4.6           ocaml/4.07.1     parallel/20190922           python/3.7.4           python3.7/matplotlib/3.1.1         python3.7/scipy/1.3.1      superlu/5.2.1
```
The following command can now be used to load, for example, PETSc:
```
$ module load petsc/3.11.3
Loading petsc/3.11.3
  Loading requirement: boost/1.71.0 openblas/0.3.7 hwloc/2.0.4 knem/1.1.3 libevent/2.1.11-stable numactl/2.0.12 ucx/1.6.0 openmpi/4.0.1 hypre/2.17.0 metis/5.1.0 mumps/5.2.1 parmetis/4.0.3 scalapack/2.0.2 scotch/6.0.7 suitesparse/5.4.0 superlu/5.2.1
    superlu_dist/6.1.1
```

Modules
=======
The available modules are shown in the table below.

| Module       | Version | Description | Dependencies |
| :---         | ---:    | :---         | :---  |
| [boost](https://www.boost.org) | 1.71.0 | Libraries for the C++ programming language | mpi, python |
| [cmake](https://cmake.org) | 3.15.2 | Open-source, cross-platform tools to build, test and package software | |
| [Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page) | 3.3.7 | C++ template library for linear algebra | Optionally depends on boost, mpfr, gmp, suitesparse, superlu |
| [fenics](https://bitbucket.org/fenics-project/dolfin/) | 2019.1.0.post0 | FEniCS Project: C++ and Python interface to the FEniCS computing platform for solving partial differential equations | Python,  |
| [fenics-dolfin](https://bitbucket.org/fenics-project/dolfin/) | 2019.1.0.post0 | FEniCS Project: C++ interface to the FEniCS computing platform for solving partial differential equations | Python,  |
| [gmp](https://gmplib.org) | 6.1.2 | Library for arbitrary precision arithmetic | |
| [gsl](https://www.gnu.org/software/gsl/) | 2.6 | GNU Scientific Library | |
| [HDF5](https://www.hdfgroup.org/solutions/hdf5/) | 1.10.5 | HDF5 high performance data software library and file format | MPI |
| [hwloc](https://www.open-mpi.org/projects/hwloc/) | 2.0.4 | Portable abstraction of hierarchical topology of modern architectures | |
| [HYPRE](https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods) | 2.17.0 | Scalable Linear Solvers and Multigrid Methods | numactl, BLAS, MPI |
| [knem](http://knem.gforge.inria.fr/) | 1.1.3 | High-Performance Intra-Node MPI Communication | hwloc |
| [libffi](https://sourceware.org/libffi/) | 3.2.1 | A Portable Foreign Function Interface Library | |
| [libtool](https://www.gnu.org/software/libtool) | 2.4.6 | The GNU Portable Library Tool | |
| [METIS](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview) | 5.1.0 | Serial Graph Partitioning and Fill-reducing Matrix Ordering | cmake |
| [mpfr](https://www.mpfr.org) | 4.0.2 | C library for multiple-precision floating-point computations | gmp |
| [MUMPS](http://mumps.enseeiht.fr/) | 5.2.1 | MUltifrontal Massively Parallel sparse direct Solver | BLAS, MPI, METIS, ParMETIS, SCOTCH, ScaLAPACK |
| [numactl](https://github.com/numactl/numactl) | 2.0.12 | NUMA support for Linux | |
| [openblas](https://openblas.net) | 0.3.7 | Optimized BLAS library | cmake |
| [OpenMPI](https://www.open-mpi.org) | 4.0.1 | A High Performance Message Passing Library | knem, numactl, ucx |
| [OpenSSL](https://www.openssl.org) | 1.1.1c | Cryptography and SSL/TLS toolkits | |
| [ParMETIS](http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview) | 4.0.3 | Parallel Graph Partitioning and Fill-reducing Matrix Ordering | BLAS, MPI |
| [patchelf](https://nixos.org/patchelf.html) | 0.10 | A small utility to modify the dynamic linker and RPATH of ELF executables | |
| [PETSc](https://www.mcs.anl.gov/petsc/) | 3.11.3 | Portable, Extensible Toolkit for Scientific Computation | boost, BLAS, MPI, hwloc, hypre, metis, mumps, parmetis, scalapack, scotch, suitesparse, superlu, superlu\_dist |
| [pybind11](https://github.com/pybind/pybind11) | 2.3.0 | Seamless operability between C++11 and Python | python |
| [python](https://github.com/pybind/pybind11) | 3.7.4 | Python programming language | libffi |
| [ScaLAPACK](http://www.netlib.org/scalapack/) | 2.0.2 | Scalable Linear Algebra PACKage | BLAS, MPI |
| [SCOTCH](https://www.labri.fr/perso/pelegrin/scotch/) | 6.0.7 | Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package | MPI |
| [SuiteSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html) | 5.4.0 | A suite of sparse matrix software | BLAS |
| [SuperLU](https://github.com/xiaoyeli/superlu) | 5.2.1 | Direct solver for large, sparse non-symmetric systems of linear equations | BLAS |
| [SuperLU\_DIST](https://github.com/xiaoyeli/superlu_dist) | 6.1.1 | MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory | BLAS, ParMETIS |
| [ucx](http://openucx.org) | 1.6.0 | Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications | knem |


### Python modules
| Module       | Version | Description | Dependencies |
| :---         | ---:    | :---         | :---  |
| [python3.7/fenics](https://bitbucket.org/fenics-project/dolfin/) | 2019.1.0.post0 | FEniCS Project: Python interface to the FEniCS computing platform for solving partial differential equations | Python,  |
| [python3.7/fenics-dijitso](https://bitbucket.org/fenics-project/dijitso/) | 2019.1.0 | FEniCS Project: Distributed just-in-time compilation | python, numpy |
| [python3.7/fenics-FFC](https://bitbucket.org/fenics-project/ffc/) | 2019.1.0 | FEniCS Project: Compiler for finite element variational forms | python, numpy, mpmath, sympy, fiat, ufl  |
| [python3.7/fenics-FIAT](https://bitbucket.org/fenics-project/fiat/) | 2019.1.0 | FEniCS Project: FInite element Automatic Tabulator | python, numpy, mpmath, sympy |
| [python3.7/fenics-ufl](https://bitbucket.org/fenics-project/ufl/) | 2019.1.0 | FEniCS Project: Unified Form Language for finite element variational forms | python, numpy |
| [python3.7/matplotlib](https://matplotlib.org) | 3.1.1 | 2D plotting library | python |
| [python3.7/mpi4py](https://mpi4py.readthedocs.io) | 3.0.2 | Python bindings for the Message Passing Interface (MPI) | python, numactl, ucx, openmpi |
| [python3.7/mpmath](http://mpmath.org) | 1.1.0 | Python library for arbitrary-precision floating-point arithmetic | python |
| [python3.7/numpy](https://www.numpy.org) | 1.17.0 | Fundamental package for scientific computing with Python | python |
| [python3.7/petsc4py](https://bitbucket.org/petsc/petsc4py) | 3.11.0 | Python bindings for PETSc | boost, openblas, numactl, ucx, openmpi, hwloc, hypre, metis, mumps, parmetis, scalapack, scotch, suitesparse, superlu, superlu\_dist, petsc, python, numpy, mpi4py |
| [python3.7/pkgconfig](https://github.com/matze/pkgconfig) | 1.5.1 | Python interface to the pkg-config command line tool | python |
| [python3.7/ply](https://www.dabeaz.com/ply) | 3.11 | lex and yacc parsing tools for Python | python |
| [python3.7/pytest](https://docs.pytest.org/) | 5.1.0 | Python testing framework | python |
| [python3.7/scipy](https://www.scipy.org) | 1.3.1 | Fundamental package for scientific computing with Python | python, python3.7/numpy |
| [python3.7/sympy](https://www.sympy.org) | 1.4 | Computer algebra system written in pure Python | python, mpmath |
