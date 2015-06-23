// (C) 2001-2010 Altera Corporation. All rights reserved.
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

// $Id: //acds/main/ip/merlin/altera_reset_controller/altera_tse_reset_synchronizer.v#7 $
// $Revision: #7 $
// $Date: 2010/04/27 $
// $Author: jyeap $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1ns / 1ns

module altera_tse_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R101,R105\"" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // -----------------------------------------------
    (* ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \" set_false_path -to [get_pins -compatibility_mode -nocase *altera_tse_reset_synchronizer_chain*|aclr]; set_false_path -to [get_pins -compatibility_mode -nocase *altera_tse_reset_synchronizer_chain*|clrn] \"" *) (*preserve*) reg [DEPTH-1:0] altera_tse_reset_synchronizer_chain;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_tse_reset_synchronizer_chain <= {DEPTH{1'b1}};
            end
            else begin
                altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
                altera_tse_reset_synchronizer_chain[DEPTH-1] <= 0;
            end
        end

        assign reset_out = altera_tse_reset_synchronizer_chain[0];
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
            altera_tse_reset_synchronizer_chain[DEPTH-1] <= reset_in;
        end

        assign reset_out = altera_tse_reset_synchronizer_chain[0];
 
    end
    endgenerate

endmodule
