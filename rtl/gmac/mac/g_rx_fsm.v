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
/***************************************************************
 Description:
 
 rx_fsm.v: This verilog file is the receive state machine for the MAC
 block. It receives nibbles from rmii block. It assembles
 double words from bytes. Generates writes to Receive FIFO
 Removes padding and generates appropriate signals to the
 CRC and Address Filtering block. It also generates the necessary
 signals to generate status for every frame.
 
 ***************************************************************/
/************** MODULE DECLARATION ****************************/
//`timescale 1ns/100ps
module g_rx_fsm(
		// Status information to Applications
		rx_sts_vld,
		rx_sts_bytes_rcvd,		
		rx_sts_large_pkt,
		rx_sts_lengthfield_err,
		rx_sts_crc_err,
		rx_sts_runt_pkt_rcvd,
		rx_sts_rx_overrun,
		rx_sts_frm_length_err,
		rx_sts_len_mismatch,
		// Data Signals to Fifo Management Block
		clr_rx_error_from_rx_fsm,
		rx2ap_rx_fsm_wrt,
		rx2ap_rx_fsm_dt,
		// Fifo Control Signal to Fifo Management Block
		rx2ap_commit_write,
		rx2ap_rewind_write,
		// To address filtering block
		//commit
		commit_write_done,
		
		// Global Signals 
		reset_n,	
		phy_rx_clk,
		// Signals from Mii/Rmii block for Receive data 
		mi2rx_strt_rcv,
		mi2rx_rcv_vld,
		mi2rx_rx_byte,
		mi2rx_end_rcv,
		mi2rx_extend,
		mi2rx_frame_err,
		mi2rx_end_frame,
		// Rx fifo management signal to indicate overrun
	        rx_fifo_full,
		ap2rx_rx_fifo_err,
		// Signal from CRC check block
		rc2rx_crc_ok,
		// Signals from Config Management Block
		cf2rx_max_pkt_sz,
		cf2rx_rx_ch_en,
		cf2rx_strp_pad_en,
		cf2rx_snd_crc,
		cf2rx_rcv_runt_pkt_en,
		cf2rx_gigabit_xfr,
      //A200 change Port added for crs based flow control
      phy_crs
      
		);

  
