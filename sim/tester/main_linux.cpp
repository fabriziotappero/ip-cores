/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <pty.h>
#include <poll.h>

#include "shared_mem.h"

//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------

//128MB
#define MAX_MEMORY   0x8000000
#define RESET_VECTOR 0x1FC00000

int main(int argc, char **argv) {
    
    if(argc != 2) {
        printf("Error: missing argument: path to vmlinux.bin file !\n");
        return -1;
    }
    
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
    
    //----------------------------------------------------------------------
    memset((void *)shared_ptr, 0, sizeof(shared_mem_t));
    
    //load linux kernel binary from address 0
    FILE *kernel_fp = fopen(argv[1], "rb");
    if(kernel_fp == NULL) {
        printf("Error: can not open file: %s\n", argv[1]);
        return -1;
    }
    uint8 *kernel_ptr = (uint8 *)shared_ptr->mem.bytes;
    while(true) {
        int_ret = fread(kernel_ptr, 1, 8192, kernel_fp);
        if(int_ret == 0) break;
        kernel_ptr += int_ret;
    }
    fclose(kernel_fp);
    
    printf("loaded linux kernel size: %d bytes.\n", (kernel_ptr - shared_ptr->mem.bytes));
    
    //----------------------------------------------------------------------
    
    uint32 *reset_ptr = (uint32 *)shared_ptr->reset_vector;
    
    reset_ptr[0] = (0b000000 << 26) | (0 << 21) | (1 << 16) | (1 << 11) | (0b00000 << 6) | (0b100100);   //AND R1,R0,R1 -- clear R1
    reset_ptr[1] = (0b001111 << 26) | (0 << 21) | (1 << 16) | 0x8000;                                    //LUI R1,0x8000
    reset_ptr[2] = (0b001101 << 26) | (1 << 21) | (1 << 16) | 0x0400;                                    //ORI R1,R1,0x400
    reset_ptr[3] = (0b000000 << 26) | (1 << 21) | (0 << 16) | (0 << 11) | (0 << 6) | (0b001000);         //JR R1
    reset_ptr[4] = 0;                                                                                    //NOP
    
    shared_ptr->check_at_event = 10000;
    
    //----------------------------------------------------------------------
    
    FILE *early_console_fp = fopen("early_console.txt", "wb");
    FILE *jtag_console_fp = fopen("jtag_console.txt", "wb");
    
    //----------------------------------------------------------------------
    
    int master_fd = 0, slave_fd = 0;
    char slave_name[256];
    memset(slave_name, 0, sizeof(slave_name));
    
    int_ret = openpty(&master_fd, &slave_fd, slave_name, NULL, NULL);
    if(int_ret != 0) {
        printf("Can not openpty().\n");
        return -1;
    }
    printf("slave pty: %s\n", slave_name);
    
    //----------------------------------------------------------------------
    
    pid_t proc_vmips = fork();
    if(proc_vmips == 0) {
        system("cd ./../vmips && ./main_linux > ./vmips_output.txt");
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
    
    //irq setup
    shared_ptr->irq2_at_event = 0;
    shared_ptr->irq3_at_event = 0xFFFFFFFF;
    
    //jtag data
    bool jtag_read_irq_enable  = false;
    bool jtag_write_irq_enable = false;
    
    uint64 loop = 0;
    
    struct pollfd master_poll;
    memset(&master_poll, 0, sizeof(master_poll));
    master_poll.fd = master_fd;
    master_poll.events = POLLIN;
    
    std::deque<char> jtag_deque;
    
    while(true) {
        loop++;
        if((loop % 100000000) == 0) printf("loop: %lld, vmips: %d ao: %d\n", loop, shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
        
        //----------------------------------------------------------------------
        
        if((loop % 10000) == 0) {
            int_ret = poll(&master_poll, 1, 0);
            if(int_ret < 0) {
                printf("Error: poll() failed.\n");
                shared_ptr->test_finished = true;
                return -1;
            }
            
            if(int_ret == 1 && (master_poll.revents & POLLIN)) {
                char read_char = 0;
                int_ret = read(master_fd, &read_char, 1);
                
                jtag_deque.push_back(read_char);
                printf("read: %c\n", read_char);
            }
        }
        
        //----------------------------------------------------------------------
        
        uint32 retry = 0;
        while(shared_ptr->proc_vmips.check_do || shared_ptr->proc_ao.check_do) {
            if(shared_ptr->proc_vmips.check_do && shared_ptr->proc_ao.check_do) {
                
                //printf("check[%d, %d]\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
                
                if(shared_ptr->proc_vmips.report.counter != shared_ptr->proc_ao.report.counter) {
                    printf("check counter mismatch: vmips: %d != %d\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
                    getchar();
                }
                
                shared_ptr->check_at_event += 10000;
                
                if(jtag_write_irq_enable == false) {
                    if(jtag_deque.empty()) {
                        if(shared_ptr->irq3_at_event != 0xFFFFFFFF) {
                            printf("jtag: disabling irq\n");
                            shared_ptr->irq3_at_event = 0xFFFFFFFF;
                        }
                    }
                    else {
                        shared_ptr->irq3_at_event = shared_ptr->proc_vmips.report.counter + 10;
                        printf("jtag: enabling irq\n");
                    }
                }
                
                shared_ptr->proc_vmips.check_do = false;
                shared_ptr->proc_ao.check_do    = false;
            }
            else {
                usleep(10);
                retry++;
                
                if(retry == 500000) {
                    printf("vmips: %08x %01x %08x\n", shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                    printf("ao:    %08x %01x %08x\n", shared_ptr->proc_ao.write_address,    shared_ptr->proc_ao.write_byteenable,    shared_ptr->proc_ao.write_data);
                    
                    printf("\nTEST FAILED. WAITING FOR CHECK [vmips: %d, ao: %d]\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
                    shared_ptr->test_finished = true;
                    return -1;
                }
            }
        }
        
        retry = 0;
        while(shared_ptr->proc_vmips.write_do || shared_ptr->proc_ao.write_do) {
            if(shared_ptr->proc_vmips.write_do && shared_ptr->proc_ao.write_do) {
                if( shared_ptr->proc_vmips.write_address    == shared_ptr->proc_ao.write_address &&
                    shared_ptr->proc_vmips.write_byteenable == shared_ptr->proc_ao.write_byteenable &&
                    shared_ptr->proc_vmips.write_data       == shared_ptr->proc_ao.write_data)
                {
                    //printf("write[%d]: %08x %01x %08x\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                    
                    if(shared_ptr->proc_vmips.report.counter != shared_ptr->proc_ao.report.counter) {
                        printf("write instruction counter mismatch: vmips: %d != %d\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
                        getchar();
                    }
                    
                    uint32 address = shared_ptr->proc_vmips.write_address;
                    uint32 byteena = shared_ptr->proc_vmips.write_byteenable;
                    uint32 value   = shared_ptr->proc_vmips.write_data;
                    
                    if(address < MAX_MEMORY) {
                        for(uint32 i=0; i<4; i++) {
                            if(byteena & 1) shared_ptr->mem.bytes[shared_ptr->proc_vmips.write_address + i] = value & 0xFF;
                            value >>= 8;
                            byteena >>= 1;
                        }
                    }
                    else if(address >= RESET_VECTOR && address < RESET_VECTOR + sizeof(shared_ptr->reset_vector)) {
                        for(uint32 i=0; i<4; i++) {
                            uint8 *vector = (uint8 *)shared_ptr->reset_vector;
                            if(byteena & 1) vector[address - RESET_VECTOR + i] = value & 0xFF;
                            value >>= 8;
                            byteena >>= 1;
                        }
                    }
                    else if(address == 0x1FFFFFFC && byteena == 8) {
                        fprintf(early_console_fp, "%c", (value >> 24) & 0xFF);
                        fflush(early_console_fp);
                    }
                    else if(address == 0x1FFFFFF8 && byteena == 1) {
                        printf("timer irq ack\n");
                        shared_ptr->irq2_at_event = shared_ptr->proc_vmips.report.counter + 500000;
                    }
                    else if(address == 0x1FFFFFF0 && byteena == 0xF) {
                        printf("write jtaguart data: %08x\n", value);
                        
                        char byte_to_write = (value & 0xFF);
                        
                        fprintf(jtag_console_fp, "%c", byte_to_write);
                        fflush(jtag_console_fp);
                        
                        write(master_fd, &byte_to_write, 1);
                    }
                    else if(address == 0x1FFFFFF4 && byteena == 0xF) {
                        printf("write jtaguart control: %08x\n", value);
                        
                        jtag_read_irq_enable  = (value & 0x1)? true : false;
                        jtag_write_irq_enable = (value & 0x2)? true : false;
                        
                        if(jtag_write_irq_enable || (jtag_read_irq_enable && jtag_deque.size() > 0))    shared_ptr->irq3_at_event = shared_ptr->proc_vmips.report.counter + 10;
                        else                                                                            shared_ptr->irq3_at_event = 0xFFFFFFFF;
                    }
                    else {
                        printf("vmips: %08x %01x %08x\n", shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                        printf("ao:    %08x %01x %08x\n", shared_ptr->proc_ao.write_address,    shared_ptr->proc_ao.write_byteenable,    shared_ptr->proc_ao.write_data);
                        
                        printf("\nTEST FAILED. MEM WRITE TO UNKNOWN.\n");
                        shared_ptr->test_finished = true;
                        return -1;
                    }
                    
                    shared_ptr->proc_vmips.write_do = false;
                    shared_ptr->proc_ao.write_do    = false;
                }
                else {
                    printf("vmips: %08x %01x %08x\n", shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                    printf("ao:    %08x %01x %08x\n", shared_ptr->proc_ao.write_address,    shared_ptr->proc_ao.write_byteenable,    shared_ptr->proc_ao.write_data);
                    
                    printf("\nTEST FAILED. MEM WRITE DIFF [%d].\n", shared_ptr->proc_vmips.report.counter);
                    shared_ptr->test_finished = true;
                    return -1;
                }
            }
            else {
                usleep(10);
                retry++;
                
                if(retry == 500000) {
                    printf("vmips: %08x %01x %08x\n", shared_ptr->proc_vmips.write_address, shared_ptr->proc_vmips.write_byteenable, shared_ptr->proc_vmips.write_data);
                    printf("ao:    %08x %01x %08x\n", shared_ptr->proc_ao.write_address,    shared_ptr->proc_ao.write_byteenable,    shared_ptr->proc_ao.write_data);
                    
                    printf("\nTEST FAILED. WAITING FOR WRITE [vmips: %d, ao: %d]\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
                    shared_ptr->test_finished = true;
                    return -1;
                }
            }
        }
        
        retry = 0;
        while(shared_ptr->proc_vmips.read_do || shared_ptr->proc_ao.read_do) {
            if(shared_ptr->proc_vmips.read_do && shared_ptr->proc_ao.read_do) {
                if( shared_ptr->proc_vmips.read_address    == shared_ptr->proc_ao.read_address &&
                    shared_ptr->proc_vmips.read_byteenable == shared_ptr->proc_ao.read_byteenable)
                {
                    printf("read: %08x %01x\n", shared_ptr->proc_vmips.read_address, shared_ptr->proc_vmips.read_byteenable);
                    
                    if(shared_ptr->proc_vmips.report.counter != shared_ptr->proc_ao.report.counter) {
                        printf("read instruction counter mismatch: vmips: %d != %d\n", shared_ptr->proc_vmips.report.counter, shared_ptr->proc_ao.report.counter);
                        getchar();
                    }
                    
                    uint32 address = shared_ptr->proc_vmips.read_address;
                    uint32 byteena = shared_ptr->proc_vmips.read_byteenable;
                    uint32 value   = 0xFFFFFFFF;
                    
                    if(address == 0x1FFFFFF0 && byteena == 0xF) {
                        if(jtag_deque.empty()) value = 0;
                        else {
                            value = 
                                (jtag_deque.front() & 0xFF) |
                                (1 << 15) |
                                (((jtag_deque.size() - 1) & 0xFFFF) << 16);
                                
                            jtag_deque.pop_front();
                        }
                        
                        if(jtag_write_irq_enable == false) {
                            if(jtag_deque.empty()) {
                                shared_ptr->irq3_at_event = 0xFFFFFFFF;
                                printf("jtag: disabling irq\n");
                            }
                            else {
                                shared_ptr->irq3_at_event = shared_ptr->proc_vmips.report.counter + 10;
                                printf("jtag: enabling irq\n");
                            }
                        }
                        
                        printf("read jtaguart data: %08x\n", value);
                    }
                    else if(address == 0x1FFFFFF4 && byteena == 0xF) {
                        value = 
                            ((jtag_read_irq_enable)?  1 : 0) |
                            ((jtag_write_irq_enable)? 2 : 0) |
                            (((jtag_deque.empty())? 0 : 1) << 8)  |     //read irq pending
                            (1 << 9)  |                                 //write irq pending
                            (1 << 10) |                                 //active
                            (0xFF << 16);                               //spaces left in write fifo
                            
                        printf("read jtaguart control: %08x\n", value);
                    }
                    else
                    {
                        printf("vmips: %08x %01x\n", shared_ptr->proc_vmips.read_address, shared_ptr->proc_vmips.read_byteenable);
                        printf("ao:    %08x %01x\n", shared_ptr->proc_ao.read_address,    shared_ptr->proc_ao.read_byteenable);
                        
                        printf("\nRUN FAILED. MEM READ FROM UNKNOWN.\n");
                        shared_ptr->test_finished = true;
                        return -1;
                        
                    }
                    
                    shared_ptr->proc_vmips.read_data = value;
                    shared_ptr->proc_ao.read_data = value;
                    
                    shared_ptr->proc_vmips.read_do = false;
                    shared_ptr->proc_ao.read_do    = false;
                }
                else {
                    printf("vmips: %08x %01x\n", shared_ptr->proc_vmips.read_address, shared_ptr->proc_vmips.read_byteenable, shared_ptr->proc_vmips.read_data);
                    printf("ao:    %08x %01x\n", shared_ptr->proc_ao.read_address,    shared_ptr->proc_ao.read_byteenable,    shared_ptr->proc_ao.read_data);
                    
                    printf("\nRUN FAILED. MEM READ DIFF.\n");
                    shared_ptr->test_finished = true;
                    return -1;
                }
            }
            else {
                usleep(10);
                retry++;
                
                if(retry == 500000) {
                    printf("vmips: %08x %01x\n", shared_ptr->proc_vmips.read_address, shared_ptr->proc_vmips.read_byteenable, shared_ptr->proc_vmips.read_data);
                    printf("ao:    %08x %01x\n", shared_ptr->proc_ao.read_address,    shared_ptr->proc_ao.read_byteenable,    shared_ptr->proc_ao.read_data);
                    
                    printf("\nTEST FAILED. WAITING FOR READ.\n");
                    shared_ptr->test_finished = true;
                    return -1;
                }
            }
        }
    }

    //---------------------------------------------------------------------- wait for process end
    waitpid(proc_vmips, NULL, 0);
    waitpid(proc_ao, NULL, 0);
    
    return 0;
}

//------------------------------------------------------------------------------
