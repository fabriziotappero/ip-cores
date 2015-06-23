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
 
 tx_fsm.v: Frames are queued in TX FIFO, when the TX FIFO has enough
 data to sustain a 100Mb or 10 Mb transfer on the TX transmit is enabled.
 Each dword has 3 extra bits, which indicate the end of the frame and
 the number of valid bytes in the current dword.
 
 ***********************************************************************/


module g_tx_fsm (
		 //Outputs
		 //FIFO
		 tx_commit_read,
		 tx_dt_rd,
		 
		 //FCS
		 tx2tc_fcs_active,
		 tx2tc_gen_crc,
		 
		 //MII interface
		 tx2mi_strt_preamble,
		 tx2mi_byte_valid,
		 tx2mi_byte,
		 tx2mi_end_transmit,
		 phy_tx_en, 
                 tx_ch_en,  
		 
		 //Application
		 tx_sts_vld,
		 tx_sts_byte_cntr, 
		 tx_sts_fifo_underrun,
		 
		 //Inputs
		 //FIFO
		 app_tx_rdy,
		 tx_end_frame,
		 app_tx_dt_in,
		 app_tx_fifo_empty,
		 
		 //dfl and back
		 df2tx_dfl_dn,
		 
		 //FCS
		 tc2tx_fcs,
		 
		 //Configuration
		 cf2tx_ch_en,
		 cf2tx_pad_enable,
		 cf2tx_append_fcs,
		 cf_mac_mode,
		 cf_mac_sa,
		 cf2tx_force_bad_fcs,

                 app_clk, 
                 set_fifo_undrn, 
		 
		 //MII interface
		 mi2tx_byte_ack,
		 tx_clk,
		 tx_reset_n,
		 app_reset_n);
 

