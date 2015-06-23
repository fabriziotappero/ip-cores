//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_rx.v"                               ////
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

module ge_1000baseX_rx(
		       
   // Receive clock and reset 
   input               ck,
   input               reset,
		      
   // Receive 8B bus from 8b10 decoder 
   input [7:0] 	       ebi_rxd,	  
 
   input               ebi_K,
   input               rx_even,
   input               carrier_detect,
		   
   // Receive sync status 
   input              sync_status, 
   input              signal_detect,

   // Frame receive pulse	
   output              rx_frame_pulse,
	   
   // Receive GMII bus 
   output reg  [7:0]   gmii_rxd,
   output reg          gmii_rx_dv,  
   output reg          gmii_rx_er,
  
   output reg          receiving,

   // Auto-negotiation ctrl 
   input      [2:0]    xmit,
   output reg [15:0]   rx_config,
   output reg          rx_config_set,		   
   input               mr_main_reset,
   output reg [2:0]    rudi,

   output reg          ability_match,
   output reg          acknowledge_match,
		   
   output              consistency_match,
   output              idle_match
);
   
   //////////////////////////////////////////////////////////////////////////////
   //  Diagnostics registers
   //////////////////////////////////////////////////////////////////////////////
   
`define RX_FRAME_CNT            16'h0000
`define RX_DATA_CNT             16'h0001         
`define EARLY_END_CNT           16'h0002          
`define CHECK_END_T_R_K28_5_CNT 16'h0003
`define CHECK_END_R_R_K28_5_CNT 16'h0004
`define CHECK_END_T_R_R_CNT     16'h0005    
`define CHECK_END_R_R_R_CNT     16'h0006     
`define CHECK_END_R_R_S_CNT     16'h0007
`define RESET                   16'hffff 
   
   reg [7:0] 	       ge_x_pcs_rx_stats_inc;

   reg [15:0] 	       rx_frame_cnt;
   reg [15:0] 	       rx_data_cnt;
   reg [15:0] 	       early_end_cnt;
   reg [15:0] 	       check_end_T_R_K28_5_cnt;
   reg [15:0] 	       check_end_R_R_K28_5_cnt;
   reg [15:0] 	       check_end_T_R_R_cnt;
   reg [15:0] 	       check_end_R_R_R_cnt;
   reg [15:0] 	       check_end_R_R_S_cnt;
   
   always @(posedge ck, posedge reset)
     
     if (reset) 
       begin
	  rx_frame_cnt            <= 0; rx_data_cnt             <= 0;
	  early_end_cnt           <= 0; check_end_T_R_K28_5_cnt <= 0;
	  check_end_R_R_K28_5_cnt <= 0; check_end_T_R_R_cnt     <= 0;
	  check_end_R_R_R_cnt     <= 0; check_end_R_R_S_cnt     <= 0;
       end 
     else
       begin
	  if      (ge_x_pcs_rx_stats_inc[0]) rx_frame_cnt            <= rx_frame_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[1]) rx_data_cnt             <= rx_data_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[2]) early_end_cnt           <= early_end_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[3]) check_end_T_R_K28_5_cnt <= check_end_T_R_K28_5_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[4]) check_end_R_R_K28_5_cnt <= check_end_R_R_K28_5_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[5]) check_end_T_R_R_cnt     <= check_end_T_R_R_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[6]) check_end_R_R_R_cnt     <= check_end_R_R_R_cnt + 1;
	  else if (ge_x_pcs_rx_stats_inc[7]) check_end_R_R_S_cnt     <= check_end_R_R_S_cnt + 1;
       end

   //////////////////////////////////////////////////////////////////////////////
   //
   ////////////////////////////////////////////////////////////////////////////// 
   
   assign 	     rx_frame_pulse = ge_x_pcs_rx_stats_inc[0];
   
   //////////////////////////////////////////////////////////////////////////////
   // Soft reset
   //////////////////////////////////////////////////////////////////////////////  

   reg 		     soft_reset;
   
   always @(posedge ck, posedge reset)
     if (reset)
       soft_reset <= 0;
     else
       soft_reset <= mr_main_reset;

   //////////////////////////////////////////////////////////////////////////////
   // When Decoding EPDs (End_Of_Packet Delimiter) the RX state machine needs
   // to compare the current code-group to the two code-groups that follow it.
   //////////////////////////////////////////////////////////////////////////////   
  
   reg [7:0] 	       ebi_rxd_d1;
   reg [7:0] 	       ebi_rxd_d2;
   reg [7:0] 	       ebi_rxd_d3;
   
   reg 		       ebi_K_d1,          ebi_K_d2,          ebi_K_d3;  
   reg 		       rx_even_d1,        rx_even_d2,        rx_even_d3;
   reg 		       sync_status_d1,    sync_status_d2,    sync_status_d3; 		       
   reg 		       carrier_detect_d1, carrier_detect_d2, carrier_detect_d3;

   always @(posedge ck, posedge reset)
     if (reset)
       begin
	  ebi_K_d1          <= 0; ebi_K_d2          <= 0; ebi_K_d3          <= 0; 
	  rx_even_d1        <= 0; rx_even_d2        <= 0; rx_even_d3        <= 0;
	  ebi_rxd_d1        <= 0; ebi_rxd_d2        <= 0; ebi_rxd_d3        <= 0;
	  sync_status_d1    <= 0; sync_status_d2    <= 0; sync_status_d3    <= 0;
	  carrier_detect_d1 <= 0; carrier_detect_d2 <= 0; carrier_detect_d3 <= 0;
       end
     else
       begin 	  
	  ebi_K_d3          <= ebi_K_d2;           ebi_K_d2          <= ebi_K_d1;          ebi_K_d1          <= ebi_K; 
	  rx_even_d3        <= rx_even_d2;         rx_even_d2        <= rx_even_d1;        rx_even_d1        <= rx_even;
	  ebi_rxd_d3        <= ebi_rxd_d2;         ebi_rxd_d2        <= ebi_rxd_d1;        ebi_rxd_d1        <= ebi_rxd;
	  sync_status_d3    <= sync_status_d2;     sync_status_d2    <= sync_status_d1;    sync_status_d1    <= sync_status;
	  carrier_detect_d3 <= carrier_detect_d2;  carrier_detect_d2 <= carrier_detect_d1; carrier_detect_d1 <= carrier_detect;
       end
   

`ifdef MODEL_TECH
   wire [4:0] ebi_rxd_d1_X;  wire [2:0] ebi_rxd_d1_Y;
   wire [4:0] ebi_rxd_d2_X;  wire [2:0] ebi_rxd_d2_Y;
   wire [4:0] ebi_rxd_d3_X;  wire [2:0] ebi_rxd_d3_Y;

   assign {ebi_rxd_d1_Y, ebi_rxd_d1_X} = ebi_rxd_d1;
   assign {ebi_rxd_d2_Y, ebi_rxd_d2_X} = ebi_rxd_d2;
   assign {ebi_rxd_d3_Y, ebi_rxd_d3_X} = ebi_rxd_d3;
