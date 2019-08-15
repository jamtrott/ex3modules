# ex3-modules
This repository contains scripts for building and installing a variety of software packages to an Environment Modules system. It is used to install software on the **eX3** cluster, a national Experimental Infrastructure for Exploration of Exascale Computing at Simula Research Laboratory, Norway.


## Modules
The available modules are shown in the table below.

| Module       | Version | Dependencies | Notes |
| :---         | ---:    | :---         | :---  |
| [dijitso](https://bitbucket.org/fenics-project/dijitso/src/master/) | 2019.1.0 | Python | fenics-2019.1.0 |
| [Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page) | 3.3.7 | Optionally depends on boost, mpfr, gmp, suitesparse, superlu | |
| [FIAT](https://bitbucket.org/fenics-project/fiat/src/master/) | 2019.1.0 | Python | fenics-2019.1.0 |
| [HDF5](https://www.hdfgroup.org/solutions/hdf5/) | 1.10.5 | MPI | |
| [hwloc](https://www.open-mpi.org/projects/hwloc/) | 2.0.4 | | |
| [HYPRE](https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods) | 2.17.0 | numactl, BLAS, MPI | |
| [knem](http://knem.gforge.inria.fr/) | 1.1.3 | hwloc | |
| [METIS](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview) | 5.1.0 | | |
| [MUMPS](http://mumps.enseeiht.fr/) | 5.2.1 | BLAS, MPI, METIS, ParMETIS, SCOTCH, ScaLAPACK | |
| [numactl](https://github.com/numactl/numactl) | 2.0.12 | | |
| [OpenMPI](https://www.open-mpi.org) | 4.0.1 | knem | |
| [patchelf](https://nixos.org/patchelf.html) | 0.10 | | |
| [ParMETIS](http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview) | 4.0.3 | BLAS, MPI | |
| [PETSc](https://www.mcs.anl.gov/petsc/) | 3.11.3 | boost, BLAS, MPI, hwloc, hypre, metis, mumps, parmetis, scalapack, scotch, suitesparse, superlu, superlu\_dist | |
| [ScaLAPACK](http://www.netlib.org/scalapack/) | 2.0.2 | BLAS, MPI | |
| [SCOTCH](https://www.labri.fr/perso/pelegrin/scotch/) | 6.0.7 | MPI | Includes PT-SCOTCH for parallel graph partitioning |
| [SuiteSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html) | 5.4.0 | BLAS | |
| [SuperLU](https://github.com/xiaoyeli/superlu) | 5.2.1 | BLAS | |
| [SuperLU\_DIST](https://github.com/xiaoyeli/superlu_dist) | 6.1.1 | BLAS, ParMETIS | |
| [ufl](https://bitbucket.org/fenics-project/ufl/src/master/) | 2019.1.0 | Python | fenics-2019.1.0 |
