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

`include "defines.v"

module execute_divide(
    input               clk,
    input               rst_n,
    
    input               exe_reset,
    input               exe_ready,
    
    input               exe_is_8bit,
    input               exe_operand_16bit,
    input               exe_operand_32bit,
    input       [6:0]   exe_cmd,
    
    input       [31:0]  eax,
    input       [31:0]  edx,
    
    input       [31:0]  src,
    
    //output
    output              div_busy,
    
    output              exe_div_exception,
    
    output      [31:0]  div_result_quotient,
    output      [31:0]  div_result_remainder
);

//------------------------------------------------------------------------------ IDIV, DIV, AAM

wire div_start;
wire div_working;

wire div_exception_min_int;
wire div_exception_zero;

reg div_overflow_waiting;

reg [5:0] div_counter;
reg       div_one_time;

wire [64:0] div_numer;
wire [32:0] div_denom;

wire [32:0] div_denom_neg;

wire [64:0] div_diff;

reg [63:0] div_dividend;
reg [63:0] div_divisor;

reg [32:0] div_quotient;

wire div_quotient_neg;
wire div_remainder_neg;

wire div_overflow_8bit;
wire div_overflow_16bit;
wire div_overflow_32bit;
wire div_overflow;

//------------------------------------------------------------------------------

assign exe_div_exception = div_exception_zero || div_exception_min_int || div_overflow_waiting;

assign div_start  = ~(exe_div_exception) && ~(div_one_time) && div_counter == 6'd0 && (exe_cmd == `CMD_IDIV || exe_cmd == `CMD_DIV || exe_cmd == `CMD_AAM);
assign div_working= div_counter > 6'd1;
assign div_busy   = div_counter != 6'd0 || ~(div_one_time);
//div_end condition: div_counter == 6'd1 && ~(exe_div_exception)

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)            div_one_time <= `FALSE;
    else if(exe_reset)           div_one_time <= `FALSE;
    else if(exe_ready)           div_one_time <= `FALSE;
    else if(div_counter > 6'd1)  div_one_time <= `TRUE;
end

assign div_exception_min_int = div_counter == 6'd0 && exe_cmd == `CMD_IDIV && (
    (  exe_is_8bit  &&                                                   eax[15:0] == 16'h8000) ||
    ((~exe_is_8bit) && exe_operand_16bit && edx[15:0] == 16'h8000     && eax[15:0] == 16'h0000) ||
    ((~exe_is_8bit) && exe_operand_32bit && edx       == 32'h80000000 && eax       == 32'h00000000));

