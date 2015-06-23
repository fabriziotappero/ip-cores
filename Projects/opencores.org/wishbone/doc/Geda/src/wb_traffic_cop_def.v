//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Xess Traffic Cop                                            ////
////                                                              ////
////  This file is part of the OR1K test application              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  This block connectes the RISC and peripheral controller     ////
////  cores together.                                             ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 OpenCores                                 ////
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
 module 
  wb_traffic_cop_def 
    #( parameter 
      t0_addr=4'd8,
      t0_addr_w=4,
      t1_addr=4'd0,
      t1_addr_w=4,
      t28_addr=4'd0,
      t28c_addr_w=4,
      t28i_addr_w=4,
      t2_addr=4'd1,
      t3_addr=4'd2,
      t4_addr=4'd3,
      t5_addr=4'd4,
      t6_addr=4'd5,
      t7_addr=4'd6,
      t8_addr=4'd7,
      wb_addr_width=32,
      wb_byte_lanes=4,
      wb_data_width=32)
     (
 input   wire                 i0_wb_cyc_i,
 input   wire                 i0_wb_stb_i,
 input   wire                 i0_wb_we_i,
 input   wire                 i1_wb_cyc_i,
 input   wire                 i1_wb_stb_i,
 input   wire                 i1_wb_we_i,
 input   wire                 i2_wb_cyc_i,
 input   wire                 i2_wb_stb_i,
 input   wire                 i2_wb_we_i,
 input   wire                 i3_wb_cyc_i,
 input   wire                 i3_wb_stb_i,
 input   wire                 i3_wb_we_i,
 input   wire                 i4_wb_cyc_i,
 input   wire                 i4_wb_stb_i,
 input   wire                 i4_wb_we_i,
 input   wire                 i5_wb_cyc_i,
 input   wire                 i5_wb_stb_i,
 input   wire                 i5_wb_we_i,
 input   wire                 i6_wb_cyc_i,
 input   wire                 i6_wb_stb_i,
 input   wire                 i6_wb_we_i,
 input   wire                 i7_wb_cyc_i,
 input   wire                 i7_wb_stb_i,
 input   wire                 i7_wb_we_i,
 input   wire                 t0_wb_ack_i,
 input   wire                 t0_wb_err_i,
 input   wire                 t1_wb_ack_i,
 input   wire                 t1_wb_err_i,
 input   wire                 t2_wb_ack_i,
 input   wire                 t2_wb_err_i,
 input   wire                 t3_wb_ack_i,
 input   wire                 t3_wb_err_i,
 input   wire                 t4_wb_ack_i,
 input   wire                 t4_wb_err_i,
 input   wire                 t5_wb_ack_i,
 input   wire                 t5_wb_err_i,
 input   wire                 t6_wb_ack_i,
 input   wire                 t6_wb_err_i,
 input   wire                 t7_wb_ack_i,
 input   wire                 t7_wb_err_i,
 input   wire                 t8_wb_ack_i,
 input   wire                 t8_wb_err_i,
 input   wire                 wb_clk_i,
 input   wire                 wb_rst_i,
 input   wire    [ wb_addr_width-1 :  0]        i0_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i1_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i2_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i3_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i4_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i5_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i6_wb_adr_i,
 input   wire    [ wb_addr_width-1 :  0]        i7_wb_adr_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i0_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i1_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i2_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i3_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i4_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i5_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i6_wb_sel_i,
 input   wire    [ wb_byte_lanes-1 :  0]        i7_wb_sel_i,
 input   wire    [ wb_data_width-1 :  0]        i0_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i1_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i2_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i3_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i4_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i5_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i6_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        i7_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t0_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t1_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t2_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t3_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t4_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t5_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t6_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t7_wb_dat_i,
 input   wire    [ wb_data_width-1 :  0]        t8_wb_dat_i,
 output   wire                 i0_wb_ack_o,
 output   wire                 i0_wb_err_o,
 output   wire                 i1_wb_ack_o,
 output   wire                 i1_wb_err_o,
 output   wire                 i2_wb_ack_o,
 output   wire                 i2_wb_err_o,
 output   wire                 i3_wb_ack_o,
 output   wire                 i3_wb_err_o,
 output   wire                 i4_wb_ack_o,
 output   wire                 i4_wb_err_o,
 output   wire                 i5_wb_ack_o,
 output   wire                 i5_wb_err_o,
 output   wire                 i6_wb_ack_o,
 output   wire                 i6_wb_err_o,
 output   wire                 i7_wb_ack_o,
 output   wire                 i7_wb_err_o,
 output   wire                 t0_wb_cyc_o,
 output   wire                 t0_wb_stb_o,
 output   wire                 t0_wb_we_o,
 output   wire                 t1_wb_cyc_o,
 output   wire                 t1_wb_stb_o,
 output   wire                 t1_wb_we_o,
 output   wire                 t2_wb_cyc_o,
 output   wire                 t2_wb_stb_o,
 output   wire                 t2_wb_we_o,
 output   wire                 t3_wb_cyc_o,
 output   wire                 t3_wb_stb_o,
 output   wire                 t3_wb_we_o,
 output   wire                 t4_wb_cyc_o,
 output   wire                 t4_wb_stb_o,
 output   wire                 t4_wb_we_o,
 output   wire                 t5_wb_cyc_o,
 output   wire                 t5_wb_stb_o,
 output   wire                 t5_wb_we_o,
 output   wire                 t6_wb_cyc_o,
 output   wire                 t6_wb_stb_o,
 output   wire                 t6_wb_we_o,
 output   wire                 t7_wb_cyc_o,
 output   wire                 t7_wb_stb_o,
 output   wire                 t7_wb_we_o,
 output   wire                 t8_wb_cyc_o,
 output   wire                 t8_wb_stb_o,
 output   wire                 t8_wb_we_o,
 output   wire    [ wb_addr_width-1 :  0]        t0_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t1_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t2_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t3_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t4_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t5_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t6_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t7_wb_adr_o,
 output   wire    [ wb_addr_width-1 :  0]        t8_wb_adr_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t0_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t1_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t2_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t3_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t4_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t5_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t6_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t7_wb_sel_o,
 output   wire    [ wb_byte_lanes-1 :  0]        t8_wb_sel_o,
 output   wire    [ wb_data_width-1 :  0]        i0_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i1_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i2_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i3_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i4_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i5_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i6_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        i7_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t0_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t1_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t2_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t3_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t4_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t5_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t6_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t7_wb_dat_o,
 output   wire    [ wb_data_width-1 :  0]        t8_wb_dat_o);
