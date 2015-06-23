#
# Makefile for DAC control circuit test
#

all:		dac_test

dac_test:	dac.v dac_test.v
		iverilog -Wall -o dac_test dac_test.v

run:		dac_test
		./dac_test

dump.vcd:	dac_test
		./dac_test

show:		dump.vcd
		gtkwave dump.vcd dac_test.cfg

clean:
		rm -f *~ dac_test dump.vcd
