/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module pipeline_if(
    input               clk,
    input               rst_n,
    
    //
    input               config_kernel_mode,
    input       [5:0]   entryhi_asid,
    
    //
    input               micro_flush_do,
    
    //
    input               exception_start,
    input       [31:0]  exception_start_pc,
    
    //
    input               mem_stall,
    
    //
    output              if_exc_address_error,
    output              if_exc_tlb_inv,
    output              if_exc_tlb_miss,
    output              if_ready,
    output      [31:0]  if_instr,
    output reg  [31:0]  if_pc,
    
    //
    input               branch_start,
    input       [31:0]  branch_address,
    
    //
    output      [8:0]   fetch_cache_read_address,
    input       [53:0]  fetch_cache_q,
    
    output      [8:0]   fetch_cache_write_address,
    output              fetch_cache_write_enable,
    output      [53:0]  fetch_cache_data,
    
    //
    output              tlb_ram_fetch_start,
    output      [19:0]  tlb_ram_fetch_vpn,
    input               tlb_ram_fetch_hit,
    input       [49:0]  tlb_ram_fetch_result,
    input               tlb_ram_fetch_missed,
    
    //
    output      [31:0]  ram_instr_address,
    output              ram_instr_req,
    input               ram_instr_ack,
    
    //
    input       [31:0]  ram_result_address,
    input               ram_result_valid,
    input               ram_result_is_read_instr,
    input       [2:0]   ram_result_burstcount,
    input       [31:0]  ram_result
); /* verilator public_module */

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

reg [31:0] branch_pc;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       branch_pc <= 32'h0;
    else if(branch_start)                   branch_pc <= branch_address;
end

reg branch_waiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       branch_waiting <= `FALSE;
    else if(if_ready || exception_start)    branch_waiting <= `FALSE;
    else if(branch_start && ~(if_ready))    branch_waiting <= `TRUE;
end

reg [31:0] exc_start_pc;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       exc_start_pc <= 32'hBFC00000;
    else if(exception_start)                exc_start_pc <= exception_start_pc;
end

reg exc_waiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       exc_waiting <= `TRUE;
    else if(exception_start)                exc_waiting <= `TRUE;
    else if(fetch_state == FETCH_IDLE)      exc_waiting <= `FALSE;
end

wire [31:0] if_pc_next = (exc_waiting)? exc_start_pc : (branch_start)? branch_address : (branch_waiting)? branch_pc : if_pc + 32'd4;

wire if_pc_update = if_ready || (exc_waiting && fetch_state == FETCH_IDLE);

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       if_pc <= 32'h0;
    else if(if_pc_update)   if_pc <= if_pc_next;
end

reg if_pc_updated;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       if_pc_updated <= `FALSE;
    else                    if_pc_updated <= if_pc_update;
end

//------------------------------------------------------------------------------

reg [19:0] if_pc_vpn_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   if_pc_vpn_last <= 20'd0;
    else                if_pc_vpn_last <= if_pc[31:12];
end

reg if_pc_vpn_changed;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       if_pc_vpn_changed <= `FALSE;
    else if(fetch_state == FETCH_IDLE)      if_pc_vpn_changed <= `FALSE;
    else if(if_pc[31:12] != if_pc_vpn_last) if_pc_vpn_changed <= `TRUE;
end

wire if_pc_vpn_change = if_pc[31:12] != if_pc_vpn_last || if_pc_vpn_changed;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

wire tlb_use_at_idle = fetch_state == FETCH_IDLE && (if_pc[31] == 1'b0 || if_pc[31:30] == 2'b11);

