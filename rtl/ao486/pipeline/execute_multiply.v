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

module execute_multiply(
    input               clk,
    input               rst_n,
    
    input               exe_reset,
    
    input       [6:0]   exe_cmd,
    input               exe_is_8bit,
    input               exe_operand_16bit,
    input               exe_operand_32bit,
    
    input       [31:0]  src,
    input       [31:0]  dst,
    
    //
    output      [65:0]  mult_result,
    output              mult_busy,
    
    output              exe_mult_overflow
);

//------------------------------------------------------------------------------ MUL, IMUL, AAD

wire mult_start;

reg [1:0] mult_counter;

wire [32:0] mult_a;
wire [32:0] mult_b;

//------------------------------------------------------------------------------

assign mult_start = mult_counter == 2'd0 && (exe_cmd == `CMD_IMUL || exe_cmd == `CMD_MUL || exe_cmd == `CMD_AAD);
assign mult_busy  = mult_counter != 2'd1;
//mult_end condition: mult_counter == 2'd1

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               mult_counter <= 2'd0;
    else if(exe_reset)              mult_counter <= 2'd0;
    else if(mult_start)             mult_counter <= 2'd2;
    else if(mult_counter != 2'd0)   mult_counter <= mult_counter - 2'd1;
end

assign mult_a =
    (exe_is_8bit)?          { {25{(exe_cmd == `CMD_IMUL) & src[7]}},  src[7:0] } :
    (exe_operand_16bit)?    { {17{(exe_cmd == `CMD_IMUL) & src[15]}}, src[15:0] } :
                            {    ((exe_cmd == `CMD_IMUL) & src[31]),  src };
                            
assign mult_b =
    (exe_cmd == `CMD_AAD)?  { 25'd0, dst[15:8] } :
    (exe_is_8bit)?          { {25{(exe_cmd == `CMD_IMUL) & dst[7]}},  dst[7:0] } :
    (exe_operand_16bit)?    { {17{(exe_cmd == `CMD_IMUL) & dst[15]}}, dst[15:0] } :
                            {    ((exe_cmd == `CMD_IMUL) & dst[31]),  dst };

simple_mult
#(
    .widtha     (33),
    .widthb     (33),
    .widthp     (66)
)
mult_inst(
    .clk        (clk),
    .a          (mult_a),
    .b          (mult_b),
    .out        (mult_result)
);

assign exe_mult_overflow =
    (exe_is_8bit       && mult_result[65:8]  != {58{(exe_cmd == `CMD_IMUL) & mult_result[7]}}) ||
    (exe_operand_16bit && mult_result[65:16] != {50{(exe_cmd == `CMD_IMUL) & mult_result[15]}}) ||
    (exe_operand_32bit && mult_result[65:32] != {34{(exe_cmd == `CMD_IMUL) & mult_result[31]}});

//------------------------------------------------------------------------------

endmodule
