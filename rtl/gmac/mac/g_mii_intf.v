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
 
 mii_intf.v: This verilog file is reduced mii interface for ethenet
 The transmit state machine generates a condition to indicate 
 start transmit. This is done using strt_preamble. The transmit
 state machine upon detecting strt_preamble generates pre-amble
 and start of frame de-limiter and then starts accepting the data
 from the transmit block by asserting the transmit nibble ack.
 
 ***************************************************************/
/************** MODULE DECLARATION ****************************/
module g_mii_intf(
                  // Data and Control Signals to tx_fsm and rx_fsm
          mi2rx_strt_rcv,
          mi2rx_rcv_vld,
          mi2rx_rx_byte,
          mi2rx_end_rcv,
          mi2rx_extend,
          mi2rx_frame_err,
          mi2rx_end_frame,
          mi2rx_crs,
          mi2tx_byte_ack,
          mi2tx_slot_vld,
          cfg_uni_mac_mode_change,

          // Phy Signals 
          phy_tx_en,
          phy_tx_er,
          phy_txd,
          phy_tx_clk,
          phy_rx_clk,
	  tx_reset_n,
	  rx_reset_n,
          phy_rx_er,
          phy_rx_dv,
          phy_rxd,
          phy_crs,
          // rx_er fix.  need to fwd to mac wrapper, to drop rx_er pkts.  mfilardo.
	  rx_sts_rx_er_reg,

                  // Reset signal
          app_reset_n,

                  // Signals from Config Management
          cf2mi_loopback_en,
          cf2mi_rmii_en,
          cf_mac_mode,
	  cf_chk_rx_dfl,
          cf_silent_mode,

                  // Signal from Application to transmit JAM
          df2rx_dfl_dn,

                  // Inputs from Transmit FSM
          tx2mi_strt_preamble,
          tx2mi_end_transmit,
          tx2mi_tx_byte,
		  tx_ch_en
          );
 

