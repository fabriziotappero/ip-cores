prefix = /usr/local

# Your build environment. selects libs, lib dirs, and include dirs
# Supported: linux, cygwin, freebsd
BUILD_ENVIRONMENT=cygwin

# Set this to 'true' if you want to build for the legacy debug unit ('debug_if' core),
# leave 'false' if you are building for the Advanced Debug Unit.
SUPPORT_LEGACY=false

# Set this to 'true' to include support for parallel cables
SUPPORT_PARALLEL_CABLES=true

# Set this to 'true' to include support for cables which require libusb
# currently includes Altera USB-Blaster and Xilinx XPC DLC8
SUPPORT_USB_CABLES=true

# Set this to 'true' to support cables which require libFTDI
# SUPPORT_USB_CABLES must also be set to 'true' to support FTDI-based cables.
SUPPORT_FTDI_CABLES=true

# Some Xilinx Parallel Cable IIIs will work just as fast as we can drive them.
# Some (clones) require us to limit their clock rate.  Three schemes are defined:
# "sleep_wait": tries not to use CPU, but may sleep much longer than desired
# "timer_wait": does busy-wait polling on a timer
# "no_wait": does not wait, runs as fast as possible
XPC3_LIMIT_SCHEME=timer_wait

# Normal error-checking on every word of a burst write can cause a significant
# slowdown, especially when using the USB-Blaster cable.  Setting this option
# true will eliminate this slowdown, at the cost of per-word error checking.
# Note that this option must also be defined in the hardware HDL.
USE_HISPEED=true

# If you have the JTAG Serial Port (JSP) included in you hardware, set
# the following to true to compile the JSP server
INCLUDE_JSP_SERVER=true

# The JTAG serial port is normally compatible with multi-device JTAG chains.
# However, this can hurt performance when using USB JTAG cables.  If you are
# using a USB JTAG cable and your JTAG chain has only one device on it,
# set this false to use a performance-optimized version.  Note this must also
# be defined in the hardware HDL.
JSP_MULTI_DEVICE_CHAIN=true

# Different optimizations have been implemented for different JTAG cables in
# the JSP driver.  The default implementation transfers the least number of
# bits, which works well for parallel JTAG cables.  When using a USB JTAG
# cable, set this to true to use a version of the driver that instead uses
# the smallest number of USB transactions.
JSP_OPTIMIZE_FOR_USB=true

# ----------------------------------------------------------------------------
# Most people shouldn't have to change anything below this line

ifeq ($(BUILD_ENVIRONMENT),linux)
# These are for native Linux.  You may need to put the path to libusb into the LIBS variable
# with the -L<dir> command.
CFLAGS = -g -O2 -Wall
CC = gcc
LIBS = -lpthread -lrt
INCLUDEDIRS = -I/usr/local/include/libusb-1.0/ -I/usr/include/ -I/usr/local/include/
endif

ifeq ($(BUILD_ENVIRONMENT),cygwin)
# These are for cygwin.  It assumes libusb.a is in the current directory.
CFLAGS = -g -O2 -Wall
CC = gcc
LIBS = -L. -lioperm -lpthread -lrt
INCLUDEDIRS = -I/usr/local/include/
endif

ifeq ($(BUILD_ENVIRONMENT),freebsd)
# These are for FreeBSD. Only FreeBSD >= 8 is supported (assumes, that
# libusb(8) is present in the base system (/usr/lib/libusb* exists).
CFLAGS = -g -O2 -Wall
CC = gcc
LIBS = -L. -L/usr/local/lib -lpthread -lrt
INCLUDEDIRS = -I/usr/local/include/
# We don't have a support for parallel cables on FreeBSD yet.
SUPPORT_PARALLEL_CABLES=false
endif

ifeq ($(SUPPORT_LEGACY),true)
CFLAGS +=  -D__LEGACY__
endif

ifeq ($(USE_HISPEED),true)
CFLAGS += -DADBG_OPT_HISPEED
endif

