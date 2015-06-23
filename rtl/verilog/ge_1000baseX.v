//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX.v"                                  ////
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

`include "ge_1000baseX_regs.v"
`include "ge_1000baseX_constants.v"


module ge_1000baseX #(
  parameter PHY_ADDR = 5'b00000		   
)(		  
   // Clocks 
   input             rx_ck,
   input             tx_ck,
		     
   // Resets		 
   input             rx_reset,
   input             tx_reset,
		 
   // Startup interface
   input             startup_enable,
		 
   // Signal detect from FO transceiver 	     
   input             signal_detect,
		 	      
   //  RLK1221 receive TBI bus 
   input   [9:0]     tbi_rxd,
		 
   //  TLK1221 transmit TBI bus 
   output   [9:0]    tbi_txd,
		 
   //  Receive GMII bus 
   output      [7:0] gmii_rxd,
   output            gmii_rx_dv,  
   output            gmii_rx_er,
   output            gmii_col,
   output reg        gmii_cs,
 	       
 
   //  Transmit GMII bus  
   input   [7:0]     gmii_txd,
   input             gmii_tx_en,
   input             gmii_tx_er,
  
   input             repeater_mode,
		 
   //  MDIO interface   
   input             mdc_reset,
   inout             mdio,
   input             mdc
	  		            
  );
   
   //////////////////////////////////////////////////////////////////////////////
   // IEEE Std 802.3-2008 Clause 22 "Reconcilliation Sublayer (RS) and 
   // Media Independent Interface (MII)IEEE 802.3-2005 Clause 22 
   //////////////////////////////////////////////////////////////////////////////
   
   wire 	     mdio_in, mdio_out, mdio_oe;
   
   wire [15:0] 	     gmii_reg_wr;
   wire [15:0] 	     gmii_reg_rd;
   wire [4:0] 	     gmii_reg_addr;
   wire 	     gmii_reg_wr_strobe;
   
   ge_1000baseX_mdio #(
    .PHY_ADDR(PHY_ADDR)
   ) gmii_mdioi(
    .reset(mdc_reset),		
    .mdc(mdc), 
    .mdio(mdio_in), 
    .mdio_out(mdio_out),
    .mdio_oe(mdio_oe),

    .data_addr(gmii_reg_addr),
    .data_rd(gmii_reg_rd),
    .data_wr(gmii_reg_wr),
    .strobe_wr(gmii_reg_wr_strobe)
   );

   // MDIO tristate drivers.
   assign mdio = (mdio_oe) ? mdio_out : 1'bz;

   assign mdio_in = mdio;
   
   //////////////////////////////////////////////////////////////////////////////
   // IEEE 802.3-2008 1000BASE-X PCS OUI and version Number
   //////////////////////////////////////////////////////////////////////////////
   
   wire [23:0] 	     IEEE_OUI =  24'ha1b2c3;
   
   wire [7:0] 	     version = { 4'b0000, 4'b0001 };
   
   //////////////////////////////////////////////////////////////////////////////
   //  Aneg configuration registers
   //////////////////////////////////////////////////////////////////////////////
   
   wire [15:0] 	 tx_config_reg; wire [15:0] rx_config_reg; wire rx_config_reg_set;
   
   //////////////////////////////////////////////////////////////////////////////
   // GMII  register 0 - Basic Control - IEEE 802.3-8 1000BASE-X clause 37 page 35 
   //////////////////////////////////////////////////////////////////////////////

   reg [15:0] 	 gmii_reg_0;
   
   wire 	 mr_main_reset, mr_loopback, mr_restart_an, mr_an_enable;
     
   assign 	 mr_main_reset = gmii_reg_0[15];
   assign 	 mr_loopback   = gmii_reg_0[14];
   assign        mr_an_enable  = gmii_reg_0[12];
   assign 	 mr_restart_an = gmii_reg_0[9];
   
`ifdef MODEL_TECH
   // Register 0 bit 11 (normally power-down) used in simulation
   // to simulate fibre being inserted and removed
   //
   wire 	 signal_detect_int = (gmii_reg_0[11] & signal_detect);
`else
   wire 	 signal_detect_int = signal_detect;
