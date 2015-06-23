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
// If CPU_0 sub-module is supported uncomment the following line
// If CPU_1 sub-module is supported uncomment the following line
//`define DBG_CPU1_SUPPORTED
// To include the JTAG Serial Port (JSP), uncomment the following line
// Define this if you intend to use the JSP in a system with multiple
// devices on the JTAG chain
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
////  adbg_wb_defines.v                                           ////
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
//// Copyright (C) 2008-2010        Authors                       ////
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
// $Log: adbg_wb_defines.v,v $
// Revision 1.4  2010-01-10 22:54:11  Nathan
// Update copyright dates
//
// Revision 1.3  2009/05/17 20:54:57  Nathan
// Changed email address to opencores.org
//
// Revision 1.2  2009/05/04 00:50:11  Nathan
// Changed the WB BIU to use big-endian byte ordering, to match the OR1000.  Kept little-endian ordering as a compile-time option in case this is ever used with a little-endian CPU.
//
// Revision 1.1  2008/07/22 20:28:32  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Endian-ness of the Wishbone interface.
// Default is BIG endian, to match the OR1200.
// If using a LITTLE endian CPU, e.g. an x86, un-comment this line.
//`define DBG_WB_LITTLE_ENDIAN
// These relate to the number of internal registers, and how
// many bits are required in the Reg. Select register
// Register index definitions for module-internal registers
// The WB module has just 1, the error register
// Valid commands/opcodes for the wishbone debug module
// 0000  NOP
// 0001  Write burst, 8-bit access
// 0010  Write burst, 16-bit access
// 0011  Write burst, 32-bit access
// 0100  Reserved
// 0101  Read burst, 8-bit access
// 0110  Read burst, 16-bit access
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
module adv_dbg_if_wb_cpu0_jsp (
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
                // WISHBONE common signals
                ,
                wb_clk_i,
                wb_rst_i,
                // WISHBONE master interface
                wb_adr_o,
                wb_dat_o,
                wb_dat_i,
                wb_cyc_o,
                wb_stb_o,
                wb_sel_o,
                wb_we_o,
                wb_ack_i,
                wb_cab_o,
                wb_err_i,
                wb_cti_o,
                wb_bte_o
                // CPU signals
                ,
                cpu0_clk_i, 
                cpu0_addr_o, 
                cpu0_data_i, 
                cpu0_data_o,
                cpu0_bp_i,
                cpu0_stall_o,
                cpu0_stb_o,
                cpu0_we_o,
                cpu0_ack_i,
                cpu0_rst_o
                ,
                // WISHBONE target interface
                wb_jsp_adr_i,
                wb_jsp_dat_o,
                wb_jsp_dat_i,
                wb_jsp_cyc_i,
                wb_jsp_stb_i,
                wb_jsp_sel_i,
                wb_jsp_we_i,
                wb_jsp_ack_o,
                wb_jsp_cab_i,
                wb_jsp_err_o,
                wb_jsp_cti_i,
                wb_jsp_bte_i,
		int_o,
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
   input   wb_rst_i;
   output [31:0] wb_adr_o;
   output [31:0] wb_dat_o;
   input [31:0]  wb_dat_i;
   output        wb_cyc_o;
   output        wb_stb_o;
   output [3:0]  wb_sel_o;
   output        wb_we_o;
   input         wb_ack_i;
   output        wb_cab_o;
   input         wb_err_i;
   output [2:0]  wb_cti_o;
   output [1:0]  wb_bte_o;
   // CPU signals
   input         cpu0_clk_i; 
   output [31:0] cpu0_addr_o; 
   input [31:0]  cpu0_data_i; 
   output [31:0] cpu0_data_o;
   input         cpu0_bp_i;
   output        cpu0_stall_o;
   output        cpu0_stb_o;
   output        cpu0_we_o;
   input         cpu0_ack_i;
   output        cpu0_rst_o;
   input [31:0]  wb_jsp_adr_i;
   output [31:0] wb_jsp_dat_o;
   input [31:0]  wb_jsp_dat_i;
   input         wb_jsp_cyc_i;
   input         wb_jsp_stb_i;
   input [3:0]   wb_jsp_sel_i;
   input         wb_jsp_we_i;
   output        wb_jsp_ack_o;
   input         wb_jsp_cab_i;
   output        wb_jsp_err_o;
   input [2:0]   wb_jsp_cti_i;
   input [1:0]   wb_jsp_bte_i;
   output 	 int_o;
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
// Connecting wishbone module
adv_dbg_if_wb_cpu0_jsp_wb_module i_dbg_wb (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_wb),
                  .tdi_i            (tdi_i),
                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),
                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[2'h0]),
                  .top_inhibit_o     (module_inhibit[2'h0]),
                  .rst_i            (rst_i),
                  // WISHBONE common signals
                  .wb_clk_i         (wb_clk_i),
                  // WISHBONE master interface
                  .wb_adr_o         (wb_adr_o), 
                  .wb_dat_o         (wb_dat_o),
                  .wb_dat_i         (wb_dat_i),
                  .wb_cyc_o         (wb_cyc_o),
                  .wb_stb_o         (wb_stb_o),
                  .wb_sel_o         (wb_sel_o),
                  .wb_we_o          (wb_we_o),
                  .wb_ack_i         (wb_ack_i),
                  .wb_cab_o         (wb_cab_o),
                  .wb_err_i         (wb_err_i),
                  .wb_cti_o         (wb_cti_o),
                  .wb_bte_o         (wb_bte_o)
            );
adv_dbg_if_wb_cpu0_jsp_or1k_module i_dbg_cpu_or1k (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_cpu0),
                  .tdi_i            (tdi_i),
                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),
                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[2'h1]),
                  .top_inhibit_o     (module_inhibit[2'h1]),
                  .rst_i            (rst_i),
                  // CPU signals
                  .cpu_clk_i        (cpu0_clk_i), 
                  .cpu_addr_o       (cpu0_addr_o), 
                  .cpu_data_i       (cpu0_data_i), 
                  .cpu_data_o       (cpu0_data_o),
                  .cpu_bp_i         (cpu0_bp_i),
                  .cpu_stall_o      (cpu0_stall_o),
                  .cpu_stb_o        (cpu0_stb_o),
                  .cpu_we_o         (cpu0_we_o),
                  .cpu_ack_i        (cpu0_ack_i),
                  .cpu_rst_o        (cpu0_rst_o)
              );
  //  DBG_CPU0_SUPPORTED
assign tdo_cpu1 = 1'b0;
assign module_inhibit[2'h2] = 1'b0;
adv_dbg_if_wb_cpu0_jsp_jsp_module i_dbg_jsp (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_jsp),
                  .tdi_i            (tdi_i),
                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),
                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[2'h3]),
                  .top_inhibit_o     (module_inhibit[2'h3]),
                  .rst_i            (rst_i),
                  // WISHBONE common signals
                  .wb_clk_i         (wb_clk_i),
                  .wb_rst_i         (wb_rst_i),
                  // WISHBONE master interface
                  .wb_adr_i         (wb_jsp_adr_i), 
                  .wb_dat_o         (wb_jsp_dat_o),
                  .wb_dat_i         (wb_jsp_dat_i),
                  .wb_cyc_i         (wb_jsp_cyc_i),
                  .wb_stb_i         (wb_jsp_stb_i),
                  .wb_sel_i         (wb_jsp_sel_i),
                  .wb_we_i          (wb_jsp_we_i),
                  .wb_ack_o         (wb_jsp_ack_o),
                  .wb_cab_i         (wb_jsp_cab_i),
                  .wb_err_o         (wb_jsp_err_o),
                  .wb_cti_i         (wb_jsp_cti_i),
                  .wb_bte_i         (wb_jsp_bte_i),
                  .biu_wr_strobe    (biu_wr_strobe),
		  .jsp_data_out     (jsp_data_out),
		  .int_o            (int_o)
            );
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
module adv_dbg_if_wb_cpu0_jsp_crc32 (clk, data, enable, shift, clr, rst, crc_out, serial_out);
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
////  adbg_jsp_biu.v                                              ////
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
module adv_dbg_if_wb_cpu0_jsp_jsp_biu
  (
   // Debug interface signals
   tck_i,
   rst_i,
   data_i,
   data_o,
   bytes_available_o,
   bytes_free_o,
   rd_strobe_i,
   wr_strobe_i,
   // Wishbone signals
   wb_clk_i,
   wb_rst_i,
   wb_adr_i,
   wb_dat_o,
   wb_dat_i,
   wb_cyc_i,
   wb_stb_i,
   wb_sel_i,
   wb_we_i,
   wb_ack_o,
   wb_cab_i,
   wb_err_o,
   wb_cti_i,
   wb_bte_i,
   int_o
   );
   // Debug interface signals
   input tck_i;
   input rst_i;
   input [7:0] data_i;  // Assume short words are in UPPER order bits!
   output [7:0] data_o;
   output [3:0] bytes_free_o;
   output [3:0] bytes_available_o;
   input 	rd_strobe_i;
   input 	wr_strobe_i;
   // Wishbone signals
   input 	 wb_clk_i;
   input 	 wb_rst_i;
   input  [31:0] wb_adr_i;
   output [31:0] wb_dat_o;
   input  [31:0] wb_dat_i;
   input 	 wb_cyc_i;
   input 	 wb_stb_i;
   input  [3:0]  wb_sel_i;
   input 	 wb_we_i;
   output 	 wb_ack_o;
   input 	 wb_cab_i;
   output 	 wb_err_o;
   input  [2:0]  wb_cti_i;
   input  [1:0]  wb_bte_i;
   output 	 int_o;
   wire 	 wb_ack_o;
   wire [31:0] 	 wb_dat_o;
   wire 	 wb_err_o;
   wire 	 int_o;
   wire [7:0] 	 data_o;
   wire [3:0] 	 bytes_free_o;
   wire [3:0] 	 bytes_available_o;
   // Registers
   reg [7:0] 	 data_in;
   reg [7:0] 	 rdata;
   reg 		 wen_tff;
   reg 		 ren_tff;
   // Wires  
   wire 	 wb_fifo_ack;
   wire [3:0] 	 wr_bytes_free;
   wire [3:0] 	 rd_bytes_avail;
   wire [3:0]	 wr_bytes_avail;  // used to generate wr_fifo_not_empty
   wire 	 rd_bytes_avail_not_zero;
   wire 	 ren_sff_out;   
   wire [7:0] 	 rd_fifo_data_out;
   wire [7:0] 	 data_to_wb;
   wire [7:0] 	 data_from_wb;
   wire 	 wr_fifo_not_empty;  // this is for the WishBone interface LSR register
   wire        rcvr_fifo_rst;  // rcvr in the WB sense, opposite most of the rest of this file
   wire        xmit_fifo_rst;  // ditto
   // Control Signals (FSM outputs)
   reg 		 wda_rst;   // reset wdata_avail SFF
   reg 		 wpp;       // Write FIFO PUSH (1) or POP (0)
   reg 		 w_fifo_en; // Enable write FIFO
   reg 		 ren_rst;   // reset 'pop' SFF
   reg 		 rdata_en;  // enable 'rdata' register
   reg 		 rpp;       // read FIFO PUSH (1) or POP (0)
   reg 		 r_fifo_en; // enable read FIFO    
   reg 		 r_wb_ack;  // read FSM acks WB transaction
   reg 		 w_wb_ack;  // write FSM acks WB transaction
   // Indicators to FSMs
   wire 	 wdata_avail; // JTAG side has data available
   wire 	 wb_rd;       // WishBone requests read
   wire 	 wb_wr;       // WishBone requests write
   wire 	 pop;         // JTAG side received a byte, pop and get next
   wire 	 rcz;         // zero bytes available in read FIFO
   //////////////////////////////////////////////////////
   // TCK clock domain
   // There is no FSM here, just signal latching and clock
   // domain synchronization
   assign 	 data_o = rdata;
   // Write enable (WEN) toggle FF
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) wen_tff <= 1'b0;
	else if(wr_strobe_i) wen_tff <= ~wen_tff;
     end 
   // Read enable (REN) toggle FF
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) ren_tff <= 1'b0;
	else if(rd_strobe_i) ren_tff <= ~ren_tff;
     end
   // Write data register
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) data_in <= 8'h0;
	else if(wr_strobe_i) data_in <= data_i;
     end
   ///////////////////////////////////////////////////////
   // Wishbone clock domain
   // Combinatorial assignments
   assign rd_bytes_avail_not_zero = !(rd_bytes_avail == 4'h0);
   assign pop = ren_sff_out & rd_bytes_avail_not_zero;
   assign rcz = ~rd_bytes_avail_not_zero;
   assign wb_fifo_ack = r_wb_ack | w_wb_ack;
   assign wr_fifo_not_empty = !(wr_bytes_avail == 4'h0);
   // rdata register
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) rdata <= 8'h0;
	else if(rdata_en) rdata <= rd_fifo_data_out;
     end
   // WEN SFF
   adv_dbg_if_wb_cpu0_jsp_syncflop wen_sff (
                     .DEST_CLK(wb_clk_i),
		     .D_SET(1'b0),
		     .D_RST(wda_rst),
		     .RESET(rst_i),
                     .TOGGLE_IN(wen_tff),
                     .D_OUT(wdata_avail)
		     );
   // REN SFF
   adv_dbg_if_wb_cpu0_jsp_syncflop ren_sff (
                     .DEST_CLK(wb_clk_i),
		     .D_SET(1'b0),
		     .D_RST(ren_rst),
		     .RESET(rst_i),
                     .TOGGLE_IN(ren_tff),
                     .D_OUT(ren_sff_out)
		     );
   // 'free space available' syncreg
   adv_dbg_if_wb_cpu0_jsp_syncreg freespace_syncreg (
			      .CLKA(wb_clk_i),
			      .CLKB(tck_i),
			      .RST(rst_i),
			      .DATA_IN(wr_bytes_free),
			      .DATA_OUT(bytes_free_o)
			      );
   // 'bytes available' syncreg
   adv_dbg_if_wb_cpu0_jsp_syncreg bytesavail_syncreg (
			      .CLKA(wb_clk_i),
			      .CLKB(tck_i),
			      .RST(rst_i),
			      .DATA_IN(rd_bytes_avail),
			      .DATA_OUT(bytes_available_o)
			      );
   // write FIFO
   adv_dbg_if_wb_cpu0_jsp_bytefifo wr_fifo (
		     .CLK(wb_clk_i),
		     .RST(rst_i | rcvr_fifo_rst),  // rst_i from JTAG clk domain, rcvr_fifo_rst from WB, RST is async reset
                     .DATA_IN(data_in),
		     .DATA_OUT(data_to_wb),
		     .PUSH_POPn(wpp),
                     .EN(w_fifo_en),
                     .BYTES_AVAIL(wr_bytes_avail),
		     .BYTES_FREE(wr_bytes_free)
		     );
   // read FIFO
   adv_dbg_if_wb_cpu0_jsp_bytefifo rd_fifo (
		     .CLK(wb_clk_i),
		     .RST(rst_i | xmit_fifo_rst),  // rst_i from JTAG clk domain, xmit_fifo_rst from WB, RST is async reset
                     .DATA_IN(data_from_wb),
		     .DATA_OUT(rd_fifo_data_out),
		     .PUSH_POPn(rpp),
                     .EN(r_fifo_en),
                     .BYTES_AVAIL(rd_bytes_avail),
		     .BYTES_FREE()
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
   always @ (rd_fsm_state or wb_wr or pop or rcz)
     begin
	case (rd_fsm_state)
          2'h0:
            begin
               if(wb_wr) next_rd_fsm_state = 2'h1;
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
	       if(wb_wr) next_rd_fsm_state = 2'h1;
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
   /////////////////////////////////////////////////////
   // State machine for the write FIFO
   reg [1:0] wr_fsm_state;
   reg [1:0] next_wr_fsm_state;
   // Sequential bit
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) wr_fsm_state <= 2'h0;
	else wr_fsm_state <= next_wr_fsm_state; 
     end
   // Determination of next state (combinatorial)
   always @ (wr_fsm_state or wb_rd or wdata_avail)
     begin
	case (wr_fsm_state)
          2'h0:
            begin
               if(wb_rd) next_wr_fsm_state = 2'h2;
               else if (wdata_avail) next_wr_fsm_state = 2'h1;
               else next_wr_fsm_state = 2'h0;
            end
          2'h1:
            begin
               if(wb_rd) next_wr_fsm_state = 2'h2;
	       else next_wr_fsm_state = 2'h0;
            end
	  2'h2:
	    begin
	       if(wdata_avail) next_wr_fsm_state = 2'h1;
	       else next_wr_fsm_state = 2'h0;
	    end
	  default:
	    begin
	       next_wr_fsm_state = 2'h0;
	    end
	endcase
     end
   // Outputs of state machine (combinatorial)
   always @ (wr_fsm_state)
     begin
	wda_rst = 1'b0;
	wpp = 1'b0;
	w_fifo_en = 1'b0;
	w_wb_ack = 1'b0;
	case (wr_fsm_state)
          2'h0:;
          2'h1:
            begin
	       wda_rst = 1'b1;
	       wpp = 1'b1;
	       w_fifo_en = 1'b1;
            end
	  2'h2:
	    begin
	       w_wb_ack = 1'b1;
	       w_fifo_en = 1'b1;
	    end
	  default:
	    begin
             wda_rst = 1'b0;
	wpp = 1'b0;
	w_fifo_en = 1'b0;
	w_wb_ack = 1'b0;
	    end
	endcase
     end
   ////////////////////////////////////////////////////////////
   // WishBone interface hardware
   // Interface signals to read and write fifos:
   // wb_rd:  read strobe
   // wb_wr:  write strobe
   // wb_fifo_ack: fifo has completed operation
   wire [31:0] bus_data_lo;
   wire [31:0] bus_data_hi;
   wire        wb_reg_ack;
   wire        rd_fifo_not_full;  // "rd fifo" is the one the WB writes to
   reg [2:0]   iir_gen;  // actually combinatorial
   wire        rd_fifo_becoming_empty;
   // These 16550 registers are at least partly implemented
   reg 	       reg_dlab_bit;  // part of the LCR
   reg [3:0]   reg_ier;
   wire [2:0]  reg_iir;
   reg 	       thr_int_arm;  // used so that an IIR read can clear a transmit interrupt
   wire [7:0]  reg_lsr;
   wire        reg_dlab_bit_wren;
   wire        reg_ier_wren;
   wire        reg_iir_rden;
   wire [7:0]  reg_lcr;  // the DLAB bit above is the 8th bit
   wire        reg_fcr_wren;  // FCR is WR-only, at the same address as the IIR (contains SW reset bits)
   // These 16550 registers are not implemented here
   wire [7:0]  reg_mcr;
   wire [7:0]  reg_msr;
   wire [7:0]  reg_scr;
   // Create handshake signals to/from the FIFOs
   assign      wb_rd = wb_cyc_i & wb_stb_i & (~wb_we_i) & wb_sel_i[3] & (wb_adr_i[1:0] == 2'b00) & (~reg_dlab_bit);
   assign      wb_wr = wb_cyc_i & wb_stb_i & wb_we_i & wb_sel_i[3] & (wb_adr_i[1:0] == 2'b00) & (~reg_dlab_bit);
   assign      wb_ack_o = wb_fifo_ack | wb_reg_ack;
   assign      wb_err_o = 1'b0;
   // Assign the unimplemented registers
   assign      reg_mcr = 8'h00;  // These bits control modem control lines, unused here
   assign      reg_msr = 8'hB0;  // CD, DSR, CTS true, RI false, no changes indicated
   assign      reg_scr = 8'h00;  // scratch register.
  // Create the simple / combinatorial registers
   assign      rd_fifo_not_full = !(rd_bytes_avail == 4'h8);
   assign      reg_lcr = {reg_dlab_bit, 7'h03};  // Always set for 8n1
   assign      reg_lsr = {1'b0, rd_fifo_not_full, rd_fifo_not_full, 4'b0000, wr_fifo_not_empty};   
   // Create enable bits for the 16550 registers that we actually implement
   assign      reg_dlab_bit_wren = wb_cyc_i & wb_stb_i & wb_we_i & wb_sel_i[0] & (wb_adr_i[2:0] == 3'b011);
   assign      reg_ier_wren = wb_cyc_i & wb_stb_i & wb_we_i & wb_sel_i[2] & (wb_adr_i[2:0] == 3'b001) & (~reg_dlab_bit);
   assign      reg_iir_rden = wb_cyc_i & wb_stb_i & (~wb_we_i) & wb_sel_i[1] & (wb_adr_i[2:0] == 3'b010);
   assign      wb_reg_ack = wb_cyc_i & wb_stb_i & (|wb_sel_i[3:0]) & (reg_dlab_bit | (wb_adr_i[2:0] != 3'b000));
   assign      reg_fcr_wren = wb_cyc_i & wb_stb_i & wb_we_i & wb_sel_i[1] & (wb_adr_i[2:0] == 3'b010);
   assign      rcvr_fifo_rst = reg_fcr_wren & wb_dat_i[9];
   assign      xmit_fifo_rst = reg_fcr_wren & wb_dat_i[10];
   // Create DLAB bit
   always @ (posedge wb_clk_i)
     begin
	if(wb_rst_i) reg_dlab_bit <= 1'b0;
	else if(reg_dlab_bit_wren) reg_dlab_bit <= wb_dat_i[7];
     end
   // Create IER.  We only use the two LS bits...
   always @ (posedge wb_clk_i)
     begin
	if(wb_rst_i) reg_ier <= 4'h0;
	else if(reg_ier_wren) reg_ier <= wb_dat_i[19:16];
     end
   // Create IIR (and THR INT arm bit)
   assign rd_fifo_becoming_empty = r_fifo_en & (~rpp) & (rd_bytes_avail == 4'h1);  // "rd fifo" is the WB write FIFO...
   always @ (posedge wb_clk_i)
     begin
	if(wb_rst_i) thr_int_arm <= 1'b0;
	else if(wb_wr | rd_fifo_becoming_empty) thr_int_arm <= 1'b1;  // Set when WB write fifo becomes empty, or on a write to it
	else if(reg_iir_rden & (~wr_fifo_not_empty)) thr_int_arm <= 1'b0;
     end
   always @ (thr_int_arm or rd_fifo_not_full or wr_fifo_not_empty)
     begin
	if(wr_fifo_not_empty) iir_gen = 3'b100;
	else if(thr_int_arm & rd_fifo_not_full) iir_gen = 3'b010;
	else iir_gen = 3'b001;
     end 
   assign reg_iir = iir_gen;
   // Create the data lines out to the WB.
   // Always put all 4 bytes on the WB data lines, let the master pick out what it
   // wants.   
   assign bus_data_lo = {data_to_wb, {4'b0000, reg_ier}, {5'b00000, reg_iir}, reg_lcr};
   assign bus_data_hi = {reg_mcr, reg_lsr, reg_msr, reg_scr};
   assign wb_dat_o = (wb_adr_i[2]) ? bus_data_hi : bus_data_lo;
   assign data_from_wb = wb_dat_i[31:24];  // Data to the FIFO
   // Generate interrupt output
   assign int_o = (rd_fifo_not_full & thr_int_arm & reg_ier[1]) | (wr_fifo_not_empty & reg_ier[0]);
endmodule
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
// Module interface
module adv_dbg_if_wb_cpu0_jsp_jsp_module (
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
                         jsp_data_out,
                         biu_wr_strobe,			    
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
   output [7:0]  jsp_data_out;
   output        biu_wr_strobe;
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
   reg [7:0]   jsp_data_out;      
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
   adv_dbg_if_wb_cpu0_jsp_jsp_biu jsp_biu_i (
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
   $display("%t  %m   Jsp wr_module State   = %s",$realtime, wr_module_string);
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
	    	  else if(module_select_i && tdi_i) wr_module_next_state = 3'h2;  // got start bit
	       else wr_module_next_state = 3'h1;
	   end
	  3'h2:
	    begin
	       if(update_dr_i) wr_module_next_state = 3'h0;
	       else if(wr_bit_count_max) wr_module_next_state = 3'h3;
	       else wr_module_next_state = 3'h2;
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
   $display("%t  %m   Jsp rd_module State   = %s",$realtime, rd_module_string);
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
	       else if(rd_bit_count_max) rd_module_next_state = 3'h2;
	       else rd_module_next_state = 3'h1;
	    end
	  3'h2:
	    begin
               if(update_dr_i) rd_module_next_state = 3'h0;
               else rd_module_next_state = 3'h3;
	    end
	  3'h3:
	    begin
	       if(update_dr_i) rd_module_next_state = 3'h0;
	       else if(rd_bit_count_max) rd_module_next_state = 3'h2;
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
module adv_dbg_if_wb_cpu0_jsp_or1k_biu
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
module adv_dbg_if_wb_cpu0_jsp_or1k_module (
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
   adv_dbg_if_wb_cpu0_jsp_or1k_status_reg or1k_statusreg_i (
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
   adv_dbg_if_wb_cpu0_jsp_or1k_biu or1k_biu_i (
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
   adv_dbg_if_wb_cpu0_jsp_crc32 or1k_crc_i
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
module adv_dbg_if_wb_cpu0_jsp_or1k_status_reg  (
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
////  adbg_wb_biu.v                                               ////
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
//// Copyright (C) 2008-2010        Authors                       ////
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
// $Log: adbg_wb_biu.v,v $
// Revision 1.5  2010-03-21 01:05:10  Nathan
// Use all 32 address bits - WishBone slaves may use the 2 least-significant address bits instead of the four wb_sel lines, or in addition to them.
//
// Revision 1.4  2010-01-10 22:54:11  Nathan
// Update copyright dates
//
// Revision 1.3  2009/05/17 20:54:57  Nathan
// Changed email address to opencores.org
//
// Revision 1.2  2009/05/04 00:50:10  Nathan
// Changed the WB BIU to use big-endian byte ordering, to match the OR1000.  Kept little-endian ordering as a compile-time option in case this is ever used with a little-endian CPU.
//
// Revision 1.1  2008/07/22 20:28:32  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.4  2008/07/08 19:04:04  Nathan
// Many small changes to eliminate compiler warnings, no functional changes.  
// System will now pass SRAM and CPU self-tests on Altera FPGA using 
// altera_virtual_jtag TAP.
//
// Top module
module adv_dbg_if_wb_cpu0_jsp_wb_biu
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
   err_o,
   word_size_i,  // 1,2, or 4
   // Wishbone signals
   wb_clk_i,
   wb_adr_o,
   wb_dat_o,
   wb_dat_i,
   wb_cyc_o,
   wb_stb_o,
   wb_sel_o,
   wb_we_o,
   wb_ack_i,
   wb_cab_o,
   wb_err_i,
   wb_cti_o,
   wb_bte_o
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
   output 	 err_o;
   input [2:0] 	 word_size_i;
   // Wishbone signals
   input 	 wb_clk_i;
   output [31:0] wb_adr_o;
   output [31:0] wb_dat_o;
   input [31:0]  wb_dat_i;
   output 	 wb_cyc_o;
   output 	 wb_stb_o;
   output [3:0]  wb_sel_o;
   output 	 wb_we_o;
   input 	 wb_ack_i;
   output 	 wb_cab_o;
   input 	 wb_err_i;
   output [2:0]  wb_cti_o;
   output [1:0]  wb_bte_o;
   wire [31:0] 	 data_o;
   reg 		 rdy_o;
   wire 	 err_o;
   wire [31:0] 	 wb_adr_o;
   reg 		 wb_cyc_o;
   reg 		 wb_stb_o;
   wire [31:0] 	 wb_dat_o;
   wire [3:0] 	 wb_sel_o;
   wire 	 wb_we_o;
   wire 	 wb_cab_o;
   wire [2:0] 	 wb_cti_o;
   wire [1:0] 	 wb_bte_o;
   // Registers
   reg [3:0] 	 sel_reg;
   reg [31:0] 	 addr_reg;  // Don't really need the two LSB, this info is in the SEL bits
   reg [31:0] 	 data_in_reg;  // dbg->WB
   reg [31:0] 	 data_out_reg;  // WB->dbg
   reg 		 wr_reg;
   reg 		 str_sync;  // This is 'active-toggle' rather than -high or -low.
   reg 		 rdy_sync;  // ditto, active-toggle
   reg 		 err_reg;
   // Sync registers.  TFF indicates TCK domain, WBFF indicates wb_clk domain
   reg 		 rdy_sync_tff1;
   reg 		 rdy_sync_tff2;
   reg 		 rdy_sync_tff2q;  // used to detect toggles
   reg 		 str_sync_wbff1;
   reg 		 str_sync_wbff2;
   reg 		 str_sync_wbff2q;  // used to detect toggles
   // Control Signals
   reg 		 data_o_en;    // latch wb_data_i
   reg 		 rdy_sync_en;  // toggle the rdy_sync signal, indicate ready to TCK domain
   reg 		 err_en;       // latch the wb_err_i signal
   // Internal signals
   reg [3:0] 	 be_dec;  // word_size and low-order address bits decoded to SEL bits
   wire 	 start_toggle;  // WB domain, indicates a toggle on the start strobe
   reg [31:0] 	 swapped_data_i;
   reg [31:0] 	 swapped_data_out;
   //////////////////////////////////////////////////////
   // TCK clock domain
   // There is no FSM here, just signal latching and clock
   // domain synchronization
   // Create byte enable signals from word_size and address (combinatorial)
   // This is for a BIG ENDIAN CPU...lowest-addressed byte is 
   // the 8 most significant bits of the 32-bit WB bus.
   always @ (word_size_i or addr_i)
     begin
	case (word_size_i)
	  3'h1:
            begin
               if(addr_i[1:0] == 2'b00) be_dec = 4'b1000;
               else if(addr_i[1:0] == 2'b01) be_dec = 4'b0100;
               else if(addr_i[1:0] == 2'b10) be_dec = 4'b0010;
               else be_dec = 4'b0001;
            end
	  3'h2:
            begin
               if(addr_i[1] == 1'b1) be_dec = 4'b0011;
               else                  be_dec = 4'b1100;
            end
	  3'h4: be_dec = 4'b1111;
	  default: be_dec = 4'b1111;  // default to 32-bit access
	endcase
     end
   // Byte- or word-swap data as necessary.  Use the non-latched be_dec signal,
   // since it and the swapped data will be latched at the same time.
   // Remember that since the data is shifted in LSB-first, shorter words
   // will be in the high-order bits. (combinatorial)
   always @ (be_dec or data_i)
     begin
	case (be_dec)
	  4'b1111: swapped_data_i = data_i;
	  4'b0011: swapped_data_i = {16'h0,data_i[31:16]};
	  4'b1100: swapped_data_i = data_i;
	  4'b0001: swapped_data_i = {24'h0, data_i[31:24]};
	  4'b0010: swapped_data_i = {16'h0, data_i[31:24], 8'h0};
	  4'b0100: swapped_data_i = {8'h0, data_i[31:24], 16'h0};
	  4'b1000: swapped_data_i = {data_i[31:24], 24'h0};
	  default: swapped_data_i = data_i;  // Shouldn't be possible
	endcase
     end
   // Latch input data on 'start' strobe, if ready.
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) begin
	   sel_reg <= 4'h0;
	   addr_reg <= 32'h0;
	   data_in_reg <= 32'h0;
	   wr_reg <= 1'b0;
	end
	else
	  if(strobe_i && rdy_o) begin
	     sel_reg <= be_dec;
	     addr_reg <= addr_i;
	     if(!rd_wrn_i) data_in_reg <= swapped_data_i;
	     wr_reg <= ~rd_wrn_i;
	  end 
     end
   // Create toggle-active strobe signal for clock sync.  This will start a transaction
   // on the WB once the toggle propagates to the FSM in the WB domain.
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
   assign wb_dat_o = data_in_reg;
   assign wb_we_o = wr_reg;
   assign wb_adr_o = addr_reg;
   assign wb_sel_o = sel_reg;
   assign data_o = data_out_reg;
   assign err_o = err_reg;
   assign wb_cti_o = 3'h0;
   assign wb_bte_o = 2'h0;
   assign wb_cab_o = 1'b0;
   ///////////////////////////////////////////////////////
   // Wishbone clock domain
    // synchronize the start strobe
    always @ (posedge wb_clk_i or posedge rst_i)
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
   // Error indicator register
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) err_reg <= 1'b0;
	else if(err_en) err_reg <= wb_err_i; 
     end
   // Byte- or word-swap the WB->dbg data, as necessary (combinatorial)
   // We assume bits not required by SEL are don't care.  We reuse assignments
   // where possible to keep the MUX smaller.  (combinatorial)
   always @ (sel_reg or wb_dat_i)
     begin
	case (sel_reg)
	  4'b1111: swapped_data_out = wb_dat_i;
	  4'b0011: swapped_data_out = wb_dat_i;
	  4'b1100: swapped_data_out = {16'h0, wb_dat_i[31:16]};
	  4'b0001: swapped_data_out = wb_dat_i;
	  4'b0010: swapped_data_out = {24'h0, wb_dat_i[15:8]};
	  4'b0100: swapped_data_out = {16'h0, wb_dat_i[31:16]};
	  4'b1000: swapped_data_out = {24'h0, wb_dat_i[31:24]};
	  default: swapped_data_out = wb_dat_i;  // Shouldn't be possible
	endcase
     end
   // WB->dbg data register
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) data_out_reg <= 32'h0;
	else if(data_o_en) data_out_reg <= swapped_data_out;
     end
   // Create a toggle-active ready signal to send to the TCK domain
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) rdy_sync <= 1'b0;
	else if(rdy_sync_en) rdy_sync <= ~rdy_sync;
     end 
   /////////////////////////////////////////////////////
   // Small state machine to create WB accesses
   // Not much more that an 'in_progress' bit, but easier
   // to read.  Deals with single-cycle and multi-cycle
   // accesses.
   reg wb_fsm_state;
   reg next_fsm_state;
   // Sequential bit
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) wb_fsm_state <= 1'h0;
	else wb_fsm_state <= next_fsm_state; 
     end
   // Determination of next state (combinatorial)
   always @ (wb_fsm_state or start_toggle or wb_ack_i or wb_err_i)
     begin
	case (wb_fsm_state)
          1'h0:
            begin
               if(start_toggle && !(wb_ack_i || wb_err_i)) next_fsm_state = 1'h1;  // Don't go to next state for 1-cycle transfer
               else next_fsm_state = 1'h0;
            end
          1'h1:
            begin
               if(wb_ack_i || wb_err_i) next_fsm_state = 1'h0;
               else next_fsm_state = 1'h1;
            end
	endcase
     end
   // Outputs of state machine (combinatorial)
   always @ (wb_fsm_state or start_toggle or wb_ack_i or wb_err_i or wr_reg)
     begin
	rdy_sync_en = 1'b0;
	err_en = 1'b0;
	data_o_en = 1'b0;
	wb_cyc_o = 1'b0;
	wb_stb_o = 1'b0;
	case (wb_fsm_state)
          1'h0:
            begin
               if(start_toggle) begin
		  wb_cyc_o = 1'b1;
		  wb_stb_o = 1'b1;
		  if(wb_ack_i || wb_err_i) begin
                     err_en = 1'b1;
                     rdy_sync_en = 1'b1;
		  end
		  if (wb_ack_i && !wr_reg) begin
                     data_o_en = 1'b1;
		  end
               end
            end
          1'h1:
            begin
               wb_cyc_o = 1'b1;
               wb_stb_o = 1'b1;
               if(wb_ack_i) begin
                  err_en = 1'b1;
                  data_o_en = 1'b1;
                  rdy_sync_en = 1'b1;
               end
               else if (wb_err_i) begin
                  err_en = 1'b1;
                  rdy_sync_en = 1'b1;
               end
            end
	endcase
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_wb_module.v                                            ////
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
//// Copyright (C) 2008-2010        Authors                       ////
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
// $Log: adbg_wb_module.v,v $
// Revision 1.5  2010-01-13 00:55:45  Nathan
// Created hi-speed mode for burst reads.  This will probably be most beneficial to the OR1K module, as GDB does a burst read of all the GPRs each time a microinstruction is single-stepped.
//
// Revision 1.2  2009/05/17 20:54:57  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/22 20:28:33  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.12  2008/07/11 08:13:30  Nathan
// Latch opcode on posedge, like other signals.  This fixes a problem when 
// the module is used with a Xilinx BSCAN TAP.  Added signals to allow modules 
// to inhibit latching of a new active module by the top module.  This allows 
// the sub-modules to force the top level module to ignore the command present
// in the input shift register after e.g. a burst read.
//
// Top module
module adv_dbg_if_wb_cpu0_jsp_wb_module  (
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
                       wb_clk_i,
                       // WISHBONE master interface
                       wb_adr_o, wb_dat_o, wb_dat_i, wb_cyc_o, wb_stb_o, wb_sel_o,
                       wb_we_o, wb_ack_i, wb_cab_o, wb_err_i, wb_cti_o, wb_bte_o 
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
   // WISHBONE master interface
   input         wb_clk_i;
   output [31:0] wb_adr_o;
   output [31:0] wb_dat_o;
   input [31:0]  wb_dat_i;
   output        wb_cyc_o;
   output        wb_stb_o;
   output [3:0]  wb_sel_o;
   output        wb_we_o;
   input         wb_ack_i;
   output        wb_cab_o;
   input         wb_err_i;
   output [2:0]  wb_cti_o;
   output [1:0]  wb_bte_o;
   //reg           wb_cyc_o;
   // Declare inputs / outputs as wires / registers
   reg 		 module_tdo_o;
   reg 		 top_inhibit_o;
   // Registers to hold state etc.
   reg [31:0] 	 address_counter;     // Holds address for next Wishbone access
   reg [5:0] 	 bit_count;            // How many bits have been shifted in/out
   reg [15:0] 	 word_count;          // bytes remaining in current burst command
   reg [3:0] 	 operation;            // holds the current command (rd/wr, word size)
   reg [32:0] 	 data_out_shift_reg;  // 32 bits to accomodate the internal_reg_error
   reg [1-1:0] internal_register_select;  // Holds index of currently selected register
   reg [32:0] 			    internal_reg_error;  // WB error module internal register.  32 bit address + error bit (LSB)
   // Control signals for the various counters / registers / state machines
   reg 				    addr_sel;          // Selects data for address_counter. 0 = data_register_i, 1 = incremented address count
   reg 				    addr_ct_en;        // Enable signal for address counter register
   reg 				    op_reg_en;         // Enable signal for 'operation' register
   reg 				    bit_ct_en;         // enable bit counter
   reg 				    bit_ct_rst;        // reset (zero) bit count register
   reg 				    word_ct_sel;       // Selects data for byte counter.  0 = data_register_i, 1 = decremented byte count
   reg 				    word_ct_en;        // Enable byte counter register
   reg 				    out_reg_ld_en;     // Enable parallel load of data_out_shift_reg
   reg 				    out_reg_shift_en;  // Enable shift of data_out_shift_reg
   reg 				    out_reg_data_sel;  // 0 = BIU data, 1 = internal register data
   reg [1:0] 			    tdo_output_sel;  // Selects signal to send to TDO.  0 = ready bit, 1 = output register, 2 = CRC match, 3 = CRC shift reg.
   reg 				    biu_strobe;      // Indicates that the bus unit should latch data and start a transaction
   reg 				    crc_clr;         // resets CRC module
   reg 				    crc_en;          // does 1-bit iteration in CRC module
   reg 				    crc_in_sel;      // selects incoming write data (=0) or outgoing read data (=1)as input to CRC module
   reg 				    crc_shift_en;    // CRC reg is also it's own output shift register; this enables a shift
   reg 				    regsel_ld_en;    // Reg. select register load enable
   reg 				    intreg_ld_en;    // load enable for internal registers
   reg 				    error_reg_en;    // Tells the error register to check for and latch a bus error
   reg 				    biu_clr_err;     // Allows FSM to reset BIU, to clear the biu_err bit which may have been set on the last transaction of the last burst.
   // Status signals
   wire 			    word_count_zero;   // true when byte counter is zero
   wire 			    bit_count_max;     // true when bit counter is equal to current word size
   wire 			    module_cmd;        // inverse of MSB of data_register_i. 1 means current cmd not for top level (but is for us)
   wire 			    biu_ready;         // indicates that the BIU has finished the last command
   wire 			    biu_err;           // indicates wishbone error during BIU transaction
   wire 			    burst_instruction; // True when the input_data_i reg has a valid burst instruction for this module
   wire 			    intreg_instruction; // True when the input_data_i reg has a valid internal register instruction
   wire 			    intreg_write;       // True when the input_data_i reg has an internal register write op
   reg 				    rd_op;              // True when operation in the opcode reg is a read, false when a write
   wire 			    crc_match;         // indicates whether data_register_i matches computed CRC
   wire 			    bit_count_32;      // true when bit count register == 32, for CRC after burst writes
   // Intermediate signals
   reg [5:0] 			    word_size_bits;          // 8,16, or 32.  Decoded from 'operation'
   reg [2:0] 			    word_size_bytes;         // 1,2, or 4
   wire [32:0] 			    incremented_address;   // value of address counter plus 'word_size'
   wire [31:0] 			    data_to_addr_counter;  // output of the mux in front of the address counter inputs
   wire [15:0] 			    data_to_word_counter;  // output of the mux in front of the byte counter input
   wire [15:0] 			    decremented_word_count;
   wire [31:0] 			    address_data_in;       // from data_register_i
   wire [15:0] 			    count_data_in;         // from data_register_i
   wire [3:0] 			    operation_in;          // from data_register_i
   wire [31:0] 			    data_to_biu;           // from data_register_i
   wire [31:0] 			    data_from_biu;         // to data_out_shift_register
   wire [31:0] 			    crc_data_out;          // output of CRC module, to output shift register
   wire 			    crc_data_in;                  // input to CRC module, either data_register_i[52] or data_out_shift_reg[0]
   wire 			    crc_serial_out;
   wire [1-1:0] reg_select_data; // from data_register_i, input to internal register select register
   wire [32:0] 			     out_reg_data;           // parallel input to the output shift register
   reg [32:0] 			     data_from_internal_reg;  // data from internal reg. MUX to output shift register
   wire 			     biu_rst;                       // logical OR of rst_i and biu_clr_err
   /////////////////////////////////////////////////
   // Combinatorial assignments
       assign module_cmd = ~(data_register_i[52]);
   assign     operation_in = data_register_i[51:48];
   assign     address_data_in = data_register_i[47:16];
   assign     count_data_in = data_register_i[15:0];
   assign data_to_biu = {tdi_i,data_register_i[52:22]};
   assign     reg_select_data = data_register_i[47:(47-(1-1))];
   ////////////////////////////////////////////////
	      // Operation decoder
   // These are only used before the operation is latched, so decode them from operation_in
   assign     burst_instruction = (~operation_in[3]) & (operation_in[0] | operation_in[1]);
   assign     intreg_instruction = ((operation_in == 4'h9) | (operation_in == 4'hd));
   assign     intreg_write = (operation_in == 4'h9);
   // This is decoded from the registered operation
   always @ (operation)
     begin
	case(operation)
          4'h1:
            begin
	       word_size_bits = 6'd7;  // Bits is actually bits-1, to make the FSM easier
	       word_size_bytes = 3'd1;
	       rd_op = 1'b0;
	    end
          4'h2:
            begin
	       word_size_bits = 6'd15;  // Bits is actually bits-1, to make the FSM easier
	       word_size_bytes = 3'd2;
	       rd_op = 1'b0;
	    end
          4'h3:
       	    begin
	       word_size_bits = 6'd31;  // Bits is actually bits-1, to make the FSM easier
	       word_size_bytes = 3'd4;
	       rd_op = 1'b0;
	    end
          4'h5:
            begin
	       word_size_bits = 6'd7;  // Bits is actually bits-1, to make the FSM easier
	       word_size_bytes = 3'd1;
	       rd_op = 1'b1;
	    end
          4'h6:
            begin
	       word_size_bits = 6'd15;  // Bits is actually bits-1, to make the FSM easier
	       word_size_bytes = 3'd2;
	       rd_op = 1'b1;
	    end
          4'h7:
	    begin
	       word_size_bits = 6'd31;  // Bits is actually bits-1, to make the FSM easier
	       word_size_bytes = 3'd4;
	       rd_op = 1'b1;
	    end        
          default:
 	    begin
 	       word_size_bits = 6'hXX;
	       word_size_bytes = 3'hX;
	       rd_op = 1'bX;
	    end       
	endcase
     end
   ////////////////////////////////////////////////
   // Module-internal register select register (no, that's not redundant.)
   // Also internal register output MUX
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) internal_register_select <= 1'h0;
	else if(regsel_ld_en) internal_register_select <= reg_select_data;
     end
   // This is completely unnecessary here, since the WB module has only 1 internal
   // register.  However, to make the module expandable, it is included anyway.
   always @ (internal_register_select or internal_reg_error)
     begin
	case(internal_register_select) 
          1'b0: data_from_internal_reg = internal_reg_error;
          default: data_from_internal_reg = internal_reg_error;
	endcase
     end
   ////////////////////////////////////////////////////////////////////
   // Module-internal registers
   // These have generic read/write/select code, but
   // individual registers may have special behavior, defined here.
   // This is the bus error register, which traps WB errors
   // We latch every new BIU address in the upper 32 bits, so we always have the address for the transaction which
   // generated the error (the address counter might increment, esp. for writes)
   // We stop latching addresses when the error bit (bit 0) is set. Keep the error bit set until it is 
   // manually cleared by a module internal register write.
   // Note we use reg_select_data straight from data_register_i, rather than the latched version - 
   // otherwise, we would write the previously selected register.
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) internal_reg_error <= 33'h0;
	else if(intreg_ld_en && (reg_select_data == 1'b0))  // do load from data input register
	  begin
             if(data_register_i[46]) internal_reg_error[0] <= 1'b0;  // if write data is 1, reset the error bit
	  end
	else if(error_reg_en && !internal_reg_error[0])
	  begin
             if(biu_err || (!biu_ready))  internal_reg_error[0] <= 1'b1;	    
             else if(biu_strobe) internal_reg_error[32:1] <= address_counter;
	  end
	else if(biu_strobe && !internal_reg_error[0]) internal_reg_error[32:1] <= address_counter;  // When no error, latch this whether error_reg_en or not
     end
   ///////////////////////////////////////////////
   // Address counter
   assign data_to_addr_counter = (addr_sel) ? incremented_address[31:0] : address_data_in;
   assign incremented_address = {1'b0,address_counter} +{30'b0, word_size_bytes};
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
  assign out_reg_data = (out_reg_data_sel) ? data_from_internal_reg : {1'b0,data_from_biu};
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) data_out_shift_reg <= 33'h0;
	else if(out_reg_ld_en) data_out_shift_reg <= out_reg_data;
	else if(out_reg_shift_en) data_out_shift_reg <= {1'b0, data_out_shift_reg[32:1]};
     end
   always @ (tdo_output_sel or data_out_shift_reg[0] or biu_ready or crc_match or crc_serial_out)
     begin
	if(tdo_output_sel == 2'h0) module_tdo_o = biu_ready;
	else if(tdo_output_sel == 2'h1) module_tdo_o = data_out_shift_reg[0];
	else if(tdo_output_sel == 2'h2) module_tdo_o = crc_match;
	else module_tdo_o = crc_serial_out;
     end
   ////////////////////////////////////////
     // Bus Interface Unit
   // It is assumed that the BIU has internal registers, and will
   // latch address, operation, and write data on rising clock edge 
   // when strobe is asserted
   assign biu_rst = rst_i | biu_clr_err;
   adv_dbg_if_wb_cpu0_jsp_wb_biu wb_biu_i 
     (
      // Debug interface signals
      .tck_i           (tck_i),
      .rst_i           (biu_rst),
      .data_i          (data_to_biu),
      .data_o          (data_from_biu),
      .addr_i          (address_counter),
      .strobe_i        (biu_strobe),
      .rd_wrn_i        (rd_op),           // If 0, then write op
      .rdy_o           (biu_ready),
      .err_o           (biu_err),
      .word_size_i     (word_size_bytes),
      // Wishbone signals
      .wb_clk_i        (wb_clk_i),
      .wb_adr_o        (wb_adr_o),
      .wb_dat_o        (wb_dat_o),
      .wb_dat_i        (wb_dat_i),
      .wb_cyc_o        (wb_cyc_o),
      .wb_stb_o        (wb_stb_o),
      .wb_sel_o        (wb_sel_o),
      .wb_we_o         (wb_we_o),
      .wb_ack_i        (wb_ack_i),
      .wb_cab_o        (wb_cab_o),
      .wb_err_i        (wb_err_i),
      .wb_cti_o        (wb_cti_o),
      .wb_bte_o        (wb_bte_o)
      );
   /////////////////////////////////////
       // CRC module
       assign crc_data_in = (crc_in_sel) ? tdi_i : data_out_shift_reg[0];  // MUX, write or read data
   adv_dbg_if_wb_cpu0_jsp_crc32  wb_crc_i
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
   assign     crc_match = (data_register_i[52:21] == crc_data_out) ? 1'b1 : 1'b0;
   ////////////////////////////////////////
   // Control FSM
   // Definition of machine state values.
   // Don't worry too much about the state encoding, the synthesis tool
   // will probably re-encode it anyway.
   reg [3:0]  module_state;       // FSM state
   reg [3:0]  module_next_state;  // combinatorial signal, not actually a register
   // sequential part of the FSM
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i)
	  module_state <= 4'h0;
	else
	  module_state <= module_next_state;
     end
   // Determination of next state; purely combinatorial
   always @ (module_state or module_select_i or module_cmd or update_dr_i or capture_dr_i or operation_in[2]
	     or word_count_zero or bit_count_max or data_register_i[52] or bit_count_32 or biu_ready or burst_instruction)
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
	     or word_count_zero or bit_count_max or data_register_i[52] or biu_ready or intreg_instruction or module_cmd 
	     or intreg_write or decremented_word_count)
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
	error_reg_en = 1'b0;
	biu_clr_err = 1'b0;  // Set this to reset the BIU, clearing the biu_err bit
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
	       if (module_next_state == 4'h4) begin
		  error_reg_en = 1'b1;       // Check the wb_error bit
		  out_reg_data_sel = 1'b0;  // select BIU data
		  out_reg_ld_en = 1'b1;
		  bit_ct_rst = 1'b1;
		  word_ct_sel = 1'b1;
		  word_ct_en = 1'b1;
		  if(!(decremented_word_count == 0) && !word_count_zero) begin  // Start a biu read transaction
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
	       top_inhibit_o = 1'b1;  // in case of early termination
	       if(bit_count_max)
	       begin
	         error_reg_en = 1'b1;       // Check the wb_error bit
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
		  biu_clr_err = 1'b1;  // If error occurred on last transaction of last burst, biu_err is still set.  Clear it.
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
		      error_reg_en = 1'b1;       // Check the wb_error bit
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
	       error_reg_en = 1'b1;       // Check the wb_error bit
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
	       top_inhibit_o = 1'b1;
	       // Bit of a hack here...an error on the final write won't be detected in STATE_Wstatus like the rest, 
	       // so we assume the bus transaction is done and check it / latch it into the error register here.
	       if(module_next_state == 4'h0) error_reg_en = 1'b1;
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
module adv_dbg_if_wb_cpu0_jsp_bytefifo (
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
module adv_dbg_if_wb_cpu0_jsp_syncflop(
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
module adv_dbg_if_wb_cpu0_jsp_syncreg (
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
   adv_dbg_if_wb_cpu0_jsp_syncflop strobe_sff (
			.DEST_CLK (CLKB),
			.D_SET (1'b0),
			.D_RST (strobe_sff_out),
			.RESET (RST),
			.TOGGLE_IN (strobe_toggle),
			.D_OUT (strobe_sff_out)
			);
   // 'ack' sync element
   adv_dbg_if_wb_cpu0_jsp_syncflop ack_sff (
		     .DEST_CLK (CLKA),
		     .D_SET (1'b0),
		     .D_RST (A_enable),
		     .RESET (RST),
		     .TOGGLE_IN (ack_toggle),
		     .D_OUT (ack_sff_out)
		     );  
endmodule
