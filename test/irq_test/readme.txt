Irq_test -- Basic trials of the interrupt handling logic.

This demo does a few very basic tests of the IRQ handling logic, by triggering
the timer interrupt and the external interrupt. No other interrupt sources are
used.
This demo will only work in the simulation test bench, because it requires the
external interrupt inputs to be wired to the P1 output port; they are in the
simulation test bench entity but not in the synthesizable demo top entity.


In order to make this demo, you need the free assembler ASEM51.

DOS BAT script 'build.bat' will assemble the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.

You can run this demo on the software simulator B51 by running script 'run.bat';
it will fail because B51 does not simulate the wiring on EXTINT required by this
program, as mentioned above.
You can run this demo in Modelsim using script /sim/light52_irq_tb.do.

Once you have run the demo in Modelsim and B51, you can then compare the
respective simulation logs (sw_log.txt and /sim/hw_sim_log.txt). For this demo,
both files should be identical.

It should be easy to port the BAT scripts to any linux shell flavor.