`endif    
   
   //////////////////////////////////////////////////////////////////////////////
   // Decode EARLY_END EPD code sequence
   //////////////////////////////////////////////////////////////////////////////   
  
   wire       early_end_idle;
   
   // Received code-group sequence K28.5/D/K28.5  
   assign     early_end_idle =  (ebi_K_d2  & ebi_rxd_d2 == `K28_5_symbol) & 
			       ~(ebi_K_d1) & 
			        (ebi_K     & ebi_rxd    == `K28_5_symbol);

   wire       early_end_config;
   
   // Received code-group sequence K28.5/(D21.5 | D2.2)/D0.0
   assign     early_end_config  = (( ebi_K_d2 &  ebi_rxd_d2  == `K28_5_symbol) & 
				   (~ebi_K_d1 & (ebi_rxd_d1  == `D21_5_symbol | ebi_rxd_d1 == `D2_2_symbol)) & 
				   (~ebi_K    &  ebi_rxd     == `D0_0_symbol));
   
   // EARLY_END state in 802.3-2008 Clause 36 Figure 36-7b
   reg 	      early_end;

   always @(posedge ck, posedge reset)
     if (reset)
       early_end <= 0;
     else
       early_end <= (early_end_idle | early_end_config) & rx_even;
   
   //////////////////////////////////////////////////////////////////////////////
   //  Decode /T/R/K28_5/ EPD code sequence
   //////////////////////////////////////////////////////////////////////////////   
 
   reg 	      check_end_T_R_K28_5;

   always @(posedge ck, posedge reset)
     if (reset)
       check_end_T_R_K28_5 <= 0;
     else 
       check_end_T_R_K28_5 <= ((ebi_K_d2 & ebi_rxd_d2  == `K29_7_symbol)  &
			       (ebi_K_d1 & ebi_rxd_d1  == `K23_7_symbol)  &
			       (ebi_K    & ebi_rxd     == `K28_5_symbol)  & rx_even);
   
   //////////////////////////////////////////////////////////////////////////////
   // Decode /T/R/R/ EPD code sequence
   //////////////////////////////////////////////////////////////////////////////  
  
   reg 	      check_end_T_R_R;
   
   always @(posedge ck, posedge reset)
     if (reset)
       check_end_T_R_R <= 0;
     else 
       check_end_T_R_R <= ((ebi_K_d2 & ebi_rxd_d2  == `K29_7_symbol) &
			   (ebi_K_d1 & ebi_rxd_d1  == `K23_7_symbol)  &
			   (ebi_K    & ebi_rxd     == `K23_7_symbol));
   
   //////////////////////////////////////////////////////////////////////////////
   // Decode /R/R/R EPD code sequence
   //////////////////////////////////////////////////////////////////////////////
   
   reg 	      check_end_R_R_R;
   
   always @(posedge ck, posedge reset)
     if (reset)
       check_end_R_R_R <= 0;
     else
       check_end_R_R_R <= ((ebi_K_d2 & ebi_rxd_d2 == `K23_7_symbol) &
			   (ebi_K_d1 & ebi_rxd_d1 == `K23_7_symbol) &
			   (ebi_K    & ebi_rxd    == `K23_7_symbol));
   
   //////////////////////////////////////////////////////////////////////////////
   // Decode /R/R/28_5 EPD code sequence
   //////////////////////////////////////////////////////////////////////////////
   
   reg 	      check_end_R_R_K28_5;
   
   always @(posedge ck, posedge reset)
     if (reset)
       check_end_R_R_K28_5 <= 0;
     else  
       check_end_R_R_K28_5 <= ((ebi_K_d2 & ebi_rxd_d2 == `K23_7_symbol) &
			       (ebi_K_d1 & ebi_rxd_d1 == `K23_7_symbol) &
			       (ebi_K    & ebi_rxd    == `K28_5_symbol) & rx_even);
   
   //////////////////////////////////////////////////////////////////////////////
   // Decode /R/R/S EPD code sequence
   ////////////////////////////////////////////////////////////////////////////// 
   
   reg   check_end_R_R_S;
   
   always @(posedge ck, posedge reset)
     if (reset)
       check_end_R_R_S <= 0;
     else
       check_end_R_R_S <= ((ebi_K_d2 & ebi_rxd_d2 == `K23_7_symbol) &
			   (ebi_K_d1 & ebi_rxd_d1 == `K23_7_symbol) &
			   (ebi_K & ebi_rxd == `K27_7_symbol));
   
   //////////////////////////////////////////////////////////////////////////////
   //  Dx.y and Kx.y symbol decoding 
   ////////////////////////////////////////////////////////////////////////////// 
   
   reg 	 K28_5_match, D2_2_match, D21_5_match, D5_6_match, D16_2_match;
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin
	  K28_5_match <= 0;
	  D2_2_match  <= 0;
	  D21_5_match <= 0;
	  D5_6_match  <= 0;
	  D16_2_match <= 0;
       end
     else begin
	K28_5_match <= (ebi_K_d2 &  ebi_rxd_d2 == `K28_5_symbol);
	D2_2_match  <= ~ebi_K_d2 & (ebi_rxd_d2 == `D2_2_symbol);
	D21_5_match <= ~ebi_K_d2 & (ebi_rxd_d2 == `D21_5_symbol);
	D5_6_match  <= ~ebi_K_d2 & (ebi_rxd_d2 == `D5_6_symbol);
	D16_2_match <= ~ebi_K_d2 & (ebi_rxd_d2 == `D16_2_symbol);
     end
  
   //////////////////////////////////////////////////////////////////////////////
   // Start of packet (/S/), End of Packet (/T/) and Carrier Extend 
   // (/R/) symbol matching
   //////////////////////////////////////////////////////////////////////////////    
   
   reg     CE_match, SPD_match, EPD_match;
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin
         CE_match   <= 0;
         SPD_match  <= 0;
         EPD_match  <= 0;
       end
     else
       begin
         CE_match   <= ebi_K_d2 & (ebi_rxd_d2 == `K23_7_symbol);
         SPD_match  <= ebi_K_d2 & (ebi_rxd_d2 == `K27_7_symbol);
         EPD_match  <= ebi_K_d2 & (ebi_rxd_d2 == `K29_7_symbol);
       end

   //////////////////////////////////////////////////////////////////////////////
   //
   ////////////////////////////////////////////////////////////////////////////// 
 
