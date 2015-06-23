
This leon3 design is tailored to the Digilent Spartan3-1600E Evaluation board:

http://www.digilentinc.com/Products/Detail.cfm?Prod=S3E1600&Nav1=Products&Nav2=Programmable

Design specifics:

* System reset is mapped to SW_SOUTH (reset)

* DSU break is mapped to SW_EAST 

* LED 0/1 indicates console UART RX and TX activity.

* LED 2/3 indicates DSU UART RX and TX activity.

* LED 4 indicates processor in debug mode

* LED 7 indicates processor in error mode

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Ethernet debug link is enabled, default IP is 192.168.0.51.

* 16-bit flash prom can be read at address 0. It can be programmed
  with GRMON version 1.1.16 or later.

* DDR is mapped at address 0x40000000 (64 Mbyte) and is clocked
  at 100 MHz. The processor and AMBA system runs on a different
  clock, and can typically reach 40 MHz. The processor clock
  is generated from the 50 MHz clock oscillator, scaled with the
  DCM factors (4/5) in xconfig.

* The APBPS2 PS/2 core is attached to the PS/2 connector

* The SVGA frame buffer runs fine with 800x600 resolution. Due to the
  limited number of clock buffers, no other resoltion is supported.
  Note that the board does not have a video DAC, so only the MSB bit (7)
  of the three colour channels is connected to the VGA connector.

  A test patter can be generated using grmon-1.1.18 or later with:

  draw test_screen 800 16

* The DSU uart is connected to the female RS232 connected. 
  The application UART1 is connected to the male RS232 connector.

* The JTAG DSU interface is enabled.

* Output from GRMON info sys is:

grmon -u

 GRMON LEON debug monitor v1.1.19a

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com


 ethernet startup.
 initialising ..............
 detected frequency:  40 MHz
 GRLIB build version: 2075

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug UART                       Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 SVGA frame buffer                    Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR266 Controller                    Gaisler Research
 LEON2 Memory Controller              European Space Agency
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 Keyboard PS/2 interface              Gaisler Research
 General purpose I/O port             Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:007   Gaisler Research  AHB Debug UART (ver 0x0)
             ahb master 1
             apb: 80000700 - 80000800
             baud rate 115200, ahb frequency 40.00
02.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 2
03.01:063   Gaisler Research  SVGA frame buffer (ver 0x0)
             ahb master 3
             apb: 80000600 - 80000700
             clk0: 40.00 MHz  
04.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 4, irq 12
             apb: 80000f00 - 80001000
             edcl ip 192.168.0.51, buffer 2 kbyte
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0x43fffff0
             CPU#0 win 8, itrace 128, V8 mul/div, srmmu, lddel 1, GRFPU-lite
                   icache 2 * 4 kbyte, 32 byte/line lrr
                   dcache 2 * 4 kbyte, 16 byte/line lrr
04.01:025   Gaisler Research  DDR266 Controller (ver 0x0)
             ahb: 40000000 - 50000000
             ahb: fff00100 - fff00200
             16-bit DDR : 1 * 64 Mbyte @ 0x40000000
                          100 MHz, col 10, ref 7.8 us
05.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: 60000000 - 70000000
             apb: 80000000 - 80000100
             16-bit prom @ 0x00000000
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
05.01:060   Gaisler Research  Keyboard PS/2 interface (ver 0x1)
             irq 5
             apb: 80000500 - 80000600
0b.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000b00 - 80000c00
grlib> 

