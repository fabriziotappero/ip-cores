/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /  COMPONENT \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  micro_bus interface between master and slaves                     */
/*                                                                    */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
 module 
  micro_bus_byte 
     (
 input   wire                 clk,
 input   wire                 rd_in,
 input   wire                 reset,
 input   wire                 wr_in,
 input   wire    [ 1 :  0]        mem_wait,
 input   wire    [ 15 :  0]        addr_in,
 input   wire    [ 47 :  0]        mem_rdata,
 input   wire    [ 7 :  0]        wdata_in,
 output   reg    [ 4 :  0]        mem_cs,
 output   reg    [ 7 :  0]        rdata_out,
 output   wire                 enable,
 output   wire                 mem_rd,
 output   wire                 mem_wr,
 output   wire    [ 15 :  0]        mem_addr,
 output   wire    [ 15 :  0]        mem_wdata);
reg [4:0] mem_cs_r;
 always@(posedge clk)     mem_cs_r  <=     mem_cs;
always@(*)
 begin
 if(addr_in[15:12] == 4'b0000)     mem_cs[0]         = 1'b1;
 else                             mem_cs[0]         = 1'b0;
 end 
always@(*)
 begin
 if(addr_in[15:12] == 4'b1111)   mem_cs[1]         = 1'b1;  
 else                             mem_cs[1]         = 1'b0;    
 end
always@(*)
 begin
 if(addr_in[15:12] == 4'b1100)   mem_cs[2]         = 1'b1;  
 else                            mem_cs[2]         = 1'b0;        
 end 
always@(*)
 begin
 if(addr_in[15:12] == 4'b1000)  mem_cs[3]         = 1'b1;
 else                            mem_cs[3]         = 1'b0;
 end 
always@(*)
 begin
 if(addr_in[15:14] == 2'b01)  mem_cs[4]          = 1'b1;
 else                            mem_cs[4]          = 1'b0;
 end
always@(*)
if ( mem_cs_r[0] ) rdata_out = mem_rdata[7:0];
else
if ( mem_cs_r[1] ) rdata_out = mem_rdata[15:8];
else
if ( mem_cs_r[2] ) rdata_out = mem_rdata[23:16];
else
if ( mem_cs_r[3] ) rdata_out = mem_rdata[31:24];
else               rdata_out = addr_in[0]?mem_rdata[47:40]:mem_rdata[39:32];
assign mem_addr   =  addr_in;
assign mem_rd     =  rd_in;
assign mem_wr     =  wr_in;
assign mem_wdata  = {wdata_in,wdata_in};
assign enable     = ~(|mem_wait);
  endmodule
