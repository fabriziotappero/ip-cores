`timescale 1ns / 1ps
/*
 * File         : Piezo.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   11-Jun-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A sound driver for a piezo-electric transducer (or other
 *   oscillating device). When enabled, the output oscillates
 *   between high and low, switching at a rate determined by the
 *   'count' register and clock frequency. The output is enabled
 *   when the highest bit is set on a Write.
 */
module Piezo_Driver(
    input  clock,
    input  reset,
    input  [24:0] data,
    input  Write,
    output reg Ack,
    output reg Piezo
    );

    reg [23:0] count;
    reg [23:0] compare;
    reg enabled;
    
    always @(posedge clock) begin
        count   <= (reset | (count == compare)) ? 24'h000000 : count + 1;
        compare <= (reset) ? 24'h000000 : ((Write) ? data[23:0] : compare);
        enabled <= (reset) ? 0 : ((Write) ? data[24] : enabled);
        Piezo   <= (reset | ~enabled) ? 0 : ((count == compare) ? ~Piezo : Piezo);
        Ack     <= (reset) ? 0 : Write;
    end
    
endmodule

