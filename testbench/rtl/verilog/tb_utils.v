//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tb_utils.v"                                         ////
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
//// Model of the  IEEE 802.3-2008 Clause 22 MDIO/MDC management  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

package tb_utils;
   
  class VirIntfHandle;
     
   virtual serial_model_if      serial_model;            

   // GMII models
   virtual gmii_tx_if           gmii_tx_model;  
   virtual gmii_rx_if           gmii_rx_model;

   // 8B/10B models
   virtual encoder_8b_tx_if     encoder_8b_tx_model;
   virtual encoder_10b_rx_if    encoder_10b_rx_model;
   virtual decoder_8b_rx_if     decoder_8b_rx_model;
     
  endclass

  function automatic string hexformat(int data[], string fmt="0x%02x", string joiner=", ");
    string buffer = "";
    string temp;
    for(int i=0; i<data.size(); i++)
      begin
        $sformat(temp, fmt, data[i]);
        if(i!=0)
          buffer = {buffer, joiner, temp};
        else
          buffer = {buffer, temp};
      end
    return buffer;
  endfunction

  function automatic string hexpretty(int data[], int n_start=4, int n_end=4);
    int n = data.size();

    if(n < n_start+n_end)
      return hexformat(data, "0x%02x", ",");
    else
      begin
        int head[] = new[n_start];
        int tail[] = new[n_end];
        string s;

        for(int i=0; i<n_start; i++)
          head[i] = data[i];

        for(int i=0; i<n_end; i++)
          tail[i] = data[n-n_end+i];

        $sformat(s, "%s...%s",
                 hexformat(head, "0x%02x", ","),
                 hexformat(tail, "0x%02x", ",")
                );
        return s;
      end
  endfunction

  
   
endpackage

