//////////////////////////////////////////////////////////////////////
////                                                              ////
////                                                              ////
////  This file is part of the USB2UART  project                  ////
////  http://www.opencores.org/cores/usb2uart/                    ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
//   Version  :0.1 -                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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


`timescale 1ns/10ps

`include "usb1_defines.v"
module tb;

wire  usb_txoe,usb_txdp,usb_txdn;

wire dpls = (usb_txoe == 1'b0) ? usb_txdp : 1'bz;
wire dmns = (usb_txoe == 1'b0) ? usb_txdn : 1'bz;

pullup(dpls); // Full Speed Device Indication
//pulldown(dmns);

parameter  SYS_BP_PER = 2.5;       
parameter  USB_BP_PER = 10.4167;       
reg sys_clk,resetn;
reg usb_48mhz_clk;

//-----------------------------------
// Register Interface
// ----------------------------------
wire [31:0]   reg_addr;   // Register Address
wire	      reg_rdwrn;  // 0 -> write, 1-> read
wire	      reg_req;    //  Register Req
wire [31:0]   reg_wdata;  // Register write data
reg   [31:0]  reg_rdata;  // Register Read Data
reg 	      reg_ack;    // Register Ack

always begin
     #SYS_BP_PER     sys_clk <= 1'b0;
     #SYS_BP_PER     sys_clk <= 1'b1;
end

always begin
     #USB_BP_PER     usb_48mhz_clk <= 1'b0;
     #USB_BP_PER     usb_48mhz_clk <= 1'b1;
end

wire usb_rxd = ((dpls == 1) && (dmns == 0)) ? 1'b1:
	       ((dpls == 0) && (dmns == 1)) ? 1'b0: 1'b0;

core dut(
	.clk_i      (usb_48mhz_clk), 
	.rst_i      (resetn),

		// USB PHY Interface
	.usb_txdp   (usb_txdp), 
	.usb_txdn   (usb_txdn), 
	.usb_txoe   (usb_txoe),
	.usb_rxd    (usb_rxd), 
	.usb_rxdp   (dpls), 
	.usb_rxdn   (dmns),

	// USB Misc
	.phy_tx_mode(1'b1), 
        .usb_rst(),

	// Interrupts
	.dropped_frame(), 
	.misaligned_frame(),
	.crc16_err(),

	// Vendor Features
	.v_set_int(), 
	.v_set_feature(), 
	.wValue(),
	.wIndex(), 
	.vendor_data(),

	// USB Status
	.usb_busy(), 
	.ep_sel(),

	// End point 1 configuration
	.ep1_cfg(	`ISO  | `IN  | 14'd0256		),
	// End point 1 'OUT' FIFO i/f
	.ep1_dout(					),
	.ep1_we(					),
	.ep1_full(		1'b0			),
	// End point 1 'IN' FIFO i/f
	.ep1_din(		8'h0		        ),
	.ep1_re(		   		        ),
	.ep1_empty(		1'b0     		),
	.ep1_bf_en(		1'b0			),
	.ep1_bf_size(		7'h0			),

	// End point 2 configuration
	.ep2_cfg(	`ISO  | `OUT | 14'd0256		),
	// End point 2 'OUT' FIFO i/f
	.ep2_dout(				        ),
	.ep2_we(				        ),
	.ep2_full(		1'b0     		),
	// End point 2 'IN' FIFO i/f
	.ep2_din(		8'h0			),
	.ep2_re(					),
	.ep2_empty(		1'b0			),
	.ep2_bf_en(		1'b0			),
	.ep2_bf_size(		7'h0			),

	// End point 3 configuration
	.ep3_cfg(	`BULK | `IN  | 14'd064		),
	// End point 3 'OUT' FIFO i/f
	.ep3_dout(					),
	.ep3_we(					),
	.ep3_full(		1'b0			),
	// End point 3 'IN' FIFO i/f
	.ep3_din(		8'h0      		),
	.ep3_re(		        		),
	.ep3_empty(		1'b0    		),
	.ep3_bf_en(		1'b0			),
	.ep3_bf_size(		7'h0			),

	// End point 4 configuration
	.ep4_cfg(	`BULK | `OUT | 14'd064		),
	// End point 4 'OUT' FIFO i/f
	.ep4_dout(		        		),
	.ep4_we(		        		),
	.ep4_full(		1'b0     		),
	// End point 4 'IN' FIFO i/f
	.ep4_din(		8'h0			),
	.ep4_re(					),
	.ep4_empty(		1'b0			),
	.ep4_bf_en(		1'b0			),
	.ep4_bf_size(		7'h0			),

	// End point 5 configuration
	.ep5_cfg(	`INT  | `IN  | 14'd064		),
	// End point 5 'OUT' FIFO i/f
	.ep5_dout(					),
	.ep5_we(					),
	.ep5_full(		1'b0			),
	// End point 5 'IN' FIFO i/f
	.ep5_din(		8'h0     		),
	.ep5_re(				        ),
	.ep5_empty(		1'b0     		),
	.ep5_bf_en(		1'b0			),
	.ep5_bf_size(		7'h0			),

	// End point 6 configuration
	.ep6_cfg(		14'h00			),
	// End point 6 'OUT' FIFO i/f
	.ep6_dout(					),
	.ep6_we(					),
	.ep6_full(		1'b0			),
	// End point 6 'IN' FIFO i/f
	.ep6_din(		8'h0			),
	.ep6_re(					),
	.ep6_empty(		1'b0			),
	.ep6_bf_en(		1'b0			),
	.ep6_bf_size(		7'h0			),

	// End point 7 configuration
	.ep7_cfg(		14'h00			),
	// End point 7 'OUT' FIFO i/f
	.ep7_dout(					),
	.ep7_we(					),
	.ep7_full(		1'b0			),
	// End point 7 'IN' FIFO i/f
	.ep7_din(		8'h0			),
	.ep7_re(					),
	.ep7_empty(		1'b0			),
	.ep7_bf_en(		1'b0			),
	.ep7_bf_size(		7'h0			),

        // Uart Line Interface
	.uart_txd     (uart_txd),
	.uart_rxd    (uart_rxd)

	); 		



usb_agent u_usb_agent(
        .dpls       (dpls),
        .dmns       (dmns)
       );

uart_agent u_uart_agent(
	.test_clk (usb_48mhz_clk),
	.sin     (uart_rxd),
	.sout    (uart_txd)
     );
test_control test_control();

always @(posedge usb_48mhz_clk)
	reg_ack <= reg_req;

always @(posedge usb_48mhz_clk)
	if(reg_req)
	    reg_rdata <= reg_wdata;



initial
begin
	resetn = 1;
	#100 resetn = 0;
	#100 resetn = 1;
	#1000
	//usb_test1;
	//usb_test2;
	usb_test3;
	
	$finish;
end

`include "usb_test1.v"
`include "usb_test2.v"
`include "usb_test3.v"
endmodule
