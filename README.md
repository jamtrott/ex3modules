# ex3-modules
This repository contains scripts for building and installing a variety of software packages to an Environment Modules system. It is used to install software on the **eX3** cluster, a national Experimental Infrastructure for Exploration of Exascale Computing at Simula Research Laboratory, Norway.

The available modules are:
 * [numactl](https://github.com/numactl/numactl)
 * [HYPRE](https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods), which depends on numactl, BLAS, and MPI.
 * [ParMETIS](http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview), which depends on BLAS and MPI.
 * [SCOTCH](https://www.labri.fr/perso/pelegrin/scotch/), which depends on MPI.
 * [SuiteSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html), which depends on BLAS.
