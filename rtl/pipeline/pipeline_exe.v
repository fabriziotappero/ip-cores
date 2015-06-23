/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module pipeline_exe(
    input               clk,
    input               rst_n,
    
    //
    input               config_kernel_mode,
    
    //
    input               exception_start,
    
    //
    input               mem_stall,
    
    //
    input       [6:0]   rf_cmd,
    input       [31:0]  rf_instr,
    input       [31:0]  rf_pc_plus4,
    input       [31:0]  rf_badvpn,
    input       [31:0]  rf_a,
    input       [31:0]  rf_b,
    
    //
    output reg  [6:0]   exe_cmd,
    output reg  [31:0]  exe_instr,
    output reg  [31:0]  exe_pc_plus4,
    output reg          exe_pc_user_seg,
    output reg  [31:0]  exe_badvpn,
    output reg  [31:0]  exe_a,
    output reg  [31:0]  exe_b,
    output reg  [1:0]   exe_branched,
    output reg  [31:0]  exe_branch_address,
    output reg          exe_cmd_cp0,
    output reg          exe_cmd_load,
    output reg          exe_cmd_store,
    
    //
    output      [4:0]   exe_result_index,
    output reg  [31:0]  exe_result,
    
    //
    output      [31:0]  data_address_next,
    output reg  [31:0]  data_address,
    
    //
    output              branch_start,
    output      [31:0]  branch_address,
    
    //
    input       [4:0]   write_buffer_counter
); /* verilator public_module */

//------------------------------------------------------------------------------

