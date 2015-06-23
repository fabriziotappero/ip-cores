/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module memory_ram(
    input               clk,
    input               rst_n,
    
    //
    input               config_switch_caches,
    
    //
    input       [8:0]   fetch_cache_read_address,
    output      [53:0]  fetch_cache_q,
    
    input       [8:0]   fetch_cache_write_address,
    input               fetch_cache_write_enable,
    input       [53:0]  fetch_cache_data,
    
    //
    input       [8:0]   data_cache_read_address,
    output      [53:0]  data_cache_q,
    
    input       [8:0]   data_cache_write_address,
    input               data_cache_write_enable,
    input       [53:0]  data_cache_data,
    
    //
    input               ram_fifo_rdreq,
    input               ram_fifo_wrreq,
    input       [66:0]  ram_fifo_data,
    
    output              ram_fifo_empty,
    output              ram_fifo_full,
    output      [66:0]  ram_fifo_q,
    
    //
    output reg  [4:0]   write_buffer_counter
);

//------------------------------------------------------------------------------

/*
vpn/pfn        offset
------20------ ---12---
tag             index
------21------- --9-- -2-

[53]    valid
[52:32] tag
[31:0]  data
*/

wire [8:0] address_1_r = (config_switch_caches)? fetch_cache_read_address  : data_cache_read_address;
wire [8:0] address_1_w = (config_switch_caches)? fetch_cache_write_address : data_cache_write_address;

wire [8:0] address_2_r = (config_switch_caches)? data_cache_read_address  : fetch_cache_read_address;
wire [8:0] address_2_w = (config_switch_caches)? data_cache_write_address : fetch_cache_write_address;

wire wren_1 = (config_switch_caches)? fetch_cache_write_enable : data_cache_write_enable;
wire wren_2 = (config_switch_caches)? data_cache_write_enable  : fetch_cache_write_enable;

wire [53:0] data_1 = (config_switch_caches)? fetch_cache_data : data_cache_data;
wire [53:0] data_2 = (config_switch_caches)? data_cache_data  : fetch_cache_data;

wire [53:0] q_1;
wire [53:0] q_2;

model_simple_dual_ram #(
    .width          (54),
    .widthad        (9)
)
cache_1_inst(
    .clk            (clk),
    
    //
    .address_a      (address_1_r),  //input [9:0]
    .q_a            (q_1),          //output [53:0]
    
    //
    .address_b      (address_1_w),  //input [9:0]
    .wren_b         (wren_1),       //input
    .data_b         (data_1)        //input [53:0]
);

model_simple_dual_ram #(
    .width          (54),
    .widthad        (9)
)
cache_2_inst(
    .clk            (clk),
    
    //
    .address_a      (address_2_r),  //input [9:0]
    .q_a            (q_2),          //output [53:0]
    
    //
    .address_b      (address_2_w),  //input [9:0]
    .wren_b         (wren_2),       //input
    .data_b         (data_2)        //input [53:0]
);

reg [8:0]  address_1_w_reg;
reg [8:0]  address_1_r_reg;
reg [8:0]  address_2_w_reg;
reg [8:0]  address_2_r_reg;
reg        wren_1_reg;
reg        wren_2_reg;
reg        config_switch_caches_reg;
reg [53:0] data_1_reg;
reg [53:0] data_2_reg;

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address_1_w_reg          <= 9'd0;   else address_1_w_reg          <= address_1_w;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address_1_r_reg          <= 9'd0;   else address_1_r_reg          <= address_1_r;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address_2_w_reg          <= 9'd0;   else address_2_w_reg          <= address_2_w;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address_2_r_reg          <= 9'd0;   else address_2_r_reg          <= address_2_r;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wren_1_reg               <= `FALSE; else wren_1_reg               <= wren_1;               end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wren_2_reg               <= `FALSE; else wren_2_reg               <= wren_2;               end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) config_switch_caches_reg <= `FALSE; else config_switch_caches_reg <= config_switch_caches; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) data_1_reg               <= 54'd0;  else data_1_reg               <= data_1;               end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) data_2_reg               <= 54'd0;  else data_2_reg               <= data_2;               end

assign fetch_cache_q =
    (config_switch_caches_reg && wren_1_reg && address_1_r_reg == address_1_w_reg)? data_1_reg :
    (config_switch_caches_reg)?                                                     q_1 :
    (wren_2_reg && address_2_r_reg == address_2_w_reg)?                             data_2_reg :
                                                                                    q_2;

assign data_cache_q =
    (config_switch_caches_reg && wren_2_reg && address_2_r_reg == address_2_w_reg)? data_2_reg :
    (config_switch_caches_reg)?                                                     q_2 :
    (wren_1_reg && address_1_r_reg == address_1_w_reg)?                             data_1_reg :
                                                                                    q_1;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                       write_buffer_counter <= 5'd0;
    else if(ram_fifo_wrreq && ram_fifo_data[66]         && (ram_fifo_empty || ~(ram_fifo_rdreq) || (ram_fifo_rdreq && ~(ram_fifo_q[66]))))  write_buffer_counter <= write_buffer_counter + 5'd1;
    else if((~(ram_fifo_wrreq) || ~(ram_fifo_data[66])) && ram_fifo_rdreq && ram_fifo_q[66])                                                write_buffer_counter <= write_buffer_counter - 5'd1;
end

//------------------------------------------------------------------------------

wire [3:0] ram_fifo_usedw;

//{ [66] 1'b is_write, [65:36] 30'b address, [35:4] 32'b value, [3:0] 4'b byteena (4'b0000 - can burst 4 words) }

model_fifo #(
    .width          (67),
    .widthu         (4)
)
ram_fifo_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    
    .sclr           (`FALSE),
    
    .rdreq          (ram_fifo_rdreq),   //input
    .wrreq          (ram_fifo_wrreq),   //input
    .data           (ram_fifo_data),    //input [66:0]
    
    .empty          (ram_fifo_empty),   //output
    .full           (ram_fifo_full),    //output
    .q              (ram_fifo_q),       //output [66:0]
    .usedw          (ram_fifo_usedw)    //output [3:0]
);

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, ram_fifo_usedw,  1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
