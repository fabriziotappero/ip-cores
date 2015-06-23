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
// To include the JTAG Serial Port (JSP), uncomment the following line
//`define DBG_JSP_SUPPORTED  
// Define this if you intend to use the JSP in a system with multiple
// devices on the JTAG chain
//`define ADBG_JSP_SUPPORT_MULTI
// If this is defined, status bits will be skipped on burst
// reads and writes to improve download speeds.
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_or1k_defines.v                                         ////
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
// $Log: adbg_or1k_defines.v,v $
// Revision 1.3  2010-01-10 22:54:10  Nathan
// Update copyright dates
//
// Revision 1.2  2009/05/17 20:54:56  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/22 20:28:31  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.3  2008/07/06 20:02:54  Nathan
// Fixes for synthesis with Xilinx ISE (also synthesizable with 
// Quartus II 7.0).  Ran through dos2unix.
//
// Revision 1.2  2008/06/26 20:52:31  Nathan
// OR1K module tested and working.  Added copyright / license info 
// to _define files.  Other cleanup.
//
// These relate to the number of internal registers, and how
// many bits are required in the Reg. Select register
// Register index definitions for module-internal registers
// Index 0 is the Status register, used for stall and reset
// Valid commands/opcodes for the or1k debug module
// 0000  NOP
// 0001 - 0010 Reserved
// 0011  Write burst, 32-bit access
// 0100 - 0110  Reserved
// 0111  Read burst, 32-bit access
// 1000  Reserved
// 1001  Internal register select/write
// 1010 - 1100 Reserved
// 1101  Internal register select
// 1110 - 1111 Reserved
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
module adv_dbg_if_cpu1 (
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
                // CPU signals
                ,
                cpu1_clk_i, 
                cpu1_addr_o, 
                cpu1_data_i, 
                cpu1_data_o,
                cpu1_bp_i,
                cpu1_stall_o,
                cpu1_stb_o,
                cpu1_we_o,
                cpu1_ack_i,
                cpu1_rst_o
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
   input         cpu1_clk_i; 
   output [31:0] cpu1_addr_o; 
   input [31:0]  cpu1_data_i; 
   output [31:0] cpu1_data_o;
   input         cpu1_bp_i;
   output        cpu1_stall_o;
   output        cpu1_stb_o;
   output        cpu1_we_o;
   input         cpu1_ack_i;
   output        cpu1_rst_o;
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
   wire 				select_cmd;  // True when the command (registered at Update_DR) is for top level/module selection
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
  if (rst_i)
    module_id_reg <= 2'b0;
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
  //  DBG_CPU0_SUPPORTED
// Connecting cpu module
adv_dbg_if_cpu1_or1k_module  i_dbg_cpu_2 (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_cpu1),
                  .tdi_i            (tdi_i),
                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),
                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[2'h2]),
                  .top_inhibit_o    (module_inhibit[2'h2]),
                  .rst_i            (rst_i),
                  // CPU signals
                  .cpu_clk_i        (cpu1_clk_i), 
                  .cpu_addr_o       (cpu1_addr_o), 
                  .cpu_data_i       (cpu1_data_i), 
                  .cpu_data_o       (cpu1_data_o),
                  .cpu_bp_i         (cpu1_bp_i),
                  .cpu_stall_o      (cpu1_stall_o),
                  .cpu_stb_o        (cpu1_stb_o),
                  .cpu_we_o         (cpu1_we_o),
                  .cpu_ack_i        (cpu1_ack_i),
                  .cpu_rst_o        (cpu1_rst_o)
              );
   assign tdo_jsp = 1'b0;
   assign module_inhibit[2'h3] = 1'b0;
assign select_inhibit = |module_inhibit;
/////////////////////////////////////////////////
// TDO output MUX
always @ (module_id_reg or tdo_wb or tdo_cpu0 or tdo_cpu1 or tdo_jsp)
begin
   case (module_id_reg)
     2'h0: tdo_o = tdo_wb;
     2'h1:     tdo_o = tdo_cpu0;
     2'h2:     tdo_o = tdo_cpu1;
     2'h3:      tdo_o = tdo_jsp;
       default:                        tdo_o = 1'b0;
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
module adv_dbg_if_cpu1_crc32 (clk, data, enable, shift, clr, rst, crc_out, serial_out);
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
////  adbg_or1k_biu.v                                             ////
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
// $Log: adbg_or1k_biu.v,v $
// Revision 1.3  2010-01-10 22:54:10  Nathan
// Update copyright dates
//
// Revision 1.2  2009/05/17 20:54:56  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/22 20:28:30  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.5  2008/07/08 19:04:03  Nathan
// Many small changes to eliminate compiler warnings, no functional 
// changes.  System will now pass SRAM and CPU self-tests on Altera 
// FPGA using altera_virtual_jtag TAP.
//
module adv_dbg_if_cpu1_or1k_biu
  (
   // Debug interface signals
   tck_i,
   rst_i,
   data_i,
   data_o,
   addr_i,
   strobe_i,
   rd_wrn_i,           // If 0, then write op
   rdy_o,
   // OR1K SPR bus signals
   cpu_clk_i,
   cpu_addr_o,
   cpu_data_i,
   cpu_data_o,
   cpu_stb_o,
   cpu_we_o,
   cpu_ack_i
   );
   // Debug interface signals
   input tck_i;
   input rst_i;
   input [31:0] data_i;  // Assume short words are in UPPER order bits!
   output [31:0] data_o;
   input [31:0]  addr_i;
   input 	 strobe_i;
   input 	 rd_wrn_i;
   output 	 rdy_o;
   // OR1K SPR bus signals
   input 	 cpu_clk_i;
   output [31:0] cpu_addr_o;
   input [31:0]  cpu_data_i;
   output [31:0] cpu_data_o;
   output 	 cpu_stb_o;
   output 	 cpu_we_o;
   input 	 cpu_ack_i;
   reg 		 rdy_o;
   reg 		 cpu_stb_o;
   // Registers
   reg [31:0] 	 addr_reg;
   reg [31:0] 	 data_in_reg;  // dbg->WB
   reg [31:0] 	 data_out_reg;  // WB->dbg
   reg 		 wr_reg;
   reg 		 str_sync;  // This is 'active-toggle' rather than -high or -low.
   reg 		 rdy_sync;  // ditto, active-toggle
   // Sync registers.  TFF indicates TCK domain, WBFF indicates cpu_clk domain
   reg 		 rdy_sync_tff1;
   reg 		 rdy_sync_tff2;
   reg 		 rdy_sync_tff2q;  // used to detect toggles
   reg 		 str_sync_wbff1;
   reg 		 str_sync_wbff2;
   reg 		 str_sync_wbff2q;  // used to detect toggles
   // Control Signals
   reg 		 data_o_en;    // latch wb_data_i
   reg 		 rdy_sync_en;  // toggle the rdy_sync signal, indicate ready to TCK domain
   // Internal signals
   wire 	 start_toggle;  // CPU domain, indicates a toggle on the start strobe
   //////////////////////////////////////////////////////
   // TCK clock domain
   // There is no FSM here, just signal latching and clock
   // domain synchronization
   // Latch input data on 'start' strobe, if ready.
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) begin
	   addr_reg <= 32'h0;
	   data_in_reg <= 32'h0;
	   wr_reg <= 1'b0;
	end
	else
	  if(strobe_i && rdy_o) begin
	     addr_reg <= addr_i;
	     if(!rd_wrn_i) data_in_reg <= data_i;
	     wr_reg <= ~rd_wrn_i;
	  end 
     end
   // Create toggle-active strobe signal for clock sync.  This will start a transaction
   // to the CPU once the toggle propagates to the FSM in the cpu_clk domain.
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) str_sync <= 1'b0;
	else if(strobe_i && rdy_o) str_sync <= ~str_sync;
     end 
   // Create rdy_o output.  Set on reset, clear on strobe (if set), set on input toggle
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) begin
           rdy_sync_tff1 <= 1'b0;
           rdy_sync_tff2 <= 1'b0;
           rdy_sync_tff2q <= 1'b0;
           rdy_o <= 1'b1; 
	end
	else begin  
	   rdy_sync_tff1 <= rdy_sync;       // Synchronize the ready signal across clock domains
	   rdy_sync_tff2 <= rdy_sync_tff1;
	   rdy_sync_tff2q <= rdy_sync_tff2;  // used to detect toggles
	   if(strobe_i && rdy_o) rdy_o <= 1'b0;
	   else if(rdy_sync_tff2 != rdy_sync_tff2q) rdy_o <= 1'b1;
	end
     end 
   //////////////////////////////////////////////////////////
   // Direct assignments, unsynchronized
   assign cpu_data_o = data_in_reg;
   assign cpu_we_o = wr_reg;
   assign cpu_addr_o = addr_reg;
   assign data_o = data_out_reg;
   ///////////////////////////////////////////////////////
   // Wishbone clock domain
  // synchronize the start strobe
  always @ (posedge cpu_clk_i or posedge rst_i)
	  begin
	     if(rst_i) begin
		str_sync_wbff1 <= 1'b0;
		str_sync_wbff2 <= 1'b0;
		str_sync_wbff2q <= 1'b0;      
	     end
	     else begin
		str_sync_wbff1 <= str_sync;
		str_sync_wbff2 <= str_sync_wbff1;
		str_sync_wbff2q <= str_sync_wbff2;  // used to detect toggles
	     end
	  end
   assign start_toggle = (str_sync_wbff2 != str_sync_wbff2q);
   // CPU->dbg data register
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) data_out_reg <= 32'h0;
	else if(data_o_en) data_out_reg <= cpu_data_i;
     end
   // Create a toggle-active ready signal to send to the TCK domain
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) rdy_sync <= 1'b0;
	else if(rdy_sync_en) rdy_sync <= ~rdy_sync;
     end 
   /////////////////////////////////////////////////////
   // Small state machine to create OR1K SPR bus accesses
   // Not much more that an 'in_progress' bit, but easier
   // to read.  Deals with single-cycle and multi-cycle
   // accesses.
   reg cpu_fsm_state;
   reg next_fsm_state;
   // Sequential bit
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) cpu_fsm_state <= 1'h0;
	else cpu_fsm_state <= next_fsm_state; 
     end
   // Determination of next state (combinatorial)
   always @ (cpu_fsm_state or start_toggle or cpu_ack_i)
     begin
	case (cpu_fsm_state)
          1'h0:
            begin
               if(start_toggle && !cpu_ack_i) next_fsm_state = 1'h1;  // Don't go to next state for 1-cycle transfer
               else next_fsm_state = 1'h0;
            end
          1'h1:
            begin
               if(cpu_ack_i) next_fsm_state = 1'h0;
               else next_fsm_state = 1'h1;
            end
	endcase
     end
   // Outputs of state machine (combinatorial)
   always @ (cpu_fsm_state or start_toggle or cpu_ack_i or wr_reg)
     begin
	rdy_sync_en = 1'b0;
	data_o_en = 1'b0;
	cpu_stb_o = 1'b0;
	case (cpu_fsm_state)
          1'h0:
            begin
               if(start_toggle) begin
		  cpu_stb_o = 1'b1;
		  if(cpu_ack_i) begin
                     rdy_sync_en = 1'b1;
		  end
		  if (cpu_ack_i && !wr_reg) begin  // latch read data
                     data_o_en = 1'b1;
		  end
               end
            end
          1'h1:
            begin
               cpu_stb_o = 1'b1;  // OR1K behavioral model needs this.  OR1200 should be indifferent.
               if(cpu_ack_i) begin
                  data_o_en = 1'b1;
                  rdy_sync_en = 1'b1;
               end
            end
	endcase
     end
