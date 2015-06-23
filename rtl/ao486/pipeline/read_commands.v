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

//PARSED_COMMENTS: this file contains parsed script comments

module read_commands(
    input               clk,
    input               rst_n,
    
    //general input
    input       [63:0]  glob_descriptor,
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_2,
    input       [31:0]  glob_param_3,
    
    input       [31:0]  glob_desc_base,
    input       [31:0]  glob_desc_limit,
    
    input       [15:0]  tr,
    input       [31:0]  tr_base,
    input       [63:0]  tr_cache,
    input               tr_cache_valid,
    input       [31:0]  tr_limit,
    
    input       [31:0]  gdtr_base,
    input       [31:0]  idtr_base,
        
    input       [31:0]  ecx,
    input       [31:0]  edx,
        
    input       [1:0]   iopl,
    
    input       [7:0]   exc_vector,
    
    input               io_allow_check_needed,
    
    input       [1:0]   cpl,
    input               cr0_pg,
    
    input               real_mode,
    input               v8086_mode,
    input               protected_mode,
    
    input       [10:0]  exe_mutex,
    
    //rd input
    input       [87:0]  rd_decoder,
    input       [6:0]   rd_cmd,
    input       [3:0]   rd_cmdex,
    input       [1:0]   rd_modregrm_mod,
    input               rd_operand_16bit,
    input               rd_operand_32bit,
    input       [31:0]  rd_memory_last,
    input       [1:0]   rd_prefix_group_1_rep,
    input               rd_address_16bit,
    input               rd_address_32bit,
    input               rd_ready,
    
    input       [31:0]  dst_wire,
    
    input               rd_descriptor_not_in_limits,
    input       [3:0]   rd_consumed,

    //rd mutex busy
    input               rd_mutex_busy_active,
    input               rd_mutex_busy_memory,
    input               rd_mutex_busy_eflags,
    input               rd_mutex_busy_ebp,
    input               rd_mutex_busy_esp,
    input               rd_mutex_busy_edx,
    input               rd_mutex_busy_ecx,
    input               rd_mutex_busy_eax,
    input               rd_mutex_busy_modregrm_reg,
    input               rd_mutex_busy_modregrm_rm,
    input               rd_mutex_busy_implicit_reg,
    
    //rd output
    output      [31:0]  rd_extra_wire,
    output      [31:0]  rd_system_linear,
    
    output      [15:0]  rd_error_code,
    
    output              rd_ss_esp_from_tss_fault,
    
    output              rd_waiting,
    
    //mutex req
    output              rd_req_memory,
    output              rd_req_eflags,
    output              rd_req_all,
    output              rd_req_reg,
    output              rd_req_rm,
    output              rd_req_implicit_reg,
    output              rd_req_reg_not_8bit,
    output              rd_req_edi,
    output              rd_req_esi,
    output              rd_req_ebp,
    output              rd_req_esp,
    output              rd_req_ebx,
    output              rd_req_edx_eax,
    output              rd_req_edx,
    output              rd_req_ecx,
    output              rd_req_eax,
    
    //address control
    output              address_enter_init,
    output              address_enter,
    output              address_enter_last,
    output              address_leave,
    output              address_esi,
    output              address_edi,
    output              address_xlat_transform,
    output              address_bits_transform,
    
    output              address_stack_pop,
    output              address_stack_pop_speedup,
    
    output              address_stack_pop_next,
    output              address_stack_pop_esp_prev,
    output              address_stack_pop_for_call,
    output              address_stack_save,
    output              address_stack_add_4_to_saved,
    
    output              address_stack_for_ret_first,
    output              address_stack_for_ret_second,
    output              address_stack_for_iret_first,
    output              address_stack_for_iret_second,
    output              address_stack_for_iret_third,
    output              address_stack_for_iret_last,
    output              address_stack_for_iret_to_v86,
    output              address_stack_for_call_param_first,
    
    output              address_ea_buffer,
    output              address_ea_buffer_plus_2,
    
    output              address_memoffset,
    
    //read control
    output              read_virtual,
    output              read_rmw_virtual,
    output              write_virtual_check,
    
    output              read_system_descriptor,
    output              read_system_word,
    output              read_system_dword,
    output              read_system_qword,
    output              read_rmw_system_dword,
    
    output              read_length_word,
    output              read_length_dword,
    
    input               read_for_rd_ready,
    input               write_virtual_check_ready,
    
    input               rd_address_effective_ready,
    
    input       [31:0]  read_4,
    input       [63:0]  read_8,

    //read signals
    output              rd_src_is_memory,
    output              rd_src_is_io,
    output              rd_src_is_modregrm_imm,
    output              rd_src_is_modregrm_imm_se,
    output              rd_src_is_imm,
    output              rd_src_is_imm_se,
    output              rd_src_is_1,
    output              rd_src_is_eax,
    output              rd_src_is_ecx,
    output              rd_src_is_cmdex,
    output              rd_src_is_implicit_reg,
    output              rd_src_is_rm,
    output              rd_src_is_reg,

    output              rd_dst_is_0,
    output              rd_dst_is_modregrm_imm_se,
    output              rd_dst_is_modregrm_imm,
    output              rd_dst_is_memory,
    output              rd_dst_is_memory_last,
    output              rd_dst_is_eip,
    output              rd_dst_is_eax,
    output              rd_dst_is_edx_eax,
    output              rd_dst_is_implicit_reg,
    output              rd_dst_is_rm,
    output              rd_dst_is_reg,
    
    //global set
    output              rd_glob_descriptor_set,
    output      [63:0]  rd_glob_descriptor_value,
    
    output              rd_glob_descriptor_2_set,
    output      [63:0]  rd_glob_descriptor_2_value,
    
    output              rd_glob_param_1_set,
    output      [31:0]  rd_glob_param_1_value,
    
    output              rd_glob_param_2_set,
    output      [31:0]  rd_glob_param_2_value,
    
    output              rd_glob_param_3_set,
    output      [31:0]  rd_glob_param_3_value,
    
    output              rd_glob_param_4_set,
    output      [31:0]  rd_glob_param_4_value,
    
    output              rd_glob_param_5_set,
    output      [31:0]  rd_glob_param_5_value,
    
    //io
    output              io_read,
    output      [15:0]  io_read_address,
    input               rd_io_ready,
    
    output              rd_io_allow_fault
);

//------------------------------------------------------------------------------ string

wire rd_string_ignore;

assign rd_string_ignore = rd_prefix_group_1_rep != 2'd0 &&
    ((rd_address_16bit && ecx[15:0] == 16'd0) || (rd_address_32bit && ecx == 32'd0));

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, glob_param_2[31:6], glob_param_3[31:25], tr[1:0], tr_cache[63:44], tr_cache[39:0],
    edx[31:16], exe_mutex[9:0], rd_decoder[87:56], rd_decoder[23:16], rd_decoder[7], rd_memory_last[31:16], dst_wire[31:16], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

`include "autogen/read_commands.v"

endmodule
