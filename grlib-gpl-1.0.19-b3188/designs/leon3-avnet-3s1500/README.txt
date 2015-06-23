
This leon3 design is tailored to the Avnet Spartan3 Eval board
---------------------------------------------------------------------

Design specifics:

* System reset is mapped to the SW[4]

* The console UART (UART 1) is connected to the P3 DB-9 connector.

* The JTAG DSU interface is enabled and works well with
  GRMON and Xilinx parallel cabel III or IV .

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Ethernet debug link is enabled, default IP is 192.168.0.51.

* The SRAM (1 Mbyte) is attached using a modified version
  of the leon2 memory controller (mctrl_avnet). This is
  because the address bus is work based rather than byte based
  and needs to be shifted 2 steps. It is possible to start
  grmon with -normw for better performance. The byte-enable
  strobes for the sram are connected and read-modify-write
  is not needed.

* The Avnet flash/sram/sdram mezzanine (ADS-FLASH-DAU-G) is 
  supported. It provides 16 Mbyte flash and 1 Mbyte additional
  sram. The sdram is attached but does not work - if somebody
  can fix this then let me know.  The FLASH memory can be 
  programmed using GRMON.

* The LEON3 processor can run up to 40 - 50 MHz on the board
  in the typical configuartion.


* Sample output from GRMON info sys is:

$ grmon -eth -u -normw

 GRMON LEON debug monitor v1.1.19b

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com


 ethernet startup.
 GRLIB build version: 2125

 initialising .............
 detected frequency:  40 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 SVGA frame buffer                    Gaisler Research
 Simple 32-bit PCI Target             Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 LEON2 Memory Controller              European Space Agency
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 Keyboard PS/2 interface              Gaisler Research
 Keyboard PS/2 interface              Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 1
02.01:063   Gaisler Research  SVGA frame buffer (ver 0x0)
             ahb master 2
             apb: 80000600 - 80000700
             clk0: 25.17 MHz
03.01:012   Gaisler Research  Simple 32-bit PCI Target (ver 0x0)
             ahb master 3
04.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 4, irq 12
             apb: 80000b00 - 80000c00
             edcl ip 192.168.0.51, buffer 2 kbyte
00.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: 40000000 - 80000000
             apb: 80000000 - 80000100
             32-bit prom @ 0x00000000
             32-bit static ram: 2 * 1024 kbyte @ 0x40000000
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 256 lines, stack pointer 0x401ffff0
             CPU#0 win 8, hwbp 2, itrace 256, V8 mul/div, lddel 1
                   icache 1 * 4 kbyte, 32 byte/line
                   dcache 1 * 4 kbyte, 32 byte/line
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38400, DSU mode
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 40
04.01:060   Gaisler Research  Keyboard PS/2 interface (ver 0x1)
             irq 4
             apb: 80000400 - 80000500
05.01:060   Gaisler Research  Keyboard PS/2 interface (ver 0x1)
             irq 5
             apb: 80000500 - 80000600
grlib> fla

 Intel-style 32-bit (2x16-bit) flash

 Manuf.    Intel               Intel
 Type      MT28F640J3          MT28F640J3

 Device ID d1210850e2c6c0c1    91210930e2c6c0c1
 User   ID ffffffffffffffff    ffffffffffffffff

 2 x 8 Mbyte = 16 Mbyte total @ 0x00000000

 CFI information

 flash family  : 1
 flash size    : 64 Mbit
 erase regions : 1
 erase blocks  : 64
 write buffer  : 32 bytes
 region  0     : 64 blocks of 128 Kbytes


grlib> lo ~/examples/soft/v8/dhry.exe
section: .text at 0x40000000, size 47568 bytes
section: .data at 0x4000b9d0, size 2408 bytes
total size: 49976 bytes (30.4 Mbit/s)
read 245 symbols
entry point: 0x40000000
grlib> run
Execution starts, 400000 runs through Dhrystone
Microseconds for one run through Dhrystone:   15.2
Dhrystones per Second:                      65573.8

Dhrystones MIPS      :                        37.3


Program exited normally.

