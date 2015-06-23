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

module execute_shift(
    
    input               exe_is_8bit,
    input               exe_operand_16bit,
    input               exe_operand_32bit,
    input               exe_prefix_2byte,
    
    input       [6:0]   exe_cmd,
    input       [3:0]   exe_cmdex,
    input       [39:0]  exe_decoder,
    input       [7:0]   exe_modregrm_imm,
    
    input               cflag,
    
    input       [31:0]  ecx,
    
    input       [31:0]  dst,
    input       [31:0]  src,
    
    //output
    output              e_shift_no_write,
    output              e_shift_oszapc_update,
    output              e_shift_cf_of_update,
    output              e_shift_oflag,
    output              e_shift_cflag,
    
    output      [31:0]  e_shift_result
);

//------------------------------------------------------------------------------ SHRD, SHLD, SAL, SAR, SHR, ROL, ROR, RCL, RCR

wire [31:0] e_shift_dst_wire;
wire [4:0]  e_shift_count;
wire [2:0]  e_shift_cmd;

wire e_shift_ROL;
wire e_shift_ROR;
wire e_shift_RCL;
wire e_shift_RCR;
wire e_shift_SHL;
wire e_shift_SHR;
wire e_shift_SAR;
wire e_shift_SHLD;
wire e_shift_SHRD;
wire e_shift_SHxD;

wire [63:0] e_shift_left_input;
wire [63:0] e_shift_right_input;
wire [32:0] e_shift_left_result;
wire        e_shift_left_cflag;
wire [32:0] e_shift_right_result;

wire e_shift_cf_of_rotate_carry_8bit;
wire e_shift_cf_of_rotate_carry_16bit;
wire e_shift_cmd_not_carry;
wire e_shift_cmd_carry;
wire e_shift_cmd_shift;
wire e_shift_cmd_rot;

//------------------------------------------------------------------------------

assign e_shift_dst_wire =
    (exe_is_8bit)?       { dst[7:0],  dst[7:0], dst[7:0], dst[7:0] } :
    (exe_operand_16bit)? { dst[15:0], dst[15:0] } :
                           dst;

assign e_shift_count = 
  (e_shift_SHxD && exe_cmdex == `CMDEX_SHxD_implicit)?      ecx[4:0] :
  (e_shift_SHxD && exe_cmdex == `CMDEX_SHxD_modregrm_imm)?  exe_modregrm_imm[4:0] :
                                                            src[4:0];

assign e_shift_cmd = exe_decoder[13:11];
assign e_shift_ROL = ~(exe_prefix_2byte) && e_shift_cmd == 3'd0;
assign e_shift_ROR = ~(exe_prefix_2byte) && e_shift_cmd == 3'd1;
assign e_shift_RCL = ~(exe_prefix_2byte) && e_shift_cmd == 3'd2;
assign e_shift_RCR = ~(exe_prefix_2byte) && e_shift_cmd == 3'd3;
assign e_shift_SHL = ~(exe_prefix_2byte) && (e_shift_cmd == 3'd4 || e_shift_cmd == 3'd6);
assign e_shift_SHR = ~(exe_prefix_2byte) && e_shift_cmd == 3'd5;
assign e_shift_SAR = ~(exe_prefix_2byte) && e_shift_cmd == 3'd7;
 
assign e_shift_SHLD = exe_prefix_2byte && ~(exe_cmd[0]);
assign e_shift_SHRD = exe_prefix_2byte &&   exe_cmd[0];
assign e_shift_SHxD = exe_prefix_2byte;

