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

/***************************************************************
  Description:
 
 tx_top.v: This module has the top level of the transmit block
 It instantiates the following blocks
 1. tx_fsm
 2. tx_crc
 3. tx_fifo_mgmt
 4. deferral
 5. backoff
 ***********************************************************************/
module g_tx_top(
      app_clk,
      set_fifo_undrn,
	      
   
		//Outputs
		//TX FIFO management
		tx_commit_read,
		tx_dt_rd,
		
		//MII interface
		tx2mi_strt_preamble,
		tx2mi_byte_valid,
		tx2mi_byte,
		tx2mi_end_transmit,
                tx_ch_en,            // MANDAR
		
		//Status to application
		tx_sts_vld,
		tx_sts_byte_cntr,
		tx_sts_fifo_underrun,
		
		
		//Inputs
		//MII interface
		phy_tx_en,
		phy_tx_er,
		
		//configuration
		cf2tx_ch_en,
		cf2df_dfl_single,
		cf2tx_pad_enable,
		cf2tx_append_fcs,
		cf_mac_mode,
		cf_mac_sa,
		cf2tx_force_bad_fcs,
		//FIFO data
		app_tx_dt_in,
		app_tx_fifo_empty,
		app_tx_rdy,
		
		//MII
		mi2tx_byte_ack,
		app_reset_n,
		tx_reset_n,
		tx_clk);
   input	      app_reset_n;            // Global app_reset for the MAC
   input              tx_reset_n;
   input 	      tx_clk;           // Transmit clock
   
   input [8:0] 	      app_tx_dt_in;
   input 	      app_tx_fifo_empty;
   input 	      app_tx_rdy;
   
   input 	      phy_tx_en;            // Transmit data Enable
   input 	      phy_tx_er;            // Transmit Error 
   input 	      cf2tx_ch_en;         // Transmit channel Enable
   input [7:0] cf2df_dfl_single;
   input       cf2tx_pad_enable;       // Padding Enabled
   input       cf2tx_append_fcs;       // Append CRC to packets
   input       cf2tx_force_bad_fcs;    // force bad fcs
   input [47:0] cf_mac_sa;              // MAC Source Address 
   input 	cf_mac_mode;       // Gigabit or 10/100

		
   
   input 	mi2tx_byte_ack;    // Transmit byte ack from RMII
   output 	tx_commit_read;
   output 	tx_dt_rd; //get the next fsm data
   
   
   output 	tx2mi_strt_preamble;   // Start preamble indicated to RMII
   output 	tx2mi_byte_valid;   // Byte valid from the Tx State Macine
   output [7:0] tx2mi_byte;  // Transmit byte to RMII
   output 	tx2mi_end_transmit;       // Transmit complete
   
   output 	tx_sts_vld;      //tx_sts is valid on valid tx_sts_vld
   output [15:0] tx_sts_byte_cntr;
   output 	 tx_sts_fifo_underrun;
   
   output 	tx_ch_en;   // MANDAR

   output        set_fifo_undrn;// Description: At GMII Interface ,
                                // abug after a transmit fifo underun was found.
                                // The packet after a packet that 
                                // underran has 1 too few bytes .

   input         app_clk;           // condor fix
   
   wire [31:0] 	 tc2tx_fcs;
   wire            set_fifo_undrn;// E3C fix
   
   
   
  
   
   // Instantiate Defferal block
   g_deferral U_deferral (
			  //Outputs
			  .df2tx_dfl_dn(df2tx_dfl_dn),
			  .cf2df_dfl_single(cf2df_dfl_single),
			  .phy_tx_en(phy_tx_en),
			  .phy_tx_er(phy_tx_er),
			  .tx_clk(tx_clk),
			  .app_reset_n(tx_reset_n));
   
  
   
   // Instantiate Transmit State machine block
   g_tx_fsm U_tx_fsm(
           .app_clk(app_clk), // condor fix
           .set_fifo_undrn(set_fifo_undrn), // E3C fix

	    //Outputs
	   .tx_commit_read(tx_commit_read),
	   .tx_dt_rd(tx_dt_rd),
	    //FCS block interface
	   .tx2tc_fcs_active(tx2tc_fcs_active),
	   .tx2tc_gen_crc(tx2tc_gen_crc),
	    //MII or RMII interface signals
	   .tx2mi_strt_preamble(tx2mi_strt_preamble),
	   .tx2mi_byte_valid(tx2mi_byte_valid),
	   .tx2mi_byte(tx2mi_byte),
	   .tx2mi_end_transmit(tx2mi_end_transmit),
	   .tx_ch_en(tx_ch_en),
           .phy_tx_en(phy_tx_en), // mfilardo.  for ofn auth fix.
	  //tx fifo management outputs
	   .tx_sts_vld(tx_sts_vld),
	   .tx_sts_byte_cntr(tx_sts_byte_cntr),		  
		     .tx_sts_fifo_underrun(tx_sts_fifo_underrun),
		     .app_tx_rdy(app_tx_rdy),
		     .tx_end_frame(app_tx_dt_in[8]),
		     .app_tx_dt_in(app_tx_dt_in[7:0]),
		     .app_tx_fifo_empty(app_tx_fifo_empty),
		     //dfl and back off
		     .df2tx_dfl_dn(df2tx_dfl_dn),
		     //inputs from FCS
		     .tc2tx_fcs(tc2tx_fcs),
		     .cf2tx_ch_en(cf2tx_ch_en),		  
		     .cf2tx_pad_enable(cf2tx_pad_enable),
		     .cf2tx_append_fcs(cf2tx_append_fcs),
		     .cf_mac_mode(cf_mac_mode),		  
		     .cf_mac_sa(cf_mac_sa),
		     .cf2tx_force_bad_fcs(cf2tx_force_bad_fcs),
		     //MII
		     .mi2tx_byte_ack(mi2tx_byte_ack),
		     .tx_clk(tx_clk),
		     .tx_reset_n(tx_reset_n),
		     .app_reset_n(app_reset_n));
   
   
   
   
   // Instantiate CRC 32 block for Transmit
   g_tx_crc32 U_tx_crc32 (
			  // List of outputs.
			  .tx_fcs (tc2tx_fcs),
			  // List of inputs
			  .gen_tx_crc(tx2tc_gen_crc),
			  .tx_reset_crc(tx2mi_strt_preamble),
			  .tx_data(tx2mi_byte),
			  .sclk(tx_clk),
			  .reset_n(tx_reset_n)
			  );
   
endmodule












