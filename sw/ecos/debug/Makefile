# This file is in the public domain and may be used for any purpose

# Usage:   make INSTALL_DIR=/path/to/ecos/install

# INSTALL_DIR=$$(INSTALL_DIR) # override on make command line
# INSTALL_DIR = ../LPC2294_ram/install
INSTALL_DIR = ../LPC2294_ram_no_net/install


# main 
MAIN_PATH = .

MAIN_OBJECT_FILES = $(MAIN_PATH)/main.o

MAIN_HEADER_FILES = $(MAIN_PATH)/lpc22xx.h \
                    $(MAIN_PATH)/shell_cmds.h \

# debug shell
DBG_SH_PATH = ../shell

DBG_SH_OBJECT_FILES = $(DBG_SH_PATH)/parse.o \
                      $(DBG_SH_PATH)/mem_func.o \
                      $(DBG_SH_PATH)/memtest.o \
                      $(DBG_SH_PATH)/dbg_sh.o
                      
DBG_SH_HEADER_FILES = $(DBG_SH_PATH)/dbg_sh.h \
                      $(DBG_SH_PATH)/parse.h \
                      $(DBG_SH_PATH)/memtest.h
                      

OBJECT_FILES = $(DBG_SH_OBJECT_FILES) $(MAIN_OBJECT_FILES)
HEADER_FILES = $(DBG_SH_HEADER_FILES) $(MAIN_HEADER_FILES)


include $(INSTALL_DIR)/include/pkgconf/ecos.mak

XCC           = $(ECOS_COMMAND_PREFIX)gcc
XAR           = $(ECOS_COMMAND_PREFIX)ar
XCXX          = $(XCC)
XLD           = $(XCC)

CFLAGS        = -I$(INSTALL_DIR)/include -I $(MAIN_PATH)/
CXXFLAGS      = $(CFLAGS)
LDFLAGS       = -nostartfiles -L$(INSTALL_DIR)/lib -Ttarget.ld

# RULES

.PHONY: all clean

all:  debug 

clean:
	-rm -f debug $(OBJECT_FILES)

%.o: %.c
	$(XCC) -c -o $*.o $(CFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

%.o: %.cxx
	$(XCXX) -c -o $*.o $(CXXFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

%.o: %.C
	$(XCXX) -c -o $*.o $(CXXFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

%.o: %.cc
	$(XCXX) -c -o $*.o $(CXXFLAGS) $(ECOS_GLOBAL_CFLAGS) $<

debug: $(OBJECT_FILES) $(HEADER_FILES) 
	$(XLD) $(LDFLAGS) $(ECOS_GLOBAL_LDFLAGS) -o $@ $(OBJECT_FILES)

