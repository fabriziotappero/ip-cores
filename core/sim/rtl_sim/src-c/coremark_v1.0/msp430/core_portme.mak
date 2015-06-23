#File: core_portme.mak

ITERATIONS  = 1
PORT_CFLAGS = -O2

# Choose GCC toolchain prefix ('msp430' for MSPGCC / 'msp430-elf' for GCC RedHat/TI)
ifndef MSPGCC_PFX
MSPGCC_PFX      = msp430-elf
endif

# Flag: OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o

# Flag: CC
#	Use this flag to define compiler to use
CC = ${MSPGCC_PFX}-gcc

# Flag: CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"

ifeq ($(MSPGCC_PFX),msp430-elf)
CFLAGS	= -D PFX_MSP430_ELF $(PORT_CFLAGS) -mcpu=msp430 -mhwmult=16bit            -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
else
CFLAGS	= -D PFX_MSP430     $(PORT_CFLAGS) -mcpu=430    -mmpy=16      -mivcnt=16  -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
endif

#Flag: LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts).
#	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
LFLAGS_END += -T$(PORT_DIR)/linker.${MSPGCC_PFX}.x

# Flag : PORT_SRCS
# 	Port specific source files can be added here
PORT_SRCS = $(PORT_DIR)/core_portme.c $(PORT_DIR)/omsp_func.c $(PORT_DIR)/copydata.c

# Flag : LOAD
#	For a simple port, we assume self hosted compile and run, no load needed.

# Flag : RUN
#	For a simple port, we assume self hosted compile and run, simple invocation of the executable

#For native compilation and execution
LOAD = echo Loading done
RUN = echo

OEXT = .o
EXE = .elf


# Target : port_pre% and port_post%
# For the purpose of this simple port, no pre or post steps needed.

.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload
port_pre% port_post% :

# FLAG : OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p
