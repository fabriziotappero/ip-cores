//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_controller_wb_tb.sv                                       ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for sd_controller_wb module                        ////
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

`include "sd_defines.h"

module sd_controller_wb_tb();

parameter TCLK = 20; // 50 MHz -> timescale 1ns

reg wb_clk_i;
reg wb_rst_i;
reg [31:0] wb_dat_i;
wire [31:0] wb_dat_o;
reg [7:0] wb_adr_i;
reg [3:0] wb_sel_i;
reg wb_we_i;
reg wb_cyc_i;
reg wb_stb_i;
wire wb_ack_o;
wire cmd_start;
wire [31:0] argument_reg;
wire [`CMD_REG_SIZE-1:0] command_reg;
reg [31:0] response_0_reg;
reg [31:0] response_1_reg;
reg [31:0] response_2_reg;
reg [31:0] response_3_reg;
wire [0:0] software_reset_reg;
wire [15:0] timeout_reg;
wire [`BLKSIZE_W-1:0] block_size_reg;
wire [15:0] controll_setting_reg;
reg [`INT_CMD_SIZE-1:0] cmd_int_status_reg;
wire [`INT_CMD_SIZE-1:0] cmd_int_enable_reg;
wire [7:0] clock_divider_reg;
reg [`INT_DATA_SIZE-1:0] data_int_status_reg;
wire [`INT_DATA_SIZE-1:0] data_int_enable_reg;
wire data_int_rst;
wire cmd_int_rst;
wire [`BLKCNT_W-1:0]block_count_reg;
wire [31:0] dma_addr_reg;

sd_controller_wb sd_controller_wb_dut(
           wb_clk_i, 
           wb_rst_i, 
           wb_dat_i, 
           wb_dat_o,
           wb_adr_i, 
           wb_sel_i, 
           wb_we_i, 
           wb_cyc_i, 
           wb_stb_i, 
           wb_ack_o,
           cmd_start,
           data_int_rst,
           cmd_int_rst,
           argument_reg,
           command_reg,
           response_0_reg,
           response_1_reg,
           response_2_reg,
           response_3_reg,
           software_reset_reg,
           timeout_reg,
           block_size_reg,
           controll_setting_reg,
           cmd_int_status_reg,
           cmd_int_enable_reg,
           clock_divider_reg,
           block_count_reg,
           dma_addr_reg,
           data_int_status_reg,
           data_int_enable_reg
       );

// Generating wb_clk_i clock
always
begin
    wb_clk_i=0;
    forever #(TCLK/2) wb_clk_i = ~wb_clk_i;
end

task wb_write;
    input integer data;
    input integer addr;
    begin
        //wait for falling edge of wb_clk_i
        wait(wb_clk_i == 1);
        wait(wb_clk_i == 0);
        
        wb_dat_i = data;
        wb_adr_i = addr;
        wb_sel_i = 4'b1111;
        wb_we_i = 1;
        wb_cyc_i = 1;
        wb_stb_i = 1;

        wait(wb_ack_o == 1);
        wb_dat_i = 0;
        wb_adr_i = 0;
        wb_sel_i = 0;
        wb_we_i = 0;
        wb_cyc_i = 0;
        wb_stb_i = 0;
        
        #(1.5*TCLK);
        assert(wb_ack_o == 0);
        #TCLK;
    end
endtask

task wb_read_check;
    input integer data;
    input integer addr;
    begin
        //wait for falling edge of wb_clk_i
        wait(wb_clk_i == 1);
        wait(wb_clk_i == 0);
        
        wb_adr_i = addr;
        wb_sel_i = 4'b1111;
        wb_we_i = 0;
        wb_cyc_i = 1;
        wb_stb_i = 1;
    
        wait(wb_ack_o == 1);
        wb_dat_i = 0;
        wb_adr_i = 0;
        wb_sel_i = 0;
        wb_we_i = 0;
        wb_cyc_i = 0;
        wb_stb_i = 0;
        assert(wb_dat_o == data);
    
        #(1.5*TCLK);
        assert(wb_ack_o == 0);
        #TCLK;
    end
endtask

