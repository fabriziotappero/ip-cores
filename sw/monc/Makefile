PRJ  = monc
CRT  = ../crt/crt-bram
SRCS = $(PRJ).c
OBJS = $(SRCS:.c=.o)
LINK = ../link/script-bram.ld

$(PRJ).v: $(PRJ).out
	mb-objcopy -O binary $(PRJ).out $(PRJ).bin
	..\..\utils\bin2bram ..\..\rtl\openfire_template_bootram.v $(PRJ).bin $(PRJ).v

$(PRJ).srec: $(PRJ).out
	mb-objcopy -O srec $(PRJ).out $(PRJ).srec
	mb-objcopy -O binary $(PRJ).out $(PRJ).bin
	..\..\utils\bin2rom $(PRJ).bin $(PRJ).rom

$(OBJS): $(SRCS)
	mb-gcc -O2 -I . -I ../lib -mno-xl-soft-mul -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.c)

$(PRJ).out: $(CRT).o  $(OBJS)
	mb-ld -L ../lib -T $(LINK) -Map=$(PRJ).map -o $(PRJ).out $(CRT).o $(OBJS) -lio
        
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
