#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vpc_dma.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "shared_mem.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    //map shared memory
    int fd = open("./../../../sim_pc/shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
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
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vpc_dma *top = new Vpc_dma();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("pc_dma.vcd");
    
    bool dump = false;
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    uint64 cycle = 0;
    bool read_cycle = false;
    
    printf("pc_dma main_plugin.cpp\n");
    while(!Verilated::gotFinish()) {
    
        //----------------------------------------------------------------------
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //000h - 00Fh for slave DMA
        input       [3:0]   slave_address,
        input               slave_read,
        output reg  [7:0]   slave_readdata,
        input               slave_write,
        input       [7:0]   slave_writedata,
        
        //080h - 08Fh for DMA page    
        input       [3:0]   page_address,
        input               page_read,
        output reg  [7:0]   page_readdata,
        input               page_write,
        input       [7:0]   page_writedata,
        
        //0C0h - 0DFh for master DMA
        input       [4:0]   master_address,
        input               master_read,
        output reg  [7:0]   master_readdata,
        input               master_write,
        input       [7:0]   master_writedata,
        */
        
        top->slave_read  = 0;
        top->slave_write = 0;
        
        top->page_read   = 0;
        top->page_write  = 0;
        
        top->master_read = 0;
        top->master_write= 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write &&
            (shared_ptr->combined.io_address == 0x0000 || shared_ptr->combined.io_address == 0x0004 || shared_ptr->combined.io_address == 0x0008 || shared_ptr->combined.io_address == 0x000C ||
             shared_ptr->combined.io_address == 0x0080 || shared_ptr->combined.io_address == 0x0084 || shared_ptr->combined.io_address == 0x0088 || shared_ptr->combined.io_address == 0x008C ||
             shared_ptr->combined.io_address == 0x00C0 || shared_ptr->combined.io_address == 0x00C4 || shared_ptr->combined.io_address == 0x00C8 || shared_ptr->combined.io_address == 0x00CC ||
             shared_ptr->combined.io_address == 0x00D0 || shared_ptr->combined.io_address == 0x00D4 || shared_ptr->combined.io_address == 0x00D8 || shared_ptr->combined.io_address == 0x00DC))
        {
            if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                printf("Vpc_dma: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                exit(-1);
            }
            
            top->slave_address = (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x000C && shared_ptr->combined.io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x000C && shared_ptr->combined.io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x000C && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                             15;
            
            top->page_address  = (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x008C && shared_ptr->combined.io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x008C && shared_ptr->combined.io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x008C && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                             15;
                                                                                                                             
            top->master_address= (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 4)?     14 :
                                 (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 8)?     15 :
                                 (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 1)?     16 :
                                 (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 2)?     17 :
                                 (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 4)?     18 :
                                 (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 8)?     19 :
                                 (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 1)?     20 :
                                 (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 2)?     21 :
                                 (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 4)?     22 :
                                 (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 8)?     23 :
                                 (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 1)?     24 :
                                 (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 2)?     25 :
                                 (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 4)?     26 :
                                 (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 8)?     27 :
                                 (shared_ptr->combined.io_address == 0x00DC && shared_ptr->combined.io_byteenable == 1)?     28 :
                                 (shared_ptr->combined.io_address == 0x00DC && shared_ptr->combined.io_byteenable == 2)?     29 :
                                 (shared_ptr->combined.io_address == 0x00DC && shared_ptr->combined.io_byteenable == 4)?     30 :
                                                                                                                             31;
                                 
                                 
            top->slave_writedata = (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                   (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                   (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                  (shared_ptr->combined.io_data >> 24) & 0xFF;
                                                                                  
            top->page_writedata =  (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                   (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                   (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                  (shared_ptr->combined.io_data >> 24) & 0xFF;
                                                                                  
            top->master_writedata= (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                   (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                   (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                  (shared_ptr->combined.io_data >> 24) & 0xFF;
            if(shared_ptr->combined.io_address == 0x0000 || shared_ptr->combined.io_address == 0x0004 || shared_ptr->combined.io_address == 0x0008 || shared_ptr->combined.io_address == 0x000C) {
                top->slave_read = 0;
                top->slave_write = 1;
            }
            if(shared_ptr->combined.io_address == 0x0080 || shared_ptr->combined.io_address == 0x0084 || shared_ptr->combined.io_address == 0x0088 || shared_ptr->combined.io_address == 0x008C) {
                top->page_read = 0;
                top->page_write = 1;
            }
            if(shared_ptr->combined.io_address == 0x00C0 || shared_ptr->combined.io_address == 0x00C4 || shared_ptr->combined.io_address == 0x00C8 || shared_ptr->combined.io_address == 0x00CC ||
               shared_ptr->combined.io_address == 0x00D0 || shared_ptr->combined.io_address == 0x00D4 || shared_ptr->combined.io_address == 0x00D8 || shared_ptr->combined.io_address == 0x00DC)
            {
                top->master_read = 0;
                top->master_write = 1;
            }
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                (shared_ptr->combined.io_address == 0x0000 || shared_ptr->combined.io_address == 0x0004 || shared_ptr->combined.io_address == 0x0008 || shared_ptr->combined.io_address == 0x000C ||
                 shared_ptr->combined.io_address == 0x0080 || shared_ptr->combined.io_address == 0x0084 || shared_ptr->combined.io_address == 0x0088 || shared_ptr->combined.io_address == 0x008C ||
                 shared_ptr->combined.io_address == 0x00C0 || shared_ptr->combined.io_address == 0x00C4 || shared_ptr->combined.io_address == 0x00C8 || shared_ptr->combined.io_address == 0x00CC ||
                 shared_ptr->combined.io_address == 0x00D0 || shared_ptr->combined.io_address == 0x00D4 || shared_ptr->combined.io_address == 0x00D8 || shared_ptr->combined.io_address == 0x00DC))
            {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vpc_dma: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->slave_address =(shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                    (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                    (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                    (shared_ptr->combined.io_address == 0x0000 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                    (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                    (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                    (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                    (shared_ptr->combined.io_address == 0x0004 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                    (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                    (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                    (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                    (shared_ptr->combined.io_address == 0x0008 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                    (shared_ptr->combined.io_address == 0x000C && shared_ptr->combined.io_byteenable == 1)?     12 :
                                    (shared_ptr->combined.io_address == 0x000C && shared_ptr->combined.io_byteenable == 2)?     13 :
                                    (shared_ptr->combined.io_address == 0x000C && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                                15;
                
                top->page_address  =(shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                    (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                    (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                    (shared_ptr->combined.io_address == 0x0080 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                    (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                    (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                    (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                    (shared_ptr->combined.io_address == 0x0084 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                    (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                    (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                    (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                    (shared_ptr->combined.io_address == 0x0088 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                    (shared_ptr->combined.io_address == 0x008C && shared_ptr->combined.io_byteenable == 1)?     12 :
                                    (shared_ptr->combined.io_address == 0x008C && shared_ptr->combined.io_byteenable == 2)?     13 :
                                    (shared_ptr->combined.io_address == 0x008C && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                                15;
                                                                                                                                
                top->master_address=(shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                    (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                    (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                    (shared_ptr->combined.io_address == 0x00C0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                    (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                    (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                    (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                    (shared_ptr->combined.io_address == 0x00C4 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                    (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                    (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                    (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                    (shared_ptr->combined.io_address == 0x00C8 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                    (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 1)?     12 :
                                    (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 2)?     13 :
                                    (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 4)?     14 :
                                    (shared_ptr->combined.io_address == 0x00CC && shared_ptr->combined.io_byteenable == 8)?     15 :
                                    (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 1)?     16 :
                                    (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 2)?     17 :
                                    (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 4)?     18 :
                                    (shared_ptr->combined.io_address == 0x00D0 && shared_ptr->combined.io_byteenable == 8)?     19 :
                                    (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 1)?     20 :
                                    (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 2)?     21 :
                                    (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 4)?     22 :
                                    (shared_ptr->combined.io_address == 0x00D4 && shared_ptr->combined.io_byteenable == 8)?     23 :
                                    (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 1)?     24 :
                                    (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 2)?     25 :
                                    (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 4)?     26 :
                                    (shared_ptr->combined.io_address == 0x00D8 && shared_ptr->combined.io_byteenable == 8)?     27 :
                                    (shared_ptr->combined.io_address == 0x00DC && shared_ptr->combined.io_byteenable == 1)?     28 :
                                    (shared_ptr->combined.io_address == 0x00DC && shared_ptr->combined.io_byteenable == 2)?     29 :
                                    (shared_ptr->combined.io_address == 0x00DC && shared_ptr->combined.io_byteenable == 4)?     30 :
                                                                                                                                31;
                                    
                                    
                top->slave_writedata = 0;
                                                                                    
                top->page_writedata = 0;
                                                                                    
                top->master_writedata= 0;
                
                if(shared_ptr->combined.io_address == 0x0000 || shared_ptr->combined.io_address == 0x0004 || shared_ptr->combined.io_address == 0x0008 || shared_ptr->combined.io_address == 0x000C) {
                    top->slave_read = 1;
                    top->slave_write = 0;
                }
                if(shared_ptr->combined.io_address == 0x0080 || shared_ptr->combined.io_address == 0x0084 || shared_ptr->combined.io_address == 0x0088 || shared_ptr->combined.io_address == 0x008C) {
                    top->page_read = 1;
                    top->page_write = 0;
                }
                if(shared_ptr->combined.io_address == 0x00C0 || shared_ptr->combined.io_address == 0x00C4 || shared_ptr->combined.io_address == 0x00C8 || shared_ptr->combined.io_address == 0x00CC ||
                shared_ptr->combined.io_address == 0x00D0 || shared_ptr->combined.io_address == 0x00D4 || shared_ptr->combined.io_address == 0x00D8 || shared_ptr->combined.io_address == 0x00DC)
                {
                    top->master_read = 1;
                    top->master_write = 0;
                }
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                (shared_ptr->combined.io_address == 0x0000 || shared_ptr->combined.io_address == 0x0004 || shared_ptr->combined.io_address == 0x0008 || shared_ptr->combined.io_address == 0x000C ||
                 shared_ptr->combined.io_address == 0x0080 || shared_ptr->combined.io_address == 0x0084 || shared_ptr->combined.io_address == 0x0088 || shared_ptr->combined.io_address == 0x008C ||
                 shared_ptr->combined.io_address == 0x00C0 || shared_ptr->combined.io_address == 0x00C4 || shared_ptr->combined.io_address == 0x00C8 || shared_ptr->combined.io_address == 0x00CC ||
                 shared_ptr->combined.io_address == 0x00D0 || shared_ptr->combined.io_address == 0x00D4 || shared_ptr->combined.io_address == 0x00D8 || shared_ptr->combined.io_address == 0x00DC))
            {
                uint32 val = 0;
                
                if(shared_ptr->combined.io_address == 0x0000 || shared_ptr->combined.io_address == 0x0004 || shared_ptr->combined.io_address == 0x0008 || shared_ptr->combined.io_address == 0x000C) {
                    val = top->slave_readdata;
                }
                if(shared_ptr->combined.io_address == 0x0080 || shared_ptr->combined.io_address == 0x0084 || shared_ptr->combined.io_address == 0x0088 || shared_ptr->combined.io_address == 0x008C) {
                    val = top->page_readdata;
                }
                if(shared_ptr->combined.io_address == 0x00C0 || shared_ptr->combined.io_address == 0x00C4 || shared_ptr->combined.io_address == 0x00C8 || shared_ptr->combined.io_address == 0x00CC ||
                   shared_ptr->combined.io_address == 0x00D0 || shared_ptr->combined.io_address == 0x00D4 || shared_ptr->combined.io_address == 0x00D8 || shared_ptr->combined.io_address == 0x00DC)
                {
                    val = top->master_readdata;
                }
                
                if(shared_ptr->combined.io_byteenable & 1) val <<= 0;
                if(shared_ptr->combined.io_byteenable & 2) val <<= 8;
                if(shared_ptr->combined.io_byteenable & 4) val <<= 16;
                if(shared_ptr->combined.io_byteenable & 8) val <<= 24;
                
                shared_ptr->combined.io_data = val;
                    
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
        }
        
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        
        if(top->avm_read != 0) {
            printf("Error: avm_read : %d\n", top->avm_read);
            exit(-1);
        }
        
        if(top->avm_write != 0) {
            printf("Error: avm_write : %d\n", top->avm_write);
            exit(-1);
        }
        
        if(top->dma_floppy_ack != 0) {
            printf("Error: dma_floppy_ack : %d\n", top->dma_floppy_ack);
            exit(-1);
        }
        
        if(top->dma_floppy_terminal != 0) {
            printf("Error: dma_floppy_terminal : %d\n", top->dma_floppy_terminal);
            exit(-1);
        }
        
        if(top->dma_soundblaster_ack != 0) {
            printf("Error: dma_soundblaster_ack : %d\n", top->dma_soundblaster_ack);
            exit(-1);
        }
        
        if(top->dma_soundblaster_terminal != 0) {
            printf("Error: dma_soundblaster_terminal : %d\n", top->dma_soundblaster_terminal);
            exit(-1);
        }
        
        //----------------------------------------------------------------------
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
        
        usleep(1);
    }
    tracer->close();
    delete tracer;
    delete top;
    
    return 0;
}

//------------------------------------------------------------------------------

/*
    input               clk,
    input               rst_n,
    
    //000h - 00Fh for slave DMA
    input       [3:0]   slave_address,
    input               slave_read,
    output reg  [7:0]   slave_readdata,
    input               slave_write,
    input       [7:0]   slave_writedata,
    
    //080h - 08Fh for DMA page    
    input       [3:0]   page_address,
    input               page_read,
    output reg  [7:0]   page_readdata,
    input               page_write,
    input       [7:0]   page_writedata,
    
    //0C0h - 0DFh for master DMA
    input       [4:0]   master_address,
    input               master_read,
    output reg  [7:0]   master_readdata,
    input               master_write,
    input       [7:0]   master_writedata,
    
    //master
    output reg  [31:0]  avm_address,
    input               avm_waitrequest,
    output reg          avm_read,
    input               avm_readdatavalid,
    input       [7:0]   avm_readdata,
    output reg          avm_write,
    output reg  [7:0]   avm_writedata,
    
    //floppy 8-bit dma channel
    input               dma_floppy_req,
    output reg          dma_floppy_ack,
    output reg          dma_floppy_terminal,
    output reg  [7:0]   dma_floppy_readdata,
    input       [7:0]   dma_floppy_writedata,
    
    //soundblaster 8-bit dma channel
    input               dma_soundblaster_req,
    output reg          dma_soundblaster_ack,
    output reg          dma_soundblaster_terminal,
    output reg  [7:0]   dma_soundblaster_readdata,
    input       [7:0]   dma_soundblaster_writedata
*/
