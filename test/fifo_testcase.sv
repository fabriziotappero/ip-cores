//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "fifo_testcase.sv"                                          ////
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
 Module Name : fifo_testcase.v
 Description : 
 Date        : 19/12/2011
 Author      : Madhumangal Javanthieswaran
 Email       : j.madhumangal@gmail.com
 Company     : 
 Version     : 1.0 
 Revision    : 0.0
************************************************************************/
program fifo_testcase (fifo_if.DR_MP dr_if,fifo_if.RC_MP rc_if);
  
initial
  begin
        
    fifo_top.DUV_IF.sync_reset;
    fifo_top.DUV_IF.sync_reset;
    fifo_top.DUV_IF.sync_reset;
    
    fifo_top.DUV_IF.write;
    fifo_top.DUV_IF.read;
    
    fifo_top.DUV_IF.write_read;
    
    fifo_top.DUV_IF.sync_reset;
    
    fifo_top.DUV_IF.fifo_empty;
    
    fifo_top.DUV_IF.sync_reset;
    
    fifo_top.DUV_IF.fifo_full;
    
    
    
  #100 $finish;
  end  

endprogram:fifo_testcase