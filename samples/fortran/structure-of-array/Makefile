ROCM ?= /opt/rocm
CUDA ?= /usr/local/cuda
FC = $(ROCM)/bin/amdflang

# Detect the GPU architecture
INSTALLED_GPU = $(shell $(ROCM)/bin/mygpu -d gfx908)
GPU_ARCH ?= $(INSTALLED_GPU)

ifeq (sm_,$(findstring sm_,$(GPU_ARCH)))
  GPU_TARGET = nvptx64-nvidia-cuda
  LFLAGS += -L$(CUDA)/targets/x86_64-linux/lib -lcudart
else
  GPU_TARGET = amdgcn-amd-amdhsa
endif

CFLAGS := -fopenmp -fopenmp-targets=$(GPU_TARGET) -Xopenmp-target=$(GPU_TARGET) -march=$(GPU_ARCH) -cpp

demo: main.o soa.o
	$(FC) $(CFLAGS) main.o soa.o -o $@

main.o: soa.o
	$(FC) $(CFLAGS) -c main.f90 -o $@

soa.o:
	$(FC) $(CFLAGS) -c soa.f90 -o $@
