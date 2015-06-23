//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "gmii_rx_model.v"                                 ////
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

module gmii_rx_model #(
  parameter DEBUG     = 0,
  parameter REDUCED   = 0, 
  parameter in_delay  = 2
)(
  interface check_intf,

  input         mii_rxck_in,
  input         gmii_rxck_in,
  output        mii_rxck_out,

  input [7:0]   rxd,
  input         rx_dv,
  input         rx_er
);
   
   import tb_utils::hexformat; 
   
   import ethernet_frame::EthernetFrame;
   import ethernet_frame::EthernetSpeed;
   import ethernet_frame::ETH10;
   import ethernet_frame::ETH1000; 
   import ethernet_frame::ethernet_inter_frame_gap;
   import ethernet_frame::ethernet_address_t;
   import ethernet_frame::ethernet_preamble_len;
   import ethernet_frame::FrameMailBox;
   import ethernet_frame::fmt_addr;
   import ethernet_frame::ethernet_preamble;
   import ethernet_frame::ethernet_sfd;
   
  wire [7:0] tmp_rxd;
  wire       tmp_rx_dv, tmp_rx_er;

   assign #in_delay tmp_rx_dv = rx_dv;
   assign #in_delay tmp_rx_er = rx_er;
   assign #in_delay tmp_rxd   = rxd;
   
   EthernetSpeed  speed = ETH1000;
   
   reg 	     mii_rxck10baseT;
   
   wire      rx_clk  = (speed == ETH1000) ? gmii_rxck_in     :
                       (speed == ETH10)   ? mii_rxck10baseT : mii_rxck_in ;
   
   assign mii_rxck_out = (speed == ETH10) ? mii_rxck10baseT : mii_rxck_in;

   FrameMailBox registered_mailboxes[ethernet_address_t];
   
   int 	     eth_parity = 0; int  eth_errors = 0;

   virtual   ether_send_intf loopback_intf;
   
  //----------------------------------------------------------------------------
  // Generate 10 baseT rx clock
  //----------------------------------------------------------------------------
  initial
    begin
      mii_rxck10baseT <= 0;
      while(1)
        begin
          repeat(5)
            @(posedge mii_rxck_in) mii_rxck10baseT <= 1;
          repeat(5)
            @(posedge mii_rxck_in) mii_rxck10baseT <= 0;
        end
    end


  //----------------------------------------------------------------------------
  // Check interface functions
  //----------------------------------------------------------------------------

  function automatic string check_intf.whoami();
    string buffer;
    $sformat(buffer, "%m");
    return buffer.substr(0, buffer.len()-17);
  endfunction

  // Register a mailbox to receive frames from a particular source address.
  function automatic void check_intf.register_mailbox(ethernet_address_t sa, FrameMailBox mbx);
    $display("%m: Registering a mailbox to address %s", fmt_addr(sa));
    registered_mailboxes[sa] = mbx;
  endfunction

  // Remove a mailbox.
  function automatic void check_intf.unregister_mailbox(ethernet_address_t sa);
    registered_mailboxes.delete(sa);
  endfunction

  // Set/clear loopback
  function automatic void check_intf.enable_loopback(virtual ether_send_intf intf);
    loopback_intf = intf;
  endfunction

  function automatic void check_intf.set_parity_errors(int parity, int errors);
    eth_parity = parity;
    eth_errors = errors;
  endfunction

  function automatic void check_intf.set_speed(EthernetSpeed m);
    speed = m;
  endfunction
     
     
   task automatic check_frame(EthernetFrame frame);
      ethernet_address_t da;
       
      if (!frame.check_crc())
	begin
           $display(" -> Error, CRC incorrect.");
           $display(" ->   Received %s", hexformat(frame.get_crc()));
           $display(" ->   Expected %s", hexformat(frame.calc_crc()));
           return;
	end
       
      da = frame.get_da();
      
      // Look for a mailbox registered to this address.
      if(registered_mailboxes.exists(da))
	void'(registered_mailboxes[da].try_put(frame));
      else
	begin
           ethernet_address_t addr;
           $display("Warning, no handler registered for Ethernet address %s.", fmt_addr(da));
           $display("%0d addresses registered:", registered_mailboxes.num());
           for(int ok=registered_mailboxes.first(addr); ok; ok=registered_mailboxes.next(addr))
             $display("  %s", fmt_addr(addr));
	end
   endtask
   
  //----------------------------------------------------------------------------
  // Receive Process.
  //----------------------------------------------------------------------------

  task automatic gmii_receive();
     EthernetFrame rx_frame;
     int odd, prev_dibit;
     int nybbles[$];
     int raw_frame[$];
     int errored;
     int preamble_count;
     int found_sfd;
     int min_gap_symbols;

     int gap = 0;
     
     if(DEBUG) $display("%m");
     
     while(tmp_rx_dv !== 1)
       begin
          gap++;
          @(posedge rx_clk);
       end
     
     if(DEBUG) $display("%m: Start of receive frame.");
     
     min_gap_symbols = (speed==ETH1000) ? ethernet_inter_frame_gap/8 : ethernet_inter_frame_gap/(REDUCED ? 2 : 4);
     
     if(gap < min_gap_symbols)
       $display("%m: Warning, insufficient interframe gap (got %0d symbols, require %0d).", gap, min_gap_symbols);
     
     // Now grab the frame. We don't attempt to decode it during reception.
     nybbles = {};  errored = 0; odd = 0; prev_dibit = 0;
     
     while(tmp_rx_dv)
       begin
          if(REDUCED & odd)
            begin
               nybbles.push_back(((tmp_rxd & 3)<<2) | prev_dibit);
               
               if(tmp_rx_er) errored = 1;
            end
          else if(!REDUCED)
            begin
               nybbles.push_back(tmp_rxd & 'hf);
	       
               if (speed == ETH1000) nybbles.push_back((tmp_rxd>>4) & 'hf);
               
               if(tmp_rx_er) errored = 1;
            end

          prev_dibit = tmp_rxd & 3;
          odd = !odd;
	  
          @(posedge rx_clk);
       end
     
    // This will mostly catch collisions, so make it just a warning.
    if (errored) begin
       $display("%m: Warning, frame contained errors (rx_er detected).");
       return;
    end
         
    // Search for the SFD.
    preamble_count = 0; found_sfd = 0;
     
     for (int i=0; i<nybbles.size(); i++)
       begin
          int nyb = nybbles[i];

          if      (nyb == ethernet_preamble) preamble_count++;
          else if (nyb == ethernet_sfd) begin
             found_sfd = 1; break;
          end
          else preamble_count = 0;
       end
     
    if (!found_sfd) begin
       $display("%m: Error, SFD not found.");
       $display("%s", hexformat(nybbles[0:20], "0x%02x", ","));
       return;
    end
     
     if (preamble_count != ethernet_preamble_len) begin
	$display("%m: Warning, preamble was %0d nybbles long.", preamble_count);
       $stop;	 
    end

    if ((preamble_count<4) || (preamble_count>2*ethernet_preamble_len)) return;

    // Chop off preamble and SFD.
    nybbles = nybbles[preamble_count+1:$];

    // Deal with an odd number of nybbles.
    if(nybbles.size() & 1)
      begin
        nybbles.push_back(0);
        $display("%m: Warning, frame contained an odd number of nybbles.");
      end

    // Convert frame to bytes:
    raw_frame = {};
    
     for (int i=0; i<nybbles.size(); i+=2)
       raw_frame.push_back(nybbles[i] | (nybbles[i+1]<<4));

    if (raw_frame.size() < ethernet_frame::ethernet_min_frame_size)
      begin
         // This will mostly catch collisions, so make it just a warning.
         $display("%m: Warning, frame too small. (%0d bytes).", raw_frame.size());
         $display("%m: Raw received frame:");
	 $display("%s", hexformat(raw_frame, "0x%01x", ","));
	 return;
      end

    if(DEBUG>1)
      begin
        $display("%m: Raw received frame:");
        $display("%s", hexformat(raw_frame, "0x%01x", ","));
      end

    rx_frame = new(.initraw(raw_frame));

    if (loopback_intf)
      begin
         // Swap around dst and src MAC addresses
         ethernet_address_t sa = rx_frame.get_sa();
	 
         rx_frame.set_sa(rx_frame.get_da()); rx_frame.set_da(sa);
	 
        // Retransmit frame.
        loopback_intf.queue_frame(rx_frame);
      end
    else
      check_frame(rx_frame);

  endtask

  always
    gmii_receive();

endmodule


