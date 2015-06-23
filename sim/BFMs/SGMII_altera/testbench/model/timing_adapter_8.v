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
// Description : Simulation Only
//
// AVALON STREAMING TIMING ADAPTER FOR 8BIT IMPLEMENTATION

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

module timing_adapter_8 (
    
  // Interface: clk                     
  input              clk,               //INPUT  : CLK
  input              reset,             //INPUT  : Asynchronous ACTIVE LOW Reset
  // Interface: in
  output reg         in_ready,          //OUTPUT : 'TIMING ADAPTER' READYNESS TO ACCEPT DATA FROM 'MAC'
  input              in_valid,          //INPUT  : 'MAC TO TIMING ADAPTER' DATA VALID
  input      [7: 0]  in_data,           //INPUT  : 'MAC TO TIMING ADAPTER' DATA
  input              in_startofpacket,  //INPUT  : 'MAC TO TIMING ADAPTER' START OF PACKET
  input              in_endofpacket,    //INPUT  : 'MAC TO TIMING ADAPTER' END OF PACKET
  input              in_error,          //INPUT  : 'MAC TO TIMING ADAPTER' PACKET DATA ERROR
  // Interface: out
  input              out_ready,         //INPUT  : 'APPLICATION' READYNESS TO ACCEPT DATA FROM 'TIMING ADAPTER'
  output reg         out_valid,         //OUTPUT : 'TIMING ADAPTER TO APPLICATION' DATA VALID
  output reg [7: 0]  out_data,          //OUTPUT : 'TIMING ADAPTER TO APPLICATION' DATA
  output reg         out_startofpacket, //OUTPUT : 'TIMING ADAPTER TO APPLICATION' START OF PACKET
  output reg         out_endofpacket,   //OUTPUT : 'TIMING ADAPTER TO APPLICATION' END OF PACKET
  output reg         out_error          //OUTPUT : 'TIMING ADAPTER TO APPLICATION' PACKET DATA ERROR
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


   // ---------------------------------------------------------------------
   //| Payload Mapping
   // ---------------------------------------------------------------------
   always @ (in_data or in_startofpacket or in_endofpacket or in_error or out_payload) 
   begin
     in_payload = {in_data,in_startofpacket,in_endofpacket,in_error};
     {out_data,out_startofpacket,out_endofpacket,out_error} = out_payload;
   end

   // ---------------------------------------------------------------------
   //| FIFO
   // ---------------------------------------------------------------------
   timing_adapter_fifo_8 u_timing_adapter_fifo 
     ( 
       .clk        (clk),               //INPUT  : CLK
       .reset      (reset),             //INPUT  : Asynchronous ACTIVE LOW Reset
       .in_ready   (),                  //OUTPUT : 'TIMING ADAPTER' READYNESS TO ACCEPT DATA FROM 'MAC'
       .in_valid   (in_valid),          //INPUT  : 'MAC TO TIMING ADAPTER' DATA VALID
       .in_data    (in_payload),        //INPUT  : 'MAC TO TIMING ADAPTER' DATA
       .out_ready  (ready),             //INPUT  : 'APPLICATION' READYNESS TO ACCEPT DATA FROM 'TIMING ADAPTER'
       .out_valid  (out_valid_wire),    //OUTPUT : 'TIMING ADAPTER TO APPLICATION' DATA VALID  
       .out_data   (out_payload),       //OUTPUT : 'TIMING ADAPTER TO APPLICATION' DATA
       .fill_level (fifo_fill)          //OUTPUT : 'TIMING ADAPTER' FIFO FILL LEVEL
       );

   // ---------------------------------------------------------------------
   //| Ready & valid signals.
   // ---------------------------------------------------------------------
   always @ (fifo_fill or out_valid_wire or out_ready)
    begin
      in_ready <= (fifo_fill < 40);
      out_valid <= out_valid_wire;
      ready = out_ready;
   end


endmodule

