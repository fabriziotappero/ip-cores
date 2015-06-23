//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

//`include "technology.h"
`include "oc_mac.h"
`default_nettype none
module oc_mac (
		input wire		res_n,
		input wire 		clk,
		input wire		tx_start,
		input wire [63:0]	tx_data,
		input wire [7:0]	tx_data_valid,
		input wire [63:0]	xgmii_rxd,
		input wire [7:0]	xgmii_rxc,

		output wire		tx_ack,
		output wire		rx_bad_frame,
		output wire		rx_good_frame,
		output wire [63:0]	rx_data,
		output wire [7:0]	rx_data_valid,
		output wire [7:0]	xgmii_txc,
		output wire[63:0]	xgmii_txd
	);

wire [1:0]	local_fault_msg_det;
wire [1:0]	remote_fault_msg_det;
wire		status_fragment_error_tog;
wire		status_pause_frame_rx_tog;


wire [63:0]	txdfifo_wdata;
wire [7:0]	txdfifo_wstatus;

wire [63:0]	xgmii_data_in;
wire [7:0]	xgmii_data_status;


rx_enqueue rx_eq0(
                  // Outputs
		.xgmii_data_in		(xgmii_data_in),
		.xgmii_data_status	(xgmii_data_status),
		.local_fault_msg_det  (local_fault_msg_det),
		.remote_fault_msg_det (remote_fault_msg_det),
		.status_fragment_error_tog(status_fragment_error_tog),
		.status_pause_frame_rx_tog(status_pause_frame_rx_tog),
		// Inputs
		.clk         		(clk),
		.res_n    		(res_n),
		.xgmii_rxd		(xgmii_rxd),
		.xgmii_rxc		(xgmii_rxc));


rx_control rx_ctrl(
                  // Outputs
		.rx_data		(rx_data),
		.rx_data_valid		(rx_data_valid),
		.rx_good_frame		(rx_good_frame),
		.rx_bad_frame		(rx_bad_frame),
		//.status_rxdfifo_udflow_tog(status_rxdfifo_udflow_tog),
		// Inputs
		.clk	 		(clk),
		.res_n			(res_n),
		.rx_inc_data		(xgmii_data_in),
		.rx_inc_status		(xgmii_data_status));


tx_dequeue tx_dq0(
                  // Outputs
		.xgmii_txd            	(xgmii_txd),
		.xgmii_txc            	(xgmii_txc),
		// Inputs
		.clk	         	(clk),
		.res_n		     	(res_n),
		.txdfifo_rdata        	(txdfifo_wdata),
		.txdfifo_rstatus      	(txdfifo_wstatus));

tx_control tx_ctrl(
		// Outputs

		.txdfifo_wdata		(txdfifo_wdata),
		.txdfifo_wstatus	(txdfifo_wstatus),
		.tx_ack			(tx_ack),

		.clk			(clk),
		.res_n			(res_n),
		.tx_start		(tx_start),
		.tx_data		(tx_data),
		.tx_data_valid		(tx_data_valid));
		


endmodule
`default_nettype wire
