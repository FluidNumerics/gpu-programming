
FC=hipfc
FFLAGS=-O0 -g
CFLAGS=-O0 -g
LFLAGS=-lm

.PHONY: clean

smoother: main.o smoother.o smoother_HIP.o
	${FC} ${FFLAGS} *.o -o $@

main.o : main.F90 smoother.o
	$(FC) $(FFLAGS) -c main.F90  -o $@

smoother.o : smoother.F90 smoother_HIP.o
	$(FC) $(FFLAGS) -c smoother.F90  -o $@

smoother_HIP.o : smoother_HIP.cpp
	$(FC) $(CFLAGS) -c smoother_HIP.cpp  -o $@

clean :
	rm *.o *.mod smoother
