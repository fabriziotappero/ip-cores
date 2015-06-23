/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module pipeline_mem(
    input               clk,
    input               rst_n,
    
    //
    input       [5:0]   interrupt_vector,
    
    //
    output              mem_stall,
    
    //
    output              config_kernel_mode,
    output              config_switch_caches,
    
    //
    input       [6:0]   exe_cmd,
    input       [31:0]  exe_instr,
    input       [31:0]  exe_pc_plus4,
    input               exe_pc_user_seg,
    input       [31:0]  exe_badvpn,
    input       [31:0]  exe_a,
    input       [31:0]  exe_b,
    input       [1:0]   exe_branched,
    input       [31:0]  exe_branch_address,
    input               exe_cmd_cp0,
    input               exe_cmd_load,
    input               exe_cmd_store,

    //
    input       [4:0]   exe_result_index,
    input       [31:0]  exe_result,
    
    //
    output reg  [4:0]   mem_result_index,
    output      [31:0]  mem_result,
    
    //
    output      [4:0]   muldiv_result_index,
    output      [31:0]  muldiv_result,
    
    //
    output              tlb_ram_read_do,
    output      [5:0]   tlb_ram_read_index,
    input               tlb_ram_read_result_ready,
    input       [49:0]  tlb_ram_read_result,
    
    //
    output              tlb_ram_write_do,
    output      [5:0]   tlb_ram_write_index,
    output      [49:0]  tlb_ram_write_value,
    
    //
    output              tlb_ram_data_start,
    output      [19:0]  tlb_ram_data_vpn,
    input               tlb_ram_data_hit,
    input       [5:0]   tlb_ram_data_index,
    input       [49:0]  tlb_ram_data_result,
    input               tlb_ram_data_missed,
    
    //
    output              exception_start,
    output      [31:0]  exception_start_pc,
    
    //
    output              micro_flush_do,
    output      [5:0]   entryhi_asid,
    
    //
    input       [31:0]  data_address_next,
    input       [31:0]  data_address,
    
    //
    output      [8:0]   data_cache_read_address,
    input       [53:0]  data_cache_q,
    
    output      [8:0]   data_cache_write_address,
    output              data_cache_write_enable,
    output      [53:0]  data_cache_data,
    
    //
    output              ram_fifo_wrreq,
    output      [66:0]  ram_fifo_data,
    input               ram_fifo_full,
    
    //
    input       [31:0]  ram_result_address,
    input               ram_result_valid,
    input               ram_result_is_read_instr,
    input       [2:0]   ram_result_burstcount,
    input       [31:0]  ram_result
); /* verilator public_module */

//------------------------------------------------------------------------------ pipeline stall
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

assign mem_stall = ~(exception_start) && (
    muldiv_busy ||
    exe_cmd_tlbp || (tlbp_in_progress && ~(tlbp_update)) ||
    load_idle_tlb_ok_cache_bad_fifo_ok || load_idle_tlb_ok_cache_bad_fifo_bad || load_idle_tlb_wait || load_state != LOAD_IDLE ||
    store_idle_tlb_ok_fifo_bad || store_idle_tlb_wait || store_state != STORE_IDLE
);

reg mem_stalled;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_stalled <= `FALSE;
    else                mem_stalled <= mem_stall;
end

//------------------------------------------------------------------------------ instruction decoding
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

wire [4:0] exe_instr_rt = exe_instr[20:16];
wire [4:0] exe_instr_rd = exe_instr[15:11];

wire mem_exc_coproc0_unusable = ~(config_coproc0_usable) && ~(config_kernel_mode) && exe_cmd_cp0;

wire exe_cmd_mtc0  = ~(mem_exc_coproc0_unusable) && ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd == `CMD_mtc0;
wire exe_cmd_rfe   = ~(mem_exc_coproc0_unusable) && ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd == `CMD_cp0_rfe;
wire exe_cmd_tlbr  = ~(mem_exc_coproc0_unusable) && ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd == `CMD_cp0_tlbr;
wire exe_cmd_tlbp  = ~(mem_exc_coproc0_unusable) && ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd == `CMD_cp0_tlbp;
wire exe_cmd_tlbwi = ~(mem_exc_coproc0_unusable) && ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd == `CMD_cp0_tlbwi;
wire exe_cmd_tlbwr = ~(mem_exc_coproc0_unusable) && ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd == `CMD_cp0_tlbwr;

wire exe_cmd_load_do  = ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd_load;
wire exe_cmd_store_do = ~(exception_start) && ~(config_kernel_mode_exc_now) && exe_cmd_store;

//------------------------------------------------------------------------------ next pipeline stage
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

reg config_kernel_mode_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   config_kernel_mode_last <= `TRUE;
    else                config_kernel_mode_last <= config_kernel_mode;
end

