AVR core + peripheral modules project version 14 (preliminary).
What's new?

1.Project was converted to Verilog,

2. USART module compatible with one used in XMEGA uC was added.
(only UART mode is supported + automatic flow control using RTS/CTS pins is added + internal loopback).

3.SMBUS(TWI) module is added (in SLAVE mode it is compatible with one used).

4.Modules which were designed/modified(USART, parallel port) lately supports both Data memory and I/O locations.   

5.The core supports all the standard instructions including (multiplications, MOVW, ...). 
  The only instruction which is not implemented for the moment is SPM (stores data in the PM) since 
  the hardware for its implementation depends very much on the type/interface/... of the used 
  memory (especially if for example FLASH IP is used for the design).
   
6.The new interconnect module is provided to simplify interfacing with both DM and I/O located peripheral modules.

7.Simple bridge for Wishbone bus was added.
