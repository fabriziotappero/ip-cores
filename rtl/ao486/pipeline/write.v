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

module write(
    input               clk,
    input               rst_n,
    
    input               exe_reset,
    input               wr_reset,
    
    //global input
    input       [63:0]  glob_descriptor,
    input       [63:0]  glob_descriptor_2,
    input       [31:0]  glob_desc_base,
    input       [31:0]  glob_desc_limit,
    
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_2,
    input       [31:0]  glob_param_3,
    input       [31:0]  glob_param_4,
    input       [31:0]  glob_param_5,

    //general input
    input       [31:0]  eip,
    
    //registers output
    output      [31:0]  gdtr_base,
    output      [15:0]  gdtr_limit,
    
    output      [31:0]  idtr_base,
    output      [15:0]  idtr_limit,
    
    //pipeline input
    input       [31:0]  exe_buffer,
    input       [463:0] exe_buffer_shifted,
    
    input               dr6_bd_set,
    
    //interrupt input
    input               interrupt_do,
    
    //exception input
    input               exc_init,
    input               exc_set_rflag,
    input               exc_debug_start,
    input               exc_pf_read,
    input               exc_pf_write,
    input               exc_pf_code,
    input               exc_pf_check,
    input               exc_restore_esp,
    input               exc_push_error,
    input       [31:0]  exc_eip,
    
    //output
    output              real_mode,
    output              v8086_mode,
    output              protected_mode,
    
    output      [1:0]   cpl,
    
    output              io_allow_check_needed,
    
    output      [2:0]   debug_len0,
    output      [2:0]   debug_len1,
    output      [2:0]   debug_len2,
    output      [2:0]   debug_len3,
    
    //wr output
    output              wr_is_front,
    
    output reg          wr_interrupt_possible,
    output              wr_string_in_progress_final,
    output reg          wr_is_esp_speculative,
    
    output reg  [10:0]  wr_mutex,
    
    output reg  [31:0]  wr_stack_offset,
    output reg  [31:0]  wr_esp_prev,
        
    output      [1:0]   wr_task_rpl,
    
    output reg  [3:0]   wr_consumed,
    
    //software interrupt
    output              wr_int,
    output              wr_int_soft_int,
    output              wr_int_soft_int_ib,
    output      [7:0]   wr_int_vector,

    output              wr_exception_external_set,
    output              wr_exception_finished,
    
    output      [15:0]  wr_error_code,
    
    //wr exception
    output reg          wr_debug_init,
    
    output              wr_new_push_ss_fault,
    output              wr_string_es_fault,
    output              wr_push_ss_fault,
    
    //eip control
    output reg  [31:0]  wr_eip,
    
    //reset request
    output              wr_req_reset_pr,
    output              wr_req_reset_dec,
    output              wr_req_reset_micro,
    output              wr_req_reset_rd,
    output              wr_req_reset_exe,
    
    //memory page fault
    input       [31:0]  tlb_code_pf_cr2,
    input       [31:0]  tlb_write_pf_cr2,
    input       [31:0]  tlb_read_pf_cr2,
    input       [31:0]  tlb_check_pf_cr2,
    
    //memory write
    output              write_do,
    input               write_done,
    input               write_page_fault,
    input               write_ac_fault,
    
    output      [1:0]   write_cpl,
    output      [31:0]  write_address,
    output      [2:0]   write_length,
    output              write_lock,
    output              write_rmw,
    output      [31:0]  write_data,
    
    //flush tlb
    output              tlbflushall_do,
    
    //io write
    output              io_write_do,
    output      [15:0]  io_write_address,
    output      [2:0]   io_write_length,
    output      [31:0]  io_write_data,
    input               io_write_done,
    
    //global write
    output              wr_glob_param_1_set,
    output      [31:0]  wr_glob_param_1_value,
    
    output              wr_glob_param_3_set,
    output      [31:0]  wr_glob_param_3_value,
    
    output              wr_glob_param_4_set,
    output      [31:0]  wr_glob_param_4_value,
    
    //registers output
    output      [31:0]  eax,
    output      [31:0]  ebx,
    output      [31:0]  ecx,
    output      [31:0]  edx,
    output      [31:0]  esi,
    output      [31:0]  edi,
    output      [31:0]  ebp,
    output      [31:0]  esp,

    output              cr0_pe,
    output              cr0_mp,
    output              cr0_em,
    output              cr0_ts,
    output              cr0_ne,
    output              cr0_wp,
    output              cr0_am,
    output              cr0_nw,
    output              cr0_cd,
    output              cr0_pg,
    
    output      [31:0]  cr2,
    output      [31:0]  cr3,
    
    output              cflag,
    output              pflag,
    output              aflag,
    output              zflag,
    output              sflag,
    output              oflag,
    output              tflag,
    output              iflag,
    output              dflag,
    output      [1:0]   iopl,
    output              ntflag,
    output              rflag,
    output              vmflag,
    output              acflag,
    output              idflag,
    
    output      [31:0]  dr0,
    output      [31:0]  dr1,
    output      [31:0]  dr2,
    output      [31:0]  dr3,
    output      [3:0]   dr6_breakpoints,
    output              dr6_b12,
    output              dr6_bd,
    output              dr6_bs,
    output              dr6_bt,
    output      [31:0]  dr7,
    
    output      [15:0]  es,
    output      [15:0]  ds,
    output      [15:0]  ss,
    output      [15:0]  fs,
    output      [15:0]  gs,
    output      [15:0]  cs,
    output      [15:0]  ldtr,
    output      [15:0]  tr,

    output      [63:0]  es_cache,
    output      [63:0]  ds_cache,
    output      [63:0]  ss_cache,
    output      [63:0]  fs_cache,
    output      [63:0]  gs_cache,
    output      [63:0]  cs_cache,
    output      [63:0]  ldtr_cache,
    output      [63:0]  tr_cache,

    output              es_cache_valid,
    output              ds_cache_valid,
    output              ss_cache_valid,
    output              fs_cache_valid,
    output              gs_cache_valid,
    output              cs_cache_valid,
    output              ldtr_cache_valid,
    output              tr_cache_valid,
    
    //pipeline wr
    output              wr_busy,
    input               exe_ready,
    
    input       [39:0]  exe_decoder,
    input       [31:0]  exe_eip_final,
    input               exe_operand_32bit,
    input               exe_address_32bit,
    input       [1:0]   exe_prefix_group_1_rep,
    input               exe_prefix_group_1_lock,
    input       [3:0]   exe_consumed_final,
    input               exe_is_8bit_final,
    input       [6:0]   exe_cmd,
    input       [3:0]   exe_cmdex,
    input       [10:0]  exe_mutex,
    input               exe_dst_is_reg,
    input               exe_dst_is_rm,
    input               exe_dst_is_memory,
    input               exe_dst_is_eax,
    input               exe_dst_is_edx_eax,
    input               exe_dst_is_implicit_reg,
    input       [31:0]  exe_linear,
    input       [3:0]   exe_debug_read,
    
    input       [31:0]  exe_result,
    input       [31:0]  exe_result2,
    input       [31:0]  exe_result_push,
    input       [4:0]   exe_result_signals,
    
    input       [3:0]   exe_arith_index,
    
    input               exe_arith_sub_carry,
    input               exe_arith_add_carry,
    input               exe_arith_adc_carry,
    input               exe_arith_sbb_carry,
    
    input       [31:0]  src_final,
    input       [31:0]  dst_final,
    
    input               exe_mult_overflow,
    input       [31:0]  exe_stack_offset   
);

//------------------------------------------------------------------------------

wire [31:0] tr_base;

wire [31:0] cs_base;
wire [31:0] cs_limit;

wire [31:0] es_base;
wire [31:0] es_limit;

wire [31:0] ss_base;
wire [31:0] ss_limit;

wire [31:0] ldtr_base;

assign tr_base     = {   tr_cache[63:56],   tr_cache[39:16] };

assign cs_base     = { cs_cache[63:56], cs_cache[39:16] };
assign cs_limit    = cs_cache[`DESC_BIT_G]? { cs_cache[51:48], cs_cache[15:0], 12'hFFF } : { 12'd0, cs_cache[51:48], cs_cache[15:0] };

assign es_base     = { es_cache[63:56], es_cache[39:16] };
assign es_limit    = es_cache[`DESC_BIT_G]? { es_cache[51:48], es_cache[15:0], 12'hFFF } : { 12'd0, es_cache[51:48], es_cache[15:0] };

