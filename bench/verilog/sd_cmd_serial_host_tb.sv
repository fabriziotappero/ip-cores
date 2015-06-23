//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_cmd_serial_host_tb.sv                                     ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for sd_cmd_serial_host module                      ////
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

module sd_cmd_serial_host_tb();

parameter SD_TCLK = 20; // 50 MHz -> timescale 1ns
parameter CMD_IDLE = 1'b1;
parameter CMD_START = 1'b0;
parameter CMD_END = 1'b1;

//---------------Input ports---------------
reg sd_clk;
reg rst;
reg [1:0] setting_i;
reg [39:0] cmd_i;
reg start_i;
reg cmd_dat_i;
//---------------Output ports---------------
wire cmd_dat_tri;
wire [119:0] response_o;
//wire ack_o;
wire finish_o;
wire crc_ok_o;
wire index_ok_o;
wire cmd_oe_o;
wire cmd_out_o;

wire [39:0] command = 40'h0123456786;
wire [127:0] response = 128'h0156789abcdef0123456789abcdef012;

function integer crc7;
    input integer crc_in;
    input bit inb;
    begin
        inb = inb ^ crc_in[0];
        crc7 = crc_in >> 1;
        crc7 = crc7 ^ (7'h48 & {7{inb}});
    end
endfunction

task sd_card_receive;
    integer crc, i;
    reg [39:0] cmd;
    reg [6:0] crc_in;
    begin
        crc = 0;
        //wait for transmission start
        wait (cmd_oe_o == 1);
        #(SD_TCLK/2);
        //get command bits
        for (i=39; i>=0; i--) begin
            cmd[i] = cmd_out_o;
            crc = crc7(crc, cmd_out_o);
            assert(cmd_oe_o == 1);
            #SD_TCLK;
        end
        assert(cmd == command);
        for (i=0; i<7; i++) begin
            crc_in[i] = cmd_out_o;
            assert(cmd_oe_o == 1);
            #SD_TCLK;
        end
        assert(crc_in == crc);
        assert(cmd_out_o == CMD_END);
        assert(cmd_oe_o == 1);
        #SD_TCLK;
        assert(cmd_oe_o == 0);
    end
endtask

task sd_card_send;
    input long_resp;
    integer crc, i, loop_end;
    begin
        crc = 0;
        if (long_resp) loop_end = 0;
        else loop_end = 127-39;
        for (i=127; i>=loop_end; i--) begin
            cmd_dat_i = response[i];
            if (!long_resp || i < 120)
                crc = crc7(crc, response[i]);
            assert(cmd_oe_o == 0);
            #SD_TCLK;
        end
        for (i=0; i<7; i++) begin
            cmd_dat_i = crc[i];
            assert(cmd_oe_o == 0);
            #SD_TCLK;
        end
        cmd_dat_i = CMD_END;
        assert(cmd_oe_o == 0);
        #SD_TCLK;
        cmd_dat_i = CMD_IDLE;
    end
endtask
    

sd_cmd_serial_host cmd_serial_host_dut(
                       .sd_clk     (sd_clk),
                       .rst        (rst),
                       .setting_i  (setting_i),
                       .cmd_i      (cmd_i),
                       .start_i      (start_i),
                       //.ack_i      (ack_i),
                       .finish_o (finish_o),
                       //.ack_o      (ack_o),
                       .response_o (response_o),
                       .crc_ok_o   (crc_ok_o),
                       .index_ok_o (index_ok_o),
                       .cmd_dat_i  (cmd_dat_tri),
                       .cmd_out_o  (cmd_out_o),
                       .cmd_oe_o   (cmd_oe_o)
                   );

assign cmd_dat_tri = cmd_oe_o ? cmd_out_o : cmd_dat_i;
// Generating WB_CLK_I clock
always
begin
    sd_clk=0;
    forever #(SD_TCLK/2) sd_clk = ~sd_clk;
end

initial
begin
    rst = 1;
    setting_i = 0;
    cmd_i = 1;
    start_i = 0;
    //ack_i = 0;
    cmd_dat_i = CMD_IDLE;
    
    $display("sd_cmd_serial_host_tb start ...");
    
    #(3*SD_TCLK);
    rst = 0;
    assert(finish_o == 0);
    //assert(ack_o == 0);
    assert(crc_ok_o == 0);
    assert(index_ok_o == 0);
    assert(cmd_out_o == 1);
    assert(cmd_oe_o == 1);
    #SD_TCLK;
    assert(finish_o == 0);
    //assert(ack_o == 0);
    assert(crc_ok_o == 0);
    assert(index_ok_o == 0);
    assert(cmd_out_o == 1);
    assert(cmd_oe_o == 1);
    #(65*SD_TCLK); //INIT_DELAY
    assert(finish_o == 0);
    //assert(ack_o == 1);
    assert(crc_ok_o == 0);
    assert(index_ok_o == 0);
    assert(cmd_oe_o == 0);
    
    //tests with normal response (check index, check crc)
    //tests with long response (check crc)
    
    //cmd without response
    setting_i = {2'h0};
    cmd_i <= command;
    start_i <= 1'b1;
    #SD_TCLK;
    setting_i = 0;
    cmd_i <= 0;
    start_i <= 0;
    fork
        sd_card_receive;
        begin
            wait(finish_o == 1);
            #(SD_TCLK/2);
            assert(crc_ok_o == 0);
            assert(index_ok_o == 0);
        end
    join
    
    //cmd with r1 response
    setting_i = {2'h1};
    cmd_i <= command;
    start_i <= 1'b1;
    #SD_TCLK;
    setting_i = 0;
    cmd_i <= 0;
    start_i <= 0;
    
    fork
        begin
            sd_card_receive;
            assert(finish_o == 0);
            sd_card_send(0);
        end
        begin
            wait(finish_o == 1);
            #(SD_TCLK/2);
            assert(response_o[119:88] == response[119:88]);
            assert(crc_ok_o == 1);
            assert(index_ok_o == 1);
        end
    join
    
    //cmd with r2 response
    setting_i = {2'h3};
    cmd_i <= command;
    start_i <= 1'b1;
    #SD_TCLK;
    setting_i = 0;
    cmd_i <= 0;
    start_i <= 0;
    
    fork
        begin
            sd_card_receive;
            assert(finish_o == 0);
            sd_card_send(1);
        end
        begin
            wait(finish_o == 1);
            #(SD_TCLK/2);
            assert(response_o == response[119:0]);
            assert(crc_ok_o == 1);
            assert(index_ok_o == 1);
        end
    join

    #(1000*SD_TCLK) $display("sd_cmd_serial_host_tb finish ...");
    $finish;
    
end

endmodule