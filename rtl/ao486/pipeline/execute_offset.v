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

module execute_offset(
    
    input               exe_operand_16bit,
    input       [39:0]  exe_decoder,
    
    input       [31:0]  ebp,
    input       [31:0]  esp,
    input       [63:0]  ss_cache,
    
    input       [63:0]  glob_descriptor,
    
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_3,
    input       [31:0]  glob_param_4,
    
    input       [31:0]  exe_address_effective,
    
    input       [31:0]  wr_stack_offset,
    
    //offset control
    input               offset_ret_far_se,
    input               offset_new_stack,
    input               offset_new_stack_minus,
    input               offset_new_stack_continue,
    input               offset_leave,
    input               offset_pop,
    input               offset_enter_last,
    input               offset_ret,
    input               offset_iret_glob_param_4,
    input               offset_iret,
    input               offset_ret_imm,
    input               offset_esp,
    input               offset_call,
    input               offset_call_keep,
    input               offset_call_int_same_first,
    input               offset_call_int_same_next,
    input               offset_int_real,
    input               offset_int_real_next,
    input               offset_task,
    
    //output
    output      [31:0]  exe_stack_offset,
    
    output      [31:0]  exe_enter_offset
);

//------------------------------------------------------------------------------

wire [31:0] e_pop_offset;
wire [31:0] e_push_offset;
wire [31:0] e_task_switch_error_push;
wire [31:0] e_push_real_int_offset;
wire [31:0] e_leave_offset;
wire [31:0] e_ret_offset;
wire [31:0] e_iret_offset;
wire [31:0] e_push_offset_for_call_int;
wire [31:0] e_temp_esp_real_int;
wire [31:0] e_temp_esp;
wire [31:0] e_push_offset_for_call_2_int;

wire [31:0] e_final_offset;
wire [31:0] e_new_stack_final_offset;

//------------------------------------------------------------------------------

assign e_pop_offset =
    (exe_operand_16bit)?    esp + 32'd2 :
                            esp + 32'd4;
assign e_push_offset =
    (exe_operand_16bit)?    esp - 32'd2 :
                            esp - 32'd4;

assign e_task_switch_error_push =
    (~(glob_param_3[17]))?  esp - 32'd2 :
                            esp - 32'd4;
                           
assign e_push_real_int_offset = esp - 32'd2;

assign e_leave_offset =
    (exe_operand_16bit)?    ebp + 32'd2 :
                            ebp + 32'd4;
assign e_ret_offset =
    (exe_operand_16bit)?    esp + 32'd2 + { {16{exe_decoder[23] & offset_ret_far_se}}, exe_decoder[23:8] } :
                            esp + 32'd4 + { 16'd0, exe_decoder[23:8] };
assign e_iret_offset =
    (exe_operand_16bit)?    esp + 32'd6 :
                            esp + 32'd12;

assign e_push_offset_for_call_int =
    (~(glob_param_1[19]))?  esp - 32'd2 :
                            esp - 32'd4;

assign e_temp_esp_real_int = wr_stack_offset - 32'd2;

assign e_temp_esp =
    (exe_operand_16bit)?    wr_stack_offset - 32'd2 :
                            wr_stack_offset - 32'd4;
                                                          
assign e_push_offset_for_call_2_int =
    (~(glob_param_1[19]))?  wr_stack_offset - 32'd2 :
                            wr_stack_offset - 32'd4; 
               
assign e_final_offset =
    (offset_leave)?                 e_leave_offset :
    (offset_pop)?                   e_pop_offset :
    (offset_enter_last)?            exe_address_effective :
    (offset_ret)?                   e_ret_offset :
    (offset_iret)?                  e_iret_offset :
    (offset_iret_glob_param_4)?     glob_param_4 :
    (offset_ret_imm)?               glob_param_4 + { 16'd0, exe_decoder[23:8] } :  
    (offset_esp)?                   esp :
    (offset_call)?                  e_temp_esp :
    (offset_call_keep)?             wr_stack_offset :
    (offset_call_int_same_first)?   e_push_offset_for_call_int :
    (offset_call_int_same_next)?    e_push_offset_for_call_2_int :
    (offset_int_real)?              e_push_real_int_offset :
    (offset_int_real_next)?         e_temp_esp_real_int :
    (offset_task)?                  e_task_switch_error_push :
                                    e_push_offset; // task_switch, call

assign e_new_stack_final_offset =
    (offset_new_stack)?                                 glob_param_4 :
    (offset_new_stack_minus && ~(glob_param_3[19]))?    glob_param_4 - 32'd2 :
    (offset_new_stack_minus)?                           glob_param_4 - 32'd4 :
    (~(glob_param_3[19]))?                              wr_stack_offset - 32'd2 :
                                                        wr_stack_offset - 32'd4;
assign exe_stack_offset =
    ((offset_new_stack || offset_new_stack_minus || offset_new_stack_continue) && glob_descriptor[`DESC_BIT_D_B])?  e_new_stack_final_offset :
    ((offset_new_stack || offset_new_stack_minus || offset_new_stack_continue))?                                    { 16'd0, e_new_stack_final_offset[15:0] } :
    (ss_cache[`DESC_BIT_D_B])?                                                                                      e_final_offset :
                                                                                                                    { 16'd0, e_final_offset[15:0] };
assign exe_enter_offset = (ss_cache[`DESC_BIT_D_B])? e_push_offset : { esp[31:16], e_push_offset[15:0] };

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, exe_decoder[39:24], exe_decoder[7:0], ss_cache[63:55], ss_cache[53:0], glob_descriptor[63:55], glob_descriptor[53:0],
    glob_param_1[31:20], glob_param_1[18:0], glob_param_3[31:20], glob_param_3[18], glob_param_3[16:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule

