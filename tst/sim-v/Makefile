#
# Makefile to build a simulation of the test circuit
#

all:		dump.vcd

show:		dump.vcd
		gtkwave dump.vcd top.cfg

dump.vcd:	top
		./top

top:		top.v
		iverilog -Wall -o top top.v

clean:
		rm -f *~ top dump.vcd
