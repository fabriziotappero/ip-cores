//////////////////////////////////////////////////////////////////
//                                                              //
//  Decode stage of Amber 2 Core                                //
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
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
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

module a23_decode
(
input                       i_clk,
input       [31:0]          i_read_data,
input                       i_fetch_stall,                  // stall all stages of the cpu at the same time
input                       i_irq,                          // interrupt request
input                       i_firq,                         // Fast interrupt request
input                       i_dabt,                         // data abort interrupt request
input                       i_iabt,                         // instruction pre-fetch abort flag
input                       i_adex,                         // Address Exception
input       [31:0]          i_execute_address,              // Registered address output by execute stage
                                                            // 2 LSBs of read address used for calculating
                                                            // shift in LDRB ops
input       [7:0]           i_abt_status,                   // Abort status
input       [31:0]          i_execute_status_bits,          // current status bits values in execute stage
input                       i_multiply_done,                // multiply unit is nearly done


// --------------------------------------------------
// Control signals to execute stage
// --------------------------------------------------
output reg  [31:0]          o_read_data = 1'd0,
output reg  [4:0]           o_read_data_alignment = 1'd0,  // 2 LSBs of read address used for calculating shift in LDRB ops

output reg  [31:0]          o_imm32 = 'd0,
output reg  [4:0]           o_imm_shift_amount = 'd0,
output reg                  o_shift_imm_zero = 'd0,
output wire [3:0]           o_condition,
output reg                  o_exclusive_exec = 'd0,         // exclusive access request ( swap instruction )
output reg                  o_data_access_exec = 'd0,       // high means the memory access is a read
                                                            // read or write, low for instruction
output wire [1:0]           o_status_bits_mode,
output wire                 o_status_bits_irq_mask,
output wire                 o_status_bits_firq_mask,

output reg  [3:0]           o_rm_sel = 'd0,
output reg  [3:0]           o_rds_sel = 'd0,
output reg  [3:0]           o_rn_sel = 'd0,
output      [3:0]           o_rm_sel_nxt,
output      [3:0]           o_rds_sel_nxt,
output      [3:0]           o_rn_sel_nxt,
output reg  [1:0]           o_barrel_shift_amount_sel = 'd0,
output reg  [1:0]           o_barrel_shift_data_sel = 'd0,
output reg  [1:0]           o_barrel_shift_function = 'd0,
output reg  [8:0]           o_alu_function = 'd0,
output reg                  o_use_carry_in = 'd0,
output reg  [1:0]           o_multiply_function = 'd0,
output reg  [2:0]           o_interrupt_vector_sel = 'd0,
output wire [3:0]           o_address_sel,
output wire [1:0]           o_pc_sel,
output reg  [1:0]           o_byte_enable_sel = 'd0,        // byte, halfword or word write
output reg  [2:0]           o_status_bits_sel = 'd0,
output reg  [2:0]           o_reg_write_sel,
output reg                  o_user_mode_regs_load,
output reg                  o_user_mode_regs_store_nxt,
output reg                  o_firq_not_user_mode,

output reg                  o_write_data_wen = 'd0,
output reg                  o_base_address_wen = 'd0,       // save LDM base address register
                                                            // in case of data abort
output wire                 o_pc_wen,
output reg  [14:0]          o_reg_bank_wen = 'd0,
output reg  [3:0]           o_reg_bank_wsel = 'd0,
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
output      [7:0]           o_dabt_status


);

`include "a23_localparams.vh"
`include "a23_functions.vh"

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
                 MTRANS_EXEC3   = 5'd12,
                 MTRANS_EXEC3B  = 5'd13,
                 MTRANS_EXEC4   = 5'd14,
                 MTRANS5_ABORT  = 5'd15,
                 MULT_PROC1     = 5'd16,  // first cycle, save pre fetch instruction
                 MULT_PROC2     = 5'd17,  // do multiplication
                 MULT_STORE     = 5'd19,  // save RdLo
                 MULT_ACCUMU    = 5'd20,  // Accumulate add lower 32 bits
                 SWAP_WRITE     = 5'd22,
                 SWAP_WAIT1     = 5'd23,
                 SWAP_WAIT2     = 5'd24,
                 COPRO_WAIT     = 5'd25;


// ========================================================
// Internal signals
// ========================================================
wire    [31:0]         instruction;
wire                   instruction_iabt;        // abort flag, follows the instruction
wire                   instruction_adex;        // address exception flag, follows the instruction
wire    [31:0]         instruction_address;     // instruction virtual address, follows
                                                // the instruction
wire    [7:0]          instruction_iabt_status; // abort status, follows the instruction
wire    [1:0]          instruction_sel;
reg     [3:0]          itype;
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
wire                   immediate_shifter_operand;
wire                   rds_use_rs;
wire                   branch;
wire                   mem_op_pre_indexed;
wire                   mem_op_post_indexed;

// Flop inputs
wire    [31:0]         imm32_nxt;
wire    [4:0]          imm_shift_amount_nxt;
wire                   shift_imm_zero_nxt;
wire    [3:0]          condition_nxt;
reg                    exclusive_exec_nxt;
reg                    data_access_exec_nxt;
wire                   shift_extend;

