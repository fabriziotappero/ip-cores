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
#include "or32.h"

#ifdef INCLUDE_INST_DUMP
    #include "or32_inst_dump.h"
#endif

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define DPRINTF(l,a)        do { if (Trace & l) printf a; } while (0)
#define TRACE_ENABLED(l)    (Trace & l)

#define MEMTRACE_WRITES     "mem_writes.txt"
#define MEMTRACE_READS      "mem_reads.txt"
#define MEMTRACE_INST       "mem_inst.txt"
#define MEMTRACE_MIN        100

#define ADD_CARRY_OUT(a,b)  ((((unsigned long long)(a) + (unsigned long long)(b)) & ((unsigned long long)1 << 32)) != 0)

#define HTONL(n) (((((unsigned int)(n) & 0xFF)) << 24) | \
                ((((unsigned int)(n) & 0xFF00)) << 8) | \
                ((((unsigned int)(n) & 0xFF0000)) >> 8) | \
                ((((unsigned int)(n) & 0xFF000000)) >> 24))

//-----------------------------------------------------------------
// Constructor
//-----------------------------------------------------------------
OR32::OR32(bool delay_slot)
{
    MemRegions = 0;

    int m;
    for (m=0;m<MAX_MEM_REGIONS;m++)
    {
        MemInstHits[m] = NULL;
        MemReadHits[m] = NULL;
        MemWriteHits[m] = NULL;
    }

    MemVectorBase = 0;

    Trace = 0;
    DelaySlotEnabled = delay_slot;
    EnablePutc = true;

    Reset();
}
//-----------------------------------------------------------------
// Constructor
//-----------------------------------------------------------------
OR32::OR32(unsigned int baseAddr, unsigned int len, bool delay_slot)
{
    int m;

    MemBase[0] = baseAddr;
    MemSize[0] = len;

    Mem[0] = new TMemory[(len + 3)/4];
    assert(Mem[0]);
    memset(Mem[0], 0, (len + 3)/4);

    MemRegions = 1;

    for (m=0;m<MAX_MEM_REGIONS;m++)
    {
        MemInstHits[m] = NULL;
        MemReadHits[m] = NULL;
        MemWriteHits[m] = NULL;
    }

    MemVectorBase = baseAddr;

    Trace = 0;
    DelaySlotEnabled = delay_slot;
    EnablePutc = true;

    Reset();
}
//-----------------------------------------------------------------
// Deconstructor
//-----------------------------------------------------------------
OR32::~OR32()
{
    int m;

    for (m=0;m<MemRegions;m++)
    {
        if (Mem[m])
            delete Mem[m];
        Mem[m] = NULL;
    }
}
//-----------------------------------------------------------------
// CreateMemory:
//-----------------------------------------------------------------
bool OR32::CreateMemory(unsigned int baseAddr, unsigned int len)
{
    if (MemRegions < MAX_MEM_REGIONS)
    {
        MemBase[MemRegions] = baseAddr;
        MemSize[MemRegions] = len;

        Mem[MemRegions] = new TMemory[(len + 3)/4];
        if (!Mem[MemRegions])
            return false;

        memset(Mem[MemRegions], 0, (len + 3)/4);

        MemRegions++;

        return true;
    }

    return false;
}
//-----------------------------------------------------------------
// EnableMemoryTrace:
//-----------------------------------------------------------------
void OR32::EnableMemoryTrace(void)
{
    int m;

    for (m=0;m<MemRegions;m++)
    {
        MemInstHits[m] = new TRegister[MemSize[m]/4];
        MemReadHits[m] = new TRegister[MemSize[m]/4];
        MemWriteHits[m] = new TRegister[MemSize[m]/4];
        assert(MemInstHits[m]);
        assert(MemReadHits[m]);
        assert(MemWriteHits[m]);

        memset(MemInstHits[m], 0, MemSize[m]);
        memset(MemReadHits[m], 0, MemSize[m]);
        memset(MemWriteHits[m], 0, MemSize[m]);
    }
}
//-----------------------------------------------------------------
// Reset: Reset CPU state
//-----------------------------------------------------------------
void OR32::Reset(TRegister start_addr /*= VECTOR_RESET*/)
{
    int i;

    r_pc = start_addr;
    r_pc_next = start_addr;
    r_pc_last = start_addr;
    r_sr = 0;
    r_epc = 0;
    r_esr = 0;

    for (i=0;i<REGISTERS;i++)
        r_gpr[i] = 0;

    r_reg_ra = 0;
    r_reg_rb = 0;
    r_reg_result = 0;
    r_rd_wb = 0;
    r_ra = 0;
    r_rb = 0;

    mem_addr = 0;
    mem_offset = 0;
    mem_wr = 0;
    mem_rd = 0;
    mem_ifetch = 0;

    Fault = 0;
    Break = 0;
    BreakValue = 0;
    Trace = 0;
    Cycle = 2;    

    MemVectorBase = start_addr - VECTOR_RESET;

    ResetStats();
    PeripheralReset();
}
//-----------------------------------------------------------------
// ResetStats: Reset runtime stats
//-----------------------------------------------------------------
void OR32::ResetStats(void)
{
    int m;

    // Clear stats
    StatsMem = 0;
    StatsMarkers = 0;
    StatsMemWrites = 0;
    StatsInstructions = 0;
    StatsNop = 0;
    StatsBranches = 0;
    StatsExceptions = 0;
    StatsMulu = 0;
    StatsMul = 0;    

    for (m=0;m<MemRegions;m++)
    {
        if (MemReadHits[m])
            memset(MemReadHits[m], 0, MemSize[m]);
        if (MemWriteHits[m])
            memset(MemWriteHits[m], 0, MemSize[m]);
        if (MemInstHits[m])
            memset(MemInstHits[m], 0, MemSize[m]);
    }
}
//-----------------------------------------------------------------
// Load: Load program code into startAddr offset
//-----------------------------------------------------------------
bool OR32::Load(unsigned int startAddr, unsigned char *data, int len)
{
    int i;
    int j;

    for (j=0;j<MemRegions;j++)
    {
        // Program fits in memory?
        if ((startAddr >= MemBase[j]) && (startAddr + len) <= (MemBase[j] + MemSize[j]))
        {
            // Make relative to start of memory
            startAddr -= MemBase[j];

            // Convert to word address
            startAddr /= 4;

            for (i=0;i<len / 4; i++)
            {
                Mem[j][startAddr+i] = *data++;
                Mem[j][startAddr+i] <<= 8;
                Mem[j][startAddr+i]|= *data++;
                Mem[j][startAddr+i] <<= 8;
                Mem[j][startAddr+i]|= *data++;
                Mem[j][startAddr+i] <<= 8;
                Mem[j][startAddr+i]|= *data++;

                Mem[j][startAddr+i] = HTONL(Mem[j][startAddr+i]);
            }

            return true;
        }
    }
    return false;
}
//-----------------------------------------------------------------
// WriteMem: Write a block of memory
//-----------------------------------------------------------------
bool OR32::WriteMem(TAddress addr, unsigned char *data, int len)
{
    int i;
    int j;

    for (j=0;j<MemRegions;j++)
    {
        if (addr >= MemBase[j] && addr < (MemBase[j] + MemSize[j]))
        {
            unsigned char *ptr = (unsigned char *)Mem[j];
            ptr += (addr - MemBase[j]);

            for (i=0;i<len; i++)
                ptr[i] = data[i];

            return true;
        }
    }

    return false;
}
//-----------------------------------------------------------------
// ReadMem: Read a block of memory
//-----------------------------------------------------------------
bool OR32::ReadMem(TAddress addr, unsigned char *data, int len)
{
    int i;
    int j;

    for (j=0;j<MemRegions;j++)
    {
        if (addr >= MemBase[j] && addr < (MemBase[j] + MemSize[j]))
        {
            unsigned char *ptr = (unsigned char *)Mem[j];
            ptr += (addr - MemBase[j]);
            
            for (i=0;i<len; i++)
                data[i] = ptr[i];

            return true;
        }
    }
        
    return false;
}
//-----------------------------------------------------------------
// GetOpcode: Get instruction from address
//-----------------------------------------------------------------
TRegister OR32::GetOpcode(TRegister address)
{
    int m;
    for (m=0;m<MemRegions;m++)
    {
        if (address >= MemBase[m] && address < (MemBase[m] + MemSize[m]))
        {
            TAddress wordAddress = (address - MemBase[m]) / 4;
            TRegister mem_word = Mem[m][wordAddress];
            return HTONL(mem_word);
        }
    }

    return 0;
}
//-----------------------------------------------------------------
// Decode: Instruction decode stage
//-----------------------------------------------------------------
void OR32::Decode(void)
{
    // Instruction opcode read complete
    mem_wr = 0;
    mem_rd = 0;
    mem_ifetch = 0;

    // Fetch instruction from 'memory bus'
    r_opcode = mem_data_in;
    mem_data_in = 0;

    // Decode opcode in-order to perform register reads
    r_ra = (r_opcode >> OR32_REG_A_SHIFT) & OR32_REG_A_MASK;
    r_rb = (r_opcode >> OR32_REG_B_SHIFT) & OR32_REG_B_MASK;
    r_rd = (r_opcode >> OR32_REG_D_SHIFT) & OR32_REG_D_MASK;
}
//-----------------------------------------------------------------
// Execute: Instruction execution stage
//-----------------------------------------------------------------
void OR32::Execute(void)
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
    TRegister v_reg_ra = 0;
    TRegister v_reg_rb = 0;
    TRegister v_reg_result = 0;
    TRegister v_store_imm = 0;
    int v_branch = 0;
    int v_jmp = 0;
    int v_exception = 0;
    TRegister v_vector = 0;
    int v_write_rd = 0;

    TRegister v_alu_op = 0;
    TRegister v_shift_op = 0;
    TRegister v_sfxx_op = 0;    

    // Notify observers of instruction execution
    MonInstructionExecute(r_pc, r_opcode);

    StatsInstructions++;

    DPRINTF(LOG_INST, ("%08x: Execute 0x%08x\n", r_pc, r_opcode));    
    DPRINTF(LOG_INST, (" rA[%2d] = 0x%08x\n", r_ra, r_reg_ra));    
    DPRINTF(LOG_INST, (" rB[%2d] = 0x%08x\n", r_rb, r_reg_rb));

    // Decode opcode fields
    v_inst      = (r_opcode >> OR32_OPCODE_SHIFT) & OR32_OPCODE_MASK;
    v_rd        = (r_opcode >> OR32_REG_D_SHIFT) & OR32_REG_D_MASK;
    v_ra        = (r_opcode >> OR32_REG_A_SHIFT) & OR32_REG_A_MASK;
    v_rb        = (r_opcode >> OR32_REG_B_SHIFT) & OR32_REG_B_MASK;
    v_imm       = (r_opcode >> OR32_IMM16_SHIFT) & OR32_IMM16_MASK;
    v_target    = (r_opcode >> OR32_ADDR_SHIFT) & OR32_ADDR_MASK;
    v_sfxx_op   = (r_opcode >> OR32_SFXXX_OP_SHIFT) & OR32_SFXXX_OP_MASK;
    v_alu_op    = (r_opcode >> OR32_ALU_OP_L_SHIFT) & OR32_ALU_OP_L_MASK;
    v_alu_op   |= (r_opcode >> OR32_ALU_OP_H_SHIFT) & OR32_ALU_OP_H_MASK;
    v_shift_op  = (r_opcode >> OR32_SHIFT_OP_SHIFT) & OR32_SHIFT_OP_MASK;
    v_store_imm = (r_opcode >> OR32_STORE_IMM_L_SHIFT) & OR32_STORE_IMM_L_MASK;
    v_store_imm|= (r_opcode >> OR32_STORE_IMM_H_SHIFT) & OR32_STORE_IMM_H_MASK;

    // Sign extend store immediate
    v_store_imm = (unsigned int)(signed short)v_store_imm;

    // Sign extend target immediate
    if (v_target & (1 << OR32_ADDR_SIGN_SHIFT))
        v_target |= ~OR32_ADDR_MASK;

    // Signed & unsigned imm -> 32-bits
    v_imm_int32 = (unsigned int)(signed short)v_imm;
    v_imm_uint32 = v_imm;

    // Load register[ra]
    v_reg_ra = r_reg_ra;

    // Load register[rb]
    v_reg_rb = r_reg_rb;

    // Zero result
    v_reg_result = 0;

    // Default target is r_rd
    r_rd_wb = r_rd;

    if (DelaySlotEnabled)
    {
        // Update PC to next value
        v_pc = r_pc_next;

        // Increment next PC value (might be overriden by branch)
        v_pc_next = r_pc_next + 4;
    }
    else
    {
        v_pc      = r_pc + 4; // Current PC + 4
        v_pc_next = r_pc + 8; // Current PC + 8 (used in branches)
    }

    // Execute instruction
    switch(v_inst)
    {
        case INST_OR32_ALU:
            switch (v_alu_op)
            {
                case INST_OR32_ADD: // l.add
                    v_reg_result = v_reg_ra + v_reg_rb;
                    v_write_rd = 1;

                    // Carry out
                    r_sr = (r_sr & ~OR32_SR_CY_BIT) | (ADD_CARRY_OUT(v_reg_ra, v_reg_rb) ? OR32_SR_CY_BIT : 0);
                break;
                case INST_OR32_ADDC: // l.addc
                    v_reg_result = v_reg_ra + v_reg_rb + ((r_sr & OR32_SR_CY_BIT) ? 1 : 0);
                    v_write_rd = 1;

                    // Carry out
                    r_sr = (r_sr & ~OR32_SR_CY_BIT) | (ADD_CARRY_OUT(v_reg_ra, v_reg_rb) ? OR32_SR_CY_BIT : 0);
                break;
                case INST_OR32_AND: // l.and
                    v_reg_result = v_reg_ra & v_reg_rb;
                    v_write_rd = 1;
                break;
                case INST_OR32_OR: // l.or
                    v_reg_result = v_reg_ra | v_reg_rb;
                    v_write_rd = 1;
                break;
                case INST_OR32_SLL: // l.sll
                    v_reg_result = v_reg_ra << (v_reg_rb & 0x3F);
                    v_write_rd = 1;
                break;
                case INST_OR32_SRA: // l.sra
                    v_reg_result = (int)v_reg_ra >> (v_reg_rb & 0x3F);
                    v_write_rd = 1;
                break;
                case INST_OR32_SRL: // l.srl
                    v_reg_result = v_reg_ra >> (v_reg_rb & 0x3F);
                    v_write_rd = 1;
                break;
                case INST_OR32_SUB: // l.sub
                    v_reg_result = v_reg_ra + ~v_reg_rb + 1;
                    v_write_rd = 1;
                break;
                case INST_OR32_XOR: // l.xor
                    v_reg_result = v_reg_ra ^ v_reg_rb;
                    v_write_rd = 1;
                break;
                case INST_OR32_MUL: // l.mul
                {
                    long long res = ((long long) (int)v_reg_ra) * ((long long)(int)v_reg_rb);
                    v_reg_result = (int)(res >> 0);
                    v_write_rd = 1;                    
                    StatsMul++;
                }
                break;
                case INST_OR32_MULU: // l.mulu
                {
                    // This implementation differs from other cores - l.mulu returns upper 
                    // 32-bits of multiplication result...
                    long long res = ((long long) (int)v_reg_ra) * ((long long)(int)v_reg_rb);
                    v_reg_result = (int)(res >> 32);
                    v_write_rd = 1;
                    StatsMulu++;
                }
                break;
                default:
                    fprintf (stderr,"Bad ALU instruction @ PC %x\n", r_pc);
                    Fault = 1;
                    v_exception = 1;
                    v_vector = MemVectorBase + VECTOR_ILLEGAL_INST;
                break;
            }
        break;

        case INST_OR32_ADDI: // l.addi 
            v_reg_result = v_reg_ra + v_imm_int32;
            v_write_rd = 1;

            // Carry out
            r_sr = (r_sr & ~OR32_SR_CY_BIT) | (ADD_CARRY_OUT(v_reg_ra, v_imm_int32) ? OR32_SR_CY_BIT : 0);
        break;

        case INST_OR32_ANDI: // l.andi
            v_reg_result = v_reg_ra & v_imm_uint32;
            v_write_rd = 1;
        break;

        case INST_OR32_BF: // l.bf
            if (r_sr & OR32_SR_F_BIT)
                v_branch = 1;
        break;

        case INST_OR32_BNF: // l.bnf
            if (!(r_sr & OR32_SR_F_BIT))
                v_branch = 1;
        break;

        case INST_OR32_J: // l.j
            v_branch = 1;
        break;

        case INST_OR32_JAL: // l.jal
            // Write next instruction address to LR
            if (DelaySlotEnabled)
                v_reg_result = v_pc_next;
            else
                v_reg_result = v_pc;
            r_rd_wb = REG_9_LR;
            v_write_rd = 1;

            v_branch = 1;
        break;

        case INST_OR32_JALR: // l.jalr
            // Write next instruction address to LR
            if (DelaySlotEnabled)
                v_reg_result = v_pc_next;
            else
                v_reg_result = v_pc;
            r_rd_wb = REG_9_LR;
            v_write_rd = 1;

            if (DelaySlotEnabled)
                v_pc_next = v_reg_rb;
            else
                v_pc = v_reg_rb;
            v_jmp = 1;
        break;

        case INST_OR32_JR: // l.jr
            if (DelaySlotEnabled)
                v_pc_next = v_reg_rb;
            else
                v_pc = v_reg_rb;
            v_jmp = 1;
        break;

        case INST_OR32_LBS: // l.lbs
        case INST_OR32_LHS: // l.lhs
        case INST_OR32_LWS: // l.lws
        case INST_OR32_LBZ: // l.lbz
        case INST_OR32_LHZ: // l.lhz
        case INST_OR32_LWZ: // l.lwz
            mem_addr = v_reg_ra + (int)v_imm_int32;
            mem_offset = mem_addr & 0x3;
            mem_wr = 0;
            mem_rd = 1;
            mem_data_out = 0;
            v_write_rd = 1;
            StatsMem++;
        break;

        case INST_OR32_MFSPR: // l.mfspr
            // Move from SPR register
            switch ((v_reg_ra | (v_imm_uint32 & OR32_MFSPR_IMM_MASK)))
            {
                // VR - Version register
                case SPR_REG_VR:
                    v_reg_result = SPR_VERSION_CURRENT;
                    v_write_rd = 1;
                break;
                // SR - Supervision register
                case SPR_REG_SR:
                    v_reg_result = r_sr;
                    v_write_rd = 1;
                break;
                // EPCR - EPC Exception saved PC
                case SPR_REG_EPCR:
                    v_reg_result = r_epc;
                    v_write_rd = 1;
                break;
                // ESR - Exception saved SR
                case SPR_REG_ESR:
                    v_reg_result = r_esr;
                    v_write_rd = 1;
                break;
                default:
                    fprintf (stderr,"Unsupported SPR register (0x%x) access @ PC %x\n", (v_reg_ra | v_imm_uint32), r_pc);
                    Fault = 1;
                    v_exception = 1;
                    v_vector = MemVectorBase + VECTOR_ILLEGAL_INST;
                break;
            }
        break;

        case INST_OR32_MTSPR: // l.mtspr
            // Move to SPR register
            switch ((v_reg_ra | (v_imm_uint32 & OR32_MTSPR_IMM_MASK)))
            {
                // SR - Supervision register
                case SPR_REG_SR:
                    r_sr = v_reg_rb;
                break;
                // EPCR - EPC Exception saved PC
                case SPR_REG_EPCR:
                    r_epc = v_reg_rb;
                break;
                // ESR - Exception saved SR
                case SPR_REG_ESR:
                    r_esr = v_reg_rb;
                break;
                default:
                    fprintf (stderr,"Unsupported SPR register (0x%x) access @ PC %x\n", (v_reg_ra | v_imm_uint32), r_pc);
                    Fault = 1;
                    v_exception = 1;
                    v_vector = VECTOR_ILLEGAL_INST;
                break;
            }
        break;

        case INST_OR32_MOVHI: // l.movhi
            v_reg_result = v_imm_uint32 << 16;
            v_write_rd = 1;
        break;

        case INST_OR32_NOP: // l.nop
            StatsNop++;

            // NOP with simulator instruction?
            if (v_imm != NOP_NOP)
                MonNop(v_imm);
        break;

        case INST_OR32_ORI: // l.ori
            v_reg_result = v_reg_ra | v_imm_uint32;
            v_write_rd = 1;
        break;

        case INST_OR32_RFE: // l.rfe
            // Restore PC & SR from EPC & ESR
            if (DelaySlotEnabled)
                v_pc_next = r_epc;
            else
                v_pc = r_epc;
            r_sr = r_esr;
            v_jmp = 1;
            
            // TODO: Handle branch delay & next instruction flush
        break;

        case INST_OR32_SHIFTI:
            switch (v_shift_op)
            {
                case INST_OR32_SLLI: // l.slli
                    v_reg_result = v_reg_ra << (r_opcode & 0x3F);
                    v_write_rd = 1;
                break;
                case INST_OR32_SRAI: // l.srai
                    v_reg_result = (int)v_reg_ra >> (r_opcode & 0x3F);
                    v_write_rd = 1;
                break;
                case INST_OR32_SRLI: // l.srli
                    v_reg_result = v_reg_ra >> (r_opcode & 0x3F);
                    v_write_rd = 1;
                break;
                default:
                    fprintf (stderr,"Bad shift instruction @ PC %x\n", r_pc);
                    Fault = 1;
                    v_exception = 1;
                    v_vector = MemVectorBase + VECTOR_ILLEGAL_INST;
                break;
            }
        break;

        case INST_OR32_SB: // l.sb
            mem_addr = v_reg_ra + (int)v_store_imm;
            mem_offset = mem_addr & 0x3;            
            mem_rd = 0;
            switch (mem_offset)
            {
                case 0x0:
                    mem_data_out = (v_reg_rb & 0xFF) << 24;
                    mem_wr = 8;
                    break;
                case 0x1:
                    mem_data_out = (v_reg_rb & 0xFF) << 16;
                    mem_wr = 4;
                    break;
                case 0x2:
                    mem_data_out = (v_reg_rb & 0xFF) << 8;
                    mem_wr = 2;
                    break;
                case 0x3:
                    mem_data_out = (v_reg_rb & 0xFF) << 0;
                    mem_wr = 1;
                    break;
            }
            StatsMem++;
            StatsMemWrites++;
        break;

        case INST_OR32_SFXX:
        case INST_OR32_SFXXI:
            switch (v_sfxx_op)
            {
                case INST_OR32_SFEQ: // l.sfeq
                    if (v_reg_ra == v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFEQI: // l.sfeqi
                    if (v_reg_ra == v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGES: // l.sfges
                    if ((int)v_reg_ra >= (int)v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGESI: // l.sfgesi
                    if ((int)v_reg_ra >= (int)v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGEU: // l.sfgeu
                    if (v_reg_ra >= v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGEUI: // l.sfgeui
                    if (v_reg_ra >= v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGTS: // l.sfgts
                    if ((int)v_reg_ra > (int)v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGTSI: // l.sfgtsi
                    if ((int)v_reg_ra > (int)v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGTU: // l.sfgtu
                    if (v_reg_ra > v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFGTUI: // l.sfgtui
                    if (v_reg_ra > v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLES: // l.sfles
                    if ((int)v_reg_ra <= (int)v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLESI: // l.sflesi
                    if ((int)v_reg_ra <= (int)v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLEU: // l.sfleu
                    if (v_reg_ra <= v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLEUI: // l.sfleui
                    if (v_reg_ra <= v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLTS: // l.sflts
                    if ((int)v_reg_ra < (int)v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLTSI: // l.sfltsi
                    if ((int)v_reg_ra < (int)v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLTU: // l.sfltu
                    if (v_reg_ra < v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFLTUI: // l.sfltui
                    if (v_reg_ra < v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFNE: // l.sfne
                    if (v_reg_ra != v_reg_rb)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                case INST_OR32_SFNEI: // l.sfnei
                    if (v_reg_ra != v_imm_int32)
                        r_sr |= OR32_SR_F_BIT;
                    else
                        r_sr &=~OR32_SR_F_BIT;
                break;
                default:
                    fprintf (stderr,"Bad SFxx instruction @ PC %x\n", r_pc);
                    Fault = 1;
                    v_exception = 1;
                    v_vector = MemVectorBase + VECTOR_ILLEGAL_INST;
                break;
            }
        break;

        case INST_OR32_SH: // l.sh
            mem_addr = v_reg_ra + (int)v_store_imm;
            mem_offset = mem_addr & 0x3;            
            mem_rd = 0;
            switch (mem_offset)
            {
                case 0x0:
                    mem_data_out = (v_reg_rb & 0xFFFF) << 16;
                    mem_wr = 0xC;
                    break;
                case 0x2:
                    mem_data_out = (v_reg_rb & 0xFFFF) << 0;
                    mem_wr = 0x3;
                    break;
                default:
                    fprintf (stderr,"Bad mem access @ PC %x (%x)\n", r_pc, mem_offset);
                    Fault = 1;
                    mem_wr = 0;
                    break;
            }
            StatsMem++;
            StatsMemWrites++;
        break;

        case INST_OR32_SW: // l.sw
            mem_addr = v_reg_ra + (int)v_store_imm;
            mem_offset = mem_addr & 0x3;
            mem_rd = 0;
            mem_wr = 0xF;
            mem_data_out = v_reg_rb;
            if (mem_offset != 0)
            {
                fprintf (stderr,"Bad mem access @ PC %x (%x)\n", r_pc, mem_offset);
                Fault = 1;
                mem_wr = 0;
            }
            StatsMem++;
            StatsMemWrites++;
        break;

        case INST_OR32_MISC: 
            switch (r_opcode >> 24)
            {
                case INST_OR32_SYS: // l.sys
                    v_exception = 1;
                    v_vector = MemVectorBase + VECTOR_SYSCALL;
                break;

                case INST_OR32_TRAP: // l.trap
                    Break = 1;
                    BreakValue = v_imm_uint32;
                    v_exception = 1;
                    v_vector = MemVectorBase + VECTOR_TRAP;
                break;
            }
        break;

        case INST_OR32_XORI: // l.xori
            v_reg_result = v_reg_ra ^ v_imm_int32;
            v_write_rd = 1;
        break;

        default:
            fprintf (stderr,"Fault @ PC %x\n", r_pc);
            Fault = 1;
            v_exception = 1;
            v_vector = MemVectorBase + VECTOR_ILLEGAL_INST;
        break;
   }

    // Notify observer of fault
    if (Fault)
        MonFault(r_pc, r_opcode);

    // Handle branches (jumps relative to current PC)
    if (v_branch == 1)
    {
        v_offset = v_target << 2;
        if (DelaySlotEnabled)
            v_pc_next = r_pc + v_offset;
        else
            v_pc = r_pc + v_offset;
        StatsBranches++;
    }
    // If not branching, handle interrupts / exceptions
    else if (v_jmp == 0)
    {
        // Check for external interrupt
        if ((v_exception == 0) && (r_sr & (1 << OR32_SR_IEE)))
        {
            // External interrupt (and not handling an exception)?
            if (PeripheralInterrupt())
            {
                v_exception = 1;
                v_vector = MemVectorBase + VECTOR_EXTINT;
            }
        }

        // Interrupt / Exception
        if (v_exception == 1)
        {
            // Save PC & SR
            r_epc = v_pc;
            r_esr = r_sr;

            v_pc = v_vector;
            v_pc_next = v_pc + 4;

            // Disable further interrupts
            r_sr = 0;

            StatsExceptions++;
            StatsBranches++;
        }
    }
    else
        StatsBranches++;

    // Update registers with variable values
    if (DelaySlotEnabled)
    {
        r_pc_last = r_pc;
        r_pc = v_pc;
        r_pc_next = v_pc_next;
    }
    else
    {
        r_pc_last = r_pc;
        r_pc = v_pc;
    }

    r_reg_result = v_reg_result;

    // No writeback required?
    if (v_write_rd == 0)
    {
        // Target register is $0 which is read-only
        r_rd_wb = 0;
    }
}
//-----------------------------------------------------------------
// WriteBack: Register write back stage
//-----------------------------------------------------------------
void OR32::WriteBack(void)
{
    TRegister v_inst;
    TRegister v_reg_result;

    mem_wr = 0;
    mem_rd = 0;
    mem_ifetch = 0;

    v_inst = (r_opcode >> OR32_OPCODE_SHIFT) & OR32_OPCODE_MASK;

    // Writeback read result
    switch(v_inst)
    {
    case INST_OR32_LBS: // l.lbs
        switch (mem_offset)
        {
            case 0x0:
                v_reg_result = (int)((signed char)(mem_data_in >> 24));
                break;
            case 0x1:
                v_reg_result = (int)((signed char)(mem_data_in >> 16));
                break;
            case 0x2:
                v_reg_result = (int)((signed char)(mem_data_in >> 8));
                break;
            case 0x3:
                v_reg_result = (int)((signed char)(mem_data_in >> 0));
                break;
        }
        break;

    case INST_OR32_LBZ: // l.lbz
        switch (mem_offset)
        {
            case 0x0:
                v_reg_result = ((unsigned char)(mem_data_in >> 24));
                break;
            case 0x1:
                v_reg_result = ((unsigned char)(mem_data_in >> 16));
                break;
            case 0x2:
                v_reg_result = ((unsigned char)(mem_data_in >> 8));
                break;
            case 0x3:
                v_reg_result = ((unsigned char)(mem_data_in >> 0));
                break;
        }
        break;
        
    case INST_OR32_LHS: // l.lhs
        switch (mem_offset)
        {
            case 0x0:
                v_reg_result = (int)((signed short)(mem_data_in >> 16));
                break;
            case 0x2:
                v_reg_result = (int)((signed short)(mem_data_in >> 0));
                break;
            default:
                fprintf (stderr,"Bad mem access @ PC %x (%x)\n", r_pc, mem_offset);
                Fault = 1;
                break;
        }
        break;

    case INST_OR32_LHZ: // l.lhz
        switch (mem_offset)
        {
            case 0x0:
                v_reg_result = ((unsigned short)(mem_data_in >> 16));
                break;
            case 0x2:
                v_reg_result = ((unsigned short)(mem_data_in >> 0));
                break;
            default:
                fprintf (stderr,"Bad mem access @ PC %x (%x)\n", r_pc, mem_offset);
                Fault = 1;
                break;
        }
        break;

    case INST_OR32_LWZ: // l.lwz
    case INST_OR32_LWS: // l.lws
        v_reg_result = mem_data_in;
        if (mem_offset != 0)
        {
            fprintf (stderr,"Bad mem access @ PC %x (%x)\n", r_pc, mem_offset);
            Fault = 1;
        }
        break;

    default:
        v_reg_result = r_reg_result;
        break;
    }    

    // Decode instruction to full text?
#ifdef INCLUDE_INST_DUMP    
    if (TRACE_ENABLED(LOG_OR1K))
        or32_instruction_dump(r_pc_last, r_opcode, r_gpr, r_rd_wb, v_reg_result, r_sr);
#endif

    // Register writeback required?
    r_reg_rd_out = v_reg_result;
    if (r_rd_wb != 0)
        r_writeback = 1;

    // Fetch next instruction
    mem_addr = r_pc;
    mem_data_out = 0;
    mem_rd = 1;
    mem_ifetch = 1;
}
//-----------------------------------------------------------------
// Clock: Execute a single instruction (including load / store)
//-----------------------------------------------------------------
bool OR32::Clock(void)
{
    bool writeback = false;    

    switch (Cycle)
    {
    // Instruction decode
    case 0:
        Cycle++;
        Decode();
        break;

    // Execute
    case 1:
        Cycle++;
        Execute();
        break;

    // Writeback & fetch next
    case 2:
        Cycle = 0;
        WriteBack();
        writeback = true;
        break;
    }

    // Notify observers if memory write will occur
    if (mem_wr)
    {
        DPRINTF(LOG_MEM, ("MEM: Write Addr %x Value %x Mask %x\n", mem_addr, mem_data_out, mem_wr));
        MonDataStore(mem_addr, mem_wr, mem_data_out);
    }

    // Internal Memory?
    int m;
    for (m=0;m<MemRegions;m++)
    {
        if (mem_addr >= MemBase[m] && mem_addr < (MemBase[m] + MemSize[m]))
        {
            TAddress wordAddress = (mem_addr - MemBase[m]) / 4;
            TRegister mem_word = Mem[m][wordAddress];
            mem_word = HTONL(mem_word);

            // Write
            switch (mem_wr)
            {
                case 0xF:
                    mem_word = mem_data_out;
                    break;
                case 0x3:
                    mem_data_out &= 0x0000FFFF;
                    mem_word &=~ 0x0000FFFF;
                    mem_word |= mem_data_out;
                    break;
                case 0xC:
                    mem_data_out &= 0xFFFF0000;
                    mem_word &=~ 0xFFFF0000;
                    mem_word |= mem_data_out;
                    break;
                case 0x1:
                    mem_data_out &= 0x000000FF;
                    mem_word &=~ 0x000000FF;
                    mem_word |= mem_data_out;
                    break;
                case 0x2:
                    mem_data_out &= 0x0000FF00;
                    mem_word &=~ 0x0000FF00;
                    mem_word |= mem_data_out;
                    break;
                case 0x4:
                    mem_data_out &= 0x00FF0000;
                    mem_word &=~ 0x00FF0000;
                    mem_word |= mem_data_out;
                    break;
                case 0x8:
                    mem_data_out &= 0xFF000000;
                    mem_word &=~ 0xFF000000;
                    mem_word |= mem_data_out;
                    break;
            }

            Mem[m][wordAddress] = HTONL(mem_word);

            // Read
            mem_data_in = mem_word;

            if (!mem_ifetch)
            {
                if (mem_wr && MemWriteHits[m])
                    MemWriteHits[m][wordAddress]++;
                else if (mem_rd && MemReadHits[m])
                    MemReadHits[m][wordAddress]++;
            }
            else if (MemInstHits[m])
                MemInstHits[m][wordAddress]++;

            break;
        }
    }

    // External / Peripheral memory
    if (m == MemRegions) 
    {
        mem_data_in = PeripheralAccess(mem_addr, mem_data_out, mem_wr, mem_rd);
    }

    // Notify observers if memory read has occurred
    if (mem_rd)
    {
        DPRINTF(LOG_MEM, ("MEM: Read Addr %x Value %x\n", mem_addr, mem_data_in));
        MonDataLoad(mem_addr, 0xF, mem_data_in);
    }

    // Clock peripherals
    PeripheralClock();

    // Writeback (if target is not R0)
    if (r_writeback && r_rd_wb != REG_0_ZERO)
    {
        r_gpr[r_rd_wb] = r_reg_rd_out;
        r_writeback = 0;
    }

    // If write-back stage just completed, show register state...
    if (writeback && TRACE_ENABLED(LOG_REGISTERS))
    {
        // Register trace
        int i;
        for (i=0;i<REGISTERS;i+=4)
        {
            printf(" %d: ", i);
            printf(" %08x %08x %08x %08x\n", r_gpr[i+0], r_gpr[i+1], r_gpr[i+2], r_gpr[i+3]);
        }

        printf(" SR = 0x%08x, EPC = 0x%08x, ESR = 0x%08x, SR_F=%d\n\n", r_sr, r_epc, r_esr, (r_sr & OR32_SR_F_BIT) ? 1 : 0);
    }

    // Reload register contents
    r_reg_ra = r_gpr[r_ra];
    r_reg_rb = r_gpr[r_rb];

    return writeback;
}
//-----------------------------------------------------------------
// Step: Step through one instruction
//-----------------------------------------------------------------
bool OR32::Step(void)
{
    while (!Clock())
        ;
    return true;
}
//-----------------------------------------------------------------
// MonNop: Default NOP functions
//-----------------------------------------------------------------
void OR32::MonNop(TRegister imm)
{
    switch (imm)
    {
        // Exit
        case NOP_EXIT:
            exit(r_gpr[NOP_DATA_REG]);
        break;
        // Report value
        case NOP_REPORT:
            if (Trace)
                fprintf(stderr, "0x%x\n", r_gpr[NOP_DATA_REG]);
            else
                printf("0x%x\n", r_gpr[NOP_DATA_REG]);
        break;
        // putc()
        case NOP_PUTC:
            if (EnablePutc)
            {
                if (Trace)
                    fprintf(stderr, "%c", r_gpr[NOP_DATA_REG]);
                else
                    printf("%c", r_gpr[NOP_DATA_REG]);
            }
        break;
        // Trace Control
        case NOP_TRACE_ON:
            Trace = r_gpr[NOP_DATA_REG];
        break;
        case NOP_TRACE_OFF:
            Trace = 0;
        break;
        case NOP_STATS_RESET:
            ResetStats();
        break;
        case NOP_STATS_MARKER:
            StatsMarkers++;
        break;
    }
}
//-----------------------------------------------------------------
// DumpStats: Show execution stats
//-----------------------------------------------------------------
void OR32::DumpStats(void)
{
    printf("Runtime Stats:\n");
    printf("- Total Instructions %d\n", StatsInstructions);
    printf("- Memory Operations %d (%d%%)\n", StatsMem, (StatsMem * 100) / StatsInstructions);
    if (StatsMem != 0)
    {
        printf("  - Reads %d (%d%%)\n", (StatsMem - StatsMemWrites), ((StatsMem - StatsMemWrites) * 100) / StatsMem);
        printf("  - Writes %d (%d%%)\n", StatsMemWrites, (StatsMemWrites * 100) / StatsMem);
    }
    printf("- MUL %d (%d%%)\n", StatsMul, (StatsMul * 100) / StatsInstructions);
    printf("- MULU %d (%d%%)\n", StatsMulu, (StatsMulu * 100) / StatsInstructions);
    printf("- NOPS %d (%d%%)\n", StatsNop, (StatsNop * 100) / StatsInstructions);
    printf("- Markers %d (%d%%)\n", StatsMarkers, (StatsMarkers * 100) / StatsInstructions);
    printf("- Branches Operations %d (%d%%)\n", StatsBranches, (StatsBranches * 100) / StatsInstructions);
    printf("- Exceptions %d (%d%%)\n", StatsExceptions, (StatsExceptions * 100) / StatsInstructions);    

    FILE *f;
    int i;
    int m;

    for (m=0;m<MemRegions;m++)
    {
        if (MemReadHits[m])
        {
            printf("Saving %s\n", MEMTRACE_READS);
            f = fopen(MEMTRACE_READS, "w");
            if (f)
            {
                for (i=0;i<MemSize[m]/4;i++)
                {
                    unsigned int addr = MemBase[m] + (i * 4);
                    if (MemReadHits[m][i] > MEMTRACE_MIN)
                    {
                        fprintf(f, "%08x %d\n", addr, MemReadHits[m][i]);
                    }
                }
                fclose(f);
            }
            else
                fprintf (stderr,"Could not open file for writing\n");
        }

        if (MemWriteHits[m])
        {
            printf("Saving %s\n", MEMTRACE_WRITES);
            f = fopen(MEMTRACE_WRITES, "w");
            if (f)
            {
                for (i=0;i<MemSize[m]/4;i++)
                {
                    unsigned int addr = MemBase[m] + (i * 4);
                    if (MemWriteHits[m][i] > MEMTRACE_MIN)
                    {
                        fprintf(f, "%08x %d\n", addr, MemWriteHits[m][i]);
                    }
                }
                fclose(f);
            }
            else
                fprintf (stderr,"Could not open file for writing\n");
        }

        if (MemInstHits[m])
        {
            printf("Saving %s\n", MEMTRACE_INST);
            f = fopen(MEMTRACE_INST, "w");
            if (f)
            {
                for (i=0;i<MemSize[m]/4;i++)
                {
                    unsigned int addr = MemBase[m] + (i * 4);
                    if (MemInstHits[m][i] > MEMTRACE_MIN)
                    {
                        fprintf(f, "%08x %d\n", addr, MemInstHits[m][i]);
                    }
                }
                fclose(f);
            }
            else
                fprintf (stderr,"Could not open file for writing\n");
        }
    }

    ResetStats();
}
