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

module decode_ready(
    
    input               enable,
    input               is_prefix,
    input       [3:0]   decoder_count,
    
    input       [95:0]  decoder,
    
    input               dec_operand_32bit,
    input               dec_address_32bit,
    
    input               dec_prefix_2byte,
    input       [2:0]   dec_modregrm_len,
    
    
    output              dec_ready_one,
    output              dec_ready_one_one,
    output              dec_ready_one_two,
    output              dec_ready_one_three,
    output              dec_ready_2byte_one,
    output              dec_ready_modregrm_one,
    output              dec_ready_2byte_modregrm,
    output              dec_ready_call_jmp_imm,
    output              dec_ready_one_imm,
    output              dec_ready_2byte_imm,
    output              dec_ready_mem_offset,
    output              dec_ready_modregrm_imm,
    output              dec_ready_2byte_modregrm_imm,
    
    input               consume_one,
    input               consume_one_one,
    input               consume_one_two,
    input               consume_one_three,
    input               consume_call_jmp_imm,
    input               consume_modregrm_one,
    input               consume_one_imm,
    input               consume_modregrm_imm,
    input               consume_mem_offset,
    
    output      [3:0]   consume_count_local,
    output              dec_is_modregrm
);

//------------------------------------------------------------------------------

wire [2:0] call_jmp_imm_len;
wire [2:0] one_imm_len;
wire [2:0] mem_offset_len;

wire [2:0] modregrm_imm_only_len;
wire [3:0] modregrm_imm_len;

//------------------------------------------------------------------------------

assign dec_is_modregrm = consume_modregrm_one || consume_modregrm_imm;

//------------------------------------------------------------------------------

/* 
 * CALL imm:
 * (@decoder[7:0] == 8'h9A || @decoder[7:0] == 8'hE8)
 *      decoder[7:0] == 8'h9A && operand_32bit  --> 7
 *      decoder[7:0] == 8'h9A                   --> 5
 *      operand_32bit                           --> 5
 *                                              --> 3
 * 
 * JMP imm:
 * (@decoder[7:0] == 8'hEA || @decoder[7:0] == 8'hE9 || @decoder[7:0] == 8'hEB)
 *      decoder[7:0] == 8'hEB                   --> 2
 *      decoder[7:0] == 8'hEA && operand_32bit  --> 7
 *      decoder[7:0] == 8'hEA                   --> 5
 *      operand_32bit                           --> 5
 *                                              --> 3 
 */
