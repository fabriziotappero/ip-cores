//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tb_lpc_top.v                                                ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ns

`include "../../rtl/verilog/wb_lpc_defines.v"

// Define Module for Test Fixture
module wb_lpc_master_bench();

// LPC Host Inputs
    reg clk_i;
    reg nrst_i;
    reg [31:0] wbs_adr_i;
    reg [31:0] wbs_dat_i;
    reg [3:0] wbs_sel_i;
    reg [1:0] wbs_tga_i;
    reg wbs_we_i;
    reg wbs_stb_i;
    reg wbs_cyc_i;
    wire [3:0] lad_i;
    reg [2:0] dma_chan_i;
    reg dma_tc_i;

// LPC Host Outputs
    wire [31:0] wbs_dat_o;
    wire wbs_ack_o;
    wire wbs_err_o;
    wire lframe_o;
    wire [3:0] lad_o;
    wire lad_oe;

// Bidirs
    wire [3:0] lad_bus;

// LPC Peripheral Inputs
    wire [31:0] wbm_dat_i;
    wire wbm_ack_i;
    wire wbm_err_i;	 

// LPC Peripheral Outputs
    wire [31:0] wbm_adr_o;
    wire [31:0] wbm_dat_o;
    wire [3:0] wbm_sel_o;
    wire [1:0] wbm_tga_o;
    wire wbm_we_o;
    wire wbm_stb_o;
    wire wbm_cyc_o;
    wire [2:0] dma_chan_o;
    wire dma_tc_o;

    wire [3:0] slave_lad_i;
    wire [3:0] slave_lad_o;

    reg dma_req_i;

    reg [7:0]  regfile_ws;

task Reset;
begin
    nrst_i = 1; # 1000;
    nrst_i = 0; # 1000;
    nrst_i = 1; # 1000;
end
endtask


task wb_write;
    input reg [31:0] adr_i;
    input reg [3:0]  sel_i;
    input reg [31:0] dat_i;
    input reg expect_err;
    reg [7:0] wait_cnt;
    begin

    wbs_adr_i = adr_i;
    wbs_sel_i = sel_i;
    wbs_dat_i = dat_i;
    wbs_stb_i = 1'b1;
    wbs_cyc_i = 1'b1;
    wbs_we_i = 1'b1;

    wait_cnt = 0;
    
    while ((wbs_ack_o == 0) & (wait_cnt < 1000))
    begin
        wait_cnt = wait_cnt+1;
        # 100;
    end

    if(wait_cnt == 1000)
    begin
        $display($time, " Error, wb_w[%x/%x]: timeout waiting for ack", adr_i, dat_i); $stop(1);
    end
	 
	 if(expect_err != wbs_err_o)
	 begin
        $display($time, " Error: wb_w[%x/%x]: wb_err_o is %d, expected %d", adr_i, dat_i, wbs_err_o, expect_err); $stop(1);
    end
    wbs_stb_i = 1'b0;
    wbs_cyc_i = 1'b0;
    wbs_we_i = 1'b0;

    wait_cnt = 0;

    while ((wbs_ack_o == 1) & (wait_cnt < 100))
    begin
        wait_cnt = wait_cnt+1;
        # 100;
    end

    if(wait_cnt == 100)
    begin
        $display($time, " Error, wb_w[%x]: timeout waiting for ack to go away", adr_i); $stop(1);
    end

    end
endtask


task wb_read;
    input reg [31:0] adr_i;
    input reg [3:0]  sel_i;
    input reg [31:0] dat_i;
    input reg expect_err;
    reg [7:0] wait_cnt;
    begin

    wbs_adr_i = adr_i;
    wbs_sel_i = sel_i;   
    wbs_dat_i = 32'h0;
    wbs_stb_i = 1'b1;
    wbs_cyc_i = 1'b1;
    wbs_we_i = 1'b0;

    wait_cnt = 0;
    
    while ((wbs_ack_o == 0) & (wait_cnt < 1000))
    begin
        wait_cnt = wait_cnt+1;
        # 100;
    end

    if(wait_cnt == 1000)
    begin
        $display($time, " Error, wb_r[%x]: timeout waiting for ack", adr_i); $stop(1);
    end

    wbs_stb_i = 1'b0;
    wbs_cyc_i = 1'b0;

	 if(expect_err != wbs_err_o)
	 begin
        $display($time, " Error: wb_r[%x/%x]: wb_err_o is %d, expected %d", adr_i, dat_i, wbs_err_o, expect_err); $stop(1);
    end

    if(wbs_err_o == 0) begin
        if(dat_i != wbs_dat_o)
        begin
            $display($time, " Error, wb_r[%x]: expected %x, got %x", adr_i, dat_i, wbs_dat_o); $stop(1);
        end
    end

    wait_cnt = 0;

    while ((wbs_ack_o == 1) & (wait_cnt < 100))
    begin
        wait_cnt = wait_cnt+1;
        # 100;
    end

    if(wait_cnt == 100)
    begin
        $display($time, " Error, wb_r[%x]: timeout waiting for ack to go away", adr_i); $stop(1);
    end
end

endtask


   always begin
       #50 clk_i = 0;
       #50 clk_i = 1;
   end

// Instantiate the UUT
    wb_lpc_host UUT_Host (
        .clk_i(clk_i), 
        .nrst_i(nrst_i), 
        .wbs_adr_i(wbs_adr_i), 
        .wbs_dat_o(wbs_dat_o), 
        .wbs_dat_i(wbs_dat_i), 
        .wbs_sel_i(wbs_sel_i),
        .wbs_tga_i(wbs_tga_i),
        .wbs_we_i(wbs_we_i), 
        .wbs_stb_i(wbs_stb_i), 
        .wbs_cyc_i(wbs_cyc_i), 
        .wbs_ack_o(wbs_ack_o),
        .wbs_err_o(wbs_err_o),
        .dma_chan_i(dma_chan_i),
        .dma_tc_i(dma_tc_i),
        .lframe_o(lframe_o), 
        .lad_i(lad_i), 
        .lad_o(lad_o), 
        .lad_oe(lad_oe)
        );

// Instantiate the module
wb_lpc_periph UUT_Periph (
    .clk_i(clk_i), 
    .nrst_i(nrst_i), 
    .wbm_adr_o(wbm_adr_o), 
    .wbm_dat_o(wbm_dat_o), 
    .wbm_dat_i(wbm_dat_i), 
    .wbm_sel_o(wbm_sel_o),
    .wbm_tga_o(wbm_tga_o),
    .wbm_we_o(wbm_we_o), 
    .wbm_stb_o(wbm_stb_o), 
    .wbm_cyc_o(wbm_cyc_o), 
    .wbm_ack_i(wbm_ack_i), 
    .wbm_err_i(wbm_err_i), 	 
    .dma_chan_o(dma_chan_o),
    .dma_tc_o(dma_tc_o),
    .lframe_i(lframe_o), 
    .lad_i(slave_lad_i), 
    .lad_o(slave_lad_o), 
    .lad_oe(slave_lad_oe)
    );

wire       ldrq_o;
wire [2:0] master_dma_chan_o;
wire       master_dma_req_o;

// Instantiate the module
wb_dreq_periph UUT_DREQ_Periph (
    .clk_i(clk_i), 
    .nrst_i(nrst_i), 
    .dma_chan_i(dma_chan_i),
    .dma_req_i(dma_req_i), 
    .ldrq_o(ldrq_o)
    );

// Instantiate the module
wb_dreq_host UUT_DREQ_Host (
    .clk_i(clk_i), 
    .nrst_i(nrst_i), 
    .dma_chan_o(master_dma_chan_o),
    .dma_req_o(master_dma_req_o), 
    .ldrq_i(ldrq_o)
    );

wire [31:0] datareg0;
wire [31:0] datareg1;

// Instantiate the module
wb_regfile regfile (
    .clk_i(clk_i), 
    .nrst_i(nrst_i), 
    .wb_adr_i(dma_chan_i == 2 ? 32'h00000008 : wbm_adr_o), 
    .wb_dat_o(wbm_dat_i), 
    .wb_dat_i(wbm_dat_o), 
    .wb_sel_i(wbm_sel_o), 
    .wb_we_i(wbm_we_o), 
    .wb_stb_i(wbm_stb_o), 
    .wb_cyc_i(wbm_cyc_o), 
    .wb_ack_o(wbm_ack_i),
    .wb_err_o(wbm_err_i),
    .ws_i(regfile_ws),
    .datareg0(datareg0), 
    .datareg1(datareg1)
    );

assign lad_bus = lad_oe ? lad_o : (slave_lad_oe ? slave_lad_o : 4'bzzzz);
assign lad_i = lad_bus;
assign slave_lad_i = lad_bus;

// Initialize Inputs
    initial begin
//      $monitor("Time: %d clk_i=%b",
//          $time, clk_i);
            clk_i = 0;
            nrst_i = 1;
            wbs_adr_i = 0;
            wbs_dat_i = 0;
            wbs_sel_i = 0;
            wbs_tga_i = `WB_TGA_IO;
            wbs_we_i = 0;
            wbs_stb_i = 0;
            wbs_cyc_i = 0;
            dma_chan_i = 3'b0;
            dma_tc_i = 0;
            dma_req_i = 0;
            regfile_ws = 8'h0;		// Number of wait-states (0-255)
    Reset();
    $display($time, " * * * Using %d peripheral-side wait-states for this test.", regfile_ws);
    wbs_tga_i = `WB_TGA_IO;
    $display($time, " Testing LPC I/O Accesses");
    wb_write(32'h00000000, `WB_SEL_BYTE, 32'h00000012, 0);
    wb_write(32'h00000001, `WB_SEL_BYTE, 32'h00000034, 0);
    wb_write(32'h00000002, `WB_SEL_BYTE, 32'h00000056, 0);
    wb_write(32'h00000003, `WB_SEL_BYTE, 32'h00000078, 0);
    wb_write(32'h00000004, `WB_SEL_BYTE, 32'h0000009a, 0);
    wb_write(32'h00000005, `WB_SEL_BYTE, 32'h000000bc, 0);
    wb_write(32'h00000006, `WB_SEL_BYTE, 32'h000000de, 0);
    wb_write(32'h00000007, `WB_SEL_BYTE, 32'h000000f0, 0);

    wb_read(32'h00000000, `WB_SEL_BYTE, 32'hXXXXXX12, 0);
    wb_read(32'h00000001, `WB_SEL_BYTE, 32'hXXXXXX34, 0);
    wb_read(32'h00000002, `WB_SEL_BYTE, 32'hXXXXXX56, 0);
    wb_read(32'h00000003, `WB_SEL_BYTE, 32'hXXXXXX78, 0);
    wb_read(32'h00000004, `WB_SEL_BYTE, 32'hXXXXXX9a, 0);
    wb_read(32'h00000005, `WB_SEL_BYTE, 32'hXXXXXXbc, 0);
    wb_read(32'h00000006, `WB_SEL_BYTE, 32'hXXXXXXde, 0);
    wb_read(32'h00000007, `WB_SEL_BYTE, 32'hXXXXXXf0, 0);

    wbs_tga_i = `WB_TGA_MEM;
    $display($time, " Testing LPC MEM Accesses");
    wb_write(32'h00000000, `WB_SEL_BYTE, 32'h00000012, 0);
    wb_write(32'h00000001, `WB_SEL_BYTE, 32'h00000034, 0);
    wb_write(32'h00000002, `WB_SEL_BYTE, 32'h00000056, 0);
    wb_write(32'h00000003, `WB_SEL_BYTE, 32'h00000078, 0);
    wb_write(32'h00000004, `WB_SEL_BYTE, 32'h0000009a, 0);
    wb_write(32'h00000005, `WB_SEL_BYTE, 32'h000000bc, 0);
    wb_write(32'h00000006, `WB_SEL_BYTE, 32'h000000de, 0);
    wb_write(32'h00000007, `WB_SEL_BYTE, 32'h000000f0, 0);

    wb_read(32'h00000000, `WB_SEL_BYTE, 32'hXXXXXX12, 0);
    wb_read(32'h00000001, `WB_SEL_BYTE, 32'hXXXXXX34, 0);
    wb_read(32'h00000002, `WB_SEL_BYTE, 32'hXXXXXX56, 0);
    wb_read(32'h00000003, `WB_SEL_BYTE, 32'hXXXXXX78, 0);
    wb_read(32'h00000004, `WB_SEL_BYTE, 32'hXXXXXX9a, 0);
    wb_read(32'h00000005, `WB_SEL_BYTE, 32'hXXXXXXbc, 0);
    wb_read(32'h00000006, `WB_SEL_BYTE, 32'hXXXXXXde, 0);
    wb_read(32'h00000007, `WB_SEL_BYTE, 32'hXXXXXXf0, 0);

    wbs_tga_i = `WB_TGA_DMA;

    $display($time, " Testing LPC DMA BYTE Accesses");
    dma_chan_i = 3'h1;
    wb_write(32'h00000000, `WB_SEL_BYTE, 32'hXXXXXX21, 0);
    wb_read(32'h00000000, `WB_SEL_BYTE, 32'hXXXXXX21, 0);

    $display($time, " Testing LPC DMA SHORT Accesses");
    dma_chan_i = 3'h3;
    wb_write(32'h00000000, `WB_SEL_SHORT, 32'hXXXX6543, 0);
    wb_read(32'h00000000, `WB_SEL_SHORT, 32'hXXXX6543, 0);

    $display($time, " Testing LPC DMA WORD Accesses");
    dma_chan_i = 3'h7;
    wb_write(32'h00000000, `WB_SEL_WORD, 32'hedcba987, 0);
    wb_read(32'h00000000, `WB_SEL_WORD, 32'hedcba987, 0);

    dma_chan_i = 3'h0;
    wbs_tga_i = `WB_TGA_FW;

    $display($time, " Testing LPC Firmwre BYTE Accesses");
    wb_write(32'h00000000, `WB_SEL_BYTE, 32'hXXXXXX12, 0);
    wb_read(32'h00000000, `WB_SEL_BYTE, 32'hXXXXXX12, 0);

    $display($time, " Testing LPC Firmware SHORT Accesses");
    wb_write(32'h00000000, `WB_SEL_SHORT, 32'hXXXX3456, 0);
    wb_read(32'h00000000, `WB_SEL_SHORT, 32'hXXXX3456, 0);

    $display($time, " Testing LPC Firmware WORD Accesses");
    wb_write(32'h00000000, `WB_SEL_WORD, 32'h789abcde, 0);
    wb_read(32'h00000000, `WB_SEL_WORD, 32'h789abcde, 0);

    dma_chan_i = 3'h0;
    // Test Wishbone transfers that complete with an error.
    // This should abort the LPC access in progress and return
    // a Wishbone error at the host.  Note that Wishbone will
    // detect the bus error when the wishbone master on the
    // LPC peripheral attempts the Wishbone transfer.  For LPC
    // reads (peripheral to host,) this will be during the
    // first byte of the LPC transfer.  For LPC writes (host
    // to peripheral,) the Wishbone cycle is initiated when
    // the last byte of the LPC access is transferred.
    wbs_tga_i = `WB_TGA_IO;
    $display($time, " Testing LPC I/O Accesses (with Wishbone error)");
    wb_write(32'h00000008, `WB_SEL_BYTE, 32'h00000012, 1);
    wb_read(32'h00000008, `WB_SEL_BYTE, 32'hXXXXXX12, 1);

    wbs_tga_i = `WB_TGA_MEM;
    $display($time, " Testing LPC MEM Accesses (with Wishbone error)");
    wb_write(32'h00000008, `WB_SEL_BYTE, 32'h00000012, 1);
    wb_read(32'h00000008, `WB_SEL_BYTE, 32'hXXXXXX12, 1);

    wbs_tga_i = `WB_TGA_DMA;

    $display($time, " Testing LPC DMA BYTE Accesses (with Wishbone error)");
    // DMA channel 2 is a special case, using this channel will cause an
    // error on the Wishbone backplane.
    dma_chan_i = 3'h2;
    wb_write(32'h00000008, `WB_SEL_BYTE, 32'hXXXXXX21, 1);
    wb_read(32'h00000008, `WB_SEL_BYTE, 32'hXXXXXX21, 1);

    $display($time, " Testing LPC DMA SHORT Accesses (with Wishbone error)");
    dma_chan_i = 3'h2;
    wb_write(32'h00000008, `WB_SEL_SHORT, 32'hXXXX6543, 1);
    wb_read(32'h00000008, `WB_SEL_SHORT, 32'hXXXX6543, 1);

    $display($time, " Testing LPC DMA WORD Accesses (with Wishbone error)");
    dma_chan_i = 3'h2;
    wb_write(32'h00000008, `WB_SEL_WORD, 32'hedcba987, 1);
    wb_read(32'h00000008, `WB_SEL_WORD, 32'hedcba987, 1);

    dma_chan_i = 3'h0;
    wbs_tga_i = `WB_TGA_FW;

    // Firmware accesses cannot generate an error, according to the LPC spec;
	 // however, the wishbone write will fail, so the subsequent read
	 // will return bad data, so we just don't check the read data.
    $display($time, " Testing LPC Firmwre BYTE Accesses (with Wishbone error)");
    wb_write(32'h00000008, `WB_SEL_BYTE, 32'hXXXXXX12, 0);
    wb_read(32'h00000008, `WB_SEL_BYTE, 32'hXXXXXXXX, 0);

    $display($time, " Testing LPC Firmware SHORT Accesses (with Wishbone error)");
    wb_write(32'h00000008, `WB_SEL_SHORT, 32'hXXXX3456, 0);
    wb_read(32'h00000008, `WB_SEL_SHORT, 32'hXXXXXXXX, 0);

    $display($time, " Testing LPC Firmware WORD Accesses (with Wishbone error)");
    wb_write(32'h00000008, `WB_SEL_WORD, 32'h789abcde, 0);
    wb_read(32'h00000008, `WB_SEL_WORD, 32'hXXXXXXXX, 0);

    $display($time, " Simulation passed"); $stop(1);

end

endmodule // wb_lpc_master_tf
