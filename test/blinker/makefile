#-- Target 'all' will build an object code VHDL package ready for synthesis ----

#-- Project configuration ------------------------------------------------------
 
# Directories              
BINDIR = bin
OBJDIR = obj
SRCDIR = src
BRPATH = ../../tools/build_rom
VHDL_TB_PATH = .
COMDIR = ../common

# The parameters we set here will end in the object code VHDL package and will 
# be passed to the MCU core as generics.

PROJ_NAME = "Blinker"
# XROM size in bytes.
XCODE_SIZE = 4096
# XRAM size in bytes.
XDATA_SIZE = 0


# Source files 
SRC :=  $(SRCDIR)/blinker.c \
        $(COMDIR)/soc.c
# Final executable HEX file
BIN :=  blinker.ihx

# Toolchain flags 
LFLAGS = -o $(OBJDIR)/ --code-size $(XCODE_SIZE) --xram-size $(XDATA_SIZE) 
CFLAGS = -o $(OBJDIR)/ -D__LIGHT52__=1


# Include the main makefile body with all the rules.
include ../include/common.mk
