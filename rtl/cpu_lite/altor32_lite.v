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
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"

//-----------------------------------------------------------------
// Module - Simple AltOR32 (non-pipelined, small, single WB interface)
//-----------------------------------------------------------------
module altor32_lite
(
    // General
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Maskable interrupt    
    input               intr_i /*verilator public*/,

    // Unmaskable interrupt
    input               nmi_i /*verilator public*/,

    // Enable core
    input               enable_i /*verilator public*/,

    // Fault
    output reg          fault_o /*verilator public*/,

    // Breakpoint / Trap
    output reg          break_o /*verilator public*/,

    // Memory interface
    output reg [31:0]   mem_addr_o /*verilator public*/,
    input [31:0]        mem_dat_i /*verilator public*/,
    output reg [31:0]   mem_dat_o /*verilator public*/,
    output [2:0]        mem_cti_o /*verilator public*/,
    output reg          mem_cyc_o /*verilator public*/,
    output reg          mem_stb_o /*verilator public*/,
    output reg          mem_we_o /*verilator public*/,
    output reg [3:0]    mem_sel_o /*verilator public*/,
    input               mem_stall_i/*verilator public*/,
    input               mem_ack_i/*verilator public*/ 
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter           BOOT_VECTOR         = 32'h00000000;
parameter           ISR_VECTOR          = 32'h00000000;
parameter           REGISTER_FILE_TYPE  = "SIMULATION";
parameter           SUPPORT_32REGS      = "ENABLED";

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------

// PC
reg [31:0]  pc_q;

// Exception saved program counter
reg [31:0]  epc_q;

// Supervisor register
reg [31:0]  sr_q;

// Exception saved supervisor register
reg [31:0]  esr_q;

// Destination register number (post execute stage)
reg [4:0]   ex_rd_q;

// ALU input A
reg [31:0]  ex_alu_a_q;

// ALU input B
reg [31:0]  ex_alu_b_q;

// ALU output
wire [31:0] ex_result_w;

// ALU Carry
wire        alu_carry_out_w;
wire        alu_carry_update_w;

// ALU Comparisons
wire        compare_equal_w;
wire        compare_gts_w;
wire        compare_gt_w;
wire        compare_lts_w;
wire        compare_lt_w;
wire        alu_flag_update_w;

// ALU operation selection
reg [3:0]   ex_alu_func_q;

// Delayed NMI
reg         nmi_q;

// SIM PUTC
`ifdef SIM_EXT_PUTC
    reg [7:0] putc_q;
`endif

wire [4:0]  ra_w;
wire [4:0]  rb_w;
wire [4:0]  rd_w;

wire [31:0] reg_ra_w;
wire [31:0] reg_rb_w;

reg [31:0]  opcode_q;

reg [31:0]  load_result_r;

reg [1:0]   mem_offset_q;

// Current state
parameter STATE_IDLE        = 0;
parameter STATE_FETCH       = 1;
parameter STATE_FETCH_WAIT  = 2;
parameter STATE_EXEC        = 3;
parameter STATE_MEM         = 4;
parameter STATE_WRITE_BACK  = 5;

reg [3:0]   state_q;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------

// ALU
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

// Writeback result
wire [31:0] w_write_res     = (state_q == STATE_MEM) ? load_result_r : ex_result_w;

// Writeback enable
wire        w_write_en      = (state_q == STATE_MEM & mem_ack_i) | (state_q == STATE_WRITE_BACK);

//-----------------------------------------------------------------
// [Xilinx] Register file
//-----------------------------------------------------------------
generate
if (REGISTER_FILE_TYPE == "XILINX")
begin : REGFILE_XIL
    altor32_regfile_xil
    #(
        .SUPPORT_32REGS(SUPPORT_32REGS)
    )
    reg_bank
    (
        // Clocking
        .clk_i(clk_i),
        .rst_i(rst_i),
        .wr_i(w_write_en),

        // Tri-port
        .ra_i(ra_w),
        .rb_i(rb_w),
        .rd_i(ex_rd_q),
        .reg_ra_o(reg_ra_w),
        .reg_rb_o(reg_rb_w),
        .reg_rd_i(w_write_res)
    );
