//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_cmd_master_tb.sv                                          ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for sd_cmd_master module                           ////
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

module sd_cmd_master_tb();

parameter SD_TCLK = 20; // 50 MHz -> timescale 1ns

reg sd_clk;
reg rst;
reg start_i;
reg int_status_rst_i;
wire [1:0] setting_o;
reg start_xfr_o;
wire go_idle_o;
wire [39:0] cmd_o;
reg [119:0] response_i;
reg crc_ok_i;
reg index_ok_i;
reg finish_i;
reg busy_i;
reg [31:0] argument_i;
reg [13:0] command_i;
reg [15:0] timeout_i;
wire [`INT_CMD_SIZE-1:0] int_status_o;
wire [31:0] response_0_o;
wire [31:0] response_1_o;
wire [31:0] response_2_o;
wire [31:0] response_3_o;

sd_cmd_master sd_cmd_master_dut(
           .sd_clk(sd_clk),
           .rst(rst),
           .start_i(start_i),
           .int_status_rst_i(int_status_rst_i),
           .setting_o(setting_o),
           .start_xfr_o(start_xfr_o),
           .go_idle_o(go_idle_o),
           .cmd_o(cmd_o),
           .response_i(response_i),
           .crc_ok_i(crc_ok_i),
           .index_ok_i(index_ok_i),
           .finish_i(finish_i),
           .busy_i(busy_i),
           //input card_detect,
           .argument_i(argument_i),
           .command_i(command_i),
           .timeout_i(timeout_i),
           .int_status_o(int_status_o),
           .response_0_o(response_0_o),
           .response_1_o(response_1_o),
           .response_2_o(response_2_o),
           .response_3_o(response_3_o)
       );

// Generating WB_CLK_I clock
always
begin
    sd_clk=0;
    forever #(SD_TCLK/2) sd_clk = ~sd_clk;
end

initial
begin
    rst = 1;
    start_i = 0;
    int_status_rst_i = 0;
    response_i = 0;
    crc_ok_i = 0;
    index_ok_i = 0;
    finish_i = 0;
    busy_i = 0;
    argument_i = 0;
    command_i = 0;
    timeout_i = 0;
    
    $display("sd_cmd_master_tb start ...");
    
    #(3*SD_TCLK);
    rst = 0;
    assert(setting_o == 0);
    assert(go_idle_o == 0);
    assert(int_status_o == 0);
    #(3*SD_TCLK);
    assert(setting_o == 0);
    assert(go_idle_o == 0);
    assert(int_status_o == 0);

    //test every response type with
    //without response
    start_i = 1;
    argument_i = 32'h01234567;
    command_i = 16'h0100; //CMD1
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    argument_i = 0;
    command_i = 0;
    timeout_i = 0;
    assert(start_xfr_o == 1);
    assert(setting_o == 2'b00);
    assert(go_idle_o == 0);
    assert(cmd_o == 40'h4101234567);
    #(10*SD_TCLK);
    finish_i = 1;
    #SD_TCLK;
    finish_i = 0;
    assert(start_xfr_o == 0);
    assert(go_idle_o == 0);
    assert(int_status_o == 1);
    
    int_status_rst_i = 1;
    #SD_TCLK;
    int_status_rst_i = 0;
    assert(int_status_o == 0);
    
    //with response
    start_i = 1;
    argument_i = 32'hdeadbeef;
    command_i = 16'h0501; //CMD5
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    argument_i = 0;
    command_i = 0;
    timeout_i = 0;
    assert(start_xfr_o == 1);
    assert(setting_o == 2'b01);
    assert(go_idle_o == 0);
    assert(cmd_o == 40'h45deadbeef);
    #(10*SD_TCLK);
    finish_i = 1;
    response_i = 120'h0102030405060708090a0b0c0d0e0f;
    #SD_TCLK;
    finish_i = 0;
    response_i = 0;
    assert(start_xfr_o == 0);
    assert(go_idle_o == 0);
    assert(int_status_o == 1);
    assert(response_0_o == 32'h01020304);
    assert(response_1_o == 32'h05060708);
    assert(response_2_o == 32'h090a0b0c);
    assert(response_3_o == 32'h0d0e0f00);
    #SD_TCLK;
    
    //with long response
    start_i = 1;
    argument_i = 32'hbad0dad0;
    command_i = 16'h1503; //CMD13
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    argument_i = 0;
    command_i = 0;
    timeout_i = 0;
    assert(int_status_o == 0); //status should be reset by ne command
    assert(start_xfr_o == 1);
    assert(setting_o == 2'b11);
    assert(go_idle_o == 0);
    assert(cmd_o == 40'h55bad0dad0);
    #(10*SD_TCLK);
    finish_i = 1;
    response_i = 120'h1112131415161718191a1b1c1d1e1f;
    #SD_TCLK;
    finish_i = 0;
    response_i = 0;
    assert(start_xfr_o == 0);
    assert(go_idle_o == 0);
    assert(int_status_o == 1);
    assert(response_0_o == 32'h11121314);
    assert(response_1_o == 32'h15161718);
    assert(response_2_o == 32'h191a1b1c);
    assert(response_3_o == 32'h1d1e1f00);
    
    int_status_rst_i = 1;
    #SD_TCLK;
    int_status_rst_i = 0;
    assert(int_status_o == 0);
    
    //test crc and index checks
    //default setup
    argument_i = 0;
    timeout_i = 100;
    response_i = 120'h0;
    
    //with crc check - no error
    start_i = 1;
    command_i = 16'h2509; //CMD5
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    #(10*SD_TCLK);
    finish_i = 1;
    crc_ok_i = 1;
    #SD_TCLK;
    finish_i = 0;
    crc_ok_i = 0;
    assert(int_status_o == 1);
    #SD_TCLK;
    
    //with crc check - error
    start_i = 1;
    command_i = 16'h2509; //CMD5
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    #(10*SD_TCLK);
    finish_i = 1;
    #SD_TCLK;
    finish_i = 0;
    response_i = 0;
    assert(int_status_o == 5'b01011);
    #SD_TCLK;
    
    //with index check - no error
    start_i = 1;
    command_i = 16'h2511; //CMD5
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    #(10*SD_TCLK);
    finish_i = 1;
    index_ok_i = 1;
    #SD_TCLK;
    finish_i = 0;
    index_ok_i = 0;
    assert(int_status_o == 1);
    #SD_TCLK;
    
    //with index check - error
    start_i = 1;
    command_i = 16'h2511; //CMD5
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    #(10*SD_TCLK);
    finish_i = 1;
    #SD_TCLK;
    finish_i = 0;
    assert(int_status_o == 5'b10011);
    #SD_TCLK;
    
    //with index and crc check - no error
    start_i = 1;
    command_i = 16'h2519; //CMD5
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    #(10*SD_TCLK);
    finish_i = 1;
    crc_ok_i = 1;
    index_ok_i = 1;
    #SD_TCLK;
    finish_i = 0;
    crc_ok_i = 0;
    index_ok_i = 0;
    assert(int_status_o == 1);
    #SD_TCLK;
    
    //with index check - error
    start_i = 1;
    command_i = 16'h2519; //CMD5
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    #(10*SD_TCLK);
    finish_i = 1;
    #SD_TCLK;
    finish_i = 0;
    assert(int_status_o == 5'b11011);
    #SD_TCLK;
    
    //test timeout
    start_i = 1;
    command_i = 16'h2519; //CMD5
    timeout_i = 10;
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    wait(go_idle_o == 1);
    #(3*SD_TCLK/2);
    assert(int_status_o == 5'b00110);
    assert(start_xfr_o == 0);
    #(2*SD_TCLK);
    assert(go_idle_o == 0);
    
    //check if can perform normal xfer after timeout
    start_i = 1;
    argument_i = 32'hdeadbeef;
    command_i = 16'h0501; //CMD5
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    argument_i = 0;
    command_i = 0;
    timeout_i = 0;
    assert(start_xfr_o == 1);
    assert(setting_o == 2'b01);
    assert(go_idle_o == 0);
    assert(cmd_o == 40'h45deadbeef);
    #(10*SD_TCLK);
    finish_i = 1;
    response_i = 120'h0102030405060708090a0b0c0d0e0f;
    #SD_TCLK;
    finish_i = 0;
    response_i = 0;
    assert(start_xfr_o == 0);
    assert(go_idle_o == 0);
    assert(int_status_o == 1);
    assert(response_0_o == 32'h01020304);
    assert(response_1_o == 32'h05060708);
    assert(response_2_o == 32'h090a0b0c);
    assert(response_3_o == 32'h0d0e0f00);
    #SD_TCLK;
    
    //test with busy check
    start_i = 1;
    command_i = 16'h7505;
    timeout_i = 100;
    #SD_TCLK;
    start_i = 0;
    command_i = 0;
    timeout_i = 0;
    #(10*SD_TCLK);
    busy_i = 1;
    finish_i = 1;
    crc_ok_i = 1;
    #SD_TCLK;
    finish_i = 0;
    crc_ok_i = 0;
    assert(int_status_o == 0);
    #(5*SD_TCLK)
    assert(int_status_o == 0);
    busy_i = 0;
    #SD_TCLK;
    assert(int_status_o == 1);
    #SD_TCLK;

    #(10*SD_TCLK) $display("sd_cmd_master_tb finish ...");
    $finish;
    
end

endmodule