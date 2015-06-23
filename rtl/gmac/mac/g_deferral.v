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
//`timescale 1ns/100ps

/***************************************************************
  Description:
  deferral.v : This block performs the deferral algorithm for
               half duplex mode, as per the IEEE 802.3 section 4.2.3.2.2
               This block also implements the optional two part deferral
               mechanism.
***********************************************************************/

module g_deferral (
		 df2tx_dfl_dn,	
		 cf2df_dfl_single,
		 phy_tx_en,
		 phy_tx_er,
		 tx_clk,
		 app_reset_n);


  input [7:0] cf2df_dfl_single;           //program with 9.6 ms
  input	       phy_tx_en;                 //TX frame is done, wait for IPG
                                          //used in FULL duplex
  input	       phy_tx_er;                 //TX Error 
  input	       tx_clk;              //MII provided tx_clk
  input	       app_reset_n;

  output       df2tx_dfl_dn;              //when active hold the TX, else
                                    //TX can send preamble  

  wire	       df2tx_dfl_dn;

  parameter    dfl_idle_st =        6'b000000;
  parameter    dfl_dfl_st =         6'b000010;
  parameter    dfl_full_tx_dn_st =  6'b010000;
  parameter    dfl_wipg_st =        6'b100000;

  reg [5:0]    curr_dfl_st, nxt_dfl_st;
  reg	       dfl_dn;
  reg	       strt_dfl;
  reg [7:0]   dfl_cntr;

  reg         phy_tx_en_d;

  wire        was_xmitted;
  
  assign df2tx_dfl_dn = dfl_dn;
  /*****************************************************************
   * Synchronous process for the FSM to enable and disable TX on
   * receive activity
   *****************************************************************/
  always @(posedge tx_clk or negedge app_reset_n)
    begin
      if (!app_reset_n)
	curr_dfl_st <= dfl_idle_st;
      else
	curr_dfl_st <= nxt_dfl_st;
    end // always @ (posedge tx_clk or negedge app_reset_n)

  /*****************************************************************
   * comb        process for the FSM to enable and disable TX on
   * receive activity
   *****************************************************************/
  always @(curr_dfl_st or dfl_cntr 
	   or phy_tx_en or phy_tx_er or was_xmitted)
    begin
      strt_dfl = 0;
      dfl_dn = 0;
      nxt_dfl_st = curr_dfl_st;
      
      case (curr_dfl_st)
	dfl_idle_st :
	  begin
	    dfl_dn = 1;
	    if (phy_tx_en)
	      begin
		dfl_dn = 0;
		nxt_dfl_st = dfl_full_tx_dn_st;
	      end // if (phy_tx_en)
	    else
	      nxt_dfl_st = dfl_idle_st;
	  end // case: dfl_idle_st

	dfl_full_tx_dn_st :
	  begin
	    // full duplex mode, wait till the current tx
	    // frame is transmitted and wait for IPG time,
	    // no need to wait for two part defferal
	    if (!phy_tx_en && !phy_tx_er)
	      begin
		strt_dfl = 1;
		nxt_dfl_st = dfl_wipg_st;
	      end // if (!phy_tx_en)
	    else
	      nxt_dfl_st = dfl_full_tx_dn_st;
	  end // case: dfl_full_tx_dn_st

	dfl_wipg_st :
	  begin
	    // This state is reached when there is no transmit
	    // in progress. In this state IPG counter should checked
	    // and upon its expiry indicate deferral done
	    // to tx_fsm block
	    if (dfl_cntr == 8'd0)
	      begin
	        dfl_dn = 1;
		nxt_dfl_st = dfl_idle_st;
              end
            else
	      nxt_dfl_st = dfl_wipg_st;
	  end // case: dfl_wipg_st

	default :
	  begin
	    nxt_dfl_st = dfl_idle_st;
	  end
      endcase // case (curr_dfl_st)
    end // always @ (curr_dfl_st )

  //counter for the single phase deferral scheme
  always @(posedge tx_clk or negedge app_reset_n)
    begin
      if (!app_reset_n)
	dfl_cntr <= 8'd0;
      else
	begin
	  if (strt_dfl)
            begin
	       dfl_cntr <= cf2df_dfl_single;
            end
	  else
	    dfl_cntr <= dfl_cntr - 1;
	end // else: !if(app_reset_n)
    end // always @ (posedge tx_clk or negedge app_reset_n)


   // Mandar
   // Detect Packet end
   assign was_xmitted = (phy_tx_en_d == 1'b1 && phy_tx_en == 1'b0) ? 1'b1 : 1'b0;


   always @(posedge tx_clk or negedge app_reset_n)
     begin
       if (!app_reset_n)
          phy_tx_en_d <= 1'b0;
       else
          phy_tx_en_d <= phy_tx_en;
     end // always @ (posedge tx_clk or negedge app_reset_n)



endmodule // deferral

  
  
		 
