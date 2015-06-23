/////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "gmii_tx_model.v"                                 ////
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


module gmii_tx_model #(
  parameter DEBUG       = 0,
  parameter full_duplex = 1,
  parameter REDUCED     = 0,
  parameter out_delay   = 5,
  parameter in_delay    = 2
)(
  interface send_intf,

  input         mii_txck_in,
  input         gmii_txck_in,
  output        txck_out,
  output        gigabit_mode,

  output  [7:0] txd,
  output        tx_en,
  output        tx_er,
  input         crs,
  input         col
);
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   import ethernet_frame::EthernetFrame;
   import ethernet_frame::EthernetSpeed;
   import ethernet_frame::ethernet_preamble;
   import ethernet_frame::ethernet_inter_frame_gap;
   import ethernet_frame::ethernet_sfd;
   import ethernet_frame::ETH10;
   import ethernet_frame::ETH1000;
   import ethernet_frame::ethernet_back_off_limit;
   import ethernet_frame::ethernet_slot_time;
   import ethernet_frame::ethernet_jam_size;
   import ethernet_frame::ethernet_attempt_limit;

   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   const int 	preamble_byte = (ethernet_preamble<<4) | ethernet_preamble;
   
   const int 	sfd_byte      = (ethernet_sfd<<4) | ethernet_preamble;
   
  
   //////////////////////////////////////////////////////////////////////////////
   // 2.5MHz 10baseT Tramsit clock
   //////////////////////////////////////////////////////////////////////////////

   reg 		mii_txck_10baseT;
   
   initial
     begin
	mii_txck_10baseT <= 0;
      while(1)
        begin
           repeat(5)
             @(posedge mii_txck_in) mii_txck_10baseT <= 1;
           repeat(5)
             @(posedge mii_txck_in) mii_txck_10baseT <= 0;
        end
     end
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   EthernetSpeed speed = ETH1000;
   
   assign gigabit_mode = (speed == ETH1000);
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   wire 	tmp_col,   tmp_crs;
   reg 		tmp_tx_en, tmp_tx_er;
   reg [7:0] 	tmp_txd;
   
   assign #out_delay txd   = (speed==ETH1000) ? tmp_txd[7:0] : tmp_txd[7:0] & 8'h0f;
   assign #out_delay tx_en = tmp_tx_en;
   assign #out_delay tx_er = tmp_tx_er;
   
   assign #in_delay tmp_crs = crs; 
   assign #in_delay tmp_col = col; 
   
   wire 	tx_clk   = (speed==ETH1000) ? gmii_txck_in     :
                           (speed==ETH10)   ? mii_txck_10baseT : mii_txck_in;
   
   assign txck_out = tx_clk;

   //////////////////////////////////////////////////////////////////////////////
   /// Transmit queue
   //////////////////////////////////////////////////////////////////////////////
   
   EthernetFrame txq[$];
   
  //////////////////////////////////////////////////////////////////////////////
  // Send interface
  //////////////////////////////////////////////////////////////////////////////

  function automatic string send_intf.whoami();
    string buffer;
    $sformat(buffer, "%m");
    return buffer.substr(0, buffer.len()-17);
  endfunction

     
   // Queue frame for transmission.
  function automatic void send_intf.queue_frame(EthernetFrame frame);
     
     EthernetFrame f = frame;
           
    txq.push_back(f);
  endfunction

  // Tag the last frame in the queue with a post transmission delay.
  function automatic void send_intf.queue_delay(time delay);
     
     if(txq.size()!=0) txq[$].delay = delay;
  endfunction

  // Wait for all frames to be transmitted.
  task automatic send_intf.sleep(time timeout);
     
     time start_time = $time; time end_time = start_time + timeout;
     
     while(1)
       begin
          @(posedge tx_clk);
	  
          if (txq.size()==0)
            begin
               if (DEBUG) $display( "%m: Finished transmit (after waiting %0t).", $time - start_time );
               break;
            end
	  
          if ($time > end_time) begin
             $display( "%m: Transmit Timeout."); break;
          end
       end
  endtask
   
  function automatic void send_intf.set_speed(EthernetSpeed m);
    speed = m;
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // (G)MII transmit 
  //////////////////////////////////////////////////////////////////////////////
   
  task automatic mii_transmit();
     
     EthernetFrame frame;  int raw_frame[]; 
     
     int max_back_off, rnd, backoff, collision, index;
     
     int txbyte, chunk_size, chunk_count, attempts  = 0;
     
     int min_gap_symbols = (speed==ETH1000) ? (ethernet_inter_frame_gap/8) : (ethernet_inter_frame_gap/4);
    
     // Wait until there is at least one frame queued to send.
     while(txq.size()==0) @(posedge tx_clk);

     // Pull frame from tx queue
     frame = txq[0];
     
     if(DEBUG) begin
        $display("%m: Frame ready for transmit:"); $display("%s", frame.repr_verbose());
     end

    while(1)
      begin
         // Backoff before retransmissions...
         if (attempts > 0)
           begin
              if      (attempts == 1)                       max_back_off = 2;
              else if (attempts <= ethernet_back_off_limit) max_back_off = max_back_off * 2;
	      
              rnd = $urandom_range(0, max_back_off-1);
              
	      backoff = ethernet_slot_time*rnd;
              
	      if (DEBUG) $display("%m: backing-off for %0d bit periods.", backoff);
	      
              for (int i=0; i < (backoff/4); i++) @(posedge tx_clk);
           end
	 
        attempts+=1;
	 
         // If half duplex, wait until medium is idle.
         if (!full_duplex) begin
	    
            while(tmp_crs) @(posedge tx_clk);
	    
            if (DEBUG) $display("%m: Media idle.");
         end
	 
         // Insert an inter-frame gap.
         for(int i=0; i<min_gap_symbols; i=i+1) @(posedge tx_clk);
         
	 if (DEBUG) $display("%m: Finished interframe gap.");
	 
         // Transmit the frame (preamble/SFD/DSA/payload/FCS):
         raw_frame = new[frame.len()+8];
	 
         for(int i=0; i<7; i++) raw_frame[i] = preamble_byte;
         
	 raw_frame[7] = sfd_byte;
         
	 for(int i=0; i<frame.len(); i++) raw_frame[i+8] = frame.raw[i];
	 
         tmp_tx_en = 1; collision = 0;
	 
         for (index=0; index<raw_frame.size() && !collision; index++)
          begin
             txbyte = raw_frame[index];
	     
	     chunk_size  = (speed==ETH1000) ? 8 : 4; chunk_count = (speed==ETH1000) ? 1 : 2;
	     
             if (REDUCED) begin chunk_size /= 2; chunk_count *= 2; end
	     
             for (int i=0; i<chunk_count && !collision; i++)
               begin
                  if((index>8) && !full_duplex && tmp_col) begin collision = 1; break; end
                  
		  tmp_txd = txbyte & ((1<<chunk_size)-1);
                  
		  txbyte >>= chunk_size;
                  
		  @(posedge tx_clk);
               end
          end
	 
         if (~collision) begin
            tmp_tx_en = 0; break;
         end
	 else
           begin
              if(index*8 > (ethernet_slot_time-64)) begin
		 $display("%m: Error, late collision.");
              end
	      
              // If there was a collision, transmit the jam sequence.
              $display("%m: Collision detected. Jamming.");
              
	      tmp_txd = 'hff;
              
	      for (int i=0; i < ethernet_jam_size/4; i++) @(posedge tx_clk);
              
	      tmp_tx_en = 0;
	      
              if (attempts > ethernet_attempt_limit) begin
                 $display("%m: Attempt limit reached. Frame aborted."); break;
              end
           end
      end
     
     // Remove frame queue after transmission
     void'(txq.pop_front());
     
  endtask
   
   initial
     begin
	tmp_txd = 1'b0; tmp_tx_en = 1'b0; tmp_tx_er = 1'b0;
	
	while(1) begin mii_transmit(); end
     end
   
endmodule

