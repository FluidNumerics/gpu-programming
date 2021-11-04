ROCM ?= /opt/rocm
CUDA ?= /usr/local/cuda
FC ?= $(ROCM)/bin/amdflang
FFLAGS ?= -O0 -g
LFLAGS ?= ""

# Detect the GPU architecture
INSTALLED_GPU = $(shell $(ROCM)/bin/mygpu -d gfx908)
GPU_ARCH ?= $(INSTALLED_GPU)

ifeq (sm_,$(findstring sm_,$(GPU_ARCH)))
  GPU_TARGET = nvptx64-nvidia-cuda
  LFLAGS += -L$(CUDA)/targets/x86_64-linux/lib -lcudart
else
  GPU_TARGET = amdgcn-amd-amdhsa
endif

FFLAGS += -fopenmp -fopenmp-targets=$(GPU_TARGET) -Xopenmp-target=$(GPU_TARGET) -march=$(GPU_ARCH)

.PHONY: clean

smoother: main.o smoother.o
	${FC} ${FFLAGS} ${LFLAGS} main.o smoother.o -o $@

main.o : main.F90 smoother.o
	$(FC) $(FFLAGS) -c main.F90  -o $@

smoother.o : smoother.F90
	$(FC) $(FFLAGS) -c smoother.F90  -o $@

clean :
	rm *.o *.mod smoother
