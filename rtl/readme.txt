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

grp_debouncer.vhd       switch debouncer model


The original development is done in Xilinx ISE 13.1, targeted to a Spartan-6 device.

ISIM SIMULATION
---------------

VHDL simulation was done in ISIM, after Place & Route, with default constraints, for the slowest Spartan-6 device.

SILICON VERIFICATION
--------------------

Design verification in silicon was done in a Digilent Atlys board, and the verification project can be found at the  \trunk\syn directory, with all the required files to replicate the verification tests, including pinlock constraints for the Atlys board.

LICENSING
---------

This work is licensed as a LGPL work. If you find this licensing too restrictive for hardware, or it is not adequate for you, please get in touch with me and we can arrange a more suitable open source hardware licensing.


If you have any questions or usage issues with this core, please open a thread in OpenCores forum, and I will be pleased to answer.

If you find a bug or a design fault in the models, or if you have an issue that you like to be addressed, please open a bug/issue in the OpenCores bugtracker for this project, at 
		http://opencores.org/project,debouncer_vhdl,bugtracker.

If you use this module, please drop some feedback at jdoin@opencores.org

In any case, thank you for testing and using this core.


Jonny Doin
jdoin@opencores.org

