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
 CFI controller engine.
 
 Contains main state machine and bus controls.

 Controlled via a simple interface to a bus controller interface.
 
 For now just implements an asynchronous controller.
 
 do_rst_i - reset the flash device
 do_init_i - initialise the device (write "read configuration register")
 do_readstatus_i - read the status of the device
 do_eraseblock_i - erase a block
 do_write_i - write a word an address
 do_read_i - read a word from an address
 
 bus_dat_o - data out to bus controller
 bus_dat_i - data in from bus controller
 bus_req_done_o - bus request done
 
 */


module cfi_ctrl_engine
  (

   clk_i, rst_i,

   do_rst_i,
   do_init_i,
   do_readstatus_i,
   do_clearstatus_i,
   do_eraseblock_i,
   do_unlockblock_i,
   do_write_i,
   do_read_i,
   do_readdeviceident_i,
   do_cfiquery_i,

   bus_dat_o,
   bus_dat_i,
   bus_adr_i,
   bus_req_done_o,
   bus_busy_o,
  
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
   
   input clk_i, rst_i;
   input do_rst_i,
	 do_init_i,
	 do_readstatus_i,
	 do_clearstatus_i,
	 do_eraseblock_i,
	 do_unlockblock_i,
	 do_write_i,
	 do_read_i,
	 do_readdeviceident_i,
	 do_cfiquery_i;
   
   output reg [flash_dq_width-1:0] bus_dat_o;
   input [flash_dq_width-1:0] 	   bus_dat_i;
   input [flash_adr_width-1:0] 	   bus_adr_i;		       
   output 			   bus_req_done_o;
   output 			   bus_busy_o;  
   
   
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

   wire 			   clk, rst;

assign clk = clk_i;
assign rst = rst_i;

   reg [5:0] 			bus_control_state;
   
   reg [flash_dq_width-1:0] 	flash_cmd_to_write;

   /* regs for flash bus control signals */
   reg flash_adv_n_r;
   reg flash_ce_n_r;
   reg flash_oe_n_r;
   reg flash_we_n_r;
   reg flash_wp_n_r;
   reg flash_rst_n_r;
   reg [flash_dq_width-1:0]  flash_dq_o_r;
   reg [flash_adr_width-1:0] flash_adr_r;

   reg [3:0] 		     flash_phy_state;
   reg [3:0] 		     flash_phy_ctr;
   wire 		     flash_phy_async_wait;
   
`define CFI_PHY_FSM_IDLE        0
`define CFI_PHY_FSM_WRITE_GO    1
`define CFI_PHY_FSM_WRITE_WAIT  2
`define CFI_PHY_FSM_WRITE_DONE  3
`define CFI_PHY_FSM_READ_GO     4
`define CFI_PHY_FSM_READ_WAIT   5
`define CFI_PHY_FSM_READ_DONE   6
`define CFI_PHY_FSM_RESET_GO    7
`define CFI_PHY_FSM_RESET_WAIT  8
`define CFI_PHY_FSM_RESET_DONE  9

   /* Defines according to CFI spec */
`define CFI_CMD_DAT_READ_STATUS_REG      8'h70
`define CFI_CMD_DAT_CLEAR_STATUS_REG     8'h50
`define CFI_CMD_DAT_WORD_PROGRAM         8'h40
`define CFI_CMD_DAT_BLOCK_ERASE          8'h20
`define CFI_CMD_DAT_READ_ARRAY           8'hff   
`define CFI_CMD_DAT_WRITE_RCR            8'h60
`define CFI_CMD_DAT_CONFIRM_WRITE_RCR    8'h03
`define CFI_CMD_DAT_UNLOCKBLOCKSETUP     8'h60
`define CFI_CMD_DAT_CONFIRM_CMD          8'hd0
`define CFI_CMD_DAT_READDEVICEIDENT      8'h90
`define CFI_CMD_DAT_CFIQUERY             8'h98


   /* Main bus-controlled FSM states */
`define CFI_FSM_IDLE                   0
`define CFI_FSM_DO_WRITE               1
`define CFI_FSM_DO_WRITE_WAIT          2
`define CFI_FSM_DO_READ                3
`define CFI_FSM_DO_READ_WAIT           4
`define CFI_FSM_DO_BUS_ACK             5
`define CFI_FSM_DO_RESET               6
`define CFI_FSM_DO_RESET_WAIT          7

   /* Used to internally track what read more we're in 
    2'b00 : read array mode
    2'b01 : read status mode
    else : something else*/
   reg [1:0] 				flash_device_read_mode;
   
   /* Track what read mode we're in */
   always @(posedge clk)
     if (rst)
       flash_device_read_mode <= 2'b00;
     else if (!flash_rst_n_o)
	flash_device_read_mode 	    <= 2'b00;
     else if (flash_phy_state == `CFI_PHY_FSM_WRITE_DONE) begin
	if (flash_cmd_to_write == `CFI_CMD_DAT_READ_ARRAY)
	   flash_device_read_mode <= 2'b00;
	else if (flash_cmd_to_write == `CFI_CMD_DAT_READ_STATUS_REG)
	   flash_device_read_mode <= 2'b01;
	else
	   /* Some other mode */
	   flash_device_read_mode <= 2'b11;
     end
	
   /* Main control state machine, controlled by the bus */
   always @(posedge clk)
     if (rst) begin
       /* Power up and start an asynchronous write to the "read config reg" */
	bus_control_state <= `CFI_FSM_IDLE;
	flash_cmd_to_write <= 0;
     end
     else
       case (bus_control_state)
	 `CFI_FSM_IDLE : begin
	    if (do_readstatus_i) begin
