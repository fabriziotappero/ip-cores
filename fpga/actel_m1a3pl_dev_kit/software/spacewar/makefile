# makfile configuration
NAME            = spacewar
OBJECTS         = bzsin.o  cline.o  compar.o  explode.o  hardware.o  main.o  point.o  reset.o  rocket1.o  rocket2.o  score.o  update.o

CFLAGS          = -O2 -Wall -g -mcpu=430 -mivcnt=16 -mmpy=none     # Uniarch flags

#switch the compiler (for the internal make rules)
CC              = msp430-gcc


.PHONY: all FORCE clean download download-jtag download-bsl dist

#all should be the first target. it's built when make is runwithout args
all: ${NAME}.elf ${NAME}.a43 ${NAME}.lst

#serial download
download: download-uart

#additional rules for files
${NAME}.elf: ${OBJECTS}
	${CC} -T linker.x -o $@ ${OBJECTS}

${NAME}.a43: ${NAME}.elf
	msp430-objcopy -O ihex $^ $@

${NAME}.lst: ${NAME}.elf
	msp430-objdump -dSt $^ >$@

download-jtag: all
	msp430-jtag -e ${NAME}.elf

download-bsl: all
	msp430-bsl -e ${NAME}.elf

download-uart: all
	openmsp430-loader.tcl -device /dev/ttyUSB0 -baudrate 115200 ${NAME}.elf

clean:
	rm -f ${NAME} ${NAME}.a43 ${NAME}.lst ${NAME}.elf *.o

#backup archive
dist:
	tar czf dist.tgz *.c *.h *.txt makefile

#dummy target as dependecy if something has to be build everytime
FORCE:

#project dependencies
bzsin.o:    bzsin.c
cline.o:    cline.c    spacewar.h
compar.o:   compar.c   spacewar.h
explode.o:  explode.c
hardware.o: hardware.c spacewar.h
main.o:     main.c     spacewar.h
point.o:    point.c    spacewar.h
reset.o:    reset.c    spacewar.h
rocket1.o:  rocket1.c  spacewar.h
rocket2.o:  rocket2.c  spacewar.h
score.o:    score.c    spacewar.h
update.o:   update.c   spacewar.h
