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

module ao486 (
    input               clk,
    input               rst_n,
    
    //--------------------------------------------------------------------------
    input               interrupt_do,
    input   [7:0]       interrupt_vector,
    output              interrupt_done,
    
    //-------------------------------------------------------------------------- Altera Avalon memory bus
    output      [31:0]  avm_address,
    output      [31:0]  avm_writedata,
    output      [3:0]   avm_byteenable,
    output      [2:0]   avm_burstcount,
    output              avm_write,
    output              avm_read,
    
    input               avm_waitrequest,
    input               avm_readdatavalid,
    input       [31:0]  avm_readdata,
    
    //-------------------------------------------------------------------------- Altera Avalon io bus
    output  [15:0]      avalon_io_address,
    output  [3:0]       avalon_io_byteenable,
    
    output              avalon_io_read,
    input               avalon_io_readdatavalid,
    input   [31:0]      avalon_io_readdata,
    
    output              avalon_io_write,
    output  [31:0]      avalon_io_writedata,
    
    input               avalon_io_waitrequest
);

//------------------------------------------------------------------------------

wire        dec_gp_fault;
wire        dec_ud_fault;
wire        dec_pf_fault;
wire        rd_seg_gp_fault;
wire        rd_descriptor_gp_fault;
wire        rd_seg_ss_fault;
wire        rd_io_allow_fault;
wire        rd_ss_esp_from_tss_fault;
wire        exe_div_exception;
wire        exe_trigger_gp_fault;
wire        exe_trigger_ts_fault;
wire        exe_trigger_ss_fault;
wire        exe_trigger_np_fault;
wire        exe_trigger_nm_fault;
wire        exe_trigger_db_fault;
wire        exe_trigger_pf_fault;
wire        exe_bound_fault;
wire        exe_load_seg_gp_fault;
wire        exe_load_seg_ss_fault;
wire        exe_load_seg_np_fault;
wire        wr_debug_init;
wire        wr_new_push_ss_fault;
wire        wr_string_es_fault;
wire        wr_push_ss_fault;

wire        read_ac_fault;
wire        read_page_fault;
wire        write_ac_fault;
wire        write_page_fault;
wire [15:0] tlb_code_pf_error_code;
wire [15:0] tlb_check_pf_error_code;
wire [15:0] tlb_write_pf_error_code;
wire [15:0] tlb_read_pf_error_code;

wire        wr_int;
wire        wr_int_soft_int;
wire        wr_int_soft_int_ib;
wire [7:0]  wr_int_vector;
wire        wr_exception_external_set;
wire        wr_exception_finished;

wire [31:0] eip;
wire [31:0] dec_eip;
wire [31:0] rd_eip;
wire [31:0] exe_eip;
wire [31:0] wr_eip;
wire [3:0]  rd_consumed;
wire [3:0]  exe_consumed;
wire [3:0]  wr_consumed;

wire        rd_dec_is_front;
wire        rd_is_front;
wire        exe_is_front;
wire        wr_is_front;

wire        wr_interrupt_possible;
wire        wr_string_in_progress_final;
wire        wr_is_esp_speculative;

wire        real_mode;

wire [15:0] rd_error_code;
wire [15:0] exe_error_code;
wire [15:0] wr_error_code;

wire        exc_dec_reset;
wire        exc_micro_reset;
wire        exc_rd_reset;
wire        exc_exe_reset;
wire        exc_wr_reset;

wire        exc_restore_esp;
wire        exc_set_rflag;
wire        exc_debug_start;
wire        exc_init;
wire        exc_load;
wire [31:0] exc_eip;
wire [7:0]  exc_vector;
wire [15:0] exc_error_code;
wire        exc_push_error;
wire        exc_soft_int;
wire        exc_soft_int_ib;
wire        exc_pf_read;
wire        exc_pf_write;
wire        exc_pf_code;
wire        exc_pf_check;

