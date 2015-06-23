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
module `VARIANT (
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
   reg [`DBG_TOP_MODULE_DATA_LEN-1:0] input_shift_reg;  // 1 bit sel/cmd, 4 bit opcode, 32 bit address, 16 bit length = 53 bits
   //reg output_shift_reg;  // Just 1 bit for status (valid module selected)
   reg [`DBG_TOP_MODULE_ID_LENGTH -1:0] module_id_reg;   // Module selection register


   // Control signals
   wire 				      select_cmd;  // True when the command (registered at Update_DR) is for top level/module selection
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
  if (rst_i)                             module_id_reg <= 2'b0;
  else if(debug_select_i && select_cmd && update_dr_i && !select_inhibit)       // Chain select
    module_id_reg <= module_id_in;
end


always @ (module_id_reg)
begin
	module_selects                 = `DBG_TOP_MAX_MODULES'h0;
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
assign module_inhibit[`DBG_TOP_WISHBONE_DEBUG_MODULE] = 1'b0;




assign tdo_cpu0 = 1'b0;
assign module_inhibit[`DBG_TOP_CPU0_DEBUG_MODULE] = 1'b0;




assign tdo_cpu1 = 1'b0;
assign module_inhibit[`DBG_TOP_CPU1_DEBUG_MODULE] = 1'b0;



`VARIANT`JFIFO_MODULE i_dbg_jfifo (
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


assign module_inhibit[`DBG_TOP_JSP_DEBUG_MODULE] = 1'b0;
   
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
