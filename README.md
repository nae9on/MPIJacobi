# MPI_Jacobi
A jacobi solver in C++ to perform weak scaling tests.

It is based on the example from the Book "Introduction to High Performance Computing for Scientists and Engineers", Chapter 9, Section 9.3.2, 1st Edition, by Georg Hager, Gerhard Wellein

The primary objective of the C++ code is to perform scaling tests (and not to implement a general Jacobi solver for different types of boundary condition's etc).

The result section presents results which are in very good agreement with those presented in the book by Hager and Wellein. In particular Figure 9.10 is correctly obtained.

The HPC tests were conducted on the compute nodes of the VSC
https://www.vscentrum.be/

The node specs are as follows:
2 Xeon Gold 6140 CPUs@2.3 GHz (Skylake), 18 cores each,
192 GB RAM,
200 GB SSD local disk,
Connection using an Infiniband EDR network (bandwidth 25 Gbit/s)

