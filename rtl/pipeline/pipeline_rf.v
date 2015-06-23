/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module pipeline_rf(
    input               clk,
    input               rst_n,
    
    //
    input               exception_start,
    
    //
    input               if_exc_address_error,
    input               if_exc_tlb_inv,
    input               if_exc_tlb_miss,
    input               if_ready,
    input       [31:0]  if_instr,
    input       [31:0]  if_pc,
    
    //
    output      [6:0]   rf_cmd,
    output reg  [31:0]  rf_instr,
    output reg  [31:0]  rf_pc_plus4,
    output reg  [31:0]  rf_badvpn,
    output      [31:0]  rf_a,
    output      [31:0]  rf_b,
    
    //
    input               mem_stall,
    
    //
    input       [4:0]   exe_result_index,
    input       [31:0]  exe_result,
    
    input       [4:0]   mem_result_index,
    input       [31:0]  mem_result,
    
    input       [4:0]   muldiv_result_index,
    input       [31:0]  muldiv_result
);

//------------------------------------------------------------------------------

wire rf_load = (if_ready || if_exc_address_error || if_exc_tlb_inv || if_exc_tlb_miss) && ~(mem_stall);

//------------------------------------------------------------------------------

//rd <- rs OP rt
wire cmd_3arg_add  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100000;
wire cmd_3arg_addu = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100001;
wire cmd_3arg_and  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100100;
wire cmd_3arg_nor  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100111;
wire cmd_3arg_or   = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100101;
wire cmd_3arg_slt  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b101010;
wire cmd_3arg_sltu = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b101011;
wire cmd_3arg_sub  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100010;
wire cmd_3arg_subu = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100011;
wire cmd_3arg_xor  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b100110;
wire cmd_3arg_sllv = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b000100;
wire cmd_3arg_srav = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b000111;
wire cmd_3arg_srlv = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b000110;

//rd <- rt OP imm
wire cmd_sll = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b000000;
wire cmd_sra = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b000011;
wire cmd_srl = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b000010;
    
//rt <- rs OP imm
wire cmd_addi  = rf_instr[31:26] == 6'b001000;
wire cmd_addiu = rf_instr[31:26] == 6'b001001;
wire cmd_andi  = rf_instr[31:26] == 6'b001100;
wire cmd_ori   = rf_instr[31:26] == 6'b001101;
wire cmd_slti  = rf_instr[31:26] == 6'b001010;
wire cmd_sltiu = rf_instr[31:26] == 6'b001011;
wire cmd_xori  = rf_instr[31:26] == 6'b001110;

//rd <- hi,lo
wire cmd_muldiv_mfhi  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b010000;
wire cmd_muldiv_mflo  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b010010;

//hi,lo <- rs
wire cmd_muldiv_mthi  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b010001 && rf_instr[15:11] == 5'b00000;
wire cmd_muldiv_mtlo  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b010011 && rf_instr[15:11] == 5'b00000;

//hi,lo <- rs OP rt
wire cmd_muldiv_mult  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b011000  && rf_instr[15:11] == 5'b00000;
wire cmd_muldiv_multu = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b011001  && rf_instr[15:11] == 5'b00000;
wire cmd_muldiv_div   = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b011010;
wire cmd_muldiv_divu  = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b011011;

//rt <- imm
wire cmd_lui = rf_instr[31:26] == 6'b001111;

//exception
wire cmd_break   = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b001101;
wire cmd_syscall = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b001100;

wire cmd_unusable123 = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] != 2'b00 && ~(cmd_cfc1_detect);
wire cmd_lwc123      = rf_instr[31:28] == 4'b1100 && rf_instr[27:26] != 2'b00;
wire cmd_swc123      = rf_instr[31:28] == 4'b1110 && rf_instr[27:26] != 2'b00;

//cmd_swc0, cmd_lwc0, cmd_cop0_inv: `CMD_exc_reserved_instr

wire exc_coproc_unusable = cmd_unusable123 || cmd_lwc123 || cmd_swc123;

// rt <- 0
wire cmd_cfc1_detect = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b01 && rf_instr[25:21] == 5'b00010 && rf_instr[15:11] == 5'b00000;

//rd_cp0 <- rt
wire cmd_mtc0  = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25:21] == 5'b00100;
//rt <- rd_cp0 
wire cmd_mfc0  = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25:21] == 5'b00000;

