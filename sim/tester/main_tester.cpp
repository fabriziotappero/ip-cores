/*
 * This file is subject to the terms and conditions of the BSD License. See
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
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>

#include "shared_mem.h"
#include "tests.h"

//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

tst_t tst_instr_fetch_tlb_invalid_exc = { .init = NULL                      };                      
tst_t tst_arith_logic_till_exc        = { .init = arith_logic_till_exc_init };  
tst_t tst_exception_till_exc          = { .init = exception_till_exc_init   };
tst_t tst_tlb_commands_till_exc       = { .init = tlb_commands_till_exc_init};
tst_t tst_branch_till_exc             = { .init = branch_till_exc_init      };
tst_t tst_data_till_exc               = { .init = data_till_exc_init        };
tst_t tst_interrupt_till_exc          = { .init = interrupt_till_exc_init   };
tst_t tst_tlb_fetch_till_exc          = { .init = tlb_fetch_till_exc_init   };
tst_t tst_tlb_data_till_exc           = { .init = tlb_data_till_exc_init    };

//------------------------------------------------------------------------------

tst_t *tst_current = &tst_tlb_data_till_exc;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

bool is_diff(volatile report_t *vmips, volatile report_t *ao) {
    char buf[65536];
    memset(buf, 0, sizeof(buf));
    char *ptr = buf;
    
    bool diff;
    bool show = false;
    
    ptr += sprintf(ptr, "name               |d| vmips     | ao       \n");
    ptr += sprintf(ptr, "------------------------------------------\n");
    
    diff = vmips->counter != ao->counter; show = show || diff;
    ptr += sprintf(ptr, "counter            |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->counter, ao->counter);
    
    diff = vmips->exception != ao->exception; show = show || diff;
    ptr += sprintf(ptr, "exception          |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->exception, ao->exception);
    
    for(int i=1; i<32; i++) {
        diff = vmips->state.reg[i-1] != ao->state.reg[i-1]; show = show || diff;
        ptr += sprintf(ptr, "reg[%02d]            |%c| %08x | %08x \n", i, (diff)? '*' : ' ', vmips->state.reg[i-1], ao->state.reg[i-1]);
    }

    diff = vmips->state.pc != ao->state.pc; show = show || diff;
    ptr += sprintf(ptr, "pc                 |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->state.pc, ao->state.pc);
    
    //not comapred: diff = vmips->state.lo != ao->state.lo; show = show || diff;
    //not comapred: ptr += sprintf(ptr, "lo                 |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->state.lo, ao->state.lo);
    
    //not comapred: diff = vmips->state.hi != ao->state.hi; show = show || diff;
    //not comapred: ptr += sprintf(ptr, "hi                 |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->state.hi, ao->state.hi);
    
    diff = vmips->state.index_p != ao->state.index_p; show = show || diff;
    ptr += sprintf(ptr, "index_p            |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.index_p, ao->state.index_p);
    
    diff = vmips->state.index_index != ao->state.index_index; show = show || diff;
    ptr += sprintf(ptr, "index_index        |%c| %02x       | %02x       \n", (diff)? '*' : ' ', vmips->state.index_index, ao->state.index_index);
    
    diff = vmips->state.random != ao->state.random; show = show || diff;
    ptr += sprintf(ptr, "random             |%c| %02x       | %02x       \n", (diff)? '*' : ' ', vmips->state.random, ao->state.random);
    
    diff = vmips->state.entrylo_pfn != ao->state.entrylo_pfn; show = show || diff;
    ptr += sprintf(ptr, "entrylo_pfn        |%c| %05x    | %05x    \n", (diff)? '*' : ' ', vmips->state.entrylo_pfn, ao->state.entrylo_pfn);
    
    diff = vmips->state.entrylo_n != ao->state.entrylo_n; show = show || diff;
    ptr += sprintf(ptr, "entrylo_n          |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.entrylo_n, ao->state.entrylo_n);
    
    diff = vmips->state.entrylo_d != ao->state.entrylo_d; show = show || diff;
    ptr += sprintf(ptr, "entrylo_d          |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.entrylo_d, ao->state.entrylo_d);
    
    diff = vmips->state.entrylo_v != ao->state.entrylo_v; show = show || diff;
    ptr += sprintf(ptr, "entrylo_v          |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.entrylo_v, ao->state.entrylo_v);
    
    diff = vmips->state.entrylo_g != ao->state.entrylo_g; show = show || diff;
    ptr += sprintf(ptr, "entrylo_g          |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.entrylo_g, ao->state.entrylo_g);
    
    diff = vmips->state.context_ptebase != ao->state.context_ptebase; show = show || diff;
    ptr += sprintf(ptr, "context_ptebase    |%c| %03x      | %03x      \n", (diff)? '*' : ' ', vmips->state.context_ptebase, ao->state.context_ptebase);
    
    diff = vmips->state.context_badvpn != ao->state.context_badvpn; show = show || diff;
    ptr += sprintf(ptr, "context_badvpn     |%c| %05x    | %05x    \n", (diff)? '*' : ' ', vmips->state.context_badvpn, ao->state.context_badvpn);
    
    diff = vmips->state.bad_vaddr != ao->state.bad_vaddr; show = show || diff;
    ptr += sprintf(ptr, "bad_vaddr          |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->state.bad_vaddr, ao->state.bad_vaddr);
    
    diff = vmips->state.entryhi_vpn != ao->state.entryhi_vpn; show = show || diff;
    ptr += sprintf(ptr, "entryhi_vpn        |%c| %05x    | %05x    \n", (diff)? '*' : ' ', vmips->state.entryhi_vpn, ao->state.entryhi_vpn);
    
    diff = vmips->state.entryhi_asid != ao->state.entryhi_asid; show = show || diff;
    ptr += sprintf(ptr, "entryhi_asid       |%c| %02x       | %02x       \n", (diff)? '*' : ' ', vmips->state.entryhi_asid, ao->state.entryhi_asid);
    
    diff = vmips->state.sr_cp_usable != ao->state.sr_cp_usable; show = show || diff;
    ptr += sprintf(ptr, "sr_cp_usable       |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_cp_usable, ao->state.sr_cp_usable);
    
    diff = vmips->state.sr_rev_endian != ao->state.sr_rev_endian; show = show || diff;
    ptr += sprintf(ptr, "sr_rev_endian      |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_rev_endian, ao->state.sr_rev_endian);
    
    diff = vmips->state.sr_bootstrap_vec != ao->state.sr_bootstrap_vec; show = show || diff;
    ptr += sprintf(ptr, "sr_bootstrap_vec   |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_bootstrap_vec, ao->state.sr_bootstrap_vec);
    
    diff = vmips->state.sr_tlb_shutdown != ao->state.sr_tlb_shutdown; show = show || diff;
    ptr += sprintf(ptr, "sr_tlb_shutdown    |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_tlb_shutdown, ao->state.sr_tlb_shutdown);
    
    diff = vmips->state.sr_parity_err != ao->state.sr_parity_err; show = show || diff;
    ptr += sprintf(ptr, "sr_parity_err      |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_parity_err, ao->state.sr_parity_err);
    
    diff = vmips->state.sr_cache_miss != ao->state.sr_cache_miss; show = show || diff;
    ptr += sprintf(ptr, "sr_cache_miss      |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_cache_miss, ao->state.sr_cache_miss);
    
    diff = vmips->state.sr_parity_zero != ao->state.sr_parity_zero; show = show || diff;
    ptr += sprintf(ptr, "sr_parity_zero     |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_parity_zero, ao->state.sr_parity_zero);
    
    diff = vmips->state.sr_switch_cache != ao->state.sr_switch_cache; show = show || diff;
    ptr += sprintf(ptr, "sr_switch_cache    |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_switch_cache, ao->state.sr_switch_cache);
    
    diff = vmips->state.sr_isolate_cache != ao->state.sr_isolate_cache; show = show || diff;
    ptr += sprintf(ptr, "sr_isolate_cache   |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.sr_isolate_cache, ao->state.sr_isolate_cache);
    
    diff = vmips->state.sr_irq_mask != ao->state.sr_irq_mask; show = show || diff;
    ptr += sprintf(ptr, "sr_irq_mask        |%c| %02x       | %02x       \n", (diff)? '*' : ' ', vmips->state.sr_irq_mask, ao->state.sr_irq_mask);
    
    diff = vmips->state.sr_ku_ie != ao->state.sr_ku_ie; show = show || diff;
    ptr += sprintf(ptr, "sr_ku_ie           |%c| %02x       | %02x       \n", (diff)? '*' : ' ', vmips->state.sr_ku_ie, ao->state.sr_ku_ie);
    
    diff = vmips->state.cause_branch_delay != ao->state.cause_branch_delay; show = show || diff;
    ptr += sprintf(ptr, "cause_branch_delay |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.cause_branch_delay, ao->state.cause_branch_delay);
    
    diff = vmips->state.cause_cp_error != ao->state.cause_cp_error; show = show || diff;
    ptr += sprintf(ptr, "cause_cp_error     |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.cause_cp_error, ao->state.cause_cp_error);
    
    diff = vmips->state.cause_irq_pending != ao->state.cause_irq_pending; show = show || diff;
    ptr += sprintf(ptr, "cause_irq_pending  |%c| %01x        | %01x        \n", (diff)? '*' : ' ', vmips->state.cause_irq_pending, ao->state.cause_irq_pending);
    
    diff = vmips->state.cause_exc_code != ao->state.cause_exc_code; show = show || diff;
    ptr += sprintf(ptr, "cause_exc_code     |%c| %02x       | %02x       \n", (diff)? '*' : ' ', vmips->state.cause_exc_code, ao->state.cause_exc_code);
    
    diff = vmips->state.epc != ao->state.epc; show = show || diff;
    ptr += sprintf(ptr, "epc                |%c| %08x | %08x \n", (diff)? '*' : ' ', vmips->state.epc, ao->state.epc);

    for(int i=0; i<64; i++) {
        diff = vmips->state.tlb[i].vpn != ao->state.tlb[i].vpn; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].vpn        |%c| %05x    | %05x    \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].vpn, ao->state.tlb[i].vpn);
        
        diff = vmips->state.tlb[i].asid != ao->state.tlb[i].asid; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].asid       |%c| %02x       | %02x       \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].asid, ao->state.tlb[i].asid);
        
        diff = vmips->state.tlb[i].pfn != ao->state.tlb[i].pfn; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].pfn        |%c| %05x    | %05x    \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].pfn, ao->state.tlb[i].pfn);
        
        diff = vmips->state.tlb[i].n != ao->state.tlb[i].n; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].n          |%c| %01x        | %01x        \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].n, ao->state.tlb[i].n);
        
        diff = vmips->state.tlb[i].d != ao->state.tlb[i].d; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].d          |%c| %01x        | %01x        \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].d, ao->state.tlb[i].d);
        
        diff = vmips->state.tlb[i].v != ao->state.tlb[i].v; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].v          |%c| %01x        | %01x        \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].v, ao->state.tlb[i].v);
        
        diff = vmips->state.tlb[i].g != ao->state.tlb[i].g; show = show || diff;
        ptr += sprintf(ptr, "tlb[%02d].g          |%c| %01x        | %01x        \n", i, (diff)? '*' : ' ', vmips->state.tlb[i].g, ao->state.tlb[i].g);
    }
    
    if(show) {
        printf("%s", buf);
        return true;
    }
    return false;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    
    int int_ret;
    
    //open file with truncate
    FILE *fp = fopen("shared_mem.dat", "wb");
    if(fp == NULL) {
        perror("Can not truncate file shared_mem.dat");
        return -1;
    }
    uint8 *buf = new uint8[sizeof(shared_mem_t)];
    memset(buf, 0, sizeof(shared_mem_t));
    
    int_ret = fwrite(buf, sizeof(shared_mem_t), 1, fp);
    delete buf;
    if(int_ret != 1) {
        perror("Can not zero-fill file shared_mem.dat");
        fclose(fp);
        return -2;
    }
    fclose(fp);
    
    //--------------------------------------------------------------------------
    
    //map shared memory
    int fd = open("./shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
    if(fd == -1) {
        perror("open() failed for shared_mem.dat");
        return -3;
    }
    
    shared_ptr = (shared_mem_t *)mmap(NULL, sizeof(shared_mem_t), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    
    if(shared_ptr == MAP_FAILED) {
        perror("mmap() failed");
        close(fd);
        return -4;
    }
    
    //--------------------------------------------------------------------------
    
    srand(0);
    
    while(true) {
        //----------------------------------------------------------------------
        memset((void *)shared_ptr, 0, sizeof(shared_mem_t));
        
        //---------------------------------------------------------------------- run init function
        
        if(tst_current->init != NULL) tst_current->init(tst_current, (shared_mem_t *)shared_ptr);
        
        //----------------------------------------------------------------------
        
        pid_t proc_vmips = fork();
        if(proc_vmips == 0) {
            system("cd ./../vmips && ./main_tester > ./vmips_output.txt");
            return 0;
        }
        
        pid_t proc_ao = fork();
        if(proc_ao == 0) {
            system("cd ./../aoR3000 && ./obj_dir/VaoR3000 > ./ao_output.txt");
            return 0;
        }
        
        //----------------------------------------------------------------------
        
        printf("Waiting for init of vmips..."); fflush(stdout);
        shared_ptr->proc_vmips.initialize_do = true;
        
        while(shared_ptr->proc_vmips.initialize_do) usleep(1);
        printf("done\n");
        
        printf("Waiting for init of aoR3000...");  fflush(stdout);
        shared_ptr->proc_ao.initialize_do = true;
        
        while(shared_ptr->proc_ao.initialize_do) usleep(1);
        printf("done\n");
        
        while(true) {
            if(shared_ptr->proc_vmips.report_do && shared_ptr->proc_ao.report_do) {
                bool diff = is_diff(&(shared_ptr->proc_vmips.report), &(shared_ptr->proc_ao.report));
                if(diff) {
                    printf("\nTEST FAILED. DIFF.\n");
                    shared_ptr->test_finished = true;
                    return -1;
                }
                if(shared_ptr->proc_vmips.report.exception == 1 && shared_ptr->proc_ao.report.exception == 1) {
                    printf("\nTEST OK.\n");
                    shared_ptr->test_finished = true;
                    break;
                }
                
                shared_ptr->proc_vmips.report_do = shared_ptr->proc_ao.report_do = false;
                printf("check ok\n");
            }
            
            while(shared_ptr->proc_vmips.write_do || shared_ptr->proc_ao.write_do) {
                if(shared_ptr->proc_vmips.write_do && shared_ptr->proc_ao.write_do) {
                    
                    if( shared_ptr->proc_vmips.write_address    == shared_ptr->proc_ao.write_address &&
                        shared_ptr->proc_vmips.write_byteenable == shared_ptr->proc_ao.write_byteenable &&
                        shared_ptr->proc_vmips.write_data       == shared_ptr->proc_ao.write_data)
                    {
                        printf("write: %08x %01x %08x\n", shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                        
                        uint32 byteena = shared_ptr->proc_vmips.write_byteenable;
                        uint32 value   = shared_ptr->proc_vmips.write_data;
                        
                        for(uint32 i=0; i<4; i++) {
                            if(byteena & 1) shared_ptr->mem.bytes[shared_ptr->proc_vmips.write_address + i] = value & 0xFF;
                            value >>= 8;
                            byteena >>= 1;
                        }
                        
                        shared_ptr->proc_vmips.write_do = false;
                        shared_ptr->proc_ao.write_do    = false;
                    }
                    else {
                        printf("vmips: %08x %01x %08x\n", shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                        printf("ao:    %08x %01x %08x\n", shared_ptr->proc_ao.write_address,    shared_ptr->proc_ao.write_byteenable,    shared_ptr->proc_ao.write_data);
                        
                        printf("\nTEST FAILED. MEM WRITE DIFF.\n");
                        shared_ptr->test_finished = true;
                        return -1;
                    }
                }
            }
        }
    
        //---------------------------------------------------------------------- wait for process end
        waitpid(proc_vmips, NULL, 0);
        waitpid(proc_ao, NULL, 0);
    }
    return 0;
}

//------------------------------------------------------------------------------