assign ss_base     = { ss_cache[63:56], ss_cache[39:16] };
assign ss_limit    = ss_cache[`DESC_BIT_G]? { ss_cache[51:48], ss_cache[15:0], 12'hFFF } : { 12'd0, ss_cache[51:48], ss_cache[15:0] };

assign ldtr_base   = { ldtr_cache[63:56], ldtr_cache[39:16] };

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

wire wr_ready;
wire w_load;

wire wr_waiting;

wire wr_one_cycle_wait;

//------------------------------------------------------------------------------

assign wr_ready = ~(wr_waiting) && wr_cmd != `CMD_NULL; //NOTE: do not use: wr_mutex[`MUTEX_ACTIVE_BIT];

assign wr_busy = wr_waiting || exc_init || wr_debug_prepare || wr_interrupt_possible_prepare || (wr_one_cycle_wait && wr_first_cycle);

assign w_load = exe_ready;

assign wr_is_front = wr_cmd != `CMD_NULL;

//------------------------------------------------------------------------------

wire wr_finished;

wire wr_not_finished;
wire wr_hlt_in_progress;
wire wr_inhibit_interrupts_and_debug;
wire wr_inhibit_interrupts;
wire iflag_to_reg;

wire wr_debug_prepare;
wire wr_interrupt_possible_prepare;

wire wr_clear_rflag;

wire wr_string_in_progress;
reg  wr_string_in_progress_last;

assign wr_finished =
    wr_ready && (~(wr_not_finished) || (wr_hlt_in_progress && iflag_to_reg && interrupt_do) || wr_string_in_progress);

assign wr_interrupt_possible_prepare =
    interrupt_do &&
    wr_ready && (~(wr_not_finished) || wr_hlt_in_progress || wr_string_in_progress) &&
    ~(wr_debug_prepare) &&
    ~(wr_inhibit_interrupts_and_debug) && ~(wr_inhibit_interrupts) && iflag_to_reg;

assign wr_clear_rflag = wr_finished && wr_eip <= cs_limit && ~(exc_init) && ~(wr_debug_prepare) && ~(wr_interrupt_possible_prepare);
    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_interrupt_possible <= `FALSE;
    else if(wr_reset)   wr_interrupt_possible <= `FALSE;
    else                wr_interrupt_possible <= wr_interrupt_possible_prepare;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_debug_init <= `FALSE;
    else                wr_debug_init <= wr_debug_prepare;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_string_in_progress_last <= `FALSE;
    else                wr_string_in_progress_last <= wr_string_in_progress;
end

assign wr_string_in_progress_final = wr_string_in_progress || ((wr_debug_init || wr_interrupt_possible) && wr_string_in_progress_last);

//------------------------------------------------------------------------------

reg wr_first_cycle;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_first_cycle <= `FALSE;
    else if(wr_reset)   wr_first_cycle <= `FALSE;
    else if(w_load)     wr_first_cycle <= `TRUE;
    else                wr_first_cycle <= `FALSE;
end

//------------------------------------------------------------------------------

reg [15:0]  wr_decoder;
reg         wr_operand_32bit;
reg         wr_address_32bit;
reg [1:0]   wr_prefix_group_1_rep;
reg         wr_prefix_group_1_lock;
reg         wr_is_8bit;
reg [6:0]   wr_cmd;
reg [3:0]   wr_cmdex;
reg         wr_dst_is_reg;
reg         wr_dst_is_rm;
reg         wr_dst_is_memory;
reg         wr_dst_is_eax;
reg         wr_dst_is_edx_eax;
reg         wr_dst_is_implicit_reg;
reg [31:0]  wr_linear;

reg [31:0]  result;
reg [31:0]  result2;
reg [4:0]   result_signals;
reg [31:0]  result_push;

reg [3:0]   wr_arith_index;
reg [31:0]  wr_src;
reg [31:0]  wr_dst;

reg         wr_arith_add_carry;
reg         wr_arith_adc_carry;
reg         wr_arith_sub_carry;
reg         wr_arith_sbb_carry;
reg         wr_mult_overflow;

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_decoder              <= 16'd0;     else if(w_load) wr_decoder              <= exe_decoder[15:0];        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_eip                  <= 32'd0;     else if(w_load) wr_eip                  <= exe_eip_final;            end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_operand_32bit        <= `FALSE;    else if(w_load) wr_operand_32bit        <= exe_operand_32bit;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_address_32bit        <= `FALSE;    else if(w_load) wr_address_32bit        <= exe_address_32bit;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_prefix_group_1_rep   <= 2'd0;      else if(w_load) wr_prefix_group_1_rep   <= exe_prefix_group_1_rep;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_prefix_group_1_lock  <= `FALSE;    else if(w_load) wr_prefix_group_1_lock  <= exe_prefix_group_1_lock;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_consumed             <= 4'd0;      else if(w_load) wr_consumed             <= exe_consumed_final;       end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_is_8bit              <= `FALSE;    else if(w_load) wr_is_8bit              <= exe_is_8bit_final;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_cmdex                <= 4'd0;      else if(w_load) wr_cmdex                <= exe_cmdex;                end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst_is_reg           <= `FALSE;    else if(w_load) wr_dst_is_reg           <= exe_dst_is_reg;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst_is_rm            <= `FALSE;    else if(w_load) wr_dst_is_rm            <= exe_dst_is_rm;            end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst_is_memory        <= `FALSE;    else if(w_load) wr_dst_is_memory        <= exe_dst_is_memory;        end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst_is_eax           <= `FALSE;    else if(w_load) wr_dst_is_eax           <= exe_dst_is_eax;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst_is_edx_eax       <= `FALSE;    else if(w_load) wr_dst_is_edx_eax       <= exe_dst_is_edx_eax;       end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst_is_implicit_reg  <= `FALSE;    else if(w_load) wr_dst_is_implicit_reg  <= exe_dst_is_implicit_reg;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_linear               <= 32'd0;     else if(w_load) wr_linear               <= exe_linear;               end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) result                  <= 32'd0;     else if(w_load) result                  <= exe_result;               end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) result2                 <= 32'd0;     else if(w_load) result2                 <= exe_result2;              end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) result_push             <= 32'd0;     else if(w_load) result_push             <= exe_result_push;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) result_signals          <= 5'd0;      else if(w_load) result_signals          <= exe_result_signals;       end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_arith_index          <= 4'd0;      else if(w_load) wr_arith_index          <= exe_arith_index;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_src                  <= 32'd0;     else if(w_load) wr_src                  <= src_final;                end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_dst                  <= 32'd0;     else if(w_load) wr_dst                  <= dst_final;                end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_arith_sub_carry      <= 1'd0;      else if(w_load) wr_arith_sub_carry      <= exe_arith_sub_carry;      end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_arith_add_carry      <= 1'd0;      else if(w_load) wr_arith_add_carry      <= exe_arith_add_carry;      end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_arith_adc_carry      <= 1'd0;      else if(w_load) wr_arith_adc_carry      <= exe_arith_adc_carry;      end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_arith_sbb_carry      <= 1'd0;      else if(w_load) wr_arith_sbb_carry      <= exe_arith_sbb_carry;      end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_mult_overflow        <= 1'd0;      else if(w_load) wr_mult_overflow        <= exe_mult_overflow;        end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) wr_stack_offset         <= 32'd0;     else if(w_load) wr_stack_offset         <= exe_stack_offset;         end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_cmd <= `CMD_NULL;
    else if(wr_reset)   wr_cmd <= `CMD_NULL;
    else if(w_load)     wr_cmd <= exe_cmd;
    else if(wr_ready)   wr_cmd <= `CMD_NULL;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       wr_mutex <= 11'd0;
    else if(wr_reset)                                       wr_mutex <= 11'd0;
    else if(w_load)                                         wr_mutex <= exe_mutex;
    else if(wr_ready && ~(wr_interrupt_possible_prepare))   wr_mutex <= 11'd0;
end

//------------------------------------------------------------------------------

wire wr_operand_16bit;
wire wr_address_16bit;

wire [1:0] wr_modregrm_mod;
wire [2:0] wr_modregrm_reg;
wire [2:0] wr_modregrm_rm;

assign wr_operand_16bit = ~(wr_operand_32bit);
assign wr_address_16bit = ~(wr_address_32bit);

assign wr_modregrm_mod = wr_decoder[15:14];
assign wr_modregrm_reg = wr_decoder[13:11];
assign wr_modregrm_rm  = wr_decoder[10:8];

//------------------------------------------------------------------------------

wire [31:0] wr_descriptor_touch_offset;
wire [31:0] wr_descriptor_busy_tss_offset;

assign wr_descriptor_touch_offset =
    (glob_param_1[2] == 1'b0)?   gdtr_base + { 16'd0, glob_param_1[15:3], 3'd0 } + 32'd5 :
                                 ldtr_base + { 16'd0, glob_param_1[15:3], 3'd0 } + 32'd5;
                                
assign wr_descriptor_busy_tss_offset =
                                gdtr_base + { 16'd0, glob_param_1[15:3], 3'd0 } + 32'd4;

//------------------------------------------------------------------------------ write memory

wire memory_write_system;

wire        write_for_wr_ready;
wire [31:0] wr_string_es_linear;

assign memory_write_system =
    write_system_touch || write_system_busy_tss || write_system_dword || write_system_word || write_rmw_system_dword;

assign write_cpl = 
    (write_new_stack_virtual)?      glob_descriptor_2[`DESC_BITS_DPL] :
    (memory_write_system)?          2'd0 :
                                    cpl;

