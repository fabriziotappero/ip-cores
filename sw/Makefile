CC = gcc
CFLAGS = -O2
EXE = .exe

all: gen_hw_looping gen_priority_encoder gen_ixgen

gen_hw_looping: gen_hw_looping.o common.o
	$(CC) gen_hw_looping.o common.o -o gen_hw_looping

gen_priority_encoder: gen_priority_encoder.o common.o
	$(CC) gen_priority_encoder.o common.o -o gen_priority_encoder

gen_ixgen: gen_ixgen.o common.o
	$(CC) gen_ixgen.o common.o -o gen_ixgen

common.o: common.c common.h
	$(CC) $(CFLAGS) -c common.c

gen_hw_looping.o: gen_hw_looping.c common.h
	$(CC) $(CFLAGS) -c gen_hw_looping.c

gen_priority_encoder.o: gen_priority_encoder.c common.h
	$(CC) $(CFLAGS) -c gen_priority_encoder.c

gen_ixgen.o: gen_ixgen.c common.h
	$(CC) $(CFLAGS) -c gen_ixgen.c

clean:
	rm -f *.o gen_hw_looping$(EXE) gen_priority_encoder$(EXE) gen_ixgen$(EXE)