parameter MIN_FRM_SIZE = 6'h2e	      ;
  /******* INPUT & OUTPUT DECLARATIONS *************************/
  output	rx_sts_vld;                    // Receive status is available for the application
  output [15:0] rx_sts_bytes_rcvd;
  output 	rx_sts_large_pkt;
  output        rx_sts_lengthfield_err;
  output        rx_sts_crc_err;
  output        rx_sts_runt_pkt_rcvd;
  output        rx_sts_rx_overrun;
  output        rx_sts_frm_length_err;
  output        rx_sts_len_mismatch;

  output 	rx2ap_rx_fsm_wrt;              // Receive Fifo Write
  output [8:0] 	rx2ap_rx_fsm_dt;               // This is 32 bit assembled receive data 
                                               // with EOP and valid bytes information in it.
  output 	rx2ap_commit_write;            // This is to RX fifo MGMT to indicate 
                                               // that the current packet 
                                               // has to be sent to application
  output 	rx2ap_rewind_write;            // This indicates the previous packet 
                                               // in the FIFO has a error
                                               // Ignore the packet and restart from the
                                               // end of previous packet
  output    clr_rx_error_from_rx_fsm;  
  output    commit_write_done;

  input 	reset_n;	                       // reset from mac application interface
  input 	phy_rx_clk;                    // Reference clock used for RX 
  
  input 	mi2rx_strt_rcv;                // Receive data from the PHY
  input 	mi2rx_rcv_vld;                 // Received nibble is valid
  input [7:0] 	mi2rx_rx_byte;                 // Rx nibble from the RMII/MII block
  input 	mi2rx_end_rcv;                 // This is provided by the RMII/MII 
                                               // block to indicate
                                               // end of receieve
  input 	mi2rx_frame_err;
  input 	mi2rx_end_frame;
  input  	rx_fifo_full;
  input 	ap2rx_rx_fifo_err;             // Receive error generated by the 
                                               // RX FIFO MGMT block
  
  input 	rc2rx_crc_ok;                  // CRC of the receiving packet is OK. 
                                               // Generated by CRC block
  
  input [15:0]  cf2rx_max_pkt_sz;              // max packet size
  
  input 	cf2rx_rx_ch_en;                // Receive Enabled
  input 	cf2rx_strp_pad_en;             // Do not Append padding after the data
  input 	cf2rx_snd_crc;                 // Append CRC to the data 
                                               // ( This automatically means padding
                                               // will be enabled)
  input 	cf2rx_rcv_runt_pkt_en;         // Receive needs to receive
  input 	cf2rx_gigabit_xfr;
  input 	mi2rx_extend;

  //A200 change Port added for crs based flow control
  input  phy_crs;
  
  
  /******* WIRE & REG DECLARATION FOR INPUT AND OUTPUTS ********/
  reg 		rx2ap_commit_write;
  reg 		rx2ap_rewind_write;
  reg [8:0] 	rx2ap_rx_fsm_dt;
  reg 		rx2ap_rx_fsm_wrt;
  wire [31:0] 	rx_sts_dt;
  reg [31:0] 	rx_sts;

  /*** REG & WIRE DECLARATIONS FOR LOCAL SIGNALS ***************/
  reg 		commit_write;
  reg 		rewind_write;
  wire 		look_at_length_field;
  reg 		send_crc;
  reg 		rcv_pad_data;
  reg 		first_dword;
  wire [15:0] 	inc_rcv_byte_count;
  reg [15:0] 	rcv_byte_count;
  reg 		reset_tmp_count;
  reg 		ld_length_byte_1,ld_length_byte_2;
  reg 		set_crc_error;
  reg 		set_byte_allgn_error;
  reg 		rx_sts_vld,e_rx_sts_vld;
  reg 		padding_needed;
  reg 		dec_data_len;
  reg 		dec_pad_len;
  reg 		gen_eop;
  reg 		set_frm_lngth_error;
  reg 		set_incomplete_frm;
  reg 		byte_boundary;
  reg 		error;
  reg 		error_seen;
  reg 		commit_write_done;
  reg 		check_padding;
  reg 		check_padding_in;
  reg [2:0] 	padding_len_reg;
  reg [15:0] 	rcv_length_reg;
  reg [15:0] 	length_counter;
  
  reg [18:0] 	rx_fsm_cur_st;
  reg [18:0] 	rx_fsm_nxt_st;
  reg 		crc_stat_reg;
  reg 		rx_runt_pkt_reg;
  reg 		large_pkt_reg;
  reg 		rx_fifo_overrun_reg;
  reg 		frm_length_err_reg;
  reg [2:0] 	crc_count;
  reg 		inc_shift_counter;
  reg 		send_data_to_fifo;
  wire 		send_runt_packet;
  reg [2:0] 	shift_counter;
  reg [2:0] 	bytes_to_fifo;
  reg [7:0] 	buf_latch4,buf_latch3,buf_latch2,buf_latch1,buf_latch0;
  wire 		ld_buf,ld_buf1,ld_buf2,ld_buf3,ld_buf4;
  reg 		lengthfield_error;
  reg 		lengthfield_err_reg;
  reg 		addr_stat_chk;
  reg           clr_rx_error_from_rx_fsm;
  
  wire [15:0]    adj_rcv_length_reg;
  wire [15:0]    adj_rcv_byte_count;
  wire [15:0]    adj_cf2rx_max_pkt_sz;
  reg            set_tag1_flag, set_tag2_flag;
  
  parameter 	rx_fsm_idle_st=               19'b0000000000000000000,
		rx_fsm_chkdestad_nib1_st =    19'b0000000000000000001,
		rx_fsm_lk4srcad_nib1_st =     19'b0000000000000000010,
		rx_fsm_lk4len_byte1_st =      19'b0000000000000000100,
		rx_fsm_lk4len_byte2_st =      19'b0000000000000001000,
		rx_fsm_getdt_nib1_st =        19'b0000000000000010000,
		rx_fsm_getpaddt_nib1_st =     19'b0000000000000100000,
		rx_fsm_updstat_st =           19'b0000000000001000000,
		rx_fsm_chkval_st =            19'b0000000000010000000,
		rx_fsm_extend_st =    	      19'b0000000100000000000;
  
  /***************** WIRE ASSIGNMENTS *************************/
  wire [6:0] 	dec_pad_length;
  wire [15:0] 	inc_length_counter;
  wire 		rx_overrun_error;
  wire          commit_condition;

