
HDR	:= assembler_bison.hh Node.hh Backend.hh Name.hh
OBJ	:= assembler.o assembler_bison.o assembler_flex.o

all:	test

loader:	assembler.exe
	assembler.exe ../loader.asm ../loader.bin

polled:	assembler.exe
	assembler.exe ../polled.asm ../polled.bin

test:	assembler.exe
	assembler.exe ../test.asm ../test.bin

rtos:	assembler.exe
	assembler.exe ../rtos.asm ../rtos.bin

assembler.exe:	$(OBJ)
	g++ -o $@ $(OBJ)

%.o:	%.cc $(HDR)
	g++ -c -o $@ $<

assembler_bison.cc:	assembler.bison
	bison -d -v -o $@ $<

assembler_bison.hh:	assembler.bison
	bison -d -v -o ansi_bison.cc $<

assembler_flex.cc:	assembler.flex assembler_bison.hh
	flex -o$@ $<

clean:

