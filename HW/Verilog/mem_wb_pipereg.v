//////////////////////////////////////////////////////////////////
//                                                              //
//  MEM/WB pipeline register                                    //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Pipeline register lies between memory and write back stages //
//                                                              //
//  Author(s):                                                  //
//      - Hesham AL-Matary, heshamelmatary@gmail.com            //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2014 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

module mem_wb_pipereg
#
(
  parameter N=32, /* most registers sizes */
  parameter M=5
) /* regfile address */
(
  input clk,
  input reset,
  input en,

  input[N-1:0] ReadData_in,
  input[N-1:0] ALUout_in,
  input[M-1:0] WriteReg_in,
  input RegWrite_in,
  input[1:0] WBResultSelect_in,
  input[2:0] BHW_in, /* byte or halfword or word ? */
  input[N-1:0] lo_in,
  input[N-1:0] hi_in,
  input[N-1:0] pcplus4_in,
  input link_in,

  /* Coprocessor0 and exceptions signals */
  input undefinedEx_in,
  input breakEx_in,
  input divbyZero_in,
  input syscallEx_in,

  input[M-1:0] CP0_wa_in,
  input[M-1:0] CP0_ra_in,
  input[1:0] CP0_Inst_in,
  input[N-1:0] CP0_dout_in,
  input[N-1:0] CP0_din_in,

  input[1:0] MemRefSize_in,

  output[N-1:0] ReadData_out,
  output[N-1:0] ALUout_out,
  output[M-1:0] WriteReg_out,
  output RegWrite_out,
  output[1:0] WBResultSelect_out,
  output[2:0] BHW_out, /* byte or halfword or word ? */
  output[N-1:0] lo_out,
  output[N-1:0] hi_out,
  output[N-1:0] pcplus4_out,
  output link_out,

  /* Coprocessor0 and exceptions signals */
  output undefinedEx_out,
  output breakEx_out,
  output divbyZero_out,
  output syscallEx_out,

  output[M-1:0] CP0_wa_out,
  output[M-1:0] CP0_ra_out,
  output[1:0] CP0_Inst_out,
  output[N-1:0] CP0_dout_out,
  output[N-1:0] CP0_din_out,

  output[1:0] MemRefSize_out
);

/* Read data from memory in case of load instruction */
register ReadData
(
  .clk(clk), .reset(reset), .en(en),
  .d(ReadData_in),
  .q(ReadData_out)
);

/* ALU output R-type */
register ALUout
(
  .clk(clk), .reset(reset), .en(en),
  .d(ALUout_in),
  .q(ALUout_out)
);

/* PC plus 4 */
register pcplus4
(
  .clk(clk), .reset(reset), .en(en),
  .d(pcplus4_in), 
  .q(pcplus4_out)
);

/* hi, lo special purpose registers */
register lo(.clk(clk), .reset(reset), .en(en), .d(lo_in), .q(lo_out));
register hi(.clk(clk), .reset(reset), .en(en), .d(hi_in), .q(hi_out));

/* Write Register Address */
register #(5) 
WriteReg
(
  .clk(clk), .reset(reset), .en(en),
  .d(WriteReg_in), 
  .q(WriteReg_out)
);

/* Control Signal */
register #(1) 
link
(
  .clk(clk), .reset(reset), .en(en),
  .d(link_in),
  .q(link_out)
);

register #(1) 
RegWrite
(
  .clk(clk), .reset(reset), .en(en),
  .d(RegWrite_in),
  .q(RegWrite_out)
);

register #(2)
WBResultSelect
(
  .clk(clk), .reset(reset), .en(en),
  .d(WBResultSelect_in), 
  .q(WBResultSelect_out)
);

register #(3) 
BHW
(
  .clk(clk), .reset(reset), .en(en), 
  .d(BHW_in),
  .q(BHW_out)
);

/* Coprocessor zero related */
register #(1) 
undefinedEx
(
  .clk(clk), .reset(reset), .en(en),
  .d(undefinedEx_in), 
  .q(undefinedEx_out)
);

register #(1)
breakEx
(
  .clk(clk), .reset(reset), .en(en),
  .d(breakEx_in),
  .q(breakEx_out)
);

register #(1)
divbyZero
(
  .clk(clk), .reset(reset), .en(en),
  .d(divbyZero_in), 
  .q(divbyZero_out)
);

register #(1)
syscallEx
(
  .clk(clk), .reset(reset), .en(en),
  .d(syscallEx_in), 
  .q(syscallEx_out)
);

register #(5)
CP0_wa
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_wa_in),
  .q(CP0_wa_out)
);

register #(5) 
CP0_ra
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_ra_in),
  .q(CP0_ra_out)
);

register #(2) 
CP0_Inst
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_Inst_in),
  .q(CP0_Inst_out)
);

register CP0_dout
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_dout_in),
  .q(CP0_dout_out)
);

register CP0_din
(
  .clk(clk), .reset(reset), .en(en),
  .d(CP0_din_in),
  .q(CP0_din_out)
);

/* Memory referece sizes */
register #(2) 
MemRefSize
(
  .clk(clk), .reset(reset), .en(en),
  .d(MemRefSize_in), 
  .q(MemRefSize_out)
);

endmodule