reg config_kernel_mode_changed;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       config_kernel_mode_changed <= `FALSE;
    else if(config_kernel_mode)             config_kernel_mode_changed <= `FALSE;
    else if(config_kernel_mode_exc_wait)    config_kernel_mode_changed <= `TRUE;
    else if(exe_cmd != `CMD_null)           config_kernel_mode_changed <= `FALSE;
end

wire config_kernel_mode_exc_now  = (config_kernel_mode_changed || (config_kernel_mode_last && ~(config_kernel_mode))) && exe_cmd != `CMD_null && exe_pc_user_seg;
wire config_kernel_mode_exc_wait = ~(config_kernel_mode_changed) && config_kernel_mode_last && ~(config_kernel_mode) && exe_cmd == `CMD_null;

//------------------------------------------------------------------------------

wire [4:0] mem_result_index_next =
    (exception_start || config_kernel_mode_exc_now)?        5'd0 :
    (exe_cmd == `CMD_cfc1_detect && config_coproc1_usable)? exe_instr_rt :
    (data_finished && load_idle_tlb_ok_finished)?           exe_instr_rt :
    (data_finished)?                                        load_instr_rt_reg :
    (muldiv_result_index != 5'd0)?                          muldiv_result_index :    
    (exe_cmd == `CMD_mfc0 && ~(mem_exc_coproc0_unusable))?  exe_instr_rt :
                                                            exe_result_index;

wire [31:0] mem_result_next =
    (exe_cmd == `CMD_cfc1_detect && config_coproc1_usable)? 32'd0 :
    (muldiv_result_index != 5'd0)?                          muldiv_result :
    (exe_cmd == `CMD_mfc0 && ~(mem_exc_coproc0_unusable))?  coproc0_output :
                                                            exe_result;

wire [6:0] mem_cmd_next =
    (exception_start)?                                                                                                          `CMD_null :
    (config_kernel_mode_exc_now)?                                                                                               `CMD_exc_load_addr_err :
    (exe_cmd == `CMD_cfc1_detect && ~(config_coproc1_usable))?                                                                  `CMD_exc_coproc_unusable :
    (mem_exc_coproc0_unusable)?                                                                                                 `CMD_exc_coproc_unusable :
    (store_idle_tlb_bad_exc_modif || store_tlb_tlb_bad_exc_modif)?                                                              `CMD_exc_tlb_modif :
    (load_idle_tlb_bad_exc_inv || load_tlb_tlb_bad_exc_inv || (load_tlb_tlb_bad_exc_miss && data_address_reg[31] == 1'b1))?     `CMD_exc_load_tlb :
    (store_idle_tlb_bad_exc_inv || store_tlb_tlb_bad_exc_inv || (store_tlb_tlb_bad_exc_miss && data_address_reg[31] == 1'b1))?  `CMD_exc_store_tlb :
    (load_tlb_tlb_bad_exc_miss  && data_address_reg[31] == 1'b0)?                                                               `CMD_exc_tlb_load_miss :
    (store_tlb_tlb_bad_exc_miss && data_address_reg[31] == 1'b0)?                                                               `CMD_exc_tlb_store_miss :
                                                                                                                                exe_cmd;
wire [31:0] mem_badvpn_next =
    (exe_cmd_load_do || exe_cmd_store_do)?                      { data_address[31:2],     ((exe_instr[27:26] == 2'b10)? 2'b00 : data_address[1:0]) } :
    (load_state != LOAD_IDLE || store_state != STORE_IDLE)?     { data_address_reg[31:2], ((mem_left_right   == 2'b10)? 2'b00 : data_address_reg[1:0]) } :
                                                                exe_badvpn;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_result_index <= 5'd0;
    else                mem_result_index <= mem_result_index_next;
end

reg [31:0] mem_result_nodata;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_result_nodata <= 32'd0;
    else                mem_result_nodata <= mem_result_next;
end

reg [31:0] mem_result_data;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_result_data <= 32'd0;
    else                mem_result_data <= data_finished_value;
end

reg mem_data_finished;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_data_finished <= `FALSE;
    else                mem_data_finished <= data_finished;
end

assign mem_result = (mem_data_finished)? mem_result_data : mem_result_nodata;

//------------------------------------------------------------------------------


reg [6:0] mem_cmd;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_cmd <= `CMD_null;
    else                mem_cmd <= mem_cmd_next;
end

reg [31:0] mem_branch_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_branch_address <= 32'd0;
    else                mem_branch_address <= exe_branch_address;
end

reg [31:0] mem_instr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_instr <= 32'd0;
    else                mem_instr <= exe_instr;
end

reg [31:0] mem_badvpn;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mem_badvpn <= 32'd0;
    else                mem_badvpn <= mem_badvpn_next;
end

reg [1:0] mem_branched;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mem_branched <= 2'd0;
    else if(~(mem_stalled)) mem_branched <= exe_branched;
end

reg [31:0] mem_pc_plus4;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mem_pc_plus4 <= 32'd0;
    else if(~(mem_stalled)) mem_pc_plus4 <= exe_pc_plus4;
end

//------------------------------------------------------------------------------ tlb
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//input               tlb_ram_data_hit,
//input       [5:0]   tlb_ram_data_index,
//input       [49:0]  tlb_ram_data_result,
//input               tlb_ram_data_missed

assign tlb_ram_write_do    = exe_cmd_tlbwi || exe_cmd_tlbwr;
assign tlb_ram_write_index = tlbw_index;
assign tlb_ram_write_value = tlbw_value;

assign tlb_ram_read_do    = exe_cmd_tlbr;
assign tlb_ram_read_index = tlbr_index;

assign tlb_ram_data_start = exe_cmd_tlbp || exe_cmd_load_do || exe_cmd_store_do;

assign tlb_ram_data_vpn =
    (exe_cmd_tlbp || tlbp_in_progress)?     tlbw_value[19:0] :
    (exe_cmd_load_do || exe_cmd_store_do)?  data_address[31:12] :
                                            data_address_reg[31:12];

//------------------------------------------------------------------------------ tlb probe

reg tlbp_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       tlbp_in_progress <= `FALSE;
    else if(exe_cmd_tlbp)   tlbp_in_progress <= `TRUE;
    else if(tlbp_update)    tlbp_in_progress <= `FALSE;
end

wire       tlbp_update = tlbp_in_progress && (tlb_ram_data_hit || tlb_ram_data_missed);
wire       tlbp_hit    = tlb_ram_data_hit;
wire [5:0] tlbp_index  = tlb_ram_data_index;

//------------------------------------------------------------------------------ load / store common
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

wire tlb_use_at_idle = (exe_cmd_load_do || exe_cmd_store_do) && (data_address[31] == 1'b0 || data_address[31:30] == 2'b11);

wire [19:0] pfn_at_idle = 
    (~(tlb_use_at_idle))?   { 3'b0, data_address[28:12] } :
    (micro_check_matched)?  micro_check_result[39:20] :
                            tlb_ram_data_result[39:20];

reg [19:0] pfn_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       pfn_reg <= 20'd0;
    else if(exe_cmd_load_do || exe_cmd_store_do)            pfn_reg <= pfn_at_idle;
    else if(load_tlb_tlb_ok_cache_bad || store_tlb_tlb_ok)  pfn_reg <= tlb_ram_data_result[39:20];
end

wire n_at_idle =
    (~(tlb_use_at_idle))?   data_address[31:29] == 3'b101 :
    (micro_check_matched)?  micro_check_result[46] :
                            tlb_ram_data_result[46];

reg n_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       n_reg <= `FALSE;
    else if(exe_cmd_load_do || exe_cmd_store_do)            n_reg <= n_at_idle;
    else if(load_tlb_tlb_ok_cache_bad || store_tlb_tlb_ok)  n_reg <= tlb_ram_data_result[46];
end

wire [3:0] byte_byteenable =
    (data_address[1:0] == 2'b00)?   4'b0001 :
    (data_address[1:0] == 2'b01)?   4'b0010 :
    (data_address[1:0] == 2'b10)?   4'b0100 :
                                    4'b1000;
wire [3:0] halfword_byteenable =
    (data_address[1:0] == 2'b00)?   4'b0011 :
                                    4'b1100;
wire [3:0] lwl_byteenable =
    (data_address[1:0] == 2'b00)?   4'b0001 :
    (data_address[1:0] == 2'b01)?   4'b0011 :
    (data_address[1:0] == 2'b10)?   4'b0111 :
                                    4'b1111;
wire [3:0] lwr_byteenable =
    (data_address[1:0] == 2'b00)?   4'b1111 :
    (data_address[1:0] == 2'b01)?   4'b1110 :
    (data_address[1:0] == 2'b10)?   4'b1100 :
                                    4'b1000;
wire [3:0] data_byteenable =
    (load_idle_cmd_lb || load_idle_cmd_lbu || load_idle_cmd_sb)?    byte_byteenable :
    (load_idle_cmd_lh || load_idle_cmd_lhu || load_idle_cmd_sh)?    halfword_byteenable :
    (load_idle_cmd_lwl || load_idle_cmd_swl)?                       lwl_byteenable :
    (load_idle_cmd_lwr || load_idle_cmd_swr)?                       lwr_byteenable :
                                                                    4'b1111;

reg [3:0] data_byteenable_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           data_byteenable_reg <= 4'b0;
    else if(exe_cmd_load_do)    data_byteenable_reg <= load_idle_byteenable;
    else if(exe_cmd_store_do)   data_byteenable_reg <= data_byteenable;
end

reg [53:0] data_cache_q_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           data_cache_q_reg <= 54'd0;
    else if(exe_cmd_load_do)    data_cache_q_reg <= data_cache_q;
    else if(exe_cmd_store_do)   data_cache_q_reg <= { data_cache_q[53:32], store_idle_data };
end

reg [31:0] data_address_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                             data_address_reg <= 32'b0;
    else if(exe_cmd_load_do || exe_cmd_store_do)  data_address_reg <= data_address;
end

reg [1:0] mem_left_right;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                             mem_left_right <= 2'b0;
    else if(exe_cmd_load_do || exe_cmd_store_do)  mem_left_right <= exe_instr[27:26];
end

//------------------------------------------------------------------------------ load
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

localparam [1:0] LOAD_IDLE   = 2'd0;
localparam [1:0] LOAD_TLB    = 2'd1;
localparam [1:0] LOAD_FIFO   = 2'd2;
localparam [1:0] LOAD_RESULT = 2'd3;

reg [1:0] load_state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       load_state <= LOAD_IDLE;
    else if(load_idle_tlb_ok_cache_bad_fifo_ok)                                                                             load_state <= LOAD_RESULT;
    else if(load_idle_tlb_ok_cache_bad_fifo_bad)                                                                            load_state <= LOAD_FIFO;
    else if(load_idle_tlb_wait)                                                                                             load_state <= LOAD_TLB;
    else if(load_tlb_tlb_ok_finished)                                                                                       load_state <= LOAD_IDLE;
    else if(load_tlb_tlb_bad_exc_inv || load_tlb_tlb_bad_exc_miss)                                                          load_state <= LOAD_IDLE;
    else if(load_tlb_tlb_ok_cache_bad_fifo_ok)                                                                              load_state <= LOAD_RESULT;
    else if(load_tlb_tlb_ok_cache_bad_fifo_bad)                                                                             load_state <= LOAD_FIFO;
    else if(load_fifo_end)                                                                                                  load_state <= LOAD_RESULT;
    else if(load_state == LOAD_RESULT && ram_result_valid && ~(ram_result_is_read_instr) && ram_result_burstcount == 3'd1)  load_state <= LOAD_IDLE;
end

wire sr_cm_clear = config_isolate_cache && (load_idle_tlb_ok_cache_ok || load_tlb_tlb_ok_cache_ok);
wire sr_cm_set   = config_isolate_cache && (load_idle_tlb_ok_cache_isolate || load_tlb_tlb_ok_cache_isolate);

wire        data_finished       = load_idle_tlb_ok_finished || load_tlb_tlb_ok_finished || (ram_result_valid && ~(ram_result_is_read_instr) && ram_result_address[31:2] == { pfn_reg, data_address_reg[11:2] });
wire [31:0] data_finished_value = (load_idle_tlb_ok_finished)? load_idle_result[31:0] : load_result_value;

//------------------------------------------------------------------------------ state IDLE

wire load_idle_cmd_lb  = exe_instr[28:26] == 3'b000;
wire load_idle_cmd_lbu = exe_instr[28:26] == 3'b100;
wire load_idle_cmd_lh  = exe_instr[28:26] == 3'b001;
wire load_idle_cmd_lhu = exe_instr[28:26] == 3'b101;
wire load_idle_cmd_lw  = exe_instr[28:26] == 3'b011;
wire load_idle_cmd_lwl = exe_instr[28:26] == 3'b010;
wire load_idle_cmd_lwr = exe_instr[28:26] == 3'b110;

wire load_idle_cmd_sb  = exe_instr[28:26] == 3'b000;
wire load_idle_cmd_sh  = exe_instr[28:26] == 3'b001;
//not used: wire load_idle_cmd_sw  = exe_instr[28:26] == 3'b011;
wire load_idle_cmd_swl = exe_instr[28:26] == 3'b010;
wire load_idle_cmd_swr = exe_instr[28:26] == 3'b110;

wire [31:0] load_idle_rt = (exe_instr_rt == mem_result_index)?  mem_result : exe_b;

wire [7:0] load_idle_byte =
    (data_address[1:0] == 2'd0)?    data_cache_q[7:0] :
    (data_address[1:0] == 2'd1)?    data_cache_q[15:8] :
    (data_address[1:0] == 2'd2)?    data_cache_q[23:16] :
                                    data_cache_q[31:24];
wire [15:0] load_idle_halfword =
    (data_address[1:0] == 2'd0)?    data_cache_q[15:0] :
                                    data_cache_q[31:16];

wire [31:0] load_idle_lwl =
    (data_address[1:0] == 2'd0)?    { data_cache_q[7:0],  load_idle_rt[23:0] } :
    (data_address[1:0] == 2'd1)?    { data_cache_q[15:0], load_idle_rt[15:0] } :
    (data_address[1:0] == 2'd2)?    { data_cache_q[23:0], load_idle_rt[7:0] } :
                                    data_cache_q[31:0];
    
wire [31:0] load_idle_lwr =
    (data_address[1:0] == 2'd0)?    data_cache_q[31:0] :
    (data_address[1:0] == 2'd1)?    { load_idle_rt[31:24], data_cache_q[31:8] } :
    (data_address[1:0] == 2'd2)?    { load_idle_rt[31:16], data_cache_q[31:16] } :
                                    { load_idle_rt[31:8],  data_cache_q[31:24] };
    
wire [31:0] load_idle_result =
    (load_idle_cmd_lb)?     { {24{load_idle_byte[7]}}, load_idle_byte } :
    (load_idle_cmd_lbu)?    { 24'd0, load_idle_byte } :
    (load_idle_cmd_lh)?     { {16{load_idle_halfword[15]}}, load_idle_halfword } :
    (load_idle_cmd_lhu)?    { 16'd0, load_idle_halfword } :
    (load_idle_cmd_lw)?     data_cache_q[31:0] :
    (load_idle_cmd_lwl)?    load_idle_lwl :
                            load_idle_lwr;

wire [3:0] load_idle_byteenable = (~(n_at_idle))? 4'hF : data_byteenable;

reg [2:0] load_cmd_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           load_cmd_reg <= 3'b0;
    else if(exe_cmd_load_do)    load_cmd_reg <= exe_instr[28:26];
end

reg [4:0] load_instr_rt_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           load_instr_rt_reg <= 5'b0;
    else if(exe_cmd_load_do)    load_instr_rt_reg <= exe_instr_rt;
end

reg [31:0] load_rt_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           load_rt_reg <= 32'd0;
    else if(exe_cmd_load_do)    load_rt_reg <= load_idle_rt;
end

wire load_idle_tlb_ok_cache_ok = exe_cmd_load_do && data_cache_q[53] && ~(n_at_idle) && (
    (~(tlb_use_at_idle) && data_cache_q[52:32] == { pfn_at_idle, data_address[11] }) ||                                                        //tlb not in use
    (tlb_use_at_idle && micro_check_matched && micro_check_result[48] && data_cache_q[52:32] == {micro_check_result[39:20], data_address[11]}) //tlb in micro
);

wire load_idle_tlb_ok_cache_isolate = exe_cmd_load_do && config_isolate_cache && (
    ~(tlb_use_at_idle) ||                                               //tlb not in use
    (tlb_use_at_idle && micro_check_matched && micro_check_result[48])  //tlb in micro
);

wire load_idle_tlb_ok_finished = load_idle_tlb_ok_cache_ok || load_idle_tlb_ok_cache_isolate;

wire load_idle_tlb_bad_exc_inv = exe_cmd_load_do && tlb_use_at_idle && (
    (micro_check_matched && ~(micro_check_result[48])) //tlb in micro
);

wire load_idle_tlb_ok_cache_bad = exe_cmd_load_do && (
    (~(tlb_use_at_idle) && (~(data_cache_q[53]) || n_at_idle || data_cache_q[52:32] != { pfn_at_idle, data_address[11] })) ||                                                          //tlb not in use
    (tlb_use_at_idle && micro_check_matched && micro_check_result[48] && (~(data_cache_q[53]) || n_at_idle || data_cache_q[52:32] != { micro_check_result[39:20], data_address[11] })) //tlb in micro
);
wire load_idle_tlb_ok_cache_bad_fifo_ok  = load_idle_tlb_ok_cache_bad && ~(ram_fifo_full);
wire load_idle_tlb_ok_cache_bad_fifo_bad = load_idle_tlb_ok_cache_bad && ram_fifo_full;
    
wire load_idle_tlb_wait = exe_cmd_load_do && tlb_use_at_idle && ~(micro_check_matched);

//------------------------------------------------------------------------------ state TLB

wire load_tlb_tlb_ok_cache_ok      = load_state == LOAD_TLB && tlb_ram_data_hit && tlb_ram_data_result[48] && data_cache_q_reg[53] && data_cache_q_reg[52:32] == { tlb_ram_data_result[39:20], data_address_reg[11] };
wire load_tlb_tlb_ok_cache_isolate = load_state == LOAD_TLB && tlb_ram_data_hit && tlb_ram_data_result[48] && config_isolate_cache;

wire load_tlb_tlb_ok_finished = load_tlb_tlb_ok_cache_ok || load_tlb_tlb_ok_cache_isolate;

wire load_tlb_tlb_bad_exc_inv = load_state == LOAD_TLB && tlb_ram_data_hit && ~(tlb_ram_data_result[48]);
wire load_tlb_tlb_bad_exc_miss= load_state == LOAD_TLB && ~(tlb_ram_data_hit) && tlb_ram_data_missed;

wire load_tlb_tlb_ok_cache_bad =
    load_state == LOAD_TLB && tlb_ram_data_hit && tlb_ram_data_result[48] && (~(data_cache_q_reg[53]) || data_cache_q_reg[52:32] != { tlb_ram_data_result[39:20], data_address_reg[11] });

wire load_tlb_tlb_ok_cache_bad_fifo_ok  = load_tlb_tlb_ok_cache_bad && ~(ram_fifo_full);
wire load_tlb_tlb_ok_cache_bad_fifo_bad = load_tlb_tlb_ok_cache_bad && ram_fifo_full;

//------------------------------------------------------------------------------ state FIFO

wire load_fifo_end = load_state == LOAD_FIFO && ~(ram_fifo_full);

//------------------------------------------------------------------------------ state TLB or RESULT

wire load_result_cmd_lb  = load_cmd_reg == 3'b000;
wire load_result_cmd_lbu = load_cmd_reg == 3'b100;
wire load_result_cmd_lh  = load_cmd_reg == 3'b001;
wire load_result_cmd_lhu = load_cmd_reg == 3'b101;
wire load_result_cmd_lw  = load_cmd_reg == 3'b011;
wire load_result_cmd_lwl = load_cmd_reg == 3'b010;
//not used: wire load_result_cmd_lwr = load_cmd_reg == 3'b110;

wire [31:0] load_result_data = (load_state == LOAD_TLB)? data_cache_q_reg[31:0] : ram_result;

wire [7:0] load_result_byte =
    (data_address_reg[1:0] == 2'd0)?    load_result_data[7:0] :
    (data_address_reg[1:0] == 2'd1)?    load_result_data[15:8] :
    (data_address_reg[1:0] == 2'd2)?    load_result_data[23:16] :
                                        load_result_data[31:24];
wire [15:0] load_result_halfword =
    (data_address_reg[1:0] == 2'd0)?    load_result_data[15:0] :
                                        load_result_data[31:16];

wire [31:0] load_result_lwl =
    (data_address_reg[1:0] == 2'd0)?    { load_result_data[7:0],  load_rt_reg[23:0] } :
    (data_address_reg[1:0] == 2'd1)?    { load_result_data[15:0], load_rt_reg[15:0] } :
    (data_address_reg[1:0] == 2'd2)?    { load_result_data[23:0], load_rt_reg[7:0] } :
                                        load_result_data;
    
wire [31:0] load_result_lwr =
    (data_address_reg[1:0] == 2'd0)?    load_result_data :
    (data_address_reg[1:0] == 2'd1)?    { load_rt_reg[31:24], load_result_data[31:8] } :
    (data_address_reg[1:0] == 2'd2)?    { load_rt_reg[31:16], load_result_data[31:16] } :
                                        { load_rt_reg[31:8],  load_result_data[31:24] };
    
wire [31:0] load_result_value =
    (load_result_cmd_lb)?   { {24{load_result_byte[7]}}, load_result_byte } :
    (load_result_cmd_lbu)?  { 24'd0, load_result_byte } :
    (load_result_cmd_lh)?   { {16{load_result_halfword[15]}}, load_result_halfword } :
    (load_result_cmd_lhu)?  { 16'd0, load_result_halfword } :
    (load_result_cmd_lw)?   load_result_data :
    (load_result_cmd_lwl)?  load_result_lwl :
                            load_result_lwr;

//------------------------------------------------------------------------------ store
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

/*
Possible store states:

    State STORE_IDLE:
    - store_idle_tlb_ok_fifo_ok  -> stay at IDLE; write fifo / cache / micro
    - store_idle_tlb_exc         -> stay at IDLE; exception
    - store_idle_tlb_ok_fifo_bad -> goto FIFO; write micro
    - store_idle_tlb_wait        -> goto TLB
    
    State STORE_FIFO:
    - store_fifo_end             -> goto IDLE; write fifo / cache
    
    State STORE_TLB:
    - store_tlb_tlb_ok_fifo_ok   -> goto IDLE; write fifo / cache / micro
    - store_tlb_tlb_ok_fifo_bad  -> goto FIFO; write micro
*/

localparam [1:0] STORE_IDLE = 2'd0;
localparam [1:0] STORE_FIFO = 2'd1;
localparam [1:0] STORE_TLB  = 2'd2;

reg [1:0] store_state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                               store_state <= STORE_IDLE;
    else if(store_idle_tlb_ok_fifo_bad)                                                             store_state <= STORE_FIFO;
    else if(store_fifo_end)                                                                         store_state <= STORE_IDLE;
    else if(store_idle_tlb_wait)                                                                    store_state <= STORE_TLB;
    else if(store_tlb_tlb_ok_fifo_ok)                                                               store_state <= STORE_IDLE;
    else if(store_tlb_tlb_ok_fifo_bad)                                                              store_state <= STORE_FIFO;
    else if(store_tlb_tlb_bad_exc_miss || store_tlb_tlb_bad_exc_modif || store_tlb_tlb_bad_exc_inv) store_state <= STORE_IDLE;
end

//------------------------------------------------------------------------------ IDLE state

wire store_idle_tlb_ok = exe_cmd_store_do && (
    ~(tlb_use_at_idle) ||                                                           //tlb not in use
    (tlb_use_at_idle && micro_check_matched && micro_check_result[48:47] == 2'b11)  //tlb in micro
);

wire store_idle_tlb_ok_fifo_ok = store_idle_tlb_ok && ~(ram_fifo_full);
wire store_idle_tlb_ok_fifo_bad= store_idle_tlb_ok && ram_fifo_full;

wire [31:0] store_idle_data_zero =
    (load_idle_cmd_swl && data_address[1:0] == 2'b00)?  { 24'd0, exe_b[31:24] } :
    (load_idle_cmd_swl && data_address[1:0] == 2'b01)?  { 16'd0, exe_b[31:16] } :
    (load_idle_cmd_swl && data_address[1:0] == 2'b10)?  { 8'd0,  exe_b[31:8] } :
    (load_idle_cmd_swl && data_address[1:0] == 2'b11)?  exe_b :
    (load_idle_cmd_swr && data_address[1:0] == 2'b00)?  exe_b :
    (load_idle_cmd_swr && data_address[1:0] == 2'b01)?  { exe_b[23:0], 8'd0 } :
    (load_idle_cmd_swr && data_address[1:0] == 2'b10)?  { exe_b[15:0], 16'd0 } :
    (load_idle_cmd_swr && data_address[1:0] == 2'b11)?  { exe_b[7:0],  24'd0 } :
    (data_address[1:0] == 2'b00)?                       exe_b :
    (data_address[1:0] == 2'b01)?                       { exe_b[23:0], 8'd0 } :
    (data_address[1:0] == 2'b10)?                       { exe_b[15:0], 16'd0 } :
                                                        { exe_b[7:0],  24'd0 };

wire [31:0] store_idle_data = {
    ({8{data_byteenable[3]}} & store_idle_data_zero[31:24]) | (~({8{data_byteenable[3]}}) & data_cache_q[31:24]),
    ({8{data_byteenable[2]}} & store_idle_data_zero[23:16]) | (~({8{data_byteenable[2]}}) & data_cache_q[23:16]),
    ({8{data_byteenable[1]}} & store_idle_data_zero[15:8])  | (~({8{data_byteenable[1]}}) & data_cache_q[15:8]),
    ({8{data_byteenable[0]}} & store_idle_data_zero[7:0])   | (~({8{data_byteenable[0]}}) & data_cache_q[7:0])
};

wire store_idle_tlb_bad_exc_modif =
    exe_cmd_store_do && tlb_use_at_idle && micro_check_matched && micro_check_result[48:47] == 2'b10;
wire store_idle_tlb_bad_exc_inv =
    exe_cmd_store_do && tlb_use_at_idle && micro_check_matched && micro_check_result[48] == 1'b0;

wire store_idle_tlb_wait = exe_cmd_store_do && tlb_use_at_idle && ~(micro_check_matched);

//------------------------------------------------------------------------------ FIFO state

wire store_fifo_end = store_state == STORE_FIFO && ~(ram_fifo_full);

//------------------------------------------------------------------------------ TLB state

wire store_tlb_tlb_ok = store_state == STORE_TLB && tlb_ram_data_hit && tlb_ram_data_result[48:47] == 2'b11;

wire store_tlb_tlb_ok_fifo_ok = store_tlb_tlb_ok && ~(ram_fifo_full);
wire store_tlb_tlb_ok_fifo_bad= store_tlb_tlb_ok && ram_fifo_full;

wire store_tlb_tlb_bad_exc_miss  = store_state == STORE_TLB && ~(tlb_ram_data_hit) && tlb_ram_data_missed;
wire store_tlb_tlb_bad_exc_modif = store_state == STORE_TLB && tlb_ram_data_hit    && tlb_ram_data_result[48:47] == 2'b10;
wire store_tlb_tlb_bad_exc_inv   = store_state == STORE_TLB && tlb_ram_data_hit    && tlb_ram_data_result[48] == 1'b0;

//------------------------------------------------------------------------------ cache
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//input       [31:0]  data_address_next,
//input       [31:0]  data_address,

//input       [31:0]  ram_result_address,
//input               ram_result_valid,
//input               ram_result_is_read_instr,
//input       [2:0]   ram_result_burstcount,
//input       [31:0]  ram_result,

//input       [53:0]  data_cache_q,

assign data_cache_write_enable = 
    (~(n_reg) && ram_result_valid && ~(ram_result_is_read_instr)) ||
    (store_idle_tlb_ok_fifo_ok && ~(n_at_idle)               && (data_byteenable == 4'hF     || (data_cache_q[53]     && data_cache_q[52:32]     == { pfn_at_idle, data_address[11]}))) ||
    (store_fifo_end            && ~(n_reg)                   && (data_byteenable_reg == 4'hF || (data_cache_q_reg[53] && data_cache_q_reg[52:32] == { pfn_reg, data_address_reg[11]}))) ||
    (store_tlb_tlb_ok_fifo_ok  && ~(tlb_ram_data_result[46]) && (data_byteenable_reg == 4'hF || (data_cache_q_reg[53] && data_cache_q_reg[52:32] == { tlb_ram_data_result[39:20], data_address_reg[11]})));

assign data_cache_write_address = (store_idle_tlb_ok_fifo_ok)? data_address[10:2] : data_address_reg[10:2];

assign data_cache_read_address = data_address_next[10:2];

/*
[53]    valid
[52:32] tag
[31:0]  data
*/
assign data_cache_data =
    (store_idle_tlb_ok_fifo_ok)?    { ~(config_isolate_cache) || data_byteenable == 4'hF,       pfn_at_idle, data_address[11],                      store_idle_data } :
    (store_fifo_end)?               { ~(config_isolate_cache) || data_byteenable_reg == 4'hF,   pfn_reg,     data_address_reg[11],                  data_cache_q_reg[31:0] } :
    (store_tlb_tlb_ok_fifo_ok)?     { ~(config_isolate_cache) || data_byteenable_reg == 4'hF,   tlb_ram_data_result[39:20], data_address_reg[11],   data_cache_q_reg[31:0] } :
                                    { 1'b1, pfn_reg,     data_address_reg[11], ram_result }; //load

//------------------------------------------------------------------------------ data fifo
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//input               ram_fifo_full,

assign ram_fifo_wrreq =
    load_idle_tlb_ok_cache_bad_fifo_ok || load_tlb_tlb_ok_cache_bad_fifo_ok || load_fifo_end ||
    (~(config_isolate_cache) && (store_idle_tlb_ok_fifo_ok || store_tlb_tlb_ok_fifo_ok || store_fifo_end));

//{ [66] 1'b is_write, [65:36] 30'b address, [35:4] 32'b value, [3:0] 4'b byteena (4'b0000 - can burst 4 words) }
assign ram_fifo_data =
    (load_idle_tlb_ok_cache_bad_fifo_ok)?   { 1'b0, pfn_at_idle, data_address[11:2],                    32'd0,                  load_idle_byteenable } :
    (load_tlb_tlb_ok_cache_bad_fifo_ok)?    { 1'b0, tlb_ram_data_result[39:20], data_address_reg[11:2], 32'd0,                  data_byteenable_reg } :
    (load_fifo_end)?                        { 1'b0, pfn_reg, data_address_reg[11:2],                    32'd0,                  data_byteenable_reg } :
    (store_idle_tlb_ok_fifo_ok)?            { 1'b1, pfn_at_idle, data_address[11:2],                    store_idle_data,        data_byteenable } :
    (store_fifo_end)?                       { 1'b1, pfn_reg, data_address_reg[11:2],                    data_cache_q_reg[31:0], data_byteenable_reg } :
                                            { 1'b1, tlb_ram_data_result[39:20], data_address_reg[11:2], data_cache_q_reg[31:0], data_byteenable_reg }; //store_tlb_tlb_ok_fifo_ok

//------------------------------------------------------------------------------ micro tlb
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//input               micro_check_matched,
/*
[19:0]  vpn
[39:20] pfn
[45:40] asid
[46]    n noncachable
[47]    d dirty = write-enable
[48]    v valid
[49]    g global
*/
//input       [49:0]  micro_check_result,

wire        micro_check_do  = tlb_use_at_idle;
wire [19:0] micro_check_vpn = data_address[31:12];
wire [5:0]  micro_check_asid = entryhi_asid;

wire micro_write_do = tlb_ram_data_hit && (load_state == LOAD_TLB || store_state == STORE_TLB);

wire [49:0] micro_write_value = tlb_ram_data_result;

wire        micro_check_matched;
wire [49:0] micro_check_result;

memory_data_tlb_micro memory_data_tlb_micro_inst(
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

//------------------------------------------------------------------------------ muldiv
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

wire muldiv_busy;

wire [6:0] exe_cmd_for_muldiv = (exception_start || config_kernel_mode_exc_now)? `CMD_null : exe_cmd;

block_muldiv block_muldiv_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .exe_cmd_for_muldiv (exe_cmd_for_muldiv),   //input [6:0]
    .exe_a              (exe_a),                //input [31:0]
    .exe_b              (exe_b),                //input [31:0]
    .exe_instr_rd       (exe_instr_rd),         //input [4:0]
    
    .muldiv_busy        (muldiv_busy),          //output
    
    .muldiv_result_index(muldiv_result_index),  //output [4:0]
    .muldiv_result      (muldiv_result)         //output [31:0]
);

//------------------------------------------------------------------------------ coprocessor 0
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

wire [31:0] coproc0_output;

wire config_isolate_cache;
wire config_coproc0_usable;
wire config_coproc1_usable;

wire [5:0]  tlbw_index;
wire [49:0] tlbw_value;
wire [5:0]  tlbr_index;

block_cp0 block_cp0_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //
    .config_switch_caches       (config_switch_caches),         //output
    .config_isolate_cache       (config_isolate_cache),         //output
    .config_coproc0_usable      (config_coproc0_usable),        //output
    .config_coproc1_usable      (config_coproc1_usable),        //output
    .config_kernel_mode         (config_kernel_mode),           //output

    //
    .exe_cmd_mtc0               (exe_cmd_mtc0),                 //input
    .exe_instr                  (exe_instr),                    //input [31:0]
    .exe_b                      (exe_b),                        //input [31:0]
    
    .exe_cmd_rfe                (exe_cmd_rfe),                  //input
    .exe_cmd_tlbr               (exe_cmd_tlbr),                 //input
    .exe_cmd_tlbwi              (exe_cmd_tlbwi),                //input
    .exe_cmd_tlbwr              (exe_cmd_tlbwr),                //input
    
    //
    .coproc0_output             (coproc0_output),               //output [31:0]

    //
    .tlbw_index                 (tlbw_index),                   //output [5:0]
    .tlbw_value                 (tlbw_value),                   //output [49:0]
    
    //
    .tlbr_index                 (tlbr_index),                   //output [5:0]
    .tlb_ram_read_result_ready  (tlb_ram_read_result_ready),    //input
    .tlb_ram_read_result        (tlb_ram_read_result),          //input [49:0]
    
    //
    .tlbp_update                (tlbp_update),                  //input
    .tlbp_hit                   (tlbp_hit),                     //input
    .tlbp_index                 (tlbp_index),                   //input [5:0]
    
    //
    .micro_flush_do             (micro_flush_do),               //output
    .entryhi_asid               (entryhi_asid),                 //output [5:0]
    
    //
    .sr_cm_set                  (sr_cm_set),                    //input
    .sr_cm_clear                (sr_cm_clear),                  //input

    //
    .interrupt_vector           (interrupt_vector),             //input [5:0]

    //
    .exception_start            (exception_start),              //output
    .exception_start_pc         (exception_start_pc),           //output [31:0]

    //
    .mem_stalled                (mem_stalled),                  //input
    .mem_cmd                    (mem_cmd),                      //input [6:0]
    .mem_instr                  (mem_instr),                    //input [31:0]
    .mem_pc_plus4               (mem_pc_plus4),                 //input [31:0]
    .mem_branched               (mem_branched),                 //input [1:0]
    .mem_branch_address         (mem_branch_address),           //input [31:0]
    .mem_badvpn                 (mem_badvpn)                    //input [31:0]
);

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, data_address_next[31:11], data_address_next[1:0], ram_result_address[1:0], micro_check_result[49], micro_check_result[45:40], micro_check_result[19:0], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
