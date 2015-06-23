
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_sync.v"                             ////
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

`include "timescale.v"

module ge_1000baseX_sync(

   //  clocks and reset 
   input               ck,
   input               reset,
   
   //  Startup interface. 
   input               startup_enable,

   //  Signal detect from FO transceiver 	     
   input               signal_detect,
		     
   //  Receive EBI bus from 8b10 decode 
   input [7:0] 	       ebi_rxd,
   input               ebi_K,

   output reg [7:0]    ebi_rxd_out,
   output reg          ebi_K_out,
		     
   //  8B/10B disparity and coding errors 
   input               decoder_disparity_err,
   input               decoder_coding_err,		     
		     
   //  RX sync status 
   output reg          sync_status,
		     
   output reg          rx_even,

   input               loopback
   );
   
   //////////////////////////////////////////////////////////////////////////////
   //  Running Disparity
   //////////////////////////////////////////////////////////////////////////////  
   
   reg 		       running_disparity;
   reg 		       running_disparity_positive_m_set;
   reg 		       running_disparity_negative_m_set;

   always @(posedge ck, posedge reset)

     // Assume negative (0) disparity at startup
     if (reset) running_disparity <= 0;

     else
       begin
	  if      (running_disparity_positive_m_set) running_disparity <= 1;
	  else if (running_disparity_negative_m_set) running_disparity <= 0;
       end

   //////////////////////////////////////////////////////////////////////////////
   // sync_status ctrl
   //////////////////////////////////////////////////////////////////////////////

   reg 		       sync_m_acquired, sync_m_lost;
   
   always @(posedge ck, posedge reset)
     if (reset) 
       sync_status <= 0;
     else
       begin
	  if      (sync_m_acquired) begin sync_status <= 1; end
	  else if (sync_m_lost)     begin sync_status <= 0; end
       end

   //////////////////////////////////////////////////////////////////////////////
   // rx_even reg
   //////////////////////////////////////////////////////////////////////////////   
   
   reg 	  rx_even_m_init, rx_even_m_set, rx_even_m_clr, rx_even_m_toggle;
   
   always @(posedge ck, posedge reset)
     if (reset)
       rx_even <= 1;
     else
	begin
	   if      (rx_even_m_init)   rx_even <= 1;
	   else if (rx_even_m_set)    rx_even <= 1;
	   else if (rx_even_m_clr)    rx_even <= 0;
	   else if (rx_even_m_toggle) rx_even <= ~rx_even;
	end
   
   //////////////////////////////////////////////////////////////////////////////
   //  COMMAs can be K28.1, K28.5 or K28.7 - see table 36-2 pg 45
   //////////////////////////////////////////////////////////////////////////////   
      
   reg [7:0]    ebi_rxd_d1;  reg          ebi_K_d1;
   				 
   always @(posedge ck, posedge reset)
     if (reset)
       begin ebi_rxd_d1 <= 0; ebi_K_d1 <= 0; end
     else
       begin ebi_rxd_d1 <= ebi_rxd; ebi_K_d1 <= ebi_K; end
   
   
   always @(posedge ck, posedge reset)
     if (reset)
       begin ebi_rxd_out <= 0; ebi_K_out <=0; end
     else
       begin ebi_rxd_out <= ebi_rxd_d1; ebi_K_out <= ebi_K_d1; end
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////   
   
   assign   K28_1_RX  = (ebi_rxd_d1 == `K28_1_symbol);
   assign   K28_5_RX  = (ebi_rxd_d1 == `K28_5_symbol);
   assign   K28_7_RX  = (ebi_rxd_d1 == `K28_7_symbol);
   
   assign   COMMA_RX = K28_1_RX | K28_5_RX | K28_7_RX;
  
   assign   COMMA_match  = COMMA_RX & ebi_K_d1;

