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

module exception(
    input               clk,
    input               rst_n,
    
    //exception indicators
    input               dec_gp_fault,
    input               dec_ud_fault,
    input               dec_pf_fault,
        
    input               rd_seg_gp_fault,
    input               rd_descriptor_gp_fault,
    input               rd_seg_ss_fault,
    input               rd_io_allow_fault,
    input               rd_ss_esp_from_tss_fault, 
    
    input               exe_div_exception,
    input               exe_trigger_gp_fault,
    input               exe_trigger_ts_fault,
    input               exe_trigger_ss_fault,
    input               exe_trigger_np_fault,
    input               exe_trigger_nm_fault,
    input               exe_trigger_db_fault,
    input               exe_trigger_pf_fault,
    input               exe_bound_fault,
    input               exe_load_seg_gp_fault,
    input               exe_load_seg_ss_fault,
    input               exe_load_seg_np_fault,
    
    input               wr_debug_init,
    
    input               wr_new_push_ss_fault,
    input               wr_string_es_fault,
    input               wr_push_ss_fault,
    
    //from memory
    input               read_ac_fault,
    input               read_page_fault,
    
    input               write_ac_fault,
    input               write_page_fault,
    
    input       [15:0]  tlb_code_pf_error_code,
    input       [15:0]  tlb_check_pf_error_code,
    input       [15:0]  tlb_write_pf_error_code,
    input       [15:0]  tlb_read_pf_error_code,
    
    //wr_int
    input               wr_int,
    input               wr_int_soft_int,
    input               wr_int_soft_int_ib,
    input       [7:0]   wr_int_vector,
    
    input               wr_exception_external_set,
    input               wr_exception_finished,
    
    //eip
    input       [31:0]  eip,
    input       [31:0]  dec_eip,
    input       [31:0]  rd_eip,
    input       [31:0]  exe_eip,
    input       [31:0]  wr_eip,
    
    input       [3:0]   rd_consumed,
    input       [3:0]   exe_consumed,
    input       [3:0]   wr_consumed,
    
    //pipeline
    input               rd_dec_is_front,
    input               rd_is_front,
    input               exe_is_front,
    input               wr_is_front,
    
    //interrupt
    input       [7:0]   interrupt_vector,
    output reg          interrupt_done,
    
    //input
    input               wr_interrupt_possible,
    input               wr_string_in_progress_final,
    input               wr_is_esp_speculative,
    
    input               real_mode,
    
    input       [15:0]  rd_error_code,
    input       [15:0]  exe_error_code,
    input       [15:0]  wr_error_code,
    
    //output
    output              exc_dec_reset,
    output              exc_micro_reset,
    output              exc_rd_reset,
    output              exc_exe_reset,
    output              exc_wr_reset,
    
    output              exc_restore_esp,
    output              exc_set_rflag,
    output              exc_debug_start,
    
    output              exc_init,
    output reg          exc_load,
    output reg  [31:0]  exc_eip,
    
    output      [7:0]   exc_vector,
    output reg  [15:0]  exc_error_code,
    output reg          exc_push_error,
    output reg          exc_soft_int,
    output reg          exc_soft_int_ib,
    
    output              exc_pf_read,
    output              exc_pf_write,
    output              exc_pf_code,
    output              exc_pf_check
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

wire        exception_init;
wire        exception_start;

wire        active_dec;
wire        active_rd;
wire        active_exe;
wire        active_wr;

wire [31:0] exception_eip_from_wr;

//------------------------------------------------------------------------------

reg         external;
reg [1:0]   count;
reg [1:0]   last_type;

reg [31:0]  trap_eip;

reg         shutdown;

reg         interrupt_load;
reg         interrupt_string_in_progress;

reg [8:0]   exc_vector_full;

//------------------------------------------------------------------------------

wire [7:0]  vector;
wire [15:0] error_code;
wire        push_error;

wire        class_trap;
wire        class_abort;

wire [1:0]  exception_type;

wire        shutdown_start;

//------------------------------------------------------------------------------

assign exc_vector = exc_vector_full[7:0];

//------------------------------------------------------------------------------

assign exception_init = exc_vector_full[8];

assign exc_init   = exception_init || wr_interrupt_possible || interrupt_done || wr_debug_init;

assign active_dec = (dec_gp_fault || dec_ud_fault || dec_pf_fault) &&
                    rd_dec_is_front && ~(exc_init);
assign active_rd  = (rd_seg_gp_fault || rd_descriptor_gp_fault || rd_seg_ss_fault || rd_io_allow_fault ||
                     rd_ss_esp_from_tss_fault || read_ac_fault || read_page_fault) &&
                    rd_is_front  && ~(exc_init);
assign active_exe = (exe_div_exception || exe_trigger_gp_fault || exe_trigger_ts_fault || exe_trigger_ss_fault ||
                     exe_trigger_np_fault || exe_trigger_nm_fault || exe_trigger_db_fault || exe_trigger_pf_fault ||
                     exe_bound_fault || exe_load_seg_gp_fault || exe_load_seg_ss_fault || exe_load_seg_np_fault) &&
                    exe_is_front && ~(exc_init);
assign active_wr  = (wr_new_push_ss_fault || wr_string_es_fault || wr_push_ss_fault || write_ac_fault ||
                     write_page_fault || wr_int) &&
                    wr_is_front  && ~(exc_init);

assign exc_pf_read = active_rd  && read_page_fault;
assign exc_pf_write= active_wr  && write_page_fault;
assign exc_pf_code = active_dec && dec_pf_fault;
assign exc_pf_check= active_exe && exe_trigger_pf_fault;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               exc_vector_full <= 9'd0;
    
    else if(active_wr && wr_new_push_ss_fault)      exc_vector_full <= { 1'b1, `EXCEPTION_SS };
    else if(active_wr && wr_string_es_fault)        exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_wr && wr_push_ss_fault)          exc_vector_full <= { 1'b1, `EXCEPTION_SS };
    else if(active_wr && write_ac_fault)            exc_vector_full <= { 1'b1, `EXCEPTION_AC };
    else if(active_wr && write_page_fault)          exc_vector_full <= { 1'b1, `EXCEPTION_PF };
    
    else if(active_wr && wr_int)                    exc_vector_full <= { 1'b0, wr_int_vector };
    
    else if(active_exe && exe_div_exception)        exc_vector_full <= { 1'b1, `EXCEPTION_DE };
    else if(active_exe && exe_trigger_gp_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_exe && exe_trigger_ts_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_TS };
    else if(active_exe && exe_trigger_ss_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_SS };
    else if(active_exe && exe_trigger_np_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_NP };
    else if(active_exe && exe_trigger_nm_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_NM };
    else if(active_exe && exe_trigger_db_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_DB };
    else if(active_exe && exe_trigger_pf_fault)     exc_vector_full <= { 1'b1, `EXCEPTION_PF };
    else if(active_exe && exe_bound_fault)          exc_vector_full <= { 1'b1, `EXCEPTION_BR };
    else if(active_exe && exe_load_seg_gp_fault)    exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_exe && exe_load_seg_ss_fault)    exc_vector_full <= { 1'b1, `EXCEPTION_SS };
    else if(active_exe && exe_load_seg_np_fault)    exc_vector_full <= { 1'b1, `EXCEPTION_NP };
    
    else if(active_rd && rd_seg_gp_fault)           exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_rd && rd_descriptor_gp_fault)    exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_rd && rd_seg_ss_fault)           exc_vector_full <= { 1'b1, `EXCEPTION_SS };
    else if(active_rd && rd_io_allow_fault)         exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_rd && rd_ss_esp_from_tss_fault)  exc_vector_full <= { 1'b1, `EXCEPTION_TS };
    else if(active_rd && read_ac_fault)             exc_vector_full <= { 1'b1, `EXCEPTION_AC };
    else if(active_rd && read_page_fault)           exc_vector_full <= { 1'b1, `EXCEPTION_PF };
    
    else if(active_dec && dec_gp_fault)             exc_vector_full <= { 1'b1, `EXCEPTION_GP };
    else if(active_dec && dec_ud_fault)             exc_vector_full <= { 1'b1, `EXCEPTION_UD };
    else if(active_dec && dec_pf_fault)             exc_vector_full <= { 1'b1, `EXCEPTION_PF };
    
    else                                            exc_vector_full <= exc_vector_full_to_reg; //set if(exception_init || wr_debug_init || interrupt_done)
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           exc_error_code <= 16'd0;
    
    else if(active_wr && write_ac_fault)        exc_error_code <= 16'd0;
    else if(active_wr && write_page_fault)      exc_error_code <= tlb_write_pf_error_code;
    else if(active_wr)                          exc_error_code <= wr_error_code;
    
    else if(active_exe && exe_trigger_pf_fault) exc_error_code <= tlb_check_pf_error_code;
    else if(active_exe)                         exc_error_code <= exe_error_code;
    
    else if(active_rd && read_ac_fault)         exc_error_code <= 16'd0;
    else if(active_rd && read_page_fault)       exc_error_code <= tlb_read_pf_error_code;
    else if(active_rd)                          exc_error_code <= rd_error_code;
    
    else if(active_dec && dec_pf_fault)         exc_error_code <= tlb_code_pf_error_code;
    else if(active_dec)                         exc_error_code <= 16'd0;
    
    else                                        exc_error_code <= exc_error_code_to_reg; //set if(exception_init || wr_debug_init || interrupt_done)
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               exc_push_error <= `FALSE;
    else if(active_wr && wr_int)    exc_push_error <= `FALSE;
    else                            exc_push_error <= exc_push_error_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               exc_soft_int <= `FALSE;
    else if(active_wr && wr_int)    exc_soft_int <= wr_int_soft_int;
    else                            exc_soft_int <= exc_soft_int_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               exc_soft_int_ib <= `FALSE;
    else if(active_wr && wr_int)    exc_soft_int_ib <= wr_int_soft_int_ib;
    else                            exc_soft_int_ib <= exc_soft_int_ib_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   exc_load <= `FALSE;
    else                exc_load <= exception_start || interrupt_done;
end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   external <= 1'b0;
    else if(wr_exception_external_set)  external <= `TRUE;
    else if(wr_exception_finished)      external <= `FALSE;
    else                                external <= external_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   count <= 2'b0;
    else if(wr_exception_finished)      count <= 2'd0;
    else                                count <= count_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   last_type <= 2'b0;
    else                last_type <= last_type_to_reg;
end

assign exception_eip_from_wr = wr_eip  - { 28'd0, wr_consumed };

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)      exc_eip <= 32'd0;
    else if(active_wr)     exc_eip <= exception_eip_from_wr;
    else if(active_exe)    exc_eip <= exe_eip - { 28'd0, exe_consumed };
    else if(active_rd)     exc_eip <= rd_eip  - { 28'd0, rd_consumed };
    else if(active_dec)    exc_eip <= eip;
    else                   exc_eip <= exc_eip_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)      trap_eip <= 32'd0;
    else if(active_wr)     trap_eip <= wr_eip;
    else if(active_exe)    trap_eip <= exe_eip;
    else if(active_rd)     trap_eip <= rd_eip;
    else if(active_dec)    trap_eip <= dec_eip;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   shutdown <= `FALSE;
    else                shutdown <= shutdown_to_reg;
end

//------------------------------------------------------------------------------

assign vector = (wr_debug_init)? `EXCEPTION_DB : exc_vector_full[7:0];

assign error_code =
    (real_mode)?                                            16'd0 :
    (vector != `EXCEPTION_PF && vector != `EXCEPTION_DF)?   { exc_error_code[15:1], external } :
                                                            exc_error_code;

assign push_error =
    ~(real_mode) && (
        (vector == `EXCEPTION_DF) || (vector == `EXCEPTION_TS) || (vector == `EXCEPTION_NP) ||
        (vector == `EXCEPTION_SS) || (vector == `EXCEPTION_GP) || (vector == `EXCEPTION_PF) ||
        (vector == `EXCEPTION_AC));

assign class_trap  = (vector == `EXCEPTION_BP) || (vector == `EXCEPTION_OF);

assign class_abort = (vector == `EXCEPTION_MC);

`define EXCEPTION_TYPE_BENIGN           2'd0
`define EXCEPTION_TYPE_CONTRIBUTORY     2'd1
`define EXCEPTION_TYPE_PAGE_FAULT       2'd2
`define EXCEPTION_TYPE_DOUBLE_FAULT     2'd3

assign exception_type =
    (vector == `EXCEPTION_DE) || (vector >= `EXCEPTION_TS && vector <= `EXCEPTION_GP)?  `EXCEPTION_TYPE_CONTRIBUTORY :
    (vector == `EXCEPTION_DF)?                                                          `EXCEPTION_TYPE_DOUBLE_FAULT :
    (vector == `EXCEPTION_PF)?                                                          `EXCEPTION_TYPE_PAGE_FAULT :
                                                                                        `EXCEPTION_TYPE_BENIGN;

assign shutdown_start = count > 2'd2 || (count > 2'd0 && last_type == `EXCEPTION_TYPE_DOUBLE_FAULT);

//------------------------------------------------------------------------------

// interrupt_vector[7:0], interrupt_done; 

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               interrupt_done <= `FALSE;
    else if(wr_interrupt_possible)  interrupt_done <= `TRUE;
    else                            interrupt_done <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           interrupt_load <= `FALSE;
    else                        interrupt_load <= interrupt_done;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               interrupt_string_in_progress <= `FALSE;
    else if(wr_interrupt_possible && wr_string_in_progress_final)   interrupt_string_in_progress <= `TRUE;
    else if(wr_interrupt_possible)                                  interrupt_string_in_progress <= `FALSE;
end

assign exc_debug_start = exc_load && vector == `EXCEPTION_DB && interrupt_load == `FALSE;

/*******************************************************************************SCRIPT

NO_ALWAYS_BLOCK(exc_eip);
NO_ALWAYS_BLOCK(exc_error_code);
NO_ALWAYS_BLOCK(exc_push_error);
NO_ALWAYS_BLOCK(exc_soft_int);
NO_ALWAYS_BLOCK(exc_soft_int_ib);
NO_ALWAYS_BLOCK(exc_vector_full);
NO_ALWAYS_BLOCK(shutdown);
NO_ALWAYS_BLOCK(last_type);
NO_ALWAYS_BLOCK(count);
NO_ALWAYS_BLOCK(external);

*/

/*******************************************************************************SCRIPT

IF(exception_init || wr_debug_init);
    //NOTE: exe_reset must in same cycle as exception_init (wr waits one cycle for wr_one_cycle_wait) 
    SET(exc_dec_reset);
    SET(exc_micro_reset);
    SET(exc_rd_reset);
    SET(exc_exe_reset);
    SET(exc_wr_reset);
    
    IF(~(class_trap) && ~(class_abort));

        IF(wr_is_esp_speculative); SET(exc_restore_esp); ENDIF();
        // eip in exc_eip

        IF(vector != `EXCEPTION_DB); SET(exc_set_rflag); ENDIF();
    ELSE();
        // trap
            //esp no change needed
            SAVE(exc_eip, trap_eip);
    ENDIF();

    IF(vector == `EXCEPTION_DB);
        IF(wr_debug_init && ~(wr_string_in_progress_final));  SAVE(exc_eip, wr_eip); ENDIF();
        IF(wr_debug_init && wr_string_in_progress_final);     SAVE(exc_eip, exception_eip_from_wr); ENDIF();
        // if not wr_debug_init -- eip already in exc_eip
    ENDIF();

    SAVE(external, `TRUE);

    IF(shutdown_start == `FALSE && count > 2'd0 && exception_type != `EXCEPTION_TYPE_DOUBLE_FAULT && (
        (last_type == `EXCEPTION_TYPE_CONTRIBUTORY && exception_type == `EXCEPTION_TYPE_CONTRIBUTORY) ||
        (last_type == `EXCEPTION_TYPE_PAGE_FAULT   && exception_type == `EXCEPTION_TYPE_CONTRIBUTORY) ||
        (last_type == `EXCEPTION_TYPE_PAGE_FAULT   && exception_type == `EXCEPTION_TYPE_PAGE_FAULT)));

        SAVE(exc_vector_full, { 1'b1, `EXCEPTION_DF });
        SAVE(exc_error_code, 16'd0);
    ELSE();
        
        IF(shutdown_start == `FALSE);
            SAVE(last_type, exception_type);
            SAVE(count,     count + 2'd1);

            SAVE(exc_push_error, push_error);
            SAVE(exc_error_code, error_code);
            
            SAVE(exc_soft_int,    `FALSE);
            SAVE(exc_soft_int_ib, `FALSE);
            
            // finish this state
            SAVE(exc_vector_full, { 1'b0, vector });
            
            SET(exception_start);
        ENDIF();
    ENDIF(); 
    
    IF(shutdown_start);
        // finish this state
        SAVE(exc_vector_full, { 1'b0, vector });
        
        SAVE(shutdown, `TRUE);
    ENDIF();
    
ENDIF();

*/

/*******************************************************************************SCRIPT

IF(shutdown);
        
    // keep pipeline reset
    SET(exc_dec_reset);
    SET(exc_micro_reset);
    SET(exc_rd_reset);
    SET(exc_exe_reset);
    SET(exc_wr_reset);
ENDIF();

*/

/*******************************************************************************SCRIPT

IF(interrupt_done);
            
    SAVE(external, `TRUE);
    
    SAVE(exc_vector_full, { 1'b0, interrupt_vector });
    
    SAVE(exc_push_error, `FALSE);
    SAVE(exc_error_code, 16'd0);
    
    SAVE(exc_eip, (interrupt_string_in_progress)? exception_eip_from_wr : wr_eip);

    SAVE(exc_soft_int,    `FALSE);
    SAVE(exc_soft_int_ib, `FALSE);
    
    SET(exc_dec_reset);
    SET(exc_micro_reset);
    SET(exc_rd_reset);
    SET(exc_exe_reset);
    SET(exc_wr_reset);
ENDIF();

*/

//------------------------------------------------------------------------------

`include "autogen/exception.v"


endmodule