ifeq ($(JSP_MULTI_DEVICE_CHAIN),true)
CFLAGS += -DENABLE_JSP_MULTI
endif

ifeq ($(JSP_OPTIMIZE_FOR_USB),true)
CFLAGS += -DOPTIMIZE_JSP_FOR_USB
endif

ifeq ($(XPC3_LIMIT_SCHEME),sleep_wait)
CFLAGS += -D__PARALLEL_SLEEP_WAIT__
else
ifeq ($(XPC3_LIMIT_SCHEME),timer_wait)
CFLAGS += -D__PARALLEL_TIMER_BUSY_WAIT__
else
# no_wait is the default, nothing to define
endif
endif


PROGRAMS = adv_jtag_bridge

HEADERS = adv_jtag_bridge.h chain_commands.h opencores_tap.h \
	altera_virtual_jtag.h rsp-server.h bsdl.h or32_selftest.c cable_common.h \
	cable_sim.h \
	bsdl_parse.h errcodes.h spr-defs.h except.h adv_dbg_commands.h dbg_api.h \
	legacy_dbg_commands.h utilities.h hardware_monitor.h hwp_server.h

SOURCES = adv_jtag_bridge.c rsp-server.c chain_commands.c cable_common.c bsdl.c \
	or32_selftest.c cable_sim.c utilities.c \
	bsdl_parse.c errcodes.c adv_dbg_commands.c dbg_api.c legacy_dbg_commands.c \
	hardware_monitor.c hwp_server.c

OBJECTS = adv_jtag_bridge.o rsp-server.o chain_commands.o cable_common.o bsdl.o \
	or32_selftest.o cable_sim.o utilities.o \
	bsdl_parse.o errcodes.o adv_dbg_commands.o dbg_api.o legacy_dbg_commands.o \
	hardware_monitor.o hwp_server.o


ifeq ($(SUPPORT_PARALLEL_CABLES),true)
CFLAGS += -D__SUPPORT_PARALLEL_CABLES__
HEADERS += cable_parallel.h
SOURCES += cable_parallel.c
OBJECTS += cable_parallel.o
endif

ifeq ($(SUPPORT_USB_CABLES),true)
CFLAGS += -D__SUPPORT_USB_CABLES__
HEADERS += cable_xpc_dlc9.h cable_usbblaster.h
SOURCES += cable_xpc_dlc9.c cable_usbblaster.c
OBJECTS += cable_xpc_dlc9.o cable_usbblaster.o

ifeq ($(SUPPORT_FTDI_CABLES),true)
CFLAGS += -D__SUPPORT_FTDI_CABLES__
LIBS += -lftdi
HEADERS += cable_ft2232.h cable_ft245.h
SOURCES += cable_ft2232.c cable_ft245.c
OBJECTS += cable_ft2232.o cable_ft245.o
endif

# libusb must follow libftdi in the list of libraries
LIBS += -lusb
endif

ifeq ($(INCLUDE_JSP_SERVER),true)
CFLAGS += -DENABLE_JSP
HEADERS += jsp_server.h
SOURCES += jsp_server.c
OBJECTS += jsp_server.o
endif


all: $(PROGRAMS)

default: $(PROGRAMS)

.c.o:
	$(CC) $(CFLAGS) -c $<

adv_jtag_bridge: Makefile $(OBJECTS) $(HEADERS)
	rm -f $@
	$(CC) -o $@ $(CFLAGS) $(INCLUDEDIRS) $(OBJECTS) $(LIBS)


install: all
	[ -d $(prefix)/bin ] || mkdir -p $(prefix)/bin
	for p in $(PROGRAMS) ; do \
	    /bin/rm -f $(prefix)/bin/$$p; \
	    /bin/cp -p $$p $(prefix)/bin/$$p; \
	done

clean: Makefile
	rm -f $(PROGRAMS) *.o *~
