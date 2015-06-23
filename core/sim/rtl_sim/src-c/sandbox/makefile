# makfile configuration
NAME            = sandbox
OBJECTS         = main.o copydata.o

# Choose GCC toolchain prefix ('msp430' for MSPGCC / 'msp430-elf' for GCC RedHat/TI)
ifndef MSPGCC_PFX
MSPGCC_PFX      = msp430
endif

# Select flags depending on selected toolchain
ifeq ($(MSPGCC_PFX),msp430-elf)
CFLAGS          = -D PFX_MSP430_ELF -O2 -Wall -g -mcpu=msp430 -mhwmult=none
else
CFLAGS          = -D PFX_MSP430     -O2 -Wall -g -mcpu=430    -mmpy=none    -mivcnt=16
endif

# Toolchain executables
CC              = ${MSPGCC_PFX}-gcc
OBJCOPY		= ${MSPGCC_PFX}-objcopy
OBJDUMP         = ${MSPGCC_PFX}-objdump


.PHONY: all FORCE clean download download-jtag download-bsl dist

#all should be the first target. it's built when make is runwithout args
all: ${NAME}.elf ${NAME}.a43 ${NAME}.lst

#confgigure the next line if you want to use the serial download
download: download-uart

#additional rules for files
${NAME}.elf: ${OBJECTS}
	${CC} ${CFLAGS} -T linker.${MSPGCC_PFX}.x -o $@ ${OBJECTS}

${NAME}.a43: ${NAME}.elf
	${OBJCOPY} -O ihex $^ $@

${NAME}.lst: ${NAME}.elf
	${OBJDUMP} -dSt $^ >$@

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
main.o: main.c
copydata.o: copydata.c
