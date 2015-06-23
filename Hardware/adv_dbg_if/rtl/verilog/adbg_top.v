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


`include "adbg_defines.v"


// Top module
module adbg_top(
                // JTAG signals
                tck_i,
                tdi_i,
                tdo_o,
                rst_i,


                // TAP states
                shift_dr_i,
                pause_dr_i,
                update_dr_i,
                capture_dr_i,

                // Instructions
                debug_select_i


                `ifdef DBG_WISHBONE_SUPPORTED
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
                `endif

                `ifdef DBG_CPU0_SUPPORTED
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
                `endif

                `ifdef DBG_CPU1_SUPPORTED
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
                `endif
		
                `ifdef DBG_JSP_SUPPORTED
                ,
		`ifndef DBG_WISHBONE_SUPPORTED
		wb_clk_i,
		wb_rst_i,
		`endif
		
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
		int_o
                `endif
		
		);


   // JTAG signals
   input   tck_i;
   input   tdi_i;
   output  tdo_o;
   input   rst_i;

   // TAP states
   input   shift_dr_i;
   input   pause_dr_i;
   input   update_dr_i;
   input   capture_dr_i;

   // Module select from TAP
   input   debug_select_i;

`ifdef DBG_WISHBONE_SUPPORTED
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
`endif

`ifdef DBG_CPU0_SUPPORTED
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
`endif

`ifdef DBG_CPU1_SUPPORTED
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
`endif

`ifdef DBG_JSP_SUPPORTED
   `ifndef DBG_WISHBONE_SUPPORTED
   input   wb_clk_i;
   input   wb_rst_i;
   `endif
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
`endif
   
   reg 		 tdo_o;
   wire 	 tdo_wb;
   wire 	 tdo_cpu0;
   wire 	 tdo_cpu1;
   wire          tdo_jsp;

   // Registers
   reg [`DBG_TOP_MODULE_DATA_LEN-1:0] input_shift_reg;  // 1 bit sel/cmd, 4 bit opcode, 32 bit address, 16 bit length = 53 bits
   //reg output_shift_reg;  // Just 1 bit for status (valid module selected)
   reg [`DBG_TOP_MODULE_ID_LENGTH -1:0] module_id_reg;   // Module selection register


   // Control signals
   wire 				select_cmd;  // True when the command (registered at Update_DR) is for top level/module selection
   wire [(`DBG_TOP_MODULE_ID_LENGTH - 1) : 0] module_id_in;    // The part of the input_shift_register to be used as the module select data
   reg [(`DBG_TOP_MAX_MODULES - 1) : 0]       module_selects;  // Select signals for the individual modules
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
	module_selects <= `DBG_TOP_MODULE_ID_LENGTH'h0;
	module_selects[module_id_reg] <= 1'b1;
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

`ifdef DBG_WISHBONE_SUPPORTED
// Connecting wishbone module
adbg_wb_module i_dbg_wb (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_wb),
                  .tdi_i            (tdi_i),

                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),

                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[`DBG_TOP_WISHBONE_DEBUG_MODULE]),
                  .top_inhibit_o     (module_inhibit[`DBG_TOP_WISHBONE_DEBUG_MODULE]),
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
`else
assign tdo_wb = 1'b0;
assign module_inhibit[`DBG_TOP_WISHBONE_DEBUG_MODULE] = 1'b0;
`endif



`ifdef DBG_CPU0_SUPPORTED
adbg_or1k_module i_dbg_cpu_or1k (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_cpu0),
                  .tdi_i            (tdi_i),

                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),

                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[`DBG_TOP_CPU0_DEBUG_MODULE]),
                  .top_inhibit_o     (module_inhibit[`DBG_TOP_CPU0_DEBUG_MODULE]),
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
`else
assign tdo_cpu0 = 1'b0;
assign module_inhibit[`DBG_TOP_CPU0_DEBUG_MODULE] = 1'b0;
`endif  //  DBG_CPU0_SUPPORTED



`ifdef DBG_CPU1_SUPPORTED
// Connecting cpu module
adbg_or1k_module i_dbg_cpu_2 (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_cpu1),
                  .tdi_i            (tdi_i),
                  
                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),

                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[`DBG_TOP_CPU1_DEBUG_MODULE]),
                  .top_inhibit_o    (module_inhibit[`DBG_TOP_CPU1_DEBUG_MODULE]),
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
`else
assign tdo_cpu1 = 1'b0;
assign module_inhibit[`DBG_TOP_CPU1_DEBUG_MODULE] = 1'b0;
`endif

`ifdef DBG_JSP_SUPPORTED
adbg_jsp_module i_dbg_jsp (
                  // JTAG signals
                  .tck_i            (tck_i),
                  .module_tdo_o     (tdo_jsp),
                  .tdi_i            (tdi_i),

                  // TAP states
                  .capture_dr_i     (capture_dr_i),
                  .shift_dr_i       (shift_dr_i),
                  .update_dr_i      (update_dr_i),

                  .data_register_i  (input_shift_reg),
                  .module_select_i  (module_selects[`DBG_TOP_JSP_DEBUG_MODULE]),
                  .top_inhibit_o     (module_inhibit[`DBG_TOP_JSP_DEBUG_MODULE]),
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
		  .int_o            (int_o)
            );
   
`else
   assign tdo_jsp = 1'b0;
   assign module_inhibit[`DBG_TOP_JSP_DEBUG_MODULE] = 1'b0;
`endif   
   
assign select_inhibit = |module_inhibit;

/////////////////////////////////////////////////
// TDO output MUX

always @ (module_id_reg or tdo_wb or tdo_cpu0 or tdo_cpu1 or tdo_jsp)
begin
   case (module_id_reg)
     `DBG_TOP_WISHBONE_DEBUG_MODULE: tdo_o <= tdo_wb;
     `DBG_TOP_CPU0_DEBUG_MODULE:     tdo_o <= tdo_cpu0;
     `DBG_TOP_CPU1_DEBUG_MODULE:     tdo_o <= tdo_cpu1;
     `DBG_TOP_JSP_DEBUG_MODULE:      tdo_o <= tdo_jsp;
       default:                        tdo_o <= 1'b0;
   endcase
end


endmodule
