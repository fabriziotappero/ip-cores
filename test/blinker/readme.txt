Blinker --  LED blinker program.

This demo will just print a welcome message to the serial port (19200/8/N/1) and
then will count up seconds, displaying the count in ports P0 (high byte) and
P1 (low byte).

This is meant to be used in small dev boards that don't have a RS232 port (like 
the only Spartan-3 dev kit I happen to have on hand).

In order to make this demo, you need the free C compiler SDCC and some flavor
of 'make'.

Running 'make all' will compile the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.
See the makefile for other make targets ('clean', etc.).

Running this demo on the software simulator B51 is possible (by running script 
'run.bat') but will do you no good: the Sw simulator doe snot simulate the 
peripherals.
You can run this demo in Modelsim by modifyng script /sim/light52_hello_tb.do
slightly -- compile the object code package for this demo.

This program uses the timer0 interrupt so it covers a wider fraction of the 
core.
