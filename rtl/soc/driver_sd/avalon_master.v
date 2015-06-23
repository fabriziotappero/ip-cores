/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module avalon_master(
    input               clk,
    input               rst_n,
    
    //
    output reg  [31:0]  avm_address,
    input               avm_waitrequest,
    output reg          avm_read,
    input       [31:0]  avm_readdata,
    input               avm_readdatavalid,
    output reg          avm_write,
    output reg  [31:0]  avm_writedata,
    
    //
    input       [31:0]  avalon_address_base,
    
    //
    input               read_start,
    input               read_next,
    output reg  [31:0]  read_data,
    output reg          read_done,
    
    //
    input               write_start,
    input               write_next,
    input       [31:0]  write_data,
    output reg          write_done
);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   avm_address <= 32'd0;
    else if(read_start || write_start)  avm_address <= avalon_address_base;
    else if(read_next || write_next)    avm_address <= avm_address + 32'd4;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   avm_read <= 1'b0;
    else if(read_start || read_next)    avm_read <= 1'b1;
    else if(~(avm_waitrequest))         avm_read <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   avm_write <= 1'b0;
    else if(write_start || write_next)  avm_write <= 1'b1;
    else if(~(avm_waitrequest))         avm_write <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   avm_writedata <= 32'd0;
    else if(write_start || write_next)  avm_writedata <= write_data;
end

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   read_data <= 32'd0;
    else if(avm_readdatavalid)          read_data <= avm_readdata;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   read_done <= 1'b0;
    else if(read_start || read_next)    read_done <= 1'b0;
    else                                read_done <= avm_readdatavalid;
end

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   write_done <= 1'b0;
    else if(write_start || write_next)  write_done <= 1'b0;
    else                                write_done <= ~(avm_waitrequest) && avm_write;
end

//------------------------------------------------------------------------------

endmodule
