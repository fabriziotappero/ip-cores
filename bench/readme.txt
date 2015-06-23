DEBOUNCER_VHDL
==============


This is a very simple switch debouncer written in VHDL. 
It is a pipelined, fully static design, and handles a group of signals with common debouncing.

The switch grouping in a std_logic_vector() has 2 main advantages: 

    -> saves silicon space, by having a common counter;
    -> guarantees that a given switch set will not show asynchronous state changes relative to each other inside the debouncing time window;

The debouncer has a very simple interface, and is straightforward to use. No vendor-specific syntax or code is used in this design.


VHDL files for spi master/slave project:
---------------------------------------

grp_debouncer.vhd               switch debouncer model
debounce_atlys_test.vhd         testbench for simulator
debounce_atlys_test.wcfg        waveform configuration for iSim testbench
debounce_atlys_top.vhd          top entity for testing in FPGA
debounce_atlys.ucf              Xilinx user constraints file for pin lock for Digilent Atlys board
debounce_vhdl_bench.xise        Xilinx ISE13.1 project


The original development is done in Xilinx ISE 13.1, targeted to a Spartan-6 device.

ISIM SIMULATION
---------------

VHDL simulation was done in ISIM, after Place & Route, with default constraints, for the slowest Spartan-6 device.


SILICON VERIFICATION
--------------------

Design verification in silicon was done in a Digilent Atlys board, and the verification project can be found at the  \trunk\bench directory, with all the required files to replicate the verification tests, including pinlock constraints for the Digilent Atlys board.


If you have any questions or usage issues with this core, please open a thread in OpenCores forum, and I will be pleased to answer.

If you find a bug or a design fault in the models, or if you have an issue that you like to be addressed, please open a bug/issue in the OpenCores bugtracker for this project, at 
		http://opencores.org/project,debouncer_vhdl,bugtracker.

If you use this module, please drop some feedback at jdoin@opencores.org

In any case, thank you for testing and using this core.


Jonny Doin
jdoin@opencores.org

