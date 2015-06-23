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

module pipeline(
    input           clk,
    input           rst_n,
    
    //to memory
    output              pr_reset,
    output              rd_reset,
    output              exe_reset,
    output              wr_reset,
    
    output              real_mode,
    
    //exception
    input               exc_restore_esp,
    input               exc_set_rflag,
    input               exc_debug_start,
    
    input               exc_init,
    input               exc_load,
    input       [31:0]  exc_eip,
    
    input       [7:0]   exc_vector,
    input       [15:0]  exc_error_code,
    input               exc_push_error,
    input               exc_soft_int,
    input               exc_soft_int_ib,
    
    input               exc_pf_read,
    input               exc_pf_write,
    input               exc_pf_code,
    input               exc_pf_check,
    
    //pipeline eip
    output      [31:0]  eip,
    output      [31:0]  dec_eip,
    output      [31:0]  rd_eip,
    output      [31:0]  exe_eip,
    output      [31:0]  wr_eip,
    
    output      [3:0]   rd_consumed,
    output      [3:0]   exe_consumed,
    output      [3:0]   wr_consumed,
    
    //exception reset
    input               exc_dec_reset,
    input               exc_micro_reset,
    input               exc_rd_reset,
    input               exc_exe_reset,
    input               exc_wr_reset,
    
    //global
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_2,
    input       [31:0]  glob_param_3,
    input       [31:0]  glob_param_4,
    input       [31:0]  glob_param_5,
    
    input       [63:0]  glob_descriptor,
    input       [63:0]  glob_descriptor_2,
    
    input       [31:0]  glob_desc_base,
    
    input       [31:0]  glob_desc_limit,
    input       [31:0]  glob_desc_2_limit,
    
    //pipeline state
    output              rd_dec_is_front,
    output              rd_is_front,
    output              exe_is_front,
    output              wr_is_front,
    
    output              pipeline_after_read_empty,
    output              pipeline_after_prefetch_empty,
    
    //dec exceptions
    output              dec_gp_fault,
    output              dec_ud_fault,
    output              dec_pf_fault,
    
    //rd exception
    output              rd_io_allow_fault,
    output              rd_descriptor_gp_fault,
    output              rd_seg_gp_fault,
    output              rd_seg_ss_fault,
    output              rd_ss_esp_from_tss_fault,
    
    //exe exception
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
    
    //wr exception
    output              wr_debug_init,
    
    output              wr_new_push_ss_fault,
    output              wr_string_es_fault,
    output              wr_push_ss_fault,
    
    //error code
    output      [15:0]  rd_error_code,
    output      [15:0]  exe_error_code,
    output      [15:0]  wr_error_code,
    
    //glob output
    output              glob_descriptor_set,
    output      [63:0]  glob_descriptor_value,

    output              glob_descriptor_2_set,
    output      [63:0]  glob_descriptor_2_value,

    output              glob_param_1_set,
    output      [31:0]  glob_param_1_value,
    output              glob_param_2_set,
    output      [31:0]  glob_param_2_value,
    output              glob_param_3_set,
    output      [31:0]  glob_param_3_value,
    output              glob_param_4_set,
    output      [31:0]  glob_param_4_value,
    output              glob_param_5_set,
    output      [31:0]  glob_param_5_value,
    
    // prefetch
    output      [1:0]   prefetch_cpl,
    output      [31:0]  prefetch_eip,
    output      [63:0]  cs_cache,
    
    output              cr0_pg,
    output              cr0_wp,
    output              cr0_am,
    output              cr0_cd,
    output              cr0_nw,
    
    output              acflag,
    
    output      [31:0]  cr3,
    
    // prefetch_fifo
    output              prefetchfifo_accept_do,
    input       [67:0]  prefetchfifo_accept_data,
    input               prefetchfifo_accept_empty,
    
    //io_read
    output              io_read_do,
    output      [15:0]  io_read_address,
    output      [2:0]   io_read_length,
    input       [31:0]  io_read_data,
    input               io_read_done,
    
    //read memory
    output              read_do,
    input               read_done,
    input               read_page_fault,
    input               read_ac_fault,
    
    output      [1:0]   read_cpl,
    output      [31:0]  read_address,
    output      [3:0]   read_length,
    output              read_lock,
    output              read_rmw,
    input       [63:0]  read_data,
    
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
    
    //flush tlb
    output              tlbflushall_do,
    
    //invd
    output              invdcode_do,
    input               invdcode_done,
    
    output              invddata_do,
    input               invddata_done,
    
    output              wbinvddata_do,
    input               wbinvddata_done,
    
    //interrupt
    input               interrupt_do,
    
    output              wr_interrupt_possible,
    output              wr_string_in_progress_final,
    output              wr_is_esp_speculative,
    
    //software interrupt
    output              wr_int,
    output              wr_int_soft_int,
    output              wr_int_soft_int_ib,
    output      [7:0]   wr_int_vector,

    output              wr_exception_external_set,
    output              wr_exception_finished,
    
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
    
    //io write
    output              io_write_do,
    output      [15:0]  io_write_address,
    output      [2:0]   io_write_length,
    output      [31:0]  io_write_data,
    input               io_write_done
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, SW[16:7], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

assign prefetch_cpl = cpl;

//------------------------------------------------------------------------------ pipeline state

wire      pipeline_dec_idle;
reg [1:0] pipeline_dec_idle_counter;

assign pipeline_dec_idle                = rd_dec_is_front && prefetchfifo_accept_empty;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               pipeline_dec_idle_counter <= 2'd0;
    else if(pipeline_dec_idle && pipeline_dec_idle_counter < 2'd3)  pipeline_dec_idle_counter <= pipeline_dec_idle_counter + 2'd1;
    else if(~(pipeline_dec_idle))                                   pipeline_dec_idle_counter <= 2'd0;
end

assign pipeline_after_read_empty        = rd_is_front;
assign pipeline_after_prefetch_empty    = pipeline_dec_idle && pipeline_dec_idle_counter == 2'd3;

//------------------------------------------------------------------------------

wire        rd_glob_descriptor_set;
wire [63:0] rd_glob_descriptor_value;
wire        rd_glob_descriptor_2_set;
wire [63:0] rd_glob_descriptor_2_value;
wire        rd_glob_param_1_set;
wire [31:0] rd_glob_param_1_value;
wire        rd_glob_param_2_set;
wire [31:0] rd_glob_param_2_value;
wire        rd_glob_param_3_set;
wire [31:0] rd_glob_param_3_value;
wire        rd_glob_param_4_set;
wire [31:0] rd_glob_param_4_value;
wire        rd_glob_param_5_set;
wire [31:0] rd_glob_param_5_value;

wire        exe_glob_descriptor_set;
wire [63:0] exe_glob_descriptor_value;
wire        exe_glob_descriptor_2_set;
wire [63:0] exe_glob_descriptor_2_value;
wire        exe_glob_param_1_set;
wire [31:0] exe_glob_param_1_value;
wire        exe_glob_param_2_set;
wire [31:0] exe_glob_param_2_value;
wire        exe_glob_param_3_set;
wire [31:0] exe_glob_param_3_value;

wire        wr_glob_param_1_set;
wire [31:0] wr_glob_param_1_value;
wire        wr_glob_param_3_set;
wire [31:0] wr_glob_param_3_value;
wire        wr_glob_param_4_set;
wire [31:0] wr_glob_param_4_value;

assign glob_descriptor_set      = rd_glob_descriptor_set | exe_glob_descriptor_set;
assign glob_descriptor_value    = (rd_glob_descriptor_set)? rd_glob_descriptor_value : exe_glob_descriptor_value;

assign glob_descriptor_2_set    = rd_glob_descriptor_2_set | exe_glob_descriptor_2_set;
assign glob_descriptor_2_value  = (rd_glob_descriptor_2_set)? rd_glob_descriptor_2_value : exe_glob_descriptor_2_value;

assign glob_param_1_set     = rd_glob_param_1_set | exe_glob_param_1_set | wr_glob_param_1_set;
assign glob_param_1_value   = (rd_glob_param_1_set)? rd_glob_param_1_value : (exe_glob_param_1_set)? exe_glob_param_1_value : wr_glob_param_1_value;

assign glob_param_2_set     = rd_glob_param_2_set | exe_glob_param_2_set;
assign glob_param_2_value   = (rd_glob_param_2_set)? rd_glob_param_2_value : exe_glob_param_2_value;

assign glob_param_3_set     = rd_glob_param_3_set | exe_glob_param_3_set | wr_glob_param_3_set;
assign glob_param_3_value   = (rd_glob_param_3_set)? rd_glob_param_3_value : (exe_glob_param_3_set)? exe_glob_param_3_value : wr_glob_param_3_value;

assign glob_param_4_set     = rd_glob_param_4_set | wr_glob_param_4_set;
assign glob_param_4_value   = (rd_glob_param_4_set)? rd_glob_param_4_value : wr_glob_param_4_value;

assign glob_param_5_set     = rd_glob_param_5_set;
assign glob_param_5_value   = rd_glob_param_5_value;

//------------------------------------------------------------------------------

wire wr_req_reset_pr;
wire wr_req_reset_dec;
wire wr_req_reset_micro;
wire wr_req_reset_rd;
wire wr_req_reset_exe;

wire dec_reset;
wire micro_reset;

assign pr_reset    =                   wr_req_reset_pr;
assign dec_reset   = exc_dec_reset   | wr_req_reset_dec;
assign micro_reset = exc_micro_reset | wr_req_reset_micro;
assign rd_reset    = exc_rd_reset    | wr_req_reset_rd;
assign exe_reset   = exc_exe_reset   | wr_req_reset_exe;
assign wr_reset    = exc_wr_reset;

//------------------------------------------------------------------------------

wire [1:0]  cpl;

wire [31:0] gdtr_base;
wire [15:0] gdtr_limit;

wire [31:0] idtr_base;
wire [15:0] idtr_limit;

wire        es_cache_valid;
wire [63:0] es_cache;
wire        cs_cache_valid;
wire        ss_cache_valid;
wire [63:0] ss_cache;
wire        ds_cache_valid;
wire [63:0] ds_cache;
wire        fs_cache_valid;
wire [63:0] fs_cache;
wire        gs_cache_valid;
wire [63:0] gs_cache;
wire        tr_cache_valid;
wire [63:0] tr_cache;
wire        ldtr_cache_valid;
wire [63:0] ldtr_cache;

wire        idflag;
wire        vmflag;
wire        rflag;
wire        ntflag;
wire [1:0]  iopl;
wire        oflag;
wire        dflag;
wire        iflag;
wire        tflag;
wire        sflag;
wire        zflag;
wire        aflag;
wire        pflag;
wire        cflag;

wire        cr0_ne;
wire        cr0_ts;
wire        cr0_em;
wire        cr0_mp;
wire        cr0_pe;

wire [31:0] cr2;

wire [31:0] eax;
wire [31:0] ebx;
wire [31:0] ecx;
wire [31:0] edx;
wire [31:0] esp;
wire [31:0] ebp;
wire [31:0] esi;
wire [31:0] edi;

wire [15:0] es;
wire [15:0] cs;
wire [15:0] ss;
wire [15:0] ds;
wire [15:0] fs;
wire [15:0] gs;
wire [15:0] ldtr;
wire [15:0] tr;

wire [31:0] dr0;
wire [31:0] dr1;
wire [31:0] dr2;
wire [31:0] dr3;
wire        dr6_bt;
wire        dr6_bs;
wire        dr6_bd;
wire        dr6_b12;
wire [3:0]  dr6_breakpoints;
wire [31:0] dr7;



//------------------------------------------------------------------------------

wire [3:0]  fetch_valid;
wire [63:0] fetch;
wire        fetch_limit;
wire        fetch_page_fault;

wire [3:0]  dec_acceptable;

fetch fetch_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    .pr_reset                   (pr_reset),
    
    // get prefetch_eip
    .wr_eip                     (wr_eip),                       //input [31:0]
    
    .prefetch_eip               (prefetch_eip),                 //output [31:0]
    
    // prefetch_fifo
    .prefetchfifo_accept_do     (prefetchfifo_accept_do),       //output
    .prefetchfifo_accept_data   (prefetchfifo_accept_data),     //input [67:0]
    .prefetchfifo_accept_empty  (prefetchfifo_accept_empty),    //input
    
    // fetch interface to decode
    .fetch_valid                (fetch_valid),                  //output [3:0]
    .fetch                      (fetch),                        //output [63:0]
    .fetch_limit                (fetch_limit),                  //output
    .fetch_page_fault           (fetch_page_fault),             //output
    
    // feedback from decode
    .dec_acceptable             (dec_acceptable)                //input [3:0]
);

//------------------------------------------------------------------------------

wire        v8086_mode;
wire        protected_mode;

wire        micro_busy;
wire        dec_ready;

wire [95:0] decoder;
wire        dec_operand_32bit;
wire        dec_address_32bit;
wire [1:0]  dec_prefix_group_1_rep;
wire        dec_prefix_group_1_lock;
wire [2:0]  dec_prefix_group_2_seg;
wire        dec_prefix_2byte;
wire [3:0]  dec_consumed;
wire [2:0]  dec_modregrm_len;
wire        dec_is_8bit;
wire [6:0]  dec_cmd;
wire [3:0]  dec_cmdex;
wire        dec_is_complex;

wire [6:0]  micro_cmd;
wire [6:0]  rd_cmd;

decode decode_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .dec_reset          (dec_reset),            //input
    
    //global input
    .cs_cache           (cs_cache),             //input [63:0]
    
    .protected_mode     (protected_mode),       //input
    
    //eip
    .pr_reset           (pr_reset),             //input
    .prefetch_eip       (prefetch_eip),         //input [31:0]
    .eip                (eip),                  //output [31:0]
    
    //fetch interface
    .fetch_valid        (fetch_valid),          //input [3:0]
    .fetch              (fetch),                //input [63:0]
    .fetch_limit        (fetch_limit),          //input
    .fetch_page_fault   (fetch_page_fault),     //input
    
    .dec_acceptable     (dec_acceptable),       //output [3:0]
    
    //exceptions
    .dec_gp_fault       (dec_gp_fault),         //output
    .dec_ud_fault       (dec_ud_fault),         //output
    .dec_pf_fault       (dec_pf_fault),         //output
    
    //pipeline
    .micro_busy                 (micro_busy),               //input
    .dec_ready                  (dec_ready),                //output
    
    .decoder                    (decoder),                  //output [95:0]
    .dec_eip                    (dec_eip),                  //output [31:0]
    .dec_operand_32bit          (dec_operand_32bit),        //output
    .dec_address_32bit          (dec_address_32bit),        //output
    .dec_prefix_group_1_rep     (dec_prefix_group_1_rep),   //output [1:0]
    .dec_prefix_group_1_lock    (dec_prefix_group_1_lock),  //output
    .dec_prefix_group_2_seg     (dec_prefix_group_2_seg),   //output [2:0]
    .dec_prefix_2byte           (dec_prefix_2byte),         //output
    .dec_consumed               (dec_consumed),             //output [3:0]
    .dec_modregrm_len           (dec_modregrm_len),         //output [2:0]
    .dec_is_8bit                (dec_is_8bit),              //output
    .dec_cmd                    (dec_cmd),                  //output [6:0]
    .dec_cmdex                  (dec_cmdex),                //output [3:0]
    .dec_is_complex             (dec_is_complex)            //output
);

