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

module write_commands(
    input               clk,
    input               rst_n,
    
    //general input
    input               real_mode,
    input               v8086_mode,
    input               protected_mode,
    
    input       [1:0]   cpl,
    
    input       [31:0]  tr_base,
    
    input       [31:0]  eip,
    
    input               io_allow_check_needed,
    
    input               exc_push_error,
    input       [31:0]  exc_eip,
    
    //global input
    input       [63:0]  glob_descriptor,
    input       [31:0]  glob_desc_base,

    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_2,
    input       [31:0]  glob_param_3,
    input       [31:0]  glob_param_4,
    input       [31:0]  glob_param_5,

    //write
    input               wr_ready,
    input       [15:0]  wr_decoder,
    input       [6:0]   wr_cmd,
    input       [3:0]   wr_cmdex,
    input               wr_is_8bit,
    input               wr_address_16bit,
    input               wr_operand_16bit,
    input               wr_operand_32bit,
    input               wr_mult_overflow,
    input       [3:0]   wr_arith_index,
    input       [1:0]   wr_modregrm_mod,
    input       [2:0]   wr_modregrm_reg,
    input       [2:0]   wr_modregrm_rm,
    input               wr_dst_is_memory,
    input               wr_dst_is_reg,
    input               wr_dst_is_rm,
    input               wr_dst_is_implicit_reg,
    input               wr_dst_is_edx_eax,
    input               wr_dst_is_eax,
    
    input               wr_arith_add_carry,
    input               wr_arith_adc_carry,
    input               wr_arith_sbb_carry,
    input               wr_arith_sub_carry,
    
    input       [31:0]  result,
    input       [31:0]  result2,
    input       [31:0]  wr_src,
    input       [31:0]  wr_dst,
    input       [4:0]   result_signals,
    input       [31:0]  result_push,
    
    input       [31:0]  exe_buffer,
    input       [463:0] exe_buffer_shifted,
    
    //global output
    output              wr_glob_param_1_set,
    output      [31:0]  wr_glob_param_1_value,
    
    output              wr_glob_param_3_set,
    output      [31:0]  wr_glob_param_3_value,
    
    output              wr_glob_param_4_set,
    output      [31:0]  wr_glob_param_4_value,
    
    //debug output
    output              wr_debug_trap_clear,
    output              wr_debug_task_trigger,
    
    //exception
    output              wr_int,
    output              wr_int_soft_int,
    output              wr_int_soft_int_ib,
    output      [7:0]   wr_int_vector,

    output              wr_exception_external_set,
    output              wr_exception_finished,
    
    output              wr_inhibit_interrupts,
    output              wr_inhibit_interrupts_and_debug,
    
    //memory
    input               write_for_wr_ready,
    
    output              write_rmw_virtual,
    output              write_virtual,
    output              write_rmw_system_dword,
    output              write_system_word,
    output              write_system_dword,
    output              write_system_busy_tss,
    output              write_system_touch,
    
    output              write_length_word,
    output              write_length_dword,
    
    output      [31:0]  wr_system_dword,
    output      [31:0]  wr_system_linear,
    
    //write regrm
    output              write_regrm,
    output              write_eax,
    output              wr_regrm_word,
    output              wr_regrm_dword,
    
    //write output
    output              wr_not_finished,
    output              wr_hlt_in_progress,
    output              wr_string_in_progress,
    output              wr_waiting,
    
    output              wr_req_reset_pr,
    output              wr_req_reset_dec,
    output              wr_req_reset_micro,
    output              wr_req_reset_rd,
    output              wr_req_reset_exe,

    output              wr_zflag_result,
    
    output reg  [1:0]   wr_task_rpl,
    
    output              wr_one_cycle_wait,
    
    //stack
    output              write_stack_virtual,
    output              write_new_stack_virtual,
    
    output              wr_push_length_word,
    output              wr_push_length_dword,
    
    input       [31:0]  wr_stack_esp,
    input       [31:0]  wr_new_stack_esp,
    
    output              wr_push_ss_fault_check,
    input               wr_push_ss_fault,
    
    output              wr_new_push_ss_fault_check,
    input               wr_new_push_ss_fault,
    
    output      [15:0]  wr_error_code,
    
    output              wr_make_esp_speculative,
    output              wr_make_esp_commit,
    
    //string
    input               wr_string_ignore,
    input       [1:0]   wr_prefix_group_1_rep,
    input               wr_string_zf_finish,
    input               wr_string_es_fault,
    input               wr_string_finish,
    
    input       [31:0]  wr_esi_final,
    input       [31:0]  wr_edi_final,
    input       [31:0]  wr_ecx_final,

    output              wr_string_gp_fault_check,
    output              write_string_es_virtual,

    //io write
    output              write_io,
    input               write_io_for_wr_ready,
    
    //segment
    output      [15:0]  wr_seg_sel,
    output              wr_seg_cache_valid,
    output      [1:0]   wr_seg_rpl,
    output      [63:0]  wr_seg_cache_mask,
    
    output              write_seg_cache,
    output              write_seg_sel,
    output              write_seg_cache_valid,
    output              write_seg_rpl,
    
    output              wr_validate_seg_regs,

    //flush tlb
    output              tlbflushall_do,
    
    //---------------------
    
    output      [31:0]  eax_to_reg,
    output      [31:0]  ebx_to_reg,
    output      [31:0]  ecx_to_reg,
    output      [31:0]  edx_to_reg,
    output      [31:0]  esi_to_reg,
    output      [31:0]  edi_to_reg,
    output      [31:0]  ebp_to_reg,
    output      [31:0]  esp_to_reg,
    
    output              cr0_pe_to_reg,
    output              cr0_mp_to_reg,
    output              cr0_em_to_reg,
    output              cr0_ts_to_reg,
    output              cr0_ne_to_reg,
    output              cr0_wp_to_reg,
    output              cr0_am_to_reg,
    output              cr0_nw_to_reg,
    output              cr0_cd_to_reg,
    output              cr0_pg_to_reg,
    
    output      [31:0]  cr2_to_reg,
    output      [31:0]  cr3_to_reg,
    
    output              cflag_to_reg,
    output              pflag_to_reg,
    output              aflag_to_reg,
    output              zflag_to_reg,
    output              sflag_to_reg,
    output              oflag_to_reg,
    output              tflag_to_reg,
    output              iflag_to_reg,
    output              dflag_to_reg,
    output      [1:0]   iopl_to_reg,
    output              ntflag_to_reg,
    output              rflag_to_reg,
    output              vmflag_to_reg,
    output              acflag_to_reg,
    output              idflag_to_reg,
    
    output      [31:0]  gdtr_base_to_reg,
    output      [15:0]  gdtr_limit_to_reg,
    
    output      [31:0]  idtr_base_to_reg,
    output      [15:0]  idtr_limit_to_reg,
    
    output      [31:0]  dr0_to_reg,
    output      [31:0]  dr1_to_reg,
    output      [31:0]  dr2_to_reg,
    output      [31:0]  dr3_to_reg,
    output      [3:0]   dr6_breakpoints_to_reg,
    output              dr6_b12_to_reg,
    output              dr6_bd_to_reg,
    output              dr6_bs_to_reg,
    output              dr6_bt_to_reg,
    output      [31:0]  dr7_to_reg,
    
    output      [15:0]  es_to_reg,
    output      [15:0]  ds_to_reg,
    output      [15:0]  ss_to_reg,
    output      [15:0]  fs_to_reg,
    output      [15:0]  gs_to_reg,
    output      [15:0]  cs_to_reg,
    output      [15:0]  ldtr_to_reg,
    output      [15:0]  tr_to_reg,

    output      [63:0]  es_cache_to_reg,
    output      [63:0]  ds_cache_to_reg,
    output      [63:0]  ss_cache_to_reg,
    output      [63:0]  fs_cache_to_reg,
    output      [63:0]  gs_cache_to_reg,
    output      [63:0]  cs_cache_to_reg,
    output      [63:0]  ldtr_cache_to_reg,
    output      [63:0]  tr_cache_to_reg,

    output              es_cache_valid_to_reg,
    output              ds_cache_valid_to_reg,
    output              ss_cache_valid_to_reg,
    output              fs_cache_valid_to_reg,
    output              gs_cache_valid_to_reg,
    output              cs_cache_valid_to_reg,
    output              ldtr_cache_valid_to_reg,

    output      [1:0]   es_rpl_to_reg,
    output      [1:0]   ds_rpl_to_reg,
    output      [1:0]   ss_rpl_to_reg,
    output      [1:0]   fs_rpl_to_reg,
    output      [1:0]   gs_rpl_to_reg,
    output      [1:0]   cs_rpl_to_reg,
    output      [1:0]   ldtr_rpl_to_reg,
    output      [1:0]   tr_rpl_to_reg,
    
    //output
    input       [31:0]  eax,
    input       [31:0]  ebx,
    input       [31:0]  ecx,
    input       [31:0]  edx,
    input       [31:0]  esi,
    input       [31:0]  edi,
    input       [31:0]  ebp,
    input       [31:0]  esp,

    input               cr0_pe,
    input               cr0_mp,
    input               cr0_em,
    input               cr0_ts,
    input               cr0_ne,
    input               cr0_wp,
    input               cr0_am,
    input               cr0_nw,
    input               cr0_cd,
    input               cr0_pg,
    
    input       [31:0]  cr2,
    input       [31:0]  cr3,
    
    input               cflag,
    input               pflag,
    input               aflag,
    input               zflag,
    input               sflag,
    input               oflag,
    input               tflag,
    input               iflag,
    input               dflag,
    input       [1:0]   iopl,
    input               ntflag,
    input               rflag,
    input               vmflag,
    input               acflag,
    input               idflag,

    input       [31:0]  gdtr_base,
    input       [15:0]  gdtr_limit,
    
    input       [31:0]  idtr_base,
    input       [15:0]  idtr_limit,
    
    input       [31:0]  dr0,
    input       [31:0]  dr1,
    input       [31:0]  dr2,
    input       [31:0]  dr3,
    input       [3:0]   dr6_breakpoints,
    input               dr6_b12,
    input               dr6_bd,
    input               dr6_bs,
    input               dr6_bt,
    input       [31:0]  dr7,
    
    input       [15:0]  es,
    input       [15:0]  ds,
    input       [15:0]  ss,
    input       [15:0]  fs,
    input       [15:0]  gs,
    input       [15:0]  cs,
    input       [15:0]  ldtr,
    input       [15:0]  tr,

    input       [63:0]  es_cache,
    input       [63:0]  ds_cache,
    input       [63:0]  ss_cache,
    input       [63:0]  fs_cache,
    input       [63:0]  gs_cache,
    input       [63:0]  cs_cache,
    input       [63:0]  ldtr_cache,
    input       [63:0]  tr_cache,

    input               es_cache_valid,
    input               ds_cache_valid,
    input               ss_cache_valid,
    input               fs_cache_valid,
    input               gs_cache_valid,
    input               cs_cache_valid,
    input               ldtr_cache_valid,

    input       [1:0]   es_rpl,
    input       [1:0]   ds_rpl,
    input       [1:0]   ss_rpl,
    input       [1:0]   fs_rpl,
    input       [1:0]   gs_rpl,
    input       [1:0]   cs_rpl,
    input       [1:0]   ldtr_rpl,
    input       [1:0]   tr_rpl
);

