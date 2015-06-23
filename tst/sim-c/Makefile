#
# Makefile to build a simulation of the test circuit
#

all:		ref

ref:		lfsr128
		./lfsr128 >ref

lfsr128:	lfsr128.c
		gcc -Wall -o lfsr128 lfsr128.c

clean:
		rm -f *~ lfsr128 ref
