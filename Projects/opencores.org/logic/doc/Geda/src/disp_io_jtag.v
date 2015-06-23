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
/*  display io interface for Digilent FPGA boards                     */
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
  disp_io_jtag 
     (
 input   wire                 clk,
 input   wire                 jtag_capture_dr,
 input   wire                 jtag_select,
 input   wire                 jtag_shift_dr,
 input   wire                 jtag_shiftcapture_dr_clk,
 input   wire                 jtag_tdi,
 input   wire                 jtag_test_logic_reset,
 input   wire                 jtag_update_dr_clk,
 input   wire                 reset,
 input   wire    [ 15 :  0]        PosD,
 input   wire    [ 3 :  0]        btn_pad_in,
 input   wire    [ 7 :  0]        PosL,
 input   wire    [ 7 :  0]        sw_pad_in,
 output   reg                 dp_pad_out,
 output   reg    [ 3 :  0]        PosB,
 output   reg    [ 3 :  0]        an_pad_out,
 output   reg    [ 6 :  0]        seg_pad_out,
 output   reg    [ 7 :  0]        PosS,
 output   reg    [ 7 :  0]        led_pad_out,
 output   wire                 jtag_tdo);
wire                        one_usec;
wire     [ 7 :  0]              update_value;
cde_divider_def
#( .SIZE (6))
cde_divider 
   (
    .clk      ( clk  ),
    .divider_in      ( 6'b100000  ),
    .divider_out      ( one_usec  ),
    .enable      ( 1'b1  ),
    .reset      ( reset  ));
cde_jtag_classic_rpc_reg
#( .BITS (8),
   .RESET_VALUE (8'h00))
jtag_rpc 
   (
   .capture_dr      ( jtag_capture_dr  ),
   .select      ( jtag_select  ),
   .shift_dr      ( jtag_shift_dr  ),
   .shiftcapture_dr_clk      ( jtag_shiftcapture_dr_clk  ),
   .tdi      ( jtag_tdi  ),
   .tdo      ( jtag_tdo  ),
   .test_logic_reset      ( jtag_test_logic_reset  ),
   .update_dr_clk      ( jtag_update_dr_clk  ),
    .capture_value      ( sw_pad_in  ),
    .update_value      ( update_value[7:0] ));
reg  [3:0]	    divide;
reg  [3:0]	    number;
always@(posedge clk )  led_pad_out <= PosL | update_value;
always@(posedge clk )  PosS        <= sw_pad_in;
always@(posedge clk )  PosB        <= btn_pad_in;
always@(posedge clk)
  if(reset)      divide <= 4'b0000;
  else
  if(one_usec)   divide <= divide+4'b0001;
  else           divide <= divide;
always@(posedge clk)   dp_pad_out   <= 1'b1;
always@(posedge clk)
  if(reset)                   an_pad_out <= 4'b1111;
  else
  if(divide[3:0] == 4'b0010)  an_pad_out <= 4'b1110;
  else   
  if(divide[3:0] == 4'b0110)  an_pad_out <= 4'b1101;
  else   
  if(divide[3:0] == 4'b1010)  an_pad_out <= 4'b1011;
  else   
  if(divide[3:0] == 4'b1110)  an_pad_out <= 4'b0111;
  else                        an_pad_out <= 4'b1111;
always@(posedge clk)
  if(divide[3:2] == 2'b00)  number <= PosD[3:0];
  else   
  if(divide[3:2] == 2'b01)  number <= PosD[7:4];
  else   
  if(divide[3:2] == 2'b10)  number <= PosD[11:8];
  else   
  if(divide[3:2] == 2'b11)  number <= PosD[15:12];
  else                      number <= number;
always@(posedge clk)
  if(reset)                   seg_pad_out <= 7'b1111111;
  else
  if(number[3:0] == 4'b0000)  seg_pad_out <= 7'b1000000;
  else   
  if(number[3:0] == 4'b0001)  seg_pad_out <= 7'b1111001;
  else   
  if(number[3:0] == 4'b0010)  seg_pad_out <= 7'b0100100;
  else   
  if(number[3:0] == 4'b0011)  seg_pad_out <= 7'b0110000;
  else   
  if(number[3:0] == 4'b0100)  seg_pad_out <= 7'b0011001;
  else   
  if(number[3:0] == 4'b0101)  seg_pad_out <= 7'b0010010;
  else   
  if(number[3:0] == 4'b0110)  seg_pad_out <= 7'b0000010;
  else   
  if(number[3:0] == 4'b0111)  seg_pad_out <= 7'b1111000;
  else
  if(number[3:0] == 4'b1000)  seg_pad_out <= 7'b0000000;
  else   
  if(number[3:0] == 4'b1001)  seg_pad_out <= 7'b0011000;
  else   
  if(number[3:0] == 4'b1010)  seg_pad_out <= 7'b0001000;
  else
  if(number[3:0] == 4'b1011)  seg_pad_out <= 7'b0000011;
  else   
  if(number[3:0] == 4'b1100)  seg_pad_out <= 7'b1000110;
  else
  if(number[3:0] == 4'b1101)  seg_pad_out <= 7'b0100001;
  else   
  if(number[3:0] == 4'b1110)  seg_pad_out <= 7'b0000110;
  else   
  if(number[3:0] == 4'b1111)  seg_pad_out <= 7'b0001110;
  else                        seg_pad_out <= 7'b1111111;
  endmodule