`endif    
   
   //////////////////////////////////////////////////////////////////////////////
   // Safe versions of various signals in the RX clock domain
   //////////////////////////////////////////////////////////////////////////////

   reg [1:0] 	 mr_main_reset_rxc, mr_loopback_rxc,  mr_restart_an_rxc;
   reg [1:0] 	 signal_detect_rxc, mr_an_enable_rxc, startup_enable_rxc;
   
   always @(posedge rx_ck, posedge rx_reset)
    if (rx_reset) begin
       mr_main_reset_rxc <= 2'b00; mr_loopback_rxc    <= 2'b00; 
       mr_restart_an_rxc <= 2'b00; mr_an_enable_rxc   <= 2'b00;
       signal_detect_rxc <= 2'b00; startup_enable_rxc <= 2'b00;
    end
    else begin
       mr_main_reset_rxc  <= {  mr_main_reset_rxc[0], mr_main_reset     };
       mr_loopback_rxc    <= {    mr_loopback_rxc[0], mr_loopback       };
       mr_restart_an_rxc  <= {  mr_restart_an_rxc[0], mr_restart_an     };
       mr_an_enable_rxc   <= {   mr_an_enable_rxc[0], mr_an_enable      };
       signal_detect_rxc  <= {  signal_detect_rxc[0], signal_detect_int };
       startup_enable_rxc <= { startup_enable_rxc[0], startup_enable    };
    end
   
   // Speed select - when AN disabled
   wire [1:0] 	     speed_select =  {gmii_reg_0[6], gmii_reg_0[13]};


`ifdef MODEL_TECH
 `define GMII_REG_0_RESET {8'h19, 8'h40}
`else
 `define GMII_REG_0_RESET {8'h11, h40}
`endif
   
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 1 - Basic Status - IEEE 802.3-5 1000baseLX clause 37 page 36 
   //////////////////////////////////////////////////////////////////////////////
   
   wire 	     mr_an_complete, sync_status;
   
