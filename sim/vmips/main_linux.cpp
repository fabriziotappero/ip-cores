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

void CPZero::initialize() {
}

void CPU::initialize() {
}

//------------------------------------------------------------------------------

void CPZero::report() {
}
    
void CPU::report() {
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

//128MB
#define MAX_MEMORY   0x08000000
#define RESET_VECTOR 0x1FC00000

uint32 isolated_cache[512];

uint32 ao_interrupts() {
    return ((event_counter >= shared_ptr->irq2_at_event)? 1 << 10 : 0) | ((event_counter >= shared_ptr->irq3_at_event)? 2 << 10 : 0);
}

uint8 ao_fetch_byte(uint32 addr, bool cacheable, bool isolated) {
    //DBE IBE
    //cpu->exception((mode == INSTFETCH / DATALOAD ? IBE : DBE), mode);
    
    if(isolated) return
        ((addr %4) == 0)?   ((isolated_cache[(addr >> 2)&0x1FF] >> 0) & 0xFF) :
        ((addr %4) == 1)?   ((isolated_cache[(addr >> 2)&0x1FF] >> 8) & 0xFF) :
        ((addr %4) == 2)?   ((isolated_cache[(addr >> 2)&0x1FF] >> 16) & 0xFF) :
                            ((isolated_cache[(addr >> 2)&0x1FF] >> 24) & 0xFF);
    
    if(addr < MAX_MEMORY) {
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
    
    if(isolated) return
        ((addr %4) == 0)?   ((isolated_cache[(addr >> 2)&0x1FF] >> 0) & 0xFFFF) :
                            ((isolated_cache[(addr >> 2)&0x1FF] >> 16) & 0xFFFF);
    
    if(addr < MAX_MEMORY) {
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
    
    if(isolated && mode == DATALOAD) return ((isolated_cache[(addr >> 2)&0x1FF] >> 0) & 0xFFFFFFFF);
    
    if(addr < MAX_MEMORY) {
        return shared_ptr->mem.ints[addr/4];
    }
    else if(addr >= RESET_VECTOR && addr < RESET_VECTOR + sizeof(shared_ptr->reset_vector)) {
        return shared_ptr->reset_vector[(addr - RESET_VECTOR)/4];
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
    
    if(isolated) return;
    
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
    
    if(isolated) return;
    
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
    
    if(isolated) {
        isolated_cache[(addr >> 2)&0x1FF] = data;
        return;
    }
    
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
        bool do_debug = false;//event_counter > 40565500;
        
        int exception_pending = cpu->step(do_debug);
        fflush(stdout);
        
        shared_ptr->proc_vmips.report.counter = event_counter;
        
        if(shared_ptr->check_at_event == event_counter) {
            shared_ptr->proc_vmips.check_do = true;
            
            while(shared_ptr->proc_vmips.check_do) usleep_or_finish();
        }
        
        event_counter++;
    }
    return 0;
}

//------------------------------------------------------------------------------
