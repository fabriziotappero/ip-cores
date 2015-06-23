PRJ  = io
SRCS = __errno.c inbyte.c outbyte.c havebyte.c uart1_printchar.c uart1_printline.c uart1_readchar.c \
       uart1_readline.c gethexstring.c puthexstring.c
OBJS = $(SRCS:.c=.o)

lib$(PRJ): $(OBJS)
	--rm lib$(PRJ).a
	mb-ar q lib$(PRJ).a $(OBJS)

$(OBJS): $(SRCS)
	mb-gcc -O2 -B. -mno-xl-soft-mul -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.c)

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
