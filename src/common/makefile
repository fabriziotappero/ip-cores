#-------------------------------------------------------------------------------
# This makefile does not contain any targets, only definitions used by the 
# makefiles of all the code samples. 
# It is meant to be included and not used standalone.
#-------------------------------------------------------------------------------
# SYSTEM PARAMETERS
#
# You can define here the default size and address of the memory blocks of the 
# system as seen by the linker, though you can't change the number and type of 
# blocks here (see /vhdl/mips_cache_*.vhdl and /vhdl/mips_pkg.vhdl).
#
# The samples' makefiles will probably redefine the values, anyway.
#
#-------------------------------------------------------------------------------
# NOTE:
# A link script '/src/ion_noxram.lds' was used in previous versions of the
# project. It is no longer used. It is known to be buggy and will be removed.
#
# See info on flag -G0 in ion_noxram.lds
#-------------------------------------------------------------------------------


### Toolchain config ###########################################################

ifeq ($(LANG),)
#****  Customize for Windows/Cygwin

# Some common file commands (Cygwin/sh version, use your own)
CP = cp
RM = RM
DWIN32 = -DWIN32
LINUX_PWD =


# MIPS GCC cross-toolchain: CodeSourcery -- replace with your own

BIN_MIPS = C:/dev/embedded/SourceryGpp/mips-elf-11-03.52/bin
CC = $(BIN_MIPS)/mips-sde-elf-gcc.exe $(CFLAGS)
AS = $(BIN_MIPS)/mips-sde-elf-as
LD = $(BIN_MIPS)/mips-sde-elf-ld
DUMP = $(BIN_MIPS)/mips-sde-elf-objdump
COPY = $(BIN_MIPS)/mips-sde-elf-objcopy

else
#**** Customize for Linux

# MIPS GCC cross-toolchain: BuildRoot toolchain in my home directory -- replace with your own
# NOTE: we will not use gcc builtin functions or libc

BIN_MIPS = /home/jaruiz/desarrollo/uClinux/MIPS/buildroot/buildroot-2010.11/output/staging/usr/bin
CC = $(BIN_MIPS)/mips-unknown-linux-uclibc-gcc $(CFLAGS)
AS = $(BIN_MIPS)/mips-unknown-linux-uclibc-as
LD = $(BIN_MIPS)/mips-unknown-linux-uclibc-ld
DUMP = $(BIN_MIPS)/mips-unknown-linux-uclibc-objdump
COPY = $(BIN_MIPS)/mips-unknown-linux-uclibc-objcopy

endif

### VHDL source file manipulation tools ########################################
ION_TOOLS = ../../tools
TO_VHDL = python $(ION_TOOLS)/bin2hdl/bin2hdl.py
VHDL_OBJ_PKG = python $(ION_TOOLS)/build_pkg/build_pkg.py -t $(ION_TOOLS)/build_pkg/templates

### Default system parameters -- to be replaced in application makefile ########

# 'CODE_BRAM' is meant to be a small BRAM (2 to 4KB) used for bootstrapping.
# 'DATA_BRAM' is a small BRAM connected to the data ports, used for debugging.
# 'XRAM' is meant to be external SRAM


# Default location of code BRAM is on the reset vector address
CODE_BRAM_ADDRESS = 0
# Default size of code BRAM in 32-bit words
CODE_BRAM_SIZE = 1024
# Default size of data BRAM in 32-bit words (meant for simulation only)
DATA_BRAM_SIZE = 256
# Default address of BRAM -- used in some simulation-only tests, see makefiles
DATA_BRAM_ADDRESS = 0x10000
# Default size of data external SRAM (XRAM) in 16-bit words (for simulation)
XRAM_SIZE = 2048
# Default address of XRAM
XRAM_ADDRESS = 0x80000000

### Project directories -- to be replaced in application makefile ##############

# Root test code source directory, where python script and vhdl templates are
SRC_DIR = ..
# VHDL test bench directory, where VHDL output files will be created
TB_DIR = ../../vhdl/tb
# VHDL DE-1 board demo root directory, for vhdl output
DEMO_DIR = ../../vhdl/demo
# Path to local libraries
LIB_PATH = $(SRC_DIR)/common/libsoc
# Link script to be used
LINK_SCRIPT = $(SRC_DIR)/common/flash.lds

### Build options -- to be replaced in application makefile ####################

# Don't use gcc builtin functions, and try to target MIPS-I architecture.
# This will prevent usage of unimplemented opcodes but will insert nops after
# load instructions, which Ion does not need.
# (See comment above about -G0 flag)
CFLAGS = -O2 -Wall -c -s -fno-builtin -mips1 -G0 -nodefaultlibs -nostdlib

# LFLAGS: linker options are in the respective makefiles