reg     [1:0]          barrel_shift_function_nxt;
wire    [8:0]          alu_function_nxt;
reg                    use_carry_in_nxt;
reg     [1:0]          multiply_function_nxt;
reg     [1:0]          status_bits_mode_nxt;
reg                    status_bits_irq_mask_nxt;
reg                    status_bits_firq_mask_nxt;

reg     [1:0]          barrel_shift_amount_sel_nxt;
reg     [1:0]          barrel_shift_data_sel_nxt;
reg     [3:0]          address_sel_nxt;
reg     [1:0]          pc_sel_nxt;
reg     [1:0]          byte_enable_sel_nxt;
reg     [2:0]          status_bits_sel_nxt;
reg     [2:0]          reg_write_sel_nxt;
reg                    user_mode_regs_load_nxt;
wire                   firq_not_user_mode_nxt;

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
reg     [3:0]          reg_bank_wsel_nxt;
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
reg     [31:0]         abt_address_reg = 'd0;
reg     [7:0]          abt_status_reg = 'd0;
reg     [31:0]         saved_current_instruction = 'd0;
reg                    saved_current_instruction_iabt = 'd0;          // access abort flag
reg                    saved_current_instruction_adex = 'd0;          // address exception
reg     [31:0]         saved_current_instruction_address = 'd0;       // virtual address of abort instruction
reg     [7:0]          saved_current_instruction_iabt_status = 'd0;   // status of abort instruction
reg     [31:0]         pre_fetch_instruction = 'd0;
reg                    pre_fetch_instruction_iabt = 'd0;              // access abort flag
reg                    pre_fetch_instruction_adex = 'd0;              // address exception
reg     [31:0]         pre_fetch_instruction_address = 'd0;           // virtual address of abort instruction
reg     [7:0]          pre_fetch_instruction_iabt_status = 'd0;       // status of abort instruction

wire                   instruction_valid;
wire                   instruction_execute;

reg     [3:0]          mtrans_reg;              // the current register being accessed as part of STM/LDM
reg     [3:0]          mtrans_reg_d1 = 'd0;     // delayed by 1 period
reg     [3:0]          mtrans_reg_d2 = 'd0;     // delayed by 2 periods
reg     [31:0]         mtrans_instruction_nxt;

wire   [31:0]          mtrans_base_reg_change;
wire   [4:0]           mtrans_num_registers;
wire                   use_saved_current_instruction;
wire                   use_pre_fetch_instruction;
wire                   interrupt;
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
reg                    mtrans_r15 = 'd0;
reg                    mtrans_r15_nxt;
reg                    restore_base_address = 'd0;
reg                    restore_base_address_nxt;

wire                   regop_set_flags;


// ========================================================
// registers for output ports with non-zero initial values
// ========================================================
reg  [3:0]           condition_r = 4'he;             // 4'he = al
reg  [1:0]           status_bits_mode_r = 2'b11;     // SVC
reg                  status_bits_irq_mask_r = 1'd1;
reg                  status_bits_firq_mask_r = 1'd1;
reg  [3:0]           address_sel_r = 4'd2;
reg  [1:0]           pc_sel_r = 2'd2;
reg                  pc_wen_r = 1'd1;

assign o_condition              = condition_r;
assign o_status_bits_mode       = status_bits_mode_r;
assign o_status_bits_irq_mask   = status_bits_irq_mask_r;
assign o_status_bits_firq_mask  = status_bits_firq_mask_r;
assign o_address_sel            = address_sel_r;
assign o_pc_sel                 = pc_sel_r;
assign o_pc_wen                 = pc_wen_r;



// ========================================================
// Instruction Abort and Data Abort outputs
// ========================================================

assign o_iabt_trigger     = instruction_iabt && status_bits_mode_r == SVC && control_state == INT_WAIT1;
assign o_iabt_address     = instruction_address;
assign o_iabt_status      = instruction_iabt_status;