exception exception_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //exception indicators
    .dec_gp_fault                  (dec_gp_fault),                  //input
    .dec_ud_fault                  (dec_ud_fault),                  //input
    .dec_pf_fault                  (dec_pf_fault),                  //input
    
    .rd_seg_gp_fault               (rd_seg_gp_fault),               //input
    .rd_descriptor_gp_fault        (rd_descriptor_gp_fault),        //input
    .rd_seg_ss_fault               (rd_seg_ss_fault),               //input
    .rd_io_allow_fault             (rd_io_allow_fault),             //input
    .rd_ss_esp_from_tss_fault      (rd_ss_esp_from_tss_fault),      //input
    
    .exe_div_exception             (exe_div_exception),             //input
    .exe_trigger_gp_fault          (exe_trigger_gp_fault),          //input
    .exe_trigger_ts_fault          (exe_trigger_ts_fault),          //input
    .exe_trigger_ss_fault          (exe_trigger_ss_fault),          //input
    .exe_trigger_np_fault          (exe_trigger_np_fault),          //input
    .exe_trigger_nm_fault          (exe_trigger_nm_fault),          //input
    .exe_trigger_db_fault          (exe_trigger_db_fault),          //input
    .exe_trigger_pf_fault          (exe_trigger_pf_fault),          //input
    .exe_bound_fault               (exe_bound_fault),               //input
    .exe_load_seg_gp_fault         (exe_load_seg_gp_fault),         //input
    .exe_load_seg_ss_fault         (exe_load_seg_ss_fault),         //input
    .exe_load_seg_np_fault         (exe_load_seg_np_fault),         //input
    
    .wr_debug_init                 (wr_debug_init),                 //input
    .wr_new_push_ss_fault          (wr_new_push_ss_fault),          //input
    .wr_string_es_fault            (wr_string_es_fault),            //input
    .wr_push_ss_fault              (wr_push_ss_fault),              //input
    
    //from memory
    .read_ac_fault                 (read_ac_fault),                 //input
    .read_page_fault               (read_page_fault),               //input
    
    .write_ac_fault                (write_ac_fault),                //input
    .write_page_fault              (write_page_fault),              //input
    
    .tlb_code_pf_error_code        (tlb_code_pf_error_code),        //input [15:0]
    .tlb_check_pf_error_code       (tlb_check_pf_error_code),       //input [15:0]
    .tlb_write_pf_error_code       (tlb_write_pf_error_code),       //input [15:0]
    .tlb_read_pf_error_code        (tlb_read_pf_error_code),        //input [15:0]
    
    //wr_int
    .wr_int                        (wr_int),                        //input
    .wr_int_soft_int               (wr_int_soft_int),               //input
    .wr_int_soft_int_ib            (wr_int_soft_int_ib),            //input
    .wr_int_vector                 (wr_int_vector),                 //input [7:0]
    
    .wr_exception_external_set     (wr_exception_external_set),     //input
    .wr_exception_finished         (wr_exception_finished),         //input
    
    //eip
    .eip                           (eip),                           //input [31:0]
    .dec_eip                       (dec_eip),                       //input [31:0]
    .rd_eip                        (rd_eip),                        //input [31:0]
    .exe_eip                       (exe_eip),                       //input [31:0]
    .wr_eip                        (wr_eip),                        //input [31:0]
    
    .rd_consumed                   (rd_consumed),                   //input [3:0]
    .exe_consumed                  (exe_consumed),                  //input [3:0]
    .wr_consumed                   (wr_consumed),                   //input [3:0]
    
    //pipeline
    .rd_dec_is_front               (rd_dec_is_front),               //input
    .rd_is_front                   (rd_is_front),                   //input
    .exe_is_front                  (exe_is_front),                  //input
    .wr_is_front                   (wr_is_front),                   //input
    
    //interrupt
    .interrupt_vector              (interrupt_vector),              //input [7:0]
    .interrupt_done                (interrupt_done),                //output
    
    //input
    .wr_interrupt_possible         (wr_interrupt_possible),         //input
    .wr_string_in_progress_final   (wr_string_in_progress_final),   //input
    .wr_is_esp_speculative         (wr_is_esp_speculative),         //input
    
    .real_mode                     (real_mode),                     //input
    
    .rd_error_code                 (rd_error_code),                 //input [15:0]
    .exe_error_code                (exe_error_code),                //input [15:0]
    .wr_error_code                 (wr_error_code),                 //input [15:0]
    
    //output
    .exc_dec_reset                 (exc_dec_reset),                 //output
    .exc_micro_reset               (exc_micro_reset),               //output
    .exc_rd_reset                  (exc_rd_reset),                  //output
    .exc_exe_reset                 (exc_exe_reset),                 //output
    .exc_wr_reset                  (exc_wr_reset),                  //output
    
    //exception output
    .exc_restore_esp               (exc_restore_esp),               //output
    .exc_set_rflag                 (exc_set_rflag),                 //output
    .exc_debug_start               (exc_debug_start),               //output
    
    .exc_init                      (exc_init),                      //output
    .exc_load                      (exc_load),                      //output
    .exc_eip                       (exc_eip),                       //output [31:0]
    
    .exc_vector                    (exc_vector),                    //output [7:0]
    .exc_error_code                (exc_error_code),                //output [15:0]
    .exc_push_error                (exc_push_error),                //output
    .exc_soft_int                  (exc_soft_int),                  //output
    .exc_soft_int_ib               (exc_soft_int_ib),               //output
    
    .exc_pf_read                   (exc_pf_read),                   //output
    .exc_pf_write                  (exc_pf_write),                  //output
    .exc_pf_code                   (exc_pf_code),                   //output
    .exc_pf_check                  (exc_pf_check)                  //output
);

