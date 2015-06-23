#
# Build SpaceWire Light driver and test program for RTEMS on LEON3.
#
# A different configuration of this test program is used in a simulation.
# In that case the program is built by sim/spwamba_leon3/Makefile.
#

TARGETDIR = /opt/rtems-4.10/sparc-rtems4.10/leon3
GCCSPECS  = -B$(TARGETDIR)/lib/ -specs bsp_specs -qrtems
CC        = sparc-rtems4.10-gcc
CFLAGS    = $(GCCSPECS) -msoft-float -Wall -Os
LDFLAGS   = $(GCCSPECS) -msoft-float

.PHONY: all
all: spwltest.dsu

spwltest.dsu: spwltest.o spacewirelight.o
	$(CC) $(LDFLAGS) $^ -o $@

spwltest.o: spwltest.c spacewirelight.h
	$(CC) $(CFLAGS) -c $<

spacewirelight.o: spacewirelight.c spacewirelight.h
	$(CC) $(CFLAGS) -c $<

.PHONY: clean
clean:
	$(RM) spwltest.dsu spwltest.o spacewirelight.o

