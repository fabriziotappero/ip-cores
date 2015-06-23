/////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ethernet_threads.v"                              ////
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

`include "ge_1000baseX_constants.v"

package ethernet_threads;
   
  import tb_utils::hexformat;
   
  import packet::Packet;
  import packet::PacketMailBox;

  import ethernet_frame::EthernetFrame;
  import ethernet_frame::FrameMailBox;
  import ethernet_frame::ethernet_address_t;
  
`define VALID 1'b1
`define INVALID 1'b0
   
  virtual class TxThread;
    virtual task run(PacketMailBox mbx);
    endtask

    virtual task pass_to_checker(Packet p, PacketMailBox mbx);
      mbx.put(p);
    endtask
  endclass


   virtual class RxThread;
     virtual task run(ref int errors, PacketMailBox mbx);
     endtask
   endclass

   function [15:0] reorder(input [15:0] x);
      reorder = {x[7:0], x[15:8]};
  
   endfunction // byte_swap
   

   //******************************************************************************
   // 8B/10B random
   //******************************************************************************
     
   function automatic void random(int seed=-1, output int value);
      
      if (seed >= 0) begin int tmp = $urandom(seed); end
      
      value = $urandom() & 'hff;
      
   endfunction // random

  //******************************************************************************
  // Ethernet frame sending thread...
  //******************************************************************************
  class GmiiTxThread extends TxThread;
    virtual gmii_tx_if   tx;
    ethernet_address_t   dst_addr;
    ethernet_address_t   src_addr;
    int                  length;
    int                  num_frames;
    int                  spacing;

    // Do nothing constructor.
    function new(); endfunction

    // Use a static function for construction so we can use :: notation.
    static function GmiiTxThread NEW(
      virtual gmii_tx_if  tx,
      ethernet_address_t  dst_addr,
      ethernet_address_t  src_addr,
      int                 length,
      int                 num_frames,
      int                 spacing
    );
      GmiiTxThread x = new();
      x.tx           = tx;
      x.dst_addr     = dst_addr;
      x.src_addr     = src_addr;
      x.length       = length;
      x.num_frames   = num_frames;
      x.spacing      = spacing;
      return x;
    endfunction

    virtual task run(PacketMailBox mbx);
      EthernetFrame frame;

      for(int i=0; i<num_frames; i++)
        begin
          int len = length<0 ? i-length : length;

          $display("\nSending Ethernet frame: %0d, length: %0d", i, len);

          frame = new(dst_addr, src_addr, .length(len));

          //$display("Transmit: %s", frame.repr_verbose(20,20));
            $display("Transmit: %s", frame.dump());
	   
          tx.queue_frame(EthernetFrame'(frame));
          pass_to_checker(frame, mbx);
          # spacing;
       end

      mbx.put(null);
    endtask
  endclass

  
  //******************************************************************************
  // Ethernet frame checking thread...
  //******************************************************************************
  class GmiiRxThread extends RxThread;
    virtual gmii_rx_if  rx;
    ethernet_address_t  dst_addr;
    time                timeout_first;
    time                timeout_rest;
    int                 dut_will_pad;

    // Do nothing constructor.
    function new(); endfunction

    // Use a static function for construction so we can use :: notation.
    static function GmiiRxThread NEW(
      input virtual gmii_rx_if   rx,
      input ethernet_address_t   dst_addr,
      input time                 timeout_first,
      input time                 timeout_rest,
      input int                  dut_will_pad=1
    );
      GmiiRxThread x = new();
      x.rx      = rx;
      x.dst_addr            = dst_addr;
      x.timeout_first = timeout_first;
      x.timeout_rest  = timeout_rest;
      x.dut_will_pad  = dut_will_pad;
      return x;
    endfunction

    virtual task run(ref int errors, PacketMailBox mbx);
      string         mod_name = string'(rx.whoami());
      FrameMailBox   rx_mbx = new();
      Packet         p;
      EthernetFrame  expected_frames[$];
      int            finished = 0;
      EthernetFrame  frame;
      time           end_time;
      time           timeout = timeout_first;
      int            matched;
      int 	     frames_matched = 0;
      
      rx.register_mailbox(ethernet_address_t'(dst_addr), FrameMailBox'(rx_mbx));

      while(1)
        begin
          // Fetch the next cell to be matched from the FIFO...
          if(!finished)
            begin
              mbx.get(p);
              if(p==null)
                finished = 1;
              else begin
                EthernetFrame expected = EthernetFrame'(p);

                // If the DUT pads frames up to the minimum Ethernet frame size then
                // we must pad the expected frame also!
                if(dut_will_pad)
                  expected.pad_up();

                expected_frames.push_back(expected);
                end
            end

          if(expected_frames.size()==0)
            break;

          // Wait for a frame to be received
          end_time = $time + timeout;
          timeout = timeout_rest;
          while((rx_mbx.try_get(frame)==0) && ($time<end_time))
            #100ns;

          if(frame==null)
            begin
              $display("%s: %0t: Error, frame timed out for address %s.", mod_name, $time, ethernet_frame::fmt_addr(dst_addr));
              errors += 1;

              // A timeout probably means the link is broken, so don't waste too much time waiting...
              if(finished)
                begin
                  void'(expected_frames.pop_back());
                  timeout_rest = timeout_rest / 2;
                end
            end
          else
            begin
              // Search the list of expected cells for one matching the received frames
              matched = 0;
              for(int i=0; i<expected_frames.size(); i++)
                if(frame.raw==expected_frames[i].raw)
                  begin
                    if(i==0) begin
                       $display("%s: -> Frame matched O.K %03d", mod_name, frames_matched++);
                    end
		    else
                      $display("%s: -> Frame did not match the next expected frame but did match frame number %0d.", mod_name, i);
                    expected_frames.delete(i);
                    matched = 1;
                    break;
                  end

              if(!matched)
                begin
                   $display("%s: %0t: -> Unexpected frame received.", mod_name, $time);
		   $display("  Rec: %s", frame.repr_verbose(25,10));
                   $display("  Exp: %s", expected_frames[0].repr_verbose(25,10));
                  errors += 1;
                end
            end
        end

      rx.unregister_mailbox(ethernet_address_t'(dst_addr));

      $display("%s: GmiiRxThread for %s has completed.", mod_name, ethernet_frame::fmt_addr(dst_addr));
    endtask
  endclass


  //******************************************************************************
  // Ignore frames from the specified address.
  //******************************************************************************
  task EtherIgnoreThread(
    virtual gmii_rx_intf rx,
    ethernet_address_t      dst_addr
  );
    FrameMailBox rx_mbx = new();
    EthernetFrame   frame;

    rx.register_mailbox(ethernet_address_t'(dst_addr), FrameMailBox'(rx_mbx));

    while(1)
      rx_mbx.get(frame);
  endtask


  //******************************************************************************
  // This structure specifies a traffic stream to be sent between two points.
  //******************************************************************************
  typedef struct {
    TxThread tx; RxThread rxi;
  } EthernetFlowEntry;

  //******************************************************************************
  // Traffic send/check task.
  //******************************************************************************
  class EthernetFlow;
     
    EthernetFlowEntry flow_table[$];

    function void create(TxThread s, RxThread c);
      EthernetFlowEntry f = '{s, c};
      flow_table.push_back(f);
    endfunction

    function void clear();
      flow_table = {};
    endfunction

    task start(ref int errors);
       EthernetFlowEntry f;
       int       local_errors = 0;

      $display("%m: Starting traffic flow.");

      // Launch all the send/receive threads...
      for(int i=0; i<flow_table.size(); i++)
        begin
          f = flow_table[i];

          fork
            PacketMailBox mbx = new();

            f.tx.run(mbx);

            if(f.rxi)
              f.rxi.run(local_errors, mbx);
          join_none

          #0; // Wait for the forked threads to start before changing their parameters!!!
        end

      wait fork;

      errors += local_errors;
      
      $display("%m: %0tns: All threads completed.", $time);

    endtask
  endclass

endpackage