wire [19:0] pfn_at_idle = 
    (~(tlb_use_at_idle))?   { 3'b0, if_pc[28:12] } :
    (micro_check_matched)?  micro_check_result[39:20] :
                            tlb_ram_fetch_result[39:20];

reg [19:0] pfn_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   pfn_reg <= 20'd0;
    else if(fetch_state == FETCH_IDLE)  pfn_reg <= pfn_at_idle;
    else if(fetch_tlb_tlb_ok_cache_bad) pfn_reg <= tlb_ram_fetch_result[39:20];
end

wire n_at_idle =
    (~(tlb_use_at_idle))?   if_pc[31:29] == 3'b101 :
    (micro_check_matched)?  micro_check_result[46] :
                            tlb_ram_fetch_result[46];

reg n_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   n_reg <= `FALSE;
    else if(fetch_state == FETCH_IDLE)  n_reg <= n_at_idle;
    else if(fetch_tlb_tlb_ok_cache_bad) n_reg <= tlb_ram_fetch_result[46];
end

reg [53:0] fetch_cache_q_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   fetch_cache_q_reg <= 54'd0;
    else if(fetch_state == FETCH_IDLE)  fetch_cache_q_reg <= fetch_cache_q;
end

//------------------------------------------------------------------------------

localparam [1:0] FETCH_IDLE    = 2'd0;
localparam [1:0] FETCH_TLB     = 2'd1;
localparam [1:0] FETCH_RESULT  = 2'd2;
localparam [1:0] FETCH_STOPPED = 2'd3;

reg [1:0] fetch_state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   fetch_state <= FETCH_STOPPED;
    
    else if(fetch_state == FETCH_STOPPED && exc_waiting)                fetch_state <= FETCH_IDLE;
    
    else if(fetch_idle_exc_address_error)                               fetch_state <= FETCH_STOPPED;
    else if(fetch_idle_tlb_bad_exc_inv)                                 fetch_state <= FETCH_STOPPED;
    else if(fetch_idle_tlb_ok_cache_bad)                                fetch_state <= FETCH_RESULT;
    else if(fetch_idle_tlb_wait)                                        fetch_state <= FETCH_TLB;
    
    else if(fetch_tlb_tlb_ok_cache_ok)                                  fetch_state <= FETCH_IDLE;
    else if(fetch_tlb_tlb_bad_exc_inv || fetch_tlb_tlb_bad_exc_miss)    fetch_state <= FETCH_STOPPED;  
    else if(fetch_tlb_tlb_ok_cache_bad)                                 fetch_state <= FETCH_RESULT;
    
    else if(fetch_result_finished)                                      fetch_state <= FETCH_IDLE;
end

assign if_ready = ~(mem_stall) && ~(exc_waiting) && (
    fetch_idle_tlb_ok_cache_ok ||
    fetch_tlb_tlb_ok_cache_ok ||
    (ram_result_valid && ram_result_is_read_instr && ram_result_address[31:2] == { pfn_reg, if_pc[11:2] } && if_pc[1:0] == 2'b00 && ~(if_pc_vpn_change))
);

assign if_instr =
    (fetch_idle_tlb_ok_cache_ok)?   fetch_cache_q[31:0] :
    (fetch_state == FETCH_TLB)?     fetch_cache_q_reg[31:0] :
                                    ram_result;

assign ram_instr_req     = fetch_idle_tlb_ok_cache_bad || fetch_tlb_tlb_ok_cache_bad || (fetch_state == FETCH_RESULT && ~(was_ram_ack) && ~(ram_instr_ack));
assign ram_instr_address = (fetch_state == FETCH_IDLE)? { pfn_at_idle, if_pc[11:0] } : { pfn_reg, if_pc[11:0] };

assign if_exc_address_error = ~(exc_waiting) && (fetch_idle_exc_address_error || exception_reg == 2'd1);
assign if_exc_tlb_inv       = ~(exc_waiting) && (fetch_idle_tlb_bad_exc_inv || fetch_tlb_tlb_bad_exc_inv || (fetch_tlb_tlb_bad_exc_miss && if_pc[31] == 1'b1) || exception_reg == 2'd2);
assign if_exc_tlb_miss      = ~(exc_waiting) && ((fetch_tlb_tlb_bad_exc_miss && if_pc[31] == 1'b0) || exception_reg == 2'd3);

reg [1:0] exception_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       exception_reg <= 2'd0;
    else if(exception_start || exc_waiting) exception_reg <= 2'd0;
    else if(if_exc_address_error)           exception_reg <= 2'd1;
    else if(if_exc_tlb_inv)                 exception_reg <= 2'd2;
    else if(if_exc_tlb_miss)                exception_reg <= 2'd3;
end

//------------------------------------------------------------------------------

assign tlb_ram_fetch_start = if_pc_updated || (fetch_state == FETCH_IDLE && (~(tlb_ram_fetch_active) || tlb_ram_fetch_hit || tlb_ram_fetch_missed)) || (fetch_state == FETCH_TLB && ~(tlb_ram_fetch_active));
assign tlb_ram_fetch_vpn   = if_pc[31:12];

reg tlb_ram_fetch_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tlb_ram_fetch_active <= `FALSE;
    else if(tlb_ram_fetch_start)                        tlb_ram_fetch_active <= `TRUE;
    else if(tlb_ram_fetch_hit || tlb_ram_fetch_missed)  tlb_ram_fetch_active <= `FALSE;
end

//------------------------------------------------------------------------------ state IDLE

wire fetch_idle_no_addr_exc = if_pc[1:0] == 2'b00 && (config_kernel_mode || if_pc[31] == 1'b0); 
wire fetch_idle_exc_address_error = fetch_state == FETCH_IDLE && ~(fetch_idle_no_addr_exc) && ~(exc_waiting);

wire fetch_idle_tlb_ok_cache_ok = fetch_state == FETCH_IDLE && ~(exc_waiting) && fetch_cache_q[53] && ~(n_at_idle) && fetch_idle_no_addr_exc && (
    (~(tlb_use_at_idle) && fetch_cache_q[52:32] == { pfn_at_idle, if_pc[11] }) ||                                                           //tlb not in use
    (tlb_use_at_idle && micro_check_matched && micro_check_result[48] && fetch_cache_q[52:32] == {micro_check_result[39:20], if_pc[11]})    //tlb in micro
);

