
CC=hipcc
#Add "-fmad=false" to CFLAGS for Nvidia platforms to disable Fused Multiply-Add
CFLAGS=-O0 -g
LFLAGS=-lm

.PHONY: clean

smoother: main.o smoother.o
	$(CCENV) $(CC) $(CFLAGS) *.o $(LFLAGS) -o $@

main.o : main.c smoother.o
	$(CC) $(CFLAGS) -c main.c  -o $@

smoother.o : smoother.c
	$(CC) $(CFLAGS) -c smoother.c  -o $@

clean :
	rm *.o smoother2d