//	       if (flash_device_read_mode != 2'b01) begin
		  flash_cmd_to_write <= `CFI_CMD_DAT_READ_STATUS_REG;
		  bus_control_state <= `CFI_FSM_DO_WRITE;
//	       end
//	       else begin
//		  flash_cmd_to_write <= 0;
//		  bus_control_state <= `CFI_FSM_DO_READ;
//	       end
	    end
	    if (do_clearstatus_i) begin
	       flash_cmd_to_write <= `CFI_CMD_DAT_CLEAR_STATUS_REG;
	       bus_control_state <= `CFI_FSM_DO_WRITE;
	    end	    
	    if (do_eraseblock_i) begin
	       flash_cmd_to_write <= `CFI_CMD_DAT_BLOCK_ERASE;
	       bus_control_state <= `CFI_FSM_DO_WRITE;
	    end
	    if (do_write_i) begin
	       flash_cmd_to_write <= `CFI_CMD_DAT_WORD_PROGRAM;
	       bus_control_state <= `CFI_FSM_DO_WRITE;
	    end
	    if (do_read_i) begin
	       if (flash_device_read_mode != 2'b00) begin
		  flash_cmd_to_write <= `CFI_CMD_DAT_READ_ARRAY;
		  bus_control_state <= `CFI_FSM_DO_WRITE;
	       end
	       else begin
		  flash_cmd_to_write <= 0;
		  bus_control_state <= `CFI_FSM_DO_READ;
	       end
	    end
	    if (do_unlockblock_i) begin
	       flash_cmd_to_write <= `CFI_CMD_DAT_UNLOCKBLOCKSETUP;
	       bus_control_state <= `CFI_FSM_DO_WRITE;
	    end
	    if (do_rst_i) begin
	       flash_cmd_to_write <= 0;
	       bus_control_state <= `CFI_FSM_DO_RESET;
	    end
	    if (do_readdeviceident_i) begin
	       flash_cmd_to_write <= `CFI_CMD_DAT_READDEVICEIDENT;
	       bus_control_state <= `CFI_FSM_DO_WRITE;
	    end
	    if (do_cfiquery_i) begin
	       flash_cmd_to_write <= `CFI_CMD_DAT_CFIQUERY;
	       bus_control_state <= `CFI_FSM_DO_WRITE;
	    end
	    
	 end // case: `CFI_FSM_IDLE
	 `CFI_FSM_DO_WRITE : begin
	    bus_control_state <= `CFI_FSM_DO_WRITE_WAIT;
	 end
	 `CFI_FSM_DO_WRITE_WAIT : begin
	    /* Wait for phy controller to finish the write command */
	    if (flash_phy_state==`CFI_PHY_FSM_WRITE_DONE) begin
	       if (flash_cmd_to_write == `CFI_CMD_DAT_READ_STATUS_REG ||
		   flash_cmd_to_write == `CFI_CMD_DAT_READ_ARRAY ||
		   flash_cmd_to_write == `CFI_CMD_DAT_READDEVICEIDENT ||
		   flash_cmd_to_write == `CFI_CMD_DAT_CFIQUERY) begin
		  /* we just changed the read mode, so go ahead and do the 
		   read */
		  bus_control_state <= `CFI_FSM_DO_READ;
	       end
	       else if (flash_cmd_to_write == `CFI_CMD_DAT_WORD_PROGRAM) begin
		  /* Setting up to do a word write, go to write again */
		  /* clear the command, to use the incoming data from the bus */
		  flash_cmd_to_write <= 0;
		  bus_control_state <= `CFI_FSM_DO_WRITE;
	       end
	       else if (flash_cmd_to_write == `CFI_CMD_DAT_BLOCK_ERASE ||
			flash_cmd_to_write == `CFI_CMD_DAT_UNLOCKBLOCKSETUP) 
	       begin
		  /* first stage of a two-stage command requiring confirm */
		  bus_control_state <= `CFI_FSM_DO_WRITE;
		  flash_cmd_to_write <= `CFI_CMD_DAT_CONFIRM_CMD;
	       end
	       else
		  /* All other operations should see us acking the bus */
		  bus_control_state <= `CFI_FSM_DO_BUS_ACK;
	    end
	 end // case: `CFI_FSM_DO_WRITE_WAIT
	  `CFI_FSM_DO_READ : begin
	     bus_control_state <= `CFI_FSM_DO_READ_WAIT;
	  end
	  `CFI_FSM_DO_READ_WAIT : begin
	     if (flash_phy_state==`CFI_PHY_FSM_READ_DONE) begin
		bus_control_state <= `CFI_FSM_DO_BUS_ACK;
	     end
	  end
	  `CFI_FSM_DO_BUS_ACK :
	     bus_control_state <= `CFI_FSM_IDLE;
	 `CFI_FSM_DO_RESET :
	   bus_control_state <= `CFI_FSM_DO_RESET_WAIT;
	 `CFI_FSM_DO_RESET_WAIT : begin
	    if (flash_phy_state==`CFI_PHY_FSM_RESET_DONE)
	      bus_control_state <= `CFI_FSM_IDLE;
	 end
	  default :
	     bus_control_state <= `CFI_FSM_IDLE;
       endcase // case (bus_control_state)

/* Tell the bus we're done */
assign bus_req_done_o = (bus_control_state==`CFI_FSM_DO_BUS_ACK);
assign bus_busy_o = !(bus_control_state == `CFI_FSM_IDLE);

/* Sample flash data for the system bus interface */
always @(posedge clk)
   if (rst)
      bus_dat_o <= 0;
   else if ((flash_phy_state == `CFI_PHY_FSM_READ_WAIT) &&
	    /* Wait for t_vlqv */
	    (!flash_phy_async_wait))
      /* Sample flash data */
      bus_dat_o <= flash_dq_io;

