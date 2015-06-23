// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/13.0/ip/merlin/altera_reset_controller/altera_reset_controller.v#1 $
// $Revision: #1 $
// $Date: 2013/02/11 $
// $Author: swbranch $

// --------------------------------------
// Reset controller
//
// Combines all the input resets and synchronizes
// the result to the clk.
// --------------------------------------

`timescale 1 ns / 1 ns

module altera_reset_controller
#(
    parameter NUM_RESET_INPUTS        = 6,
    parameter OUTPUT_RESET_SYNC_EDGES = "deassert",
    parameter SYNC_DEPTH              = 2
)
(
    // --------------------------------------
    // We support up to 16 reset inputs, for now
    // --------------------------------------
    input reset_in0,
    input reset_in1,
    input reset_in2,
    input reset_in3,
    input reset_in4,
    input reset_in5,
    input reset_in6,
    input reset_in7,
    input reset_in8,
    input reset_in9,
    input reset_in10,
    input reset_in11,
    input reset_in12,
    input reset_in13,
    input reset_in14,
    input reset_in15,

    input  clk,
    output reset_out
);

    localparam ASYNC_RESET = (OUTPUT_RESET_SYNC_EDGES == "deassert");

    wire merged_reset;

    // --------------------------------------
    // "Or" all the input resets together
    // --------------------------------------
    assign merged_reset = (  
                              reset_in0 | 
                              reset_in1 | 
                              reset_in2 | 
                              reset_in3 | 
                              reset_in4 | 
                              reset_in5 | 
                              reset_in6 | 
                              reset_in7 | 
                              reset_in8 | 
                              reset_in9 | 
                              reset_in10 | 
                              reset_in11 | 
                              reset_in12 | 
                              reset_in13 | 
                              reset_in14 | 
                              reset_in15
                          );

    // --------------------------------------
    // And if required, synchronize it to the required clock domain,
    // with the correct synchronization type
    // --------------------------------------
    generate if (OUTPUT_RESET_SYNC_EDGES == "none") begin

        assign reset_out = merged_reset;

    end else begin

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH),
            .ASYNC_RESET(ASYNC_RESET)
        )
        alt_rst_sync_uq1
        (
            .clk        (clk),
            .reset_in   (merged_reset),
            .reset_out  (reset_out)
        );

    end
    endgenerate
    
endmodule
