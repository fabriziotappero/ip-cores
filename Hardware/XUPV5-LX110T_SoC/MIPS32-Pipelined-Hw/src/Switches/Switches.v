`timescale 1ns / 1ps
/*
 * File         : Switches.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   17-Jul-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A read interface between a 4-way handshaking data bus and
 *   8 physical switches, which are debounced. 
 */
module Switches(
    input  clock,
    input  reset,
    input  Read,
    input  Write,
    input  [7:0] Switch_in, // Direct from physical switches
    output reg Ack,
    output [7:0] Switch_out
    );

    always @(posedge clock) begin
        Ack <= (reset) ? 0 : (Read | Write);
    end

    // Low-level switch debounce filter
    Switch_Filter Switch_Filter (
        .clock       (clock),
        .reset       (reset),
        .switch_in   (Switch_in),
        .switch_out  (Switch_out)
    );

endmodule

