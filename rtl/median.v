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
/* +----------------------------------------------------------------------------
   Universidade Federal da Bahia
  ------------------------------------------------------------------------------
   PROJECT: FPGA Median Filter
  ------------------------------------------------------------------------------
   FILE NAME            : median.v
   AUTHOR               : João Carlos Bittencourt
   AUTHOR'S E-MAIL      : joaocarlos@ieee.org
   -----------------------------------------------------------------------------
   RELEASE HISTORY
   VERSION  DATE        AUTHOR        DESCRIPTION
   1.0      2013-08-13  joao.nunes    initial version
   -----------------------------------------------------------------------------
   KEYWORDS: median, filter, image processing
   -----------------------------------------------------------------------------
   PURPOSE: Top level entity of the Median Filter algorithm datapath.
   ----------------------------------------------------------------------------- */
`define DEBUG

module median
#(
    parameter MEM_DATA_WIDTH = 32,
    parameter LUT_ADDR_WIDTH = 10, // Input LUTs
    parameter MEM_ADDR_WIDTH = 10, // Output Memory
    parameter PIXEL_DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 320,
    parameter IMG_HEIGHT = 320
)(
    input clk, // Clock
    input rst_n, // Asynchronous reset active low
    input [31:0] word0,
    input [31:0] word1,
    input [31:0] word2,

    // Test signals
    `ifdef DEBUG
    output [PIXEL_DATA_WIDTH-1:0] pixel1,
    output [PIXEL_DATA_WIDTH-1:0] pixel2,
    output [PIXEL_DATA_WIDTH-1:0] pixel3,
    output [PIXEL_DATA_WIDTH-1:0] pixel4,
    `else
    output [MEM_DATA_WIDTH-1:0] median_word,
    `endif
    output [LUT_ADDR_WIDTH-1:0] raddr_a,
    output [LUT_ADDR_WIDTH-1:0] raddr_b,
    output [LUT_ADDR_WIDTH-1:0] raddr_c,

    output [MEM_ADDR_WIDTH-1:0] waddr
);

    wire [PIXEL_DATA_WIDTH-1:0] x2_y1;
    wire [PIXEL_DATA_WIDTH-1:0] x2_y0;
    wire [PIXEL_DATA_WIDTH-1:0] x2_ym1;
    wire [PIXEL_DATA_WIDTH-1:0] x1_y1;
    wire [PIXEL_DATA_WIDTH-1:0] x1_y0;
    wire [PIXEL_DATA_WIDTH-1:0] x1_ym1;
    wire [PIXEL_DATA_WIDTH-1:0] x0_y1;
    wire [PIXEL_DATA_WIDTH-1:0] x0_y0;
    wire [PIXEL_DATA_WIDTH-1:0] x0_ym1;
    wire [PIXEL_DATA_WIDTH-1:0] xm1_y1;
    wire [PIXEL_DATA_WIDTH-1:0] xm1_y0;
    wire [PIXEL_DATA_WIDTH-1:0] xm1_ym1;

    assign x2_y1   = word0[PIXEL_DATA_WIDTH-1:0];
    assign x2_y0   = word1[PIXEL_DATA_WIDTH-1:0];
    assign x2_ym1  = word2[PIXEL_DATA_WIDTH-1:0];

    assign x1_y1   = word0[(PIXEL_DATA_WIDTH*2)-1:PIXEL_DATA_WIDTH];
    assign x1_y0   = word1[(PIXEL_DATA_WIDTH*2)-1:PIXEL_DATA_WIDTH];
    assign x1_ym1  = word2[(PIXEL_DATA_WIDTH*2)-1:PIXEL_DATA_WIDTH];

    assign x0_y1   = word0[(PIXEL_DATA_WIDTH*3)-1:(PIXEL_DATA_WIDTH*2)];
    assign x0_y0   = word1[(PIXEL_DATA_WIDTH*3)-1:(PIXEL_DATA_WIDTH*2)];
    assign x0_ym1  = word2[(PIXEL_DATA_WIDTH*3)-1:(PIXEL_DATA_WIDTH*2)];

    assign xm1_y1  = word0[(PIXEL_DATA_WIDTH*4)-1:(PIXEL_DATA_WIDTH*3)];
    assign xm1_y0  = word1[(PIXEL_DATA_WIDTH*4)-1:(PIXEL_DATA_WIDTH*3)];
    assign xm1_ym1 = word2[(PIXEL_DATA_WIDTH*4)-1:(PIXEL_DATA_WIDTH*3)];

    // wire [PIXEL_DATA_WIDTH-1:0] pixel1_sig;
    // wire [PIXEL_DATA_WIDTH-1:0] pixel2_sig;
    // wire [PIXEL_DATA_WIDTH-1:0] pixel3_sig;
    // wire [PIXEL_DATA_WIDTH-1:0] pixel4_sig;

    `ifndef DEBUG
    assign median_word = {pixel1,pixel2,pixel3,pixel4};
    `endif

    // Common network output signals
    wire [PIXEL_DATA_WIDTH-1:0] c3l;
    wire [PIXEL_DATA_WIDTH-1:0] c3h;
    wire [PIXEL_DATA_WIDTH-1:0] c3m;
    wire [PIXEL_DATA_WIDTH-1:0] c3l_reg;
    wire [PIXEL_DATA_WIDTH-1:0] c3h_reg;
    wire [PIXEL_DATA_WIDTH-1:0] c3m_reg;
    wire [PIXEL_DATA_WIDTH-1:0] c2l;
    wire [PIXEL_DATA_WIDTH-1:0] c2h;
    wire [PIXEL_DATA_WIDTH-1:0] c2m;
    wire [PIXEL_DATA_WIDTH-1:0] c2l_reg;
    wire [PIXEL_DATA_WIDTH-1:0] c2h_reg;
    wire [PIXEL_DATA_WIDTH-1:0] c2m_reg;
    wire [PIXEL_DATA_WIDTH-1:0] c1l;
    wire [PIXEL_DATA_WIDTH-1:0] c1h;
    wire [PIXEL_DATA_WIDTH-1:0] c1m;
    wire [PIXEL_DATA_WIDTH-1:0] c0h;
    wire [PIXEL_DATA_WIDTH-1:0] c0m;
    wire [PIXEL_DATA_WIDTH-1:0] c0l;

    // Delay signals to be placed over the output registers
    wire [PIXEL_DATA_WIDTH-1:0] p1_sig;
    wire [PIXEL_DATA_WIDTH-1:0] p2_sig;
    wire [PIXEL_DATA_WIDTH-1:0] p3_sig;

    //------------------------------------------------------------
    // Windowing Memory Address Controller
    //------------------------------------------------------------
    state_machine
    #(
        .LUT_ADDR_WIDTH(LUT_ADDR_WIDTH),
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) window_contol (
        .clk(clk), // Clock
        .rst_n(rst_n), // Asynchronous reset active low

        .raddr_a(raddr_a),
        .raddr_b(raddr_b),
        .raddr_c(raddr_c),

        .waddr(waddr)
    );

    //------------------------------------------------------------
    // Pixel registers
    //------------------------------------------------------------
    // always @(posedge clk or negedge rst_n)
    // begin : pixel_reg
    //     if(~rst_n) begin
    //         pixel1 <= {PIXEL_DATA_WIDTH{1'b0}};
    //         pixel2 <= {PIXEL_DATA_WIDTH{1'b0}};
    //         pixel3 <= {PIXEL_DATA_WIDTH{1'b0}};
    //         pixel4 <= {PIXEL_DATA_WIDTH{1'b0}};
    //     end else begin
    //         pixel1 <= pixel1_sig;
    //         pixel2 <= pixel2_sig;
    //         pixel3 <= pixel3_sig;
    //         //pixel4 <= pixel4_sig;
    //    end
    // end

    //------------------------------------------------------------
    // Input datapath common network
    //------------------------------------------------------------
    common_network
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) common_network_u0 (
        .x2_y1(x2_y1),
        .x2_y0(x2_y0),
        .x2_ym1(x2_ym1),
        .x1_y1(x1_y1),
        .x1_y0(x1_y0),
        .x1_ym1(x1_ym1),
        .x0_y1(x0_y1),
        .x0_y0(x0_y0),
        .x0_ym1(x0_ym1),
        .xm1_y1(xm1_y1),
        .xm1_y0(xm1_y0),
        .xm1_ym1(xm1_ym1),

        .c3l(c3l),
        .c3h(c3h),
        .c3m(c3m),
        .c2l(c2l),
        .c2h(c2h),
        .c2m(c2m),
        .c1l(c1l),
        .c1h(c1h),
        .c1m(c1m),
        .c0h(c0h),
        .c0m(c0m),
        .c0l(c0l)
    );

    //------------------------------------------------------------
    // Pipeline Registers
    //------------------------------------------------------------
    dff_3_pipe
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) dff_c3_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .d0(c3h),
        .d1(c3m),
        .d2(c3l),

        .q0(c3h_reg),
        .q1(c3m_reg),
        .q2(c3l_reg)
    );

    dff_3_pipe
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) dff_c2_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .d0(c2h),
        .d1(c2m),
        .d2(c2l),

        .q0(c2h_reg),
        .q1(c2m_reg),
        .q2(c2l_reg)
    );

    // Output pieline registers (P1, P2, P3)
    dff_3_pipe
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) dff_out_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .d0(p1_sig),
        .d1(p2_sig),
        .d2(p3_sig),

        .q0(pixel1),
        .q1(pixel2),
        .q2(pixel3)
    );

    //------------------------------------------------------------
    // Median Filter Pixel Network
    //------------------------------------------------------------

    // Pixel 1
    pixel_network
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) pixel_network_u0 (
        .c3h(c1h),
        .c3m(c1m),
        .c3l(c1l),
        .c2h(c0h),
        .c2m(c0m),
        .c2l(c0l),
        .c1h(c3h_reg),
        .c1m(c3m_reg),
        .c1l(c3l_reg),

        .median(p1_sig)
    );

    pixel_network
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) pixel_network_u1 (
        .c3h(c2h),
        .c3m(c2m),
        .c3l(c2l),
        .c2h(c1h),
        .c2m(c1m),
        .c2l(c1l),
        .c1h(c0h),
        .c1m(c0m),
        .c1l(c0l),

        .median(p2_sig)
    );

    pixel_network
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) pixel_network_u2 (
        .c3h(c3h),
        .c3m(c3m),
        .c3l(c3l),
        .c2h(c2h),
        .c2m(c2m),
        .c2l(c2l),
        .c1h(c1h),
        .c1m(c1m),
        .c1l(c1l),

        .median(p3_sig)
    );

    pixel_network
    #(
        .DATA_WIDTH(PIXEL_DATA_WIDTH)
    ) pixel_network_u3 (
        .c3h(c0h),
        .c3m(c0m),
        .c3l(c0l),
        .c2h(c3h_reg),
        .c2m(c3m_reg),
        .c2l(c3l_reg),
        .c1h(c2h_reg),
        .c1m(c2m_reg),
        .c1l(c2l_reg),

        .median(pixel4)
    );

endmodule