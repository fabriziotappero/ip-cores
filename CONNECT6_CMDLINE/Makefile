SRC=./
GCC=g++
all: fpt_connect6 test

fpt_connect6: ${SRC}/main.cpp util.o connect6.o connect6_synth.o 
	${GCC} -o connect6 ${SRC}/main.cpp util.o connect6.o connect6_synth.o   -lpthread -lm -g -pg
	cp connect6 ../DEMO

connect6_synth.o: ${SRC}/connect6_synth.cpp ${SRC}/connect6_synth.h
	${GCC} -c -g -pg ${SRC}/connect6_synth.cpp
connect6.o: ${SRC}/connect6.cpp ${SRC}/connect6.h
	${GCC} -c -g -pg ${SRC}/connect6.cpp

util.o: ${SRC}/util.cpp ${SRC}/util.h
	${GCC} -c -g -pg ${SRC}/util.cpp
	


test:
	./connect6 -player L -port /dev/ttyS0

clean:
	rm -f *.o connect6 gmon.out myboard.txt
