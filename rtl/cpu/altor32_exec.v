//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.1
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//`define CONF_CORE_DEBUG
//`define CONF_CORE_TRACE

//-----------------------------------------------------------------
// Module - Instruction Execute
//-----------------------------------------------------------------
module altor32_exec
(
    // General
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Maskable interrupt    
    input               intr_i /*verilator public*/,

    // Break interrupt
    input               break_i /*verilator public*/,

    // Fault
    output reg          fault_o /*verilator public*/,

    // Breakpoint / Trap
    output reg          break_o /*verilator public*/,

    // Cache control
    output reg          icache_flush_o /*verilator public*/,
    output reg          dcache_flush_o /*verilator public*/,
        
    // Branch
    output              branch_o /*verilator public*/,
    output [31:0]       branch_pc_o /*verilator public*/,
    output              stall_o /*verilator public*/,

    // Opcode & arguments
    input [31:0]        opcode_i /*verilator public*/,
    input [31:0]        opcode_pc_i /*verilator public*/,
    input               opcode_valid_i /*verilator public*/,

    // Reg A
    input [4:0]         reg_ra_i /*verilator public*/,
    input [31:0]        reg_ra_value_i /*verilator public*/,

    // Reg B
    input [4:0]         reg_rb_i /*verilator public*/,
    input [31:0]        reg_rb_value_i /*verilator public*/,

    // Reg D
    input [4:0]         reg_rd_i /*verilator public*/,

    // Output
    output [31:0]       opcode_o /*verilator public*/,
    output [31:0]       opcode_pc_o /*verilator public*/,
    output [4:0]        reg_rd_o /*verilator public*/,
    output [31:0]       reg_rd_value_o /*verilator public*/,
    output [63:0]       mult_res_o /*verilator public*/,

    // Register write back bypass
    input [4:0]         wb_rd_i /*verilator public*/,
    input [31:0]        wb_rd_value_i /*verilator public*/,

    // Memory Interface
    output reg [31:0]   dmem_addr_o /*verilator public*/,
    output reg [31:0]   dmem_data_out_o /*verilator public*/,
    input [31:0]        dmem_data_in_i /*verilator public*/,
    output reg [3:0]    dmem_sel_o /*verilator public*/,
    output reg          dmem_we_o /*verilator public*/,
    output reg          dmem_stb_o /*verilator public*/,
    output reg          dmem_cyc_o /*verilator public*/,
    input               dmem_stall_i /*verilator public*/,
    input               dmem_ack_i /*verilator public*/
);

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"
`include "altor32_funcs.v"

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter           BOOT_VECTOR         = 32'h00000000;
parameter           ISR_VECTOR          = 32'h00000000;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------

// Branch PC
reg [31:0]  pc_branch_q;
reg         pc_fetch_q;

// Exception saved program counter
reg [31:0]  epc_q;

// Supervisor register
reg [31:0]  sr_q;

// Exception saved supervisor register
reg [31:0]  esr_q;

// Destination register number (post execute stage)
reg [4:0]   ex_rd_q;

// Current opcode (PC for debug)
reg [31:0]  ex_opcode_q;
reg [31:0]  ex_opcode_pc_q;

// ALU input A
reg [31:0]  ex_alu_a_q;

// ALU input B
reg [31:0]  ex_alu_b_q;

// ALU output
wire [31:0] ex_result_w;

// Resolved RA/RB register contents
wire [31:0] ra_resolved_w;
wire [31:0] rb_resolved_w;
wire        operand_resolved_w;
wire        resolve_failed_w;

// ALU Carry
wire        alu_carry_out_w;
wire        alu_carry_update_w;
wire        alu_flag_update_w;

// ALU Comparisons
wire        compare_equal_w;
wire        compare_gts_w;
wire        compare_gt_w;
wire        compare_lts_w;
wire        compare_lt_w;

// ALU operation selection
reg [3:0]   ex_alu_func_q;

// Load instruction details
reg [4:0]   load_rd_q;
reg [7:0]   load_inst_q;
reg [1:0]   load_offset_q;

// Load forwarding
wire        load_inst_w;
wire [31:0] load_result_w;

// Memory access?
reg         mem_load_q;
reg         mem_store_q;
reg         mem_access_q;

wire        load_pending_w;
wire        store_pending_w;
wire        load_insert_w;
wire        load_stall_w;

reg         d_mem_load_q;

reg         break_q;

// Exception/Interrupt was last instruction
reg         exc_last_q;

// SIM PUTC
`ifdef SIM_EXT_PUTC
    reg [7:0] putc_q;
`endif

//-----------------------------------------------------------------
// ALU
//-----------------------------------------------------------------
altor32_alu alu
(
    // ALU operation select
    .op_i(ex_alu_func_q),

    // Operands
    .a_i(ex_alu_a_q),
    .b_i(ex_alu_b_q),
    .c_i(sr_q[`SR_CY]),

    // Result
    .p_o(ex_result_w),

    // Carry
    .c_o(alu_carry_out_w),
    .c_update_o(alu_carry_update_w),

    // Comparisons
    .equal_o(compare_equal_w),
    .greater_than_signed_o(compare_gts_w),
    .greater_than_o(compare_gt_w),
    .less_than_signed_o(compare_lts_w),
    .less_than_o(compare_lt_w),
    .flag_update_o(alu_flag_update_w)
);

//-----------------------------------------------------------------
// Load result forwarding
//-----------------------------------------------------------------
altor32_lfu
u_lfu
(
    // Opcode
    .opcode_i(load_inst_q),

    // Memory load result
    .mem_result_i(dmem_data_in_i),
    .mem_offset_i(load_offset_q),

    // Result
    .load_result_o(load_result_w),
    .load_insn_o(load_inst_w)
);

