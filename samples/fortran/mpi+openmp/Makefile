FC=mpif90
CXX=mpic++
GPU_TARGET=amdgcn-amd-amdhsa
GPU_ARCH=gfx90a
GPU_OFFLOAD=-fopenmp -fopenmp-targets=$(GPU_TARGET) -Xopenmp-target=$(GPU_TARGET) -march=$(GPU_ARCH)

OPT=-O0 -g

gpu_aware_test: 
	$(CXX) $(OPT) -c openmpi_gpu_support.cpp -o openmpi_gpu_support.cpp.o
	$(FC) $(OPT) -c openmpi_gpu_support.f90 -o openmpi_gpu_support.f90.o
	$(FC) $(OPT) $(GPU_OFFLOAD) -c main.f90 -o main.f90.o
	$(FC) $(OPT) $(GPU_OFFLOAD) main.f90.o openmpi_gpu_support.f90.o openmpi_gpu_support.cpp.o -lstdc++ -o gpu_aware_test
