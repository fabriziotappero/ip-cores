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

module tlb(
    input               clk,
    input               rst_n,

    input               pr_reset,
    input               rd_reset,
    input               exe_reset,
    input               wr_reset,
    
    // from control
    input               cr0_pg,
    input               cr0_wp,
    input               cr0_am,
    input               cr0_cd,
    input               cr0_nw,
    
    input               acflag,
    
    input   [31:0]      cr3,
    
    input               pipeline_after_read_empty,
    input               pipeline_after_prefetch_empty,
    
    output reg  [31:0]  tlb_code_pf_cr2,
    output reg  [15:0]  tlb_code_pf_error_code,
    
    output reg  [31:0]  tlb_check_pf_cr2,
    output reg  [15:0]  tlb_check_pf_error_code,
    
    output reg  [31:0]  tlb_write_pf_cr2,
    output reg  [15:0]  tlb_write_pf_error_code,
        
    output reg  [31:0]  tlb_read_pf_cr2,
    output reg  [15:0]  tlb_read_pf_error_code,
    
    //RESP:
    input               tlbflushsingle_do,
    output              tlbflushsingle_done,
    input   [31:0]      tlbflushsingle_address,
    //END
    
    //RESP:
    input               tlbflushall_do,
    //END
    
    //RESP:
    input               tlbread_do,
    output              tlbread_done,
    output              tlbread_page_fault,
    output              tlbread_ac_fault,
    output              tlbread_retry,
    
    input   [1:0]       tlbread_cpl,
    input   [31:0]      tlbread_address,
    input   [3:0]       tlbread_length,
    input   [3:0]       tlbread_length_full,
    input               tlbread_lock,
    input               tlbread_rmw,
    output  [63:0]      tlbread_data,
    //END
    
    //RESP:
    input               tlbwrite_do,
    output              tlbwrite_done,
    output              tlbwrite_page_fault,
    output              tlbwrite_ac_fault,
    
    input   [1:0]       tlbwrite_cpl,
    input   [31:0]      tlbwrite_address,
    input   [2:0]       tlbwrite_length,
    input   [2:0]       tlbwrite_length_full,
    input               tlbwrite_lock,
    input               tlbwrite_rmw,
    input   [31:0]      tlbwrite_data,
    //END
    
    //RESP:
    input               tlbcheck_do,
    output reg          tlbcheck_done,
    output              tlbcheck_page_fault,
    
    input   [31:0]      tlbcheck_address,
    input               tlbcheck_rw,
    //END
    
    //REQ:
    output              dcacheread_do,
    input               dcacheread_done,
    
    output  [3:0]       dcacheread_length,
    output              dcacheread_cache_disable,
    output  [31:0]      dcacheread_address,
    input   [63:0]      dcacheread_data,
    //END
    
    //REQ:
    output              dcachewrite_do,
    input               dcachewrite_done,
    
    output  [2:0]       dcachewrite_length,
    output              dcachewrite_cache_disable,
    output  [31:0]      dcachewrite_address,
    output              dcachewrite_write_through,
    output  [31:0]      dcachewrite_data,
    //END
    
    //RESP:
    input               tlbcoderequest_do,
    input       [31:0]  tlbcoderequest_address,
    input               tlbcoderequest_su,
    //END

    //REQ:
    output reg          tlbcode_do,
    output      [31:0]  tlbcode_linear,
    output reg  [31:0]  tlbcode_physical,
    output reg          tlbcode_cache_disable,
    //END
    
    //REQ:
    output              prefetchfifo_signal_pf_do
    //END
);

//------------------------------------------------------------------------------

reg [4:0]   state;

reg [31:0]  linear;
reg         su;
reg         rw;
reg         wp;
reg [1:0]   current_type;

reg [31:0]  pde;
reg [31:0]  pte;

reg         code_pf;
reg         check_pf;

reg         write_pf;
reg         write_ac;

reg         read_pf;
reg         read_ac;

reg         pr_reset_waiting;

reg         tlbflushall_do_waiting;

reg [1:0]   write_double_state;
reg [31:0]  write_double_linear;

//------------------------------------------------------------------------------

wire [31:0] memtype_physical;
wire        memtype_cache_disable;
wire        memtype_write_transparent;

wire        rw_entry;
wire        su_entry;
wire        fault;

wire        rw_entry_before_pte;
wire        su_entry_before_pte;
wire        fault_before_pte;

wire [31:0] cr3_base;
wire        cr3_pwt;
wire        cr3_pcd;