parameter CORE_MIN_FRAME_SIZE = 16'h40;  //64 bytes => 
// (12(add)+2(len)+46(pay) + 4CRC)*2
parameter CORE_MIN_FRAME_COL_SIZE = 16'h40;  //63 bytes => 
// tx_fsm lags MII by one byte
parameter CORE_PAYLOAD_SIZE = 16'h3C ; //60 bytes => 
// (12(add)+2(len)+46(pay))*2

 
  input	       cf2tx_ch_en;           //transmit enable application clock
  input        app_tx_rdy;            //tx fifo management, enough buffer to tx
  input        tx_end_frame;          //Current DWORD marks end of frame 
  input [7:0]  app_tx_dt_in;          //double word data from the TX fifo mgmt
  input        app_tx_fifo_empty;     //TX fifo is empty, if there were a data
                                      //data request when app_tx_fifo_empty is asserted
                                      //would result in FIFO underrun and error cond
  input [31:0] tc2tx_fcs;
  
  //defferral inputs
  input        df2tx_dfl_dn;          //IPG time between frames is satisfied
  
  //configuration inputs
  input        cf2tx_pad_enable;      //pad the TX frame if they are small
  input        cf2tx_append_fcs;      //on every TX, compute and append FCS, when
                                      //cf2tx_pad_enable and the current frame is small
                                      //FCS is computed and appended to the frame
                                      //irrespective of this signal
  input        cf_mac_mode;           // 1 is GMII 0 10/100
  input [47:0] cf_mac_sa;
  input        cf2tx_force_bad_fcs;
  input        mi2tx_byte_ack;        //MII interface accepted last byte
  input        tx_clk;
  input        tx_reset_n;
  input        app_reset_n;
  
  //tx fifo management outputs
  output       tx_commit_read;        //64 bytes have been transmitted successfully
  //hence advance the rd pointer
  output       tx_dt_rd;              //get net dword from the TX FIFO
  //FCS interface
  output       tx2tc_fcs_active;      //FCS being shipped to RMII or MII interface
  output       tx2tc_gen_crc;         //update the CRC with new byte
  
  
  //MII or RMII interface signals
  output       tx2mi_strt_preamble;   //ask RMII or MII interface to send preamable
  output       tx2mi_byte_valid;      //current byte to RMII or MII is valid
  output [7:0] tx2mi_byte;            //data to RMII and MII interface
  output       tx2mi_end_transmit;    //frame transfer done
  output       tx_sts_vld;            //tx status is valid
  output [15:0] tx_sts_byte_cntr;   
  output 	tx_sts_fifo_underrun;
  output 	tx_ch_en;   // MANDAR

  input 	phy_tx_en;   // mfilardo ofn auth fix.
  
  input 	app_clk; 
  output    set_fifo_undrn; // Description: At GMII Interface ,
                            // abug after a transmit fifo underun was found.
                            // The packet after a packet that 
                            // underran has 1 too few bytes .

  
  parameter 	mn_idle_st = 3'd0;
  parameter 	mn_snd_full_dup_frm_st = 3'd1;
  
  parameter 	fcs_idle_st = 0;
  parameter 	fcs_snd_st = 1;
  
  parameter 	dt_idle_st =      12'b000000000000;
  parameter 	dt_xfr_st =       12'b000000000001;
  parameter 	dt_pad_st =       12'b000000000010;
  parameter 	dt_fcs_st =       12'b000000000100;
  
   
  wire 		tx_commit_read; 
  wire 		tx_dt_rd;            //request TX FIFO for more data
  wire 		tx2tc_fcs_active;    //FCS is currently transmitted
  wire 		tx2tc_gen_crc;
  wire 		tx2mi_strt_preamble;
  wire 		tx2mi_end_transmit;
  wire [7:0] 	tx2mi_byte;
  wire 		tx2mi_byte_valid;
  wire          cfg_force_bad_fcs_pulse;
  reg [15:0] 	tx_sts_byte_cntr;
  reg 		tx_sts_fifo_underrun;
  
  
  reg [11:0] 	curr_dt_st, nxt_dt_st;
  reg 		tx_fcs_dn, tx_fcs_dn_reg; //FCS fsm on completion of appending FCS
  reg 		curr_fcs_st, nxt_fcs_st;  //FSM for  FCS
  reg 		fcs_active;               //FCS is currently transmitted
  
  reg 		init_fcs_select;          //initiliaze FCS mux select
  reg 		clr_bad_fcs;              //tx_reset the bad FCS requirement
  reg 		clr_pad_byte;             //clear the padded condition
  reg [2:0] 	fcs_mux_select;           //mux select for  FCS
  reg 		send_bad_fcs;             //registered send bad FCS requirement
  reg 		set_bad_fcs;              //set the above register
  reg [15:0] 	tx_byte_cntr;             //count the number of bytes xfr'ed
  reg 		tx_fsm_rd;                //request TX FIFO for more data
  reg 		tx_byte_valid;            //current byte to MII is valdi
  reg 		strt_fcs, strt_fcs_reg;   //data is done, send FCS
  reg 		frm_padded;               //current frame is padded
  
  
  reg 		set_pad_byte;             //send zero filled bytes
  reg 		e_tx_sts_vld;             //current packet is transferred
  reg 		tx_sts_vld;		  //02999
  reg 		strt_preamble;
  reg [7:0] 	tx_byte;
  reg [7:0] 	tx_fsm_dt_reg;
  reg 		tx_end_frame_reg;
  reg 		tx_lst_xfr_dt, tx_lst_xfr_fcs;
  reg 		commit_read; 
  reg 		set_max_retry_reached;
  reg 		gen_tx_crc;
  reg 		set_fifo_undrn, clr_fifo_undrn, fifo_undrn;
  reg 		commit_read_sent;
  reg 		clr_first_dfl, set_first_dfl;
  
  wire 		tx_lst_xfr;
  
  
  reg 		tx_lst_xfr_fcs_reg;
  wire [15:0] 	tx_byte_cntr_int;
   
  reg		cur_idle_st_del;

  reg           app_tx_rdy_dly;


  always @(posedge tx_clk or negedge tx_reset_n) begin
    if (!tx_reset_n) begin
      app_tx_rdy_dly <= 1'b0;
    end
    else begin
      app_tx_rdy_dly <= app_tx_rdy;
    end
  end



  assign 	tx_commit_read = commit_read;
  assign 	tx_dt_rd = tx_fsm_rd;
  assign 	tx2tc_fcs_active = fcs_active;
  assign 	tx2tc_gen_crc = gen_tx_crc;
  assign 	tx2mi_strt_preamble = strt_preamble;
  assign 	tx2mi_byte_valid = tx_byte_valid;
  assign 	tx2mi_byte = tx_byte;
  assign 	tx2mi_end_transmit = tx_lst_xfr;
  
  assign 	tx_lst_xfr = tx_lst_xfr_dt || tx_lst_xfr_fcs; 
  
