//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_an.v"                               ////
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
//// IEEE Std 802.3-2008 Clause 37" Auto-Negotiation function,    ////
//// type 1000BASE-X"; see :                                      ////
////                                                              ////
//// http://standards.ieee.org/about/get/802/802.3.html           ////
//// and                                                          ////
//// doc/802.3-2008_section3.pdf, Clause 37.                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`include "ge_1000baseX_constants.v"
`include "timescale.v"

module ge_1000baseX_an (
		  
   // --- clocks and reset ---
   input               ck, 
   input               reset,

   // --- Startup interface. ---
   input               startup_enable,
  
   // --- Auto-negotiation ctrl parameter ---
   output reg [2:0]    xmit,
   output reg [15:0]   tx_config,
   input      [15:0]   rx_config,
   input               rx_config_set,
   input               ability_match,
   input               acknowledge_match,
   input               consistency_match,
   input               idle_match,
		    
   // --- RX_UNITDATA.indicate messages from RX state machine ---
   input      [2:0]    rudi,
		    
       
   // --- Synchronisation Status ---
   input               sync_status,
   input               signal_detect,
		    
   // --- GMII Register 0 - AN Basic Control register ---
   input               mr_main_reset,
   input               mr_loopback,
   input               mr_restart_an,
   input               mr_an_enable,

   // --- GMII Register 1 - AN Basic Status register ---		    
   output reg          mr_an_complete,

   // --- GMII register 4 - AN Advertisement		    
   input [15:0]         mr_adv_ability,

   // --- GMII register 5 - AN Link Partner Ability
   output reg [15:0]	mr_lp_adv_ability,
	
   // --- GMII register 6 - AN Expansion
   output reg           mr_np_abl,
   output reg           mr_page_rx,    	   

   // --- GMII register 7 - AN Next Page
   input [15:0]         mr_np_tx,
		
   // --- GMII register 8 - AN Link Partner Next Page
   output reg [15:0]    mr_lp_np_rx	    
 );
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////

   reg 			mr_np_loaded;
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
`ifdef MODEL_TECH
  enum logic [3:0] {
`else
  localparam
`endif
		    S_PCS_AN_STARTUP_RUN          = 0,
		    S_PCS_AN_ENABLE               = 1,
		    S_PCS_AN_RESTART              = 2,
		    S_PCS_AN_DISABLE_LINK_OK      = 3,
		    S_PCS_AN_ABILITY_DETECT       = 4,
		    S_PCS_AN_ACKNOWLEDGE_DETECT   = 5,
		    S_PCS_AN_COMPLETE_ACKNOWLEDGE = 6,
		    S_PCS_AN_IDLE_DETECT          = 7,
		    S_PCS_AN_LINK_OK              = 8,
		    S_PCS_AN_NEXT_PAGE_WAIT       = 9
`ifdef MODEL_TECH
  } pcs_an_present, pcs_an_next;
`else
   ; reg [3:0] pcs_an_present, pcs_an_next;
`endif
   
   //////////////////////////////////////////////////////////////////////////////
   // rx configuration
   //////////////////////////////////////////////////////////////////////////////
     
   wire rx_config_clr = ~rx_config_set;
   
   //////////////////////////////////////////////////////////////////////////////
   //  Link timer
   //////////////////////////////////////////////////////////////////////////////  
 
`ifdef MODEL_TECH
`define LINK_TIMER_DONE 1250
`else
`define LINK_TIMER_DONE 1250000
`endif
   
   reg [20:0] link_timer_cnt;
   reg 	      link_timer_m_start, link_timer_m_inc;
   wire       link_timer_done;

   always @(posedge ck, posedge reset)
    if (reset)
      begin
         link_timer_cnt <= 0;
      end
    else
      begin
	 if      (link_timer_m_start) link_timer_cnt <= 0;
	 else if (link_timer_m_inc) link_timer_cnt <= link_timer_cnt + 1;
      end

      assign link_timer_done = (link_timer_cnt >= `LINK_TIMER_DONE);
   
   //////////////////////////////////////////////////////////////////////////////
   // xmit -  set to tell TX state machine state of AN
   //////////////////////////////////////////////////////////////////////////////
   
   reg 	    xmit_CONFIGURATION_m_set, xmit_DATA_m_set, xmit_IDLE_m_set;
   
   always @(posedge ck, posedge reset)
     if (reset)
       xmit <= `XMIT_IDLE;
     else
       begin  
	  if      (~mr_an_enable & rudi != `RUDI_INVALID) xmit <= `XMIT_DATA;         
	  else if (xmit_CONFIGURATION_m_set)              xmit <= `XMIT_CONFIGURATION; 
	  else if (xmit_DATA_m_set)                       xmit <= `XMIT_DATA;
	  else if (xmit_IDLE_m_set)                       xmit <= `XMIT_IDLE;
       end

   //////////////////////////////////////////////////////////////////////////////
   //  mr_lp_adv_ability - variable to store Link partner capabilities
   //////////////////////////////////////////////////////////////////////////////
   
   reg 	    mr_lp_adv_ability_set, mr_lp_adv_ability_clr;
   
     always @(posedge ck, posedge reset)
       if (reset)
	 mr_lp_adv_ability <= 16'h0;
       else
	 begin
	    if      (mr_lp_adv_ability_set) mr_lp_adv_ability <= rx_config;
	    else if (mr_lp_adv_ability_clr) mr_lp_adv_ability <= 16'h00;
	 end
 
   //////////////////////////////////////////////////////////////////////////////
   //  mr_np_loaded - variable to indicate if the next page has been loaded
   //////////////////////////////////////////////////////////////////////////////   
 
   reg      mr_np_loaded_m_set, mr_np_loaded_m_clr;
  
    always @(posedge ck, posedge reset)
     if (reset)
       mr_np_loaded <= 0;
     else
       begin
	  if       (mr_np_loaded_m_set) mr_np_loaded <= 1;
	  else if  (mr_np_loaded_m_clr) mr_np_loaded <= 0;
       end
    
   //////////////////////////////////////////////////////////////////////////////
   // mr_page_rx_m_clr 
   //////////////////////////////////////////////////////////////////////////////  
 
   reg 	    mr_page_rx_m_set, mr_page_rx_m_clr; 	    
   
   always @(posedge ck, posedge reset)
    if (reset)
      mr_page_rx <= 0;
    else 
      begin
	 if       (mr_page_rx_m_set) mr_page_rx <= 1;
  	 else if  (mr_page_rx_m_clr) mr_page_rx <= 0;
      end
 
   //////////////////////////////////////////////////////////////////////////////
   //  mr_an_complete
   //////////////////////////////////////////////////////////////////////////////
 
   reg       mr_an_complete_m_set, mr_an_complete_m_clr;
   
   always @(posedge ck, posedge reset)
     if (reset)
	mr_an_complete <= 0;
     else
       begin
	  if      (mr_an_complete_m_set) mr_an_complete <= 1;
	  else if (mr_an_complete_m_clr) mr_an_complete <= 0;
       end
   
   //////////////////////////////////////////////////////////////////////////////
   // toggle_tx
   //////////////////////////////////////////////////////////////////////////////
   
   reg toggle_tx, toggle_tx_adv_m_set, toggle_tx_toggle_m_set;

   always @(posedge ck, posedge reset)
     if (reset)
       toggle_tx <= 0;
     else
       begin
	  if      (toggle_tx_adv_m_set)    toggle_tx <= mr_adv_ability[12];
	  else if (toggle_tx_toggle_m_set) toggle_tx <= ~toggle_tx;
       end
   
   //////////////////////////////////////////////////////////////////////////////
   // toggle_rx
   //////////////////////////////////////////////////////////////////////////////   
 
   reg toggle_rx, toggle_rx_m_set;
   
   always @(posedge ck, posedge reset)
     if (reset)
       toggle_rx <= 0;
     else
       begin
	  if (toggle_rx_m_set) toggle_rx <= rx_config[11];
       end
   
   //////////////////////////////////////////////////////////////////////////////
   // tx_config register ctrl
   //////////////////////////////////////////////////////////////////////////////  
   
   reg 	    tx_config_m_clr, tx_config_ABILITY_m_set, tx_config_ACK_m_set, tx_config_NP_m_set;

   always @(posedge ck, posedge reset)
     if (reset)
       tx_config <= 0;
     else
       begin
	  if      (tx_config_m_clr)         tx_config     <= 0;
	  else if (tx_config_ACK_m_set)     tx_config[14] <= 1;
	  else if (tx_config_ABILITY_m_set) tx_config     <= { mr_adv_ability[15],1'b0, mr_adv_ability[13:0]                          };
   	  else if (tx_config_NP_m_set)      tx_config     <= { mr_np_tx[15],      1'b0, mr_np_tx[13:12],     toggle_tx,mr_np_tx[10:0] };
       end

   //////////////////////////////////////////////////////////////////////////////
   // np_rx
   //////////////////////////////////////////////////////////////////////////////
  
   reg  np_rx, np_rx_m_set;
   
    always @(posedge ck, posedge reset)
      if (reset)
	np_rx <= 0;
      else
	begin
	   if (np_rx_m_set) np_rx <= rx_config[15];
	end 
   
   //////////////////////////////////////////////////////////////////////////////
   //  mr_lp_np_rx
   //////////////////////////////////////////////////////////////////////////////   
  
   reg  mr_lp_np_rx_m_set;
   
    always @(posedge ck, posedge reset)
      if (reset)
	mr_lp_np_rx <= 0;
      else
	begin
	   if (mr_lp_np_rx_m_set) mr_lp_np_rx <= rx_config[15];
	end 
   
   //////////////////////////////////////////////////////////////////////////////
   // np_page_rx
   //////////////////////////////////////////////////////////////////////////////
 
   reg        np_page_rx, np_page_rx_m_set;

   always @(posedge ck, posedge reset)
     if (reset)
       np_page_rx <= 0;
     else
       begin
	  if (np_page_rx_m_set) np_page_rx <= 1;
       end 
   
   //////////////////////////////////////////////////////////////////////////////
   // resolve_priority
   //////////////////////////////////////////////////////////////////////////////
  
   reg        resolve_priority, resolve_priority_m_set;
   
   always @(posedge ck, posedge reset)
     if (reset)
       resolve_priority <= 0;
     else
       begin
	  if (resolve_priority_m_set) resolve_priority <= 1;
       end 

   //////////////////////////////////////////////////////////////////////////////
   // autonegotiation state machine registered part
   //////////////////////////////////////////////////////////////////////////////    
   
   always @(posedge ck, posedge reset)
     
     pcs_an_present <= (reset) ? S_PCS_AN_STARTUP_RUN :  pcs_an_next;
   
   //////////////////////////////////////////////////////////////////////////////
   // autonegotiation state machine - IEEE 802.3-2008 Clause 36
   //////////////////////////////////////////////////////////////////////////////
  
   always @*
     begin
	pcs_an_next = pcs_an_present;

	xmit_CONFIGURATION_m_set = 0; xmit_DATA_m_set = 0; xmit_IDLE_m_set = 0;
	
	mr_np_loaded_m_set = 0; mr_np_loaded_m_clr = 0;
	
	mr_page_rx_m_set = 0;  mr_page_rx_m_clr = 0;
	
	mr_an_complete_m_set = 0;  mr_an_complete_m_clr = 0;
	
	mr_lp_adv_ability_set = 0;  mr_lp_adv_ability_clr = 0;
	
	tx_config_m_clr = 0; tx_config_ABILITY_m_set = 0;tx_config_ACK_m_set = 0;tx_config_NP_m_set = 0;
	
	link_timer_m_start = 0; link_timer_m_inc = 0;
	
	toggle_tx_adv_m_set = 0; toggle_tx_toggle_m_set = 0;
	
	toggle_rx_m_set = 0; mr_lp_np_rx_m_set = 0; np_rx_m_set = 0; np_page_rx_m_set = 0;
	
	resolve_priority_m_set = 0;
        
	case (pcs_an_present)

	  S_PCS_AN_STARTUP_RUN:
	    begin
	       pcs_an_next = startup_enable ? S_PCS_AN_ENABLE: S_PCS_AN_STARTUP_RUN;
	    end

	
	  S_PCS_AN_ENABLE:
	    begin
	       mr_page_rx_m_clr = 1;  mr_lp_adv_ability_clr = 1; mr_an_complete_m_clr = 1;
	       
	       if (mr_an_enable)  
		 begin
		    xmit_CONFIGURATION_m_set = 1; tx_config_m_clr = 1;  
		 end
	       else xmit_IDLE_m_set = 1;
	       
	       pcs_an_next = (mr_an_enable) ? S_PCS_AN_RESTART  : S_PCS_AN_DISABLE_LINK_OK; 
	    
	       link_timer_m_start = mr_an_enable;
	    end

	  S_PCS_AN_RESTART:
	    begin
	       mr_np_loaded_m_clr = 1; tx_config_m_clr = 1; xmit_CONFIGURATION_m_set = 1;
	       
	       pcs_an_next = (link_timer_done) ? S_PCS_AN_ABILITY_DETECT : S_PCS_AN_RESTART;
	       
	       link_timer_m_inc = ~link_timer_done;
	    end
	  
	  S_PCS_AN_DISABLE_LINK_OK:
	    begin
	       xmit_DATA_m_set = 1;
	       
               pcs_an_next = S_PCS_AN_DISABLE_LINK_OK;
             end

	  S_PCS_AN_ABILITY_DETECT:
	    begin
	       toggle_tx_adv_m_set = 1; tx_config_ABILITY_m_set = 1;

	       pcs_an_next = (ability_match & rx_config_set) ? S_PCS_AN_ACKNOWLEDGE_DETECT : S_PCS_AN_ABILITY_DETECT;

	       mr_lp_adv_ability_set = (ability_match & rx_config_set);

	    end

	  S_PCS_AN_ACKNOWLEDGE_DETECT:
	    begin
	       tx_config_ACK_m_set = 1;

	       pcs_an_next = (acknowledge_match & consistency_match)  ? S_PCS_AN_COMPLETE_ACKNOWLEDGE : 
			     (acknowledge_match & ~consistency_match) ? S_PCS_AN_ENABLE               :
			     (ability_match & rx_config_clr)          ? S_PCS_AN_ENABLE               : S_PCS_AN_ACKNOWLEDGE_DETECT;
	       
	       link_timer_m_start = (acknowledge_match & consistency_match);
	    end

	  S_PCS_AN_COMPLETE_ACKNOWLEDGE:
	    begin
	       toggle_tx_toggle_m_set = 1; toggle_rx_m_set = 1; np_rx_m_set = 1; mr_page_rx_m_set = 1;

	       if (ability_match & rx_config_clr)  pcs_an_next = S_PCS_AN_ENABLE;

	       else if (link_timer_done & (~ability_match | rx_config_set)) 
		 begin
		    link_timer_m_start = 1;  pcs_an_next = S_PCS_AN_IDLE_DETECT;
		 end
	       
	       else link_timer_m_inc = ~link_timer_done;
	    end

	  S_PCS_AN_IDLE_DETECT:
	    begin
	       xmit_IDLE_m_set = 1; resolve_priority_m_set = 1;
	       
	       pcs_an_next = (ability_match & rx_config_clr) ? S_PCS_AN_ENABLE : 
			     (idle_match & link_timer_done)  ? S_PCS_AN_LINK_OK : S_PCS_AN_IDLE_DETECT;
	       
	       link_timer_m_inc = ~link_timer_done;
	    end
	  
	  S_PCS_AN_LINK_OK:
	    begin
	       xmit_DATA_m_set = 1; mr_an_complete_m_set = 1; resolve_priority_m_set = 1;
	       
	       pcs_an_next = (ability_match | mr_restart_an) ? S_PCS_AN_ENABLE : S_PCS_AN_LINK_OK;	       
	    end
	endcase 
	     
	if      (~sync_status)          pcs_an_next = S_PCS_AN_ENABLE;
	else if (mr_main_reset)         pcs_an_next = S_PCS_AN_ENABLE;
        else if (mr_restart_an)   	pcs_an_next = S_PCS_AN_ENABLE;
        else if (rudi == `RUDI_INVALID) pcs_an_next = S_PCS_AN_ENABLE;
     end
     
endmodule
