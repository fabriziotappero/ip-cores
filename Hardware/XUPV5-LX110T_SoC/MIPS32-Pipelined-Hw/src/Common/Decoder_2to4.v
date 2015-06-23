`timescale 1ns / 1ps
/*
 * File         : Decoder_2to4.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   14-Aug-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A simple 2-to-4 line single bit decoder. Accepts a two bit number
 *   and sets one of four outputs high based on that number.
 *
 *   Mapping:
 *      00  ->  0001
 *      01  ->  0010
 *      10  ->  0100
 *      11  ->  1000
 */
module Decoder_2to4(
    input  [1:0] A,
    output reg [3:0] B
    );

    always @(A) begin
        case (A)
            2'd0 : B <= 4'b0001;
            2'd1 : B <= 4'b0010;
            2'd2 : B <= 4'b0100;
            2'd3 : B <= 4'b1000;
        endcase
    end

endmodule

