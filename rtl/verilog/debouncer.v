//////////////////////////////////////////////////////////////////////
////                                                              ////
//// debouncer.v                                                  ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
//// Debounce a mechanical switch or contact.                     ////
////                                                              ////
//// To Do:                                                       ////
//// Verify in silicon.                                           ////
////                                                              ////
//// Author(s):                                                   ////
//// - Shannon Hill                                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Shannon Hill and OPENCORES.ORG            ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: debouncer.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module debouncer( /*AUTOARG*/
// Outputs
button_o, 
// Inputs
rst_i, clk_i, button_i
);

parameter CW = 8;

input        rst_i;
input        clk_i;     // 1us period for a (1<<CW)us debounce interval
input        button_i;
output       button_o;

reg          button_1;
reg          button_2;
reg [CW-1:0] count;
reg          button_o;

wire         changed  =   button_2 ^ button_o;

always @( posedge clk_i or posedge rst_i )
if( rst_i )
begin
          button_1 <= 1'b0;
          button_2 <= 1'b0;
          count    <= {CW{1'b0}};
          button_o <= 1'b0;
end
else
begin
          button_1 <= button_i;       // async input
          button_2 <= button_1;

          count    <= count + 1'b1;

 casex( { changed, &count } )

  2'b0x:  count    <= {CW{1'b0}};    // output == input; reset counter

  2'b10: ;                           // output != input; wait for debounce timeout...

  2'b11:  button_o <= button_2;      // copy input to output

 default: ;
 endcase

end

endmodule




