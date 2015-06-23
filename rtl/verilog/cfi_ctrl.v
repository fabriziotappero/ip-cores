////////////////////////////////////////////////////////////////// ////
////                                                              //// 
////  Common Flash Interface (CFI) controller                     //// 
////                                                              //// 
////  This file is part of the cfi_ctrl project                   //// 
////  http://opencores.org/project,cfi_ctrl                       //// 
////                                                              //// 
////  Description                                                 //// 
////  See below                                                   //// 
////                                                              //// 
////  To Do:                                                      //// 
////   -                                                          //// 
////                                                              //// 
////  Author(s):                                                  //// 
////      - Julius Baxter, julius@opencores.org                   //// 
////                                                              //// 
////////////////////////////////////////////////////////////////////// 
////                                                              //// 
//// Copyright (C) 2011 Authors and OPENCORES.ORG                 //// 
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
//// from http://www.gnu.org/copyleft/lesser.html                 //// 
////                                                              ////
////////////////////////////////////////////////////////////////////// 

/*
 Top level of CFI controller with 32-bit Wishbone classic interface
 
 Intended to be used at about 66MHz with a 32MB CFI flash part with 16-bit
 data interface.

 This module has two configurations - one where it pulls in the CFI control 
 engine, which is intended to simplify accesses to a CFI flash, such as block
 unlock, erase, and programming. The alternate configuration is essentially
 mapping Wishbone accesses to the flash's bus.
 
 CFI Engine Wishbone interface: 
 
 Basic functionality:
 Bits [27:26] decode the operation.
 2'b00 : read/write to the flash memory
 2'b01 : unlock block
 2'b10 : erase block
 2'b11 : block registers, other flash control features
 
 0xc00_0000 : block status/control register
 bits:
 [0]: r/o : CFI controller busy
 [1]: w/o : clear flash status register
 [2]: w/o : reset flash device and controller
 
 0xc00_0004 : flash device status register
 bits
 [7:0] : r/o : flash device status register

 0xe00_0000 : read device identifier information
 User is able to access the device identifier information such as:
 offset 0x0 : manufacturer code
 offset 0x2 : device id
 offset bba + 0x4 : block (add increments of 128KB block size)
 offset 0xa : read config register
 See CFI docs for further details (shift offset left by 1)
 
 0xe01_0000 : CFI query
 User is able to access the CFI query information
 The hex offsets in the CFI spec should be shifted left by one before
 applying to the Wishbone bus.
 
 Addresses under 0x000_0000 cause direct access to the flash
 Addresses under 0x400_0000 cause the block (addressed in [24:0]) to be unlocked
 Addresses under 0x800_0000 cause the block (addressed in [24:0]) to be erased
 
 */

