//////////////////////////////////////////////////////////////////
//                                                              //
//  Execute stage of Amber 2 Core                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Executes instructions. Instantiates the register file, ALU  //
//  multiplication unit and barrel shifter. This stage is       //
//  relitively simple. All the complex stuff is done in the     //
//  decode stage.                                               //
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

`include "a23_config_defines.vh"

module a23_execute (

input                       i_clk,
input       [31:0]          i_read_data,
input       [4:0]           i_read_data_alignment,  // 2 LSBs of address in [4:3], appended 
                                                    // with 3 zeros
input       [31:0]          i_copro_read_data,      // From Co-Processor, to either Register 
                                                    // or Memory
input                       i_data_access_exec,     // from Instruction Decode stage
                                                    // high means the memory access is a read 
                                                    // read or write, low for instruction

output reg  [31:0]          o_copro_write_data = 'd0,
output reg  [31:0]          o_write_data = 'd0,
output wire [31:0]          o_address,
output reg                  o_adex = 'd0,           // Address Exception
output reg                  o_address_valid = 'd0,  // Prevents the reset address value being a 
                                                    // wishbone access
output      [31:0]          o_address_nxt,          // un-registered version of address to the 
                                                    // cache rams address ports
output reg                  o_priviledged = 'd0,    // Priviledged access
output reg                  o_exclusive = 'd0,      // swap access
output reg                  o_write_enable = 'd0,
output reg  [3:0]           o_byte_enable = 'd0,
output reg                  o_data_access = 'd0,    // To Fetch stage. high = data fetch, 
                                                    // low = instruction fetch
output      [31:0]          o_status_bits,          // Full PC will all status bits, but PC part zero'ed out
output                      o_multiply_done,


// --------------------------------------------------
// Control signals from Instruction Decode stage
// --------------------------------------------------
input                       i_fetch_stall,          // stall all stages of the cpu at the same time
input      [1:0]            i_status_bits_mode,
input                       i_status_bits_irq_mask,
input                       i_status_bits_firq_mask,
input      [31:0]           i_imm32,
input      [4:0]            i_imm_shift_amount,
input                       i_shift_imm_zero,
input      [3:0]            i_condition,
input                       i_exclusive_exec,       // swap access
input                       i_use_carry_in,         // e.g. add with carry instruction

input      [3:0]            i_rm_sel,
input      [3:0]            i_rds_sel,
input      [3:0]            i_rn_sel,
input      [3:0]            i_rm_sel_nxt,
input      [3:0]            i_rds_sel_nxt,
input      [3:0]            i_rn_sel_nxt,
input      [1:0]            i_barrel_shift_amount_sel,
input      [1:0]            i_barrel_shift_data_sel,
input      [1:0]            i_barrel_shift_function,
input      [8:0]            i_alu_function,
input      [1:0]            i_multiply_function,
input      [2:0]            i_interrupt_vector_sel,
input      [3:0]            i_address_sel,
input      [1:0]            i_pc_sel,
input      [1:0]            i_byte_enable_sel,
input      [2:0]            i_status_bits_sel,
input      [2:0]            i_reg_write_sel,
input                       i_user_mode_regs_load,
input                       i_user_mode_regs_store_nxt,
input                       i_firq_not_user_mode,

input                       i_write_data_wen,
input                       i_base_address_wen,     // save LDM base address register, 
                                                    // in case of data abort
input                       i_pc_wen,
input      [14:0]           i_reg_bank_wen,
input      [3:0]            i_reg_bank_wsel,
input                       i_status_bits_flags_wen,
input                       i_status_bits_mode_wen,
input                       i_status_bits_irq_mask_wen,
input                       i_status_bits_firq_mask_wen,
input                       i_copro_write_data_wen

);

`include "a23_localparams.vh"
`include "a23_functions.vh"

// ========================================================
// Internal signals
// ========================================================
wire [31:0]         write_data_nxt;
wire [3:0]          byte_enable_nxt;
wire [31:0]         pc_plus4;
wire [31:0]         pc_minus4;
wire [31:0]         address_plus4;
wire [31:0]         alu_plus4;
wire [31:0]         rn_plus4;
wire [31:0]         alu_out;
wire [3:0]          alu_flags;
wire [31:0]         rm;
wire [31:0]         rs;
wire [31:0]         rd;
wire [31:0]         rn;
wire [31:0]         pc;
wire [31:0]         pc_nxt;
wire                write_enable_nxt;
wire [31:0]         interrupt_vector;
wire [7:0]          shift_amount;
wire [31:0]         barrel_shift_in;
wire [31:0]         barrel_shift_out;
wire                barrel_shift_carry;
wire                barrel_shift_carry_alu;

wire [3:0]          status_bits_flags_nxt;
reg  [3:0]          status_bits_flags = 'd0;
wire [1:0]          status_bits_mode_nxt;
wire [1:0]          status_bits_mode_nr;
reg  [1:0]          status_bits_mode = SVC;
                    // raw rs select
wire [1:0]          status_bits_mode_rds_nxt;
wire [1:0]          status_bits_mode_rds_nr;
reg  [1:0]          status_bits_mode_rds;
                    // one-hot encoded rs select
wire [3:0]          status_bits_mode_rds_oh_nxt;
reg  [3:0]          status_bits_mode_rds_oh = 1'd1 << OH_SVC;
wire                status_bits_mode_rds_oh_update;
wire                status_bits_irq_mask_nxt;
reg                 status_bits_irq_mask = 1'd1;
wire                status_bits_firq_mask_nxt;
reg                 status_bits_firq_mask = 1'd1;

wire                execute;           // high when condition execution is true
wire [31:0]         reg_write_nxt;
wire                pc_wen;
wire [14:0]         reg_bank_wen;
wire [3:0]          reg_bank_wsel;
wire [31:0]         multiply_out;
wire [1:0]          multiply_flags;
reg  [31:0]         base_address = 'd0;    // Saves base address during LDM instruction in 
                                           // case of data abort

wire                priviledged_nxt;      
wire                priviledged_update;
wire                address_update;
wire                base_address_update;
wire                write_data_update;
wire                copro_write_data_update;
wire                byte_enable_update;
wire                data_access_update;
wire                write_enable_update;
wire                exclusive_update;
wire                status_bits_flags_update;
wire                status_bits_mode_update;
wire                status_bits_irq_mask_update;
wire                status_bits_firq_mask_update;
wire [1:0]          status_bits_out;

wire [31:0]         alu_out_pc_filtered;
wire                adex_nxt;

wire                carry_in;

reg  [31:0]         address_r = 32'hdead_dead;


// ========================================================
// Status Bits in PC register
// ========================================================
assign status_bits_out = (i_status_bits_mode_wen && i_status_bits_sel == 3'd1 && execute) ? 
                            alu_out[1:0] : status_bits_mode ;


assign o_status_bits = {   status_bits_flags,           // 31:28
                           status_bits_irq_mask,        // 7
                           status_bits_firq_mask,       // 6
                           24'd0,
                           status_bits_out};          // 1:0 = mode

// ========================================================
// Status Bits Select
// ========================================================
assign status_bits_flags_nxt     = i_status_bits_sel == 3'd0 ? alu_flags                           :
                                   i_status_bits_sel == 3'd1 ? alu_out          [31:28]            :
                                   i_status_bits_sel == 3'd3 ? i_copro_read_data[31:28]            :
                                   //  update flags after a multiply operation
                                   i_status_bits_sel == 3'd4 ? { multiply_flags, status_bits_flags[1:0] } :
                                   // regops that do not change the overflow flag
                                   i_status_bits_sel == 3'd5 ? { alu_flags[3:1], status_bits_flags[0] } :
                                                               4'b1111 ;

assign status_bits_mode_nxt      = i_status_bits_sel == 3'd0 ? i_status_bits_mode       :
                                   i_status_bits_sel == 3'd5 ? i_status_bits_mode       :
                                   i_status_bits_sel == 3'd1 ? alu_out            [1:0] :
                                                               i_copro_read_data  [1:0] ;


// Used for the Rds output of register_bank - this special version of
// status_bits_mode speeds up the critical path from status_bits_mode through the
// register_bank, barrel_shifter and alu. It moves a mux needed for the
// i_user_mode_regs_store_nxt signal back into the previous stage -
// so its really part of the decode stage even though the logic is right here
// In addition the signal is one-hot encoded to further speed up the logic
// Raw version is also kept for ram-based register bank implementation.

assign status_bits_mode_rds_nxt  = i_user_mode_regs_store_nxt ? USR                  :
                                   status_bits_mode_update    ? status_bits_mode_nxt :
                                                                status_bits_mode     ;

assign status_bits_mode_rds_oh_nxt    = oh_status_bits_mode(status_bits_mode_rds_nxt);


assign status_bits_irq_mask_nxt  = i_status_bits_sel == 3'd0 ? i_status_bits_irq_mask      :
                                   i_status_bits_sel == 3'd5 ? i_status_bits_irq_mask      :
                                   i_status_bits_sel == 3'd1 ? alu_out                [27] :
                                                               i_copro_read_data      [27] ;
                            
assign status_bits_firq_mask_nxt = i_status_bits_sel == 3'd0 ? i_status_bits_firq_mask     :
                                   i_status_bits_sel == 3'd5 ? i_status_bits_firq_mask     :
                                   i_status_bits_sel == 3'd1 ? alu_out                [26] :
                                                               i_copro_read_data      [26] ;



// ========================================================
// Adders
// ========================================================
assign pc_plus4      = pc        + 32'd4;
assign pc_minus4     = pc        - 32'd4;
assign address_plus4 = address_r + 32'd4;
assign alu_plus4     = alu_out   + 32'd4;
assign rn_plus4      = rn        + 32'd4;


// ========================================================
// Barrel Shift Amount Select
// ========================================================
// An immediate shift value of 0 is translated into 32
assign shift_amount = i_barrel_shift_amount_sel == 2'd0 ? 8'd0                           :
                      i_barrel_shift_amount_sel == 2'd1 ? rs[7:0]                        :
                      i_barrel_shift_amount_sel == 2'd2 ? {3'd0, i_imm_shift_amount    } :
                                                          {3'd0, i_read_data_alignment } ;

// ========================================================
// Barrel Shift Data Select
// ========================================================
assign barrel_shift_in = i_barrel_shift_data_sel == 2'd0 ? i_imm32       :
                         i_barrel_shift_data_sel == 2'd1 ? i_read_data   :
                                                           rm            ;
                            
// ========================================================
// Interrupt vector Select
// ========================================================

assign interrupt_vector = // Reset vector
                          (i_interrupt_vector_sel == 3'd0) ? 32'h00000000 :  
                          // Data abort interrupt vector                 
                          (i_interrupt_vector_sel == 3'd1) ? 32'h00000010 :
                          // Fast interrupt vector  
                          (i_interrupt_vector_sel == 3'd2) ? 32'h0000001c :
                          // Regular interrupt vector
                          (i_interrupt_vector_sel == 3'd3) ? 32'h00000018 :
                          // Prefetch abort interrupt vector
                          (i_interrupt_vector_sel == 3'd5) ? 32'h0000000c :
                          // Undefined instruction interrupt vector
                          (i_interrupt_vector_sel == 3'd6) ? 32'h00000004 :
                          // Software (SWI) interrupt vector
                          (i_interrupt_vector_sel == 3'd7) ? 32'h00000008 :
                          // Default is the address exception interrupt
                                                             32'h00000014 ;


// ========================================================
// Address Select
// ========================================================

// If rd is the pc, then seperate the address bits from the status bits for
// generating the next address to fetch
assign alu_out_pc_filtered = pc_wen && i_pc_sel == 2'd1 ? pcf(alu_out) : alu_out;

// if current instruction does not execute because it does not meet the condition
// then address advances to next instruction
assign o_address_nxt = (!execute)              ? pc_plus4              : 
                       (i_address_sel == 4'd0) ? pc_plus4              :
                       (i_address_sel == 4'd1) ? alu_out_pc_filtered   :
                       (i_address_sel == 4'd2) ? interrupt_vector      :
                       (i_address_sel == 4'd3) ? pc                    :
                       (i_address_sel == 4'd4) ? rn                    :
                       (i_address_sel == 4'd5) ? address_plus4         :  // MTRANS address incrementer
                       (i_address_sel == 4'd6) ? alu_plus4             :  // MTRANS decrement after
                                                 rn_plus4              ;  // MTRANS increment before

// Data accesses use 32-bit address space, but instruction
// accesses are restricted to 26 bit space
assign adex_nxt      = |o_address_nxt[31:26] && !i_data_access_exec;

// ========================================================
// Program Counter Select
// ========================================================
// If current instruction does not execute because it does not meet the condition
// then PC advances to next instruction
assign pc_nxt = (!execute)       ? pc_plus4              :
                i_pc_sel == 2'd0 ? pc_plus4              :
                i_pc_sel == 2'd1 ? alu_out               :
                                   interrupt_vector      ;


// ========================================================
// Register Write Select
// ========================================================
wire [31:0] save_int_pc;
wire [31:0] save_int_pc_m4;

assign save_int_pc    = { status_bits_flags, 
                          status_bits_irq_mask, 
                          status_bits_firq_mask, 
                          pc[25:2], 
                          status_bits_mode      };


assign save_int_pc_m4 = { status_bits_flags, 
                          status_bits_irq_mask, 
                          status_bits_firq_mask, 
                          pc_minus4[25:2], 
                          status_bits_mode      };


assign reg_write_nxt = i_reg_write_sel == 3'd0 ? alu_out               :
                       // save pc to lr on an interrupt                    
                       i_reg_write_sel == 3'd1 ? save_int_pc_m4        :
                       // to update Rd at the end of Multiplication
                       i_reg_write_sel == 3'd2 ? multiply_out          :
                       i_reg_write_sel == 3'd3 ? o_status_bits         :
                       i_reg_write_sel == 3'd5 ? i_copro_read_data     :  // mrc
                       i_reg_write_sel == 3'd6 ? base_address          :
                                                 save_int_pc           ;  


// ========================================================
// Byte Enable Select
// ========================================================
assign byte_enable_nxt = i_byte_enable_sel == 2'd0  ? 4'b1111 :  // word write
                         i_byte_enable_sel == 2'd2  ?            // halfword write
                         ( o_address_nxt[1] == 1'd0 ? 4'b0011 : 
                                                      4'b1100  ) :
                           
                         o_address_nxt[1:0] == 2'd0 ? 4'b0001 :  // byte write
                         o_address_nxt[1:0] == 2'd1 ? 4'b0010 :
                         o_address_nxt[1:0] == 2'd2 ? 4'b0100 :
                                                      4'b1000 ;


// ========================================================
// Write Data Select
// ========================================================
assign write_data_nxt = i_byte_enable_sel == 2'd0 ? rd            :
                                                    {4{rd[ 7:0]}} ;


// ========================================================
// Conditional Execution
// ========================================================
assign execute = conditional_execute ( i_condition, status_bits_flags );
            
// allow the PC to increment to the next instruction when current
// instruction does not execute
assign pc_wen       = i_pc_wen || !execute;

// only update register bank if current instruction executes
assign reg_bank_wen = {{15{execute}} & i_reg_bank_wen};

assign reg_bank_wsel = {{4{~execute}} | i_reg_bank_wsel};


// ========================================================
// Priviledged output flag
// ========================================================
// Need to look at status_bits_mode_nxt so switch to priviledged mode
// at the same time as assert interrupt vector address
assign priviledged_nxt  = ( i_status_bits_mode_wen ? status_bits_mode_nxt : status_bits_mode ) != USR ;


// ========================================================
// Write Enable
// ========================================================
// This must be de-asserted when execute is fault
assign write_enable_nxt = execute && i_write_data_wen;


// ========================================================
// Register Update
// ========================================================

assign priviledged_update              = !i_fetch_stall;       
assign data_access_update              = !i_fetch_stall && execute;
assign write_enable_update             = !i_fetch_stall;
assign write_data_update               = !i_fetch_stall && execute && i_write_data_wen;
assign exclusive_update                = !i_fetch_stall && execute;
assign address_update                  = !i_fetch_stall;
assign byte_enable_update              = !i_fetch_stall && execute && i_write_data_wen;
assign copro_write_data_update         = !i_fetch_stall && execute && i_copro_write_data_wen;

assign base_address_update             = !i_fetch_stall && execute && i_base_address_wen; 
assign status_bits_flags_update        = !i_fetch_stall && execute && i_status_bits_flags_wen;
assign status_bits_mode_update         = !i_fetch_stall && execute && i_status_bits_mode_wen;
assign status_bits_mode_rds_oh_update  = !i_fetch_stall;
assign status_bits_irq_mask_update     = !i_fetch_stall && execute && i_status_bits_irq_mask_wen;
assign status_bits_firq_mask_update    = !i_fetch_stall && execute && i_status_bits_firq_mask_wen;

assign status_bits_mode_rds_nr         =  status_bits_mode_rds_oh_update ? status_bits_mode_rds_nxt :
                                                                           status_bits_mode_rds     ;

assign status_bits_mode_nr             =  status_bits_mode_update        ? status_bits_mode_nxt     :
                                                                           status_bits_mode         ;

always @( posedge i_clk )
    begin                                                                                                             
    o_priviledged           <= priviledged_update             ? priviledged_nxt              : o_priviledged;
    o_exclusive             <= exclusive_update               ? i_exclusive_exec             : o_exclusive;
    o_data_access           <= data_access_update             ? i_data_access_exec           : o_data_access;
    o_write_enable          <= write_enable_update            ? write_enable_nxt             : o_write_enable;
    o_write_data            <= write_data_update              ? write_data_nxt               : o_write_data; 
    address_r               <= address_update                 ? o_address_nxt                : address_r;    
    o_adex                  <= address_update                 ? adex_nxt                     : o_adex;    
    o_address_valid         <= address_update                 ? 1'd1                         : o_address_valid;
    o_byte_enable           <= byte_enable_update             ? byte_enable_nxt              : o_byte_enable;
    o_copro_write_data      <= copro_write_data_update        ? write_data_nxt               : o_copro_write_data; 

    base_address            <= base_address_update            ? rn                           : base_address;    

    status_bits_flags       <= status_bits_flags_update       ? status_bits_flags_nxt        : status_bits_flags;
    status_bits_mode        <=  status_bits_mode_nr;
    status_bits_mode_rds_oh <= status_bits_mode_rds_oh_update ? status_bits_mode_rds_oh_nxt  : status_bits_mode_rds_oh;
    status_bits_mode_rds    <= status_bits_mode_rds_nr;
    status_bits_irq_mask    <= status_bits_irq_mask_update    ? status_bits_irq_mask_nxt     : status_bits_irq_mask;
    status_bits_firq_mask   <= status_bits_firq_mask_update   ? status_bits_firq_mask_nxt    : status_bits_firq_mask;
    end

assign o_address = address_r;


// ========================================================
// Instantiate Barrel Shift
// ========================================================

assign carry_in = i_use_carry_in ? status_bits_flags[1] : 1'd0;

`ifndef ALTERA_FPGA
a23_barrel_shift u_barrel_shift  (
`else
a23_barrel_shift_fpga u_barrel_shift  (
`endif
    .i_in             ( barrel_shift_in           ),
    .i_carry_in       ( carry_in                  ),
    .i_shift_amount   ( shift_amount              ),
    .i_shift_imm_zero ( i_shift_imm_zero          ),
    .i_function       ( i_barrel_shift_function   ),

    .o_out            ( barrel_shift_out          ),
    .o_carry_out      ( barrel_shift_carry        ));



