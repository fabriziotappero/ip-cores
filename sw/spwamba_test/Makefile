#
# Build test software for SpaceWire Light with AMBA interface on LEON3.
#
# This Makefile builds a test program for use with spwamba_gr-xc3s1500
# on real hardware.
#
# A different configuration of this test program is used in a simulation.
# In that case the program is built by sim/spwamba_leon3/Makefile.
#

SWDEFS = -DTXCLKFREQ=200 -DDESCTABLESIZE=10 -DQUEUEFILL=1980 -DLOOPBACKSWITCH=0

CC = sparc-elf-gcc
CFLAGS = -msoft-float -Wall -Os
LDFLAGS = -msoft-float

MKPROM = sparc-elf-mkprom
PROMFLAGS = -freq 40 -nosram -sdram 64 -v -msoft-float

.PHONY: all
all: spwamba_test.dsu spwamba_test.prom

spwamba_test.dsu: spwamba_test.o
	$(CC) $(LDFLAGS) $^ -o $@

spwamba_test.prom: spwamba_test.dsu
	$(MKPROM) $(PROMFLAGS) $< -o $@

spwamba_test.o: spwamba_test.c
	$(CC) $(SWDEFS) $(CFLAGS) -c $<

.PHONY: clean
clean:
	$(RM) spwamba_test.o spwamba_test.dsu spwamba_test.prom xdump.s

