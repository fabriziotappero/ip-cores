//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_defines.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the Advanced Debug Interface.          ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 - 2010 Authors                            ////
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
// Length of the MODULE ID register
// How many modules can be supported by the module id length
// Chains
// Length of data
// If WISHBONE sub-module is supported uncomment the following line
//`define DBG_WISHBONE_SUPPORTED
// If CPU_0 sub-module is supported uncomment the following line
//`define DBG_CPU0_SUPPORTED
// If CPU_1 sub-module is supported uncomment the following line
//`define DBG_CPU1_SUPPORTED
// To include the JTAG Serial Port (JSP), uncomment the following line
// Define this if you intend to use the JSP in a system with multiple
// devices on the JTAG chain
// If this is defined, status bits will be skipped on burst
// reads and writes to improve download speeds.
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_top.v                                                  ////
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
//// Copyright (C) 2008-2010 Authors                              ////
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
// Top module
module adv_dbg_if_jfifo (
                // JTAG signals
                tck_i,
                tdi_i,
                tdo_o,
                rst_i,
                // TAP states
                shift_dr_i,
                update_dr_i,
                capture_dr_i,
                // Instructions
                debug_select_i
                ,
		wb_clk_i,
                // WISHBONE target interface
                wb_jsp_dat_i,
                wb_jsp_stb_i,
		biu_wr_strobe,
		jsp_data_out
		);
   // JTAG signals
   input   tck_i;
   input   tdi_i;
   output  tdo_o;
   input   rst_i;
   // TAP states
   input   shift_dr_i;
   input   update_dr_i;
   input   capture_dr_i;
   // Module select from TAP
   input   debug_select_i;
   input   wb_clk_i;
   input [7:0]  wb_jsp_dat_i;
   input         wb_jsp_stb_i;
   output 	 biu_wr_strobe;
   output [7:0]	 jsp_data_out;
   reg 		 tdo_o;
   wire 	 tdo_wb;
   wire 	 tdo_cpu0;
   wire 	 tdo_cpu1;
   wire          tdo_jsp;
   // Registers
   reg [53-1:0] input_shift_reg;  // 1 bit sel/cmd, 4 bit opcode, 32 bit address, 16 bit length = 53 bits
   //reg output_shift_reg;  // Just 1 bit for status (valid module selected)
   reg [2 -1:0] module_id_reg;   // Module selection register
   // Control signals
   wire 				      select_cmd;  // True when the command (registered at Update_DR) is for top level/module selection
   wire [(2 - 1) : 0] module_id_in;    // The part of the input_shift_register to be used as the module select data
   reg [(4 - 1) : 0]       module_selects;  // Select signals for the individual modules
   wire 				      select_inhibit;  // OR of inhibit signals from sub-modules, prevents latching of a new module ID
   wire [3:0] 				      module_inhibit;  // signals to allow submodules to prevent top level from latching new module ID
   ///////////////////////////////////////
   // Combinatorial assignments
assign select_cmd = input_shift_reg[52];
assign module_id_in = input_shift_reg[51:50];
//////////////////////////////////////////////////////////
// Module select register and select signals
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)                             module_id_reg <= 2'b0;
  else if(debug_select_i && select_cmd && update_dr_i && !select_inhibit)       // Chain select
    module_id_reg <= module_id_in;
end
always @ (module_id_reg)
begin
	module_selects                 = 4'h0;
	module_selects[module_id_reg]  = 1'b1;
end
///////////////////////////////////////////////
// Data input shift register
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    input_shift_reg <= 53'h0;
  else if(debug_select_i && shift_dr_i)
    input_shift_reg <= {tdi_i, input_shift_reg[52:1]};
