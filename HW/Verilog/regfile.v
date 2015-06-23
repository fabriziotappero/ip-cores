//////////////////////////////////////////////////////////////////
//                                                              //
//  Register file for Edge core.                                //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  General purpose 32 x 32 bit register file                   //
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

module regfile
(
  clk,
  reset,
  ra1,
  ra2,
  wa3,
  we3,
  wd3,
  rd1,
  rd2
);
/* Bus size in bits for data */
parameter N = 32;
/* Bus size in bits for Addresses, the register file size should be 2**addr_size */
parameter addr_size = 5;

/* Specify IO sizes */
input wire clk;
input wire reset;
input wire[addr_size-1:0] ra1;
input wire[addr_size-1:0]ra2;
input wire[addr_size-1:0]wa3;
input wire we3;
input wire[N-1:0] wd3;
output reg[N-1:0] rd1;
output reg[N-1:0] rd2;
integer i;

/* Define register file*/
reg[N-1:0] rf [(2**addr_size)-1:0];

initial
begin
  for(i=0; i<32; i=i+1)
    rf[i] = 0;
end

always @(posedge clk)
  if (we3)
    rf[wa3] = wd3;
    
always @(negedge clk)
begin
  rd1 = (ra1 != 0)? rf[ra1]:0;
  rd2 = (ra2 != 0)? rf[ra2]:0;
end

endmodule 