assign write_lock = wr_prefix_group_1_lock;

assign write_rmw = write_rmw_virtual || write_rmw_system_dword;

assign write_address =
    (write_string_es_virtual)?                  wr_string_es_linear :
    (write_stack_virtual)?                      wr_push_linear :
    (write_new_stack_virtual)?                  wr_new_push_linear :
    (write_system_touch)?                       wr_descriptor_touch_offset :
    (write_system_busy_tss)?                    wr_descriptor_busy_tss_offset :
    (write_system_dword || write_system_word)?  wr_system_linear :
                                                wr_linear; //used by write_rmw_system_dword

assign write_data =
    (write_stack_virtual || write_string_es_virtual || write_new_stack_virtual)?    result_push :
    (write_system_touch)?                                                           { 24'd0, glob_descriptor[47:41], 1'b1 } :
    (write_system_busy_tss)?                                                        glob_descriptor[63:32] | 32'h00000200 :
    (write_rmw_system_dword || write_system_dword || write_system_word)?            wr_system_dword :
                                                                                    result;

assign write_length =
    (write_stack_virtual || write_new_stack_virtual)?   wr_push_length :
    (write_system_touch)?       3'd1 :
    (write_system_busy_tss)?    3'd4 :
    (write_length_word)?        3'd2 :
    (write_rmw_system_dword)?   3'd4 :
    (write_system_dword)?       3'd4 :
    (write_system_word)?        3'd2 :
    (write_length_dword)?       3'd4 :
    wr_is_8bit?                 3'd1 : //last 3: write_string_es_virtual also
    wr_operand_16bit?           3'd2 :
                                3'd4;

assign write_do = ~(wr_reset) && ~(write_done) && ~(write_page_fault) && ~(write_ac_fault) &&
    (write_rmw_virtual || write_virtual || write_stack_virtual || write_new_stack_virtual ||
     write_string_es_virtual || memory_write_system);


assign write_for_wr_ready = write_done && ~(write_page_fault) && ~(write_ac_fault);

//------------------------------------------------------------------------------ write io

wire write_io_for_wr_ready;

assign io_write_do      = write_io;
assign io_write_address = glob_param_1[15:0];
assign io_write_length  = (wr_is_8bit)? 3'd1 : (wr_operand_16bit)? 3'd2 : 3'd4;
assign io_write_data    = result_push;    

assign write_io_for_wr_ready = io_write_done;

//------------------------------------------------------------------------------ esp speculative

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               wr_esp_prev <= 32'd0;
    else if(wr_make_esp_speculative && ~(wr_is_esp_speculative))    wr_esp_prev <= esp;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   wr_is_esp_speculative <= `FALSE;
    else if(wr_reset || exe_reset)      wr_is_esp_speculative <= `FALSE;
    else if(wr_make_esp_commit)         wr_is_esp_speculative <= `FALSE;
    else if(wr_make_esp_speculative)    wr_is_esp_speculative <= `TRUE;
end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, glob_descriptor_2[63:47], glob_descriptor_2[44:0], exe_decoder[39:16], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

wire        write_stack_virtual;
wire        write_new_stack_virtual;
wire        wr_push_length_word;
wire        wr_push_length_dword;
wire        wr_push_ss_fault_check;
wire        wr_new_push_ss_fault_check;
wire        wr_make_esp_speculative;
wire        wr_make_esp_commit;

wire        wr_validate_seg_regs;

wire [15:0] wr_seg_sel;
wire        wr_seg_cache_valid;
wire [1:0]  wr_seg_rpl;
wire [63:0] wr_seg_cache_mask;

wire        write_seg_cache;
wire        write_seg_sel;
wire        write_seg_cache_valid;
wire        write_seg_rpl;

wire        wr_debug_trap_clear;
wire        wr_debug_task_trigger;

wire        write_rmw_virtual;
wire        write_virtual;
wire        write_rmw_system_dword;
wire        write_system_word;
wire        write_system_dword;
wire        write_system_busy_tss;
wire        write_system_touch;

wire        write_length_word;
wire        write_length_dword;

wire [31:0] wr_system_dword;
wire [31:0] wr_system_linear;

wire        write_regrm;
wire        write_eax;
wire        wr_regrm_word;
wire        wr_regrm_dword;

wire        wr_string_gp_fault_check;
wire        write_string_es_virtual;

wire        write_io;

//registers
wire [1:0]  es_rpl;
wire [1:0]  ds_rpl;
wire [1:0]  ss_rpl;
wire [1:0]  fs_rpl;
wire [1:0]  gs_rpl;
wire [1:0]  cs_rpl;
wire [1:0]  ldtr_rpl;
wire [1:0]  tr_rpl;

wire [31:0] eax_to_reg;
wire [31:0] ebx_to_reg;
wire [31:0] ecx_to_reg;
wire [31:0] edx_to_reg;
wire [31:0] esi_to_reg;
wire [31:0] edi_to_reg;
wire [31:0] ebp_to_reg;
wire [31:0] esp_to_reg;
wire        cr0_pe_to_reg;
wire        cr0_mp_to_reg;
wire        cr0_em_to_reg;
wire        cr0_ts_to_reg;
wire        cr0_ne_to_reg;
wire        cr0_wp_to_reg;
wire        cr0_am_to_reg;
wire        cr0_nw_to_reg;
wire        cr0_cd_to_reg;
wire        cr0_pg_to_reg;
wire [31:0] cr2_to_reg;
wire [31:0] cr3_to_reg;
wire        cflag_to_reg;
wire        pflag_to_reg;
wire        aflag_to_reg;
wire        zflag_to_reg;
wire        sflag_to_reg;
wire        oflag_to_reg;
wire        tflag_to_reg;
//wire        iflag_to_reg; --declared above
wire        dflag_to_reg;
wire [1:0]  iopl_to_reg;
wire        ntflag_to_reg;
wire        rflag_to_reg;
wire        vmflag_to_reg;
wire        acflag_to_reg;
wire        idflag_to_reg;
wire [31:0] gdtr_base_to_reg;
wire [15:0] gdtr_limit_to_reg;
wire [31:0] idtr_base_to_reg;
wire [15:0] idtr_limit_to_reg;
wire [31:0] dr0_to_reg;
wire [31:0] dr1_to_reg;
wire [31:0] dr2_to_reg;
wire [31:0] dr3_to_reg;
wire [3:0]  dr6_breakpoints_to_reg;
wire        dr6_b12_to_reg;
wire        dr6_bd_to_reg;
wire        dr6_bs_to_reg;
wire        dr6_bt_to_reg;
wire [31:0] dr7_to_reg;
wire [15:0] es_to_reg;
wire [15:0] ds_to_reg;
wire [15:0] ss_to_reg;
wire [15:0] fs_to_reg;
wire [15:0] gs_to_reg;
wire [15:0] cs_to_reg;
wire [15:0] ldtr_to_reg;
wire [15:0] tr_to_reg;
wire [63:0] es_cache_to_reg;
wire [63:0] ds_cache_to_reg;
wire [63:0] ss_cache_to_reg;
wire [63:0] fs_cache_to_reg;
wire [63:0] gs_cache_to_reg;
wire [63:0] cs_cache_to_reg;
wire [63:0] ldtr_cache_to_reg;
wire [63:0] tr_cache_to_reg;
wire        es_cache_valid_to_reg;
wire        ds_cache_valid_to_reg;
wire        ss_cache_valid_to_reg;
wire        fs_cache_valid_to_reg;
wire        gs_cache_valid_to_reg;
wire        cs_cache_valid_to_reg;
wire        ldtr_cache_valid_to_reg;
wire [1:0]  es_rpl_to_reg;
wire [1:0]  ds_rpl_to_reg;
wire [1:0]  ss_rpl_to_reg;
wire [1:0]  fs_rpl_to_reg;
wire [1:0]  gs_rpl_to_reg;
wire [1:0]  cs_rpl_to_reg;
wire [1:0]  ldtr_rpl_to_reg;
wire [1:0]  tr_rpl_to_reg;