//To take care of 1 less byte count when fcs is not appended.
   assign tx_byte_cntr_int = (curr_dt_st == dt_fcs_st)  ? tx_byte_cntr : tx_byte_cntr + 16'h1; 
   
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	begin
	  tx_sts_vld <= 1'b0;
	  tx_sts_byte_cntr <= 16'b0;	   
	  tx_sts_fifo_underrun <= 1'b0;
	end // if (!tx_reset_n)
      else
	begin
	  tx_sts_vld <= e_tx_sts_vld;
	  if (e_tx_sts_vld)
	    begin
	      tx_sts_byte_cntr <= tx_byte_cntr_int;
	      tx_sts_fifo_underrun <= fifo_undrn || set_fifo_undrn;
	    end
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  
  
  
  half_dup_dble_reg U_dble_reg2 (
			//outputs
			.sync_out_pulse(tx_ch_en),
			//inputs
			.in_pulse(cf2tx_ch_en),
			.dest_clk(tx_clk),
			.reset_n(tx_reset_n)
			);
  
  

  half_dup_dble_reg U_dble_reg4 (
			//outputs
			.sync_out_pulse(cfg_force_bad_fcs_pulse),
			//inputs
			.in_pulse(cf2tx_force_bad_fcs),
			.dest_clk(tx_clk),
			.reset_n(tx_reset_n)
			);
  
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	cur_idle_st_del <= 1'b1;
      else
        cur_idle_st_del <= (curr_dt_st==dt_idle_st);
    end

  //Data pump, this state machine gets triggered by TX FIFO
  //This FSM control's the MUX loging to channel the 32 bit
  //data to byte wide and also keeps track of the end of the
  //frame and the valid bytes for the last double word. tx_sts_vld
  //is generated by this fsm.
  //Collission handling, retry operations are done in this FSM.
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	curr_dt_st <= dt_idle_st;
      else if (tx_ch_en)
	curr_dt_st <= nxt_dt_st;
      else
	curr_dt_st <= dt_idle_st;
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  //combinatorial process
  //always @(curr_dt_st or mi2tx_byte_ack or app_tx_fifo_empty 
  always @(curr_dt_st or mi2tx_byte_ack or app_tx_fifo_empty
	   or tx_end_frame_reg or commit_read_sent
	   or tx_byte_cntr or tx_fcs_dn_reg or cf2tx_pad_enable or tx_ch_en
	   or df2tx_dfl_dn or app_tx_rdy
	   or strt_fcs_reg 
	   or tx_end_frame or tx_clk 
	   or cf2tx_append_fcs 
	   or app_tx_rdy_dly or cur_idle_st_del)
    begin
      nxt_dt_st = curr_dt_st;
      tx_fsm_rd = 0;
      tx_byte_valid = 0;
      set_bad_fcs = 0;
      strt_fcs = 0;
      set_pad_byte = 0;
      set_max_retry_reached = 0;
      e_tx_sts_vld = 0;
      commit_read = 0;
      strt_preamble = 0;
      tx_lst_xfr_dt = 0;
      clr_pad_byte = 0;
      set_fifo_undrn = 0;
      clr_fifo_undrn = 0;
      clr_first_dfl = 0;
      set_first_dfl = 0;
      case (curr_dt_st)
	dt_idle_st :
	  begin
	    //clear early state
	    clr_pad_byte = 1;
	    clr_fifo_undrn = 1;
	    clr_first_dfl = 1'b1;
	    //wait until there is enough data in the TX FIFO
	    //and tx_enabled and not waiting for pause period
	    //in the case of full duplex
	    if (tx_ch_en) //config, channel enable
	      begin
		       if (app_tx_rdy && df2tx_dfl_dn)
		       begin
		         tx_fsm_rd = 1;
		         nxt_dt_st = dt_xfr_st;
		         strt_preamble = 1;
		       end 
		       else
		           nxt_dt_st = dt_idle_st;
	      end // if (tx_ch_en)
	     else
	      nxt_dt_st = dt_idle_st;
	  end // case: dt_idle_st
	
	dt_xfr_st :
	  begin
	    tx_byte_valid = 1;
	    //compare the mux_select to max bytes to be transmitted
	    //on the last dword of the frame
	    if (mi2tx_byte_ack && (tx_end_frame_reg))
	      begin
		// If it is end of frame detection and the count
		// indicates that there is no need for padding then if
		// pad is enabled dont check for cf2tx_append_fcs and Append
		// the CRC with the data packet
		if ((tx_byte_cntr >= ( CORE_PAYLOAD_SIZE - 1)) && cf2tx_append_fcs)
		  begin
		    strt_fcs = 1;
		    nxt_dt_st = dt_fcs_st;
		  end // if (cf2tx_append_fcs)
		else
		  //ending the current transfer, check the frame size
		  //padding or FCS needs to be performed
		  if (tx_byte_cntr < ( CORE_PAYLOAD_SIZE - 1))
		    begin
		      //less than min frame size, check to see if
		      //padding can be done
		      if(cf2tx_pad_enable)
			begin
			  nxt_dt_st = dt_pad_st;
			end // if (cf2tx_pad_enable)
		      else
			begin
			  //if no padding, check to see if FCS needs
			  //to be computed
			  if (cf2tx_append_fcs)
			    begin
			      strt_fcs = 1;
			      nxt_dt_st = dt_fcs_st;
			    end // if (cf2tx_append_fcs)
			  else
			    //if no FCS, complete the transfer
			    begin 
			      e_tx_sts_vld = 1;
			      commit_read = 1;
			      nxt_dt_st = dt_idle_st;
			    end // else: !if(cf2tx_append_fcs)
			end // else: !if(cf2tx_pad_enable)
		    end // if (tx_byte_cntr < ( CORE_MIN_FRAME_SIZE - 1))
		  else
		    //minimmum frame sent, check to see if FCS needs to
		    //be computed else transfer is done
		    begin
		      if (cf2tx_append_fcs)
			begin
			  strt_fcs = 1;
			  nxt_dt_st = dt_fcs_st;
			end // if (cf2tx_append_fcs)
		      else
			begin
			  commit_read = !commit_read_sent;
			  e_tx_sts_vld = 1;
			  nxt_dt_st = dt_idle_st;
			end // else: !if(cf2tx_append_fcs)
		    end // else: !if(tx_byte_cntr < ( CORE_MIN_FRAME_SIZE - 1))
	      end 
	    else if (mi2tx_byte_ack)
	      begin
		//time to fetch the new dword
		//check to see if the fifo is empty
		//if it is then send the crc with last bit
		//inverted as bad CRC so that the destination
		//can throw away the frame
		if (app_tx_fifo_empty)
		  begin
		    //TX has encountered error, finish the current byte
		    //append wrong fcs
		    set_bad_fcs = 1;
		    strt_fcs = 1;
		    nxt_dt_st = dt_fcs_st;
		    set_fifo_undrn = 1;   
		  end // if (mi2tx_byte_ack && ((mux_select == 1) ||...
		tx_fsm_rd = 1; //just to set error, or
		//get next word
	      end // if (mi2tx_byte_ack && mux_selectl == 1)
	    //provide end of transfer to MII/RMII interface
	    //commit_read pointer
	    if (mi2tx_byte_ack )
	      commit_read = !commit_read_sent;
	    
	    if (tx_end_frame_reg)
	      begin
		if (tx_byte_cntr < (CORE_PAYLOAD_SIZE - 1))
		  begin
		    if(!cf2tx_pad_enable)
		      begin
			if (!cf2tx_append_fcs)
			  tx_lst_xfr_dt = 1;
		      end // if (!cf2tx_pad_enable)
		  end // if (tx_byte_cntr < (CORE_MIN_FRAME_SIZE - 1))
		else 
		  begin
		    if (!cf2tx_append_fcs)
		      tx_lst_xfr_dt = 1;
		  end
	      end // if ((mux_select == mux_max_select) && (tx_end_frame_reg))
	  end // case: dt_xfr_st
	
	dt_pad_st :
	  begin
	    //wait until the padded data is enough to satisfy
	    //the minimum packet size and then return to idle
	    tx_byte_valid = 1;
	    set_pad_byte = 1;
	    //check to see if the 48 bytes are sent and then move to the
	    //crc state
	    if (mi2tx_byte_ack && (tx_byte_cntr == CORE_PAYLOAD_SIZE - 1))
		begin
		  strt_fcs = 1;
		  nxt_dt_st = dt_fcs_st;
	     end // if (mi2tx_byte_ack && (tx_byte_cntr == CORE_PAYLOAD_SIZE - 1))
	  end // case: dt_pad_st
	
	dt_fcs_st :
	  begin
	    if (tx_fcs_dn_reg && !strt_fcs_reg)
	      //last byte of crc is transmitted to MII and
	      //a new set of CRC is not transmitted to MII (this
	      //could be because of JAM sequence)
	      begin
		 //In the case of MII, while in this state the
		 //MII interface will be transferring the last
		 //byte to the PHY. If a collision is seen in this
		 //state then do the appropriate
		 commit_read = !commit_read_sent;
		 nxt_dt_st = dt_idle_st;
		 e_tx_sts_vld = 1;
	      end // if (tx_fcs_dn)
	      else
	      begin
		nxt_dt_st = dt_fcs_st;
	      end // else: !if(tx_fcs_dn)
	  end // case: dt_fcs_st
	
	
	
	default :
	  begin
	    nxt_dt_st = dt_idle_st;
	  end
      endcase // case (curr_dt_st)
    end // always @ (curr_dt_st or )
 
  //counter to track the number of bytes transferred excluding
  //the preamble and SOF
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	begin
	  tx_byte_cntr <= 16'd0;
	end // if (!tx_reset_n)
      else
	begin
	  if (mi2tx_byte_ack)
	    begin
	      tx_byte_cntr <= tx_byte_cntr + 1;
	    end // if (mi2tx_byte_ack)
	  else if (strt_preamble)
	    begin
	      tx_byte_cntr <= 16'd0;
	    end // else: !if(mi2tx_byte_ack)
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)

