`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
//// 																					////
//// MODULE NAME: testbech for management module   					////
//// 																					////
//// DESCRIPTION: Test Read & Write Internal Registers. Test MDIO ////
////              signals, including Read & Write                 ////
////																					////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/						////
////																					////
//// AUTHOR(S):																	////
//// Zheng Cao			                                             ////
////							                                    		////
//////////////////////////////////////////////////////////////////////
////																					////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.			   ////
////																					////
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
//// from http://www.opencores.org/lgpl.shtml   						////
////																					////
//////////////////////////////////////////////////////////////////////
//
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2006/06/06 05:09:46  fisher5090
// no message
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

module manage_tst_v;

	// Inputs
	reg mgmt_clk;
	reg rxclk;
	reg txclk;
	reg [1:0] mgmt_opcode;
	reg [9:0] mgmt_addr;
	reg [31:0] mgmt_wr_data;
	reg mgmt_miim_sel;
	reg mgmt_req;
	reg [18:0] rxStatRegPlus;
	reg [14:0] txStatRegPlus;
	reg reset;

	// Outputs
	wire [31:0] mgmt_rd_data;
	wire mgmt_miim_rdy;
	wire [52:0] cfgRxRegData;
	wire [9:0] cfgTxRegData;
	wire mdc;
	wire mdio;
	
	// Management configuration register address (0x340)
	reg [8:0] CONFIG_MANAGEMENT_ADD;
  
   // Flow control configuration register address (0x2C0)
   reg [8:0] CONFIG_FLOW_CTRL_ADD;
  
   // Reconciliation sublayer configuration register address (0x300)
	reg [8:0] CONFIG_RECONCILIATION_ADD;
  
   // Receiver configuration register address (0x200)
   reg [8:0] RECEIVER_ADD0;
  
   // Receiver configuration register address (0x240)
   reg [8:0] RECEIVER_ADD1;

   // Transmitter configuration register address	(0x280)
   reg [8:0] TRANSMITTER_ADD;



  // Set up constants values....
  initial
  begin

    // Management configuration register address (0x340)
    CONFIG_MANAGEMENT_ADD = 9'b101000000;
    
	 // Reconciliation sublayer configuration register address (0x300)
    CONFIG_RECONCILIATION_ADD = 9'b100000000;
  
    // Flow control configuration register address (0x2C0)
    CONFIG_FLOW_CTRL_ADD  = 9'b011000000;
  
    // Receiver configuration register address (0x200)
	 RECEIVER_ADD0 = 9'b000000000;
    // Receiver configuration register address	(0x240)
    RECEIVER_ADD1 = 9'b001000000;

    // Transmitter configuration register address	(0x280)
    TRANSMITTER_ADD = 9'b010000000;

  end
  
	management_top uut (
		.mgmt_clk(mgmt_clk), 
		.rxclk(rxclk), 
		.txclk(txclk), 
		.mgmt_opcode(mgmt_opcode), 
		.mgmt_addr(mgmt_addr), 
		.mgmt_wr_data(mgmt_wr_data), 
		.mgmt_rd_data(mgmt_rd_data), 
		.mgmt_miim_sel(mgmt_miim_sel), 
		.mgmt_req(mgmt_req), 
		.mgmt_miim_rdy(mgmt_miim_rdy), 
		.rxStatRegPlus(rxStatRegPlus), 
		.txStatRegPlus(txStatRegPlus), 
		.cfgRxRegData(cfgRxRegData), 
		.cfgTxRegData(cfgTxRegData), 
		.mdc(mdc), 
		.mdio(mdio),
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		rxclk = 0;
		txclk = 0;
		rxStatRegPlus = 0;
		txStatRegPlus = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 0;  
		// Add stimulus here

	end
	
  initial                 // drives mgmt_clk
  begin
    mgmt_clk <= 1'b0;
	#2000;
    forever
    begin	 
      mgmt_clk <= 1'b0;
      #12000;
      mgmt_clk <= 1'b1;
      #12000;
    end
  end
  
  initial
  begin : p_management  
    integer I;
    mgmt_req       <= 1'b0;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;
    mgmt_addr      <= 32'h0;
    mgmt_wr_data   <= 32'h0;

    // reset the core
    $display("** Note: Resetting core...");
      
    reset <= 1'b1;
    #210000
    reset <= 1'b0;
    #500000

    //------------------------------------------------------------------
    // set up MDC frequency. Write 2E to Management configuration  
    // (register Add=340). This will enable MDIO and set MDC to 2.3 MHz
    //------------------------------------------------------------------
    $display("** Note: Setting MDC Frequency to 2.3MHZ....");

    // set CLOCK_DIVIDE value to 9 dec. for 41.66. MHz mgmt_CLK and enable MDIO
    @(negedge mgmt_clk)
    mgmt_addr[9]   <= 1'b1;
    mgmt_addr[8:0] <= CONFIG_MANAGEMENT_ADD;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b01;
    mgmt_wr_data   <= 32'b00000000000000000000000000101001;

    //------------------------------------------------------------------
    // Reading Management Configuration Register (Add=340).  
    //------------------------------------------------------------------
    $display("** Note: Reading Management Configuration  Register....");

    // Read from management configuration register
    @(negedge mgmt_clk)
    mgmt_addr[9]   <= 1'b1;
    mgmt_addr[8:0] <= CONFIG_MANAGEMENT_ADD;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;

    //------------------------------------------------------------------
    // Disable Flow Control. Set top 3 bits of the flow control 
    // configuration register (Add=2C0) to zero therefore disabling tx 
    // and rx flow control. 
    //------------------------------------------------------------------
    $display("** Note: Disabling tx and rx flow control...");

    // Turn off flow control by writing relevant bits into the register    
    @(negedge mgmt_clk)
    mgmt_addr[9]   <= 1'b1;
    mgmt_addr[8:0] <= CONFIG_FLOW_CTRL_ADD;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b01;
    mgmt_wr_data   <= 32'b00000000000000000000001100000000;

    //------------------------------------------------------------------
    // Reading Flow Control Configuration Register (Add=2C0).  
    //------------------------------------------------------------------
    $display("** Note: Reading Flow Control Configuration  Register....");

    // Read from flow control register
    @(negedge mgmt_clk)
    mgmt_addr[9]   <= 1'b1;
    mgmt_addr[8:0] <= CONFIG_RECONCILIATION_ADD;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;
	 
	 // Read from statistics register 0
    @(negedge mgmt_clk)
	 mgmt_req <= 1'b1;
    mgmt_addr[9]   <= 1'b0;
    mgmt_addr[8:0] <= 0;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;
	 
	 
	 @(negedge mgmt_clk)
	 mgmt_req <= 1'b0;
    mgmt_addr[9]   <= 1'b0;
    mgmt_addr[8:0] <= 1;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;
	 
	 // Read from statistics register 1
	 @(negedge mgmt_clk)
	 mgmt_req <= 1'b1;
    mgmt_addr[9]   <= 1'b0;
    mgmt_addr[8:0] <= 1;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;
	 
	 @(negedge mgmt_clk)
	 mgmt_req <= 1'b0;
    mgmt_addr[9]   <= 1'b0;
    mgmt_addr[8:0] <= 1;
    mgmt_miim_sel  <= 1'b0;
    mgmt_opcode    <= 2'b11;
	 
	 // MDIO WRITE
    @(negedge mgmt_clk)
	 mgmt_req <= 1'b1;
    mgmt_addr[9]   <= 1'b1;
    mgmt_addr[8:0] <= CONFIG_FLOW_CTRL_ADD;
    mgmt_miim_sel  <= 1'b1;
    mgmt_opcode    <= 2'b01; 
	 mgmt_wr_data   <= 32'b00000000000000000000001100110000;
	 #50000
	 @(negedge mgmt_clk)
	 mgmt_req <= 1'b0;
    wait (mgmt_miim_rdy ==1'b1);
	 #50000
	 
    // MDIO READ
    @(negedge mgmt_clk)
	 mgmt_req <= 1'b1;
    mgmt_addr[9]   <= 1'b1;
    mgmt_addr[8:0] <= CONFIG_FLOW_CTRL_ADD;
    mgmt_miim_sel  <= 1'b1;
    mgmt_opcode    <= 2'b10; 
	 mgmt_wr_data   <= 32'b00000000000000000000001100110000;

	 @(negedge mgmt_clk)
	 mgmt_req <= 1'b0;
	
    #100000
    // test process here is done
    $display("** failure: Simulation Stopped");
    $stop;

  end 

      
endmodule

