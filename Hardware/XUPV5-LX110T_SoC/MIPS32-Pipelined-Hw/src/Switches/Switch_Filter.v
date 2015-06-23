`timescale 1ns / 1ps
/*
 * File         : Switch_Filter.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   18-Jun-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A debouncer for 8 switches. 
 */
module Switch_Filter(
    input  clock,
    input  reset,
    input  [7:0] switch_in,
    output reg [7:0] switch_out
    );


    reg [5:0] c7, c6, c5, c4, c3, c2, c1, c0;

    always @(posedge clock) begin
        c0 <= (reset) ? 6'h20 : ((switch_in[0] & (c0 != 6'h3F)) ? c0 + 1 : ((~switch_in[0] & (c0 != 6'h00)) ? c0 - 1 : c0));
        c1 <= (reset) ? 6'h20 : ((switch_in[1] & (c1 != 6'h3F)) ? c1 + 1 : ((~switch_in[1] & (c1 != 6'h00)) ? c1 - 1 : c1));
        c2 <= (reset) ? 6'h20 : ((switch_in[2] & (c2 != 6'h3F)) ? c2 + 1 : ((~switch_in[2] & (c2 != 6'h00)) ? c2 - 1 : c2));
        c3 <= (reset) ? 6'h20 : ((switch_in[3] & (c3 != 6'h3F)) ? c3 + 1 : ((~switch_in[3] & (c3 != 6'h00)) ? c3 - 1 : c3));
        c4 <= (reset) ? 6'h20 : ((switch_in[4] & (c4 != 6'h3F)) ? c4 + 1 : ((~switch_in[4] & (c4 != 6'h00)) ? c4 - 1 : c4));
        c5 <= (reset) ? 6'h20 : ((switch_in[5] & (c5 != 6'h3F)) ? c5 + 1 : ((~switch_in[5] & (c5 != 6'h00)) ? c5 - 1 : c5));
        c6 <= (reset) ? 6'h20 : ((switch_in[6] & (c6 != 6'h3F)) ? c6 + 1 : ((~switch_in[6] & (c6 != 6'h00)) ? c6 - 1 : c6));
        c7 <= (reset) ? 6'h20 : ((switch_in[7] & (c7 != 6'h3F)) ? c7 + 1 : ((~switch_in[7] & (c7 != 6'h00)) ? c7 - 1 : c7));
    end

    always @(posedge clock) begin
        switch_out[0] <= (reset) ? 0 : ((c0 == 6'h00) ? 0 : ((c0 == 6'h3F) ? 1 : switch_out[0]));
        switch_out[1] <= (reset) ? 0 : ((c1 == 6'h00) ? 0 : ((c1 == 6'h3F) ? 1 : switch_out[1]));
        switch_out[2] <= (reset) ? 0 : ((c2 == 6'h00) ? 0 : ((c2 == 6'h3F) ? 1 : switch_out[2]));
        switch_out[3] <= (reset) ? 0 : ((c3 == 6'h00) ? 0 : ((c3 == 6'h3F) ? 1 : switch_out[3]));
        switch_out[4] <= (reset) ? 0 : ((c4 == 6'h00) ? 0 : ((c4 == 6'h3F) ? 1 : switch_out[4]));
        switch_out[5] <= (reset) ? 0 : ((c5 == 6'h00) ? 0 : ((c5 == 6'h3F) ? 1 : switch_out[5]));
        switch_out[6] <= (reset) ? 0 : ((c6 == 6'h00) ? 0 : ((c6 == 6'h3F) ? 1 : switch_out[6]));
        switch_out[7] <= (reset) ? 0 : ((c7 == 6'h00) ? 0 : ((c7 == 6'h3F) ? 1 : switch_out[7]));
    end

/*
    reg [19:0] c7, c6, c5, c4, c3, c2, c1, c0;

    always @(posedge clock) begin
        c0 <= (reset) ? 20'h80000 : ((switch_in[0] & (c0 != 20'hFFFFF)) ? c0 + 1 : ((~switch_in[0] & (c0 != 20'h00000)) ? c0 - 1 : c0));
        c1 <= (reset) ? 20'h80000 : ((switch_in[1] & (c1 != 20'hFFFFF)) ? c1 + 1 : ((~switch_in[1] & (c1 != 20'h00000)) ? c1 - 1 : c1));
        c2 <= (reset) ? 20'h80000 : ((switch_in[2] & (c2 != 20'hFFFFF)) ? c2 + 1 : ((~switch_in[2] & (c2 != 20'h00000)) ? c2 - 1 : c2));
        c3 <= (reset) ? 20'h80000 : ((switch_in[3] & (c3 != 20'hFFFFF)) ? c3 + 1 : ((~switch_in[3] & (c3 != 20'h00000)) ? c3 - 1 : c3));
        c4 <= (reset) ? 20'h80000 : ((switch_in[4] & (c4 != 20'hFFFFF)) ? c4 + 1 : ((~switch_in[4] & (c4 != 20'h00000)) ? c4 - 1 : c4));
        c5 <= (reset) ? 20'h80000 : ((switch_in[5] & (c5 != 20'hFFFFF)) ? c5 + 1 : ((~switch_in[5] & (c5 != 20'h00000)) ? c5 - 1 : c5));
        c6 <= (reset) ? 20'h80000 : ((switch_in[6] & (c6 != 20'hFFFFF)) ? c6 + 1 : ((~switch_in[6] & (c6 != 20'h00000)) ? c6 - 1 : c6));
        c7 <= (reset) ? 20'h80000 : ((switch_in[7] & (c7 != 20'hFFFFF)) ? c7 + 1 : ((~switch_in[7] & (c7 != 20'h00000)) ? c7 - 1 : c7));
    end

    always @(posedge clock) begin
        switch_out[0] <= (reset) ? 0 : ((c0 == 20'h00000) ? 0 : ((c0 == 20'hFFFFF) ? 1 : switch_out[0]));
        switch_out[1] <= (reset) ? 0 : ((c1 == 20'h00000) ? 0 : ((c1 == 20'hFFFFF) ? 1 : switch_out[1]));
        switch_out[2] <= (reset) ? 0 : ((c2 == 20'h00000) ? 0 : ((c2 == 20'hFFFFF) ? 1 : switch_out[2]));
        switch_out[3] <= (reset) ? 0 : ((c3 == 20'h00000) ? 0 : ((c3 == 20'hFFFFF) ? 1 : switch_out[3]));
        switch_out[4] <= (reset) ? 0 : ((c4 == 20'h00000) ? 0 : ((c4 == 20'hFFFFF) ? 1 : switch_out[4]));
        switch_out[5] <= (reset) ? 0 : ((c5 == 20'h00000) ? 0 : ((c5 == 20'hFFFFF) ? 1 : switch_out[5]));
        switch_out[6] <= (reset) ? 0 : ((c6 == 20'h00000) ? 0 : ((c6 == 20'hFFFFF) ? 1 : switch_out[6]));
        switch_out[7] <= (reset) ? 0 : ((c7 == 20'h00000) ? 0 : ((c7 == 20'hFFFFF) ? 1 : switch_out[7]));
    end
*/

endmodule

