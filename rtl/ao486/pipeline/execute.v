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

module execute(
    input               clk,
    input               rst_n,
    
    input               exe_reset,
    
    //general input
    input       [31:0]  eax,
    input       [31:0]  ecx,
    input       [31:0]  edx,
    input       [31:0]  ebp,
    input       [31:0]  esp,
    
    input       [63:0]  cs_cache,
    input       [63:0]  tr_cache,
    input       [63:0]  ss_cache,
    
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
    
    //tlbcheck
    output              tlbcheck_do,
    input               tlbcheck_done,
    input               tlbcheck_page_fault,
    
    output      [31:0]  tlbcheck_address,
    output              tlbcheck_rw,
    
    //tlbflushsingle
    output              tlbflushsingle_do,
    input               tlbflushsingle_done,
    
    output      [31:0]  tlbflushsingle_address,
    
    //invd
    output              invdcode_do,
    input               invdcode_done,
    
    output              invddata_do,
    input               invddata_done,
    
    output              wbinvddata_do,
    input               wbinvddata_done,
    
    //pipeline input
    input       [31:0]  wr_esp_prev,
    input       [31:0]  wr_stack_offset,
    
    input       [10:0]  wr_mutex,
    
    //pipeline output
    output              exe_is_front,
    
    //global input
    input       [63:0]  glob_descriptor,
    input       [63:0]  glob_descriptor_2,
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_2,
    input       [31:0]  glob_param_3,
    input       [31:0]  glob_param_4,
    input       [31:0]  glob_param_5,
    
    input       [1:0]   wr_task_rpl,
    
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
    
    //to microcode
    output      [31:0]  task_eip,
    //to wr
    output      [31:0]  exe_buffer,
    output      [463:0] exe_buffer_shifted,
    
    //exceptions
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
    output              exe_div_exception,
    
    output      [15:0]  exe_error_code,
    
    output reg  [31:0]  exe_eip,
    output reg  [3:0]   exe_consumed,
    
    //rd pipeline
    output              exe_busy,
    input               rd_ready,
    
    input       [87:0]  rd_decoder,
    input       [31:0]  rd_eip,
    input               rd_operand_32bit,
    input               rd_address_32bit,
    input       [1:0]   rd_prefix_group_1_rep,
    input               rd_prefix_group_1_lock,
    input               rd_prefix_2byte,
    input       [3:0]   rd_consumed,
    input               rd_is_8bit,
    input       [6:0]   rd_cmd,
    input       [3:0]   rd_cmdex,
    input       [31:0]  rd_modregrm_imm,
    input       [10:0]  rd_mutex_next,
    input               rd_dst_is_reg,
    input               rd_dst_is_rm,
    input               rd_dst_is_memory,
    input               rd_dst_is_eax,
    input               rd_dst_is_edx_eax,
    input               rd_dst_is_implicit_reg,
    input       [31:0]  rd_extra_wire,
    input       [31:0]  rd_linear,
    input       [3:0]   rd_debug_read,
    input       [31:0]  src_wire,
    input       [31:0]  dst_wire,
    input       [31:0]  rd_address_effective,
    
    //exe pipeline
    input               wr_busy,
    output              exe_ready,
    
    output reg  [39:0]  exe_decoder,
    output      [31:0]  exe_eip_final,
    output reg          exe_operand_32bit,
    output reg          exe_address_32bit,
    output reg  [1:0]   exe_prefix_group_1_rep,
    output reg          exe_prefix_group_1_lock,
    output      [3:0]   exe_consumed_final,
    output              exe_is_8bit_final,
    output reg  [6:0]   exe_cmd,
    output reg  [3:0]   exe_cmdex,
    output reg  [10:0]  exe_mutex,
    output reg          exe_dst_is_reg,
    output reg          exe_dst_is_rm,
    output reg          exe_dst_is_memory,
    output reg          exe_dst_is_eax,
    output reg          exe_dst_is_edx_eax,
    output reg          exe_dst_is_implicit_reg,
    output reg  [31:0]  exe_linear,
    output reg  [3:0]   exe_debug_read,
    
    output      [31:0]  exe_result,
    output      [31:0]  exe_result2,
    output      [31:0]  exe_result_push,
    output      [4:0]   exe_result_signals,
    
    output      [3:0]   exe_arith_index,
    
    output              exe_arith_sub_carry,
    output              exe_arith_add_carry,
    output              exe_arith_adc_carry,
    output              exe_arith_sbb_carry,
    
    output      [31:0]  src_final,
    output      [31:0]  dst_final,
    
    output              exe_mult_overflow,
    output      [31:0]  exe_stack_offset
);

