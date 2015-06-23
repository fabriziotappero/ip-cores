#!/bin/sh

rm -f oks8sim.out
rm -f oks8sim.vcd
iverilog -csim -o oks8sim.out
vvp oks8sim.out
gtkwave oks8sim.vcd
