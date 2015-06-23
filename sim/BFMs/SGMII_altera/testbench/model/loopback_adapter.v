// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_timing_adapter8.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/MAC/mac/timing_adapter/altera_tse_timing_adapter8.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : SIMULATION ONLY
//
// AVALON STREAMING TIMING ADAPTER FOR 8BIT IMPLEMENTATION

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

module loopback_adapter (
    
  // Interface: clk                     
  input              clk,
  input              reset,
  // Interface: in
  output reg         in_ready,
  input              in_valid,
  input      [7: 0]  in_data,
  input              in_startofpacket,
  input              in_endofpacket,
  input      [4:0]   in_error,
  // Interface: out
  input              out_ready,
  output reg         out_valid,
  output reg [7: 0]  out_data,
  output reg         out_startofpacket,
  output reg         out_endofpacket,
  output reg         out_error
);


    


   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------

   reg  [10: 0] in_payload;
   wire [10: 0] out_payload;
   wire         in_ready_wire;
   wire         out_valid_wire;
   wire [ 6: 0] fifo_fill;
   reg          ready;
   wire in_err;

   assign in_err = in_error[0]|in_error[1]|in_error[2]|in_error[3]|in_error[4];
   // ---------------------------------------------------------------------
   //| Payload Mapping
   // ---------------------------------------------------------------------
   always @ (in_data or in_startofpacket or in_endofpacket or in_err or out_payload) 
   begin
     in_payload = {in_data,in_startofpacket,in_endofpacket,in_err};
     {out_data,out_startofpacket,out_endofpacket,out_error} = out_payload;
   end

   // ---------------------------------------------------------------------
   //| FIFO
   // ---------------------------------------------------------------------
   loopback_adapter_fifo u_loopback_adapter_fifo 
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
   always @ (fifo_fill or out_valid_wire or out_ready)
    begin
      in_ready <= (fifo_fill < 48);	  //was 40
      out_valid <= out_valid_wire;
      ready = out_ready;
   end


endmodule

