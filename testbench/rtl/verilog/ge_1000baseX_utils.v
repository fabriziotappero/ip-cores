//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_utils.v"                            ////
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

`include "ge_1000baseX_regs.v"

package ge_1000baseX_utils;
   
   import tb_utils::VirIntfHandle;
   
   task automatic reg_write(VirIntfHandle vih, int addr, reg [15:0] data);
    
      vih.serial_model.write(addr, data);
     
   endtask 
   
   task automatic reg_read(VirIntfHandle vih, int addr, output reg [15:0] val);
      
      vih.serial_model.read(addr, val);
       
   endtask
      
   task automatic signal_detect_ctrl(VirIntfHandle vih, int s);
   
      reg [15:0] b;
      
      reg_read(vih,`GMII_BASIC_CTRL, b);
      
      if (s==0) begin b &= ~(16'h0800); end else begin b |= 16'h0800; end
      
      reg_write(vih, `GMII_BASIC_CTRL, (b & 16'hffff));
      
   endtask
   
   task automatic unplug_fo(VirIntfHandle vih);

      $display("%m: FO interface unplugged", );
      
      signal_detect_ctrl(vih, 0);
      
   endtask // automatic
   
    task automatic insert_fo(VirIntfHandle vih);
       
       $display("%m: FO interface inserted");
       
       signal_detect_ctrl(vih, 1);
       
    endtask // automatic

   task automatic read_phy_ident(VirIntfHandle vih);
      
      reg [15:0] id1,  id2;
      
      reg_read(vih,`GMII_PHY_ID1, id1); reg_read(vih,`GMII_PHY_ID2, id2);
      
      $display("%m: 1000baseX PCS OUI: %02h%02h%02h - ver %02d.%02d", 
	       id1[7:0], id1[15:8], id2[7:0], id2[15:12], id2[11:8]);
      
   endtask
 
   task automatic reset_aneg(VirIntfHandle vih);

      reg [15:0] basic_ctrl;
            
      $display("%m");

      reg_read(vih,`GMII_BASIC_CTRL, basic_ctrl);
      
      basic_ctrl = (basic_ctrl & 16'hffff) | 16'h8000;
      
      reg_write(vih, `GMII_BASIC_CTRL, basic_ctrl);

   endtask // automatic
   
   task automatic restart_aneg(VirIntfHandle vih);

      reg [15:0] basic_ctrl;
     
      $display("%m");
      
      reg_read(vih,`GMII_BASIC_CTRL, basic_ctrl);
      
      basic_ctrl = (basic_ctrl & 16'hffff) | 16'h0200;

      reg_write(vih, `GMII_BASIC_CTRL, basic_ctrl);

   endtask // automatic


   task automatic signal_detect_poll(VirIntfHandle vih);
      
      reg [15:0] status =  0; reg [31:0] counter = 0;
      
      $display("%m");
      
      while(!status[2])
	begin
	   reg_read(vih, `GMII_BASIC_STATUS, status);
	   
	   $display("%m: %u: Waiting for signal_detect - status is %16b", counter, status);
	   counter +=1;
	end
      
   endtask
   
   task automatic aneg_complete_poll(VirIntfHandle vih);

      reg [31:0] cnt = 0; reg [15:0] basic_status =  0;
     
      $display("%m");
      
      while(!basic_status[5])
	begin
	   reg_read(vih, `GMII_BASIC_STATUS, basic_status);  cnt +=1;
	
	   $display("%m: Polling ANEG complete : %16b : attempt %d", basic_status, cnt);
	   
	end
   endtask

     task automatic read_aneg_link_partner_capablities(VirIntfHandle vih);

      reg [15:0] lp_adv;
      
      reg_read(vih,`GMII_AN_LP_ADV, lp_adv);

      $display("%m: ANEG Link Partner capability: %04h", lp_adv);
      
   endtask 

   
endpackage 

   

