/*
 * This file is subject to the terms and conditions of the GPL License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "shared_mem.h"
#include "vmips_emulator.h"

//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------


#define GET(field, mask) \
    (shared_ptr->initial.field & mask)

void CPZero::initialize() {
    for(int i=0; i<64; i++) {
        tlb[i].entryHi = 0;
        tlb[i].entryHi |= GET(tlb[i].vpn, 0xFFFFF) << 12;
        tlb[i].entryHi |= GET(tlb[i].asid, 0x3F)   << 6;
        
        tlb[i].entryLo = 0;
        tlb[i].entryLo |= GET(tlb[i].pfn, 0xFFFFF) << 12;
        tlb[i].entryLo |= GET(tlb[i].n,   0x1)     << 11;
        tlb[i].entryLo |= GET(tlb[i].d,   0x1)     << 10;
        tlb[i].entryLo |= GET(tlb[i].v,   0x1)     << 9;
        tlb[i].entryLo |= GET(tlb[i].g,   0x1)     << 8;
    }
    for(int i=0; i<32; i++) reg[i] = 0; //cp0 regs
    
    reg[0] |= GET(index_p, 0x1)      << 31;
    reg[0] |= GET(index_index, 0x3F) << 8;

    reg[1] |= GET(random, 0x3F) << 8;
  
    reg[2] |= GET(entrylo_pfn, 0xFFFFF) << 12;
    reg[2] |= GET(entrylo_n,   0x1)     << 11;
    reg[2] |= GET(entrylo_d,   0x1)     << 10;
    reg[2] |= GET(entrylo_v,   0x1)     << 9;
    reg[2] |= GET(entrylo_g,   0x1)     << 8;
    
    reg[4] |= GET(context_ptebase, 0x7FF)   << 21;
    reg[4] |= GET(context_badvpn,  0x7FFFF) << 2;
    
    reg[8] |= GET(bad_vaddr, 0xFFFFFFFF);
    
    reg[10] |= GET(entryhi_vpn, 0xFFFFF) << 12;
    reg[10] |= GET(entryhi_asid, 0x3F)   << 6;
    
    reg[12] |= GET(sr_cp_usable,     0xF) << 28;
    reg[12] |= GET(sr_rev_endian,    0x1) << 25;
    reg[12] |= GET(sr_bootstrap_vec, 0x1) << 22;
    reg[12] |= GET(sr_tlb_shutdown,  0x1) << 21;
    reg[12] |= GET(sr_parity_err,    0x1) << 20;
    reg[12] |= GET(sr_cache_miss,    0x1) << 19;
    reg[12] |= GET(sr_parity_zero,   0x1) << 18;
    reg[12] |= GET(sr_switch_cache,  0x1) << 17;
    reg[12] |= GET(sr_isolate_cache, 0x1) << 16;
    reg[12] |= GET(sr_irq_mask,      0xFF) << 8;
    reg[12] |= GET(sr_ku_ie,         0x3F) << 0;
    
    reg[13] |= GET(cause_branch_delay, 0x1)  << 31;
    reg[13] |= GET(cause_cp_error,     0x3)  << 28;
    reg[13] |= GET(cause_irq_pending,  0x3)  << 8; //only 2 lowest bits
    reg[13] |= GET(cause_exc_code,     0x1F) << 2;
    
    reg[14] |= GET(epc, 0xFFFFFFFF);
    
    reg[15] |= 0x00000230; /* MIPS R3000A */
}

void CPU::initialize() {
    
    put_reg(0, 0);
    for(int i=1; i<32; i++) { put_reg(i, GET(reg[i-1], 0xFFFFFFFF)); }
    
    pc = GET(pc, 0xFFFFFFFF);
    //not comapred: hi = GET(hi, 0xFFFFFFFF);
    //not compared: lo = GET(lo, 0xFFFFFFFF);
    
    cpzero->initialize();
}

//------------------------------------------------------------------------------

#define PUT(field, val, mask) \
    shared_ptr->proc_vmips.report.state.field = (val) & mask