//------------------------------------------------------------------------------

wire        io_read_do;
wire [15:0] io_read_address;
wire [2:0]  io_read_length;
wire [31:0] io_read_data;
wire        io_read_done;

wire        io_write_do;
wire [15:0] io_write_address;
wire [2:0]  io_write_length;
wire [31:0] io_write_data;
wire        io_write_done;

avalon_io avalon_io_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //io_read
    .io_read_do                    (io_read_do),                    //input
    .io_read_address               (io_read_address),               //input [15:0]
    .io_read_length                (io_read_length),                //input [2:0]
    .io_read_data                  (io_read_data),                  //output [31:0]
    .io_read_done                  (io_read_done),                  //output
    
    //io_write
    .io_write_do                   (io_write_do),                   //input
    .io_write_address              (io_write_address),              //input [15:0]
    .io_write_length               (io_write_length),               //input [2:0]
    .io_write_data                 (io_write_data),                 //input [31:0]
    .io_write_done                 (io_write_done),                 //output
    
    .dcache_busy                   (dcache_busy),                   //input
    
    //Avalon
    .avalon_io_address             (avalon_io_address),             //output [15:0]
    .avalon_io_byteenable          (avalon_io_byteenable),          //output [3:0]
    
    .avalon_io_read                (avalon_io_read),                //output
    .avalon_io_readdatavalid       (avalon_io_readdatavalid),       //input
    .avalon_io_readdata            (avalon_io_readdata),            //input [31:0]
    
    .avalon_io_write               (avalon_io_write),               //output
    .avalon_io_writedata           (avalon_io_writedata),           //output [31:0]
    .avalon_io_waitrequest         (avalon_io_waitrequest)          //input
);

//------------------------------------------------------------------------------

wire        glob_param_1_set;
wire [31:0] glob_param_1_value;
wire        glob_param_2_set;
wire [31:0] glob_param_2_value;
wire        glob_param_3_set;
wire [31:0] glob_param_3_value;
wire        glob_param_4_set;
wire [31:0] glob_param_4_value;
wire        glob_param_5_set;
wire [31:0] glob_param_5_value;
wire        glob_descriptor_set;
wire [63:0] glob_descriptor_value;
wire        glob_descriptor_2_set;
wire [63:0] glob_descriptor_2_value;
wire [31:0] glob_param_1;
wire [31:0] glob_param_2;
wire [31:0] glob_param_3;
wire [31:0] glob_param_4;
wire [31:0] glob_param_5;
wire [63:0] glob_descriptor;
wire [63:0] glob_descriptor_2;
wire [31:0] glob_desc_base;
wire [31:0] glob_desc_limit;
wire [31:0] glob_desc_2_limit;

