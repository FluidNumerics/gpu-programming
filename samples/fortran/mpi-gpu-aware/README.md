# MPI GPU Aware Support

When building multi-GPU Fortran applications, you may want to know at run-time whether or not the system you are running on provides GPU-aware MPI. Both OpenMPI and MVAPICH2-GDR provide the `MPIX_Query_rocm_support()` and `MPIX_Query_cuda_support()` functions in C and the Fortran syntax is not supported. To work around this, we can use the language interoperability feature in Fortran, through ISO C Binding, to expose this method to Fortran.

## What's included
This example includes the following files

* `openmpi_gpu_support.cpp` - A simple C++ file that provides a wrapper for `MPIX_Query_rocm_support` and `MPIX_Query_cuda_support` that is simply called `MPIX_Query_gpu_support`. If either ROCm or CUDA aware support is detected, the function returns `true`; otherwise `false`.
* `openmpi_gpu_support.f90` - A simple fortran module that defines a Fortran interface that binds to the `MPIX_Query_gpu_support` C++ function. This module allows us to call `MPIX_Query_gpu_support` as if it were a Fortran function that returns a fortran `logical`
* `main.f90` - An adapation of a MPI-Fortran Hello World program that issues a call to our `MPIX_Query_gpu_support` function and informs us if GPU aware support is available on our system
* `Makefile` - A quick n' dirty makefile to help you build the application.


## Before you try it out

We recommend that you [install OpenMPI v5.0.x with GPU aware support](https://fluidnumerics.github.io/gpu-programming/MPIplus/GetStartedwithOMPI)


## To demo this example

```
$ make
mpic++ -O0 -g -cpp -c openmpi_gpu_support.cpp -o openmpi_gpu_support.cpp.o
mpif90 -O0 -g -c openmpi_gpu_support.f90 -o openmpi_gpu_support.f90.o
mpif90 -O0 -g -c main.f90 -o main.f90.o
mpif90 -O0 -g main.f90.o openmpi_gpu_support.f90.o openmpi_gpu_support.cpp.o -lstdc++ -o gpu_aware_test


$ mpirun -np 2 ./gpu_aware_test
 Hello World from process:            1 of            2
 GPU aware support:  T
 Hello World from process:            0 of            2
 GPU aware support:  T
```
