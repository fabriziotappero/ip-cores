1. All of the SPI FLASH interface modules are in "spi_pack.vhd"
2. The file "spi_flash_sim.txt" is used to define the contents of the 
   simulated SPI FLASH device which is used in the testbench.
3. The testbench is part of the larger design 
   "spi_flash_interface_used_in_larger_FPGA_setting_for_register_initialization"
   which is a .zip file containing many VHDL source files.
   
   The SPI FLASH interface is used in the larger design to automatically
   read the SPI FLASH, and provide ASCII command characters through a UART
   which feeds a serial command interface.
   
   The testbench essentially emulates a UART by reading a file.  The serial
   characters are used to issue commands which can exercise the various
   parts of the design.  The file which feeds the commands to the design
   under test is called "rs232_test_in.txt" and the results file of
   serial response characters is "rs232_test_out.txt"  The files are
   contained within the /testbench subfolder.
   
   The operation of the larger design is too complicated to explain here,
   but please read the code in spi_pack.vhd, it has comments that explain
   many aspects of the unit's operation.

   Enjoy!
   
   John Clayton
   September 6th, 2013.
   