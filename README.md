# ex3-modules
This repository contains scripts for building and installing a variety of software packages to an Environment Modules system. It is used to install software on the **eX3** cluster, a national Experimental Infrastructure for Exploration of Exascale Computing at Simula Research Laboratory, Norway.


## Modules
The available modules are shown in the table below.

| Module       | Version | Description | Dependencies |
| :---         | ---:    | :---         | :---  |
| [cmake](https://cmake.org) | 3.15.2 | Open-source, cross-platform tools to build, test and package software | |
| [Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page) | 3.3.7 | C++ template library for linear algebra | Optionally depends on boost, mpfr, gmp, suitesparse, superlu |
| [fenicsproject/dijitso](https://bitbucket.org/fenics-project/dijitso/src/master/) | 2019.1.0 | FEniCS Project: Distributed just-in-time compilation | Python |
| [fenicsproject/FFC](https://bitbucket.org/fenics-project/ffc/src/master/) | 2019.1.0 | FEniCS Project: Compiler for finite element variational forms | Python |
| [fenicsproject/FIAT](https://bitbucket.org/fenics-project/fiat/src/master/) | 2019.1.0 | FEniCS Project: FInite element Automatic Tabulator | Python |
| [fenicsproject/ufl](https://bitbucket.org/fenics-project/ufl/src/master/) | 2019.1.0 | FEniCS Project: Unified Form Language for finite element variational forms | Python |
| [HDF5](https://www.hdfgroup.org/solutions/hdf5/) | 1.10.5 | HDF5 high performance data software library and file format | MPI |
| [hwloc](https://www.open-mpi.org/projects/hwloc/) | 2.0.4 | Portable abstraction of hierarchical topology of modern architectures | |
| [HYPRE](https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods) | 2.17.0 | Scalable Linear Solvers and Multigrid Methods | numactl, BLAS, MPI |
| [knem](http://knem.gforge.inria.fr/) | 1.1.3 | High-Performance Intra-Node MPI Communication | hwloc |
| [libffi](https://sourceware.org/libffi/) | 3.2.1 | A Portable Foreign Function Interface Library | |
| [METIS](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview) | 5.1.0 | Serial Graph Partitioning and Fill-reducing Matrix Ordering | cmake |
| [MUMPS](http://mumps.enseeiht.fr/) | 5.2.1 | MUltifrontal Massively Parallel sparse direct Solver | BLAS, MPI, METIS, ParMETIS, SCOTCH, ScaLAPACK |
| [numactl](https://github.com/numactl/numactl) | 2.0.12 | NUMA support for Linux | |
| [OpenMPI](https://www.open-mpi.org) | 4.0.1 | A High Performance Message Passing Library | knem, numactl, ucx |
| [OpenSSL](https://www.openssl.org) | 1.1.1c | Cryptography and SSL/TLS toolkits | |
| [ParMETIS](http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview) | 4.0.3 | Parallel Graph Partitioning and Fill-reducing Matrix Ordering | BLAS, MPI |
| [patchelf](https://nixos.org/patchelf.html) | 0.10 | A small utility to modify the dynamic linker and RPATH of ELF executables | |
| [PETSc](https://www.mcs.anl.gov/petsc/) | 3.11.3 | Portable, Extensible Toolkit for Scientific Computation | boost, BLAS, MPI, hwloc, hypre, metis, mumps, parmetis, scalapack, scotch, suitesparse, superlu, superlu\_dist |
| [pybind11](https://github.com/pybind/pybind11) | 2.3.0 | Seamless operability between C++11 and Python | |
| [python](https://github.com/pybind/pybind11) | 3.7.4 | Python programming language | libffi |
| [ScaLAPACK](http://www.netlib.org/scalapack/) | 2.0.2 | Scalable Linear Algebra PACKage | BLAS, MPI |
| [SCOTCH](https://www.labri.fr/perso/pelegrin/scotch/) | 6.0.7 | Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package | MPI |
| [SuiteSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html) | 5.4.0 | A suite of sparse matrix software | BLAS |
| [SuperLU](https://github.com/xiaoyeli/superlu) | 5.2.1 | Direct solver for large, sparse non-symmetric systems of linear equations | BLAS |
| [SuperLU\_DIST](https://github.com/xiaoyeli/superlu_dist) | 6.1.1 | MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory | BLAS, ParMETIS |
| [ucx](http://openucx.org) | 1.6.0 | Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications | knem |
