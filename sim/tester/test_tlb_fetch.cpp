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

void tlb_fetch_till_exc_init(tst_t *tst, shared_mem_t *shared_ptr) {
    
    for(int i=1; i<32; i++) shared_ptr->initial.reg[i-1] = rand_uint32();
    
    shared_ptr->initial.pc = (rand() % 2)? 0x00091000 : 0xF0001000;
        
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
    shared_ptr->initial.sr_switch_cache     = 0; //rand() & 0x1;
    shared_ptr->initial.sr_isolate_cache    = 0; //rand() & 0x1;
    shared_ptr->initial.sr_irq_mask         = rand() & 0xFF;
    shared_ptr->initial.sr_ku_ie            = rand() & 0x3F;
    
    shared_ptr->initial.cause_branch_delay  = rand() & 0x1;
    shared_ptr->initial.cause_cp_error      = rand() & 0x3;
    shared_ptr->initial.cause_irq_pending   = 0;
    shared_ptr->initial.cause_exc_code      = rand() & 0x1F;
    
    shared_ptr->initial.epc                 = rand_uint32();
    
    //
    uint32 vaddr_pc = shared_ptr->initial.pc;
    uint32 paddr_pc = 0x5000;
    
    shared_ptr->initial.tlb[55].vpn  = (vaddr_pc >> 12) & 0xFFFFF;
    shared_ptr->initial.tlb[55].asid = ((rand() % 5) == 0)? (rand() % 0x1F) : shared_ptr->initial.entryhi_asid;
    shared_ptr->initial.tlb[55].pfn  = (paddr_pc >> 12) & 0xFFFFF;
    shared_ptr->initial.tlb[55].n    = rand() % 2;
    shared_ptr->initial.tlb[55].d    = rand() % 2;
    shared_ptr->initial.tlb[55].v    = rand() % 2;
    shared_ptr->initial.tlb[55].g    = rand() % 2;
    
    //
    shared_ptr->initial.reg[0] = 5;
    
    //
    shared_ptr->irq2_at_event = 0xFFFFFFFF;
    shared_ptr->irq3_at_event = 0xFFFFFFFF;
    
    //
    uint32 *ptr = &shared_ptr->mem.ints[paddr_pc / 4];
    
    for(int i=0; i<10; i++) {
        (*ptr) = 0;
        ptr++;
    }
    
    (*ptr) = (0b001000 << 26) | (0b00001 << 21) | (0b00001 << 16) | 0xFFFF; //SUB 1 from reg[0] (reg1)
    ptr++;
    
    (*ptr) = (0b000100 << 26) | (0b00000 << 21) | (0b00001 << 16) | 2; //BEQ
    ptr++;
    
    (*ptr) = 0; //delay slot
    ptr++;
    
    (*ptr) = (0b000010 << 26) | ((vaddr_pc >> 2) & 0x3FFFFFF); //J back
    ptr++;
    
    (*ptr) = 0; //delay slot
    ptr++;
    
    (*ptr) = rand() & 0x03FFFFC0;
    (*ptr) |= 0b001100; //SYSCALL
    ptr++;
}

//------------------------------------------------------------------------------