//stack
wire [31:0] wr_stack_esp;
wire [31:0] wr_push_linear;
wire [31:0] wr_new_stack_esp;
wire [31:0] wr_new_push_linear;
wire [2:0]  wr_push_length;

//string
wire [31:0] wr_esi_final;
wire [31:0] wr_edi_final;
wire [31:0] wr_ecx_final;

wire        wr_string_ignore;

wire        wr_zflag_result;
wire        wr_string_zf_finish;
wire        wr_string_finish;

write_commands write_commands_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //general input
    .real_mode              (real_mode),                //input
    .v8086_mode             (v8086_mode),               //input
    .protected_mode         (protected_mode),           //input
    
    .cpl                    (cpl),                      //input [1:0]
    
    .tr_base                (tr_base),                  //input [31:0]
    
    .eip                    (eip),                      //input [31:0]
    
    .io_allow_check_needed  (io_allow_check_needed),    //input
    
    .exc_push_error         (exc_push_error),           //input
    .exc_eip                (exc_eip),                  //input [31:0]
    
    //global input
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    .glob_desc_base                (glob_desc_base),                //input [31:0]
                                   
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    .glob_param_2                  (glob_param_2),                  //input [31:0]
    .glob_param_3                  (glob_param_3),                  //input [31:0]
    .glob_param_4                  (glob_param_4),                  //input [31:0]
    .glob_param_5                  (glob_param_5),                  //input [31:0]

    //write
    .wr_ready                      (wr_ready),                      //input
    .wr_decoder                    (wr_decoder),                    //input [15:0]
    .wr_cmd                        (wr_cmd),                        //input [6:0]
    .wr_cmdex                      (wr_cmdex),                      //input [3:0]
    .wr_is_8bit                    (wr_is_8bit),                    //input
    .wr_address_16bit              (wr_address_16bit),              //input
    .wr_operand_16bit              (wr_operand_16bit),              //input
    .wr_operand_32bit              (wr_operand_32bit),              //input
    .wr_mult_overflow              (wr_mult_overflow),              //input
    .wr_arith_index                (wr_arith_index),                //input [3:0]
    .wr_modregrm_mod               (wr_modregrm_mod),               //input [1:0]
    .wr_modregrm_reg               (wr_modregrm_reg),               //input [2:0]
    .wr_modregrm_rm                (wr_modregrm_rm),                //input [2:0]
    .wr_dst_is_memory              (wr_dst_is_memory),              //input
    .wr_dst_is_reg                 (wr_dst_is_reg),                 //input
    .wr_dst_is_rm                  (wr_dst_is_rm),                  //input
    .wr_dst_is_implicit_reg        (wr_dst_is_implicit_reg),        //input
    .wr_dst_is_edx_eax             (wr_dst_is_edx_eax),             //input
    .wr_dst_is_eax                 (wr_dst_is_eax),                 //input
    
    .wr_arith_add_carry            (wr_arith_add_carry),            //input
    .wr_arith_adc_carry            (wr_arith_adc_carry),            //input
    .wr_arith_sbb_carry            (wr_arith_sbb_carry),            //input
    .wr_arith_sub_carry            (wr_arith_sub_carry),            //input
    
    .result                        (result),                        //input [31:0]
    .result2                       (result2),                       //input [31:0]

    .wr_src                        (wr_src),                        //input [31:0]
    .wr_dst                        (wr_dst),                        //input [31:0]
    .result_signals                (result_signals),                //input [4:0]
    .result_push                   (result_push),                   //input [31:0]

    .exe_buffer                    (exe_buffer),                    //input [31:0]
    .exe_buffer_shifted            (exe_buffer_shifted),            //input [463:0]
    
    //global output
    .wr_glob_param_1_set              (wr_glob_param_1_set),            //output
    .wr_glob_param_1_value            (wr_glob_param_1_value),          //output [31:0]

    .wr_glob_param_3_set              (wr_glob_param_3_set),            //output
    .wr_glob_param_3_value            (wr_glob_param_3_value),          //output [31:0]

    .wr_glob_param_4_set              (wr_glob_param_4_set),            //output
    .wr_glob_param_4_value            (wr_glob_param_4_value),          //output [31:0]

    //debug output
    .wr_debug_trap_clear     (wr_debug_trap_clear),                     //output
    .wr_debug_task_trigger   (wr_debug_task_trigger),                   //output
    
    //exception
    .wr_int                          (wr_int),                          //output
    .wr_int_soft_int                 (wr_int_soft_int),                 //output
    .wr_int_soft_int_ib              (wr_int_soft_int_ib),              //output
    .wr_int_vector                   (wr_int_vector),                   //output [7:0]

    .wr_exception_external_set       (wr_exception_external_set),       //output
    .wr_exception_finished           (wr_exception_finished),           //output
    
    .wr_inhibit_interrupts           (wr_inhibit_interrupts),           //output
    .wr_inhibit_interrupts_and_debug (wr_inhibit_interrupts_and_debug), //output
    
    //memory
    .write_for_wr_ready            (write_for_wr_ready),            //input

    .write_rmw_virtual             (write_rmw_virtual),             //output
    .write_virtual                 (write_virtual),                 //output
    .write_rmw_system_dword        (write_rmw_system_dword),        //output
    .write_system_word             (write_system_word),             //output
    .write_system_dword            (write_system_dword),            //output
    .write_system_busy_tss         (write_system_busy_tss),         //output
    .write_system_touch            (write_system_touch),            //output

    .write_length_word             (write_length_word),             //output
    .write_length_dword            (write_length_dword),            //output

    .wr_system_dword               (wr_system_dword),               //output [31:0]
    .wr_system_linear              (wr_system_linear),              //output [31:0]

    
    //write regrm
    .write_regrm                   (write_regrm),                   //output
    .write_eax                     (write_eax),                     //output
    .wr_regrm_word                 (wr_regrm_word),                 //output
    .wr_regrm_dword                (wr_regrm_dword),                //output

    
    //write output
    .wr_not_finished               (wr_not_finished),               //output
    .wr_hlt_in_progress            (wr_hlt_in_progress),            //output
    .wr_string_in_progress         (wr_string_in_progress),         //output
    .wr_waiting                    (wr_waiting),                    //output

    .wr_req_reset_pr               (wr_req_reset_pr),               //output
    .wr_req_reset_dec              (wr_req_reset_dec),              //output
    .wr_req_reset_micro            (wr_req_reset_micro),            //output
    .wr_req_reset_rd               (wr_req_reset_rd),               //output
    .wr_req_reset_exe              (wr_req_reset_exe),              //output

    .wr_zflag_result               (wr_zflag_result),               //output
    
    .wr_task_rpl                   (wr_task_rpl),                   //output [1:0]
    
    .wr_one_cycle_wait             (wr_one_cycle_wait),             //output

    //stack
    .write_stack_virtual           (write_stack_virtual),           //output
    .write_new_stack_virtual       (write_new_stack_virtual),       //output

    .wr_push_length_word           (wr_push_length_word),           //output
    .wr_push_length_dword          (wr_push_length_dword),          //output

    .wr_stack_esp                  (wr_stack_esp),                  //input [31:0]
    .wr_new_stack_esp              (wr_new_stack_esp),              //input [31:0]

                                   
    .wr_push_ss_fault_check        (wr_push_ss_fault_check),        //output
    .wr_push_ss_fault              (wr_push_ss_fault),              //input

    .wr_new_push_ss_fault_check    (wr_new_push_ss_fault_check),    //output
    .wr_new_push_ss_fault          (wr_new_push_ss_fault),          //input

    .wr_error_code                 (wr_error_code),                 //output [15:0]

    .wr_make_esp_speculative       (wr_make_esp_speculative),       //output
    .wr_make_esp_commit            (wr_make_esp_commit),            //output
    
    //string
    .wr_string_ignore              (wr_string_ignore),              //input
    .wr_prefix_group_1_rep         (wr_prefix_group_1_rep),         //input [1:0]
    .wr_string_zf_finish           (wr_string_zf_finish),           //input
    .wr_string_es_fault            (wr_string_es_fault),            //input
    .wr_string_finish              (wr_string_finish),              //input

    .wr_esi_final                  (wr_esi_final),                  //input [31:0]
    .wr_edi_final                  (wr_edi_final),                  //input [31:0]
    .wr_ecx_final                  (wr_ecx_final),                  //input [31:0]

    .wr_string_gp_fault_check      (wr_string_gp_fault_check),      //output
    .write_string_es_virtual       (write_string_es_virtual),       //output

    //io write
    .write_io                      (write_io),                      //output
    .write_io_for_wr_ready         (write_io_for_wr_ready),         //input
    
    //segment
    .wr_seg_sel                    (wr_seg_sel),                    //output [15:0]
    .wr_seg_cache_valid            (wr_seg_cache_valid),            //output
    .wr_seg_rpl                    (wr_seg_rpl),                    //output [1:0]
    .wr_seg_cache_mask             (wr_seg_cache_mask),             //output [63:0]

    .write_seg_cache               (write_seg_cache),               //output
    .write_seg_sel                 (write_seg_sel),                 //output
    .write_seg_cache_valid         (write_seg_cache_valid),         //output
    .write_seg_rpl                 (write_seg_rpl),                 //output

    .wr_validate_seg_regs          (wr_validate_seg_regs),          //output

    //flush tlb
    .tlbflushall_do                (tlbflushall_do),                //output
    
    //---------------------
    
    .eax_to_reg                    (eax_to_reg),                    //output [31:0]
    .ebx_to_reg                    (ebx_to_reg),                    //output [31:0]
    .ecx_to_reg                    (ecx_to_reg),                    //output [31:0]
    .edx_to_reg                    (edx_to_reg),                    //output [31:0]
    .esi_to_reg                    (esi_to_reg),                    //output [31:0]
    .edi_to_reg                    (edi_to_reg),                    //output [31:0]
    .ebp_to_reg                    (ebp_to_reg),                    //output [31:0]
    .esp_to_reg                    (esp_to_reg),                    //output [31:0]
    .cr0_pe_to_reg                 (cr0_pe_to_reg),                 //output
    .cr0_mp_to_reg                 (cr0_mp_to_reg),                 //output
    .cr0_em_to_reg                 (cr0_em_to_reg),                 //output
    .cr0_ts_to_reg                 (cr0_ts_to_reg),                 //output
    .cr0_ne_to_reg                 (cr0_ne_to_reg),                 //output
    .cr0_wp_to_reg                 (cr0_wp_to_reg),                 //output
    .cr0_am_to_reg                 (cr0_am_to_reg),                 //output
    .cr0_nw_to_reg                 (cr0_nw_to_reg),                 //output
    .cr0_cd_to_reg                 (cr0_cd_to_reg),                 //output
    .cr0_pg_to_reg                 (cr0_pg_to_reg),                 //output
    .cr2_to_reg                    (cr2_to_reg),                    //output [31:0]
    .cr3_to_reg                    (cr3_to_reg),                    //output [31:0]
    .cflag_to_reg                  (cflag_to_reg),                  //output
    .pflag_to_reg                  (pflag_to_reg),                  //output
    .aflag_to_reg                  (aflag_to_reg),                  //output
    .zflag_to_reg                  (zflag_to_reg),                  //output
    .sflag_to_reg                  (sflag_to_reg),                  //output
    .oflag_to_reg                  (oflag_to_reg),                  //output
    .tflag_to_reg                  (tflag_to_reg),                  //output
    .iflag_to_reg                  (iflag_to_reg),                  //output
    .dflag_to_reg                  (dflag_to_reg),                  //output
    .iopl_to_reg                   (iopl_to_reg),                   //output [1:0]
    .ntflag_to_reg                 (ntflag_to_reg),                 //output
    .rflag_to_reg                  (rflag_to_reg),                  //output
    .vmflag_to_reg                 (vmflag_to_reg),                 //output
    .acflag_to_reg                 (acflag_to_reg),                 //output
    .idflag_to_reg                 (idflag_to_reg),                 //output
    .gdtr_base_to_reg              (gdtr_base_to_reg),              //output [31:0]
    .gdtr_limit_to_reg             (gdtr_limit_to_reg),             //output [15:0]
    .idtr_base_to_reg              (idtr_base_to_reg),              //output [31:0]
    .idtr_limit_to_reg             (idtr_limit_to_reg),             //output [15:0]
    .dr0_to_reg                    (dr0_to_reg),                    //output [31:0]
    .dr1_to_reg                    (dr1_to_reg),                    //output [31:0]
    .dr2_to_reg                    (dr2_to_reg),                    //output [31:0]
    .dr3_to_reg                    (dr3_to_reg),                    //output [31:0]
    .dr6_breakpoints_to_reg        (dr6_breakpoints_to_reg),        //output [3:0]
    .dr6_b12_to_reg                (dr6_b12_to_reg),                //output
    .dr6_bd_to_reg                 (dr6_bd_to_reg),                 //output
    .dr6_bs_to_reg                 (dr6_bs_to_reg),                 //output
    .dr6_bt_to_reg                 (dr6_bt_to_reg),                 //output
    .dr7_to_reg                    (dr7_to_reg),                    //output [31:0]
    .es_to_reg                     (es_to_reg),                     //output [15:0]
    .ds_to_reg                     (ds_to_reg),                     //output [15:0]
    .ss_to_reg                     (ss_to_reg),                     //output [15:0]
    .fs_to_reg                     (fs_to_reg),                     //output [15:0]
    .gs_to_reg                     (gs_to_reg),                     //output [15:0]
    .cs_to_reg                     (cs_to_reg),                     //output [15:0]
    .ldtr_to_reg                   (ldtr_to_reg),                   //output [15:0]
    .tr_to_reg                     (tr_to_reg),                     //output [15:0]
    .es_cache_to_reg               (es_cache_to_reg),               //output [63:0]
    .ds_cache_to_reg               (ds_cache_to_reg),               //output [63:0]
    .ss_cache_to_reg               (ss_cache_to_reg),               //output [63:0]
    .fs_cache_to_reg               (fs_cache_to_reg),               //output [63:0]
    .gs_cache_to_reg               (gs_cache_to_reg),               //output [63:0]
    .cs_cache_to_reg               (cs_cache_to_reg),               //output [63:0]
    .ldtr_cache_to_reg             (ldtr_cache_to_reg),             //output [63:0]
    .tr_cache_to_reg               (tr_cache_to_reg),               //output [63:0]
    .es_cache_valid_to_reg         (es_cache_valid_to_reg),         //output
    .ds_cache_valid_to_reg         (ds_cache_valid_to_reg),         //output
    .ss_cache_valid_to_reg         (ss_cache_valid_to_reg),         //output
    .fs_cache_valid_to_reg         (fs_cache_valid_to_reg),         //output
    .gs_cache_valid_to_reg         (gs_cache_valid_to_reg),         //output
    .cs_cache_valid_to_reg         (cs_cache_valid_to_reg),         //output
    .ldtr_cache_valid_to_reg       (ldtr_cache_valid_to_reg),       //output
    .es_rpl_to_reg                 (es_rpl_to_reg),                 //output [1:0]
    .ds_rpl_to_reg                 (ds_rpl_to_reg),                 //output [1:0]
    .ss_rpl_to_reg                 (ss_rpl_to_reg),                 //output [1:0]
    .fs_rpl_to_reg                 (fs_rpl_to_reg),                 //output [1:0]
    .gs_rpl_to_reg                 (gs_rpl_to_reg),                 //output [1:0]
    .cs_rpl_to_reg                 (cs_rpl_to_reg),                 //output [1:0]
    .ldtr_rpl_to_reg               (ldtr_rpl_to_reg),               //output [1:0]
    .tr_rpl_to_reg                 (tr_rpl_to_reg),                 //output [1:0]
    
    //output
    .eax                           (eax),                           //input [31:0]
    .ebx                           (ebx),                           //input [31:0]
    .ecx                           (ecx),                           //input [31:0]
    .edx                           (edx),                           //input [31:0]
    .esi                           (esi),                           //input [31:0]
    .edi                           (edi),                           //input [31:0]
    .ebp                           (ebp),                           //input [31:0]
    .esp                           (esp),                           //input [31:0]
    .cr0_pe                        (cr0_pe),                        //input
    .cr0_mp                        (cr0_mp),                        //input
    .cr0_em                        (cr0_em),                        //input
    .cr0_ts                        (cr0_ts),                        //input
    .cr0_ne                        (cr0_ne),                        //input
    .cr0_wp                        (cr0_wp),                        //input
    .cr0_am                        (cr0_am),                        //input
    .cr0_nw                        (cr0_nw),                        //input
    .cr0_cd                        (cr0_cd),                        //input
    .cr0_pg                        (cr0_pg),                        //input
    .cr2                           (cr2),                           //input [31:0]
    .cr3                           (cr3),                           //input [31:0]
    .cflag                         (cflag),                         //input
    .pflag                         (pflag),                         //input
    .aflag                         (aflag),                         //input
    .zflag                         (zflag),                         //input
    .sflag                         (sflag),                         //input
    .oflag                         (oflag),                         //input
    .tflag                         (tflag),                         //input
    .iflag                         (iflag),                         //input
    .dflag                         (dflag),                         //input
    .iopl                          (iopl),                          //input [1:0]
    .ntflag                        (ntflag),                        //input
    .rflag                         (rflag),                         //input
    .vmflag                        (vmflag),                        //input
    .acflag                        (acflag),                        //input
    .idflag                        (idflag),                        //input
    .gdtr_base                     (gdtr_base),                     //input [31:0]
    .gdtr_limit                    (gdtr_limit),                    //input [15:0]
    .idtr_base                     (idtr_base),                     //input [31:0]
    .idtr_limit                    (idtr_limit),                    //input [15:0]
    .dr0                           (dr0),                           //input [31:0]
    .dr1                           (dr1),                           //input [31:0]
    .dr2                           (dr2),                           //input [31:0]
    .dr3                           (dr3),                           //input [31:0]
    .dr6_breakpoints               (dr6_breakpoints),               //input [3:0]
    .dr6_b12                       (dr6_b12),                       //input
    .dr6_bd                        (dr6_bd),                        //input
    .dr6_bs                        (dr6_bs),                        //input
    .dr6_bt                        (dr6_bt),                        //input
    .dr7                           (dr7),                           //input [31:0]
    .es                            (es),                            //input [15:0]
    .ds                            (ds),                            //input [15:0]
    .ss                            (ss),                            //input [15:0]
    .fs                            (fs),                            //input [15:0]
    .gs                            (gs),                            //input [15:0]
    .cs                            (cs),                            //input [15:0]
    .ldtr                          (ldtr),                          //input [15:0]
    .tr                            (tr),                            //input [15:0]
    .es_cache                      (es_cache),                      //input [63:0]
    .ds_cache                      (ds_cache),                      //input [63:0]
    .ss_cache                      (ss_cache),                      //input [63:0]
    .fs_cache                      (fs_cache),                      //input [63:0]
    .gs_cache                      (gs_cache),                      //input [63:0]
    .cs_cache                      (cs_cache),                      //input [63:0]
    .ldtr_cache                    (ldtr_cache),                    //input [63:0]
    .tr_cache                      (tr_cache),                      //input [63:0]
    .es_cache_valid                (es_cache_valid),                //input
    .ds_cache_valid                (ds_cache_valid),                //input
    .ss_cache_valid                (ss_cache_valid),                //input
    .fs_cache_valid                (fs_cache_valid),                //input
    .gs_cache_valid                (gs_cache_valid),                //input
    .cs_cache_valid                (cs_cache_valid),                //input
    .ldtr_cache_valid              (ldtr_cache_valid),              //input
    .es_rpl                        (es_rpl),                        //input [1:0]
    .ds_rpl                        (ds_rpl),                        //input [1:0]
    .ss_rpl                        (ss_rpl),                        //input [1:0]
    .fs_rpl                        (fs_rpl),                        //input [1:0]
    .gs_rpl                        (gs_rpl),                        //input [1:0]
    .cs_rpl                        (cs_rpl),                        //input [1:0]
    .ldtr_rpl                      (ldtr_rpl),                      //input [1:0]
    .tr_rpl                        (tr_rpl)                         //input [1:0]
);
    