//------------------------------------------------------------------------------

wire [31:0] task_eip;

wire        io_allow_check_needed;

wire        rd_busy;
wire        micro_ready;
wire [87:0] micro_decoder;
wire [31:0] micro_eip;
wire        micro_operand_32bit;
wire        micro_address_32bit;
wire [1:0]  micro_prefix_group_1_rep;
wire        micro_prefix_group_1_lock;
wire [2:0]  micro_prefix_group_2_seg;
wire        micro_prefix_2byte;
wire [3:0]  micro_consumed;
wire [2:0]  micro_modregrm_len;
wire        micro_is_8bit;
wire [3:0]  micro_cmdex;

microcode microcode_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .micro_reset        (micro_reset), //input
    
    .exc_init                      (exc_init),                      //input
    .exc_load                      (exc_load),                      //input
    .exc_eip                       (exc_eip),                       //input [31:0]
    
    .task_eip                      (task_eip),                      //input [31:0]
    
    //command control
    .real_mode                     (real_mode),                     //input
    .v8086_mode                    (v8086_mode),                    //input
    .protected_mode                (protected_mode),                //input
    
    .io_allow_check_needed         (io_allow_check_needed),         //input
    .exc_push_error                (exc_push_error),                //input
    .cr0_pg                        (cr0_pg),                        //input
    .oflag                         (oflag),                         //input
    .ntflag                        (ntflag),                        //input
    .cpl                           (cpl),                           //input [1:0]
    
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    .glob_param_3                  (glob_param_3),                  //input [31:0]
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    
    //decoder
    .micro_busy                    (micro_busy),                    //output
    .dec_ready                     (dec_ready),                     //input

    .decoder                       (decoder),                       //input [95:0]
    .dec_eip                       (dec_eip),                       //input [31:0]
    .dec_operand_32bit             (dec_operand_32bit),             //input
    .dec_address_32bit             (dec_address_32bit),             //input
    .dec_prefix_group_1_rep        (dec_prefix_group_1_rep),        //input [1:0]
    .dec_prefix_group_1_lock       (dec_prefix_group_1_lock),       //input
    .dec_prefix_group_2_seg        (dec_prefix_group_2_seg),        //input [2:0]
    .dec_prefix_2byte              (dec_prefix_2byte),              //input
    .dec_consumed                  (dec_consumed),                  //input [3:0]
    .dec_modregrm_len              (dec_modregrm_len),              //input [2:0]
    .dec_is_8bit                   (dec_is_8bit),                   //input
    .dec_cmd                       (dec_cmd),                       //input [6:0]
    .dec_cmdex                     (dec_cmdex),                     //input [3:0]
    .dec_is_complex                (dec_is_complex),                //input
    
    //micro
    .rd_busy                       (rd_busy),                       //input
    .micro_ready                   (micro_ready),                   //output
    
    .micro_decoder                 (micro_decoder),                 //output [87:0]
    .micro_eip                     (micro_eip),                     //output [31:0]
    .micro_operand_32bit           (micro_operand_32bit),           //output
    .micro_address_32bit           (micro_address_32bit),           //output
    .micro_prefix_group_1_rep      (micro_prefix_group_1_rep),      //output [1:0]
    .micro_prefix_group_1_lock     (micro_prefix_group_1_lock),     //output
    .micro_prefix_group_2_seg      (micro_prefix_group_2_seg),      //output [2:0]
    .micro_prefix_2byte            (micro_prefix_2byte),            //output
    .micro_consumed                (micro_consumed),                //output [3:0]
    .micro_modregrm_len            (micro_modregrm_len),            //output [2:0]
    .micro_is_8bit                 (micro_is_8bit),                 //output
    .micro_cmd                     (micro_cmd),                     //output [6:0]
    .micro_cmdex                   (micro_cmdex)                    //output [3:0]
);