parameter NO_GMII_PREAMBLE   = 5'b00111;
parameter NO_MII_PREAMBLE    = 5'b01111;
parameter NO_RMII_PREAMBLE   = 5'b11111;
parameter GMII_JAM_COUNT     = 5'b0011;
parameter MII_JAM_COUNT      = 5'b0111;
parameter RMII_JAM_COUNT     = 5'b1111;
 
  /******* INPUT & OUTPUT DECLARATIONS *************************/

  output      mi2rx_strt_rcv;     // This is generated by the MII block to indicate start 
                                  // of receive data.
  output      mi2rx_rcv_vld;      // This signal is asserted by MII on reception of valid
                                  // bytes to indicate to the RX block to accept data from PHY
  output[7:0] mi2rx_rx_byte;      // This the receive data from the PHY gathered as bytes 
  output      mi2rx_end_rcv;      // This signal is asserted with the last data assembled
  output      mi2rx_extend;       // This signal is asserted during carrier extension (Receive)
  output      mi2rx_frame_err;    // This signal is asserted during Dibit Error (In RMII Mode)
                                  // or Nibble Error in (MII Mode)
  output      mi2rx_end_frame;    // End of Frame 
  output      mi2rx_crs;          // CRS signal in rx_clk domain
  output      mi2tx_byte_ack;     // MII block acknowledges a byte during transmit
  output      mi2tx_slot_vld;     // MII block acknowledges valid slot during transmit // mfilardo
  
  output      phy_tx_en;          // Enable data on TX
  output      phy_tx_er;          // Transmit Error (Used in Carrier Extension in 1000 Mode)
  output[7:0] phy_txd;            // Transmit data on the line 

  input      phy_tx_clk;         // Transmit Clock in 10/100 Mb/s 
 
  output       rx_sts_rx_er_reg;  // rx_er fix.  need to fwd to mac wrapper, to drop rx_er pkts.  mfilardo.
  input       app_reset_n;          // reset from the application interface

  input       phy_rx_clk;         // Receive Clock in 10/100/1000 Mb/s 
  input       phy_rx_er;          // Receive Error. Used in Carrier Extension in 1000 Mode 
  input       phy_rx_dv;          // Receive Data Valid from the PHY 
  input[7:0]  phy_rxd;            // Receive Data 
  input       phy_crs;            // Carrier Sense from the line 

  input       tx_reset_n;
  input       rx_reset_n;


  input       cf2mi_loopback_en;           // loop back enable
  input       cf2mi_rmii_en;               // RMII Mode
  input       cf_mac_mode;                 // Mac Mode 0--> 10/100 Mode, 1--> 1000 Mode 
  input       cf_chk_rx_dfl;               // Check for Deferal 
  input       cf_silent_mode;              // PHY Inactive 
  input       df2rx_dfl_dn;                // Deferal Done in Rx Clock Domain 
  input       tx2mi_strt_preamble;         // Tx FSM indicates to MII to generate 
                                           // preamble on the line 
  input       tx2mi_end_transmit;          // This is provided by the TX block to 
                                           // indicate end of transmit
  input[7:0]  tx2mi_tx_byte;               // 8 bits of data from Tx block
  input       tx_ch_en;                    // Transmitt Enable 
  input       cfg_uni_mac_mode_change;

  /******* WIRE & REG DECLARATION FOR INPUT AND OUTPUTS ********/
  reg       phy_tx_en;
  reg       mi2tx_byte_ack;
  reg       mi2tx_slot_vld;
  reg [7:0] phy_txd;
  wire [7:0] mi2rx_rx_byte;
  reg [7:0] mi2rx_rx_byte_in;
  reg       mi2rx_extend;
  reg       mi2rx_extend_err;
  reg       mi2rx_strt_rcv;
  reg       mi2rx_end_rcv;
  reg       mi2rx_rcv_vld;
  reg       mi2rx_frame_err;

  /*** REG & WIRE DECLARATIONS FOR LOCAL SIGNALS ***************/

  reg [4:0]  tx_preamble_cnt_val;


  reg        strt_rcv_in;
  reg        end_rcv_in;
  reg        rx_dv_in;
  reg        rx_er_in;
  reg        rcv_valid_in;



  reg [7:0]  rxd_in;
  
  parameter  mii_rx_idle_st = 3'd0, mii_rx_pre_st = 3'd1,
             mii_rx_byte_st = 3'd2, mii_rx_end_st = 3'd3,
             mii_rx_dibit_st = 3'd4, mii_rx_nibble_st = 3'd5;

  reg [2:0]  mii_rx_nxt_st; 
  reg [2:0]  mii_rx_cur_st;
  
  parameter  mii_tx_idle_st =  4'd0, mii_tx_pre_st  =  4'd1,
             mii_tx_byte_st = 4'd2,  mii_tx_end_st = 4'd3,
             mii_tx_nibble_st = 4'd5,
	     mii_tx_nibble_end_st = 4'd6, mii_tx_dibit_st = 4'd7,
	     mii_tx_dibit_end_st = 4'd8;

  reg [3:0]  mii_tx_cur_st;
  reg [3:0]  mii_tx_nxt_st;
  
  wire       receive_detect;
  wire       pre_condition;
  wire       sfd_condition;
  wire       tx_en;
  wire       tx_er;
  wire [7:0] txd;
  wire       byte_boundary_rx, byte_boundary_tx;

  reg        tx_en_in;
  reg        tx_err_in;
  reg        tx_ext_in;
  reg        tx_pre_in;
  reg        tx_sfd_in;
  reg        tx_xfr_ack_in;
  reg        inc_preamble_cntr;
  reg        rst_preamble_cntr;
  reg [1:0]  tx_xfr_cnt, rx_xfr_cnt, tx_slot_xfr_cnt;
  reg        rx_dv;
  reg        rx_er;
  reg        rcv_err_in;
  reg	     mi2rx_end_frame_in;	

  reg [1:0]  tx_dibit_in;
  reg        mi2rx_extend_in, mi2rx_extend_err_in, mi2rx_end_frame;
  reg        crs_in;
  reg        phy_tx_er;

  wire       dibit_check_rx, dibit_check_tx;
  wire       nibble_check_rx, nibble_check_tx;
  wire       pre_condition_gmii, pre_condition_mii, pre_condition_rmii;
  wire       sfd_condition_gmii, sfd_condition_mii, sfd_condition_rmii;
  wire [3:0] tx_nibble_in;
  reg [7:0]  rxd;
  wire       receive_detect_pulse;
  reg        d_receive_detect;


  reg        lb_tx_en, lb_tx_er;
  reg        rx_dv_del;
  reg  [1:0] rxd_del;
  reg        rx_dfl_dn;
  reg        rx_dfl_dn_reg;


  /******** SEQUENTIAL LOGIC **********************************/

  // This logic generates appropriate receive data valid
  // in case of loop back 
  always @(tx_en or phy_rxd or txd or phy_rx_dv or tx_er or phy_crs
           or cf2mi_loopback_en or phy_tx_en or phy_rx_er or
	   cf2mi_rmii_en or cf_mac_mode)
    begin
      if(cf2mi_loopback_en)
        begin
          rx_dv_in = tx_en;
          rx_er_in = tx_er;
          rxd_in = txd;
          crs_in = (tx_en | tx_er) && cf_mac_mode;
        end // if (mii_loopback_en)
      else
        begin
          rx_dv_in = phy_rx_dv ;
          rx_er_in = phy_rx_er;
          rxd_in = phy_rxd;
	  // *** NOTE ****
	  // phy_crs should be a combination of crs and tx_en
	  // In Full Duplex tx_en determines deferral in half duplex
	  // crs determines deferral
          crs_in = (tx_en | tx_er);
        end // else: !if(mii_loopback_en)
    end


  // Following state machine is to detect start preamble and
  // transmit preamble and sfd and then the data.
  // This state machine also generates acknowledge to TX block
  // to allow the TX block to update its byte pointers
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        begin
          mii_tx_cur_st <= mii_tx_idle_st; 
        end
      else if (tx_ch_en)
        begin
          mii_tx_cur_st <= mii_tx_nxt_st; 
        end
      else 
        begin
          mii_tx_cur_st <= mii_tx_idle_st; 
        end
    end

  always @(mii_tx_cur_st or tx2mi_strt_preamble or tx2mi_end_transmit or cf_mac_mode 
           or cf2mi_rmii_en or tx_preamble_cnt_val or byte_boundary_tx  
	   or tx_xfr_cnt or receive_detect
	   or receive_detect_pulse or cfg_uni_mac_mode_change)
    begin
      
      mii_tx_nxt_st = mii_tx_cur_st;
      tx_en_in = 1'b0;
      tx_pre_in = 1'b0;
      tx_sfd_in = 1'b0;
      tx_err_in = 1'b0;
      tx_ext_in = 1'b0;
      inc_preamble_cntr = 1'b0;
      rst_preamble_cntr = 1'b0;
      tx_xfr_ack_in = 1'b0;
      
      casex(mii_tx_cur_st)       // synopsys parallel_case full_case
    
        mii_tx_idle_st:
	// wait from start from transmit state machine
          begin
            if(tx2mi_strt_preamble)
              begin
                inc_preamble_cntr = 1'b1;
                tx_en_in = 1'b1;
                tx_pre_in = 1'b1;
                mii_tx_nxt_st = mii_tx_pre_st;
              end
            else
              mii_tx_nxt_st = mii_tx_idle_st;
          end

        mii_tx_pre_st:
        // This state generates the preamble to be transmitted and
        // generates SFD before transitioning the data state
          begin
            if((tx_preamble_cnt_val == NO_GMII_PREAMBLE) && cf_mac_mode)
              begin
                tx_en_in = 1'b1;
                tx_sfd_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                rst_preamble_cntr = 1'b1;
                mii_tx_nxt_st = mii_tx_byte_st;
              end
            else if((tx_preamble_cnt_val == NO_MII_PREAMBLE) && !cf_mac_mode &&
	            !cf2mi_rmii_en)
              begin
                tx_en_in = 1'b1;
                tx_sfd_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                rst_preamble_cntr = 1'b1;
                mii_tx_nxt_st = mii_tx_nibble_st;
	      end
            else if((tx_preamble_cnt_val == NO_RMII_PREAMBLE) && !cf_mac_mode &&
	           cf2mi_rmii_en)
              begin
                tx_en_in = 1'b1;
                tx_sfd_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                rst_preamble_cntr = 1'b1;
                mii_tx_nxt_st = mii_tx_dibit_st;
	      end
            else
              begin
                inc_preamble_cntr = 1'b1;
                tx_en_in = 1'b1;
                tx_pre_in = 1'b1;
                mii_tx_nxt_st = mii_tx_pre_st;
              end
          end
     
        mii_tx_byte_st:
        // This state picks up a byte from the transmit block
        // before transmitting on the line
		  begin  
            if(tx2mi_end_transmit && byte_boundary_tx )
             	begin
              		tx_en_in = 1'b1;
              		tx_xfr_ack_in = 1'b0;
              		mii_tx_nxt_st = mii_tx_end_st;
             	end
				else if (!cf_mac_mode & cfg_uni_mac_mode_change)  // Mandar
             	begin
            		tx_en_in = 1'b1;
            		tx_xfr_ack_in = 1'b1;
            		mii_tx_nxt_st = mii_tx_nibble_st;
             	end
          	else
              	begin
               	tx_en_in = 1'b1;
               	tx_xfr_ack_in = 1'b1;
               	mii_tx_nxt_st = mii_tx_byte_st;
            	end
         end
			 
       /*mii_tx_byte_st:
        // This state picks up a byte from the transmit block
        // before transmitting on the line
          begin
            if(tx2mi_end_transmit && byte_boundary_tx )
              begin
                tx_en_in = 1'b1;
                tx_xfr_ack_in = 1'b0;
                mii_tx_nxt_st = mii_tx_end_st;
              end
            else
              begin
                tx_en_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                mii_tx_nxt_st = mii_tx_byte_st;
              end
          end*/
 
        mii_tx_end_st:
        // This state checks for the end of transfer 
        // and extend for carrier extension
          begin
            if(tx2mi_strt_preamble)
	      begin
                tx_en_in = 1'b1;
                tx_pre_in = 1'b1;
                mii_tx_nxt_st = mii_tx_pre_st;
	      end
            else
              begin
                tx_en_in = 1'b0;
                mii_tx_nxt_st = mii_tx_idle_st;
              end
          end

        /*mii_tx_nibble_st:
        // This state picks up a byte from the transmit block
        // before transmitting on the line
          begin
            if(tx2mi_end_transmit && !byte_boundary_tx )
              begin
                tx_en_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                mii_tx_nxt_st = mii_tx_nibble_end_st;
              end
            else
              begin
                tx_en_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                mii_tx_nxt_st = mii_tx_nibble_st;
              end
	  		end*/
		  
        mii_tx_nibble_st:                             // Mandar
        // This state picks up a byte from the transmit block
        // before transmitting on the line
					begin
            		if(tx2mi_end_transmit && !byte_boundary_tx )
              			begin
                			tx_en_in = 1'b1;
                			tx_xfr_ack_in = 1'b1;
                			mii_tx_nxt_st = mii_tx_nibble_end_st;
              			end
                 else if (cf_mac_mode & cfg_uni_mac_mode_change)  // Mandar
              			begin
                			tx_en_in = 1'b1;
                			tx_xfr_ack_in = 1'b1;
                        mii_tx_nxt_st = mii_tx_byte_st;
              			end
            		else
              			begin
                			tx_en_in = 1'b1;
                			tx_xfr_ack_in = 1'b1;
                			mii_tx_nxt_st = mii_tx_nibble_st;
              			end
					end		

        mii_tx_nibble_end_st:
        // This state checks for the end of transfer 
        // and extend for carrier extension
          begin
            if(tx2mi_strt_preamble)
	      begin
                tx_en_in = 1'b1;
                tx_pre_in = 1'b1;
                mii_tx_nxt_st = mii_tx_pre_st;
	      end
            else
              begin
                tx_en_in = 1'b0;
                mii_tx_nxt_st = mii_tx_idle_st;
              end
	  end

        mii_tx_dibit_st:
        // This state picks up a byte from the transmit block
        // before transmitting on the line
          begin
            if(tx2mi_end_transmit && (tx_xfr_cnt[0]) && (tx_xfr_cnt[1]) )
              begin
                tx_en_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                mii_tx_nxt_st = mii_tx_dibit_end_st;
              end
            else
              begin
                tx_en_in = 1'b1;
                tx_xfr_ack_in = 1'b1;
                mii_tx_nxt_st = mii_tx_dibit_st;
              end
	  end

        mii_tx_dibit_end_st:
        // This state checks for the end of transfer 
        // and extend for carrier extension
          begin
             if(tx2mi_strt_preamble)
	      begin
                tx_en_in = 1'b1;
                tx_pre_in = 1'b1;
                mii_tx_nxt_st = mii_tx_pre_st;
	      end
            else
              begin
                tx_en_in = 1'b1;
                mii_tx_nxt_st = mii_tx_idle_st;
              end
	  end
       endcase     
     end // end always 
  
  // All the data, enable and ack signals leaving this blocks are
  // registered tx_data and tx_en are outputs going to PHY tx_nibble_ack 
  // is indicating to the TX block of acceptance of data nibble
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        begin
	  lb_tx_en <= 1'b0;
	  lb_tx_er <= 1'b0;
          phy_tx_en <= 1'b0;
          phy_tx_er <= 1'b0;
	  mi2tx_byte_ack <= 1'b0;
	  mi2tx_slot_vld <= 1'b0;
        end
      else
        begin
	  lb_tx_en <= tx_en_in;
	  lb_tx_er <= tx_err_in;
          phy_tx_en <= (cf_silent_mode) ? 1'b0 : tx_en_in; 
          phy_tx_er <= (cf_silent_mode) ? 1'b0 : tx_err_in;
	  mi2tx_byte_ack <= (cf_mac_mode || (cf2mi_rmii_en && tx_xfr_cnt[1] && !tx_xfr_cnt[0]) || 
	                     (!cf2mi_rmii_en && nibble_check_tx)) ? tx_xfr_ack_in : 1'b0; 
	  mi2tx_slot_vld <= (cf_mac_mode || (cf2mi_rmii_en && tx_slot_xfr_cnt[1] && !tx_slot_xfr_cnt[0]) || 
	                     (!cf2mi_rmii_en && tx_slot_xfr_cnt[0] )) ? (tx_xfr_ack_in || inc_preamble_cntr) : 1'b0; 
        end
    end

  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        begin
          phy_txd[7:0] <= 8'b00000000;
	end
      else
	begin
	  if (cf_mac_mode) 
             phy_txd[7:0] <= (tx_pre_in) ? 8'b01010101 : ((tx_sfd_in) ? 
	                      8'b11010101 :  ((tx_ext_in) ? 8'b00001111: tx2mi_tx_byte));
	  else if (!cf_mac_mode && !cf2mi_rmii_en) 
             phy_txd[3:0] <= (tx_pre_in) ? 4'b0101 : ((tx_sfd_in) ? 
	                      4'b1101 : tx_nibble_in) ;
	  else if (!cf_mac_mode && cf2mi_rmii_en) 
             phy_txd[1:0] <= (tx_pre_in) ? 2'b01 : ((tx_sfd_in) ? 
	                      2'b11 : tx_dibit_in) ;
	end
    end
  assign receive_detect_pulse = receive_detect && !d_receive_detect;


  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        d_receive_detect <= 0;
      else 
        d_receive_detect <= receive_detect; 
    end
  // counter for the number transfers 
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        tx_xfr_cnt <= 2'd0;
      else if(tx2mi_strt_preamble)
        tx_xfr_cnt <= 2'd0;
      else if(tx_xfr_ack_in)
        tx_xfr_cnt <= tx_xfr_cnt + 1; 
    end

  // phy_tx_en_dly
  reg phy_tx_en_dly;
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        phy_tx_en_dly <= 1'd0;
      else
        phy_tx_en_dly <= phy_tx_en;
    end
   
   wire phy_tx_en_fall;
   assign phy_tx_en_fall = phy_tx_en_dly && !phy_tx_en;

  // counter for the number transfers  ... 
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        tx_slot_xfr_cnt <= 2'd0;
      else if(phy_tx_en_fall)
        tx_slot_xfr_cnt <= 2'd0;
      else if(inc_preamble_cntr || tx_xfr_ack_in)
        tx_slot_xfr_cnt <= tx_slot_xfr_cnt + 1; 
    end

  assign nibble_check_tx = tx_xfr_cnt[0];
  assign dibit_check_tx= tx_xfr_cnt[0] && tx_xfr_cnt[1];
  assign byte_boundary_tx = (cf_mac_mode) ? 1'b1: 
               ((!cf_mac_mode && !cf2mi_rmii_en) ? nibble_check_tx :  dibit_check_tx);
 
  assign tx_nibble_in = (tx_xfr_cnt[0]) ? tx2mi_tx_byte[3:0] : tx2mi_tx_byte[7:4];

