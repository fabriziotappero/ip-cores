
This leon3 design is tailored to the Altera NiosII Cyclone-III 
Development board, with 16-bit DDR SDRAM and 1 Mbyte of SSRAM. 

0. Introduction
---------------

The leon3 design can be synthesized with quartus or synplify,
and can reach 50 - 70 MHz depending on configuration and synthesis
options. Use 'make quartus' or 'make quartus-synp' to run the
complete flow. To program the FPGA in batch mode, use 
'make quartus-prog-fpga' or 'make quartus-prog-fpga-ref (reference config).

The output from grmon should look something like this:

grmon -altjtag -jtagdevice 1 -ramrws 1 -normw -u

 GRMON LEON debug monitor v1.1.30

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com

 using Altera JTAG cable
Can't open file '/root/.jtag.conf', errno = 2
Can't open file '/root/.jtag.conf', errno = 2
 Selected cable 1 - USB-Blaster [USB 1-1.2]
JTAG chain:
@1: EP3C25 (0x020F30DD)

 GRLIB build version: 2996

 initialising ..........
 detected frequency:  51 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 LEON2 Memory Controller              European Space Agency
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR266 Controller                    Gaisler Research
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
00.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: a0000000 - b0000000
             apb: 80000000 - 80000100
             16-bit prom @ 0x00000000
             32-bit static ram: 1 * 1024 kbyte @ 0xa0000000
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0xa00ffff0
             CPU#0 win 8, hwbp 2, itrace 128, V8 mul/div, lddel 1
                   icache 2 * 8 kbyte, 32 byte/line lru
                   dcache 2 * 4 kbyte, 16 byte/line lru
03.01:025   Gaisler Research  DDR266 Controller (ver 0x0)
             ahb: 40000000 - 50000000
             ahb: fff00100 - fff00200
             16-bit DDR : 1 * 32 Mbyte @ 0x40000000
                          100 MHz, col 9, ref 7.8 us
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38403, DSU mode (FIFO debug)
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 51
05.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000500 - 80000600
grlib>



1. DDR interface
----------------

The DDR interface is supported and runs at 100 MHz.
The read data clock phase shift should be set to 90' (rskew = 2500).

2. SSRAM interface
------------------

The SSRAM can be accessed using the standard LEON2 MCTRL core.
One read waitstate is needed, start grmon with :

	grmon -altjtag -jtagdevice 1 -ramrws 1 -normw -u

3. UART
-------

The board has no RS232 connector, so grmon should be started
with -u to loop-back the UART output to the console.

4. Flash memory
---------------

The 16-bit flash memory can be accessed and programmed by grmon,
if the SSRAM is working. The output from the 'flash' command is
listed below:

grlib> fla

 Intel-style 16-bit flash on D[31:16]

 Manuf.    Intel
 Device    0x881B

 Device ID 70a6ffff00684403
 User   ID ffffffffffffffff


 1 x 16 Mbyte = 16 Mbyte total @ 0x00000000


 CFI info
 flash family  : 1
 flash size    : 128 Mbit
 erase regions : 2
 erase blocks  : 131
 write buffer  : 64 bytes
 region  0     : 4 blocks of 32 Kbytes
 region  1     : 127 blocks of 128 Kbytes


5.1 How to program the flash prom with a FPGA programming file
--------------------------------------------------------------

There are two ways of programming the Flash memory. One using
Altera's Parallel Flash Loader and one using GRMON.

Programming the Flash using Altera's Parallel Flash Loader:

  1.  Start Quartus II and select File -> Convert Programming Files

  2.  Make the following settings:

       Programming File Type: Programmer Object file (.pof)
       Mode: Active Parallel
       Configuration device: CFI_128MB

  3.  Select "Configuration Master" under "Input files to convert" and click
      "Add file"

  4.  Select the leon3mp.sof file and click OK

  5.  Select "SOF data" and click "Properties"

  6.  Change the following properties:

       Address mode for selected pages: Start
       Start address: 0x020000

  7.  Generate the programmer object file by clicking "Generate"

  8.  Start the Quartus II programmer

  9.  Click "Auto Detect"

  10. Right-click on the detected EP3C25 device and select "Attach Flash Device"

  11. Select Flash Memory, CFI_128MB and click "OK"

  12. Right click on the added CFI_128MB Flash device and select "Change File"

  13. Select the .pof file that was generated in step 7 and click "OK".

  14. Check the "Program/Configure" box for the added file under the Flash
      device. Checking this box will change the Device File to "Factory
      default PFL image"

  15. Click "Start"

  16. When programming has successfully finished press "Reconfigure" on the
      board to load the leon3mp design.  

Programming the Flash with GRMON:

  1. Create a hex file of the programming file with Quartus. Choose 
     "Active Parallel" as the Mode. This mode is available in Quartus II 7.2 

  2. Convert the Intel Hex file to srecord format. The hexfile needs to be byte 
     swapped. This can be done with a tool from the SRecord package which can be
     downloaded from http://srecord.sourceforge.net/. Issue the command:

        srec_cat output_file.hexout -Intel -byteswap > fpga.srec

     If the resulting fpga.srec file does not have the correct offset, the
     offset may have to be given as an argument to srec_cat:

        srec_cat output_file.hexout -Intel -byteswap -offset 0x20000 > fpga.srec

     To see that the data has the correct offset, issue the command:
       
        srec_info fpga.srec

     The "Data:" area should start at 020000.

  3. Program the flash memory using grmon:

      flash unlock all
      flash erase 0x20000 0x100000
      flash load fpga.srec

The programming is slow, and will take at approximately 30 minutes.

