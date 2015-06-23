/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstdlib>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "VaoR3000.h"
#include "VaoR3000_aoR3000.h"
#include "VaoR3000_pipeline_rf.h"
#include "VaoR3000_pipeline_if.h"
#include "VaoR3000_pipeline_mem.h"
#include "VaoR3000_block_muldiv.h"
#include "VaoR3000_memory_tlb_ram.h"
#include "VaoR3000_block_cp0.h"
#include "VaoR3000_pipeline_exe.h"
#include "VaoR3000_model_true_dual_ram__W32_WB4.h"
#include "VaoR3000_model_simple_dual_ram__W20_WB5.h"

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "shared_mem.h"

//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------

#define GET(field, mask) \
    (shared_ptr->initial.field & mask)

void initialize(VaoR3000 *top) {
    
    top->v->pipeline_rf_inst->regs_a_inst->__PVT__mem[0] = top->v->pipeline_rf_inst->regs_b_inst->__PVT__mem[0] = 0;
    for(int i=1; i<32; i++) top->v->pipeline_rf_inst->regs_a_inst->__PVT__mem[i] = top->v->pipeline_rf_inst->regs_b_inst->__PVT__mem[i] = GET(reg[i-1], 0xFFFFFFFF);
    
    top->v->pipeline_if_inst->__PVT__exc_start_pc           = GET(pc, 0xFFFFFFFF);
    //not compared: top->v->pipeline_mem_inst->block_muldiv_inst->__PVT__hi = GET(hi, 0xFFFFFFFF);
    //not compared: top->v->pipeline_mem_inst->block_muldiv_inst->__PVT__lo = GET(lo, 0xFFFFFFFF);
    
    for(int i=0; i<64; i++) {
/*
[19:0]  vpn
[39:20] pfn
[45:40] asid
[46]    n noncachable
[47]    d dirty = write-enable
[48]    v valid
[49]    g global
*/
        uint64 entry = 0;
        entry |= (uint64)(GET(tlb[i].vpn, 0xFFFFF)) << 0;
        entry |= (uint64)(GET(tlb[i].asid, 0x3F))   << 40;
        entry |= (uint64)(GET(tlb[i].pfn, 0xFFFFF)) << 20;
        entry |= (uint64)(GET(tlb[i].n,   0x1))     << 46;
        entry |= (uint64)(GET(tlb[i].d,   0x1))     << 47;
        entry |= (uint64)(GET(tlb[i].v,   0x1))     << 48;
        entry |= (uint64)(GET(tlb[i].g,   0x1))     << 49;
        
        if((i % 8) == 0) top->v->memory_tlb_ram_inst->tlb0_inst->__PVT__mem[i/8]     = entry;
        if((i % 8) == 1) top->v->memory_tlb_ram_inst->tlb0_inst->__PVT__mem[8+(i/8)] = entry;
        if((i % 8) == 2) top->v->memory_tlb_ram_inst->tlb1_inst->__PVT__mem[i/8]     = entry;
        if((i % 8) == 3) top->v->memory_tlb_ram_inst->tlb1_inst->__PVT__mem[8+(i/8)] = entry;
        if((i % 8) == 4) top->v->memory_tlb_ram_inst->tlb2_inst->__PVT__mem[i/8]     = entry;
        if((i % 8) == 5) top->v->memory_tlb_ram_inst->tlb2_inst->__PVT__mem[8+(i/8)] = entry;
        if((i % 8) == 6) top->v->memory_tlb_ram_inst->tlb3_inst->__PVT__mem[i/8]     = entry;
        if((i % 8) == 7) top->v->memory_tlb_ram_inst->tlb3_inst->__PVT__mem[8+(i/8)] = entry;
    }
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_probe   = GET(index_p, 0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlbr_index  = GET(index_index, 0x3F);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_random  = GET(random, 0x3F);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_pfn = GET(entrylo_pfn, 0xFFFFF);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_n   = GET(entrylo_n,   0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_d   = GET(entrylo_d,   0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_v   = GET(entrylo_v,   0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_g   = GET(entrylo_g,   0x1);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_ptebase = GET(context_ptebase, 0x7FF);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_badvpn  = GET(context_badvpn,  0x7FFFF);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__badvaddr    = GET(bad_vaddr, 0xFFFFFFFF);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entryhi_vpn  = GET(entryhi_vpn, 0xFFFFF);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entryhi_asid = GET(entryhi_asid, 0x3F);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_coproc_usable     = GET(sr_cp_usable,     0xF);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_reverse_endian    = GET(sr_rev_endian,    0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_bev               = GET(sr_bootstrap_vec, 0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_tlb_shutdown      = GET(sr_tlb_shutdown,  0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_parity_error      = GET(sr_parity_err,    0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_cm                = GET(sr_cache_miss,    0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_parity_zero       = GET(sr_parity_zero,   0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__config_switch_caches = GET(sr_switch_cache,  0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__config_isolate_cache = GET(sr_isolate_cache, 0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_im                = GET(sr_irq_mask,      0xFF);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_ku_ie             = GET(sr_ku_ie,         0x3F);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_bd          = GET(cause_branch_delay, 0x1);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_ce          = GET(cause_cp_error,     0x3);
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_ip_writable = GET(cause_irq_pending,  0x3); //only 2 lowest bits
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_exccode     = GET(cause_exc_code,     0x1F);
    
    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__epc = GET(epc, 0xFFFFFFFF);
}

//------------------------------------------------------------------------------

#define PUT(field, val, mask) \
    shared_ptr->proc_ao.report.state.field = (val) & mask

void report(VaoR3000 *top, bool is_cp0_update, bool is_tlbr) {
    
    for(int i=1; i<32; i++) PUT(reg[i-1], top->v->pipeline_rf_inst->regs_a_inst->__PVT__mem[i], 0xFFFFFFFF);
    
    PUT(pc, top->v->pipeline_if_inst->__PVT__if_pc,                  0xFFFFFFFF);
    //not compared: PUT(hi, top->v->pipeline_mem_inst->block_muldiv_inst->__PVT__hi, 0xFFFFFFFF);
    //not compared: PUT(lo, top->v->pipeline_mem_inst->block_muldiv_inst->__PVT__lo, 0xFFFFFFFF);
    
    if(is_tlbr) {
        PUT(entrylo_pfn, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_pfn, 0xFFFFF);
        PUT(entrylo_n,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_n,   0x1);
        PUT(entrylo_d,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_d,   0x1);
        PUT(entrylo_v,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_v,   0x1);
        PUT(entrylo_g,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_g,   0x1);
    
        PUT(entryhi_vpn,  top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entryhi_vpn,  0xFFFFF);
        PUT(entryhi_asid, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entryhi_asid, 0x3F);
    }
    
    if(is_cp0_update == false) return;
    
    for(int i=0; i<64; i++) {
        uint64 entry = 0;
        if((i % 8) == 0) entry = top->v->memory_tlb_ram_inst->tlb0_inst->__PVT__mem[i/8];
        if((i % 8) == 1) entry = top->v->memory_tlb_ram_inst->tlb0_inst->__PVT__mem[8+(i/8)];
        if((i % 8) == 2) entry = top->v->memory_tlb_ram_inst->tlb1_inst->__PVT__mem[i/8];
        if((i % 8) == 3) entry = top->v->memory_tlb_ram_inst->tlb1_inst->__PVT__mem[8+(i/8)];
        if((i % 8) == 4) entry = top->v->memory_tlb_ram_inst->tlb2_inst->__PVT__mem[i/8];
        if((i % 8) == 5) entry = top->v->memory_tlb_ram_inst->tlb2_inst->__PVT__mem[8+(i/8)];
        if((i % 8) == 6) entry = top->v->memory_tlb_ram_inst->tlb3_inst->__PVT__mem[i/8];
        if((i % 8) == 7) entry = top->v->memory_tlb_ram_inst->tlb3_inst->__PVT__mem[8+(i/8)];
/*
[19:0]  vpn
[39:20] pfn
[45:40] asid
[46]    n noncachable
[47]    d dirty = write-enable
[48]    v valid
[49]    g global
*/
        PUT(tlb[i].vpn,  entry >> 0,  0xFFFFF);
        PUT(tlb[i].asid, entry >> 40, 0x3F);
        
        PUT(tlb[i].pfn,  entry >> 20, 0xFFFFF);
        PUT(tlb[i].n,    entry >> 46, 0x1);
        PUT(tlb[i].d,    entry >> 47, 0x1);
        PUT(tlb[i].v,    entry >> 48, 0x1);
        PUT(tlb[i].g,    entry >> 49, 0x1);
    }
    
    PUT(index_p,     top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_probe,  0x1);
    PUT(index_index, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlbr_index, 0x3F);
    
    PUT(random, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_random, 0x3F);
    
    PUT(entrylo_pfn, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_pfn, 0xFFFFF);
    PUT(entrylo_n,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_n,   0x1);
    PUT(entrylo_d,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_d,   0x1);
    PUT(entrylo_v,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_v,   0x1);
    PUT(entrylo_g,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entrylo_g,   0x1);
    
    PUT(context_ptebase, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_ptebase, 0x7FF);
    PUT(context_badvpn,  top->v->pipeline_mem_inst->block_cp0_inst->__PVT__tlb_badvpn,  0x7FFFF);
    
    PUT(bad_vaddr, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__badvaddr, 0xFFFFFFFF);
    
    PUT(entryhi_vpn,  top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entryhi_vpn,  0xFFFFF);
    PUT(entryhi_asid, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__entryhi_asid, 0x3F);
    
    PUT(sr_cp_usable,     top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_coproc_usable,     0xF);
    PUT(sr_rev_endian,    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_reverse_endian,    0x1);
    PUT(sr_bootstrap_vec, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_bev,               0x1);
    PUT(sr_tlb_shutdown,  top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_tlb_shutdown,      0x1);
    PUT(sr_parity_err,    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_parity_error,      0x1);
    PUT(sr_cache_miss,    top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_cm,                0x1);
    PUT(sr_parity_zero,   top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_parity_zero,       0x1);
    PUT(sr_switch_cache,  top->v->pipeline_mem_inst->block_cp0_inst->__PVT__config_switch_caches, 0x1);
    PUT(sr_isolate_cache, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__config_isolate_cache, 0x1);
    PUT(sr_irq_mask,      top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_im,                0xFF);
    PUT(sr_ku_ie,         top->v->pipeline_mem_inst->block_cp0_inst->__PVT__sr_ku_ie,             0x3F);
    
    PUT(cause_branch_delay, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_bd,          0x1);
    PUT(cause_cp_error,     top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_ce,          0x3);
    PUT(cause_irq_pending,  top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_ip_writable, 0x3); //only 2 lowest bits
    PUT(cause_exc_code,     top->v->pipeline_mem_inst->block_cp0_inst->__PVT__cause_exccode,     0x1F);
    
    PUT(epc, top->v->pipeline_mem_inst->block_cp0_inst->__PVT__epc, 0xFFFFFFFF);
}

//------------------------------------------------------------------------------

void usleep_or_finish() {
    if(shared_ptr->test_finished) {
        printf("Finishing.\n");
        exit(0);
    }
    usleep(1);
}

//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    
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
    
    //--------------------------------------------------------------------------
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    VaoR3000 *top = new VaoR3000();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("aoR3000.vcd");
    
    bool dump_enabled = true;
    
    //reset
    vluint64_t halfcycle = 0;
    
    top->clk = 0; top->rst_n = 1; top->eval(); if(dump_enabled) { tracer->dump(halfcycle); } halfcycle++;
    top->clk = 0; top->rst_n = 0; top->eval(); if(dump_enabled) { tracer->dump(halfcycle); } halfcycle++;
    top->rst_n = 1;
    
    printf("Waiting for initialize..."); fflush(stdout);
    while(shared_ptr->proc_ao.initialize_do == false) usleep_or_finish();
    
    initialize(top);
    shared_ptr->proc_ao.initialize_do = false;
    printf("done\n");
    
    
    //--------------------------------------------------------------------------
    
    uint32 event_counter = 0;
    
    struct read_t {
        uint32 count;
        uint32 byteenable;
        uint32 address;
    };
    read_t read[5];
    uint32 read_list_count = sizeof(read) / sizeof(read_t);
    memset(read, 0, sizeof(read));
    
    bool   stall_wait = false;
    uint32 stall_pc = 0;
    uint32 stall_branched = 0;   
    bool   stall_state = false;
    
    while(!Verilated::gotFinish()) {
        
        //---------------------------------------------------------------------- avalon master
        
        top->avm_waitrequest   = 0;
        top->avm_readdatavalid = 0;
        top->avm_readdata      = 0;
        
        if(top->avm_read) {
            bool found = false;
            for(uint32 i=0; i<read_list_count; i++) {
                if(read[i].count == 0) {
                    read[i].address    = top->avm_address & 0xFFFFFFFC;
                    read[i].byteenable = top->avm_byteenable;
                    read[i].count      = top->avm_burstcount;
                    
                    found = true;
                    break;
                }
            }
            if(found == false) {
                printf("[aoR3000]: read fatal error: too many reads.\n");
                exit(-1);
            }
        }
        else if(read[0].count > 0) {
            top->avm_readdatavalid = 1;
            
            if(read[0].address < 0x08000000) {
                top->avm_readdata = shared_ptr->mem.ints[read[0].address/4];
            }
            else {
                shared_ptr->proc_ao.read_address    = read[0].address & 0xFFFFFFFC;
                shared_ptr->proc_ao.read_byteenable = read[0].byteenable;
                shared_ptr->proc_ao.read_do         = true;

                while(shared_ptr->proc_ao.read_do) usleep_or_finish();
            
                top->avm_readdata = shared_ptr->proc_ao.read_data;
            }
            read[0].address += 4;
            read[0].count--;
            
            if(read[0].count == 0) {
                memmove(&read[0], &read[1], sizeof(read) - sizeof(read_t));
            }
        }
        
        //----------------------------------------------------------------------
        
        uint32 cmd = top->v->pipeline_mem_inst->__PVT__mem_cmd & 0x7F;
        
        bool stall_start = cmd != 0   && stall_state == true;
        bool stall_end   = stall_wait && stall_state == false;
        
        uint32 was_instruction = ((cmd != 0) && stall_state == false) || stall_end;
        uint32 was_pc          = top->v->pipeline_mem_inst->__PVT__mem_pc_plus4;
        
        if(stall_start) {
            stall_wait = true;
            stall_pc = was_pc;
        }
        else if(stall_end) {
            stall_wait = false;
        }
        
        stall_state = (top->v->pipeline_mem_inst->__PVT__mem_stall & 1) != 0;
        
        report(top, true, false);
        
        //---------------------------------------------------------------------- interrupt
        
        top->interrupt_vector = (was_instruction && shared_ptr->irq2_at_event == (event_counter + 1))? 0x1 : 0;
        
        //---------------------------------------------------------------------- clock
        top->clk = 0;
        top->eval();
        
        if(dump_enabled) tracer->dump(halfcycle);
        halfcycle++;
        
        top->clk = 1;
        top->eval();
        
        if(dump_enabled) tracer->dump(halfcycle);
        halfcycle++;
        
        tracer->flush();
        
        //----------------------------------------------------------------------
        if(top->avm_write) {
            if(top->avm_burstcount != 1) {
                printf("[avalon master error]: top->avm_burstcount(%d) != 1\n", top->avm_burstcount);
                exit(-1);
            }
            
            uint32 mask = 0;
            uint32 byteena = top->avm_byteenable;
            for(uint32 i=0; i<4; i++) {
                if(byteena & 1) mask |= (0xFF << (i*8));
                byteena >>= 1;
            }
            
            shared_ptr->proc_ao.write_address    = top->avm_address & 0xFFFFFFFC;
            shared_ptr->proc_ao.write_byteenable = top->avm_byteenable;
            shared_ptr->proc_ao.write_data       = top->avm_writedata & mask;
            shared_ptr->proc_ao.write_do         = true;

            while(shared_ptr->proc_ao.write_do) usleep_or_finish();
        }
        
        uint32 is_exception = top->v->pipeline_if_inst->__PVT__exc_waiting & 1;
        
        if((is_exception && (event_counter > 0 || halfcycle >= (4*2))) || was_instruction) {
            
            was_pc       = (stall_end)? stall_pc       : was_pc;
            
            report(top, is_exception, cmd == 40); //TLBR
            shared_ptr->proc_ao.report.counter     = event_counter;
            shared_ptr->proc_ao.report.exception   = (is_exception)? 1 : 0;
            
            if(is_exception)    PUT(pc, top->v->pipeline_if_inst->__PVT__exc_start_pc, 0xFFFFFFFF);
            else                PUT(pc, was_pc, 0xFFFFFFFF);
            
            shared_ptr->proc_ao.report_do = true;
        
            while(shared_ptr->proc_ao.report_do) usleep_or_finish();
            
            event_counter++;
        }
    }
    
    top->final();
    delete top;
    return 0;
}

//------------------------------------------------------------------------------

/*
module aoR3000(
    input               clk,
    input               rst_n,
    
    //
    input       [5:0]   interrupt_vector,
    
    //
    output      [31:0]  avm_address,
    output      [31:0]  avm_writedata,
    output      [3:0]   avm_byteenable,
    output      [2:0]   avm_burstcount,
    output              avm_write,
    output              avm_read,
    
    input               avm_waitrequest,
    input               avm_readdatavalid,
    input       [31:0]  avm_readdata
);
*/

//------------------------------------------------------------------------------
