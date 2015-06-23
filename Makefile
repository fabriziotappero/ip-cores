CC=tcc -g
#CC=gcc -MD -O2

CF_SRC = \
         src/ex.cf \
	 src/id.cf \
	 src/mem.cf \
	 src/pipe.cf \
	 src/reg.cf \
	 src/wb.cf

or1200: harness/harness.c Cpu.c Cpu.h
	$(CC) -o or1200 harness/harness.c Cpu.c

Cpu.c Cpu.h: $(CF_SRC) harness/pipe_test.cf
	cf harness/pipe_test.cf