//------------------------------------------------------------------------------

wire [3:0]  wr_debug_code_reg;
wire [3:0]  wr_debug_write_reg;
wire [3:0]  wr_debug_read_reg;
wire        wr_debug_step_reg;
wire        wr_debug_task_reg;

write_debug write_debug_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    
    //general input
    .dr0                                (dr0),              //input [31:0]
    .dr1                                (dr1),              //input [31:0]
    .dr2                                (dr2),              //input [31:0]
    .dr3                                (dr3),              //input [31:0]
    .dr7                                (dr7),              //input [31:0]
    
    .debug_len0                         (debug_len0),       //input [2:0]
    .debug_len1                         (debug_len1),       //input [2:0]
    .debug_len2                         (debug_len2),       //input [2:0]
    .debug_len3                         (debug_len3),       //input [2:0]
    
    .rflag_to_reg                       (rflag_to_reg),     //input
    .tflag_to_reg                       (tflag_to_reg),     //input
    
    .wr_eip                             (wr_eip),           //input [31:0]
    
    .cs_base                            (cs_base),          //input [31:0]
    .cs_limit                           (cs_limit),         //input [31:0]
    
    //memory write
    .write_address                      (write_address),                    //input [31:0]
    .write_length                       (write_length),                     //input [2:0]
    .write_for_wr_ready                 (write_for_wr_ready),               //input
    
    //write control
    .w_load                             (w_load),                           //input
    .wr_finished                        (wr_finished),                      //input
    .wr_inhibit_interrupts_and_debug    (wr_inhibit_interrupts_and_debug),  //input
    .wr_debug_task_trigger              (wr_debug_task_trigger),            //input
    .wr_debug_trap_clear                (wr_debug_trap_clear),              //input
    
    .wr_string_in_progress              (wr_string_in_progress),            //input
    
    //pipeline input
    .exe_debug_read                     (exe_debug_read),                   //input [3:0]
    
    //output
    .wr_debug_prepare                   (wr_debug_prepare),                 //output
    
    .wr_debug_code_reg                  (wr_debug_code_reg),                //output [3:0]
    .wr_debug_write_reg                 (wr_debug_write_reg),               //output [3:0]
    .wr_debug_read_reg                  (wr_debug_read_reg),                //output [3:0]
    .wr_debug_step_reg                  (wr_debug_step_reg),                //output
    .wr_debug_task_reg                  (wr_debug_task_reg)                 //output
);
    