wire cmd_bc0f    = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25:21] == 5'b01000 && rf_instr[20:16] == 5'd0;
wire cmd_bc0t    = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25:21] == 5'b01000 && rf_instr[20:16] == 5'd1;
wire cmd_bc0_ign = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25:21] == 5'b01000 && (rf_instr[20:16] == 5'd2 || rf_instr[20:16] == 5'd3);

wire cmd_rfe   = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25] == 1'b1 && rf_instr[5:0] == 6'b010000;
wire cmd_tlbp  = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25] == 1'b1 && rf_instr[5:0] == 6'b001000;
wire cmd_tlbr  = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25] == 1'b1 && rf_instr[5:0] == 6'b000001;
wire cmd_tlbwi = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25] == 1'b1 && rf_instr[5:0] == 6'b000010;
wire cmd_tlbwr = rf_instr[31:28] == 4'b0100 && rf_instr[27:26] == 2'b00 && rf_instr[25] == 1'b1 && rf_instr[5:0] == 6'b000110;

//rt <- mem
wire cmd_lb  = rf_instr[31:26] == 6'b100000;
wire cmd_lbu = rf_instr[31:26] == 6'b100100;
wire cmd_lh  = rf_instr[31:26] == 6'b100001;
wire cmd_lhu = rf_instr[31:26] == 6'b100101;
wire cmd_lw  = rf_instr[31:26] == 6'b100011;
wire cmd_lwl = rf_instr[31:26] == 6'b100010;
wire cmd_lwr = rf_instr[31:26] == 6'b100110;

//mem <- rt
wire cmd_sb  = rf_instr[31:26] == 6'b101000;
wire cmd_sh  = rf_instr[31:26] == 6'b101001;
wire cmd_sw  = rf_instr[31:26] == 6'b101011;
wire cmd_swl = rf_instr[31:26] == 6'b101010;
wire cmd_swr = rf_instr[31:26] == 6'b101110;

//<- rs, rt
wire cmd_beq    = rf_instr[31:26] == 6'b000100;
wire cmd_bne    = rf_instr[31:26] == 6'b000101;
//<- rs
wire cmd_bgez   = rf_instr[31:26] == 6'b000001 && rf_instr[20:16] == 5'b00001;
wire cmd_bgtz   = rf_instr[31:26] == 6'b000111 && rf_instr[20:16] == 5'b00000;
wire cmd_blez   = rf_instr[31:26] == 6'b000110 && rf_instr[20:16] == 5'b00000;
wire cmd_bltz   = rf_instr[31:26] == 6'b000001 && rf_instr[20:16] == 5'b00000;
wire pre_jr     = if_instr[31:26] == 6'b000000 && if_instr[5:0] == 6'b001000;
wire cmd_jr     = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b001000 && rf_jr_check;
//r31 <- rs
wire cmd_bgezal = rf_instr[31:26] == 6'b000001 && rf_instr[20:16] == 5'b10001;
wire cmd_bltzal = rf_instr[31:26] == 6'b000001 && rf_instr[20:16] == 5'b10000;
//rd <- rs
wire cmd_jalr   = rf_instr[31:26] == 6'b000000 && rf_instr[5:0] == 6'b001001;
//r31 <-
wire cmd_jal    = rf_instr[31:26] == 6'b000011;
//
wire cmd_j      = rf_instr[31:26] == 6'b000010;

//------------------------------------------------------------------------------

