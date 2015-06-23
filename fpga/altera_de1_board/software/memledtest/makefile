# makfile configuration
NAME            = memledtest
OBJECTS         = main.o 7seg.o gray.o memtest.o

CFLAGS          = -O2 -Wall -g -mcpu=430 -mivcnt=16 -mmpy=16     # Uniarch flags

# use custom linker script
LDFLAGS         = -Tlink.ld

#switch the compiler (for the internal make rules)
CC              = msp430-gcc
LD              = msp430-gcc


.PHONY: all FORCE clean download download-jtag download-bsl dist

#all should be the first target. it's built when make is runwithout args
all: ${NAME}.elf $(NAME).bin ${NAME}.a43 ${NAME}.lst $(NAME).mif

#confgigure the next line if you want to use the serial download
download: download-uart
#download: download-jtag
#download: download-bsl

#additional rules for files

#link everything together
${NAME}.elf: ${OBJECTS}
	${LD} $(LDFLAGS) -o $@ ${OBJECTS}

# binary image, then .MIF file for quartus
${NAME}.bin: ${NAME}.elf
	msp430-objcopy -O binary --gap-fill 255 $^ $@
$(NAME).mif: $(NAME).bin
	../bin/mifwrite $^ $@

# ihex image
${NAME}.a43: ${NAME}.elf
	msp430-objcopy -O ihex $^ $@

# disassembler file
${NAME}.lst: ${NAME}.elf
	msp430-objdump -dSt $^ >$@

download-jtag: all
	msp430-jtag -e ${NAME}.elf

download-bsl: all
	msp430-bsl -e ${NAME}.elf

download-uart: all
	openmsp430-loader.tcl -device /dev/ttyUSB0 -baudrate 115200 ${NAME}.elf

clean:
	rm -f ${NAME} ${NAME}.a43 ${NAME}.lst $(NAME).bin $(NAME).mif $(NAME).elf *.o

#backup archive
dist:
	tar czf dist.tgz *.c *.h *.txt makefile

#dummy target as dependecy if something has to be build everytime
FORCE:

#project dependencies
main.o: main.c hardware.h 7seg.h
7seg.o: 7seg.c 7seg.h
gray.o: gray.c gray.h
memtest.o: memtest.c memtest.h
