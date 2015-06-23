
This leon3 design is tailored to the Altera NiosII Cyclone III 
Embedded Evaluation Kit, with 16-bit DDR SDRAM and 1 Mbyte of SSRAM. 
The kit consists of a Cyclone III FPGA starter board and the LCD
Multimedia Daughter Card.

0. Introduction
---------------

The leon3 design can be synthesized with quartus or synplify,
and can reach 60 - 70 MHz depending on configuration and synthesis
options. Use 'make quartus' or 'make quartus-synp' to run the
complete flow. To program the FPGA in batch mode, use 
'make quartus-prog-fpga' or 
'make quartus-prog-fpga-ref (reference config).

This template design does not require modification of the logic in the
daughter card CPLD. The CPLD is assumed to have its default configuration.

The daughter card documentation has the following notice to avoid 
bus contention:

"There are two LVDS termination resistors on the Cyclone III FPGA 
Starter Board, R3 and R4. R3 connects HC_RX_CLK and HC_TD_27MHZ; 
R4 connects HC_ADC_PENIRQ_n and HC_TX_CLK."

When using	Disable		Setting
Video decoder	Ethernet PHY	HC_ETH_RESET_N to 0
Touch panel	Ethernet PHY	HC_ETH_RESET_N to 0
Ethernet PHY	Video decoder	HC_TD_RESET to 0 and do not
				use the touch panel function
				when the ethernet PHY is
				enabled.

In the template design, HC_TD_RESET is always driven to '0'.
The user is responsible for not using the touch panel at
the same time as the Ethernet PHY is in use.

1. Unsupported peripherals / Further development
------------------------------------------------

The video decoder and audio decoder are not used.

2. System
---------

The output from grmon should look something like this:

grmon -altjtag -jtagdevice 1 -ramrws 1 -normw

 GRMON LEON debug monitor v1.1.30

 Copyright (C) 2004-2008 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com

 using Altera JTAG cable
 Selected cable 1 - USB-Blaster [USB 1-1.1]
JTAG chain:
@1: EP3C25 (0x020F30DD)

 GRLIB build version: 3050

 initialising ................
 detected frequency:  50 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 SVGA frame buffer                    Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 LEON2 Memory Controller              European Space Agency
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR266 Controller                    Gaisler Research
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 General purpose I/O port             Gaisler Research
 Keyboard PS/2 interface              Gaisler Research
 AMBA Wrapper for OC I2C-master       Gaisler Research
 SPI Controller                       Gaisler Research
 SPI Controller                       Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 1
02.01:063   Gaisler Research  SVGA frame buffer (ver 0x0)
             ahb master 2
             apb: 80000b00 - 80000c00
             clk0: 33.20 MHz
03.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 3, irq 10
             apb: 80000a00 - 80000b00
             edcl ip 192.168.0.57, buffer 2 kbyte
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
             baud rate 38343
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 50
05.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000500 - 80000600
06.01:060   Gaisler Research  Keyboard PS/2 interface (ver 0x1)
             irq 6
             apb: 80000600 - 80000700
08.01:028   Gaisler Research  AMBA Wrapper for OC I2C-master (ver 0x0)
             irq 11
             apb: 80000800 - 80000900
09.01:02d   Gaisler Research  SPI Controller (ver 0x1)
             irq 9
             apb: 80000900 - 80000a00
             FIFO depth: 4, 1 slave select signals
             Controller index for use in GRMON: 1
0c.01:02d   Gaisler Research  SPI Controller (ver 0x1)
             irq 12
             apb: 80000c00 - 80000d00
             FIFO depth: 4, 2 slave select signals
             Controller index for use in GRMON: 2
grlib> 

3. DDR interface
----------------

The DDR interface is supported and runs at 100 MHz.
The read data clock phase shift should be set to 90' (rskew = 2500).

4. SSRAM interface
------------------

The SSRAM can be accessed using the standard LEON2 MCTRL core.
One read waitstate is needed, start grmon with :

	grmon -altjtag -jtagdevice 1 -ramrws 1 -normw

5. Flash memory
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

The programming is slow, and will take at approximately 30 minutes with a JTAG 
connection. The ethernet debug link is significantly faster.

6. SPI SD Card interface
----------------

The design instantiates a SPICTRL core which is connected to the SD card slot.
The user may deselect the SPI controller (SPICTRL) and enable the SPI memory
controller instead. SPIMCTRL allows reading SD cards without additonal software
support. The design will not synthesize if both cores are enabled.

Suitable configuration values for SPIMCTRL are; SD Card = 1, Clock divisor = 2,
Alt. clock divisor = 7. Note that the SPIMCTRL core will insert a large amount
of wait states on the system bus if AMBA SPLIT support is not enabled.

7. Ethernet interface
---------------------

The design can be configured to instantiate a GRETH. Note that if the
LCD touch panel interface is enabled the GRETH is not instantiated 
even if it is selected in xconfig. See the note about bus contention
in section 0. Introduction of this file.


8. I2C interface
----------------

The design instantiates an I2C-master that is connected to the daughter
card EEPROM. The daughter card uses uni-directional I2C clock lines
and this prevents slaves from stretching the master clock.

grlib> i2c read 0x50 0 16

 00:    10      10      00      07
 04:    ed      08      07      6d
 08:    0f      6a      0f      09
 0c:    00      84      00      94

9. LCD support
---------------

Two cores must be instantiated to fully support all the functionality
of the LCD touch panel. For video display an SVGACTRL core is 
instantiated. The 3-wire interface and panel ADC is interfaced with 
an instantiation of a SPICTRL core. The designer can configure the 
design to exclude any of these cores.

The 3-wire serial interface and the touch panel ADC are wired to
share the same clock. The touch panel slave select signal is wired
to the first slave select signal of the SPICTRL core. The three wire 
enable signal is wired to the second slave select signal.

The ADC busy and interrupt signals are connected to GPIO 3 and 4, 
respectively, and can be accessed via the GRGPIO core.

10. VGA support
---------------

The designer can enable a SVGACTRL core to drive the VGA DAC.


11. Loading and starting an OS from GRMON
-----------------------------------------

Before loading an OS with GRMON it may be necessary to adjust
the stack pointer. This can be done by supplying the flag

    -stack 0x41ffff00 

or by using the GRMON command
   
   stack 0x41ffff00

after a connection has been made to the board.

