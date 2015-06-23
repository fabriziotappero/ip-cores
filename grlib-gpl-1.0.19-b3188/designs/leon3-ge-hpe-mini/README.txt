
This leon3 design is tailored to the HPE_mini board from
Gleichmann Electronics:

http://www.ger-fae.com/Hpe_mini_ac2.html

The default configuartion (and pre-compiled bit files) contains
a leon3 configuration with SDRAM controller and Ethernet DSU.
The IP address for the ethernet DSU is 192.168.0.68 . The
'info sys' command in grmon returns the following report:

grlib> inf sys
00.01:003   Gaisler Research  LEON3 SPARC V8 Processor (ver 0)
             ahb master 0
01.01:007   Gaisler Research  AHB Debug UART (ver 0)
             ahb master 1
             apb: 80000700 - 80000800
             baud rate 115200, ahb frequency 25.00
02.01:01d   Gaisler Research  GR Ethernet MAC (ver 0)
             ahb master 2, irq 12
             apb: 80000f00 - 80001000
             edcl ip 192.168.0.68, buffer 2 kbyte
00.04:00f   European Space Agency  LEON2 Memory Controller (ver 1)
             ahb: 00000000 - 20000000
             ahb: 20000000 - 40000000
             ahb: 40000000 - 80000000
             apb: 80000000 - 80000100
             32-bit prom @ 0x00000000
             32-bit sdram: 1 * 128 Mbyte @ 0x40000000, col 10, cas 2, ref 7.7 us
01.01:006   Gaisler Research  AHB/APB Bridge (ver 0)
             ahb: 80000000 - 80100000
02.01:004   Gaisler Research  LEON3 Debug Support Unit (ver 1)
             ahb: 90000000 - a0000000
             AHB trace 64 lines, stack pointer 0x47fffff0
             CPU#0 win 8, itrace 64, V8 mul/div, srmmu, lddel 1
                   icache 1 * 4 kbyte, 32 byte/line
                   dcache 1 * 4 kbyte, 32 byte/line
04.10:003   Gleichmann Electronics  Sigma delta DAC (ver 0)
             ahb: fff01000 - fff01100
07.10:004   Gleichmann Electronics  Unknown device (ver 1)
             irq 5
             ahb: fff24000 - fff24100
             ahb: fff34000 - fff34100
01.01:00c   Gaisler Research  Generic APB UART (ver 1)
             irq 2
             apb: 80000100 - 80000200
             baud rate 38400, DSU mode
02.01:00d   Gaisler Research  Multi-processor Interrupt Ctrl (ver 3)
             apb: 80000200 - 80000300
03.01:011   Gaisler Research  Modular Timer Unit (ver 0)
             irq 8
             apb: 80000300 - 80000400
             8-bit scaler, 2 * 32-bit timers, divisor 25
05.01:061   Gaisler Research  Text-based video controller (ver 0)
             apb: 80000600 - 80000700


