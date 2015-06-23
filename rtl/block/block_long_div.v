/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module block_long_div(
    input               clk,
    input               rst_n,
    
    input               start,
    input       [32:0]  dividend,
    input       [32:0]  divisor,
    
    output              ready,
    output      [31:0]  quotient,
    output      [31:0]  remainder
);

//------------------------------------------------------------------------------

reg [5:0] div_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               div_counter <= 6'd0;
    else if(start)                  div_counter <= 6'd33;
    else if(div_counter != 6'd0)    div_counter <= div_counter - 6'd1;
end

wire div_working = div_counter > 6'd1;

wire [64:0] div_diff = { 32'd0, div_dividend } - div_divisor;

reg [31:0] div_dividend;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_dividend <= 32'd0;
    else if(start && dividend[32] == 1'b0)          div_dividend <=  dividend[31:0];
    else if(start && dividend[32] == 1'b1)          div_dividend <= -dividend[31:0];
    else if(div_working && div_diff[64] == 1'b0)    div_dividend <= div_diff[31:0];
end

wire [32:0] divisor_neg = -divisor;

reg [63:0] div_divisor;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_divisor <= 64'd0;
    else if(start && divisor[32] == 1'b0)           div_divisor <= { 1'b0, divisor[31:0],     31'd0 };
    else if(start && divisor[32] == 1'b1)           div_divisor <= { 1'b0, divisor_neg[31:0], 31'd0 };
    else if(div_working)                            div_divisor <= { 1'b0, div_divisor[63:1] };
end

reg [31:0] div_quotient;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_quotient <= 32'd0;
    else if(start)                                  div_quotient <= 32'd0;
    else if(div_working && div_diff[64] == 1'b0)    div_quotient <= { div_quotient[30:0], 1'b1 };
    else if(div_working && div_diff[64] == 1'b1)    div_quotient <= { div_quotient[30:0], 1'b0 };
end

reg div_quotient_neg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   div_quotient_neg <= 1'b0;
    else if(start)      div_quotient_neg <= dividend[32] ^ divisor[32];
end

reg div_remainder_neg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   div_remainder_neg <= 1'b0;
    else if(start)      div_remainder_neg <= dividend[32];
end

assign ready     = div_counter == 6'd1;
assign quotient  = (div_quotient_neg)?   -div_quotient[31:0] : div_quotient[31:0];
assign remainder = (div_remainder_neg)?  -div_dividend[31:0] : div_dividend[31:0];

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, div_diff[63:32], divisor_neg[32],  1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
