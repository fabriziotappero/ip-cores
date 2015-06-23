//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "fifo_if.sv"                                          ////
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
 Module Name : fifo_if.sv
 Description : 
 Date        : 19/12/2011
 Author      : Madhumangal Javanthieswaran
 Email       : j.madhumangal@gmail.com
 Company     : 
 Version     : 1.0 
 Revision    : 0.0
************************************************************************/
interface fifo_if(input bit clock);

//Fifo size definitions
parameter WIDTH = 8;
parameter DEPTH = 16;
parameter POINTER_SIZE = 5;


//Inputs
logic resetn;    
logic write_enb;
logic read_enb; 
logic [WIDTH-1:0] data_in;  

//Outputs
logic [WIDTH-1:0] data_out; 
logic empty;    
logic full;     

clocking dr_cb @(posedge clock);
  output resetn;
  output write_enb;
  output read_enb;
  output data_in;
endclocking

clocking rcv_cb @(posedge clock);
  input data_out;
  input empty;
  input full;
endclocking

//modport DUV_IF(input clock,resetn,write_enb,read_enb,data_in, output data_out,empty,full);

modport DR_MP(clocking dr_cb);
modport RC_MP(clocking rcv_cb);


task sync_reset;
  begin
    dr_cb.resetn <= 0;
    dr_cb.read_enb <= 0;
    dr_cb.write_enb <= 0;
    //repeat(2)
    @(dr_cb);
    repeat(2)
    @(rcv_cb);
    if(rcv_cb.data_out == 8'd0)
      $display($time,"sync_reset works");
    else
      $display($time,"sync_reset error");
  end
endtask:sync_reset

task write;
 begin
    dr_cb.resetn <= 1;
    dr_cb.write_enb <= 1;
    dr_cb.data_in <= 8'd85;
    @(dr_cb);
    $display($time,"write works");
 end
 endtask:write

task read;
  begin
    dr_cb.resetn <= 1;
    dr_cb.read_enb <= 1;
    repeat(2)
    @(rcv_cb);
    if(rcv_cb.data_out == 8'd85)
      $display($time,"read works");
    else
      $display($time,"read error");  
    //@(rcv_cb);
  end
endtask:read

 
task write_read;
  begin
    dr_cb.resetn <= 1;
    dr_cb.write_enb <= 1;
    dr_cb.data_in <= 8'd170;
    dr_cb.read_enb <= 1;
    repeat(2)
    @(dr_cb);
    repeat(2)
    @(rcv_cb);
    if(rcv_cb.data_out == 8'd170)
      $display($time,"write_read works");
    else
      $display($time,"write_read error");  
  end
endtask:write_read

task fifo_full;
  begin
    dr_cb.resetn <= 1;
    dr_cb.write_enb <= 1;
    dr_cb.read_enb <= 0;
    dr_cb.data_in <= $random;
    
    repeat(16)
    @(dr_cb);
    //repeat(16)
    @(rcv_cb);
    
    
    if(rcv_cb.full == 1)
      $display($time,"fifo_full works");
    else
      $display($time,"fifo_full error");
  end
endtask

task fifo_empty;
  begin
    dr_cb.resetn <= 1;
    dr_cb.write_enb <= 0;
    dr_cb.read_enb <= 1;
    repeat(2)
    @(dr_cb);
    if(rcv_cb.empty == 1)
      $display($time,"fifo_empty works");
    else
      $display($time,"fifo_empty error");
  end   
endtask


endinterface:fifo_if
