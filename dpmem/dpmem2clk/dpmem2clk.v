/*
-------------------------------------------------------------------------------
-- Title      : Dual Port memory Core
-- Project    : Memory Cores
-------------------------------------------------------------------------------
-- File        : dpmem2clk.v
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenCores Project
-- Created     : 2000/09/20
-- Last update : 2000/09/26
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This Verilog code file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   20 September 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- Todo			   :   Must use generic code i.e. use the parameters
-------------------------------------------------------------------------------
*/


module dpmem2clk(Wclk,Wen,Wadd,Datain,Rclk,Ren,Radd,Dataout);

parameter WIDTH=8;
parameter ADD_WIDTH=4;
parameter IDELOUTPUT=8'h0;


input Wclk;
input Wen;
input [3:0] Wadd;
input [7:0] Datain;
input Rclk;
input Ren;
input [3:0] Radd;
output [7:0] Dataout;

/////////////////////////



reg [7:0] data [0:7];

reg [7:0] outport;
/////////////////////////

always @ (posedge Rclk)
begin

   if( Ren == 1'b1 )
        outport  <= data[Radd]; 
      else
        outport  <= IDELOUTPUT;
              
end

/////////////////////////

always @ (posedge Wclk)
begin

   if( Wen == 1'b1 )
       data[Wadd]   <= Datain; 
     
end      


/////////////////////////

assign Dataout = outport;

/////////////////////////////////
endmodule