wb_traffic_cop_arb
#( .multitarg (0),
   .t0_addr (t0_addr),
   .t0_addr_w (t0_addr_w),
   .t17_addr (t0_addr),
   .t17_addr_w (t0_addr_w),
   .wb_addr_width (wb_addr_width),
   .wb_byte_lanes (wb_byte_lanes),
   .wb_data_width (wb_data_width))
t0_CH 
   (
 );
wb_traffic_cop_exp
#( .t0_addr (t1_addr),
   .t0_addr_w (t1_addr_w),
   .t17_addr_w (t28i_addr_w),
   .t1_addr (t2_addr),
   .t2_addr (t3_addr),
   .t3_addr (t4_addr),
   .t4_addr (t5_addr),
   .t5_addr (t6_addr),
   .t6_addr (t7_addr),
   .t7_addr (t8_addr),
   .wb_addr_width (wb_addr_width),
   .wb_byte_lanes (wb_byte_lanes),
   .wb_data_width (wb_data_width))
t18_CH_lower 
   (
 );
wb_traffic_cop_arb
#( .multitarg (1),
   .t0_addr (t1_addr),
   .t0_addr_w (t1_addr_w),
   .t17_addr (t28_addr),
   .t17_addr_w (t28c_addr_w),
   .wb_addr_width (wb_addr_width),
   .wb_byte_lanes (wb_byte_lanes),
   .wb_data_width (wb_data_width))
t18_CH_upper 
   (
 );
