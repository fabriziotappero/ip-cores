
This leon3 design is tailored to the Altera NiosII Stratix-III 
Development board, with 64-bit DDR2 SDRAM and 4 Mbyte PSRAM. 

0. Introduction
---------------

The leon3 design can be synthesized with quartus or synplify,
and can reach 150 - 170 MHz depending on configuration and synthesis
options. Use 'make quartus' or 'make quartus-synp' to run the
complete flow. To program the FPGA in batch mode, use 
'make quartus-prog-fpga' or 'make quartus-prog-fpga-ref (reference config).

The output from grmon should look something like this:

grmon -altjtag -jtagdevice 1 -u

 GRMON LEON debug monitor v1.1.29

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com

 using Altera JTAG cable
 Selected cable 1 - USB-Blaster [USB 1-1.2]
JTAG chain:
@1: EP3SL150 (0x121020DD)

 GRLIB build version: 2949

 initialising ...........
 detected frequency: 152 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 LEON2 Memory Controller              European Space Agency
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR2 Controller                      Gaisler Research
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 General purpose I/O port             Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> info sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 1
02.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 2, irq 12
             apb: 80000b00 - 80000c00
             edcl ip 192.168.0.88, buffer 2 kbyte
00.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: a0000000 - b0000000
             apb: 80000000 - 80000100
             16-bit prom @ 0x00000000
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0x7ffffff0
             CPU#0 win 8, hwbp 2, itrace 128, V8 mul/div, lddel 1
                   icache 2 * 8 kbyte, 32 byte/line lru
                   dcache 2 * 4 kbyte, 32 byte/line lru
03.01:02e   Gaisler Research  DDR2 Controller (ver 0x0)
             ahb: 40000000 - 80000000
             ahb: fff00100 - fff00200
             64-bit DDR2 : 2 * 512 Mbyte @ 0x40000000
                          200 MHz, col 10, ref 7.8 us
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38383, DSU mode (FIFO debug)
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 152
05.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000500 - 80000600
grlib>



1. DDR2 interface
----------------

The DDR2 interface has been tested up to 200 MHz. The input data delay
has to be recalibrated when the interface frequency change. This can be 
done dynamically or by changing the delay in the .qsf file.

2. SSRAM interface
------------------

The PSRAM is not supported.

3. UART
-------

The board has no RS232 connector, so grmon should be started
with -u to loop-back the UART output to the console.

4. Flash memory
---------------

The 16-bit flash memory can be accessed and programmed by grmon,
if the SSRAM is working. The output from the 'flash' command is
listed below:

grlib> flash

 Intel-style 16-bit flash on D[31:16]

 Manuf.    Intel
 Device    0x891C

 Device ID a1d1ffff02824530
 User   ID ffffffffffffffff


 1 x 32 Mbyte = 32 Mbyte total @ 0x00000000


 CFI info
 flash family  : 1
 flash size    : 256 Mbit
 erase regions : 2
 erase blocks  : 259
 write buffer  : 64 bytes
 region  0     : 4 blocks of 32 Kbytes
 region  1     : 255 blocks of 128 Kbytes


* How to program the flash prom with a FPGA programming file

  1. Create a hex file of the programming file with Quartus.

  2. Convert it to srecord and adjust the load address:

	objcopy --adjust-vma=0x20000 output_file.hexout -O srec fpga.srec

  3. Program the flash memory using grmon:

      flash unlock all
      flash erase 0x20000 0x100000
      flash load fpga.srec

The programming is slow, and will take at approximately 30 minutes.

5. Ethernet
-----------

The Ethernet debug link is enabled with IP=192.168.0.88.
To be able to connect to the EDCL, the PHY has to be configured by 
the following grmon command:

wmdio 18 27 0x808f
wmdio 18 0 0xb100



