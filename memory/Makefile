
all:	test

loader:	makemem.exe
	makemem.exe ..\loader.bin

polled:	makemem.exe
	makemem.exe ..\polled.bin

test:	makemem.exe
	makemem.exe ..\test.bin

rtos:	makemem.exe
	makemem.exe ..\rtos.bin

makemem.exe:	makemem.cc
	g++ -o $@ $<

clean:
	del makemem.exe