module cfi_ctrl
  (
   wb_clk_i, wb_rst_i,
     
   wb_dat_i, wb_adr_i,
   wb_stb_i, wb_cyc_i,
   wb_we_i, wb_sel_i,
   wb_dat_o, wb_ack_o,
   wb_err_o, wb_rty_o,


   flash_dq_io,
   flash_adr_o,
   flash_adv_n_o,
   flash_ce_n_o,
   flash_clk_o,
   flash_oe_n_o,
   flash_rst_n_o,
   flash_wait_i,
   flash_we_n_o,
   flash_wp_n_o
  
   );

   parameter flash_dq_width = 16;
   parameter flash_adr_width = 24;

   parameter flash_write_cycles = 4; // wlwh/Tclk = 50ns / 15 ns (66Mhz)
   parameter flash_read_cycles = 7;  // elqv/Tclk = 95 / 15 ns (66MHz)

   parameter cfi_engine = "ENABLED";

   inout [flash_dq_width-1:0] 	   flash_dq_io;
   output [flash_adr_width-1:0]    flash_adr_o;

   output 			   flash_adv_n_o;
   output 			   flash_ce_n_o;
   output 			   flash_clk_o;
   output 			   flash_oe_n_o;
   output 			   flash_rst_n_o;
   input 			   flash_wait_i;
   output 			   flash_we_n_o;
   output 			   flash_wp_n_o;


   input 			   wb_clk_i, wb_rst_i;


   input [31:0] 		   wb_dat_i, wb_adr_i;
   input 			   wb_stb_i, wb_cyc_i,
				   wb_we_i;
   input [3:0] 			   wb_sel_i;
   
   output reg [31:0] 		   wb_dat_o;
   output reg 			   wb_ack_o;
   output 			   wb_err_o, wb_rty_o;

   reg [3:0] 			   wb_state;
   generate
      if (cfi_engine == "ENABLED") begin : cfi_engine_gen
	 wire 			   do_rst, do_init, do_readstatus;
	 wire 			   do_clearstatus, do_eraseblock, do_write, 
				   do_read, do_unlockblock;

	 /* Track when we have new bus accesses and are currently serving them */
	 reg 			   wb_req_in_progress;
	 wire 			   wb_req_new;
	 always @(posedge wb_clk_i)
	   if (wb_rst_i)
	     wb_req_in_progress <= 0;
	   else if (wb_req_new)
	     wb_req_in_progress <= 1'b1;
	   else if (wb_ack_o)
	     wb_req_in_progress <= 0;
	 
	 assign wb_req_new = (wb_stb_i & wb_cyc_i) & !wb_req_in_progress;

	 /* Registers for interfacing with the CFI controller */
	 reg [15:0] 		   cfi_bus_dat_i;
	 wire [15:0] 		   cfi_bus_dat_o;
	 reg [23:0] 		   cfi_bus_adr_i;
	 wire 			   cfi_bus_ack_o;
	 wire 			   cfi_bus_busy_o;
	 
	 wire 			   cfi_rw_sel;
	 wire 			   cfi_unlock_sel;
	 wire 			   cfi_erase_sel;
	 wire 			   cfi_scr_sel;
	 wire 			   cfi_readstatus_sel;
	 wire 			   cfi_clearstatus_sel;
	 wire 			   cfi_rst_sel;
	 wire 			   cfi_busy_sel;
	 wire 			   cfi_readdeviceident_sel;
	 wire 			   cfi_cfiquery_sel;

	 reg 			   cfi_bus_go;

	 reg 			   cfi_first_of_two_accesses;
	 
	 assign cfi_rw_sel = wb_adr_i[27:26]==2'b00;
	 assign cfi_unlock_sel = wb_adr_i[27:26]==2'b01 && wb_we_i;
	 assign cfi_erase_sel = wb_adr_i[27:26]==2'b10 && wb_we_i;
	 assign cfi_scr_sel = wb_adr_i[27:26]==2'b11 && wb_adr_i[25:0]==26'd0;
	 assign cfi_readstatus_sel = wb_adr_i[27:26]==2'b11 && 
				     wb_adr_i[25:0]==26'd4 && !wb_we_i;
	 assign cfi_clearstatus_sel = cfi_scr_sel && wb_dat_i[1] && wb_we_i;
	 assign cfi_rst_sel = cfi_scr_sel && wb_dat_i[2] && wb_we_i;
	 assign cfi_busy_sel = cfi_scr_sel & !wb_we_i;
	 assign cfi_readdeviceident_sel = wb_adr_i[27:26]==2'b11 && 
					  wb_adr_i[25]==1'b1 && !wb_adr_i[16]==1'b1 &&
					  !wb_we_i;

	 assign cfi_cfiquery_sel = wb_adr_i[27:26]==2'b11 && 
				   wb_adr_i[25]==1'b1 && wb_adr_i[16]==1'b1 &&
				   !wb_we_i;
	 

	 assign do_rst = cfi_rst_sel & cfi_bus_go;
	 assign do_init = 0;
	 assign do_readstatus = cfi_readstatus_sel & cfi_bus_go;
	 assign do_clearstatus = cfi_clearstatus_sel & cfi_bus_go;
	 assign do_eraseblock = cfi_erase_sel & cfi_bus_go;
	 assign do_write = cfi_rw_sel & wb_we_i & cfi_bus_go ;
	 assign do_read = cfi_rw_sel & !wb_we_i & cfi_bus_go ;
	 assign do_unlockblock = cfi_unlock_sel & cfi_bus_go ;
	 assign do_readdeviceident = cfi_readdeviceident_sel & cfi_bus_go ;
	 assign do_cfiquery = cfi_cfiquery_sel & cfi_bus_go ;
	 

	 /* Main statemachine */
