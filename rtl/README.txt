//////////////////////////////////////////////////////////////////////
////                                                              ////
////  README.txt                                                  ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in this README.txt  ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000,2001 Authors                              ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
// Revision 1.2  2001/06/01 22:22:35  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.1  2001/05/18 13:12:09  mohor
// Header changed. All additional information is now avaliable in this README.txt file.
//
//



PROJECT: 
SoC/OpenRISC Development (debug) Interface


PROJECT AND DOCUMENTATION ON THE WEB:

The project that this files are part of is avaliable on the opencores
web page: 

http://www.opencores.org/cores/DebugInterface/

Documentation can also be found there. For direct download of the
documentation go to:

http://www.opencores.org/cgi-bin/cvsget.cgi/dbg_interface/doc/DbgSupp.pdf




OVERVIEW (main Features):
                                   
Development Interface is used for development purposes      
(Boundary Scan testing and debugging). It is an interface   
between the RISC, peripheral cores and any commercial       
debugger/emulator or BS testing device. The external        
debugger or BS tester connects to the core via JTAG port.   
The Development Port also contains a trace and support for  
tracing the program flow, execution coverage and profiling  
the code. 

dbg_tb.v is a testbench file.
file_communication.v is used for simulating the whole design together with the 
  debugger through two files that make a JTAG interface
dbg_top.v is top level module of the development interface design



COMPATIBILITY:

- WISHBONE rev B.1
- IEEE 1149.1 (JTAG)



KNOWN PROBLEMS (limits):
- RISC changes Watchpoints and breakpoints on rising edge of the
Mclk clock signal. Simulation should do the same.



TO DO:
- Add a WISHBONE master support if needed
- Add support for boundary scan (This is already done, but not yet incorporated in the design)