//
// Internal wires & registers
//
//
// Outputs for initiators from both mi_to_st blocks
//
wire    [wb_data_width-1:0]    xi0_wb_dat_o;
wire                        xi0_wb_ack_o;
wire                        xi0_wb_err_o;
wire    [wb_data_width-1:0]    xi1_wb_dat_o;
wire                        xi1_wb_ack_o;
wire                        xi1_wb_err_o;
wire    [wb_data_width-1:0]          xi2_wb_dat_o;
wire                        xi2_wb_ack_o;
wire                        xi2_wb_err_o;
wire    [wb_data_width-1:0]    xi3_wb_dat_o;
wire                        xi3_wb_ack_o;
wire                        xi3_wb_err_o;
wire    [wb_data_width-1:0]    xi4_wb_dat_o;
wire                        xi4_wb_ack_o;
wire                        xi4_wb_err_o;
wire    [wb_data_width-1:0]    xi5_wb_dat_o;
wire                        xi5_wb_ack_o;
wire                        xi5_wb_err_o;
wire    [wb_data_width-1:0]    xi6_wb_dat_o;
wire                        xi6_wb_ack_o;
wire                        xi6_wb_err_o;
wire    [wb_data_width-1:0]    xi7_wb_dat_o;
wire                        xi7_wb_ack_o;
wire                        xi7_wb_err_o;
wire    [wb_data_width-1:0]    yi0_wb_dat_o;
wire                        yi0_wb_ack_o;
wire                        yi0_wb_err_o;
wire    [wb_data_width-1:0]    yi1_wb_dat_o;
wire                        yi1_wb_ack_o;
wire                        yi1_wb_err_o;
wire    [wb_data_width-1:0]          yi2_wb_dat_o;
wire                        yi2_wb_ack_o;
wire                        yi2_wb_err_o;
wire    [wb_data_width-1:0]    yi3_wb_dat_o;
wire                        yi3_wb_ack_o;
wire                        yi3_wb_err_o;
wire    [wb_data_width-1:0]    yi4_wb_dat_o;
wire                        yi4_wb_ack_o;
wire                        yi4_wb_err_o;
wire    [wb_data_width-1:0]    yi5_wb_dat_o;
wire                        yi5_wb_ack_o;
wire                        yi5_wb_err_o;
wire    [wb_data_width-1:0]    yi6_wb_dat_o;
wire                        yi6_wb_ack_o;
wire                        yi6_wb_err_o;
wire    [wb_data_width-1:0]    yi7_wb_dat_o;
wire                        yi7_wb_ack_o;
wire                        yi7_wb_err_o;
//
// Intermediate signals connecting peripheral channel's
// mi_to_st and si_to_mt blocks.
//
wire                            z_wb_cyc_i;
wire                        z_wb_stb_i;
wire    [wb_addr_width-1:0]    z_wb_adr_i;
wire    [wb_byte_lanes-1:0]    z_wb_sel_i;
wire                        z_wb_we_i;
wire    [wb_data_width-1:0]    z_wb_dat_i;
wire    [wb_data_width-1:0]    z_wb_dat_t;
wire                        z_wb_ack_t;
wire                        z_wb_err_t;
//
// Outputs for initiators are ORed from both mi_to_st blocks
//
assign i0_wb_dat_o = xi0_wb_dat_o | yi0_wb_dat_o;
assign i0_wb_ack_o = xi0_wb_ack_o | yi0_wb_ack_o;
assign i0_wb_err_o = xi0_wb_err_o | yi0_wb_err_o;
assign i1_wb_dat_o = xi1_wb_dat_o | yi1_wb_dat_o;
assign i1_wb_ack_o = xi1_wb_ack_o | yi1_wb_ack_o;
assign i1_wb_err_o = xi1_wb_err_o | yi1_wb_err_o;
assign i2_wb_dat_o = xi2_wb_dat_o | yi2_wb_dat_o;
assign i2_wb_ack_o = xi2_wb_ack_o | yi2_wb_ack_o;
assign i2_wb_err_o = xi2_wb_err_o | yi2_wb_err_o;
assign i3_wb_dat_o = xi3_wb_dat_o | yi3_wb_dat_o;
assign i3_wb_ack_o = xi3_wb_ack_o | yi3_wb_ack_o;
assign i3_wb_err_o = xi3_wb_err_o | yi3_wb_err_o;
assign i4_wb_dat_o = xi4_wb_dat_o | yi4_wb_dat_o;
assign i4_wb_ack_o = xi4_wb_ack_o | yi4_wb_ack_o;
assign i4_wb_err_o = xi4_wb_err_o | yi4_wb_err_o;
assign i5_wb_dat_o = xi5_wb_dat_o | yi5_wb_dat_o;
assign i5_wb_ack_o = xi5_wb_ack_o | yi5_wb_ack_o;
assign i5_wb_err_o = xi5_wb_err_o | yi5_wb_err_o;
assign i6_wb_dat_o = xi6_wb_dat_o | yi6_wb_dat_o;
assign i6_wb_ack_o = xi6_wb_ack_o | yi6_wb_ack_o;
assign i6_wb_err_o = xi6_wb_err_o | yi6_wb_err_o;
assign i7_wb_dat_o = xi7_wb_dat_o | yi7_wb_dat_o;
assign i7_wb_ack_o = xi7_wb_ack_o | yi7_wb_ack_o;
assign i7_wb_err_o = xi7_wb_err_o | yi7_wb_err_o;
//
// From initiators to target 0
//
wb_traffic_cop_arb
  #(.wb_addr_width (wb_addr_width),
    .wb_data_width (wb_data_width),
    .wb_byte_lanes (wb_byte_lanes),
    .t0_addr_w  (t0_addr_w), 
    .t0_addr    (t0_addr), 
    .multitarg  (0), 
    .t17_addr_w (t0_addr_w), 
    .t17_addr   (t0_addr)) 
