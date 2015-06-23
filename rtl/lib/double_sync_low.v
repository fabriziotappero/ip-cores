//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//----------------------------------------------------------------------------
// Simple Double sync logic with Reset value = 1
// This double signal should be used for signal transiting from low to high
//----------------------------------------------------------------------------

module double_sync_low   (
              in_data    ,
              out_clk    ,
              out_rst_n  ,
              out_data   
          );

parameter WIDTH = 1;

input [WIDTH-1:0]    in_data    ; // Input from Different clock domain
input                out_clk    ; // Output clock
input                out_rst_n  ; // Active low Reset
output[WIDTH-1:0]    out_data   ; // Output Data


reg [WIDTH-1:0]     in_data_s  ; // One   Cycle sync 
reg [WIDTH-1:0]     in_data_2s ; // two   Cycle sync 
reg [WIDTH-1:0]     in_data_3s ; // three Cycle sync 

assign out_data =  in_data_3s;

always @(negedge out_rst_n or posedge out_clk)
begin
   if(out_rst_n == 1'b0)
   begin
      in_data_s  <= {WIDTH{1'b1}};
      in_data_2s <= {WIDTH{1'b1}};
      in_data_3s <= {WIDTH{1'b1}};
   end
   else
   begin
      in_data_s  <= in_data;
      in_data_2s <= in_data_s;
      in_data_3s <= in_data_2s;
   end
end


endmodule
