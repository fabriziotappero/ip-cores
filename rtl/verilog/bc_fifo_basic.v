//////////////////////////////////////////////////////////////////////
////                                                              ////
//// bc_fifo_basic.v                                              ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// Asynchronous Boundary Crossing FIFO                          ////
////                                                              ////
//// 2 Parameters: Address Width, Data Width                      ////
////   Data storage is internally inferred.                       ////
////   Protected against read-while-empty and write-while-full    ////
////   The minimum address width (AW) is 2.                       ////
////                                                              ////
//// To Do:                                                       ////
//// Verify in silicon.                                           ////
////                                                              ////
//// Author(s):                                                   ////
//// - Shannon Hill                                               ////
////   (based on the generic_fifo_dc_gray design from             ////
////    Rudolf Usselmann.  This variant infers its own            ////
////    data storage, defends itself against write-while-full     ////
////    and read-while-empty, and forces its output data to 0     ////
////    when empty.)                                              ////
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
// $Id: bc_fifo_basic.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module bc_fifo_basic( /*AUTOARG*/
// Outputs
get_do, get_have, put_need, 
// Inputs
put_rst_i, get_rst_i, get_clk_i, get, put_clk_i, put_di, put
);

parameter AW=3;  // default address width
parameter DW=8;  // default data width

input            put_rst_i;       // async reset from the put_clk_i domain
input            get_rst_i;       // async reset from the get_clk_i domain

input            get_clk_i;
output [DW-1:0]  get_do;
input            get;
output           get_have;        // fifo has 1 or more

input            put_clk_i;
input  [DW-1:0]  put_di;
input            put;
output           put_need;        // fifo has room for 1 more

reg  [AW  :0]    rp_bin;
reg  [AW  :0]    rp_gra;
reg  [AW  :0]    rp_gra_sync;

reg  [AW  :0]    wp_bin;
reg  [AW  :0]    wp_gra;
reg  [AW  :0]    wp_gra_sync;

reg              put_full;
reg              get_emty;

wire             get_have = ~get_emty;
wire             put_need = ~put_full;

reg  [DW-1:0]    mem [0:(1<<AW)-1];    // fifo data

wire [DW-1:0]    get_do = {DW{get_have}} & mem[ rp_bin[AW-1:0] ]; // output data

//////////////////////////

function [AW:0] bin_to_gray;
input [AW:0] b;
begin
 bin_to_gray = b ^ (b>>1);
end
endfunction

//////////////////////////

function [AW:0] gray_to_bin;
input [AW:0] g;
reg   [AW:0] b;
integer      i;
begin
 for( i=0; i<=AW; i=i+1 ) b[i] = ^(g>>i);
 gray_to_bin = b;
end
endfunction

////////////////////////////
// in the get_clk_i domain
////////////////////////////

wire [AW  :0] rp_bin_add1 = rp_bin + 1'd1;
wire [AW  :0] rp_gra_add1 = bin_to_gray( rp_bin_add1 );
//
// get the gray-coded write pointer over to the get_clk_i domain
//
always @( posedge get_clk_i or posedge get_rst_i ) // put_clk_i to get_clk_i boundary crossing
if( get_rst_i )
      wp_gra_sync  <= 0;
else  wp_gra_sync  <= wp_gra;

//
// convert the sampled graycode read pointer to binary
//
// wire [AW  :0] wp_bin_sync = gray_to_bin( wp_gra_sync );

// compare the write pointer and read pointer
//
// set  empty when: getting AND the next read pointer == the current write pointer
// hold empty when: read pointer == write pointer
// clr  empty when: read pointer no longer equal to write pointer
//
always @( posedge get_clk_i or posedge get_rst_i )
if( get_rst_i )
begin
     rp_bin   <= 0;
     rp_gra   <= 0;
     get_emty <= 1'b1;
end
else
begin

     get_emty <=       ( rp_gra      == wp_gra_sync )  |
   ( get & ~get_emty & ( rp_gra_add1 == wp_gra_sync ) );

 if( get & ~get_emty )
  begin
     rp_bin   <= rp_bin_add1;
     rp_gra   <= rp_gra_add1;
  end
end

////////////////////////////////
// over in the put_clk_i domain
////////////////////////////////

wire [AW  :0] wp_bin_add1 = wp_bin + 1'd1;
wire [AW  :0] wp_gra_add1 = bin_to_gray( wp_bin_add1 );
//
// get the gray-coded read pointer over to the put_clk_i domain
//
always @( posedge put_clk_i or posedge put_rst_i )  // get_clk_i to put_clk_i boundary crossing
if( put_rst_i )
     rp_gra_sync  <= 0;
else rp_gra_sync  <= rp_gra;
//
// convert the sampled graycode read pointer to binary
//
wire [AW  :0] rp_bin_sync = gray_to_bin( rp_gra_sync );

// compare the read pointer and write pointer
//
// set  full when: putting AND the next write pointer ==  read pointer
// hold full when: full and write pointer == read pointer
// clr  full when: write pointer no longer equal to read pointer
//
always @( posedge put_clk_i or posedge put_rst_i )
if( put_rst_i )
 begin
     wp_bin   <= 0;
     wp_gra   <= 0;
     put_full <= 1'b0;
 end
else
begin
           put_full <=
  (                   ( wp_bin[     AW-1:0] == rp_bin_sync[AW-1:0] ) & ( wp_bin[     AW] != rp_bin_sync[AW] ) ) |
  ( put & ~put_full & ( wp_bin_add1[AW-1:0] == rp_bin_sync[AW-1:0] ) & ( wp_bin_add1[AW] != rp_bin_sync[AW] ) );

if( put & ~put_full )
 begin
     wp_bin   <= wp_bin_add1;
     wp_gra   <= wp_gra_add1;
 end
end

always @( posedge put_clk_i )
if( put & ~put_full ) mem[ wp_bin[AW-1:0] ] <= put_di;  // do the data write

endmodule
