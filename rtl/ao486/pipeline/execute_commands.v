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

module execute_commands(
    input               clk,
    input               rst_n,
    
    input               exe_reset,
    
    //general input
    input       [31:0]  eax,
    input       [31:0]  ecx,
    input       [31:0]  edx,
    input       [31:0]  ebp,
    input       [31:0]  esp,
    
    input       [31:0]  tr_base,
    
    input       [15:0]  es,
    input       [15:0]  cs,
    input       [15:0]  ss,
    input       [15:0]  ds,
    input       [15:0]  fs,
    input       [15:0]  gs,
    input       [15:0]  ldtr,
    input       [15:0]  tr,
    
    input       [31:0]  cr2,
    input       [31:0]  cr3,
    
    input       [31:0]  dr0,
    input       [31:0]  dr1,
    input       [31:0]  dr2,
    input       [31:0]  dr3,
    input               dr6_bt,
    input               dr6_bs,
    input               dr6_bd,
    input               dr6_b12,
    input       [3:0]   dr6_breakpoints,
    input       [31:0]  dr7,
    
    input       [1:0]   cpl,
    
    input               real_mode,
    input               v8086_mode,
    input               protected_mode,
    
    input               idflag,
    input               acflag,
    input               vmflag,
    input               rflag,
    input               ntflag,
    input       [1:0]   iopl,
    input               oflag,
    input               dflag,
    input               iflag,
    input               tflag,
    input               sflag,
    input               zflag,
    input               aflag,
    input               pflag,
    input               cflag,
    
    input               cr0_pg,
    input               cr0_cd,
    input               cr0_nw,
    input               cr0_am,
    input               cr0_wp,
    input               cr0_ne,
    input               cr0_ts,
    input               cr0_em,
    input               cr0_mp,
    input               cr0_pe,
    
    input       [31:0]  cs_limit,
    input       [31:0]  tr_limit,
    input       [63:0]  tr_cache,
    input       [63:0]  ss_cache,
    
    input       [15:0]  idtr_limit,
    input       [31:0]  idtr_base,
    
    input       [15:0]  gdtr_limit,
    input       [31:0]  gdtr_base,
    
    //exception input
    input               exc_push_error,
    input       [15:0]  exc_error_code,
    input               exc_soft_int_ib,
    input               exc_soft_int,
    input       [7:0]   exc_vector,
    
    //exe input
    input       [10:0]  exe_mutex_current,
    
    input       [31:0]  exe_eip,
    input       [31:0]  exe_extra,
    input       [31:0]  exe_linear,
    input       [6:0]   exe_cmd,
    input       [3:0]   exe_cmdex,
    input       [39:0]  exe_decoder,
    input       [2:0]   exe_modregrm_reg,
    input       [31:0]  exe_address_effective,
    input               exe_is_8bit,
    input               exe_operand_16bit,
    input               exe_operand_32bit,
    input               exe_address_16bit,
    input       [3:0]   exe_consumed,
    
    input       [31:0]  src,
    input       [31:0]  dst,
    
    input       [31:0]  exe_enter_offset,
    
    input               exe_ready,
    
    //mult
    input               mult_busy,
    input       [65:0]  mult_result,
    
    //div
    input               div_busy,
    input               exe_div_exception,
    
    input       [31:0]  div_result_quotient,
    input       [31:0]  div_result_remainder,
    
    //shift
    input               e_shift_no_write,
    input               e_shift_oszapc_update,
    input               e_shift_cf_of_update,
    input               e_shift_oflag,
    input               e_shift_cflag,
    
    input       [31:0]  e_shift_result,
    
    //tlbcheck
    output              tlbcheck_do,
    input               tlbcheck_done,
    input               tlbcheck_page_fault,
    
    output      [31:0]  tlbcheck_address,
    output              tlbcheck_rw,
    //----
    
    //tlbflushsingle
    output              tlbflushsingle_do,
    input               tlbflushsingle_done,
    
    output      [31:0]  tlbflushsingle_address,
    //----
    
    //invd
    output              invdcode_do,
    input               invdcode_done,
    
    output              invddata_do,
    input               invddata_done,
    
    output              wbinvddata_do,
    input               wbinvddata_done,
    //---
    
    //pipeline input
    input       [1:0]   wr_task_rpl,
    input       [31:0]  wr_esp_prev,
    
    //global input
    input       [63:0]  glob_descriptor,
    input       [63:0]  glob_descriptor_2,
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_2,
    input       [31:0]  glob_param_3,
    input       [31:0]  glob_param_5,
    
    input       [31:0]  glob_desc_base,
    
    input       [31:0]  glob_desc_limit,
    input       [31:0]  glob_desc_2_limit,
    
    //global set
    output              exe_glob_descriptor_set,
    output      [63:0]  exe_glob_descriptor_value,
    
    output              exe_glob_descriptor_2_set,
    output      [63:0]  exe_glob_descriptor_2_value,
    
    output              exe_glob_param_1_set,
    output      [31:0]  exe_glob_param_1_value,
    
    output              exe_glob_param_2_set,
    output      [31:0]  exe_glob_param_2_value,
    
    output              exe_glob_param_3_set,
    output      [31:0]  exe_glob_param_3_value,
    
    output              dr6_bd_set,
    
    //offset control
    output              offset_ret_far_se,
    output              offset_new_stack,
    output              offset_new_stack_minus,
    output              offset_new_stack_continue,
    output              offset_leave,
    output              offset_pop,
    output              offset_enter_last,
    output              offset_ret,
    output              offset_iret_glob_param_4,
    output              offset_iret,
    output              offset_ret_imm,
    output              offset_esp,
    output              offset_call,
    output              offset_call_keep,
    output              offset_call_int_same_first,
    output              offset_call_int_same_next,
    output              offset_int_real,
    output              offset_int_real_next,
    output              offset_task,
    
    //task output
    output      [31:0]  task_eip,

    //exe output
    output              exe_waiting,
    
    output              exe_bound_fault,
    output              exe_trigger_gp_fault,
    output              exe_trigger_ts_fault,
    output              exe_trigger_ss_fault,
    output              exe_trigger_np_fault,
    output              exe_trigger_pf_fault,
    output              exe_trigger_db_fault,
    output              exe_trigger_nm_fault,
    output              exe_load_seg_gp_fault,
    output              exe_load_seg_ss_fault,
    output              exe_load_seg_np_fault,
    
    output      [15:0]  exe_error_code,
    
    output      [31:0]  exe_result,
    output      [31:0]  exe_result2,
    output      [31:0]  exe_result_push,
    output      [4:0]   exe_result_signals,
    
    output      [3:0]   exe_arith_index,
    
    output              exe_arith_sub_carry,
    output              exe_arith_add_carry,
    output              exe_arith_adc_carry,
    output              exe_arith_sbb_carry,
    
    output reg [31:0]   exe_buffer,
    output reg [463:0]  exe_buffer_shifted,
    
    //output local
    output              exe_is_8bit_clear,
    
    output              exe_cmpxchg_switch,
    
    output              exe_task_switch_finished,
    
    output              exe_eip_from_glob_param_2,
    output              exe_eip_from_glob_param_2_16bit,
    
    //branch
    output              exe_branch,
    output      [31:0]  exe_branch_eip
);

