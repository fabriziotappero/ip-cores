//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MESI_ISC Project                                            ////
////                                                              ////
////  Author(s):                                                  ////
////      - Yair Amitay       yair.amitay@yahoo.com               ////
////                          www.linkedin.com/in/yairamitay      ////
////                                                              ////
////  Description                                                 ////
////  mesi_isc_tb_define                                          ////
////  -------------------                                         ////
////  Contains the timescale and the define declaration of the    ////
////  block tb                                                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//`define messages

`define mesi_isc_debug

// CPU instructions
`define MESI_ISC_TB_INS_NOP 4'd0
`define MESI_ISC_TB_INS_WR  4'd1
`define MESI_ISC_TB_INS_RD  4'd2

`define MESI_ISC_TB_CPU_M_STATE_IDLE        0
`define MESI_ISC_TB_CPU_M_STATE_WR_CACHE    1
`define MESI_ISC_TB_CPU_M_STATE_RD_CACHE    2
`define MESI_ISC_TB_CPU_M_STATE_SEND_WR_BR  3
`define MESI_ISC_TB_CPU_M_STATE_SEND_RD_BR  4

`define MESI_ISC_TB_CPU_C_STATE_IDLE        0
`define MESI_ISC_TB_CPU_C_STATE_WR_SNOOP    1
`define MESI_ISC_TB_CPU_C_STATE_RD_SNOOP    2
`define MESI_ISC_TB_CPU_C_STATE_EVICT_INVALIDATE 3
`define MESI_ISC_TB_CPU_C_STATE_EVICT       4
`define MESI_ISC_TB_CPU_C_STATE_RD_LINE_WR  5
`define MESI_ISC_TB_CPU_C_STATE_RD_LINE_RD  6
`define MESI_ISC_TB_CPU_C_STATE_RD_CACHE    7
`define MESI_ISC_TB_CPU_C_STATE_WR_CACHE    8


`define MESI_ISC_TB_CPU_MESI_M              4'b1001
`define MESI_ISC_TB_CPU_MESI_E              4'b0101
`define MESI_ISC_TB_CPU_MESI_S              4'b0011
`define MESI_ISC_TB_CPU_MESI_I              4'b0000