assign rf_cmd =
    (exception_start)?          `CMD_null :
    (rf_exc_address_error)?     `CMD_exc_load_addr_err :
    (rf_exc_tlb_inv)?           `CMD_exc_load_tlb :
    (rf_exc_tlb_miss)?          `CMD_exc_tlb_load_miss :
    (~(rf_ready))?              `CMD_null :
    (cmd_3arg_add)?             `CMD_3arg_add :
    (cmd_3arg_addu)?            `CMD_3arg_addu :
    (cmd_3arg_and)?             `CMD_3arg_and :
    (cmd_3arg_nor)?             `CMD_3arg_nor :
    (cmd_3arg_or)?              `CMD_3arg_or :
    (cmd_3arg_slt)?             `CMD_3arg_slt :
    (cmd_3arg_sltu)?            `CMD_3arg_sltu :
    (cmd_3arg_sub)?             `CMD_3arg_sub :
    (cmd_3arg_subu)?            `CMD_3arg_subu :
    (cmd_3arg_xor)?             `CMD_3arg_xor :
    (cmd_3arg_sllv)?            `CMD_3arg_sllv :
    (cmd_3arg_srav)?            `CMD_3arg_srav :
    (cmd_3arg_srlv)?            `CMD_3arg_srlv :
    (cmd_sll)?                  `CMD_sll :
    (cmd_sra)?                  `CMD_sra :
    (cmd_srl)?                  `CMD_srl :
    (cmd_addi)?                 `CMD_addi :
    (cmd_addiu)?                `CMD_addiu :
    (cmd_andi)?                 `CMD_andi :
    (cmd_ori)?                  `CMD_ori :
    (cmd_slti)?                 `CMD_slti :
    (cmd_sltiu)?                `CMD_sltiu :
    (cmd_xori)?                 `CMD_xori :
    (cmd_muldiv_mfhi)?          `CMD_muldiv_mfhi :
    (cmd_muldiv_mflo)?          `CMD_muldiv_mflo :
    (cmd_muldiv_mthi)?          `CMD_muldiv_mthi :
    (cmd_muldiv_mtlo)?          `CMD_muldiv_mtlo :
    (cmd_muldiv_mult)?          `CMD_muldiv_mult :
    (cmd_muldiv_multu)?         `CMD_muldiv_multu :
    (cmd_muldiv_div)?           `CMD_muldiv_div :
    (cmd_muldiv_divu)?          `CMD_muldiv_divu :
    (cmd_lui)?                  `CMD_lui :
    (cmd_break)?                `CMD_break :
    (cmd_syscall)?              `CMD_syscall :
    (exc_coproc_unusable)?      `CMD_exc_coproc_unusable :
    (cmd_mtc0)?                 `CMD_mtc0 :
    (cmd_mfc0)?                 `CMD_mfc0 :
    (cmd_cfc1_detect)?          `CMD_cfc1_detect :
    (cmd_rfe)?                  `CMD_cp0_rfe :
    (cmd_tlbp)?                 `CMD_cp0_tlbp :
    (cmd_tlbr)?                 `CMD_cp0_tlbr :
    (cmd_tlbwi)?                `CMD_cp0_tlbwi :
    (cmd_tlbwr)?                `CMD_cp0_tlbwr :
    (cmd_bc0f)?                 `CMD_cp0_bc0f :
    (cmd_bc0t)?                 `CMD_cp0_bc0t :
    (cmd_bc0_ign)?              `CMD_cp0_bc0_ign :
    (cmd_lb)?                   `CMD_lb :
    (cmd_lbu)?                  `CMD_lbu :
    (cmd_lh)?                   `CMD_lh :
    (cmd_lhu)?                  `CMD_lhu :
    (cmd_lw)?                   `CMD_lw :
    (cmd_lwl)?                  `CMD_lwl :
    (cmd_lwr)?                  `CMD_lwr :
    (cmd_sb)?                   `CMD_sb :
    (cmd_sh)?                   `CMD_sh :
    (cmd_sw)?                   `CMD_sw :
    (cmd_swl)?                  `CMD_swl :
    (cmd_swr)?                  `CMD_swr :
    (cmd_beq)?                  `CMD_beq :
    (cmd_bne)?                  `CMD_bne :
    (cmd_bgez)?                 `CMD_bgez :
    (cmd_bgtz)?                 `CMD_bgtz :
    (cmd_blez)?                 `CMD_blez :
    (cmd_bltz)?                 `CMD_bltz :
    (cmd_jr)?                   `CMD_jr :
    (cmd_bgezal)?               `CMD_bgezal :
    (cmd_bltzal)?               `CMD_bltzal :
    (cmd_jalr)?                 `CMD_jalr :
    (cmd_jal)?                  `CMD_jal :
    (cmd_j)?                    `CMD_j :
                                `CMD_exc_reserved_instr;

reg rf_exc_address_error;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_exc_address_error <= `FALSE;
    else if(exception_start)    rf_exc_address_error <= `FALSE;
    else if(rf_load)            rf_exc_address_error <= if_exc_address_error;
end

reg rf_exc_tlb_inv;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_exc_tlb_inv <= `FALSE;
    else if(exception_start)    rf_exc_tlb_inv <= `FALSE;
    else if(rf_load)            rf_exc_tlb_inv <= if_exc_tlb_inv;
