//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_or1k_module.v                                          ////
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
//// Copyright (C) 2008 - 2010       Authors                      ////
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
//
// CVS Revision History
//
// $Log: adbg_or1k_module.v,v $
// Revision 1.6  2010-03-08 21:04:18  Nathan
// Changes for the JTAG serial port module.  Uncompiled, untestede.  Removed CVS logs, minor fixes in comments.
//
// Revision 1.5  2010-01-13 00:55:45  Nathan
// Created hi-speed mode for burst reads.  This will probably be most beneficial to the OR1K module, as GDB does a burst read of all the GPRs each time a microinstruction is single-stepped.
//
// Revision 1.2  2009/05/17 20:54:56  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/22 20:28:31  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.7  2008/07/11 08:13:29  Nathan
// Latch opcode on posedge, like other signals.  This fixes a problem 
// when the module is used with a Xilinx BSCAN TAP.  Added signals to 
// allow modules to inhibit latching of a new active module by the top 
// module.  This allows the sub-modules to force the top level module 
// to ignore the command present in the input shift register after e.g. 
// a burst read.
//


`include "adbg_defines.v"
`include "adbg_or1k_defines.v"

// Module interface
module adbg_or1k_module (
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

			 // Interfate to the OR1K debug unit
			 cpu_clk_i, 
			 cpu_addr_o, 
			 cpu_data_i, 
			 cpu_data_o,
			 cpu_bp_i,
			 cpu_stall_o,
			 cpu_stb_o,
			 cpu_we_o,
			 cpu_ack_i,
			 cpu_rst_o
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

   // Interface to OR1200 debug unit
   input 	 cpu_clk_i;    // 'bus' style interface to SPRs
   output [31:0] cpu_addr_o;
   input [31:0]  cpu_data_i;
   output [31:0] cpu_data_o;
   output 	 cpu_stb_o;
   output 	 cpu_we_o;
   input 	 cpu_ack_i;
   output 	 cpu_rst_o;  // control lines
   input 	 cpu_bp_i;
   output 	 cpu_stall_o;

   // Declare inputs / outputs as wires / registers
   reg 		 module_tdo_o;
   reg 		 top_inhibit_o;


   // Registers to hold state etc.
   reg [31:0] 	 address_counter;     // Holds address for next Wishbone access
   reg [5:0] 	 bit_count;            // How many bits have been shifted in/out
   reg [15:0] 	 word_count;          // bytes remaining in current burst command
   reg [3:0] 	 operation;            // holds the current command (rd/wr, word size)
   reg [31:0] 	 data_out_shift_reg;  // parallel-load output shift register
   reg [`DBG_OR1K_REGSELECT_SIZE-1:0] internal_register_select;  // Holds index of currently selected register
   wire [1:0] 			      internal_reg_status;  // Holds CPU stall and reset status - signal is output of separate module


   // Control signals for the various counters / registers / state machines
   reg 				      addr_sel;          // Selects data for address_counter. 0 = data_register_i, 1 = incremented address count
   reg 				      addr_ct_en;        // Enable signal for address counter register
   reg 				      op_reg_en;         // Enable signal for 'operation' register
   reg 				      bit_ct_en;         // enable bit counter
   reg 				      bit_ct_rst;        // reset (zero) bit count register
   reg 				      word_ct_sel;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
   reg 				      word_ct_en;        // Enable byte counter register
   reg 				      out_reg_ld_en;     // Enable parallel load of data_out_shift_reg
   reg 				      out_reg_shift_en;  // Enable shift of data_out_shift_reg
   reg 				      out_reg_data_sel;  // 0 = BIU data, 1 = internal register data
   reg [1:0] 			      tdo_output_sel;  // Selects signal to send to TDO.  0 = ready bit, 1 = output register, 2 = CRC match, 3 = CRC shift reg.
   reg 				      biu_strobe;      // Indicates that the bus unit should latch data and start a transaction
   reg 				      crc_clr;         // resets CRC module
   reg 				      crc_en;          // does 1-bit iteration in CRC module
   reg 				      crc_in_sel;      // selects incoming write data (=0) or outgoing read data (=1)as input to CRC module
   reg 				      crc_shift_en;    // CRC reg is also it's own output shift register; this enables a shift
   reg 				      regsel_ld_en;    // Reg. select register load enable
   reg 				      intreg_ld_en;    // load enable for internal registers


   // Status signals
   wire 			      word_count_zero;   // true when byte counter is zero
   wire 			      bit_count_max;     // true when bit counter is equal to current word size
   wire 			      module_cmd;        // inverse of MSB of data_register_i. 1 means current cmd not for top level (but is for us)
   wire 			      biu_ready;         // indicates that the BIU has finished the last command
   wire 			      burst_instruction; // True when the input_data_i reg has a valid burst instruction for this module
   wire 			      intreg_instruction; // True when the input_data_i reg has a valid internal register instruction
   wire 			      intreg_write;       // True when the input_data_i reg has an internal register write op
   wire 			      rd_op;              // True when operation in the opcode reg is a read, false when a write
   wire 			      crc_match;         // indicates whether data_register_i matches computed CRC
   wire 			      bit_count_32;      // true when bit count register == 32, for CRC after burst writes

   // Intermediate signals
   wire [5:0] 			      word_size_bits;         // 8,16, or 32.  Decoded from 'operation'
   wire [2:0] 			      address_increment;      // How much to add to the address counter each iteration 
   wire [32:0] 			      incremented_address;   // value of address counter plus 'word_size'
   wire [31:0] 			      data_to_addr_counter;  // output of the mux in front of the address counter inputs
   wire [15:0] 			      data_to_word_counter;  // output of the mux in front of the byte counter input
   wire [15:0] 			      decremented_word_count;
   wire [31:0] 			      address_data_in;       // from data_register_i
   wire [15:0] 			      count_data_in;         // from data_register_i
   wire [3:0] 			      operation_in;          // from data_register_i
   wire [31:0] 			      data_to_biu;           // from data_register_i
   wire [31:0] 			      data_from_biu;         // to data_out_shift_register
   wire [31:0] 			      crc_data_out;          // output of CRC module, to output shift register
   wire 			      crc_data_in;                  // input to CRC module, either data_register_i[52] or data_out_shift_reg[0]
   wire 			      crc_serial_out;
   wire [`DBG_OR1K_REGSELECT_SIZE-1:0] reg_select_data; // from data_register_i, input to internal register select register
   wire [31:0] 			       out_reg_data;           // parallel input to the output shift register
   reg [31:0] 			       data_from_internal_reg;  // data from internal reg. MUX to output shift register
   wire 			       status_reg_wr;


   /////////////////////////////////////////////////
   // Combinatorial assignments

       assign module_cmd = ~(data_register_i[52]);
   assign     operation_in = data_register_i[51:48];
   assign     address_data_in = data_register_i[47:16];
   assign     count_data_in = data_register_i[15:0];
`ifdef ADBG_USE_HISPEED
   assign     data_to_biu = {tdi_i,data_register_i[52:22]};
`else   
   assign     data_to_biu = data_register_i[52:21];
`endif   
   assign     reg_select_data = data_register_i[47:(47-(`DBG_OR1K_REGSELECT_SIZE-1))];

   ////////////////////////////////////////////////
	      // Operation decoder

   // These are only used before the operation is latched, so decode them from operation_in
   assign     burst_instruction = (operation_in == `DBG_OR1K_CMD_BWRITE32) | (operation_in == `DBG_OR1K_CMD_BREAD32);
   assign     intreg_instruction = ((operation_in == `DBG_OR1K_CMD_IREG_WR) | (operation_in == `DBG_OR1K_CMD_IREG_SEL));
   assign     intreg_write = (operation_in == `DBG_OR1K_CMD_IREG_WR);

   // These are constant, the CPU module only does 32-bit accesses
   assign     word_size_bits = 5'd31;  // Bits is actually bits-1, to make the FSM easier
   assign     address_increment = 3'd1;  // This is only used to increment the address.  SPRs are word-addressed.

   // This is the only thing that actually needs to be saved and 'decoded' from the latched opcode
   // It goes to the BIU each time a transaction is started.
   assign     rd_op = operation[2];


   ////////////////////////////////////////////////
   // Module-internal register select register (no, that's not redundant.)
   // Also internal register output MUX

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) internal_register_select = 1'h0;
	else if(regsel_ld_en) internal_register_select = reg_select_data;
     end

   // This is completely unnecessary here, since the module has only 1 internal
   // register.  However, to make the module expandable, it is included anyway.
   always @ (internal_register_select or internal_reg_status)
     begin
	case(internal_register_select) 
          `DBG_OR1K_INTREG_STATUS: data_from_internal_reg = {30'h0, internal_reg_status};
          default: data_from_internal_reg = {30'h0, internal_reg_status};
	endcase
     end
   


   ////////////////////////////////////////////////////////////////////
   // Module-internal registers
   // These have generic read/write/select code, but
   // individual registers may have special behavior, defined here.

   // This is the status register, which holds the reset and stall states.

   assign status_reg_wr = (intreg_ld_en & (reg_select_data == `DBG_OR1K_INTREG_STATUS));

   adbg_or1k_status_reg or1k_statusreg_i (
				     .data_i(data_register_i[(47-`DBG_OR1K_REGSELECT_SIZE):(47-(`DBG_OR1K_REGSELECT_SIZE+1))]), 
				     .we_i(status_reg_wr),
				     .tck_i(tck_i),
				     .bp_i(cpu_bp_i),
				     .rst_i(rst_i),
				     .cpu_clk_i(cpu_clk_i),
				     .ctrl_reg_o(internal_reg_status),
				     .cpu_stall_o(cpu_stall_o),
				     .cpu_rst_o(cpu_rst_o)
				     );


   ///////////////////////////////////////////////
   // Address counter

     assign data_to_addr_counter = (addr_sel) ? incremented_address[31:0] : address_data_in;
   assign   incremented_address = address_counter + address_increment;

   // Technically, since this data (sometimes) comes from the input shift reg, we should latch on
   // negedge, per the JTAG spec. But that makes things difficult when incrementing.
   always @ (posedge tck_i or posedge rst_i)  // JTAG spec specifies latch on negative edge in UPDATE_DR state
     begin
	if(rst_i)
	  address_counter <= 32'h0;
	else if(addr_ct_en)
	  address_counter <= data_to_addr_counter;
     end

   ////////////////////////////////////////
     // Opcode latch

   always @ (posedge tck_i or posedge rst_i)  // JTAG spec specifies latch on negative edge in UPDATE_DR state
     begin
	if(rst_i)
	  operation <= 4'h0;
	else if(op_reg_en)
	  operation <= operation_in;
     end

   //////////////////////////////////////
     // Bit counter

   always @ (posedge tck_i or posedge rst_i)
     begin

	if(rst_i)             bit_count <= 6'h0;
	else if(bit_ct_rst)  bit_count <= 6'h0;
	else if(bit_ct_en)    bit_count <= bit_count + 6'h1;

     end

   assign bit_count_max = (bit_count == word_size_bits) ? 1'b1 : 1'b0 ;
   assign bit_count_32 = (bit_count == 6'h20) ? 1'b1 : 1'b0;

   ////////////////////////////////////////
   // Word counter

   assign data_to_word_counter = (word_ct_sel) ?  decremented_word_count : count_data_in;
   assign decremented_word_count = word_count - 16'h1;

   // Technically, since this data (sometimes) comes from the input shift reg, we should latch on
   // negedge, per the JTAG spec. But that makes things difficult when incrementing.
   always @ (posedge tck_i or posedge rst_i)  // JTAG spec specifies latch on negative edge in UPDATE_DR state
     begin
	if(rst_i)
	  word_count <= 16'h0;
	else if(word_ct_en)
	  word_count <= data_to_word_counter;
     end

   assign word_count_zero = (word_count == 16'h0);

   /////////////////////////////////////////////////////
			    // Output register and TDO output MUX

			    assign out_reg_data = (out_reg_data_sel) ? data_from_internal_reg : data_from_biu;

   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) data_out_shift_reg <= 32'h0;
	else if(out_reg_ld_en) data_out_shift_reg <= out_reg_data;
	else if(out_reg_shift_en) data_out_shift_reg <= {1'b0, data_out_shift_reg[31:1]};
     end


   always @ (tdo_output_sel or data_out_shift_reg[0] or biu_ready or crc_match or crc_serial_out)
     begin
	if(tdo_output_sel == 2'h0) module_tdo_o <= biu_ready;
	else if(tdo_output_sel == 2'h1) module_tdo_o <= data_out_shift_reg[0];
	else if(tdo_output_sel == 2'h2) module_tdo_o <= crc_match;
	else module_tdo_o <= crc_serial_out;
     end

   ////////////////////////////////////////
     // Bus Interface Unit (to OR1K SPR bus)
   // It is assumed that the BIU has internal registers, and will
   // latch address, operation, and write data on rising clock edge 
   // when strobe is asserted

   adbg_or1k_biu or1k_biu_i (
			     // Debug interface signals
			     .tck_i           (tck_i),
			     .rst_i           (rst_i),
			     .data_i          (data_to_biu),
			     .data_o          (data_from_biu),
			     .addr_i          (address_counter),
			     .strobe_i        (biu_strobe),
			     .rd_wrn_i        (rd_op),           // If 0, then write op
			     .rdy_o           (biu_ready),
			     //  This bus has no error signal
			     
			     // OR1K SPR bus signals
			     .cpu_clk_i(cpu_clk_i),
			     .cpu_addr_o(cpu_addr_o),
			     .cpu_data_i(cpu_data_i),
			     .cpu_data_o(cpu_data_o),
			     .cpu_stb_o(cpu_stb_o),
			     .cpu_we_o(cpu_we_o),
			     .cpu_ack_i(cpu_ack_i)
			     );



   /////////////////////////////////////
     // CRC module

     assign crc_data_in = (crc_in_sel) ? tdi_i : data_out_shift_reg[0];  // MUX, write or read data

   adbg_crc32 or1k_crc_i
     (
      .clk(tck_i), 
      .data(crc_data_in),
      .enable(crc_en),
      .shift(crc_shift_en),
      .clr(crc_clr),
      .rst(rst_i),
      .crc_out(crc_data_out),
      .serial_out(crc_serial_out)
      );

   assign   crc_match = (data_register_i[52:21] == crc_data_out) ? 1'b1 : 1'b0;

   ////////////////////////////////////////
   // Control FSM

   // Definition of machine state values.
   // Don't worry too much about the state encoding, the synthesis tool
   // will probably re-encode it anyway.

`define STATE_idle     4'h0
`define STATE_Rbegin   4'h1
`define STATE_Rready   4'h2
`define STATE_Rstatus  4'h3
`define STATE_Rburst   4'h4
`define STATE_Wready   4'h5
`define STATE_Wwait    4'h6
`define STATE_Wburst   4'h7
`define STATE_Wstatus  4'h8
`define STATE_Rcrc     4'h9
`define STATE_Wcrc     4'ha
`define STATE_Wmatch   4'hb

   reg [3:0] module_state;       // FSM state
   reg [3:0] module_next_state;  // combinatorial signal, not actually a register



   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  module_state <= `STATE_idle;
	else
	  module_state <= module_next_state;
     end


   // Determination of next state; purely combinatorial
   always @ (module_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i or operation_in[2]
	     or word_count_zero or bit_count_max or data_register_i[52] or bit_count_32 or biu_ready
	     or module_cmd or intreg_write or decremented_word_count or burst_instruction)
     begin
	case(module_state)
	  `STATE_idle:
	    begin
	       if(module_cmd && module_select_i && update_dr_i && burst_instruction && operation_in[2]) module_next_state <= `STATE_Rbegin;
	       else if(module_cmd && module_select_i && update_dr_i && burst_instruction) module_next_state <= `STATE_Wready;
	       else module_next_state <= `STATE_idle;
	    end

	  `STATE_Rbegin:
	    begin
	       if(word_count_zero) module_next_state <= `STATE_idle;  // set up a burst of size 0, illegal.
	       else module_next_state <= `STATE_Rready;
	    end
	  `STATE_Rready:
	    begin
	       if(module_select_i && capture_dr_i) module_next_state <= `STATE_Rstatus;
	       else module_next_state <= `STATE_Rready;
	    end
	  `STATE_Rstatus:
	    begin
	       if(update_dr_i) module_next_state <= `STATE_idle; 
	       else if (biu_ready) module_next_state <= `STATE_Rburst;
	       else module_next_state <= `STATE_Rstatus;
	    end
	  `STATE_Rburst:
	    begin
	       if(update_dr_i) module_next_state <= `STATE_idle; 
	       else if(bit_count_max && word_count_zero) module_next_state <= `STATE_Rcrc;
`ifndef ADBG_USE_HISPEED         
	       else if(bit_count_max) module_next_state <= `STATE_Rstatus;
`endif	         
	       else module_next_state <= `STATE_Rburst;
	    end
	  `STATE_Rcrc:
	    begin
	       if(update_dr_i) module_next_state <= `STATE_idle;
	       // This doubles as the 'recovery' state, so stay here until update_dr_i.
	       else module_next_state <= `STATE_Rcrc;    
	    end

	  `STATE_Wready:
	    begin
	       if(word_count_zero) module_next_state <= `STATE_idle;
	       else if(module_select_i && capture_dr_i) module_next_state <= `STATE_Wwait;
	       else module_next_state <= `STATE_Wready;
	    end
	  `STATE_Wwait:
	    begin
	       if(update_dr_i)  module_next_state <= `STATE_idle;  // client terminated early
	       else if(module_select_i && data_register_i[52]) module_next_state <= `STATE_Wburst; // Got a start bit
	       else module_next_state <= `STATE_Wwait;
	    end
	  `STATE_Wburst:
	    begin
	       if(update_dr_i)  module_next_state <= `STATE_idle;  // client terminated early    
	       else if(bit_count_max) 
	         begin
`ifdef ADBG_USE_HISPEED
		        if(word_count_zero) module_next_state <= `STATE_Wcrc;
		        else module_next_state <= `STATE_Wburst;
`else	           
	         module_next_state <= `STATE_Wstatus;
`endif	           
	         end
	       else module_next_state <= `STATE_Wburst;
	    end
	  `STATE_Wstatus:
	    begin
	       if(update_dr_i)  module_next_state <= `STATE_idle;  // client terminated early    
	       else if(word_count_zero) module_next_state <= `STATE_Wcrc;
	       // can't wait until bus ready if multiple devices in chain...
	       // Would have to read postfix_bits, then send another start bit and push it through
	       // prefix_bits...potentially very inefficient.
	       else module_next_state <= `STATE_Wburst;
	    end
	  
	  `STATE_Wcrc:
	    begin
	       if(update_dr_i)  module_next_state <= `STATE_idle;  // client terminated early
	       else if(bit_count_32) module_next_state <= `STATE_Wmatch;
	       else module_next_state <= `STATE_Wcrc;    
	    end
	  
	  `STATE_Wmatch:
	    begin
	       if(update_dr_i)  module_next_state <= `STATE_idle;
	       // This doubles as our recovery state, stay here until update_dr_i
	       else module_next_state <= `STATE_Wmatch;    
	    end

	  default: module_next_state <= `STATE_idle;  // shouldn't actually happen...
	endcase
     end


   // Outputs of state machine, pure combinatorial
   always @ (module_state or module_next_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i or operation_in[2]
	     or word_count_zero or bit_count_max or data_register_i[52] or biu_ready or intreg_instruction
	     or module_cmd or intreg_write or decremented_word_count)
     begin
	// Default everything to 0, keeps the case statement simple
	addr_sel <= 1'b1;  // Selects data for address_counter. 0 = data_register_i, 1 = incremented address count
	addr_ct_en <= 1'b0;  // Enable signal for address counter register
	op_reg_en <= 1'b0;  // Enable signal for 'operation' register
	bit_ct_en <= 1'b0;  // enable bit counter
	bit_ct_rst <= 1'b0;  // reset (zero) bit count register
	word_ct_sel <= 1'b1;  // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
	word_ct_en <= 1'b0;   // Enable byte counter register
	out_reg_ld_en <= 1'b0;  // Enable parallel load of data_out_shift_reg
	out_reg_shift_en <= 1'b0;  // Enable shift of data_out_shift_reg
	tdo_output_sel <= 2'b1;   // 1 = data reg, 0 = biu_ready, 2 = crc_match, 3 = CRC data
	biu_strobe <= 1'b0;
	crc_clr <= 1'b0;
	crc_en <= 1'b0;      // add the input bit to the CRC calculation
	crc_in_sel <= 1'b0;  // 0 = tdo, 1 = tdi
	crc_shift_en <= 1'b0;
	out_reg_data_sel <= 1'b1;  // 0 = BIU data, 1 = internal register data
	regsel_ld_en <= 1'b0;
	intreg_ld_en <= 1'b0;
	top_inhibit_o <= 1'b0;  // Don't disable the top-level module in the default case

	case(module_state)
	  `STATE_idle:
	    begin
	       addr_sel <= 1'b0;
	       word_ct_sel <= 1'b0;
	       
	       // Operations for internal registers - stay in idle state
	       if(module_select_i & shift_dr_i) out_reg_shift_en <= 1'b1; // For module regs
	       if(module_select_i & capture_dr_i) 
		 begin
		    out_reg_data_sel <= 1'b1;  // select internal register data
		    out_reg_ld_en <= 1'b1;   // For module regs
		 end
	       if(module_select_i & module_cmd & update_dr_i) begin
		  if(intreg_instruction) regsel_ld_en <= 1'b1;  // For module regs
		  if(intreg_write)       intreg_ld_en <= 1'b1;  // For module regs
	       end
	       
	       // Burst operations
	       if(module_next_state != `STATE_idle) begin  // Do the same to receive read or write opcode
		  addr_ct_en <= 1'b1;
		  op_reg_en <= 1'b1;
		  bit_ct_rst <= 1'b1;
		  word_ct_en <= 1'b1;
		  crc_clr <= 1'b1;
	       end
	    end

	  `STATE_Rbegin:
	    begin
	       if(!word_count_zero) begin  // Start a biu read transaction
		  biu_strobe <= 1'b1;
		  addr_sel <= 1'b1;
		  addr_ct_en <= 1'b1;
	       end
	    end

	  `STATE_Rready:
	    ; // Just a wait state
	  
	  `STATE_Rstatus:
	    begin
	       tdo_output_sel <= 2'h0;
	       top_inhibit_o <= 1'b1;    // in case of early termination
	       
	       if (module_next_state == `STATE_Rburst) 
	       begin
	         out_reg_data_sel <= 1'b0;  // select BIU data
	         out_reg_ld_en <= 1'b1;
	         bit_ct_rst <= 1'b1;
	         word_ct_sel <= 1'b1;
	         word_ct_en <= 1'b1;
	         if(!(decremented_word_count == 0) && !word_count_zero)  // Start a biu read transaction
	         begin
	           biu_strobe <= 1'b1;
	           addr_sel <= 1'b1;
	           addr_ct_en <= 1'b1;
	         end
	       end
	    end

	  `STATE_Rburst:
	    begin
	       tdo_output_sel <= 2'h1;
	       out_reg_shift_en <= 1'b1;
	       bit_ct_en <= 1'b1;
	       crc_en <= 1'b1;
	       crc_in_sel <= 1'b0;  // read data in output shift register LSB (tdo)
	       top_inhibit_o <= 1'b1;    // in case of early termination
	       
`ifdef ADBG_USE_HISPEED
	       if(bit_count_max)
	       begin
	         out_reg_data_sel <= 1'b0;  // select BIU data
	         out_reg_ld_en <= 1'b1;
	         bit_ct_rst <= 1'b1;
	         word_ct_sel <= 1'b1;
	         word_ct_en <= 1'b1;
	         if(!(decremented_word_count == 0) && !word_count_zero)  // Start a biu read transaction
	         begin
	           biu_strobe <= 1'b1;
	           addr_sel <= 1'b1;
	           addr_ct_en <= 1'b1;
	         end
	       end
`endif	       
	    end

	  `STATE_Rcrc:
	    begin
	       // Just shift out the data, don't bother counting, we don't move on until update_dr_i
	       tdo_output_sel <= 2'h3;
	       crc_shift_en <= 1'b1;
	       top_inhibit_o <= 1'b1;
	    end

	  `STATE_Wready:
	    ; // Just a wait state

	  `STATE_Wwait:
	    begin
	       tdo_output_sel <= 2'h1;
	       top_inhibit_o <= 1'b1;    // in case of early termination
	       if(module_next_state == `STATE_Wburst) begin
		  bit_ct_en <= 1'b1;
		  word_ct_sel <= 1'b1;  // Pre-decrement the byte count
		  word_ct_en <= 1'b1;
		  crc_en <= 1'b1;  // CRC gets tdi_i, which is 1 cycle ahead of data_register_i, so we need the bit there now in the CRC
		  crc_in_sel <= 1'b1;  // read data from tdi_i
	       end
	    end

	  `STATE_Wburst:
	    begin
	       bit_ct_en <= 1'b1;
	       tdo_output_sel <= 2'h1;
	       crc_en <= 1'b1;
	       crc_in_sel <= 1'b1;  // read data from tdi_i
	       top_inhibit_o <= 1'b1;    // in case of early termination
	       
`ifdef ADBG_USE_HISPEED
	       // It would be better to do this in STATE_Wstatus, but we don't use that state 
	       // if ADBG_USE_HISPEED is defined.  
	       if(bit_count_max)
		      begin
		      bit_ct_rst <= 1'b1;  // Zero the bit count
		      // start transaction. Can't do this here if not hispeed, biu_ready
		      // is the status bit, and it's 0 if we start a transaction here.
		      biu_strobe <= 1'b1;  // Start a BIU transaction
		      addr_ct_en <= 1'b1;  // Increment thte address counter
		      // Also can't dec the byte count yet unless hispeed,
		      // that would skip the last word.
		      word_ct_sel <= 1'b1;  // Decrement the byte count
		      word_ct_en <= 1'b1;
		      end
`endif		       
	    end

	  `STATE_Wstatus:
	    begin
	       tdo_output_sel <= 2'h0;  // Send the status bit to TDO
	       // start transaction
	       biu_strobe <= 1'b1;  // Start a BIU transaction
	       word_ct_sel <= 1'b1;  // Decrement the byte count
	       word_ct_en <= 1'b1;
	       bit_ct_rst <= 1'b1;  // Zero the bit count
	       addr_ct_en <= 1'b1;  // Increment thte address counter
	       top_inhibit_o <= 1'b1;    // in case of early termination
	    end
	  
	  `STATE_Wcrc:
	    begin
               bit_ct_en <= 1'b1;
               top_inhibit_o <= 1'b1;    // in case of early termination
               if(module_next_state == `STATE_Wmatch) tdo_output_sel <= 2'h2;  // This is when the 'match' bit is actually read
	    end
	  
	  `STATE_Wmatch:
	    begin
               tdo_output_sel <= 2'h2;
               top_inhibit_o <= 1'b1;    // in case of early termination
	    end

	  default: ;
	endcase
     end


endmodule