void CPZero::report() {
    for(int i=0; i<64; i++) {
        PUT(tlb[i].vpn,  tlb[i].entryHi >> 12, 0xFFFFF);
        PUT(tlb[i].asid, tlb[i].entryHi >> 6,  0x3F);
        
        PUT(tlb[i].pfn,  tlb[i].entryLo >> 12, 0xFFFFF);
        PUT(tlb[i].n,    tlb[i].entryLo >> 11, 0x1);
        PUT(tlb[i].d,    tlb[i].entryLo >> 10, 0x1);
        PUT(tlb[i].v,    tlb[i].entryLo >> 9, 0x1);
        PUT(tlb[i].g,    tlb[i].entryLo >> 8, 0x1);
    }

    PUT(index_p,     reg[0] >> 31, 0x1);
    PUT(index_index, reg[0] >> 8,  0x3F);
   
    PUT(random, reg[1] >> 8, 0x3F);
    
    PUT(entrylo_pfn, reg[2] >> 12, 0xFFFFF);
    PUT(entrylo_n,   reg[2] >> 11, 0x1);
    PUT(entrylo_d,   reg[2] >> 10, 0x1);
    PUT(entrylo_v,   reg[2] >> 9,  0x1);
    PUT(entrylo_g,   reg[2] >> 8,  0x1);
    
    PUT(context_ptebase, reg[4] >> 21, 0x7FF);
    PUT(context_badvpn,  reg[4] >> 2,  0x7FFFF);
    
    PUT(bad_vaddr, reg[8], 0xFFFFFFFF);
    
    PUT(entryhi_vpn,  reg[10] >> 12, 0xFFFFF);
    PUT(entryhi_asid, reg[10] >> 6,  0x3F);
    
    PUT(sr_cp_usable,     reg[12] >> 28, 0xF);
    PUT(sr_rev_endian,    reg[12] >> 25, 0x1);
    PUT(sr_bootstrap_vec, reg[12] >> 22, 0x1);
    PUT(sr_tlb_shutdown,  reg[12] >> 21, 0x1);
    PUT(sr_parity_err,    reg[12] >> 20, 0x1);
    PUT(sr_cache_miss,    reg[12] >> 19, 0x1);
    PUT(sr_parity_zero,   reg[12] >> 18, 0x1);
    PUT(sr_switch_cache,  reg[12] >> 17, 0x1);
    PUT(sr_isolate_cache, reg[12] >> 16, 0x1);
    PUT(sr_irq_mask,      reg[12] >> 8,  0xFF);
    PUT(sr_ku_ie,         reg[12] >> 0,  0x3F);
    
    PUT(cause_branch_delay, reg[13] >> 31, 0x1);
    PUT(cause_cp_error,     reg[13] >> 28, 0x3);
    PUT(cause_irq_pending,  reg[13] >> 8,  0x3); //only 2 lowest bits
    PUT(cause_exc_code,     reg[13] >> 2,  0x1F);
    
    PUT(epc, reg[14], 0xFFFFFFFF);
}
    
void CPU::report() {
    for(int i=1; i<32; i++) PUT(reg[i-1], get_reg(i), 0xFFFFFFFF);
    
    PUT(pc, pc, 0xFFFFFFFF);
    //not compared: PUT(hi, hi, 0xFFFFFFFF);
    //not compared: PUT(lo, lo, 0xFFFFFFFF);
    
    cpzero->report();
}

//------------------------------------------------------------------------------

CPU *cpu = NULL;
uint32 event_counter = 0;

void usleep_or_finish() {
    if(shared_ptr->test_finished) {
        printf("Finishing.\n");
        exit(0);
    }
    usleep(1);
}

uint32 ao_interrupts() {
    return (shared_ptr->irq2_at_event == event_counter)? 1 << 10 : 0;
}

uint8 ao_fetch_byte(uint32 addr, bool cacheable, bool isolated) {
    //DBE IBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    if(addr < 0x8000000) {
        return shared_ptr->mem.bytes[addr];
    }
    
    shared_ptr->proc_vmips.read_address    = addr & 0xFFFFFFFC;
    shared_ptr->proc_vmips.read_byteenable = ((addr % 4) == 0)? 0x1 : ((addr % 4) == 1)? 0x2 : ((addr % 4) == 2)? 0x3 : 0x4;
    shared_ptr->proc_vmips.read_do         = true;
    
    while(shared_ptr->proc_vmips.read_do) usleep_or_finish();
    
    return (shared_ptr->proc_vmips.read_data >> ( ((addr % 4) == 0)? 0 : ((addr % 4) == 1)? 8 : ((addr % 4) == 2)? 16 : 24 )) & 0xFF;
}

uint16 ao_fetch_halfword(uint32 addr, bool cacheable, bool isolated) {
    //AdE
    if (addr % 2 != 0) {
        cpu->exception(AdEL,DATALOAD);
        return 0xffff;
    }
    
    //DBE IBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    if(addr < 0x8000000) {
        return shared_ptr->mem.shorts[addr/2];
    }
    
    shared_ptr->proc_vmips.read_address    = addr & 0xFFFFFFFC;
    shared_ptr->proc_vmips.read_byteenable = ((addr % 4) == 0)? 0x3 : 0xC;
    shared_ptr->proc_vmips.read_do         = true;
    
    while(shared_ptr->proc_vmips.read_do) usleep_or_finish();
    
    return (shared_ptr->proc_vmips.read_data >> ( ((addr % 4) == 0)? 0 : 16 )) & 0xFFFF;
}

