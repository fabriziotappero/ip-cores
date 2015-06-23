//////////////////////////////////////////////////////////////////////
////                                                              ////
//// oc_fifo_basic.v                                              ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// One Clock FIFO                                               ////
////                                                              ////
//// 2 Parameters: Address Width, Data Width                      ////
////   Data storage is internally inferred.                       ////
////   Protected against read-while-empty and write-while-full.   ////
////   When empty, force data output to zero.                     ////
////                                                              ////
////   The minimum address width (AW) is 2.                       ////
////                                                              ////
//// To Do:                                                       ////
////   Verify in silicon.                                         ////
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
// $Id: oc_fifo_basic.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module oc_fifo_basic( /*AUTOARG*/
// Outputs
have, take_do, need, 
// Inputs
rst_i, clk_i, take, give, give_di
);

parameter AW=3;    // default address width
parameter DW=8;    // default data width

input            rst_i;
input            clk_i;

output           have;
input            take;
output [DW-1:0]  take_do;

output           need;
input            give;
input  [DW-1:0]  give_di;

reg  [AW  :0]    rp;
reg  [AW  :0]    wp;
wire [AW  :0]    rp_add1 = rp + 1'b1;
wire [AW  :0]    wp_add1 = wp + 1'b1;

reg              full;
reg              emty;

wire             have = ~emty;
wire             need = ~full;

reg  [DW-1:0]    mem [0:(1<<AW)-1];

wire [DW-1:0]    take_do = {DW{have}} & mem[ rp[AW-1:0] ]; // take data

always @( posedge clk_i )
        if( give & ~full ) mem[ wp[AW-1:0] ] <= give_di;   // give data

always @( posedge clk_i or posedge rst_i )
if( rst_i )
begin
      wp    <= {AW+1{1'b0}};
      rp    <= {AW+1{1'b0}};
      emty  <= 1'b1;
      full  <= 1'b0;
end
else
begin
     if( give & ~full ) wp <= wp_add1; // increment write pointer
     if( take & ~emty ) rp <= rp_add1; // increment read  pointer

     casex( { give,take, full,emty } )

     // write an entry; no longer empty; might go full

     4'b10_0X: begin  // is give, no take, no full
               full  <= ( wp_add1[AW-1:0] == rp[AW-1:0] ) & ( wp_add1[AW] != rp[AW] );
               emty  <= 1'b0;
               end

     // read  an entry; no longer full ; might go empty

     4'b01_X0: begin  // is take, no give, no emty
               full  <= 1'b0;
               emty  <= ( rp_add1 == wp );
               end

     // take & give while full ; take wins, give loses; no longer full...

     4'b11_10: full  <= 1'b0; // is take, is give, is full, no emty

     // take & give while empty; give wins, take loses; no longer empty...

     4'b11_01: emty  <= 1'b0; // is take, is give, no full, is emty

     default: ;

     endcase

end
endmodule
