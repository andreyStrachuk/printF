CC = gcc
NC = nasm

CFLAGS = -c -Wall #-Wpedantic -Wextra 

NASMFLAGS = -w+all -f elf64

LFLAGS = -fno-pie

PROG_NAME = printF

cs = test.cpp
asms = printF.asm

all:
	$(CC) $(CFLAGS) $(cs)
	
	$(NC) $(NASMFLAGS) $(asms)
	
	$(CC) $(LFLAGS) *.o -o $(PROG_NAME)
	
clean:
	rm *.o
