//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_tx.v"                               ////
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

`include "ge_1000baseX_constants.v"
`include "ge_1000baseX_regs.v"

module ge_1000baseX_tx (
		    	   
   //  transmit clock and reset 		  
   input ck,
   input reset,

   // SERDES transmit 10B bus 
   output   [9:0]    tbi_txd,

   // Transmit GMII bus 
   input             gmii_tx_en_in,
   input             gmii_tx_er_in,
   input   [7:0]     gmii_txd_in,

   output reg        gmii_col,

   input             receiving,		    
   output reg        transmitting,

   input             signal_detect,
		    
   // Frame transmit pulse	
   output            tx_frame_pulse,
		    
   // Auto-negotiation ctrl 
   input [2:0]       xmit,
   input [15:0]      tx_config,
   input             mr_main_reset
			
   );
           
   //////////////////////////////////////////////////////////////////////////////
   // Diagnostics registers
   //////////////////////////////////////////////////////////////////////////////

`define TX_FRAME_CNT             16'h0000    
`define TX_DATA_CNT              16'h0001
`define TX_ERROR_CNT             16'h0002
`define END_OF_PACKET_NOEXT_CNT  16'h0003
`define END_OF_PACKET_EXT_CNT    16'h0004
`define EXTEND_BY_1_CNT          16'h0005
`define CARRIER_EXTEND_CNT       16'h0006
`define EPD2_NOEXT_CNT           16'h0007
`define EPD3_CNT                 16'h0008
`define RESET                    16'hffff
   
   reg [8:0] 	       ge_x_pcs_tx_stats_inc;
   
   reg [15:0] 	       tx_frame_cnt; 
   reg [15:0] 	       tx_error_cnt;
   reg [15:0] 	       tx_data_cnt;
   reg [15:0] 	       end_of_packet_noext_cnt;
   reg [15:0] 	       end_of_packet_ext_cnt;
   reg [15:0] 	       extend_by_1_cnt;
   reg [15:0] 	       carrier_extend_cnt;
   reg [15:0] 	       epd2_noext_cnt;
   reg [15:0] 	       epd3_cnt;
   
   always @(posedge ck, posedge reset)
     
     if (reset)
       begin
	  tx_frame_cnt            <= 'd0; tx_data_cnt             <= 'd0;  
	  tx_error_cnt            <= 'd0; end_of_packet_noext_cnt <= 'd0;
	  end_of_packet_ext_cnt   <= 'd0; extend_by_1_cnt         <= 'd0;
	  carrier_extend_cnt      <= 'd0; epd2_noext_cnt          <= 'd0;
	  epd3_cnt                <= 'd0;
       end
     else
       begin
	  if      (ge_x_pcs_tx_stats_inc[0])  tx_frame_cnt            <= tx_frame_cnt + 1;
	  else if (ge_x_pcs_tx_stats_inc[1])  tx_data_cnt             <= tx_data_cnt + 1;  
	  else if (ge_x_pcs_tx_stats_inc[2])  tx_error_cnt            <= tx_error_cnt + 1;
	  else if (ge_x_pcs_tx_stats_inc[3])  end_of_packet_noext_cnt <= end_of_packet_noext_cnt + 1;
	  else if (ge_x_pcs_tx_stats_inc[4])  end_of_packet_ext_cnt   <= end_of_packet_ext_cnt + 1;
	  else if (ge_x_pcs_tx_stats_inc[5])  extend_by_1_cnt         <= extend_by_1_cnt + 1;
	  else if (ge_x_pcs_tx_stats_inc[6])  carrier_extend_cnt      <= carrier_extend_cnt + 1; 
	  else if (ge_x_pcs_tx_stats_inc[7])  epd2_noext_cnt          <= epd2_noext_cnt + 1;
	  else if (ge_x_pcs_tx_stats_inc[8])  epd3_cnt                <= epd3_cnt + 1;
       end 

   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   assign 	     tx_frame_pulse = ge_x_pcs_tx_stats_inc[0];
   
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
   // Running disparity
   //////////////////////////////////////////////////////////////////////////////
   
   wire	  encoder_disparity; // 0 - Negative Running Disparity, 1 - Positive Running Disparity

   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   reg 	  gmii_tx_en_pipe, gmii_tx_er_pipe; reg [7:0]  gmii_txd_pipe;

   reg 	  gmii_d1, gmii_d1_m_set, gmii_d1_m_clr;
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin
	  gmii_d1 <= 0;
	  gmii_tx_en_pipe <= 0; gmii_tx_er_pipe <= 0; gmii_txd_pipe <= 0;
       end
     else
       begin
	  gmii_tx_en_pipe <= gmii_tx_en_in;
	  gmii_tx_er_pipe <= gmii_tx_er_in;
	  gmii_txd_pipe   <= gmii_txd_in;
	  
	  if      (gmii_d1_m_set) gmii_d1 <= 1;
	  else if (gmii_d1_m_clr) gmii_d1 <= 0;
	  
       end
   
   wire       gmii_tx_en = (gmii_d1) ? gmii_tx_en_pipe : gmii_tx_en_in;
   wire       gmii_tx_er = (gmii_d1) ? gmii_tx_er_pipe : gmii_tx_er_in;
   wire [7:0] gmii_txd   = (gmii_d1) ? gmii_txd_pipe   : gmii_txd_in;
   
   //////////////////////////////////////////////////////////////////////////////
   // gmii_col
   //////////////////////////////////////////////////////////////////////////////  

   reg  gmii_col_m_set, gmii_col_m_clr;


    always @(posedge ck, posedge reset)
      if (reset)
	begin
	   gmii_col <= 0;
	end
      else
	begin
	   if      (gmii_col_m_set) begin gmii_col <= 1; end
	   else if (gmii_col_m_clr) begin gmii_col <= 0; end
	end
   
   //////////////////////////////////////////////////////////////////////////////
   // Current transmit state
   //////////////////////////////////////////////////////////////////////////////     
   
   reg 	transmitting_m_set, transmitting_m_clr;
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin
	  transmitting <= 0;
       end
     else
       begin
	  if      (transmitting_m_set) begin transmitting <= 1; end
	  else if (transmitting_m_clr) begin transmitting <= 0; end
       end

   //////////////////////////////////////////////////////////////////////////////
   // Configuration Counter and decode logic
   //////////////////////////////////////////////////////////////////////////////    

   reg [3:0] config_cnt;
   
   reg 	     config_cnt_clr, config_cnt_inc;
   
   always @(posedge ck, posedge reset)
     if (reset)
       config_cnt <= 0;
     else
       begin
	  if      (config_cnt_clr) config_cnt <= 0;
	  else if (config_cnt_inc) config_cnt <= config_cnt + 1; 
       end

   assign config_C1_done = (config_cnt == 3);
   assign config_C2_done = (config_cnt == 7);
   		  
   assign config_cnt_K28_5     = (config_cnt == 0 | config_cnt == 4);
   assign config_cnt_D21_5     = (config_cnt == 1);
   assign config_cnt_D2_2      = (config_cnt == 5);
   assign config_cnt_config_lo = (config_cnt == 2 | config_cnt == 6);
   assign config_cnt_config_hi = (config_cnt == 3 | config_cnt == 7);

   //////////////////////////////////////////////////////////////////////////////
   // Idle counter and decode logic
   //////////////////////////////////////////////////////////////////////////////    
   
   reg idle_cnt; 
   
   reg 	     idle_cnt_m_clr, idle_cnt_m_inc;
   
   always @(posedge ck, posedge reset)
     if (reset)
       idle_cnt <= 0;
     else
       begin
	  if      (idle_cnt_m_clr) idle_cnt <= 0;
	  else if (idle_cnt_m_inc) idle_cnt <= idle_cnt + 1; 

       end
   
   wire   idle_cnt_done, idle_cnt_is_clr, idle_cnt_is_set;
   
   assign idle_cnt_done   = idle_cnt;  
   assign idle_cnt_is_clr = ~idle_cnt; 
   assign idle_cnt_is_set = idle_cnt;  
   
   //////////////////////////////////////////////////////////////////////////////
   // PCS Transmit - IEEE 802.3-2005 Clause 36, Figure 36-6 page 58
   //////////////////////////////////////////////////////////////////////////////   
   //  
   reg [7:0] encoder_8b_rxd; 
   
   reg 	     encoder_K;
   
   reg 	     encoder_8b_rxd_gmii_txd_m_set, encoder_8b_rxd_config_lo_m_set, encoder_8b_rxd_config_hi_m_set;
   
   reg 	     encoder_8b_rxd_K30_7_m_set, encoder_8b_rxd_K29_7_m_set, encoder_8b_rxd_K28_1_m_set, encoder_8b_rxd_K28_5_m_set, encoder_8b_rxd_K27_7_m_set, encoder_8b_rxd_K23_7_m_set;
   
   reg 	     encoder_8b_rxd_D21_5_m_set, encoder_8b_rxd_D2_2_m_set, encoder_8b_rxd_D5_6_m_set, encoder_8b_rxd_D16_2_m_set;
   
   reg 	     encoder_tx_even;
   
   wire      encoder_tx_even_set = (encoder_8b_rxd_K28_5_m_set| encoder_8b_rxd_config_lo_m_set);
   
   wire      encoder_tx_even_clr = (encoder_8b_rxd_D21_5_m_set|encoder_8b_rxd_D21_5_m_set|encoder_8b_rxd_D5_6_m_set|encoder_8b_rxd_D16_2_m_set|encoder_8b_rxd_config_hi_m_set);
   
   wire      encoder_tx_even_toggle = (encoder_8b_rxd_gmii_txd_m_set|encoder_8b_rxd_K30_7_m_set|encoder_8b_rxd_K27_7_m_set|encoder_8b_rxd_K29_7_m_set|encoder_8b_rxd_K23_7_m_set);
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin
	  encoder_K <= 0; encoder_8b_rxd <= 0; encoder_tx_even <= 0;
       end
     else
       begin
	  // Input 8b10b encode K ctrl strobe 
	  encoder_K <= encoder_8b_rxd_K30_7_m_set|encoder_8b_rxd_K29_7_m_set|encoder_8b_rxd_K28_5_m_set|encoder_8b_rxd_K27_7_m_set|encoder_8b_rxd_K23_7_m_set;

	  // Input to 8b10b encode EBI (Eight Bit Interface) bus.
	  encoder_8b_rxd <=  
		      // Drive special K codes onto 8b10_enc encoder_8b_rxd - K strobe high
		      encoder_8b_rxd_K30_7_m_set      ? `K30_7_symbol   :
		      encoder_8b_rxd_K29_7_m_set      ? `K29_7_symbol   :			     
		      encoder_8b_rxd_K28_5_m_set      ? `K28_5_symbol   :
		      encoder_8b_rxd_K28_1_m_set      ? `K28_1_symbol   :
		      encoder_8b_rxd_K27_7_m_set      ? `K27_7_symbol   :
		      encoder_8b_rxd_K23_7_m_set      ? `K23_7_symbol   :
		      // Drive Special Data Codes onto 8b10 enc encoder_8b_rxd - K strobe low
		      encoder_8b_rxd_D21_5_m_set      ? `D21_5_symbol   :
		      encoder_8b_rxd_D2_2_m_set       ? `D2_2_symbol    :  
		      encoder_8b_rxd_D5_6_m_set       ? `D5_6_symbol    :
		      encoder_8b_rxd_D16_2_m_set      ? `D16_2_symbol   :
		      // Drive Tx Config register onto 8b10 enc encoder_8b_rxd - K strobe low
		      encoder_8b_rxd_config_lo_m_set  ? tx_config[7:0]  : 
		      encoder_8b_rxd_config_hi_m_set  ? tx_config[15:8] : 

		      // Drive GMII txd onto 8b10 enc encoder_8b_rxd - K strobe low
		      encoder_8b_rxd_gmii_txd_m_set   ? gmii_txd : 0;

	  // Keep track of even/odd TX status
	  encoder_tx_even <= encoder_tx_even_set    ? 1            : 
			     encoder_tx_even_clr    ? 0            : 
			     encoder_tx_even_toggle ? ~encoder_tx_even : encoder_tx_even;
       end
   

 

   //////////////////////////////////////////////////////////////////////////////
   //  VOID - see IEEE 802.3-2005 Section 36 (PCS) page 55 
   //////////////////////////////////////////////////////////////////////////////    

   assign VOID = (~gmii_tx_en & gmii_tx_er & gmii_txd != 8'b00001111) | (gmii_tx_en & gmii_tx_er);

   //////////////////////////////////////////////////////////////////////////////
   // Instantiate 8b10 Encode  module
   //////////////////////////////////////////////////////////////////////////////   
   //   
   encoder_8b10b encoder_8b10bi(
		       
      //  Clocks 
      .SBYTECLK(ck),
		       
      //  Reset 
      .reset(reset),
    
      //  eight bit interface (ebi) input  
      .ebi(encoder_8b_rxd),

      //  ten bit interface (tbi) output to TBI bus 
      .tbi(tbi_txd),

      //  Data/special code-group ctrl  	       
      .K(encoder_K),

      // Running Disparity
      .disparity(encoder_disparity)
   );


`ifdef MODEL_TECH

   wire [4:0] encoder_8b_X;  wire [2:0] encoder_8b_Y;
   
   assign     encoder_8b_X = encoder_8b_rxd[4:0];
   assign     encoder_8b_Y = encoder_8b_rxd[7:5];
`endif    
   
`ifdef MODEL_TECH
  enum logic [4:0] {
`else
  localparam
`endif
		    S_PCS_TX_TEST_XMIT            = 0,
		    S_PCS_TX_XMIT_DATA            = 1,      
		    S_PCS_TX_ALIGN_ERR_START      = 2,
		    S_PCS_TX_START_ERROR          = 3,
		    S_PCS_TX_DATA_ERROR           = 4,
		    S_PCS_TX_START_OF_PACKET      = 5,
		    S_PCS_TX_PACKET               = 6,
		    S_PCS_TX_END_OF_PACKET_NOEXT  = 7,
		    S_PCS_TX_END_OF_PACKET_EXT    = 8,
		    S_PCS_TX_EXTEND_BY_1          = 9,
		    S_PCS_TX_CARRIER_EXTEND       = 10,   
		    S_PCS_TX_EPD2_NOEXT           = 11,
		    S_PCS_TX_EPD3                 = 12,
		    S_PCS_TX_CONFIGURATION        = 13,
		    S_PCS_TX_IDLE                 = 14
`ifdef MODEL_TECH
  } pcs_tx_present, pcs_tx_next;