//COMMIT_WRITE CONDITION
assign commit_condition = ((inc_rcv_byte_count[14:0] == 15'd65)&& !commit_write_done );



  /******** SEQUENTIAL LOGIC **********************************/
  half_dup_dble_reg U_dble_reg1 (
			//outputs
			.sync_out_pulse(rx_ch_en),
			//inputs
			.in_pulse(cf2rx_rx_ch_en),
			.dest_clk(phy_rx_clk),
			.reset_n(reset_n)
			);
  
  // ap2rx_rx_fifo_err signal is generated in rx_clk domain
  assign 	rx_overrun_error = ap2rx_rx_fifo_err;
  
  reg 		rx_sts_vld_delayed;
  always @(posedge phy_rx_clk 
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  rx_sts <= 32'b0;
	  rx_sts_vld <= 1'b0;
          rx_sts_vld_delayed <= 1'b0;
	end
      else
	begin
	  rx_sts_vld <= rx_sts_vld_delayed;
	  rx_sts_vld_delayed <= e_rx_sts_vld;
	  if (e_rx_sts_vld)  
	    rx_sts <= rx_sts_dt;
	end
    end
  
  always @(posedge phy_rx_clk 
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  rx_fsm_cur_st <= rx_fsm_idle_st;
	  check_padding <= 1'b0;
	end
      else
	begin
	  rx_fsm_cur_st <= rx_fsm_nxt_st;
	  check_padding <= check_padding_in;
	end
    end
  reg first_byte_seen; 
  
  
  always @(posedge phy_rx_clk 
	   or negedge reset_n)      
      if(!reset_n)
	first_byte_seen <= 1'b0;
      else if(mi2rx_strt_rcv)
	first_byte_seen <= 1'b1;
      else if(mi2rx_rcv_vld)
	first_byte_seen <= 1'b0;
  


// adjust rcv_length reg for packet sizes < 64 bytes
assign adj_rcv_length_reg =   (rcv_length_reg < 8'h2E) ? 8'h2E : rcv_length_reg;

// subtr 18 bytes (sa + da + fcs + t/l)
assign adj_rcv_byte_count = rcv_byte_count - 8'd18;

// configured max packet size should be 16'd1518.
assign adj_cf2rx_max_pkt_sz = cf2rx_max_pkt_sz;


 
  // Following state machine is to receive nibbles from the RMII/MII
  // block and packetize them to 32 bits with information of EOP and 
  // valid bytes. It also discards packets which are less than minimum
  // frame size. It performs Address validity and Data validity.
  always @(rx_fsm_cur_st or mi2rx_strt_rcv or rx_ch_en or cf2rx_strp_pad_en 
	   or cf2rx_snd_crc or look_at_length_field 
	   or mi2rx_rcv_vld or first_dword or rc2rx_crc_ok  
	   or mi2rx_end_rcv or mi2rx_rx_byte or mi2rx_extend
	   or inc_length_counter or rcv_length_reg or commit_write_done
	   or crc_count or shift_counter or bytes_to_fifo
	    or cf2rx_rcv_runt_pkt_en 
	   or inc_rcv_byte_count or send_runt_packet
	   or rcv_byte_count or first_dword 
	   or commit_condition or rx_fifo_full or ap2rx_rx_fifo_err )
    begin
      rx_fsm_nxt_st = rx_fsm_cur_st;
      set_tag1_flag = 1'b0;
      set_tag2_flag = 1'b0;
      reset_tmp_count = 1'b0;
      ld_length_byte_1 = 1'b0;
      ld_length_byte_2 = 1'b0;
      dec_data_len = 1'b0;
      dec_pad_len = 1'b0;
      commit_write = 1'b0;
      rewind_write = 1'b0;
      e_rx_sts_vld = 1'b0;
      set_crc_error = 1'b0;
      check_padding_in = 1'b0;
      set_byte_allgn_error = 1'b0;
      set_incomplete_frm = 1'b0;
      set_frm_lngth_error = 1'b0;
      gen_eop = 1'b0;
      error = 1'b0;
      byte_boundary= 1'b0;
      send_crc = 1'b0;
      rcv_pad_data = 1'b0;
      inc_shift_counter = 1'b0;
      send_data_to_fifo = 1'b0;
      lengthfield_error = 1'b0;
      addr_stat_chk = 1'b0;
      clr_rx_error_from_rx_fsm = 1'b0;


      case(rx_fsm_cur_st)       
	rx_fsm_idle_st:
	  // Waiting for packet from mii block
	  // Continues accepting data only if
	  // receive has been enabled
	  begin
	    if(ap2rx_rx_fifo_err)
		begin
		   clr_rx_error_from_rx_fsm = 1'b1;
                   rx_fsm_nxt_st = rx_fsm_idle_st;
		end
	    else if (rx_fifo_full)
	      rx_fsm_nxt_st = rx_fsm_idle_st;
	    else if(mi2rx_strt_rcv && rx_ch_en )
	      rx_fsm_nxt_st = rx_fsm_chkdestad_nib1_st;
	    else
	      rx_fsm_nxt_st = rx_fsm_idle_st;
	  end
	
	rx_fsm_chkdestad_nib1_st:
	  begin
	    // collecting the nibbles of destination
	    // address
	    if(ap2rx_rx_fifo_err)
	      begin
		rewind_write = 1'b1;
		rx_fsm_nxt_st = rx_fsm_idle_st;
	      end
	    else if(mi2rx_end_rcv)
	      begin
		if(cf2rx_rcv_runt_pkt_en)
		  begin
		    rx_fsm_nxt_st = rx_fsm_chkval_st;
		    commit_write = 1'b1;
		  end
		else
		  begin
		    rx_fsm_nxt_st = rx_fsm_idle_st;
		    if (rcv_byte_count[2:0] > 5)
		      rewind_write = 1'b1;
		  end
	      end // if (mi2rx_end_rcv)

	    else if(mi2rx_rcv_vld && inc_rcv_byte_count[14:0] == 15'd6)
	      begin
		       rx_fsm_nxt_st = rx_fsm_lk4srcad_nib1_st;
	      end
	    else
	      begin
		rx_fsm_nxt_st = rx_fsm_chkdestad_nib1_st;
	      end
	  end
	
	rx_fsm_lk4srcad_nib1_st:
	  // collecting nibbles of source address
	  // in case of termination of packet
	  // or carrier sense error then generate eop
	  // and generate status
	  begin
	    if(ap2rx_rx_fifo_err )
	      begin
		rewind_write = 1;
		rx_fsm_nxt_st = rx_fsm_idle_st;
	      end // else: !if(mi2rx_end_rcv)
	    else if(mi2rx_end_rcv)
	      begin
		if(cf2rx_rcv_runt_pkt_en)
		  begin
		    rx_fsm_nxt_st = rx_fsm_chkval_st;
		    commit_write = 1'b1;
		  end
		else
		  begin
		    rx_fsm_nxt_st = rx_fsm_idle_st;
		    rewind_write = 1'b1;
		  end
	      end
	    else if(mi2rx_rcv_vld && inc_rcv_byte_count[14:0] == 15'd12)
	      begin
	          rx_fsm_nxt_st = rx_fsm_lk4len_byte1_st;
	      end
	    else
	      begin
		rx_fsm_nxt_st = rx_fsm_lk4srcad_nib1_st;
	      end
	  end
	
	rx_fsm_lk4len_byte1_st:
	  // this state collects the odd nibbles of the length 
	  // field. 
	  begin
	    if(ap2rx_rx_fifo_err) 
	      begin
		rewind_write = 1;
		rx_fsm_nxt_st = rx_fsm_idle_st;
	      end // else: !if(mi2rx_end_rcv)
	    else if(mi2rx_end_rcv)
	      begin
		if(cf2rx_rcv_runt_pkt_en)
		  begin
		    rx_fsm_nxt_st = rx_fsm_chkval_st;
		    commit_write = 1'b1;
		  end
		else
		  begin
		    rx_fsm_nxt_st = rx_fsm_idle_st;
		    rewind_write = 1'b1;
		  end
	      end
	    else if(mi2rx_rcv_vld)
	      begin
		ld_length_byte_1 = 1'b1;
		rx_fsm_nxt_st = rx_fsm_lk4len_byte2_st;
	      end
	    else
	      rx_fsm_nxt_st = rx_fsm_lk4len_byte1_st;
	  end
	
	rx_fsm_lk4len_byte2_st:
	  // This state generates the even nibbles of the length
	  // field
	begin
	   if(ap2rx_rx_fifo_err )
	   begin
	      rewind_write = 1;
	      rx_fsm_nxt_st = rx_fsm_idle_st;
	   end // else: !if(mi2rx_end_rcv)
	   else if(mi2rx_end_rcv)
	   begin
	      if(cf2rx_rcv_runt_pkt_en)
	      begin
		 rx_fsm_nxt_st = rx_fsm_chkval_st;
		 commit_write = 1'b1;
	      end
	      else
	      begin
		 rx_fsm_nxt_st = rx_fsm_idle_st;
		 rewind_write = 1'b1;
	      end
	   end
	   else if(mi2rx_rcv_vld )
	   begin
	      ld_length_byte_2 = 1'b1;
	      check_padding_in = 1'b1;
	      rx_fsm_nxt_st = rx_fsm_getdt_nib1_st;
	   end
	   else
	        rx_fsm_nxt_st = rx_fsm_lk4len_byte2_st;
        end // rx_fsm_lk4len_byte2_st

	rx_fsm_getdt_nib1_st: //state number 7
	  // This state collects the nibbles of the receive data
	  // This state makes a determination to remove padding
	  // only if strip padding is enabled and the length field
	  // detected is less than 64
	  begin
	    if  (commit_condition)
	      commit_write = 1'b1;
	    
	    if((ap2rx_rx_fifo_err) && !commit_write_done)
	      begin
		rewind_write = 1;
		rx_fsm_nxt_st = rx_fsm_idle_st;
	      end // else: !if(mi2rx_end_rcv)
	    else if (ap2rx_rx_fifo_err)
	      begin
	        rx_fsm_nxt_st = rx_fsm_updstat_st;
	      end
	    else if(mi2rx_end_rcv)
	      begin
		if(cf2rx_rcv_runt_pkt_en && !(commit_write_done | commit_condition))
		  begin
		    commit_write = 1'b1;
		    rx_fsm_nxt_st = rx_fsm_chkval_st;
		  end
		else if(!(commit_write_done | commit_condition) && !cf2rx_rcv_runt_pkt_en)
		  begin
		    rewind_write = 1'b1;
		    rx_fsm_nxt_st = rx_fsm_idle_st;
		  end
		else
		  rx_fsm_nxt_st = rx_fsm_chkval_st;
	      end
	    else if(mi2rx_rcv_vld && (inc_length_counter == rcv_length_reg) && 
		    look_at_length_field)
	      begin
		dec_data_len = 1'b1;
		rx_fsm_nxt_st = rx_fsm_getpaddt_nib1_st;
	      end
	    else if(mi2rx_rcv_vld && look_at_length_field)
	      begin
		dec_data_len = 1'b1;
		rx_fsm_nxt_st = rx_fsm_getdt_nib1_st;
	      end
	    else
	      rx_fsm_nxt_st = rx_fsm_getdt_nib1_st;
	  end
	
	rx_fsm_getpaddt_nib1_st:
	  // This state handles the padded data in case of less than 64
	  // byte packets This handles the odd nibbles
	  begin
	    if(ap2rx_rx_fifo_err)
	      begin
            	if(rcv_byte_count[14:0] <= 15'd64) // mfilardo
            	//if(inc_rcv_byte_count[14:0] <= 15'd64)
            	  begin
            	    rewind_write = 1'b1;
	            rx_fsm_nxt_st = rx_fsm_idle_st;
	          end
	        else
	          rx_fsm_nxt_st = rx_fsm_updstat_st;
	      end
	    else if(mi2rx_end_rcv)
	      begin
	        //if(inc_rcv_byte_count[14:0] == 15'd64)
	        if(rcv_byte_count[14:0] == 15'd64) // mfilardo
		  lengthfield_error = 0;
		else
		  lengthfield_error = 1;
		
		  rx_fsm_nxt_st = rx_fsm_extend_st;    
	      end
	    else if(mi2rx_rcv_vld) 
	      begin
		if(cf2rx_strp_pad_en)
		  rcv_pad_data = 1'b1;
	      end
	    else
	      rx_fsm_nxt_st = rx_fsm_getpaddt_nib1_st;
	  end // case: rx_fsm_getpaddt_nib1_st
	
	
	rx_fsm_extend_st:
	  //This state handles the first extend conditon in the
	  //cf2rx_gigabit_xfr
	  //transfer
	  begin
	    if (mi2rx_extend)
	      begin
		  rx_fsm_nxt_st = rx_fsm_extend_st;    
	      end
	    else
	      begin
		commit_write = 1'b1;
		rx_fsm_nxt_st = rx_fsm_chkval_st;    	    	    
	      end
	  end
	rx_fsm_chkval_st:
	  // This packet generates the validity of the packet
	  // This is reached either on clean or error type
	  // completion of packet.
	  begin
	    if(ap2rx_rx_fifo_err)
	      begin
	        rx_fsm_nxt_st = rx_fsm_updstat_st;
	      end
	    else if(cf2rx_rcv_runt_pkt_en && first_dword)
	      begin
		rx_fsm_nxt_st = rx_fsm_chkval_st;
		case(rcv_byte_count[2:0]) 
		  3'd1:
		    begin
		      if(shift_counter == 3'd4)
			begin
			  if(bytes_to_fifo == rcv_byte_count[2:0])
			    begin
			      gen_eop = 1'b1;
			      rx_fsm_nxt_st = rx_fsm_updstat_st;
			    end // if (bytes_to_fifo == rcv_nibble_count[3:1])
			  else
			    send_data_to_fifo = 1'b1;
			end // if (shift_counter == 3'd4)
		      else
			inc_shift_counter = 1;
		    end // case: 3'd1
		  
		  3'd2:   
		    begin
		      if(shift_counter == 3'd3)
			begin
			  if(bytes_to_fifo == rcv_byte_count[2:0])
			    begin
			      gen_eop = 1'b1;
			      rx_fsm_nxt_st = rx_fsm_updstat_st;
			    end // if (bytes_to_fifo == rcv_nibble_count[3:1])
			  else
			    send_data_to_fifo = 1'b1;
			end // if (shift_counter == 3'd3)
		      else
			inc_shift_counter = 1;
		    end // case: 3'd2
		  
		  3'd3:
		    begin
		      if(shift_counter == 3'd2)
			begin
			  if(bytes_to_fifo == rcv_byte_count[2:0])
			    begin
			      gen_eop = 1'b1;
			      rx_fsm_nxt_st = rx_fsm_updstat_st;
			    end
			  else
			    send_data_to_fifo = 1'b1;
			end // if (shift_counter == 3'd2)
		      else
			inc_shift_counter = 1;
		    end // case: 3'd3
		  
		  3'd4:
		    begin
		      if(shift_counter == 3'd1)
			begin
			  if(bytes_to_fifo == rcv_byte_count[2:0])
			    begin
			      gen_eop = 1'b1;
			      rx_fsm_nxt_st = rx_fsm_updstat_st;
			    end // if (bytes_to_fifo == rcv_nibble_count[3:1])
			  else
			    send_data_to_fifo = 1'b1;
			end
		      else
			inc_shift_counter = 1;
		    end // case: 3'd4
		  default:
		    begin
		      rx_fsm_nxt_st = rx_fsm_idle_st;
		      gen_eop = 1'b0;
		    end
		endcase // case(rcv_nibble_count[3
	      end // if (cf2rx_rcv_runt_pkt_en && first_dword)
	    else if(((cf2rx_snd_crc || send_runt_packet || look_at_length_field) 
		     && crc_count == 3'd4))
	      begin
		gen_eop = 1'b1;
		rx_fsm_nxt_st = rx_fsm_updstat_st;
	      end
	    else if(send_runt_packet || look_at_length_field)
	      begin
		send_crc = 1'b1;
		rx_fsm_nxt_st = rx_fsm_chkval_st;
	      end
	    else if(!cf2rx_snd_crc)
	      begin
		gen_eop = 1'b1;
		rx_fsm_nxt_st = rx_fsm_updstat_st;
	      end
	    else 
	      begin
		send_crc = 1'b1;
		rx_fsm_nxt_st = rx_fsm_chkval_st;
	      end
	  end // case: rx_fsm_chkval_st
	
	rx_fsm_updstat_st:
	  // This state updates the status to the application
	  // This allows the application to determine the validity
	  // of the packet so that it can take the necessary action
	  begin
	    e_rx_sts_vld = 1'b1;
	    rx_fsm_nxt_st = rx_fsm_idle_st;
	  end
	
	default:
	  begin
	    rx_fsm_nxt_st = rx_fsm_idle_st;
	  end
      endcase // casex(rx_fsm_cur_st)
    end // always @ (rx_fsm_cur_st or mi2rx_strt_rcv or rx_ch_en or cf2rx_strp_pad_en...
  
  always @(inc_rcv_byte_count)
    begin
      if(inc_rcv_byte_count[14:0] < 15'd6)
        first_dword = 1'b1;
      else
        first_dword = 1'b0;
    end // always @ (inc_rcv_nibble_count or...
  
  
  always @(posedge phy_rx_clk
	   or negedge reset_n)
    begin
      if(!reset_n)
	crc_count <= 3'b000;
      else if(mi2rx_strt_rcv)
	crc_count <= 3'b000;
      else if(send_crc)
	crc_count <= crc_count + 1;
    end // always @ (posedge phy_rx_clk...
  
  // These signals are used as intermediate flags to determine
  // whether to commit pointer or not to commit pointers
  // to the  application
  // error_seen helps in tracking errors which could occurs in between
  // packet transfer
  always @(posedge phy_rx_clk
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  commit_write_done <= 1'b1;
	  error_seen <= 1'b0;
	end
      else if(mi2rx_strt_rcv)
	begin
	  commit_write_done <= 1'b0;
	  error_seen <= 1'b0;
	end
      else 
	begin
	  if(commit_write)
	    commit_write_done <= 1'b1;
	  if(error)
	    error_seen <= 1'b1;
	end
    end // always @ (posedge phy_rx_clk...
  
  assign look_at_length_field = cf2rx_strp_pad_en && 
				(rcv_length_reg < MIN_FRM_SIZE) && (|rcv_length_reg);
  assign send_runt_packet = cf2rx_rcv_runt_pkt_en && 
	 (rcv_byte_count[15:8] == 8'd0 && rcv_byte_count[7:0] < 8'd64);
  
  

  
  assign inc_rcv_byte_count = rcv_byte_count + 16'h1;
  
  always @(posedge phy_rx_clk
           or negedge reset_n)
    begin
      if(!reset_n)
	rcv_byte_count <= 16'h0000;
      else if(mi2rx_strt_rcv)
	rcv_byte_count <= 16'h0000;
      else if(mi2rx_rcv_vld)
	rcv_byte_count <= inc_rcv_byte_count;
    end // always @ (posedge phy_rx_clk...
  
  // This signal is asserted wheneven there is no valid transfer on the
  // line. Valid transfer is only between mi2rx_strt_rcv and
  // mi2rx_end_rcv. In case
  // of rewind write transfer becomes invalid. Such data should not be
  // written in to the fifo
  reg dt_xfr_invalid;
  always @(posedge phy_rx_clk
           or negedge reset_n)
    begin
      if(!reset_n)
	dt_xfr_invalid <= 1;
      else if(rewind_write || ap2rx_rx_fifo_err)
	dt_xfr_invalid <= 1;
      else if(mi2rx_strt_rcv)
	dt_xfr_invalid <= 0;
    end
  // This is the mux to gather nibbles to two octets for the length field
  // of the register
  assign inc_length_counter = length_counter + 16'h1;
  always @(posedge phy_rx_clk 
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  rcv_length_reg <= 16'b0;
	  length_counter <= 16'b0;
	end // if (reset_n)
      else if (rx_ch_en)
	begin
	  if(mi2rx_strt_rcv)
	    begin
	      length_counter <= 16'b0;
	      rcv_length_reg <= 16'b0;
	    end
	  else if(dec_data_len )
	    length_counter <= inc_length_counter;
	  else
	    begin  
	      if(ld_length_byte_1)
		begin
		  rcv_length_reg[15:8] <= mi2rx_rx_byte;
		end 
	    else if(ld_length_byte_2)
	      begin
	    	rcv_length_reg[7:0] <= mi2rx_rx_byte;
	      end 
	    end // else: !if(dec_data_len)
	end // else: !if(!reset_n)
    end // always @ (posedge phy_rx_clk...
  
  // This signal helps in making sure that when packets are received the
  // channel is enabled else ignore the complete packet until next start
  // of packet
  reg enable_channel; 
  always @(posedge phy_rx_clk 
	   or negedge reset_n)
    begin
      if(!reset_n)
	enable_channel <= 0;
      else if(gen_eop)
	enable_channel <= 0;
      else if(mi2rx_strt_rcv && rx_ch_en)
	enable_channel <= 1;
    end
  
  // This is the decremented padding length register
  // Once it reaches zero CRC should follow
  assign dec_pad_length = padding_len_reg - 7'h1;
  always @(posedge phy_rx_clk 
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  padding_needed <= 1'b0; 
	  padding_len_reg <= 6'b0;
	end
      else if(mi2rx_strt_rcv)
	begin
	  padding_needed <= 1'b0; 
	  padding_len_reg <= 6'b0;
	end
      else if(look_at_length_field && 
	      check_padding)
	begin
	  padding_len_reg <= MIN_FRM_SIZE - rcv_length_reg[5:0];
	  padding_needed <= 1'b1; 
	end 
      else if(dec_pad_len)
	begin
	  padding_len_reg <= dec_pad_len;
	  padding_needed <= padding_needed; 
	end
    end // always @ (posedge phy_rx_clk...
  
  /*********************************************************  
   Status Generation for Receive packets
   Statuses in this case are checked at end of receive packets
   and are registered and provided inthe next state along with
   rx_sts_valid bit asserted
   *********************************************************/ 
  
  reg[14:0] fifo_byte_count;
  wire [14:0] inc_fifo_byte_count;
  wire [14:0] dec_fifo_byte_count;
  assign      inc_fifo_byte_count = fifo_byte_count + 15'h1;
  assign      dec_fifo_byte_count = fifo_byte_count - 15'h1;
  
  always @(posedge phy_rx_clk or negedge reset_n)
    begin
      if(!reset_n)
	fifo_byte_count <= 15'd0;
      else if(rewind_write || mi2rx_strt_rcv)
	fifo_byte_count <= 15'd0;
      else if(rx2ap_rx_fsm_wrt)
	fifo_byte_count <= inc_fifo_byte_count;
    end
  
  reg        length_sz_mismatch;
  
  assign rx_sts_dt[31:16] = (e_rx_sts_vld && ap2rx_rx_fifo_err) ?
                            {dec_fifo_byte_count + 16'h1} : {fifo_byte_count + 16'h1};
  assign rx_sts_dt[15:13] = 3'd0;
  assign rx_sts_dt[12] = length_sz_mismatch;
  assign rx_sts_dt[11] = 1'b0;
  assign rx_sts_dt[10] = large_pkt_reg;
  assign rx_sts_dt[7] = lengthfield_err_reg;
  assign rx_sts_dt[6] = crc_stat_reg;
  assign rx_sts_dt[5] = rx_runt_pkt_reg;
  assign rx_sts_dt[4] = rx_fifo_overrun_reg;
  assign rx_sts_dt[2] = frm_length_err_reg;
  assign rx_sts_dt[1:0] = 2'd0;
  
  wire 	      rx_sts_large_pkt;
  wire [15:0] rx_sts_bytes_rcvd;   
  wire        rx_sts_lengthfield_err;
  wire        rx_sts_crc_err;
  wire        rx_sts_runt_pkt_rcvd;
  wire        rx_sts_rx_overrun;
  wire        rx_sts_frm_length_err;
  wire        rx_sts_len_mismatch;
  
  assign      rx_sts_bytes_rcvd = rx_sts[31:16];
  assign      rx_sts_len_mismatch = rx_sts[12];
  assign      rx_sts_large_pkt = rx_sts[10];
  assign      rx_sts_lengthfield_err = rx_sts[7];
  assign      rx_sts_crc_err = rx_sts[6];
  assign      rx_sts_runt_pkt_rcvd = rx_sts[5];
  assign      rx_sts_rx_overrun = rx_sts[4];
  assign      rx_sts_frm_length_err = rx_sts[2];
  
  
  always @(posedge phy_rx_clk 
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  crc_stat_reg <= 1'b0;
	  frm_length_err_reg <= 1'b0;
	  lengthfield_err_reg <= 1'b0;
	  rx_fifo_overrun_reg <= 1'b0;
	  rx_runt_pkt_reg <= 1'b0;
	  large_pkt_reg <= 1'b0;	  
          length_sz_mismatch <= 1'b0;
	end
      else if(mi2rx_strt_rcv)
	begin
	  crc_stat_reg <= 1'b0;
	  frm_length_err_reg <= 1'b0;
	  lengthfield_err_reg <= 1'b0;
	  rx_fifo_overrun_reg <= 1'b0;
	  rx_runt_pkt_reg <= 1'b0;
	  large_pkt_reg <= 1'b0;	  
          length_sz_mismatch <= 1'b0;
	end
      else 
	begin
	  if(rx_overrun_error)
	    rx_fifo_overrun_reg <= 1'b1;
	  
	  if(lengthfield_error) 
	    lengthfield_err_reg <= 1'b1;
	  
	  if(mi2rx_end_rcv && mi2rx_frame_err) 
	    frm_length_err_reg <= 1'b1;
	  
	  if(mi2rx_end_rcv)
	    begin
	      if(!rc2rx_crc_ok)
		crc_stat_reg <= 1'b1;
	      if(rcv_byte_count[14:0] < 15'd64)
		rx_runt_pkt_reg <= 1'b1;
	      if(rcv_byte_count[14:0] > adj_cf2rx_max_pkt_sz)
		large_pkt_reg <= 1'b1;
	      if( (adj_rcv_byte_count[15:0] != adj_rcv_length_reg) && (adj_rcv_length_reg <= 16'd1500) )
		length_sz_mismatch <= 1'b1;
	    end // if (mi2rx_end_rcv)
	end // else: !if(mi2rx_strt_rcv)
    end // always @ (posedge phy_rx_clk...
  
  /***************************************************/
  //
  // Additions for Byte operation 
  //
  /***************************************************/
  always @(posedge phy_rx_clk or
	   negedge reset_n)
    begin
      if(!reset_n)
	shift_counter <= 3'd0;
      else if(mi2rx_strt_rcv)
	shift_counter <= 3'd0;
      else if(inc_shift_counter)
	shift_counter <= shift_counter + 1;
    end // always @ (posedge phy_rx_clk or...
  
  always @(posedge phy_rx_clk or
	   negedge reset_n)
    begin
      if(!reset_n)
	bytes_to_fifo <= 3'd0;
      else if(mi2rx_strt_rcv)
	bytes_to_fifo <= 3'd1;
      else if(send_data_to_fifo)
	bytes_to_fifo <= bytes_to_fifo + 1;
    end // always @ (posedge phy_rx_clk or...
  
  wire[8:0] e_rx_fsm_dt;
  wire 	    e_rx_fsm_wrt;
  assign    e_rx_fsm_dt[7:0] = buf_latch4;
//  assign    e_rx_fsm_dt[8] = (rx_fifo_full) ? 1'b1 :gen_eop;
  assign    e_rx_fsm_dt[8] = gen_eop;
  
  always @(posedge phy_rx_clk or
	   negedge reset_n)
    begin
      if(!reset_n)
	begin
	  rx2ap_rx_fsm_dt <= 9'd0;
	  rx2ap_rx_fsm_wrt <= 1'b0;
	  rx2ap_commit_write <= 1'b0;
	  rx2ap_rewind_write <= 1'b0;
	end
      else
	begin
	  rx2ap_rx_fsm_wrt <= e_rx_fsm_wrt && (!ap2rx_rx_fifo_err);
	  rx2ap_rx_fsm_dt <= e_rx_fsm_dt;
	  rx2ap_commit_write <= commit_write;
	  rx2ap_rewind_write <= rewind_write;
	end
    end // always @ (posedge phy_rx_clk or...

  assign e_rx_fsm_wrt = ((enable_channel &&  
			  mi2rx_rcv_vld && !first_dword) || 
			 (enable_channel && 
			  (gen_eop || send_crc)) || 
			 (enable_channel && send_data_to_fifo)) && !rcv_pad_data
			&& !dt_xfr_invalid && !rewind_write;
  assign ld_buf = enable_channel && !rcv_pad_data && (|rcv_byte_count == 1) && 
	 (mi2rx_rcv_vld) || send_crc || inc_shift_counter || send_data_to_fifo;
  
  assign ld_buf4 = ld_buf ;
  assign ld_buf3 = ld_buf ;
  assign ld_buf2 = ld_buf ;
  assign ld_buf1 = ld_buf ;
  always @(posedge phy_rx_clk
	   or negedge reset_n)
    begin
      if(!reset_n)
	begin
	  buf_latch4 <= 8'b0;
	  buf_latch3 <= 8'b0;
	  buf_latch2 <= 8'b0;
	  buf_latch1 <= 8'b0;
	  buf_latch0 <= 8'b0;
	end
      else
	begin
	  if(ld_buf4)
	    buf_latch4 <= buf_latch3;
	  
	  if(ld_buf3)
	    buf_latch3 <= buf_latch2;
	  
	  if(ld_buf2)
	    buf_latch2 <= buf_latch1;
	  
	  if(ld_buf1)
	    buf_latch1 <= buf_latch0;
	  
	  if (rx_ch_en)
	    begin
	      if(mi2rx_strt_rcv)
		begin
		  buf_latch0 <= 8'b0;
		end
	      else 
		begin
		  if(mi2rx_rcv_vld && !rcv_pad_data)
		    begin
		      buf_latch0 <= mi2rx_rx_byte;
		    end
		end // else: !if(mi2rx_strt_rcv)
	    end // if (rx_ch_en)
	end // else: !if(!reset_n)
    end // always @ (posedge phy_rx_clk...
  
endmodule