`ifdef MODEL_TECH
   // For simulation - sync_status is on gmii_reg 1 bit 7 - currently unused
   wire [15:0] 	     gmii_reg_1 = { 1'b0,        1'b0,                 1'b0,           1'b0, 
				    1'b0,        1'b0,                 1'b0,           1'b0, 
				    sync_status, 1'b1,                 mr_an_complete, 1'b0,
				    1'b1,        signal_detect_rxc[1], 1'b0,           1'b0};
`else   
   wire [15:0] 	     gmii_reg_1 = { 1'b0,        1'b0,                 1'b0,           1'b0, 
				    1'b0,        1'b0,                 1'b0,           1'b0, 
				    1'b0,        1'b1,                 mr_an_complete, 1'b0,
				    1'b1,        signal_detect_rxc[1], 1'b0,           1'b0};
`endif
   
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 2 - PHY Identifier 1 - IEEE 802.3-5 1000baseX 
   // clause 37 page 36 
   //////////////////////////////////////////////////////////////////////////////
   
   wire [15:0] 	     gmii_reg_2 = { IEEE_OUI[15:8], IEEE_OUI[23:16]};

   //////////////////////////////////////////////////////////////////////////////
   // --- GMII register 3 - PHY Identifier 2 - IEEE 802.3-5 1000baseX 
   // clause 37 page 36
   //////////////////////////////////////////////////////////////////////////////
   
   wire [15:0] 	     gmii_reg_3 = { version, IEEE_OUI[7:0] };
   
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 4 - Auto-Negotiation Advertisement - IEEE 802.3-5 1000baseX 
   // clause 37 page 37 
   //////////////////////////////////////////////////////////////////////////////
   
   reg  [15:0] 	     gmii_reg_4;

   wire [15:0] 	     mr_adv_ability;
   
   // See IEEE 802.3-5 1000baseLX clause 37 page 82 - Table 37-1 for these
   
   assign 	     mr_adv_ability = gmii_reg_4;
   
`define GMII_REG_4_RESET 16'b0000000000100000
   
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 5 - Auto-Negotiation Link Partner Ability - IEEE 802.3-5 
   // 1000baseX clause 37 page 37
   //////////////////////////////////////////////////////////////////////////////
  
   wire [15:0] 	     mr_lp_adv_ability;  
   
   wire [15:0] 	     gmii_reg_5 = mr_lp_adv_ability;
	           
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 6 - Auto-Negotiation Expansion - IEEE 802.3-5 1000baseX 
   // clause 37 page 38
   //////////////////////////////////////////////////////////////////////////////

   wire [15:0] 	     gmii_reg_6;
   
   wire		     mr_np_abl, mr_page_rx;

   assign 	     gmii_reg_6 = { 1'b0,      1'b0, 1'b0,      1'b0,
				    1'b0,      1'b0, 1'b0,      1'b0,
				    1'b0,      1'b0, 1'b0,      1'b0,
				    mr_np_abl, 1'b0, mr_page_rx,1'b0};
   
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 7 - Auto-Negotiation Link Partner Next Page - IEEE 802.3-5 
   // 1000baseX clause 37 page 38 
   //////////////////////////////////////////////////////////////////////////////
   
   reg [15:0] 	     gmii_reg_7;
   
   wire[15:0] 	     mr_np_tx;
   
   assign 	     mr_np_tx = gmii_reg_7;

`define GMII_REG_7_RESET 16'b0000000000000000
    
   //////////////////////////////////////////////////////////////////////////////
   // GMII register 8 - Auto-Negotiation Link Partner Next Page - IEEE 802.3-5 
   // 1000baseX clause 37 page 38
   //////////////////////////////////////////////////////////////////////////////
   
   wire [15:0] 	     gmii_reg_8;
   
   wire [15:0] 	     mr_lp_np_rx;
   
   assign 	     gmii_reg_8 = mr_lp_np_rx;
   
   //////////////////////////////////////////////////////////////////////////////
   // IEEE Std 802.3-2008 Clause 22 "Reconcilliation Sublayer (RS) and 
   // Media Independent Interface (MII)IEEE 802.3-2005 Clause 22 
   //////////////////////////////////////////////////////////////////////////////
   
   // Read operations
   assign gmii_reg_rd = (gmii_reg_addr == `GMII_BASIC_CTRL)       ? gmii_reg_0  :
			(gmii_reg_addr == `GMII_BASIC_STATUS)     ? gmii_reg_1  :
			(gmii_reg_addr == `GMII_PHY_ID1)          ? gmii_reg_2  :
			(gmii_reg_addr == `GMII_PHY_ID2)          ? gmii_reg_3  :
			(gmii_reg_addr == `GMII_AN_ADV)           ? gmii_reg_4  :
			(gmii_reg_addr == `GMII_AN_LP_ADV)        ? gmii_reg_5  :
			(gmii_reg_addr == `GMII_AN_EXPANSION)     ? gmii_reg_6  :
			(gmii_reg_addr == `GMII_AN_NP)            ? gmii_reg_7  :       
			(gmii_reg_addr == `GMII_AN_LP_NP)         ? gmii_reg_8  : 5'b00000;
   
   // Write operations
   always @(posedge mdc or posedge mdc_reset)
     if (mdc_reset)
       begin
	  gmii_reg_0  <= `GMII_REG_0_RESET;
	  gmii_reg_4  <= `GMII_REG_4_RESET;
	  gmii_reg_7  <= `GMII_REG_7_RESET;
       end
     else
       if (gmii_reg_wr_strobe)
	 begin
	    case (gmii_reg_addr)
	      
	      `GMII_BASIC_CTRL       : gmii_reg_0  <= gmii_reg_wr;
	      `GMII_AN_ADV           : gmii_reg_4  <= gmii_reg_wr;
	      `GMII_AN_NP            : gmii_reg_7  <= gmii_reg_wr; 
	    endcase 
	 end
       else
	 begin
	    // mr_an_restart is self clearing
	    if (gmii_reg_0[9]) gmii_reg_0[9] <= 1'b0;
	    
	    // mr_main_reset) is self clearing
	    else if (gmii_reg_0[15]) gmii_reg_0[15] <= 1'b0;
	 end 

     
   //////////////////////////////////////////////////////////////////////////////
   // Status
   //////////////////////////////////////////////////////////////////////////////
  
   wire [2:0] 	     xmit;

   wire 	     carrier_detect;
   
   wire 	     transmitting, receiving;
      
   //////////////////////////////////////////////////////////////////////////////
   //  Generate GMII Carrier Sense - IEEE 802.3-2008 Clause 36 - 26.2.5.2.5
   //////////////////////////////////////////////////////////////////////////////
   
   always @(posedge rx_ck, posedge rx_reset)
     if (rx_reset)
       gmii_cs <= 1'b0;
     else
       if      ((~repeater_mode & transmitting) | receiving)  begin gmii_cs <= 1'b1; end
   
       else if ((repeater_mode | ~transmitting) & ~receiving) begin gmii_cs <= 1'b0; end

   
   //////////////////////////////////////////////////////////////////////////////
   // delayed versions of 10b interface 
   //////////////////////////////////////////////////////////////////////////////	  
   
   reg [9:0] 	       tbi_rxd_d1, tbi_rxd_d2, tbi_rxd_d3, tbi_rxd_d4;
   
   always @(posedge rx_ck, posedge rx_reset)
     begin
	tbi_rxd_d1 <= (rx_reset) ? 0 : tbi_rxd;
	tbi_rxd_d2 <= (rx_reset) ? 0 : tbi_rxd_d1;
	tbi_rxd_d3 <= (rx_reset) ? 0 : tbi_rxd_d2;
	tbi_rxd_d4 <= (rx_reset) ? 0 : tbi_rxd_d3;
     end
    
   //////////////////////////////////////////////////////////////////////////////
   /// 8b10 decoder module
   //////////////////////////////////////////////////////////////////////////////
  
   wire 	       decoder_K, decoder_disparity_err, decoder_coding_err;
   
   wire [7:0] 	       decoder_8b_rxd;

	    
   decoder_8b10b decoder_8b10bi(
		       
      .RBYTECLK(rx_ck),
		
      .reset(rx_reset),

      // 10B input
      .tbi(tbi_rxd_d1),   
      
      // Data/special code-group ctrl 		       
      .K_out(decoder_K),

      // 8B output   
      .ebi(decoder_8b_rxd),
		       
      // Disparity error 
      .disparity_err(decoder_disparity_err),

      // Disparity output  
      .disparity(decoder_disparity_out),
      				
      // Coding error 
      .coding_err(decoder_coding_err)
   );
   
