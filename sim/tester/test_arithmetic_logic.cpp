/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstdlib>

#include "tests.h"

//------------------------------------------------------------------------------

void put_instruction(uint32 *ptr, bool &was_mul, bool &was_div) {

    uint32 instr_special[] = {
        0b000000, //SSL
        0b000010, //SRL
        0b000011, //SRA
        0b000100, //SLLV
        0b000110, //SRLV
        0b000111, //SRAV
        0b010000, //MFHI
        0b010001, //MTHI     i
        0b010010, //MFLO
        0b010011, //MTLO     i
        0b011000, //MULT     i
        0b011001, //MULTU    i
        0b011010, //DIV
        0b011011, //DIVU
        0b100000, //ADD      e
        0b100001, //ADDU
        0b100010, //SUB      e
        0b100011, //SUBU
        0b100100, //AND
        0b100101, //OR
        0b100110, //XOR
        0b100111, //NOR
        0b101010, //SLT
        0b101011, //SLTU
    };
    uint32 instr_imm[] = {
        0b001000, //ADDI     e
        0b001001, //ADDIU
        0b001010, //SLTI
        0b001011, //SLTIU
        0b001100, //ANDI
        0b001101, //ORI
        0b001110, //XORI
        0b001111, //LUI
    };
    
    while(true) {
        uint32 instr = rand() & 0x03FFFFFF;
        uint32 count = (sizeof(instr_special) + sizeof(instr_imm)) / sizeof(uint32);
        uint32 index = rand() % count;
        
        //sequences not generated:
        //mul* -> mt*; mul* -> div*
        //div* -> mt*; div* -> mul*
        //mul* and div* finish after mf*
        
        if(was_div == false && (index == 10 || index == 11)) was_mul = true;
        if(was_mul == false && (index == 12 || index == 13)) was_div = true;
        if(was_div && (index == 10 || index == 11)) continue;
        if(was_mul && (index == 12 || index == 13)) continue;
        if((was_div || was_mul) && (index == 7 || index == 9)) continue;
        if((index == 6 || index == 8)) was_div = was_mul = false;
        
        if(index >= (sizeof(instr_special) / sizeof(uint32))) {
            index -= (sizeof(instr_special) / sizeof(uint32));
            instr |= instr_imm[index] << 26;
            
            if(index == 7 || index == 9 || index == 10 || index == 11) if((rand() % 3) != 0) instr &= 0xFFFF07FF;
        }
        else {
            instr &= 0xFFFFFFC0;
            instr |= instr_special[index];
        }
        (*ptr) = instr;
        break;
    }
}

void arith_logic_till_exc_init(tst_t *tst, shared_mem_t *shared_ptr) {
    
    for(int i=1; i<32; i++) shared_ptr->initial.reg[i-1] = rand_uint32();
    
    shared_ptr->initial.pc = 0xA0001000;
    
    //tlb left zero
    
    shared_ptr->initial.index_p             = rand() & 0x1;
    shared_ptr->initial.index_index         = rand() & 0x3F;

    shared_ptr->initial.random              = rand() & 0x3F;
    
    shared_ptr->initial.entrylo_pfn         = rand() & 0xFFFFF;
    shared_ptr->initial.entrylo_n           = rand() & 0x1;
    shared_ptr->initial.entrylo_d           = rand() & 0x1;
    shared_ptr->initial.entrylo_v           = rand() & 0x1;
    shared_ptr->initial.entrylo_g           = rand() & 0x1;
    
    shared_ptr->initial.context_ptebase     = rand() & 0x7FF;
    shared_ptr->initial.context_badvpn      = rand() & 0x7FFFF;
    
    shared_ptr->initial.bad_vaddr           = rand_uint32();
    
    shared_ptr->initial.entryhi_vpn         = rand() & 0xFFFFF;
    shared_ptr->initial.entryhi_asid        = rand() & 0x3F;
    
    shared_ptr->initial.sr_cp_usable        = rand() & 0xF;
    shared_ptr->initial.sr_rev_endian       = rand() & 0x1;
    shared_ptr->initial.sr_bootstrap_vec    = rand() & 0x1;
    shared_ptr->initial.sr_tlb_shutdown     = rand() & 0x1;
    shared_ptr->initial.sr_parity_err       = rand() & 0x1;
    shared_ptr->initial.sr_cache_miss       = rand() & 0x1;
    shared_ptr->initial.sr_parity_zero      = rand() & 0x1;
    shared_ptr->initial.sr_switch_cache     = rand() & 0x1;
    shared_ptr->initial.sr_isolate_cache    = rand() & 0x1;
    shared_ptr->initial.sr_irq_mask         = rand() & 0xFF;
    shared_ptr->initial.sr_ku_ie            = rand() & 0x3F;
    
    shared_ptr->initial.cause_branch_delay  = rand() & 0x1;
    shared_ptr->initial.cause_cp_error      = rand() & 0x3;
    shared_ptr->initial.cause_irq_pending   = 0;
    shared_ptr->initial.cause_exc_code      = rand() & 0x1F;
    
    shared_ptr->initial.epc                 = rand_uint32();
    
    //
    shared_ptr->irq2_at_event = 0xFFFFFFFF;
    shared_ptr->irq3_at_event = 0xFFFFFFFF;
    
    //
    bool was_mul = false;
    bool was_div = false;
    
    //
    uint32 *ptr = &shared_ptr->mem.ints[(shared_ptr->initial.pc & 0x1FFFFFFF) / 4];
    for(int i=0; i<5; i++) {
        put_instruction(ptr, was_mul, was_div);
        ptr++;
    }
    
    //finish with SYSCALL or BREAK
    (*ptr) = rand() & 0x03FFFFC0;
    if(rand() % 2)  (*ptr) |= 0b001100;
    else            (*ptr) |= 0b001101;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