//------------------------------------------------------------------------------

wire [2:0]  debug_len0;
wire [2:0]  debug_len1;
wire [2:0]  debug_len2;
wire [2:0]  debug_len3;

wire [10:0] exe_mutex;
wire [10:0] wr_mutex;

wire [31:0] wr_esp_prev;

wire        exe_busy;
wire        rd_ready;
wire [87:0] rd_decoder;
wire        rd_operand_32bit;
wire        rd_address_32bit;
wire [1:0]  rd_prefix_group_1_rep;
wire        rd_prefix_group_1_lock;
wire        rd_prefix_2byte;
wire        rd_is_8bit;
//wire [6:0]  rd_cmd;
wire [3:0]  rd_cmdex;
wire [31:0] rd_modregrm_imm;
wire [10:0] rd_mutex_next;
wire        rd_dst_is_reg;
wire        rd_dst_is_rm;
wire        rd_dst_is_memory;
wire        rd_dst_is_eax;
wire        rd_dst_is_edx_eax;
wire        rd_dst_is_implicit_reg;
wire [31:0] rd_extra_wire;
wire [31:0] rd_linear;
wire [3:0]  rd_debug_read;
wire [31:0] src_wire;
wire [31:0] dst_wire;
wire [31:0] rd_address_effective;

read read_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .rd_reset           (rd_reset), //input
    
    //debug input
    .dr0                           (dr0),                           //input [31:0]
    .dr1                           (dr1),                           //input [31:0]
    .dr2                           (dr2),                           //input [31:0]
    .dr3                           (dr3),                           //input [31:0]
    .dr7                           (dr7),                           //input [31:0]
    
    .debug_len0                    (debug_len0),                    //input [2:0]
    .debug_len1                    (debug_len1),                    //input [2:0]
    .debug_len2                    (debug_len2),                    //input [2:0]
    .debug_len3                    (debug_len3),                    //input [2:0]
    
    //global input
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    .glob_param_2                  (glob_param_2),                  //input [31:0]
    .glob_param_3                  (glob_param_3),                  //input [31:0]
    
    .glob_desc_limit               (glob_desc_limit),               //input [31:0]
    .glob_desc_base                (glob_desc_base),                //input [31:0]
    
    //general input
    .gdtr_limit                    (gdtr_limit),                    //input [15:0]
    
    .gdtr_base                     (gdtr_base),                     //input [31:0]
    .idtr_base                     (idtr_base),                     //input [31:0]
    
    .es_cache_valid                (es_cache_valid),                //input
    .es_cache                      (es_cache),                      //input [63:0]
    .cs_cache_valid                (cs_cache_valid),                //input
    .cs_cache                      (cs_cache),                      //input [63:0]
    .ss_cache_valid                (ss_cache_valid),                //input
    .ss_cache                      (ss_cache),                      //input [63:0]
    .ds_cache_valid                (ds_cache_valid),                //input
    .ds_cache                      (ds_cache),                      //input [63:0]
    .fs_cache_valid                (fs_cache_valid),                //input
    .fs_cache                      (fs_cache),                      //input [63:0]
    .gs_cache_valid                (gs_cache_valid),                //input
    .gs_cache                      (gs_cache),                      //input [63:0]
    .tr_cache_valid                (tr_cache_valid),                //input
    .tr_cache                      (tr_cache),                      //input [63:0]
    .tr                            (tr),                            //input [15:0]
    .ldtr_cache_valid              (ldtr_cache_valid),              //input
    .ldtr_cache                    (ldtr_cache),                    //input [63:0]
    
    .cpl                           (cpl),                           //input [1:0]
    
    .iopl                          (iopl),                          //input [1:0]
    
    .cr0_pg                        (cr0_pg),                        //input
    
    .real_mode                     (real_mode),                     //input
    .v8086_mode                    (v8086_mode),                    //input
    .protected_mode                (protected_mode),                //input
    
    .io_allow_check_needed  (io_allow_check_needed), //input
    
    .eax                           (eax),                           //input [31:0]
    .ebx                           (ebx),                           //input [31:0]
    .ecx                           (ecx),                           //input [31:0]
    .edx                           (edx),                           //input [31:0]
    .esp                           (esp),                           //input [31:0]
    .ebp                           (ebp),                           //input [31:0]
    .esi                           (esi),                           //input [31:0]
    .edi                           (edi),                           //input [31:0]
    
    //pipeline input
    .exe_trigger_gp_fault    (exe_trigger_gp_fault),   //output
    
    .exe_mutex                     (exe_mutex),                     //input [10:0]
    .wr_mutex                      (wr_mutex),                      //input [10:0]
    
    .wr_esp_prev            (wr_esp_prev),  //input [31:0]
    
    .exc_vector             (exc_vector),   //input [7:0]
    
    //rd exception
    .rd_io_allow_fault             (rd_io_allow_fault),             //output
    .rd_error_code                 (rd_error_code),                 //output [15:0]
    .rd_descriptor_gp_fault        (rd_descriptor_gp_fault),        //output
    .rd_seg_gp_fault               (rd_seg_gp_fault),               //output
    .rd_seg_ss_fault               (rd_seg_ss_fault),               //output
    .rd_ss_esp_from_tss_fault      (rd_ss_esp_from_tss_fault),      //output
               
    //pipeline state
    .rd_dec_is_front               (rd_dec_is_front),               //output
    .rd_is_front                   (rd_is_front),                   //output
    
    //glob output
    .rd_glob_descriptor_set           (rd_glob_descriptor_set),           //output
    .rd_glob_descriptor_value         (rd_glob_descriptor_value),         //output [63:0]
    .rd_glob_descriptor_2_set         (rd_glob_descriptor_2_set),         //output
    .rd_glob_descriptor_2_value       (rd_glob_descriptor_2_value),       //output [63:0]
    
    .rd_glob_param_1_set              (rd_glob_param_1_set),              //output
    .rd_glob_param_1_value            (rd_glob_param_1_value),            //output [31:0]
    .rd_glob_param_2_set              (rd_glob_param_2_set),              //output
    .rd_glob_param_2_value            (rd_glob_param_2_value),            //output [31:0]
    .rd_glob_param_3_set              (rd_glob_param_3_set),              //output
    .rd_glob_param_3_value            (rd_glob_param_3_value),            //output [31:0]
    .rd_glob_param_4_set              (rd_glob_param_4_set),              //output
    .rd_glob_param_4_value            (rd_glob_param_4_value),            //output [31:0]
    .rd_glob_param_5_set              (rd_glob_param_5_set),              //output
    .rd_glob_param_5_value            (rd_glob_param_5_value),            //output [31:0]
    
    //io_read
    .io_read_do                    (io_read_do),                    //output
    .io_read_address               (io_read_address),               //output [15:0]
    .io_read_length                (io_read_length),                //output [2:0]
    .io_read_data                  (io_read_data),                  //input [31:0]
    .io_read_done                  (io_read_done),                  //input
    
    //read memory
    .read_do                       (read_do),                       //output
    .read_done                     (read_done),                     //input
    .read_page_fault               (read_page_fault),               //input
    .read_ac_fault                 (read_ac_fault),                 //input
    .read_cpl                      (read_cpl),                      //output [1:0]
    .read_address                  (read_address),                  //output [31:0]
    .read_length                   (read_length),                   //output [3:0]
    .read_lock                     (read_lock),                     //output
    .read_rmw                      (read_rmw),                      //output
    .read_data                     (read_data),                     //input [63:0]
    
    //micro pipeline
    .rd_busy                       (rd_busy),                       //output
    .micro_ready                   (micro_ready),                   //input
    
    .micro_decoder                 (micro_decoder),                 //input [87:0]
    .micro_eip                     (micro_eip),                     //input [31:0]
    .micro_operand_32bit           (micro_operand_32bit),           //input
    .micro_address_32bit           (micro_address_32bit),           //input
    .micro_prefix_group_1_rep      (micro_prefix_group_1_rep),      //input [1:0]
    .micro_prefix_group_1_lock     (micro_prefix_group_1_lock),     //input
    .micro_prefix_group_2_seg      (micro_prefix_group_2_seg),      //input [2:0]
    .micro_prefix_2byte            (micro_prefix_2byte),            //input
    .micro_consumed                (micro_consumed),                //input [3:0]
    .micro_modregrm_len            (micro_modregrm_len),            //input [2:0]
    .micro_is_8bit                 (micro_is_8bit),                 //input
    .micro_cmd                     (micro_cmd),                     //input [6:0]
    .micro_cmdex                   (micro_cmdex),                   //input [3:0]
    
    //rd pipeline
    .exe_busy                      (exe_busy),                      //input
    .rd_ready                      (rd_ready),                      //output
    
    .rd_decoder                    (rd_decoder),                    //output [87:0]
    .rd_eip                        (rd_eip),                        //output [31:0]
    .rd_operand_32bit              (rd_operand_32bit),              //output
    .rd_address_32bit              (rd_address_32bit),              //output
    .rd_prefix_group_1_rep         (rd_prefix_group_1_rep),         //output [1:0]
    .rd_prefix_group_1_lock        (rd_prefix_group_1_lock),        //output
    .rd_prefix_2byte               (rd_prefix_2byte),               //output
    .rd_consumed                   (rd_consumed),                   //output [3:0]
    .rd_is_8bit                    (rd_is_8bit),                    //output
    .rd_cmd                        (rd_cmd),                        //output [6:0]
    .rd_cmdex                      (rd_cmdex),                      //output [3:0]
    .rd_modregrm_imm               (rd_modregrm_imm),               //output [31:0]
    .rd_mutex_next                 (rd_mutex_next),                 //output [10:0]
    .rd_dst_is_reg                 (rd_dst_is_reg),                 //output
    .rd_dst_is_rm                  (rd_dst_is_rm),                  //output
    .rd_dst_is_memory              (rd_dst_is_memory),              //output
    .rd_dst_is_eax                 (rd_dst_is_eax),                 //output
    .rd_dst_is_edx_eax             (rd_dst_is_edx_eax),             //output
    .rd_dst_is_implicit_reg        (rd_dst_is_implicit_reg),        //output
    .rd_extra_wire                 (rd_extra_wire),                 //output [31:0]
    .rd_linear                     (rd_linear),                     //output [31:0]
    .rd_debug_read                 (rd_debug_read),                 //output [3:0]
    .src_wire                      (src_wire),                      //output [31:0]
    .dst_wire                      (dst_wire),                      //output [31:0]
    .rd_address_effective          (rd_address_effective)           //output [31:0]
);

