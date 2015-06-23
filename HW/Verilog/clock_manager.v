//////////////////////////////////////////////////////////////////
//                                                              //
//  Clock manager for Edge core                                 //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  The clock manager depends on counter concept to output the  //
//  desired clock frequency.                                    //
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

module clock_manager
#
(
  parameter SYSCLK = 100000000, // 100 MHz for atlys board
  parameter CLK_OUT = 100000000, // desizred clock output
  parameter DIV=1,
  parameter MUL=1
)
(
  input clk_in,
  output clk_out   
);

reg[31:0] counter = 0;
reg clk_buffer = 0;

always @(posedge clk_in)
begin
  if(counter == 32'd0)
    clk_buffer = ~clk_buffer;
    
  counter = counter + 1;
  
  if (counter == (SYSCLK/CLK_OUT)/2)
    counter = 31'd0; 
end

assign clk_out = clk_buffer;

endmodule
