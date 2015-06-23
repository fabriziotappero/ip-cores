//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
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
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "or32_isa.h"
#include "or32_inst_dump.h"

//-----------------------------------------------------------------
// or32_instruction_to_string: Decode instruction to string
//-----------------------------------------------------------------
int or32_instruction_to_string(TRegister opcode, char *output, int max_len)
{
    TRegister v_ra = 0;
    TRegister v_rb = 0;
    TRegister v_rd = 0;
    TRegister v_inst = 0;
    TRegister v_op = 0;
    TRegister v_target = 0;
    TRegister v_pc = 0;
    TRegister v_pc_next = 0;
    TRegister v_imm = 0;
    TRegister v_imm_uint32 = 0;
    TRegister v_imm_int32 = 0;
    TRegister v_offset = 0;
    TRegister v_store_imm = 0;
    int v_branch = 0;
    int v_jmp = 0;

    TRegister v_alu_op = 0;
    TRegister v_shift_op = 0;
    TRegister v_sfxx_op = 0;

    // Decode opcode
    v_inst      = (opcode >> OR32_OPCODE_SHIFT) & OR32_OPCODE_MASK;
    v_rd        = (opcode >> OR32_REG_D_SHIFT) & OR32_REG_D_MASK;
    v_ra        = (opcode >> OR32_REG_A_SHIFT) & OR32_REG_A_MASK;
    v_rb        = (opcode >> OR32_REG_B_SHIFT) & OR32_REG_B_MASK;
    v_imm       = (opcode >> OR32_IMM16_SHIFT) & OR32_IMM16_MASK;
    v_target    = (opcode >> OR32_ADDR_SHIFT) & OR32_ADDR_MASK;
    v_sfxx_op   = (opcode >> OR32_SFXXX_OP_SHIFT) & OR32_SFXXX_OP_MASK;
    v_alu_op    = (opcode >> OR32_ALU_OP_L_SHIFT) & OR32_ALU_OP_L_MASK;
    v_alu_op   |= (opcode >> OR32_ALU_OP_H_SHIFT) & OR32_ALU_OP_H_MASK;
    v_shift_op  = (opcode >> OR32_SHIFT_OP_SHIFT) & OR32_SHIFT_OP_MASK;
    v_store_imm = (opcode >> OR32_STORE_IMM_L_SHIFT) & OR32_STORE_IMM_L_MASK;
    v_store_imm|= (opcode >> OR32_STORE_IMM_H_SHIFT) & OR32_STORE_IMM_H_MASK;

    // Sign extend store immediate
    v_store_imm = (unsigned int)(signed short)v_store_imm;

    // Sign extend target immediate
    if (v_target & (1 << 25))
        v_target |= ~OR32_ADDR_MASK;

    // Signed & unsigned imm -> 32-bits
    v_imm_int32 = (unsigned int)(signed short)v_imm;
    v_imm_uint32 = v_imm;

    output[0] = 0;

    // Execute instruction
    switch(v_inst)
    {
        case INST_OR32_ALU:
            switch (v_alu_op)
            {
                case INST_OR32_ADD: // l.add
                    sprintf(output, "l.add   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_ADDC: // l.addc
                    sprintf(output, "l.addc  r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_AND: // l.and
                    sprintf(output, "l.and   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_OR: // l.or
                    sprintf(output, "l.or    r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_SLL: // l.sll
                    sprintf(output, "l.sll   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_SRA: // l.sra
                    sprintf(output, "l.sra   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_SRL: // l.srl
                    sprintf(output, "l.srl   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_SUB: // l.sub
                    sprintf(output, "l.sub   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_XOR: // l.xor
                    sprintf(output, "l.xor   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_MUL: // l.mul
                    sprintf(output, "l.mul   r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
                case INST_OR32_MULU: // l.mulu
                    sprintf(output, "l.mulu  r%d,r%d,r%d", v_rd, v_ra, v_rb);
                break;
            }
        break;

        case INST_OR32_ADDI: // l.addi 
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.addi  r%d,r%d,%d", v_rd, v_ra, v_imm_int32);
            else
                sprintf(output, "l.addi  r%d,r%d,0x%x", v_rd, v_ra, v_imm_int32);
        break;

        case INST_OR32_ANDI: // l.andi
            sprintf(output, "l.andi  r%d,r%d,0x%x", v_rd, v_ra, v_imm_uint32);
        break;

        case INST_OR32_BF: // l.bf
            if ((int)v_target <= 0)
                sprintf(output, "l.bf    %d", (int)v_target);
            else
                sprintf(output, "l.bf    0x%x", (int)v_target);
        break;

        case INST_OR32_BNF: // l.bnf
            if ((int)v_target <= 0)
                sprintf(output, "l.bnf   %d", (int)v_target);
            else
                sprintf(output, "l.bnf   0x%x", (int)v_target);
        break;

        case INST_OR32_J: // l.j
            if ((int)v_target <= 0)
                sprintf(output, "l.j     %d", (int)v_target);
            else
                sprintf(output, "l.j     0x%x", (int)v_target);
        break;

        case INST_OR32_JAL: // l.jal
            if ((int)v_target <= 0)
                sprintf(output, "l.jal   %d", (int)v_target);
            else
                sprintf(output, "l.jal   0x%x", (int)v_target);
        break;

        case INST_OR32_JALR: // l.jalr
            sprintf(output, "l.jalr  r%d", v_rb);
        break;

        case INST_OR32_JR: // l.jr
            sprintf(output, "l.jr    r%d", v_rb);
        break;

        case INST_OR32_LBS: // l.lbs
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.lbs   r%d,%d(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
            else
                sprintf(output, "l.lbs   r%d,0x%x(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
        break;

        case INST_OR32_LHS: // l.lhs
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.lhs   r%d,%d(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
            else
                sprintf(output, "l.lhs   r%d,0x%x(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
        break;

        case INST_OR32_LWS: // l.lws
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.lws   r%d,%d(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
            else
                sprintf(output, "l.lws   r%d,0x%x(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
        break;

        case INST_OR32_LBZ: // l.lbz
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.lbz   r%d,%d(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
            else
                sprintf(output, "l.lbz   r%d,0x%x(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
        break;

        case INST_OR32_LHZ: // l.lhz
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.lhz   r%d,%d(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
            else
                sprintf(output, "l.lhz   r%d,0x%x(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
        break;

        case INST_OR32_LWZ: // l.lwz
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.lwz   r%d,%d(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
            else
                sprintf(output, "l.lwz   r%d,0x%x(r%d)", v_rd, (int)v_imm_int32, v_ra, v_rd);
        break;

        case INST_OR32_MFSPR: // l.mfspr
        break;

        case INST_OR32_MOVHI: // l.movhi
            if (v_imm_uint32 == 0)
                sprintf(output, "l.movhi r%d,%d", v_rd, v_imm_uint32);
            else
                sprintf(output, "l.movhi r%d,0x%x", v_rd, v_imm_uint32);
        break;

        case INST_OR32_MTSPR: // l.mtspr
        break;

        case INST_OR32_NOP: // l.nop
            if (v_imm != 0)
                sprintf(output, "l.nop   0x%x", v_imm);
            else
                sprintf(output, "l.nop   0");
        break;

        case INST_OR32_ORI: // l.ori
            if (v_imm_uint32 == 0)
                sprintf(output, "l.ori   r%d,r%d,%d", v_rd, v_ra, v_imm_uint32);
            else
                sprintf(output, "l.ori   r%d,r%d,0x%x", v_rd, v_ra, v_imm_uint32);
        break;

        case INST_OR32_RFE: // l.rfe
            sprintf(output, "l.rfe");
        break;

        case INST_OR32_SHIFTI:
            switch (v_shift_op)
            {
                case INST_OR32_SLLI: // l.slli
                    sprintf(output, "l.slli  r%d,r%d,0x%x", v_rd, v_ra, (opcode & 0x3F));
                break;
                case INST_OR32_SRAI: // l.srai
                    sprintf(output, "l.srai  r%d,r%d,0x%x", v_rd, v_ra, (opcode & 0x3F));
                break;
                case INST_OR32_SRLI: // l.srli
                    sprintf(output, "l.srli  r%d,r%d,0x%x", v_rd, v_ra, (opcode & 0x3F));
                break;
            }
        break;

        case INST_OR32_SB: // l.sb
            if ((int)v_store_imm < 0)
                sprintf(output, "l.sb    %d(r%d),r%d", (int)v_store_imm, v_ra, v_rb);
            else
                sprintf(output, "l.sb    0x%x(r%d),r%d", (int)v_store_imm, v_ra, v_rb);
        break;

        case INST_OR32_SFXX:
        case INST_OR32_SFXXI:
            switch (v_sfxx_op)
            {
                case INST_OR32_SFEQ: // l.sfeq
                    sprintf(output, "l.sfeq  r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFEQI: // l.sfeqi
                    sprintf(output, "l.sfeqi r%d,0x%x", v_ra, (int)v_imm_int32);
                break;
                case INST_OR32_SFGES: // l.sfges
                    sprintf(output, "l.sfges r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFGESI: // l.sfgesi
                    sprintf(output, "l.sfgesi r%d,0x%x", v_ra, (int)v_imm_int32);
                break;
                case INST_OR32_SFGEU: // l.sfgeu
                    sprintf(output, "l.sfgeu r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFGEUI: // l.sfgeui
                    sprintf(output, "l.sfgeui r%d,0x%x", v_ra, v_imm_uint32);
                break;
                case INST_OR32_SFGTS: // l.sfgts
                    sprintf(output, "l.sfgts r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFGTSI: // l.sfgtsi
                    sprintf(output, "l.sfgtsi r%d,0x%x", v_ra, (int)v_imm_int32);
                break;
                case INST_OR32_SFGTU: // l.sfgtu
                    sprintf(output, "l.sfgtu r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFGTUI: // l.sfgtui
                    sprintf(output, "l.sfgtui r%d,0x%x", v_ra, v_imm_uint32);
                break;
                case INST_OR32_SFLES: // l.sfles
                    sprintf(output, "l.sfles r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFLESI: // l.sflesi
                    sprintf(output, "l.sflesi r%d,0x%x", v_ra, (int)v_imm_int32);
                break;
                case INST_OR32_SFLEU: // l.sfleu
                    sprintf(output, "l.sfleu r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFLEUI: // l.sfleui
                    sprintf(output, "l.sfleui r%d,0x%x", v_ra, v_imm_uint32);
                break;
                case INST_OR32_SFLTS: // l.sflts
                    sprintf(output, "l.sflts r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFLTSI: // l.sfltsi
                    sprintf(output, "l.sfltsi r%d,0x%x", v_ra, (int)v_imm_int32);
                break;
                case INST_OR32_SFLTU: // l.sfltu
                    sprintf(output, "l.sfltu r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFLTUI: // l.sfltui
                    sprintf(output, "l.sfltui r%d,0x%x", v_ra, v_imm_uint32);
                break;
                case INST_OR32_SFNE: // l.sfne
                    sprintf(output, "l.sfne  r%d,r%d", v_ra, v_rb);
                break;
                case INST_OR32_SFNEI: // l.sfnei
                    sprintf(output, "l.sfnei  r%d,0x%x", v_ra, v_imm_uint32);
                break;
            }
        break;

        case INST_OR32_SH: // l.sh
            if ((int)v_store_imm < 0)
                sprintf(output, "l.sh    %d(r%d),r%d", (int)v_store_imm, v_ra, v_rb);
            else
                sprintf(output, "l.sh    0x%x(r%d),r%d", (int)v_store_imm, v_ra, v_rb);
        break;

        case INST_OR32_SW: // l.sw
            if ((int)v_store_imm < 0)
                sprintf(output, "l.sw    %d(r%d),r%d", (int)v_store_imm, v_ra, v_rb);
            else
                sprintf(output, "l.sw    0x%x(r%d),r%d", (int)v_store_imm, v_ra, v_rb);
        break;

        case INST_OR32_MISC: 
            switch (opcode >> 24)
            {
                case INST_OR32_SYS: // l.sys
                    sprintf(output, "l.sys");
                break;

                case INST_OR32_TRAP: // l.trap
                    sprintf(output, "l.trap");
                break;
            }
        break;

        case INST_OR32_XORI: // l.xori
            if ((int)v_imm_int32 < 0)
                sprintf(output, "l.xori  r%d,r%d,%d", v_rd, v_ra, v_imm_int32);
            else
                sprintf(output, "l.xori  r%d,r%d,0x%x", v_rd, v_ra, v_imm_int32);
        break;
   }

   return (output[0] != 0);
}
//-----------------------------------------------------------------
// or32_instruction_to_string: Decode instruction to string
//-----------------------------------------------------------------
void or32_instruction_dump(TRegister pc, TRegister opcode, TRegister gpr[REGISTERS], TRegister rd, TRegister result, TRegister sr)
{
    char output[1024];

    // Decode opcode in-order to perform register reads
    TRegister ra = (opcode >> OR32_REG_A_SHIFT) & OR32_REG_A_MASK;
    TRegister rb = (opcode >> OR32_REG_B_SHIFT) & OR32_REG_B_MASK;
    TRegister v_inst = (opcode >> OR32_OPCODE_SHIFT) & OR32_OPCODE_MASK;

    TRegister v_store_imm = (opcode >> OR32_STORE_IMM_L_SHIFT) & OR32_STORE_IMM_L_MASK;
    v_store_imm|= (opcode >> OR32_STORE_IMM_H_SHIFT) & OR32_STORE_IMM_H_MASK;
    v_store_imm = (unsigned int)(signed short)v_store_imm;

    // Decode instruction in or1ksim trace format
    or32_instruction_to_string(opcode, output, sizeof(output)-1);

    if (rd != 0 && v_inst != INST_OR32_JAL && v_inst != INST_OR32_JALR)
        printf("S %08x: %08x %-23s r%d         = %08x  flag: %d\n", pc, opcode, output, rd, result, sr & OR32_SR_F_BIT ? 1: 0);
    else if (v_inst == INST_OR32_SB || v_inst == INST_OR32_SH || v_inst == INST_OR32_SW)
    {
        if (v_inst == INST_OR32_SB)
            printf("S %08x: %08x %-23s [%08x] = %02x  flag: %d\n", pc, opcode, output, gpr[ra] + (int)v_store_imm, gpr[rb], sr & OR32_SR_F_BIT ? 1: 0);
        else if (v_inst == INST_OR32_SH)
            printf("S %08x: %08x %-23s [%08x] = %04x  flag: %d\n", pc, opcode, output, gpr[ra] + (int)v_store_imm, gpr[rb], sr & OR32_SR_F_BIT ? 1: 0);
        else
            printf("S %08x: %08x %-23s [%08x] = %08x  flag: %d\n", pc, opcode, output, gpr[ra] + (int)v_store_imm, gpr[rb], sr & OR32_SR_F_BIT ? 1: 0);
    }
    else
        printf("S %08x: %08x %-45s  flag: %d\n", pc, opcode, output, sr & OR32_SR_F_BIT ? 1: 0);
}