//------------------------------------------------------------------------------

wire [31:0] wr_stack_offset;
wire [1:0]  wr_task_rpl;
    
wire        dr6_bd_set;

wire [31:0]  exe_buffer;
wire [463:0] exe_buffer_shifted;

wire        wr_busy;
wire        exe_ready;
wire [39:0] exe_decoder;
wire [31:0] exe_eip_final;
wire        exe_operand_32bit;
wire        exe_address_32bit;
wire [1:0]  exe_prefix_group_1_rep;
wire        exe_prefix_group_1_lock;
wire [3:0]  exe_consumed_final;
wire        exe_is_8bit_final;
wire [6:0]  exe_cmd;
wire [3:0]  exe_cmdex;
wire        exe_dst_is_reg;
wire        exe_dst_is_rm;
wire        exe_dst_is_memory;
wire        exe_dst_is_eax;
wire        exe_dst_is_edx_eax;
wire        exe_dst_is_implicit_reg;
wire [31:0] exe_linear;
wire [3:0]  exe_debug_read;
wire [31:0] exe_result;
wire [31:0] exe_result2;
wire [31:0] exe_result_push;
wire [4:0]  exe_result_signals;
wire [3:0]  exe_arith_index;
wire        exe_arith_sub_carry;
wire        exe_arith_add_carry;
wire        exe_arith_adc_carry;
wire        exe_arith_sbb_carry;
wire [31:0] src_final;
wire [31:0] dst_final;
wire        exe_mult_overflow;
wire [31:0] exe_stack_offset;