initial
begin
    wb_rst_i = 1;
    wb_dat_i = 0;
    wb_adr_i = 0;
    wb_sel_i = 0;
    wb_we_i = 0;
    wb_cyc_i = 0;
    wb_stb_i = 0;
    response_0_reg = 0;
    response_1_reg = 0;
    response_2_reg = 0;
    response_3_reg = 0;
    cmd_int_status_reg = 0;
    data_int_status_reg = 0;
    
    #(3.2*TCLK);
    wb_rst_i = 0;
    #TCLK;

    $display("sd_controller_wb_tb start ...");

    assert(wb_dat_o == 0);
    assert(wb_ack_o == 0);
    assert(cmd_start == 0);
    assert(argument_reg == 0);
    assert(command_reg == 0);
    assert(software_reset_reg == 0);
    assert(timeout_reg == 0);
    assert(block_size_reg == `RESET_BLOCK_SIZE);
    assert(controll_setting_reg == 0);
    assert(cmd_int_status_reg == 0);
    assert(cmd_int_enable_reg == 0);
    assert(clock_divider_reg == `RESET_CLK_DIV);
    assert(data_int_enable_reg == 0);
    assert(data_int_rst == 0);
    assert(cmd_int_rst == 0);
    assert(block_count_reg == 0);
    assert(dma_addr_reg == 0);
    
    //check argument register and cmd_start signal
    fork
        begin
            wb_write(32'h01020304, `argument);
            assert(argument_reg == 32'h01020304);
        end
        begin
            wait(cmd_start == 1);
            #(1.1*TCLK);
            assert(cmd_start == 0);
        end
    join
    
    //check command register
    wb_write(16'h0405, `command);
    assert(command_reg == 16'h0405);
    
    //check response_0 register
    response_0_reg = 32'h04050607;
    wb_read_check(32'h04050607, `resp0);
    
    //check response_1 register
    response_1_reg = 32'h05060708;
    wb_read_check(32'h05060708, `resp1);
    
    //check response_2 register
    response_2_reg = 32'h06070809;
    wb_read_check(32'h06070809, `resp2);
    
    //check response_3 register
    response_3_reg = 32'h0708090a;
    wb_read_check(32'h0708090a, `resp3);
    
    //check controller register
    wb_write(16'h0a0b, `controller);
    assert(controll_setting_reg == 16'h0a0b);
    
    //check timeout register
    wb_write(16'h0b0c, `timeout);
    assert(timeout_reg == 16'h0b0c);
    
    //check clock_devider register
    wb_write(8'h0d, `clock_d);
    assert(clock_divider_reg == 8'h0d);
    
    //check reset register
    wb_write(1'h1, `reset);
    assert(software_reset_reg == 1'h1);

    //check voltage register
    wb_read_check(8'b0000_111_1, `voltage);
    
    //check capability register
    wb_read_check(16'h0000, `capa);
    
    //check cmd_isr register write
    fork
        begin
            wb_write(32'h0, `cmd_isr);
        end
        begin
            wait(cmd_int_rst == 1);
            #(1.1*TCLK);
            assert(cmd_int_rst == 0);
        end
    join
    //check cmd_isr register read
    cmd_int_status_reg = 5'h1a;
    wb_read_check(5'h1a, `cmd_isr);
    
    //check cmd_iser register
    wb_write(5'h15, `cmd_iser);
    assert(cmd_int_enable_reg == 5'h15);
    
    //check data_isr register write
    fork
        begin
            wb_write(32'h0, `data_isr);
        end
        begin
            wait(data_int_rst == 1);
            #(1.1*TCLK);
            assert(data_int_rst == 0);
        end
    join
    //check data_isr register read
    data_int_status_reg = 3'h6;
    wb_read_check(3'h6, `data_isr);
    
    //check data_iser register
    wb_write(3'h5, `data_iser);
    assert(data_int_enable_reg == 3'h5);
    
    //check blksize register
    wb_write(12'habc, `blksize);
    assert(block_size_reg == 12'habc); 
    
    //check blkcnt register
    wb_write(16'h1011, `blkcnt);
    assert(block_count_reg == 16'h1011); 
    
    //check dst_src_addr register
    wb_write(32'h11121314, `dst_src_addr);
    assert(dma_addr_reg == 32'h11121314); 

    #(10*TCLK) $display("sd_controller_wb_tb finish ...");
    $finish;
    
end

endmodule 
 
