
This leon3 design is tailored to the Xilinx Virtex4 ML403 board
---------------------------------------------------------------------

Design specifics:

* System reset is mapped to the CPU RESET button

* The serial port is connected to the console UART (UART 1) when
  dip switch 1 on the GPIO DIP switch is off. Otherwise it is 
  connected to the DSU UART. The DSU BREAK input is mapped
  on the 'south' push-button.

* The JTAG DSU interface is enabled and works well with
  GRMON and Xilinx parallel cables. Grmon-1.0.24 and later
  also work with the Xilinx Platform USB cable.

* The 100 Mbit version of GRETH is enabled. Ethernet debug link
  is also enabled, but will only work on a 100 Mbit connection.
  The 1000 Mbit version of GRETH is not enabled but works well on 
  the board. Note that this core is not available in the GPL version
  of GRLIB. If the 1000 Mbit version is enabled, the IOBDELAY
  constraints for phy_rx_data(7 downto 4) should be uncommented
  in leon3mp.ucf. These constraints must not be present for designs 
  without the 1000 Mbit GRETH due to a bug in Xilinx's map tool.

* DDR is mapped at address 0x40000000, using the DDRSPA core.
  The DDR runs OK up to 120 MHz, higher frequencies can give
  data errors and is not recommended.

* The LEON3 processor can run up to 70 - 80 MHz on the board
  in the typical configuration.

* The SSRAM can be interfaced with either the SSRAM controller
  or the LEON2 Memory controller. Start GRMON with -ramws 1
  when the LEON2 controller is used.

* The I2C-master is enabled and is connected to the boards I2C
  bus which contains an EEPROM (24LC04B-I/ST) with I2C address
  0b1010--B (where B selects one of two 256-word blocks and '-'
  is don't care).

* The FLASH memory can be programmed using GRMON, regardless
  of which memory controller that is used.

* If the VGA core is enabled its constraints should be
  uncommented in leon3mp.ucf.

* Sample output from GRMON is:

 GRMON LEON debug monitor v1.1.19c

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com


 using JTAG cable on parallel port
 JTAG chain: xc95144xl xc4vlx25 xcf32p xccace

 GRLIB build version: 2314

 initialising .............
 detected frequency:  65 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 DDR266 Controller                    Gaisler Research
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 LEON2 Memory Controller              European Space Agency
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 General purpose I/O port             Gaisler Research
 AMBA Wrapper for OC I2C-master       Gaisler Research
 AHB status register                  Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 1
02.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 2, irq 12
             apb: 80000b00 - 80000c00
             edcl ip 192.168.0.69, buffer 2 kbyte
00.01:025   Gaisler Research  DDR266 Controller (ver 0x0)
             ahb: 40000000 - 50000000
             ahb: fff00100 - fff00200
             32-bit DDR : 1 * 64 Mbyte @ 0x40000000
                          120 MHz, col 9, ref 7.8 us
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0x43fffff0
             CPU#0 win 8, hwbp 2, itrace 128, srmmu, lddel 1
                   icache 4 * 4 kbyte, 32 byte/line lru
                   dcache 4 * 4 kbyte, 16 byte/line lru
03.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: c0000000 - c1000000
             apb: 80000000 - 80000100
             32-bit prom @ 0x00000000
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38400
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 65
08.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000800 - 80000900
0c.01:028   Gaisler Research  AMBA Wrapper for OC I2C-master (ver 0x0)
             irq 11
             apb: 80000c00 - 80000d00
0f.01:052   Gaisler Research  AHB status register (ver 0x0)
             irq 7
             apb: 80000f00 - 80001000
grlib> fla

 Intel-style 32-bit (2x16-bit) flash

 Manuf.    Intel               Intel
 Type      MT28F320J3          MT28F320J3

 Device ID 81210928c438f018    d13909b886afd4e6
 User   ID a003ffffbb35ce9b    ffffffffffffffff

 2 x 4 Mbyte = 8 Mbyte total @ 0x00000000

 CFI information

 flash family  : 1
 flash size    : 32 Mbit
 erase regions : 1
 erase blocks  : 32
 write buffer  : 32 bytes
 region  0     : 32 blocks of 128 Kbytes

grlib> i2c read 0x50 0x00 8

 00:    48      57      2d      56
 04:    34      2d      4d      4c

grlib> i2c read 0x51 0x00 8

 00:    00      00      00      00
 04:    00      00      00      00

grlib>  
