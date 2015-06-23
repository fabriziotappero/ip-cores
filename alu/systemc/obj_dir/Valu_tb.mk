# Verilated -*- Makefile -*-

default: Valu_tb

# Constants...
PERL = perl
VERILATOR_ROOT = /usr/local/verilator-3.701
SYSTEMPERL = /home/leonous/Download/tmp/SystemPerl-1.310

# Switches...
VM_SP = 0
VM_SC = 1
VM_SP_OR_SC = 1
VM_PCLI = 0
VM_SC_TARGET_ARCH = linux

# Vars...
VM_PREFIX = Valu_tb
VM_MODPREFIX = Valu_tb
VM_USER_CLASSES = \
	sc_main \
	verilated \

VM_USER_DIR = \
	. \


# Default rules...
include Valu_tb_classes.mk
include $(VERILATOR_ROOT)/include/verilated.mk

# Local rules...
VPATH += $(VM_USER_DIR)

sc_main.o: sc_main.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
verilated.o: verilated.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<

# Link rules...
Valu_tb: $(VK_USER_OBJS) $(SP_SRCS) $(VM_PREFIX)__ALL.a
	$(LINK) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@ $(LIBS) $(SC_LIBS) 2>&1 | c++filt


# Verilated -*- Makefile -*-