global_regs global_regs_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //input
    .glob_param_1_set              (glob_param_1_set),              //input
    .glob_param_1_value            (glob_param_1_value),            //input [31:0]
    .glob_param_2_set              (glob_param_2_set),              //input
    .glob_param_2_value            (glob_param_2_value),            //input [31:0]
    .glob_param_3_set              (glob_param_3_set),              //input
    .glob_param_3_value            (glob_param_3_value),            //input [31:0]
    .glob_param_4_set              (glob_param_4_set),              //input
    .glob_param_4_value            (glob_param_4_value),            //input [31:0]
    .glob_param_5_set              (glob_param_5_set),              //input
    .glob_param_5_value            (glob_param_5_value),            //input [31:0]
    .glob_descriptor_set           (glob_descriptor_set),           //input
    .glob_descriptor_value         (glob_descriptor_value),         //input [63:0]
    .glob_descriptor_2_set         (glob_descriptor_2_set),         //input
    .glob_descriptor_2_value       (glob_descriptor_2_value),       //input [63:0]
    
    //output
    .glob_param_1                  (glob_param_1),                  //output [31:0]
    .glob_param_2                  (glob_param_2),                  //output [31:0]
    .glob_param_3                  (glob_param_3),                  //output [31:0]
    .glob_param_4                  (glob_param_4),                  //output [31:0]
    .glob_param_5                  (glob_param_5),                  //output [31:0]
    .glob_descriptor               (glob_descriptor),               //output [63:0]
    .glob_descriptor_2             (glob_descriptor_2),             //output [63:0]
    .glob_desc_base                (glob_desc_base),                //output [31:0]
    .glob_desc_limit               (glob_desc_limit),               //output [31:0]
    .glob_desc_2_limit             (glob_desc_2_limit)              //output [31:0]
);

//------------------------------------------------------------------------------

wire        read_do;
wire        read_done;

wire [1:0]  read_cpl;
wire [31:0] read_address;
wire [3:0]  read_length;
wire        read_lock;
wire        read_rmw;
wire [63:0] read_data;

wire        write_do;
wire        write_done;

wire [1:0]  write_cpl;
wire [31:0] write_address;
wire [2:0]  write_length;
wire        write_lock;
wire        write_rmw;
wire [31:0] write_data;

wire        tlbcheck_do;
wire        tlbcheck_done;
wire        tlbcheck_page_fault;
wire [31:0] tlbcheck_address;
wire        tlbcheck_rw;

wire        dcache_busy;

wire        tlbflushsingle_do;
wire        tlbflushsingle_done;
wire [31:0] tlbflushsingle_address;

wire        tlbflushall_do;
wire        invdcode_do;
wire        invdcode_done;
wire        invddata_do;
wire        invddata_done;
wire        wbinvddata_do;
wire        wbinvddata_done;

wire [1:0]  prefetch_cpl;
wire [31:0] prefetch_eip;
wire [63:0] cs_cache;

wire        cr0_pg;
wire        cr0_wp;
wire        cr0_am;
wire        cr0_cd;
wire        cr0_nw;

wire        acflag;

wire [31:0] cr3;

wire        prefetchfifo_accept_do;
wire [67:0] prefetchfifo_accept_data;
wire        prefetchfifo_accept_empty;

wire        pipeline_after_read_empty;
wire        pipeline_after_prefetch_empty;

wire [31:0] tlb_code_pf_cr2;
wire [31:0] tlb_check_pf_cr2;
wire [31:0] tlb_write_pf_cr2;
wire [31:0] tlb_read_pf_cr2;

wire        pr_reset;
wire        rd_reset;
wire        exe_reset;
wire        wr_reset;