`ifdef MODEL_TECH
   
   wire [4:0] ebi_rxd_X;  wire [2:0] ebi_rxd_Y;
   
   assign     ebi_rxd_X = ebi_rxd[4:0];
   assign     ebi_rxd_Y = ebi_rxd[7:5];
`endif
   
   //////////////////////////////////////////////////////////////////////////////
   // rx_Config_reg
   //////////////////////////////////////////////////////////////////////////////  
 
   reg [15:0] rx_config_d1; reg [15:0] rx_config_d2;  reg [7:0] rx_config_lo;  
   
   reg 	      rx_config_lo_read, rx_config_hi_read;
   
   wire [15:0] rx_config_tmp = { ebi_rxd_d3, rx_config_lo };
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin
	  rx_config <= 0; rx_config_set <= 0; rx_config_lo <= 0; rx_config_d1 <= 0; rx_config_d2 <= 0;
       end
     else
       begin
	  if (rx_config_lo_read) 
	    begin 
	       rx_config_d2  <= rx_config_d1; 
	       rx_config_d1  <= rx_config;
	       rx_config_lo  <= ebi_rxd_d3;
	    end
	  else if (rx_config_hi_read) begin
	     
	     rx_config  <= rx_config_tmp;
	     
	     rx_config_set <= |rx_config_tmp;
	  end
       end

   //////////////////////////////////////////////////////////////////////////////
   // rx_config_cnt
   ////////////////////////////////////////////////////////////////////////////// 
   
   reg [2:0] rx_config_cnt;
   reg 	     rx_config_cnt_m_inc, rx_config_cnt_m_rst;

   always @(posedge ck, posedge reset)
     if (reset)
       rx_config_cnt <= 0;
     else
       begin
   	  if      (rx_config_cnt_m_inc) rx_config_cnt <= rx_config_cnt + 1;
   	  else if (rx_config_cnt_m_rst) rx_config_cnt <= 0;
       end

   wire rx_config_cnt_done;

   assign rx_config_cnt_done = (rx_config_cnt == 3);
   
   //////////////////////////////////////////////////////////////////////////////
   // receive ability matching
   //////////////////////////////////////////////////////////////////////////////    
   
   wire [6:0] ability; wire [6:0] ability_d1; wire [6:0] ability_d2;
   
   assign      ability    = { rx_config[15],    rx_config[13:12],    rx_config[8:5]   };  
   assign      ability_d1 = { rx_config_d1[15], rx_config_d1[13:12], rx_config_d1[8:5]}; 
   assign      ability_d2 = { rx_config_d2[15], rx_config_d2[13:12], rx_config_d2[8:5]};     

   assign ability_matched1 = ~| (ability ^ ability_d1);
   assign ability_matched2 = ~| (ability ^ ability_d2);
   
   assign ability_matched = rx_config_cnt_done & ability_matched1 & ability_matched2;
   
     reg [6:0] ability_matched_reg;

   always @(posedge ck, posedge reset)
     if (reset)
       ability_matched_reg <= 0;
     else begin

	ability_match <= ability_matched;
	
	if (ability_matched) ability_matched_reg <= ability;
     end
 
   //////////////////////////////////////////////////////////////////////////////
   // receive config matching
   //////////////////////////////////////////////////////////////////////////////   
   
   assign rx_config_match1 = ability_matched1 & ~(rx_config[14] ^ rx_config_d1[14]);
   assign rx_config_match2 = ability_matched2 & ~(rx_config[14] ^ rx_config_d2[14]);
   
   assign  rx_config_match = rx_config_match1 & rx_config_match2;
   
   //////////////////////////////////////////////////////////////////////////////
   // receive acknowledge matching
   //////////////////////////////////////////////////////////////////////////////    
  
   always @(posedge ck, posedge reset)
     
     acknowledge_match <= (reset) ? 0 : ( rx_config_match & rx_config_d2[14] );

   //////////////////////////////////////////////////////////////////////////////
   // receive consistency matching
   ////////////////////////////////////////////////////////////////////////////// 

   assign        consistency_match = ability_match & ~|(ability_matched_reg ^ ability);
 
   //////////////////////////////////////////////////////////////////////////////
   // receive idle counter/matching
   ////////////////////////////////////////////////////////////////////////////// 
   
   reg [1:0]   idle_cnt;
   
   reg 	       idle_cnt_m_inc, idle_cnt_m_clr;
   
   always @(posedge ck, posedge reset)

      if (reset)
	   idle_cnt <= 0;
      else
	begin
	   if      (idle_cnt_m_clr) idle_cnt <= 0;
	   else if (idle_cnt_m_inc) idle_cnt <= idle_cnt + 1;
	end

   assign idle_match = (idle_cnt == 3);
   
   //////////////////////////////////////////////////////////////////////////////
   // RX_UNITDATA.indicate - Signal from PCS RX -> PCS AutoNeg process
   ////////////////////////////////////////////////////////////////////////////// 
  
   reg 	  rudi_INVALID_m_set; reg  rudi_IDLE_m_set; reg rudi_CONF_m_set;
   
   always @(posedge ck, posedge reset)
     if (reset)
       rudi <= `RUDI_INVALID;
     else
       begin
	  if      (rudi_INVALID_m_set)  rudi <= `RUDI_INVALID; 
	  else if (rudi_IDLE_m_set)     rudi <= `RUDI_IDLE;
	  else if (rudi_CONF_m_set)     rudi <= `RUDI_CONF;
       end

   //////////////////////////////////////////////////////////////////////////////
   // GMII output 
   ////////////////////////////////////////////////////////////////////////////// 
 
   reg gmii_rxd_false_carrier_m_set, gmii_rxd_preamble_m_set, gmii_rxd_ext_err_m_set;
   
   reg gmii_rxd_packet_burst_m_set, gmii_rxd_trr_extend_m_set, gmii_rxd_m_set;
   
   always @(posedge ck, posedge reset)
     
     if (reset)
       gmii_rxd <= 0;
     else
       begin
	  gmii_rxd <= (gmii_rxd_m_set)               ? ebi_rxd_d3  :
		      (gmii_rxd_false_carrier_m_set) ? 8'b00001110 :
		      (gmii_rxd_preamble_m_set)      ? 8'b01010101 :
		      (gmii_rxd_ext_err_m_set)       ? 8'b00011111 :
		      (gmii_rxd_trr_extend_m_set)    ? 8'b00001111 :
		      (gmii_rxd_packet_burst_m_set)  ? 8'b00001111 : 0;
       end 

   //////////////////////////////////////////////////////////////////////////////
   // Current receive state
   ////////////////////////////////////////////////////////////////////////////// 
  
   reg 	receiving_m_set, receiving_m_clr;
   
   always @(posedge ck, posedge reset)
     if (reset)
       receiving <= 0;
     else
       begin
	  if      (receiving_m_set) receiving <= 1;
	  else if (receiving_m_clr) receiving <= 0;
       end
     	 

