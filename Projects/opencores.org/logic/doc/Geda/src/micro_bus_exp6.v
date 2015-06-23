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
  micro_bus_exp6 
    #( parameter 
      MAS_ADD_WIDTH=4,
      MAS_DATA_WIDTH=8,
      SLA_ADD_WIDTH=8,
      SLA_DATA_WIDTH=16)
     (
 input   wire                 clk,
 input   wire                 cs_in,
 input   wire                 enable,
 input   wire                 rd_in,
 input   wire                 reset,
 input   wire                 wr_in,
 input   wire    [ 7 :  0]        addr_in,
 input   wire    [ 7 :  0]        mas_0_rdata_in,
 input   wire    [ 7 :  0]        mas_1_rdata_in,
 input   wire    [ 7 :  0]        mas_2_rdata_in,
 input   wire    [ 7 :  0]        mas_3_rdata_in,
 input   wire    [ 7 :  0]        mas_4_rdata_in,
 input   wire    [ 7 :  0]        mas_5_rdata_in,
 input   wire    [ 7 :  0]        wdata_in,
 output   reg                 wait_out,
 output   wire                 mas_0_cs_out,
 output   wire                 mas_0_rd_out,
 output   wire                 mas_0_wr_out,
 output   wire                 mas_1_cs_out,
 output   wire                 mas_1_rd_out,
 output   wire                 mas_1_wr_out,
 output   wire                 mas_2_cs_out,
 output   wire                 mas_2_rd_out,
 output   wire                 mas_2_wr_out,
 output   wire                 mas_3_cs_out,
 output   wire                 mas_3_rd_out,
 output   wire                 mas_3_wr_out,
 output   wire                 mas_4_cs_out,
 output   wire                 mas_4_rd_out,
 output   wire                 mas_4_wr_out,
 output   wire                 mas_5_cs_out,
 output   wire                 mas_5_rd_out,
 output   wire                 mas_5_wr_out,
 output   wire    [ 15 :  0]        rdata_out,
 output   wire    [ 3 :  0]        mas_0_addr_out,
 output   wire    [ 3 :  0]        mas_1_addr_out,
 output   wire    [ 3 :  0]        mas_2_addr_out,
 output   wire    [ 3 :  0]        mas_3_addr_out,
 output   wire    [ 3 :  0]        mas_4_addr_out,
 output   wire    [ 3 :  0]        mas_5_addr_out,
 output   wire    [ 7 :  0]        mas_0_wdata_out,
 output   wire    [ 7 :  0]        mas_1_wdata_out,
 output   wire    [ 7 :  0]        mas_2_wdata_out,
 output   wire    [ 7 :  0]        mas_3_wdata_out,
 output   wire    [ 7 :  0]        mas_4_wdata_out,
 output   wire    [ 7 :  0]        mas_5_wdata_out);
reg [7:0]  rdata_out_reg;
always@(posedge clk)
rdata_out_reg     <= mas_0_rdata_in  &
                     mas_1_rdata_in  & 
                     mas_2_rdata_in  & 
                     mas_3_rdata_in  & 
                     mas_4_rdata_in  & 
                     mas_5_rdata_in; 
assign mas_0_rd_out    = rd_in;
assign mas_1_rd_out    = rd_in;
assign mas_2_rd_out    = rd_in;
assign mas_3_rd_out    = rd_in;
assign mas_4_rd_out    = rd_in;
assign mas_5_rd_out    = rd_in;
assign mas_0_wr_out    = wr_in;
assign mas_1_wr_out    = wr_in;
assign mas_2_wr_out    = wr_in;
assign mas_3_wr_out    = wr_in;
assign mas_4_wr_out    = wr_in;
assign mas_5_wr_out    = wr_in;
assign mas_0_wdata_out = wdata_in;
assign mas_1_wdata_out = wdata_in;
assign mas_2_wdata_out = wdata_in;
assign mas_3_wdata_out = wdata_in;
assign mas_4_wdata_out = wdata_in;
assign mas_5_wdata_out = wdata_in;
assign mas_0_addr_out  = addr_in[3:0];
assign mas_1_addr_out  = addr_in[3:0];
assign mas_2_addr_out  = addr_in[3:0];
assign mas_3_addr_out  = addr_in[3:0];
assign mas_4_addr_out  = addr_in[3:0];
assign mas_5_addr_out  = addr_in[3:0];
assign  mas_0_cs_out = (addr_in[7:4] == 4'h0) && cs_in;
assign  mas_1_cs_out = (addr_in[7:4] == 4'h1) && cs_in;
assign  mas_2_cs_out = (addr_in[7:4] == 4'h2) && cs_in;
assign  mas_3_cs_out = (addr_in[7:4] == 4'h3) && cs_in;
assign  mas_4_cs_out = (addr_in[7:4] == 4'h4) && cs_in;
assign  mas_5_cs_out = (addr_in[7:4] == 4'h5) && cs_in;
assign   rdata_out = (rd_in && cs_in)?{8'h00,rdata_out_reg}:16'hffff;
always@(posedge clk)
if(reset || enable) 
   begin
   wait_out  <= 1'b1;
   end   
else
    wait_out <= 1'b0;  
  endmodule
