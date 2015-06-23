//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_data_xfer_trig_tb.sv                                      ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for sd_data_xfer_trig module                       ////
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

module sd_data_xfer_trig_tb(); 

parameter SD_TCLK = 20; // 50 MHz -> timescale 1ns

//---------------Input ports---------------
reg sd_clk;
reg rst;
reg cmd_with_data_start_i;
reg r_w_i;
reg [`INT_CMD_SIZE-1:0] cmd_int_status_i;
//---------------Output ports---------------
wire start_tx_o;
wire start_rx_o;

sd_data_xfer_trig sd_data_xfer_trig_dut(
    .sd_clk                (sd_clk),
    .rst                   (rst),
    .cmd_with_data_start_i (cmd_with_data_start_i),
    .r_w_i                 (r_w_i),
    .cmd_int_status_i      (cmd_int_status_i),
    .start_tx_o            (start_tx_o),
    .start_rx_o            (start_rx_o)
    );

// Generating SD_CLK clock
always
begin
    sd_clk = 0;
    forever #(SD_TCLK/2) sd_clk = ~sd_clk;
end

initial
begin
    rst = 1;
    cmd_with_data_start_i = 0;
    r_w_i = 0;
    cmd_int_status_i = 0;
    
    $display("sd_data_xfer_trig_tb start ...");
    
    #(3*SD_TCLK);
    rst = 0;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);

    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //succesful cmd xfer test - read
    cmd_with_data_start_i = 1;
    r_w_i = 1;
    
    #(2*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 1);
    cmd_with_data_start_i = 0;
    r_w_i = 0;
    
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    cmd_int_status_i[`INT_CMD_CC] = 1;
    #(2*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    cmd_int_status_i[`INT_CMD_CC] = 0;
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //reset
    rst = 1;
    #(3*SD_TCLK);
    rst = 0;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //succesful cmd xfer test - write
    cmd_with_data_start_i = 1;
    
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    cmd_with_data_start_i = 0;
    
    #(3*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    cmd_int_status_i[`INT_CMD_CC] = 1;
    #(2*SD_TCLK);
    assert(start_tx_o == 1);
    assert(start_rx_o == 0);
    cmd_int_status_i[`INT_CMD_CC] = 0;
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //reset
    rst = 1;
    #(3*SD_TCLK);
    rst = 0;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //unsuccesful cmd xfer test - read
    cmd_with_data_start_i = 1;
    r_w_i = 1;
    
    #(2*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 1);
    cmd_with_data_start_i = 0;
    r_w_i = 0;
    
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    cmd_int_status_i[`INT_CMD_EI] = 1;
    #(2*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    cmd_int_status_i[`INT_CMD_EI] = 0;
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //reset
    rst = 1;
    #(3*SD_TCLK);
    rst = 0;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    //unsuccesful cmd xfer test - write
    cmd_with_data_start_i = 1;
    
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    cmd_with_data_start_i = 0;
    
    #(3*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    cmd_int_status_i[`INT_CMD_EI] = 1;
    #(2*SD_TCLK);
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    cmd_int_status_i[`INT_CMD_EI] = 0;
    #SD_TCLK;
    assert(start_tx_o == 0);
    assert(start_rx_o == 0);
    
    #(10*SD_TCLK) $display("sd_data_xfer_trig_tb finish ...");
    $finish;
    
end

endmodule