`ifdef MODEL_TECH
   wire [4:0] ebi_rxd_X;  wire [2:0] ebi_rxd_Y;
   
   assign     ebi_rxd_X = ebi_rxd[4:0];
   assign     ebi_rxd_Y = ebi_rxd[7:5];
`endif
   
   //////////////////////////////////////////////////////////////////////////////
   //  Definition of /INVLAID/ as per section 36.2.4.6
   //////////////////////////////////////////////////////////////////////////////   
   reg 	      INVALID;
   
   always @(posedge ck, posedge reset)
     
     INVALID <= (reset) ? 0 : decoder_disparity_err | decoder_coding_err;
   
   assign VALID = ~INVALID;
   
   //////////////////////////////////////////////////////////////////////////////
   //  good_cgs ctrl
   //////////////////////////////////////////////////////////////////////////////   
      
   reg [2:0] 	       good_cgs;
   reg 		       good_cgs_m_init, good_cgs_m_inc, good_cgs_m_cnt;
   	       
   always @(posedge ck, posedge reset)
     if (reset)
       good_cgs <= 0;
     else
       begin
	  if      (good_cgs_m_init)  good_cgs <= 0;
	  else if (good_cgs_m_cnt)   good_cgs <= 1;
	  else if (good_cgs_m_inc)   good_cgs <= good_cgs + 1 ;
	  
       end
   
   assign good_cgs_done = (good_cgs == 3);

   assign cgbad = INVALID | (COMMA_match & rx_even);
   
   assign cggood = ~cgbad;
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
    
`ifdef MODEL_TECH
  enum logic [3:0] {
`else
  localparam
`endif
		    S_PCS_SYNC_RUN            = 0,
		    S_PCS_SYNC_LOSS_OF_SYNC   = 1,
		    S_PCS_SYNC_COMMA_DETECT_1 = 2,
		    S_PCS_SYNC_ACQUIRE_SYNC_1 = 3,
		    S_PCS_SYNC_COMMA_DETECT_2 = 4,
		    S_PCS_SYNC_ACQUIRE_SYNC_2 = 5,
		    S_PCS_SYNC_COMMA_DETECT_3 = 6,
		    S_PCS_SYNC_ACQUIRED_1     = 7,
		    S_PCS_SYNC_ACQUIRED_2     = 8,
		    S_PCS_SYNC_ACQUIRED_3     = 9,
		    S_PCS_SYNC_ACQUIRED_4     = 10,
		    S_PCS_SYNC_ACQUIRED_2A    = 11,
		    S_PCS_SYNC_ACQUIRED_3A    = 12,
		    S_PCS_SYNC_ACQUIRED_4A    = 13
`ifdef MODEL_TECH
  } pcs_sync_present, pcs_sync_next;
