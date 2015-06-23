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
// 1.1      2013-09-04  laue.rami     modified version
// -----------------------------------------------------------------------------
// KEYWORDS: median, filter, image processing
// -----------------------------------------------------------------------------
// PURPOSE: Testbench for Median filter.
// -----------------------------------------------------------------------------
`define IMG_HEIGHT 'd320
`define IMG_WIDTH  'd320
module median_tb;

    `include "../tb/driver.sv"

    driver driver_u0;

    localparam PERIOD = 10;
    localparam PIXEL_DATA_WIDTH = 8;
    localparam LUT_ADDR_WIDTH = 14; // Input LUTs
    localparam MEM_ADDR_WIDTH = 14; // Output Memory

    bit clk;

    wire [MEM_ADDR_WIDTH-1:0] raddr_a;
    wire [MEM_ADDR_WIDTH-1:0] raddr_b;
    wire [MEM_ADDR_WIDTH-1:0] raddr_c;
    wire [MEM_ADDR_WIDTH-1:0] waddr_a;
    wire [MEM_ADDR_WIDTH-1:0] waddr_b;
    wire [MEM_ADDR_WIDTH-1:0] waddr_c;


    wire [MEM_ADDR_WIDTH-1:0] waddr;

    reg [(PIXEL_DATA_WIDTH*4)-1:0] word0;
    reg [(PIXEL_DATA_WIDTH*4)-1:0] word1;
    reg [(PIXEL_DATA_WIDTH*4)-1:0] word2;

    wire [31:0] w_data_bram0;
    wire [31:0] w_data_bram1;
    wire [31:0] w_data_bram2;

    //dut_if interface
    dut_if dut_if (clk);

    //driver

    always #(PERIOD/2) clk = ~clk;

    dual_port_ram
    #(
      .MEMFILE("./memA.hex"),
      .DATA_WIDTH('d32),
      .ADDR_WIDTH('d14)
    )
    BRAM0
    (
      .clk(clk),
      .r_ena(1'b1),
      .w_ena(1'b0),
      .w_data(w_data_bram0),
      .w_addr(waddr_a),
      .r_addr(raddr_a),
      .r_data(dut_if.word0)
    );

    dual_port_ram
    #(
      .MEMFILE("./memB.hex"),
      .DATA_WIDTH('d32),
      .ADDR_WIDTH('d14)
    )
    BRAM1
    (
      .clk(clk),
      .r_ena(1'b1),
      .w_ena(1'b0),
      .w_data(w_data_bram1),
      .w_addr(waddr_b),
      .r_addr(raddr_b),
      .r_data(dut_if.word1)
    );

    dual_port_ram
    #(
      .MEMFILE("./memC.hex"),
      .DATA_WIDTH('d32),
      .ADDR_WIDTH('d14)
    )
    BRAM2
    (
      .clk(clk),
      .r_ena(1'b1),
      .w_ena(1'b0),
      .w_data(w_data_bram2),
      .w_addr(waddr_c),
      .r_addr(raddr_c),
      .r_data(dut_if.word2)
    );

    median
    #(
        .MEM_DATA_WIDTH(PIXEL_DATA_WIDTH*4),
        .PIXEL_DATA_WIDTH(PIXEL_DATA_WIDTH),
        .LUT_ADDR_WIDTH(LUT_ADDR_WIDTH),
        .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
        .IMG_WIDTH(`IMG_WIDTH),
        .IMG_HEIGHT(`IMG_HEIGHT)
    ) dut_u0 (
        .clk(clk), // Clock
        .rst_n(dut_if.rst_n), // Asynchronous reset active low
        .word0(dut_if.ch_word0),
        .word1(dut_if.ch_word1),
        .word2(dut_if.ch_word2),
        .pixel1(dut_if.pixel1),
        .pixel2(dut_if.pixel2),
        .pixel3(dut_if.pixel3),
        .pixel4(dut_if.pixel4),
        .raddr_a(raddr_a),
        .raddr_b(raddr_b),
        .raddr_c(raddr_c),
        .waddr(dut_if.waddr)
    );

    always@(*)begin
       dut_if.window_line_counter  = dut_u0.window_contol.window_line_counter;
    end

    initial begin
        $display("INICIO -------");
        driver_u0 = new(dut_if);
        driver_u0.init();
        driver_u0.receive_data();
        driver_u0.reorganize_lines();
        wait(dut_if.end_of_operation);
        driver_u0.write_file();
        #(PERIOD*3)
        repeat(100)@(negedge clk);
        $stop;
    end

endmodule
