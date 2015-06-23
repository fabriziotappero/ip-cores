/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module avalon_slave(
    input               clk,
    input               rst_n,
    
    //
    input       [1:0]   avs_address,
    input               avs_read,
    output      [31:0]  avs_readdata,
    input               avs_write,
    input       [31:0]  avs_writedata,
    
    //
    output reg          operation_init,
    output reg          operation_read,
    output reg          operation_write,
    
    input               operation_sector_update,
    output              operation_sector_last,
    
    input               operation_finished_ok,
    input               operation_finished_with_error,
    
    //
    output reg  [31:0]  sd_address,
    output reg  [31:0]  avalon_address_base  
);

//------------------------------------------------------------------------------

assign avs_readdata = (avs_address == 2'd0)? {29'd0, status[2:0]} : { 29'd0, mutex };

reg [2:0] mutex;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               mutex <= 3'd0;
    else if(mutex == 3'd0 && avs_address == 2'd1 && avs_read)                       mutex <= 3'd1;
    else if(mutex == 3'd0 && avs_address == 2'd2 && avs_read)                       mutex <= 3'd2;
    else if(mutex == 3'd0 && avs_address == 2'd3 && avs_read)                       mutex <= 3'd3;
    else if(mutex < 3'd4 && (operation_init || operation_read || operation_write))  mutex <= 3'd4;
    else if(operation_finished_ok || operation_finished_with_error)                 mutex <= 3'd0;
end

//------------------------------------------------------------------------------

wire operation_idle = ~(operation_init) && ~(operation_read) && ~(operation_write);

localparam [1:0] CONTROL_IDLE   = 2'd0; //not used
localparam [1:0] CONTROL_INIT   = 2'd1;
localparam [1:0] CONTROL_READ   = 2'd2;
localparam [1:0] CONTROL_WRITE  = 2'd3;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   operation_init <= 1'b1;
    else if(operation_finished_ok || operation_finished_with_error)                                     operation_init <= 1'b0;
    else if(operation_idle && avs_write && avs_address == 2'd3 && avs_writedata[1:0] == CONTROL_INIT)   operation_init <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   operation_read <= 1'b0;
    else if(operation_finished_ok || operation_finished_with_error)                                     operation_read <= 1'b0;
    else if(operation_idle && avs_write && avs_address == 2'd3 && avs_writedata[1:0] == CONTROL_READ)   operation_read <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   operation_write <= 1'b0;
    else if(operation_finished_ok || operation_finished_with_error)                                     operation_write <= 1'b0;
    else if(operation_idle && avs_write && avs_address == 2'd3 && avs_writedata[1:0] == CONTROL_WRITE)  operation_write <= 1'b1;
end

//------------------------------------------------------------------------------

localparam [2:0] STATUS_INIT        = 3'd0;
localparam [2:0] STATUS_INIT_ERROR  = 3'd1;
localparam [2:0] STATUS_IDLE        = 3'd2;
localparam [2:0] STATUS_READ        = 3'd3;
localparam [2:0] STATUS_WRITE       = 3'd4;
localparam [2:0] STATUS_ERROR       = 3'd5;

reg [2:0] status;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   status <= STATUS_INIT;
    else if(operation_idle && avs_write && avs_address == 2'd3 && avs_writedata[1:0] == CONTROL_INIT)   status <= STATUS_INIT;
    else if(operation_idle && avs_write && avs_address == 2'd3 && avs_writedata[1:0] == CONTROL_READ)   status <= STATUS_READ;
    else if(operation_idle && avs_write && avs_address == 2'd3 && avs_writedata[1:0] == CONTROL_WRITE)  status <= STATUS_WRITE;
    else if(operation_init && operation_finished_with_error)                                            status <= STATUS_INIT_ERROR;
    else if(operation_finished_with_error)                                                              status <= STATUS_ERROR;
    else if(operation_finished_ok)                                                                      status <= STATUS_IDLE;
end

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           avalon_address_base <= 32'd0;
    else if(operation_idle && avs_write && avs_address == 2'd0) avalon_address_base <= avs_writedata;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           sd_address <= 32'd0;
    else if(operation_idle && avs_write && avs_address == 2'd1) sd_address <= avs_writedata;
end

reg [31:0] sd_block_count;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           sd_block_count <= 32'd0;
    else if(operation_sector_update)                            sd_block_count <= sd_block_count - 32'd1;
    else if(operation_idle && avs_write && avs_address == 2'd2) sd_block_count <= avs_writedata;
end

assign operation_sector_last = sd_block_count == 32'd1;

//------------------------------------------------------------------------------

endmodule
