This leon3 design is tailored to the Xilinx XtremeDSP Starter Platform, Spartan-3A DSP 1800A Edition

http://www.xilinx.com/s3adspstarter

This design can not be simulated without making some small
modifications to the design. The reason for this is that the
simulation model of the DDR2 memory does not support preloading of
data and can thus not be used as main memory (at least not without
excessive simulation time for loading instructions/data into memory).

The DDR2 memory is mapped to address 0x60000000 during simulation,
instead of 0x40000000 that is used during synthesis. The reason for
this is that the DDR2 memory simulation model can not be initialized
with data. So to avoid excessive simulation times, where data has to
be written to the memory, an SDRAM is mapped to address 0x40000000
during simulation.

Synplify version 9.4 is prefered for synthesis, since earlier versions
have shown tendencies to create incorrect results.

Design specifics:

* System reset is mapped to SW5 (reset)

* DSU break is mapped to SW6 

* LED 13/14 indicates DSU UART TX and RX activity.

* LED 12 indicates processor in debug mode

* LED 11 indicates if the DLL in the DDR2 memory controller is locked
  to the system clock

* LED 7 indicates processor in error mode

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Ethernet debug link is enabled, default IP is 192.168.0.51.

* 8-bit flash prom can be read at address 0. It can be programmed
  with GRMON version 1.1.16 or later.

* DDR2 is mapped at address 0x40000000 (128 Mbyte) and is clocked
  at 125 MHz. The processor and AMBA system runs on a different
  clock, and can typically reach 40 MHz. The processor clock
  is generated from the 125 MHz clock oscillator, scaled with the
  DCM factors (7/20) in xconfig.

*  The application UART1 is connected to the male RS232 connector.

* The JTAG DSU interface is enabled.

* Output from GRMON info sys is:

grmon -eth -u

 GRMON LEON debug monitor v1.1.31

 Copyright (C) 2004-2008 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com

 Xilinx cable: Cable type/rev : 0x3
 JTAG chain: xc3sd1800a

 GRLIB build version: 3107

 initialising ............
 detected frequency:  45 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 SVGA frame buffer                    Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR2 Controller                      Gaisler Research
 LEON2 Memory Controller              European Space Agency
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
02.01:063   Gaisler Research  SVGA frame buffer (ver 0x0)
             ahb master 2
             apb: 80000600 - 80000700
             clk0: 25.00 MHz
03.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 3, irq 12
             apb: 80000f00 - 80001000
             edcl ip 192.168.0.51, buffer 2 kbyte
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 256 lines, stack pointer 0x47fffff0
             CPU#0 win 8, itrace 256, V8 mul/div, srmmu, lddel 1
                   icache 2 * 4 kbyte, 32 byte/line rnd
                   dcache 2 * 4 kbyte, 16 byte/line rnd
04.01:02e   Gaisler Research  DDR2 Controller (ver 0x0)
             ahb: 40000000 - 48000000
             ahb: fff00100 - fff00200
             32-bit DDR2 : 1 * 128 Mbyte @ 0x40000000
                          125 MHz, col 10, ref 7.8 us
05.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             apb: 80000000 - 80000100
             8-bit prom @ 0x00000000
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38527
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 45
0b.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000b00 - 80000c00
grlib>