`ifdef MODEL_TECH
   wire [4:0] 	       decoder_8b_rxd_X;  
   wire [2:0] 	       decoder_8b_rxd_Y;
   
   assign {decoder_8b_rxd_Y, decoder_8b_rxd_X} = decoder_8b_rxd;
   
`endif
  
   //////////////////////////////////////////////////////////////////////////////
   // Instantiate 802.3-2005 PCS sync module - 802.3-2008 Clause 36
   //////////////////////////////////////////////////////////////////////////////  
  
   wire 	       sync_K, sync_rx_even;
   wire [7:0] 	       sync_8b_rxd;
   
`ifdef MODEL_TECH
   wire [4:0] 	       sync_8b_rxd_X = sync_8b_rxd[4:0];
   wire [2:0] 	       sync_8b_rxd_Y = sync_8b_rxd[7:5];
`endif
   
   ge_1000baseX_sync ge_1000baseX_sync_i(
			      
      .ck(rx_ck), .reset(rx_reset),

      .startup_enable(startup_enable_rxc[1]),
				
      // Signal detect from FO transceiver 	     
      .signal_detect(signal_detect_rxc[1]),
				
      // 8B input from 8b10 decoder 
      .ebi_rxd(decoder_8b_rxd),
      .ebi_K(decoder_K),	

      // 8B output from sync
      .ebi_rxd_out(sync_8b_rxd),
      .ebi_K_out(sync_K),	

       // Synchronisation status
      .sync_status(sync_status),
      
      .rx_even(sync_rx_even),	
	
      .decoder_disparity_err(decoder_disparity_err),
					 
      .decoder_coding_err(decoder_coding_err),		

      .loopback(mr_loopback_rxc[1])
   );

   //////////////////////////////////////////////////////////////////////////////
   // Carrier Detect - IEEE 802.3-2008 Section 36.2.5.1.4
   //////////////////////////////////////////////////////////////////////////////
   
   wire [5:0] 	       sb; wire [3:0] fb;

   wire 	       RDn_cd_fail_match1, RDn_cd_fail_match2, RDn_cd_fail_match;

   wire 	       RDp_cd_fail_match1, RDp_cd_fail_match2, 	RDp_cd_fail_match;      
	
   assign 	       sb[5:0] = tbi_rxd_d4[9:4];  
   
   assign 	       fb[3:0] = tbi_rxd_d4[3:0];
   
   assign 	       RDn_cd_fail_match1 = ((sb == 6'b110000) & ((fb == 4'b0101) | (fb == 4'b0100) | (fb == 4'b0111) | (fb == 4'b0001) | (fb==4'b1101)));
   
   assign 	       RDn_cd_fail_match2 = ((fb == 4'b0101) & ((sb==6'b110001) |(sb==6'b110010) | (sb==6'b110100) | (sb==6'b111000) | (sb==6'b100000) | (sb==6'b010000)));
   
   assign 	       RDn_cd_fail_match = RDn_cd_fail_match1 | RDn_cd_fail_match2;

   
   assign 	       RDp_cd_fail_match1 = ((sb == 6'b001111) & ((fb==4'b1010)|(fb==4'b1011)|(fb==4'b1000)|(fb==4'b1110)|(fb==4'b0010)));

   assign 	       RDp_cd_fail_match2 = ((fb == 4'b1010) & ((sb==6'b001110)|(sb==6'b001101)|(sb==6'b001011)|(sb==6'b000111)|(sb==6'b011111)|(sb==6'b101111)));
          
   assign 	       RDp_cd_fail_match = RDp_cd_fail_match1 | RDp_cd_fail_match2;

   assign 	       carrier_detect = sync_rx_even &  ~RDn_cd_fail_match & ~RDp_cd_fail_match;

   //////////////////////////////////////////////////////////////////////////////
   // 802.3-2008 1000baseX PCS autonegotiation (AN) module - 802.3-2008 Clause 37
   //////////////////////////////////////////////////////////////////////////////
  
   wire [2:0] 	       rudi; // RX_UNITDATA.indicate messages
   
   ge_1000baseX_an ge_1000baseX_an_i(
      
       .ck(rx_ck),.reset(rx_reset),

       .startup_enable(startup_enable_rxc[1]),			       
	
       //  Auto-negotiation ctrl 
       .xmit(xmit),
       .rx_config(rx_config_reg),
       .rx_config_set(rx_config_reg_set),			     
       .tx_config(tx_config_reg),

       // RX_UNITDATA.indicate messages		       
       .rudi(rudi),

       // Auto-negotiation /C/ and /I/ matching 		       
       .ability_match(ability_match),
       .acknowledge_match(acknowledge_match),
       .consistency_match(consistency_match),	
       .idle_match(idle_match),
			       
       // Synchronisation Status 
       .sync_status(sync_status),
       .signal_detect(signal_detect_rxc[1]),
			     
       // GMII Register 0 - AN Basic Control
       .mr_main_reset(mr_main_reset_rxc[1]),
       .mr_loopback(mr_loopback_rxc[1]),
       .mr_restart_an(mr_restart_an_rxc[1]),
       .mr_an_enable(mr_an_enable_rxc[1]),

       // GMII Register 1 - AN Basic Status		     
       .mr_an_complete(mr_an_complete),		     

       // GMII register 4 - AN Advertisement	     
       .mr_adv_ability(mr_adv_ability),
		
       // GMII register 5 - AN Link Partner Ability
       .mr_lp_adv_ability(mr_lp_adv_ability),

       // GMII register 6 - AN Expansion
       .mr_np_abl(mr_np_abl),
       .mr_page_rx(mr_page_rx),
			     
       // GMII register 7 - AN Next Page
       .mr_np_tx(mr_np_tx),
			     
       // GMII register 8 - AN Link Partner Next Page 	
       .mr_lp_np_rx(mr_lp_np_rx)
   );

   wire 	       tx_frame_pulse, frame_rx_pulse;
   
   //////////////////////////////////////////////////////////////////////////////
   // 802.3-2008 1000baseX PCS receive module - 802.3-2008 Clause 36
   //////////////////////////////////////////////////////////////////////////////
  
   ge_1000baseX_rx ge_1000base_rxi(
     			    		      
      .ck(rx_ck), .reset(rx_reset),
  
      // Receive 8B bus from sync module 
      .ebi_rxd(sync_8b_rxd),
      .ebi_K(sync_K),
			    
      .rx_even(sync_rx_even),
      .carrier_detect(carrier_detect),
      .sync_status(sync_status),
			    
      // Signal detect from FO transceiver 	     
      .signal_detect(signal_detect_rxc[1]),
      
       // Receive frame pulse	
      .rx_frame_pulse(rx_frame_pulse),
    
       // Receive GMII bus 
      .gmii_rxd(gmii_rxd),
      .gmii_rx_dv(gmii_rx_dv),
      .gmii_rx_er(gmii_rx_er),
    		      
       // Auto-negotiation ctrl 
       .xmit(xmit),  
       .mr_main_reset(mr_main_reset_rxc[1]),
       .rx_config(rx_config_reg),
       .rx_config_set(rx_config_reg_set),		    
       .rudi(rudi),
			      
       // Auto-negotiation /C/ and /I/ matching 		      
       .ability_match(ability_match),
       .acknowledge_match(acknowledge_match),
       .consistency_match(consistency_match),	
       .idle_match(idle_match),
	
       .receiving(receiving)	      
   );
     
   //////////////////////////////////////////////////////////////////////////////
   //  Safe versions of various signals in the TX clock domain
   //////////////////////////////////////////////////////////////////////////////
   
   reg [1:0] mr_main_reset_txc, receiving_txc, signal_detect_txc, startup_enable_txc;
     
   always @(posedge tx_ck, posedge tx_reset)
     if (tx_reset) begin
	
	mr_main_reset_txc <= 2'b00; receiving_txc      <= 2'b00; 
	signal_detect_txc <= 2'b00; startup_enable_txc <= 2'b00;
     end
     else
       begin
	  mr_main_reset_txc  <= {  mr_main_reset_txc[0], mr_main_reset  };
	  receiving_txc      <= {      receiving_txc[0], receiving      };
	  signal_detect_txc  <= {  signal_detect_txc[0], signal_detect  };
	  startup_enable_txc <= { startup_enable_txc[0], startup_enable };
       end
   
   reg [2:0] xmit_txc, xmit_txc0;
   
   always @(posedge tx_ck, posedge tx_reset)
     begin
	xmit_txc <= (tx_reset) ? `XMIT_IDLE :  xmit_txc0;
	
	xmit_txc0 <= (tx_reset) ? `XMIT_IDLE : xmit;
     end
   
   //////////////////////////////////////////////////////////////////////////////
   // 802.3-2008 1000baseX PCS transmit module  802.3-2008 Clause 36
   //////////////////////////////////////////////////////////////////////////////
   
   ge_1000baseX_tx ge_1000baseX_txi(
			        			    
      // --- TX clock and reset ---	      
      .ck(tx_ck),
      .reset(tx_reset),

       // --- RLK1221 transmit TBI bus ---		       
      .tbi_txd(tbi_txd),
			    
      .signal_detect(signal_detect_txc[1]),
 			    
       // Transmit frame pulse	
      .tx_frame_pulse(tx_frame_pulse),
			    
       // --- Transmit GMII bus - 
      .gmii_tx_en_in(gmii_tx_en),
      .gmii_tx_er_in(gmii_tx_er),
      .gmii_txd_in(gmii_txd),
      
      .gmii_col(gmii_col),
			    
      .receiving(receiving_txc[1]),	        
      .transmitting(transmitting),
			    		    
       // --- Auto-negotiation ctrl ---
      .xmit(xmit_txc),
      .tx_config(tx_config_reg),		
      .mr_main_reset(mr_main_reset_txc[1])
   );

   //////////////////////////////////////////////////////////////////////////////
   // Frame transmit LED pulse
   //////////////////////////////////////////////////////////////////////////////
   
   reg [23:0] 	       tx_led_counter;
   reg 		       tx_frame_pulse_latch, tx_frame_activity;
   
   always @(posedge tx_ck, posedge tx_reset)

     if (tx_reset)
       begin
	  tx_led_counter <= 0; tx_frame_activity <= 0;  tx_frame_pulse_latch <= 1;
       end
     else
       begin
	  tx_led_counter <= tx_led_counter + 1;
	  
	  if (tx_frame_activity)
	    begin
	       if (~tx_led_counter[23]) begin tx_frame_pulse_latch <= 0;tx_frame_activity <= 0; end
	    end
	  else if (tx_led_counter[23] & tx_frame_pulse_latch) tx_frame_activity <= 1;
	  
	  else if (tx_frame_pulse) tx_frame_pulse_latch <= 1;
       end 

   //////////////////////////////////////////////////////////////////////////////
   // Frame receive LED pulse
   //////////////////////////////////////////////////////////////////////////////
   
   reg [23:0] 	       rx_led_counter;
   reg 		       rx_frame_pulse_latch, rx_frame_activity;
   
   always @(posedge rx_ck, posedge rx_reset)

     if (rx_reset)
       begin
	  rx_led_counter <= 0; rx_frame_activity <= 0;  rx_frame_pulse_latch <= 1;
       end
     else
       begin
	  rx_led_counter <= rx_led_counter + 1;
	  
	  if (rx_frame_activity)
	    begin
	       if (~rx_led_counter[23]) begin rx_frame_pulse_latch <= 0;rx_frame_activity <= 0; end
	    end
	  else if (rx_led_counter[23] & rx_frame_pulse_latch) rx_frame_activity <= 1;
	  
	  else if (rx_frame_pulse) rx_frame_pulse_latch <= 1;
       end 

   
   wire fo_activity = rx_frame_activity | tx_frame_activity;
   
endmodule