// ========================================================
// Instantiate ALU
// ========================================================
assign barrel_shift_carry_alu =  i_barrel_shift_data_sel == 2'd0 ? 
                                  (i_imm_shift_amount[4:1] == 0 ? status_bits_flags[1] : i_imm32[31]) : 
                                   barrel_shift_carry;

a23_alu u_alu (
    .i_a_in                 ( rn                      ),
    .i_b_in                 ( barrel_shift_out        ),
    .i_barrel_shift_carry   ( barrel_shift_carry_alu  ),
    .i_status_bits_carry    ( status_bits_flags[1]    ),
    .i_function             ( i_alu_function          ),
  
    .o_out                  ( alu_out                 ),
    .o_flags                ( alu_flags               ));



// ========================================================
// Instantiate Booth 64-bit Multiplier-Accumulator
// ========================================================
a23_multiply u_multiply (
    .i_clk          ( i_clk                 ),
    .i_fetch_stall  ( i_fetch_stall         ),
    .i_a_in         ( rs                    ),
    .i_b_in         ( rm                    ),
    .i_function     ( i_multiply_function   ),
    .i_execute      ( execute               ),
    .o_out          ( multiply_out          ),
    .o_flags        ( multiply_flags        ),  // [1] = N, [0] = Z
    .o_done         ( o_multiply_done       )     
);


