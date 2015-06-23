PRJ  = sample
CRT  = ../crt/crt-sram
LIBIO = ../lib/uart1io
SRCS = $(PRJ).c
OBJS = $(SRCS:.c=.o)
LINK = ../link/sp3sk-sram.ld

$(PRJ).srec: $(PRJ).out
	mb-objcopy -O srec $(PRJ).out $(PRJ).srec
	mb-objcopy -O binary $(PRJ).out $(PRJ).bin
	..\..\utils\bin2rom $(PRJ).bin $(PRJ).rom

$(OBJS): $(SRCS)
	mb-gcc -B. -mno-xl-soft-mul -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.c)

$(PRJ).out: $(CRT).o  $(OBJS)
	mb-ld -T $(LINK) -Map=$(PRJ).map -o $(PRJ).out $(CRT).o $(OBJS) $(LIBIO).o -lgcc -lc -lm -lgcc
        
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