wire exc_int_overflow =
    ((rf_cmd == `CMD_3arg_add || rf_cmd == `CMD_addi) && (
        (rf_a[31] == 1'b1 && rf_b_imm[31] == 1'b1 && result_sum[31] == 1'b0) ||
        (rf_a[31] == 1'b0 && rf_b_imm[31] == 1'b0 && result_sum[31] == 1'b1))) ||
    (rf_cmd == `CMD_3arg_sub && (
        (rf_a[31] == 1'b1 && rf_b[31] == 1'b0 && result_sub[31] == 1'b0) ||
        (rf_a[31] == 1'b0 && rf_b[31] == 1'b1 && result_sub[31] == 1'b1)));

wire [6:0] exe_cmd_next =
    (mem_stall || exception_start)? `CMD_null :
    (exc_load_address_error)?       `CMD_exc_load_addr_err :
    (exc_store_address_error)?      `CMD_exc_store_addr_err :
    (exc_int_overflow)?             `CMD_exc_int_overflow :
                                    rf_cmd;

wire exe_cmd_cp0_next = ~(mem_stall) && ~(exception_start) && (
    rf_cmd == `CMD_mtc0 || rf_cmd == `CMD_cp0_rfe || rf_cmd == `CMD_cp0_tlbr || rf_cmd == `CMD_cp0_tlbp ||
    rf_cmd == `CMD_cp0_tlbwi || rf_cmd == `CMD_cp0_tlbwr || rf_cmd == `CMD_mfc0
);

wire cmd_load =
    rf_cmd == `CMD_lb || rf_cmd == `CMD_lbu || rf_cmd == `CMD_lh  || rf_cmd == `CMD_lhu ||
    rf_cmd == `CMD_lw || rf_cmd == `CMD_lwl || rf_cmd == `CMD_lwr;
    
wire cmd_store =
    rf_cmd == `CMD_sb || rf_cmd == `CMD_sh || rf_cmd == `CMD_sw || rf_cmd == `CMD_swl || rf_cmd == `CMD_swr;

wire exe_cmd_load_next = ~(mem_stall) && ~(exception_start) && cmd_load && ~(exc_load_address_error);

wire exe_cmd_store_next = ~(mem_stall) && ~(exception_start) && cmd_store && ~(exc_store_address_error);
    
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_cmd         <= `CMD_null; else exe_cmd         <= exe_cmd_next;               end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_cmd_cp0     <= `FALSE;    else exe_cmd_cp0     <= exe_cmd_cp0_next;           end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_cmd_load    <= `FALSE;    else exe_cmd_load    <= exe_cmd_load_next;          end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_cmd_store   <= `FALSE;    else exe_cmd_store   <= exe_cmd_store_next;         end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_result      <= 32'd0;     else exe_result      <= result;                     end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_instr       <= 32'd0;     else exe_instr       <= rf_instr;                   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_pc_plus4    <= 32'd0;     else exe_pc_plus4    <= rf_pc_plus4;                end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_pc_user_seg <= `FALSE;    else exe_pc_user_seg <= rf_pc_plus4 > 32'h80000000; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_a           <= 32'd0;     else exe_a           <= rf_a;                       end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) exe_b           <= 32'd0;     else exe_b           <= rf_b;                       end

wire [4:0] rf_instr_rt = rf_instr[20:16];
wire [4:0] rf_instr_rd = rf_instr[15:11];

wire exe_cmd_next_is_rd =
    rf_cmd == `CMD_3arg_add  || rf_cmd == `CMD_3arg_addu || rf_cmd == `CMD_3arg_and  || rf_cmd == `CMD_3arg_nor  ||
    rf_cmd == `CMD_3arg_or   || rf_cmd == `CMD_3arg_slt  || rf_cmd == `CMD_3arg_sltu || rf_cmd == `CMD_3arg_sub  ||
    rf_cmd == `CMD_3arg_subu || rf_cmd == `CMD_3arg_xor  || rf_cmd == `CMD_3arg_sllv || rf_cmd == `CMD_3arg_srav ||
    rf_cmd == `CMD_3arg_srlv || rf_cmd == `CMD_sll       || rf_cmd == `CMD_sra       || rf_cmd == `CMD_srl       ||
    rf_cmd == `CMD_jalr;

wire exe_cmd_next_is_rt =
    rf_cmd == `CMD_addi || rf_cmd == `CMD_addiu || rf_cmd == `CMD_andi || rf_cmd == `CMD_ori ||
    rf_cmd == `CMD_slti || rf_cmd == `CMD_sltiu || rf_cmd == `CMD_xori || rf_cmd == `CMD_lui;

wire exe_cmd_next_is_r31 = rf_cmd == `CMD_bgezal || rf_cmd == `CMD_bltzal || rf_cmd == `CMD_jal;

wire [4:0] exe_result_index_next =
    (exe_cmd_next_is_rd)?   rf_instr_rd :
    (exe_cmd_next_is_rt)?   rf_instr_rt :
    (exe_cmd_next_is_r31)?  5'd31 :
                            5'd0;

reg [4:0] exe_result_index_pre;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   exe_result_index_pre <= 5'd0;
    else                exe_result_index_pre <= exe_result_index_next;
end

reg exe_result_valid;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   exe_result_valid <= `FALSE;
    else                exe_result_valid <= ~(mem_stall) && ~(exception_start) && ~(exc_int_overflow);
end

assign exe_result_index = (exe_result_valid)? exe_result_index_pre : 5'd0;

//------------------------------------------------------------------------------

assign data_address_next = rf_a + { {16{rf_instr[15]}}, rf_instr[15:0] };

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   data_address <= 32'd0;
    else                data_address <= data_address_next;
end

wire exc_load_address_error = 
    ((rf_cmd == `CMD_lh || rf_cmd == `CMD_lhu) && data_address_next[0]) ||
    (rf_cmd == `CMD_lw && data_address_next[1:0] != 2'b00) ||
    (cmd_load && ~(config_kernel_mode) && data_address_next[31]);

wire exc_store_address_error =
    (rf_cmd == `CMD_sh && data_address_next[0]) ||
    (rf_cmd == `CMD_sw && data_address_next[1:0] != 2'b00) ||
    (cmd_store && ~(config_kernel_mode) && data_address_next[31]);

//------------------------------------------------------------------------------

wire write_buffer_empty = ~(exe_cmd_store) && write_buffer_counter == 5'd0;

assign branch_start = ~(mem_stall) && (
    rf_cmd == `CMD_jr || rf_cmd == `CMD_j || rf_cmd == `CMD_jal || rf_cmd == `CMD_jalr ||
    (rf_cmd == `CMD_beq      && rf_a == rf_b) ||
    (rf_cmd == `CMD_bne      && rf_a != rf_b) ||
    (rf_cmd == `CMD_bgez     && rf_a[31] == 1'b0) ||
    (rf_cmd == `CMD_bgtz     && rf_a[31] == 1'b0 && rf_a != 32'd0) ||
    (rf_cmd == `CMD_blez     && (rf_a[31] == 1'b1 || rf_a == 32'd0)) ||
    (rf_cmd == `CMD_bltz     && rf_a[31] == 1'b1) ||
    (rf_cmd == `CMD_bgezal   && rf_a[31] == 1'b0) ||
    (rf_cmd == `CMD_bltzal   && rf_a[31] == 1'b1) ||
    (rf_cmd == `CMD_cp0_bc0t && write_buffer_empty) ||
    (rf_cmd == `CMD_cp0_bc0f && ~(write_buffer_empty))
);

assign branch_address =
    (rf_cmd == `CMD_jal || rf_cmd == `CMD_j)?       { rf_pc_plus4[31:28], rf_instr[25:0], 2'b00 } :
    (rf_cmd == `CMD_jr  || rf_cmd == `CMD_jalr)?    rf_a :
                                                    rf_pc_plus4 + { {14{rf_instr[15]}}, rf_instr[15:0], 2'b00 };

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       exe_branched <= 2'd0;
    else if(branch_start)                                   exe_branched <= 2'd1;
    else if(exe_cmd != `CMD_null && exe_branched == 2'd1)   exe_branched <= 2'd2;
    else if(exe_cmd != `CMD_null)                           exe_branched <= 2'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       exe_branch_address <= 32'd0;
    else if(branch_start)   exe_branch_address <= branch_address;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   exe_badvpn <= 32'd0;
    else                exe_badvpn <= rf_badvpn;
end

//------------------------------------------------------------------------------

wire [31:0] rf_b_imm = (rf_cmd == `CMD_addi || rf_cmd == `CMD_addiu || rf_cmd == `CMD_slti || rf_cmd == `CMD_sltiu)? { {16{rf_instr[15]}}, rf_instr[15:0] } : rf_b; 
    
wire [31:0] result_sum = rf_a + rf_b_imm;
wire [32:0] result_sub = rf_a - rf_b_imm;

wire [31:0] result =
    (rf_cmd == `CMD_3arg_add || rf_cmd == `CMD_addi || rf_cmd == `CMD_addiu || rf_cmd == `CMD_3arg_addu)?       result_sum :
    (rf_cmd == `CMD_3arg_and)?                                                                                  rf_a & rf_b :
    (rf_cmd == `CMD_andi)?                                                                                      { 16'd0, rf_a[15:0] & rf_instr[15:0] } :
    (rf_cmd == `CMD_3arg_nor)?                                                                                  ~(rf_a | rf_b) :
    (rf_cmd == `CMD_3arg_or)?                                                                                   rf_a | rf_b :
    (rf_cmd == `CMD_ori)?                                                                                       { rf_a[31:16], rf_a[15:0] | rf_instr[15:0] } :
    (rf_cmd == `CMD_sll || rf_cmd == `CMD_3arg_sllv)?                                                           shift_left :
    (rf_cmd == `CMD_sra || rf_cmd == `CMD_3arg_srav || rf_cmd == `CMD_srl || rf_cmd == `CMD_3arg_srlv)?         shift_right :
    (rf_cmd == `CMD_3arg_slt || rf_cmd == `CMD_slti)?                                                           { 31'b0, (rf_a[31] ^ rf_b_imm[31])? rf_a[31] : result_sub[31] } :
    (rf_cmd == `CMD_3arg_sltu || rf_cmd == `CMD_sltiu)?                                                         { 31'b0, result_sub[32] } :
    (rf_cmd == `CMD_3arg_sub || rf_cmd == `CMD_3arg_subu)?                                                      result_sub[31:0] :
    (rf_cmd == `CMD_3arg_xor)?                                                                                  rf_a ^ rf_b :
    (rf_cmd == `CMD_xori)?                                                                                      rf_a ^ { 16'd0, rf_instr[15:0] } :
    (rf_cmd == `CMD_lui)?                                                                                       { rf_instr[15:0], 16'd0 } :
                                                                                                                rf_pc_plus4 + 32'd4; //cmd_bgezal, cmd_bltzal, cmd_jal, cmd_jalr
    
//------------------------------------------------------------------------------ shift
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

wire [31:0] shift_left;
wire [31:0] shift_right;

block_shift block_shift_inst(
    .rf_cmd         (rf_cmd),       //input [6:0]
    .rf_instr       (rf_instr),     //input [31:0]
    .rf_a           (rf_a),         //input [31:0]
    .rf_b           (rf_b),         //input [31:0]
    
    .shift_left     (shift_left),   //output [31:0]
    .shift_right    (shift_right)   //output [31:0]
);

//------------------------------------------------------------------------------

endmodule
