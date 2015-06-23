//////////////////////////////////////////////////////////////////
//                                                              //
//  Decode stage of Amber 25 Core                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  This module is the most complex part of the Amber core      //
//  It decodes and sequences all instructions and handles all   //
//  interrupts                                                  //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////
`include "global_defines.vh"

module a25_decode
(
input                       i_clk,
input       [31:0]          i_fetch_instruction,
input                       i_core_stall,                   // stall all stages of the Amber core at the same time
input                       i_irq,                          // interrupt request
input                       i_firq,                         // Fast interrupt request
input                       i_dabt,                         // data abort interrupt request
input                       i_iabt,                         // instruction pre-fetch abort flag
input                       i_adex,                         // Address Exception
input       [31:0]          i_execute_iaddress,             // Registered instruction address output by execute stage
input       [31:0]          i_execute_daddress,             // Registered instruction address output by execute stage
input       [7:0]           i_abt_status,                   // Abort status
input       [31:0]          i_execute_status_bits,          // current status bits values in execute stage
input                       i_multiply_done,                // multiply unit is nearly done


// --------------------------------------------------
// Control signals to execute stage
// --------------------------------------------------
output reg  [31:0]          o_imm32 = 'd0,
output reg  [4:0]           o_imm_shift_amount = 'd0,
output reg                  o_shift_imm_zero = 'd0,
output wire [3:0]           o_condition,
output reg                  o_decode_exclusive = 'd0,       // exclusive access request ( swap instruction )
output wire                 o_decode_iaccess,               // Indicates an instruction access
output reg                  o_decode_daccess = 'd0,         // Indicates a data access
output wire [1:0]           o_status_bits_mode,
output wire                 o_status_bits_irq_mask,
output wire                 o_status_bits_firq_mask,

output reg  [3:0]           o_rm_sel  = 'd0,
output reg  [3:0]           o_rs_sel  = 'd0,
output reg  [7:0]           o_load_rd = 'd0,                // [7] load flags with PC
                                                            // [6] load status bits with PC
                                                            // [5] Write into User Mode register
                                                            // [4] zero-extend load
                                                            // [3:0] destination register, Rd
output reg  [3:0]           o_rn_sel  = 'd0,
output reg  [1:0]           o_barrel_shift_amount_sel = 'd0,
output reg  [1:0]           o_barrel_shift_data_sel = 'd0,
output reg  [1:0]           o_barrel_shift_function = 'd0,
output reg  [8:0]           o_alu_function = 'd0,
output reg  [1:0]           o_multiply_function = 'd0,
output reg  [2:0]           o_interrupt_vector_sel = 'd0,
output wire [3:0]           o_iaddress_sel,
output wire [3:0]           o_daddress_sel,
output wire [2:0]           o_pc_sel,
output reg  [1:0]           o_byte_enable_sel = 'd0,        // byte, halfword or word write
output reg  [2:0]           o_status_bits_sel = 'd0,
output reg  [2:0]           o_reg_write_sel,
output reg                  o_user_mode_regs_store_nxt,
output reg                  o_firq_not_user_mode,
output reg                  o_use_carry_in,

output reg                  o_write_data_wen = 'd0,
output reg                  o_base_address_wen = 'd0,       // save ldm base address register
                                                            // in case of data abort
output wire                 o_pc_wen,
output reg  [14:0]          o_reg_bank_wen = 'd0,
output reg                  o_status_bits_flags_wen = 'd0,
output reg                  o_status_bits_mode_wen = 'd0,
output reg                  o_status_bits_irq_mask_wen = 'd0,
output reg                  o_status_bits_firq_mask_wen = 'd0,

// --------------------------------------------------
// Co-Processor interface
// --------------------------------------------------
output reg  [2:0]           o_copro_opcode1 = 'd0,
output reg  [2:0]           o_copro_opcode2 = 'd0,
output reg  [3:0]           o_copro_crn = 'd0,
output reg  [3:0]           o_copro_crm = 'd0,
output reg  [3:0]           o_copro_num = 'd0,
output reg  [1:0]           o_copro_operation = 'd0, // 0 = no operation,
                                                     // 1 = Move to Amber Core Register from Coprocessor
                                                     // 2 = Move to Coprocessor from Amber Core Register
output reg                  o_copro_write_data_wen = 'd0,
output                      o_iabt_trigger,
output      [31:0]          o_iabt_address,
output      [7:0]           o_iabt_status,
output                      o_dabt_trigger,
output      [31:0]          o_dabt_address,
output      [7:0]           o_dabt_status,
output                      o_conflict,
output reg                  o_rn_use_read,
output reg                  o_rm_use_read,
output reg                  o_rs_use_read,
output reg                  o_rd_use_read

);

`include "a25_localparams.vh"
`include "a25_functions.vh"

localparam [4:0] RST_WAIT1      = 5'd0,
                 RST_WAIT2      = 5'd1,
                 INT_WAIT1      = 5'd2,
                 INT_WAIT2      = 5'd3,
                 EXECUTE        = 5'd4,
                 PRE_FETCH_EXEC = 5'd5,  // Execute the Pre-Fetched Instruction
                 MEM_WAIT1      = 5'd6,  // conditionally decode current instruction, in case
                                         // previous instruction does not execute in S2
                 MEM_WAIT2      = 5'd7,
                 PC_STALL1      = 5'd8,  // Program Counter altered
                                         // conditionally decude current instruction, in case
                                         // previous instruction does not execute in S2
                 PC_STALL2      = 5'd9,
                 MTRANS_EXEC1   = 5'd10,
                 MTRANS_EXEC2   = 5'd11,
                 MTRANS_ABORT   = 5'd12,
                 MULT_PROC1     = 5'd13,  // first cycle, save pre fetch instruction
                 MULT_PROC2     = 5'd14,  // do multiplication
                 MULT_STORE     = 5'd15,  // save RdLo
                 MULT_ACCUMU    = 5'd16,  // Accumulate add lower 32 bits
                 SWAP_WRITE     = 5'd17,
                 SWAP_WAIT1     = 5'd18,
                 SWAP_WAIT2     = 5'd19,
                 COPRO_WAIT     = 5'd20;


// ========================================================
// Internal signals
// ========================================================
wire    [31:0]         instruction;
wire    [3:0]          type;                    // regop, mem access etc.
wire                   instruction_iabt;        // abort flag, follows the instruction
wire                   instruction_adex;        // address exception flag, follows the instruction
wire    [31:0]         instruction_address;     // instruction virtual address, follows
                                                // the instruction
wire    [7:0]          instruction_iabt_status; // abort status, follows the instruction
wire    [1:0]          instruction_sel;
wire    [3:0]          opcode;
wire    [7:0]          imm8;
wire    [31:0]         offset12;
wire    [31:0]         offset24;
wire    [4:0]          shift_imm;

wire                   opcode_compare;
wire                   mem_op;
wire                   load_op;
wire                   store_op;
wire                   write_pc;
wire                   current_write_pc;
reg                    load_pc_nxt;
reg                    load_pc_r = 'd0;
wire                   immediate_shift_op;
wire                   rds_use_rs;
wire                   branch;
wire                   mem_op_pre_indexed;
wire                   mem_op_post_indexed;

// Flop inputs
wire    [31:0]         imm32_nxt;
wire    [4:0]          imm_shift_amount_nxt;
wire                   shift_imm_zero_nxt;
wire    [3:0]          condition_nxt;
reg                    decode_exclusive_nxt;
reg                    decode_iaccess_nxt;
reg                    decode_daccess_nxt;
wire                   shift_extend;

reg     [1:0]          barrel_shift_function_nxt;
wire    [8:0]          alu_function_nxt;
reg     [1:0]          multiply_function_nxt;
reg     [1:0]          status_bits_mode_nxt;
reg                    status_bits_irq_mask_nxt;
reg                    status_bits_firq_mask_nxt;

wire    [3:0]          rm_sel_nxt;
wire    [3:0]          rs_sel_nxt;

wire    [3:0]          rn_sel_nxt;
reg     [1:0]          barrel_shift_amount_sel_nxt;
reg     [1:0]          barrel_shift_data_sel_nxt;
reg     [3:0]          iaddress_sel_nxt;
reg     [3:0]          daddress_sel_nxt;
reg     [2:0]          pc_sel_nxt;
reg     [1:0]          byte_enable_sel_nxt;
reg     [2:0]          status_bits_sel_nxt;
reg     [2:0]          reg_write_sel_nxt;
wire                   firq_not_user_mode_nxt;
reg                    use_carry_in_nxt;

// ALU Function signals
reg                    alu_swap_sel_nxt;
reg                    alu_not_sel_nxt;
reg     [1:0]          alu_cin_sel_nxt;
reg                    alu_cout_sel_nxt;
reg     [3:0]          alu_out_sel_nxt;

reg                    write_data_wen_nxt;
reg                    copro_write_data_wen_nxt;
reg                    base_address_wen_nxt;
reg                    pc_wen_nxt;
reg     [14:0]         reg_bank_wen_nxt;
reg                    status_bits_flags_wen_nxt;
reg                    status_bits_mode_wen_nxt;
reg                    status_bits_irq_mask_wen_nxt;
reg                    status_bits_firq_mask_wen_nxt;

reg                    saved_current_instruction_wen;   // saved load instruction
reg                    pre_fetch_instruction_wen;       // pre-fetch instruction

reg     [4:0]          control_state = RST_WAIT1;
reg     [4:0]          control_state_nxt;


wire                   dabt;
reg                    dabt_reg = 'd0;
reg                    dabt_reg_d1;
reg                    iabt_reg = 'd0;
reg                    adex_reg = 'd0;
reg     [31:0]         fetch_address_r = 'd0;
reg     [7:0]          abt_status_reg = 'd0;
reg     [31:0]         fetch_instruction_r = 'd0;
reg     [3:0]          fetch_instruction_type_r = 'd0;
reg     [31:0]         saved_current_instruction = 'd0;
reg     [3:0]          saved_current_instruction_type = 'd0;
reg                    saved_current_instruction_iabt = 'd0;          // access abort flag
reg                    saved_current_instruction_adex = 'd0;          // address exception
reg     [31:0]         saved_current_instruction_address = 'd0;       // virtual address of abort instruction
reg     [7:0]          saved_current_instruction_iabt_status = 'd0;   // status of abort instruction
reg     [31:0]         pre_fetch_instruction = 'd0;
reg     [3:0]          pre_fetch_instruction_type = 'd0;
reg                    pre_fetch_instruction_iabt = 'd0;              // access abort flag
reg                    pre_fetch_instruction_adex = 'd0;              // address exception
reg     [31:0]         pre_fetch_instruction_address = 'd0;           // virtual address of abort instruction
reg     [7:0]          pre_fetch_instruction_iabt_status = 'd0;       // status of abort instruction
reg     [31:0]         hold_instruction = 'd0;
reg     [3:0]          hold_instruction_type = 'd0;
reg                    hold_instruction_iabt = 'd0;                   // access abort flag
reg                    hold_instruction_adex = 'd0;                   // address exception
reg     [31:0]         hold_instruction_address = 'd0;                // virtual address of abort instruction
reg     [7:0]          hold_instruction_iabt_status = 'd0;            // status of abort instruction

wire                   instruction_valid;
wire                   instruction_execute;
reg                    instruction_execute_r = 'd0;

reg     [3:0]          mtrans_reg1;             // the current register being accessed as part of stm/ldm
reg     [3:0]          mtrans_reg2;             // the next register being accessed as part of stm/ldm
reg     [31:0]         mtrans_instruction_nxt;
wire    [15:0]         mtrans_reg2_mask;

wire   [31:0]          mtrans_base_reg_change;
wire   [4:0]           mtrans_num_registers;
wire                   use_saved_current_instruction;
wire                   use_hold_instruction;
wire                   use_pre_fetch_instruction;
wire                   interrupt;
wire                   interrupt_or_conflict;
wire   [1:0]           interrupt_mode;
wire   [2:0]           next_interrupt;
reg                    irq = 'd0;
reg                    firq = 'd0;
wire                   firq_request;
wire                   irq_request;
wire                   swi_request;
wire                   und_request;
wire                   dabt_request;
reg    [1:0]           copro_operation_nxt;
reg                    restore_base_address = 'd0;
reg                    restore_base_address_nxt;

wire                   regop_set_flags;

wire    [7:0]          load_rd_nxt;
wire                   load_rd_byte;
wire                   ldm_user_mode;
wire                   ldm_status_bits;
wire                   ldm_flags;
wire    [6:0]          load_rd_d1_nxt;
reg     [6:0]          load_rd_d1 = 'd0;  // MSB is the valid bit

wire                   rn_valid;
wire                   rm_valid;
wire                   rs_valid;
wire                   rd_valid;
wire                   stm_valid;
wire                   rn_conflict1;
wire                   rn_conflict2;
wire                   rm_conflict1;
wire                   rm_conflict2;
wire                   rs_conflict1;
wire                   rs_conflict2;
wire                   rd_conflict1;
wire                   rd_conflict2;
wire                   stm_conflict1a;
wire                   stm_conflict1b;
wire                   stm_conflict2a;
wire                   stm_conflict2b;
wire                   conflict1;          // Register conflict1 with ldr operation
wire                   conflict2;          // Register conflict1 with ldr operation
wire                   conflict;           // Register conflict1 with ldr operation
reg                    conflict_r = 'd0;
reg                    rn_conflict1_r = 'd0;
reg                    rm_conflict1_r = 'd0;
reg                    rs_conflict1_r = 'd0;
reg                    rd_conflict1_r = 'd0;

// ========================================================
// registers for output ports with non-zero initial values
// ========================================================
reg  [3:0]           condition_r = 4'he;             // 4'he = al
reg                  decode_iaccess_r = 1'd1;        // Indicates an instruction access
reg  [1:0]           status_bits_mode_r = 2'b11;     // SVC
reg                  status_bits_irq_mask_r = 1'd1;
reg                  status_bits_firq_mask_r = 1'd1;
reg  [3:0]           iaddress_sel_r = 4'd2;
reg  [3:0]           daddress_sel_r = 4'd2;
reg  [2:0]           pc_sel_r = 3'd2;
reg                  pc_wen_r = 1'd1;


assign o_condition                 = condition_r;
assign o_decode_iaccess            = decode_iaccess_r;
assign o_status_bits_mode          = status_bits_mode_r;
assign o_status_bits_irq_mask      = status_bits_irq_mask_r;
assign o_status_bits_firq_mask     = status_bits_firq_mask_r;
assign o_iaddress_sel              = iaddress_sel_r;
assign o_daddress_sel              = daddress_sel_r;
assign o_pc_sel                    = pc_sel_r;
assign o_pc_wen                    = pc_wen_r;



// ========================================================
// Instruction Abort and Data Abort outputs
// ========================================================

assign o_iabt_trigger     = instruction_iabt && status_bits_mode_r == SVC && control_state == INT_WAIT1;
assign o_iabt_address     = instruction_address;
assign o_iabt_status      = instruction_iabt_status;

assign o_dabt_trigger     = dabt_reg && !dabt_reg_d1;
assign o_dabt_address     = fetch_address_r;
assign o_dabt_status      = abt_status_reg;


// ========================================================
// Instruction Decode
// ========================================================

// for instructions that take more than one cycle
// the instruction is saved in the 'saved_mem_instruction'
// register and then that register is used for the rest of
// the execution of the instruction.
// But if the instruction does not execute because of the
// condition, then need to select the next instruction to
// decode
assign use_saved_current_instruction = instruction_execute &&
                          ( control_state == MEM_WAIT1     ||
                            control_state == MEM_WAIT2     ||
                            control_state == MTRANS_EXEC1  ||
                            control_state == MTRANS_EXEC2  ||
                            control_state == MTRANS_ABORT  ||
                            control_state == MULT_PROC1    ||
                            control_state == MULT_PROC2    ||
                            control_state == MULT_ACCUMU   ||
                            control_state == MULT_STORE    ||
                            control_state == INT_WAIT1     ||
                            control_state == INT_WAIT2     ||
                            control_state == SWAP_WRITE    ||
                            control_state == SWAP_WAIT1    ||
                            control_state == SWAP_WAIT2    ||
                            control_state == COPRO_WAIT     );

assign use_hold_instruction = conflict_r;

assign use_pre_fetch_instruction = control_state == PRE_FETCH_EXEC;


assign instruction_sel  =         use_hold_instruction           ? 2'd3 :  // hold_instruction
                                  use_saved_current_instruction  ? 2'd1 :  // saved_current_instruction
                                  use_pre_fetch_instruction      ? 2'd2 :  // pre_fetch_instruction
                                                                   2'd0 ;  // fetch_instruction_r

assign instruction      =         instruction_sel == 2'd0 ? fetch_instruction_r       :
                                  instruction_sel == 2'd1 ? saved_current_instruction :
                                  instruction_sel == 2'd3 ? hold_instruction          :
                                                            pre_fetch_instruction     ;

assign type             =         instruction_sel == 2'd0 ? fetch_instruction_type_r       :
                                  instruction_sel == 2'd1 ? saved_current_instruction_type :
                                  instruction_sel == 2'd3 ? hold_instruction_type          :
                                                            pre_fetch_instruction_type     ;

// abort flag
assign instruction_iabt =         instruction_sel == 2'd0 ? iabt_reg                       :
                                  instruction_sel == 2'd1 ? saved_current_instruction_iabt :
                                  instruction_sel == 2'd3 ? hold_instruction_iabt          :
                                                            pre_fetch_instruction_iabt     ;

assign instruction_address =      instruction_sel == 2'd0 ? fetch_address_r                   :
                                  instruction_sel == 2'd1 ? saved_current_instruction_address :
                                  instruction_sel == 2'd3 ? hold_instruction_address          :
                                                            pre_fetch_instruction_address     ;

assign instruction_iabt_status =  instruction_sel == 2'd0 ? abt_status_reg                        :
                                  instruction_sel == 2'd1 ? saved_current_instruction_iabt_status :
                                  instruction_sel == 2'd3 ? hold_instruction_iabt_status          :
                                                            pre_fetch_instruction_iabt_status     ;

// instruction address exception
assign instruction_adex =         instruction_sel == 2'd0 ? adex_reg                       :
                                  instruction_sel == 2'd1 ? saved_current_instruction_adex :
                                  instruction_sel == 2'd3 ? hold_instruction_adex          :
                                                            pre_fetch_instruction_adex     ;


// ========================================================
// Fixed fields within the instruction
// ========================================================

assign opcode               = instruction[24:21];
assign condition_nxt        = instruction[31:28];

assign rm_sel_nxt           = instruction[3:0];
assign rn_sel_nxt           = branch ? 4'd15 : instruction[19:16]; // Use PC to calculate branch destination
assign rs_sel_nxt           = control_state == SWAP_WRITE  ? instruction[3:0]   : // Rm gets written out to memory
                              type == MTRANS               ? mtrans_reg1         :
                              branch                       ? 4'd15              : // Update the PC
                              rds_use_rs                   ? instruction[11:8]  :
                                                             instruction[15:12] ;

// Load from memory into registers
assign ldm_user_mode        = type == MTRANS && {instruction[22],instruction[20],instruction[15]} == 3'b110;
assign ldm_flags            = type == MTRANS && rs_sel_nxt == 4'd15 && instruction[20] && instruction[22];
assign ldm_status_bits      = type == MTRANS && rs_sel_nxt == 4'd15 && instruction[20] && instruction[22] && i_execute_status_bits[1:0] != USR;
assign load_rd_byte         = (type == TRANS || type == SWAP) && instruction[22];
assign load_rd_nxt          = {ldm_flags, ldm_status_bits, ldm_user_mode, load_rd_byte, rs_sel_nxt};

// this is used for RRX
assign shift_extend         = !instruction[25] && !instruction[4] && !(|instruction[11:7]) && instruction[6:5] == 2'b11;

                            // MSB indicates valid dirty target register
assign load_rd_d1_nxt       = {o_decode_daccess && !o_write_data_wen, o_load_rd[3:0]};
assign shift_imm            = instruction[11:7];
assign offset12             = { 20'h0, instruction[11:0]};
assign offset24             = {{6{instruction[23]}}, instruction[23:0], 2'd0 }; // sign extend
assign imm8                 = instruction[7:0];

assign immediate_shift_op   = instruction[25];
assign rds_use_rs           = (type == REGOP && !instruction[25] && instruction[4]) ||
                              (type == MULT &&
                               (control_state == MULT_PROC1  ||
                                control_state == MULT_PROC2  ||
//                                instruction_valid && !interrupt )) ;
// remove the '!conflict' term from the interrupt logic used here
// to break a combinational loop
                                (instruction_valid && !interrupt_or_conflict))) ;


assign branch               = type == BRANCH;
assign opcode_compare       = opcode == CMP || opcode == CMN || opcode == TEQ || opcode == TST ;
assign mem_op               = type == TRANS;
assign load_op              = mem_op && instruction[20];
assign store_op             = mem_op && !instruction[20];
assign write_pc             = (pc_wen_nxt && pc_sel_nxt != 3'd0) || load_pc_r || load_pc_nxt;
assign current_write_pc     = (pc_wen_nxt && pc_sel_nxt != 3'd0) || load_pc_nxt;
assign regop_set_flags      = type == REGOP && instruction[20];

assign mem_op_pre_indexed   =  instruction[24] && instruction[21];
assign mem_op_post_indexed  = !instruction[24];

assign imm32_nxt            =  // add 0 to Rm
                               type == MULT               ? {  32'd0                      } :

                               // 4 x number of registers
                               type == MTRANS             ? {  mtrans_base_reg_change     } :
                               type == BRANCH             ? {  offset24                   } :
                               type == TRANS              ? {  offset12                   } :
                               instruction[11:8] == 4'h0  ? {            24'h0, imm8[7:0] } :
                               instruction[11:8] == 4'h1  ? { imm8[1:0], 24'h0, imm8[7:2] } :
                               instruction[11:8] == 4'h2  ? { imm8[3:0], 24'h0, imm8[7:4] } :
                               instruction[11:8] == 4'h3  ? { imm8[5:0], 24'h0, imm8[7:6] } :
                               instruction[11:8] == 4'h4  ? { imm8[7:0], 24'h0            } :
                               instruction[11:8] == 4'h5  ? { 2'h0,  imm8[7:0], 22'h0     } :
                               instruction[11:8] == 4'h6  ? { 4'h0,  imm8[7:0], 20'h0     } :
                               instruction[11:8] == 4'h7  ? { 6'h0,  imm8[7:0], 18'h0     } :
                               instruction[11:8] == 4'h8  ? { 8'h0,  imm8[7:0], 16'h0     } :
                               instruction[11:8] == 4'h9  ? { 10'h0, imm8[7:0], 14'h0     } :
                               instruction[11:8] == 4'ha  ? { 12'h0, imm8[7:0], 12'h0     } :
                               instruction[11:8] == 4'hb  ? { 14'h0, imm8[7:0], 10'h0     } :
                               instruction[11:8] == 4'hc  ? { 16'h0, imm8[7:0], 8'h0      } :
                               instruction[11:8] == 4'hd  ? { 18'h0, imm8[7:0], 6'h0      } :
                               instruction[11:8] == 4'he  ? { 20'h0, imm8[7:0], 4'h0      } :
                                                            { 22'h0, imm8[7:0], 2'h0      } ;


assign imm_shift_amount_nxt = shift_imm ;

       // This signal is encoded in the decode stage because
       // it is on the critical path in the execute stage
assign shift_imm_zero_nxt   = imm_shift_amount_nxt == 5'd0 &&       // immediate amount = 0
                              barrel_shift_amount_sel_nxt == 2'd2;  // shift immediate amount

assign alu_function_nxt     = { alu_swap_sel_nxt,
                                alu_not_sel_nxt,
                                alu_cin_sel_nxt,
                                alu_cout_sel_nxt,
                                alu_out_sel_nxt  };

// ========================================================
// Register Conflict Detection
// ========================================================
assign rn_valid       = type == REGOP || type == MULT || type == SWAP || type == TRANS || type == MTRANS || type == CODTRANS;
assign rm_valid       = type == REGOP || type == MULT || type == SWAP || (type == TRANS && immediate_shift_op);
assign rs_valid       = rds_use_rs;
assign rd_valid       = (type == TRANS  && store_op) || (type == REGOP || type == SWAP);
assign stm_valid      = type == MTRANS && !instruction[20];   // stm instruction


assign rn_conflict1   = instruction_execute   && rn_valid  && ( load_rd_d1_nxt[4] && rn_sel_nxt         == load_rd_d1_nxt[3:0] );
assign rn_conflict2   = instruction_execute_r && rn_valid  && ( load_rd_d1    [4] && rn_sel_nxt         == load_rd_d1    [3:0] );
assign rm_conflict1   = instruction_execute   && rm_valid  && ( load_rd_d1_nxt[4] && rm_sel_nxt         == load_rd_d1_nxt[3:0] );
assign rm_conflict2   = instruction_execute_r && rm_valid  && ( load_rd_d1    [4] && rm_sel_nxt         == load_rd_d1    [3:0] );
assign rs_conflict1   = instruction_execute   && rs_valid  && ( load_rd_d1_nxt[4] && rs_sel_nxt         == load_rd_d1_nxt[3:0] );
assign rs_conflict2   = instruction_execute_r && rs_valid  && ( load_rd_d1    [4] && rs_sel_nxt         == load_rd_d1    [3:0] );
assign rd_conflict1   = instruction_execute   && rd_valid  && ( load_rd_d1_nxt[4] && instruction[15:12] == load_rd_d1_nxt[3:0] );
assign rd_conflict2   = instruction_execute_r && rd_valid  && ( load_rd_d1    [4] && instruction[15:12] == load_rd_d1    [3:0] );

assign stm_conflict1a = instruction_execute   && stm_valid && ( load_rd_d1_nxt[4] && mtrans_reg1        == load_rd_d1_nxt[3:0] );
assign stm_conflict1b = instruction_execute   && stm_valid && ( load_rd_d1_nxt[4] && mtrans_reg2        == load_rd_d1_nxt[3:0] );
assign stm_conflict2a = instruction_execute_r && stm_valid && ( load_rd_d1    [4] && mtrans_reg1        == load_rd_d1    [3:0] );
assign stm_conflict2b = instruction_execute_r && stm_valid && ( load_rd_d1    [4] && mtrans_reg2        == load_rd_d1    [3:0] );

assign conflict1      = instruction_valid &&
                        (rn_conflict1 || rm_conflict1 || rs_conflict1 || rd_conflict1 ||
                         stm_conflict1a || stm_conflict1b);

assign conflict2      = instruction_valid && (stm_conflict2a || stm_conflict2b);

assign conflict       = conflict1 || conflict2;


always @( posedge i_clk )
    if ( !i_core_stall )
        begin
        conflict_r              <= conflict;
        instruction_execute_r   <= instruction_execute;
        rn_conflict1_r          <= rn_conflict1 && instruction_execute;
        rm_conflict1_r          <= rm_conflict1 && instruction_execute;
        rs_conflict1_r          <= rs_conflict1 && instruction_execute;
        rd_conflict1_r          <= rd_conflict1 && instruction_execute;
        o_rn_use_read           <= instruction_valid && ( rn_conflict1_r || rn_conflict2 );
        o_rm_use_read           <= instruction_valid && ( rm_conflict1_r || rm_conflict2 );
        o_rs_use_read           <= instruction_valid && ( rs_conflict1_r || rs_conflict2 );
        o_rd_use_read           <= instruction_valid && ( rd_conflict1_r || rd_conflict2 );
        end

assign o_conflict = conflict;


// ========================================================
// MTRANS Operations
// ========================================================

   // Bit 15 = r15
   // Bit 0  = r0
   // In ldm and stm instructions r0 is loaded or stored first
always @*
    casez ( instruction[15:0] )
    16'b???????????????1 : mtrans_reg1 = 4'h0 ;
    16'b??????????????10 : mtrans_reg1 = 4'h1 ;
    16'b?????????????100 : mtrans_reg1 = 4'h2 ;
    16'b????????????1000 : mtrans_reg1 = 4'h3 ;
    16'b???????????10000 : mtrans_reg1 = 4'h4 ;
    16'b??????????100000 : mtrans_reg1 = 4'h5 ;
    16'b?????????1000000 : mtrans_reg1 = 4'h6 ;
    16'b????????10000000 : mtrans_reg1 = 4'h7 ;
    16'b???????100000000 : mtrans_reg1 = 4'h8 ;
    16'b??????1000000000 : mtrans_reg1 = 4'h9 ;
    16'b?????10000000000 : mtrans_reg1 = 4'ha ;
    16'b????100000000000 : mtrans_reg1 = 4'hb ;
    16'b???1000000000000 : mtrans_reg1 = 4'hc ;
    16'b??10000000000000 : mtrans_reg1 = 4'hd ;
    16'b?100000000000000 : mtrans_reg1 = 4'he ;
    default              : mtrans_reg1 = 4'hf ;
    endcase


assign mtrans_reg2_mask = 1'd1<<mtrans_reg1;

always @*
    casez ( instruction[15:0] & ~mtrans_reg2_mask )
    16'b???????????????1 : mtrans_reg2 = 4'h0 ;
    16'b??????????????10 : mtrans_reg2 = 4'h1 ;
    16'b?????????????100 : mtrans_reg2 = 4'h2 ;
    16'b????????????1000 : mtrans_reg2 = 4'h3 ;
    16'b???????????10000 : mtrans_reg2 = 4'h4 ;
    16'b??????????100000 : mtrans_reg2 = 4'h5 ;
    16'b?????????1000000 : mtrans_reg2 = 4'h6 ;
    16'b????????10000000 : mtrans_reg2 = 4'h7 ;
    16'b???????100000000 : mtrans_reg2 = 4'h8 ;
    16'b??????1000000000 : mtrans_reg2 = 4'h9 ;
    16'b?????10000000000 : mtrans_reg2 = 4'ha ;
    16'b????100000000000 : mtrans_reg2 = 4'hb ;
    16'b???1000000000000 : mtrans_reg2 = 4'hc ;
    16'b??10000000000000 : mtrans_reg2 = 4'hd ;
    16'b?100000000000000 : mtrans_reg2 = 4'he ;
    default              : mtrans_reg2 = 4'hf ;
    endcase

always @*
    casez (instruction[15:0])
    16'b???????????????1 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 1],  1'd0};
    16'b??????????????10 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 2],  2'd0};
    16'b?????????????100 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 3],  3'd0};
    16'b????????????1000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 4],  4'd0};
    16'b???????????10000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 5],  5'd0};
    16'b??????????100000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 6],  6'd0};
    16'b?????????1000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 7],  7'd0};
    16'b????????10000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 8],  8'd0};
    16'b???????100000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15: 9],  9'd0};
    16'b??????1000000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15:10], 10'd0};
    16'b?????10000000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15:11], 11'd0};
    16'b????100000000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15:12], 12'd0};
    16'b???1000000000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15:13], 13'd0};
    16'b??10000000000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15:14], 14'd0};
    16'b?100000000000000 : mtrans_instruction_nxt = {instruction[31:16], instruction[15   ], 15'd0};
    default              : mtrans_instruction_nxt = {instruction[31:16],                     16'd0};
    endcase


// number of registers to be stored
assign mtrans_num_registers =   {4'd0, instruction[15]} +
                                {4'd0, instruction[14]} +
                                {4'd0, instruction[13]} +
                                {4'd0, instruction[12]} +
                                {4'd0, instruction[11]} +
                                {4'd0, instruction[10]} +
                                {4'd0, instruction[ 9]} +
                                {4'd0, instruction[ 8]} +
                                {4'd0, instruction[ 7]} +
                                {4'd0, instruction[ 6]} +
                                {4'd0, instruction[ 5]} +
                                {4'd0, instruction[ 4]} +
                                {4'd0, instruction[ 3]} +
                                {4'd0, instruction[ 2]} +
                                {4'd0, instruction[ 1]} +
                                {4'd0, instruction[ 0]} ;

// 4 x number of registers to be stored
assign mtrans_base_reg_change = {25'd0, mtrans_num_registers, 2'd0};

// ========================================================
// Interrupts
// ========================================================

assign firq_request = firq && !i_execute_status_bits[26];
assign irq_request  = irq  && !i_execute_status_bits[27];
assign swi_request  = type == SWI;
assign dabt_request = dabt_reg;

// copro15 and copro13 only supports reg trans opcodes
// all other opcodes involving co-processors cause an
// undefined instrution interrupt
assign und_request  =   type == CODTRANS ||
                        type == COREGOP  ||
                      ( type == CORTRANS && instruction[11:8] != 4'd15 );


  // in order of priority !!
  // Highest
  // 1 Reset
  // 2 Data Abort (including data TLB miss)
  // 3 FIRQ
  // 4 IRQ
  // 5 Prefetch Abort (including prefetch TLB miss)
  // 6 Undefined instruction, SWI
  // Lowest
assign next_interrupt = dabt_request     ? 3'd1 :  // Data Abort
                        firq_request     ? 3'd2 :  // FIRQ
                        irq_request      ? 3'd3 :  // IRQ
                        instruction_adex ? 3'd4 :  // Address Exception
                        instruction_iabt ? 3'd5 :  // PreFetch Abort, only triggered
                                                   // if the instruction is used
                        und_request      ? 3'd6 :  // Undefined Instruction
                        swi_request      ? 3'd7 :  // SWI
                                           3'd0 ;  // none


// SWI and undefined instructions do not cause an interrupt in the decode
// stage. They only trigger interrupts if they arfe executed, so the
// interrupt is triggered if the execute condition is met in the execute stage
assign interrupt      = next_interrupt != 3'd0 &&
                        next_interrupt != 3'd7 &&  // SWI
                        next_interrupt != 3'd6 &&  // undefined interrupt
                        !conflict               ;  // Wait for conflicts to resolve before
                                                   // triggering int


// Added to use in rds_use_rs logic to break a combinational loop invloving
// the conflict signal
assign interrupt_or_conflict
                     =  next_interrupt != 3'd0 &&
                        next_interrupt != 3'd7 &&  // SWI
                        next_interrupt != 3'd6  ;  // undefined interrupt

assign interrupt_mode = next_interrupt == 3'd2 ? FIRQ :
                        next_interrupt == 3'd3 ? IRQ  :
                        next_interrupt == 3'd4 ? SVC  :
                        next_interrupt == 3'd5 ? SVC  :
                        next_interrupt == 3'd6 ? SVC  :
                        next_interrupt == 3'd7 ? SVC  :
                        next_interrupt == 3'd1 ? SVC  :
                                                 USR  ;


// ========================================================
// Generate control signals
// ========================================================
always @*
    begin
    // default mode
    status_bits_mode_nxt            = i_execute_status_bits[1:0];   // change to mode in execute stage get reflected
                                                                    // back to this stage automatically
    status_bits_irq_mask_nxt        = status_bits_irq_mask_r;
    status_bits_firq_mask_nxt       = status_bits_firq_mask_r;
    decode_exclusive_nxt            = 1'd0;
    decode_daccess_nxt              = 1'd0;
    decode_iaccess_nxt              = 1'd1;
    copro_operation_nxt             = 'd0;

    // Save an instruction to use later
    saved_current_instruction_wen   = 1'd0;
    pre_fetch_instruction_wen       = 1'd0;
    restore_base_address_nxt        = restore_base_address;

    // default Mux Select values
    barrel_shift_amount_sel_nxt     = 'd0;  // don't shift the input
    barrel_shift_data_sel_nxt       = 'd0;  // immediate value
    barrel_shift_function_nxt       = 'd0;
    use_carry_in_nxt                = 'd0;
    multiply_function_nxt           = 'd0;
    iaddress_sel_nxt                = 'd0;
    daddress_sel_nxt                = 'd0;
    pc_sel_nxt                      = 'd0;
    load_pc_nxt                     = 'd0;
    byte_enable_sel_nxt             = 'd0;
    status_bits_sel_nxt             = 'd0;
    reg_write_sel_nxt               = 'd0;
    o_user_mode_regs_store_nxt      = 'd0;

    // ALU Muxes
    alu_swap_sel_nxt                = 'd0;
    alu_not_sel_nxt                 = 'd0;
    alu_cin_sel_nxt                 = 'd0;
    alu_cout_sel_nxt                = 'd0;
    alu_out_sel_nxt                 = 'd0;

    // default Flop Write Enable values
    write_data_wen_nxt              = 'd0;
    copro_write_data_wen_nxt        = 'd0;
    base_address_wen_nxt            = 'd0;
    pc_wen_nxt                      = 'd1;
    reg_bank_wen_nxt                = 'd0;  // Don't select any

    status_bits_flags_wen_nxt       = 'd0;
    status_bits_mode_wen_nxt        = 'd0;
    status_bits_irq_mask_wen_nxt    = 'd0;
    status_bits_firq_mask_wen_nxt   = 'd0;

    if ( instruction_valid && !interrupt && !conflict )
        begin
        if ( type == REGOP )
            begin
            if ( !opcode_compare )
                begin
                // Check is the load destination is the PC
                if (instruction[15:12]  == 4'd15)
                    begin
                    pc_sel_nxt       = 3'd1; // alu_out
                    iaddress_sel_nxt = 4'd1; // alu_out
                    end
                else
                    reg_bank_wen_nxt = decode (instruction[15:12]);
                end

            if ( !immediate_shift_op )
                begin
                barrel_shift_function_nxt  = instruction[6:5];
                end

            if ( !immediate_shift_op )
                barrel_shift_data_sel_nxt = 2'd2; // Shift value from Rm register

            if ( !immediate_shift_op && instruction[4] )
                barrel_shift_amount_sel_nxt = 2'd1; // Shift amount from Rs registter

            if ( !immediate_shift_op && !instruction[4] )
                barrel_shift_amount_sel_nxt = 2'd2; // Shift immediate amount

            // regops that do not change the overflow flag
            if ( opcode == AND || opcode == EOR || opcode == TST || opcode == TEQ ||
                 opcode == ORR || opcode == MOV || opcode == BIC || opcode == MVN )
                status_bits_sel_nxt = 3'd5;

            if ( opcode == ADD || opcode == CMN )   // CMN is just like an ADD
                begin
                alu_out_sel_nxt  = 4'd1; // Add
                use_carry_in_nxt = shift_extend;
                end

            if ( opcode == ADC ) // Add with Carry
                begin
                alu_out_sel_nxt  = 4'd1; // Add
                alu_cin_sel_nxt  = 2'd2; // carry in from status_bits
                use_carry_in_nxt = shift_extend;
                end

            if ( opcode == SUB || opcode == CMP ) // Subtract
                begin
                alu_out_sel_nxt  = 4'd1; // Add
                alu_cin_sel_nxt  = 2'd1; // cin = 1
                alu_not_sel_nxt  = 1'd1; // invert B
                end

            // SBC (Subtract with Carry) subtracts the value of its
            // second operand and the value of NOT(Carry flag) from
            // the value of its first operand.
            //  Rd = Rn - shifter_operand - NOT(C Flag)
            if ( opcode == SBC ) // Subtract with Carry
                begin
                alu_out_sel_nxt  = 4'd1; // Add
                alu_cin_sel_nxt  = 2'd2; // carry in from status_bits
                alu_not_sel_nxt  = 1'd1; // invert B
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == RSB ) // Reverse Subtract
                begin
                alu_out_sel_nxt  = 4'd1; // Add
                alu_cin_sel_nxt  = 2'd1; // cin = 1
                alu_not_sel_nxt  = 1'd1; // invert B
                alu_swap_sel_nxt = 1'd1; // swap A and B
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == RSC ) // Reverse Subtract with carry
                begin
                alu_out_sel_nxt  = 4'd1; // Add
                alu_cin_sel_nxt  = 2'd2; // carry in from status_bits
                alu_not_sel_nxt  = 1'd1; // invert B
                alu_swap_sel_nxt = 1'd1; // swap A and B
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == AND || opcode == TST ) // Logical AND, Test  (using AND operator)
                begin
                alu_out_sel_nxt  = 4'd8;  // AND
                alu_cout_sel_nxt = 1'd1;  // i_barrel_shift_carry
                end

            if ( opcode == EOR || opcode == TEQ ) // Logical Exclusive OR, Test Equivalence (using EOR operator)
                begin
                alu_out_sel_nxt = 4'd6;  // XOR
                alu_cout_sel_nxt = 1'd1; // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == ORR )
                begin
                alu_out_sel_nxt  = 4'd7; // OR
                alu_cout_sel_nxt = 1'd1;  // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == BIC ) // Bit Clear (using AND & NOT operators)
                begin
                alu_out_sel_nxt  = 4'd8;  // AND
                alu_not_sel_nxt  = 1'd1;  // invert B
                alu_cout_sel_nxt = 1'd1;  // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
               end

            if ( opcode == MOV ) // Move
                begin
                alu_cout_sel_nxt = 1'd1;  // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == MVN ) // Move NOT
                begin
                alu_not_sel_nxt  = 1'd1; // invert B
                alu_cout_sel_nxt = 1'd1;  // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
               end
            end

        // Load & Store instructions
        if ( mem_op )
            begin
            if ( load_op && instruction[15:12]  == 4'd15 ) // Write to PC
                begin
                saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
                pc_wen_nxt                      = 1'd0; // hold current PC value rather than an instruction fetch
                load_pc_nxt                     = 1'd1;
                end

            decode_daccess_nxt              = 1'd1; // indicate a valid data access
            alu_out_sel_nxt                 = 4'd1; // Add

            if ( !instruction[23] )  // U: Subtract offset
                begin
                alu_cin_sel_nxt  = 2'd1; // cin = 1
                alu_not_sel_nxt  = 1'd1; // invert B
                end

            if ( store_op )
                begin
                write_data_wen_nxt = 1'd1;
                if ( type == TRANS && instruction[22] )
                    byte_enable_sel_nxt = 2'd1;         // Save byte
                end

                // need to update the register holding the address ?
                // This is Rn bits [19:16]
            if ( mem_op_pre_indexed || mem_op_post_indexed )
                begin
                // Check is the load destination is the PC
                if ( rn_sel_nxt  == 4'd15 )
                    pc_sel_nxt = 3'd1;
                else
                    reg_bank_wen_nxt = decode ( rn_sel_nxt );
                end

                // if post-indexed, then use Rn rather than ALU output, as address
            if ( mem_op_post_indexed )
               daddress_sel_nxt = 4'd4; // Rn
            else
               daddress_sel_nxt = 4'd1; // alu out

            if ( instruction[25] && type ==  TRANS )
                barrel_shift_data_sel_nxt = 2'd2; // Shift value from Rm register

            if ( type == TRANS && instruction[25] && shift_imm != 5'd0 )
                begin
                barrel_shift_function_nxt   = instruction[6:5];
                barrel_shift_amount_sel_nxt = 2'd2; // imm_shift_amount
                end
            end


        if ( type == BRANCH )
            begin
            pc_sel_nxt            = 3'd1; // alu_out
            iaddress_sel_nxt      = 4'd1; // alu_out
            alu_out_sel_nxt       = 4'd1; // Add

            if ( instruction[24] ) // Link
                begin
                reg_bank_wen_nxt  = decode (4'd14);  // Save PC to LR
                reg_write_sel_nxt = 3'd1;            // pc - 32'd4
                end
            end


        if ( type == MTRANS )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            decode_daccess_nxt              = 1'd1; // valid data access
            alu_out_sel_nxt                 = 4'd1; // Add
            base_address_wen_nxt            = 1'd1; // Save the value of the register used for the base address,
                                                    // in case of a data abort, and need to restore the value

            if ( mtrans_num_registers > 4'd1 )
                begin
                iaddress_sel_nxt        = 4'd3; // pc  (not pc + 4)
                pc_wen_nxt              = 1'd0; // hold current PC value rather than an instruction fetch
                end


            // The spec says -
            // If the instruction would have overwritten the base with data
            // (that is, it has the base in the transfer list), the overwriting is prevented.
            // This is true even when the abort occurs after the base word gets loaded
            restore_base_address_nxt        = instruction[20] &&
                                                (instruction[15:0] & (1'd1 << instruction[19:16]));

            // Increment
            if ( instruction[23] )
                begin
                if ( instruction[24] )    // increment before
                    daddress_sel_nxt = 4'd7; // Rn + 4
                else
                    daddress_sel_nxt = 4'd4; // Rn
                end
            else
            // Decrement
                begin
                alu_cin_sel_nxt  = 2'd1; // cin = 1
                alu_not_sel_nxt  = 1'd1; // invert B
                if ( !instruction[24] )    // decrement after
                    daddress_sel_nxt  = 4'd6; // alu out + 4
                else
                    daddress_sel_nxt  = 4'd1; // alu out
                end

            // Load or store ?
            if ( !instruction[20] )  // Store
                write_data_wen_nxt = 1'd1;

            // stm: store the user mode registers, when in priviledged mode
            if ( {instruction[22],instruction[20]} == 2'b10 )
                o_user_mode_regs_store_nxt = 1'd1;

            // update the base register ?
            if ( instruction[21] )  // the W bit
                reg_bank_wen_nxt  = decode (rn_sel_nxt);

            // write to the pc ?
            if ( instruction[20] && mtrans_reg1 == 4'd15 ) // Write to PC
                begin
                saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
                pc_wen_nxt                      = 1'd0; // hold current PC value rather than an instruction fetch
                load_pc_nxt                     = 1'd1;
                end
            end


        if ( type == MULT )
            begin
            multiply_function_nxt[0]        = 1'd1; // set enable
                                                    // some bits can be changed just below
            saved_current_instruction_wen   = 1'd1; // Save the Multiply instruction to
                                                    // refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value

            if ( instruction[21] )
                multiply_function_nxt[1]    = 1'd1; // accumulate
            end


        // swp - do read part first
        if ( type == SWAP )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value
            decode_iaccess_nxt              = 1'd0; // skip the instruction fetch
            decode_daccess_nxt              = 1'd1; // data access
            barrel_shift_data_sel_nxt       = 2'd2; // Shift value from Rm register
            daddress_sel_nxt                = 4'd4; // Rn
            decode_exclusive_nxt            = 1'd1; // signal an exclusive access
            end


        // mcr & mrc - takes two cycles
        if ( type == CORTRANS && !und_request )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value
            iaddress_sel_nxt                = 4'd3; // pc  (not pc + 4)

            if ( instruction[20] ) // MRC
                copro_operation_nxt         = 2'd1;  // Register transfer from Co-Processor
            else // MCR
                begin
                 // Don't enable operation to Co-Processor until next period
                 // So it gets the Rd value from the execution stage at the same time
                copro_operation_nxt      = 2'd0;
                copro_write_data_wen_nxt = 1'd1;  // Rd register value to co-processor
                end
            end


        if ( type == SWI || und_request )
            begin
            // save address of next instruction to Supervisor Mode LR
            reg_write_sel_nxt               = 3'd1;            // pc -4
            reg_bank_wen_nxt                = decode (4'd14);  // LR

            iaddress_sel_nxt                = 4'd2;            // interrupt_vector
            pc_sel_nxt                      = 3'd2;            // interrupt_vector

            status_bits_mode_nxt            = interrupt_mode;  // e.g. Supervisor mode
            status_bits_mode_wen_nxt        = 1'd1;

            // disable normal interrupts
            status_bits_irq_mask_nxt        = 1'd1;
            status_bits_irq_mask_wen_nxt    = 1'd1;
            end


        if ( regop_set_flags )
            begin
            status_bits_flags_wen_nxt = 1'd1;

            // If <Rd> is r15, the ALU output is copied to the Status Bits.
            // Not allowed to use r15 for mul or lma instructions
            if ( instruction[15:12] == 4'd15 )
                begin
                status_bits_sel_nxt       = 3'd1; // alu out

                // Priviledged mode? Then also update the other status bits
                if ( i_execute_status_bits[1:0] != USR )
                    begin
                    status_bits_mode_wen_nxt      = 1'd1;
                    status_bits_irq_mask_wen_nxt  = 1'd1;
                    status_bits_firq_mask_wen_nxt = 1'd1;
                    end
                end
            end

        end

    // Handle asynchronous interrupts.
    // interrupts are processed only during execution states
    // multicycle instructions must complete before the interrupt starts
    // SWI, Address Exception and Undefined Instruction interrupts are only executed if the
    // instruction that causes the interrupt is conditionally executed so
    // its not handled here
    if ( instruction_valid && interrupt &&  next_interrupt != 3'd6 )
        begin
        // Save the interrupt causing instruction to refer back to later
        // This also saves the instruction abort vma and status, in the case of an
        // instruction abort interrupt
        saved_current_instruction_wen   = 1'd1;

        // save address of next instruction to Supervisor Mode LR
        // Address Exception ?
        if ( next_interrupt == 3'd4 )
            reg_write_sel_nxt               = 3'd7;            // pc
        else
            reg_write_sel_nxt               = 3'd1;            // pc -4

        reg_bank_wen_nxt                = decode (4'd14);  // LR

        iaddress_sel_nxt                = 4'd2;            // interrupt_vector
        pc_sel_nxt                      = 3'd2;            // interrupt_vector

        status_bits_mode_nxt            = interrupt_mode;  // e.g. Supervisor mode
        status_bits_mode_wen_nxt        = 1'd1;

        // disable normal interrupts
        status_bits_irq_mask_nxt        = 1'd1;
        status_bits_irq_mask_wen_nxt    = 1'd1;

        // disable fast interrupts
        if ( next_interrupt == 3'd2 ) // FIRQ
            begin
            status_bits_firq_mask_nxt        = 1'd1;
            status_bits_firq_mask_wen_nxt    = 1'd1;
            end
        end


    // previous instruction was ldr
    // if it is currently executing in the execute stage do the following
    if ( control_state == MEM_WAIT1 && !conflict )
        begin
        // Save the next instruction to execute later
        // Do this even if the ldr instruction does not execute because of Condition
        pre_fetch_instruction_wen   = 1'd1;

        if ( instruction_execute ) // conditional execution state
            begin
            iaddress_sel_nxt            = 4'd3; // pc  (not pc + 4)
            pc_wen_nxt                  = 1'd0; // hold current PC value
            load_pc_nxt                 = load_pc_r;
            end
        end


    // completion of ldr instruction
    if ( control_state == MEM_WAIT2 )
        begin
        if ( !dabt )  // dont load data there is an abort on the data read
            begin
            pc_wen_nxt                  = 1'd0; // hold current PC value

            // Check if the load destination is the PC
            if (( type == TRANS && instruction[15:12]  == 4'd15 ) ||
                ( type == MTRANS && instruction[20] && mtrans_reg1 == 4'd15 ))
                begin
                pc_sel_nxt       = 3'd3; // read_data_filtered
                iaddress_sel_nxt = 4'd3; // hold value after reading in from mem
                load_pc_nxt      = load_pc_r;
                end
            end
        end


    // second cycle of multiple load or store
    if ( control_state == MTRANS_EXEC1 && !conflict )
        begin
        // Save the next instruction to execute later
        pre_fetch_instruction_wen   = 1'd1;

        if ( instruction_execute ) // conditional execution state
            begin
            daddress_sel_nxt            = 4'd5;  // o_address
            decode_daccess_nxt          = 1'd1;  // data access

            if ( mtrans_num_registers > 4'd2 )
                decode_iaccess_nxt      = 1'd0;  // skip the instruction fetch


            if ( mtrans_num_registers != 4'd1 )
                begin
                pc_wen_nxt              = 1'd0;  // hold current PC value
                iaddress_sel_nxt        = 4'd3;  // pc  (not pc + 4)
                end


            if ( !instruction[20] ) // Store
                write_data_wen_nxt = 1'd1;

            // stm: store the user mode registers, when in priviledged mode
            if ( {instruction[22],instruction[20]} == 2'b10 )
                o_user_mode_regs_store_nxt = 1'd1;

            // write to the pc ?
            if ( instruction[20] && mtrans_reg1 == 4'd15 ) // Write to PC
                begin
                saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
                pc_wen_nxt                      = 1'd0; // hold current PC value rather than an instruction fetch
                load_pc_nxt                     = 1'd1;
                end
            end
        end


    // third cycle of multiple load or store
    if ( control_state == MTRANS_EXEC2 )
        begin
        daddress_sel_nxt            = 4'd5;  // o_address
        decode_daccess_nxt          = 1'd1;  // data access

        if ( mtrans_num_registers > 4'd2 )
            begin
            decode_iaccess_nxt      = 1'd0;  // skip the instruction fetch
            end

        if ( mtrans_num_registers > 4'd1 )
            begin
            pc_wen_nxt              = 1'd0; // hold current PC value
            iaddress_sel_nxt        = 4'd3;  // pc  (not pc + 4)
            end

        // Store
        if ( !instruction[20] )
            write_data_wen_nxt = 1'd1;

        // stm: store the user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20]} == 2'b10 )
            o_user_mode_regs_store_nxt = 1'd1;

        // write to the pc ?
        if ( instruction[20] && mtrans_reg1 == 4'd15 ) // Write to PC
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value rather than an instruction fetch
            load_pc_nxt                     = 1'd1;
            end
        end


    // state is for when a data abort interrupt is triggered during an ldm
    if ( control_state == MTRANS_ABORT )
        begin
        // Restore the Base Address, if the base register is included in the
        // list of registers being loaded
        if (restore_base_address) // ldm with base address in register list
            begin
            reg_write_sel_nxt = 3'd6;                        // write base_register
            reg_bank_wen_nxt  = decode ( instruction[19:16] ); // to Rn
            end
        end


        // Multiply or Multiply-Accumulate
    if ( control_state == MULT_PROC1 && instruction_execute && !conflict )
        begin
        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pre_fetch_instruction_wen   = 1'd1;
        pc_wen_nxt                  = 1'd0;  // hold current PC value
        multiply_function_nxt       = o_multiply_function;
        end


        // Multiply or Multiply-Accumulate
        // Do multiplication
        // Wait for done or accumulate signal
    if ( control_state == MULT_PROC2 )
        begin
        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pc_wen_nxt              = 1'd0;  // hold current PC value
        iaddress_sel_nxt        = 4'd3;  // pc  (not pc + 4)
        multiply_function_nxt   = o_multiply_function;
        end


    // Save RdLo
    // always last cycle of all multiply or multiply accumulate operations
    if ( control_state == MULT_STORE )
        begin
        reg_write_sel_nxt     = 3'd2; // multiply_out
        multiply_function_nxt = o_multiply_function;

        if ( type == MULT ) // 32-bit
            reg_bank_wen_nxt      = decode (instruction[19:16]); // Rd
        else  // 64-bit / Long
            reg_bank_wen_nxt      = decode (instruction[15:12]); // RdLo

        if ( instruction[20] )  // the 'S' bit
            begin
            status_bits_sel_nxt       = 3'd4; // { multiply_flags, status_bits_flags[1:0] }
            status_bits_flags_wen_nxt = 1'd1;
            end
        end


    // Add lower 32 bits to multiplication product
    if ( control_state == MULT_ACCUMU )
        begin
        multiply_function_nxt = o_multiply_function;
        pc_wen_nxt            = 1'd0;  // hold current PC value
        iaddress_sel_nxt      = 4'd3;  // pc  (not pc + 4)
        end


    // swp - do write request in 2nd cycle
    if ( control_state == SWAP_WRITE && instruction_execute && !conflict )
        begin
        barrel_shift_data_sel_nxt       = 2'd2; // Shift value from Rm register
        daddress_sel_nxt                = 4'd4; // Rn
        write_data_wen_nxt              = 1'd1;
        decode_iaccess_nxt              = 1'd0; // skip the instruction fetch
        decode_daccess_nxt              = 1'd1; // data access

        if ( instruction[22] )
            byte_enable_sel_nxt = 2'd1;         // Save byte

        if ( instruction_execute )              // conditional execution state
            pc_wen_nxt                  = 1'd0; // hold current PC value

        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pre_fetch_instruction_wen       = 1'd1;

        load_pc_nxt                     = load_pc_r;
        end


    // swp - receive read response in 3rd cycle
    if ( control_state == SWAP_WAIT1 )
        begin

        if ( instruction_execute ) // conditional execution state
            begin
            iaddress_sel_nxt            = 4'd3; // pc  (not pc + 4)
            pc_wen_nxt                  = 1'd0; // hold current PC value
            end

        if ( !dabt )
            begin
            // Check is the load destination is the PC
            if ( instruction[15:12]  == 4'd15 )
                begin
                pc_sel_nxt       = 3'd3; // read_data_filtered
                iaddress_sel_nxt = 4'd3; // hold value after reading in from mem
                load_pc_nxt      = load_pc_r;
                end
            end
        end


    // 1 cycle delay for Co-Processor Register access
    if ( control_state == COPRO_WAIT && instruction_execute && !conflict )
        begin
        pre_fetch_instruction_wen = 1'd1;

        if ( instruction[20] ) // mrc instruction
            begin
            // Check is the load destination is the PC
            if ( instruction[15:12]  == 4'd15 )
                begin
                // If r15 is specified for <Rd>, the condition code flags are
                // updated instead of a general-purpose register.
                status_bits_sel_nxt           = 3'd3;  // i_copro_data
                status_bits_flags_wen_nxt     = 1'd1;

                // Can't change these in USR mode
                if ( i_execute_status_bits[1:0] != USR )
                   begin
                   status_bits_mode_wen_nxt      = 1'd1;
                   status_bits_irq_mask_wen_nxt  = 1'd1;
                   status_bits_firq_mask_wen_nxt = 1'd1;
                   end
                end
            else
                reg_bank_wen_nxt = decode (instruction[15:12]);

            reg_write_sel_nxt = 3'd5;     // i_copro_data
            end
        else // mcr instruction
            begin
            copro_operation_nxt      = 2'd2;  // Register transfer to Co-Processor
            end
        end


    // Have just changed the status_bits mode but this
    // creates a 1 cycle gap with the old mode
    // coming back from execute into instruction_decode
    // So squash that old mode value during this
    // cycle of the interrupt transition
    if ( control_state == INT_WAIT1 )
        status_bits_mode_nxt            = status_bits_mode_r;   // Supervisor mode

    end


// Speed up the long path from u_decode/fetch_instruction_r to u_register_bank/r8_firq
// This pre-encodes the firq_s3 signal thats used in u_register_bank
assign firq_not_user_mode_nxt = status_bits_mode_nxt == FIRQ;


// ========================================================
// Next State Logic
// ========================================================

// this replicates the current value of the execute signal in the execute stage
assign instruction_execute = conditional_execute ( condition_r, i_execute_status_bits[31:28] );


// First state of executing a new instruction
// Its complex because of conditional execution of multi-cycle instructions
assign instruction_valid = ((control_state == EXECUTE || control_state == PRE_FETCH_EXEC) ||
                              // when last instruction was multi-cycle instruction but did not execute
                              // because condition was false then act like you're in the execute state
                             (!instruction_execute && (control_state == PC_STALL1    ||
                                                       control_state == MEM_WAIT1    ||
                                                       control_state == COPRO_WAIT   ||
                                                       control_state == SWAP_WRITE   ||
                                                       control_state == MULT_PROC1   ||
                                                       control_state == MTRANS_EXEC1  ) ));


 always @*
    begin
    // default is to hold the current state
    control_state_nxt = control_state;

    // Note: The order is important here
    if ( control_state == RST_WAIT1 )     control_state_nxt = RST_WAIT2;
    if ( control_state == RST_WAIT2 )     control_state_nxt = EXECUTE;
    if ( control_state == INT_WAIT1 )     control_state_nxt = INT_WAIT2;
    if ( control_state == INT_WAIT2 )     control_state_nxt = EXECUTE;
    if ( control_state == COPRO_WAIT )    control_state_nxt = PRE_FETCH_EXEC;
    if ( control_state == PC_STALL1 )     control_state_nxt = PC_STALL2;
    if ( control_state == PC_STALL2 )     control_state_nxt = EXECUTE;
    if ( control_state == SWAP_WRITE )    control_state_nxt = SWAP_WAIT1;
    if ( control_state == SWAP_WAIT1 )    control_state_nxt = SWAP_WAIT2;
    if ( control_state == MULT_STORE )    control_state_nxt = PRE_FETCH_EXEC;
    if ( control_state == MTRANS_ABORT )  control_state_nxt = PRE_FETCH_EXEC;

    if ( control_state == MEM_WAIT1 )
        control_state_nxt = MEM_WAIT2;

    if ( control_state == MEM_WAIT2   ||
        control_state == SWAP_WAIT2    )
        begin
        if ( write_pc ) // writing to the PC!!
            control_state_nxt = PC_STALL1;
        else
            control_state_nxt = PRE_FETCH_EXEC;
        end

    if ( control_state == MTRANS_EXEC1 )
        begin
        if ( mtrans_instruction_nxt[15:0] != 16'd0 )
            control_state_nxt = MTRANS_EXEC2;
        else   // if the register list holds a single register
            begin
            if ( dabt ) // data abort
                control_state_nxt = MTRANS_ABORT;
            else if ( write_pc ) // writing to the PC!!
                control_state_nxt = MEM_WAIT1;
            else
                control_state_nxt = PRE_FETCH_EXEC;
            end
        end

        // Stay in State MTRANS_EXEC2 until the full list of registers to
        // load or store has been processed
    if ( control_state == MTRANS_EXEC2 && mtrans_num_registers == 5'd1 )
        begin
        if ( dabt ) // data abort
            control_state_nxt = MTRANS_ABORT;
        else if ( write_pc ) // writing to the PC!!
            control_state_nxt = MEM_WAIT1;
        else
            control_state_nxt = PRE_FETCH_EXEC;
        end


    if ( control_state == MULT_PROC1 )
        begin
        if (!instruction_execute)
            control_state_nxt = PRE_FETCH_EXEC;
        else
            control_state_nxt = MULT_PROC2;
        end

    if ( control_state == MULT_PROC2 )
        begin
        if ( i_multiply_done )
            if      ( o_multiply_function[1] )  // Accumulate ?
                control_state_nxt = MULT_ACCUMU;
            else
                control_state_nxt = MULT_STORE;
        end


    if ( control_state == MULT_ACCUMU )
        begin
        control_state_nxt = MULT_STORE;
        end


    // This should come at the end, so that conditional execution works
    // correctly
    if ( instruction_valid )
        begin
        // default is to stay in execute state, or to move into this
        // state from a conditional execute state
        control_state_nxt = EXECUTE;

        if ( current_write_pc )
             control_state_nxt = PC_STALL1;

        if ( load_op && instruction[15:12]  == 4'd15 )  // load new PC value
             control_state_nxt = MEM_WAIT1;

        // ldm rx, {pc}
        if ( type == MTRANS && instruction[20] && mtrans_reg1 == 4'd15 ) // Write to PC
             control_state_nxt = MEM_WAIT1;

        if ( type == MTRANS && !conflict && mtrans_num_registers != 5'd0 && mtrans_num_registers != 5'd1 )
            control_state_nxt = MTRANS_EXEC1;

        if ( type == MULT && !conflict )
                control_state_nxt = MULT_PROC1;

        if ( type == SWAP && !conflict )
                control_state_nxt = SWAP_WRITE;

        if ( type == CORTRANS && !und_request && !conflict )
                control_state_nxt = COPRO_WAIT;

         // interrupt overrides everything else so its last
        if ( interrupt && !conflict )
                control_state_nxt = INT_WAIT1;
        end

    end


// ========================================================
// Register Update
// ========================================================
always @ ( posedge i_clk )
    if ( !i_core_stall )
        begin
        if (!conflict)
            begin
            fetch_instruction_r         <= i_fetch_instruction;
            fetch_instruction_type_r    <= instruction_type(i_fetch_instruction);
            fetch_address_r             <= i_execute_iaddress;
            iabt_reg                    <= i_iabt;
            adex_reg                    <= i_adex;
            abt_status_reg              <= i_abt_status;
            end

        status_bits_mode_r          <= status_bits_mode_nxt;
        status_bits_irq_mask_r      <= status_bits_irq_mask_nxt;
        status_bits_firq_mask_r     <= status_bits_firq_mask_nxt;
        o_imm32                     <= imm32_nxt;
        o_imm_shift_amount          <= imm_shift_amount_nxt;
        o_shift_imm_zero            <= shift_imm_zero_nxt;

                                        // when have an interrupt, execute the interrupt operation
                                        // unconditionally in the execute stage
                                        // ensures that status_bits register gets updated correctly
                                        // Likewise when in middle of multi-cycle instructions
                                        // execute them unconditionally
        condition_r                 <= instruction_valid && !interrupt ? condition_nxt : AL;
        o_decode_exclusive          <= decode_exclusive_nxt;
        decode_iaccess_r            <= decode_iaccess_nxt;
        o_decode_daccess            <= decode_daccess_nxt;

        o_rm_sel                    <= rm_sel_nxt;
        o_rs_sel                    <= rs_sel_nxt;
        o_load_rd                   <= load_rd_nxt;
        load_rd_d1                  <= load_rd_d1_nxt;
        load_pc_r                   <= load_pc_nxt;
        o_rn_sel                    <= rn_sel_nxt;
        o_barrel_shift_amount_sel   <= barrel_shift_amount_sel_nxt;
        o_barrel_shift_data_sel     <= barrel_shift_data_sel_nxt;
        o_barrel_shift_function     <= barrel_shift_function_nxt;
        o_alu_function              <= alu_function_nxt;
        o_use_carry_in              <= use_carry_in_nxt;
        o_multiply_function         <= multiply_function_nxt;
        o_interrupt_vector_sel      <= next_interrupt;
        iaddress_sel_r              <= iaddress_sel_nxt;
        daddress_sel_r              <= daddress_sel_nxt;
        pc_sel_r                    <= pc_sel_nxt;
        o_byte_enable_sel           <= byte_enable_sel_nxt;
        o_status_bits_sel           <= status_bits_sel_nxt;
        o_reg_write_sel             <= reg_write_sel_nxt;
        o_firq_not_user_mode        <= firq_not_user_mode_nxt;
        o_write_data_wen            <= write_data_wen_nxt;
        o_base_address_wen          <= base_address_wen_nxt;
        pc_wen_r                    <= pc_wen_nxt;
        o_reg_bank_wen              <= reg_bank_wen_nxt;
        o_status_bits_flags_wen     <= status_bits_flags_wen_nxt;
        o_status_bits_mode_wen      <= status_bits_mode_wen_nxt;
        o_status_bits_irq_mask_wen  <= status_bits_irq_mask_wen_nxt;
        o_status_bits_firq_mask_wen <= status_bits_firq_mask_wen_nxt;

        o_copro_opcode1             <= instruction[23:21];
        o_copro_opcode2             <= instruction[7:5];
        o_copro_crn                 <= instruction[19:16];
        o_copro_crm                 <= instruction[3:0];
        o_copro_num                 <= instruction[11:8];
        o_copro_operation           <= copro_operation_nxt;
        o_copro_write_data_wen      <= copro_write_data_wen_nxt;
        restore_base_address        <= restore_base_address_nxt;
        control_state               <= control_state_nxt;
        end



always @ ( posedge i_clk )
    if ( !i_core_stall )
        begin
        // sometimes this is a pre-fetch instruction
        // e.g. two ldr instructions in a row. The second ldr will be saved
        // to the pre-fetch instruction register
        // then when its decoded, a copy is saved to the saved_current_instruction
        // register
        if      ( type == MTRANS )
            begin
            saved_current_instruction              <= mtrans_instruction_nxt;
            saved_current_instruction_type         <= type;
            saved_current_instruction_iabt         <= instruction_iabt;
            saved_current_instruction_adex         <= instruction_adex;
            saved_current_instruction_address      <= instruction_address;
            saved_current_instruction_iabt_status  <= instruction_iabt_status;
            end
        else if ( saved_current_instruction_wen )
            begin
            saved_current_instruction              <= instruction;
            saved_current_instruction_type         <= type;
            saved_current_instruction_iabt         <= instruction_iabt;
            saved_current_instruction_adex         <= instruction_adex;
            saved_current_instruction_address      <= instruction_address;
            saved_current_instruction_iabt_status  <= instruction_iabt_status;
            end

        if      ( pre_fetch_instruction_wen )
            begin
            pre_fetch_instruction                  <= fetch_instruction_r;
            pre_fetch_instruction_type             <= fetch_instruction_type_r;
            pre_fetch_instruction_iabt             <= iabt_reg;
            pre_fetch_instruction_adex             <= adex_reg;
            pre_fetch_instruction_address          <= fetch_address_r;
            pre_fetch_instruction_iabt_status      <= abt_status_reg;
            end


        // TODO possible to use saved_current_instruction instead and save some regs?
        hold_instruction              <= instruction;
        hold_instruction_type         <= type;
        hold_instruction_iabt         <= instruction_iabt;
        hold_instruction_adex         <= instruction_adex;
        hold_instruction_address      <= instruction_address;
        hold_instruction_iabt_status  <= instruction_iabt_status;
        end



always @ ( posedge i_clk )
    if ( !i_core_stall )
        begin
        irq   <= i_irq;
        firq  <= i_firq;

        if ( control_state == INT_WAIT1 && status_bits_mode_r == SVC )
            begin
            dabt_reg  <= 1'd0;
            end
        else
            begin
            dabt_reg  <= dabt_reg || i_dabt;
            end

        dabt_reg_d1  <= dabt_reg;
        end

assign dabt = dabt_reg || i_dabt;


// ========================================================
// Decompiler for debugging core - not synthesizable
// ========================================================
//synopsys translate_off

`include "debug_functions.vh"

