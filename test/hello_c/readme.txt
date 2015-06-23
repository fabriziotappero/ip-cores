Hello_c --  This is your typical 'Hello World!' in C.

This demo will just print a welcome message to the serial port (19200/8/N/1).


In order to make this demo, you need the free C compiler SDCC and some flavor
of 'make'.

Running 'make all' will compile the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.
See the makefile for other make targets ('clean', etc.).

You can run this demo on the software simulator B51 by running script 'run.bat'.
You can run this demo in Modelsim by modifyng script /sim/light52_hello_tb.do
slightly -- compile the object code package for this demo.

Once you have run the demo in Modelsim and B51, you can then compare the
respective simulation logs (sw_log.txt and /sim/hw_sim_log.txt). For this demo,
both files might not be identical because the B51 simulator is not cycle
accurate in its simulation of the serial port.

It should be easy to port the BAT scripts to any linux shell flavor.
