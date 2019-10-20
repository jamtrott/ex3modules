Modules
=======
The available modules are shown in the table below.

| Package | Version | Module name | Description | Dependencies |
| :---    | ---:    | :---        | :---        | :---         |
| [binutils](https://www.gnu.org/software/binutils/) | 2.32 | binutils/2.32 | Tools for creating and managing binary programs |  |
| [boost](https://www.boost.org) | 1.71.0 | boost/1.71.0 | Libraries for the C++ programming language | openmpi/4.0.1, python/3.7.4 |
| [cmake](https://cmake.org/) | 3.15.2 | cmake/3.15.2 | Open-source, cross-platform tools to build, test and package software |  |
| [cuda-toolkit](https://developer.nvidia.com/cuda-toolkit) | 10.1.243 | cuda-toolkit/10.1.243 | Development environment for high performance GPU-accelerated applications |  |
| [doxygen](http://www.doxygen.nl/) | 1.8.16 | doxygen/1.8.16 | Tool for generating documentation from annotated C++ source code | cmake/3.15.2, python/3.7.4 |
| [eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page) | 3.3.7 | eigen/3.3.7 | C++ template library for linear algebra | cmake/3.15.2, boost/1.71.0, mpfr/4.0.2, gmp/6.1.2, metis/5.1.0, suitesparse/5.4.0, openblas/0.3.7, superlu/5.2.1 |
| [elfutils](https://sourceware.org/elfutils/) | 0.177 | elfutils/0.177 | Collection of utilities to handle ELF objects |  |
| [fenics](https://fenicsproject.org) | 2019.1.0 | fenics/2019.1.0 | Computing platform for solving partial differential equations | numactl/2.0.12, ucx/1.6.0, openmpi/4.0.1, openblas/0.3.7, hdf5/1.10.5, parmetis/4.0.3, scotch/6.0.7, suitesparse/5.4.0, hwloc/2.0.4, hypre/2.17.0, metis/5.1.0, mumps/5.2.1, scalapack/2.0.2, superlu/5.2.1, superlu\_dist/6.1.1, eigen/3.3.7, petsc/3.11.3, python/3.7.4, python3.7/numpy/1.17.0, python3.7/mpmath/1.1.0, python3.7/sympy/1.4, pybind11/2.3.0, python3.7/ply/3.11, python3.7/mpi4py/3.0.2, python3.7/petsc4py/3.11.0, python3.7/fenics-dijitso/2019.1.0, python3.7/fenics-fiat/2019.1.0, python3.7/fenics-ufl/2019.1.0, python3.7/fenics-ffc/2019.1.0, python3.7/fenics/2019.1.0.post0, fenics-dolfin/2019.1.0.post0, python3.7/matplotlib/3.1.1 |
| [dolfin](https://bitbucket.org/fenics-project/dolfin/) | 2019.1.0.post0 | fenics-dolfin/2019.1.0.post0 | C++ interface to the FEniCS computing platform for solving partial differential equations | cmake/3.15.2, boost/1.71.0, openmpi/4.0.1, openblas/0.3.7, hdf5/1.10.5, parmetis/4.0.3, scotch/6.0.7, suitesparse/5.4.0, metis/5.1.0, eigen/3.3.7, petsc/3.11.3, python/3.7.4, python3.7/fenics-dijitso/2019.1.0, python3.7/fenics-fiat/2019.1.0, python3.7/fenics-ufl/2019.1.0, python3.7/fenics-ffc/2019.1.0 |
| [freetype](https://www.freetype.org) | 2.10.1 | freetype/2.10.1 | Font rendering library | libpng/1.6.37 |
| [gcc](https://gcc.gnu.org) | 9.2.0 | gcc/9.2.0 | GNU Compiler Collection | mpfr/4.0.2, gmp/6.1.2, mpc/1.1.0 |
| [gmp](https://gmplib.org) | 6.1.2 | gmp/6.1.2 | Library for arbitrary precision arithmetic |  |
| [googletest](https://github.com/google/googletest) | 1.8.1 | googletest/1.8.1 | Googletest - Google Testing and Mocking Framework | cmake/3.15.2 |
| [gsl](https://www.gnu.org/software/gsl/) | 2.6 | gsl/2.6 | The GNU Scientific Library (GSL) is a collection of routines for numerical computing. |  |
| [hdf5](https://www.hdfgroup.org/solutions/hdf5/) | 1.10.5 | hdf5/1.10.5 | HDF5 high performance data software library and file format | openmpi/4.0.1 |
| [hwloc](https://www.open-mpi.org/projects/hwloc/) | 2.0.4 | hwloc/2.0.4 | Portable abstraction of hierarchical topology of modern architectures |  |
| [hypre](https://github.com/hypre-space/hypre) | 2.17.0 | hypre/2.17.0 | Scalable Linear Solvers and Multigrid Methods | openblas/0.3.7, openmpi/4.0.1 |
| [iperf](https://sourceforge.net/projects/iperf2/) | 2.0.13 | iperf/2.0.13 | Network traffic tool for measuring TCP and UDP performance |  |
| [knem](http://knem.gforge.inria.fr/) | 1.1.3 | knem/1.1.3 | High-Performance Intra-Node MPI Communication | hwloc/2.0.4 |
| [libevent](https://libevent.org) | 2.1.11-stable | libevent/2.1.11-stable | Event notification library |  |
| [libffi](https://sourceware.org/libffi/) | 3.2.1 | libffi/3.2.1 | A Portable Foreign Function Interface Library |  |
| [libpfm](http://perfmon2.sourceforge.net/) | 4.10.1 | libpfm/4.10.1 | Performance monitoring library for Linux |  |
| [libpng](http://www.libpng.org/pub/png/libpng.html) | 1.6.37 | libpng/1.6.37 | Official Portable Network Graphics reference library for handling PNG images |  |
| [libtool](https://www.gnu.org/software/libtool/) | 2.4.6 | libtool/2.4.6 | The GNU Portable Library Tool |  |
| [libunwind](https://www.nongnu.org/libunwind/) | 1.3.1 | libunwind/1.3.1 | Library for working with program call-chains |  |
| [metis](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview) | 5.1.0 | metis/5.1.0 | Serial Graph Partitioning and Fill-reducing Matrix Ordering | cmake/3.15.2 |
| [mpc](http://www.multiprecision.org/mpc) | 1.1.0 | mpc/1.1.0 | Library for arbitrary precision complex arithmetic with correct rounding | gmp/6.1.2, mpfr/4.0.2 |
| [mpfr](https://www.mpfr.org) | 4.0.2 | mpfr/4.0.2 | C library for multiple-precision floating-point computations | gmp/6.1.2 |
| [mumps](http://mumps.enseeiht.fr/) | 5.2.1 | mumps/5.2.1 | MUltifrontal Massively Parallel sparse direct Solver | openblas/0.3.7, openmpi/4.0.1, metis/5.1.0, parmetis/4.0.3, scotch/6.0.7, scalapack/2.0.2 |
| [munge](https://dun.github.io/munge/) | 0.5.13 | munge/0.5.13 | Authentication service for creating and validating credentials | openssl/1.1.1c |
| [numactl](https://github.com/numactl/numactl) | 2.0.12 | numactl/2.0.12 | NUMA support for Linux |  |
| [ocaml](https://ocaml.org) | 4.07.1 | ocaml/4.07.1 | Core OCaml system with compilers, runtime system, and base libraries |  |
| [opam](https://opam.ocaml.org) | 2.0.5 | ocaml4.07/opam/2.0.5 | Source-based package manager for OCaml | ocaml/4.07.1 |
| [ocaml](https://ocaml.org) | 4.08.1 | ocaml/4.08.1 | Core OCaml system with compilers, runtime system, and base libraries |  |
| [opam](https://opam.ocaml.org) | 2.0.5 | ocaml4.08/opam/2.0.5 | Source-based package manager for OCaml | ocaml/4.08.1 |
| [openblas](http://www.openblas.net) | 0.3.7 | openblas/0.3.7 | Optimized BLAS library | cmake/3.15.2, gcc/9.2.0 |
| [openmpi](https://www.open-mpi.org) | 4.0.1 | openmpi/4.0.1 | A High Performance Message Passing Library | knem/1.1.3, hwloc/2.0.4, libevent/2.1.11-stable, numactl/2.0.12, ucx/1.6.0 |
| [openssl](https://www.openssl.org/) | 1.1.1c | openssl/1.1.1c | TLS/SSL and crypto library |  |
| [osu-micro-benchmarks](http://mvapich.cse.ohio-state.edu/benchmarks/) | 5.6.2 | osu-micro-benchmarks/5.6.2 | Benchmarks for MPI, OpenSHMEM, UPC and UPC++ | openmpi/4.0.1 |
| [parallel](https://www.gnu.org/software/parallel/) | 20190922 | parallel/20190922 | Shell tool for executing jobs in parallel using one or more computers |  |
| [parmetis](http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview) | 4.0.3 | parmetis/4.0.3 | Parallel Graph Partitioning and Fill-reducing Matrix Ordering | cmake/3.15.2, openmpi/4.0.1 |
| [patchelf](https://github.com/NixOS/patchelf) | 0.10 | patchelf/0.10 | A small utility to modify the dynamic linker and RPATH of ELF executables |  |
| [perf](https://perf.wiki.kernel.org/index.php/Main_Page) | 4.19.75 | perf/4.19.75 | Performance analysis tools for Linux | numactl/2.0.12, elfutils/0.177, openssl/1.1.1c, libunwind/1.3.1 |
| [petsc](https://www.mcs.anl.gov/petsc/) | 3.11.3 | petsc/3.11.3 | Portable, Extensible Toolkit for Scientific Computation | boost/1.71.0, openblas/0.3.7, openmpi/4.0.1, hwloc/2.0.4, hypre/2.17.0, metis/5.1.0, mumps/5.2.1, parmetis/4.0.3, python/3.7.4, scalapack/2.0.2, scotch/6.0.7, suitesparse/5.4.0, superlu/5.2.1, superlu\_dist/6.1.1 |
| [petsc](https://www.mcs.anl.gov/petsc/) | 3.11.3-cuda | petsc/3.11.3-cuda | Portable, Extensible Toolkit for Scientific Computation | boost/1.71.0, openblas/0.3.7, openmpi/4.0.1, hwloc/2.0.4, hypre/2.17.0, metis/5.1.0, mumps/5.2.1, parmetis/4.0.3, python/3.7.4, scalapack/2.0.2, scotch/6.0.7, suitesparse/5.4.0, superlu/5.2.1, superlu\_dist/6.1.1, cuda-toolkit/10.1.243 |
| [pmix](https://pmix.org) | 3.1.4 | pmix/3.1.4 | PMIx: Process management for exascale environments | hwloc/2.0.4, libevent/2.1.11-stable |
| [pybind11](https://github.com/pybind/pybind11) | 2.3.0 | pybind11/2.3.0 | Seamless operability between C++11 and Python | boost/1.71.0, cmake/3.15.2, python/3.7.4, python3.7/pytest/5.1.0 |
| [python](https://www.python.org/) | 3.7.4 | python/3.7.4 | Python programming language | libffi/3.2.1, openssl/1.1.1c |
| [breathe](https://breathe.readthedocs.io/) | 4.13.1 | python3.7/breathe/4.13.1 | Bridge between the Sphinx and Doxygen documentation systems | python/3.7.4 |
| [cython](https://www.cython.org/) | 0.29.13 | python3.7/cython/0.29.13 | Optimising static compiler for Python | python/3.7.4 |
| [fenics](https://bitbucket.org/fenics-project/dolfin/) | 2019.1.0.post0 | python3.7/fenics/2019.1.0.post0 | Python interface to the FEniCS computing platform for solving partial differential equations | cmake/3.15.2, python/3.7.4, python3.7/numpy/1.17.0, python3.7/pkgconfig/1.5.1, python3.7/fenics-dijitso/2019.1.0, python3.7/fenics-fiat/2019.1.0, python3.7/fenics-ufl/2019.1.0, python3.7/fenics-ffc/2019.1.0, pybind11/2.3.0, python3.7/ply/3.11, python3.7/mpi4py/3.0.2, python3.7/petsc4py/3.11.0, fenics-dolfin/2019.1.0.post0 |
| [fenics-dijitso](https://bitbucket.org/fenics-project/dijitso/) | 2019.1.0 | python3.7/fenics-dijitso/2019.1.0 | FEniCS Project: Distributed just-in-time compilation | python/3.7.4, python3.7/numpy/1.17.0 |
| [fenics-ffc](https://bitbucket.org/fenics-project/ffc/) | 2019.1.0 | python3.7/fenics-ffc/2019.1.0 | FEniCS Project: FEniCS Form Compiler | python/3.7.4, python3.7/numpy/1.17.0, python3.7/mpmath/1.1.0, python3.7/sympy/1.4, python3.7/fenics-dijitso/2019.1.0, python3.7/fenics-fiat/2019.1.0, python3.7/fenics-ufl/2019.1.0 |
| [fenics-fiat](https://bitbucket.org/fenics-project/fiat/) | 2019.1.0 | python3.7/fenics-fiat/2019.1.0 | FEniCS Project: FInite element Automatic Tabulator | python/3.7.4, python3.7/numpy/1.17.0, python3.7/mpmath/1.1.0, python3.7/sympy/1.4 |
| [fenics-ufl](https://bitbucket.org/fenics-project/ufl/) | 2019.1.0 | python3.7/fenics-ufl/2019.1.0 | FEniCS Project: Unified Form Language | python/3.7.4, python3.7/numpy/1.17.0 |
| [matplotlib](https://matplotlib.org) | 3.1.1 | python3.7/matplotlib/3.1.1 | 2D plotting library | freetype/2.10.1, python/3.7.4, python3.7/numpy/1.17.0 |
| [mpi4py](https://mpi4py.readthedocs.io/) | 3.0.2 | python3.7/mpi4py/3.0.2 | Python bindings for the Message Passing Interface (MPI) | python/3.7.4, openmpi/4.0.1 |
| [mpmath](https://www.mpmath.org/) | 1.1.0 | python3.7/mpmath/1.1.0 | Python library for arbitrary-precision floating-point arithmetic | python/3.7.4 |
| [numpy](https://www.numpy.org/) | 1.17.0 | python3.7/numpy/1.17.0 | Fundamental package for scientific computing with Python | python/3.7.4 |
| [petsc4py](https://bitbucket.org/petsc/petsc4py) | 3.11.0 | python3.7/petsc4py/3.11.0 | Python bindings for PETSc | petsc/3.11.3, python/3.7.4, python3.7/numpy/1.17.0, python3.7/mpi4py/3.0.2 |
| [pkgconfig](https://github.com/matze/pkgconfig) | 1.5.1 | python3.7/pkgconfig/1.5.1 | Python interface to the pkg-config command line tool | python/3.7.4 |
| [ply](https://www.dabeaz.com/ply/) | 3.11 | python3.7/ply/3.11 | lex and yacc parsing tools for Python | python/3.7.4 |
| [pytest](https://docs.pytest.org/) | 5.1.0 | python3.7/pytest/5.1.0 | Python testing framework | python/3.7.4 |
| [scipy](https://www.scipy.org/) | 1.3.1 | python3.7/scipy/1.3.1 | Fundamental package for scientific computing with Python | python/3.7.4, python3.7/cython/0.29.13, python3.7/numpy/1.17.0, openblas/0.3.7 |
| [sphinx](https://www.sphinx-doc.org/) | 2.2.0 | python3.7/sphinx/2.2.0 | Python documentation generator | python/3.7.4 |
| [sympy](https://www.sympy.org/) | 1.4 | python3.7/sympy/1.4 | Computer algebra system written in pure Python | python/3.7.4, python3.7/mpmath/1.1.0 |
| [qperf](https://github.com/linux-rdma/qperf) | 0.4.11 | qperf/0.4.11 | Tool for measuring socket and RDMA performance |  |
| [scalapack](http://www.netlib.org/scalapack/) | 2.0.2 | scalapack/2.0.2 | Scalable Linear Algebra PACKage | cmake/3.15.2, openblas/0.3.7, openmpi/4.0.1 |
| [scotch](https://www.labri.fr/perso/pelegrin/scotch/) | 6.0.7 | scotch/6.0.7 | Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package | openmpi/4.0.1 |
| [slurm](https://www.schedmd.com) | 19.05.2 | slurm/19.05.2 | Highly configurable open-source workload manager | pmix/3.1.4, ucx/1.6.0, numactl/2.0.12, hwloc/2.0.4, munge/0.5.13 |
| [suitesparse](http://faculty.cse.tamu.edu/davis/suitesparse.html) | 5.4.0 | suitesparse/5.4.0 | A suite of sparse matrix software | cmake/3.15.2, openblas/0.3.7, metis/5.1.0 |
| [superlu](https://github.com/xiaoyeli/superlu) | 5.2.1 | superlu/5.2.1 | Direct solver for large, sparse non-symmetric systems of linear equations | cmake/3.15.2, openblas/0.3.7 |
| [superlu_dist](https://github.com/xiaoyeli/superlu_dist) | 6.1.1 | superlu_dist/6.1.1 | MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory | cmake/3.15.2, openblas/0.3.7, openmpi/4.0.1, parmetis/4.0.3 |
| [ucx](http://www.openucx.org) | 1.6.0 | ucx/1.6.0 | Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications | knem/1.1.3, numactl/2.0.12 |
