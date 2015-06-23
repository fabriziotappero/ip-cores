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

void tlb_commands_till_exc_init(tst_t *tst, shared_mem_t *shared_ptr) {
    
    for(int i=1; i<32; i++) shared_ptr->initial.reg[i-1] = rand_uint32();
    
    shared_ptr->initial.pc = 0xA0001000;
    
    for(int i=0; i<64; i++) shared_ptr->initial.tlb[i].vpn = rand() & 0xFFFFF;
    
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
    uint32 *ptr = &shared_ptr->mem.ints[(shared_ptr->initial.pc & 0x1FFFFFFF) / 4];
    
    for(int i=0; i<100; i++) {
        
        uint32 type = rand() % 5;
        
        if(type == 0) { //RFE
            (*ptr) = rand() & 0x01FFFFC0;
            (*ptr) |= (0b0100 << 28) | (0b00 << 26) | (0b1 << 25) | (0b010000 << 0);
        }
        else if(type == 1) { //TLBWR
            (*ptr) = rand() & 0x01FFFFC0;
            (*ptr) |= (0b0100 << 28) | (0b00 << 26) | (0b1 << 25) | (0b000110 << 0);
            
            ptr++;
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
        }
        else if(type == 2) { //TLBWI
            (*ptr) = rand() & 0x01FFFFC0;
            (*ptr) |= (0b0100 << 28) | (0b00 << 26) | (0b1 << 25) | (0b000010 << 0);
            
            ptr++;
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
        }
        else if(type == 3) { //TLBR
            (*ptr) = rand() & 0x01FFFFC0;
            (*ptr) |= (0b0100 << 28) | (0b00 << 26) | (0b1 << 25) | (0b000001 << 0);
        }
        else if(type == 4) { //TLBP
            (*ptr) = rand() & 0x01FFFFC0;
            (*ptr) |= (0b0100 << 28) | (0b00 << 26) | (0b1 << 25) | (0b001000 << 0);
        }
        
        ptr++;
    }
    
    for(int i=0; i<5; i++) {
        (*ptr) = rand() & 0x03FFFFC0;
        (*ptr) |= 0b001100; //SYSCALL
        ptr++;
    }
}

//------------------------------------------------------------------------------
