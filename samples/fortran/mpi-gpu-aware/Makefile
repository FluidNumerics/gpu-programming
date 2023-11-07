FC=mpif90
CXX=mpic++

OPT=-O0 -g

gpu_aware_test:
	$(CXX) $(OPT) -cpp -c openmpi_gpu_support.cpp -o openmpi_gpu_support.cpp.o
	$(FC) $(OPT) -c openmpi_gpu_support.f90 -o openmpi_gpu_support.f90.o
	$(FC) $(OPT) -c main.f90 -o main.f90.o
	$(FC) $(OPT) main.f90.o openmpi_gpu_support.f90.o openmpi_gpu_support.cpp.o -lstdc++ -o gpu_aware_test
