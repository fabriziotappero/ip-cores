
all:	test

simulate.exe:	simulate.cc
	gcc -o $@ simulate.cc

%.o:	%.cc $(HDR)
	g++ -c -o $@ $<

.PHONY:	sim asm bin clean

test:	simulate.exe ../test.bin
	simulate.exe ../test.bin ../test.sym

polled:	simulate.exe ../polled.bin
	simulate.exe ../polled.bin ../polled.sym

loader:	simulate.exe ../loader.bin
	simulate.exe ../loader.bin ../loader.sym