end
//-----------------------------------------------------------------
// [Altera] Register file
//-----------------------------------------------------------------
else if (REGISTER_FILE_TYPE == "ALTERA")
begin : REGFILE_ALT
    altor32_regfile_alt
    #(
        .SUPPORT_32REGS(SUPPORT_32REGS)
    )    
    reg_bank
    (
        // Clocking
        .clk_i(clk_i),
        .rst_i(rst_i),
        .wr_i(w_write_en),

        // Tri-port
        .ra_i(ra_w),
        .rb_i(rb_w),
        .rd_i(ex_rd_q),
        .reg_ra_o(reg_ra_w),
        .reg_rb_o(reg_rb_w),
        .reg_rd_i(w_write_res)
    );
end
//-----------------------------------------------------------------
// [Simulation] Register file
//-----------------------------------------------------------------
else
begin : REGFILE_SIM
    altor32_regfile_sim
    #(
        .SUPPORT_32REGS(SUPPORT_32REGS)
    )
    reg_bank
    (
        // Clocking
        .clk_i(clk_i),
        .rst_i(rst_i),
        .wr_i(w_write_en),

        // Tri-port
        .ra_i(ra_w),
        .rb_i(rb_w),
        .rd_i(ex_rd_q),
        .reg_ra_o(reg_ra_w),
        .reg_rb_o(reg_rb_w),
        .reg_rd_i(w_write_res)
    );
