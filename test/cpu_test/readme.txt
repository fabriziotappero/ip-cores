Cpu_test -- Perform a basic test of all the CPU opcodes.

This demo will test all the CPU opcodes for basic behavior. Each opcode is
tested at least once. Those opcodes with more complex behavior (e.g. ADD) are
tested with a few 'corner cases', but the test is by no means exhaustive.

In particular, this test bench does not check for unintended side effects.

This demo can be run on a physical core, but it is most useful when used with
the simulation log feature -- comparing the simulation logs of Modelsim and the
software simulator B51 (included as part of this project).

In order to make this demo, you need the free assembler ASEM51.

DOS BAT script 'build.bat' will assemble the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.
In fact, two object code packages will be built: the code will be assembled

You can run this demo on the software simulator B51 by running script
'run_full.bat'. This script will simulate the 'full' CPU which implements the
optional BCD opcodes. Script 'run.bat' will simulate the basic cpu with no BCD
opcodes.
You can run this demo in Modelsim using script /sim/light52_full_tb.do (for the
full CPU) or script /sim/light52_tb.do (basic CPU).

Once you have run the demo in Modelsim and B51, you can then compare the
respective simulation logs (sw_log.txt and /sim/hw_sim_log.txt). For this demo,
both files should be identical.

It should be easy to port the BAT scripts to any linux shell flavor.