wire fetch_idle_tlb_bad_exc_inv = fetch_state == FETCH_IDLE && ~(exc_waiting) && tlb_use_at_idle && fetch_idle_no_addr_exc && (
    (micro_check_matched && ~(micro_check_result[48])) //tlb in micro
);

wire fetch_idle_tlb_ok_cache_bad = fetch_state == FETCH_IDLE && ~(exc_waiting) && fetch_idle_no_addr_exc && (
    (~(tlb_use_at_idle) && (~(fetch_cache_q[53]) || n_at_idle || fetch_cache_q[52:32] != { pfn_at_idle, if_pc[11] })) ||                                                        //tlb not in use
    (tlb_use_at_idle && micro_check_matched && micro_check_result[48] && (~(fetch_cache_q[53]) || n_at_idle || fetch_cache_q[52:32] != {micro_check_result[39:20], if_pc[11]})) //tlb in micro
);

wire fetch_idle_tlb_wait = fetch_state == FETCH_IDLE && ~(exc_waiting) && fetch_idle_no_addr_exc && tlb_use_at_idle && ~(micro_check_matched);

//------------------------------------------------------------------------------ state TLB

wire fetch_tlb_tlb_ok_cache_ok  = fetch_state == FETCH_TLB && tlb_ram_fetch_hit && tlb_ram_fetch_result[48] && fetch_cache_q_reg[53] && fetch_cache_q_reg[52:32] == { tlb_ram_fetch_result[39:20], if_pc[11] };

wire fetch_tlb_tlb_bad_exc_inv  = fetch_state == FETCH_TLB && tlb_ram_fetch_hit    && ~(tlb_ram_fetch_result[48]);
wire fetch_tlb_tlb_bad_exc_miss = fetch_state == FETCH_TLB && ~(tlb_ram_fetch_hit) && tlb_ram_fetch_missed;

wire fetch_tlb_tlb_ok_cache_bad = fetch_state == FETCH_TLB && tlb_ram_fetch_hit && tlb_ram_fetch_result[48] && (~(fetch_cache_q_reg[53]) || fetch_cache_q_reg[52:32] != { tlb_ram_fetch_result[39:20], if_pc[11] });

//------------------------------------------------------------------------------ state RESULT

reg was_ram_ack;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       was_ram_ack <= `FALSE;
    else if(fetch_state != FETCH_RESULT)    was_ram_ack <= `FALSE;
    else if(ram_instr_ack)                  was_ram_ack <= `TRUE;
end

reg is_ram_stalled;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   is_ram_stalled <= `FALSE;
    else if(mem_stall && ram_result_valid && ram_result_is_read_instr && ram_result_burstcount == 3'd1) is_ram_stalled <= `TRUE;
    else if(~(mem_stall))                                                                               is_ram_stalled <= `FALSE;
end

wire fetch_result_finished = ~(mem_stall) && fetch_state == FETCH_RESULT && ((ram_result_valid && ram_result_is_read_instr && ram_result_burstcount == 3'd1) || is_ram_stalled);

//------------------------------------------------------------------------------ cache
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

assign fetch_cache_read_address  = (if_pc_update)? if_pc_next[10:2] : if_pc[10:2];

assign fetch_cache_write_address = ram_result_address[10:2];

assign fetch_cache_write_enable = (~(n_reg) && ram_result_valid && ram_result_is_read_instr);

/*
[53]    valid
[52:32] tag
[31:0]  data
*/
assign fetch_cache_data = { 1'b1, ram_result_address[31:11], ram_result }; //load

//------------------------------------------------------------------------------ micro
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

/*
[19:0]  vpn
[39:20] pfn
[45:40] asid
[46]    n noncachable
[47]    d dirty = write-enable
[48]    v valid
[49]    g global
*/

//input               micro_check_matched,
//input       [49:0]  micro_check_result,

wire        micro_check_do   = tlb_use_at_idle;
wire [19:0] micro_check_vpn  = if_pc[31:12];
wire [5:0]  micro_check_asid = entryhi_asid;

wire micro_write_do = tlb_ram_fetch_hit && fetch_state == FETCH_TLB;

wire [49:0] micro_write_value = tlb_ram_fetch_result;

wire        micro_check_matched;
wire [49:0] micro_check_result;

memory_instr_tlb_micro memory_instr_tlb_micro_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //
    .micro_flush_do     (micro_flush_do),       //input
    
    //
    .micro_write_do     (micro_write_do),       //input
    .micro_write_value  (micro_write_value),    //input [49:0]
    
    //
    .micro_check_do     (micro_check_do),       //input
    .micro_check_vpn    (micro_check_vpn),      //input [19:0]
    .micro_check_asid   (micro_check_asid),     //input [5:0]
    .micro_check_matched(micro_check_matched),  //output
    .micro_check_result (micro_check_result)    //output [49:0]
);

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, ram_result_address[1:0], micro_check_result[49], micro_check_result[47], micro_check_result[45:40], micro_check_result[19:0], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
