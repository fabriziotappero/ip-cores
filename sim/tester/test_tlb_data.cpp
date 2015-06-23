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

void tlb_data_till_exc_init(tst_t *tst, shared_mem_t *shared_ptr) {
    
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
    shared_ptr->irq2_at_event = 0xFFFFFFFF;
    shared_ptr->irq3_at_event = 0xFFFFFFFF;
    
    //pc
    uint32 vaddr_pc = shared_ptr->initial.pc;
    uint32 paddr_pc = 0x5000;
    
    shared_ptr->initial.tlb[55].vpn  = (vaddr_pc >> 12) & 0xFFFFF;
    shared_ptr->initial.tlb[55].asid = ((rand() % 5) == 0)? (rand() % 0x1F) : shared_ptr->initial.entryhi_asid;
    shared_ptr->initial.tlb[55].pfn  = (paddr_pc >> 12) & 0xFFFFF;
    shared_ptr->initial.tlb[55].n    = rand() % 2;
    shared_ptr->initial.tlb[55].d    = rand() % 2;
    shared_ptr->initial.tlb[55].v    = rand() % 2;
    shared_ptr->initial.tlb[55].g    = rand() % 2;
    
    uint32 *ptr = &shared_ptr->mem.ints[paddr_pc / 4];
    
    //data
    uint32 vaddr_data = (rand() % 2)? 0x000C1000 : 0xF01C1000;
    uint32 paddr_data = 0x000A0000;
    
    for(uint32 i=0; i<14; i++) { //14 * 4096 - virtual memory
        shared_ptr->initial.tlb[5+i].vpn  = ((vaddr_data - ((8-i)*4096)) >> 12) & 0xFFFFF;
        shared_ptr->initial.tlb[5+i].asid = ((rand() % 5) == 0)? (rand() % 0x1F) : shared_ptr->initial.entryhi_asid;
        shared_ptr->initial.tlb[5+i].pfn  = ((paddr_data - ((8-i)*4096)) >> 12) & 0xFFFFF;
        shared_ptr->initial.tlb[5+i].n    = rand() % 2;
        shared_ptr->initial.tlb[5+i].d    = rand() % 2;
        shared_ptr->initial.tlb[5+i].v    = rand() % 2;
        shared_ptr->initial.tlb[5+i].g    = rand() % 2;
    }
    
    uint32 scope = 65536;
    
    uint32 loading_reg = 0;
    
    shared_ptr->initial.reg[0] = vaddr_data;
    
    for(int operation=0; operation<100; operation++) {
        
        uint32 type = rand() % 12;
        
        uint32 storing_reg = 2 + (rand() % 30);
        while(storing_reg == loading_reg) storing_reg = 2 + (rand() % 30);
        
        if(type == 0) { //LB
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100000 << 26) | (1 << 21) | (loading_reg << 16) | (rand() % scope);
            ptr++;
        }
        else if(type == 1) { //LBU
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100100 << 26) | (1 << 21) | (loading_reg << 16) | (rand() % scope);
            ptr++;
        }
        else if(type == 2) { //LH
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100001 << 26) | (1 << 21) | (loading_reg << 16) | ((rand() % scope) & 0xFFFE) | (((rand() % 5) == 0)? 1 : 0);
            ptr++;
        }
        else if(type == 3) { //LHU
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100101 << 26) | (1 << 21) | (loading_reg << 16) | ((rand() % scope) & 0xFFFE) | (((rand() % 5) == 0)? 1 : 0);
            ptr++;
        }
        else if(type == 4) { //LW
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100011 << 26) | (1 << 21) | (loading_reg << 16) | ((rand() % scope) & 0xFFFC) | (((rand() % 5) == 0)? (1 + (rand() % 3)) : 0);
            ptr++;
        }
        else if(type == 5) { //LWL
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100010 << 26) | (1 << 21) | (loading_reg << 16) | (rand() % scope);
            ptr++;
        }
        else if(type == 6) { //LWR
            loading_reg = 2 + (rand() % 30);
            
            (*ptr) = (0b100110 << 26) | (1 << 21) | (loading_reg << 16) | (rand() % scope);
            ptr++;
        }
        else if(type == 7) { //SB
            loading_reg = 0;
            
            (*ptr) = (0b101000 << 26) | (1 << 21) | (storing_reg << 16) | (rand() % scope);
            ptr++;
        }
        else if(type == 8) { //SH
            loading_reg = 0;
            
            (*ptr) = (0b101001 << 26) | (1 << 21) | (storing_reg << 16) | ((rand() % scope) & 0xFFFE) | (((rand() % 5) == 0)? 1 : 0);
            ptr++;
        }
        else if(type == 9) { //SW
            loading_reg = 0;
            
            (*ptr) = (0b101011 << 26) | (1 << 21) | (storing_reg << 16) | ((rand() % scope) & 0xFFFC) | (((rand() % 5) == 0)? (1 + (rand() % 3)) : 0);
            ptr++;
        }
        else if(type == 10) { //SWL
            loading_reg = 0;
            
            (*ptr) = (0b101010 << 26) | (1 << 21) | (storing_reg << 16) | (rand() % scope);
            ptr++;
        }
        else if(type == 11) { //SWR
            loading_reg = 0;
            
            (*ptr) = (0b101110 << 26) | (1 << 21) | (storing_reg << 16) | (rand() % scope);
            ptr++;
        }
    }
    
    for(uint32 i=paddr_data - 32768; i<paddr_data + 32768; i++) {
        shared_ptr->mem.ints[i/4] = rand_uint32();
    }
    
    (*ptr) = rand() & 0x03FFFFC0;
    (*ptr) |= 0b001100; //SYSCALL
    ptr++;
}

//------------------------------------------------------------------------------
