//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "fifo.v"                                          ////
////                                                              ////
////  This file is part of the "synchronous_reset_fifo" project   ////
//// http://opencores.com/project,synchronous_reset_fifo          ////
////                                                              ////
////  Author:                                                     ////
////     - Madhumangal Javanthieswaran (madhu54321@opencores.org) ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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

/************************************************************************
 Design Name : synchronous_reset_fifo
 Module Name : fifo.v
 Description : 
 Date        : 19/12/2011
 Author      : Madhumangal Javanthieswaran
 Email       : j.madhumangal@gmail.com
 Company     : 
 Version     : 1.0 
 Revision    : 0.0
************************************************************************/
//Fifo size definitions

//Fifo Module
module fifo(clock,write_enb,read_enb,data_in,data_out,empty,full,resetn);

parameter WIDTH = 8;
parameter DEPTH = 16;
parameter POINTER_SIZE = 5;

//Inputs
input clock;
input resetn;    
input write_enb;
input read_enb; 
input [WIDTH-1:0] data_in;  
               
//Outputs
output [WIDTH-1:0] data_out; 
output empty;    
output full;     

//Wires and Internal Registers
wire empty;    
wire full;     
reg [WIDTH-1:0] memory [0:DEPTH-1]; 
reg [POINTER_SIZE-1:0] write_ptr; 
reg [POINTER_SIZE-1:0] read_ptr; 
reg [WIDTH-1:0] data_out;


//Asynchronous Logic
//FIFO full and empty logic

assign empty = ((write_ptr - read_ptr)== 5'b00000) ? 1'b1 : 1'b0;
assign full  = ((write_ptr - read_ptr) == 5'b10000) ? 1'b1 : 1'b0; 

//Synchronous Logic
//FIFO write and read logic 
always@(posedge clock) 
begin 
	if (resetn == 1'b0) 
   begin
   write_ptr <= 5'b00000;
   read_ptr  <= 5'b00000;
   data_out <= 8'b00000000;
   end 
  
  else 
//Simultaneous Read and Write
   begin
   if ((write_enb == 1'b1) &&  (full == 1'b0)) 
    begin
    memory[write_ptr] <= data_in;
    write_ptr <= write_ptr + 1;
    end 
   end
   begin
   if ((read_enb == 1'b1) &&  (empty == 1'b0)) 
    begin
    data_out <= memory[read_ptr];
    read_ptr <= read_ptr + 1;
    end
   end 
end
endmodule 