end
//////////////////////////////////////////////
// Debug module instantiations
assign tdo_wb = 1'b0;
assign module_inhibit[2'h0] = 1'b0;
assign tdo_cpu0 = 1'b0;
assign module_inhibit[2'h1] = 1'b0;
assign tdo_cpu1 = 1'b0;
assign module_inhibit[2'h2] = 1'b0;
adv_dbg_if_jfifo_jfifo_module i_dbg_jfifo (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_jsp),
                  .tdi_i            (tdi_i),
                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),
                  .data_register_i  (input_shift_reg),
                  .module_select_i  (debug_select_i),
//                  .module_select_i  (module_selects[`DBG_TOP_JSP_DEBUG_MODULE]),
                  .rst_i            (rst_i),
                  // WISHBONE common signals
                  .wb_clk_i         (wb_clk_i),
                  // WISHBONE master interface
                  .wb_dat_i         (wb_jsp_dat_i),
                  .wb_stb_i         (wb_jsp_stb_i),
                  .biu_wr_strobe    (biu_wr_strobe),
		  .jsp_data_out     (jsp_data_out)
            );
assign select_inhibit = |module_inhibit;
assign module_inhibit[2'h3] = 1'b0;
/////////////////////////////////////////////////
// TDO output MUX
always @ (*)
begin
   case (debug_select_i)
             1:       tdo_o = tdo_jsp;
       default:       tdo_o = 1'b0;
   endcase
end
endmodule
//////////////////////////////////////////////////////////////////////
// File:  CRC32.v                             
// Date:  Thu Nov 27 13:56:49 2003                                                      
//                                                                     
// Copyright (C) 1999-2003 Easics NV.                 
// This source file may be used and distributed without restriction    
// provided that this copyright statement is not removed from the file 
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose: Verilog module containing a synthesizable CRC function
//   * polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
//   * data width: 1
//                                                                     
// Info: janz@easics.be (Jan Zegers)                           
//       http://www.easics.com
//
// Modified by Nathan Yawn for the Advanced Debug Module
// Changes (C) 2008 - 2010 Nathan Yawn                                 
///////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: adbg_crc32.v,v $
// Revision 1.3  2011-10-24 02:25:11  natey
// Removed extraneous '#1' delays, which were a holdover from the original
// versions in the previous dbg_if core.
//
// Revision 1.2  2010-01-10 22:54:10  Nathan
// Update copyright dates
//
// Revision 1.1  2008/07/22 20:28:29  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.3  2008/07/06 20:02:53  Nathan
// Fixes for synthesis with Xilinx ISE (also synthesizable with 
// Quartus II 7.0).  Ran through dos2unix.
//
// Revision 1.2  2008/06/20 19:22:10  Nathan
// Reversed the direction of the CRC computation shift, for a more 
// hardware-efficient implementation.
//
//
//
//
module adv_dbg_if_jfifo_crc32 (clk, data, enable, shift, clr, rst, crc_out, serial_out);
input         clk;
input         data;
input         enable;
input         shift;
input         clr;
input         rst;
output [31:0] crc_out;
output        serial_out;
reg    [31:0] crc;
wire   [31:0] new_crc;
// You may notice that the 'poly' in this implementation is backwards.
// This is because the shift is also 'backwards', so that the data can
// be shifted out in the same direction, which saves on logic + routing.
assign new_crc[0] = crc[1];
assign new_crc[1] = crc[2];
assign new_crc[2] = crc[3];
assign new_crc[3] = crc[4];
assign new_crc[4] = crc[5];
assign new_crc[5] = crc[6] ^ data ^ crc[0];
assign new_crc[6] = crc[7];
assign new_crc[7] = crc[8];
assign new_crc[8] = crc[9] ^ data ^ crc[0];
assign new_crc[9] = crc[10] ^ data ^ crc[0];
assign new_crc[10] = crc[11];
assign new_crc[11] = crc[12];
assign new_crc[12] = crc[13];
assign new_crc[13] = crc[14];
assign new_crc[14] = crc[15];
assign new_crc[15] = crc[16] ^ data ^ crc[0];
assign new_crc[16] = crc[17];
assign new_crc[17] = crc[18];
assign new_crc[18] = crc[19];
assign new_crc[19] = crc[20] ^ data ^ crc[0];
assign new_crc[20] = crc[21] ^ data ^ crc[0];
assign new_crc[21] = crc[22] ^ data ^ crc[0];
assign new_crc[22] = crc[23];
assign new_crc[23] = crc[24] ^ data ^ crc[0];
assign new_crc[24] = crc[25] ^ data ^ crc[0];
assign new_crc[25] = crc[26];
assign new_crc[26] = crc[27] ^ data ^ crc[0];
assign new_crc[27] = crc[28] ^ data ^ crc[0];
assign new_crc[28] = crc[29];
assign new_crc[29] = crc[30] ^ data ^ crc[0];
assign new_crc[30] = crc[31] ^ data ^ crc[0];
assign new_crc[31] =           data ^ crc[0];
always @ (posedge clk or posedge rst)
begin
  if(rst)
    crc[31:0] <= 32'hffffffff;
  else if(clr)
    crc[31:0] <= 32'hffffffff;
  else if(enable)
    crc[31:0] <= new_crc;
  else if (shift)
    crc[31:0] <= {1'b0, crc[31:1]};
end
//assign crc_match = (crc == 32'h0);
assign crc_out = crc; //[31];
assign serial_out = crc[0];
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_jfifo_biu.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Debug Interface.               ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010        Authors                            ////
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
// This is where the magic happens in the JTAG Serial Port.  The serial
// port FIFOs and counters are kept in the WishBone clock domain.
// 'Syncflop' elements are used to synchronize strobe lines across
// clock domains, and 'syncreg' elements keep the byte and free count
// as current as possible in the JTAG clock domain.  Also in the WB
// clock domain is a WishBone target interface, which more or less
// tries to emulate a 16550 without FIFOs (despite the fact that
// FIFOs are actually present, they are opaque to the WB interface.)
//
// Top module
module adv_dbg_if_jfifo_jfifo_biu
  (
   // Debug interface signals
   tck_i,
   rst_i,
   data_o,
   bytes_available_o,
   bytes_free_o,
   rd_strobe_i,
   wr_strobe_i,
   // Wishbone signals
   wb_clk_i,
   wb_dat_i,
   wb_stb_i
   );
   // Debug interface signals
   input tck_i;
   input rst_i;
   output [7:0] data_o;
   output [3:0] bytes_free_o;
   output [3:0] bytes_available_o;
   input 	rd_strobe_i;
   input 	wr_strobe_i;
   // Wishbone signals
   input 	 wb_clk_i;
   input  [7:0]  wb_dat_i;
   input 	 wb_stb_i;
   wire [7:0] 	 data_o;
   wire [3:0] 	 bytes_free_o;
   assign        bytes_free_o = 4'b0100;
   wire [3:0] 	 bytes_available_o;
   // Registers
   reg [7:0] 	 rdata;
   reg 		 ren_tff;
   // Wires  
   wire 	 wb_fifo_ack;
   wire [3:0] 	 wr_bytes_free;
   wire [3:0] 	 rd_bytes_avail;
   wire [3:0]	 wr_bytes_avail;  // used to generate wr_fifo_not_empty
   assign       wr_bytes_avail = 4'b0000;
   wire 	 rd_bytes_avail_not_zero;
   wire 	 ren_sff_out;   
   wire [7:0] 	 rd_fifo_data_out;
   wire 	 wr_fifo_not_empty;  // this is for the WishBone interface LSR register
   // Control Signals (FSM outputs)
   reg 		 ren_rst;   // reset 'pop' SFF
   reg 		 rdata_en;  // enable 'rdata' register
   reg 		 rpp;       // read FIFO PUSH (1) or POP (0)
   reg 		 r_fifo_en; // enable read FIFO    
   reg 		 r_wb_ack;  // read FSM acks WB transaction
   // Indicators to FSMs
   wire 	 pop;         // JTAG side received a byte, pop and get next
   wire 	 rcz;         // zero bytes available in read FIFO
   //////////////////////////////////////////////////////
   // TCK clock domain
   // There is no FSM here, just signal latching and clock
   // domain synchronization
   assign 	 data_o = rdata;
   // Read enable (REN) toggle FF
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) ren_tff <= 1'b0;
	else if(rd_strobe_i) ren_tff <= ~ren_tff;
     end
   ///////////////////////////////////////////////////////
   // Wishbone clock domain
   // Combinatorial assignments
   assign rd_bytes_avail_not_zero = !(rd_bytes_avail == 4'h0);
   assign pop = ren_sff_out & rd_bytes_avail_not_zero;
   assign rcz = ~rd_bytes_avail_not_zero;
   assign wb_fifo_ack = r_wb_ack ;
   assign wr_fifo_not_empty = 1'b0;
   // rdata register
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) rdata <= 8'h0;
	else if(rdata_en) rdata <= rd_fifo_data_out;
     end
   // REN SFF
   adv_dbg_if_jfifo_syncflop ren_sff (
                     .DEST_CLK(wb_clk_i),
		     .D_SET(1'b0),
		     .D_RST(ren_rst),
		     .RESET(rst_i),
                     .TOGGLE_IN(ren_tff),
                     .D_OUT(ren_sff_out)
		     );
   // 'bytes available' syncreg
   adv_dbg_if_jfifo_syncreg bytesavail_syncreg (
			      .CLKA(wb_clk_i),
			      .CLKB(tck_i),
			      .RST(rst_i),
			      .DATA_IN(rd_bytes_avail),
			      .DATA_OUT(bytes_available_o)
			      );
   // read FIFO
   adv_dbg_if_jfifo_bytefifo rd_fifo (
		     .CLK          ( wb_clk_i          ),
		     .RST          ( rst_i             ),  // rst_i from JTAG clk domain, xmit_fifo_rst from WB, RST is async reset
                     .DATA_IN      ( wb_dat_i[7:0]     ),
		     .DATA_OUT     ( rd_fifo_data_out  ),
		     .PUSH_POPn    ( rpp               ),
                     .EN           ( r_fifo_en         ),
                     .BYTES_AVAIL  ( rd_bytes_avail    ),
		     .BYTES_FREE   (                   )
		     );			      
   /////////////////////////////////////////////////////
   // State machine for the read FIFO
   reg [1:0] rd_fsm_state;
   reg [1:0]   next_rd_fsm_state;
   // Sequential bit
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) rd_fsm_state <= 2'h0;
	else rd_fsm_state <= next_rd_fsm_state; 
     end
   // Determination of next state (combinatorial)
   always @ (*)
     begin
	case (rd_fsm_state)
          2'h0:
            begin
               if(wb_stb_i) next_rd_fsm_state = 2'h1;
               else if (pop) next_rd_fsm_state = 2'h2;
               else next_rd_fsm_state = 2'h0;
            end
          2'h1:
            begin
               if(rcz) next_rd_fsm_state = 2'h3;  // putting first item in fifo, move to rdata in state LATCH
               else if(pop) next_rd_fsm_state = 2'h2;
	       else next_rd_fsm_state = 2'h0;
            end
	  2'h2:
	    begin
	       next_rd_fsm_state = 2'h3; // new data at FIFO head, move to rdata in state LATCH
	    end
	  2'h3:
	    begin
	       if(wb_stb_i) next_rd_fsm_state = 2'h1;
	       else if(pop) next_rd_fsm_state = 2'h2;
	       else next_rd_fsm_state = 2'h0;
	    end
	  default:
	    begin
	       next_rd_fsm_state = 2'h0;
	    end
	endcase
     end
   // Outputs of state machine (combinatorial)
   always @ (rd_fsm_state)
     begin
	ren_rst = 1'b0;
	rpp = 1'b0;
	r_fifo_en = 1'b0;
	rdata_en = 1'b0;
	r_wb_ack = 1'b0;
	case (rd_fsm_state)
          2'h0:;
          2'h1:
            begin
	       rpp = 1'b1;
	       r_fifo_en = 1'b1;
	       r_wb_ack = 1'b1;
            end
	  2'h2:
	    begin
	       ren_rst = 1'b1;
	       r_fifo_en = 1'b1;
	    end
	  2'h3:
	    begin
	       rdata_en = 1'b1;
	    end
	endcase
     end
endmodule
/////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_jfifo_module.v                                         ////
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
// Module interface
module adv_dbg_if_jfifo_jfifo_module (
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
			 rst_i,
                         jsp_data_out,
                         biu_wr_strobe,			    
			 // WISHBONE 
			 wb_clk_i, wb_dat_i, wb_stb_i 
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
   input         rst_i;
   output [7:0]  jsp_data_out;
   output        biu_wr_strobe;
   // WISHBONE slave interface
   input         wb_clk_i;
   input  [7:0]  wb_dat_i;
   input         wb_stb_i;
   reg [7:0]   jsp_data_out;      
   // Declare inputs / outputs as wires / registers
   wire 	 module_tdo_o;
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
   wire [7:0] 	 out_reg_data;           // parallel input to the output shift register
   wire [7:0] 	 count_data_from_biu;
   //////////////////////////////////////
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)                   jsp_data_out <= 8'h00;
	else if(biu_wr_strobe)      jsp_data_out <= data_to_biu;
        else                        jsp_data_out <= jsp_data_out;
     end
   /////////////////////////////////////////////////
   // Combinatorial assignments
   assign count_data_from_biu = {biu_bytes_available, biu_space_available};
   assign count_data_in = {tdi_i,data_register_i[52:50]};  // Second nibble of user data
   assign data_to_biu   = {tdi_i,data_register_i[52:46]};
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
   assign out_reg_data = (out_reg_data_sel) ? count_data_from_biu   : data_from_biu;
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)                 data_out_shift_reg     <= 8'h0;
	else if(out_reg_ld_en)    data_out_shift_reg     <= out_reg_data;
	else if(out_reg_shift_en) data_out_shift_reg     <= {1'b0, data_out_shift_reg[7:1]};
     end
   assign module_tdo_o = data_out_shift_reg[0];
   ////////////////////////////////////////
   // Bus Interface Unit (to JTAG  UART)
   // It is assumed that the BIU has internal registers, and will
   // latch write data (and ack read data) on rising clock edge 
   // when strobe is asserted
   adv_dbg_if_jfifo_jfifo_biu jsp_biu_i (
			   // Debug interface signals
			   .tck_i             (tck_i),
			   .rst_i             (rst_i),
			   .data_o            (data_from_biu),
			   .bytes_available_o (biu_bytes_available),
			   .bytes_free_o      (biu_space_available),
			   .rd_strobe_i       (biu_rd_strobe),
			   .wr_strobe_i       (biu_wr_strobe),
			   // Wishbone slave signals
			   .wb_clk_i        (wb_clk_i),
			   .wb_dat_i        (wb_dat_i),
			   .wb_stb_i        (wb_stb_i)
			   );
   ////////////////////////////////////////
   // Input Control FSM
   // Definition of machine state values.
   // Don't worry too much about the state encoding, the synthesis tool
   // will probably re-encode it anyway.
   reg [2:0] wr_module_state;       // FSM state
   reg [2:0] wr_module_next_state;  // combinatorial signal, not actually a register
reg [8*16-1:0] wr_module_string;
always @(*) begin
   case (wr_module_state)
      3'h0:      wr_module_string = "wr_idle";
      3'h1:      wr_module_string = "wr_wait";
      3'h2:    wr_module_string = "wr_counts";
      3'h3:      wr_module_string = "wr_xfer";
      default:             wr_module_string = "-XXXXXX-";
   endcase
   $display("%t  %m   JFifo wr_module State   = %s",$realtime, wr_module_string);
end
 //  `ifndef SYNTHESYS
   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  wr_module_state <= 3'h0;
	else  
	  wr_module_state <= wr_module_next_state;
     end
   // Determination of next state; purely combinatorial
   always @ (wr_module_state or module_select_i or update_dr_i or capture_dr_i 
	     or shift_dr_i or wr_bit_count_max or tdi_i)
     begin
	case(wr_module_state)
	  3'h0:
	    begin
	       if(module_select_i && capture_dr_i) wr_module_next_state = 3'h1;
	       else wr_module_next_state = 3'h0;
	    end
	   3'h1:
	   begin 
	     	 if(update_dr_i) wr_module_next_state = 3'h0;
	    	  else if(module_select_i && tdi_i  && shift_dr_i     ) wr_module_next_state = 3'h2;  // got start bit
	       else wr_module_next_state = 3'h1;
	   end
	  3'h2:
	    begin
	       if(update_dr_i)                                 wr_module_next_state = 3'h0;
	       else if(wr_bit_count_max   && shift_dr_i )      wr_module_next_state = 3'h3;
	       else                                            wr_module_next_state = 3'h2;
	    end
	  3'h3:
	    begin
	       if(update_dr_i) wr_module_next_state = 3'h0;
	       else wr_module_next_state = 3'h3;
	    end
	  default: wr_module_next_state = 3'h0;  // shouldn't actually happen...
	endcase
     end
   // Outputs of state machine, pure combinatorial
   always @ (wr_module_state or wr_module_next_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i
	     or in_word_count_zero or out_word_count_zero or wr_bit_count_max or decremented_in_word_count
	     or decremented_out_word_count or user_word_count_zero)
     begin
	// Default everything to 0, keeps the case statement simple
	wr_bit_ct_en = 1'b0;         // enable bit counter
	wr_bit_ct_rst = 1'b0;        // reset (zero) bit count register
	in_word_ct_sel = 1'b0;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
	user_word_ct_sel = 1'b0;  // selects data for user byte counter, 0 = user data, 1 = decremented count
	in_word_ct_en = 1'b0;     // Enable input byte counter register
	user_word_ct_en = 1'b0;   // enable user byte count register
	biu_wr_strobe = 1'b0;    // Indicates BIU should latch input + begin a write operation
	case(wr_module_state)
	  3'h0:
	    begin
	       in_word_ct_sel = 1'b0;
	       // Going to transfer; enable count registers and output register
	       if(wr_module_next_state != 3'h0) begin
		  wr_bit_ct_rst = 1'b1;
		  in_word_ct_en = 1'b1;
	       end
	    end
	  // This state is only used when support for multi-device JTAG chains is enabled.
	  3'h1:
	    begin
	       wr_bit_ct_en = 1'b0;  // Don't do anything, just wait for the start bit.
	    end
	  3'h2:
	    begin
	       if(shift_dr_i) begin // Don't do anything in PAUSE or EXIT states...
		  wr_bit_ct_en = 1'b1;
		  user_word_ct_sel = 1'b0;
		  if(wr_bit_count_max) begin
		     wr_bit_ct_rst = 1'b1;
		     user_word_ct_en = 1'b1;
		  end
	       end
	    end
	  3'h3:
	    begin
	       if(shift_dr_i) begin  // Don't do anything in PAUSE or EXIT states
		  wr_bit_ct_en = 1'b1;
		  in_word_ct_sel = 1'b1;
		  user_word_ct_sel = 1'b1;
		  if(wr_bit_count_max) begin  // Start biu transactions, if word counts allow
		     wr_bit_ct_rst = 1'b1;
		     if(!(in_word_count_zero || user_word_count_zero)) begin
			biu_wr_strobe = 1'b1;
			in_word_ct_en = 1'b1;
			user_word_ct_en = 1'b1;
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
// We do not send the equivalent of a 'start bit' (like the one the input FSM
// waits for when support for multi-device JTAG chains is enabled).  Since the
// input and output are going to be offset anyway, why bother...
   reg [2:0] rd_module_state;       // FSM state
   reg [2:0] rd_module_next_state;  // combinatorial signal, not actually a register
reg [8*16-1:0] rd_module_string;
always @(*) begin
   case (rd_module_state)
      3'h0:      rd_module_string = "rd_idle";
      3'h1:    rd_module_string = "rd_counts";
      3'h2:     rd_module_string = "rd_rdack";
      3'h3:      rd_module_string = "rd_xfer";
      default:             rd_module_string = "-XXXXXX-";
   endcase
   $display("%t  %m   JFifo rd_module State   = %s",$realtime, rd_module_string);
end
 //  `ifndef SYNTHESYS
   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  rd_module_state <= 3'h0;
	else
	  rd_module_state <= rd_module_next_state;
     end
   // Determination of next state; purely combinatorial
   always @ (rd_module_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i or rd_bit_count_max)
     begin
	case(rd_module_state)
	  3'h0:
	    begin
	       if(module_select_i && capture_dr_i) rd_module_next_state = 3'h1;
	       else rd_module_next_state = 3'h0;
	    end
	  3'h1:
	    begin
	       if(update_dr_i) rd_module_next_state = 3'h0;
	       else if(rd_bit_count_max  && shift_dr_i ) rd_module_next_state = 3'h2;
	       else rd_module_next_state = 3'h1;
	    end
	  3'h2:
	    begin
               if(update_dr_i) rd_module_next_state = 3'h0;
	       else if(shift_dr_i ) rd_module_next_state = 3'h3;
               else rd_module_next_state = 3'h2;
	    end
	  3'h3:
	    begin
	       if(update_dr_i) rd_module_next_state = 3'h0;
	       else if(rd_bit_count_max  && shift_dr_i ) rd_module_next_state = 3'h2;
	       else rd_module_next_state = 3'h3;
	    end
	  default: rd_module_next_state = 3'h0;  // shouldn't actually happen...
	endcase
     end
   // Outputs of state machine, pure combinatorial
   always @ (rd_module_state or rd_module_next_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i
	     or in_word_count_zero or out_word_count_zero or rd_bit_count_max or decremented_in_word_count
	     or decremented_out_word_count)
     begin
	// Default everything to 0, keeps the case statement simple
	rd_bit_ct_en = 1'b0;         // enable bit counter
	rd_bit_ct_rst = 1'b0;        // reset (zero) bit count register
	out_word_ct_sel = 1'b0;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
	out_word_ct_en = 1'b0;    // Enable output byte count register
	out_reg_ld_en = 1'b0;     // Enable parallel load of data_out_shift_reg
	out_reg_shift_en = 1'b0;  // Enable shift of data_out_shift_reg
	out_reg_data_sel = 1'b0;  // 0 = BIU data, 1 = byte count data (also from BIU)
	biu_rd_strobe = 1'b0;     // Indicates that the bus unit should ACK the last read operation + start another
	case(rd_module_state)
	  3'h0:
	    begin
	       out_reg_data_sel = 1'b1;
	       out_word_ct_sel = 1'b0;
	       // Going to transfer; enable count registers and output register
	       if(rd_module_next_state != 3'h0) begin
		  out_reg_ld_en = 1'b1;
		  rd_bit_ct_rst = 1'b1;
		  out_word_ct_en = 1'b1;
	       end
	    end
	  3'h1:
	    begin
	       if(shift_dr_i) begin // Don't do anything in PAUSE or EXIT states...
		  rd_bit_ct_en = 1'b1;
		  out_reg_shift_en = 1'b1;
		  if(rd_bit_count_max) begin
		     rd_bit_ct_rst = 1'b1;
		     // Latch the next output word, but don't ack until STATE_rd_rdack
		     if(!out_word_count_zero) begin
			out_reg_ld_en = 1'b1;
			out_reg_shift_en = 1'b0;
		     end
		  end
	       end
	    end
	  3'h2:
	    begin
	       if(shift_dr_i) begin  // Don't do anything in PAUSE or EXIT states
		  rd_bit_ct_en = 1'b1;
		  out_reg_shift_en = 1'b1;
		  out_reg_data_sel = 1'b0;
		  // Never have to worry about bit_count_max here.
		  if(!out_word_count_zero) begin
		     biu_rd_strobe = 1'b1;
		  end
	       end
	    end
	  3'h3:
	    begin
	       if(shift_dr_i) begin  // Don't do anything in PAUSE or EXIT states
		  rd_bit_ct_en = 1'b1;
		  out_word_ct_sel = 1'b1;
		  out_reg_shift_en = 1'b1;
		  out_reg_data_sel = 1'b0;
		  if(rd_bit_count_max) begin  // Start biu transaction, if word count allows
		     rd_bit_ct_rst = 1'b1;
		     // Don't ack the read byte here, we do it in STATE_rdack
		     if(!out_word_count_zero) begin
			out_reg_ld_en = 1'b1;
			out_reg_shift_en = 1'b0;
			out_word_ct_en = 1'b1;
		     end
		  end
	       end
	    end
	  default: ;
	endcase
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_bytefifo.v                                             ////
////                                                              ////
////                                                              ////
////  A simple byte-wide FIFO with byte and free space counts     ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors                                   ////
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
// This is an 8-entry, byte-wide, single-port FIFO.  It can either
// push or pop a byte each clock cycle (but not both).  It includes
// outputs indicating the number of bytes in the FIFO, and the number
// of bytes free - if you don't connect BYTES_FREE, the synthesis
// tool should eliminate the hardware to generate it.
//
// This attempts to use few resources.  There is only 1 counter,
// and only 1 decoder.  The FIFO works like a big shift register:
// bytes are always written to entry '0' of the FIFO, and older
// bytes are shifted toward entry '7' as newer bytes are added.
// The counter determines which entry the output reads.
//
// One caveat is that the DATA_OUT will glitch during a 'push'
// operation.  If the output is being sent to another clock
// domain, you should register it first.
//
// Ports:
// CLK:  Clock for all synchronous elements
// RST:  Zeros the counter and all registers asynchronously
// DATA_IN: Data to be pushed into the FIFO
// DATA_OUT: Always shows the data at the head of the FIFO, '00' if empty
// PUSH_POPn: When high (and EN is high), DATA_IN will be pushed onto the
//            FIFO and the count will be incremented at the next posedge
//            of CLK (assuming the FIFO is not full).  When low (and EN
//            is high), the count will be decremented and the output changed
//            to the next value in the FIFO (assuming FIFO not empty).
// EN: When high at posedege CLK, a push or pop operation will be performed,
//     based on the value of PUSH_POPn, assuming sufficient data or space.
// BYTES_AVAIL: Number of bytes in the FIFO.  May be in the range 0 to 8.
// BYTES_FREE: Free space in the FIFO.  May be in the range 0 to 8.          
// Top module
module adv_dbg_if_jfifo_bytefifo (
		 CLK,
		 RST,
                 DATA_IN,
		 DATA_OUT,
		 PUSH_POPn,
                 EN,
                 BYTES_AVAIL,
		 BYTES_FREE
		);
   input        CLK;
   input        RST;
   input  [7:0] DATA_IN;
   output [7:0] DATA_OUT;
   input        PUSH_POPn;
   input        EN;
   output [3:0] BYTES_AVAIL;
   output [3:0] BYTES_FREE;
   reg [7:0] 	reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
   reg [3:0] 	counter;
   reg [7:0]  DATA_OUT;
   wire [3:0]  BYTES_AVAIL;
   wire [3:0] 	BYTES_FREE;
   wire 	push_ok;
   wire    pop_ok;
   ///////////////////////////////////
   // Combinatorial assignments
   assign BYTES_AVAIL = counter;  
   assign  BYTES_FREE = 4'h8 - BYTES_AVAIL;
   assign  push_ok = !(counter == 4'h8);
   assign  pop_ok = !(counter == 4'h0);
   ///////////////////////////////////
   // FIFO memory / shift registers
   // Reg 0 - takes input from DATA_IN
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg0 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg0 <= DATA_IN;
     end
   // Reg 1 - takes input from reg0
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg1 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg1 <= reg0;
     end
   // Reg 2 - takes input from reg1
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg2 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg2 <= reg1;
     end
   // Reg 3 - takes input from reg2
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg3 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg3 <= reg2;
     end
   // Reg 4 - takes input from reg3
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg4 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg4 <= reg3;
     end
   // Reg 5 - takes input from reg4
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg5 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg5 <= reg4;
     end
   // Reg 6 - takes input from reg5
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg6 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg6 <= reg5;
     end
   // Reg 7 - takes input from reg6
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg7 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg7 <= reg6;
     end
   ///////////////////////////////////////////////////
   // Read counter
   // This is a 4-bit saturating up/down counter
  // The 'saturating' is done via push_ok and pop_ok
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)             counter <= 4'h0;
	else if(EN & PUSH_POPn & push_ok)  counter <= counter + 4'h1;
	else if(EN & (~PUSH_POPn) & pop_ok)    counter <= counter - 4'h1;
     end
   /////////////////////////////////////////////////
   // Output decoder
   always @ (counter or reg0 or reg1 or reg2 or reg3 or reg4 or reg5
	     or reg6 or reg7)
     begin
	case (counter)
	  4'h1:     DATA_OUT = reg0; 
	  4'h2:     DATA_OUT = reg1;
	  4'h3:     DATA_OUT = reg2;
	  4'h4:     DATA_OUT = reg3;
	  4'h5:     DATA_OUT = reg4;
	  4'h6:     DATA_OUT = reg5;
	  4'h7:     DATA_OUT = reg6;
	  4'h8:     DATA_OUT = reg7;
	  default:  DATA_OUT = 8'h00;
	endcase
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_syncflop.v                                             ////
////                                                              ////
////                                                              ////
////  A generic synchronization device between two clock domains  ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors                                   ////
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
// This is a synchronization element between two clock domains. It
// uses toggle signaling - that is, clock domain 1 changes the state
// of TOGGLE_IN to indicate a change, rather than setting the level
// high.  When TOGGLE_IN changes state, the output on D_OUT will be
// set to level '1', and will hold that value until D_RST is held
// high during a rising edge of DEST_CLK.  D_OUT will be updated
// on the second rising edge of DEST_CLK after the state of
// TOGGLE_IN has changed.
// RESET is asynchronous.  This is necessary to coordinate the reset
// between different clock domains with potentially different reset
// signals.
//
// Ports:
// DEST_CLK:  Clock for the target clock domain
// D_SET:     Synchronously set the output to '1'
// D_CLR:     Synchronously reset the output to '0'
// RESET:     Set all FF's to '0' (asynchronous)
// TOGGLE_IN: Toggle data signal from source clock domain
// D_OUT:     Output to clock domain 2
// Top module
module adv_dbg_if_jfifo_syncflop(
                DEST_CLK,
		D_SET,
		D_RST,
		RESET,
                TOGGLE_IN,
                D_OUT
		);
   input   DEST_CLK;
   input   D_SET;
   input   D_RST;
   input   RESET;
   input   TOGGLE_IN;
   output  D_OUT;
   reg 	   sync1;
   reg 	   sync2;
   reg 	   syncprev;
   reg 	   srflop;
   wire    syncxor;
   wire    srinput;
   wire    D_OUT;
   // Combinatorial assignments
   assign  syncxor = sync2 ^ syncprev;
   assign  srinput = syncxor | D_SET;  
   assign  D_OUT = srflop | syncxor;
   // First DFF (always enabled)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) sync1 <= 1'b0;
	else sync1 <= TOGGLE_IN;
     end
   // Second DFF (always enabled)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) sync2 <= 1'b0;
	else sync2 <= sync1;
     end
   // Third DFF (always enabled, used to detect toggles)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) syncprev <= 1'b0;
	else syncprev <= sync2;
     end
   // Set/Reset FF (holds detected toggles)
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET)         srflop <= 1'b0;
	else if(D_RST)    srflop <= 1'b0;
	else if (srinput) srflop <= 1'b1;
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_syncreg.v                                              ////
////                                                              ////
////                                                              ////
////  Synchronizes a register between two clock domains           ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors                                   ////
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
// This is a synchronization element between two clock domains. Domain A
// is considered the 'source' domain (produces the data), and Domain B
// is considered the 'destination' domain (consumes the data).  It is assumed
// that clock A is faster than clock B, but this element will work
// regardless.  The idea here is NOT to insure that domain B sees every
// change to the value generated by domain A.  Rather, this device
// attempts to keep the value seen by domain B as current as possible,
// always updating to the latest value of the input in domain A.
// Thus, there may be dozens or hundreds of changes to register A
// which are not seen by domain B.  There is no external acknowledge
// of receipt from domain B.  Domain B simply wants the most current
// value of register A possible at any given time.
// Note the reset is asynchronous; this is necessary to coordinate between
// two clock domains which may have separate reset signals.  I could find
// no other way to insure correct initialization with two separate 
// reset signals.
//
// Ports:
// CLKA:  Clock for the source domain
// CLKB:  Clock for the destination domain
// RST:  Asynchronously resets all sync elements, prepares
//       unit for operation.
// DATA_IN:  Data input from clock domain A
// DATA_OUT: Data output to clock domain B
// 
// Top module
module adv_dbg_if_jfifo_syncreg (
                CLKA,
		CLKB,
		RST,
                DATA_IN,
                DATA_OUT
		);
   input   CLKA;
   input   CLKB;
   input   RST;
   input   [3:0] DATA_IN;
   output  [3:0] DATA_OUT;
   reg 	   [3:0] regA;
   reg 	   [3:0] regB;
   reg 	   strobe_toggle;
   reg 	   ack_toggle;
   wire    A_not_equal;
   wire    A_enable;
   wire    strobe_sff_out;
   wire    ack_sff_out;
   wire [3:0]   DATA_OUT;
   // Combinatorial assignments
   assign  A_enable = A_not_equal & ack_sff_out;
   assign  A_not_equal = !(DATA_IN == regA);
   assign DATA_OUT = regB;   
   // register A (latches input any time it changes)
   always @ (posedge CLKA or posedge RST)
     begin
	if(RST)
	  regA <= 4'b0;
	else if(A_enable)
	  regA <= DATA_IN;
     end
   // register B (latches data from regA when enabled by the strobe SFF)
   always @ (posedge CLKB or posedge RST)
     begin
	if(RST)
	  regB <= 4'b0;
	else if(strobe_sff_out)
	  regB <= regA;
     end
   // 'strobe' toggle FF
   always @ (posedge CLKA or posedge RST)
     begin
	if(RST)
	  strobe_toggle <= 1'b0;
	else if(A_enable)
	  strobe_toggle <= ~strobe_toggle;
     end
   // 'ack' toggle FF
   // This is set to '1' at reset, to initialize the unit.
   always @ (posedge CLKB or posedge RST)
     begin
	if(RST)
	  ack_toggle <= 1'b1;
	else if (strobe_sff_out)
	  ack_toggle <= ~ack_toggle;
     end
   // 'strobe' sync element
   adv_dbg_if_jfifo_syncflop strobe_sff (
			.DEST_CLK (CLKB),
			.D_SET (1'b0),
			.D_RST (strobe_sff_out),
			.RESET (RST),
			.TOGGLE_IN (strobe_toggle),
			.D_OUT (strobe_sff_out)
			);
   // 'ack' sync element
   adv_dbg_if_jfifo_syncflop ack_sff (
		     .DEST_CLK (CLKA),
		     .D_SET (1'b0),
		     .D_RST (A_enable),
		     .RESET (RST),
		     .TOGGLE_IN (ack_toggle),
		     .D_OUT (ack_sff_out)
		     );  
endmodule