end
endgenerate

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
    inst_r               = {2'b00,opcode_q[31:26]};

    // Sub instructions
    alu_op_r             = {opcode_q[9:6],opcode_q[3:0]};
    sfxx_op_r            = {5'b00,opcode_q[31:21]} & `INST_OR32_SFMASK;
    shift_op_r           = opcode_q[7:6];

    // Branch target
    target_int26_r       = sign_extend_imm26(opcode_q[25:0]);

    // Store immediate
    store_int32_r        = sign_extend_imm16({opcode_q[25:21],opcode_q[10:0]});

    // Signed & unsigned imm -> 32-bits
    uint16_r             = opcode_q[15:0];
    int32_r              = sign_extend_imm16(opcode_q[15:0]);
    uint32_r             = extend_imm16(opcode_q[15:0]);

    // Register values [ra/rb]
    reg_ra_r             = reg_ra_w;
    reg_rb_r             = reg_rb_w;

    // Shift ammount (from register[rb])
    shift_rb_r           = {26'b00,reg_rb_w[5:0]};

    // Shift ammount (from immediate)
    shift_imm_r          = {26'b00,opcode_q[5:0]};

    // MTSPR/MFSPR operand
    mxspr_uint16_r       = (reg_ra_w[15:0] | {5'b00000,opcode_q[10:0]});
end

//-----------------------------------------------------------------
// Instruction Decode
//-----------------------------------------------------------------
wire inst_add_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_ADD);  // l.add
wire inst_addc_w    = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_ADDC); // l.addc
wire inst_and_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_AND);  // l.and
wire inst_or_w      = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_OR);   // l.or
wire inst_sll_w     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_SLL);  // l.sll
wire inst_sw_ra     = (inst_r == `INST_OR32_ALU) & (alu_op_r == `INST_OR32_SRA);  // l.sra
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

wire inst_sys_w     = (inst_r == `INST_OR32_MISC) & (opcode_q[31:24] == `INST_OR32_SYS);  // l.sys
wire inst_trap_w    = (inst_r == `INST_OR32_MISC) & (opcode_q[31:24] == `INST_OR32_TRAP); // l.trap

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
// Next State Logic
//-----------------------------------------------------------------
reg [3:0] next_state_r;
always @ *
begin
    next_state_r = state_q;

    case (state_q)    
    //-----------------------------------------
    // IDLE - 
    //-----------------------------------------
    STATE_IDLE :
    begin
        if (enable_i)
            next_state_r    = STATE_FETCH;
    end    
    //-----------------------------------------
    // FETCH - Fetch line from memory
    //-----------------------------------------
    STATE_FETCH :
    begin
        next_state_r    = STATE_FETCH_WAIT;
    end
    //-----------------------------------------
    // FETCH_WAIT - Wait for read responses
    //-----------------------------------------
    STATE_FETCH_WAIT:
    begin
        // Read from memory complete
        if (mem_ack_i)
            next_state_r = STATE_EXEC;
    end  
    //-----------------------------------------
    // EXEC
    //-----------------------------------------
    STATE_EXEC :
    begin
        if (load_inst_r || store_inst_r)
            next_state_r    = STATE_MEM;
        else
            next_state_r    = STATE_WRITE_BACK;
    end
    //-----------------------------------------
    // MEM
    //-----------------------------------------
    STATE_MEM :
    begin
        // Read from memory complete
        if (mem_ack_i)
            next_state_r = STATE_FETCH;
    end    
    //-----------------------------------------
    // WRITE_BACK
    //-----------------------------------------
    STATE_WRITE_BACK :
    begin
        if (enable_i)
            next_state_r    = STATE_FETCH;
    end    
    default:
        ;
   endcase
end

// Update state
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        state_q   <= STATE_IDLE;
   else
        state_q   <= next_state_r;
end

//-----------------------------------------------------------------
// Memory Access / Instruction Fetch
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        mem_addr_o      <= 32'h00000000;        
        mem_dat_o       <= 32'h00000000;
        mem_sel_o       <= 4'b0;
        mem_we_o        <= 1'b0;
        mem_stb_o       <= 1'b0;
        mem_cyc_o       <= 1'b0;

        opcode_q        <= 32'h00000000;
        mem_offset_q    <= 2'b0;
   end
   else
   begin
   
        if (~mem_stall_i)
            mem_stb_o    <= 1'b0;
        
        case (state_q)

            //-----------------------------------------
            // FETCH - Issue instruction fetch
            //-----------------------------------------
            STATE_FETCH :
            begin
                // Start fetch from memory
                mem_addr_o  <= pc_q;
                mem_stb_o   <= 1'b1;
                mem_we_o    <= 1'b0;
                mem_cyc_o   <= 1'b1;
            end
            //-----------------------------------------
            // FETCH_WAIT - Wait for response
            //-----------------------------------------
            STATE_FETCH_WAIT :
            begin
                // Data ready from memory?
                if (mem_ack_i)
                begin
                    opcode_q    <= mem_dat_i;
                    mem_cyc_o   <= 1'b0;                            
                end
            end
            //-----------------------------------------
            // EXEC - Issue read / write
            //-----------------------------------------            
            STATE_EXEC :
            begin
            `ifdef CONF_CORE_TRACE
                $display("%08x: Execute 0x%08x", pc_q, opcode_q);
                $display(" rA[%d] = 0x%08x", ra_w, reg_ra_r);
                $display(" rB[%d] = 0x%08x", rb_w, reg_rb_r);
            `endif

                case (1'b1)
                 // l.lbs l.lhs l.lws l.lbz l.lhz l.lwz
                 load_inst_r:
                 begin
                     mem_addr_o      <= {mem_addr_r[31:2], 2'b0};
                     mem_offset_q    <= mem_addr_r[1:0];
                     mem_dat_o       <= 32'h00000000;
                     mem_sel_o       <= 4'b1111;
                     mem_we_o        <= 1'b0;
                     mem_stb_o       <= 1'b1;
                     mem_cyc_o       <= 1'b1;   

      `ifdef CONF_CORE_DEBUG
                     $display(" Load from 0x%08x to R%d", mem_addr_r, rd_w);
      `endif
                 end

                 inst_sb_w: // l.sb
                 begin
                     mem_addr_o      <= {mem_addr_r[31:2], 2'b0};
                     mem_offset_q    <= mem_addr_r[1:0];
                     case (mem_addr_r[1:0])
                         2'b00 :
                         begin
                             mem_dat_o       <= {reg_rb_r[7:0],24'h000000};
                             mem_sel_o       <= 4'b1000;
                             mem_we_o        <= 1'b1;
                             mem_stb_o       <= 1'b1;
                             mem_cyc_o       <= 1'b1;
                         end
                         2'b01 :
                         begin
                             mem_dat_o       <= {{8'h00,reg_rb_r[7:0]},16'h0000};
                             mem_sel_o       <= 4'b0100;
                             mem_we_o        <= 1'b1;
                             mem_stb_o       <= 1'b1;
                             mem_cyc_o       <= 1'b1;
                         end
                         2'b10 :
                         begin
                             mem_dat_o       <= {{16'h0000,reg_rb_r[7:0]},8'h00};
                             mem_sel_o       <= 4'b0010;
                             mem_we_o        <= 1'b1;
                             mem_stb_o       <= 1'b1;
                             mem_cyc_o       <= 1'b1;
                         end
                         2'b11 :
                         begin
                             mem_dat_o       <= {24'h000000,reg_rb_r[7:0]};
                             mem_sel_o       <= 4'b0001;
                             mem_we_o        <= 1'b1;
                             mem_stb_o       <= 1'b1;
                             mem_cyc_o       <= 1'b1;
                         end
                         default :
                            ;
                     endcase
                 end

                inst_sh_w: // l.sh
                begin
                     mem_addr_o      <= {mem_addr_r[31:2], 2'b0};
                     mem_offset_q    <= mem_addr_r[1:0];
                     case (mem_addr_r[1:0])
                         2'b00 :
                         begin
                             mem_dat_o       <= {reg_rb_r[15:0],16'h0000};
                             mem_sel_o       <= 4'b1100;
                             mem_we_o        <= 1'b1;
                             mem_stb_o       <= 1'b1;
                             mem_cyc_o       <= 1'b1;
                         end
                         2'b10 :
                         begin
                             mem_dat_o       <= {16'h0000,reg_rb_r[15:0]};
                             mem_sel_o       <= 4'b0011;
                             mem_we_o        <= 1'b1;
                             mem_stb_o       <= 1'b1;
                             mem_cyc_o       <= 1'b1;
                         end
                         default :
                            ;
                     endcase
                end

                inst_sw_w: // l.sw
                begin
                     mem_addr_o      <= {mem_addr_r[31:2], 2'b0};
                     mem_offset_q    <= mem_addr_r[1:0];
                     mem_dat_o       <= reg_rb_r;
                     mem_sel_o       <= 4'b1111;
                     mem_we_o        <= 1'b1;
                     mem_stb_o       <= 1'b1;
                     mem_cyc_o       <= 1'b1;

      `ifdef CONF_CORE_DEBUG
                     $display(" Store R%d to 0x%08x = 0x%08x", rb_w, {mem_addr_r[31:2],2'b00}, reg_rb_r);
      `endif
                end
                default:
                    ;
             endcase
            end
            //-----------------------------------------
            // MEM - Wait for response
            //-----------------------------------------
            STATE_MEM :
            begin
                // Data ready from memory?
                if (mem_ack_i)
                begin
                    mem_cyc_o   <= 1'b0;
                end
            end            
            default:
                ;
           endcase
   end
end

assign mem_cti_o        = 3'b111;

// If simulation, RA = 03 if NOP instruction
`ifdef SIMULATION
    wire [7:0] v_fetch_inst = {2'b00, opcode_q[31:26]};
    wire       v_is_nop     = (v_fetch_inst == `INST_OR32_NOP);
    assign     ra_w         = v_is_nop ? 5'd3 : opcode_q[20:16];
`else
    assign     ra_w         = opcode_q[20:16];
`endif

assign rb_w        = opcode_q[15:11];
assign rd_w        = opcode_q[25:21];

//-----------------------------------------------------------------
// Next PC
//-----------------------------------------------------------------
reg [31:0]  next_pc_r;

always @ *
begin
    // Next expected PC (current PC + 4)
    next_pc_r  = (pc_q + 4);
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
        next_sr_r[`SR_F]           = compare_result_r;

    // Latch carry if updated
    if (alu_carry_update_w)
        next_sr_r[`SR_CY]          = alu_carry_out_w;

    case (1'b1)
      inst_mtspr_w:
      begin
          case (mxspr_uint16_r)
          // SR - Supervision register
          `SPR_REG_SR:
          begin
              next_sr_r[`SR_F]     = reg_rb_r[`SR_F];
              next_sr_r[`SR_CY]    = reg_rb_r[`SR_CY];
              next_sr_r[`SR_IEE]   = reg_rb_r[`SR_IEE];
          end
          default:
            ;        
          endcase
      end
      inst_rfe_w:
      begin
          next_sr_r[`SR_F]         = esr_q[`SR_F];
          next_sr_r[`SR_CY]        = esr_q[`SR_CY];
          next_sr_r[`SR_IEE]       = esr_q[`SR_IEE];
      end          
      inst_sfxx_w,
      inst_sfxxi_w:
           next_sr_r[`SR_F]        = compare_result_r;
      default:
        ;
    endcase
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

     inst_sw_ra: // l.sra
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

     inst_mul_w,   // l.mul
     inst_mulu_w:  // l.mulu
     begin
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
               alu_input_a_r           = 32'b0;
               alu_input_a_r[`SR_F]    = next_sr_r[`SR_F];
               alu_input_a_r[`SR_CY]   = next_sr_r[`SR_CY];
               alu_input_a_r[`SR_IEE]  = next_sr_r[`SR_IEE];
               write_rd_r              = 1'b1;
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
               alu_input_a_r           = 32'b0;
               alu_input_a_r[`SR_F]    = esr_q[`SR_F];
               alu_input_a_r[`SR_CY]   = esr_q[`SR_CY];
               alu_input_a_r[`SR_IEE]  = esr_q[`SR_IEE];
               write_rd_r              = 1'b1;
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

     // l.lbs l.lhs l.lws l.lbz l.lhz l.lwz
     inst_lbs_w,
     inst_lhs_w,
     inst_lws_w,
     inst_lbz_w,
     inst_lhz_w,
     inst_lwz_w:
          write_rd_r    = 1'b1;

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
// Comparisons
//-----------------------------------------------------------------
always @ *
begin
    case (1'b1)
    inst_sfges_w: // l.sfges
        compare_result_r = compare_gts_w | compare_equal_w;

    inst_sfgeu_w: // l.sfgeu
        compare_result_r = compare_gt_w | compare_equal_w;

    inst_sfgts_w: // l.sfgts
        compare_result_r = compare_gts_w;

    inst_sfgtu_w: // l.sfgtu
        compare_result_r = compare_gt_w;

    inst_sfles_w: // l.sfles
        compare_result_r = compare_lts_w | compare_equal_w;

    inst_sfleu_w: // l.sfleu
        compare_result_r = compare_lt_w | compare_equal_w;

    inst_sflts_w: // l.sflts
        compare_result_r = compare_lts_w;

    inst_sfltu_w: // l.sfltu
        compare_result_r = compare_lt_w;

    inst_sfne_w: // l.sfne
        compare_result_r = ~compare_equal_w;

    default: // l.sfeq
        compare_result_r = compare_equal_w;
    endcase    
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
    branch_target_r = (pc_q + {target_int26_r[29:0],2'b00});    

    case (1'b1)
    inst_bf_w: // l.bf
        branch_r      = sr_q[`SR_F];

    inst_bnf_w: // l.bnf
        branch_r      = ~sr_q[`SR_F];

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
       inst_sw_ra,
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
           // Update ALU input flops
           ex_alu_func_q         <= alu_func_r;
           ex_alu_a_q            <= alu_input_a_r;
           ex_alu_b_q            <= alu_input_b_r;

           // Branch and link (Rd = LR/R9)
           if (branch_link_r)
              ex_rd_q            <= 5'd9;           
           // Instruction with register writeback
           else if (write_rd_r)
              ex_rd_q            <= rd_w;
           else
              ex_rd_q            <= 5'b0;
   end
end

//-----------------------------------------------------------------
// Execute: Branch / exceptions
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       pc_q                 <= BOOT_VECTOR + `VECTOR_RESET;

       // Status registers
       epc_q                <= 32'h00000000;
       sr_q                 <= 32'h00000000;
       esr_q                <= 32'h00000000;

       fault_o              <= 1'b0;

       nmi_q                <= 1'b0;
   end
   else
   begin
      // Record NMI in-case it can't be processed this cycle
      if (nmi_i)
          nmi_q             <= 1'b1;

       // Core disabled?
       if (~enable_i)
       begin
           // Reset
           pc_q                 <= BOOT_VECTOR + `VECTOR_RESET;

           // Status registers
           epc_q                <= 32'h00000000;
           sr_q                 <= 32'h00000000;
           esr_q                <= 32'h00000000;

           fault_o              <= 1'b0;

           nmi_q                <= 1'b0;
       end
       // Write-back?
       else if (w_write_en)
       begin
           // Update SR
           sr_q                 <= next_sr_r;

           // Exception: Instruction opcode not valid / supported, invalid PC
           if (invalid_inst_r || (pc_q[1:0] != 2'b00))
           begin
                // Save PC of next instruction
                epc_q       <= next_pc_r;
                esr_q       <= next_sr_r;

                // Disable further interrupts
                sr_q        <= 32'b0;

                // Set PC to exception vector
                if (invalid_inst_r)
                    pc_q    <= ISR_VECTOR + `VECTOR_ILLEGAL_INST;
                else
                    pc_q    <= ISR_VECTOR + `VECTOR_BUS_ERROR;

                fault_o     <= 1'b1;
           end       
           // Exception: Syscall / Break
           else if (branch_except_r)
           begin
                // Save PC of next instruction
                epc_q       <= next_pc_r;
                esr_q       <= next_sr_r;

                // Disable further interrupts
                sr_q        <= 32'b0;

                // Set PC to exception vector
                pc_q        <= branch_target_r;
                
    `ifdef CONF_CORE_DEBUG
               $display(" Exception 0x%08x", branch_target_r);
    `endif
           end
           // Non-maskable interrupt
           else if (nmi_i | nmi_q)
           begin
                nmi_q       <= 1'b0;

                // Save PC of next instruction
                if (branch_r)
                    epc_q   <= branch_target_r;
                // Next expected PC (current PC + 4)
                else
                    epc_q   <= next_pc_r;

                esr_q       <= next_sr_r;

                // Disable further interrupts
                sr_q        <= 32'b0;

                // Set PC to exception vector
                pc_q        <= ISR_VECTOR + `VECTOR_NMI;
                
    `ifdef CONF_CORE_DEBUG
               $display(" NMI 0x%08x", ISR_VECTOR + `VECTOR_NMI);
    `endif
           end       
           // External interrupt
           else if (intr_i && next_sr_r[`SR_IEE])
           begin
                // Save PC of next instruction & SR
                if (branch_r)
                    epc_q   <= branch_target_r;
                // Next expected PC (current PC + 4)
                else
                    epc_q   <= next_pc_r;

                esr_q       <= next_sr_r;

                // Disable further interrupts
                sr_q        <= 32'b0;

                // Set PC to external interrupt vector
                pc_q        <= ISR_VECTOR + `VECTOR_EXTINT;
                
    `ifdef CONF_CORE_DEBUG
               $display(" External Interrupt 0x%08x", ISR_VECTOR + `VECTOR_EXTINT);
    `endif
           end        
           // Branch (l.bf, l.bnf, l.j, l.jal, l.jr, l.jalr, l.rfe)
           else if (branch_r)
           begin
                // Perform branch
                pc_q        <= branch_target_r;
               
    `ifdef CONF_CORE_DEBUG
               $display(" Branch to 0x%08x", branch_target_r);
    `endif
           end
           // Non branch
           else
           begin
                // Update EPC / ESR which may have been updated
                // by an MTSPR write
                pc_q           <= next_pc_r;
                epc_q          <= next_epc_r;
                esr_q          <= next_esr_r;
           end
      end
   end
end

//-------------------------------------------------------------------
// Load result
//-------------------------------------------------------------------
always @ *
begin
    load_result_r   = 32'h00000000;

    case (1'b1)

        inst_lbs_w, // l.lbs
        inst_lbz_w: // l.lbz
        begin
            case (mem_offset_q)
                2'b00 :   load_result_r[7:0] = mem_dat_i[31:24];
                2'b01 :   load_result_r[7:0] = mem_dat_i[23:16];
                2'b10 :   load_result_r[7:0] = mem_dat_i[15:8];
                2'b11 :   load_result_r[7:0] = mem_dat_i[7:0];
                default : ;
            endcase
        
            // Sign extend LB
            if (inst_lbs_w && load_result_r[7])
                load_result_r[31:8] = 24'hFFFFFF;
        end
        
        inst_lhs_w, // l.lhs
        inst_lhz_w: // l.lhz
        begin
            case (mem_offset_q)
                2'b00 :   load_result_r[15:0] = mem_dat_i[31:16];
                2'b10 :   load_result_r[15:0] = mem_dat_i[15:0];
                default : ;                
            endcase

            // Sign extend LH
            if (inst_lhs_w && load_result_r[15])
                load_result_r[31:16] = 16'hFFFF;
        end

        // l.lwz l.lws
        default :
            load_result_r   = mem_dat_i;
    endcase  
end

//-----------------------------------------------------------------
// Execute: Misc operations
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       break_o              <= 1'b0;
   end
   else
   begin
       break_o              <= 1'b0;

       case (1'b1)
       inst_trap_w: // l.trap
            break_o         <= 1'b1;
       default:
          ;
      endcase
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
          if (inst_nop_w && state_q == STATE_EXEC)
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
       end
    end
`endif

`include "altor32_funcs.v"

//-------------------------------------------------------------------
// Hooks for debug
//-------------------------------------------------------------------
`ifdef verilator
   function [31:0] get_opcode_ex;
      // verilator public
      get_opcode_ex = (state_q == STATE_EXEC) ? opcode_q : `OPCODE_INST_BUBBLE;
   endfunction
   function [31:0] get_pc_ex;
      // verilator public
      get_pc_ex = pc_q;
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
      get_reg_valid = (state_q == STATE_EXEC) ? 1'b1 : 1'b0;
   endfunction
   function [4:0] get_reg_ra;
      // verilator public
      get_reg_ra = ra_w;
   endfunction
   function [31:0] get_reg_ra_value;
      // verilator public
      get_reg_ra_value = reg_ra_w;
   endfunction
   function [4:0] get_reg_rb;
      // verilator public
      get_reg_rb = rb_w;
   endfunction   
   function [31:0] get_reg_rb_value;
      // verilator public
      get_reg_rb_value = reg_rb_w;
   endfunction
`endif

endmodule
