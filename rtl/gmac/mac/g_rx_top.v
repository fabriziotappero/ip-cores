//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//`timescale 1ns/100ps

 module g_rx_top(
		app_reset_n,
		phy_rx_clk,
		rx_reset_n,
		app_clk,
                          scan_mode,
		rx_sts_vld,
		rx_sts_bytes_rcvd,
		rx_sts_large_pkt,
	        rx_sts_lengthfield_err,
	        rx_sts_len_mismatch,
	        rx_sts_crc_err,
	        rx_sts_runt_pkt_rcvd,
	        rx_sts_rx_overrun,
	        rx_sts_frm_length_err,
                clr_rx_error_from_rx_fsm,
		rx_fifo_full,
		rx_dt_wrt,
		rx_dt_out,
		rx_commit_wr,
		commit_write_done,
		rx_rewind_wr,
	        mi2rx_strt_rcv,
	        mi2rx_rcv_vld,
	        mi2rx_rx_byte,
	        mi2rx_end_rcv,
	        mi2rx_extend,
	        mi2rx_frame_err,
	        mi2rx_end_frame,
		phy_rx_dv,
		cf2rx_max_pkt_sz,
	        cf2rx_rx_ch_en,
	        cf2rx_strp_pad_en,
	        cf2rx_snd_crc,
	        cf2df_dfl_single_rx,
		cf2rx_rcv_runt_pkt_en,
	        cf_macmode,
		mi2rx_crs,
		df2rx_dfl_dn,
		ap2rx_rx_fifo_err,
      //A200 change Port added for crs based flow control
      phy_crs
	       );

    input		app_reset_n;
    input        	phy_rx_clk;
    input               rx_reset_n;
    input		app_clk;
   input        scan_mode;
   
    output		rx_sts_vld;
    output [15:0]       rx_sts_bytes_rcvd;
    output              rx_sts_large_pkt;
    output              rx_sts_lengthfield_err;
    output              rx_sts_len_mismatch;
    output              rx_sts_crc_err;
    output              rx_sts_runt_pkt_rcvd;
    output              rx_sts_rx_overrun;
    output              rx_sts_frm_length_err;

    output              clr_rx_error_from_rx_fsm;
    input               rx_fifo_full;
    output		rx_dt_wrt;
    output [8:0]	rx_dt_out;
    output		rx_commit_wr;
    output 		commit_write_done;
    output		rx_rewind_wr;
    input               mi2rx_strt_rcv;
    input		mi2rx_rcv_vld;
    input [7:0]		mi2rx_rx_byte;
    input		mi2rx_end_rcv;
    input		mi2rx_extend;
    input		mi2rx_frame_err;
    input		mi2rx_end_frame;
    input		phy_rx_dv;
    input [15:0]        cf2rx_max_pkt_sz;
    input		cf2rx_rx_ch_en;
    input		cf2rx_strp_pad_en;
    input		cf2rx_snd_crc;
    input		cf2rx_rcv_runt_pkt_en;
    input		cf_macmode;
    input  [7:0]        cf2df_dfl_single_rx;
    input               ap2rx_rx_fifo_err;
    input               mi2rx_crs;
    output              df2rx_dfl_dn;

    //A200 change Port added for crs based flow control
    input            phy_crs;



    g_rx_fsm u_rx_fsm(
	      // Status information to Applications
	      .rx_sts_vld(rx_sts_vld),
	      .rx_sts_bytes_rcvd(rx_sts_bytes_rcvd),
	      .rx_sts_large_pkt(rx_sts_large_pkt),
	      .rx_sts_lengthfield_err(rx_sts_lengthfield_err),
	      .rx_sts_len_mismatch(rx_sts_len_mismatch),
	      .rx_sts_crc_err(rx_sts_crc_err),
	      .rx_sts_runt_pkt_rcvd(rx_sts_runt_pkt_rcvd),
	      .rx_sts_rx_overrun(rx_sts_rx_overrun),
	      .rx_sts_frm_length_err(rx_sts_frm_length_err),
	      // Data Signals to Fifo Management Block
	      .clr_rx_error_from_rx_fsm(clr_rx_error_from_rx_fsm),
	      .rx2ap_rx_fsm_wrt(rx_dt_wrt),
	      .rx2ap_rx_fsm_dt(rx_dt_out),
	      // Fifo Control Signal to Fifo Management Block
	      .rx2ap_commit_write(rx_commit_wr),
	      .rx2ap_rewind_write(rx_rewind_wr),
	      // To address filtering block
	      .commit_write_done(commit_write_done),      
             
	      // Global Signals 
	      .reset_n(rx_reset_n),	
	      .phy_rx_clk(phy_rx_clk),
	      // Signals from Mii/Rmii block for Receive data 
	      .mi2rx_strt_rcv(mi2rx_strt_rcv),
	      .mi2rx_rcv_vld(mi2rx_rcv_vld),
	      .mi2rx_rx_byte(mi2rx_rx_byte),
	      .mi2rx_end_rcv(mi2rx_end_rcv),
	      .mi2rx_extend(mi2rx_extend),
	      .mi2rx_end_frame(mi2rx_end_frame),
	      .mi2rx_frame_err(mi2rx_frame_err),
              // Rx fifo management signal to indicate overrun
	      .rx_fifo_full(rx_fifo_full),
	      .ap2rx_rx_fifo_err(ap2rx_rx_fifo_err),
              // Signal from CRC check block
	      .rc2rx_crc_ok(rc2rx_crc_ok),
	      // Signals from Address filtering block
              // Signals from Config Management Block
	      .cf2rx_max_pkt_sz(cf2rx_max_pkt_sz),
	      .cf2rx_rx_ch_en(cf2rx_rx_ch_en),
	      .cf2rx_strp_pad_en(cf2rx_strp_pad_en),
	      .cf2rx_snd_crc(cf2rx_snd_crc),
	      .cf2rx_rcv_runt_pkt_en(cf2rx_rcv_runt_pkt_en),
	      .cf2rx_gigabit_xfr(cf_macmode), 
         //A200 change Port added for crs based flow control
         .phy_crs(phy_crs)
	      );

 
  g_rx_crc32 u_rx_crc32 (
              // CRC Valid signal to rx_fsm
	      .rc2rf_crc_ok(rc2rx_crc_ok),
	      
	      // Global Signals
	      .phy_rx_clk(phy_rx_clk),
	      .reset_n(rx_reset_n),
              // CRC Data signals
	      .mi2rc_strt_rcv(mi2rx_strt_rcv),
	      .mi2rc_rcv_valid(mi2rx_rcv_vld),
	      .mi2rc_rx_byte(mi2rx_rx_byte)
	      );


  g_deferral_rx U_deferral_rx (
//0503 Changed .port names to match g_deferral_rx
	    .rx_dfl_dn(df2rx_dfl_dn),	
	    .dfl_single(cf2df_dfl_single_rx),
	    .rx_dv(phy_rx_dv),
//0504	    .phy_rx_er(phy_rx_er),
	    .rx_clk(phy_rx_clk),
	    .reset_n(rx_reset_n));

  endmodule
