		README memTest 

Open Cygwin and cd to the directory where this file is located.
Now type;
make

The make script has a common section that builds the object files from
the source files, and then two linker sections, one that creates an image
file with code and date based at address 0x0 (FPGA internal block RAM),
and another image file that uses 0x40000000 (external DRAM) as a base.

BlockRAM resident targets:
memTest.intel.hex is used as a FPGA Block RAM
initialization file in Altera Quartus
memTestSim.8bit.hex is used as a memory initialization
file during simulation. Note that the Makefile renames this file 
memory.hex and copies it to the sim directory. Also note that the 
Makefile uses compiler switches to build slightly different versions for
hardware and simulation. The hardware targeted build is a full memory test,
whereas the simulation targeted build is a much shorter test, with less text 
printing.

DRAM resident target:
memTestDramResident.bin can be copied to flash memory at location 0x90000.
Now use an Altera programming file that initializes FPGA block RAM with the 
boot loader, and the memory test program will be copied from flash to DRAM
and executed.