`else
   ; reg [4:0] pcs_tx_present, pcs_tx_next;
`endif

    
   //////////////////////////////////////////////////////////////////////////////
   // xmit ctrl
   //////////////////////////////////////////////////////////////////////////////

   wire      xmit_idle,  xmit_configuration, xmit_data;
   
   assign    xmit_configuration = (xmit == `XMIT_CONFIGURATION);
   
   assign    xmit_idle = (xmit == `XMIT_IDLE) | (xmit == `XMIT_DATA & (gmii_tx_en | gmii_tx_er));
   
   assign    xmit_data = (xmit == `XMIT_DATA  & ~gmii_tx_en & ~gmii_tx_er);

   reg [2:0] xmit_saved; wire xmitCHANGE;
   
   always @(posedge ck, posedge reset)

     xmit_saved <= (reset) ? `XMIT_IDLE : xmit;
   
   assign xmitCHANGE = (xmit != xmit_saved);

   //////////////////////////////////////////////////////////////////////////////
   // transmit state machine registered part.
   //////////////////////////////////////////////////////////////////////////////
   
   always @(posedge ck, posedge reset)

     pcs_tx_present <= (reset) ? S_PCS_TX_TEST_XMIT :  pcs_tx_next;
   
   //////////////////////////////////////////////////////////////////////////////
   // transmit state machine - IEEE 802.3-2008 Clause 36
   //////////////////////////////////////////////////////////////////////////////
   
   always @*
     begin
	pcs_tx_next = pcs_tx_present;
	
	encoder_8b_rxd_gmii_txd_m_set = 0;

	encoder_8b_rxd_K30_7_m_set = 0; 
	encoder_8b_rxd_K29_7_m_set = 0; 
	encoder_8b_rxd_K28_5_m_set = 0;
	encoder_8b_rxd_K28_1_m_set = 0;
	encoder_8b_rxd_K27_7_m_set = 0; 
	encoder_8b_rxd_K23_7_m_set = 0;
	
	encoder_8b_rxd_D21_5_m_set = 0; 
	encoder_8b_rxd_D2_2_m_set = 0; 
	encoder_8b_rxd_D5_6_m_set = 0; 
	encoder_8b_rxd_D16_2_m_set = 0;
	
	encoder_8b_rxd_config_lo_m_set = 0; 
	encoder_8b_rxd_config_hi_m_set = 0;
	
	transmitting_m_set = 0; transmitting_m_clr = 0;
	
	gmii_col_m_set = 0; gmii_col_m_clr = 0;
	
	config_cnt_clr = 0; config_cnt_inc = 0;
	
	idle_cnt_m_clr = 0; idle_cnt_m_inc = 0;
	
	gmii_d1_m_set = 0; gmii_d1_m_clr = 0;

	ge_x_pcs_tx_stats_inc = 'd0;
	
	case (pcs_tx_present)
	 
	  S_PCS_TX_TEST_XMIT:
	    begin
 	       transmitting_m_clr = 1; gmii_col_m_clr = 1; gmii_d1_m_clr = 1;
	       
	       pcs_tx_next =  xmit_configuration  ? S_PCS_TX_CONFIGURATION    :
			      xmit_idle           ? S_PCS_TX_IDLE      :  
			      xmit_data           ? S_PCS_TX_XMIT_DATA : S_PCS_TX_TEST_XMIT;
	       
	       idle_cnt_m_clr = xmit_idle; config_cnt_clr = xmit_configuration; 
	    end
        
	  S_PCS_TX_XMIT_DATA:
	    begin
	       
	       idle_cnt_m_inc = idle_cnt_is_clr; idle_cnt_m_clr = ~idle_cnt_is_clr;

	       encoder_8b_rxd_D5_6_m_set  = (~idle_cnt_is_clr & encoder_disparity);
	       encoder_8b_rxd_D16_2_m_set = (~idle_cnt_is_clr & ~encoder_disparity);
	       encoder_8b_rxd_K28_5_m_set = (idle_cnt_is_clr & ~gmii_tx_en);
	       
	       encoder_8b_rxd_K27_7_m_set = (idle_cnt_is_clr & gmii_tx_en);
	       
	       gmii_d1_m_set    = ~idle_cnt_is_clr & gmii_tx_en ;
	       
	       transmitting_m_set = (idle_cnt_is_clr & gmii_tx_en);
	       
	       if (idle_cnt_is_clr & gmii_tx_en & receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
	       
	       if (idle_cnt_is_clr)
		 begin
		    pcs_tx_next = (xmit != `XMIT_DATA)  ? S_PCS_TX_TEST_XMIT  :
				  (~gmii_tx_en)         ? S_PCS_TX_XMIT_DATA  :
				  (gmii_tx_er)          ? S_PCS_TX_DATA_ERROR : S_PCS_TX_PACKET;

		    // Keep count of good frames
		    ge_x_pcs_tx_stats_inc[0] = gmii_tx_en & ~gmii_tx_er;
		    
		    // Keep count of errored frames
		    ge_x_pcs_tx_stats_inc[2] = gmii_tx_en & gmii_tx_er;
		    
		 end
	    end

	  
	  S_PCS_TX_START_ERROR:
	    begin
	       transmitting_m_set = 1;
	      
	       if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;

	       encoder_8b_rxd_K27_7_m_set = 1;

	       pcs_tx_next = S_PCS_TX_DATA_ERROR;
	    end

	  
	  S_PCS_TX_DATA_ERROR:
	    begin
	       if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
	       
	       encoder_8b_rxd_K30_7_m_set = 1;
	       
	       pcs_tx_next = S_PCS_TX_PACKET;
	    end
	  
	  
	  S_PCS_TX_START_OF_PACKET:
	    begin
	       transmitting_m_set = 1; encoder_8b_rxd_K27_7_m_set = 1;
	       
	       if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
	       
	       pcs_tx_next = S_PCS_TX_PACKET;
	    end
	  
	  S_PCS_TX_PACKET:
	    begin
	       idle_cnt_m_clr = 1;
	       
	       // END_OF_PACKET_NOEXT
	       if (~gmii_tx_en & ~gmii_tx_er)
		 begin
		    if (~encoder_tx_even) transmitting_m_clr = 1;
		    
		    gmii_col_m_clr = 1; encoder_8b_rxd_K29_7_m_set = 1;
		    
		    pcs_tx_next = S_PCS_TX_EPD2_NOEXT;
		 end
	       
	       // END_OF_PACKET_EXT
	       else if (~gmii_tx_en & gmii_tx_er)
		 begin
		    if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
		    
		    if (VOID) encoder_8b_rxd_K30_7_m_set = 1; else encoder_8b_rxd_K29_7_m_set = 1;
		    
		    pcs_tx_next = (gmii_tx_er) ? S_PCS_TX_CARRIER_EXTEND : S_PCS_TX_EXTEND_BY_1;
		 end
	       
	       else // TX_DATA
		 begin
		    // Keep count of number of TX bytes
		    ge_x_pcs_tx_stats_inc[1] = 1;
		    
		    if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
		    
		    if (VOID) encoder_8b_rxd_K30_7_m_set = 1; else encoder_8b_rxd_gmii_txd_m_set = 1;
		 end
	    end

	  S_PCS_TX_END_OF_PACKET_NOEXT:
	    begin

	       ge_x_pcs_tx_stats_inc[3] = 1;
	       
	       if (~encoder_tx_even) transmitting_m_clr = 1;
	       
	       gmii_col_m_clr = 1; encoder_8b_rxd_K29_7_m_set = 1;
	       
	       pcs_tx_next = S_PCS_TX_EPD2_NOEXT;
	    end
	  
	  
	  S_PCS_TX_END_OF_PACKET_EXT:
	    begin

	       ge_x_pcs_tx_stats_inc[4] = 1;
	       
	       if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
	       
	       if (VOID) encoder_8b_rxd_K30_7_m_set = 1; else encoder_8b_rxd_K29_7_m_set = 1;

	       pcs_tx_next = (gmii_tx_er) ? S_PCS_TX_CARRIER_EXTEND : S_PCS_TX_EXTEND_BY_1;
	    end
	  
	  S_PCS_TX_EXTEND_BY_1:
	    begin
	       ge_x_pcs_tx_stats_inc[5] = 1;
	       
	       if (~encoder_tx_even) transmitting_m_clr = 1;
	       
	       gmii_col_m_clr = 1; encoder_8b_rxd_K23_7_m_set = 1;
	    
	       pcs_tx_next = S_PCS_TX_EPD2_NOEXT;
	    end

	  
	  S_PCS_TX_CARRIER_EXTEND:
	    begin

	       ge_x_pcs_tx_stats_inc[6] = 1;
	       
	       if (receiving) gmii_col_m_set = 1; else gmii_col_m_clr = 1;
	       
	       if (VOID) encoder_8b_rxd_K30_7_m_set = 1; else encoder_8b_rxd_K23_7_m_set = 1;

	       pcs_tx_next = (~gmii_tx_en & ~gmii_tx_er) ? S_PCS_TX_EXTEND_BY_1 :
			     (gmii_tx_en  &  gmii_tx_er) ? S_PCS_TX_START_ERROR :
			     (gmii_tx_en  & ~gmii_tx_er) ? S_PCS_TX_START_OF_PACKET : 
     		             S_PCS_TX_CARRIER_EXTEND;   
	    end

	  S_PCS_TX_EPD2_NOEXT:
	    begin
	       
	       ge_x_pcs_tx_stats_inc[7] = 1;
	       
	       gmii_d1_m_clr = 1; transmitting_m_clr = 1; encoder_8b_rxd_K23_7_m_set = 1;

	       pcs_tx_next = (encoder_tx_even) ? S_PCS_TX_XMIT_DATA : S_PCS_TX_EPD3;
	    end

	  
	  S_PCS_TX_EPD3:
	    begin
	       ge_x_pcs_tx_stats_inc[8] = 1;
	       
	       encoder_8b_rxd_K23_7_m_set = 1;

	       pcs_tx_next = S_PCS_TX_XMIT_DATA;
	    end
	  
	  //////////////////////////////////////////////////////////////////////////////
	  // IEEE 802.3-2005 Clause 36  Figure 36-6
	    
	  S_PCS_TX_CONFIGURATION:
	    begin
	       encoder_8b_rxd_K28_5_m_set     = config_cnt_K28_5;
	       encoder_8b_rxd_D21_5_m_set     = config_cnt_D21_5;
	       encoder_8b_rxd_D2_2_m_set      = config_cnt_D2_2;
	       encoder_8b_rxd_config_lo_m_set = config_cnt_config_lo;

	       encoder_8b_rxd_config_hi_m_set = config_cnt_config_hi;

	       if ((config_C1_done | config_C2_done))
		 begin
		    pcs_tx_next = (xmit_idle) ? S_PCS_TX_IDLE      :  
				  (xmit_data) ? S_PCS_TX_XMIT_DATA : S_PCS_TX_CONFIGURATION; 
		    
		    idle_cnt_m_clr = xmit_idle;
		 end
	       
	       if (config_C2_done | (config_C1_done & (xmit != `XMIT_CONFIGURATION))) config_cnt_clr = 1; 
	       else                                                                   config_cnt_inc = 1; 
	    end

	  
	  S_PCS_TX_IDLE:
	    begin
	       encoder_8b_rxd_K28_5_m_set =  idle_cnt_is_clr;
	       encoder_8b_rxd_D5_6_m_set  = (idle_cnt_is_set & encoder_disparity);
	       encoder_8b_rxd_D16_2_m_set = (idle_cnt_is_set & ~encoder_disparity);

	       pcs_tx_next = (idle_cnt_done & xmit_data)          ? S_PCS_TX_XMIT_DATA     :
			     (idle_cnt_done & xmit_configuration) ? S_PCS_TX_CONFIGURATION : S_PCS_TX_IDLE;
	       
	       idle_cnt_m_clr = idle_cnt_done; idle_cnt_m_inc = ~idle_cnt_done;
	       
	       config_cnt_clr = (idle_cnt_done & xmit_configuration);
	    end 
	endcase
       
	if (mr_main_reset)      pcs_tx_next = S_PCS_TX_TEST_XMIT;
	 	
     end
       
   
endmodule