//------------------------------------------------------------------------------ flags
wire sflag_result;
wire zflag_result;
wire pflag_result;

wire w_logic_arith;
wire w_sub_arith;

wire aflag_arith;
wire cflag_arith;
wire oflag_arith;

assign sflag_result =   (wr_is_8bit)?       result[7] :
                        (wr_operand_16bit)? result[15] :
                                            result[31];

assign zflag_result =   (wr_is_8bit)?       result[7:0]  == 8'd0 :
                        (wr_operand_16bit)? result[15:0] == 16'd0 :
                                            result[31:0] == 32'd0;
                  
assign wr_zflag_result = zflag_result;

assign pflag_result = ~(result[7] ^ result[6] ^ result[5] ^ result[4] ^ result[3] ^ result[2] ^ result[1] ^ result[0]);

assign w_logic_arith =
    ~(wr_arith_index[3]) || // logic OSZAPC: AAM,AAD,AAA,AAS,DAA,DAS, BSF,BSR, Shift
    wr_arith_index == (`ARITH_VALID | `ARITH_OR) || wr_arith_index == (`ARITH_VALID | `ARITH_AND) || wr_arith_index == (`ARITH_VALID | `ARITH_XOR);

assign w_sub_arith  = wr_arith_index == (`ARITH_VALID | `ARITH_SBB) || wr_arith_index == (`ARITH_VALID | `ARITH_SUB) || wr_arith_index == (`ARITH_VALID | `ARITH_CMP);

