
This leon3 design is tailored to the Altera NiosII Startix2 
Development board, with 16-bit DDR SDRAM and 2 Mbyte of SSRAM. 

As of this time, the DDR interface only works up to 120 MHz.
At 130 MHz, DDR data can be read but not written. 

NOTE: the test bench cannot be simulated with DDR enabled
because the Altera pads do not have the correct delay models.

* The SMSC LAN91C111 10/100 Ethernet controller is attached
  to the I/O area of the memory controller at address 0x20000300.
  The ethernet interrupt is connected to GPIO[4], i.e. IRQ4.


* How to program the flash prom with a FPGA programming file

  1. Create a hex file of the programming file with Quartus.

  2. Convert it to srecord and adjust the load address:

	objcopy --adjust-vma=0x800000 output_file.hexout -O srec fpga.srec

  3. Program the flash memory using grmon:

      flash unlock all
      flash erase 0x800000 0xb00000
      flash load fpga.srec


* The SSRAM can be use if one waitstate is programmed in the memory controller.
  When using grmon, start with -ramws 1 .
