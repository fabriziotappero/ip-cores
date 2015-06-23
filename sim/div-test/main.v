/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module main(
    input               clk,
    input               rst_n,
    
    input               start,
    input       [2:0]  dividend,
    input       [2:0]  divisor,
    
    output              ready,
    output      [1:0]  quotient,
    output      [1:0]  remainder
);

//------------------------------------------------------------------------------

reg [5:0] div_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               div_counter <= 6'd0;
    else if(start)                  div_counter <= 6'd3;
    else if(div_counter != 6'd0)    div_counter <= div_counter - 6'd1;
end

wire div_working = div_counter > 6'd1;

wire [4:0] div_diff = { 2'd0, div_dividend } - div_divisor;

reg [1:0] div_dividend;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_dividend <= 2'd0;
    else if(start && dividend[2] == 1'b0)          div_dividend <=  dividend[1:0];
    else if(start && dividend[2] == 1'b1)          div_dividend <= -dividend[1:0];
    else if(div_working && div_diff[4] == 1'b0)    div_dividend <= div_diff[1:0];
end

wire [2:0] divisor_neg = -divisor;

reg [3:0] div_divisor;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_divisor <= 4'd0;
    else if(start && divisor[2] == 1'b0)           div_divisor <= { 1'b0, divisor[1:0],     1'd0 };
    else if(start && divisor[2] == 1'b1)           div_divisor <= { 1'b0, divisor_neg[1:0], 1'd0 };
    else if(div_working)                            div_divisor <= { 1'b0, div_divisor[3:1] };
end

reg [1:0] div_quotient;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_quotient <= 2'd0;
    else if(start)                                  div_quotient <= 2'd0;
    else if(div_working && div_diff[4] == 1'b0)    div_quotient <= { div_quotient[0], 1'b1 };
    else if(div_working && div_diff[4] == 1'b1)    div_quotient <= { div_quotient[0], 1'b0 };
end

reg div_quotient_neg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   div_quotient_neg <= 1'b0;
    else if(start)      div_quotient_neg <= dividend[2] ^ divisor[2];
end

reg div_remainder_neg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   div_remainder_neg <= 1'b0;
    else if(start)      div_remainder_neg <= dividend[2];
end

assign ready     = div_counter == 6'd1;
assign quotient  = (div_quotient_neg)?   -div_quotient[1:0] : div_quotient[1:0];
assign remainder = (div_remainder_neg)?  -div_dividend[1:0] : div_dividend[1:0];

//------------------------------------------------------------------------------

wire _unused_ok = &{ 1'b0, div_diff[3:2], divisor_neg[2],  1'b0 };

//------------------------------------------------------------------------------

endmodule