//------------------------------------------------------------------------------

write_register write_register_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //general input
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    
    //wr input
    .wr_is_8bit                    (wr_is_8bit),                    //input
    .wr_operand_32bit              (wr_operand_32bit),              //input
    .wr_decoder                    (wr_decoder),                    //input [15:0]
    .wr_modregrm_reg               (wr_modregrm_reg),               //input [2:0]
    .wr_modregrm_rm                (wr_modregrm_rm),                //input [2:0]
                                   
    .wr_clear_rflag                (wr_clear_rflag),                //input
    
    //segment control
    .wr_seg_sel                    (wr_seg_sel),                    //input [15:0]
    .wr_seg_rpl                    (wr_seg_rpl),                    //input [1:0]
    .wr_seg_cache_valid            (wr_seg_cache_valid),            //input
                                   
    .write_seg_sel                 (write_seg_sel),                 //input
    .write_seg_rpl                 (write_seg_rpl),                 //input
    .write_seg_cache               (write_seg_cache),               //input
    .write_seg_cache_valid         (write_seg_cache_valid),         //input
    .wr_seg_cache_mask             (wr_seg_cache_mask),             //input [63:0]
    
    .wr_validate_seg_regs          (wr_validate_seg_regs),          //input
    
    .write_system_touch            (write_system_touch),            //input
    .write_system_busy_tss         (write_system_busy_tss),         //input
    
    //exe exception write
    .dr6_bd_set                    (dr6_bd_set), //input
    
    //exception input
    .exc_set_rflag                 (exc_set_rflag),                 //input
    .exc_debug_start               (exc_debug_start),               //input
    .exc_pf_read                   (exc_pf_read),                   //input
    .exc_pf_write                  (exc_pf_write),                  //input
    .exc_pf_code                   (exc_pf_code),                   //input
    .exc_pf_check                  (exc_pf_check),                  //input
    .exc_restore_esp               (exc_restore_esp),               //input
    
    .wr_esp_prev                   (wr_esp_prev),                   //input [31:0]
                                   
    //cr2 input
    .tlb_code_pf_cr2               (tlb_code_pf_cr2),               //input [31:0]
    .tlb_write_pf_cr2              (tlb_write_pf_cr2),              //input [31:0]
    .tlb_read_pf_cr2               (tlb_read_pf_cr2),               //input [31:0]
    .tlb_check_pf_cr2              (tlb_check_pf_cr2),              //input [31:0]
    
    //debug input
    .wr_debug_code_reg             (wr_debug_code_reg),             //input [3:0]
    .wr_debug_write_reg            (wr_debug_write_reg),            //input [3:0]
    .wr_debug_read_reg             (wr_debug_read_reg),             //input [3:0]
    .wr_debug_step_reg             (wr_debug_step_reg),             //input
    .wr_debug_task_reg             (wr_debug_task_reg),             //input
                                   
    //write reg
    .write_eax                     (write_eax),                     //input
    .write_regrm                   (write_regrm),                   //input
                                   
    //write reg options
    .wr_dst_is_rm                  (wr_dst_is_rm),                  //input
    .wr_dst_is_reg                 (wr_dst_is_reg),                 //input
    .wr_dst_is_implicit_reg        (wr_dst_is_implicit_reg),        //input
    .wr_regrm_word                 (wr_regrm_word),                 //input
    .wr_regrm_dword                (wr_regrm_dword),                //input
    
    //write reg data
    .result                        (result),                        //input [31:0]
    
    //output
    .cpl                           (cpl),                           //output [1:0]

    .protected_mode                 (protected_mode),               //output
    .v8086_mode                     (v8086_mode),                   //output
    .real_mode                      (real_mode),                    //output
                                   
    .io_allow_check_needed         (io_allow_check_needed),         //output

    .debug_len0                    (debug_len0),                    //output [2:0]
    .debug_len1                    (debug_len1),                    //output [2:0]
    .debug_len2                    (debug_len2),                    //output [2:0]
    .debug_len3                    (debug_len3),                    //output [2:0]

    //registers input
    
    .eax_to_reg                    (eax_to_reg),                    //input [31:0]
    .ebx_to_reg                    (ebx_to_reg),                    //input [31:0]
    .ecx_to_reg                    (ecx_to_reg),                    //input [31:0]
    .edx_to_reg                    (edx_to_reg),                    //input [31:0]
    .esi_to_reg                    (esi_to_reg),                    //input [31:0]
    .edi_to_reg                    (edi_to_reg),                    //input [31:0]
    .ebp_to_reg                    (ebp_to_reg),                    //input [31:0]
    .esp_to_reg                    (esp_to_reg),                    //input [31:0]
    .cr0_pe_to_reg                 (cr0_pe_to_reg),                 //input
    .cr0_mp_to_reg                 (cr0_mp_to_reg),                 //input
    .cr0_em_to_reg                 (cr0_em_to_reg),                 //input
    .cr0_ts_to_reg                 (cr0_ts_to_reg),                 //input
    .cr0_ne_to_reg                 (cr0_ne_to_reg),                 //input
    .cr0_wp_to_reg                 (cr0_wp_to_reg),                 //input
    .cr0_am_to_reg                 (cr0_am_to_reg),                 //input
    .cr0_nw_to_reg                 (cr0_nw_to_reg),                 //input
    .cr0_cd_to_reg                 (cr0_cd_to_reg),                 //input
    .cr0_pg_to_reg                 (cr0_pg_to_reg),                 //input
    .cr2_to_reg                    (cr2_to_reg),                    //input [31:0]
    .cr3_to_reg                    (cr3_to_reg),                    //input [31:0]
    .cflag_to_reg                  (cflag_to_reg),                  //input
    .pflag_to_reg                  (pflag_to_reg),                  //input
    .aflag_to_reg                  (aflag_to_reg),                  //input
    .zflag_to_reg                  (zflag_to_reg),                  //input
    .sflag_to_reg                  (sflag_to_reg),                  //input
    .oflag_to_reg                  (oflag_to_reg),                  //input
    .tflag_to_reg                  (tflag_to_reg),                  //input
    .iflag_to_reg                  (iflag_to_reg),                  //input
    .dflag_to_reg                  (dflag_to_reg),                  //input
    .iopl_to_reg                   (iopl_to_reg),                   //input [1:0]
    .ntflag_to_reg                 (ntflag_to_reg),                 //input
    .rflag_to_reg                  (rflag_to_reg),                  //input
    .vmflag_to_reg                 (vmflag_to_reg),                 //input
    .acflag_to_reg                 (acflag_to_reg),                 //input
    .idflag_to_reg                 (idflag_to_reg),                 //input
    .gdtr_base_to_reg              (gdtr_base_to_reg),              //input [31:0]
    .gdtr_limit_to_reg             (gdtr_limit_to_reg),             //input [15:0]
    .idtr_base_to_reg              (idtr_base_to_reg),              //input [31:0]
    .idtr_limit_to_reg             (idtr_limit_to_reg),             //input [15:0]
    .dr0_to_reg                    (dr0_to_reg),                    //input [31:0]
    .dr1_to_reg                    (dr1_to_reg),                    //input [31:0]
    .dr2_to_reg                    (dr2_to_reg),                    //input [31:0]
    .dr3_to_reg                    (dr3_to_reg),                    //input [31:0]
    .dr6_breakpoints_to_reg        (dr6_breakpoints_to_reg),        //input [3:0]
    .dr6_b12_to_reg                (dr6_b12_to_reg),                //input
    .dr6_bd_to_reg                 (dr6_bd_to_reg),                 //input
    .dr6_bs_to_reg                 (dr6_bs_to_reg),                 //input
    .dr6_bt_to_reg                 (dr6_bt_to_reg),                 //input
    .dr7_to_reg                    (dr7_to_reg),                    //input [31:0]
    .es_to_reg                     (es_to_reg),                     //input [15:0]
    .ds_to_reg                     (ds_to_reg),                     //input [15:0]
    .ss_to_reg                     (ss_to_reg),                     //input [15:0]
    .fs_to_reg                     (fs_to_reg),                     //input [15:0]
    .gs_to_reg                     (gs_to_reg),                     //input [15:0]
    .cs_to_reg                     (cs_to_reg),                     //input [15:0]
    .ldtr_to_reg                   (ldtr_to_reg),                   //input [15:0]
    .tr_to_reg                     (tr_to_reg),                     //input [15:0]
    .es_cache_to_reg               (es_cache_to_reg),               //input [63:0]
    .ds_cache_to_reg               (ds_cache_to_reg),               //input [63:0]
    .ss_cache_to_reg               (ss_cache_to_reg),               //input [63:0]
    .fs_cache_to_reg               (fs_cache_to_reg),               //input [63:0]
    .gs_cache_to_reg               (gs_cache_to_reg),               //input [63:0]
    .cs_cache_to_reg               (cs_cache_to_reg),               //input [63:0]
    .ldtr_cache_to_reg             (ldtr_cache_to_reg),             //input [63:0]
    .tr_cache_to_reg               (tr_cache_to_reg),               //input [63:0]
    .es_cache_valid_to_reg         (es_cache_valid_to_reg),         //input
    .ds_cache_valid_to_reg         (ds_cache_valid_to_reg),         //input
    .ss_cache_valid_to_reg         (ss_cache_valid_to_reg),         //input
    .fs_cache_valid_to_reg         (fs_cache_valid_to_reg),         //input
    .gs_cache_valid_to_reg         (gs_cache_valid_to_reg),         //input
    .cs_cache_valid_to_reg         (cs_cache_valid_to_reg),         //input
    .ldtr_cache_valid_to_reg       (ldtr_cache_valid_to_reg),       //input
    .es_rpl_to_reg                 (es_rpl_to_reg),                 //input [1:0]
    .ds_rpl_to_reg                 (ds_rpl_to_reg),                 //input [1:0]
    .ss_rpl_to_reg                 (ss_rpl_to_reg),                 //input [1:0]
    .fs_rpl_to_reg                 (fs_rpl_to_reg),                 //input [1:0]
    .gs_rpl_to_reg                 (gs_rpl_to_reg),                 //input [1:0]
    .cs_rpl_to_reg                 (cs_rpl_to_reg),                 //input [1:0]
    .ldtr_rpl_to_reg               (ldtr_rpl_to_reg),               //input [1:0]
    .tr_rpl_to_reg                 (tr_rpl_to_reg),                 //input [1:0]
    
    //registers output
    .eax                 (eax),                 //output [31:0]
    .ebx                 (ebx),                 //output [31:0]
    .ecx                 (ecx),                 //output [31:0]
    .edx                 (edx),                 //output [31:0]
    .esi                 (esi),                 //output [31:0]
    .edi                 (edi),                 //output [31:0]
    .ebp                 (ebp),                 //output [31:0]
    .esp                 (esp),                 //output [31:0]
    .cr0_pe              (cr0_pe),              //output
    .cr0_mp              (cr0_mp),              //output
    .cr0_em              (cr0_em),              //output
    .cr0_ts              (cr0_ts),              //output
    .cr0_ne              (cr0_ne),              //output
    .cr0_wp              (cr0_wp),              //output
    .cr0_am              (cr0_am),              //output
    .cr0_nw              (cr0_nw),              //output
    .cr0_cd              (cr0_cd),              //output
    .cr0_pg              (cr0_pg),              //output
    .cr2                 (cr2),                 //output [31:0]
    .cr3                 (cr3),                 //output [31:0]
    .cflag               (cflag),               //output
    .pflag               (pflag),               //output
    .aflag               (aflag),               //output
    .zflag               (zflag),               //output
    .sflag               (sflag),               //output
    .oflag               (oflag),               //output
    .tflag               (tflag),               //output
    .iflag               (iflag),               //output
    .dflag               (dflag),               //output
    .iopl                (iopl),                //output [1:0]
    .ntflag              (ntflag),              //output
    .rflag               (rflag),               //output
    .vmflag              (vmflag),              //output
    .acflag              (acflag),              //output
    .idflag              (idflag),              //output
    .gdtr_base           (gdtr_base),           //output [31:0]
    .gdtr_limit          (gdtr_limit),          //output [15:0]
    .idtr_base           (idtr_base),           //output [31:0]
    .idtr_limit          (idtr_limit),          //output [15:0]
    .dr0                 (dr0),                 //output [31:0]
    .dr1                 (dr1),                 //output [31:0]
    .dr2                 (dr2),                 //output [31:0]
    .dr3                 (dr3),                 //output [31:0]
    .dr6_breakpoints     (dr6_breakpoints),     //output [3:0]
    .dr6_b12             (dr6_b12),             //output
    .dr6_bd              (dr6_bd),              //output
    .dr6_bs              (dr6_bs),              //output
    .dr6_bt              (dr6_bt),              //output
    .dr7                 (dr7),                 //output [31:0]
    .es                  (es),                  //output [15:0]
    .ds                  (ds),                  //output [15:0]
    .ss                  (ss),                  //output [15:0]
    .fs                  (fs),                  //output [15:0]
    .gs                  (gs),                  //output [15:0]
    .cs                  (cs),                  //output [15:0]
    .ldtr                (ldtr),                //output [15:0]
    .tr                  (tr),                  //output [15:0]
    .es_cache            (es_cache),            //output [63:0]
    .ds_cache            (ds_cache),            //output [63:0]
    .ss_cache            (ss_cache),            //output [63:0]
    .fs_cache            (fs_cache),            //output [63:0]
    .gs_cache            (gs_cache),            //output [63:0]
    .cs_cache            (cs_cache),            //output [63:0]
    .ldtr_cache          (ldtr_cache),          //output [63:0]
    .tr_cache            (tr_cache),            //output [63:0]
    .es_cache_valid      (es_cache_valid),      //output
    .ds_cache_valid      (ds_cache_valid),      //output
    .ss_cache_valid      (ss_cache_valid),      //output
    .fs_cache_valid      (fs_cache_valid),      //output
    .gs_cache_valid      (gs_cache_valid),      //output
    .cs_cache_valid      (cs_cache_valid),      //output
    .ldtr_cache_valid    (ldtr_cache_valid),    //output
    .tr_cache_valid      (tr_cache_valid),      //output
    .es_rpl              (es_rpl),              //output [1:0]
    .ds_rpl              (ds_rpl),              //output [1:0]
    .ss_rpl              (ss_rpl),              //output [1:0]
    .fs_rpl              (fs_rpl),              //output [1:0]
    .gs_rpl              (gs_rpl),              //output [1:0]
    .cs_rpl              (cs_rpl),              //output [1:0]
    .ldtr_rpl            (ldtr_rpl),            //output [1:0]
    .tr_rpl              (tr_rpl)               //output [1:0]
);
    
