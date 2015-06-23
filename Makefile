
all:	test

loader:
	gcc -c loader.c
	make -C .\compiler loader
	make -C .\asm loader
	make -C .\memory loader
#	make -C .\sim loader

polled:
	gcc -c polled.c
	make -C .\compiler polled
	make -C .\asm polled
	make -C .\memory polled
	make -C .\sim polled

test:
	gcc -c test.c
	make -C .\compiler test
	make -C .\asm test
	make -C .\memory test
#	make -C .\sim test

rtos:
	gcc -c rtos.c
	make -C .\compiler rtos
	make -C .\asm rtos
	make -C .\memory rtos

config:

clean:

