CC=powerpc-linux-gnu-gcc
AS=powerpc-eabi-as
#XILINX_INC=../ppc405_0/libsrc/cpu_ppc405_v1_10_a/src

tstamp_lnx: tstamp_lnx.o
	$(CC) -o $@ -static $<

tstamp_lnx.o: tstamp_lnx.s
	grep -v gnu_attribute < $< > tmp.s
	$(AS) -o $@ tmp.s
	rm -rf tmp.s

tstamp_lnx.s: tstamp_lnx.c
	$(CC) -S $<

clean:
	rm -rf tstamp_lnx.[os]
