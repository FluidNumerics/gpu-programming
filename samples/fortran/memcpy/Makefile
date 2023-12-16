
FC=hipfc
FFLAGS=-v -O2
GPU_ARCH=gfx90a

FFLAGS+=--offload-arch=$(GPU_ARCH)

.PHONY: clean

memcpy_bench: memcpy_bench_tools.o memcpy_bench.o
	$(FC) $(FFLAGS) *.o -o $@

memcpy_bench.o: memcpy_bench_tools.o memcpy_bench.f90
	$(FC) $(FFLAGS) -c memcpy_bench.f90 -o $@

memcpy_bench_tools.o : memcpy_bench_tools.f90
	$(FC) $(FFLAGS) -c memcpy_bench_tools.f90  -o $@

clean :
	rm *.o *.mod memcpy_bench
