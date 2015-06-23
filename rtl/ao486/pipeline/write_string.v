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

module write_string(
    
    input               wr_is_8bit,
    input               wr_operand_16bit,
    input               wr_address_16bit,
    input               wr_address_32bit,
    input       [1:0]   wr_prefix_group_1_rep,
    
    input               wr_string_gp_fault_check,
    
    input               dflag,
    
    input               wr_zflag_result,
    
    input       [31:0]  ecx,
    input       [31:0]  esi,
    input       [31:0]  edi,
    
    input       [63:0]  es_cache,
    input               es_cache_valid,
    input       [31:0]  es_base,
    input       [31:0]  es_limit,
    
    //output
    output      [31:0]  wr_esi_final,
    output      [31:0]  wr_edi_final,
    output      [31:0]  wr_ecx_final,
    
    output              wr_string_ignore,
    output              wr_string_finish,
    output              wr_string_zf_finish,
    
    output      [31:0]  wr_string_es_linear,
    
    output              wr_string_es_fault
);

//------------------------------------------------------------------------------ string
wire [31:0] w_string_size;
wire [31:0] w_esi;
wire [31:0] w_edi;
wire [31:0] w_ecx;


assign w_string_size = (wr_is_8bit)? 32'd1 : (wr_operand_16bit)? 32'd2 : 32'd4;

assign w_esi = (dflag)? esi - w_string_size : esi + w_string_size;
assign w_edi = (dflag)? edi - w_string_size : edi + w_string_size;
assign w_ecx = ecx - 32'd1;

assign wr_esi_final = (wr_address_16bit)? { esi[31:16], w_esi[15:0] } : w_esi;
assign wr_edi_final = (wr_address_16bit)? { edi[31:16], w_edi[15:0] } : w_edi;
assign wr_ecx_final = (wr_address_16bit)? { ecx[31:16], w_ecx[15:0] } : w_ecx;

assign wr_string_ignore = wr_prefix_group_1_rep != 2'd0 &&
    ((wr_address_16bit && ecx[15:0] == 16'd0) || (wr_address_32bit && ecx == 32'd0));

assign wr_string_finish =
    (wr_prefix_group_1_rep != 2'd0 && ((wr_address_16bit && ecx[15:0] == 16'd1) || (wr_address_32bit && ecx == 32'd1)));
    
assign wr_string_zf_finish =
     wr_string_finish ||
    (wr_prefix_group_1_rep == 2'd1 && wr_zflag_result) ||
    (wr_prefix_group_1_rep == 2'd2 && ~(wr_zflag_result));
    
//------------------------------------------------------------------------------ string ES
wire [31:0] w_edi_offset;
wire [2:0]  wr_string_es_length;
wire [2:0]  wr_string_es_length_minus_1;
wire [31:0] w_string_es_upper_limit;

wire        w_string_es_not_fit;
wire        w_string_es_limit_overflow;

wire        w_string_es_no_write;

assign w_edi_offset = (wr_address_16bit)? { 16'd0, edi[15:0] } : edi;

assign wr_string_es_linear = es_base + w_edi_offset;

assign wr_string_es_length         = (wr_is_8bit)? 3'd1 : (wr_operand_16bit)? 3'd2 : 3'd4;
assign wr_string_es_length_minus_1 = wr_string_es_length - 3'd1;

assign w_string_es_upper_limit = (es_cache[`DESC_BIT_D_B])? 32'hFFFFFFFF : 32'h0000FFFF; //d-b

// (CODE or not EXPAND-DOWN)
assign w_string_es_not_fit = (es_cache[43] || !es_cache[42])?
    es_limit                - w_edi_offset < { 29'd0, wr_string_es_length_minus_1 } :
    w_string_es_upper_limit - w_edi_offset < { 29'd0, wr_string_es_length_minus_1 };

assign w_string_es_limit_overflow =
    ((es_cache[43] || !es_cache[42]) && w_edi_offset > es_limit) ||
    (!es_cache[43] && es_cache[42] && (w_edi_offset <= es_limit || w_edi_offset > w_string_es_upper_limit));
    
// (CODE or not writable)
assign w_string_es_no_write = es_cache[43] || !es_cache[41];
    
assign wr_string_es_fault = ~(wr_string_ignore) && wr_string_gp_fault_check &&
    (w_string_es_not_fit || w_string_es_limit_overflow || ~(es_cache_valid) || w_string_es_no_write);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, es_cache[63:55], es_cache[53:44], es_cache[40:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
