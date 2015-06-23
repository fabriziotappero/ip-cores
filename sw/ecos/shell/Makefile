# Mostly written by Jonathan Larmour, Red Hat, Inc.
# Reference to ecos.mak added by John Dallaway, eCosCentric Limited, 2003-01-20
# This file is in the public domain and may be used for any purpose

# Usage:   make INSTALL_DIR=/path/to/ecos/install

# INSTALL_DIR=$$(INSTALL_DIR) # override on make command line
# INSTALL_DIR = ../ROM_slow/install
INSTALL_DIR = ../LPC2294_ram/install

OBJECT_FILES = parse.o main.o mem_func.o memtest.o dbg_sh.o
LIB_OBJECT_FILES = parse.o mem_func.o memtest.o dbg_sh.o
HEADER_FILES = lpc22xx.h dbg_sh.h parse.h shell_cmds.h memtest.h


include $(INSTALL_DIR)/include/pkgconf/ecos.mak

XCC           = $(ECOS_COMMAND_PREFIX)gcc
XAR           = $(ECOS_COMMAND_PREFIX)ar
XCXX          = $(XCC)
XLD           = $(XCC)

CFLAGS        = -I$(INSTALL_DIR)/include
CXXFLAGS      = $(CFLAGS)
LDFLAGS       = -nostartfiles -L$(INSTALL_DIR)/lib -Ttarget.ld

# RULES

.PHONY: all clean

all:  dbg_sh dbg_sh_lib

clean:
	-rm -f dbg_sh libdbg_sh.a $(OBJECT_FILES)

%.o: %.c
	$(XCC) -c -o $*.o $(CFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

%.o: %.cxx
	$(XCXX) -c -o $*.o $(CXXFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

%.o: %.C
	$(XCXX) -c -o $*.o $(CXXFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

%.o: %.cc
	$(XCXX) -c -o $*.o $(CXXFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

dbg_sh: $(OBJECT_FILES) $(HEADER_FILES) 
	$(XLD) $(LDFLAGS) $(ECOS_GLOBAL_LDFLAGS) -o $@ $(OBJECT_FILES)

dbg_sh_lib: $(OBJECT_FILES) $(HEADER_FILES) 
	$(XAR) rcs libdbg_sh.a $(LIB_OBJECT_FILES)

