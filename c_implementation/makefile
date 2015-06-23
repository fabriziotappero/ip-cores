OBJ=sudoku.o
CFLAGS=-O3 -msse4.2

%.o: %.c
	gcc $(CFLAGS) $< -c

sudoku: $(OBJ)
	gcc $(CFLAGS) $(OBJ) -o $@

all: sudoku

clean: $(OBJ) sudoku
	rm $(OBJ) sudoku