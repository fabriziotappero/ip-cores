/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module memory_avalon(
    input               clk,
    input               rst_n,
    
    //{ [66] 1'b is_write, [65:36] 30'b address, [35:4] 32'b value, [3:0] 4'b byteena (4'b0000 - can burst 4 words) } 
    input       [66:0]  ram_fifo_q,
    input               ram_fifo_empty,
    output              ram_fifo_rdreq,
    
    //address and req must be held till ack; on ack address can change
    input       [31:0]  ram_instr_address,
    input               ram_instr_req,
    output reg          ram_instr_ack,
    
    output reg  [31:0]  ram_result_address,
    output reg          ram_result_valid,
    output reg          ram_result_is_read_instr,
    output reg  [2:0]   ram_result_burstcount,
    output reg  [31:0]  ram_result,
    
    //Avalon master interface
    output reg  [31:0]  avm_address,
    output reg  [31:0]  avm_writedata,
    output reg  [3:0]   avm_byteenable,
    output reg  [2:0]   avm_burstcount,
    output reg          avm_write,
    output reg          avm_read,
    
    input               avm_waitrequest,
    input               avm_readdatavalid,
    input       [31:0]  avm_readdata
);

//------------------------------------------------------------------------------ state machine

localparam [1:0] STATE_IDLE  = 2'd0;
localparam [1:0] STATE_WRITE = 2'd1;
localparam [1:0] STATE_READ  = 2'd2;

wire start_write        = (state == STATE_IDLE || ~(avm_waitrequest)) && ~(ram_fifo_empty) && ram_fifo_q[66] == 1'b1;
wire start_read         = (state == STATE_IDLE || ~(avm_waitrequest)) && ~(ram_fifo_empty) && ram_fifo_q[66] == 1'b0 && readp_possible;
wire start_instr_read   = (state == STATE_IDLE || ~(avm_waitrequest)) && ~(start_write) && ~(start_read) && ram_instr_req && readp_possible;

assign ram_fifo_rdreq = start_read || start_write;

reg [1:0] state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       state <= STATE_IDLE;
    else if(start_write)                    state <= STATE_WRITE;
    else if(start_read || start_instr_read) state <= STATE_READ;
    else if(~(avm_waitrequest))             state <= STATE_IDLE;
end

//------------------------------------------------------------------------------ pipeline read

//[33] is_read_instr [32:30] burstcount [29:0] address

wire readp_0_update =                                           (start_read || start_instr_read) && readp_2[32:30] == 3'd0 && readp_1[32:30] == 3'd0 && (readp_0[32:30] == 3'd0 || readp_chain);
wire readp_1_update =                      ~(readp_0_update) && (start_read || start_instr_read) && readp_2[32:30] == 3'd0 &&                           (readp_1[32:30] == 3'd0 || readp_chain);
wire readp_2_update = ~(readp_1_update) && ~(readp_0_update) && (start_read || start_instr_read) &&                                                     (readp_2[32:30] == 3'd0 || readp_chain);

wire readp_chain = readp_0[32:30] == 3'd1 && avm_readdatavalid;

wire [2:0]  readp_0_burstcount = readp_0[32:30] - 3'd1;
wire [29:0] readp_0_address    = readp_0[29:0]  + 30'd1;

wire [2:0]  read_burstcount = (ram_fifo_q[3:0] == 4'h0)? 3'd4 : 3'd1;

wire [33:0] readp_value = (start_read)? { 1'b0, read_burstcount, ram_fifo_q[65:36] } : { 1'b1, 3'd4, ram_instr_address[31:2] };

reg [33:0] readp_0;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   readp_0 <= 34'd0;
    else if(readp_0_update)                             readp_0 <= readp_value;
    else if(readp_chain)                                readp_0 <= readp_1;
    else if(readp_0[32:30] > 3'd0 && avm_readdatavalid) readp_0 <= { readp_0[33], readp_0_burstcount, readp_0_address };
end

reg [33:0] readp_1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       readp_1 <= 34'd0;
    else if(readp_1_update) readp_1 <= readp_value;
    else if(readp_chain)    readp_1 <= readp_2;
end

reg [33:0] readp_2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       readp_2 <= 34'd0;
    else if(readp_2_update) readp_2 <= readp_value;
    else if(readp_chain)    readp_2 <= 34'd0;
end

wire readp_possible = readp_2[32:30] == 3'd0 || readp_1[32:30] == 3'd0 || readp_0[32:30] == 3'd0 || (readp_0[32:30] == 3'd1 && avm_readdatavalid);

//------------------------------------------------------------------------------ avalon bus control

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       avm_address <= 32'd0;
    else if(start_write || start_read)      avm_address <= { ram_fifo_q[65:36], 2'b00 };
    else if(start_instr_read)               avm_address <= { ram_instr_address[31:2], 2'b00 }; 
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       avm_writedata <= 32'd0;
    else if(start_write)                    avm_writedata <= ram_fifo_q[35:4];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       avm_byteenable <= 4'd0;
    else if(start_write || start_read)      avm_byteenable <= (ram_fifo_q[3:0] == 4'h0)? 4'hF : ram_fifo_q[3:0];
    else if(start_instr_read)               avm_byteenable <= 4'hF;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       avm_burstcount <= 3'd0;
    else if(start_write)                    avm_burstcount <= 3'd1;
    else if(start_read)                     avm_burstcount <= read_burstcount;
    else if(start_instr_read)               avm_burstcount <= 3'd4;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       avm_read <= 1'b0;
    else if(start_read || start_instr_read) avm_read <= 1'b1;
    else if(~(avm_waitrequest))             avm_read <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       avm_write <= 1'b0;
    else if(start_write)                    avm_write <= 1'b1;
    else if(~(avm_waitrequest))             avm_write <= 1'b0;
end

//------------------------------------------------------------------------------ results

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ram_instr_ack            <= `FALSE; else ram_instr_ack            <= start_instr_read;         end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ram_result_address       <= 32'd0;  else ram_result_address       <= { readp_0[29:0], 2'b00 }; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ram_result_valid         <= `FALSE; else ram_result_valid         <= avm_readdatavalid;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ram_result_burstcount    <= 3'd0;   else ram_result_burstcount    <= readp_0[32:30];           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ram_result_is_read_instr <= 1'b0;   else ram_result_is_read_instr <= readp_0[33];              end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) ram_result               <= 32'd0;  else ram_result               <= avm_readdata;             end

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, ram_instr_address[1:0], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
