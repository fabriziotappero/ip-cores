HOW TO run a simulation

Note, if you want to test changes to a peripheral, it may be 
easier and faster to simulate the peripheral seperately from the 
cyc2-openrisc project. See spiMaster project for example.

First build the software application. sw/memTest can be used
as an example.
From Cygwin window, cd to sw/memTest
make clean all
This will build memTestSim.8bit.hex, and copy the file to the sim directory
as memory.hex

Run 
  build_icarus.bat
to compile the source files, and 
  run_icarus.bat
to run the simulation. You should see DRAM activity reported to the
command window. You can turn this off by setting Debug = 1'b0 in 
model/mt48lc2m32.v. When you see the DRAM write activity finish, leave the
simulation to run for one more minute (to let the UART output complete), and
then stop the simulation using
  ^C ^C
And quit the simulation.
You can view FPGA block RAM activity in sram.log, and the UART output
in uart.log
Now from a command window, cd to the sim directory, and run GTKwave;
  GTKwave wave.vcd
From the GTKWave application;
  Search >> Signal Search Tree
and browse design hierarchy and select the signals you wish to view.