memory memory_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //REQ:
    .read_do                       (read_do),                       //input
    .read_done                     (read_done),                     //output
    .read_page_fault               (read_page_fault),               //output
    .read_ac_fault                 (read_ac_fault),                 //output
    
    .read_cpl                      (read_cpl),                      //input [1:0]
    .read_address                  (read_address),                  //input [31:0]
    .read_length                   (read_length),                   //input [3:0]
    .read_lock                     (read_lock),                     //input
    .read_rmw                      (read_rmw),                      //input
    .read_data                     (read_data),                     //output [63:0]
    //END
    
    //REQ:
    .write_do                      (write_do),                      //input
    .write_done                    (write_done),                    //output
    .write_page_fault              (write_page_fault),              //output
    .write_ac_fault                (write_ac_fault),                //output
    
    .write_cpl                     (write_cpl),                     //input [1:0]
    .write_address                 (write_address),                 //input [31:0]
    .write_length                  (write_length),                  //input [2:0]
    .write_lock                    (write_lock),                    //input
    .write_rmw                     (write_rmw),                     //input
    .write_data                    (write_data),                    //input [31:0]
    //END
    
    //REQ:
    .tlbcheck_do                   (tlbcheck_do),                   //input
    .tlbcheck_done                 (tlbcheck_done),                 //output
    .tlbcheck_page_fault           (tlbcheck_page_fault),           //output
    
    .tlbcheck_address              (tlbcheck_address),              //input [31:0]
    .tlbcheck_rw                   (tlbcheck_rw),                   //input
    //END
    
    .dcache_busy                   (dcache_busy),                   //output
    
    //RESP:
    .tlbflushsingle_do             (tlbflushsingle_do),             //input
    .tlbflushsingle_done           (tlbflushsingle_done),           //output
    .tlbflushsingle_address        (tlbflushsingle_address),        //input [31:0]
    //END
    
    .tlbflushall_do                (tlbflushall_do),                //input
    
    .invdcode_do                   (invdcode_do),                   //input
    .invdcode_done                 (invdcode_done),                 //output
    
    .invddata_do                   (invddata_do),                   //input
    .invddata_done                 (invddata_done),                 //output
    
    .wbinvddata_do                 (wbinvddata_do),                 //input
    .wbinvddata_done               (wbinvddata_done),               //output
    
    // prefetch exported
    .prefetch_cpl                  (prefetch_cpl),                  //input [1:0]
    .prefetch_eip                  (prefetch_eip),                  //input [31:0]
    .cs_cache                      (cs_cache),                      //input [63:0]
    
    .cr0_pg                        (cr0_pg),                        //input
    .cr0_wp                        (cr0_wp),                        //input
    .cr0_am                        (cr0_am),                        //input
    .cr0_cd                        (cr0_cd),                        //input
    .cr0_nw                        (cr0_nw),                        //input
    
    .acflag                        (acflag),                        //input
    
    .cr3                           (cr3),                           //input [31:0]
    
    // prefetch_fifo exported
    .prefetchfifo_accept_do        (prefetchfifo_accept_do),        //input
    .prefetchfifo_accept_data      (prefetchfifo_accept_data),      //output [67:0]
    .prefetchfifo_accept_empty     (prefetchfifo_accept_empty),     //output
    
    // pipeline state
    .pipeline_after_read_empty     (pipeline_after_read_empty),     //input
    .pipeline_after_prefetch_empty (pipeline_after_prefetch_empty), //input
    
    .tlb_code_pf_error_code        (tlb_code_pf_error_code),        //output [15:0]
    .tlb_check_pf_error_code       (tlb_check_pf_error_code),       //output [15:0]
    .tlb_write_pf_error_code       (tlb_write_pf_error_code),       //output [15:0]
    .tlb_read_pf_error_code        (tlb_read_pf_error_code),        //output [15:0]
    
    .tlb_code_pf_cr2               (tlb_code_pf_cr2),               //output [31:0]
    .tlb_check_pf_cr2              (tlb_check_pf_cr2),              //output [31:0]
    .tlb_write_pf_cr2              (tlb_write_pf_cr2),              //output [31:0]
    .tlb_read_pf_cr2               (tlb_read_pf_cr2),               //output [31:0]
                   
    // reset exported
    .pr_reset                      (pr_reset),                      //input
    .rd_reset                      (rd_reset),                      //input
    .exe_reset                     (exe_reset),                     //input
    .wr_reset                      (wr_reset),                      //input
    
    // avalon master
    .avm_address                   (avm_address),                   //output [31:0]
    .avm_writedata                 (avm_writedata),                 //output [31:0]
    .avm_byteenable                (avm_byteenable),                //output [3:0]
    .avm_burstcount                (avm_burstcount),                //output [2:0]
    .avm_write                     (avm_write),                     //output
    .avm_read                      (avm_read),                      //output
    .avm_waitrequest               (avm_waitrequest),               //input
    .avm_readdatavalid             (avm_readdatavalid),             //input
    .avm_readdata                  (avm_readdata)                   //input [31:0]
);

