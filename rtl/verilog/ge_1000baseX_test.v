//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_test.v"                            ////
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

`include "timescale.v"

module ge_1000baseX_test
(
  // --- Resets ---
  input            reset_pin,

  // --- GE 125MHz reference clock ---
  input             GE_125MHz_ref_ckpin,
 
  // --- FO TBI 125MHz Rx clk --- 
  input             tbi_rx_ckpin,
 
  // --- Fibre-Optic (fo) GE TBI Interface ---
  input       [9:0] tbi_rxd,
  output      [9:0] tbi_txd,

 // --- GMII interface ---
  output      [7:0] gmii_rxd,
  output            gmii_rx_dv, 
  output            gmii_rx_er, 
  output            gmii_col, 
  output            gmii_cs,
 
  input       [7:0] gmii_txd,
  input             gmii_tx_en, 
  input             gmii_tx_er,
 
 //  --- Fibre-Optic (fo) ctrl signals ---
  output            sync_en,
  output            loop_en,
  output            prbs_en,
 
  input             signal_detect,
  input             sync,
  
 // --- MDIO interface
  inout             mdio,
  input             mdio_ckpin
 );
   
   assign   sync_en = 1'b0;
   assign   loop_en = 1'b0;
   assign   prbs_en = 1'b0;

   
   //----------------------------------------------------------------------------
   // MDIO/MDC clock buffering
   //----------------------------------------------------------------------------
   
   IBUFG mdio_ckpin_bufi(.I(mdio_ckpin), .O(mdio_ckpin_buf));

   BUFG mdio_ck_bufi(.I(mdio_ckpin_buf), .O(mdc));
   
   //----------------------------------------------------------------------------
   // GE 125MHz reference clock
   //----------------------------------------------------------------------------
   
   IBUFG GE_125MHz_ref_ckpin_bufi(.I(GE_125MHz_ref_ckpin), .O(GE_125MHz_ref_ckpin_buf));

   wire GE_125MHz_ref_ck_locked;
   
   DCM #(
    .CLKIN_PERIOD(8.0),         // Specify period of input clock in ns
    .CLKFX_MULTIPLY(5),
    .CLKFX_DIVIDE(8)            
   ) GE_125MHz_ref_ck_DCMi(
    .CLK0(GE_125MHz_ref_ck_unbuf),			   
    .CLK180(),
    .CLK270(),
    .CLK2X(),
    .CLK2X180(),
    .CLK90(),
    .CLKDV(),
    .CLKFX(),
    .CLKFX180(),
    .LOCKED(GE_125MHz_ref_ck_locked),
    .PSDONE(),
    .STATUS(),
    .CLKFB(GE_125MHz_ref_ck),			   
    .CLKIN(GE_125MHz_ref_ckpin_buf),
    .DSSEN(1'b0),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .RST(reset_pin)
  );

   //----------------------------------------------------------------------------
   // 125MHz refence clock
   //----------------------------------------------------------------------------
`ifdef MODEL_TECH  
    BUFG GE_125MHz_ref_ck_bufi(.I(GE_125MHz_ref_ck_unbuf), .O(GE_125MHz_ref_ck));
`else
    BUFGMUX GE_125MHz_ref_ck_bufi(.I1(GE_125MHz_ref_ck_unbuf), .O(GE_125MHz_ref_ck), .S(1'b1));
`endif
     
   //----------------------------------------------------------------------------
   // Fibre-Optic (FO) TBI RX clock.
   //----------------------------------------------------------------------------
   
   IBUFG tbi_rx_ckpin_bufi(.I(tbi_rx_ckpin), .O(tbi_rx_ckpin_buf));
   
   DCM #(
    .CLKIN_PERIOD(8.0)         
   ) tbi_rx_ck_DCMi(
    .CLK0(tbi_rx_ck_unbuf),	       
    .CLK180(),
    .CLK270(),
    .CLK2X(),
    .CLK2X180(),
    .CLK90(),
    .CLKDV(),		       
    .CLKFX(),
    .CLKFX180(),
    .LOCKED(tbi_rx_ck_locked),
    .PSDONE(),
    .STATUS(),
    .CLKFB(tbi_rx_ck),		       
    .CLKIN(tbi_rx_ckpin_buf),
    .DSSEN(1'b0),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .RST(reset_pin)
  );	
   
   // FO TBI 125MHz rx clock
   BUFG tbi_rx_ck_bufi( .I(tbi_rx_ck_unbuf), .O(tbi_rx_ck));		   
	        
   //----------------------------------------------------------------------------
   // Reset Cleaners
   //----------------------------------------------------------------------------
   
   wire  main_clocks_locked =  GE_125MHz_ref_ck_locked;
   
   wire  tbi_rxck_reset_in  = reset_pin | ~main_clocks_locked;
   wire  GE_125MHz_reset_in = reset_pin | ~main_clocks_locked;
   wire  mdc_reset_in       = reset_pin | ~main_clocks_locked;
   
   wire  GE_125MHz_reset, tbi_rx_reset;

   clean_rst GE_125MHz_reset_cleaneri(.clk(GE_125MHz_ref_ck), .rsti(GE_125MHz_reset_in), .rsto(GE_125MHz_reset));
   clean_rst tbi_rx_reset_cleaneri(   .clk(tbi_rx_ck),        .rsti(tbi_rxck_reset_in),  .rsto(tbi_rx_reset));
   clean_rst mdc_reset_cleaneri(      .clk(mdc),              .rsti(mdc_reset_in),       .rsto(mdc_reset));
 
   //-------------------------------------------------------------------------------
   // --- IEEE 802.3-2008 1000baseX PCS ---
   //-------------------------------------------------------------------------------

   ge_1000baseX ge_1000baseX_i(
    
      // --- Clocks ---
      .rx_ck(tbi_rx_ck), .tx_ck(GE_125MHz_ref_ck), 
    		   
      // --- resets --- 
      .tx_reset(GE_125MHz_reset), .rx_reset(tbi_rx_reset), 	       
			  
      // --- Startup interface. ---
      .startup_enable(~GE_125MHz_reset),

       // --- Signal detect from FO transceiver 
      .signal_detect(signal_detect),
			
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
  
      // --- Receive 8B10B bus ---
      .tbi_rxd(tbi_rxd),		      
      // --- Transmit 8B10B bus ---		     
      .tbi_txd(tbi_txd),
      
      // --- Mode of operation ---
      .repeater_mode(1'b0),
		      
      // --- MDIO interface ---
      .mdc_reset(mdc_reset), 	      
      .mdc(mdc),
      .mdio(mdio)/* synthesis xc_pullup = 1 */
   );
   
   
endmodule