assign call_jmp_imm_len =
    // 8'hEB
    (decoder[1:0] == 2'b11)?                      3'd2 :
    // (8'h9A or 8'hEA) and 32bit
    (decoder[1] == 1'b1 && dec_operand_32bit)?    3'd7 :
    // (8'hE8 or 8'hE9) and 16bit
    (decoder[1] == 1'b0 && ~(dec_operand_32bit))? 3'd3 :
    // else
                                                  3'd5;
                                                
/* Arithmetic:
 * @decoder[7:6] == 2'b00 && @decoder[2:1] == 2'b10
 *      decoder[0] == 1'b0                      --> 2
 *      operand_32bit                           --> 5
 *                                              --> 3
 * 
 * PUSH imm:
 * (@decoder[7:0] == 8'h6A || @decoder[7:0] == 8'h68)
 *      decoder[7:0] == 8'h6A                   --> 2
 *      operand_32bit                           --> 5
 *                                              --> 3
 * 
 * TEST imm:
 * { @decoder[7:1], 1'b0 } == 8'hA8
 *      decoder[0] == 1'b0                      --> 2
 *      operand_32bit                           --> 5
 *                                              --> 3
 * MOV imm:
 * @decoder[7:4] == 4'hB
 *      decoder[7:3] != 8'hB8                   --> 2
 *      operand_32bit                           --> 5
 *                                              --> 3
 * Jcc:
 * @decoder_ready_2byte_imm && @decoder[7:4] == 4'h8
 *      operand_32bit                           --> 5
 *                                              --> 3
 */
assign one_imm_len =
    (~(dec_prefix_2byte) && ({ decoder[7:3], 3'b0 } == 8'hB0 || decoder[7:0] == 8'hA8 || decoder[7:0] == 8'h6A ||
                             { decoder[7:6], decoder[0] } == 3'b000 ))?     3'd2 :
    (dec_operand_32bit)?                                                    3'd5 :
                                                                            3'd3;

assign mem_offset_len = (dec_address_32bit)? 3'd5 : 3'd3;

/* Arithmetic:
 * (@decoder[7:0] == 8'h80 || @decoder[7:0] == 8'h81 || @decoder[7:0] == 8'h83)
 *      decoder[7:0] == 8'h80 || decoder[7:0] == 8'h83              --> 1
 *      operand_32bit                                               --> 4
 *                                                                  --> 2
 * 
 * IMUL:
 * (@decoder[7:0] == 8'h69 || @decoder[7:0] == 8'h6B)
 *      decoder[7:0] == 8'h6B                                       --> 1
 *      operand_32bit                                               --> 4
 *                                                                  --> 2
 * 
 * TEST:
 *  { @decoder[7:1], 1'b0 } == 8'hF6 && { @decoder[13:12], 1'b0 } == 3'd0
 *      decoder[7:0] == 8'hF6                                       --> 1
 *      operand_32bit                                               --> 4
 *                                                                  --> 2
 * 
 * MOV:
 *  { @decoder[7:1], 1'b0 } == 8'hC6 && @decoder[13:11] == 3'd0
 *      decoder[7:0] == 8'hC6                                       --> 1
 *      operand_32bit                                               --> 4
 *                                                                  --> 2
 * 
 * Shift:
 *  { @decoder[7:1], 1'b0 } == 8'hC0                                --> 1
 *                                                                  
 * 
 * prefix_2byte                                                     --> 1
 */
assign modregrm_imm_only_len =
    (dec_prefix_2byte || { decoder[7:1], 1'b0 } == 8'hC0 || decoder[1:0] == 2'b00 || decoder[1:0] == 2'b10 || decoder[2:0] == 3'b011)?
                                                                            3'd1 :
    (dec_operand_32bit)?                                                    3'd4 :
                                                                            3'd2;


assign modregrm_imm_len = { 1'b0, dec_modregrm_len } + { 1'b0,  modregrm_imm_only_len };


//------------------------------------------------------------------------------

assign consume_count_local =
    (consume_one)?              4'd1 :
    (consume_one_one)?          4'd2 :
    (consume_one_two)?          4'd3 :
    (consume_one_three)?        4'd4 :
    (consume_call_jmp_imm)?     { 1'b0, call_jmp_imm_len } :
    (consume_modregrm_one)?     { 1'b0, dec_modregrm_len } :
    (consume_one_imm)?          { 1'b0, one_imm_len } :
    (consume_modregrm_imm)?     modregrm_imm_len :
    (consume_mem_offset)?       { 1'b0, mem_offset_len } :
                                4'd0;

//------------------------------------------------------------------------------

assign dec_ready_one                = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= 4'd1;
    
assign dec_ready_one_one            = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= 4'd2;

assign dec_ready_one_two            = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= 4'd3;
    
assign dec_ready_one_three          = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= 4'd4;

assign dec_ready_2byte_one          = enable && dec_prefix_2byte && decoder_count >= 4'd1;
    
assign dec_ready_modregrm_one       = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= { 1'b0, dec_modregrm_len };

assign dec_ready_2byte_modregrm     = enable && dec_prefix_2byte && decoder_count >= { 1'b0, dec_modregrm_len };
    
assign dec_ready_call_jmp_imm       = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= { 1'b0, call_jmp_imm_len };

assign dec_ready_one_imm            = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= { 1'b0, one_imm_len };
    
assign dec_ready_2byte_imm          = enable && dec_prefix_2byte && decoder_count >= { 1'b0, one_imm_len };
    
assign dec_ready_mem_offset         = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= { 1'b0, mem_offset_len };
    
assign dec_ready_modregrm_imm       = enable && ~(is_prefix) && ~(dec_prefix_2byte) && decoder_count >= modregrm_imm_len;
                                                                                                        
assign dec_ready_2byte_modregrm_imm = enable && dec_prefix_2byte && decoder_count >= modregrm_imm_len;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, decoder[95:8], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
  