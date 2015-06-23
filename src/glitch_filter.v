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


`include "timescale.v"


module
  glitch_filter
  #(
    parameter SIZE = 3
  ) 
  (
    input in,
    output reg out,
    
    output rise,
    output fall,
    
    input clk,
    input rst  
  );
  
  
  // --------------------------------------------------------------------
  //  in sync flop
  reg in_reg;
  always @(posedge clk)
    in_reg <= in;


  // --------------------------------------------------------------------
  //  glitch filter
  reg [(SIZE-1):0] buffer;
  always @(posedge clk)
    buffer <= { buffer[(SIZE-2):0], in_reg };
    
  wire all_hi = &{in_reg, buffer};
  wire all_lo = ~|{in_reg, buffer};
  
  wire out_en = (all_hi & in_reg) | (all_lo & ~in_reg);
  
  always @(posedge clk)
    if( out_en )
      out <= buffer[(SIZE-1)];


  // --------------------------------------------------------------------
  //  outputs  
  assign fall = all_lo & out;
  assign rise = all_hi & ~out;

  
endmodule