`ifdef MODEL_TECH
  enum logic [4:0] {
`else
  localparam
`endif
		    S_PCS_RX_START            = 0,
		    S_PCS_RX_LINK_FAILED      = 1,
		    S_PCS_RX_WAIT_K           = 2,
		    S_PCS_RX_K                = 3,
		    S_PCS_RX_CONFIG_CB        = 4,
		    S_PCS_RX_CONFIG_CC        = 5,
		    S_PCS_RX_CONFIG_CD        = 6,
		    S_PCS_RX_INVALID          = 7,
		    S_PCS_RX_IDLE_D           = 8,
		    S_PCS_RX_FALSE_CARRIER    = 9,
		    S_PCS_RX_START_OF_PACKET  = 10,
		    S_PCS_RX_RECEIVE          = 11,
		    S_PCS_RX_EARLY_END        = 12,
		    S_PCS_RX_TRI_RRI          = 13,
		    S_PCS_RX_TRR_EXTEND       = 14,
		    S_PCS_RX_EPD2_CHECK_END   = 15,
		    S_PCS_RX_PACKET_BURST_RRS = 16,
		    S_PCS_RX_EXTEND_ERR       = 17,
		    S_PCS_RX_EARLY_END_EXT    = 18,
		    S_PCS_RX_DATA_ERROR       = 19,
		    S_PCS_RX_DATA             = 20
`ifdef MODEL_TECH
  } pcs_rx_present, pcs_rx_next;