endmodule
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
// Module interface
module adv_dbg_if_cpu1_or1k_module (
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
   reg [1-1:0] internal_register_select;  // Holds index of currently selected register
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
   wire [1-1:0] reg_select_data; // from data_register_i, input to internal register select register
   wire [31:0] 			       out_reg_data;           // parallel input to the output shift register
   reg [31:0] 			       data_from_internal_reg;  // data from internal reg. MUX to output shift register
   wire 			       status_reg_wr;
   /////////////////////////////////////////////////
   // Combinatorial assignments
       assign module_cmd = ~(data_register_i[52]);
   assign     operation_in = data_register_i[51:48];
   assign     address_data_in = data_register_i[47:16];
   assign     count_data_in = data_register_i[15:0];
   assign     data_to_biu = {tdi_i,data_register_i[52:22]};
   assign     reg_select_data = data_register_i[47:(47-(1-1))];
   ////////////////////////////////////////////////
	      // Operation decoder
   // These are only used before the operation is latched, so decode them from operation_in
   assign     burst_instruction = (operation_in == 4'h3) | (operation_in == 4'h7);
   assign     intreg_instruction = ((operation_in == 4'h9) | (operation_in == 4'hd));
   assign     intreg_write = (operation_in == 4'h9);
   // These are constant, the CPU module only does 32-bit accesses
   assign     word_size_bits = 6'd31;  // Bits is actually bits-1, to make the FSM easier
   assign     address_increment = 3'd1;  // This is only used to increment the address.  SPRs are word-addressed.
   // This is the only thing that actually needs to be saved and 'decoded' from the latched opcode
   // It goes to the BIU each time a transaction is started.
   assign     rd_op = operation[2];
   ////////////////////////////////////////////////
   // Module-internal register select register (no, that's not redundant.)
   // Also internal register output MUX
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) internal_register_select <= 1'h0;
	else if(regsel_ld_en) internal_register_select <= reg_select_data;
     end
   // This is completely unnecessary here, since the module has only 1 internal
   // register.  However, to make the module expandable, it is included anyway.
   always @ (internal_register_select or internal_reg_status)
     begin
	case(internal_register_select) 
          1'b0: data_from_internal_reg = {30'h0, internal_reg_status};
          default: data_from_internal_reg = {30'h0, internal_reg_status};
	endcase
     end
   ////////////////////////////////////////////////////////////////////
   // Module-internal registers
   // These have generic read/write/select code, but
   // individual registers may have special behavior, defined here.
   // This is the status register, which holds the reset and stall states.
   assign status_reg_wr = (intreg_ld_en & (reg_select_data == 1'b0));
   adv_dbg_if_cpu1_or1k_status_reg or1k_statusreg_i (
				     .data_i(data_register_i[(47-1):(47-(1+1))]), 
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
   assign   incremented_address  = {1'b0,address_counter} +{30'b0,address_increment };
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
	if(tdo_output_sel == 2'h0) module_tdo_o = biu_ready;
	else if(tdo_output_sel == 2'h1) module_tdo_o = data_out_shift_reg[0];
	else if(tdo_output_sel == 2'h2) module_tdo_o = crc_match;
	else module_tdo_o = crc_serial_out;
     end
   ////////////////////////////////////////
     // Bus Interface Unit (to OR1K SPR bus)
   // It is assumed that the BIU has internal registers, and will
   // latch address, operation, and write data on rising clock edge 
   // when strobe is asserted
   adv_dbg_if_cpu1_or1k_biu or1k_biu_i (
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
   adv_dbg_if_cpu1_crc32 or1k_crc_i
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
   reg [3:0] module_state;       // FSM state
   reg [3:0] module_next_state;  // combinatorial signal, not actually a register
   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  module_state <= 4'h0;
	else
	  module_state <= module_next_state;
     end
   // Determination of next state; purely combinatorial
   always @ (module_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i or operation_in[2]
	     or word_count_zero or bit_count_max or data_register_i[52] or bit_count_32 or biu_ready
	     or module_cmd or intreg_write or decremented_word_count or burst_instruction)
     begin
	case(module_state)
	  4'h0:
	    begin
	       if(module_cmd && module_select_i && update_dr_i && burst_instruction && operation_in[2]) module_next_state = 4'h1;
	       else if(module_cmd && module_select_i && update_dr_i && burst_instruction) module_next_state = 4'h5;
	       else module_next_state = 4'h0;
	    end
	  4'h1:
	    begin
	       if(word_count_zero) module_next_state = 4'h0;  // set up a burst of size 0, illegal.
	       else module_next_state = 4'h2;
	    end
	  4'h2:
	    begin
	       if(module_select_i && capture_dr_i) module_next_state = 4'h3;
	       else module_next_state = 4'h2;
	    end
	  4'h3:
	    begin
	       if(update_dr_i) module_next_state = 4'h0; 
	       else if (biu_ready) module_next_state = 4'h4;
	       else module_next_state = 4'h3;
	    end
	  4'h4:
	    begin
	       if(update_dr_i) module_next_state = 4'h0; 
	       else if(bit_count_max && word_count_zero) module_next_state = 4'h9;
	       else module_next_state = 4'h4;
	    end
	  4'h9:
	    begin
	       if(update_dr_i) module_next_state = 4'h0;
	       // This doubles as the 'recovery' state, so stay here until update_dr_i.
	       else module_next_state = 4'h9;    
	    end
	  4'h5:
	    begin
	       if(word_count_zero) module_next_state = 4'h0;
	       else if(module_select_i && capture_dr_i) module_next_state = 4'h6;
	       else module_next_state = 4'h5;
	    end
	  4'h6:
	    begin
	       if(update_dr_i)  module_next_state = 4'h0;  // client terminated early
	       else if(module_select_i && data_register_i[52]) module_next_state = 4'h7; // Got a start bit
	       else module_next_state = 4'h6;
	    end
	  4'h7:
	    begin
	       if(update_dr_i)  module_next_state = 4'h0;  // client terminated early    
	       else if(bit_count_max) 
	         begin
		        if(word_count_zero) module_next_state = 4'ha;
		        else module_next_state = 4'h7;
	         end
	       else module_next_state = 4'h7;
	    end
	  4'h8:
	    begin
	       if(update_dr_i)  module_next_state = 4'h0;  // client terminated early    
	       else if(word_count_zero) module_next_state = 4'ha;
	       // can't wait until bus ready if multiple devices in chain...
	       // Would have to read postfix_bits, then send another start bit and push it through
	       // prefix_bits...potentially very inefficient.
	       else module_next_state = 4'h7;
	    end
	  4'ha:
	    begin
	       if(update_dr_i)  module_next_state = 4'h0;  // client terminated early
	       else if(bit_count_32) module_next_state = 4'hb;
	       else module_next_state = 4'ha;    
	    end
	  4'hb:
	    begin
	       if(update_dr_i)  module_next_state = 4'h0;
	       // This doubles as our recovery state, stay here until update_dr_i
	       else module_next_state = 4'hb;    
	    end
	  default: module_next_state = 4'h0;  // shouldn't actually happen...
	endcase
     end
   // Outputs of state machine, pure combinatorial
   always @ (module_state or module_next_state or module_select_i or update_dr_i or capture_dr_i or shift_dr_i or operation_in[2]
	     or word_count_zero or bit_count_max or data_register_i[52] or biu_ready or intreg_instruction
	     or module_cmd or intreg_write or decremented_word_count)
     begin
	// Default everything to 0, keeps the case statement simple
	addr_sel = 1'b1;  // Selects data for address_counter. 0 = data_register_i, 1 = incremented address count
	addr_ct_en = 1'b0;  // Enable signal for address counter register
	op_reg_en = 1'b0;  // Enable signal for 'operation' register
	bit_ct_en = 1'b0;  // enable bit counter
	bit_ct_rst = 1'b0;  // reset (zero) bit count register
	word_ct_sel = 1'b1;  // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
	word_ct_en = 1'b0;   // Enable byte counter register
	out_reg_ld_en = 1'b0;  // Enable parallel load of data_out_shift_reg
	out_reg_shift_en = 1'b0;  // Enable shift of data_out_shift_reg
	tdo_output_sel = 2'b1;   // 1 = data reg, 0 = biu_ready, 2 = crc_match, 3 = CRC data
	biu_strobe = 1'b0;
	crc_clr = 1'b0;
	crc_en = 1'b0;      // add the input bit to the CRC calculation
	crc_in_sel = 1'b0;  // 0 = tdo, 1 = tdi
	crc_shift_en = 1'b0;
	out_reg_data_sel = 1'b1;  // 0 = BIU data, 1 = internal register data
	regsel_ld_en = 1'b0;
	intreg_ld_en = 1'b0;
	top_inhibit_o = 1'b0;  // Don't disable the top-level module in the default case
	case(module_state)
	  4'h0:
	    begin
	       addr_sel = 1'b0;
	       word_ct_sel = 1'b0;
	       // Operations for internal registers - stay in idle state
	       if(module_select_i & shift_dr_i) out_reg_shift_en = 1'b1; // For module regs
	       if(module_select_i & capture_dr_i) 
		 begin
		    out_reg_data_sel = 1'b1;  // select internal register data
		    out_reg_ld_en = 1'b1;   // For module regs
		 end
	       if(module_select_i & module_cmd & update_dr_i) begin
		  if(intreg_instruction) regsel_ld_en = 1'b1;  // For module regs
		  if(intreg_write)       intreg_ld_en = 1'b1;  // For module regs
	       end
	       // Burst operations
	       if(module_next_state != 4'h0) begin  // Do the same to receive read or write opcode
		  addr_ct_en = 1'b1;
		  op_reg_en = 1'b1;
		  bit_ct_rst = 1'b1;
		  word_ct_en = 1'b1;
		  crc_clr = 1'b1;
	       end
	    end
	  4'h1:
	    begin
	       if(!word_count_zero) begin  // Start a biu read transaction
		  biu_strobe = 1'b1;
		  addr_sel = 1'b1;
		  addr_ct_en = 1'b1;
	       end
	    end
	  4'h2:
	    ; // Just a wait state
	  4'h3:
	    begin
	       tdo_output_sel = 2'h0;
	       top_inhibit_o = 1'b1;    // in case of early termination
	       if (module_next_state == 4'h4) 
	       begin
	         out_reg_data_sel = 1'b0;  // select BIU data
	         out_reg_ld_en = 1'b1;
	         bit_ct_rst = 1'b1;
	         word_ct_sel = 1'b1;
	         word_ct_en = 1'b1;
	         if(!(decremented_word_count == 0) && !word_count_zero)  // Start a biu read transaction
	         begin
	           biu_strobe = 1'b1;
	           addr_sel = 1'b1;
	           addr_ct_en = 1'b1;
	         end
	       end
	    end
	  4'h4:
	    begin
	       tdo_output_sel = 2'h1;
	       out_reg_shift_en = 1'b1;
	       bit_ct_en = 1'b1;
	       crc_en = 1'b1;
	       crc_in_sel = 1'b0;  // read data in output shift register LSB (tdo)
	       top_inhibit_o = 1'b1;    // in case of early termination
	       if(bit_count_max)
	       begin
	         out_reg_data_sel = 1'b0;  // select BIU data
	         out_reg_ld_en = 1'b1;
	         bit_ct_rst = 1'b1;
	         word_ct_sel = 1'b1;
	         word_ct_en = 1'b1;
	         if(!(decremented_word_count == 0) && !word_count_zero)  // Start a biu read transaction
	         begin
	           biu_strobe = 1'b1;
	           addr_sel = 1'b1;
	           addr_ct_en = 1'b1;
	         end
	       end
	    end
	  4'h9:
	    begin
	       // Just shift out the data, don't bother counting, we don't move on until update_dr_i
	       tdo_output_sel = 2'h3;
	       crc_shift_en = 1'b1;
	       top_inhibit_o = 1'b1;
	    end
	  4'h5:
	    ; // Just a wait state
	  4'h6:
	    begin
	       tdo_output_sel = 2'h1;
	       top_inhibit_o = 1'b1;    // in case of early termination
	       if(module_next_state == 4'h7) begin
		  bit_ct_en = 1'b1;
		  word_ct_sel = 1'b1;  // Pre-decrement the byte count
		  word_ct_en = 1'b1;
		  crc_en = 1'b1;  // CRC gets tdi_i, which is 1 cycle ahead of data_register_i, so we need the bit there now in the CRC
		  crc_in_sel = 1'b1;  // read data from tdi_i
	       end
	    end
	  4'h7:
	    begin
	       bit_ct_en = 1'b1;
	       tdo_output_sel = 2'h1;
	       crc_en = 1'b1;
	       crc_in_sel = 1'b1;  // read data from tdi_i
	       top_inhibit_o = 1'b1;    // in case of early termination
	       // It would be better to do this in STATE_Wstatus, but we don't use that state 
	       // if ADBG_USE_HISPEED is defined.  
	       if(bit_count_max)
		      begin
		      bit_ct_rst = 1'b1;  // Zero the bit count
		      // start transaction. Can't do this here if not hispeed, biu_ready
		      // is the status bit, and it's 0 if we start a transaction here.
		      biu_strobe = 1'b1;  // Start a BIU transaction
		      addr_ct_en = 1'b1;  // Increment thte address counter
		      // Also can't dec the byte count yet unless hispeed,
		      // that would skip the last word.
		      word_ct_sel = 1'b1;  // Decrement the byte count
		      word_ct_en = 1'b1;
		      end
	    end
	  4'h8:
	    begin
	       tdo_output_sel = 2'h0;  // Send the status bit to TDO
	       // start transaction
	       biu_strobe = 1'b1;  // Start a BIU transaction
	       word_ct_sel = 1'b1;  // Decrement the byte count
	       word_ct_en = 1'b1;
	       bit_ct_rst = 1'b1;  // Zero the bit count
	       addr_ct_en = 1'b1;  // Increment thte address counter
	       top_inhibit_o = 1'b1;    // in case of early termination
	    end
	  4'ha:
	    begin
               bit_ct_en = 1'b1;
               top_inhibit_o = 1'b1;    // in case of early termination
               if(module_next_state == 4'hb) tdo_output_sel = 2'h2;  // This is when the 'match' bit is actually read
	    end
	  4'hb:
	    begin
               tdo_output_sel = 2'h2;
               top_inhibit_o = 1'b1;    // in case of early termination
	    end
	  default: ;
	endcase
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_or1k_status_reg.v                                      ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Debug Interface.               ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////       Nathan Yawn (nyawn@opencores.org)                      ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2011 Authors                            ////
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
// $Log: adbg_or1k_status_reg.v,v $
// Revision 1.3  2011-10-24 02:25:11  natey
// Removed extraneous '#1' delays, which were a holdover from the original
// versions in the previous dbg_if core.
//
// Revision 1.2  2010-01-10 22:54:10  Nathan
// Update copyright dates
//
// Revision 1.1  2008/07/22 20:28:31  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.3  2008/07/06 20:02:54  Nathan
// Fixes for synthesis with Xilinx ISE (also synthesizable with 
// Quartus II 7.0).  Ran through dos2unix.
//
// Revision 1.2  2008/06/26 20:52:32  Nathan
// OR1K module tested and working.  Added copyright / license info 
// to _define files.  Other cleanup.
//
//
//
//
module adv_dbg_if_cpu1_or1k_status_reg  (
                              data_i, 
                              we_i, 
                              tck_i, 
                              bp_i, 
                              rst_i,
                              cpu_clk_i, 
                              ctrl_reg_o,
                              cpu_stall_o, 
                              cpu_rst_o 
                              );
   input  [2 - 1:0] data_i;
   input 			       we_i;
   input 			       tck_i;
   input 			       bp_i;
   input 			       rst_i;
   input 			       cpu_clk_i;
   output [2 - 1:0] ctrl_reg_o;
   output 			       cpu_stall_o;
   output 			       cpu_rst_o;
   reg 				       cpu_reset;
   wire [2:1] 			       cpu_op_out;
   reg 				       stall_bp, stall_bp_csff, stall_bp_tck;
   reg 				       stall_reg, stall_reg_csff, stall_reg_cpu;
   reg 				       cpu_reset_csff;
   reg 				       cpu_rst_o;
   // Breakpoint is latched and synchronized. Stall is set and latched.
   // This is done in the CPU clock domain, because the JTAG clock (TCK) is
   // irregular.  By only allowing bp_i to set (but not reset) the stall_bp
   // signal, we insure that the CPU will remain in the stalled state until
   // the debug host can read the state.
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i)
	  stall_bp <= 1'b0;
	else if(bp_i)
	  stall_bp <= 1'b1;
	else if(stall_reg_cpu)
	  stall_bp <= 1'b0;
     end
   // Synchronizing
   always @ (posedge tck_i or posedge rst_i)
     begin
	if (rst_i)
	  begin
	     stall_bp_csff <= 1'b0;
	     stall_bp_tck  <= 1'b0;
	  end
	else
	  begin
	     stall_bp_csff <= stall_bp;
	     stall_bp_tck  <= stall_bp_csff;
	  end
     end
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if (rst_i)
	  begin
	     stall_reg_csff <= 1'b0;
	     stall_reg_cpu  <= 1'b0;
	  end
	else
	  begin
	     stall_reg_csff <= stall_reg;
	     stall_reg_cpu  <= stall_reg_csff;
	  end
     end
   // bp_i forces a stall immediately on a breakpoint
   // stall_bp holds the stall until the debug host acts
   // stall_reg_cpu allows the debug host to control a stall.
   assign cpu_stall_o = bp_i | stall_bp | stall_reg_cpu;
   // Writing data to the control registers (stall)
   // This can be set either by the debug host, or by
   // a CPU breakpoint.  It can only be cleared by the host.
   always @ (posedge tck_i or posedge rst_i)
     begin
	if (rst_i)
	  stall_reg <= 1'b0;
	else if (stall_bp_tck)
	  stall_reg <= 1'b1;
	else if (we_i)
	  stall_reg <= data_i[0];
     end
   // Writing data to the control registers (reset)
   always @ (posedge tck_i or posedge rst_i)
     begin
	if (rst_i)
	  cpu_reset  <= 1'b0;
	else if(we_i)
	  cpu_reset  <= data_i[1];
     end
   // Synchronizing signals from registers
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if (rst_i)
	  begin
	     cpu_reset_csff      <= 1'b0; 
	     cpu_rst_o           <= 1'b0; 
	  end
	else
	  begin
	     cpu_reset_csff      <= cpu_reset;
	     cpu_rst_o           <= cpu_reset_csff;
	  end
     end
   // Value for read back
   assign ctrl_reg_o = {cpu_reset, stall_reg};
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
module adv_dbg_if_cpu1_bytefifo (
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
module adv_dbg_if_cpu1_syncflop(
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
module adv_dbg_if_cpu1_syncreg (
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
   adv_dbg_if_cpu1_syncflop strobe_sff (
			.DEST_CLK (CLKB),
			.D_SET (1'b0),
			.D_RST (strobe_sff_out),
			.RESET (RST),
			.TOGGLE_IN (strobe_toggle),
			.D_OUT (strobe_sff_out)
			);
   // 'ack' sync element
   adv_dbg_if_cpu1_syncflop ack_sff (
		     .DEST_CLK (CLKA),
		     .D_SET (1'b0),
		     .D_RST (A_enable),
		     .RESET (RST),
		     .TOGGLE_IN (ack_toggle),
		     .D_OUT (ack_sff_out)
		     );  
endmodule