`define WB_FSM_IDLE 0
`define WB_FSM_CFI_CMD_WAIT 2
	 
	 always @(posedge wb_clk_i)
	   if (wb_rst_i) begin
	      wb_state <= `WB_FSM_IDLE;
	      cfi_bus_go <= 0;

	      /* Wishbone regs */
	      wb_dat_o <= 0;
	      wb_ack_o <= 0;

	      cfi_first_of_two_accesses <= 0;
	      
	   end
	   else begin
	      case (wb_state)
		`WB_FSM_IDLE: begin
		   wb_ack_o <= 0;
		   cfi_bus_go <= 0;
		   /* Pickup new incoming accesses */
		   /* Potentially get into a state where we received a bus request
		    but the CFI was still busy so waited. In this case we'll get a 
		    ACK from the controller and have a new request registered */
		   if (wb_req_new) begin
		      
		      if (cfi_busy_sel) /* want to read the busy flag */
			begin
			   wb_ack_o <= 1;
			   wb_dat_o <= {30'd0, cfi_bus_busy_o};
			end
		      else if (!cfi_bus_busy_o | (wb_req_in_progress & cfi_bus_ack_o))
			begin
			   if (cfi_rw_sel | cfi_unlock_sel | cfi_erase_sel |
			       cfi_readstatus_sel | cfi_clearstatus_sel | 
			       cfi_rst_sel | cfi_readdeviceident_sel | 
			       cfi_cfiquery_sel) 
			     begin
				wb_state <= `WB_FSM_CFI_CMD_WAIT;
				cfi_bus_go <= 1;
				
				if (cfi_rw_sel) begin
				   /* Map address onto the 16-bit word bus*/
				   /* Reads always do full 32-bits, so adjust
				    address accordingly.*/
				   

				   /* setup address and number of cycles depending
				    on request */
				   if (wb_we_i) begin /* Writing */
				      /* Only possible to write shorts at a time */
				      cfi_bus_dat_i <= wb_sel_i[1:0]==2'b11 ? 
						       wb_dat_i[15:0] : 
						       wb_dat_i[31:16];
				      cfi_bus_adr_i[23:0] <= wb_adr_i[24:1];
				   end
				   else begin /* Reading */
				      /* Full or part word? */
				      if ((&wb_sel_i)) begin /* 32-bits */
					 cfi_first_of_two_accesses <= 1;
					 cfi_bus_adr_i[23:0] <= {wb_adr_i[24:2],1'b0};
				      end
				      else begin /*16-bits or byte */
					 cfi_bus_adr_i[23:0] <= {wb_adr_i[24:1]};
				      end
				   end
				end
				if (cfi_unlock_sel | cfi_erase_sel)
				  cfi_bus_adr_i[23:0] <= wb_adr_i[24:1];
				if (cfi_readdeviceident_sel)
				  cfi_bus_adr_i[23:0] <= {wb_adr_i[24:17],1'b0,
							  7'd0,wb_adr_i[9:1]};
				if (cfi_cfiquery_sel)
				  cfi_bus_adr_i[23:0] <= {14'd0,wb_adr_i[10:1]};
			     end // if (cfi_rw_sel | cfi_unlock_sel | ...
			end // if (!cfi_bus_busy_o | (wb_req_in_progress & ...
		   end // if (wb_req_new)
		end // case: `WB_FSM_IDLE
		`WB_FSM_CFI_CMD_WAIT: begin
		   cfi_bus_go <= 0;
		   /* Wait for the CFI controller to do its thing */
		   if (cfi_bus_ack_o) begin
		      if (cfi_rw_sel) begin
			 /* Is this the first of two accesses? */
			 if (cfi_first_of_two_accesses) begin
			    cfi_bus_adr_i <= cfi_bus_adr_i+1;
			    cfi_first_of_two_accesses <= 0;
			    cfi_bus_go <= 1;
			    /* Dealing with a read or a write */
			    /*
			     if (wb_we_i)
			     cfi_bus_dat_i <= wb_dat_i[31:16];
			     else
			     */
			    wb_dat_o[31:16] <= cfi_bus_dat_o;
			 end
			 else begin
			    wb_state <= `WB_FSM_IDLE;
			    wb_ack_o <= 1'b1;
			    if (!wb_we_i) begin
			       if (&wb_sel_i)
				 wb_dat_o[15:0] <= cfi_bus_dat_o;
			       else begin
				  case (wb_sel_i)
				    4'b0001 :
				      wb_dat_o[31:0] <= {4{cfi_bus_dat_o[7:0]}};
				    4'b0010:
				      wb_dat_o[31:0] <= {4{cfi_bus_dat_o[15:8]}};
				    4'b0011 :
				      wb_dat_o[31:0] <= {cfi_bus_dat_o,cfi_bus_dat_o};
				    4'b0100 :
				      wb_dat_o[31:0] <= {4{cfi_bus_dat_o[7:0]}};
				    4'b1100 :
				      wb_dat_o[31:0] <= {cfi_bus_dat_o,cfi_bus_dat_o};
				    4'b1000 :
				      wb_dat_o[31:0] <= {4{cfi_bus_dat_o[15:8]}};
				  endcase // case (wb_sel_i)
			       end

			       
			    end
			 end // else: !if(cfi_first_of_two_accesses)
		      end // if (cfi_rw_sel)	
		      else begin
			 /* All other accesses should be a single go of the CFI
			  controller */
			 wb_state <= `WB_FSM_IDLE;
			 wb_ack_o <= 1'b1;
			 /* Get the read status data out */
			 if (cfi_readstatus_sel)
			   wb_dat_o <= {4{cfi_bus_dat_o[7:0]}};
			 if (cfi_readdeviceident_sel | cfi_cfiquery_sel)
			   wb_dat_o <= {2{cfi_bus_dat_o[15:0]}};
		      end
		   end // if (cfi_bus_ack_o)
		   else if (cfi_rst_sel)begin
		      /* The reset command won't ACK back over the bus, incase
		       the FSM hung and it actually reset all of its internals */
		      wb_state <= `WB_FSM_IDLE;
		      wb_ack_o <= 1'b1;
		   end
		end // case: `WB_FSM_CFI_CMD_WAIT
	      endcase // case (wb_state)
	   end // else: !if(wb_rst_i)
	 
	 assign wb_err_o = 0;
	 assign wb_rty_o = 0;

	 cfi_ctrl_engine
	   # (.cfi_part_wlwh_cycles(flash_write_cycles),
	      .cfi_part_elqv_cycles(flash_read_cycles)
	      )
	 cfi_ctrl_engine0
	   (
	    .clk_i(wb_clk_i), 
	    .rst_i(wb_rst_i),

	    .do_rst_i(do_rst),
	    .do_init_i(do_init),
	    .do_readstatus_i(do_readstatus),
	    .do_clearstatus_i(do_clearstatus),
	    .do_eraseblock_i(do_eraseblock),
	    .do_unlockblock_i(do_unlockblock),
	    .do_write_i(do_write),
	    .do_read_i(do_read),
	    .do_readdeviceident_i(do_readdeviceident),
	    .do_cfiquery_i(do_cfiquery),

	    .bus_dat_o(cfi_bus_dat_o),
	    .bus_dat_i(cfi_bus_dat_i),
	    .bus_adr_i(cfi_bus_adr_i),
	    .bus_req_done_o(cfi_bus_ack_o),
	    .bus_busy_o(cfi_bus_busy_o),

	    .flash_dq_io(flash_dq_io),
	    .flash_adr_o(flash_adr_o),
	    .flash_adv_n_o(flash_adv_n_o),
	    .flash_ce_n_o(flash_ce_n_o),
	    .flash_clk_o(flash_clk_o),
	    .flash_oe_n_o(flash_oe_n_o),
	    .flash_rst_n_o(flash_rst_n_o),
	    .flash_wait_i(flash_wait_i),
	    .flash_we_n_o(flash_we_n_o),
	    .flash_wp_n_o(flash_wp_n_o)

	    );
      end // if (cfi_engine == "ENABLED")
      else begin : cfi_simple

	 reg long_read;
	 reg [4:0] flash_ctr;
	 reg [3:0] wb_state;


	 reg [flash_dq_width-1:0] flash_dq_o_r;
	 reg [flash_adr_width-1:0] flash_adr_o_r;
	 reg 			   flash_oe_n_o_r;
	 reg 			   flash_we_n_o_r;
	 reg 			   flash_rst_n_o_r;
	 wire 			   our_flash_oe;
	 
	 assign flash_ce_n_o = 0;
	 assign flash_clk_o = 1;
	 assign flash_rst_n_o = flash_rst_n_o_r;
	 assign flash_wp_n_o = 1;
	 assign flash_adv_n_o = 0;
	 assign flash_dq_io = (our_flash_oe) ? flash_dq_o_r : 
			      {flash_dq_width{1'bz}};
	 assign flash_adr_o = flash_adr_o_r;
	 assign flash_oe_n_o = flash_oe_n_o_r;
	 assign flash_we_n_o = flash_we_n_o_r;
	 

`define WB_STATE_IDLE 0
`define WB_STATE_WAIT 1

	 assign our_flash_oe = (wb_state == `WB_STATE_WAIT ||
				wb_ack_o) & wb_we_i;	 
	 
	 always @(posedge wb_clk_i)
	   if (wb_rst_i)
	     begin
		wb_ack_o <= 0;
		wb_dat_o <= 0;
		wb_state <= `WB_STATE_IDLE;
		flash_dq_o_r <= 0;
		flash_adr_o_r <= 0;
		flash_oe_n_o_r <= 1;
		flash_we_n_o_r <= 1;
		flash_rst_n_o_r <= 0; /* active */
		long_read <= 0;
		flash_ctr <= 0;
		
	     end
	   else begin
	      if (|flash_ctr)
		flash_ctr <= flash_ctr - 1;
	      
	      case(wb_state)
		`WB_STATE_IDLE: begin
		   /* reset some signals to NOP status */
		   wb_ack_o <= 0;
		   flash_oe_n_o_r <= 1;
		   flash_we_n_o_r <= 1;
		   flash_rst_n_o_r <= 1;

		   if (wb_stb_i & wb_cyc_i & !wb_ack_o) begin
		      flash_adr_o_r <= wb_adr_i[flash_adr_width:1];
		      wb_state <= `WB_STATE_WAIT;
		      if (wb_adr_i[27]) begin
			 /* Reset the flash, no matter the access */
			 flash_rst_n_o_r <= 0;
			 flash_ctr <= 5'd16;
		      end
		      else if (wb_we_i) begin
			 /* load counter with write cycle counter */
			 flash_ctr <= flash_write_cycles - 1;
			 /* flash bus write command */
			 flash_we_n_o_r <= 0;
			 flash_dq_o_r <= (|wb_sel_i[3:2]) ? wb_dat_i[31:16] :
					 wb_dat_i[15:0];
		      end
		      else begin
			 /* load counter with write cycle counter */
			 flash_ctr <= flash_read_cycles - 1;
			 if (&wb_sel_i)
			   long_read <= 1; // Full 32-bit read, 2 read cycles
			 flash_oe_n_o_r <= 0;
		      end // else: !if(wb_we_i)
		   end // if (wb_stb_i & wb_cyc_i)
		   
		end
		`WB_STATE_WAIT: begin
		   if (!(|flash_ctr)) begin
		      if (wb_we_i) begin
			 /* write finished */
			 wb_ack_o <= 1;
			 wb_state <= `WB_STATE_IDLE;
			 flash_we_n_o_r <= 1;
		      end
		      else begin
			 /* read finished */
			 if (!(&wb_sel_i)) /* short or byte read */ begin
			    case (wb_sel_i)
			      4'b0001,
			      4'b0100:
				wb_dat_o <= {4{flash_dq_io[7:0]}};
			      4'b1000,
			      4'b0010:
				wb_dat_o <= {4{flash_dq_io[15:8]}};
			      default:
				wb_dat_o <= {2{flash_dq_io}};
			    endcase // case (wb_sel_i)
			    wb_state <= `WB_STATE_IDLE;
			    wb_ack_o <= 1;
			    flash_oe_n_o_r <= 1;
			 end
			 else if (long_read) begin
			    /* now go on to read next word */
			    wb_dat_o[31:16] <= flash_dq_io;
			    long_read <= 0;
			    flash_ctr <= flash_read_cycles;
			    flash_adr_o_r <= flash_adr_o_r + 1;
			 end
			 else begin
			    /* finished two-part read */
			    wb_dat_o[15:0] <= flash_dq_io;
			    wb_state <= `WB_STATE_IDLE;
			    wb_ack_o <= 1;
			    flash_oe_n_o_r <= 1;
			 end
		      end
		   end
		end

		default:
		  wb_state <= `WB_STATE_IDLE;
	      endcase // case (wb_state)
	   end // else: !if(wb_rst_i)
	 
      end // block: cfi_simple
   endgenerate

endmodule // cfi_ctrl