// ========================================================
// Instantiate Register Bank
// ========================================================
`ifndef A23_RAM_REGISTER_BANK
a23_register_bank u_register_bank(
    .i_clk                   ( i_clk                     ),
    .i_fetch_stall           ( i_fetch_stall             ),
    .i_rm_sel                ( i_rm_sel                  ),
    .i_rds_sel               ( i_rds_sel                 ),
    .i_rn_sel                ( i_rn_sel                  ),
    .i_pc_wen                ( pc_wen                    ),
    .i_reg_bank_wen          ( reg_bank_wen              ),
    .i_pc                    ( pc_nxt[25:2]              ),
    .i_reg                   ( reg_write_nxt             ),
    .i_mode_idec             ( i_status_bits_mode        ),
    .i_mode_exec             ( status_bits_mode          ),

    .i_status_bits_flags     ( status_bits_flags         ),
    .i_status_bits_irq_mask  ( status_bits_irq_mask      ),
    .i_status_bits_firq_mask ( status_bits_firq_mask     ),

    // pre-encoded in decode stage to speed up long path
    .i_firq_not_user_mode    ( i_firq_not_user_mode      ),
    
    // use one-hot version for speed, combine with i_user_mode_regs_store
    .i_mode_rds_exec         ( status_bits_mode_rds_oh   ),  
    
    .i_user_mode_regs_load   ( i_user_mode_regs_load     ),
    .o_rm                    ( rm                        ),
    .o_rs                    ( rs                        ),
    .o_rd                    ( rd                        ),
    .o_rn                    ( rn                        ),
    .o_pc                    ( pc                        )
);
`else
a23_ram_register_bank u_register_bank(
    .i_clk                   ( i_clk                     ),
    .i_fetch_stall           ( i_fetch_stall             ),
    .i_rm_sel                ( i_rm_sel_nxt              ),
    .i_rds_sel               ( i_rds_sel_nxt             ),
    .i_rn_sel                ( i_rn_sel_nxt              ),
    .i_pc_wen                ( pc_wen                    ),
    .i_reg_bank_wsel         ( reg_bank_wsel             ),
    .i_pc                    ( pc_nxt[25:2]              ),
    .i_reg                   ( reg_write_nxt             ),

    .i_mode_exec_nxt         ( status_bits_mode_nr       ),
    .i_mode_exec             ( status_bits_mode          ),
    .i_mode_rds_exec         ( status_bits_mode_rds_nr   ),
    .i_user_mode_regs_load   ( i_user_mode_regs_load     ),

    .i_status_bits_flags     ( status_bits_flags         ),
    .i_status_bits_irq_mask  ( status_bits_irq_mask      ),
    .i_status_bits_firq_mask ( status_bits_firq_mask     ),

    .o_rm                    ( rm                        ),
    .o_rs                    ( rs                        ),
    .o_rd                    ( rd                        ),
    .o_rn                    ( rn                        ),
    .o_pc                    ( pc                        )
);
`endif

// ========================================================
// Debug - non-synthesizable code
// ========================================================
//synopsys translate_off

wire    [(2*8)-1:0]    xCONDITION;
wire    [(4*8)-1:0]    xMODE;

assign  xCONDITION           = i_condition == EQ ? "EQ"  :
                               i_condition == NE ? "NE"  :
                               i_condition == CS ? "CS"  :
                               i_condition == CC ? "CC"  :
                               i_condition == MI ? "MI"  :
                               i_condition == PL ? "PL"  :
                               i_condition == VS ? "VS"  :
                               i_condition == VC ? "VC"  :
                               i_condition == HI ? "HI"  :
                               i_condition == LS ? "LS"  :
                               i_condition == GE ? "GE"  :
                               i_condition == LT ? "LT"  :
                               i_condition == GT ? "GT"  :
                               i_condition == LE ? "LE"  :
                               i_condition == AL ? "AL"  :
                                                   "NV " ;

assign  xMODE  =  status_bits_mode == SVC  ? "SVC"  :
                  status_bits_mode == IRQ  ? "IRQ"  :
                  status_bits_mode == FIRQ ? "FIRQ" :
                  status_bits_mode == USR  ? "USR"  :
                                             "XXX"  ;
                                             

//synopsys translate_on

endmodule