t0_ch
 (
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .i0_wb_cyc_i(i0_wb_cyc_i),
    .i0_wb_stb_i(i0_wb_stb_i),
    .i0_wb_adr_i(i0_wb_adr_i),
    .i0_wb_sel_i(i0_wb_sel_i),
    .i0_wb_we_i(i0_wb_we_i),
    .i0_wb_dat_i(i0_wb_dat_i),
    .i0_wb_dat_o(xi0_wb_dat_o),
    .i0_wb_ack_o(xi0_wb_ack_o),
    .i0_wb_err_o(xi0_wb_err_o),
    .i1_wb_cyc_i(i1_wb_cyc_i),
    .i1_wb_stb_i(i1_wb_stb_i),
    .i1_wb_adr_i(i1_wb_adr_i),
    .i1_wb_sel_i(i1_wb_sel_i),
    .i1_wb_we_i(i1_wb_we_i),
    .i1_wb_dat_i(i1_wb_dat_i),
    .i1_wb_dat_o(xi1_wb_dat_o),
    .i1_wb_ack_o(xi1_wb_ack_o),
    .i1_wb_err_o(xi1_wb_err_o),
    .i2_wb_cyc_i(i2_wb_cyc_i),
    .i2_wb_stb_i(i2_wb_stb_i),
    .i2_wb_adr_i(i2_wb_adr_i),
    .i2_wb_sel_i(i2_wb_sel_i),
    .i2_wb_we_i(i2_wb_we_i),
    .i2_wb_dat_i(i2_wb_dat_i),
    .i2_wb_dat_o(xi2_wb_dat_o),
    .i2_wb_ack_o(xi2_wb_ack_o),
    .i2_wb_err_o(xi2_wb_err_o),
    .i3_wb_cyc_i(i3_wb_cyc_i),
    .i3_wb_stb_i(i3_wb_stb_i),
    .i3_wb_adr_i(i3_wb_adr_i),
    .i3_wb_sel_i(i3_wb_sel_i),
    .i3_wb_we_i(i3_wb_we_i),
    .i3_wb_dat_i(i3_wb_dat_i),
    .i3_wb_dat_o(xi3_wb_dat_o),
    .i3_wb_ack_o(xi3_wb_ack_o),
    .i3_wb_err_o(xi3_wb_err_o),
    .i4_wb_cyc_i(i4_wb_cyc_i),
    .i4_wb_stb_i(i4_wb_stb_i),
    .i4_wb_adr_i(i4_wb_adr_i),
    .i4_wb_sel_i(i4_wb_sel_i),
    .i4_wb_we_i(i4_wb_we_i),
    .i4_wb_dat_i(i4_wb_dat_i),
    .i4_wb_dat_o(xi4_wb_dat_o),
    .i4_wb_ack_o(xi4_wb_ack_o),
    .i4_wb_err_o(xi4_wb_err_o),
    .i5_wb_cyc_i(i5_wb_cyc_i),
    .i5_wb_stb_i(i5_wb_stb_i),
    .i5_wb_adr_i(i5_wb_adr_i),
    .i5_wb_sel_i(i5_wb_sel_i),
    .i5_wb_we_i(i5_wb_we_i),
    .i5_wb_dat_i(i5_wb_dat_i),
    .i5_wb_dat_o(xi5_wb_dat_o),
    .i5_wb_ack_o(xi5_wb_ack_o),
    .i5_wb_err_o(xi5_wb_err_o),
    .i6_wb_cyc_i(i6_wb_cyc_i),
    .i6_wb_stb_i(i6_wb_stb_i),
    .i6_wb_adr_i(i6_wb_adr_i),
    .i6_wb_sel_i(i6_wb_sel_i),
    .i6_wb_we_i(i6_wb_we_i),
    .i6_wb_dat_i(i6_wb_dat_i),
    .i6_wb_dat_o(xi6_wb_dat_o),
    .i6_wb_ack_o(xi6_wb_ack_o),
    .i6_wb_err_o(xi6_wb_err_o),
    .i7_wb_cyc_i(i7_wb_cyc_i),
    .i7_wb_stb_i(i7_wb_stb_i),
    .i7_wb_adr_i(i7_wb_adr_i),
    .i7_wb_sel_i(i7_wb_sel_i),
    .i7_wb_we_i(i7_wb_we_i),
    .i7_wb_dat_i(i7_wb_dat_i),
    .i7_wb_dat_o(xi7_wb_dat_o),
    .i7_wb_ack_o(xi7_wb_ack_o),
    .i7_wb_err_o(xi7_wb_err_o),
    .t0_wb_cyc_o(t0_wb_cyc_o),
    .t0_wb_stb_o(t0_wb_stb_o),
    .t0_wb_adr_o(t0_wb_adr_o),
    .t0_wb_sel_o(t0_wb_sel_o),
    .t0_wb_we_o(t0_wb_we_o),
    .t0_wb_dat_o(t0_wb_dat_o),
    .t0_wb_dat_i(t0_wb_dat_i),
    .t0_wb_ack_i(t0_wb_ack_i),
    .t0_wb_err_i(t0_wb_err_i)
);
//
// From initiators to targets 1-8 (upper part)
//
wb_traffic_cop_arb
  #(.wb_addr_width (wb_addr_width),
    .wb_data_width (wb_data_width),
    .wb_byte_lanes (wb_byte_lanes),
    .multitarg     (1), 
    .t0_addr_w     (t1_addr_w), 
    .t17_addr_w    (t28c_addr_w), 
    .t0_addr       (t1_addr), 
    .t17_addr      (t28_addr)) 
    t18_ch_upper(
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .i0_wb_cyc_i(i0_wb_cyc_i),
    .i0_wb_stb_i(i0_wb_stb_i),
    .i0_wb_adr_i(i0_wb_adr_i),
    .i0_wb_sel_i(i0_wb_sel_i),
    .i0_wb_we_i(i0_wb_we_i),
    .i0_wb_dat_i(i0_wb_dat_i),
    .i0_wb_dat_o(yi0_wb_dat_o),
    .i0_wb_ack_o(yi0_wb_ack_o),
    .i0_wb_err_o(yi0_wb_err_o),
    .i1_wb_cyc_i(i1_wb_cyc_i),
    .i1_wb_stb_i(i1_wb_stb_i),
    .i1_wb_adr_i(i1_wb_adr_i),
    .i1_wb_sel_i(i1_wb_sel_i),
    .i1_wb_we_i(i1_wb_we_i),
    .i1_wb_dat_i(i1_wb_dat_i),
    .i1_wb_dat_o(yi1_wb_dat_o),
    .i1_wb_ack_o(yi1_wb_ack_o),
    .i1_wb_err_o(yi1_wb_err_o),
    .i2_wb_cyc_i(i2_wb_cyc_i),
    .i2_wb_stb_i(i2_wb_stb_i),
    .i2_wb_adr_i(i2_wb_adr_i),
    .i2_wb_sel_i(i2_wb_sel_i),
    .i2_wb_we_i(i2_wb_we_i),
    .i2_wb_dat_i(i2_wb_dat_i),
    .i2_wb_dat_o(yi2_wb_dat_o),
    .i2_wb_ack_o(yi2_wb_ack_o),
    .i2_wb_err_o(yi2_wb_err_o),
    .i3_wb_cyc_i(i3_wb_cyc_i),
    .i3_wb_stb_i(i3_wb_stb_i),
    .i3_wb_adr_i(i3_wb_adr_i),
    .i3_wb_sel_i(i3_wb_sel_i),
    .i3_wb_we_i(i3_wb_we_i),
    .i3_wb_dat_i(i3_wb_dat_i),
    .i3_wb_dat_o(yi3_wb_dat_o),
    .i3_wb_ack_o(yi3_wb_ack_o),
    .i3_wb_err_o(yi3_wb_err_o),
    .i4_wb_cyc_i(i4_wb_cyc_i),
    .i4_wb_stb_i(i4_wb_stb_i),
    .i4_wb_adr_i(i4_wb_adr_i),
    .i4_wb_sel_i(i4_wb_sel_i),
    .i4_wb_we_i(i4_wb_we_i),
    .i4_wb_dat_i(i4_wb_dat_i),
    .i4_wb_dat_o(yi4_wb_dat_o),
    .i4_wb_ack_o(yi4_wb_ack_o),
    .i4_wb_err_o(yi4_wb_err_o),
    .i5_wb_cyc_i(i5_wb_cyc_i),
    .i5_wb_stb_i(i5_wb_stb_i),
    .i5_wb_adr_i(i5_wb_adr_i),
    .i5_wb_sel_i(i5_wb_sel_i),
    .i5_wb_we_i(i5_wb_we_i),
    .i5_wb_dat_i(i5_wb_dat_i),
    .i5_wb_dat_o(yi5_wb_dat_o),
    .i5_wb_ack_o(yi5_wb_ack_o),
    .i5_wb_err_o(yi5_wb_err_o),
    .i6_wb_cyc_i(i6_wb_cyc_i),
    .i6_wb_stb_i(i6_wb_stb_i),
    .i6_wb_adr_i(i6_wb_adr_i),
    .i6_wb_sel_i(i6_wb_sel_i),
    .i6_wb_we_i(i6_wb_we_i),
    .i6_wb_dat_i(i6_wb_dat_i),
    .i6_wb_dat_o(yi6_wb_dat_o),
    .i6_wb_ack_o(yi6_wb_ack_o),
    .i6_wb_err_o(yi6_wb_err_o),
    .i7_wb_cyc_i(i7_wb_cyc_i),
    .i7_wb_stb_i(i7_wb_stb_i),
    .i7_wb_adr_i(i7_wb_adr_i),
    .i7_wb_sel_i(i7_wb_sel_i),
    .i7_wb_we_i(i7_wb_we_i),
    .i7_wb_dat_i(i7_wb_dat_i),
    .i7_wb_dat_o(yi7_wb_dat_o),
    .i7_wb_ack_o(yi7_wb_ack_o),
    .i7_wb_err_o(yi7_wb_err_o),
    .t0_wb_cyc_o(z_wb_cyc_i),
    .t0_wb_stb_o(z_wb_stb_i),
    .t0_wb_adr_o(z_wb_adr_i),
    .t0_wb_sel_o(z_wb_sel_i),
    .t0_wb_we_o(z_wb_we_i),
    .t0_wb_dat_o(z_wb_dat_i),
    .t0_wb_dat_i(z_wb_dat_t),
    .t0_wb_ack_i(z_wb_ack_t),
    .t0_wb_err_i(z_wb_err_t)
);
//
// From initiators to targets 1-8 (lower part)
//
wb_traffic_cop_exp
  #( .wb_addr_width (wb_addr_width),
     .wb_data_width (wb_data_width), 
     .wb_byte_lanes (wb_byte_lanes),
     .t0_addr_w     (t1_addr_w),
     .t17_addr_w    (t28i_addr_w),  
     .t0_addr       (t1_addr), 
     .t1_addr       (t2_addr), 
     .t2_addr       (t3_addr), 
     .t3_addr       (t4_addr),  
     .t4_addr       (t5_addr),   
     .t5_addr       (t6_addr),   
     .t6_addr       (t7_addr),   
     .t7_addr       (t8_addr))   
         t18_ch_lower(
    .i0_wb_cyc_i(z_wb_cyc_i),
    .i0_wb_stb_i(z_wb_stb_i),
    .i0_wb_adr_i(z_wb_adr_i),
    .i0_wb_sel_i(z_wb_sel_i),
    .i0_wb_we_i(z_wb_we_i),
    .i0_wb_dat_i(z_wb_dat_i),
    .i0_wb_dat_o(z_wb_dat_t),
    .i0_wb_ack_o(z_wb_ack_t),
    .i0_wb_err_o(z_wb_err_t),
    .t0_wb_cyc_o(t1_wb_cyc_o),
    .t0_wb_stb_o(t1_wb_stb_o),
    .t0_wb_adr_o(t1_wb_adr_o),
    .t0_wb_sel_o(t1_wb_sel_o),
    .t0_wb_we_o(t1_wb_we_o),
    .t0_wb_dat_o(t1_wb_dat_o),
    .t0_wb_dat_i(t1_wb_dat_i),
    .t0_wb_ack_i(t1_wb_ack_i),
    .t0_wb_err_i(t1_wb_err_i),
    .t1_wb_cyc_o(t2_wb_cyc_o),
    .t1_wb_stb_o(t2_wb_stb_o),
    .t1_wb_adr_o(t2_wb_adr_o),
    .t1_wb_sel_o(t2_wb_sel_o),
    .t1_wb_we_o(t2_wb_we_o),
    .t1_wb_dat_o(t2_wb_dat_o),
    .t1_wb_dat_i(t2_wb_dat_i),
    .t1_wb_ack_i(t2_wb_ack_i),
    .t1_wb_err_i(t2_wb_err_i),
    .t2_wb_cyc_o(t3_wb_cyc_o),
    .t2_wb_stb_o(t3_wb_stb_o),
    .t2_wb_adr_o(t3_wb_adr_o),
    .t2_wb_sel_o(t3_wb_sel_o),
    .t2_wb_we_o(t3_wb_we_o),
    .t2_wb_dat_o(t3_wb_dat_o),
    .t2_wb_dat_i(t3_wb_dat_i),
    .t2_wb_ack_i(t3_wb_ack_i),
    .t2_wb_err_i(t3_wb_err_i),
    .t3_wb_cyc_o(t4_wb_cyc_o),
    .t3_wb_stb_o(t4_wb_stb_o),
    .t3_wb_adr_o(t4_wb_adr_o),
    .t3_wb_sel_o(t4_wb_sel_o),
    .t3_wb_we_o(t4_wb_we_o),
    .t3_wb_dat_o(t4_wb_dat_o),
    .t3_wb_dat_i(t4_wb_dat_i),
    .t3_wb_ack_i(t4_wb_ack_i),
    .t3_wb_err_i(t4_wb_err_i),
    .t4_wb_cyc_o(t5_wb_cyc_o),
    .t4_wb_stb_o(t5_wb_stb_o),
    .t4_wb_adr_o(t5_wb_adr_o),
    .t4_wb_sel_o(t5_wb_sel_o),
    .t4_wb_we_o(t5_wb_we_o),
    .t4_wb_dat_o(t5_wb_dat_o),
    .t4_wb_dat_i(t5_wb_dat_i),
    .t4_wb_ack_i(t5_wb_ack_i),
    .t4_wb_err_i(t5_wb_err_i),
    .t5_wb_cyc_o(t6_wb_cyc_o),
    .t5_wb_stb_o(t6_wb_stb_o),
    .t5_wb_adr_o(t6_wb_adr_o),
    .t5_wb_sel_o(t6_wb_sel_o),
    .t5_wb_we_o(t6_wb_we_o),
    .t5_wb_dat_o(t6_wb_dat_o),
    .t5_wb_dat_i(t6_wb_dat_i),
    .t5_wb_ack_i(t6_wb_ack_i),
    .t5_wb_err_i(t6_wb_err_i),
    .t6_wb_cyc_o(t7_wb_cyc_o),
    .t6_wb_stb_o(t7_wb_stb_o),
    .t6_wb_adr_o(t7_wb_adr_o),
    .t6_wb_sel_o(t7_wb_sel_o),
    .t6_wb_we_o(t7_wb_we_o),
    .t6_wb_dat_o(t7_wb_dat_o),
    .t6_wb_dat_i(t7_wb_dat_i),
    .t6_wb_ack_i(t7_wb_ack_i),
    .t6_wb_err_i(t7_wb_err_i),
    .t7_wb_cyc_o(t8_wb_cyc_o),
    .t7_wb_stb_o(t8_wb_stb_o),
    .t7_wb_adr_o(t8_wb_adr_o),
    .t7_wb_sel_o(t8_wb_sel_o),
    .t7_wb_we_o(t8_wb_we_o),
    .t7_wb_dat_o(t8_wb_dat_o),
    .t7_wb_dat_i(t8_wb_dat_i),
    .t7_wb_ack_i(t8_wb_ack_i),
    .t7_wb_err_i(t8_wb_err_i)
);
  endmodule