assign e_shift_left_input =
    (e_shift_SHL)?                       { e_shift_dst_wire, 32'd0 } :
    (e_shift_ROL)?                       { e_shift_dst_wire, e_shift_dst_wire } :
    (e_shift_RCL && exe_is_8bit)?        { dst[7:0], cflag, dst[7:0], cflag, dst[7:2], dst[7:0],
                                                     cflag, dst[7:0], cflag, dst[7:0], cflag, dst[7:0], cflag, dst[7:4] } :
    (e_shift_RCL  && exe_operand_16bit)? { e_shift_dst_wire, cflag, dst[15:0], cflag, dst[15:2] } :
    (e_shift_RCL  && exe_operand_32bit)? { e_shift_dst_wire, cflag, dst[31:1] } :
    (e_shift_SHLD && exe_operand_16bit)? { e_shift_dst_wire, src[15:0], dst[15:0] } :
                                         { e_shift_dst_wire, src }; // e_shift_SHLD
assign e_shift_right_input =
    (e_shift_SAR && exe_is_8bit)?           { {56{dst[7]}},  dst[7:0] } :
    (e_shift_SAR && exe_operand_16bit)?     { {48{dst[15]}}, dst[15:0] } :
    (e_shift_SAR && exe_operand_32bit)?     { {32{dst[31]}}, dst[31:0] } :
    (e_shift_SHR && exe_is_8bit)?           { 56'b0, dst[7:0] } :
    (e_shift_SHR && exe_operand_16bit)?     { 48'b0, dst[15:0] } :
    (e_shift_SHR && exe_operand_32bit)?     { 32'b0, dst[31:0] } :
    (e_shift_ROR)?                          { e_shift_dst_wire, e_shift_dst_wire } :
    (e_shift_RCR && exe_is_8bit)?           { dst[0], cflag, dst[7:0], cflag, dst[7:0], cflag, dst[7:0],
                                              cflag, dst[7:0], cflag, dst[7:0], cflag, dst[7:0], cflag, dst[7:0] } :
    (e_shift_RCR && exe_operand_16bit)?     { dst[12:0], cflag, dst[15:0], cflag, dst[15:0], cflag, dst[15:0] } :
    (e_shift_RCR && exe_operand_32bit)?     { dst[30:0], cflag, dst } :
    (e_shift_SHRD && exe_operand_16bit)?    { e_shift_dst_wire, src[15:0], dst[15:0] } :
                                            { src, dst }; // e_shift_SHRD: 32-bits
    
assign e_shift_left_result =
    (e_shift_count == 5'd0)?  { cflag,  e_shift_left_input[63:32] } :
    (e_shift_count == 5'd1)?            e_shift_left_input[63:31] :
    (e_shift_count == 5'd2)?            e_shift_left_input[62:30] :
    (e_shift_count == 5'd3)?            e_shift_left_input[61:29] :
    (e_shift_count == 5'd4)?            e_shift_left_input[60:28] :
    (e_shift_count == 5'd5)?            e_shift_left_input[59:27] :
    (e_shift_count == 5'd6)?            e_shift_left_input[58:26] :
    (e_shift_count == 5'd7)?            e_shift_left_input[57:25] :
    (e_shift_count == 5'd8)?            e_shift_left_input[56:24] :
    (e_shift_count == 5'd9)?            e_shift_left_input[55:23] :
    (e_shift_count == 5'd10)?           e_shift_left_input[54:22] :
    (e_shift_count == 5'd11)?           e_shift_left_input[53:21] :
    (e_shift_count == 5'd12)?           e_shift_left_input[52:20] :
    (e_shift_count == 5'd13)?           e_shift_left_input[51:19] :
    (e_shift_count == 5'd14)?           e_shift_left_input[50:18] :
    (e_shift_count == 5'd15)?           e_shift_left_input[49:17] :
    (e_shift_count == 5'd16)?           e_shift_left_input[48:16] :
    (e_shift_count == 5'd17)?           e_shift_left_input[47:15] :
    (e_shift_count == 5'd18)?           e_shift_left_input[46:14] :
    (e_shift_count == 5'd19)?           e_shift_left_input[45:13] :
    (e_shift_count == 5'd20)?           e_shift_left_input[44:12] :
    (e_shift_count == 5'd21)?           e_shift_left_input[43:11] :
    (e_shift_count == 5'd22)?           e_shift_left_input[42:10] :
    (e_shift_count == 5'd23)?           e_shift_left_input[41:9] :
    (e_shift_count == 5'd24)?           e_shift_left_input[40:8] :
    (e_shift_count == 5'd25)?           e_shift_left_input[39:7] :
    (e_shift_count == 5'd26)?           e_shift_left_input[38:6] :
    (e_shift_count == 5'd27)?           e_shift_left_input[37:5] :
    (e_shift_count == 5'd28)?           e_shift_left_input[36:4] :
    (e_shift_count == 5'd29)?           e_shift_left_input[35:3] :
    (e_shift_count == 5'd30)?           e_shift_left_input[34:2] :
                                        e_shift_left_input[33:1];

assign e_shift_left_cflag =
    (e_shift_SHL &&   exe_is_8bit                       && e_shift_count >= 5'd9)?    1'b0 :
    (e_shift_SHL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count >= 5'd17)?   1'b0 :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd25)?   dst[1] :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd26)?   dst[0] :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd27)?   cflag :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd28)?   dst[7] :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd29)?   dst[6] :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd30)?   dst[5] :
    (e_shift_RCL &&   exe_is_8bit                       && e_shift_count == 5'd31)?   dst[4] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd17)?   cflag :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd18)?   dst[15] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd19)?   dst[14] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd20)?   dst[13] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd21)?   dst[12] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd22)?   dst[11] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd23)?   dst[10] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd24)?   dst[9] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd25)?   dst[8] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd26)?   dst[7] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd27)?   dst[6] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd28)?   dst[5] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd29)?   dst[4] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd30)?   dst[3] :
    (e_shift_RCL && ~(exe_is_8bit) && exe_operand_16bit && e_shift_count == 5'd31)?   dst[2] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd17)?   src[15] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd18)?   src[14] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd19)?   src[13] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd20)?   src[12] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd21)?   src[11] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd22)?   src[10] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd23)?   src[9] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd24)?   src[8] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd25)?   src[7] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd26)?   src[6] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd27)?   src[5] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd28)?   src[4] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd29)?   src[3] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd30)?   src[2] :
    (e_shift_SHLD &&                  exe_operand_16bit && e_shift_count == 5'd31)?   src[1] :
                                                                                      e_shift_left_result[32];
                            
assign e_shift_right_result =
    (e_shift_count == 5'd0)?  { e_shift_right_input[31:0], cflag } :
    (e_shift_count == 5'd1)?    e_shift_right_input[32:0] :
    (e_shift_count == 5'd2)?    e_shift_right_input[33:1] :
    (e_shift_count == 5'd3)?    e_shift_right_input[34:2] :
    (e_shift_count == 5'd4)?    e_shift_right_input[35:3] :
    (e_shift_count == 5'd5)?    e_shift_right_input[36:4] :
    (e_shift_count == 5'd6)?    e_shift_right_input[37:5] :
    (e_shift_count == 5'd7)?    e_shift_right_input[38:6] :
    (e_shift_count == 5'd8)?    e_shift_right_input[39:7] :
    (e_shift_count == 5'd9)?    e_shift_right_input[40:8] :
    (e_shift_count == 5'd10)?   e_shift_right_input[41:9] :
    (e_shift_count == 5'd11)?   e_shift_right_input[42:10] :
    (e_shift_count == 5'd12)?   e_shift_right_input[43:11] :
    (e_shift_count == 5'd13)?   e_shift_right_input[44:12] :
    (e_shift_count == 5'd14)?   e_shift_right_input[45:13] :
    (e_shift_count == 5'd15)?   e_shift_right_input[46:14] :
    (e_shift_count == 5'd16)?   e_shift_right_input[47:15] :
    (e_shift_count == 5'd17)?   e_shift_right_input[48:16] :
    (e_shift_count == 5'd18)?   e_shift_right_input[49:17] :
    (e_shift_count == 5'd19)?   e_shift_right_input[50:18] :
    (e_shift_count == 5'd20)?   e_shift_right_input[51:19] :
    (e_shift_count == 5'd21)?   e_shift_right_input[52:20] :
    (e_shift_count == 5'd22)?   e_shift_right_input[53:21] :
    (e_shift_count == 5'd23)?   e_shift_right_input[54:22] :
    (e_shift_count == 5'd24)?   e_shift_right_input[55:23] :
    (e_shift_count == 5'd25)?   e_shift_right_input[56:24] :
    (e_shift_count == 5'd26)?   e_shift_right_input[57:25] :
    (e_shift_count == 5'd27)?   e_shift_right_input[58:26] :
    (e_shift_count == 5'd28)?   e_shift_right_input[59:27] :
    (e_shift_count == 5'd29)?   e_shift_right_input[60:28] :
    (e_shift_count == 5'd30)?   e_shift_right_input[61:29] :
                                e_shift_right_input[62:30];
assign e_shift_cflag =
    (e_shift_SHL || e_shift_ROL || e_shift_RCL || e_shift_SHLD)?    e_shift_left_cflag :
    (e_shift_SHRD && exe_operand_16bit && e_shift_count >= 5'd17)?  1'b0 :
                                                                    e_shift_right_result[0];

assign e_shift_oflag =  (e_shift_ROL)?                                                  e_shift_result[31] ^ e_shift_result[0] :
                        (e_shift_ROR || e_shift_RCR || e_shift_SHR || e_shift_SHRD)?    e_shift_result[31] ^ e_shift_result[30] :
                        (e_shift_RCL || e_shift_SHL || e_shift_SHLD)?                   e_shift_result[31] ^ e_shift_cflag :
                                                                                        1'b0; //e_shift_SAR

assign e_shift_result =
    ((e_shift_SHL || e_shift_ROL || e_shift_RCL || e_shift_SHLD) && exe_is_8bit)?       { {24{e_shift_left_result[7]}},  e_shift_left_result[7:0] } :
    ((e_shift_SHL || e_shift_ROL || e_shift_RCL || e_shift_SHLD) && exe_operand_16bit)? { {16{e_shift_left_result[15]}}, e_shift_left_result[15:0] } :
    ((e_shift_SHL || e_shift_ROL || e_shift_RCL || e_shift_SHLD) && exe_operand_32bit)?       e_shift_left_result[31:0] :
    (exe_is_8bit)?                                                                      { e_shift_right_result[8],  {23{e_shift_right_result[7]}},  e_shift_right_result[8:1] } :
    (exe_operand_16bit)?                                                                { e_shift_right_result[16], {15{e_shift_right_result[15]}}, e_shift_right_result[16:1] } :
                                                                                          e_shift_right_result[32:1];

assign e_shift_cf_of_rotate_carry_8bit  = e_shift_count != 5'd0 && e_shift_count != 5'd9 && e_shift_count != 5'd18 && e_shift_count != 5'd27;
assign e_shift_cf_of_rotate_carry_16bit = e_shift_count != 5'd0 && e_shift_count != 5'd17;

assign e_shift_cmd_not_carry = e_shift_ROL || e_shift_ROR || e_shift_SHL || e_shift_SHR || e_shift_SAR || e_shift_SHLD || e_shift_SHRD;
assign e_shift_cmd_carry     = e_shift_RCL || e_shift_RCR;
assign e_shift_cmd_shift     = e_shift_SHL || e_shift_SHR || e_shift_SAR || e_shift_SHLD || e_shift_SHRD;
assign e_shift_cmd_rot       = e_shift_ROL || e_shift_ROR;

assign e_shift_cf_of_update =
    (e_shift_count != 5'd0 && e_shift_cmd_not_carry) ||
    (   exe_is_8bit                      && e_shift_cf_of_rotate_carry_8bit  && e_shift_cmd_carry) ||
    (~(exe_is_8bit) && exe_operand_16bit && e_shift_cf_of_rotate_carry_16bit && e_shift_cmd_carry) ||
    (~(exe_is_8bit) && exe_operand_32bit && e_shift_count != 5'd0            && e_shift_cmd_carry);

assign e_shift_oszapc_update = e_shift_cf_of_update && e_shift_cmd_shift;

assign e_shift_no_write =
    (                                       e_shift_cmd_shift && e_shift_count == 5'd0) ||
    (  exe_is_8bit                       && e_shift_cmd_rot   && e_shift_count[2:0] == 3'd0) ||
    (~(exe_is_8bit) && exe_operand_16bit && e_shift_cmd_rot   && e_shift_count[3:0] == 4'd0) ||
    
    (  exe_is_8bit                       && e_shift_cmd_carry && ~(e_shift_cf_of_rotate_carry_8bit))  ||
    (~(exe_is_8bit) && exe_operand_16bit && e_shift_cmd_carry && ~(e_shift_cf_of_rotate_carry_16bit)) ||
    
    (~(exe_is_8bit) && exe_operand_32bit && e_shift_count      == 5'd0);
    
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, exe_cmd[6:1], exe_decoder[39:14], exe_decoder[10:0], exe_modregrm_imm[7:5], ecx[31:5], e_shift_left_input[0], e_shift_right_input[63], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
