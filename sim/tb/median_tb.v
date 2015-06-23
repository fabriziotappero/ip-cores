/* --------------------------------------------------------------------------------
 This file is part of FPGA Median Filter.

    FPGA Median Filter is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA Median Filter is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA Median Filter.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------- */
// +----------------------------------------------------------------------------
// Universidade Federal da Bahia
//------------------------------------------------------------------------------
// PROJECT: FPGA Median Filter
//------------------------------------------------------------------------------
// FILE NAME            : median_tb.v
// AUTHOR               : João Carlos Bittencourt
// AUTHOR'S E-MAIL      : joaocarlos@ieee.org
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION  DATE        AUTHOR        DESCRIPTION
// 1.0      2013-08-27  joao.nunes    initial version
// -----------------------------------------------------------------------------
// KEYWORDS: median, filter, image processing
// -----------------------------------------------------------------------------
// PURPOSE: Testbench for Median filter.
// -----------------------------------------------------------------------------
module median_tb;

    localparam PERIOD = 10;
    localparam PIXEL_DATA_WIDTH = 8;
    localparam LUT_ADDR_WIDTH = 10; // Input LUTs
    localparam MEM_ADDR_WIDTH = 10; // Output Memory

    reg clk;
    reg rst_n;
    always #(PERIOD/2) clk = ~clk;

    reg [(PIXEL_DATA_WIDTH*4)-1:0] word0;
    reg [(PIXEL_DATA_WIDTH*4)-1:0] word1;
    reg [(PIXEL_DATA_WIDTH*4)-1:0] word2;

    wire [PIXEL_DATA_WIDTH-1:0] pixel1;
    wire [PIXEL_DATA_WIDTH-1:0] pixel2;
    wire [PIXEL_DATA_WIDTH-1:0] pixel3;
    wire [PIXEL_DATA_WIDTH-1:0] pixel4;

    wire [9:0] raddr_a;
    wire [9:0] raddr_b;
    wire [9:0] raddr_c;

    wire [9:0] waddr;

    median
    #(
        .MEM_DATA_WIDTH(PIXEL_DATA_WIDTH*4),
        .PIXEL_DATA_WIDTH(PIXEL_DATA_WIDTH),
        .LUT_ADDR_WIDTH(LUT_ADDR_WIDTH),
        .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH)
    ) dut_u0 (
        .clk(clk), // Clock
        .rst_n(rst_n), // Asynchronous reset active low

        .word0(word0),
        .word1(word1),
        .word2(word2),

        .pixel1(pixel1),
        .pixel2(pixel2),
        .pixel3(pixel3),
        .pixel4(pixel4),
        .raddr_a(raddr_a),
        .raddr_b(raddr_b),
        .raddr_c(raddr_c),

        .waddr(waddr)
    );

    initial begin
        clk = 1;
        rst_n = 0;
        word0 = 0;
        word1 = 0;
        word2 = 0;
        #(PERIOD*3)
        rst_n = 1;
        word0 = {8'd160,8'd171,8'd164,8'd142};
        word1 = {8'd123,8'd141,8'd149,8'd154};
        word2 = {8'd163,8'd177,8'd171,8'd136};
        #PERIOD
        word0 = {8'd167,8'd193,8'd171,8'd160};
        word1 = {8'd174,8'd150,8'd123,8'd166};
        word2 = {8'd142,8'd165,8'd162,8'd171};
        #PERIOD
        word0 = {8'd168,8'd179,8'd146,8'd173};
        word1 = {8'd171,8'd160,8'd152,8'd154};
        word2 = {8'd156,8'd142,8'd147,8'd167};
        #PERIOD
        word0 = {8'd123,8'd141,8'd149,8'd154};
        word1 = {8'd163,8'd177,8'd171,8'd136};
        word2 = {8'd204,8'd151,8'd140,8'd140};
        #PERIOD
        word0 = {8'd174,8'd150,8'd123,8'd166};
        word1 = {8'd142,8'd165,8'd162,8'd171};
        word2 = {8'd142,8'd158,8'd149,8'd128};
        #PERIOD
        word0 = {8'd171,8'd160,8'd152,8'd154};
        word1 = {8'd156,8'd142,8'd147,8'd167};
        word2 = {8'd159,8'd128,8'd131,8'd160};
        repeat (100) @(negedge clk);
        $stop;
    end

endmodule