//------------------------------------------------------------------------------

wire [31:0] tr_base;
wire [31:0] tr_limit;

wire [31:0] cs_limit;

assign tr_base  = { tr_cache[63:56], tr_cache[39:16] };

assign tr_limit = tr_cache[`DESC_BIT_G]? { tr_cache[51:48], tr_cache[15:0], 12'hFFF } : { 12'd0, tr_cache[51:48], tr_cache[15:0] };
assign cs_limit = cs_cache[`DESC_BIT_G]? { cs_cache[51:48], cs_cache[15:0], 12'hFFF } : { 12'd0, cs_cache[51:48], cs_cache[15:0] };

//------------------------------------------------------------------------------

wire        e_load;

wire        exe_operand_16bit;
wire        exe_address_16bit;

wire [10:0] exe_mutex_current;

wire [2:0]  exe_modregrm_reg;

//------------------------------------------------------------------------------

wire exe_waiting;
    
wire exe_is_8bit_clear;

wire exe_cmpxchg_switch;

wire exe_task_switch_finished;
    
wire exe_eip_from_glob_param_2;
wire exe_eip_from_glob_param_2_16bit;

//------------------------------------------------------------------------------

assign exe_ready = ~(exe_reset) && ~(exe_waiting) && exe_cmd != `CMD_NULL && ~(wr_busy);

assign exe_busy = exe_waiting || (exe_ready == `FALSE && exe_cmd != `CMD_NULL);

assign e_load = rd_ready;

//------------------------------------------------------------------------------

reg         exe_is_8bit;
reg [7:0]   exe_modregrm_imm;
reg [31:0]  exe_extra;
reg [31:0]  src;
reg [31:0]  dst;
reg [31:0]  exe_address_effective;
reg         exe_prefix_2byte;

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_decoder              <= 40'd0;     else if(e_load) exe_decoder              <= rd_decoder[39:0];        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_eip                  <= 32'd0;     else if(e_load) exe_eip                  <= rd_eip;                  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_operand_32bit        <= `FALSE;    else if(e_load) exe_operand_32bit        <= rd_operand_32bit;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_address_32bit        <= `FALSE;    else if(e_load) exe_address_32bit        <= rd_address_32bit;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_prefix_group_1_rep   <= 2'd0;      else if(e_load) exe_prefix_group_1_rep   <= rd_prefix_group_1_rep;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_prefix_group_1_lock  <= `FALSE;    else if(e_load) exe_prefix_group_1_lock  <= rd_prefix_group_1_lock;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_prefix_2byte         <= `FALSE;    else if(e_load) exe_prefix_2byte         <= rd_prefix_2byte;         end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_consumed             <= 4'd0;      else if(e_load) exe_consumed             <= rd_consumed;             end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_is_8bit              <= `FALSE;    else if(e_load) exe_is_8bit              <= rd_is_8bit;              end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_cmdex                <= 4'd0;      else if(e_load) exe_cmdex                <= rd_cmdex;                end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_modregrm_imm         <= 8'd0;      else if(e_load) exe_modregrm_imm         <= rd_modregrm_imm[7:0];    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_dst_is_reg           <= `FALSE;    else if(e_load) exe_dst_is_reg           <= rd_dst_is_reg;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_dst_is_rm            <= `FALSE;    else if(e_load) exe_dst_is_rm            <= rd_dst_is_rm;            end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_dst_is_memory        <= `FALSE;    else if(e_load) exe_dst_is_memory        <= rd_dst_is_memory;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_dst_is_eax           <= `FALSE;    else if(e_load) exe_dst_is_eax           <= rd_dst_is_eax;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_dst_is_edx_eax       <= `FALSE;    else if(e_load) exe_dst_is_edx_eax       <= rd_dst_is_edx_eax;       end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_dst_is_implicit_reg  <= `FALSE;    else if(e_load) exe_dst_is_implicit_reg  <= rd_dst_is_implicit_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_extra                <= 32'd0;     else if(e_load) exe_extra                <= rd_extra_wire;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_linear               <= 32'd0;     else if(e_load) exe_linear               <= rd_linear;               end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_debug_read           <= 4'd0;      else if(e_load) exe_debug_read           <= rd_debug_read;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) src                      <= 32'd0;     else if(e_load) src                      <= src_wire;                end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) dst                      <= 32'd0;     else if(e_load) dst                      <= dst_wire;                end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_address_effective    <= 32'd0;     else if(e_load) exe_address_effective    <= rd_address_effective;    end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   exe_mutex <= 11'd0;
    else if(exe_reset)  exe_mutex <= 11'd0;
    else if(e_load)     exe_mutex <= rd_mutex_next;
    else if(exe_ready)  exe_mutex <= 11'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   exe_cmd <= `CMD_NULL;
    else if(exe_reset)  exe_cmd <= `CMD_NULL;
    else if(e_load)     exe_cmd <= rd_cmd;
    else if(exe_ready)  exe_cmd <= `CMD_NULL;