//-----

assign aflag_arith = (w_logic_arith)? 1'b0 : wr_src[4] ^ wr_dst[4] ^ result[4];

assign cflag_arith =
    (w_logic_arith)?                                    1'b0 :
    (wr_is_8bit)?                                       wr_src[8]  ^ wr_dst[8]  ^ result[8] :
    (wr_operand_16bit)?                                 wr_src[16] ^ wr_dst[16] ^ result[16] :
    (wr_arith_index == (`ARITH_VALID | `ARITH_ADD))?    wr_arith_add_carry :
    (wr_arith_index == (`ARITH_VALID | `ARITH_ADC))?    wr_arith_adc_carry :
    (wr_arith_index == (`ARITH_VALID | `ARITH_SBB))?    wr_arith_sbb_carry :
                                                        wr_arith_sub_carry; // `ARITH_SUB || `ARITH_CMP
assign oflag_arith =
    (w_logic_arith)?                    1'b0 :
    (w_sub_arith && wr_is_8bit)?        (wr_src[7]  == 1'b0 && wr_dst[7]  && result[7]  == 1'b0) || (wr_src[7]  && wr_dst[7]  == 1'b0 && result[7]) :
    (w_sub_arith && wr_operand_16bit)?  (wr_src[15] == 1'b0 && wr_dst[15] && result[15] == 1'b0) || (wr_src[15] && wr_dst[15] == 1'b0 && result[15]) :
    (w_sub_arith)?                      (wr_src[31] == 1'b0 && wr_dst[31] && result[31] == 1'b0) || (wr_src[31] && wr_dst[31] == 1'b0 && result[31]) :
    (wr_is_8bit)?                       (wr_src[7]  == 1'b0 && wr_dst[7]  == 1'b0 && result[7])  || (wr_src[7]  && wr_dst[7]  && result[7]  == 1'b0) :
    (wr_operand_16bit)?                 (wr_src[15] == 1'b0 && wr_dst[15] == 1'b0 && result[15]) || (wr_src[15] && wr_dst[15] && result[15] == 1'b0) :
                                        (wr_src[31] == 1'b0 && wr_dst[31] == 1'b0 && result[31]) || (wr_src[31] && wr_dst[31] && result[31] == 1'b0);

//------------------------------------------------------------------------------ task

wire [31:0] task_eflags;
wire [15:0] task_es;
wire [15:0] task_cs;
wire [15:0] task_ss;
wire [15:0] task_ds;
wire [15:0] task_fs;
wire [15:0] task_gs;
wire [15:0] task_ldtr;
wire [15:0] task_trap;
    
assign task_eflags= (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'd0, exe_buffer_shifted[383:368] } : exe_buffer_shifted[399:368];

assign task_es    = exe_buffer_shifted[111:96];
assign task_cs    = exe_buffer_shifted[95:80];
assign task_ss    = exe_buffer_shifted[79:64];
assign task_ds    = exe_buffer_shifted[63:48];

assign task_fs    = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? 16'd0 : exe_buffer_shifted[47:32];
assign task_gs    = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? 16'd0 : exe_buffer_shifted[31:16];

assign task_ldtr  = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? exe_buffer_shifted[47:32] : exe_buffer_shifted[15:0];

assign task_trap  = exe_buffer[15:0];

/*******************************************************************************SCRIPT

NO_ALWAYS_BLOCK(eax);
NO_ALWAYS_BLOCK(ebx);
NO_ALWAYS_BLOCK(ecx);
NO_ALWAYS_BLOCK(edx);
NO_ALWAYS_BLOCK(esi);
NO_ALWAYS_BLOCK(edi);
NO_ALWAYS_BLOCK(ebp);
NO_ALWAYS_BLOCK(esp);
    
NO_ALWAYS_BLOCK(cr0_pe);
NO_ALWAYS_BLOCK(cr0_mp);
NO_ALWAYS_BLOCK(cr0_em);
NO_ALWAYS_BLOCK(cr0_ts);
NO_ALWAYS_BLOCK(cr0_ne);
NO_ALWAYS_BLOCK(cr0_wp);
NO_ALWAYS_BLOCK(cr0_am);
NO_ALWAYS_BLOCK(cr0_nw);
NO_ALWAYS_BLOCK(cr0_cd);
NO_ALWAYS_BLOCK(cr0_pg);
    
NO_ALWAYS_BLOCK(cr2);
NO_ALWAYS_BLOCK(cr3);
    
NO_ALWAYS_BLOCK(cflag);
NO_ALWAYS_BLOCK(pflag);
NO_ALWAYS_BLOCK(aflag);
NO_ALWAYS_BLOCK(zflag);
NO_ALWAYS_BLOCK(sflag);
NO_ALWAYS_BLOCK(oflag);
NO_ALWAYS_BLOCK(tflag);
NO_ALWAYS_BLOCK(iflag);
NO_ALWAYS_BLOCK(dflag);
NO_ALWAYS_BLOCK(iopl);
NO_ALWAYS_BLOCK(ntflag);
NO_ALWAYS_BLOCK(rflag);
NO_ALWAYS_BLOCK(vmflag);
NO_ALWAYS_BLOCK(acflag);
NO_ALWAYS_BLOCK(idflag);
    
NO_ALWAYS_BLOCK(gdtr_base);
NO_ALWAYS_BLOCK(gdtr_limit);
    
NO_ALWAYS_BLOCK(idtr_base);
NO_ALWAYS_BLOCK(idtr_limit);

NO_ALWAYS_BLOCK(dr0);
NO_ALWAYS_BLOCK(dr1);
NO_ALWAYS_BLOCK(dr2);
NO_ALWAYS_BLOCK(dr3);
NO_ALWAYS_BLOCK(dr6_breakpoints);
NO_ALWAYS_BLOCK(dr6_b12);
NO_ALWAYS_BLOCK(dr6_bd);
NO_ALWAYS_BLOCK(dr6_bs);
NO_ALWAYS_BLOCK(dr6_bt);
NO_ALWAYS_BLOCK(dr7);
    
NO_ALWAYS_BLOCK(es);
NO_ALWAYS_BLOCK(ds);
NO_ALWAYS_BLOCK(ss);
NO_ALWAYS_BLOCK(fs);
NO_ALWAYS_BLOCK(gs);
NO_ALWAYS_BLOCK(cs);
NO_ALWAYS_BLOCK(ldtr);
NO_ALWAYS_BLOCK(tr);

NO_ALWAYS_BLOCK(es_cache);
NO_ALWAYS_BLOCK(ds_cache);
NO_ALWAYS_BLOCK(ss_cache);
NO_ALWAYS_BLOCK(fs_cache);
NO_ALWAYS_BLOCK(gs_cache);
NO_ALWAYS_BLOCK(cs_cache);
NO_ALWAYS_BLOCK(ldtr_cache);
NO_ALWAYS_BLOCK(tr_cache);

NO_ALWAYS_BLOCK(es_cache_valid);
NO_ALWAYS_BLOCK(ds_cache_valid);
NO_ALWAYS_BLOCK(ss_cache_valid);
NO_ALWAYS_BLOCK(fs_cache_valid);
NO_ALWAYS_BLOCK(gs_cache_valid);
NO_ALWAYS_BLOCK(cs_cache_valid);
NO_ALWAYS_BLOCK(ldtr_cache_valid);

NO_ALWAYS_BLOCK(es_rpl);
NO_ALWAYS_BLOCK(ds_rpl);
NO_ALWAYS_BLOCK(ss_rpl);
NO_ALWAYS_BLOCK(fs_rpl);
NO_ALWAYS_BLOCK(gs_rpl);
NO_ALWAYS_BLOCK(cs_rpl);
NO_ALWAYS_BLOCK(ldtr_rpl);
NO_ALWAYS_BLOCK(tr_rpl);
*/

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, glob_param_1[31:21], glob_param_5[31:22], glob_param_5[20:19], glob_param_5[17], glob_param_5[15], glob_param_5[5], glob_param_5[3], glob_param_5[1], wr_decoder[7:6], wr_decoder[2:0],
    wr_src[30:17], wr_src[14:9], wr_src[6:5], wr_src[3:0], wr_dst[30:17], wr_dst[14:9], wr_dst[6:5], wr_dst[3:0], exe_buffer_shifted[431:400],
    task_eflags[31:22], task_eflags[20:19], task_eflags[15], task_eflags[5], task_eflags[3], task_eflags[1], task_trap[15:1], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

`include "autogen/write_commands.v"

//------------------------------------------------------------------------------

endmodule
