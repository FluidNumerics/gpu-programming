
FC=gfortran
FFLAGS=-O0 -g -pg
CFLAGS=-O0 -g
LFLAGS=-lm

.PHONY: clean

smoother: main.o smoother.o
	${FC} ${FFLAGS} *.o -o $@

main.o : main.F90 smoother.o
	$(FC) $(FFLAGS) -c main.F90  -o $@

smoother.o : smoother.F90
	$(FC) $(FFLAGS) -c smoother.F90  -o $@

clean :
	rm *.o *.mod smoother
