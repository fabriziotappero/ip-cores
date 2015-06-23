//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
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

/***************************************************************
  Description:
  deferral.v : This block performs the deferral algorithm for
               half duplex mode, as per the IEEE 802.3 section 4.2.3.2.2
               This block also implements the optional two part deferral
               mechanism.
***********************************************************************/

module g_deferral_rx (
		 rx_dfl_dn,	
		 dfl_single,
		 rx_dv,
		 rx_clk,
		 reset_n);


  input [7:0] dfl_single;           //program with 9.6 ms
  input	       rx_dv;               //TX frame is done, wait for IPG
                                    //used in FULL duplex
  input	       rx_clk;              //MII provided rx_clk
  input	       reset_n;

  output       rx_dfl_dn;              //when active hold the TX, else
                                    //TX can send preamble  

  parameter    dfl_idle_st =        6'b000000;
  parameter    dfl_dfl_st =         6'b000010;
  parameter    dfl_full_tx_dn_st =  6'b010000;
  parameter    dfl_wipg_st =        6'b100000;

  reg [5:0]    curr_dfl_st, nxt_dfl_st;
  reg	       rx_dfl_dn;
  reg	       strt_dfl;
  reg [8:0]   fst_dfl_cntr;
  reg [8:0]   dfl_cntr;
  reg [8:0]   scnd_dfl_cntr;
  
  /*****************************************************************
   * Synchronous process for the FSM to enable and disable TX on
   * receive activity
   *****************************************************************/
  always @(posedge rx_clk or negedge reset_n)
    begin
      if (!reset_n)
	curr_dfl_st <= dfl_idle_st;
      else
	curr_dfl_st <= nxt_dfl_st;
    end // always @ (posedge rx_clk or negedge reset_n)

  /*****************************************************************
   * comb        process for the FSM to enable and disable TX on
   * receive activity
   *****************************************************************/
  always @(curr_dfl_st or dfl_cntr or rx_dv)
    begin
      strt_dfl = 0;
      rx_dfl_dn = 0;
      nxt_dfl_st = curr_dfl_st;
      
      case (curr_dfl_st)
	dfl_idle_st :
	  begin
	    rx_dfl_dn = 1;
	    if (rx_dv)
	      begin
		rx_dfl_dn = 0;
		nxt_dfl_st = dfl_full_tx_dn_st;
	      end // if (rx_dv)
	    else
	      nxt_dfl_st = dfl_idle_st;
	  end // case: dfl_idle_st

	dfl_full_tx_dn_st :
	  begin
	    // full duplex mode, wait till the current tx
	    // frame is transmitted and wait for IPG time,
	    // no need to wait for two part defferal
	    if (!rx_dv)
	      begin
		strt_dfl = 1;
		nxt_dfl_st = dfl_wipg_st;
	      end // if (!rx_dv)
	    else
	      nxt_dfl_st = dfl_full_tx_dn_st;
	  end // case: dfl_full_tx_dn_st

	dfl_wipg_st :
	  begin
	    // This state is reached when there is no transmit
	    // in progress. In this state IPG counter should checked
	    // and upon its expiry indicate deferral done
	    // to tx_fsm block
	    if (dfl_cntr == 9'd0)
	      begin
	        rx_dfl_dn = 1;
		nxt_dfl_st = dfl_idle_st;
              end
            else
	      nxt_dfl_st = dfl_wipg_st;
	  end // case: dfl_wipg_st

	dfl_dfl_st :
	  //wait in this state till deferral time is done
	  //if CRS is active before the deferral time
	  //restart the deferral process again
	  begin
	      begin
		if (dfl_cntr == 9'd0)
		  begin
		      rx_dfl_dn = 1;
		      nxt_dfl_st = dfl_idle_st;
		  end
		else
		  nxt_dfl_st = dfl_dfl_st;
	      end // 
	  end // case: dfl_dfl_st
	
	default :
	  begin
	    nxt_dfl_st = dfl_idle_st;
	  end
      endcase // case (curr_dfl_st)
    end // always @ (curr_dfl_st  )

  //counter for the single phase deferral scheme
  always @(posedge rx_clk or negedge reset_n)
    begin
      if (!reset_n)
	dfl_cntr <= 9'd0;
      else
	begin
	  if (strt_dfl)
	    begin
	      dfl_cntr[7:0] <= dfl_single;
	      dfl_cntr[8] <= 0;
	    end
	  else
	    dfl_cntr <= dfl_cntr - 1;
	end // else: !if(reset_n)
    end // always @ (posedge rx_clk or negedge reset_n)

endmodule // deferral

  
  
		 
