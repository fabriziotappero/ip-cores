# makfile configuration
NAME            = dhrystone_4mcu
OBJECTS         = dhry21a.o dhry21b.o omsp_func.o copydata.o

# Compiler performance option (-Os / -O2 / -O3)
PORT_CFLAGS     = -O2

# Choose GCC toolchain prefix ('msp430' for MSPGCC / 'msp430-elf' for GCC RedHat/TI)
ifndef MSPGCC_PFX
MSPGCC_PFX      = msp430
endif

# disable some warnings specific to the Dhrystone code
WARNINGS        =  -Wall

# Select flags depending on selected toolchain
ifeq ($(MSPGCC_PFX),msp430-elf)
CFLAGS		= -D PFX_MSP430_ELF $(PORT_CFLAGS) ${WARNINGS} -g -mcpu=msp430 -mhwmult=16bit
else
CFLAGS		= -D PFX_MSP430     $(PORT_CFLAGS) ${WARNINGS} -g -mcpu=430    -mmpy=16		-mivcnt=16
endif

# Toolchain executables
CC              = ${MSPGCC_PFX}-gcc
OBJCOPY		= ${MSPGCC_PFX}-objcopy
OBJDUMP         = ${MSPGCC_PFX}-objdump

.PHONY: all FORCE clean download dist

#all should be the first target. it's built when make is runwithout args
all: ${NAME}.elf ${NAME}.a43 ${NAME}.lst

#configure the next line if you want to use the serial download
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
dhry_21a.o: dhry_21a.c
dhry_21b.o: dhry_21b.c
omsp_func.o: omsp_func.c
copydata.o: copydata.c
