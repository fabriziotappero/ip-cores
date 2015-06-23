/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     SIM    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  Clock and Reset generator for simulations                          */
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
  vga_model_def 
     (
 input   wire                 clk,
 input   wire                 hsync_n,
 input   wire                 reset,
 input   wire                 vsync_n,
 input   wire    [ 1 :  0]        blue,
 input   wire    [ 2 :  0]        green,
 input   wire    [ 2 :  0]        red);
reg                        exp_device_rx_parity;
reg                        mask_device_rx_parity;
reg     [ 7 :  0]              exp_device_rx_data;
reg     [ 7 :  0]              mask_device_rx_data;
wire                        drv_device_rx_parity;
wire                        prb_device_rx_parity;
wire     [ 7 :  0]              drv_device_rx_data;
wire     [ 7 :  0]              prb_device_rx_data;
assign prb_device_rx_data = 8'h00;
assign  prb_device_rx_parity = 1'b0;
always@(posedge clk)
  if(reset)
   mask_device_rx_parity <= 1'b0;
  else
   mask_device_rx_parity <= 1'b0;
always@(posedge clk)
  if(reset)
   mask_device_rx_data <= 8'b0;
  else
   mask_device_rx_data <= 8'b0;
reg [23:0] red_h_cnt;
reg [23:0] green_h_cnt;
reg [23:0] blue_h_cnt;
reg [23:0] red_h_lat;
reg [23:0] green_h_lat;
reg [23:0] blue_h_lat;
reg [47:0] v_cnt;
reg [47:0] v_lat;
reg hsync;
reg vsync;
always@(posedge clk)
if(reset)             hsync <= 1'b0;
else                  hsync <= !hsync_n;
always@(posedge clk)
if(reset)             vsync <= 1'b0;
else                  vsync <= !vsync_n;
always@(posedge clk)
if(reset || (hsync))               red_h_cnt <= 24'h0;
else                               red_h_cnt <= red_h_cnt + red;
always@(posedge clk)
if   (reset)                       red_h_lat <= 24'h0;
else if(!hsync_n &&(!hsync))       red_h_lat <= red_h_cnt;
else                               red_h_lat <= red_h_lat;
always@(posedge clk)
if(reset || (hsync))               green_h_cnt <= 24'h0;
else                               green_h_cnt <= green_h_cnt + green;
always@(posedge clk)
if   (reset)                       green_h_lat <= 24'h0;
else if(!hsync_n &&(!hsync))       green_h_lat <= green_h_cnt;
else                               green_h_lat <= green_h_lat;
always@(posedge clk)
if(reset || (hsync))               blue_h_cnt <= 24'h0;
else                               blue_h_cnt <= blue_h_cnt + blue;
always@(posedge clk)
if   (reset)                       blue_h_lat <= 24'h0;
else if(!hsync_n &&(!hsync))       blue_h_lat <= blue_h_lat;
else                               blue_h_lat <= blue_h_cnt;
always@(posedge clk)
if   (reset)                       v_cnt      <= 48'h0;
else if(!hsync_n &&(!hsync))       v_cnt      <= red_h_cnt + green_h_cnt + blue_h_cnt + v_cnt;
else                               v_cnt      <= v_cnt;
always@(posedge clk)
if   (reset)                       v_lat <= 48'h0;
else if(!vsync_n &&(vsync))        v_lat <= v_cnt;
else                               v_lat <= v_lat;
/*
io_probe_def 
#(.MESG   ("vga data receive error"),
  .WIDTH  (8)
  )
rx_shift_buffer_prb   
(
  .clk           ( clk ),
  .drive_value   (8'bzzzzzzzz), 
  .expected_value( exp_rx_shift_buffer),
  .mask          ( mask_rx_shift_buffer),
  .signal        ( prb_rx_shift_buffer)
);      
io_probe_def 
#(.MESG   ("vga parity error"))
rx_parity_err_prb   
(
  .clk           ( clk ),
  .drive_value   (1'bz), 
  .expected_value( exp_rx_parity_err),
  .mask          ( mask_rx_parity_err),
  .signal        ( prb_rx_parity_err)
);      
*/
  endmodule