assign cr3_base = { cr3[31:12], 12'd0 };
assign cr3_pwt  = cr3[3];
assign cr3_pcd  = cr3[4];

//------------------------------------------------------------------------------

assign tlbread_data       = dcacheread_data;
assign tlbread_page_fault = read_pf;
assign tlbread_ac_fault   = read_ac;

assign tlbwrite_page_fault = write_pf;
assign tlbwrite_ac_fault   = write_ac;

assign tlbcheck_page_fault = check_pf;

assign rw_entry = (state == STATE_LOAD_PTE_END)? pde[1] & pte[1] : translate_combined_rw;
assign su_entry = (state == STATE_LOAD_PTE_END)? pde[2] & pte[2] : translate_combined_su;    

assign fault =
    // user can not access supervisor
    (su && ~(su_entry)) ||
    // user can not write on read-only page
    (su && su_entry && ~(rw_entry) && rw) ||
    // supervisor can not write on read-only page when write-protect is on
    (wp && ~(su) && ~(rw_entry) && rw);

assign rw_entry_before_pte = pde[1] & dcacheread_data[1];
assign su_entry_before_pte = pde[2] & dcacheread_data[2];
    
assign fault_before_pte =
    // user can not access supervisor
    (su && ~(su_entry_before_pte)) ||
    // user can not write on read-only page
    (su && su_entry_before_pte && ~(rw_entry_before_pte) && rw) ||
    // supervisor can not write on read-only page when write-protect is on
    (wp && ~(su) && ~(rw_entry_before_pte) && rw);

    
assign tlbcode_linear = linear;

//------------------------------------------------------------------------------

localparam [4:0] STATE_IDLE             = 5'd0;
localparam [4:0] STATE_CODE_CHECK       = 5'd1;
localparam [4:0] STATE_LOAD_PDE         = 5'd2;
localparam [4:0] STATE_LOAD_PTE_START   = 5'd3;
localparam [4:0] STATE_LOAD_PTE         = 5'd4;
localparam [4:0] STATE_LOAD_PTE_END     = 5'd5;
localparam [4:0] STATE_SAVE_PDE         = 5'd6;
localparam [4:0] STATE_SAVE_PTE_START   = 5'd7;
localparam [4:0] STATE_SAVE_PTE         = 5'd8;
localparam [4:0] STATE_CHECK_CHECK      = 5'd9;
localparam [4:0] STATE_WRITE_CHECK      = 5'd10;
localparam [4:0] STATE_WRITE_WAIT_START = 5'd11;
localparam [4:0] STATE_WRITE_WAIT       = 5'd12;
localparam [4:0] STATE_WRITE_DOUBLE     = 5'd13;
localparam [4:0] STATE_READ_CHECK       = 5'd14;
localparam [4:0] STATE_READ_WAIT_START  = 5'd15;
localparam [4:0] STATE_READ_WAIT        = 5'd16;
localparam [4:0] STATE_RETRY            = 5'd17;

localparam [1:0] TYPE_CODE  = 2'd0;
localparam [1:0] TYPE_CHECK = 2'd1;
localparam [1:0] TYPE_WRITE = 2'd2;
localparam [1:0] TYPE_READ  = 2'd3;

localparam [1:0] WRITE_DOUBLE_NONE    = 2'd0;
localparam [1:0] WRITE_DOUBLE_CHECK   = 2'd1;
localparam [1:0] WRITE_DOUBLE_RESTART = 2'd2;

//------------------------------------------------------------------------------

tlb_memtype tlb_memtype_inst(
    .physical           (memtype_physical),             //input [31:0]
                       
    .cache_disable      (memtype_cache_disable),        //output
    .write_transparent  (memtype_write_transparent)     //output
);

wire translate_combined_rw;
wire translate_combined_su;

wire tlbregs_tlbflushsingle_do;
wire tlbregs_tlbflushall_do;

wire        translate_do;
wire        translate_valid;
wire [31:0] translate_physical;
wire        translate_pwt;
wire        translate_pcd;

wire        tlbregs_write_do;
wire [31:0] tlbregs_write_linear;
wire [31:0] tlbregs_write_physical;
wire        tlbregs_write_pwt;
wire        tlbregs_write_pcd;
wire        tlbregs_write_combined_rw;
wire        tlbregs_write_combined_su;

tlb_regs tlb_regs_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //RESP:
    .tlbflushsingle_do          (tlbregs_tlbflushsingle_do),    //input
    .tlbflushsingle_address     (tlbflushsingle_address),       //input [31:0]
    //END
    
    //RESP:
    .tlbflushall_do             (tlbregs_tlbflushall_do),       //input
    //END
    
    .rw                         (rw),                           //input
    
    //RESP:
    .tlbregs_write_do           (tlbregs_write_do),             //input
    .tlbregs_write_linear       (tlbregs_write_linear),         //input [31:0]
    .tlbregs_write_physical     (tlbregs_write_physical),       //input [31:0]
    
    .tlbregs_write_pwt          (tlbregs_write_pwt),            //input
    .tlbregs_write_pcd          (tlbregs_write_pcd),            //input
    .tlbregs_write_combined_rw  (tlbregs_write_combined_rw),    //input
    .tlbregs_write_combined_su  (tlbregs_write_combined_su),    //input
    //END
    
    //RESP:
    .translate_do               (translate_do),                 //input
    .translate_linear           (linear),                       //input [31:0]
    .translate_valid            (translate_valid),              //output
    .translate_physical         (translate_physical),           //output [31:0]
    .translate_pwt              (translate_pwt),                //output
    .translate_pcd              (translate_pcd),                //output
    .translate_combined_rw      (translate_combined_rw),        //output
    .translate_combined_su      (translate_combined_su)         //output
    //END
);

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   code_pf <= `FALSE;
    else if(pr_reset)   code_pf <= `FALSE;
    else                code_pf <= code_pf_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   check_pf <= `FALSE;
    else if(exe_reset)  check_pf <= `FALSE;
    else                check_pf <= check_pf_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   read_pf <= `FALSE;
    else if(rd_reset)   read_pf <= `FALSE;
    else                read_pf <= read_pf_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   read_ac <= `FALSE;
    else if(rd_reset)   read_ac <= `FALSE;
    else                read_ac <= read_ac_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   write_pf <= `FALSE;
    else if(wr_reset)   write_pf <= `FALSE;
    else                write_pf <= write_pf_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   write_ac <= `FALSE;
    else if(wr_reset)   write_ac <= `FALSE;
    else                write_ac <= write_ac_to_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           pr_reset_waiting <= `FALSE;
    else if(pr_reset && state != STATE_IDLE)    pr_reset_waiting <= `TRUE;
    else if(state == STATE_IDLE)                pr_reset_waiting <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               tlbflushall_do_waiting <= `FALSE;
    else if(tlbflushall_do && state != STATE_IDLE)  tlbflushall_do_waiting <= `TRUE;
    else if(tlbregs_tlbflushall_do)                 tlbflushall_do_waiting <= `FALSE;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, cr3[11:5], cr3[2:0], tlbread_lock, tlbwrite_lock, tlbwrite_rmw, cr3_base[11:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

/*******************************************************************************SCRIPT
NO_ALWAYS_BLOCK(code_pf);
NO_ALWAYS_BLOCK(check_pf);
NO_ALWAYS_BLOCK(read_pf);
NO_ALWAYS_BLOCK(write_pf);
NO_ALWAYS_BLOCK(read_ac);
NO_ALWAYS_BLOCK(write_ac);
*/
    
/*******************************************************************************SCRIPT
IF(state == STATE_IDLE);
    
    SAVE(tlbcheck_done, `FALSE);
    SAVE(tlbcode_do,    `FALSE);
    SAVE(read_pf,       `FALSE);
    SAVE(write_pf,      `FALSE);
    
    IF(tlbflushsingle_do);
    
        SET(tlbregs_tlbflushsingle_do);
        SET(tlbflushsingle_done);
    
    ELSE_IF(tlbflushall_do || tlbflushall_do_waiting);
        
        SET(tlbregs_tlbflushall_do);
    
    ELSE_IF(~(wr_reset) && tlbwrite_do && ~(write_ac) && cr0_am && acflag && tlbwrite_cpl == 2'd3 &&
             ( (tlbwrite_length_full == 3'd2 && tlbwrite_address[0] != 1'b0) || (tlbwrite_length_full == 3'd4 && tlbwrite_address[1:0] != 2'b00) )
    );
        
        SAVE(write_ac, `TRUE);
    
    ELSE_IF(~(wr_reset) && tlbwrite_do && ~(write_pf) && ~(write_ac));
        
        SAVE(rw,             `TRUE);
        SAVE(su,             tlbwrite_cpl == 2'd3);
        SAVE(wp,             cr0_wp);

        SAVE(write_double_state, (cr0_pg && tlbwrite_length != tlbwrite_length_full && { 1'b0, tlbwrite_address[11:0] } + { 10'd0, tlbwrite_length_full } >= 13'h1000)? WRITE_DOUBLE_CHECK : WRITE_DOUBLE_NONE);
        
        SAVE(linear, tlbwrite_address);
        SAVE(state,  STATE_WRITE_CHECK);
        
    ELSE_IF(~(exe_reset) && tlbcheck_do && ~(tlbcheck_done) && ~(check_pf));
    
        SAVE(rw,             tlbcheck_rw);
        SAVE(su,             `FALSE);
        SAVE(wp,             cr0_wp);
        
        SAVE(write_double_state, WRITE_DOUBLE_NONE);
        
        SAVE(linear, tlbcheck_address);
        SAVE(state,  STATE_CHECK_CHECK);
        
    ELSE_IF(~(rd_reset) && tlbread_do && ~(read_ac) && cr0_am && acflag && tlbread_cpl == 2'd3 &&
             ( (tlbread_length_full == 4'd2 && tlbread_address[0] != 1'b0) || (tlbread_length_full == 4'd4 && tlbread_address[1:0] != 2'b00))
    );
        
        SAVE(read_ac, `TRUE);
    
    ELSE_IF(~(rd_reset) && tlbread_do && ~(read_pf) && ~(read_ac));
        
        SAVE(rw,             tlbread_rmw);
        SAVE(su,             tlbread_cpl == 2'd3);
        SAVE(wp,             cr0_wp);
        
        SAVE(write_double_state, WRITE_DOUBLE_NONE);
        
        SAVE(linear, tlbread_address);
        SAVE(state,  STATE_READ_CHECK);
        
        
    ELSE_IF(~(pr_reset) && tlbcoderequest_do && ~(code_pf) && ~(tlbcode_do));
        
        SAVE(rw,             `FALSE);
        SAVE(su,             tlbcoderequest_su);
        SAVE(wp,             cr0_wp);
        
        SAVE(write_double_state, WRITE_DOUBLE_NONE);
        
        SAVE(linear, tlbcoderequest_address);
        SAVE(state,  STATE_CODE_CHECK);
        
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_DOUBLE);
    
    IF(write_double_state == WRITE_DOUBLE_CHECK);
        SAVE(linear, { linear[31:12], 12'd0 } + 32'h00001000);
        SAVE(write_double_linear, linear);
        
        SAVE(write_double_state, WRITE_DOUBLE_RESTART);
        SAVE(state,              STATE_WRITE_CHECK);
    ELSE();
        SAVE(linear, write_double_linear);
        
        SAVE(write_double_state, WRITE_DOUBLE_NONE);
        SAVE(state,              STATE_WRITE_CHECK);
    ENDIF();
ENDIF();

*/

/*******************************************************************************SCRIPT
IF(state == STATE_WRITE_WAIT);

    IF(dcachewrite_done);
        SET(tlbwrite_done);
        
        SAVE(state, STATE_IDLE);
    ENDIF();

ENDIF();
*/

/*******************************************************************************SCRIPT
    
IF(state == STATE_READ_WAIT);

    IF(dcacheread_done);
        SET(tlbread_done);
        
        SAVE(state, STATE_IDLE);
    ENDIF();

ENDIF();
*/
    
/*******************************************************************************SCRIPT

IF(state == STATE_READ_CHECK);
    
    IF(cr0_pg);
        SET(translate_do);
    ENDIF();
    
    IF(~(cr0_pg) || translate_valid);
        
        IF(cr0_pg && fault);
            SAVE(read_pf,            `TRUE);
            
            SAVE(tlb_read_pf_cr2,        linear);
            SAVE(tlb_read_pf_error_code, { 13'd0, su, rw, `TRUE });
            
            SAVE(state, STATE_IDLE);
            
        ELSE();

            SET(memtype_physical, translate_physical);
        
            SET(dcacheread_do);
            SET(dcacheread_address,          memtype_physical);
            SET(dcacheread_length,           tlbread_length);
            SET(dcacheread_cache_disable,    cr0_cd || translate_pcd || memtype_cache_disable);
            
            SAVE(state, STATE_READ_WAIT);
        ENDIF();

    ELSE();
        
        SET(memtype_physical, { cr3_base[31:12], linear[31:22], 2'd0 });
        
        SET(dcacheread_do);
        SET(dcacheread_address,          memtype_physical);
        SET(dcacheread_length,           4'd4);
        SET(dcacheread_cache_disable,    cr0_cd || cr3_pcd || memtype_cache_disable);
        
        SAVE(current_type,   TYPE_READ);
        SAVE(state,          STATE_LOAD_PDE);
    
    ENDIF();
    
ENDIF();
*/

/*******************************************************************************SCRIPT
    
IF(state == STATE_WRITE_CHECK);
    
    IF(cr0_pg);
        SET(translate_do);
    ENDIF();
    
    IF(~(cr0_pg) || translate_valid);
        
        IF(cr0_pg && fault);
            SAVE(write_pf,                `TRUE);
            
            SAVE(tlb_write_pf_cr2,        linear);
            SAVE(tlb_write_pf_error_code, { 13'd0, su, rw, `TRUE });
            
            SAVE(state, STATE_IDLE);
            
        ELSE_IF(translate_valid && write_double_state != WRITE_DOUBLE_NONE);
        
            SAVE(state, STATE_WRITE_DOUBLE);
            
        ELSE();
            
            SET(memtype_physical, translate_physical);

            SET(dcachewrite_do);
            SET(dcachewrite_address,         memtype_physical);
            SET(dcachewrite_length,          tlbwrite_length);
            SET(dcachewrite_cache_disable,   cr0_cd || translate_pcd || memtype_cache_disable);
            SET(dcachewrite_write_through,   cr0_nw || translate_pwt || memtype_write_transparent);
            SET(dcachewrite_data,            tlbwrite_data);
            
            SAVE(state, STATE_WRITE_WAIT);
        ENDIF();

    ELSE();
        
        SET(memtype_physical, { cr3_base[31:12], linear[31:22], 2'd0 });
        
        SET(dcacheread_do);
        SET(dcacheread_address,          memtype_physical);
        SET(dcacheread_length,           4'd4);
        SET(dcacheread_cache_disable,    cr0_cd || cr3_pcd || memtype_cache_disable);
        
        SAVE(current_type,   TYPE_WRITE);
        SAVE(state,          STATE_LOAD_PDE);
    
    ENDIF();
    
ENDIF();
*/
    
/*******************************************************************************SCRIPT
 
IF(state == STATE_CHECK_CHECK);

    IF(cr0_pg);
        SET(translate_do);
    ENDIF();
    
    IF(~(cr0_pg) || translate_valid);
        
        IF(cr0_pg && fault);
            SAVE(check_pf,               `TRUE);
            
            SAVE(tlb_check_pf_cr2,       linear);
            SAVE(tlb_check_pf_error_code,{ 13'd0, su, rw, `TRUE });
            
        ELSE();
            SAVE(tlbcheck_done, `TRUE);
        ENDIF();
        
        SAVE(state, STATE_IDLE);
        
    ELSE();
        
        SET(memtype_physical, { cr3_base[31:12], linear[31:22], 2'd0 });
        
        SET(dcacheread_do);
        SET(dcacheread_address,          memtype_physical);
        SET(dcacheread_length,           4'd4);
        SET(dcacheread_cache_disable,    cr0_cd || cr3_pcd || memtype_cache_disable);
        
        SAVE(current_type,   TYPE_CHECK);
        SAVE(state,          STATE_LOAD_PDE);
    
    ENDIF();
    
ENDIF();
*/
    
/*******************************************************************************SCRIPT

IF(state == STATE_CODE_CHECK);
    
    IF(cr0_pg);
        SET(translate_do);
    ENDIF();
    
    IF(pr_reset || pr_reset_waiting); //NOTE: pr_reset required
        
        SAVE(state, STATE_IDLE);
        
    ELSE_IF(~(cr0_pg) || translate_valid);
    
        IF(cr0_pg && fault);
            SAVE(code_pf,                `TRUE);
            
            SAVE(tlb_code_pf_cr2,       linear);
            SAVE(tlb_code_pf_error_code,{ 13'd0, su, rw, `TRUE });
            
            SET(prefetchfifo_signal_pf_do);

        ELSE();
            
            SET(memtype_physical, translate_physical);
            
            SAVE(tlbcode_do, `TRUE);
            SAVE(tlbcode_physical,        memtype_physical);
            SAVE(tlbcode_cache_disable,   cr0_cd || translate_pcd || memtype_cache_disable);
        
        ENDIF();
        
        SAVE(state, STATE_IDLE);
        
    ELSE();
        
        SET(memtype_physical, { cr3_base[31:12], linear[31:22], 2'd0 });
        
        
        SET(dcacheread_do);
        SET(dcacheread_address,          memtype_physical);
        SET(dcacheread_length,           4'd4);
        SET(dcacheread_cache_disable,    cr0_cd || cr3_pcd || memtype_cache_disable);
        
        SAVE(current_type,   TYPE_CODE);
        SAVE(state,          STATE_LOAD_PDE);
    ENDIF();
ENDIF();
*/
    
/*******************************************************************************SCRIPT

IF(state == STATE_LOAD_PDE);

    IF(dcacheread_done);
    
        SAVE(pde, dcacheread_data[31:0]);
    
        IF(dcacheread_data[0] == `FALSE);
            
            IF(current_type == TYPE_CODE && ~(pr_reset) && ~(pr_reset_waiting));
            
                SAVE(code_pf,                `TRUE);
                SAVE(tlb_code_pf_cr2,        linear);
                SAVE(tlb_code_pf_error_code, { 13'd0, su, rw, `FALSE });

                SET(prefetchfifo_signal_pf_do);
                
            ELSE_IF(current_type == TYPE_CHECK);
                
                SAVE(check_pf,               `TRUE);
                SAVE(tlb_check_pf_cr2,       linear);
                SAVE(tlb_check_pf_error_code,{ 13'd0, su, rw, `FALSE });
            
            ELSE_IF(current_type == TYPE_WRITE);
            
                SAVE(write_pf,               `TRUE);
                SAVE(tlb_write_pf_cr2,       linear);
                SAVE(tlb_write_pf_error_code,{ 13'd0, su, rw, `FALSE });
                
            ELSE_IF(current_type == TYPE_READ);
            
                SAVE(read_pf,                `TRUE);
                SAVE(tlb_read_pf_cr2,        linear);
                SAVE(tlb_read_pf_error_code, { 13'd0, su, rw, `FALSE });
                
            ENDIF();
            
            SAVE(state, STATE_IDLE);
            
        ELSE();
        
            SAVE(state, STATE_LOAD_PTE_START);
            
        ENDIF();
    ENDIF();
ENDIF();
*/
    
/*******************************************************************************SCRIPT
IF(state == STATE_LOAD_PTE_START);

    SET(memtype_physical, { pde[31:12], linear[21:12], 2'd0 });
            
    SET(dcacheread_do);
    SET(dcacheread_address,          memtype_physical);
    SET(dcacheread_length,           4'd4);
    SET(dcacheread_cache_disable,    cr0_cd || pde[4] || memtype_cache_disable);
    
    SAVE(state, STATE_LOAD_PTE);

ENDIF();
*/

/*******************************************************************************SCRIPT
IF(state == STATE_RETRY);

    SAVE(state, STATE_IDLE);
    
    SET(tlbread_retry, current_type == TYPE_READ);
ENDIF();
*/

/*******************************************************************************SCRIPT
IF(state == STATE_LOAD_PTE);

    IF(dcacheread_done);
    
        SAVE(pte, dcacheread_data[31:0]);
    
        IF(dcacheread_data[0] == `FALSE || fault_before_pte);
            
            IF(current_type == TYPE_CODE && ~(pr_reset) && ~(pr_reset_waiting));
        
                SAVE(code_pf,                `TRUE);
                SAVE(tlb_code_pf_cr2,        linear);
                SAVE(tlb_code_pf_error_code, { 13'd0, su, rw, dcacheread_data[0] });

                SET(prefetchfifo_signal_pf_do);
            
            ELSE_IF(current_type == TYPE_CHECK);
                
                SAVE(check_pf,               `TRUE);
                SAVE(tlb_check_pf_cr2,       linear);
                SAVE(tlb_check_pf_error_code,{ 13'd0, su, rw, dcacheread_data[0] });
            
            ELSE_IF(current_type == TYPE_WRITE);
                
                SAVE(write_pf,               `TRUE);
                SAVE(tlb_write_pf_cr2,       linear);
                SAVE(tlb_write_pf_error_code,{ 13'd0, su, rw, dcacheread_data[0] });
            
            ELSE_IF(current_type == TYPE_READ);
                
                SAVE(read_pf,            `TRUE);
                SAVE(tlb_read_pf_cr2,        linear);
                SAVE(tlb_read_pf_error_code, { 13'd0, su, rw, dcacheread_data[0] });
                
            ENDIF();
            
            SAVE(state, STATE_IDLE);
                
        ELSE_IF(((current_type == TYPE_READ && ~(pipeline_after_read_empty)) || (current_type == TYPE_CODE && (~(pipeline_after_prefetch_empty) || pr_reset_waiting))) &&
                 (pde[5] == `FALSE || dcacheread_data[5] == `FALSE || (dcacheread_data[6] == `FALSE && rw)));
            
                // no side effects for read or code possible yet
                SAVE(state, STATE_RETRY);

//AO-notlb: ELSE_IF(current_type == TYPE_CODE && (pr_reset || pr_reset_waiting));
//AO-notlb: SAVE(state, STATE_IDLE);

        ELSE();
            SAVE(state, STATE_LOAD_PTE_END);
        ENDIF();
    ENDIF();
ENDIF();
*/


/*******************************************************************************SCRIPT
IF(state == STATE_LOAD_PTE_END);

//NOTE: always write to TLB: IF(cr0_cd == `FALSE && pde[4] == `FALSE && pte[4] == `FALSE);
    
    SET(tlbregs_write_do);
    SET(tlbregs_write_linear,        linear);
    SET(tlbregs_write_physical,      { pte[31:12], linear[11:0] });
    SET(tlbregs_write_pwt,           pte[3]);
    SET(tlbregs_write_pcd,           pte[4]);
    SET(tlbregs_write_combined_rw,   rw_entry);
    SET(tlbregs_write_combined_su,   su_entry);
    
    // PDE not accessed
    IF(pde[5] == `FALSE);
        
        SET(memtype_physical, { cr3_base[31:12], linear[31:22], 2'd0 });
        
        SET(dcachewrite_do);
        SET(dcachewrite_address,         memtype_physical);
        SET(dcachewrite_length,          3'd4);
        SET(dcachewrite_cache_disable,   cr0_cd || cr3_pcd || memtype_cache_disable);
        SET(dcachewrite_write_through,   cr0_nw || cr3_pwt || memtype_write_transparent);
        SET(dcachewrite_data,            pde | 32'h00000020);
        
        SAVE(state, STATE_SAVE_PDE);
        
    // PTE not accessed or has to become dirty
    ELSE_IF(pte[5] == `FALSE || (pte[6] == `FALSE && rw));
        
        SET(memtype_physical, { pde[31:12], linear[21:12], 2'b00 });
    
        SET(dcachewrite_do);
        SET(dcachewrite_address,         memtype_physical);
        SET(dcachewrite_length,          3'd4);
        SET(dcachewrite_cache_disable,   cr0_cd || pde[4] || memtype_cache_disable);
        SET(dcachewrite_write_through,   cr0_nw || pde[3] || memtype_write_transparent);
        SET(dcachewrite_data,            pte[31:0] | 32'h00000020 | ((pte[6] == `FALSE && rw)? 32'h00000040 : 32'h00000000));
    
        SAVE(state, STATE_SAVE_PTE);
        
    ELSE();
        
        IF(current_type == TYPE_WRITE && write_double_state != WRITE_DOUBLE_NONE);
        
            SAVE(state, STATE_WRITE_DOUBLE);
        
        ELSE_IF(current_type == TYPE_WRITE);
        
            SET(memtype_physical, { pte[31:12], linear[11:0] });

            SET(dcachewrite_do);
            SET(dcachewrite_address,         memtype_physical);
            SET(dcachewrite_length,          tlbwrite_length);
            SET(dcachewrite_cache_disable,   cr0_cd || pte[4] || memtype_cache_disable);
            SET(dcachewrite_write_through,   cr0_nw || pte[3] || memtype_write_transparent);
            SET(dcachewrite_data,            tlbwrite_data);
        
            SAVE(state, STATE_WRITE_WAIT);
        
        ELSE_IF(current_type == TYPE_READ);
        
            SAVE(state, STATE_READ_WAIT_START);

//AO-notlb: ELSE_IF(current_type == TYPE_CODE && pr_reset == 1'b0 && pr_reset_waiting == 1'b0);
//AO-notlb: SAVE(tlbcode_do, `TRUE);
//AO-notlb: SAVE(tlbcode_physical,    { pte[31:12], linear[11:0] });
//AO-notlb: SAVE(tlbcode_cache_disable,   cr0_cd);
//AO-notlb: SAVE(state, STATE_IDLE);
        ELSE();
        
            SAVE(state, STATE_IDLE);
        ENDIF();
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT
IF(state == STATE_READ_WAIT_START);
    
    SET(memtype_physical, { pte[31:12], linear[11:0] });
                    
    SET(dcacheread_do);
    SET(dcacheread_address,          memtype_physical);
    SET(dcacheread_length,           tlbread_length);
    SET(dcacheread_cache_disable,    cr0_cd || pte[4] || memtype_cache_disable);

    SAVE(state, STATE_READ_WAIT);
    
ENDIF();
*/

/*******************************************************************************SCRIPT
    
IF(state == STATE_SAVE_PDE);

    IF(dcachewrite_done);
        
        // PTE not accessed or has to become dirty
        IF(pte[5] == `FALSE || (pte[6] == `FALSE && rw));
        
            SAVE(state, STATE_SAVE_PTE_START);
        
        ELSE();
            
            IF(current_type == TYPE_WRITE);
                
                SAVE(state, STATE_WRITE_WAIT_START);
                
            ELSE_IF(current_type == TYPE_READ);
                
                SET(memtype_physical, { pte[31:12], linear[11:0] });

                SET(dcacheread_do);
                SET(dcacheread_address,          memtype_physical);
                SET(dcacheread_length,           tlbread_length);
                SET(dcacheread_cache_disable,    cr0_cd || pte[4] || memtype_cache_disable);

                SAVE(state, STATE_READ_WAIT);
                
//AO-notlb: ELSE_IF(current_type == TYPE_CODE && pr_reset == 1'b0 && pr_reset_waiting == 1'b0);
//AO-notlb: SAVE(tlbcode_do, `TRUE);
//AO-notlb: SAVE(tlbcode_physical,    { pte[31:12], linear[11:0] });
//AO-notlb: SAVE(tlbcode_cache_disable,   cr0_cd);
//AO-notlb: SAVE(state, STATE_IDLE);

            ELSE();
        
                SAVE(state, STATE_IDLE);
                
            ENDIF();
            
        ENDIF();
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_SAVE_PTE_START);

    SET(memtype_physical, { pde[31:12], linear[21:12], 2'b00 });
            
    SET(dcachewrite_do);
    SET(dcachewrite_address,         memtype_physical);
    SET(dcachewrite_length,          3'd4);
    SET(dcachewrite_cache_disable,   cr0_cd || pde[4] || memtype_cache_disable);
    SET(dcachewrite_write_through,   cr0_nw || pde[3] || memtype_write_transparent);
    SET(dcachewrite_data,            pte[31:0] | 32'h00000020 | ((pte[6] == `FALSE && rw)? 32'h00000040 : 32'h00000000));

    SAVE(state, STATE_SAVE_PTE);

ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_WAIT_START);
    
    IF(current_type == TYPE_WRITE && write_double_state != WRITE_DOUBLE_NONE);
        
        SAVE(state, STATE_WRITE_DOUBLE);
    
    ELSE();
    
        SET(memtype_physical, { pte[31:12], linear[11:0] });

        SET(dcachewrite_do);
        SET(dcachewrite_address,         memtype_physical);
        SET(dcachewrite_length,          tlbwrite_length);
        SET(dcachewrite_cache_disable,   cr0_cd || pte[4] || memtype_cache_disable);
        SET(dcachewrite_write_through,   cr0_nw || pte[3] || memtype_write_transparent);
        SET(dcachewrite_data,            tlbwrite_data);

        SAVE(state, STATE_WRITE_WAIT);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_SAVE_PTE);

    IF(dcachewrite_done);

        IF(current_type == TYPE_WRITE);
                
            SAVE(state, STATE_WRITE_WAIT_START);
            
        ELSE_IF(current_type == TYPE_READ);
                
            SET(memtype_physical, { pte[31:12], linear[11:0] });
            
            SET(dcacheread_do);
            SET(dcacheread_address,          memtype_physical);
            SET(dcacheread_length,           tlbread_length);
            SET(dcacheread_cache_disable,    cr0_cd || pte[4] || memtype_cache_disable);

            SAVE(state, STATE_READ_WAIT);
            
//AO-notlb: ELSE_IF(current_type == TYPE_CODE && pr_reset == 1'b0 && pr_reset_waiting == 1'b0);
//AO-notlb: SAVE(tlbcode_do, `TRUE);
//AO-notlb: SAVE(tlbcode_physical,    { pte[31:12], linear[11:0] });
//AO-notlb: SAVE(tlbcode_cache_disable,   cr0_cd);
//AO-notlb: SAVE(state, STATE_IDLE);

        ELSE();
            
            SAVE(state, STATE_IDLE);
        ENDIF();
        
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/tlb.v"

endmodule
