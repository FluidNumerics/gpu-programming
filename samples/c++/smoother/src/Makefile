
CC=gcc
CFLAGS=-O0 -g
LFLAGS=-lm

.PHONY: clean

smoother: main.o smoother.o
	$(CCENV) $(CC) $(CFLAGS) *.o $(LFLAGS) -o $@

main.o : main.cpp smoother.o
	$(CC) $(CFLAGS) -c main.cpp  -o $@

smoother.o : smoother.cpp
	$(CC) $(CFLAGS) -c smoother.cpp  -o $@

clean :
	rm *.o smoother2d