//------------------------------------------------------------------------------

write_stack write_stack_inst(
    
    .glob_descriptor            (glob_descriptor),              //input [63:0]
    
    .esp                        (esp),                          //input [31:0]
    
    .ss_cache                   (ss_cache),                     //input [63:0]
    .ss_base                    (ss_base),                      //input [31:0]
    .ss_limit                   (ss_limit),                     //input [31:0]
    
    .glob_desc_base             (glob_desc_base),               //input [31:0]
    .glob_desc_limit            (glob_desc_limit),              //input [31:0]
    
    .wr_operand_16bit           (wr_operand_16bit),             //input
    .wr_stack_offset            (wr_stack_offset),              //input [31:0]
    
    .wr_new_push_ss_fault_check (wr_new_push_ss_fault_check),   //input
    .wr_push_length_word        (wr_push_length_word),          //input
    .wr_push_length_dword       (wr_push_length_dword),         //input
    
    .wr_push_ss_fault_check     (wr_push_ss_fault_check),       //input
    
    //output
    .wr_stack_esp               (wr_stack_esp),                 //output [31:0]
    .wr_push_linear             (wr_push_linear),               //output [31:0]
    
    .wr_new_stack_esp           (wr_new_stack_esp),             //output [31:0]
    .wr_new_push_linear         (wr_new_push_linear),           //output [31:0]
    
    .wr_push_length             (wr_push_length),               //output [2:0]
    
    .wr_push_ss_fault           (wr_push_ss_fault),             //output
    .wr_new_push_ss_fault       (wr_new_push_ss_fault)          //output
);
    