end

reg rf_exc_tlb_miss;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_exc_tlb_miss <= `FALSE;
    else if(exception_start)    rf_exc_tlb_miss <= `FALSE;
    else if(rf_load)            rf_exc_tlb_miss <= if_exc_tlb_miss;
end

reg rf_ready;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_ready <= `FALSE;
    else if(exception_start)    rf_ready <= `FALSE;
    else if(rf_load && if_ready)rf_ready <= `TRUE;
    else if(~(mem_stall))       rf_ready <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_instr <= 32'd0;
    else if(rf_load)            rf_instr <= if_instr;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_pc_plus4 <= 32'd0;
    else if(rf_load)            rf_pc_plus4 <= if_pc + 32'd4;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rf_badvpn <= 32'd0;
    else if(rf_load)            rf_badvpn <= if_pc;
end

//------------------------------------------------------------------------------

wire [4:0] rf_instr_rs = rf_instr[25:21];
wire [4:0] rf_instr_rt = rf_instr[20:16];
wire [4:0] rf_instr_rd = rf_instr[15:11];

assign rf_a = 
    (exe_result_index != 5'd0    && rf_instr_rs == exe_result_index)?       exe_result :
    (muldiv_result_index != 5'd0 && rf_instr_rs == muldiv_result_index)?    muldiv_result :
    (mem_result_index != 5'd0    && rf_instr_rs == mem_result_index)?       mem_result :
                                                                            q_a_final;

assign rf_b =
    (exe_result_index != 5'd0    && rf_instr_rt == exe_result_index)?       exe_result :
    (muldiv_result_index != 5'd0 && rf_instr_rt == muldiv_result_index)?    muldiv_result :
    (mem_result_index != 5'd0    && rf_instr_rt == mem_result_index)?       mem_result :
                                                                            q_b_final;

wire rf_jr_check =
    (exe_result_index != 5'd0    && rf_instr_rd == exe_result_index)?       exe_result == 32'd0 :
    (muldiv_result_index != 5'd0 && rf_instr_rd == muldiv_result_index)?    muldiv_result == 32'd0 :
    (mem_result_index != 5'd0    && rf_instr_rd == mem_result_index)?       mem_result == 32'd0 :
                                                                            q_b_final == 32'd0;

//------------------------------------------------------------------------------

reg [4:0]  address_a_reg;
reg [4:0]  address_b_reg;
reg [4:0]  written_index_reg;
reg [31:0] written_data_reg;

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address_a_reg     <= 5'd0;  else if(~(mem_stall)) address_a_reg <= address_a; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) address_b_reg     <= 5'd0;  else if(~(mem_stall)) address_b_reg <= address_b; end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) written_data_reg  <= 32'd0; else written_data_reg  <= mem_result;       end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) written_index_reg <= 5'd0;  else written_index_reg <= mem_result_index; end

wire [31:0] q_a_final = (written_index_reg != 5'd0 && address_a_reg == written_index_reg)? written_data_reg : q_a;
wire [31:0] q_b_final = (written_index_reg != 5'd0 && address_b_reg == written_index_reg)? written_data_reg : q_b;

//------------------------------------------------------------------------------
wire [4:0] if_instr_rs = if_instr[25:21];
wire [4:0] if_instr_rt = if_instr[20:16];
wire [4:0] if_instr_rd = if_instr[15:11];

wire [4:0] address_a = if_instr_rs;
wire [4:0] address_b = (pre_jr)? if_instr_rd : if_instr_rt;

wire [31:0] q_a;
wire [31:0] q_b;

model_simple_dual_ram #(
    .width          (32),
    .widthad        (5)
)
regs_a_inst(
    .clk            (clk),
    
    .address_a      ((mem_stall)? address_a_reg : address_a),
    .q_a            (q_a),
    
    .address_b      (mem_result_index),
    .wren_b         (mem_result_index != 5'd0),
    .data_b         (mem_result)
);

model_simple_dual_ram #(
    .width          (32),
    .widthad        (5)
)
regs_b_inst(
    .clk            (clk),
    
    .address_a      ((mem_stall)? address_b_reg : address_b),
    .q_a            (q_b),
    
    .address_b      (mem_result_index),
    .wren_b         (mem_result_index != 5'd0),
    .data_b         (mem_result)
);


//------------------------------------------------------------------------------

endmodule
