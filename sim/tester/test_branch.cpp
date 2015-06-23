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

void branch_till_exc_init(tst_t *tst, shared_mem_t *shared_ptr) {
    
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
    uint32 *ptr = &shared_ptr->mem.ints[(shared_ptr->initial.pc & 0x1FFFFFFF) / 4];
    
    uint32 type  = rand() % 12;
    uint32 after = rand() % 3;
/*
0 - branch, no exception in delay slot
1 - no branch
2 - branch, exception in delay slot
*/
    if(type == 0) { //BEQ
        shared_ptr->initial.reg[0] = 1;
        shared_ptr->initial.reg[1] = (after == 0)? 1 : (after == 1)? 2 : 1;
           
        (*ptr) = (0b000100 << 26) | (1 << 21) | (2 << 16) | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 1) { //BGEZ
        shared_ptr->initial.reg[0] = (after == 0)? 1 : (after == 1)? 0x80000000 : 1;
        
        (*ptr) = (0b000001 << 26) | (1 << 21) | (0b00001 << 16) | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 2) { //BGEZAL
        shared_ptr->initial.reg[0] = (after == 0)? 0 : (after == 1)? 0x80000000 : 1;
        
        (*ptr) = (0b000001 << 26) | (1 << 21) | (0b10001 << 16) | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 3) { //BGTZ
        shared_ptr->initial.reg[0] = (after == 0)? 1 : (after == 1)? ((rand() % 2)? 0 : 0x80000000) : 1;
        
        (*ptr) = (0b000111 << 26) | (1 << 21) | ((rand() % 3 == 0)? rand() & 0x1F : 0b00000) << 16 | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 4) { //BLEZ
        shared_ptr->initial.reg[0] = (after == 0)? 0x80000000 : (after == 1)? 1 : 0;
        
        (*ptr) = (0b000110 << 26) | (1 << 21) | ((rand() % 3 == 0)? rand() & 0x1F : 0b00000) << 16  | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 5) { //BLTZ
        shared_ptr->initial.reg[0] = (after == 0)? 0x80000000 : (after == 1)? ((rand() % 2)? 0 : 1) : 0xFFFFFFFF;
        
        (*ptr) = (0b000001 << 26) | (1 << 21) | (0b00000 << 16) | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 6) { //BLTZAL
        shared_ptr->initial.reg[0] = (after == 0)? 0x80000000 : (after == 1)? ((rand() % 2)? 0 : 1) : 0xFFFFFFFF;
        
        (*ptr) = (0b000001 << 26) | (1 << 21) | (0b10000 << 16) | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 7) { //BNE
        shared_ptr->initial.reg[0] = 1;
        shared_ptr->initial.reg[1] = (after == 0)? 2 : (after == 1)? 1 : 3;
           
        (*ptr) = (0b000101 << 26) | (1 << 21) | (2 << 16) | (1 + (rand() % 10));
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 8) { //J
        uint32 dest = (((0xA0001000) >> 2) & 0x3FFFFFF) | (1 + (rand() % 10));
        
        (*ptr) = (0b000010 << 26) | dest;
        ptr++;
        
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 9) { //JAL
        uint32 dest = (((0xA0001000) >> 2) & 0x3FFFFFF) | (1 + (rand() % 10));
        
        (*ptr) = (0b000011 << 26) | dest;
        ptr++;
        
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 10) { //JALR
        uint32 dest = 0xA0001000 | ((1 + (rand() % 10)) << 2) | (((rand() % 2) == 0)? 1 : 0);
        
        shared_ptr->initial.reg[0] = dest;
           
        (*ptr) = (0b000000 << 26) | (1 << 21) | ((rand() & 0x1F) << 16) | ((rand() & 0x1F) << 11) | ((rand() & 0x1F) << 6) | 0b001001;
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
    else if(type == 11) { //JR
        uint32 dest = 0xA0001000 | ((1 + (rand() % 10)) << 2) | (((rand() % 3) == 0)? 1 : 0);
        
        shared_ptr->initial.reg[0] = dest;
        shared_ptr->initial.reg[1] = (after == 1)? 1 : 0;
        
        (*ptr) = (0b000000 << 26) | (1 << 21) | ((rand() & 0x1F) << 16) | (2 << 11) | ((rand() & 0x1F) << 6) | 0b001000;
        ptr++;
            
        (*ptr) = (after == 2)? 0b001100 /*SYSCALL*/: 0; //delay slot
        ptr++;
            
        for(int i=0; i<10; i++) {
            (*ptr) = rand() & 0x03FFFFC0;
            (*ptr) |= 0b001100; //SYSCALL
            ptr++;
        }
    }
}

//------------------------------------------------------------------------------
