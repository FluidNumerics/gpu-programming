# MPI+HIPFort GPU-Aware communication

When building multi-GPU Fortran applications, you may want to know at run-time whether or not the system you are running on provides GPU-aware MPI. Both OpenMPI and MVAPICH2-GDR provide the `MPIX_Query_rocm_support()` and `MPIX_Query_cuda_support()` functions in C and the Fortran syntax is not supported. To work around this, we can use the language interoperability feature in Fortran, through ISO C Binding, to expose this method to Fortran.

## What's included
This example includes the following files

* `openmpi_gpu_support.cpp` - A simple C++ file that provides a wrapper for `MPIX_Query_rocm_support` and `MPIX_Query_cuda_support` that is simply called `MPIX_Query_gpu_support`. If either ROCm or CUDA aware support is detected, the function returns `true`; otherwise `false`.
* `openmpi_gpu_support.f90` - A simple fortran module that defines a Fortran interface that binds to the `MPIX_Query_gpu_support` C++ function. This module allows us to call `MPIX_Query_gpu_support` as if it were a Fortran function that returns a fortran `logical`
* `main.f90` - An adapation of a MPI-Fortran Hello World program that issues a call to our `MPIX_Query_gpu_support` function and handle MPI exchange on the GPU.
* `Makefile` - A quick n' dirty makefile to help you build the application.


## Before you try it out

We recommend that you [install OpenMPI v5.0.x with GPU aware support](https://fluidnumerics.github.io/gpu-programming/MPIplus/GetStartedwithOMPI)


## To demo this example

```
$ OMPI_MPIFC=/opt/rocm/bin/hipfc make
mpic++ -O0 -g -cpp -c openmpi_gpu_support.cpp -o openmpi_gpu_support.cpp.o
mpif90 -O0 -g -c openmpi_gpu_support.f90 -o openmpi_gpu_support.f90.o
mpif90 -v -O0 -g -c main.f90 -o main.f90.o
/usr/bin/gfortran  -g  -c -cpp -I/opt/rocm/include/hipfort/amdgcn  main.f90  -I/opt/software/ompi/include -I/opt/software/ompi/lib  -o /home/joe/gpu-programming/samples/fortran/mpi+hipfort/main.f90.o
#Info:  Temp files kept in /tmp
mpif90 -v -O0 -g main.f90.o openmpi_gpu_support.f90.o openmpi_gpu_support.cpp.o -lstdc++ -o gpu_aware_test
/usr/bin/gfortran  -g -cpp -I/opt/rocm/include/hipfort/amdgcn  main.f90.o openmpi_gpu_support.f90.o openmpi_gpu_support.cpp.o  -lstdc++ -I/opt/software/ompi/include -I/opt/software/ompi/lib -L/opt/software/ompi/lib -Wl,-rpath -Wl,/opt/software/ompi/lib -Wl,--enable-new-dtags -lmpi_usempif08 -lmpi_usempi_ignore_tkr -lmpi_mpifh -lmpi -L/opt/rocm/lib -lhipfort-amdgcn -L/opt/rocm/lib -lamdhip64 -Wl,-rpath=/opt/rocm/lib  -lstdc++ -o /home/joe/gpu-programming/samples/fortran/mpi+hipfort/gpu_aware_test
#Info:  Temp files kept in /tmp


$ mpirun -np 2 -x UCX_TLS=sm,self,rocm --mca pml ucx ./gpu_aware_test 
 Hello World from process:            1 of            2
 GPU aware MPI detected!
 Hello World from process:            0 of            2
 GPU aware MPI detected!
 rank 1 : data received correctly!
```
