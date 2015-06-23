
This leon3 design is tailored to the Digilent Virtex2-Pro XUP board

Design specifics:

* System reset is mapped to the RESET/RELOAD button

* LED 0 indicates LEON3 in debug mode.

* LED 1 indicates LEON3 in error mode.

* LED 2 and 3 indicates UART RX and TX activity.

* The serial port is connected to the console UART (UART 1) when
  dip switch 0 on SW7 is on. Otherwise it is connected to the
  DSU UART.

* The JTAG DSU interface is enabled and works well with
  GRMON and Xilinx parallel cabel III or IV . The on-board
  USB connection can also be used if grmon is started with
  -xilusb, but is very slow. Cable drivers from ISE-9.2 or later
  are necessary.

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Ethernet debug link is enabled, default IP is 192.168.0.51.

* DDR is mapped at address 0x40000000. Any DDR DIMM between
  128 - 1024 Mbyte can be used. Note that the DIMM must
  support CL=2 and run on 2.5 V. The DDR frequency should
  be set to 90 - 120 MHz.  The processor and AMBA system 
  runs on a different clock, and can typically reach 60 - 70 MHz.

* IMPORTANT : If you download a new bitfile to the FPGA, make sure you
  press the reset button shortly to reset the clock DLLs. Otherwise
  the design will NOT work.

* The XUP board has no flash prom. To boot the system during
  simultion, an on-chip AHBROM core is used. The AHBROM is 
  filled with the contents of prom.exe. It and can be re-built with:

	make soft
	rm ahbrom.vhd
	make ahbrom.vhd
	make vsim


* Typical output from GRMON info sys is:

 using JTAG cable on parallel port
 JTAG chain: xc2vp30 xccace xcf32p

 initialising ...........
 detected frequency:  70 MHz
 GRLIB build version: 1888

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug UART                       Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 AHB ROM                              Gaisler Research
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR266 Controller                    Gaisler Research
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0)
             ahb master 0
01.01:007   Gaisler Research  AHB Debug UART (ver 0)
             ahb master 1
             apb: 80000700 - 80000800
             baud rate 115200, ahb frequency 70.00
02.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0)
             ahb master 2
03.01:01d   Gaisler Research  GR Ethernet MAC (ver 0)
             ahb master 3, irq 12
             apb: 80000b00 - 80000c00
             edcl ip 192.168.0.64, buffer 2 kbyte
00.01:01b   Gaisler Research  AHB ROM (ver 0)
             ahb: 00000000 - 00100000
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0x4ffffff0
             CPU#0 win 8, hwbp 2, itrace 128, V8 mul/div, srmmu, lddel 1
                   icache 2 * 8 kbyte, 32 byte/line lrr
                   dcache 2 * 8 kbyte, 32 byte/line lrr
03.01:025   Gaisler Research  DDR266 Controller (ver 0)
             ahb: 40000000 - 80000000
             ahb: fff00100 - fff00200
             64-bit DDR : 1 * 256 Mbyte @ 0x40000000
                          120 MHz, col 10, ref 7.8 us
01.01:00c   Gaisler Research  Generic APB UART (ver 1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38400, DSU mode
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 70