/*  always @(tx_xfr_cnt or tx2mi_tx_byte or phy_tx_clk)
	begin
	  if (!tx_xfr_cnt[1] && !tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[1:0];
	  else if (!tx_xfr_cnt[1] && tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[3:2];
	  else if (tx_xfr_cnt[1] && !tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[5:4];
	  else if (tx_xfr_cnt[1] && tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[7:6];
	  else
	    tx_dibit_in <= tx2mi_tx_byte[1:0];
	end
*/
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
	tx_dibit_in <= 2'b0;
      else if(tx2mi_strt_preamble)
	tx_dibit_in <= 2'b0;
      else
	begin
	  if (!tx_xfr_cnt[1] && !tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[1:0];
	  else if (!tx_xfr_cnt[1] && tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[3:2];
	  else if (tx_xfr_cnt[1] && !tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[5:4];
	  else if (tx_xfr_cnt[1] && tx_xfr_cnt[0])
	    tx_dibit_in <= tx2mi_tx_byte[7:6];
	end
    end
  
  // counter for the number of preamble to be sent
  // before transmitting the sfd
  always @(posedge phy_tx_clk or negedge tx_reset_n)
    begin
      if(!tx_reset_n)
        tx_preamble_cnt_val <= 5'd0;
      else if(rst_preamble_cntr)
        tx_preamble_cnt_val <= 5'd0;
      else if(inc_preamble_cntr)
        tx_preamble_cnt_val <= tx_preamble_cnt_val + 1;
    end
  
  

    always @(posedge phy_rx_clk or negedge rx_reset_n)
      begin
        if(!rx_reset_n)
	  rx_dfl_dn_reg <= 1'b0;
	else if (df2rx_dfl_dn)
	  rx_dfl_dn_reg <= 1'b1;
	else 
	  begin
	    if (!phy_rx_dv && !phy_rx_er)
	      rx_dfl_dn_reg <= 1'b0;
	  end
      end

  assign mi2rx_rx_byte = mi2rx_rx_byte_in;
  //assign rxd = (!cf_mac_mode && cf2mi_rmii_en)? mi2rx_rx_byte : mi2rx_rx_byte_in;

  assign pre_condition_gmii = (!rxd[7] && rxd[6] && !rxd[5] && rxd[4] 
                               && !rxd[3] && rxd[2] && !rxd[1] && rxd[0] && rx_dv
			       && !(!rx_dfl_dn_reg && cf_chk_rx_dfl));

  assign pre_condition_mii = (!rxd[3] && rxd[2] && !rxd[1] && rxd[0] && rx_dv
		              && !(!rx_dfl_dn_reg && cf_chk_rx_dfl));

  assign pre_condition_rmii = (!rxd[1] && rxd[0] && rx_dv
                               && !rxd_del[1] && rxd_del[0] && rx_dv_del 
		               && !(!rx_dfl_dn_reg && cf_chk_rx_dfl));

  assign sfd_condition_gmii = (rxd[7] && rxd[6] && !rxd[5] && rxd[4] 
                               && !rxd[3] && rxd[2] && !rxd[1] && rxd[0] && rx_dv
			       && !(!rx_dfl_dn_reg && cf_chk_rx_dfl));

  assign sfd_condition_mii = (rxd[3] && rxd[2] && !rxd[1] && rxd[0] && rx_dv
		              && !(!rx_dfl_dn_reg && cf_chk_rx_dfl));

  assign sfd_condition_rmii = (rxd[1] && rxd[0] && rx_dv
                               && !rxd_del[1] && rxd_del[0] && rx_dv_del 
		               && !(!rx_dfl_dn_reg && cf_chk_rx_dfl));
  


  assign pre_condition = (cf_mac_mode) ? pre_condition_gmii : 
                         ((cf2mi_rmii_en) ? pre_condition_rmii : pre_condition_mii);

  assign sfd_condition = (cf_mac_mode) ? sfd_condition_gmii : 
                         ((cf2mi_rmii_en) ? sfd_condition_rmii : sfd_condition_mii);

  // Following state machine is to detect strt preamble and
  // receive preamble and sfd and then the data.
  always @(posedge phy_rx_clk or negedge rx_reset_n)
    begin
      if(!rx_reset_n)
        begin
          mii_rx_cur_st <= mii_rx_idle_st; 
	end
      else
        begin
          mii_rx_cur_st <= mii_rx_nxt_st; 
        end
    end

  always @(mii_rx_cur_st or rx_dv or rx_er or pre_condition or sfd_condition 
           or byte_boundary_rx or rxd or rx_xfr_cnt or cf2mi_rmii_en or cf_mac_mode)
    begin
      mii_rx_nxt_st = mii_rx_cur_st;
      strt_rcv_in = 1'b0;
      end_rcv_in = 1'b0;
      rcv_valid_in = 1'b0;
      rcv_err_in = 1'b0;
      mi2rx_extend_in = 1'b0;
      mi2rx_extend_err_in = 1'b0;
      mi2rx_end_frame_in = 1'b0;
      
      casex(mii_rx_cur_st)       // synopsys parallel_case full_case

        mii_rx_idle_st:
        // This state is waiting for pre-amble to
        // appear on the line in Receive mode
        begin
          if(pre_condition)
            mii_rx_nxt_st = mii_rx_pre_st;
          else
            mii_rx_nxt_st = mii_rx_idle_st;
        end
    
        mii_rx_pre_st:
        // This state checks the pre-amble and Waits for SFD on the line 
        begin
          if(sfd_condition)
            begin
              strt_rcv_in = 1'b1;
	      if(cf_mac_mode)
                mii_rx_nxt_st = mii_rx_byte_st;
	      else if(!cf_mac_mode && !cf2mi_rmii_en)
                mii_rx_nxt_st = mii_rx_nibble_st;
	      else if(!cf_mac_mode && cf2mi_rmii_en)
                mii_rx_nxt_st = mii_rx_dibit_st;
            end
          else if(pre_condition)
	    begin
              mii_rx_nxt_st = mii_rx_pre_st;
	    end
          else if(!rx_dv && rx_er && cf_mac_mode)
	    begin
	      mi2rx_extend_in = (rxd == 8'h0F) ? 1'b1: 1'b0;
	      mi2rx_extend_err_in = (rxd == 8'h1F) ? 1'b1: 1'b0;
              mii_rx_nxt_st = mii_rx_pre_st;
	    end
          else
            begin
	      mi2rx_end_frame_in = 1'b1;
              mii_rx_nxt_st = mii_rx_idle_st;
            end
        end
    
        mii_rx_byte_st:
        // This state looks for data validity and latches di-bit2 and
        // sends it to the receiver
        begin
          if(rx_dv)
            begin
              rcv_valid_in = 1'b1;
              mii_rx_nxt_st = mii_rx_byte_st;
            end
	  else if (!rx_dv && rx_er && cf_mac_mode)
            begin
	      mi2rx_extend_in = (rxd == 8'h0F) ? 1'b1: 1'b0;
	      mi2rx_extend_err_in = (rxd == 8'h1F) ? 1'b1: 1'b0;
              end_rcv_in = 1'b1;
              mii_rx_nxt_st = mii_rx_pre_st;
            end
          else
            begin
              end_rcv_in = 1'b1;
              mii_rx_nxt_st = mii_rx_end_st;
            end
        end

        mii_rx_end_st:
        // This state looks for data validity and latches di-bit2 and
        // sends it to the receiver
           mii_rx_nxt_st = mii_rx_idle_st;

        mii_rx_nibble_st:
        begin
          if(rx_dv)
            begin
              rcv_valid_in = 1'b1;
              mii_rx_nxt_st = mii_rx_nibble_st;
            end
          else
            begin
              end_rcv_in = 1'b1;
              mii_rx_nxt_st = mii_rx_end_st;
	      if(rx_xfr_cnt[0])
	        rcv_err_in = 1'b1;
            end
        end

        mii_rx_dibit_st:
        begin
          if(rx_dv)
            begin
              rcv_valid_in = 1'b1;
              mii_rx_nxt_st = mii_rx_dibit_st;
            end
          else
            begin
              end_rcv_in = 1'b1;
              mii_rx_nxt_st = mii_rx_end_st;
	      if(!(!rx_xfr_cnt[0] && !rx_xfr_cnt[1]))
	        rcv_err_in = 1'b1;
            end
        end

      endcase
    end // always @ (mii_rx_cur_st...
  
  // counter for the number receives 
  always @(posedge phy_rx_clk or negedge rx_reset_n)
    begin
      if(!rx_reset_n)
        rx_xfr_cnt <= 2'd0;
      else if(mi2rx_end_rcv)
        rx_xfr_cnt <= 2'd0; 
      else if(rcv_valid_in)
        rx_xfr_cnt <= rx_xfr_cnt + 1; 
    end

  always @(posedge phy_rx_clk or negedge rx_reset_n)
    begin
      if(!rx_reset_n)
        begin
	  mi2rx_rx_byte_in <= 8'b0;
	  rxd <= 8'b0;
	  rxd_del <= 2'b0;
	end
      else
	begin
	  rxd <= rxd_in;
//	  rxd_del <= rxd_in[1:0];
	  rxd_del <= rxd[1:0];

	  if (cf_mac_mode)
	    mi2rx_rx_byte_in <= rxd;
	  else if (!cf_mac_mode && !cf2mi_rmii_en)
	    begin
	      if(!rx_xfr_cnt[0])
	        mi2rx_rx_byte_in[3:0] <= rxd[3:0];
	      else
	        mi2rx_rx_byte_in[7:4] <= rxd[3:0];
	    end
	  else if(!cf_mac_mode && cf2mi_rmii_en)
	    begin
	      if(!rx_xfr_cnt[1] && !rx_xfr_cnt[0])
	        mi2rx_rx_byte_in[1:0] <= rxd[1:0];
	      else if(!rx_xfr_cnt[1] && rx_xfr_cnt[0])
	        mi2rx_rx_byte_in[3:2] <= rxd[1:0];
	      else if(rx_xfr_cnt[1] && !rx_xfr_cnt[0])
	        mi2rx_rx_byte_in[5:4] <= rxd[1:0];
	      else if(rx_xfr_cnt[1] && rx_xfr_cnt[0])
	        mi2rx_rx_byte_in[7:6] <= rxd[1:0];
	    end
	end
    end

  reg  rx_sts_rx_er_reg;
  always @(posedge phy_rx_clk or negedge rx_reset_n) begin
      if(!rx_reset_n) begin
	  rx_sts_rx_er_reg <= 1'b0;
      end
      else if (mi2rx_strt_rcv) begin
	  rx_sts_rx_er_reg <= 1'b0;
      end
      else if(phy_rx_dv && phy_rx_er) begin
	  rx_sts_rx_er_reg <= 1'b1;
      end
  end

  always @(posedge phy_rx_clk 
       or negedge rx_reset_n)
    begin
      if(!rx_reset_n)
        begin
          mi2rx_rcv_vld <= 1'b0;
	end
      else if(cf_mac_mode)
          mi2rx_rcv_vld <= rcv_valid_in;
      else if(!cf_mac_mode && cf2mi_rmii_en && rx_xfr_cnt[0] && rx_xfr_cnt[1])
          mi2rx_rcv_vld <= rcv_valid_in;
      else if(!cf_mac_mode && !cf2mi_rmii_en && rx_xfr_cnt[0])
          mi2rx_rcv_vld <= rcv_valid_in;
      else
          mi2rx_rcv_vld <= 1'b0;
    end
  // All the data, enable and ack signals out of RX block are
  // registered 
  always @(posedge phy_rx_clk or negedge rx_reset_n)
    begin
      if(!rx_reset_n)
        begin
          mi2rx_strt_rcv <= 1'b0;
          mi2rx_end_rcv <= 1'b0;
          //mi2rx_rcv_vld <= 1'b0;
          mi2rx_frame_err <= 1'b0;
          mi2rx_extend <= 1'b0;
          mi2rx_extend_err <= 1'b0;
	  mi2rx_end_frame <= 1'b0; 
	  rx_dv <= 1'b0;
	  rx_er <= 1'b0;
	  rx_dv_del <= 1'b0;
        end
      else
        begin
          mi2rx_strt_rcv <= strt_rcv_in;
          mi2rx_end_rcv <= end_rcv_in; 
          //mi2rx_rcv_vld <= rcv_valid_in;
          mi2rx_frame_err <= rcv_err_in;
          mi2rx_extend <= mi2rx_extend_in; 
          mi2rx_extend_err <= mi2rx_extend_err_in;
	  mi2rx_end_frame <= mi2rx_end_frame_in;
	  rx_dv <= rx_dv_in;
	  rx_er <= rx_er_in;
	  rx_dv_del <= rx_dv;
        end
    end



 half_dup_dble_reg U_dble_reg1 (
                 //outputs
                 .sync_out_pulse(receive_detect),
                 //inputs
                 .in_pulse(rx_dv_in),
                 .dest_clk(phy_tx_clk),
                 .reset_n(tx_reset_n)
             );


wire test;

 half_dup_dble_reg U_dble_reg5 (
                 //outputs
                 .sync_out_pulse(tx_en),
                 //inputs
                 .in_pulse(lb_tx_en),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );

 half_dup_dble_reg U_dble_reg6 (
                 //outputs
                 .sync_out_pulse(txd[0]),
                 //inputs
                 .in_pulse(phy_txd[0]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );

 half_dup_dble_reg U_dble_reg7 (
                 //outputs
                 .sync_out_pulse(txd[1]),
                 //inputs
                 .in_pulse(phy_txd[1]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );

 half_dup_dble_reg U_dble_reg8 (
                 //outputs
                 .sync_out_pulse(txd[2]),
                 //inputs
                 .in_pulse(phy_txd[2]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );

 half_dup_dble_reg U_dble_reg9 (
                 //outputs
                 .sync_out_pulse(txd[3]),
                 //inputs
                 .in_pulse(phy_txd[3]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );

 half_dup_dble_reg U_dble_reg10 (
                 //outputs
                 .sync_out_pulse(txd[4]),
                 //inputs
                 .in_pulse(phy_txd[4]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );


 half_dup_dble_reg U_dble_reg11 (
                 //outputs
                 .sync_out_pulse(txd[5]),
                 //inputs
                 .in_pulse(phy_txd[5]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );


 half_dup_dble_reg U_dble_reg12 (
                 //outputs
                 .sync_out_pulse(txd[6]),
                 //inputs
                 .in_pulse(phy_txd[6]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );


 half_dup_dble_reg U_dble_reg13 (
                 //outputs
                 .sync_out_pulse(txd[7]),
                 //inputs
                 .in_pulse(phy_txd[7]),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );


 half_dup_dble_reg U_dble_reg14 (
                 //outputs
                 .sync_out_pulse(tx_er),
                 //inputs
                 .in_pulse(lb_tx_er),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );


 half_dup_dble_reg U_dble_reg15 (
                 //outputs
                 .sync_out_pulse(mi2rx_crs),
                 //inputs
                 .in_pulse(crs_in),
                 .dest_clk(phy_rx_clk),
                 .reset_n(rx_reset_n)
             );

endmodule