assign div_exception_zero = div_counter == 6'd0 && (exe_cmd == `CMD_IDIV || exe_cmd == `CMD_DIV || exe_cmd == `CMD_AAM) && (
    (exe_is_8bit        && src[7:0]  == 8'd0) ||
    (exe_operand_16bit  && src[15:0] == 16'd0) ||
    (exe_operand_32bit  && src       == 32'd0) );

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_overflow_waiting <= `FALSE;
    else if(exe_reset)                              div_overflow_waiting <= `FALSE;
    else if(div_counter == 6'd1 && div_overflow)    div_overflow_waiting <= `TRUE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       div_counter <= 6'd0;
    else if(exe_reset)                      div_counter <= 6'd0;
    else if(div_start && exe_is_8bit)       div_counter <= 6'd10;
    else if(div_start && exe_operand_16bit) div_counter <= 6'd18;
    else if(div_start && exe_operand_32bit) div_counter <= 6'd34;
    else if(div_counter != 6'd0)            div_counter <= div_counter - 6'd1;
end
    
assign div_numer =
    (exe_cmd == `CMD_AAM)?  { 57'd0, eax[7:0] } :
    (exe_is_8bit)?          { {49{(exe_cmd == `CMD_IDIV) & eax[15]}}, eax[15:0] } :
    (exe_operand_16bit)?    { {33{(exe_cmd == `CMD_IDIV) & edx[15]}}, edx[15:0], eax[15:0] } :
                            {    ((exe_cmd == `CMD_IDIV) & edx[31]),  edx, eax };

assign div_denom =
    (exe_is_8bit)?          { {25{(exe_cmd == `CMD_IDIV) & src[7]}},  src[7:0] } :
    (exe_operand_16bit)?    { {17{(exe_cmd == `CMD_IDIV) & src[15]}}, src[15:0] } :
                            {    ((exe_cmd == `CMD_IDIV) & src[31]),  src };

assign div_denom_neg = -div_denom;
                            
assign div_diff = div_dividend - div_divisor;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_dividend <= 64'd0;
    else if(div_start && div_numer[64] == 1'b0)     div_dividend <=  div_numer[63:0];
    else if(div_start && div_numer[64] == 1'b1)     div_dividend <= -div_numer[63:0];
    else if(div_working && div_diff[64] == 1'b0)    div_dividend <= div_diff[63:0];
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   div_divisor <= 64'd0;
    else if(div_start && div_denom[32] == 1'b0 && exe_is_8bit)          div_divisor <= { 48'd0, div_denom    [7:0], 8'd0 };
    else if(div_start && div_denom[32] == 1'b1 && exe_is_8bit)          div_divisor <= { 48'd0, div_denom_neg[7:0], 8'd0 };
    else if(div_start && div_denom[32] == 1'b0 && exe_operand_16bit)    div_divisor <= { 32'd0, div_denom    [15:0],16'd0 };
    else if(div_start && div_denom[32] == 1'b1 && exe_operand_16bit)    div_divisor <= { 32'd0, div_denom_neg[15:0],16'd0 };
    else if(div_start && div_denom[32] == 1'b0 && exe_operand_32bit)    div_divisor <= {        div_denom    [31:0],32'd0 };
    else if(div_start && div_denom[32] == 1'b1 && exe_operand_32bit)    div_divisor <= {        div_denom_neg[31:0],32'd0 };
    else if(div_working)                                                div_divisor <= { 1'b0, div_divisor[63:1] };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               div_quotient <= 33'd0;
    else if(div_start)                              div_quotient <= 33'd0;
    else if(div_working && div_diff[64] == 1'b0)    div_quotient <= { div_quotient[31:0], 1'b1 };
    else if(div_working && div_diff[64] == 1'b1)    div_quotient <= { div_quotient[31:0], 1'b0 };
end

assign div_quotient_neg   = div_numer[64] ^ div_denom[32];
assign div_remainder_neg  = div_numer[64];

assign div_overflow_8bit =
    (exe_cmd == `CMD_IDIV && ( (~(div_quotient_neg) && div_quotient[8:7] != 2'b00) || (div_quotient_neg && div_quotient[8:0] > 9'h80) )) ||
    (exe_cmd != `CMD_IDIV && div_quotient[8]);
    
assign div_overflow_16bit =
    (exe_cmd == `CMD_IDIV && ( (~(div_quotient_neg) && div_quotient[16:15] != 2'b00) || (div_quotient_neg && div_quotient[16:0] > 17'h8000) )) ||
    (exe_cmd != `CMD_IDIV && div_quotient[16]);

assign div_overflow_32bit =
    (exe_cmd == `CMD_IDIV && ( (~(div_quotient_neg) && div_quotient[32:31] != 2'b00) || (div_quotient_neg && div_quotient[32:0] > 33'h80000000) )) ||
    (exe_cmd != `CMD_IDIV && div_quotient[32]);
    
assign div_overflow = (exe_cmd == `CMD_IDIV || exe_cmd == `CMD_DIV) && (
    (exe_is_8bit       && div_overflow_8bit)  ||
    (exe_operand_16bit && div_overflow_16bit) ||
    (exe_operand_32bit && div_overflow_32bit));

assign div_result_quotient     = (div_quotient_neg)?   -div_quotient[31:0] : div_quotient[31:0];
assign div_result_remainder    = (div_remainder_neg)?  -div_dividend[31:0] : div_dividend[31:0];

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, div_denom_neg[32], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