uint32 ao_fetch_word(uint32 addr, int32 mode, bool cacheable, bool isolated) {
    //AdE
    if (addr % 4 != 0) {
        cpu->exception(AdEL,mode);
        return 0xffffffff;
    }
    
    //DBE IBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    if(addr < 0x8000000) {
        return shared_ptr->mem.ints[addr/4];
    }
    
    shared_ptr->proc_vmips.read_address    = addr & 0xFFFFFFFC;
    shared_ptr->proc_vmips.read_byteenable = 0xF;
    shared_ptr->proc_vmips.read_do         = true;
    
    while(shared_ptr->proc_vmips.read_do) usleep_or_finish();
    
    return (shared_ptr->proc_vmips.read_data) & 0xFFFFFFFF;
}

void ao_store_byte(uint32 addr, uint8 data, bool cacheable, bool isolated) {
    //DBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    shared_ptr->proc_vmips.write_address    = addr & 0xFFFFFFFC;
    shared_ptr->proc_vmips.write_byteenable = ((addr % 4) == 0)? 0x1 : ((addr % 4) == 1)? 0x2 : ((addr % 4) == 2)? 0x4 : 0x8;
    shared_ptr->proc_vmips.write_data       = ((addr % 4) == 0)? data : ((addr % 4) == 1)? data << 8 : ((addr % 4) == 2)? data << 16 : data << 24;
    shared_ptr->proc_vmips.write_do         = true;
    
    while(shared_ptr->proc_vmips.write_do) usleep_or_finish();
}

void ao_store_halfword(uint32 addr, uint16 data, bool cacheable, bool isolated) {
    //AdE
    if (addr % 2 != 0) {
        cpu->exception(AdES,DATASTORE);
        return;
    }
    
    //DBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    shared_ptr->proc_vmips.write_address    = addr & 0xFFFFFFFC;
    shared_ptr->proc_vmips.write_byteenable = ((addr % 4) == 0)? 0x3 : 0xC;
    shared_ptr->proc_vmips.write_data       = ((addr % 4) == 0)? data : data << 16;
    shared_ptr->proc_vmips.write_do         = true;
    
    while(shared_ptr->proc_vmips.write_do) usleep_or_finish();
}

void ao_store_word(uint32 addr, uint32 data, bool cacheable, bool isolated, uint32 byteenable) {
    //AdE
    if (addr % 4 != 0) {
        cpu->exception(AdES,DATASTORE);
        return;
    }
    
    //DBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    shared_ptr->proc_vmips.write_address    = addr & 0xFFFFFFFC;
    shared_ptr->proc_vmips.write_byteenable = byteenable;
    shared_ptr->proc_vmips.write_data       = data;
    shared_ptr->proc_vmips.write_do         = true;
    
    while(shared_ptr->proc_vmips.write_do) usleep_or_finish();
}

void fatal_error(const char *error, ...) {
    printf("[fatal_error]: %s\n", error);
    exit(-1);
}

//------------------------------------------------------------------------------


int main() {
    //map shared memory
    int fd = open("./../tester/shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
    if(fd == -1) {
        perror("open() failed for shared_mem.dat");
        return -1;
    }
    
    shared_ptr = (shared_mem_t *)mmap(NULL, sizeof(shared_mem_t), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    
    if(shared_ptr == MAP_FAILED) {
        perror("mmap() failed");
        close(fd);
        return -2;
    }
    
    cpu = new CPU();
    cpu->reset();
    
    printf("Waiting for initialize..."); fflush(stdout);
    while(shared_ptr->proc_vmips.initialize_do == false) usleep_or_finish();
    
    cpu->initialize();
    shared_ptr->proc_vmips.initialize_do = false;
    printf("done\n");
    
    while(true) {
        int exception_pending = cpu->step();
        
        cpu->report();
        shared_ptr->proc_vmips.report.counter     = event_counter;
        shared_ptr->proc_vmips.report.exception   = (exception_pending > 0)? 1 : 0;
        
        if(cpu->was_delayed_transfer && exception_pending == 0) shared_ptr->proc_vmips.report.state.pc = cpu->was_delayed_pc;
        
        shared_ptr->proc_vmips.report_do = true;
        
        while(shared_ptr->proc_vmips.report_do) usleep_or_finish();
        
        event_counter++;
    }
    return 0;
}

//------------------------------------------------------------------------------
