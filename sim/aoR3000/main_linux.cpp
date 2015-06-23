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

void usleep_or_finish() {
    if(shared_ptr->test_finished) {
        printf("Finishing.\n");
        exit(0);
    }
    usleep(1);
}

//128MB
#define MAX_MEMORY   0x08000000
#define RESET_VECTOR 0x1FC00000

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
    
    bool dump_enabled = false;
    
    //reset
    vluint64_t halfcycle = 0;
    
    top->clk = 0; top->rst_n = 1; top->eval(); if(dump_enabled) { tracer->dump(halfcycle); } halfcycle++;
    top->clk = 0; top->rst_n = 0; top->eval(); if(dump_enabled) { tracer->dump(halfcycle); } halfcycle++;
    top->rst_n = 1;
    
    printf("Waiting for initialize..."); fflush(stdout);
    while(shared_ptr->proc_ao.initialize_do == false) usleep_or_finish();
    
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
    bool   stall_state = false;
    
    bool   is_exception_waiting = false;
    
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
            
            if(read[0].address < MAX_MEMORY) {
                top->avm_readdata = shared_ptr->mem.ints[read[0].address/4];
            }
            else if(read[0].address >= RESET_VECTOR && read[0].address < RESET_VECTOR + sizeof(shared_ptr->reset_vector)) {
                top->avm_readdata = shared_ptr->reset_vector[(read[0].address - RESET_VECTOR)/4];
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
        
        if(stall_state == true) stall_state = ((top->v->pipeline_mem_inst->__PVT__mem_stall & 1) == 0)? false : true;
        
        uint32 cmd = top->v->pipeline_mem_inst->__PVT__mem_cmd & 0x7F;
        
        bool stall_start = cmd != 0   && stall_state == true;
        bool stall_end   = stall_wait && stall_state == false;
        
        uint32 was_instruction = ((cmd != 0) && stall_state == false) || stall_end;
        uint32 was_pc          = top->v->pipeline_mem_inst->__PVT__mem_pc_plus4;
        
        if(stall_start) {
            stall_wait = true;
        }
        else if(stall_end) {
            stall_wait = false;
        }
        
        if(stall_state == false) stall_state = ((top->v->pipeline_mem_inst->__PVT__mem_stall & 1) == 0)? false : true;
        
        //----------------------------------------------------------------------
        
        bool dump_enabled = false; //event_counter > 40565500;
        
        //---------------------------------------------------------------------- interrupt
        
        bool irq2_enable = ((was_instruction && stall_end == false && (event_counter + 1) == shared_ptr->irq2_at_event)) || ((event_counter + 1) > shared_ptr->irq2_at_event);
        bool irq3_enable = ((was_instruction && stall_end == false && (event_counter + 1) == shared_ptr->irq3_at_event)) || ((event_counter + 1) > shared_ptr->irq3_at_event);
        top->interrupt_vector = ((irq2_enable)? 1 : 0) | ((irq3_enable)? 2 : 0);
        
        if(dump_enabled) {
            printf("[%d]: ena2: %d ena3: %d cmd: %d at2: %d at3: %d stall_state: %d stall_start: %d stall_end: %d\n",
                event_counter, (uint32)irq2_enable, (uint32)irq3_enable, cmd, shared_ptr->irq2_at_event, shared_ptr->irq3_at_event, stall_state, (uint32)stall_start, (uint32)stall_end);
            fflush(stdout);
        }
      
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
        
        uint32 is_exception = (top->v->pipeline_if_inst->__PVT__exc_waiting & 1);
        
        //interrupt after stalled instruction ignored
        
        if((is_exception && was_instruction && (event_counter > 0 || halfcycle >= (4*2))) || was_instruction) {
            
            if(dump_enabled) { printf("inc: %d, exception: %d\n", event_counter, is_exception); fflush(stdout); }
            
            shared_ptr->proc_ao.report.counter = event_counter;
            
            if(shared_ptr->check_at_event == event_counter) {
                shared_ptr->proc_ao.check_do = true;
                
                while(shared_ptr->proc_ao.check_do) usleep_or_finish();
            }
            
            event_counter++;
        }

        is_exception_waiting = is_exception;
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
