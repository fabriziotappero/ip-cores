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
  i2c_to_wb_config
  (
    input   [7:0]       i2c_byte_in,
    input               tip_addr_ack,
    output              i2c_ack_out,
    
    input               wb_clk_i,
    input               wb_rst_i  
  );

  
  // --------------------------------------------------------------------
  //  address decoder  
  reg i2c_addr_ack_out_r;
  
  always @(*)
    casez( i2c_byte_in )
      8'b1111_000?: i2c_addr_ack_out_r = 1'b0;
      default:      i2c_addr_ack_out_r = 1'b1;
    endcase
    
    
  // --------------------------------------------------------------------
  //  outputs  
  assign i2c_ack_out = tip_addr_ack ? i2c_addr_ack_out_r : 1'b0;
//   assign i2c_ack_out = 1'b0;
  
    
endmodule

