ROCM ?= /opt/rocm
CUDA ?= /usr/local/cuda
CFLAGS=-O3
LFLAGS=-lm
CC ?= $(ROCM)/bin/clang


# Detect the GPU architecture
INSTALLED_GPU  = $(shell $(ROCM)/bin/mygpu -d gfx900)# Default ROCM_GPU is gfx900 which is vega
GPU_ARCH       ?= $(INSTALLED_GPU)
ifeq (sm_,$(findstring sm_,$(GPU_ARCH)))
  GPU_TARGET = nvptx64-nvidia-cuda
  LFLAGS += -L$(CUDA)/targets/$(UNAMEP)-linux/lib -lcudart
else
  GPU_TARGET = amdgcn-amd-amdhsa
endif

CFLAGS += -fopenmp -fopenmp-targets=$(GPU_TARGET) -Xopenmp-target=$(GPU_TARGET) -march=$(GPU_ARCH)

.PHONY: clean

smoother: main.o smoother.o
	$(CCENV) $(CC) $(CFLAGS) $(LFLAGS) *.o -o $@

main.o : main.cpp smoother.o
	$(CC) -c main.cpp $(CFLAGS) -o $@

smoother.o : smoother.cpp
	$(CC) -c smoother.cpp $(CFLAGS) -o $@

clean :
	rm *.o smoother2d
