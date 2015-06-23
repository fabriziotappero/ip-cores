
This leon3 design is tailored to the Xilinx Virtex5 ML501 board
---------------------------------------------------------------------

Design specifics:

* System reset is mapped to the CPU RESET button. When programming
  the FPGA only, the CPU RESET button must be pressed once before
  connecting grmon to reset the DCM clock generators.

* The serial port is connected to the console UART (UART 1) when
  dip switch 1 on the GPIO DIP switch is off. Otherwise it is 
  connected to the DSU UART. The DSU BREAK input is mapped
  on the 'south' push-button.

* The JTAG DSU interface is enabled and works well with
  GRMON and Xilinx parallel cabel III or IV .

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Using 1 Gbit is also possible with the commercial grlib version.
  Ethernet debug link is enabled, default IP is 192.168.0.53.

* DDR2 is supported. The default frequency is 140 MHz but it's
  possible to go higher. When changing frequency the delay on the
  data signals might need to be changed too. How to do this is
  described in the DDR2SPA section of grip.pdf (see description of
  SDCFG3 register).

* The SSRAM can be interfaced with the LEON2 Memory controller. 
  Start GRMON with -ramrws 1 when the LEON2 controller is used.

* The FLASH memory can be accessed and programmed through grmon

* The LEON3 processor can run up to 80 - 90 MHz on the board
  in the typical configuartion.

* The I2C master is connected to the 'Main' I2C bus. An EEPROM (M24C08)
  can be accessed at I2C address 0x50.

* TODO: DVI VGA support

* Sample output from GRMON is:

GRMON LEON debug monitor v1.1.23b

 Copyright (C) 2004,2005 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com


 using JTAG cable on parallel port
 JTAG chain: xc5vlx50 xccace xc95144xl xcf32p

 Device ID: : 0x501
 GRLIB build version: 2564

 initialising ................
 detected frequency:  80 MHz

 Component                            Vendor
 LEON3 SPARC V8 Processor             Gaisler Research
 AHB Debug UART                       Gaisler Research
 AHB Debug JTAG TAP                   Gaisler Research
 GR Ethernet MAC                      Gaisler Research
 DDR2 Controller                      Gaisler Research
 AHB/APB Bridge                       Gaisler Research
 LEON3 Debug Support Unit             Gaisler Research
 LEON2 Memory Controller              European Space Agency
 Generic APB UART                     Gaisler Research
 Multi-processor Interrupt Ctrl       Gaisler Research
 Modular Timer Unit                   Gaisler Research
 Keyboard PS/2 interface              Gaisler Research
 Keyboard PS/2 interface              Gaisler Research
 General purpose I/O port             Gaisler Research
 AMBA Wrapper for OC I2C-master       Gaisler Research
 AHB status register                  Gaisler Research

 Use command 'info sys' to print a detailed report of attached cores

grlib> info sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0x0)
             ahb master 0
01.01:007   Gaisler Research  AHB Debug UART (ver 0x0)
             ahb master 1
             apb: 80000700 - 80000800
             baud rate 115200, ahb frequency 80.00
02.01:01c   Gaisler Research  AHB Debug JTAG TAP (ver 0x0)
             ahb master 2
03.01:01d   Gaisler Research  GR Ethernet MAC (ver 0x0)
             ahb master 3, irq 12
             apb: 80000b00 - 80000c00
             edcl ip 192.168.0.53, buffer 2 kbyte
00.01:02e   Gaisler Research  DDR2 Controller (ver 0x0)
            ahb: 40000000 - 60000000
            ahb: fff00100 - fff00200
            64-bit DDR2 : 1 * 256 Mbyte @ 0x40000000
                         140 MHz, col 11, ref 7.8 us
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0x00000000
             CPU#0 win 8, hwbp 2, itrace 128, V8 mul/div, srmmu, lddel 1
                   icache 2 * 8 kbyte, 32 byte/line lru
                   dcache 1 * 8 kbyte, 16 byte/line lru
03.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: c0000000 - c2000000
             apb: 80000000 - 80000100
             16-bit prom @ 0x00000000
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38400
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 0x3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0x0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 80
04.01:060   Gaisler Research  Keyboard PS/2 interface (ver 0x1)
             irq 4
             apb: 80000400 - 80000500
05.01:060   Gaisler Research  Keyboard PS/2 interface (ver 0x1)
             irq 5
             apb: 80000500 - 80000600
08.01:01a   Gaisler Research  General purpose I/O port (ver 0x0)
             apb: 80000800 - 80000900
0c.01:028   Gaisler Research  AMBA Wrapper for OC I2C-master (ver 0x0)
             irq 11
             apb: 80000c00 - 80000d00
0f.01:052   Gaisler Research  AHB status register (ver 0x0)
             irq 7
             apb: 80000f00 - 80001000
grlib>