execute execute_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .exe_reset          (exe_reset),    //input
    
    //general input
    .eax                           (eax),                           //input [31:0]
    .ecx                           (ecx),                           //input [31:0]
    .edx                           (edx),                           //input [31:0]
    .ebp                           (ebp),                           //input [31:0]
    .esp                           (esp),                           //input [31:0]
    
    .cs_cache                      (cs_cache),                      //input [63:0]
    .tr_cache                      (tr_cache),                      //input [63:0]
    .ss_cache                      (ss_cache),                      //input [63:0]
    
    .es                            (es),                            //input [15:0]
    .cs                            (cs),                            //input [15:0]
    .ss                            (ss),                            //input [15:0]
    .ds                            (ds),                            //input [15:0]
    .fs                            (fs),                            //input [15:0]
    .gs                            (gs),                            //input [15:0]
    .ldtr                          (ldtr),                          //input [15:0]
    .tr                            (tr),                            //input [15:0]
    
    .cr2                           (cr2),                           //input [31:0]
    .cr3                           (cr3),                           //input [31:0]
    
    .dr0                           (dr0),                           //input [31:0]
    .dr1                           (dr1),                           //input [31:0]
    .dr2                           (dr2),                           //input [31:0]
    .dr3                           (dr3),                           //input [31:0]
    .dr6_bt                        (dr6_bt),                        //input
    .dr6_bs                        (dr6_bs),                        //input
    .dr6_bd                        (dr6_bd),                        //input
    .dr6_b12                       (dr6_b12),                       //input
    .dr6_breakpoints               (dr6_breakpoints),               //input [3:0]
    .dr7                           (dr7),                           //input [31:0]
    
    .cpl                           (cpl),                           //input [1:0]
    
    .real_mode                     (real_mode),                     //input
    .v8086_mode                    (v8086_mode),                    //input
    .protected_mode                (protected_mode),                //input
    
    .idflag                        (idflag),                        //input
    .acflag                        (acflag),                        //input
    .vmflag                        (vmflag),                        //input
    .rflag                         (rflag),                         //input
    .ntflag                        (ntflag),                        //input
    .iopl                          (iopl),                          //input [1:0]
    .oflag                         (oflag),                         //input
    .dflag                         (dflag),                         //input
    .iflag                         (iflag),                         //input
    .tflag                         (tflag),                         //input
    .sflag                         (sflag),                         //input
    .zflag                         (zflag),                         //input
    .aflag                         (aflag),                         //input
    .pflag                         (pflag),                         //input
    .cflag                         (cflag),                         //input
    
    .cr0_pg                        (cr0_pg),                        //input
    .cr0_cd                        (cr0_cd),                        //input
    .cr0_nw                        (cr0_nw),                        //input
    .cr0_am                        (cr0_am),                        //input
    .cr0_wp                        (cr0_wp),                        //input
    .cr0_ne                        (cr0_ne),                        //input
    .cr0_ts                        (cr0_ts),                        //input
    .cr0_em                        (cr0_em),                        //input
    .cr0_mp                        (cr0_mp),                        //input
    .cr0_pe                        (cr0_pe),                        //input
    
    .idtr_limit                    (idtr_limit),                    //input [15:0]
    .idtr_base                     (idtr_base),                     //input [31:0]
    .gdtr_limit                    (gdtr_limit),                    //input [15:0]
    .gdtr_base                     (gdtr_base),                     //input [31:0]
    
    //exception input
    .exc_push_error                (exc_push_error),                //input
    .exc_error_code                (exc_error_code),                //input [15:0]
    .exc_soft_int_ib               (exc_soft_int_ib),               //input
    .exc_soft_int                  (exc_soft_int),                  //input
    .exc_vector                    (exc_vector),                    //input [7:0]
    
    //tlbcheck
    .tlbcheck_do                   (tlbcheck_do),                   //output
    .tlbcheck_done                 (tlbcheck_done),                 //input
    .tlbcheck_page_fault           (tlbcheck_page_fault),           //input
    .tlbcheck_address              (tlbcheck_address),              //output [31:0]
    .tlbcheck_rw                   (tlbcheck_rw),                   //output
    
    //tlbflushsingle
    .tlbflushsingle_do             (tlbflushsingle_do),             //output
    .tlbflushsingle_done           (tlbflushsingle_done),           //input
    .tlbflushsingle_address        (tlbflushsingle_address),        //output [31:0]
    
    //invd
    .invdcode_do                   (invdcode_do),                   //output
    .invdcode_done                 (invdcode_done),                 //input
    
    .invddata_do                   (invddata_do),                   //output
    .invddata_done                 (invddata_done),                 //input
    
    .wbinvddata_do                 (wbinvddata_do),                 //output
    .wbinvddata_done               (wbinvddata_done),               //input
    
    //pipeline input
    .wr_esp_prev                   (wr_esp_prev),      //input [31:0]
    .wr_stack_offset               (wr_stack_offset),   //input [31:0]
    
    .wr_mutex                      (wr_mutex),                      //input [10:0]
    
    //pipeline output
    .exe_is_front           (exe_is_front),   //output
    
    //global input
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    .glob_descriptor_2             (glob_descriptor_2),             //input [63:0]
    
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    .glob_param_2                  (glob_param_2),                  //input [31:0]
    .glob_param_3                  (glob_param_3),                  //input [31:0]
    .glob_param_4                  (glob_param_4),                  //input [31:0]
    .glob_param_5                  (glob_param_5),                  //input [31:0]
    
    .wr_task_rpl                   (wr_task_rpl),                   //input [1:0]
    
    .glob_desc_base                (glob_desc_base),                //input [31:0]
    .glob_desc_limit               (glob_desc_limit),               //input [31:0]
    .glob_desc_2_limit             (glob_desc_2_limit),             //input [31:0]
    
    //global set
    .exe_glob_descriptor_set       (exe_glob_descriptor_set),       //output
    .exe_glob_descriptor_value     (exe_glob_descriptor_value),     //output [63:0]
    
    .exe_glob_descriptor_2_set     (exe_glob_descriptor_2_set),     //output
    .exe_glob_descriptor_2_value   (exe_glob_descriptor_2_value),   //output [63:0]
    
    .exe_glob_param_1_set          (exe_glob_param_1_set),          //output
    .exe_glob_param_1_value        (exe_glob_param_1_value),        //output [31:0]
    .exe_glob_param_2_set          (exe_glob_param_2_set),          //output
    .exe_glob_param_2_value        (exe_glob_param_2_value),        //output [31:0]
    .exe_glob_param_3_set          (exe_glob_param_3_set),          //output
    .exe_glob_param_3_value        (exe_glob_param_3_value),        //output [31:0]
    
    //wr set
    .dr6_bd_set             (dr6_bd_set),           //output
    
    //to microcode
    .task_eip               (task_eip),             //output [31:0]
    //to wr
    .exe_buffer             (exe_buffer),           //output [31:0]
    .exe_buffer_shifted     (exe_buffer_shifted),   //output [463:0]
    
    //exceptions
    .exe_bound_fault               (exe_bound_fault),               //output
    .exe_trigger_gp_fault          (exe_trigger_gp_fault),          //output
    .exe_trigger_ts_fault          (exe_trigger_ts_fault),          //output
    .exe_trigger_ss_fault          (exe_trigger_ss_fault),          //output
    .exe_trigger_np_fault          (exe_trigger_np_fault),          //output
    .exe_trigger_pf_fault          (exe_trigger_pf_fault),          //output
    .exe_trigger_db_fault          (exe_trigger_db_fault),          //output
    .exe_trigger_nm_fault          (exe_trigger_nm_fault),          //output
    .exe_load_seg_gp_fault         (exe_load_seg_gp_fault),         //output
    .exe_load_seg_ss_fault         (exe_load_seg_ss_fault),         //output
    .exe_load_seg_np_fault         (exe_load_seg_np_fault),         //output
    .exe_div_exception             (exe_div_exception),             //output
    
    .exe_error_code                (exe_error_code),                //output [15:0]
    
    .exe_eip                       (exe_eip),                       //output [31:0]
    .exe_consumed                  (exe_consumed),                  //output [3:0]
                     
    //rd pipeline
    .exe_busy                      (exe_busy),                      //output
    .rd_ready                      (rd_ready),                      //input
    .rd_decoder                    (rd_decoder),                    //input [87:0]
    .rd_eip                        (rd_eip),                        //input [31:0]
    .rd_operand_32bit              (rd_operand_32bit),              //input
    .rd_address_32bit              (rd_address_32bit),              //input
    .rd_prefix_group_1_rep         (rd_prefix_group_1_rep),         //input [1:0]
    .rd_prefix_group_1_lock        (rd_prefix_group_1_lock),        //input
    .rd_prefix_2byte               (rd_prefix_2byte),               //input
    .rd_consumed                   (rd_consumed),                   //input [3:0]
    .rd_is_8bit                    (rd_is_8bit),                    //input
    .rd_cmd                        (rd_cmd),                        //input [6:0]
    .rd_cmdex                      (rd_cmdex),                      //input [3:0]
    .rd_modregrm_imm               (rd_modregrm_imm),               //input [31:0]
    .rd_mutex_next                 (rd_mutex_next),                 //input [10:0]
    .rd_dst_is_reg                 (rd_dst_is_reg),                 //input
    .rd_dst_is_rm                  (rd_dst_is_rm),                  //input
    .rd_dst_is_memory              (rd_dst_is_memory),              //input
    .rd_dst_is_eax                 (rd_dst_is_eax),                 //input
    .rd_dst_is_edx_eax             (rd_dst_is_edx_eax),             //input
    .rd_dst_is_implicit_reg        (rd_dst_is_implicit_reg),        //input
    .rd_extra_wire                 (rd_extra_wire),                 //input [31:0]
    .rd_linear                     (rd_linear),                     //input [31:0]
    .rd_debug_read                 (rd_debug_read),                 //input [3:0]
    .src_wire                      (src_wire),                      //input [31:0]
    .dst_wire                      (dst_wire),                      //input [31:0]
    .rd_address_effective          (rd_address_effective),          //input [31:0]
    
    //exe pipeline
    .wr_busy                       (wr_busy),                       //input
    .exe_ready                     (exe_ready),                     //output
    
    .exe_decoder                   (exe_decoder),                   //output [39:0]
    .exe_eip_final                 (exe_eip_final),                 //output [31:0]
    .exe_operand_32bit             (exe_operand_32bit),             //output
    .exe_address_32bit             (exe_address_32bit),             //output
    .exe_prefix_group_1_rep        (exe_prefix_group_1_rep),        //output [1:0]
    .exe_prefix_group_1_lock       (exe_prefix_group_1_lock),       //output
    .exe_consumed_final            (exe_consumed_final),            //output [3:0]
    .exe_is_8bit_final             (exe_is_8bit_final),             //output
    .exe_cmd                       (exe_cmd),                       //output [6:0]
    .exe_cmdex                     (exe_cmdex),                     //output [3:0]
    .exe_mutex                     (exe_mutex),                     //output [10:0]
    .exe_dst_is_reg                (exe_dst_is_reg),                //output
    .exe_dst_is_rm                 (exe_dst_is_rm),                 //output
    .exe_dst_is_memory             (exe_dst_is_memory),             //output
    .exe_dst_is_eax                (exe_dst_is_eax),                //output
    .exe_dst_is_edx_eax            (exe_dst_is_edx_eax),            //output
    .exe_dst_is_implicit_reg       (exe_dst_is_implicit_reg),       //output
    .exe_linear                    (exe_linear),                    //output [31:0]
    .exe_debug_read                (exe_debug_read),                //output [3:0]
    .exe_result                    (exe_result),                    //output [31:0]
    .exe_result2                   (exe_result2),                   //output [31:0]
    .exe_result_push               (exe_result_push),               //output [31:0]
    .exe_result_signals            (exe_result_signals),            //output [4:0]
    .exe_arith_index               (exe_arith_index),               //output [3:0]
    .exe_arith_sub_carry           (exe_arith_sub_carry),           //output
    .exe_arith_add_carry           (exe_arith_add_carry),           //output
    .exe_arith_adc_carry           (exe_arith_adc_carry),           //output
    .exe_arith_sbb_carry           (exe_arith_sbb_carry),           //output
    .src_final                     (src_final),                     //output [31:0]
    .dst_final                     (dst_final),                     //output [31:0]
    .exe_mult_overflow             (exe_mult_overflow),             //output
    .exe_stack_offset              (exe_stack_offset)               //output [31:0]
);

