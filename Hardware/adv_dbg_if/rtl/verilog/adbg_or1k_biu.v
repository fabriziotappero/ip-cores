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



module adbg_or1k_biu
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

`define STATE_IDLE     1'h0
`define STATE_TRANSFER 1'h1

   // Sequential bit
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) cpu_fsm_state <= `STATE_IDLE;
	else cpu_fsm_state <= next_fsm_state; 
     end

   // Determination of next state (combinatorial)
   always @ (cpu_fsm_state or start_toggle or cpu_ack_i)
     begin
	case (cpu_fsm_state)
          `STATE_IDLE:
            begin
               if(start_toggle && !cpu_ack_i) next_fsm_state <= `STATE_TRANSFER;  // Don't go to next state for 1-cycle transfer
               else next_fsm_state <= `STATE_IDLE;
            end
          `STATE_TRANSFER:
            begin
               if(cpu_ack_i) next_fsm_state <= `STATE_IDLE;
               else next_fsm_state <= `STATE_TRANSFER;
            end
	endcase
     end

   // Outputs of state machine (combinatorial)
   always @ (cpu_fsm_state or start_toggle or cpu_ack_i or wr_reg)
     begin
	rdy_sync_en <= 1'b0;
	data_o_en <= 1'b0;
	cpu_stb_o <= 1'b0;
	
	case (cpu_fsm_state)
          `STATE_IDLE:
            begin
               if(start_toggle) begin
		  cpu_stb_o <= 1'b1;
		  if(cpu_ack_i) begin
                     rdy_sync_en <= 1'b1;
		  end
		  
		  if (cpu_ack_i && !wr_reg) begin  // latch read data
                     data_o_en <= 1'b1;
		  end
               end
            end

          `STATE_TRANSFER:
            begin
               cpu_stb_o <= 1'b1;  // OR1K behavioral model needs this.  OR1200 should be indifferent.
               if(cpu_ack_i) begin
                  data_o_en <= 1'b1;
                  rdy_sync_en <= 1'b1;
               end
            end
	endcase

     end

endmodule

