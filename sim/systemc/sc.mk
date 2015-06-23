# Verilated -*- Makefile -*-

default: Vxge_mac__ALL.a

# Constants...
PERL = perl
#VERILATOR_ROOT = /opt/verilator-3.656
#SYSTEMPERL = /opt/SystemPerl-1.282

# Switches...
VM_SP = 0
VM_SC = 1
VM_SP_OR_SC = 1
VM_PCLI = 0
VM_SC_TARGET_ARCH = linux

# Vars...
VM_PREFIX = Vxge_mac
VM_MODPREFIX = Vxge_mac
VM_USER_CLASSES = \

VM_USER_DIR = \


CPPFLAGS += -I..
CPPFLAGS += -I.
CPPFLAGS += -I$(SYSTEMC)/include
#CPPFLAGS += -I$(VERILATOR_ROOT)/include
CPPFLAGS += -I$(SYSTEMPERL)/src
# -DSYSTEMPERL


include Vxge_mac_classes.mk
include $(VERILATOR_ROOT)/include/verilated.mk

# Local rules...

#SOURCES=../../tb_sc/sc_packet.cpp
#OBJECTS=$(SOURCES:.cpp=.o)

#all: $(OBJECTS)

%.o: ../../tbench/systemc/%.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $<


# Verilated -*- Makefile -*-
