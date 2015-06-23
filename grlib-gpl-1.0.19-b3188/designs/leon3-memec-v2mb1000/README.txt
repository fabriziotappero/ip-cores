
This leon3 design is tailored to the MEMEC V2MB1000 board

Design specifics:

* DSU BREAK is mapped to puch button 1

* LED indicates LEON3 in debug mode.

* The serial port on main board is connected to the DSU UART.

* The console UART (UART1) is maaped on the P160 module port

* The GRETH core is mapped on the PHY on P160. Due to the
  small size of the FPGA (XC2V1000), it does not fit when
  the processor is enabled

* DDR is mapped at address 0x40000000 (32 Mbyte). 

* PROM is mapped at address 0, the SRAM on 0x60000000


NOTE: this design has not been tested on real hardware, please
report success or failure ot jiri@gaisler.com.

Jiri.