//------------------------------------------------------------------------------ 

//------------------------------------------------------------------------------ eflags

wire [31:0] exe_push_eflags;
wire [31:0] exe_pushf_eflags;

assign exe_push_eflags   = { 10'b0,idflag,2'b0,acflag,vmflag,rflag,1'b0,ntflag,iopl,oflag,dflag,iflag,tflag,sflag,zflag,1'b0,aflag,1'b0,pflag,1'b1,cflag };
assign exe_pushf_eflags  = { 10'b0,idflag,2'b0,acflag,1'b0,  1'b0, 1'b0,ntflag,iopl,oflag,dflag,iflag,tflag,sflag,zflag,1'b0,aflag,1'b0,pflag,1'b1,cflag };
                         
//------------------------------------------------------------------------------ descriptor load seg

wire [2:0]  exe_segment;
wire [15:0] exe_selector;
wire [63:0] exe_descriptor;

wire exe_privilege_not_accepted;

assign exe_segment    = glob_param_1[18:16];
assign exe_selector   = glob_param_1[15:0];
assign exe_descriptor = glob_descriptor;

//task_switch, lar,lsl,verr,verw
assign exe_privilege_not_accepted =
    exe_selector[`SELECTOR_BITS_RPL] > exe_descriptor[`DESC_BITS_DPL] || cpl > exe_descriptor[`DESC_BITS_DPL];

//------------------------------------------------------------------------------ exe_buffer
    
wire        exe_buffer_shift;
wire        exe_buffer_shift_word;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               exe_buffer_shifted <= 464'd0;
    else if(exe_buffer_shift)       exe_buffer_shifted <= { exe_buffer_shifted[431:0], exe_buffer };
    else if(exe_buffer_shift_word)  exe_buffer_shifted <= { exe_buffer_shifted[447:0], exe_buffer[15:0] };
end

//------------------------------------------------------------------------------ 

wire [32:0] exe_arith_adc;
wire [32:0] exe_arith_add;
wire [31:0] exe_arith_and;
wire [31:0] exe_arith_not;
wire [31:0] exe_arith_or;
wire [32:0] exe_arith_sub;
wire [32:0] exe_arith_sbb;
wire [31:0] exe_arith_xor;

wire        exe_cmpxchg_switch_carry;

assign exe_arith_adc   = src + dst + { 31'd0, cflag };
assign exe_arith_add   = src + dst;
assign exe_arith_and   = src & dst;
assign exe_arith_not   = ~dst;
assign exe_arith_or    = src | dst;
assign exe_arith_sub   = dst - src;
assign exe_arith_sbb   = dst - src - { 31'd0, cflag };
assign exe_arith_xor   = src ^ dst;

assign exe_arith_sub_carry = (exe_cmpxchg_switch)? exe_cmpxchg_switch_carry : exe_arith_sub[32];
assign exe_arith_add_carry = exe_arith_add[32];
assign exe_arith_adc_carry = exe_arith_adc[32];
assign exe_arith_sbb_carry = exe_arith_sbb[32];

//------------------------------------------------------------------------------ 

wire [15:0] e_seg_by_cmdex;

assign e_seg_by_cmdex =
    (exe_cmdex[2:0] == 3'd0)?   es :
    (exe_cmdex[2:0] == 3'd1)?   cs :
    (exe_cmdex[2:0] == 3'd2)?   ss :
    (exe_cmdex[2:0] == 3'd3)?   ds :
    (exe_cmdex[2:0] == 3'd4)?   fs :
    (exe_cmdex[2:0] == 3'd5)?   gs :
    (exe_cmdex[2:0] == 3'd6)?   ldtr :
                                tr;

//------------------------------------------------------------------------------ task switch

//exe -> microcode
assign task_eip   = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'd0, exe_buffer_shifted[415:400] } : exe_buffer_shifted[431:400];

//------------------------------------------------------------------------------ Jcc, JCXZ, LOOP

wire [31:0] e_eip_next_sum;
    
assign e_eip_next_sum =
    (exe_is_8bit)?          exe_eip + { {24{exe_decoder[15]}}, exe_decoder[15:8] } :
    (exe_operand_16bit)?    exe_eip + { {16{exe_decoder[23]}}, exe_decoder[23:8] } :
                            exe_eip + exe_decoder[39:8];

assign exe_branch_eip =
    (exe_operand_16bit)?    { 16'd0, e_eip_next_sum[15:0] } :
                            e_eip_next_sum;

//------------------------------------------------------------------------------ Jcc, SETcc

wire exe_condition;

condition exe_condition_inst(
    .oflag      (oflag), //input
    .cflag      (cflag), //input
    .sflag      (sflag), //input
    .zflag      (zflag), //input
    .pflag      (pflag), //input
    
    .index      (exe_decoder[3:0]), //input [3:0]
    
    .condition  (exe_condition)  //output
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, edx[31:16], tr_cache[63:44], tr_cache[39:0], exe_mutex_current[9], exe_mutex_current[7:5], exe_mutex_current[3], exe_mutex_current[1],
    exe_decoder[7:4], mult_result[65:64], exe_selector[15:3], exe_descriptor[63:48], exe_descriptor[39:0], e_aaa_sum_ax[7:4], e_aas_sub_ax[7:4], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

`include "autogen/execute_commands.v"

//------------------------------------------------------------------------------
    
endmodule
