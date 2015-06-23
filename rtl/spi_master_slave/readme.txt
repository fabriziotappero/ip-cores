SPI_MASTER_SLAVE
================


This project was started from the need to have a robust yet simple SPI interface core
written in VHDL to use in generic FPGA-to-device interfacing. 
The resulting cores generate very small and efficient circuits, that operate from very
slow SPI clocks up to over 50MHz SPI clocks.


VHDL files for spi master/slave project:
---------------------------------------

spi_master.vhd		spi master module, can be used independently
spi_slave.vhd		spi slave module, can be used independently
spi_loopback.vhd	wrapper module for simulating the master and slave modules
spi_loopback_test.vhd	testbench for simulating the loopback module, test master against slave
spi_loopback.ucf	constraints for simulation: Spartan-6, area, LUT compression.


The original development is done in Xilinx ISE 13.1, targeted to a Spartan-6 device.

ISIM SIMULATION
---------------

VHDL simulation was done in ISIM, after Place & Route, with default constraints, for the slowest 
Spartan-6 device, synthesis generated 41 slices, and the design was simulated at 25MHz spi SCK, and 100MHz for the parallel interfaces clocks.

SILICON VERIFICATION
--------------------

Design verification in silicon was done in a Digilent Atlys board, and the verification project can be found at the  \trunk\syn directory, with all the required files to replicate the verification tests, including pinlock constraints for the Atlys board.

LICENSING
---------

This work is licensed as a LGPL work. If you find this licensing too restrictive for hardware, or it is not adequate for you, please get in touch with me and we can arrange a more suitable open source hardware licensing.



If you have any questions or usage issues with this core, please open a thread in OpenCores forum, and I will be pleased to answer.

If you find a bug or a design fault in the models, or if you have an issue that you like to be addressed, please open a bug/issue in the OpenCores bugtracker for this project, at 
		http://opencores.org/project,spi_master_slave,bugtracker.


In any case, thank you for testing and using this core.


Jonny Doin
jdoin@opencores.org

