
ZAS	:= C:/sdcc/bin/as-z80
ZLD	:= C:/sdcc/bin/aslink

HDR	:=  ansic_bison.cc.h Node.hh Backend.hh Name.hh
OBJ	:= cc80.o ansic_bison.o ansic_flex.o Node.o Name.o Expression.o \
	   Statement.o Backend.o
MEMTOP	:= 0x2000

all:	test

cc80.exe:	$(OBJ)
	g++ -g -o $@ $(OBJ)

%.o:	%.cc $(HDR)
	g++ -g -c -o $@ $<

ansic_bison.cc:	ansic.bison
	bison -d -v -o $@ $<

ansic_bison.cc.h:	ansic.bison
	bison -d -v -o ansi_bison.cc $<

ansic_flex.cc:	ansic.flex ansic_bison.cc.h
	flex -o$@ $<

loader:	cc80.exe
	cc80.exe -l $(MEMTOP) ..\loader.c ..\loader.asm

polled:	cc80.exe
	cc80.exe $(MEMTOP) ..\polled.c ..\polled.asm

test:	cc80.exe
	cc80.exe $(MEMTOP) ..\test.c ..\test.asm

rtos:	cc80.exe
	cc80.exe $(MEMTOP) ..\rtos.c ..\rtos.asm

clean:

