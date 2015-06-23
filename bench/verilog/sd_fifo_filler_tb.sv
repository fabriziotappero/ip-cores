//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_fifo_filler_tb.sv                                         ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for sd_fifo_filler module                          ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module sd_fifo_filler_tb();

parameter WB_TCLK = 20; // 50 MHz -> timescale 1ns
parameter SD_TCLK = WB_TCLK*2; // 25 MHz -> timescale 1ns

reg wb_clk;
reg rst;
wire [31:0] wbm_adr_o;
wire wbm_we_o;
wire [31:0] wbm_dat_o;
wire [31:0] wbm_dat_i;
wire wbm_cyc_o;
wire wbm_stb_o;
wire wbm_ack_i;
reg en_rx_i;
reg en_tx_i;
reg [31:0] adr_i;
reg sd_clk;
reg [31:0] dat_i;
wire [31:0] dat_o;
reg wr_i;
reg rd_i;
wire sd_full_o;
wire sd_empty_o;
wire wb_full_o;
wire wb_empty_o;

//wb slave helpers
integer wb_wait;
integer wb_wait_counter;
integer wb_idx;
//fifo driver helpers
reg fifo_drv_ena;
integer fifo_drv_wait;
integer fifo_drv_wait_counter;
integer fifo_drv_idx;

//test memory vector
integer test_mem[0:31] = {
        32'h01234567, 32'h12345678, 32'h23456789, 32'h3456789a, 32'h456789ab, 32'h56789abc, 32'h6789abcd, 32'h789abcde,
        32'h89abcdef, 32'h9abcdef0, 32'habcdef01, 32'hbcdef012, 32'hcdef0123, 32'hdef01234, 32'hef012345, 32'hf0123456,
        32'h00010203, 32'h04050607, 32'h08090a0b, 32'h0c0d0e0f, 32'h10111213, 32'h14151617, 32'h18191a1b, 32'h1c1d1e1f,
        32'h20212223, 32'h24252627, 32'h28292a2b, 32'h2c2d2e2f, 32'h30313233, 32'h34353637, 32'h38393a3b, 32'h3c3d3e3f
    };

sd_fifo_filler sd_fifo_filler_dut(
                      .wb_clk    (wb_clk),
                      .rst       (rst),
                      .wbm_adr_o (wbm_adr_o),
                      .wbm_we_o  (wbm_we_o),
                      .wbm_dat_o (wbm_dat_o),
                      .wbm_dat_i (wbm_dat_i),
                      .wbm_cyc_o (wbm_cyc_o),
                      .wbm_stb_o (wbm_stb_o),
                      .wbm_ack_i (wbm_ack_i),
                      .en_rx_i   (en_rx_i),
                      .en_tx_i   (en_tx_i),
                      .adr_i     (adr_i),
                      .sd_clk    (sd_clk),
                      .dat_i     (dat_i),
                      .dat_o     (dat_o),
                      .wr_i      (wr_i),
                      .rd_i      (rd_i),
                      .sd_empty_o   (sd_empty_o),
                      .sd_full_o   (sd_full_o),
                      .wb_empty_o   (wb_empty_o),
                      .wb_full_o    (wb_full_o)
                  );

// Generating sd_clk clock
always
begin
    sd_clk=0;
    forever #(SD_TCLK/2) sd_clk = ~sd_clk;
end
// Generating wb_clk clock
always
begin
    wb_clk=0;
    forever #(WB_TCLK/2) wb_clk = ~wb_clk;
end

assign wbm_ack_i = wbm_cyc_o && wbm_stb_o & wb_wait == wb_wait_counter;
assign wbm_dat_i = wbm_ack_i ? test_mem[wb_idx] : 0;
//wb slave
always @(posedge wb_clk) begin
    if (wbm_cyc_o && wbm_stb_o && wbm_we_o) begin
        if (wbm_ack_i) begin
            assert(test_mem[wb_idx] == wbm_dat_o);
            assert(wbm_adr_o == adr_i + 4*wb_idx);
            wb_wait_counter <= 0;
            wb_idx++;
        end
        wb_wait_counter++;
    end
    else if (wbm_cyc_o && wbm_stb_o) begin
        if (wbm_ack_i) begin
            assert(wbm_adr_o == adr_i + 4*wb_idx);
            wb_wait_counter <= 0;
            wb_idx++;
        end
        wb_wait_counter++;
    end
    else begin
        wb_wait_counter <= 0;
    end
    if (!en_rx_i && !en_tx_i) wb_idx = 0;
end
    
//fifo driver
always @(posedge sd_clk)
    if (en_rx_i) begin
        if (fifo_drv_wait == fifo_drv_wait_counter) begin
            wr_i <= 1;
            dat_i <= test_mem[fifo_drv_idx];
            fifo_drv_wait_counter <= 0;
            fifo_drv_idx++;
        end
        else begin
            wr_i <= 0;
            dat_i <= 0;
            fifo_drv_wait_counter++;
        end
    end
    else if (fifo_drv_ena) begin
        if (fifo_drv_wait_counter == 0) begin
            rd_i <= 1;
            assert(dat_o == test_mem[fifo_drv_idx]);
            fifo_drv_wait_counter++;
            fifo_drv_idx++;
        end
        else begin
            rd_i <= 0;
            if (fifo_drv_wait_counter == fifo_drv_wait)
                fifo_drv_wait_counter <= 0;
            else
                fifo_drv_wait_counter++;
        end
    end
    else begin
        wr_i <= 0;
        rd_i <= 0;
        fifo_drv_idx = 0;
        fifo_drv_wait_counter <= 0;
    end

initial
begin
    rst = 1;
    fifo_drv_wait = 0;
    fifo_drv_ena = 0;
    wb_wait = 2;
    en_rx_i = 0;
    en_tx_i = 0;
    adr_i = 0;
    dat_i = 0;
    wr_i = 0;
    rd_i = 0;
    
    $display("sd_fifo_filler_tb finish ...");
    
    #(3*WB_TCLK);
    rst = 0;
    assert(wbm_we_o == 0);
    assert(wbm_cyc_o == 0);
    assert(wbm_stb_o == 0);
    assert(wb_full_o == 0);
    #(3*WB_TCLK);
    assert(wbm_we_o == 0);
    assert(wbm_cyc_o == 0);
    assert(wbm_stb_o == 0);
    assert(wb_full_o == 0);
    assert(sd_empty_o == 1);
    
    //check normal operation
    en_rx_i = 1;
    fifo_drv_wait = 7;
    wb_wait = 2;
    
    #(100*WB_TCLK);
    wait(wbm_cyc_o == 0);
    en_rx_i = 0;
    #SD_TCLK;
    assert(wbm_we_o == 0);
    assert(wbm_cyc_o == 0);
    assert(wbm_stb_o == 0);
    assert(wb_full_o == 0);

    //check for full condition
    #(WB_TCLK/2);
    en_rx_i = 1;
    fifo_drv_wait = 7;
    wb_wait = 17*(fifo_drv_wait+1)*(SD_TCLK/WB_TCLK);
    #(wb_wait*WB_TCLK);
    #SD_TCLK;
    assert(sd_full_o == 1);
    assert(wb_empty_o == 0);
    en_rx_i = 0;
    fork
        begin
            #WB_TCLK;
            assert(wbm_we_o == 0);
            assert(wbm_cyc_o == 0);
            assert(wbm_stb_o == 0);
        end
        begin
            #SD_TCLK;
            assert(sd_full_o == 0);
        end
    join
    wait(wb_empty_o == 1);
    #SD_TCLK;
    
    //fill almost fuul fifo then burst write
    en_rx_i = 1;
    fifo_drv_wait = 7;
    wb_wait = 14*(fifo_drv_wait+1)*(SD_TCLK/WB_TCLK);
    wait(wbm_ack_i);
    #SD_TCLK;
    assert(sd_full_o == 0);
    assert(wb_empty_o == 0);
    wb_wait = 0;
    wait(wb_empty_o == 1);
    wait(wbm_cyc_o == 0);
    en_rx_i = 0;
    #SD_TCLK;
    assert(wbm_we_o == 0);
    assert(wbm_cyc_o == 0);
    assert(wbm_stb_o == 0);
    assert(sd_full_o == 0);
    
//////////////////////////////////////////////////////////////
    //check fifo fill
    en_tx_i = 1;
    wb_wait = 2;
    wait(wb_full_o == 1);
    #(WB_TCLK/2);
    assert(sd_empty_o == 0);
    assert(wbm_we_o == 0);
    assert(wbm_cyc_o == 0);
    assert(wbm_stb_o == 0);
    #WB_TCLK;
    assert(sd_empty_o == 0);
    assert(wbm_we_o == 0);
    assert(wbm_cyc_o == 0);
    assert(wbm_stb_o == 0);
    
    //check normal operation
    fifo_drv_wait = 7;
    fifo_drv_ena = 1;
    #(100*SD_TCLK);
    wait(wbm_cyc_o == 0 && rd_i == 0);
    #(WB_TCLK/2);
    en_tx_i = 0;
    fifo_drv_ena = 0;
    wait(sd_empty_o == 1);
    assert(wb_full_o == 0);

    #(10*WB_TCLK) $display("sd_fifo_filler_tb finish ...");
    $finish;
    
end

endmodule