end

//------------------------------------------------------------------------------

assign exe_operand_16bit = ~(exe_operand_32bit);
assign exe_address_16bit = ~(exe_address_32bit);

assign exe_mutex_current      = wr_mutex;

assign exe_modregrm_reg = exe_decoder[13:11];

//------------------------------------------------------------------------------ misc

assign exe_is_8bit_final = (exe_is_8bit_clear)? `FALSE : exe_is_8bit;

assign exe_is_front = exe_cmd != `CMD_NULL && ~(exe_mutex_current[`MUTEX_ACTIVE_BIT]);

assign dst_final     = (exe_cmpxchg_switch)? eax : dst;
assign src_final     = (exe_cmpxchg_switch)? dst : src;

assign exe_consumed_final = (exe_task_switch_finished)?   glob_param_3[21:18] : exe_consumed;

//------------------------------------------------------------------------------ eip

wire        exe_branch;
wire [31:0] exe_branch_eip;

assign exe_eip_final =
    (exe_eip_from_glob_param_2 && ~(exe_task_switch_finished))? glob_param_2 :
    (exe_eip_from_glob_param_2_16bit)?                          { 16'd0, glob_param_2[15:0] } :
    (exe_branch)?                                               exe_branch_eip :
                                                                exe_eip;

//------------------------------------------------------------------------------

wire offset_ret_far_se;
wire offset_new_stack;
wire offset_new_stack_minus;
wire offset_new_stack_continue;
wire offset_leave;
wire offset_pop;
wire offset_enter_last;
wire offset_ret;
wire offset_iret_glob_param_4;
wire offset_iret;
wire offset_ret_imm;
wire offset_esp;
wire offset_call;
wire offset_call_keep;
wire offset_call_int_same_first;
wire offset_call_int_same_next;
wire offset_int_real;
wire offset_int_real_next;
wire offset_task;

wire [31:0] exe_enter_offset;

execute_offset execute_offset_inst(
    
    .exe_operand_16bit          (exe_operand_16bit),        //input
    .exe_decoder                (exe_decoder),              //input [39:0]
    
    .ebp                        (ebp),                      //input [31:0]
    .esp                        (esp),                      //input [31:0]
    .ss_cache                   (ss_cache),                 //input [63:0]
    
    .glob_descriptor            (glob_descriptor),          //input [63:0]
    
    .glob_param_1               (glob_param_1),             //input [31:0]
    .glob_param_3               (glob_param_3),             //input [31:0]
    .glob_param_4               (glob_param_4),             //input [31:0]
    
    .exe_address_effective      (exe_address_effective),    //input [31:0]
    
    .wr_stack_offset            (wr_stack_offset),          //input [31:0]
    
    //offset control
    .offset_ret_far_se          (offset_ret_far_se),          //input
    .offset_new_stack           (offset_new_stack),           //input
    .offset_new_stack_minus     (offset_new_stack_minus),     //input
    .offset_new_stack_continue  (offset_new_stack_continue),  //input
    .offset_leave               (offset_leave),               //input
    .offset_pop                 (offset_pop),                 //input
    .offset_enter_last          (offset_enter_last),          //input
    .offset_ret                 (offset_ret),                 //input
    .offset_iret_glob_param_4   (offset_iret_glob_param_4),   //input
    .offset_iret                (offset_iret),                //input
    .offset_ret_imm             (offset_ret_imm),             //input
    .offset_esp                 (offset_esp),                 //input
    .offset_call                (offset_call),                //input
    .offset_call_keep           (offset_call_keep),           //input
    .offset_call_int_same_first (offset_call_int_same_first), //input
    .offset_call_int_same_next  (offset_call_int_same_next),  //input
    .offset_int_real            (offset_int_real),            //input
    .offset_int_real_next       (offset_int_real_next),       //input
    .offset_task                (offset_task),                //input
    
    //output
    .exe_stack_offset           (exe_stack_offset),           //output [31:0]
    
    .exe_enter_offset           (exe_enter_offset)            //output [31:0]
);

//------------------------------------------------------------------------------

wire e_shift_no_write;
wire e_shift_oszapc_update;
wire e_shift_cf_of_update;
wire e_shift_oflag;
wire e_shift_cflag;

wire [31:0] e_shift_result;

execute_shift execute_shift_inst(
    
    .exe_is_8bit            (exe_is_8bit),              //input
    .exe_operand_16bit      (exe_operand_16bit),        //input
    .exe_operand_32bit      (exe_operand_32bit),        //input
    .exe_prefix_2byte       (exe_prefix_2byte),         //input
    
    .exe_cmd                (exe_cmd),                  //input [6:0]
    .exe_cmdex              (exe_cmdex),                //input [3:0]
    .exe_decoder            (exe_decoder),              //input [39:0]
    .exe_modregrm_imm       (exe_modregrm_imm),         //input [7:0]
    
    .cflag                  (cflag),                    //input
    
    .ecx                    (ecx),                      //input [31:0]
    
    .dst                    (dst),                      //input [31:0]
    .src                    (src),                      //input [31:0]
    
    //output
    .e_shift_no_write       (e_shift_no_write),         //output
    .e_shift_oszapc_update  (e_shift_oszapc_update),    //output
    .e_shift_cf_of_update   (e_shift_cf_of_update),     //output
    .e_shift_oflag          (e_shift_oflag),            //output
    .e_shift_cflag          (e_shift_cflag),            //output
    
    .e_shift_result         (e_shift_result)            //output [31:0]
);

//------------------------------------------------------------------------------

wire [65:0] mult_result;
wire        mult_busy;    

execute_multiply execute_multiply_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .exe_reset              (exe_reset),
    
    .exe_cmd                (exe_cmd),            //input [6:0]
    .exe_is_8bit            (exe_is_8bit),        //input
    .exe_operand_16bit      (exe_operand_16bit),  //input
    .exe_operand_32bit      (exe_operand_32bit),  //input
    
    .src                    (src),                //input [31:0]
    .dst                    (dst),                //input [31:0]
    
    //output
    .mult_result            (mult_result),        //output [65:0]
    .mult_busy              (mult_busy),          //output
    
    .exe_mult_overflow      (exe_mult_overflow)   //output
);

//------------------------------------------------------------------------------
wire        div_busy;

wire [31:0] div_result_quotient;
wire [31:0] div_result_remainder;

execute_divide execute_divide_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .exe_reset              (exe_reset),
    .exe_ready              (exe_ready),
    
    .exe_is_8bit            (exe_is_8bit),          //input
    .exe_operand_16bit      (exe_operand_16bit),    //input
    .exe_operand_32bit      (exe_operand_32bit),    //input
    .exe_cmd                (exe_cmd),              //input [6:0]
    
    .eax                    (eax),                  //input [31:0]
    .edx                    (edx),                  //input [31:0]
    
    .src                    (src),                  //input [31:0]
    
    //output
    .div_busy               (div_busy),             //output
    
    .exe_div_exception      (exe_div_exception),    //output
    
    .div_result_quotient    (div_result_quotient),  //output [31:0]
    .div_result_remainder   (div_result_remainder)  //output [31:0]
);

//------------------------------------------------------------------------------

execute_commands execute_commands_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .exe_reset          (exe_reset),
    
    //general input
    .eax                (eax),              //input [31:0]
    .ecx                (ecx),              //input [31:0]
    .edx                (edx),              //input [31:0]
    .ebp                (ebp),              //input [31:0]
    .esp                (esp),              //input [31:0]
    
    .tr_base            (tr_base),          //input [31:0]
    
    .es                 (es),               //input [15:0]
    .cs                 (cs),               //input [15:0]
    .ss                 (ss),               //input [15:0]
    .ds                 (ds),               //input [15:0]
    .fs                 (fs),               //input [15:0]
    .gs                 (gs),               //input [15:0]
    .ldtr               (ldtr),             //input [15:0]
    .tr                 (tr),               //input [15:0]
    
    .cr2                (cr2),              //input [31:0]
    .cr3                (cr3),              //input [31:0]
    
    .dr0                (dr0),              //input [31:0]
    .dr1                (dr1),              //input [31:0]
    .dr2                (dr2),              //input [31:0]
    .dr3                (dr3),              //input [31:0]
    .dr6_bt             (dr6_bt),           //input
    .dr6_bs             (dr6_bs),           //input
    .dr6_bd             (dr6_bd),           //input
    .dr6_b12            (dr6_b12),          //input
    .dr6_breakpoints    (dr6_breakpoints),    //input [3:0]
    .dr7                (dr7),                //input [31:0]
    
    .cpl                (cpl),                //input [1:0]
    
    .real_mode          (real_mode),          //input
    .v8086_mode         (v8086_mode),         //input
    .protected_mode     (protected_mode),     //input
    
    .idflag                             (idflag),                           //input
    .acflag                             (acflag),                           //input
    .vmflag                             (vmflag),                           //input
    .rflag                              (rflag),                            //input
    .ntflag                             (ntflag),                           //input
    .iopl                               (iopl),                             //input [1:0]
    .oflag                              (oflag),                            //input
    .dflag                              (dflag),                            //input
    .iflag                              (iflag),                            //input
    .tflag                              (tflag),                            //input
    .sflag                              (sflag),                            //input
    .zflag                              (zflag),                            //input
    .aflag                              (aflag),                            //input
    .pflag                              (pflag),                            //input
    .cflag                              (cflag),                            //input
    
    .cr0_pg                             (cr0_pg),                           //input
    .cr0_cd                             (cr0_cd),                           //input
    .cr0_nw                             (cr0_nw),                           //input
    .cr0_am                             (cr0_am),                           //input
    .cr0_wp                             (cr0_wp),                           //input
    .cr0_ne                             (cr0_ne),                           //input
    .cr0_ts                             (cr0_ts),                           //input
    .cr0_em                             (cr0_em),                           //input
    .cr0_mp                             (cr0_mp),                           //input
    .cr0_pe                             (cr0_pe),                           //input
    
    .cs_limit                           (cs_limit),                         //input [31:0]
    .tr_limit                           (tr_limit),                         //input [31:0]
    .tr_cache                           (tr_cache),                         //input [63:0]
    .ss_cache                           (ss_cache),                         //input [63:0]
   
    .idtr_limit                         (idtr_limit),                       //input [15:0]
    .idtr_base                          (idtr_base),                        //input [15:0]
    
    .gdtr_limit                         (gdtr_limit),                       //input [15:0]
    .gdtr_base                          (gdtr_base),                        //input [31:0]
    
    //exception input
    .exc_push_error                     (exc_push_error),                   //input
    .exc_error_code                     (exc_error_code),                   //input [15:0]
    .exc_soft_int_ib                    (exc_soft_int_ib),                  //input
    .exc_soft_int                       (exc_soft_int),                     //input
    .exc_vector                         (exc_vector),                       //input [7:0]
    
    //exe input
    .exe_mutex_current                  (exe_mutex_current),                //input [10:0]
    
    .exe_eip                            (exe_eip),                          //input [31:0]
    .exe_extra                          (exe_extra),                        //input [31:0]
    .exe_linear                         (exe_linear),                       //input [31:0]
    .exe_cmd                            (exe_cmd),                          //input [6:0]
    .exe_cmdex                          (exe_cmdex),                        //input [3:0]
    .exe_decoder                        (exe_decoder),                      //input [39:0]
    .exe_modregrm_reg                   (exe_modregrm_reg),                 //input [2:0]
    .exe_address_effective              (exe_address_effective),            //input [31:0]
    .exe_is_8bit                        (exe_is_8bit),                      //input
    .exe_operand_16bit                  (exe_operand_16bit),                //input
    .exe_operand_32bit                  (exe_operand_32bit),                //input
    .exe_address_16bit                  (exe_address_16bit),                //input
    .exe_consumed                       (exe_consumed),                     //input [3:0]
    
    .src                                (src),                              //input [31:0]
    .dst                                (dst),                              //input [31:0]
    
    .exe_enter_offset                   (exe_enter_offset),                 //input [31:0]
    
    .exe_ready                          (exe_ready),                        //input
    
    //mult
    .mult_busy                          (mult_busy),                        //input
    .mult_result                        (mult_result),                      //input [31:0]
    
    //div
    .div_busy                           (div_busy),                         //input
    .exe_div_exception                  (exe_div_exception),                //input
    
    .div_result_quotient                (div_result_quotient),              //input [31:0]
    .div_result_remainder               (div_result_remainder),             //input [31:0]
    
    //shift
    .e_shift_no_write                   (e_shift_no_write),                 //input
    .e_shift_oszapc_update              (e_shift_oszapc_update),            //input
    .e_shift_cf_of_update               (e_shift_cf_of_update),             //input
    .e_shift_oflag                      (e_shift_oflag),                    //input
    .e_shift_cflag                      (e_shift_cflag),                    //input
    
    .e_shift_result                     (e_shift_result),                   //input [31:0]
    
    //tlbcheck
    .tlbcheck_do                        (tlbcheck_do),                      //output
    .tlbcheck_done                      (tlbcheck_done),                    //input
    .tlbcheck_page_fault                (tlbcheck_page_fault),              //input
    
    .tlbcheck_address                   (tlbcheck_address),                 //output [31:0]
    .tlbcheck_rw                        (tlbcheck_rw),                      //output
    
    //tlbflushsingle
    .tlbflushsingle_do                  (tlbflushsingle_do),                //output
    .tlbflushsingle_done                (tlbflushsingle_done),              //input
    
    .tlbflushsingle_address             (tlbflushsingle_address),           //output [31:0]
    
    //invd
    .invdcode_do                        (invdcode_do),                      //output
    .invdcode_done                      (invdcode_done),                    //input
    
    .invddata_do                        (invddata_do),                      //output
    .invddata_done                      (invddata_done),                    //input
    
    .wbinvddata_do                      (wbinvddata_do),                    //output
    .wbinvddata_done                    (wbinvddata_done),                  //input
    
    //pipeline input
    .wr_task_rpl                        (wr_task_rpl),                      //input [1:0]
    .wr_esp_prev                        (wr_esp_prev),                      //input [31:0]
    
    //global input
    .glob_descriptor                    (glob_descriptor),                  //input [63:0]
    .glob_descriptor_2                  (glob_descriptor_2),                //input [63:0]
    .glob_param_1                       (glob_param_1),                     //input [31:0]
    .glob_param_2                       (glob_param_2),                     //input [31:0]
    .glob_param_3                       (glob_param_3),                     //input [31:0]
    .glob_param_5                       (glob_param_5),                     //input [31:0]
    
    .glob_desc_base                     (glob_desc_base),                   //input [31:0]
    
    .glob_desc_limit                    (glob_desc_limit),                  //input [31:0]
    .glob_desc_2_limit                  (glob_desc_2_limit),                //input [31:0]
    
    //global set
    .exe_glob_descriptor_set                (exe_glob_descriptor_set),              //output
    .exe_glob_descriptor_value              (exe_glob_descriptor_value),            //output [63:0]
    
    .exe_glob_descriptor_2_set              (exe_glob_descriptor_2_set),            //output
    .exe_glob_descriptor_2_value            (exe_glob_descriptor_2_value),          //output [63:0]
    
    .exe_glob_param_1_set                   (exe_glob_param_1_set),                 //output
    .exe_glob_param_1_value                 (exe_glob_param_1_value),               //output [31:0]
    
    .exe_glob_param_2_set                   (exe_glob_param_2_set),                 //output
    .exe_glob_param_2_value                 (exe_glob_param_2_value),               //output [31:0]
    
    .exe_glob_param_3_set                   (exe_glob_param_3_set),                 //output
    .exe_glob_param_3_value                 (exe_glob_param_3_value),               //output [31:0]
    
    .dr6_bd_set                         (dr6_bd_set),                       //output
    
    //offset control
    .offset_ret_far_se                  (offset_ret_far_se),                //output
    .offset_new_stack                   (offset_new_stack),                 //output
    .offset_new_stack_minus             (offset_new_stack_minus),           //output
    .offset_new_stack_continue          (offset_new_stack_continue),        //output
    .offset_leave                       (offset_leave),                     //output
    .offset_pop                         (offset_pop),                       //output
    .offset_enter_last                  (offset_enter_last),                //output
    .offset_ret                         (offset_ret),                       //output
    .offset_iret_glob_param_4           (offset_iret_glob_param_4),         //output
    .offset_iret                        (offset_iret),                      //output
    .offset_ret_imm                     (offset_ret_imm),                   //output
    .offset_esp                         (offset_esp),                       //output
    .offset_call                        (offset_call),                      //output
    .offset_call_keep                   (offset_call_keep),                 //output
    .offset_call_int_same_first         (offset_call_int_same_first),       //output
    .offset_call_int_same_next          (offset_call_int_same_next),        //output
    .offset_int_real                    (offset_int_real),                  //output
    .offset_int_real_next               (offset_int_real_next),             //output
    .offset_task                        (offset_task),                      //output
    
    //task output
    .task_eip                           (task_eip),                         //output [31:0]

    //exe output
    .exe_waiting                        (exe_waiting),                      //output
    
    .exe_bound_fault                    (exe_bound_fault),                  //output
    .exe_trigger_gp_fault               (exe_trigger_gp_fault),             //output
    .exe_trigger_ts_fault               (exe_trigger_ts_fault),             //output
    .exe_trigger_ss_fault               (exe_trigger_ss_fault),             //output
    .exe_trigger_np_fault               (exe_trigger_np_fault),             //output
    .exe_trigger_pf_fault               (exe_trigger_pf_fault),             //output
    .exe_trigger_db_fault               (exe_trigger_db_fault),             //output
    .exe_trigger_nm_fault               (exe_trigger_nm_fault),             //output
    .exe_load_seg_gp_fault              (exe_load_seg_gp_fault),            //output
    .exe_load_seg_ss_fault              (exe_load_seg_ss_fault),            //output
    .exe_load_seg_np_fault              (exe_load_seg_np_fault),            //output
    
    .exe_error_code                     (exe_error_code),                   //output [15:0]
    
    .exe_result                         (exe_result),                       //output [31:0]
    .exe_result2                        (exe_result2),                      //output [31:0]
    .exe_result_push                    (exe_result_push),                  //output [31:0]
    .exe_result_signals                 (exe_result_signals),               //output [4:0]
    
    .exe_arith_index                    (exe_arith_index),                  //output [3:0]
    
    .exe_arith_sub_carry                (exe_arith_sub_carry),              //output
    .exe_arith_add_carry                (exe_arith_add_carry),              //output
    .exe_arith_adc_carry                (exe_arith_adc_carry),              //output
    .exe_arith_sbb_carry                (exe_arith_sbb_carry),              //output
    
    .exe_buffer                         (exe_buffer),                       //output [31:0]
    .exe_buffer_shifted                 (exe_buffer_shifted),               //output [463:0]
    
    //output local
    .exe_is_8bit_clear                  (exe_is_8bit_clear),                //output
    
    .exe_cmpxchg_switch                 (exe_cmpxchg_switch),               //output
    
    .exe_task_switch_finished           (exe_task_switch_finished),         //output
    
    .exe_eip_from_glob_param_2          (exe_eip_from_glob_param_2),        //output
    .exe_eip_from_glob_param_2_16bit    (exe_eip_from_glob_param_2_16bit),  //output
    
    //branch
    .exe_branch                         (exe_branch),                       //output
    .exe_branch_eip                     (exe_branch_eip)                    //output [31:0]
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, cs_cache[63:56], cs_cache[54:52], cs_cache[47:16], rd_decoder[87:24], rd_modregrm_imm[31:8], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
