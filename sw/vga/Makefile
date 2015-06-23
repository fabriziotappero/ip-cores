PRJ  = vga
CRT  = ../crt/crt-sram
LIB  = vga_5x7_fuente.c vga_5x7_putchar.c vga_5x7_putline.c vga_5x7_setfgcolor.c vga_5x7_setbgcolor.c vga_clearscreen.c vga_drawpixel.c
SRCS = $(PRJ).c $(LIB)
OBJS = $(SRCS:.c=.o)
LINK = ../link/sp3sk-sram.ld

$(PRJ).srec: $(PRJ).out
	mb-objcopy -O srec $(PRJ).out $(PRJ).srec
	mb-objcopy -O binary $(PRJ).out $(PRJ).bin
	..\..\utils\bin2rom $(PRJ).bin $(PRJ).rom

libvga:
	--rm $(PRJ).a
	mb-ar q lib$(PRJ).a $(OBJS)

$(OBJS): $(SRCS)
	mb-gcc -O2 -B. -mno-xl-soft-mul -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.c)

$(PRJ).out: $(CRT).o  $(OBJS)
	mb-ld -L ../lib -T $(LINK) -Map=$(PRJ).map -o $(PRJ).out $(CRT).o $(OBJS) -lgcc -lc -lm -lgcc -lio
        
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
