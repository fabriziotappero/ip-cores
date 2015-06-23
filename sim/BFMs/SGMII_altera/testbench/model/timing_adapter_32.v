// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: timing_adapter_32.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/gen/timing_adapter_32.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg/TTChong
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : (Simulation only)
//
// Timing adapater  (from 3 to zero ready latency) Client Interface Ethernet Traffic Generator
// Instantiating a FIFO unit (timing_adapter_fifo_32.v)
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

// --------------------------------------------------------------------------------
//| Avalon Streaming Timing Adapter
// --------------------------------------------------------------------------------

`timescale 1ns / 1ps
module timing_adapter_32 (
    
      // Interface: clk
      input              clk,
      input              reset,
      // Interface: in
      output reg         in_ready,
      input              in_valid,
      input      [31: 0] in_data,
      input              in_startofpacket,
      input              in_endofpacket,
      input      [ 1: 0] in_empty,
      input              in_error,
      // Interface: out
      input              out_ready,
      output reg         out_valid,
      output reg [31: 0] out_data,
      output reg         out_startofpacket,
      output reg         out_endofpacket,
      output reg [ 1: 0] out_empty,
      output reg         out_error
);




   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------

   reg  [36: 0] in_payload;
   wire [36: 0] out_payload;
   wire         in_ready_wire;
   wire         out_valid_wire;
   wire [ 2: 0] fifo_fill;
   reg          ready;


   // ---------------------------------------------------------------------
   //| Payload Mapping
   // ---------------------------------------------------------------------
   always @ (in_data or in_startofpacket or in_endofpacket or in_empty or  in_error or out_payload)
   begin
     in_payload = {in_data,in_startofpacket,in_endofpacket,in_empty,in_error};
     {out_data,out_startofpacket,out_endofpacket,out_empty,out_error} = out_payload;
   end

   // ---------------------------------------------------------------------
   //| FIFO
   // ---------------------------------------------------------------------
   timing_adapter_fifo_32 timing_adapter_fifo 
     ( 
       .clk        (clk),
       .reset      (reset),
       .in_ready   (),
       .in_valid   (in_valid),      
       .in_data    (in_payload),
       .out_ready  (ready),
       .out_valid  (out_valid_wire),      
       .out_data   (out_payload),
       .fill_level (fifo_fill)
       );

   // ---------------------------------------------------------------------
   //| Ready & valid signals.
   // ---------------------------------------------------------------------
   always @ (fifo_fill or  out_valid_wire or out_ready) 
   begin
      in_ready  <= (fifo_fill < 3);
      out_valid <= out_valid_wire;
      ready     = out_ready;
   end


endmodule