assign o_dabt_trigger     = dabt_reg && !dabt_reg_d1;
assign o_dabt_address     = abt_address_reg;
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
assign use_saved_current_instruction =  instruction_execute &&
                          ( control_state == MEM_WAIT1     ||
                            control_state == MEM_WAIT2     ||
                            control_state == MTRANS_EXEC1  ||
                            control_state == MTRANS_EXEC2  ||
                            control_state == MTRANS_EXEC3  ||
                            control_state == MTRANS_EXEC3B ||
                            control_state == MTRANS_EXEC4  ||
                            control_state == MTRANS5_ABORT ||
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

assign use_pre_fetch_instruction = control_state == PRE_FETCH_EXEC;


assign instruction_sel  =         use_saved_current_instruction  ? 2'd1 :  // saved_current_instruction
                                  use_pre_fetch_instruction      ? 2'd2 :  // pre_fetch_instruction
                                                                   2'd0 ;  // o_read_data

assign instruction      =         instruction_sel == 2'd0 ? o_read_data               :
                                  instruction_sel == 2'd1 ? saved_current_instruction :
                                                            pre_fetch_instruction     ;

// abort flag
assign instruction_iabt =         instruction_sel == 2'd0 ? iabt_reg                       :
                                  instruction_sel == 2'd1 ? saved_current_instruction_iabt :
                                                            pre_fetch_instruction_iabt     ;

assign instruction_address =      instruction_sel == 2'd0 ? abt_address_reg                   :
                                  instruction_sel == 2'd1 ? saved_current_instruction_address :
                                                            pre_fetch_instruction_address     ;

assign instruction_iabt_status =  instruction_sel == 2'd0 ? abt_status_reg                        :
                                  instruction_sel == 2'd1 ? saved_current_instruction_iabt_status :
                                                            pre_fetch_instruction_iabt_status     ;

// instruction address exception
assign instruction_adex =         instruction_sel == 2'd0 ? adex_reg                       :
                                  instruction_sel == 2'd1 ? saved_current_instruction_adex :
                                                            pre_fetch_instruction_adex     ;

// Instruction Decode - Order is important!
always @*
    casez ({instruction[27:20], instruction[7:4]})
        12'b00010?001001 : itype = SWAP;
        12'b000000??1001 : itype = MULT;
        12'b00?????????? : itype = REGOP;
        12'b01?????????? : itype = TRANS;
        12'b100????????? : itype = MTRANS;
        12'b101????????? : itype = BRANCH;
        12'b110????????? : itype = CODTRANS;
        12'b1110???????0 : itype = COREGOP;
        12'b1110???????1 : itype = CORTRANS;
        default:           itype = SWI;
    endcase


// ========================================================
// Fixed fields within the instruction
// ========================================================

assign opcode        = instruction[24:21];
assign condition_nxt = instruction[31:28];

assign o_rm_sel_nxt    = instruction[3:0];

assign o_rn_sel_nxt    = branch  ? 4'd15              : // Use PC to calculate branch destination
                                   instruction[19:16] ;

assign o_rds_sel_nxt   = control_state == SWAP_WRITE  ? instruction[3:0]   : // Rm gets written out to memory
                         itype == MTRANS              ? mtrans_reg         :
                         branch                       ? 4'd15              : // Update the PC
                         rds_use_rs                   ? instruction[11:8]  :
                                                        instruction[15:12] ;


assign shift_imm     = instruction[11:7];

// this is used for RRX
assign shift_extend  = !instruction[25] && !instruction[4] && !(|instruction[11:7]) && instruction[6:5] == 2'b11;

assign offset12      = { 20'h0, instruction[11:0]};
assign offset24      = {{6{instruction[23]}}, instruction[23:0], 2'd0 }; // sign extend
assign imm8          = instruction[7:0];

assign immediate_shifter_operand = instruction[25];
assign rds_use_rs                = (itype == REGOP && !instruction[25] && instruction[4]) ||
                                   (itype == MULT &&
                                    (control_state == MULT_PROC1  ||
                                     control_state == MULT_PROC2  ||
                                     instruction_valid && !interrupt )) ;
assign branch                    = itype == BRANCH;
assign opcode_compare =
            opcode == CMP ||
            opcode == CMN ||
            opcode == TEQ ||
            opcode == TST ;


assign mem_op               = itype == TRANS;
assign load_op              = mem_op && instruction[20];
assign store_op             = mem_op && !instruction[20];
assign write_pc             = pc_wen_nxt && pc_sel_nxt != 2'd0;
assign regop_set_flags      = itype == REGOP && instruction[20];

assign mem_op_pre_indexed   =  instruction[24] && instruction[21];
assign mem_op_post_indexed  = !instruction[24];

assign imm32_nxt            =  // add 0 to Rm
                               itype == MULT               ? {  32'd0                      } :

                               // 4 x number of registers
                               itype == MTRANS             ? {  mtrans_base_reg_change     } :
                               itype == BRANCH             ? {  offset24                   } :
                               itype == TRANS              ? {  offset12                   } :
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
// MTRANS Operations
// ========================================================

   // Bit 15 = r15
   // Bit 0  = R0
   // In LDM and STM instructions R0 is loaded or stored first
always @*
    casez (instruction[15:0])
    16'b???????????????1 : mtrans_reg = 4'h0 ;
    16'b??????????????10 : mtrans_reg = 4'h1 ;
    16'b?????????????100 : mtrans_reg = 4'h2 ;
    16'b????????????1000 : mtrans_reg = 4'h3 ;
    16'b???????????10000 : mtrans_reg = 4'h4 ;
    16'b??????????100000 : mtrans_reg = 4'h5 ;
    16'b?????????1000000 : mtrans_reg = 4'h6 ;
    16'b????????10000000 : mtrans_reg = 4'h7 ;
    16'b???????100000000 : mtrans_reg = 4'h8 ;
    16'b??????1000000000 : mtrans_reg = 4'h9 ;
    16'b?????10000000000 : mtrans_reg = 4'ha ;
    16'b????100000000000 : mtrans_reg = 4'hb ;
    16'b???1000000000000 : mtrans_reg = 4'hc ;
    16'b??10000000000000 : mtrans_reg = 4'hd ;
    16'b?100000000000000 : mtrans_reg = 4'he ;
    default              : mtrans_reg = 4'hf ;
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
assign swi_request  = itype == SWI;
assign dabt_request = dabt_reg;

// copro15 and copro13 only supports reg trans opcodes
// all other opcodes involving co-processors cause an
// undefined instrution interrupt
assign und_request  =   itype == CODTRANS ||
                        itype == COREGOP  ||
                      ( itype == CORTRANS && instruction[11:8] != 4'd15 );


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
                        next_interrupt != 3'd6 ;   // undefined interrupt


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
    exclusive_exec_nxt              = 1'd0;
    data_access_exec_nxt            = 1'd0;
    copro_operation_nxt             = 'd0;

    // Save an instruction to use later
    saved_current_instruction_wen   = 1'd0;
    pre_fetch_instruction_wen       = 1'd0;
    mtrans_r15_nxt                  = mtrans_r15;
    restore_base_address_nxt        = restore_base_address;

    // default Mux Select values
    barrel_shift_amount_sel_nxt     = 'd0;  // don't shift the input
    barrel_shift_data_sel_nxt       = 'd0;  // immediate value
    barrel_shift_function_nxt       = 'd0;
    use_carry_in_nxt                = 'd0;
    multiply_function_nxt           = 'd0;
    address_sel_nxt                 = 'd0;
    pc_sel_nxt                      = 'd0;
    byte_enable_sel_nxt             = 'd0;
    status_bits_sel_nxt             = 'd0;
    reg_write_sel_nxt               = 'd0;
    user_mode_regs_load_nxt         = 'd0;
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
    reg_bank_wsel_nxt               = 'hF;  // Don't select any
    status_bits_flags_wen_nxt       = 'd0;
    status_bits_mode_wen_nxt        = 'd0;
    status_bits_irq_mask_wen_nxt    = 'd0;
    status_bits_firq_mask_wen_nxt   = 'd0;

    if ( instruction_valid && !interrupt )
        begin
        if ( itype == REGOP )
            begin
            if ( !opcode_compare )
                begin
                // Check is the load destination is the PC
                if (instruction[15:12]  == 4'd15)
                    begin
                    pc_sel_nxt      = 2'd1; // alu_out
                    address_sel_nxt = 4'd1; // alu_out
                    end
                else
                    reg_bank_wsel_nxt = instruction[15:12];
                end

            if ( !immediate_shifter_operand )
                barrel_shift_function_nxt  = instruction[6:5];

            if ( !immediate_shifter_operand )
                barrel_shift_data_sel_nxt = 2'd2; // Shift value from Rm register

            if ( !immediate_shifter_operand && instruction[4] )
                barrel_shift_amount_sel_nxt = 2'd1; // Shift amount from Rs registter

            if ( !immediate_shifter_operand && !instruction[4] )
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
                alu_out_sel_nxt  = 4'd6; // XOR
                alu_cout_sel_nxt = 1'd1; // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
                end

            if ( opcode == ORR )
                begin
                alu_out_sel_nxt  = 4'd7; // OR
                alu_cout_sel_nxt = 1'd1; // i_barrel_shift_carry
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
                alu_cout_sel_nxt = 1'd1; // i_barrel_shift_carry
                use_carry_in_nxt = 1'd1;
                end
            end

        // Load & Store instructions
        if ( mem_op )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value
            data_access_exec_nxt            = 1'd1; // indicate that its a data read or write,
                                                    // rather than an instruction fetch
            alu_out_sel_nxt                 = 4'd1; // Add

            if ( !instruction[23] )  // U: Subtract offset
                begin
                alu_cin_sel_nxt  = 2'd1; // cin = 1
                alu_not_sel_nxt  = 1'd1; // invert B
                end

            if ( store_op )
                begin
                write_data_wen_nxt = 1'd1;
                if ( itype == TRANS && instruction[22] )
                    byte_enable_sel_nxt = 2'd1;         // Save byte
                end

                // need to update the register holding the address ?
                // This is Rn bits [19:16]
            if ( mem_op_pre_indexed || mem_op_post_indexed )
                begin
                // Check is the load destination is the PC
                if ( o_rn_sel_nxt  == 4'd15 )
                    pc_sel_nxt = 2'd1;
                else
                    reg_bank_wsel_nxt = o_rn_sel_nxt;
                end

                // if post-indexed, then use Rn rather than ALU output, as address
            if ( mem_op_post_indexed )
               address_sel_nxt = 4'd4; // Rn
            else
               address_sel_nxt = 4'd1; // alu out

            if ( instruction[25] && itype ==  TRANS )
                barrel_shift_data_sel_nxt = 2'd2; // Shift value from Rm register

            if ( itype == TRANS && instruction[25] && shift_imm != 5'd0 )
                begin
                barrel_shift_function_nxt   = instruction[6:5];
                barrel_shift_amount_sel_nxt = 2'd2; // imm_shift_amount
                end
            end

        if ( itype == BRANCH )
            begin
            pc_sel_nxt      = 2'd1; // alu_out
            address_sel_nxt = 4'd1; // alu_out
            alu_out_sel_nxt = 4'd1; // Add

            if ( instruction[24] ) // Link
                begin
                reg_bank_wsel_nxt  = 4'd14;  // Save PC to LR
                reg_write_sel_nxt = 3'd1;            // pc - 32'd4
                end
            end

        if ( itype == MTRANS )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value
            data_access_exec_nxt            = 1'd1; // indicate that its a data read or write,
                                                    // rather than an instruction fetch
            alu_out_sel_nxt                 = 4'd1; // Add
            mtrans_r15_nxt                  = instruction[15];  // load or save r15 ?
            base_address_wen_nxt            = 1'd1; // Save the value of the register used for the base address,
                                                    // in case of a data abort, and need to restore the value

            // The spec says -
            // If the instruction would have overwritten the base with data
            // (that is, it has the base in the transfer list), the overwriting is prevented.
            // This is true even when the abort occurs after the base word gets loaded
            restore_base_address_nxt        = instruction[20] &&
                                                (instruction[15:0] & (1'd1 << instruction[19:16]));

            // Increment or Decrement
            if ( instruction[23] ) // increment
                begin
                if ( instruction[24] )    // increment before
                    address_sel_nxt = 4'd7; // Rn + 4
                else
                    address_sel_nxt = 4'd4; // Rn
                end
            else // decrement
                begin
                alu_cin_sel_nxt  = 2'd1; // cin = 1
                alu_not_sel_nxt  = 1'd1; // invert B
                if ( !instruction[24] )    // decrement after
                    address_sel_nxt  = 4'd6; // alu out + 4
                else
                    address_sel_nxt  = 4'd1; // alu out
                end

            // Load or store ?
            if ( !instruction[20] )  // Store
                write_data_wen_nxt = 1'd1;

            // LDM: load into user mode registers, when in priviledged mode
            // Don't use mtrans_r15 here because its not loaded yet
            //if ( {instruction[22],instruction[20],instruction[15]} == 3'b110 )
            if ( {instruction[22:20],instruction[15]} == 4'b1010 )
                user_mode_regs_load_nxt = 1'd1;

            // SDM: store the user mode registers, when in priviledged mode
            //if ( {instruction[22],instruction[20]} == 3'b10 )
            if ( {instruction[22:20]} == 3'b100 )
                o_user_mode_regs_store_nxt = 1'd1;

            // update the base register ?
            if ( instruction[21] )  // the W bit
                reg_bank_wsel_nxt  = o_rn_sel_nxt;
            end


        if ( itype == MULT )
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
        if ( itype == SWAP )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value
            data_access_exec_nxt            = 1'd1; // indicate that its a data read or write,
                                                    // rather than an instruction fetch
            barrel_shift_data_sel_nxt       = 2'd2; // Shift value from Rm register
            address_sel_nxt                 = 4'd4; // Rn
            exclusive_exec_nxt              = 1'd1; // signal an exclusive access
            end


        // mcr & mrc - takes two cycles
        if ( itype == CORTRANS && !und_request )
            begin
            saved_current_instruction_wen   = 1'd1; // Save the memory access instruction to refer back to later
            pc_wen_nxt                      = 1'd0; // hold current PC value
            address_sel_nxt                 = 4'd3; // pc  (not pc + 4)

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


        if ( itype == SWI || und_request )
            begin
            // save address of next instruction to Supervisor Mode LR
            reg_write_sel_nxt               = 3'd1;            // pc -4
            reg_bank_wsel_nxt               = 4'd14;  // LR

            address_sel_nxt                 = 4'd2;            // interrupt_vector
            pc_sel_nxt                      = 2'd2;            // interrupt_vector

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

        reg_bank_wsel_nxt               = 4'd14;           // LR

        address_sel_nxt                 = 4'd2;            // interrupt_vector
        pc_sel_nxt                      = 2'd2;            // interrupt_vector

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


    // previous instruction was either ldr or sdr
    // if it is currently executing in the execute stage do the following
    if ( control_state == MEM_WAIT1 )
        begin
        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pre_fetch_instruction_wen   = 1'd1;

        if ( instruction_execute ) // conditional execution state
            begin
            address_sel_nxt             = 4'd3; // pc  (not pc + 4)
            pc_wen_nxt                  = 1'd0; // hold current PC value
            end
        end


    // completion of load operation
    if ( control_state == MEM_WAIT2 && load_op )
        begin
        barrel_shift_data_sel_nxt   = 2'd1;  // load word from memory
        barrel_shift_amount_sel_nxt = 2'd3;  // shift by address[1:0] x 8

        // shift needed
        if ( i_execute_address[1:0] != 2'd0 )
            barrel_shift_function_nxt = ROR;

        // load a byte
        if ( itype == TRANS && instruction[22] )
            alu_out_sel_nxt             = 4'd3;  // zero_extend8

        if ( !dabt )  // dont load data there is an abort on the data read
            begin
            // Check if the load destination is the PC
            if (instruction[15:12]  == 4'd15)
                begin
                pc_sel_nxt      = 2'd1; // alu_out
                address_sel_nxt = 4'd1; // alu_out
                end
            else
                reg_bank_wsel_nxt = instruction[15:12];
            end
        end


    // second cycle of multiple load or store
    if ( control_state == MTRANS_EXEC1 )
        begin
        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pre_fetch_instruction_wen   = 1'd1;

        if ( instruction_execute ) // conditional execution state
            begin
            address_sel_nxt             = 4'd5;  // o_address
            pc_wen_nxt                  = 1'd0;  // hold current PC value
            data_access_exec_nxt        = 1'd1;  // indicate that its a data read or write,
                                                 // rather than an instruction fetch

            if ( !instruction[20] ) // Store
                write_data_wen_nxt = 1'd1;

            // LDM: load into user mode registers, when in priviledged mode
            //if ( {instruction[22],instruction[20],mtrans_r15} == 3'b110 )
            if ( {instruction[22:20],mtrans_r15} == 4'b1010 )
                user_mode_regs_load_nxt = 1'd1;

            // SDM: store the user mode registers, when in priviledged mode
            //if ( {instruction[22],instruction[20]} == 2'b10 )
            if ( {instruction[22:20]} == 3'b100 )
                o_user_mode_regs_store_nxt = 1'd1;
            end
        end


        // third cycle of multiple load or store
    if ( control_state == MTRANS_EXEC2 )
        begin
        address_sel_nxt             = 4'd5;  // o_address
        pc_wen_nxt                  = 1'd0;  // hold current PC value
        data_access_exec_nxt        = 1'd1;  // indicate that its a data read or write,
                                             // rather than an instruction fetch
        barrel_shift_data_sel_nxt   = 2'd1;  // load word from memory

        // Load or Store
        if ( instruction[20] ) // Load
            begin
            // Can never be loading the PC in this state, as the PC is always
            // the last register in the set to be loaded
            if ( !dabt )
                reg_bank_wsel_nxt = mtrans_reg_d2;
            end
        else // Store
            write_data_wen_nxt = 1'd1;

        // LDM: load into user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20],mtrans_r15} == 3'b110 )
            user_mode_regs_load_nxt = 1'd1;

        // SDM: store the user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20]} == 2'b10 )
            o_user_mode_regs_store_nxt = 1'd1;
        end


        // second or fourth cycle of multiple load or store
    if ( control_state == MTRANS_EXEC3 && instruction_execute )
        begin
        address_sel_nxt             = 4'd3; // pc  (not pc + 4)
        pc_wen_nxt                  = 1'd0;  // hold current PC value
        barrel_shift_data_sel_nxt   = 2'd1;  // load word from memory

        // Can never be loading the PC in this state, as the PC is always
        // the last register in the set to be loaded
        if ( instruction[20] && !dabt ) // Load
            reg_bank_wsel_nxt = mtrans_reg_d2;

        // LDM: load into user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20],mtrans_r15} == 3'b110 )
            user_mode_regs_load_nxt = 1'd1;

        // SDM: store the user mode registers, when in priviledged mode
        //if ( {instruction[22:20]} == 3'b100 )
        if ( {instruction[22],instruction[20]} == 2'b10 )
            o_user_mode_regs_store_nxt = 1'd1;
       end

    // state is used for LMD/STM of a single register
    if ( control_state == MTRANS_EXEC3B && instruction_execute )
        begin
        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pre_fetch_instruction_wen   = 1'd1;

        address_sel_nxt             = 4'd3;  // pc  (not pc + 4)
        pc_wen_nxt                  = 1'd0;  // hold current PC value

        // LDM: load into user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20],mtrans_r15} == 3'b110 )
            user_mode_regs_load_nxt = 1'd1;

        // SDM: store the user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20]} == 2'b10 )
            o_user_mode_regs_store_nxt = 1'd1;
        end

    if ( control_state == MTRANS_EXEC4 )
        begin
        barrel_shift_data_sel_nxt   = 2'd1;  // load word from memory

        if ( instruction[20] ) // Load
            begin
            if (!dabt) // dont overwrite registers or status if theres a data abort
                begin
                if ( mtrans_reg_d2 == 4'd15 ) // load new value into PC
                    begin
                    address_sel_nxt = 4'd1; // alu_out - read instructions using new PC value
                    pc_sel_nxt      = 2'd1; // alu_out
                    pc_wen_nxt      = 1'd1; // write PC

                    // ldm with S bit and pc: the Status bits are updated
                    // Node this must be done only at the end
                    // so the register set is the set in the mode before it
                    // gets changed.
                    if ( instruction[22] )
                         begin
                         status_bits_sel_nxt           = 3'd1; // alu out
                         status_bits_flags_wen_nxt     = 1'd1;

                         // Can't change the mode or mask bits in User mode
                         if ( i_execute_status_bits[1:0] != USR )
                            begin
                            status_bits_mode_wen_nxt      = 1'd1;
                            status_bits_irq_mask_wen_nxt  = 1'd1;
                            status_bits_firq_mask_wen_nxt = 1'd1;
                            end
                         end
                    end
                else
                    begin
                    reg_bank_wsel_nxt = mtrans_reg_d2;
                    end
                end
            end

           // we have a data abort interrupt
        if ( dabt )
            begin
            pc_wen_nxt = 1'd0;  // hold current PC value
            end

        // LDM: load into user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20],mtrans_r15} == 3'b110 )
            user_mode_regs_load_nxt = 1'd1;

        // SDM: store the user mode registers, when in priviledged mode
        if ( {instruction[22],instruction[20]} == 2'b10 )
            o_user_mode_regs_store_nxt = 1'd1;
        end


    // state is for when a data abort interrupt is triggered during an LDM
    if ( control_state == MTRANS5_ABORT )
        begin
        // Restore the Base Address, if the base register is included in the
        // list of registers being loaded
        if (restore_base_address) // LDM with base address in register list
            begin
            reg_write_sel_nxt = 3'd6;                        // write base_register
            reg_bank_wsel_nxt  = instruction[19:16];         // to Rn
            end
        end


        // Multiply or Multiply-Accumulate
    if ( control_state == MULT_PROC1 && instruction_execute )
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
        address_sel_nxt         = 4'd3;  // pc  (not pc + 4)
        multiply_function_nxt   = o_multiply_function;
        end


    // Save RdLo
    // always last cycle of all multiply or multiply accumulate operations
    if ( control_state == MULT_STORE )
        begin
        reg_write_sel_nxt     = 3'd2; // multiply_out
        multiply_function_nxt = o_multiply_function;

        if ( itype == MULT ) // 32-bit
            reg_bank_wsel_nxt      = instruction[19:16]; // Rd
        else  // 64-bit / Long
            reg_bank_wsel_nxt      = instruction[15:12]; // RdLo

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
        address_sel_nxt       = 4'd3;  // pc  (not pc + 4)
        end

    // swp - do write request in 2nd cycle
    if ( control_state == SWAP_WRITE && instruction_execute )
        begin
        barrel_shift_data_sel_nxt       = 2'd2; // Shift value from Rm register
        address_sel_nxt                 = 4'd4; // Rn
        write_data_wen_nxt              = 1'd1;
        data_access_exec_nxt            = 1'd1; // indicate that its a data read or write,
                                                // rather than an instruction fetch

        if ( instruction[22] )
            byte_enable_sel_nxt = 2'd1;         // Save byte

        if ( instruction_execute )                         // conditional execution state
            pc_wen_nxt                  = 1'd0; // hold current PC value

        // Save the next instruction to execute later
        // Do this even if this instruction does not execute because of Condition
        pre_fetch_instruction_wen   = 1'd1;

        end


    // swp - receive read response in 3rd cycle
    if ( control_state == SWAP_WAIT1 )
        begin
        barrel_shift_data_sel_nxt   = 2'd1;  // load word from memory
        barrel_shift_amount_sel_nxt = 2'd3;  // shift by address[1:0] x 8

        // shift needed
        if ( i_execute_address[1:0] != 2'd0 )
            barrel_shift_function_nxt = ROR;

        if ( instruction_execute ) // conditional execution state
            begin
            address_sel_nxt             = 4'd3; // pc  (not pc + 4)
            pc_wen_nxt                  = 1'd0; // hold current PC value
            end

        // load a byte
        if ( instruction[22] )
            alu_out_sel_nxt = 4'd3;  // zero_extend8

        if ( !dabt )
            begin
            // Check is the load destination is the PC
            if ( instruction[15:12]  == 4'd15 )
                begin
                pc_sel_nxt      = 2'd1; // alu_out
                address_sel_nxt = 4'd1; // alu_out
                end
            else
                reg_bank_wsel_nxt = instruction[15:12];
            end
        end

    // 1 cycle delay for Co-Processor Register access
    if ( control_state == COPRO_WAIT && instruction_execute )
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
                reg_bank_wsel_nxt = instruction[15:12];

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


// Speed up the long path from u_decode/o_read_data to u_register_bank/r8_firq
// This pre-encodes the firq_s3 signal thats used in u_register_bank
assign firq_not_user_mode_nxt = !user_mode_regs_load_nxt && status_bits_mode_nxt == FIRQ;


// ========================================================
// Next State Logic
// ========================================================

// this replicates the current value of the execute signal in the execute stage
assign instruction_execute = conditional_execute ( condition_r, i_execute_status_bits[31:28] );

assign instruction_valid = (control_state == EXECUTE || control_state == PRE_FETCH_EXEC) ||
                     // when last instruction was multi-cycle instruction but did not execute
                     // because condition was false then act like you're in the execute state
                    (!instruction_execute && (control_state == PC_STALL1    ||
                                              control_state == MEM_WAIT1    ||
                                              control_state == COPRO_WAIT   ||
                                              control_state == SWAP_WRITE   ||
                                              control_state == MULT_PROC1   ||
                                              control_state == MTRANS_EXEC1 ||
                                              control_state == MTRANS_EXEC3 ||
                                              control_state == MTRANS_EXEC3B  ) );


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
    if ( control_state == MTRANS5_ABORT ) control_state_nxt = PRE_FETCH_EXEC;

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
        if (mtrans_instruction_nxt[15:0] != 16'd0)
            control_state_nxt = MTRANS_EXEC2;
        else   // if the register list holds a single register
            control_state_nxt = MTRANS_EXEC3;
        end

        // Stay in State MTRANS_EXEC2 until the full list of registers to
        // load or store has been processed
    if ( control_state == MTRANS_EXEC2 && mtrans_num_registers == 5'd1 )
        control_state_nxt = MTRANS_EXEC3;

    if ( control_state == MTRANS_EXEC3 )     control_state_nxt = MTRANS_EXEC4;

    if ( control_state == MTRANS_EXEC3B )    control_state_nxt = MTRANS_EXEC4;

    if ( control_state == MTRANS_EXEC4  )
        begin
        if ( dabt ) // data abort
            control_state_nxt = MTRANS5_ABORT;
        else if (write_pc) // writing to the PC!!
            control_state_nxt = PC_STALL1;
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

        if ( mem_op )  // load or store word or byte
             control_state_nxt = MEM_WAIT1;
        if ( write_pc )
             control_state_nxt = PC_STALL1;
        if ( itype == MTRANS )
            begin
            if ( mtrans_num_registers != 5'd0 )
                begin
                // check for LDM/STM of a single register
                if ( mtrans_num_registers == 5'd1 )
                    control_state_nxt = MTRANS_EXEC3B;
                else
                    control_state_nxt = MTRANS_EXEC1;
                end
            else
                control_state_nxt = MTRANS_EXEC3;
            end

        if ( itype == MULT )
                control_state_nxt = MULT_PROC1;

        if ( itype == SWAP )
                control_state_nxt = SWAP_WRITE;

        if ( itype == CORTRANS && !und_request )
                control_state_nxt = COPRO_WAIT;

         // interrupt overrides everything else so its last
        if ( interrupt )
                control_state_nxt = INT_WAIT1;
        end
    end


// ========================================================
// Register Update
// ========================================================
always @ ( posedge i_clk )
    if (!i_fetch_stall)
        begin
        o_read_data                 <= i_read_data;
        o_read_data_alignment       <= {i_execute_address[1:0], 3'd0};
        abt_address_reg             <= i_execute_address;
        iabt_reg                    <= i_iabt;
        adex_reg                    <= i_adex;
        abt_status_reg              <= i_abt_status;
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
        o_exclusive_exec            <= exclusive_exec_nxt;
        o_data_access_exec          <= data_access_exec_nxt;

        o_rm_sel                    <= o_rm_sel_nxt;
        o_rds_sel                   <= o_rds_sel_nxt;
        o_rn_sel                    <= o_rn_sel_nxt;
        o_barrel_shift_amount_sel   <= barrel_shift_amount_sel_nxt;
        o_barrel_shift_data_sel     <= barrel_shift_data_sel_nxt;
        o_barrel_shift_function     <= barrel_shift_function_nxt;
        o_alu_function              <= alu_function_nxt;
        o_use_carry_in              <= use_carry_in_nxt;
        o_multiply_function         <= multiply_function_nxt;
        o_interrupt_vector_sel      <= next_interrupt;
        address_sel_r               <= address_sel_nxt;
        pc_sel_r                    <= pc_sel_nxt;
        o_byte_enable_sel           <= byte_enable_sel_nxt;
        o_status_bits_sel           <= status_bits_sel_nxt;
        o_reg_write_sel             <= reg_write_sel_nxt;
        o_user_mode_regs_load       <= user_mode_regs_load_nxt;
        o_firq_not_user_mode        <= firq_not_user_mode_nxt;
        o_write_data_wen            <= write_data_wen_nxt;
        o_base_address_wen          <= base_address_wen_nxt;
        pc_wen_r                    <= pc_wen_nxt;
        o_reg_bank_wsel             <= reg_bank_wsel_nxt;
        o_reg_bank_wen              <= decode ( reg_bank_wsel_nxt );
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
        mtrans_r15                  <= mtrans_r15_nxt;
        restore_base_address        <= restore_base_address_nxt;
        control_state               <= control_state_nxt;
        mtrans_reg_d1               <= mtrans_reg;
        mtrans_reg_d2               <= mtrans_reg_d1;
        end



always @ ( posedge i_clk )
    if ( !i_fetch_stall )
        begin
        // sometimes this is a pre-fetch instruction
        // e.g. two ldr instructions in a row. The second ldr will be saved
        // to the pre-fetch instruction register
        // then when its decoded, a copy is saved to the saved_current_instruction
        // register
        if      (itype == MTRANS)
            begin
            saved_current_instruction              <= mtrans_instruction_nxt;
            saved_current_instruction_iabt         <= instruction_iabt;
            saved_current_instruction_adex         <= instruction_adex;
            saved_current_instruction_address      <= instruction_address;
            saved_current_instruction_iabt_status  <= instruction_iabt_status;
            end
        else if (saved_current_instruction_wen)
            begin
            saved_current_instruction              <= instruction;
            saved_current_instruction_iabt         <= instruction_iabt;
            saved_current_instruction_adex         <= instruction_adex;
            saved_current_instruction_address      <= instruction_address;
            saved_current_instruction_iabt_status  <= instruction_iabt_status;
            end

        if      (pre_fetch_instruction_wen)
            begin
            pre_fetch_instruction                  <= o_read_data;
            pre_fetch_instruction_iabt             <= iabt_reg;
            pre_fetch_instruction_adex             <= adex_reg;
            pre_fetch_instruction_address          <= abt_address_reg;
            pre_fetch_instruction_iabt_status      <= abt_status_reg;
            end
        end



always @ ( posedge i_clk )
    if ( !i_fetch_stall )
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

a23_decompile  u_decompile (
    .i_clk                      ( i_clk                            ),
    .i_fetch_stall              ( i_fetch_stall                    ),
    .i_instruction              ( instruction                      ),
    .i_instruction_valid        ( instruction_valid                ),
    .i_instruction_execute      ( instruction_execute              ),
    .i_instruction_address      ( instruction_address              ),
    .i_interrupt                ( {3{interrupt}} & next_interrupt  ),
    .i_interrupt_state          ( control_state == INT_WAIT2       ),
    .i_instruction_undefined    ( und_request                      ),
    .i_pc_sel                   ( pc_sel_r                         ),
    .i_pc_wen                   ( pc_wen_r                         ));



wire    [(15*8)-1:0]    xCONTROL_STATE;
wire    [(15*8)-1:0]    xMODE;

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
                               control_state == MTRANS_EXEC3   ? "MTRANS_EXEC3"   :
                               control_state == MTRANS_EXEC3B  ? "MTRANS_EXEC3B"  :
                               control_state == MTRANS_EXEC4   ? "MTRANS_EXEC4"   :
                               control_state == MTRANS5_ABORT  ? "MTRANS5_ABORT"  :
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

always @( posedge i_clk )
    if (control_state == EXECUTE && ((instruction[0] === 1'bx) || (instruction[31] === 1'bx)))
        begin
        `TB_ERROR_MESSAGE
        $display("Instruction with x's =%08h", instruction);
        end
//synopsys translate_on

endmodule