a25_decompile  u_decompile (
    .i_clk                      ( i_clk                            ),
    .i_core_stall               ( i_core_stall                     ),
    .i_instruction              ( instruction                      ),
    .i_instruction_valid        ( instruction_valid &&!conflict    ),
    .i_instruction_execute      ( instruction_execute              ),
    .i_instruction_address      ( instruction_address              ),
    .i_interrupt                ( {3{interrupt}} & next_interrupt  ),
    .i_interrupt_state          ( control_state == INT_WAIT2       ),
    .i_instruction_undefined    ( und_request                      ),
    .i_pc_sel                   ( pc_sel_r                         ),
    .i_pc_wen                   ( pc_wen_r                         ));


wire    [(15*8)-1:0]    xCONTROL_STATE;
wire    [(15*8)-1:0]    xMODE;
wire    [( 8*8)-1:0]    xTYPE;

assign xCONTROL_STATE        =
                               control_state == RST_WAIT1      ? "RST_WAIT1"      :
                               control_state == RST_WAIT2      ? "RST_WAIT2"      :


                               control_state == INT_WAIT1      ? "INT_WAIT1"      :
                               control_state == INT_WAIT2      ? "INT_WAIT2"      :
                               control_state == EXECUTE        ? "EXECUTE"        :
                               control_state == PRE_FETCH_EXEC ? "PRE_FETCH_EXEC" :
                               control_state == MEM_WAIT1      ? "MEM_WAIT1"      :
                               control_state == MEM_WAIT2      ? "MEM_WAIT2"      :
                               control_state == PC_STALL1      ? "PC_STALL1"      :
                               control_state == PC_STALL2      ? "PC_STALL2"      :
                               control_state == MTRANS_EXEC1   ? "MTRANS_EXEC1"   :
                               control_state == MTRANS_EXEC2   ? "MTRANS_EXEC2"   :
                               control_state == MTRANS_ABORT   ? "MTRANS_ABORT"   :
                               control_state == MULT_PROC1     ? "MULT_PROC1"     :
                               control_state == MULT_PROC2     ? "MULT_PROC2"     :
                               control_state == MULT_STORE     ? "MULT_STORE"     :
                               control_state == MULT_ACCUMU    ? "MULT_ACCUMU"    :
                               control_state == SWAP_WRITE     ? "SWAP_WRITE"     :
                               control_state == SWAP_WAIT1     ? "SWAP_WAIT1"     :
                               control_state == SWAP_WAIT2     ? "SWAP_WAIT2"     :
                               control_state == COPRO_WAIT     ? "COPRO_WAIT"     :
                                                                 "UNKNOWN "       ;

assign xMODE  = mode_name ( status_bits_mode_r );

assign xTYPE  =
                               type == REGOP    ? "REGOP"    :
                               type == MULT     ? "MULT"     :
                               type == SWAP     ? "SWAP"     :
                               type == TRANS    ? "TRANS"    :
                               type == MTRANS   ? "MTRANS"   :
                               type == BRANCH   ? "BRANCH"   :
                               type == CODTRANS ? "CODTRANS" :
                               type == COREGOP  ? "COREGOP"  :
                               type == CORTRANS ? "CORTRANS" :
                               type == SWI      ? "SWI"      :
                                                  "UNKNOWN"  ;


always @( posedge i_clk )
    if (control_state == EXECUTE && ((instruction[0] === 1'bx) || (instruction[31] === 1'bx)))
        begin
        `TB_ERROR_MESSAGE
        $display("Instruction with x's =%08h", instruction);
        end
//synopsys translate_on

endmodule