/* Flash physical interface control state machine */
always @(posedge clk)
   if (rst)
   begin
      flash_adv_n_r <= 1'b0;
      flash_ce_n_r  <= 1'b1;
      flash_oe_n_r  <= 1'b1;
      flash_we_n_r  <= 1'b1;
      flash_dq_o_r  <= 0;
      flash_adr_r   <= 0;
      flash_rst_n_r <= 0;

      flash_phy_state <= `CFI_PHY_FSM_IDLE;
   end
   else
   begin
      case (flash_phy_state)
	 `CFI_PHY_FSM_IDLE : begin
	    flash_rst_n_r <= 1'b1;
	    flash_ce_n_r <= 1'b0;
	    
	    /* Take address from the bus controller */
	    flash_adr_r  <= bus_adr_i;

	    /* Wait for a read or write command */
	    if (bus_control_state == `CFI_FSM_DO_WRITE)
	    begin
	       flash_phy_state <= `CFI_PHY_FSM_WRITE_GO;
	       /* Are we going to write a command? */
	       if (flash_cmd_to_write) begin
		  flash_dq_o_r <= {{(flash_dq_width-8){1'b0}},
				   flash_cmd_to_write};
	       end
	       else
		  flash_dq_o_r <= bus_dat_i;
	       
	    end
	    if (bus_control_state == `CFI_FSM_DO_READ) begin
	       flash_phy_state <= `CFI_PHY_FSM_READ_GO;
	    end
	    if (bus_control_state == `CFI_FSM_DO_RESET) begin
	       flash_phy_state <= `CFI_PHY_FSM_RESET_GO;
	    end	    
	 end
	 `CFI_PHY_FSM_WRITE_GO: begin
	    /* Assert CE, WE */
	    flash_we_n_r <= 1'b0;
	    
	    flash_phy_state <= `CFI_PHY_FSM_WRITE_WAIT;
	 end
	 `CFI_PHY_FSM_WRITE_WAIT: begin
	    /* Wait for t_wlwh */
	    if (!flash_phy_async_wait) begin
	       flash_phy_state <= `CFI_PHY_FSM_WRITE_DONE;
	       flash_we_n_r <= 1'b1;
	    end
	 end
	 `CFI_PHY_FSM_WRITE_DONE: begin
	    flash_phy_state <= `CFI_PHY_FSM_IDLE;
	 end

	 `CFI_PHY_FSM_READ_GO: begin
	    /* Assert CE, OE */
	    /*flash_adv_n_r <= 1'b1;*/
	    flash_ce_n_r <= 1'b0;
	    flash_oe_n_r <= 1'b0;
	    flash_phy_state <= `CFI_PHY_FSM_READ_WAIT;
	 end
	 `CFI_PHY_FSM_READ_WAIT: begin
	    /* Wait for t_vlqv */
	    if (!flash_phy_async_wait) begin
	       flash_oe_n_r    <= 1'b1;
	       flash_phy_state <= `CFI_PHY_FSM_READ_DONE;
	    end
	 end
	 `CFI_PHY_FSM_READ_DONE: begin
	    flash_phy_state <= `CFI_PHY_FSM_IDLE;
	 end
	`CFI_PHY_FSM_RESET_GO: begin
	   flash_phy_state <= `CFI_PHY_FSM_RESET_WAIT;
	   flash_rst_n_r <= 1'b0;
	   flash_oe_n_r <= 1'b1;
	end
	`CFI_PHY_FSM_RESET_WAIT : begin
	   if (!flash_phy_async_wait) begin
	      flash_rst_n_r    <= 1'b1;
	      flash_phy_state <= `CFI_PHY_FSM_RESET_DONE;
	   end
	end
	`CFI_PHY_FSM_RESET_DONE : begin
	   flash_phy_state <= `CFI_PHY_FSM_IDLE;
	end
	 default:
	    flash_phy_state <= `CFI_PHY_FSM_IDLE;
      endcase
   end

/* Defaults are for 95ns access time part, 66MHz (15.15ns) system clock */
/* wlwh: cycles for WE assert to WE de-assert: write time */
parameter cfi_part_wlwh_cycles = 4; /* wlwh = 50ns, tck = 15ns, cycles = 4*/
/* elqv: cycles from adress  to data valid */
parameter cfi_part_elqv_cycles = 7; /* tsop 256mbit elqv = 95ns, tck = 15ns, cycles = 6*/

assign flash_phy_async_wait = (|flash_phy_ctr);

/* Load counter with wait times in cycles, determined by parameters. */
always @(posedge clk)
   if (rst)
      flash_phy_ctr <= 0;
   else if (flash_phy_state==`CFI_PHY_FSM_WRITE_GO)
      flash_phy_ctr <= cfi_part_wlwh_cycles - 1;
   else if (flash_phy_state==`CFI_PHY_FSM_READ_GO)
     flash_phy_ctr <= cfi_part_elqv_cycles - 2;
   else if (flash_phy_state==`CFI_PHY_FSM_RESET_GO)
     flash_phy_ctr <= 10;
   else if (|flash_phy_ctr)
      flash_phy_ctr <= flash_phy_ctr - 1;

   /* Signal to indicate when we should drive the data bus */
   wire flash_bus_write_enable;
   assign flash_bus_write_enable = (bus_control_state == `CFI_FSM_DO_WRITE) |
				   (bus_control_state == `CFI_FSM_DO_WRITE_WAIT);
   
/* Assign signals to physical bus */
assign flash_dq_io = flash_bus_write_enable ? flash_dq_o_r : 
		     {flash_dq_width{1'bz}};
assign flash_adr_o = flash_adr_r;
assign flash_adv_n_o = flash_adv_n_r;
assign flash_wp_n_o = 1'b1; /* Never write protect */
assign flash_ce_n_o = flash_ce_n_r;
assign flash_oe_n_o = flash_oe_n_r;
assign flash_we_n_o = flash_we_n_r;
assign flash_clk_o = 1'b1;
assign flash_rst_n_o = flash_rst_n_r;
endmodule // cfi_ctrl_engine


   
   