`else
   ; reg [4:0] pcs_rx_present, pcs_rx_next;
`endif
   
   //////////////////////////////////////////////////////////////////////////////
   // gmii_rx_er ctrl
   //////////////////////////////////////////////////////////////////////////////

   reg gmii_rx_er_m_set, gmii_rx_er_m_clr;
   
   always @(posedge ck, posedge reset)
     if (reset)
       gmii_rx_er <= 0;
     else
       begin
	  if      (gmii_rx_er_m_set) gmii_rx_er <= 1;
	  else if (gmii_rx_er_m_clr) gmii_rx_er <= 0;
       end
   
   //////////////////////////////////////////////////////////////////////////////
   // gmii_rx_dv ctrl
   ////////////////////////////////////////////////////////////////////////////// 
   
   reg gmii_rx_dv_m_set, gmii_rx_dv_m_clr;
   
   always @(posedge ck, posedge reset)
     if (reset)
       gmii_rx_dv <= 0;
     else
       begin
	  if      (gmii_rx_dv_m_set) gmii_rx_dv <= 1;
	  else if (gmii_rx_dv_m_clr) gmii_rx_dv <= 0;
       end   

   //////////////////////////////////////////////////////////////////////////////
   // 
   ////////////////////////////////////////////////////////////////////////////// 
   
   wire  xmit_DATA, xmit_nDATA, xmit_DATA_CD, xmit_DATA_nCD;
   
   assign xmit_DATA = (xmit == `XMIT_DATA);
   
   assign xmit_nDATA = (xmit != `XMIT_DATA);
   
   assign xmit_DATA_CD = (xmit_DATA & carrier_detect_d3);
   
   assign xmit_DATA_nCD = (xmit_DATA & ~carrier_detect_d3);
 
   wire   xmit_DATA_CD_SPD, xmit_DATA_CD_nSPD, xmit_DATA_CD_nSPD_nK28_5;
   
   assign xmit_DATA_CD_SPD = xmit_DATA_CD & SPD_match;
   
   assign xmit_DATA_CD_nSPD = xmit_DATA_CD & ~SPD_match;
   
   assign xmit_DATA_CD_nSPD_nK28_5 = xmit_DATA_CD_nSPD & ~K28_5_match;


   //////////////////////////////////////////////////////////////////////////////
   // receive state machine registered part.
   //////////////////////////////////////////////////////////////////////////////    
     
   always @(posedge ck, posedge reset)
     
     pcs_rx_present <= (reset) ? S_PCS_RX_START :  pcs_rx_next;
    
   //////////////////////////////////////////////////////////////////////////////
   // receive state machine - IEEE 802.3-2008 Clause 36  Figure 36-7a, 36-7b
   ////////////////////////////////////////////////////////////////////////////// 

   always @*
     begin	
	pcs_rx_next = pcs_rx_present;

	rx_config_lo_read = 0; rx_config_hi_read = 0;
 	
	receiving_m_set = 0; receiving_m_clr = 0;
		
	gmii_rxd_false_carrier_m_set = 0; gmii_rxd_preamble_m_set = 0; gmii_rxd_ext_err_m_set = 0; 
	
	gmii_rxd_packet_burst_m_set = 0; gmii_rxd_trr_extend_m_set = 0; gmii_rxd_m_set = 0;
	
	idle_cnt_m_clr = 0; idle_cnt_m_inc = 0;
	
	gmii_rx_er_m_set = 0; gmii_rx_er_m_clr = 0;
	
	gmii_rx_dv_m_set = 0; gmii_rx_dv_m_clr = 0;
	
	rudi_INVALID_m_set = 0; rudi_IDLE_m_set = 0; rudi_CONF_m_set = 0;

	rx_config_cnt_m_inc = 0; rx_config_cnt_m_rst = 0;

	ge_x_pcs_rx_stats_inc = 16'h0000;
		
	case (pcs_rx_present)

	  S_PCS_RX_START:
	    begin
	       pcs_rx_next = S_PCS_RX_LINK_FAILED; 
	    end
	  
	  S_PCS_RX_LINK_FAILED:
	    begin
	       rudi_INVALID_m_set = (xmit_nDATA);
	       
	       if (receiving) begin receiving_m_clr = 1;  gmii_rx_er_m_set = 1; end
	       else           begin gmii_rx_dv_m_clr = 1; gmii_rx_er_m_clr = 1; end
	       
	       pcs_rx_next = S_PCS_RX_WAIT_K;
	    end
	  
	  S_PCS_RX_WAIT_K:
	    begin
	       rx_config_cnt_m_rst = 1;
	       
	       receiving_m_clr = 1; gmii_rx_dv_m_clr = 1; gmii_rx_er_m_clr = 1;

	       pcs_rx_next = (K28_5_match & rx_even_d3) ? S_PCS_RX_K : S_PCS_RX_WAIT_K;
	    end


	  S_PCS_RX_K:
	    begin
	       receiving_m_clr = 1; gmii_rx_dv_m_clr = 1; gmii_rx_er_m_clr = 1;

	       rudi_IDLE_m_set = (xmit_nDATA & ~ebi_K_d3 & ~D21_5_match & ~D2_2_match) |
				 (xmit_DATA & ~D21_5_match & ~D2_2_match);
              	       
	       pcs_rx_next = (D21_5_match | D2_2_match)                              ? S_PCS_RX_CONFIG_CB   :	 
			     ((xmit_nDATA) & ~ebi_K_d3 & ~D21_5_match & ~D2_2_match) ? S_PCS_RX_IDLE_D      :
			     ((xmit_DATA) & ~D21_5_match & ~D2_2_match)              ? S_PCS_RX_IDLE_D      :
                             ((xmit_nDATA) & ebi_K_d3)                               ? S_PCS_RX_INVALID     : S_PCS_RX_INVALID;
	    end
	  
	  S_PCS_RX_CONFIG_CB:
	    begin
	       // Keep a count of the number of consecutive /C/ streams 
	       rx_config_cnt_m_inc = ~rx_config_cnt_done;
	       
	       rx_config_lo_read = ~ebi_K_d3; 
	       
	       receiving_m_clr = 1; gmii_rx_dv_m_clr = 1; gmii_rx_er_m_clr = 1;
	       
	       pcs_rx_next = (ebi_K_d3) ? S_PCS_RX_INVALID : S_PCS_RX_CONFIG_CC;	     
	    end

	  
	  S_PCS_RX_CONFIG_CC:
	    begin
	       rx_config_hi_read = ~ebi_K_d3;  idle_cnt_m_clr = 1;
	       
	       // Signal from RX -> ANEG indicating /C/ ordered set received
	       rudi_CONF_m_set = ~ebi_K_d3; 

	       pcs_rx_next = (ebi_K_d3) ? S_PCS_RX_INVALID : S_PCS_RX_CONFIG_CD;
	    end

	  S_PCS_RX_CONFIG_CD:
	    begin
	       pcs_rx_next = (K28_5_match & rx_even_d3) ? S_PCS_RX_K : S_PCS_RX_INVALID;
	    end
	  
	  
	  S_PCS_RX_INVALID:
	    begin
	       // Signal from RX -> ANEG indicating INVALID
	       rudi_INVALID_m_set = (xmit == `XMIT_CONFIGURATION);
	       
	       receiving_m_set = (xmit_DATA);
	       
	       pcs_rx_next = (K28_5_match & rx_even_d3)  ? S_PCS_RX_K       :
			     (~K28_5_match & rx_even_d3) ? S_PCS_RX_WAIT_K  : S_PCS_RX_INVALID;
	    end

	  
	  S_PCS_RX_IDLE_D:
	    begin
	       // Must be receiving a IDLE so reset config cnt and idle_matcher logic
	       rx_config_cnt_m_rst = 1;  idle_cnt_m_inc = ~idle_match; 

	       // Signal from RX -> ANEG indicating /I/ ordered set received
	       rudi_IDLE_m_set = 1;
	       
	       // Generate rx_dv only if we've detected a START_OF_PACKET
	       if (xmit_DATA_CD_SPD)         gmii_rx_dv_m_set = 1; else gmii_rx_dv_m_clr = 1;

	       // Generate rx_er if we've detected a FALSE_CARRIER
	       if (xmit_DATA_CD_nSPD_nK28_5) gmii_rx_er_m_set = 1; else gmii_rx_er_m_clr = 1;
	       
	       if (xmit_DATA_CD) 
		 begin
		    if (~K28_5_match) 
		      begin 
			 receiving_m_set = 1;
			 if (SPD_match) gmii_rxd_preamble_m_set = 1; else gmii_rxd_false_carrier_m_set = 1;
		      end
		 end
	       else receiving_m_clr = 1; 

	       pcs_rx_next = (~K28_5_match & ~xmit_DATA    )  ? S_PCS_RX_INVALID       :
			     ( xmit_DATA_CD_SPD            )  ? S_PCS_RX_RECEIVE       : 
			     ( xmit_DATA_nCD | K28_5_match )  ? S_PCS_RX_K             :
			     ( xmit_DATA_CD_nSPD           )  ? S_PCS_RX_FALSE_CARRIER :  S_PCS_RX_IDLE_D;

	       ge_x_pcs_rx_stats_inc[0] = xmit_DATA_CD_SPD;
    
	    end 
	  
	  
	  S_PCS_RX_FALSE_CARRIER:
	    begin
	       gmii_rx_er_m_set = 1; gmii_rxd_false_carrier_m_set = 1;
	       
	       pcs_rx_next = (K28_5_match & rx_even_d3) ? S_PCS_RX_K : S_PCS_RX_FALSE_CARRIER;
	    end

	  //----------------------------------------------------------------------------
	  // IEEE 802.3-2008 Clause 36  Figure 36-7b

	  S_PCS_RX_START_OF_PACKET:
	    begin
	       gmii_rx_dv_m_set = 1; gmii_rx_er_m_clr = 1; gmii_rxd_preamble_m_set = 1;
	       
	       pcs_rx_next = S_PCS_RX_RECEIVE;
	    end
	  
	  S_PCS_RX_RECEIVE:
	    begin
	       
	       if (early_end)  // EARLY_END
		 begin
		    ge_x_pcs_rx_stats_inc[2] = 1;
		    
		    gmii_rx_er_m_set = 1; pcs_rx_next = S_PCS_RX_EARLY_END;
		 end

	       else if (check_end_T_R_K28_5) // TRI+RRI
		 begin
		    
		    ge_x_pcs_rx_stats_inc[3] = 1;
		    
		    receiving_m_clr = 1; gmii_rx_dv_m_clr  = 1;  gmii_rx_er_m_clr = 1;
		    
		    pcs_rx_next = S_PCS_RX_TRI_RRI;  
		 end

	       else if (check_end_T_R_R) // TRR+EXTEND
		 begin
		    
		    ge_x_pcs_rx_stats_inc[5] = 1;
   	    
		    gmii_rx_dv_m_clr  = 1;  gmii_rx_er_m_set = 1; gmii_rxd_trr_extend_m_set = 1;
		    
		    pcs_rx_next = S_PCS_RX_EPD2_CHECK_END; 
		 end
	       
	       else if (check_end_R_R_R) // EARLY_END_EXT
		 begin
		    
		    ge_x_pcs_rx_stats_inc[6] = 1;
		    
		    gmii_rx_er_m_set = 1;  pcs_rx_next = S_PCS_RX_EPD2_CHECK_END; 
		 end
	       
	       else if (~ebi_K_d3) // RX_DATA
		 begin
		    ge_x_pcs_rx_stats_inc[1] = 1;
		    
		    gmii_rx_er_m_clr = 1; gmii_rxd_m_set = 1;
		 end
	       
	       else  // RX_DATA_ERROR
		 gmii_rx_er_m_set = 1;
	    end

	  
	  S_PCS_RX_EARLY_END:
	    begin
	       pcs_rx_next =  (D21_5_match | D2_2_match) ? S_PCS_RX_CONFIG_CB : S_PCS_RX_IDLE_D;
	    end
	  
	  S_PCS_RX_TRI_RRI:
	    begin
	       pcs_rx_next = (K28_5_match) ? S_PCS_RX_K : S_PCS_RX_TRI_RRI;         
	    end
	    
	  S_PCS_RX_TRR_EXTEND:
	    begin
	       gmii_rx_dv_m_clr = 1; gmii_rx_er_m_set = 1; gmii_rxd_trr_extend_m_set = 1;
	       
	       pcs_rx_next = S_PCS_RX_EPD2_CHECK_END; 
	    end

	  
	  S_PCS_RX_EPD2_CHECK_END:
	    begin

	       if (check_end_R_R_R)
		 begin
		     
		    gmii_rx_dv_m_clr  = 1;  gmii_rx_er_m_set = 1; gmii_rxd_trr_extend_m_set = 1;
		 end

	       else if (check_end_R_R_K28_5)
		 begin
		    
		    ge_x_pcs_rx_stats_inc[4] = 1;
		    
		    receiving_m_clr = 1; gmii_rx_dv_m_clr = 1; gmii_rx_er_m_clr = 1;

		 end

	       else if (check_end_R_R_S)
		 begin
		    ge_x_pcs_rx_stats_inc[7] = 1;
		 end

	       pcs_rx_next = (check_end_R_R_R)     ? S_PCS_RX_TRR_EXTEND       :     
			     (check_end_R_R_K28_5) ? S_PCS_RX_TRI_RRI          :              
			     (check_end_R_R_S)     ? S_PCS_RX_PACKET_BURST_RRS : S_PCS_RX_EXTEND_ERR;       
	    end
	  
	  S_PCS_RX_PACKET_BURST_RRS:
	    begin
	       gmii_rx_dv_m_clr = 1; gmii_rxd_packet_burst_m_set = 1;
	       
	       pcs_rx_next = (SPD_match) ? S_PCS_RX_START_OF_PACKET : S_PCS_RX_PACKET_BURST_RRS;
	    end
	  
	   S_PCS_RX_EXTEND_ERR:
	     begin
		gmii_rx_dv_m_clr  = 1;  gmii_rxd_ext_err_m_set = 1;
		
		pcs_rx_next = (SPD_match)                              ? S_PCS_RX_START_OF_PACKET :
			      (K28_5_match & rx_even_d3)               ? S_PCS_RX_K           :          
			      (~SPD_match & ~K28_5_match & rx_even_d3) ? S_PCS_RX_EPD2_CHECK_END  : S_PCS_RX_EXTEND_ERR;
	     end
	  
	  S_PCS_RX_EARLY_END_EXT:
	    begin
	       gmii_rx_er_m_set = 1;
	         
	       pcs_rx_next = S_PCS_RX_EPD2_CHECK_END;  
	    end
	  
	  S_PCS_RX_DATA_ERROR:
	    begin 
	       gmii_rx_er_m_set = 1;
	       
	       pcs_rx_next = S_PCS_RX_RECEIVE;
	    end
	  
	  S_PCS_RX_DATA:
	    begin
	       gmii_rx_er_m_clr = 1; gmii_rxd_m_set = 1;
	       
	       pcs_rx_next = S_PCS_RX_RECEIVE;
	    end
	endcase

	if      (~signal_detect)  pcs_rx_next = S_PCS_RX_LINK_FAILED;
	else if (~sync_status_d3) pcs_rx_next = S_PCS_RX_LINK_FAILED;    
	else if (soft_reset)      pcs_rx_next = S_PCS_RX_WAIT_K;
	  
     end 
   
endmodule
