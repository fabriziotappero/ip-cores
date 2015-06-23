what's this?
------------
it's a simple example project for the MSP430 series MCU and the GCC port
of the mspgcc project. the project contains a makefile and uses assembler
and C sources. this time it is a software UART with Timer_A.

this example shows the following features:
 - Timer_A uart, full duplex
    o same pins as BSL (P1.1 TX, P2.2 RX)
    o it contains a reusable code

 - software FLL
   the watch crystal is used as reference and the main clock
   is adjusted to 1.536MHz on startup

 - use uprintf to print formated strings and do a printf
   emulation that prints to the serial port.

 - the main loop is a simple line editor. when a return character
   ('\r', usualy RETURN key) is received, it writes the received
   characters from the buffer to the serial port.
   connect a terminal at 9600,N,8,1 to try it out.

 - makefile
    o compile and link
    o include assembler files
    o convert to intel hex format
    o generate a listing with mixed C / assembly

required hardware
-----------------

 - a MSP430F1121 or larger device (any from the F1x series)
   connect pins P1.1 (TX) and P2.2 (RX) through level converters
   to a terminal. you can also use a BSL hardware, the same pins
   are used.
 
 - watch crystal 32.768kHz
 
 - optionaly a LED on P2.5  (470 Ohms series resistor to GND)

disclaimer
----------
this example is part of the mspgcc project http://mspgcc.sf.net
see license.txt for details.

chris