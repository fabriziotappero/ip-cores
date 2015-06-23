//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_tb.v"                               ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
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
////                                                              ////
//// This module is based on the coding method described in       ////
//// IEEE Std 802.3-2008 Clause 36 "Physical Coding Sublayer(PCS) ////
//// and Physical Medium Attachment (PMA) sublayer, type          ////
//// 1000BASE-X"; see :                                           ////
////                                                              ////
//// http://standards.ieee.org/about/get/802/802.3.html           ////
//// and                                                          ////
//// doc/802.3-2008_section3.pdf, Clause/Section 36.              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

module ge_1000baseX_tb #(
  parameter test_name = "",
  parameter quit_on_stop = 0
) ();
   
   //////////////////////////////////////////////////////////////////////
   // Clock and reset generation.
   //////////////////////////////////////////////////////////////////////
   
   localparam mdio_ck_period            = 1000ns;
   
   localparam GE_125MHz_ref_ck_period   = 8ns;

   reg 	     running;
   
   // Generate MDIO clock (MDC)
   clock_gen #(.period(mdio_ck_period)) mdio_ck_gen(.enable(running), .ck(mdc));

   // Generate 125MHz clock reference.
   clock_gen #(.period( GE_125MHz_ref_ck_period)) GE_125MHz_ref_ck_gen(.enable(running), .ck(GE_125MHz_ref_ckpin));

   
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // De-assert main reset 10 clocks after startup
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   reg 	     reset;
   
   initial
   begin
      reset = 1;
      repeat(50) @(posedge GE_125MHz_ref_ckpin);
      reset = 0;
    end

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Handle to all the virtual interfaces of the testbench models.
  ///////////////////////////////////////////////////////////////////////////////////////////////////
 
   tb_utils::VirIntfHandle h = new();

   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // 8B10B bus and PCS GMII interfaces
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   wire [9:0] tbi_rxd, tbi_txd;

   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // PCS GMII interfaces
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   wire [7:0] gmii_rxd, gmii_txd; 
   
   wire       gmii_rx_dv, gmii_rx_er, gmii_col, gmii_cs, gmii_tx_en, gmii_tx_er;

   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // Assert signal_detect a number of clocks after startup
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   wire       sync = 1'b1; reg 	      signal_detect;
   
   initial
     begin
	signal_detect = 1'b0;
	repeat(1000) @(posedge GE_125MHz_ref_ckpin);
	signal_detect = 1'b1;
     end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // Loopback on 10B TX and RX interface
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   assign tbi_rxd = tbi_txd;

   ///////////////////////////////////////////////////////////////////////////////////////////////////
   //  
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   wire       sync_en, loop_en, prbs_en;   
  
   
   ge_1000baseX_test ge_1000baseX_testi(
      
      // --- Resets ---				 
      .reset_pin(reset),
				 
      // --- 125MHz Ref clk				 
      .GE_125MHz_ref_ckpin(GE_125MHz_ref_ckpin),
      
      // --- FO TBI 125MHz Rx clk			 
      .tbi_rx_ckpin(GE_125MHz_ref_ckpin),		 
      						  
      // --- TLK1221 transmit TBI bus ---		     
      .tbi_txd(tbi_txd),
      .tbi_rxd(tbi_rxd),

      // --- Receive GMII bus --- 
      .gmii_rxd(gmii_rxd),
      .gmii_rx_dv(gmii_rx_dv),
      .gmii_rx_er(gmii_rx_er),
      .gmii_col(gmii_col),
      .gmii_cs(gmii_cs),
	
       // --- Transmit GMII bus ---		     
      .gmii_tx_en(gmii_tx_en),
      .gmii_tx_er(gmii_tx_er),
      .gmii_txd(gmii_txd),

      // --- Ctrl/status strobes --- 
      .sync_en(sync_en),
      .loop_en(loop_en),
      .prbs_en(prbs_en),
				 
      .signal_detect(signal_detect),
      .sync(sync),
				       
      // --- MDIO interface ---	      
      .mdio(mdio),
      .mdio_ckpin(mdc)			
   );
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // GMII bus tx model
   ///////////////////////////////////////////////////////////////////////////////////////////////////
  
   gmii_tx_if gmii_tx_model_if_i();
   
   gmii_tx_model #(
    .DEBUG(1)
  ) phy_gmii_tx_model_i (
    .send_intf(gmii_tx_model_if_i.model),

    .mii_txck_in(1'b0),
    .gmii_txck_in(GE_125MHz_ref_ckpin),
    .txck_out(),
    .gigabit_mode(),

    .txd(gmii_txd),
    .tx_en(gmii_tx_en),
    .tx_er(gmii_tx_er),
			     
    .crs(gmii_cs),
    .col(gmii_col)
  );
   
  initial h.gmii_tx_model = gmii_tx_model_if_i;
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // GMII bus rx model
  ///////////////////////////////////////////////////////////////////////////////////////////////////
   
  gmii_rx_if gmii_rx_model_if_i();
   
  gmii_rx_model #(
    .DEBUG(2)
  ) gmii_rx_model_i(
    .check_intf(gmii_rx_model_if_i.model),

    .mii_rxck_in(1'b0),
    .gmii_rxck_in(GE_125MHz_ref_ckpin),
    .mii_rxck_out(),

    .rxd(gmii_rxd),
    .rx_dv(gmii_rx_dv),
    .rx_er(gmii_rx_er)
  );
   
   initial h.gmii_rx_model = gmii_rx_model_if_i;

   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // mdio mdc serial interface model
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   serial_model_if serial_model_if_i();

   mdio_serial_model #(
    .PHY_ADDR(5'b00000)
  ) mdio_serial_model_i (
    .cmd_intf(serial_model_if_i.model),

    .reset(reset),  
    .mdc(mdc),
    .mdio(mdio)
  );
   
   initial h.serial_model = serial_model_if_i;

   ///////////////////////////////////////////////////////////////////////////////////////////////////
   // 8B10B 10B receive model
   ///////////////////////////////////////////////////////////////////////////////////////////////////
   
   encoder_10b_rx_if encoder_10b_rx_model_ifi();
   
   encoder_10b_rx_model #(
     .DEBUG(1) 			     
   ) encoder_10b_rx_modeli (
				   
     .check_intf(encoder_10b_rx_model_ifi.model),
 
     .reset(reset),
				   
     .SBYTECLK(GE_125MHz_ref_ckpin),
				 
     .tbi_rx(tbi_rxd)		
  );
    
   initial h.encoder_10b_rx_model = encoder_10b_rx_model_ifi;
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Test script selection and launch.
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  int errors;

  initial
    begin
      errors = 0; running = 1;

      #0;

      case(test_name)
	"ge_1000baseX_tb": ge_1000baseX_tb_script::main(h, errors);
        default:
          begin
            errors++;
            $display("%m:Unknown test '%s'", test_name);
          end
      endcase

      running = 0;

       $display("Test completed,",);
       
       if(errors)  $display("%0d errors", errors);
       else        $display("success.");

       if (quit_on_stop) $finish;
       else
         $stop;
    end

endmodule