//-----------------------------------------------------------------
// Load / store pending logic
//-----------------------------------------------------------------
altor32_lsu
u_lsu
(
    // Current instruction
    .opcode_valid_i(opcode_valid_i & ~pc_fetch_q),
    .opcode_i({2'b00,opcode_i[31:26]}),

    // Load / Store pending
    .load_pending_i(mem_load_q),
    .store_pending_i(mem_store_q),

    // Load dest register
    .rd_load_i(load_rd_q),

    // Load insn in WB stage
    .load_wb_i(d_mem_load_q),

    // Memory status
    .mem_access_i(mem_access_q),
    .mem_ack_i(dmem_ack_i),

    // Load / store still pending
    .load_pending_o(load_pending_w),
    .store_pending_o(store_pending_w),

    // Insert load result into pipeline
    .write_result_o(load_insert_w),

    // Stall pipeline due
    .stall_o(load_stall_w)
);

//-----------------------------------------------------------------
// Operand forwarding
//-----------------------------------------------------------------
altor32_dfu
u_dfu
(
    // Input registers
    .ra_i(reg_ra_i),
    .rb_i(reg_rb_i),

    // Input register contents
    .ra_regval_i(reg_ra_value_i),
    .rb_regval_i(reg_rb_value_i),

    // Dest register (EXEC stage)
    .rd_ex_i(ex_rd_q),

    // Dest register (WB stage)
    .rd_wb_i(wb_rd_i),

    // Load pending / target
    .load_pending_i(load_pending_w),
    .rd_load_i(load_rd_q),

    // Multiplier status
    .mult_ex_i(1'b0),

    // Result (EXEC)
    .result_ex_i(ex_result_w),

    // Result (WB)
    .result_wb_i(wb_rd_value_i),

    // Resolved register values
    .result_ra_o(ra_resolved_w),
    .result_rb_o(rb_resolved_w),

    // Operands required forwarding
    .resolved_o(operand_resolved_w),

    // Stall due to failed resolve
    .stall_o(resolve_failed_w)
);

//-----------------------------------------------------------------
// Opcode decode
//-----------------------------------------------------------------
reg [7:0]  inst_r;
reg [7:0]  alu_op_r;
reg [1:0]  shift_op_r;
reg [15:0] sfxx_op_r;
reg [15:0] uint16_r;
reg [31:0] uint32_r;
reg [31:0] int32_r;
reg [31:0] store_int32_r;
reg [15:0] mxspr_uint16_r;
reg [31:0] target_int26_r;
reg [31:0] reg_ra_r;
reg [31:0] reg_rb_r;
reg [31:0] shift_rb_r;
reg [31:0] shift_imm_r;

always @ *
begin
    // Instruction
    inst_r               = {2'b00,opcode_i[31:26]};

    // Sub instructions
    alu_op_r             = {opcode_i[9:6],opcode_i[3:0]};
    sfxx_op_r            = {5'b00,opcode_i[31:21]} & `INST_OR32_SFMASK;
    shift_op_r           = opcode_i[7:6];

    // Branch target
    target_int26_r       = sign_extend_imm26(opcode_i[25:0]);

    // Store immediate
    store_int32_r        = sign_extend_imm16({opcode_i[25:21],opcode_i[10:0]});

    // Signed & unsigned imm -> 32-bits
    uint16_r             = opcode_i[15:0];
    int32_r              = sign_extend_imm16(opcode_i[15:0]);
    uint32_r             = extend_imm16(opcode_i[15:0]);

    // Register values [ra/rb]
    reg_ra_r             = ra_resolved_w;
    reg_rb_r             = rb_resolved_w;

    // Shift ammount (from register[rb])
    shift_rb_r           = {26'b00,rb_resolved_w[5:0]};

    // Shift ammount (from immediate)
    shift_imm_r          = {26'b00,opcode_i[5:0]};

    // MTSPR/MFSPR operand
    // NOTE: Use unresolved register value and stall pipeline if required.
    // This is to improve timing.
    mxspr_uint16_r       = (reg_ra_value_i[15:0] | {5'b00000,opcode_i[10:0]});
end

//-----------------------------------------------------------------
// Instruction Decode
//-----------------------------------------------------------------
wire inst_add_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_ADD);  // l.add
wire inst_addc_w    = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_ADDC); // l.addc
wire inst_and_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_AND);  // l.and
wire inst_or_w      = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_OR);   // l.or
wire inst_sll_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_SLL);  // l.sll
wire inst_sra_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_SRA);  // l.sra
wire inst_srl_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_SRL);  // l.srl
wire inst_sub_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_SUB);  // l.sub
wire inst_xor_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_XOR);  // l.xor
wire inst_mul_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_MUL);  // l.mul
wire inst_mulu_w    = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_MULU); // l.mulu

wire inst_addi_w    = (inst_r == `INST_OR32_ADDI);  // l.addi
wire inst_andi_w    = (inst_r == `INST_OR32_ANDI);  // l.andi
wire inst_bf_w      = (inst_r == `INST_OR32_BF);    // l.bf
wire inst_bnf_w     = (inst_r == `INST_OR32_BNF);   // l.bnf
wire inst_j_w       = (inst_r == `INST_OR32_J);     // l.j
wire inst_jal_w     = (inst_r == `INST_OR32_JAL);   // l.jal
wire inst_jalr_w    = (inst_r == `INST_OR32_JALR);  // l.jalr
wire inst_jr_w      = (inst_r == `INST_OR32_JR);    // l.jr
wire inst_lbs_w     = (inst_r == `INST_OR32_LBS);   // l.lbs
wire inst_lhs_w     = (inst_r == `INST_OR32_LHS);   // l.lhs
wire inst_lws_w     = (inst_r == `INST_OR32_LWS);   // l.lws
wire inst_lbz_w     = (inst_r == `INST_OR32_LBZ);   // l.lbz
wire inst_lhz_w     = (inst_r == `INST_OR32_LHZ);   // l.lhz
wire inst_lwz_w     = (inst_r == `INST_OR32_LWZ);   // l.lwz
wire inst_mfspr_w   = (inst_r == `INST_OR32_MFSPR); // l.mfspr
wire inst_mtspr_w   = (inst_r == `INST_OR32_MTSPR); // l.mtspr
wire inst_movhi_w   = (inst_r == `INST_OR32_MOVHI); // l.movhi
wire inst_nop_w     = (inst_r == `INST_OR32_NOP);   // l.nop
wire inst_ori_w     = (inst_r == `INST_OR32_ORI);   // l.ori
wire inst_rfe_w     = (inst_r == `INST_OR32_RFE);   // l.rfe

