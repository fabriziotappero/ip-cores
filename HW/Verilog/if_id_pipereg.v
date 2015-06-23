//////////////////////////////////////////////////////////////////
//                                                              //
//  IF/ID pipeline register                                    //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Pipeline register lies between fetch and decode stages      //
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

module if_id_pipereg
#
(
  parameter N=32, /* most registers sizes */
  parameter M=5
) /* regfile address */
(
  input clk,
  input reset,
  input en,
  input [N-1:0] IR_in,
  input [N-1:0] PCplus4_in,
  input [N-1:0] PC_in,
  output [N-1:0] IR_out,

  output [N-1:0] PC_out,
  output [N-1:0] PCplus4_out
);

register IR
(
  .clk(clk), .reset(reset), .en(en),
  .d(IR_in),
  .q(IR_out)
);

register PC_4
(
  .clk(clk), .reset(reset), .en(en),
  .d(PCplus4_in),
  .q(PCplus4_out)
);

register PC
(
  .clk(clk), .reset(reset), .en(en),
  .d(PC_in),
  .q(PC_out)
);

endmodule
