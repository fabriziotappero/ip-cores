
This leon3 design is tailored to the Avnet Virtex4 LX25 Evaluation board:

http://www.em.avnet.com/evk/home/0,1719,RID%253D0%2526CID%253D16863%2526CCD%253DUSA%2526SID%253D4746%2526DID%253DDF2%2526SRT%253D1%2526LID%253D0%2526PRT%253D0%2526PVW%253D%2526BID%253DDF2%2526CTP%253DEVK,00.html

Design specifics:

* System reset is mapped to SW3

* LED 0 indicates LEON3 in debug mode.

* LED 6 and 7 indicates UART RX and TX activity.

* The serial port is connected to the console UART (UART 1) when
  dip switch 1 on S1 is off. Otherwise it is connected to the
  DSU UART.

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Ethernet debug link is enabled, default IP is 192.168.0.69.

* 16-bit flash prom can be read at address 0. It can be programmed
  with GRMON version 1.1.14a or later.

* DDR is mapped at address 0x40000000 (32 Mbyte). It can run at 
  90 - 130 MHz. The processor and AMBA system runs on a different
  clock, and can typically reach 70 - 80 MHz.

* The board comes in two variations: one with an LX25 FPGA and one
  with an LX60 device. It is possible to choose the correct FPGA
  in the xconfig setup under the 'Board options' menu.

* Output from GRMON info sys is:

$ grmon -eth -u -ip 192.168.0.69 -nb

 GRMON LEON debug monitor v1.1.27b

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com


 ethernet startup.
 GRLIB build version: 2878

 initialising ............
 detected frequency:  70 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug UART                       Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 DDR266 Controller                    Gaisler Research
 LEON2 Memory Controller              European Space Agency
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 General purpose I/O port             Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:007   Gaisler Research  AHB Debug UART (ver 0x0)
             ahb master 1
             apb: 80000700 - 80000800
             baud rate 115200, ahb frequency 70.00
02.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 2
03.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 3, irq 12
             apb: 80000f00 - 80001000
             edcl ip 192.168.0.69, buffer 2 kbyte
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0x41fffff0
             CPU#0 win 8, hwbp 2, itrace 128, V8 mul/div, srmmu, lddel 1, GRFPU-lite
                   icache 2 * 16 kbyte, 32 byte/line lrr
                   dcache 2 * 16 kbyte, 32 byte/line lrr
04.01:025   Gaisler Research  DDR266 Controller (ver 0x0)
             ahb: 40000000 - 50000000
             ahb: fff00100 - fff00200
             16-bit DDR : 1 * 32 Mbyte @ 0x40000000
                          100 MHz, col 9, ref 7.8 us
05.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: 60000000 - 70000000
             apb: 80000000 - 80000100
             16-bit prom @ 0x00000000
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38400, DSU mode (FIFO debug)
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 70
0b.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000b00 - 80000c00
grlib> fla

 Intel-style 16-bit flash on D[31:16]

 Manuf.    Intel
 Device    MT28F640J3

 Device ID 1598ffff00024098
 User   ID ffffffffffffffff


 1 x 8 Mbyte = 8 Mbyte total @ 0x00000000


 CFI info
 flash family  : 1
 flash size    : 64 Mbit
 erase regions : 1
 erase blocks  : 64
 write buffer  : 32 bytes
 region  0     : 64 blocks of 128 Kbytes

grlib>                                                             
