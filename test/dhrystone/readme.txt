Dhrystone -- Dhrystone benchmark ported to the light52 MCU.

This demo will just run the benchmark and print the results to the serial
port (19200/8/N/1). with a 50MHz clock, the benchmark should take about 15
seconds to complete.

In order to make this demo, you need the free C compiler SDCC and some flavor
of 'make'.

Running 'make all' will compile the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.
See the makefile for other make targets ('clean', etc.).

You can run this demo on the software simulator B51 by running script 'run.bat'.
You can run this demo in Modelsim by modifyng script /sim/light52_c2sb_tb.do
slightly -- compile the object code package for this demo.
Note that both simulations will produce huge log files and take a very long
time, specially Modelsim's. Since B51 is not clock-accurate in the simulation of
peripherals, the logs may not be identical.

This demo is not meant for cosimulation but for execution on real hardware.


It should be easy to port the BAT scripts to any linux shell flavor.