//------------------------------------------------------------------------------

write_string write_string_inst(
    
    .wr_is_8bit                 (wr_is_8bit),               //input
    .wr_operand_16bit           (wr_operand_16bit),         //input
    .wr_address_16bit           (wr_address_16bit),         //input
    .wr_address_32bit           (wr_address_32bit),         //input
    .wr_prefix_group_1_rep      (wr_prefix_group_1_rep),    //input [1:0]
    
    .wr_string_gp_fault_check   (wr_string_gp_fault_check), //input
    
    .dflag                      (dflag),                    //input
    
    .wr_zflag_result            (wr_zflag_result),          //input
    
    .ecx                        (ecx),                      //input [31:0]
    .esi                        (esi),                      //input [31:0]
    .edi                        (edi),                      //input [31:0]
    
    .es_cache                   (es_cache),                 //input [63:0]
    .es_cache_valid             (es_cache_valid),           //input
    .es_base                    (es_base),                  //input [31:0]
    .es_limit                   (es_limit),                 //input [31:0]
    
    //output
    .wr_esi_final               (wr_esi_final),             //output [31:0]
    .wr_edi_final               (wr_edi_final),             //output [31:0]
    .wr_ecx_final               (wr_ecx_final),             //output [31:0]
    
    .wr_string_ignore           (wr_string_ignore),         //output
    .wr_string_finish           (wr_string_finish),         //output
    .wr_string_zf_finish        (wr_string_zf_finish),      //output
    
    .wr_string_es_linear        (wr_string_es_linear),      //output [31:0]
    
    .wr_string_es_fault         (wr_string_es_fault)        //output
);
    
//------------------------------------------------------------------------------
    
endmodule
