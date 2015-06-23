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

//PARSED_COMMENTS: this file contains parsed script comments

module decode_commands(
    
    input               protected_mode,
    
    input               dec_ready_one,
    input               dec_ready_one_one,
    input               dec_ready_one_two,
    input               dec_ready_one_three,
    input               dec_ready_2byte_one,
    input               dec_ready_modregrm_one,
    input               dec_ready_2byte_modregrm,
    input               dec_ready_call_jmp_imm,
    input               dec_ready_one_imm,
    input               dec_ready_2byte_imm,
    input               dec_ready_mem_offset,
    input               dec_ready_modregrm_imm,
    input               dec_ready_2byte_modregrm_imm,
    
    input       [95:0]  decoder,
    input               prefix_group_1_lock,
    input       [1:0]   dec_prefix_group_1_rep,
    input               dec_prefix_2byte,
    
    output              consume_one,
    output              consume_one_one,
    output              consume_one_two,
    output              consume_one_three,
    output              consume_call_jmp_imm,
    output              consume_modregrm_one,
    output              consume_one_imm,
    output              consume_modregrm_imm,
    output              consume_mem_offset,
    
    output              dec_exception_ud,
    
    output              dec_is_8bit,
    output      [6:0]   dec_cmd,
    output      [3:0]   dec_cmdex,
    output              dec_is_complex
);

//------------------------------------------------------------------------------

`define DEC_MODREGRM_IS_MOD_11  (decoder[15:14] == 2'b11)

//------------------------------------------------------------------------------

wire exception_ud_invalid;
wire exception_ud;

//------------------------------------------------------------------------------

assign exception_ud_invalid =
    (dec_ready_modregrm_one && (
        (decoder[7:0] == 8'h8F && decoder[13:11] != 3'd0) ||
        (decoder[7:0] == 8'hFE && decoder[13:12] != 2'd0) ||
        (decoder[7:0] == 8'hFF && decoder[13:11] == 3'd7) ||
        ({ decoder[7:1], 1'b0 } == 8'hC6 && decoder[13:11] != 3'd0) )) ||
    (dec_ready_2byte_modregrm && (
        (decoder[7:0] == 8'h00 && { decoder[13:12], 1'b0 } == 3'd6) ||
        (decoder[7:0] == 8'h01 && decoder[13:11] == 3'd5) ||
        (decoder[7:0] == 8'hBA && decoder[13] == 1'd0) )) ||
    (dec_ready_modregrm_imm && (
        ({ decoder[7:1], 1'b0 } == 8'hC6 && decoder[13:11] != 3'd0) )) ||
    (dec_ready_2byte_one && (
        { decoder[7:1], 1'b0 } == 8'hA6 || decoder[7:0] == 8'hAA || decoder[7:0] == 8'hAE ||
        { decoder[7:1], 1'b0 } == 8'hB8 || (decoder[7:4] == 4'hC && decoder[3] == 1'b0 && decoder[2:1] != 2'b00) ||
        (decoder[7:4] >= 4'hD) || (decoder[7:4] >= 4'h3 && decoder[7:4] <= 4'h7) || decoder[7:4] == 4'h1 ||
        (decoder[7:4] == 4'h2 && decoder[3:0] >= 4'h4) || { decoder[7:1], 1'b0 } == 8'h04 || decoder[7:0] == 8'h07 ||
        (decoder[7:4] == 4'd0 && decoder[3:0] >= 4'hA) ));


//------------------------------------------------------------------------------
   
assign dec_exception_ud = exception_ud_invalid || exception_ud;
    
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, decoder[95:16], decoder[10:8], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

`include "autogen/decode_commands.v"


endmodule
