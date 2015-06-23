//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_jsp_module.v                                           ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Advanced Debug Interface.      ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010       Authors                             ////
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


`include "adbg_defines.v"

// Module interface
module adbg_jsp_module (
			 // JTAG signals
			 tck_i,
			 module_tdo_o,
			 tdi_i,

			 // TAP states
			 capture_dr_i,
			 shift_dr_i,
			 update_dr_i,

			 data_register_i,  // the data register is at top level, shared between all modules
			 module_select_i,
			 top_inhibit_o,
			 rst_i,

			 // WISHBONE common signals
			 wb_clk_i, wb_rst_i,

			 // WISHBONE slave interface
			 wb_adr_i, wb_dat_o, wb_dat_i, wb_cyc_i, wb_stb_i, wb_sel_i,
			 wb_we_i, wb_ack_o, wb_cab_i, wb_err_o, wb_cti_i, wb_bte_i, int_o 
			 );

   // JTAG signals
   input         tck_i;
   output        module_tdo_o;
   input         tdi_i;  // This is only used by the CRC module - data_register_i[MSB] is delayed a cycle

   // TAP states
   input         capture_dr_i;
   input         shift_dr_i;
   input         update_dr_i;

   input [52:0]  data_register_i;
   input         module_select_i;
   output        top_inhibit_o;
   input         rst_i;
   
   // WISHBONE slave interface
   input         wb_clk_i;
   input         wb_rst_i;
   input  [31:0] wb_adr_i;
   output [31:0] wb_dat_o;
   input  [31:0] wb_dat_i;
   input         wb_cyc_i;
   input         wb_stb_i;
   input   [3:0] wb_sel_i;
   input         wb_we_i;
   output        wb_ack_o;
   input         wb_cab_i;
   output        wb_err_o;
   input   [2:0] wb_cti_i;
   input   [1:0] wb_bte_i;
   output 	 int_o;
  
   // Declare inputs / outputs as wires / registers
   wire 	 module_tdo_o;
   wire 	 top_inhibit_o;

   // NOTE:  For the rest of this file, "input" and the "in" direction refer to bytes being transferred
   // from the PC, through the JTAG, and into the BIU FIFO.  The "output" direction refers to data being
   // transferred from the BIU FIFO, through the JTAG to the PC.
   
   // The read and write bit counts are separated to allow for JTAG chains with multiple devices.
   // The read bit count starts right away (after a single throwaway bit), but the write count
   // waits to receive a '1' start bit.

   // Registers to hold state etc.
   reg [3:0] 	 read_bit_count;            // How many bits have been shifted out
   reg [3:0]   write_bit_count;      // How many bits have been shifted in
   reg [3:0] 	 input_word_count;     // space (bytes) remaining in input FIFO (from JTAG)
   reg [3:0]     output_word_count;    // bytes remaining in output FIFO (to JTAG)
   reg [3:0] 	 user_word_count;     // bytes user intends to send from PC
   reg [7:0] 	 data_out_shift_reg;  // parallel-load output shift register


   // Control signals for the various counters / registers / state machines
   reg 		 rd_bit_ct_en;         // enable bit counter
   reg 		 rd_bit_ct_rst;        // reset (zero) bit count register
   reg 		 wr_bit_ct_en;         // enable bit counter
   reg 		 wr_bit_ct_rst;        // reset (zero) bit count register   
   reg 		 in_word_ct_sel;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
   reg 		 out_word_ct_sel;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
   reg 		 in_word_ct_en;     // Enable input byte counter register
   reg           out_word_ct_en;    // Enable output byte count register
   reg           user_word_ct_en;   // Enable user byte count registere
   reg           user_word_ct_sel;  // selects data for user byte counter.  0 = user data, 1 = decremented byte count
   reg 		 out_reg_ld_en;     // Enable parallel load of data_out_shift_reg
   reg 		 out_reg_shift_en;  // Enable shift of data_out_shift_reg
   reg 		 out_reg_data_sel;  // 0 = BIU data, 1 = byte count data (also from BIU)
   reg 		 biu_rd_strobe;      // Indicates that the bus unit should ACK the last read operation + start another
   reg 		 biu_wr_strobe;   // Indicates BIU should latch input + begin a write operation


   // Status signals
   wire 	 in_word_count_zero;   // true when input byte counter is zero
   wire 	 out_word_count_zero;   // true when output byte counter is zero
   wire          user_word_count_zero; // true when user byte counter is zero
   wire 	 rd_bit_count_max;     // true when bit counter is equal to current word size
   wire 	 wr_bit_count_max;     // true when bit counter is equal to current word size
      
   // Intermediate signals
   wire [3:0] 	 data_to_in_word_counter;  // output of the mux in front of the input byte counter reg
   wire [3:0] 	 data_to_out_word_counter;  // output of the mux in front of the output byte counter reg
   wire [3:0] 	 data_to_user_word_counter;  // output of mux in front of user word counter
   wire [3:0] 	 decremented_in_word_count;
   wire [3:0] 	 decremented_out_word_count;
   wire [3:0] 	 decremented_user_word_count;
   wire [3:0] 	 count_data_in;         // from data_register_i
   wire [7:0] 	 data_to_biu;           // from data_register_i
   wire [7:0] 	 data_from_biu;         // to data_out_shift_register
   wire [3:0] 	 biu_space_available;
   wire [3:0] 	 biu_bytes_available;
   wire [7:0] 	 count_data_from_biu;   // combined space avail / bytes avail
   wire [7:0] 	 out_reg_data;           // parallel input to the output shift register


   /////////////////////////////////////////////////
   // Combinatorial assignments

   assign count_data_from_biu = {biu_bytes_available, biu_space_available};
   assign count_data_in = {tdi_i, data_register_i[52:50]};  // Second nibble of user data
   assign data_to_biu = {tdi_i,data_register_i[52:46]};
   assign top_inhibit_o = 1'b0;

   //////////////////////////////////////
   // Input bit counter

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)             write_bit_count <= 4'h0;
	else if(wr_bit_ct_rst)   write_bit_count <= 4'h0;
	else if(wr_bit_ct_en)    write_bit_count <= write_bit_count + 4'h1;
     end

   assign wr_bit_count_max = (write_bit_count == 4'h7) ? 1'b1 : 1'b0;

   //////////////////////////////////////
   // Output bit counter

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)             read_bit_count <= 4'h0;
	else if(rd_bit_ct_rst)   read_bit_count <= 4'h0;
	else if(rd_bit_ct_en)    read_bit_count <= read_bit_count + 4'h1;
     end

   assign rd_bit_count_max = (read_bit_count == 4'h7) ? 1'b1 : 1'b0;

   ////////////////////////////////////////
   // Input word counter

   assign data_to_in_word_counter = (in_word_ct_sel) ?  decremented_in_word_count : biu_space_available;
   assign decremented_in_word_count = input_word_count - 4'h1;

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  input_word_count <= 4'h0;
	else if(in_word_ct_en)
	  input_word_count <= data_to_in_word_counter;
     end

   assign in_word_count_zero = (input_word_count == 4'h0);
   
   ////////////////////////////////////////
   // Output word counter

   assign data_to_out_word_counter = (out_word_ct_sel) ?  decremented_out_word_count : biu_bytes_available;
   assign decremented_out_word_count = output_word_count - 4'h1;

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  output_word_count <= 4'h0;
	else if(out_word_ct_en)
	  output_word_count <= data_to_out_word_counter;
     end

   assign out_word_count_zero = (output_word_count == 4'h0);

   ////////////////////////////////////////
   // User word counter

   assign data_to_user_word_counter = (user_word_ct_sel) ?  decremented_user_word_count : count_data_in;
   assign decremented_user_word_count = user_word_count - 4'h1;

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)                 user_word_count <= 4'h0;
	else if(user_word_ct_en)  user_word_count <= data_to_user_word_counter;
     end

   assign user_word_count_zero = (user_word_count == 4'h0);
    
   /////////////////////////////////////////////////////
   // Output register and TDO output MUX

   assign out_reg_data = (out_reg_data_sel) ? count_data_from_biu : data_from_biu;

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) data_out_shift_reg <= 8'h0;
	else if(out_reg_ld_en) data_out_shift_reg <= out_reg_data;
	else if(out_reg_shift_en) data_out_shift_reg <= {1'b0, data_out_shift_reg[7:1]};
     end

   assign module_tdo_o = data_out_shift_reg[0];
   
   ////////////////////////////////////////
   // Bus Interface Unit (to JTAG / WB UART)
   // It is assumed that the BIU has internal registers, and will
   // latch write data (and ack read data) on rising clock edge 
   // when strobe is asserted

   adbg_jsp_biu jsp_biu_i (
			   // Debug interface signals
			   .tck_i           (tck_i),
			   .rst_i           (rst_i),
			   .data_i          (data_to_biu),
			   .data_o          (data_from_biu),
			   .bytes_available_o (biu_bytes_available),
			   .bytes_free_o    (biu_space_available),
			   .rd_strobe_i     (biu_rd_strobe),
			   .wr_strobe_i     (biu_wr_strobe),
			   
			   // Wishbone slave signals
			   .wb_clk_i        (wb_clk_i),
			   .wb_rst_i        (wb_rst_i),
			   .wb_adr_i        (wb_adr_i),
			   .wb_dat_o        (wb_dat_o),
			   .wb_dat_i        (wb_dat_i),
			   .wb_cyc_i        (wb_cyc_i),
			   .wb_stb_i        (wb_stb_i),
			   .wb_sel_i        (wb_sel_i),
			   .wb_we_i         (wb_we_i),
			   .wb_ack_o        (wb_ack_o),
			   .wb_cab_i        (wb_cab_i),
			   .wb_err_o        (wb_err_o),
			   .wb_cti_i        (wb_cti_i),
			   .wb_bte_i        (wb_bte_i),
			   .int_o           (int_o)
			   );


   ////////////////////////////////////////
   // Input Control FSM

   // Definition of machine state values.
   // Don't worry too much about the state encoding, the synthesis tool
   // will probably re-encode it anyway.

`define STATE_wr_idle     3'h0
`define STATE_wr_wait     3'h1
`define STATE_wr_counts   3'h2
`define STATE_wr_xfer     3'h3

   reg [2:0] wr_module_state;       // FSM state
   reg [2:0] wr_module_next_state;  // combinatorial signal, not actually a register


   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  wr_module_state <= `STATE_wr_idle;
	else
	  wr_module_state <= wr_module_next_state;
     end


   // Determination of next state; purely combinatorial
   always @ (wr_module_state or module_select_i or update_dr_i or capture_dr_i 
	     or shift_dr_i or wr_bit_count_max or tdi_i)
     begin
	case(wr_module_state)
	  `STATE_wr_idle:
	    begin
`ifdef ADBG_JSP_SUPPORT_MULTI
	       if(module_select_i && capture_dr_i) wr_module_next_state <= `STATE_wr_wait;
`else
	       if(module_select_i && capture_dr_i) wr_module_next_state <= `STATE_wr_counts;
`endif
	       else wr_module_next_state <= `STATE_wr_idle;
	    end
	   `STATE_wr_wait:
	   begin 
	     	 if(update_dr_i) wr_module_next_state <= `STATE_wr_idle;
	    	  else if(module_select_i && tdi_i) wr_module_next_state <= `STATE_wr_counts;  // got start bit
	       else wr_module_next_state <= `STATE_wr_wait;
	   end
	  `STATE_wr_counts:
	    begin
	       if(update_dr_i) wr_module_next_state <= `STATE_wr_idle;
	       else if(wr_bit_count_max) wr_module_next_state <= `STATE_wr_xfer;
	       else wr_module_next_state <= `STATE_wr_counts;
	    end

	  `STATE_wr_xfer:
	    begin
	       if(update_dr_i) wr_module_next_state <= `STATE_wr_idle;
	       else wr_module_next_state <= `STATE_wr_xfer;
	    end
	  
	  default: wr_module_next_state <= `STATE_wr_idle;  // shouldn't actually happen...
	endcase
     end
   

   // Outputs of state machine, pure combinatorial
   always @ (wr_module_state or wr_module_next_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i
	     or in_word_count_zero or out_word_count_zero or wr_bit_count_max or decremented_in_word_count
	     or decremented_out_word_count or user_word_count_zero)
     begin
	// Default everything to 0, keeps the case statement simple
	wr_bit_ct_en <= 1'b0;         // enable bit counter
	wr_bit_ct_rst <= 1'b0;        // reset (zero) bit count register
	in_word_ct_sel <= 1'b0;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
	user_word_ct_sel <= 1'b0;  // selects data for user byte counter, 0 = user data, 1 = decremented count
	in_word_ct_en <= 1'b0;     // Enable input byte counter register
	user_word_ct_en <= 1'b0;   // enable user byte count register
	biu_wr_strobe <= 1'b0;    // Indicates BIU should latch input + begin a write operation
	
	case(wr_module_state)
	  `STATE_wr_idle:
	    begin
	       in_word_ct_sel <= 1'b0;
	       
	       // Going to transfer; enable count registers and output register
	       if(wr_module_next_state != `STATE_wr_idle) begin
		  wr_bit_ct_rst <= 1'b1;
		  in_word_ct_en <= 1'b1;
	       end
	    end

	  // This state is only used when support for multi-device JTAG chains is enabled.
	  `STATE_wr_wait:
	    begin
	       wr_bit_ct_en <= 1'b0;  // Don't do anything, just wait for the start bit.
	    end

	  `STATE_wr_counts:
	    begin
	       if(shift_dr_i) begin // Don't do anything in PAUSE or EXIT states...
		  wr_bit_ct_en <= 1'b1;
		  user_word_ct_sel <= 1'b0;
		  
		  if(wr_bit_count_max) begin
		     wr_bit_ct_rst <= 1'b1;
		     user_word_ct_en <= 1'b1;
		  end
	       end
	    end
    
	  `STATE_wr_xfer:
	    begin
	       if(shift_dr_i) begin  // Don't do anything in PAUSE or EXIT states
		  wr_bit_ct_en <= 1'b1;
		  in_word_ct_sel <= 1'b1;
		  user_word_ct_sel <= 1'b1;
	       
		  if(wr_bit_count_max) begin  // Start biu transactions, if word counts allow
		     wr_bit_ct_rst <= 1'b1;
		  
		     if(!(in_word_count_zero || user_word_count_zero)) begin
			biu_wr_strobe <= 1'b1;
			in_word_ct_en <= 1'b1;
			user_word_ct_en <= 1'b1;
		     end

		  end
	       end
	    end

	  default: ;
	endcase
     end

   ////////////////////////////////////////
   // Output Control FSM

   // Definition of machine state values.
   // Don't worry too much about the state encoding, the synthesis tool
   // will probably re-encode it anyway.

`define STATE_rd_idle     4'h0
`define STATE_rd_counts   4'h1
`define STATE_rd_rdack   4'h2
`define STATE_rd_xfer  4'h3

// We do not send the equivalent of a 'start bit' (like the one the input FSM
// waits for when support for multi-device JTAG chains is enabled).  Since the
// input and output are going to be offset anyway, why bother...

   reg [2:0] rd_module_state;       // FSM state
   reg [2:0] rd_module_next_state;  // combinatorial signal, not actually a register


   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  rd_module_state <= `STATE_rd_idle;
	else
	  rd_module_state <= rd_module_next_state;
     end


   // Determination of next state; purely combinatorial
   always @ (rd_module_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i or rd_bit_count_max)
     begin
	case(rd_module_state)
	  `STATE_rd_idle:
	    begin
	       if(module_select_i && capture_dr_i) rd_module_next_state <= `STATE_rd_counts;
	       else rd_module_next_state <= `STATE_rd_idle;
	    end
	  `STATE_rd_counts:
	    begin
	       if(update_dr_i) rd_module_next_state <= `STATE_rd_idle;
	       else if(rd_bit_count_max) rd_module_next_state <= `STATE_rd_rdack;
	       else rd_module_next_state <= `STATE_rd_counts;
	    end
	  `STATE_rd_rdack:
	    begin
               if(update_dr_i) rd_module_next_state <= `STATE_rd_idle;
               else rd_module_next_state <= `STATE_rd_xfer;
	    end
	  `STATE_rd_xfer:
	    begin
	       if(update_dr_i) rd_module_next_state <= `STATE_rd_idle;
	       else if(rd_bit_count_max) rd_module_next_state <= `STATE_rd_rdack;
	       else rd_module_next_state <= `STATE_rd_xfer;
	    end
	  
	  default: rd_module_next_state <= `STATE_rd_idle;  // shouldn't actually happen...
	endcase
     end
   

   // Outputs of state machine, pure combinatorial
   always @ (rd_module_state or rd_module_next_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i
	     or in_word_count_zero or out_word_count_zero or rd_bit_count_max or decremented_in_word_count
	     or decremented_out_word_count)
     begin
	// Default everything to 0, keeps the case statement simple
	rd_bit_ct_en <= 1'b0;         // enable bit counter
	rd_bit_ct_rst <= 1'b0;        // reset (zero) bit count register
	out_word_ct_sel <= 1'b0;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
	out_word_ct_en <= 1'b0;    // Enable output byte count register
	out_reg_ld_en <= 1'b0;     // Enable parallel load of data_out_shift_reg
	out_reg_shift_en <= 1'b0;  // Enable shift of data_out_shift_reg
	out_reg_data_sel <= 1'b0;  // 0 = BIU data, 1 = byte count data (also from BIU)
	biu_rd_strobe <= 1'b0;     // Indicates that the bus unit should ACK the last read operation + start another
	
	case(rd_module_state)
	  `STATE_rd_idle:
	    begin
	       out_reg_data_sel <= 1'b1;
	       out_word_ct_sel <= 1'b0;
	       
	       // Going to transfer; enable count registers and output register
	       if(rd_module_next_state != `STATE_rd_idle) begin
		  out_reg_ld_en <= 1'b1;
		  rd_bit_ct_rst <= 1'b1;
		  out_word_ct_en <= 1'b1;
	       end
	    end

	  `STATE_rd_counts:
	    begin
	       if(shift_dr_i) begin // Don't do anything in PAUSE or EXIT states...
		  rd_bit_ct_en <= 1'b1;
		  out_reg_shift_en <= 1'b1;
		  
		  if(rd_bit_count_max) begin
		     rd_bit_ct_rst <= 1'b1;
		     
		     // Latch the next output word, but don't ack until STATE_rd_rdack
		     if(!out_word_count_zero) begin
			out_reg_ld_en <= 1'b1;
			out_reg_shift_en <= 1'b0;
		     end
		  end
	       end
	    end
 
	  `STATE_rd_rdack:
	    begin
	       if(shift_dr_i) begin  // Don't do anything in PAUSE or EXIT states
		  rd_bit_ct_en <= 1'b1;
		  out_reg_shift_en <= 1'b1;
		  out_reg_data_sel <= 1'b0;
      
		  // Never have to worry about bit_count_max here.
      
		  if(!out_word_count_zero) begin
		     biu_rd_strobe <= 1'b1;
		  end
	       end
	    end
    
	  `STATE_rd_xfer:
	    begin
	       if(shift_dr_i) begin  // Don't do anything in PAUSE or EXIT states
		  rd_bit_ct_en <= 1'b1;
		  out_word_ct_sel <= 1'b1;
		  out_reg_shift_en <= 1'b1;
		  out_reg_data_sel <= 1'b0;
	       
		  if(rd_bit_count_max) begin  // Start biu transaction, if word count allows
		     rd_bit_ct_rst <= 1'b1;

		     // Don't ack the read byte here, we do it in STATE_rdack
		     if(!out_word_count_zero) begin
			out_reg_ld_en <= 1'b1;
			out_reg_shift_en <= 1'b0;
			out_word_ct_en <= 1'b1;
		     end
		  end
	       end
	    end

	  default: ;
	endcase
     end


endmodule

