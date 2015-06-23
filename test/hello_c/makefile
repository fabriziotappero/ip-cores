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

PROJ_NAME = "Hello World"
# XROM size in bytes.
XCODE_SIZE = 2048
# XRAM size in bytes -- should be zero but the HW does not support that yet.
XDATA_SIZE = 512


# Source files 
SRC :=  $(SRCDIR)/hello.c
# Final executable HEX file
BIN :=  hello.ihx

# Toolchain flags 
LFLAGS = -o $(OBJDIR)/ --code-size $(XCODE_SIZE) --xram-size $(XDATA_SIZE) 
CFLAGS = -o $(OBJDIR)/ -D__LIGHT52__=1


# Include the main makefile body with all the rules.
include ../include/common.mk
