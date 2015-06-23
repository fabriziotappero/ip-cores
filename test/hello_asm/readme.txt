Hello_asm -- displays a 'hello' greeting message on the serial port.

In order to make this demo, you need the free assembler ASEM51.

DOS BAT script 'build.bat' will assemble the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.

You can run this demo on the software simulator by running script 'run.bat'.

You can run this demo in Modelsim using script /sim/light52_hello_tb.do.

Once you have run the demo in Modelsim and B51, you can then compare the
respective simulation logs (sw_log.txt and /sim/hw_sim_log.txt). For this demo,
both files should be identical.

It should be easy to port the BAT scripts to any linux shell flavor.