wire inst_sb_w      = (inst_r == `INST_OR32_SB);    // l.sb
wire inst_sh_w      = (inst_r == `INST_OR32_SH);    // l.sh
wire inst_sw_w      = (inst_r == `INST_OR32_SW);    // l.sw

wire inst_slli_w    = (inst_r == `INST_OR32_SHIFTI) & (shift_op_r == `INST_OR32_SLLI);  // l.slli
wire inst_srai_w    = (inst_r == `INST_OR32_SHIFTI) & (shift_op_r == `INST_OR32_SRAI);  // l.srai
wire inst_srli_w    = (inst_r == `INST_OR32_SHIFTI) & (shift_op_r == `INST_OR32_SRLI);  // l.srli

wire inst_xori_w    = (inst_r == `INST_OR32_XORI);   // l.xori

wire inst_sfxx_w    = (inst_r == `INST_OR32_SFXX);
wire inst_sfxxi_w   = (inst_r == `INST_OR32_SFXXI);

wire inst_sfeq_w    = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFEQ);   // l.sfeq
wire inst_sfges_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFGES);  // l.sfges

wire inst_sfgeu_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFGEU);  // l.sfgeu
wire inst_sfgts_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFGTS);  // l.sfgts
wire inst_sfgtu_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFGTU);  // l.sfgtu
wire inst_sfles_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFLES);  // l.sfles
wire inst_sfleu_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFLEU);  // l.sfleu
wire inst_sflts_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFLTS);  // l.sflts
wire inst_sfltu_w   = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFLTU);  // l.sfltu
wire inst_sfne_w    = (inst_sfxx_w || inst_sfxxi_w) & (sfxx_op_r == `INST_OR32_SFNE);   // l.sfne

wire inst_sys_w     = (inst_r == `INST_OR32_MISC) & (opcode_i[31:24] == `INST_OR32_SYS);  // l.sys
wire inst_trap_w    = (inst_r == `INST_OR32_MISC) & (opcode_i[31:24] == `INST_OR32_TRAP); // l.trap

//-----------------------------------------------------------------
// Stall / Execute
//-----------------------------------------------------------------
reg execute_inst_r;
reg stall_inst_r;

always @ *
begin
    execute_inst_r  = 1'b1;
    stall_inst_r    = 1'b0;

    // No opcode ready or branch delay slot
    if (~opcode_valid_i | pc_fetch_q)
        execute_inst_r  = 1'b0;
    // Valid instruction, but load result / operand not ready
    else if (resolve_failed_w | load_stall_w |
            (operand_resolved_w & (inst_mfspr_w | inst_mtspr_w)))
        stall_inst_r    = 1'b1;
end

//-----------------------------------------------------------------
// Next PC
//-----------------------------------------------------------------
reg [31:0]  next_pc_r;

always @ *
begin
    // Next expected PC (current PC + 4)
    next_pc_r  = (opcode_pc_i + 4);
end

//-----------------------------------------------------------------
// Next SR
//-----------------------------------------------------------------
reg [31:0]  next_sr_r;
reg         compare_result_r;
always @ *
begin
    next_sr_r = sr_q;

    // Update SR.F
    if (alu_flag_update_w)
        next_sr_r[`SR_F] = compare_result_r;

    // Latch carry if updated
    if (alu_carry_update_w)
        next_sr_r[`SR_CY] = alu_carry_out_w;

    // If valid instruction, check if SR needs updating
    if (execute_inst_r & ~stall_inst_r)
    begin

      // Clear step control (if not executing higher priority syscall/break)
      if (!inst_sys_w && !inst_trap_w)
          next_sr_r[`SR_STEP] = 1'b0;

      case (1'b1)
      inst_mtspr_w:
      begin
          case (mxspr_uint16_r)
          // SR - Supervision register
          `SPR_REG_SR:
          begin
              next_sr_r = reg_rb_r;

              // Don't store cache flush requests
              next_sr_r[`SR_ICACHE_FLUSH] = 1'b0;
              next_sr_r[`SR_DCACHE_FLUSH] = 1'b0;
          end
          default:
            ;        
          endcase
      end
      inst_rfe_w:
          next_sr_r = esr_q;
      default:
        ;
      endcase
    end
end

//-----------------------------------------------------------------
// Next EPC/ESR
//-----------------------------------------------------------------
reg [31:0]  next_epc_r;
reg [31:0]  next_esr_r;

always @ *
begin
    next_epc_r = epc_q;
    next_esr_r = esr_q;
    // Instruction after interrupt, update SR.F
    if (exc_last_q && alu_flag_update_w)
        next_esr_r[`SR_F] = compare_result_r;

    //  Instruction after interrupt, latch carry if updated
    if (exc_last_q && alu_carry_update_w)
        next_esr_r[`SR_CY] = alu_carry_out_w;
    
    if (execute_inst_r & ~stall_inst_r)
    begin
        case (1'b1)
        inst_mtspr_w: // l.mtspr
        begin
           case (mxspr_uint16_r)
               // EPCR - EPC Exception saved PC
               `SPR_REG_EPCR:   next_epc_r = reg_rb_r;

               // ESR - Exception saved SR
               `SPR_REG_ESR:    next_esr_r = reg_rb_r;
           endcase
        end
        default:
          ;
        endcase
    end
end

//-----------------------------------------------------------------
// ALU inputs
//-----------------------------------------------------------------

// ALU operation selection
reg [3:0]  alu_func_r;

// ALU operands
reg [31:0] alu_input_a_r;
reg [31:0] alu_input_b_r;
reg        write_rd_r;

always @ *
begin
   alu_func_r     = `ALU_NONE;
   alu_input_a_r  = 32'b0;
   alu_input_b_r  = 32'b0;
   write_rd_r     = 1'b0;

   case (1'b1)

     inst_add_w: // l.add
     begin
       alu_func_r     = `ALU_ADD;
       alu_input_a_r  = reg_ra_r;
       alu_input_b_r  = reg_rb_r;
       write_rd_r     = 1'b1;
     end
     
     inst_addc_w: // l.addc
     begin
         alu_func_r     = `ALU_ADDC;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = reg_rb_r;
         write_rd_r     = 1'b1;
     end                     

     inst_and_w: // l.and
     begin
         alu_func_r     = `ALU_AND;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = reg_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_or_w: // l.or
     begin
         alu_func_r     = `ALU_OR;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = reg_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_sll_w: // l.sll
     begin
         alu_func_r     = `ALU_SHIFTL;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = shift_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_sra_w: // l.sra
     begin
         alu_func_r     = `ALU_SHIRTR_ARITH;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = shift_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_srl_w: // l.srl
     begin
         alu_func_r     = `ALU_SHIFTR;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = shift_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_sub_w: // l.sub
     begin
         alu_func_r     = `ALU_SUB;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = reg_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_xor_w: // l.xor
     begin
         alu_func_r     = `ALU_XOR;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = reg_rb_r;
         write_rd_r     = 1'b1;
     end

     inst_addi_w: // l.addi
     begin
         alu_func_r     = `ALU_ADD;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = int32_r;
         write_rd_r     = 1'b1;
     end

     inst_andi_w: // l.andi
     begin
         alu_func_r     = `ALU_AND;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = uint32_r;
         write_rd_r     = 1'b1;
     end

     inst_jal_w: // l.jal
     begin
         alu_input_a_r  = next_pc_r;
         write_rd_r     = 1'b1;
     end

     inst_jalr_w: // l.jalr
     begin
         alu_input_a_r  = next_pc_r;
         write_rd_r     = 1'b1;
     end

     inst_mfspr_w: // l.mfspr
     begin
        case (mxspr_uint16_r)
           // SR - Supervision register
           `SPR_REG_SR:
           begin
               alu_input_a_r = next_sr_r;
               write_rd_r    = 1'b1;
           end

           // EPCR - EPC Exception saved PC
           `SPR_REG_EPCR:
           begin
               alu_input_a_r  = epc_q;
               write_rd_r     = 1'b1;
           end

           // ESR - Exception saved SR
           `SPR_REG_ESR:
           begin
               alu_input_a_r  = esr_q;
               write_rd_r     = 1'b1;
           end
           default:
              ;
        endcase
     end

     inst_movhi_w: // l.movhi
     begin
         alu_input_a_r  = {uint16_r,16'h0000};
         write_rd_r     = 1'b1;
     end

     inst_ori_w: // l.ori
     begin
         alu_func_r     = `ALU_OR;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = uint32_r;
         write_rd_r     = 1'b1;
     end

     inst_slli_w: // l.slli
     begin
         alu_func_r     = `ALU_SHIFTL;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = shift_imm_r;
         write_rd_r     = 1'b1;
     end

     inst_srai_w: // l.srai
     begin
         alu_func_r     = `ALU_SHIRTR_ARITH;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = shift_imm_r;
         write_rd_r     = 1'b1;
     end

     inst_srli_w: // l.srli
     begin
         alu_func_r     = `ALU_SHIFTR;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = shift_imm_r;
         write_rd_r     = 1'b1;
     end

     // l.lbs l.lhs l.lws l.lbz l.lhz l.lwz
     inst_lbs_w,
     inst_lhs_w,
     inst_lws_w,
     inst_lbz_w,
     inst_lhz_w,
     inst_lwz_w:
          write_rd_r    = 1'b1;

     // l.sf*i
     inst_sfxxi_w:
     begin
         alu_func_r     = `ALU_COMPARE;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = int32_r;
     end

     // l.sf*
     inst_sfxx_w:
     begin
         alu_func_r     = `ALU_COMPARE;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = reg_rb_r;
     end

     inst_xori_w: // l.xori
     begin
         alu_func_r     = `ALU_XOR;
         alu_input_a_r  = reg_ra_r;
         alu_input_b_r  = int32_r;
         write_rd_r     = 1'b1;
     end
     default:
        ;     
   endcase
end

//-----------------------------------------------------------------
// Comparisons (from ALU outputs)
//-----------------------------------------------------------------
reg inst_sfges_r;
reg inst_sfgeu_r;
reg inst_sfgts_r;
reg inst_sfgtu_r;
reg inst_sfles_r;
reg inst_sfleu_r;
reg inst_sflts_r;
reg inst_sfltu_r;
reg inst_sfne_r;
reg inst_sfges_q;
reg inst_sfgeu_q;
reg inst_sfgts_q;
reg inst_sfgtu_q;
reg inst_sfles_q;
reg inst_sfleu_q;
reg inst_sflts_q;
reg inst_sfltu_q;
reg inst_sfne_q;

always @ *
begin
    inst_sfges_r = 1'b0;
    inst_sfgeu_r = 1'b0;
    inst_sfgts_r = 1'b0;
    inst_sfgtu_r = 1'b0;
    inst_sfles_r = 1'b0;
    inst_sfleu_r = 1'b0;
    inst_sflts_r = 1'b0;
    inst_sfltu_r = 1'b0;
    inst_sfne_r  = 1'b0;

    // Valid instruction
    if (execute_inst_r && ~stall_inst_r)
    begin

        case (1'b1)    
        inst_sfges_w:  // l.sfges
            inst_sfges_r = 1'b1;

        inst_sfgeu_w:  // l.sfgeu
            inst_sfgeu_r = 1'b1;

        inst_sfgts_w:  // l.sfgts
            inst_sfgts_r = 1'b1;

        inst_sfgtu_w:  // l.sfgtu
            inst_sfgtu_r = 1'b1;

        inst_sfles_w:  // l.sfles
            inst_sfles_r = 1'b1;

        inst_sfleu_w:  // l.sfleu
            inst_sfleu_r = 1'b1;

        inst_sflts_w:  // l.sflts
            inst_sflts_r = 1'b1;

        inst_sfltu_w:  // l.sfltu
            inst_sfltu_r = 1'b1;

        inst_sfne_w:  // l.sfne
            inst_sfne_r  = 1'b1;

        default:
            ;    
        endcase
    end
end

always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin      
        inst_sfges_q <= 1'b0;
        inst_sfgeu_q <= 1'b0;
        inst_sfgts_q <= 1'b0;
        inst_sfgtu_q <= 1'b0;
        inst_sfles_q <= 1'b0;
        inst_sfleu_q <= 1'b0;
        inst_sflts_q <= 1'b0;
        inst_sfltu_q <= 1'b0;
        inst_sfne_q <= 1'b0;
   end
   else
   begin        
        inst_sfges_q <= inst_sfges_r;
        inst_sfgeu_q <= inst_sfgeu_r;
        inst_sfgts_q <= inst_sfgts_r;
        inst_sfgtu_q <= inst_sfgtu_r;
        inst_sfles_q <= inst_sfles_r;
        inst_sfleu_q <= inst_sfleu_r;
        inst_sflts_q <= inst_sflts_r;
        inst_sfltu_q <= inst_sfltu_r;
        inst_sfne_q  <= inst_sfne_r;
   end
end

always @ *
begin
    case (1'b1)
    inst_sfges_q: // l.sfges
        compare_result_r = compare_gts_w | compare_equal_w;

    inst_sfgeu_q: // l.sfgeu
        compare_result_r = compare_gt_w | compare_equal_w;

    inst_sfgts_q: // l.sfgts
        compare_result_r = compare_gts_w;

    inst_sfgtu_q: // l.sfgtu
        compare_result_r = compare_gt_w;

    inst_sfles_q: // l.sfles
        compare_result_r = compare_lts_w | compare_equal_w;

    inst_sfleu_q: // l.sfleu
        compare_result_r = compare_lt_w | compare_equal_w;

    inst_sflts_q: // l.sflts
        compare_result_r = compare_lts_w;

    inst_sfltu_q: // l.sfltu
        compare_result_r = compare_lt_w;

    inst_sfne_q: // l.sfne
        compare_result_r = ~compare_equal_w;

    default: // l.sfeq
        compare_result_r = compare_equal_w;   
    endcase
end

//-----------------------------------------------------------------
// Load/Store operation?
//-----------------------------------------------------------------
reg         load_inst_r;
reg         store_inst_r;
reg [31:0]  mem_addr_r;
always @ *
begin
    load_inst_r  = inst_lbs_w | inst_lhs_w | inst_lws_w |
                   inst_lbz_w | inst_lhz_w | inst_lwz_w;
    store_inst_r = inst_sb_w  | inst_sh_w  | inst_sw_w;

    // Memory address is relative to RA
    mem_addr_r = reg_ra_r + (store_inst_r ? store_int32_r : int32_r);
end

//-----------------------------------------------------------------
// Branches
//-----------------------------------------------------------------
reg         branch_r;
reg         branch_link_r;
reg [31:0]  branch_target_r;
reg         branch_except_r;

always @ *
begin

    branch_r        = 1'b0;
    branch_link_r   = 1'b0;
    branch_except_r = 1'b0; 

    // Default branch target is relative to current PC
    branch_target_r = (opcode_pc_i + {target_int26_r[29:0],2'b00});    

    case (1'b1)
    inst_bf_w: // l.bf
        branch_r      = next_sr_r[`SR_F];

    inst_bnf_w: // l.bnf
        branch_r      = ~next_sr_r[`SR_F];

    inst_j_w: // l.j
        branch_r      = 1'b1;

    inst_jal_w: // l.jal
    begin
        // Write to REG_9_LR
        branch_link_r = 1'b1;
        branch_r      = 1'b1;
    end

    inst_jalr_w: // l.jalr
    begin
        // Write to REG_9_LR
        branch_link_r   = 1'b1;
        branch_r        = 1'b1;
        branch_target_r = reg_rb_r;
    end

    inst_jr_w: // l.jr
    begin
        branch_r        = 1'b1;
        branch_target_r = reg_rb_r;
    end

    inst_rfe_w: // l.rfe
    begin
        branch_r        = 1'b1;
        branch_target_r = epc_q;
    end

    inst_sys_w: // l.sys
    begin
        branch_r        = 1'b1;
        branch_except_r = 1'b1;
        branch_target_r = ISR_VECTOR + `VECTOR_SYSCALL;            
    end

    inst_trap_w: // l.trap
    begin
        branch_r        = 1'b1;
        branch_except_r = 1'b1;
        branch_target_r = ISR_VECTOR + `VECTOR_TRAP;
    end

    default:
        ;
    endcase
end

//-----------------------------------------------------------------
// Invalid instruction
//-----------------------------------------------------------------
reg invalid_inst_r;

always @ *
begin
    case (1'b1)
       inst_add_w, 
       inst_addc_w,
       inst_and_w,
       inst_or_w,
       inst_sll_w,
       inst_sra_w,
       inst_srl_w,
       inst_sub_w,
       inst_xor_w,      
       inst_addi_w,
       inst_andi_w,
       inst_bf_w,
       inst_bnf_w,
       inst_j_w,
       inst_jal_w,
       inst_jalr_w,
       inst_jr_w,
       inst_lbs_w,
       inst_lhs_w,
       inst_lws_w,
       inst_lbz_w,
       inst_lhz_w,
       inst_lwz_w,
       inst_mfspr_w,
       inst_mtspr_w,
       inst_movhi_w,
       inst_nop_w,
       inst_ori_w,
       inst_rfe_w,
       inst_sb_w,
       inst_sh_w,
       inst_sw_w,
       inst_xori_w,
       inst_slli_w,
       inst_srai_w,
       inst_srli_w,
       inst_sfeq_w,
       inst_sfges_w,
       inst_sfgeu_w,
       inst_sfgts_w,
       inst_sfgtu_w,
       inst_sfles_w,
       inst_sfleu_w,
       inst_sflts_w,
       inst_sfltu_w,
       inst_sfne_w,
       inst_sys_w,
       inst_trap_w:
          invalid_inst_r = 1'b0;
       default:
          invalid_inst_r = 1'b1;
    endcase
end

//-----------------------------------------------------------------
// Execute: ALU control
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin      
       ex_alu_func_q         <= `ALU_NONE;
       ex_alu_a_q            <= 32'h00000000;
       ex_alu_b_q            <= 32'h00000000;
       ex_rd_q               <= 5'b00000;
   end
   else
   begin           
       //---------------------------------------------------------------
       // Instruction not ready
       //---------------------------------------------------------------
       if (~execute_inst_r | stall_inst_r)
       begin
           // Insert load result?
           if (load_insert_w)
           begin
               // Feed load result into pipeline
               ex_alu_func_q   <= `ALU_NONE;
               ex_alu_a_q      <= load_result_w;
               ex_alu_b_q      <= 32'b0;
               ex_rd_q         <= load_rd_q;
           end
           else
           begin
               // No ALU operation (output == input_a)
               ex_alu_func_q   <= `ALU_NONE;
               ex_alu_a_q      <= 32'b0;
               ex_alu_b_q      <= 32'b0;
               ex_rd_q         <= 5'b0;
           end
       end   
       //---------------------------------------------------------------
       // Valid instruction
       //---------------------------------------------------------------
       else
       begin
           // Update ALU input flops
           ex_alu_func_q         <= alu_func_r;
           ex_alu_a_q            <= alu_input_a_r;
           ex_alu_b_q            <= alu_input_b_r;

           // Branch and link (Rd = LR/R9)
           if (branch_link_r)
              ex_rd_q            <= 5'd9;           
           // Instruction with register writeback
           else if (write_rd_r)
              ex_rd_q            <= reg_rd_i;
           else
              ex_rd_q            <= 5'b0;
       end
   end
end

//-----------------------------------------------------------------
// Execute: Update executed PC / opcode
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin      
       ex_opcode_q           <= 32'h00000000;
       ex_opcode_pc_q        <= 32'h00000000;
   end
   else
   begin
       // Instruction not ready
       if (~execute_inst_r | stall_inst_r)
       begin
           // Store bubble opcode
           ex_opcode_q            <= `OPCODE_INST_BUBBLE;
           ex_opcode_pc_q         <= opcode_pc_i;
       end   
       // Valid instruction
       else
       begin
           // Store opcode
           ex_opcode_q            <= opcode_i;
           ex_opcode_pc_q         <= opcode_pc_i;

        `ifdef CONF_CORE_TRACE
           $display("%08x: Execute 0x%08x", opcode_pc_i, opcode_i);
           $display(" rA[%d] = 0x%08x", reg_ra_i, reg_ra_r);
           $display(" rB[%d] = 0x%08x", reg_rb_i, reg_rb_r);
        `endif
       end
   end
end

//-----------------------------------------------------------------
// Execute: Branch / exceptions
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       pc_branch_q          <= 32'h00000000;
       pc_fetch_q           <= 1'b0;
       exc_last_q           <= 1'b0;

       // Status registers
       epc_q                <= 32'h00000000;
       sr_q                 <= 32'h00000000;
       esr_q                <= 32'h00000000;

       fault_o              <= 1'b0;

       break_q              <= 1'b0;
       break_o              <= 1'b0;
   end
   else
   begin
      // Flop break request, clear when break interrupt executed
      if (break_i)
          break_q           <= 1'b1;

       // Reset branch request
       pc_fetch_q           <= 1'b0;
       exc_last_q           <= 1'b0;

       break_o              <= 1'b0;

       // Update SR
       sr_q                 <= next_sr_r;

       // Update EPC / ESR which may have been updated by an 
       // MTSPR write / flag update in instruction after interrupt
       epc_q                <= next_epc_r;
       esr_q                <= next_esr_r;

       // Instruction ready
       if (execute_inst_r & ~stall_inst_r)
       begin
           // Exception: Instruction opcode not valid / supported, invalid PC
           if (invalid_inst_r || (opcode_pc_i[1:0] != 2'b00))
           begin
                // Save PC of next instruction
                epc_q       <= next_pc_r;
                esr_q       <= next_sr_r;

                // Disable further interrupts
                sr_q        <= 32'b0;

                // Set PC to exception vector
                if (invalid_inst_r)
                    pc_branch_q <= ISR_VECTOR + `VECTOR_ILLEGAL_INST;
                else
                    pc_branch_q <= ISR_VECTOR + `VECTOR_BUS_ERROR;
                pc_fetch_q  <= 1'b1;
                exc_last_q  <= 1'b1;

                fault_o     <= 1'b1;
           end
           // Exception: Syscall / Break
           else if (branch_except_r)
           begin
                // Save PC of next instruction
                epc_q       <= next_pc_r;
                esr_q       <= next_sr_r;

                // Disable further interrupts / break events
                sr_q        <= 32'b0;

                // Set PC to exception vector
                pc_branch_q <= branch_target_r;
                pc_fetch_q  <= 1'b1;
                exc_last_q  <= 1'b1;

                if (inst_trap_w)
                    break_o     <= 1'b1;
                
    `ifdef CONF_CORE_DEBUG
               $display(" Exception 0x%08x", branch_target_r);
    `endif
           end
           // Single step / break request
           else if ((sr_q[`SR_STEP] || break_q) && sr_q[`SR_DBGEN])
           begin
                // Save PC of next instruction
                if (branch_r)
                    epc_q   <= branch_target_r;
                // Next expected PC (current PC + 4)
                else
                    epc_q   <= next_pc_r;

                // Save SR
                esr_q       <= next_sr_r;

                // Disable further interrupts / break events
                sr_q        <= 32'b0;
                break_q     <= 1'b0;
                break_o     <= 1'b1;

                // Set PC to trap vector
                pc_branch_q <= ISR_VECTOR + `VECTOR_TRAP;
                pc_fetch_q  <= 1'b1;
                exc_last_q  <= 1'b1;

    `ifdef CONF_CORE_DEBUG
               $display(" Break Event 0x%08x", ISR_VECTOR + `VECTOR_TRAP);
    `endif
           end
           // External interrupt
           else if (intr_i && next_sr_r[`SR_IEE])
           begin
                // Save PC of next instruction & SR
                if (branch_r)
                    epc_q <= branch_target_r;
                // Next expected PC (current PC + 4)
                else
                    epc_q <= next_pc_r;

                esr_q       <= next_sr_r;

                // Disable further interrupts / break events
                sr_q        <= 32'b0;

                // Set PC to external interrupt vector
                pc_branch_q <= ISR_VECTOR + `VECTOR_EXTINT;
                pc_fetch_q  <= 1'b1;
                exc_last_q  <= 1'b1;
                
    `ifdef CONF_CORE_DEBUG
               $display(" External Interrupt 0x%08x", ISR_VECTOR + `VECTOR_EXTINT);
    `endif
           end        
           // Branch (l.bf, l.bnf, l.j, l.jal, l.jr, l.jalr, l.rfe)
           else if (branch_r)
           begin
                // Perform branch
                pc_branch_q    <= branch_target_r;
                pc_fetch_q     <= 1'b1;
               
    `ifdef CONF_CORE_DEBUG
               $display(" Branch to 0x%08x", branch_target_r);
    `endif
           end
      end
   end
end

//-----------------------------------------------------------------
// Execute: Memory operations
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       // Data memory
       dmem_addr_o          <= 32'h00000000;
       dmem_data_out_o      <= 32'h00000000;
       dmem_we_o            <= 1'b0;
       dmem_sel_o           <= 4'b0000;
       dmem_stb_o           <= 1'b0;
       dmem_cyc_o           <= 1'b0;
       
       mem_load_q           <= 1'b0;
       mem_store_q          <= 1'b0;
       mem_access_q         <= 1'b0;
       
       load_rd_q            <= 5'b00000;
       load_inst_q          <= 8'h00;
       load_offset_q        <= 2'b00;

       d_mem_load_q         <= 1'b0;
   end
   else
   begin

       // If memory access accepted by slave
       if (~dmem_stall_i)
           dmem_stb_o   <= 1'b0;

       if (dmem_ack_i)
            dmem_cyc_o  <= 1'b0;

       mem_access_q     <= 1'b0;
       d_mem_load_q     <= mem_access_q & mem_load_q;      

       // Pending accesses
       mem_load_q   <= load_pending_w;
       mem_store_q  <= store_pending_w;
             
       //---------------------------------------------------------------
       // Valid instruction
       //---------------------------------------------------------------
       if (execute_inst_r & ~stall_inst_r)
       begin
           // Branch and link (Rd = LR/R9)
           if (branch_link_r)
           begin
              // Load outstanding, check if result target is being
              // overwritten (to avoid WAR hazard)
              if (load_rd_q == 5'd9)
                  // Ditch load result when it arrives
                  load_rd_q     <= 5'b00000;              
           end
           // Instruction with register writeback
           else if (write_rd_r)
           begin
              // Load outstanding, check if result target is being
              // overwritten (to avoid WAR hazard)
              if (reg_rd_i == load_rd_q && ~load_inst_r)
                  // Ditch load result when it arrives
                  load_rd_q     <= 5'b00000;              
           end

           case (1'b1)

             // l.lbs l.lhs l.lws l.lbz l.lhz l.lwz
             load_inst_r:
             begin
                 dmem_addr_o      <= mem_addr_r;
                 dmem_data_out_o  <= 32'h00000000;
                 dmem_sel_o       <= 4'b1111;
                 dmem_we_o        <= 1'b0;
                 dmem_stb_o       <= 1'b1;
                 dmem_cyc_o       <= 1'b1;   

                 // Mark load as pending
                 mem_load_q      <= 1'b1;
                 mem_access_q    <= 1'b1;
                 
                 // Record target register
                 load_rd_q        <= reg_rd_i;
                 load_inst_q      <= inst_r;
                 load_offset_q    <= mem_addr_r[1:0];
                 
  `ifdef CONF_CORE_DEBUG
                 $display(" Load from 0x%08x to R%d", mem_addr_r, reg_rd_i);
  `endif
             end

             inst_sb_w: // l.sb
             begin
                 dmem_addr_o <= mem_addr_r;
                 mem_access_q <= 1'b1;
                 case (mem_addr_r[1:0])
                     2'b00 :
                     begin
                         dmem_data_out_o  <= {reg_rb_r[7:0],24'h000000};
                         dmem_sel_o       <= 4'b1000;
                         dmem_we_o        <= 1'b1;
                         dmem_stb_o       <= 1'b1;
                         dmem_cyc_o       <= 1'b1;
                         mem_store_q      <= 1'b1;
                     end
                     2'b01 :
                     begin
                         dmem_data_out_o  <= {{8'h00,reg_rb_r[7:0]},16'h0000};
                         dmem_sel_o       <= 4'b0100;
                         dmem_we_o        <= 1'b1;
                         dmem_stb_o       <= 1'b1;
                         dmem_cyc_o       <= 1'b1;
                         mem_store_q      <= 1'b1;
                     end
                     2'b10 :
                     begin
                         dmem_data_out_o  <= {{16'h0000,reg_rb_r[7:0]},8'h00};
                         dmem_sel_o       <= 4'b0010;
                         dmem_we_o        <= 1'b1;
                         dmem_stb_o       <= 1'b1;
                         dmem_cyc_o       <= 1'b1;
                         mem_store_q      <= 1'b1;
                     end
                     2'b11 :
                     begin
                         dmem_data_out_o  <= {24'h000000,reg_rb_r[7:0]};
                         dmem_sel_o       <= 4'b0001;
                         dmem_we_o        <= 1'b1;
                         dmem_stb_o       <= 1'b1;
                         dmem_cyc_o       <= 1'b1;
                         mem_store_q      <= 1'b1;
                     end
                     default :
                        ;
                 endcase
             end

            inst_sh_w: // l.sh
            begin
                 dmem_addr_o <= mem_addr_r;
                 mem_access_q <= 1'b1;
                 case (mem_addr_r[1:0])
                     2'b00 :
                     begin
                         dmem_data_out_o  <= {reg_rb_r[15:0],16'h0000};
                         dmem_sel_o       <= 4'b1100;
                         dmem_we_o        <= 1'b1;
                         dmem_stb_o       <= 1'b1;
                         dmem_cyc_o       <= 1'b1;
                         mem_store_q      <= 1'b1;
                     end
                     2'b10 :
                     begin
                         dmem_data_out_o  <= {16'h0000,reg_rb_r[15:0]};
                         dmem_sel_o       <= 4'b0011;
                         dmem_we_o        <= 1'b1;
                         dmem_stb_o       <= 1'b1;
                         dmem_cyc_o       <= 1'b1;
                         mem_store_q      <= 1'b1;
                     end
                     default :
                        ;
                 endcase
            end

            inst_sw_w: // l.sw
            begin
                 dmem_addr_o      <= mem_addr_r;
                 dmem_data_out_o  <= reg_rb_r;
                 dmem_sel_o       <= 4'b1111;
                 dmem_we_o        <= 1'b1;
                 dmem_stb_o       <= 1'b1;
                 dmem_cyc_o       <= 1'b1;
                 mem_access_q     <= 1'b1;
                 mem_store_q      <= 1'b1;

  `ifdef CONF_CORE_DEBUG
                 $display(" Store R%d to 0x%08x = 0x%08x", reg_rb_i, {mem_addr_r[31:2],2'b00}, reg_rb_r);
  `endif
            end
            default:
                ;
         endcase
       end
   end
end

//-----------------------------------------------------------------
// Execute: Misc operations
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       icache_flush_o       <= 1'b0; 
       dcache_flush_o       <= 1'b0;
   end
   else
   begin
       icache_flush_o       <= 1'b0; 
       dcache_flush_o       <= 1'b0;            

       //---------------------------------------------------------------
       // Valid instruction
       //---------------------------------------------------------------
       if (execute_inst_r & ~stall_inst_r)
       begin
          case (1'b1)
          inst_mtspr_w: // l.mtspr
          begin
               case (mxspr_uint16_r)
                   // SR - Supervision register
                   `SPR_REG_SR:
                   begin
                       // Cache flush request?
                       icache_flush_o <= reg_rb_r[`SR_ICACHE_FLUSH];
                       dcache_flush_o <= reg_rb_r[`SR_DCACHE_FLUSH];
                   end
               endcase
          end
          default:
              ;
         endcase
       end
   end
end

//-----------------------------------------------------------------
// Execute: NOP (simulation) operations
//-----------------------------------------------------------------
`ifdef SIMULATION
    always @ (posedge clk_i or posedge rst_i)
    begin
       if (rst_i == 1'b1)
       begin
    `ifdef SIM_EXT_PUTC
          putc_q                <= 8'b0;
    `endif
       end
       else
       begin
    `ifdef SIM_EXT_PUTC
          putc_q                <= 8'b0;
    `endif   
           //---------------------------------------------------------------
           // Valid instruction
           //---------------------------------------------------------------
           if (execute_inst_r & ~stall_inst_r)
           begin

               case (1'b1)
               inst_nop_w: // l.nop
                begin
                    case (uint16_r)
                    // NOP_PUTC
                    16'h0004:
                    begin
      `ifdef SIM_EXT_PUTC
                      putc_q  <= reg_ra_r[7:0];
      `else    
                      $write("%c", reg_ra_r[7:0]);
      `endif              
                    end
                    // NOP
                    16'h0000: ;
                    endcase
                end
                default:
                    ;
             endcase
           end
       end
    end
`endif

//-------------------------------------------------------------------
// Assignments
//-------------------------------------------------------------------

assign branch_pc_o          = pc_branch_q;
assign branch_o             = pc_fetch_q;
assign stall_o              = stall_inst_r;

assign opcode_o             = ex_opcode_q;
assign opcode_pc_o          = ex_opcode_pc_q;

assign reg_rd_o             = ex_rd_q;
assign reg_rd_value_o       = ex_result_w;

assign mult_res_o           = 64'b0;

//-------------------------------------------------------------------
// Hooks for debug
//-------------------------------------------------------------------
`ifdef verilator
   function [31:0] get_opcode_ex;
      // verilator public
      get_opcode_ex = ex_opcode_q;
   endfunction
   function [31:0] get_pc_ex;
      // verilator public
      get_pc_ex = ex_opcode_pc_q;
   endfunction   
   function [7:0] get_putc;
      // verilator public
   `ifdef SIM_EXT_PUTC
      get_putc = putc_q;
   `else
      get_putc = 8'b0;
   `endif      
   endfunction
   function [0:0] get_reg_valid;
      // verilator public
      get_reg_valid = ~(resolve_failed_w | load_stall_w | ~opcode_valid_i);
   endfunction
   function [4:0] get_reg_ra;
      // verilator public
      get_reg_ra = reg_ra_i;
   endfunction
   function [31:0] get_reg_ra_value;
      // verilator public
      get_reg_ra_value = ra_resolved_w;
   endfunction
   function [4:0] get_reg_rb;
      // verilator public
      get_reg_rb = reg_rb_i;
   endfunction   
   function [31:0] get_reg_rb_value;
      // verilator public
      get_reg_rb_value = rb_resolved_w;
   endfunction
`endif

endmodule
