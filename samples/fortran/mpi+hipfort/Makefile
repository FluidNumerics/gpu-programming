FC=mpif90
CXX=mpic++
#HIPFC=/opt/rocm/bin/hipfc

OPT=-O0 -g

gpu_aware_test: 
	$(CXX) $(OPT) -cpp -c openmpi_gpu_support.cpp -o openmpi_gpu_support.cpp.o
	$(FC) $(OPT) -c openmpi_gpu_support.f90 -o openmpi_gpu_support.f90.o
	$(FC) -v $(OPT) -c main.f90 -o main.f90.o
	$(FC) -v $(OPT) main.f90.o openmpi_gpu_support.f90.o openmpi_gpu_support.cpp.o -lstdc++ -o gpu_aware_test
