//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_defines.v                                          ////
////                                                              ////
////  Description                                                 ////
////  Bunch of defines used in this core                          ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

`ifndef SYS_CLOCK_HZ
`define SYS_CLOCK_HZ 100_000_000
`endif

`define T_100_MICROSECONDS (`SYS_CLOCK_HZ / 10_000)
`define T_200_MICROSECONDS (`SYS_CLOCK_HZ /  5_000)
// Ideally below define should be $clog2(`T_100_MICROSECONDS + 1)
`define T_100_MICROSECONDS_SIZE 14
// ... and same here $clog2(`T_200_MICROSECONDS + 1)
`define T_200_MICROSECONDS_SIZE 15
