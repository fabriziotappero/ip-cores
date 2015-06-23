
CC=gcc
APP=or32-idecode

all: or32-opc.o or32-dis.o 
	(\
	$(CC) $^ -o $(APP);\
	mv $(APP) ../../../bin;\
	)

%.o: %.c
	$(CC) -O2 -c $*.c -o $*.o;



