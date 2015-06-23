///////////////////////////////////////////////////////////////////////////////
// $Id: ethernet_parser_64bit.v 2201 2007-08-21 06:52:51Z jnaous $
//
// Module: ethernet_parser_64bit.v
// Project: NF2.1
// Description: parses the Ethernet header for a 64 bit datapath
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
  module ethernet_parser_64bit
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter NUM_IQ_BITS = 3,
      parameter INPUT_ARBITER_STAGE_NUM = 2
      )
   (// --- Interface to the previous stage
    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    input                              in_wr,

    // --- Interface to output_port_lookup
   
    output reg                         eth_done,
    output reg [NUM_IQ_BITS-1:0]       src_port,

    // --- Misc
    
    input                              reset,
    input                              clk
   );


   // ------------ Internal Params --------

   parameter NUM_STATES  = 3;
   parameter READ_WORD_1 = 1;
   parameter READ_WORD_2 = 2;
   parameter WAIT_EOP    = 4;

   // ------------- Regs/ wires -----------

   reg [NUM_STATES-1:0]                state;
   reg [NUM_STATES-1:0]                state_next;

 
   reg                                 eth_done_next;
   reg [NUM_IQ_BITS-1:0]               src_port_next;

   // ------------ Logic ----------------
   
   always @(*) begin
     
      eth_done_next    = eth_done;
      src_port_next    = src_port;
      state_next       = state;
      case(state)
        /* read the input source header and get the first word */
        READ_WORD_1: begin
           if(in_wr && in_ctrl==2'hFF) begin
             
           end
           else if(in_wr && in_ctrl==0) begin
         
              state_next            = READ_WORD_2;
           end
        end // case: READ_WORD_1

        READ_WORD_2: begin
           if(in_wr) begin
			  src_port_next = in_data[15 :0];
              state_next            = WAIT_EOP;
              eth_done_next         = 1;
           end
        end

        WAIT_EOP: begin
           if(in_wr && in_ctrl!=0) begin
              eth_done_next   = 0;
              state_next      = READ_WORD_1;
           end
        end
      endcase // case(state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
       
         eth_done     <= 0;
         state        <= READ_WORD_1;
         src_port     <= 0;
      end
      else begin
       
         eth_done     <= eth_done_next;
         state        <= state_next;
         src_port     <= src_port_next;
      end // else: !if(reset)
   end // always @ (posedge clk)

endmodule // ethernet_parser_64bit