// So, introduce strt_preamble_pls to compensate for delay.
  reg s_p_d1, s_p_d2, s_p_d3;
  wire strt_preamble_pls;
  always @(posedge tx_clk or negedge tx_reset_n) begin
    if (!tx_reset_n) begin
	   s_p_d1 <= 1'b0;
	   s_p_d2 <= 1'b0;
	   s_p_d3 <= 1'b0;
    end // if (!tx_reset_n)
    else begin
	   s_p_d1 <= strt_preamble;
	   s_p_d2 <= s_p_d1;
	   s_p_d3 <= s_p_d2;
    end
  end // always

  wire strt_preamble_prog;
  assign strt_preamble_pls = strt_preamble || s_p_d1 || s_p_d2 || s_p_d3;
  assign strt_preamble_prog = strt_preamble;
//ECO fix, part1 end

  //fsm to transmit the FCS
  //synchronous process
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	curr_fcs_st <= fcs_idle_st;
      else
	curr_fcs_st <= nxt_fcs_st;
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  //set bad fcs requirement
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	send_bad_fcs <= 0;
      else
	begin
	  //if (set_bad_fcs)
	  if (set_bad_fcs | cfg_force_bad_fcs_pulse)
	    send_bad_fcs <= 1;
	  else if (clr_bad_fcs)
	    send_bad_fcs <= 0;
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  //set the error condition flags
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	begin
	  fifo_undrn <= 0;
	end // if (!tx_reset_n)
      else
	begin
	  
	  if (set_fifo_undrn)
	    fifo_undrn <= 1;
	  else if (clr_fifo_undrn)
	    fifo_undrn <= 0;
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  //sync block for tx_fcs_dn
  
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	begin
	  strt_fcs_reg <= 0;
	  tx_fcs_dn_reg <= 0;
	  tx_lst_xfr_fcs_reg <= 0; //naveen 052799  
	end // if (!tx_reset_n)
      else
	begin
	  tx_fcs_dn_reg <= tx_fcs_dn;
	  strt_fcs_reg <= strt_fcs;
	  tx_lst_xfr_fcs_reg <= tx_lst_xfr_fcs; //naveen 052799	  
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  //combinatorial process
  //bad fcs or good fcs could have been requested, in either case
  //the 8 bytes have to be shifted out, in the case of bad fcs
  //the last bit of the last byte will up toggled.
  always @(curr_fcs_st or mi2tx_byte_ack or fcs_mux_select or
	   strt_fcs or strt_fcs_reg)
    begin
      nxt_fcs_st = curr_fcs_st;
      fcs_active = 0;
      init_fcs_select = 0;
      tx_fcs_dn = 0;
      clr_bad_fcs = 0;
      tx_lst_xfr_fcs = 0;
      case (curr_fcs_st)
	fcs_idle_st :
	  if (strt_fcs || strt_fcs_reg)
	    begin
	      nxt_fcs_st = fcs_snd_st;
	      init_fcs_select = 1;
	    end // if (strt_fcs)
	fcs_snd_st :
	  begin
	    fcs_active = 1;
	    if (fcs_mux_select == 3'd3)
	      tx_lst_xfr_fcs = 1;
	    if (mi2tx_byte_ack && fcs_mux_select == 3'd3)
	      begin
		tx_fcs_dn = 1;
		clr_bad_fcs = 1;
		nxt_fcs_st = fcs_idle_st;
	      end // if (mi2tx_byte_ack)
	  end // case: fcs_snd_st
	default :
	  begin
	    nxt_fcs_st = fcs_idle_st;
	  end
      endcase // case (curr_fcs_st)
    end // always @ (curr_fcs_st or)
  
  //fcs mux select counter
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	fcs_mux_select <= 3'd0;
      else
	begin
	  if (strt_fcs)
	    fcs_mux_select <= 3'd0;
	  else if (mi2tx_byte_ack)
	    fcs_mux_select <= fcs_mux_select  + 1 ;
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  //remmember if frame is padded
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	frm_padded <= 0;
      else
	begin
	  if (clr_pad_byte)
	    frm_padded <= 0;
	  else if (set_pad_byte)
	    frm_padded <= 1;
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  
  //register the TX fifo data on tx_fsm_rd and demux
  //it for byte access
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	begin
	  tx_fsm_dt_reg <= 8'd0;
	  tx_end_frame_reg <= 0;
	end // if (!tx_reset_n)
      else
	begin
	  if (tx_fsm_rd)
	    begin
	      tx_fsm_dt_reg <= app_tx_dt_in;
	      tx_end_frame_reg <= tx_end_frame;
	    end // if (tx_fsm_rd)
	  if (e_tx_sts_vld)
	    tx_end_frame_reg <= 0;
	end // else: !if(!tx_reset_n)
    end // always @ (posedge tx_clk or negedge tx_reset_n)
  
  
  //Data mux, is controlled either by the mux select from the
  //primary data flow or from the FCS mux select. When PAD
  //data option is used bytes of all zeros are transmitted
  always @(fcs_active or app_tx_dt_in or tc2tx_fcs
	   or send_bad_fcs or fcs_mux_select or 
	   set_pad_byte or tx_fsm_dt_reg  )
    begin
      if (!fcs_active && !set_pad_byte)
	    begin
	  //primary data flow
	       tx_byte = tx_fsm_dt_reg[7:0];
	    end // if (!fcs_active)
      else if (fcs_active)
	    begin
	  tx_byte = tc2tx_fcs[7:0];	  
	  case (fcs_mux_select)
	    3'd0 :
	      tx_byte = tc2tx_fcs[7:0];
	    3'd1 :
	      tx_byte = tc2tx_fcs[15:8];
	    3'd2 :
	      tx_byte = tc2tx_fcs[23:16];
	    default :
	      begin
		if (send_bad_fcs)
		  tx_byte = {!tc2tx_fcs[31], tc2tx_fcs[30:24]};
		else
		  tx_byte = tc2tx_fcs[31:24];
	      end // case: 3'd7
	  endcase // case (mux_select)
	end // else: !if(!fcs_active)
      else if (set_pad_byte)
	tx_byte = 8'd0;
      else
	tx_byte = 8'd0;
    end // always @ (fcs_active or app_tx_dt_in or tc2tx_fcs or mux_select...
  
  //generate fcs computation enable. One cycle after the
  //strt_preamble the tx_byte is stable and a cycle after the
  //mi2tx_byte_ack also a new byte is stable
  always @(posedge tx_clk or negedge tx_reset_n)
    begin
      if (!tx_reset_n)
	gen_tx_crc <= 1'b0;
      else
	begin
	  if (fcs_active || strt_fcs)
	    gen_tx_crc <= 1'b0;
	  else
	    gen_tx_crc <= strt_preamble || mi2tx_byte_ack;
	end // else: !if(!tx_reset_n)
    end // always (posedge tx_clk or negedge tx_reset_n)
  
  
endmodule // tx_fsm
