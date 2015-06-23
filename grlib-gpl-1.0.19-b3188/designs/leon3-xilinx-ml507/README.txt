
This leon3 design is tailored to the Xilinx Virtex5 ML507 board
---------------------------------------------------------------------

Design specifics:

* System reset is mapped to the CPU RESET button

* The serial port is connected to the console UART (UART 1) when
  dip switch 1 on the GPIO DIP switch is off. Otherwise it is 
  connected to the DSU UART. The DSU BREAK input is mapped
  on the 'south' push-button.

* The JTAG DSU interface is enabled and works well with
  GRMON and Xilinx parallel and USB cabels

* The GRETH core is enabled and runs without problems at 100 Mbit.
  Using 1 Gbit is also possible with the commercial grlib version.
  Ethernet debug link is enabled, default IP is 192.168.0.52.

* DDR2 is now supported and run OK at 200 MHz. The default frequency 
  is 190 MHz but it's possible to go higher. When changing frequency 
  the delay on the data signals might need to be changed too. How to 
  do this is described in the DDR2SPA section of grip.pdf (see 
  description of SDCFG3 register).

* The SSRAM can be interfaced with the LEON2 Memory controller. 
  Start GRMON with -ramrws 1 when the LEON2 controller is used.

* The FLASH memory can be programmed using GRMON

* The LEON3 processor can run up to 80 - 90 MHz on the board
  in the typical configuartion.

* The I2C master is connected to the 'Main' I2C bus. An EEPROM (M24C08)
  can be accessed at I2C address 0x50.

* TODO: DVI VGA support

* To load and run the design from Platform Flash the DIP-Switch SW3[1:8] should be
  set to 00011001.

* Sample output from GRMON is:

 GRMON LEON debug monitor v1.1.31

 Copyright (C) 2004-2008 Gaisler Research - all rights reserved.
 For latest updates, go to http://www.gaisler.com/
 Comments or bug-reports to support@gaisler.com


 using JTAG cable on parallel port
 JTAG chain: xc5vfx70t xccace xc95144xl xcf32p xcf32p

 Device ID: : 0x507
 GRLIB build version: 3060

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

grlib> inf sys
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
             edcl ip 192.168.0.52, buffer 2 kbyte
00.01:02e   Gaisler Research  DDR2 Controller (ver 0x0)
             ahb: 40000000 - 60000000
             ahb: fff00100 - fff00200
             no sdram found
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0x0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 0x1)
             ahb: 90000000 - a0000000
             AHB trace 128 lines, stack pointer 0xc00ffff0
             CPU#0 win 8, hwbp 2, itrace 128, V8 mul/div, lddel 1
                   icache 2 * 8 kbyte, 32 byte/line lrr
                   dcache 2 * 4 kbyte, 16 byte/line lrr
03.04:00f   European Space Agency  LEON2 Memory Controller (ver 0x1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: c0000000 - c2000000
             apb: 80000000 - 80000100
             16-bit prom @ 0x00000000
             32-bit static ram: 1 * 1024 kbyte @ 0xc0000000
01.01:00c   Gaisler Research  Generic APB UART (ver 0x1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38461, DSU mode (FIFO debug)
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
grlib> fla

 Intel-style 16-bit flash on D[31:16]

 Manuf.    Intel
 Device    Strataflash P30

 Device ID 1a1effff01cd4673
 User   ID ffffffffffffffff


 1 x 32 Mbyte = 32 Mbyte total @ 0x00000000


 CFI info
 flash family  : 1
 flash size    : 256 Mbit
 erase regions : 2
 erase blocks  : 259
 write buffer  : 64 bytes
 lock-down     : yes
 region  0     : 255 blocks of 128 Kbytes
 region  1     : 4 blocks of 32 Kbytes

grlib> i2c scan

Scanning 7-bit address space on I2C bus:
 Detected I2C device at address 0x2c
 Detected I2C device at address 0x50
 Detected I2C device at address 0x51
 Detected I2C device at address 0x52
 Detected I2C device at address 0x53
Scan of I2C bus completed. 5 devices found

grlib>  i2c read 0x50 0x00 10

 00:    00      01      02      03
 04:    04      05      06      07
 08:    08      09

grlib>
