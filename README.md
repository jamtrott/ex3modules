# ex3-modules
This repository contains scripts for building and installing a variety of software packages to an Environment Modules system. It is used to install software on the **eX3** cluster, a national Experimental Infrastructure for Exploration of Exascale Computing at Simula Research Laboratory, Norway.


## Modules
The available modules are shown in the table below.

| Module       | Dependencies | Notes |
| :---         | :---         | :---  |
| [numactl](https://github.com/numactl/numactl) | | |
| [HYPRE](https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods) | numactl, BLAS, MPI | |
| [ParMETIS](http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview) | BLAS, MPI | |
| [SCOTCH](https://www.labri.fr/perso/pelegrin/scotch/) | MPI | Includes PT-SCOTCH for parallel graph partitioning |
| [SuiteSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html) | BLAS | |
