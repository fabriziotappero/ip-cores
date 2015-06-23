
CFLAGS = -Wall

.PHONY: all
all: i8039

i8039: i8039.o memory.o main.o 8039dasm.o
	gcc -s -o i8039 main.o i8039.o memory.o 8039dasm.o

i8039.o: i8039.h i8039.c types.h memory.h
	gcc $(CFLAGS) -O -c i8039.c

8039dasm.o: 8039dasm.c
	gcc $(CFLAGS) -O -c 8039dasm.c

memory.o: memory.c memory.h types.h
	gcc $(CFLAGS) -O -c memory.c

main.o: main.c memory.h types.h i8039.h
	gcc $(CFLAGS) -O -c main.c


.PHONY: clean
clean:
	rm -f *.o *~ i8039 log
