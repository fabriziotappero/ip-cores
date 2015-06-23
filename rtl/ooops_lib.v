
//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs common module library                                 //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Basic library of common blocks such as different types of   //
//  flops, etc...                                               //
//                                                              //
//  Author(s):                                                  //
//      - Joshua Smith, smjoshua@umich.edu                      //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2012 Authors and OPENCORES.ORG                 //
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
`include "ooops_defs.v"

// Regular DFF
module MDFF #(parameter DW = 1) (
  input wire          clk,
  input wire [DW-1:0] din,
  output reg [DW-1:0] dout
  );

  always @(posedge clk)
    dout <= `SD din;

endmodule

// Loadable DFF
module MDFFL #(parameter DW = 1) (
  input wire          clk,
  input wire          ld,
  input wire [DW-1:0] din,
  output reg [DW-1:0] dout
  );

  always @(posedge clk)
    if (ld) dout <= `SD din;

endmodule

// Resetable DFF
module MDFFR #(parameter DW = 1) (
  input wire          clk,
  input wire          rst,
  input wire [DW-1:0] rst_din,
  input wire [DW-1:0] din,
  output reg [DW-1:0] dout
  );

  always @(posedge clk)
    if (rst)  dout <= `SD rst_din;
    else      dout <= `SD din;

endmodule

// Loadable, resetable DFF
module MDFFLR #(parameter DW = 1) (
  input wire          clk,
  input wire          rst,
  input wire          ld,
  input wire [DW-1:0] rst_din,
  input wire [DW-1:0] din,
  output reg [DW-1:0] dout
  );

  always @(posedge clk)
    if (rst)      dout <= `SD rst_din;
    else if (ld)  dout <= `SD din;

endmodule
