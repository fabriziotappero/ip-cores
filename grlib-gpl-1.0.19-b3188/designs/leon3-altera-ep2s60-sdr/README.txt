
This leon3 design is tailored to the Altera NiosII Startix2 
Development board, with 32-bit SDR SDRAM and 1 Mbyte of SRAM. 
Later versions of this board used DDR RAM, for which you should
use the leon3-altera-ep2s60-ddr template design.


* The SMSC LAN91C111 10/100 Ethernet controller is attached
  to the I/O area of the memory controller at address 0x20000300.
  The ethernet interrupt is connected to GPIO[4], i.e. IRQ4.

* How to program the flash prom with a FPGA programming file

  1. Create a hex file of the programming file with Quartus.

  2. Convert it to srecord and adjust the load address:

	objcopy --adjust-vma=0x800000 output_file.hexout -O srec fpga.srec

  3. Program the flash memory using grmon:

      flash erase 0x800000 0xb00000
      flash load fpga.srec