//------------------------------------------------------------------------------

pipeline pipeline_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //to memory
    .pr_reset                      (pr_reset),                      //output
    .rd_reset                      (rd_reset),                      //output
    .exe_reset                     (exe_reset),                     //output
    .wr_reset                      (wr_reset),                      //output
                       
    .real_mode                     (real_mode),                     //output

    //exception
    .exc_restore_esp               (exc_restore_esp),               //input
    .exc_set_rflag                 (exc_set_rflag),                 //input
    .exc_debug_start               (exc_debug_start),               //input
    
    .exc_init                      (exc_init),                      //input
    .exc_load                      (exc_load),                      //input
    .exc_eip                       (exc_eip),                       //input [31:0]
    
    .exc_vector                    (exc_vector),                    //input [7:0]
    .exc_error_code                (exc_error_code),                //input [15:0]
    .exc_push_error                (exc_push_error),                //input
    .exc_soft_int                  (exc_soft_int),                  //input
    .exc_soft_int_ib               (exc_soft_int_ib),               //input
    
    .exc_pf_read                   (exc_pf_read),                   //input
    .exc_pf_write                  (exc_pf_write),                  //input
    .exc_pf_code                   (exc_pf_code),                   //input
    .exc_pf_check                  (exc_pf_check),                  //input
    
    //pipeline eip
    .eip                           (eip),                           //output [31:0]
    .dec_eip                       (dec_eip),                       //output [31:0]
    .rd_eip                        (rd_eip),                        //output [31:0]
    .exe_eip                       (exe_eip),                       //output [31:0]
    .wr_eip                        (wr_eip),                        //output [31:0]
    
    .rd_consumed                   (rd_consumed),                   //output [3:0]
    .exe_consumed                  (exe_consumed),                  //output [3:0]
    .wr_consumed                   (wr_consumed),                   //output [3:0]
    
    //exception reset
    .exc_dec_reset                 (exc_dec_reset),                 //input
    .exc_micro_reset               (exc_micro_reset),               //input
    .exc_rd_reset                  (exc_rd_reset),                  //input
    .exc_exe_reset                 (exc_exe_reset),                 //input
    .exc_wr_reset                  (exc_wr_reset),                  //input
    
    //global
    .glob_param_1                  (glob_param_1),                  //input [31:0]
    .glob_param_2                  (glob_param_2),                  //input [31:0]
    .glob_param_3                  (glob_param_3),                  //input [31:0]
    .glob_param_4                  (glob_param_4),                  //input [31:0]
    .glob_param_5                  (glob_param_5),                  //input [31:0]
    
    .glob_descriptor               (glob_descriptor),               //input [63:0]
    .glob_descriptor_2             (glob_descriptor_2),             //input [63:0]
    
    .glob_desc_base                (glob_desc_base),                //input [31:0]
    
    .glob_desc_limit               (glob_desc_limit),               //input [31:0]
    .glob_desc_2_limit             (glob_desc_2_limit),             //input [31:0]
    
    //pipeline state
    .rd_dec_is_front               (rd_dec_is_front),               //output
    .rd_is_front                   (rd_is_front),                   //output
    .exe_is_front                  (exe_is_front),                  //output
    .wr_is_front                   (wr_is_front),                   //output
    
    .pipeline_after_read_empty     (pipeline_after_read_empty),     //output
    .pipeline_after_prefetch_empty (pipeline_after_prefetch_empty), //output
    
    //dec exceptions
    .dec_gp_fault                  (dec_gp_fault),                  //output
    .dec_ud_fault                  (dec_ud_fault),                  //output
    .dec_pf_fault                  (dec_pf_fault),                  //output
    
    //rd exception
    .rd_io_allow_fault             (rd_io_allow_fault),             //output
    .rd_descriptor_gp_fault        (rd_descriptor_gp_fault),        //output
    .rd_seg_gp_fault               (rd_seg_gp_fault),               //output
    .rd_seg_ss_fault               (rd_seg_ss_fault),               //output
    .rd_ss_esp_from_tss_fault      (rd_ss_esp_from_tss_fault),      //output
    
    //exe exception
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
    
    //wr exception
    .wr_debug_init                 (wr_debug_init),                 //output
    .wr_new_push_ss_fault          (wr_new_push_ss_fault),          //output
    .wr_string_es_fault            (wr_string_es_fault),            //output
    .wr_push_ss_fault              (wr_push_ss_fault),              //output
    
    //error code
    .rd_error_code                 (rd_error_code),                 //output [15:0]
    .exe_error_code                (exe_error_code),                //output [15:0]
    .wr_error_code                 (wr_error_code),                 //output [15:0]
    
    //glob output
    .glob_descriptor_set           (glob_descriptor_set),           //output
    .glob_descriptor_value         (glob_descriptor_value),         //output [63:0]
    .glob_descriptor_2_set         (glob_descriptor_2_set),         //output
    .glob_descriptor_2_value       (glob_descriptor_2_value),       //output [63:0]
    
    .glob_param_1_set              (glob_param_1_set),              //output
    .glob_param_1_value            (glob_param_1_value),            //output [31:0]
    .glob_param_2_set              (glob_param_2_set),              //output
    .glob_param_2_value            (glob_param_2_value),            //output [31:0]
    .glob_param_3_set              (glob_param_3_set),              //output
    .glob_param_3_value            (glob_param_3_value),            //output [31:0]
    .glob_param_4_set              (glob_param_4_set),              //output
    .glob_param_4_value            (glob_param_4_value),            //output [31:0]
    .glob_param_5_set              (glob_param_5_set),              //output
    .glob_param_5_value            (glob_param_5_value),            //output [31:0]
    
    // prefetch
    .prefetch_cpl                  (prefetch_cpl),                  //output [1:0]
    .prefetch_eip                  (prefetch_eip),                  //output [31:0]
    
    .cs_cache                      (cs_cache),                      //output [63:0]
    
    .cr0_pg                        (cr0_pg),                        //output
    .cr0_wp                        (cr0_wp),                        //output
    .cr0_am                        (cr0_am),                        //output
    .cr0_cd                        (cr0_cd),                        //output
    .cr0_nw                        (cr0_nw),                        //output
    
    .acflag                        (acflag),                        //output
    
    .cr3                           (cr3),                           //output [31:0]
    
    // prefetch_fifo
    .prefetchfifo_accept_do        (prefetchfifo_accept_do),        //output
    .prefetchfifo_accept_data      (prefetchfifo_accept_data),      //input [67:0]
    .prefetchfifo_accept_empty     (prefetchfifo_accept_empty),     //input
    
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
    
    //flush tlb
    .tlbflushall_do                (tlbflushall_do),                //output
    
    .invdcode_do                   (invdcode_do),                   //output
    .invdcode_done                 (invdcode_done),                 //input
    
    .invddata_do                   (invddata_do),                   //output
    .invddata_done                 (invddata_done),                 //input
    
    .wbinvddata_do                 (wbinvddata_do),                 //output
    .wbinvddata_done               (wbinvddata_done),               //input
    
    //interrupt
    .interrupt_do                  (interrupt_do),                  //input
    
    .wr_interrupt_possible         (wr_interrupt_possible),         //output
    .wr_string_in_progress_final   (wr_string_in_progress_final),   //output
    .wr_is_esp_speculative         (wr_is_esp_speculative),         //output
    
    //software interrupt
    .wr_int                        (wr_int),                        //output
    .wr_int_soft_int               (wr_int_soft_int),               //output
    .wr_int_soft_int_ib            (wr_int_soft_int_ib),            //output
    .wr_int_vector                 (wr_int_vector),                 //output [7:0]
    
    .wr_exception_external_set     (wr_exception_external_set),     //output
    .wr_exception_finished         (wr_exception_finished),         //output
    
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
    
    //io write
    .io_write_do                   (io_write_do),                   //output
    .io_write_address              (io_write_address),              //output [15:0]
    .io_write_length               (io_write_length),               //output [2:0]
    .io_write_data                 (io_write_data),                 //output [31:0]
    .io_write_done                 (io_write_done)                  //input
);

//------------------------------------------------------------------------------

endmodule
