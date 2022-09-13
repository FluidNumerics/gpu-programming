
CC=hipcc
CFLAGS=-O2
LFLAGS=

.PHONY: clean

memcpy_bench: memcpy_bench.o
	$(CCENV) $(CC) $(CFLAGS) *.o $(LFLAGS) -o $@

memcpy_bench.o : memcpy_bench.cpp
	$(CC) $(CFLAGS) -c memcpy_bench.cpp  -o $@

clean :
	rm *.o memcpy_bench
