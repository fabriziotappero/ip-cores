//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "fifo_top.sv"                                          ////
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
 Module Name : fifo_top.sv
 Description : 
 Date        : 19/12/2011
 Author      : Madhumangal Javanthieswaran
 Email       : j.madhumangal@gmail.com
 Company     : 
 Version     : 1.0 
 Revision    : 0.0
************************************************************************/
module fifo_top();
bit clock;

fifo_if DUV_IF(clock);

fifo RTL_IF(.clock(clock),
            .resetn(DUV_IF.resetn),
            .write_enb(DUV_IF.write_enb),
            .read_enb(DUV_IF.read_enb),
            .data_in(DUV_IF.data_in),
            .data_out(DUV_IF.data_out),
            .empty(DUV_IF.empty),
            .full(DUV_IF.full)
            );

fifo_testcase TEST_IF(DUV_IF,DUV_IF);

initial
clock = 0;

always 
  begin
    #10 clock = ~ clock;
  end

endmodule:fifo_top