`else
   ; reg [3:0] pcs_sync_present, pcs_sync_next;
`endif
 
   //////////////////////////////////////////////////////////////////////////////
   // sync state machine registered part.
   //////////////////////////////////////////////////////////////////////////////   
   
   always @(posedge ck or posedge reset)

     pcs_sync_present <= (reset) ? S_PCS_SYNC_RUN : pcs_sync_next;
   
   //////////////////////////////////////////////////////////////////////////////
   //  sync state machine  - IEEE 802.3-2008 Clause 36  Figure 36-9
   //////////////////////////////////////////////////////////////////////////////      
   
   always @*
     begin	
	pcs_sync_next = pcs_sync_present;
	
	good_cgs_m_init = 0; good_cgs_m_inc = 0; good_cgs_m_cnt = 0;
	
	sync_m_acquired = 0; sync_m_lost = 0;
	
	rx_even_m_init = 0; rx_even_m_set = 0; rx_even_m_clr = 0; rx_even_m_toggle = 0;
	
	running_disparity_negative_m_set = 0; running_disparity_positive_m_set = 0;
	
	case (pcs_sync_present)
	  
	  S_PCS_SYNC_RUN:
	    begin
	       if (startup_enable) pcs_sync_next = S_PCS_SYNC_LOSS_OF_SYNC;
	    end
  
	  S_PCS_SYNC_LOSS_OF_SYNC :
	    begin

	       sync_m_lost = sync_status; 
	       
	       if ((signal_detect | loopback) & COMMA_match)
		 begin
		    rx_even_m_set = 1; pcs_sync_next = S_PCS_SYNC_COMMA_DETECT_1;
		 end
	       else    
		 rx_even_m_toggle = 1;
	    end
	  
	  S_PCS_SYNC_COMMA_DETECT_1 :
	    begin
	       rx_even_m_toggle = 1;
	       
	       pcs_sync_next = (~ebi_K_d1 & ~cgbad) ? S_PCS_SYNC_ACQUIRE_SYNC_1 : S_PCS_SYNC_LOSS_OF_SYNC;
	    end
	  
	  S_PCS_SYNC_ACQUIRE_SYNC_1:
	    begin
	       if (~rx_even & COMMA_match) 
		 begin 
		    rx_even_m_set = 1; pcs_sync_next = S_PCS_SYNC_COMMA_DETECT_2;
		 end
	       else
		 begin
		    rx_even_m_toggle = 1;
	    
		    pcs_sync_next = (~COMMA_match & ~INVALID) ? S_PCS_SYNC_ACQUIRE_SYNC_1 : S_PCS_SYNC_LOSS_OF_SYNC;	       
		 end
	    end
	       
	  S_PCS_SYNC_COMMA_DETECT_2:
	    begin
	       rx_even_m_toggle = 1;
	     
	       pcs_sync_next = (~ebi_K_d1 & ~cgbad) ? S_PCS_SYNC_ACQUIRE_SYNC_2 : S_PCS_SYNC_LOSS_OF_SYNC;
	    end
	  
	  S_PCS_SYNC_ACQUIRE_SYNC_2:
	    begin
	       if (~rx_even & COMMA_match)
		 begin
		    rx_even_m_set = 1; pcs_sync_next = S_PCS_SYNC_COMMA_DETECT_3;
		 end
	       else
		 begin
		    rx_even_m_toggle = 1;
		    
		    pcs_sync_next = (~COMMA_match & ~INVALID) ? S_PCS_SYNC_ACQUIRE_SYNC_2 : S_PCS_SYNC_LOSS_OF_SYNC;
		 end
	    end
	  
	  S_PCS_SYNC_COMMA_DETECT_3:
	    begin
	       rx_even_m_toggle = 1;
	       
	       pcs_sync_next = (~ebi_K_d1 & ~cgbad) ? S_PCS_SYNC_ACQUIRED_1 : S_PCS_SYNC_LOSS_OF_SYNC;
	       
	       sync_m_acquired = ~ebi_K_d1;
	    end 
	  
	  S_PCS_SYNC_ACQUIRED_1:
	    begin
	       rx_even_m_toggle = 1;

	       pcs_sync_next = cggood ? S_PCS_SYNC_ACQUIRED_1 : S_PCS_SYNC_ACQUIRED_2;
	    end
	  
	  S_PCS_SYNC_ACQUIRED_2:
	    begin
	       rx_even_m_toggle = 1;
	       
	       if (cggood) good_cgs_m_cnt = 1; else good_cgs_m_init = 1;
	       
	       pcs_sync_next = cggood ? S_PCS_SYNC_ACQUIRED_2A : S_PCS_SYNC_ACQUIRED_3;
	    end 
	  
	  S_PCS_SYNC_ACQUIRED_3:
	    begin
	   
	       rx_even_m_toggle = 1; 
	   
	       if (cggood) good_cgs_m_cnt = 1; else good_cgs_m_init = 1;
	       
	       pcs_sync_next = cggood ? S_PCS_SYNC_ACQUIRED_3A: S_PCS_SYNC_ACQUIRED_4;
	    end
	  
	  S_PCS_SYNC_ACQUIRED_4:
	    begin
	    
	       rx_even_m_toggle = 1; 
	       
	       if (cggood) good_cgs_m_cnt = 1; else good_cgs_m_init = 1;
	       
	       pcs_sync_next = cggood ? S_PCS_SYNC_ACQUIRED_4A: S_PCS_SYNC_LOSS_OF_SYNC;
	    end
   
	  S_PCS_SYNC_ACQUIRED_2A:
	    begin
	       rx_even_m_toggle = 1; good_cgs_m_inc = 1;

	       pcs_sync_next = (cgbad)         ? S_PCS_SYNC_ACQUIRED_3 :
			       (good_cgs_done) ? S_PCS_SYNC_ACQUIRED_1 : S_PCS_SYNC_ACQUIRED_2A; 
	    end
	  
	  S_PCS_SYNC_ACQUIRED_3A:
	    begin
	       rx_even_m_toggle = 1; good_cgs_m_inc = 1;

	        pcs_sync_next = (cgbad)         ? S_PCS_SYNC_ACQUIRED_4 :
			        (good_cgs_done) ? S_PCS_SYNC_ACQUIRED_2 : S_PCS_SYNC_ACQUIRED_3A; 
	    end
  
	  S_PCS_SYNC_ACQUIRED_4A:
	    begin
	       rx_even_m_toggle = 1; good_cgs_m_inc = 1;
	       
	       pcs_sync_next = (cgbad)         ? S_PCS_SYNC_LOSS_OF_SYNC :
			       (good_cgs_done) ? S_PCS_SYNC_ACQUIRED_3   : S_PCS_SYNC_ACQUIRED_4A; 
	    end 
	  
	endcase 
	
	if (~signal_detect) pcs_sync_next = S_PCS_SYNC_LOSS_OF_SYNC;	
     end

endmodule
