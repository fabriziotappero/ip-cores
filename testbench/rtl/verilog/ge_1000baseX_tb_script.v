/////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_tb_script.v"                        ////
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
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

package ge_1000baseX_tb_script;
  
   import tb_utils::VirIntfHandle;
   
   import ethernet_threads::EthernetFlow;
   import ethernet_threads::GmiiTxThread;
   import ethernet_threads::GmiiRxThread;
      
   import ge_1000baseX_utils::reg_read;
   import ge_1000baseX_utils::reg_write;
   import ge_1000baseX_utils::read_phy_ident;
   import ge_1000baseX_utils::unplug_fo;
   import ge_1000baseX_utils::insert_fo;
   import ge_1000baseX_utils::restart_aneg; 
   import ge_1000baseX_utils::read_aneg_link_partner_capablities;
   import ge_1000baseX_utils::reset_aneg;
   import ge_1000baseX_utils::aneg_complete_poll;
   import ge_1000baseX_utils::signal_detect_poll;

   import ethernet_frame::ETH_A_TB;
   import ethernet_frame::ETH1000;
   
   task automatic main(VirIntfHandle vih, ref int errors);
      
      EthernetFlow eFlow = new();
      
      # 3us;
      
      vih.gmii_tx_model.set_speed(ETH1000); vih.gmii_rx_model.set_speed(ETH1000);
      
      read_phy_ident(vih);

      // Simulate inserting FO cable and wait for signal_detect
      insert_fo(vih); signal_detect_poll(vih);

      // Force ANEG restart and wait for ANEG with link partner 
      restart_aneg(vih); aneg_complete_poll(vih);

      // Display link partner capabilities
      read_aneg_link_partner_capablities(vih);

      eFlow.clear();
      
      $display("%m: Starting Ethernet frame (GMII <-> 1000baseX) tests");
      
      eFlow.create(GmiiTxThread::NEW(vih.gmii_tx_model, ETH_A_TB, ETH_A_TB, -64, 10, 96ns),
		   GmiiRxThread::NEW(vih.gmii_rx_model, ETH_A_TB, 250us, 250us, .dut_will_pad(0)));
      
      eFlow.start(errors); if (errors) return;
      
   endtask
   
endpackage

