#
# makefile for md6 programs

# for GCC:
CC = gcc
CFLAGS = -Wall -O3

# for Microsoft VS
# CC = CL.EXE
# CFLAGS = /O2 /arch:SSE2

md6_test : md6_test.c md6_compress.c md6_mode.c 
	$(CC) $(CFLAGS) -o $@ $^

md6_test2 : md6_test.c md6_compress.c md6_mode.c 
	$(CC) -pg $(CFLAGS) -o $@ $^

md6sum : md6sum.c md6_compress.c md6_mode.c
	$(CC) $(CFLAGS) -o $@ $^




