/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module pit(
    input               clk,
    input               rst_n,
    
    output              irq,
    
    //io slave 040h-043h
    input       [1:0]   io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //speaker port 61h
    input               speaker_61h_read,
    output      [7:0]   speaker_61h_readdata,
    input               speaker_61h_write,
    input       [7:0]   speaker_61h_writedata,
    
    //speaker output
    output reg          speaker_enable,
    output              speaker_out,
    
    //mgmt slave
    /*
    0.[7:0]: cycles in sysclock 1193181 Hz
    */
    input               mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

reg io_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) io_read_last <= 1'b0; else if(io_read_last) io_read_last <= 1'b0; else io_read_last <= io_read; end 
wire io_read_valid = io_read && io_read_last == 1'b0;

//------------------------------------------------------------------------------ system clock

reg [7:0] cycles_in_1193181hz; //838.096ns
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               cycles_in_1193181hz <= 8'd25;
    else if(mgmt_write && mgmt_address == 1'b0)     cycles_in_1193181hz <= mgmt_writedata[7:0];
end

reg [7:0] system_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               system_counter <= 8'd0;
    else if(system_counter >= cycles_in_1193181hz)  system_counter <= 8'd0;
    else                                            system_counter <= system_counter + 8'd2;
end

reg system_clock;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               system_clock <= 1'b0;
    else if(system_counter >= cycles_in_1193181hz)  system_clock <= ~(system_clock);
end

//------------------------------------------------------------------------------ read io

wire [7:0] io_readdata_next =
    (io_read_valid && io_address == 2'd0)?    counter_0_readdata :
    (io_read_valid && io_address == 2'd1)?    counter_1_readdata :
    (io_read_valid && io_address == 2'd2)?    counter_2_readdata :
                                              8'd0; //control address

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'd0;
    else                io_readdata <= io_readdata_next;
end

//------------------------------------------------------------------------------ speaker

assign speaker_61h_readdata = { 2'b0, speaker_out, counter_1_toggle, 2'b0, speaker_enable, speaker_gate };

reg [5:0] counter_1_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           counter_1_cnt <= 6'd0;
    else if(system_counter >= cycles_in_1193181hz && counter_1_cnt == 6'd35)    counter_1_cnt <= 6'd0;
    else if(system_counter >= cycles_in_1193181hz)                              counter_1_cnt <= counter_1_cnt + 6'd1;
end

reg counter_1_toggle;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           counter_1_toggle <= 1'b0;
    else if(system_counter >= cycles_in_1193181hz && counter_1_cnt == 6'd35)    counter_1_toggle <= ~(counter_1_toggle);
end


reg speaker_gate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           speaker_gate <= 1'b0;
    else if(speaker_61h_write)  speaker_gate <= speaker_61h_writedata[0];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           speaker_enable <= 1'b0;
    else if(speaker_61h_write)  speaker_enable <= speaker_61h_writedata[1];
end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

wire [7:0] counter_0_readdata;
wire [7:0] counter_1_readdata;
wire [7:0] counter_2_readdata;

pit_counter pit_counter_0(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .clock              (system_clock),     //input
    .gate               (1'b1),             //input
    .out                (irq),              //output
    
    .data_in            (io_writedata),                                                                                                                                         //input [7:0]
    .set_control_mode   (io_write && io_address == 2'd3 && io_writedata[7:6] == 2'b00 && io_writedata[5:4] != 2'b00),                                                           //input
    .latch_count        (io_write && io_address == 2'd3 && ((io_writedata[7:6] == 2'b00 && io_writedata[5:4] == 2'b00) || (io_writedata[7:5] == 3'b110 && io_writedata[1]))),   //input
    .latch_status       (io_write && io_address == 2'd3 && io_writedata[7:6] == 2'b11 && io_writedata[4] == 1'b0 && io_writedata[1]),                                           //input
    .write              (io_write && io_address == 2'd0),                                                                                                                       //input
    .read               (io_read_valid && io_address == 2'd0),                                                                                                                  //input
    
    .data_out           (counter_0_readdata)    //output [7:0]
);

pit_counter pit_counter_1(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .clock              (system_clock),     //input
    .gate               (1'b1),             //input
    /* verilator lint_off PINNOCONNECT */
    .out                (),                 //output
    /* verilator lint_on PINNOCONNECT */
    
    .data_in            (io_writedata),                                                                                                                                         //input [7:0]
    .set_control_mode   (io_write && io_address == 2'd3 && io_writedata[7:6] == 2'b01 && io_writedata[5:4] != 2'b00),                                                           //input
    .latch_count        (io_write && io_address == 2'd3 && ((io_writedata[7:6] == 2'b01 && io_writedata[5:4] == 2'b00) || (io_writedata[7:5] == 3'b110 && io_writedata[2]))),   //input
    .latch_status       (io_write && io_address == 2'd3 && io_writedata[7:6] == 2'b11 && io_writedata[4] == 1'b0 && io_writedata[2]),                                           //input
    .write              (io_write && io_address == 2'd1),                                                                                                                       //input
    .read               (io_read_valid && io_address == 2'd1),                                                                                                                  //input
    
    .data_out           (counter_1_readdata)    //output [7:0]
);

pit_counter pit_counter_2(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .clock              (system_clock),     //input
    .gate               (speaker_gate),     //input
    .out                (speaker_out),      //output
    
    .data_in            (io_writedata),                                                                                                                                         //input [7:0]
    .set_control_mode   (io_write && io_address == 2'd3 && io_writedata[7:6] == 2'b10 && io_writedata[5:4] != 2'b00),                                                           //input
    .latch_count        (io_write && io_address == 2'd3 && ((io_writedata[7:6] == 2'b10 && io_writedata[5:4] == 2'b00) || (io_writedata[7:5] == 3'b110 && io_writedata[3]))),   //input
    .latch_status       (io_write && io_address == 2'd3 && io_writedata[7:6] == 2'b11 && io_writedata[4] == 1'b0 && io_writedata[3]),                                           //input
    .write              (io_write && io_address == 2'd2),                                                                                                                       //input
    .read               (io_read_valid && io_address == 2'd2),                                                                                                                  //input
    
    .data_out           (counter_2_readdata)    //output [7:0]
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, speaker_61h_read, speaker_61h_writedata[7:2], mgmt_writedata[31:8], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
