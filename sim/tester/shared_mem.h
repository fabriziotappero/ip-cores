/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#ifndef __SHARED_MEM_H
#define __SHARED_MEM_H

//------------------------------------------------------------------------------

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef unsigned long  uint64;

typedef char  int8;
typedef short int16;
typedef int   int32;
typedef long  int64;

//------------------------------------------------------------------------------

union memory_t {
    uint8  bytes [134217728];
    uint16 shorts[67108864];
    uint32 ints  [33554432];
};

struct tlb_t {
    uint32 vpn;
    uint32 asid;
    uint32 pfn;
    uint32 n;
    uint32 d;
    uint32 v;
    uint32 g;
};

struct processor_state_t {
    uint32 reg[31];
    uint32 pc;
    //lo, hi not compared
    
    tlb_t tlb[64];
    
    uint32 index_p;
    uint32 index_index;
    
    uint32 random;
    
    uint32 entrylo_pfn;
    uint32 entrylo_n;
    uint32 entrylo_d;
    uint32 entrylo_v;
    uint32 entrylo_g;
    
    uint32 context_ptebase;
    uint32 context_badvpn;
    
    uint32 bad_vaddr;
    
    uint32 entryhi_vpn;
    uint32 entryhi_asid;
    
    uint32 sr_cp_usable;
    uint32 sr_rev_endian;
    uint32 sr_bootstrap_vec;
    uint32 sr_tlb_shutdown;
    uint32 sr_parity_err;
    uint32 sr_cache_miss;
    uint32 sr_parity_zero;
    uint32 sr_switch_cache;
    uint32 sr_isolate_cache;
    uint32 sr_irq_mask;
    uint32 sr_ku_ie;
    
    uint32 cause_branch_delay;
    uint32 cause_cp_error;
    uint32 cause_irq_pending;
    uint32 cause_exc_code;
    
    uint32 epc;
};

struct report_t {
    uint32 counter;
    uint32 exception;
    processor_state_t state;
};

struct processor_t {
    uint32 initialize_do;
    
    uint32 read_do;
    uint32 read_address;
    uint32 read_byteenable;
    uint32 read_data;
    
    uint32 write_do;
    uint32 write_address;
    uint32 write_byteenable;
    uint32 write_data;
    
    uint32 check_do;
    
    uint32   report_do;
    report_t report;
};

struct shared_mem_t {
    memory_t mem;
    
    uint32 reset_vector[1024];
    
    processor_state_t initial;
    
    uint32 test_finished;
    
    uint32 irq2_at_event;
    
    uint32 irq3_at_event;
    
    uint32 check_at_event;
    
    processor_t proc_ao;
    processor_t proc_vmips;
};

//------------------------------------------------------------------------------

#endif //__SHARED_MEM_H
