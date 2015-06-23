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
  micro_bus_def 
    #( parameter 
      ADD=0,
      CH0_BITS=4,
      CH0_MATCH=4'h0,
      CH1_BITS=4,
      CH1_MATCH=4'h0,
      CH2_BITS=4,
      CH2_MATCH=4'h0,
      CH3_BITS=4,
      CH3_MATCH=4'h0,
      CH4_BITS=4,
      CH4_MATCH=4'h0,
      CH5_BITS=4,
      CH5_MATCH=4'h0)
     (
 input   wire                 clk,
 input   wire                 ext_mem_wait,
 input   wire                 io_reg_wait,
 input   wire                 rd_in,
 input   wire                 reset,
 input   wire                 wr_in,
 input   wire    [ 1 :  0]        mem_wait,
 input   wire    [ 15 :  0]        addr_in,
 input   wire    [ 15 :  0]        data_rdata,
 input   wire    [ 15 :  0]        ext_mem_rdata,
 input   wire    [ 15 :  0]        io_reg_rdata,
 input   wire    [ 15 :  0]        mem_rdata,
 input   wire    [ 15 :  0]        prog_rom_mem_rdata,
 input   wire    [ 15 :  0]        sh_prog_rom_mem_rdata,
 input   wire    [ 7 :  0]        wdata_in,
 output   reg                 data_cs,
 output   reg                 ext_mem_cs,
 output   reg                 io_reg_cs,
 output   reg                 mem_cs,
 output   reg                 prog_rom_mem_cs,
 output   reg                 sh_prog_rom_mem_cs,
 output   reg    [ 15 :  0]        rdata_out,
 output   wire                 data_rd,
 output   wire                 data_wr,
 output   wire                 enable,
 output   wire                 ext_mem_rd,
 output   wire                 ext_mem_wr,
 output   wire                 io_reg_rd,
 output   wire                 io_reg_wr,
 output   wire                 mem_rd,
 output   wire                 mem_wr,
 output   wire                 prog_rom_mem_rd,
 output   wire                 prog_rom_mem_wr,
 output   wire                 sh_prog_rom_mem_rd,
 output   wire                 sh_prog_rom_mem_wr,
 output   wire    [ 1 :  0]        data_be,
 output   wire    [ 11 :  0]        prog_rom_mem_addr,
 output   wire    [ 11 :  0]        sh_prog_rom_mem_addr,
 output   wire    [ 11 :  1]        data_addr,
 output   wire    [ 13 :  0]        ext_mem_addr,
 output   wire    [ 15 :  0]        data_wdata,
 output   wire    [ 15 :  0]        ext_mem_wdata,
 output   wire    [ 15 :  0]        mem_addr,
 output   wire    [ 15 :  0]        mem_wdata,
 output   wire    [ 15 :  0]        prog_rom_mem_wdata,
 output   wire    [ 15 :  0]        sh_prog_rom_mem_wdata,
 output   wire    [ 7 :  0]        io_reg_addr,
 output   wire    [ 7 :  0]        io_reg_wdata);
assign enable     = ~( ext_mem_wait || io_reg_wait  );
/*   CH0   */
reg mem_cs_r;
always@(addr_in)
 begin
 if(addr_in[ADD-1:ADD-CH0_BITS] == CH0_MATCH)      mem_cs         = 1'b1;
 else                                              mem_cs         = 1'b0;
 end 
always@(posedge clk)
begin
     mem_cs_r  <=     mem_cs;
end 
assign mem_addr   = addr_in;
assign mem_rd     = rd_in;
assign mem_wr     = wr_in;
assign mem_wdata  = {wdata_in,wdata_in};
/*   CH1   */
reg data_cs_r;
always@(addr_in)
 begin
 if(addr_in[ADD-1:ADD-CH1_BITS] == CH1_MATCH)   data_cs           = 1'b1;
 else                                           data_cs           = 1'b0;
 end 
always@(posedge clk)
begin
     data_cs_r  <=     data_cs;
end 
assign data_addr            = addr_in[ADD-CH1_BITS-1:1];
assign data_rd              = rd_in;
assign data_wr              = wr_in;
assign data_wdata           = {wdata_in,wdata_in};
assign data_be[0]           = !addr_in[0];
assign data_be[1]           =  addr_in[0];
/*   CH2   */
reg io_reg_cs_r;
always@(addr_in)
 begin
 if(addr_in[ADD-1:ADD-CH2_BITS] == CH2_MATCH)   io_reg_cs           = 1'b1;
 else                               io_reg_cs           = 1'b0;
 end 
always@(posedge clk)
begin
     io_reg_cs_r  <=     io_reg_cs;
end 
assign io_reg_addr            = addr_in[ADD-CH2_BITS-1:0];
assign io_reg_rd              = rd_in;
assign io_reg_wr              = wr_in;
assign io_reg_wdata           = wdata_in;
/*   CH3   */
reg ext_mem_cs_r;
always@(addr_in)
 begin
 if(addr_in[ADD-1:ADD-CH3_BITS] == CH3_MATCH)     ext_mem_cs            = 1'b1;
 else                                             ext_mem_cs            = 1'b0;
 end
always@(posedge clk)
begin
     ext_mem_cs_r  <=     ext_mem_cs;
end 
assign ext_mem_addr            = addr_in[ADD-CH3_BITS-1:0];
assign ext_mem_rd              = rd_in;
assign ext_mem_wr              = wr_in;
assign ext_mem_wdata           = {wdata_in,wdata_in};
/*   CH4   */
reg prog_rom_mem_cs_r;
always@(addr_in)
 begin
 if(addr_in[ADD-1:ADD-CH4_BITS] == CH4_MATCH)   prog_rom_mem_cs          = 1'b1;
 else                                           prog_rom_mem_cs          = 1'b0;
 end
always@(posedge clk)
begin
     prog_rom_mem_cs_r  <=     prog_rom_mem_cs;
end 
assign prog_rom_mem_addr            = addr_in[ADD-CH4_BITS-1:0];
assign prog_rom_mem_rd              = rd_in;
assign prog_rom_mem_wr              = wr_in;
assign prog_rom_mem_wdata           = {wdata_in,wdata_in};
/*   CH5   */
reg sh_prog_rom_mem_cs_r;
always@(addr_in)
 begin
 if(addr_in[ADD-1:ADD-CH5_BITS] == CH5_MATCH)  sh_prog_rom_mem_cs         = 1'b1;  
 else                                          sh_prog_rom_mem_cs         = 1'b0;        
 end 
always@(posedge clk)
begin
     sh_prog_rom_mem_cs_r  <=     sh_prog_rom_mem_cs;
end 
assign sh_prog_rom_mem_addr            = addr_in[ADD-CH5_BITS-1:0];
assign sh_prog_rom_mem_rd              = rd_in;
assign sh_prog_rom_mem_wr              = wr_in;
assign sh_prog_rom_mem_wdata           = {wdata_in,wdata_in};
always@(*)
if ( mem_cs_r )                   rdata_out = mem_rdata;
else
if ( data_cs_r )                  rdata_out = data_rdata;
else
if ( prog_rom_mem_cs_r )          rdata_out = prog_rom_mem_rdata;
else
if ( io_reg_cs_r )                rdata_out = io_reg_rdata;
else
if ( sh_prog_rom_mem_cs_r )       rdata_out = sh_prog_rom_mem_rdata;
else                              rdata_out = ext_mem_rdata;
  endmodule
