PRJ  = freertos
LIBS = portasm.s
LIB  = croutine.c heap_2.c list.c port.c queue.c tasks.c
OBJS = $(LIB:.c=.o)
OBJSS= $(LIBS:.s=.o)

$(PRJ): $(OBJS) $(OBJSS)
	--rm lib$(PRJ).a
	mb-ar q lib$(PRJ).a $(OBJS) $(OBJSS)

$(OBJS): $(LIB)
	mb-gcc -I . -I ../lib -mno-xl-soft-mul -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.c)

$(OBJSS): $(LIBS)
	mb-as -ahlms=$(@:.o=.lst) -o $@ $(@:.o=.s)

clean:
	-rm *.o
	-rm *.out
	-rm *.bin
	-rm *.v
	-rm *.map
	-rm *.lst
	-rm *.bak
	-rm *.srec
	-rm *.prom
	-rm *.rom
	-rm *.a