//------------------------------------------------------------------------------

write write_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .exe_reset          (exe_reset),  //input
    .wr_reset           (wr_reset),   //input
    
    //global input
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    .glob_descriptor_2             (glob_descriptor_2),             //input [63:0]
    .glob_desc_base                (glob_desc_base),                //input [31:0]
    .glob_desc_limit               (glob_desc_limit),               //input [31:0]
    
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    .glob_param_2                  (glob_param_2),                  //input [31:0]
    .glob_param_3                  (glob_param_3),                  //input [31:0]
    .glob_param_4                  (glob_param_4),                  //input [31:0]
    .glob_param_5                  (glob_param_5),                  //input [31:0]
    
    //general input
    .eip                           (eip),                           //input [31:0]
    
    //registers output
    .gdtr_base                     (gdtr_base),                     //output [31:0]
    .gdtr_limit                    (gdtr_limit),                    //output [15:0]
    
    .idtr_base                     (idtr_base),                     //output [31:0]
    .idtr_limit                    (idtr_limit),                    //output [15:0]
    
    //pipeline input
    .exe_buffer                    (exe_buffer),                    //input [31:0]
    .exe_buffer_shifted            (exe_buffer_shifted),            //input [463:0]
    
    .dr6_bd_set                    (dr6_bd_set),                    //input
    
    //interrupt input
    .interrupt_do                  (interrupt_do),                  //input
    
    //exception input
    .exc_init                      (exc_init),                      //input
    .exc_set_rflag                 (exc_set_rflag),                 //input
    .exc_debug_start               (exc_debug_start),               //input
    .exc_pf_read                   (exc_pf_read),                   //input
    .exc_pf_write                  (exc_pf_write),                  //input
    .exc_pf_code                   (exc_pf_code),                   //input
    .exc_pf_check                  (exc_pf_check),                  //input
    .exc_restore_esp               (exc_restore_esp),               //input
    .exc_push_error                (exc_push_error),                //input
    .exc_eip                       (exc_eip),                       //input [31:0]
    
    //output
    .real_mode                     (real_mode),                     //output
    .v8086_mode                    (v8086_mode),                    //output
    .protected_mode                (protected_mode),                //output
    
    .cpl                           (cpl),                           //output [1:0]
    
    .io_allow_check_needed      (io_allow_check_needed), //output
    
    .debug_len0                    (debug_len0),                    //output [2:0]
    .debug_len1                    (debug_len1),                    //output [2:0]
    .debug_len2                    (debug_len2),                    //output [2:0]
    .debug_len3                    (debug_len3),                    //output [2:0]
    
    //wr output
    .wr_is_front                   (wr_is_front),                   //output
    
    .wr_interrupt_possible         (wr_interrupt_possible),         //output
    .wr_string_in_progress_final   (wr_string_in_progress_final),   //output
    .wr_is_esp_speculative         (wr_is_esp_speculative),         //output
    
    .wr_mutex                      (wr_mutex),                      //output [10:0]
    
    .wr_stack_offset               (wr_stack_offset),               //output [31:0]
    .wr_esp_prev                   (wr_esp_prev),                   //output [31:0]
    
    .wr_task_rpl                   (wr_task_rpl),                   //output [1:0]

    .wr_consumed                   (wr_consumed),                   //output [3:0]
    
    //software interrupt
    .wr_int                        (wr_int),                        //output
    .wr_int_soft_int               (wr_int_soft_int),               //output
    .wr_int_soft_int_ib            (wr_int_soft_int_ib),            //output
    .wr_int_vector                 (wr_int_vector),                 //output [7:0]
    
    .wr_exception_external_set     (wr_exception_external_set),     //output
    .wr_exception_finished         (wr_exception_finished),         //output
    
    .wr_error_code                 (wr_error_code),                 //output [15:0]
    
    //wr exception
    .wr_debug_init                 (wr_debug_init),                 //output
    
    .wr_new_push_ss_fault          (wr_new_push_ss_fault),          //output
    .wr_string_es_fault            (wr_string_es_fault),            //output
    .wr_push_ss_fault              (wr_push_ss_fault),              //output
    
    //eip control
    .wr_eip                         (wr_eip),                       //output [31:0]
    
    //reset request
    .wr_req_reset_pr               (wr_req_reset_pr),               //output
    .wr_req_reset_dec              (wr_req_reset_dec),              //output
    .wr_req_reset_micro            (wr_req_reset_micro),            //output
    .wr_req_reset_rd               (wr_req_reset_rd),               //output
    .wr_req_reset_exe              (wr_req_reset_exe),              //output
        
    //memory page fault
    .tlb_code_pf_cr2               (tlb_code_pf_cr2),               //input [31:0]
    .tlb_write_pf_cr2              (tlb_write_pf_cr2),              //input [31:0]
    .tlb_read_pf_cr2               (tlb_read_pf_cr2),               //input [31:0]
    .tlb_check_pf_cr2              (tlb_check_pf_cr2),              //input [31:0]
    
    //memory write
    .write_do                      (write_do),                      //output
    .write_done                    (write_done),                    //input
    .write_page_fault              (write_page_fault),              //input
    .write_ac_fault                (write_ac_fault),                //input
    .write_cpl                     (write_cpl),                     //output [1:0]
    .write_address                 (write_address),                 //output [31:0]
    .write_length                  (write_length),                  //output [2:0]
    .write_lock                    (write_lock),                    //output
    .write_rmw                     (write_rmw),                     //output
    .write_data                    (write_data),                    //output [31:0]
    
    //flush tlb             
    .tlbflushall_do                (tlbflushall_do),                //output
    
    //io write
    .io_write_do                   (io_write_do),                   //output
    .io_write_address              (io_write_address),              //output [15:0]
    .io_write_length               (io_write_length),               //output [2:0]
    .io_write_data                 (io_write_data),                 //output [31:0]
    .io_write_done                 (io_write_done),                 //input
    
    //global write
    .wr_glob_param_1_set           (wr_glob_param_1_set),           //output
    .wr_glob_param_1_value         (wr_glob_param_1_value),         //output [31:0]
    .wr_glob_param_3_set           (wr_glob_param_3_set),           //output
    .wr_glob_param_3_value         (wr_glob_param_3_value),         //output [31:0]
    .wr_glob_param_4_set           (wr_glob_param_4_set),           //output
    .wr_glob_param_4_value         (wr_glob_param_4_value),         //output [31:0]
    
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
                 
    //pipeline wr
    .wr_busy                       (wr_busy),                       //output
    .exe_ready                     (exe_ready),                     //input
    
    .exe_decoder                   (exe_decoder),                   //input [39:0]
    .exe_eip_final                 (exe_eip_final),                 //input [31:0]
    .exe_operand_32bit             (exe_operand_32bit),             //input
    .exe_address_32bit             (exe_address_32bit),             //input
    .exe_prefix_group_1_rep        (exe_prefix_group_1_rep),        //input [1:0]
    .exe_prefix_group_1_lock       (exe_prefix_group_1_lock),       //input
    .exe_consumed_final            (exe_consumed_final),            //input [3:0]
    .exe_is_8bit_final             (exe_is_8bit_final),             //input
    .exe_cmd                       (exe_cmd),                       //input [6:0]
    .exe_cmdex                     (exe_cmdex),                     //input [3:0]
    .exe_mutex                     (exe_mutex),                     //input [10:0]
    .exe_dst_is_reg                (exe_dst_is_reg),                //input
    .exe_dst_is_rm                 (exe_dst_is_rm),                 //input
    .exe_dst_is_memory             (exe_dst_is_memory),             //input
    .exe_dst_is_eax                (exe_dst_is_eax),                //input
    .exe_dst_is_edx_eax            (exe_dst_is_edx_eax),            //input
    .exe_dst_is_implicit_reg       (exe_dst_is_implicit_reg),       //input
    .exe_linear                    (exe_linear),                    //input [31:0]
    .exe_debug_read                (exe_debug_read),                //input [3:0]
    .exe_result                    (exe_result),                    //input [31:0]
    .exe_result2                   (exe_result2),                   //input [31:0]
    .exe_result_push               (exe_result_push),               //input [31:0]
    .exe_result_signals            (exe_result_signals),            //input [4:0]
    .exe_arith_index               (exe_arith_index),               //input [3:0]
    .exe_arith_sub_carry           (exe_arith_sub_carry),           //input
    .exe_arith_add_carry           (exe_arith_add_carry),           //input
    .exe_arith_adc_carry           (exe_arith_adc_carry),           //input
    .exe_arith_sbb_carry           (exe_arith_sbb_carry),           //input
    .src_final                     (src_final),                     //input [31:0]
    .dst_final                     (dst_final),                     //input [31:0]
    .exe_mult_overflow             (exe_mult_overflow),             //input
    .exe_stack_offset              (exe_stack_offset)               //input [31:0]
);


//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------



endmodule
