#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vvga.h"
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
    
    Vvga *top = new Vvga();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("vga.vcd");
    
    bool dump = false;
    
    //reset
    top->clk_26 = 0; top->rst_n = 1; top->eval();
    top->clk_26 = 1; top->rst_n = 1; top->eval();
    top->clk_26 = 1; top->rst_n = 0; top->eval();
    top->clk_26 = 0; top->rst_n = 0; top->eval();
    top->clk_26 = 0; top->rst_n = 1; top->eval();
    
    uint64 cycle = 0;
    bool read_cycle = false;
    bool read_mem_cycle = false;
    
    uint32 curr_io_byteenable = 0;
    uint32 curr_io_byteena_modif = 0;
    step_t curr_io_step = STEP_IDLE;
    
    uint32 curr_mem_byteenable = 0;
    uint32 curr_mem_byteena_modif = 0;
    step_t curr_mem_step = STEP_IDLE;
    
    uint32 curr_mrd_byteenable = 0;
    uint32 curr_mrd_byteena_modif = 0;
    step_t curr_mrd_step = STEP_IDLE;
    
    printf("vga main_plugin.cpp\n");
    while(!Verilated::gotFinish()) {
    
        //----------------------------------------------------------------------
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //avalon slave vga io 0x3B0 - 0x3BF
        input       [3:0]   io_b_address,
        input               io_b_read,
        output      [7:0]   io_b_readdata,
        input               io_b_write,
        input       [7:0]   io_b_writedata,
        
        //avalon slave vga io 0x3C0 - 0xCF
        input       [3:0]   io_c_address,
        input               io_c_read,
        output      [7:0]   io_c_readdata,
        input               io_c_write,
        input       [7:0]   io_c_writedata,
        
        //avalon slave vga io 0x3D0 - 0x3DF
        input       [3:0]   io_d_address,
        input               io_d_read,
        output      [7:0]   io_d_readdata,
        input               io_d_write,
        input       [7:0]   io_d_writedata,
        */
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write &&
            (shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC ||
             shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC ||
             shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC))
        {
            if(curr_io_step == STEP_IDLE) {
                curr_io_byteena_modif = shared_ptr->combined.io_byteenable;
                curr_io_step = STEP_REQ;
            }
            
            if(curr_io_step == STEP_REQ) {
                if((curr_io_byteena_modif >> 0) & 1) {
                    curr_io_byteenable = 1;
                    curr_io_byteena_modif &= 0xE;
                }
                else if((curr_io_byteena_modif >> 1) & 1) {
                    curr_io_byteenable = 2;
                    curr_io_byteena_modif &= 0xC;
                }
                else if((curr_io_byteena_modif >> 2) & 1) {
                    curr_io_byteenable = 4;
                    curr_io_byteena_modif &= 0x8;
                }
                else if((curr_io_byteena_modif >> 3) & 1) {
                    curr_io_byteenable = 8;
                    curr_io_byteena_modif &= 0x0;
                }
                else {
                    shared_ptr->combined.io_step = STEP_ACK;
                    curr_io_step = STEP_IDLE;
                }
            }
        }
        
        top->io_b_read   = 0;
        top->io_b_write  = 0;
        
        top->io_c_read   = 0;
        top->io_c_write  = 0;
        
        top->io_d_read   = 0;
        top->io_d_write  = 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && curr_io_step == STEP_REQ &&
            (shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC ||
             shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC ||
             shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC))
        {
            if(curr_io_byteenable != 1 && curr_io_byteenable != 2 && curr_io_byteenable != 4 && curr_io_byteenable != 8) {
                printf("Vvga: curr_io_byteenable invalid: %04x %x\n", shared_ptr->combined.io_address, curr_io_byteenable);
                exit(-1);
            }
            
            top->io_b_address  = (shared_ptr->combined.io_address == 0x03B0 && curr_io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x03B0 && curr_io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x03B0 && curr_io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x03B0 && curr_io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x03B4 && curr_io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x03B4 && curr_io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x03B4 && curr_io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x03B4 && curr_io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x03B8 && curr_io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x03B8 && curr_io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x03B8 && curr_io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x03B8 && curr_io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x03BC && curr_io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x03BC && curr_io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x03BC && curr_io_byteenable == 4)?     14 :
                                                                                                                             15;
            
            top->io_c_address  = (shared_ptr->combined.io_address == 0x03C0 && curr_io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x03C0 && curr_io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x03C0 && curr_io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x03C0 && curr_io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x03C4 && curr_io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x03C4 && curr_io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x03C4 && curr_io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x03C4 && curr_io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x03C8 && curr_io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x03C8 && curr_io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x03C8 && curr_io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x03C8 && curr_io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x03CC && curr_io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x03CC && curr_io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x03CC && curr_io_byteenable == 4)?     14 :
                                                                                                                             15;
                                                                                                                             
            top->io_d_address  = (shared_ptr->combined.io_address == 0x03D0 && curr_io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x03D0 && curr_io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x03D0 && curr_io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x03D0 && curr_io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x03D4 && curr_io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x03D4 && curr_io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x03D4 && curr_io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x03D4 && curr_io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x03D8 && curr_io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x03D8 && curr_io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x03D8 && curr_io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x03D8 && curr_io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x03DC && curr_io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x03DC && curr_io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x03DC && curr_io_byteenable == 4)?     14 :
                                                                                                                             15;
                                 
                                 
            top->io_b_writedata  = (curr_io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                   (curr_io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                   (curr_io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                  (shared_ptr->combined.io_data >> 24) & 0xFF;
                                                                                  
            top->io_c_writedata =  (curr_io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                   (curr_io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                   (curr_io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                  (shared_ptr->combined.io_data >> 24) & 0xFF;
                                                                                  
            top->io_d_writedata  = (curr_io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                   (curr_io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                   (curr_io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                  (shared_ptr->combined.io_data >> 24) & 0xFF;

            if(shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC) {
                top->io_b_read  = 0;
                top->io_b_write = 1;
            }
            if(shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC) {
                top->io_c_read  = 0;
                top->io_c_write = 1;
            }
            if(shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC) {
                top->io_d_read  = 0;
                top->io_d_write = 1;
            }
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                (shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC ||
                 shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC ||
                 shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC))
            {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vvga: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->io_b_address = (shared_ptr->combined.io_address == 0x03B0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                    (shared_ptr->combined.io_address == 0x03B0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                    (shared_ptr->combined.io_address == 0x03B0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                    (shared_ptr->combined.io_address == 0x03B0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                    (shared_ptr->combined.io_address == 0x03B4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                    (shared_ptr->combined.io_address == 0x03B4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                    (shared_ptr->combined.io_address == 0x03B4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                    (shared_ptr->combined.io_address == 0x03B4 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                    (shared_ptr->combined.io_address == 0x03B8 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                    (shared_ptr->combined.io_address == 0x03B8 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                    (shared_ptr->combined.io_address == 0x03B8 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                    (shared_ptr->combined.io_address == 0x03B8 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                    (shared_ptr->combined.io_address == 0x03BC && shared_ptr->combined.io_byteenable == 1)?     12 :
                                    (shared_ptr->combined.io_address == 0x03BC && shared_ptr->combined.io_byteenable == 2)?     13 :
                                    (shared_ptr->combined.io_address == 0x03BC && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                                15;
                
                top->io_c_address = (shared_ptr->combined.io_address == 0x03C0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                    (shared_ptr->combined.io_address == 0x03C0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                    (shared_ptr->combined.io_address == 0x03C0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                    (shared_ptr->combined.io_address == 0x03C0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                    (shared_ptr->combined.io_address == 0x03C4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                    (shared_ptr->combined.io_address == 0x03C4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                    (shared_ptr->combined.io_address == 0x03C4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                    (shared_ptr->combined.io_address == 0x03C4 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                    (shared_ptr->combined.io_address == 0x03C8 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                    (shared_ptr->combined.io_address == 0x03C8 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                    (shared_ptr->combined.io_address == 0x03C8 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                    (shared_ptr->combined.io_address == 0x03C8 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                    (shared_ptr->combined.io_address == 0x03CC && shared_ptr->combined.io_byteenable == 1)?     12 :
                                    (shared_ptr->combined.io_address == 0x03CC && shared_ptr->combined.io_byteenable == 2)?     13 :
                                    (shared_ptr->combined.io_address == 0x03CC && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                                15;
                                                                                                                                
                top->io_d_address = (shared_ptr->combined.io_address == 0x03D0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                    (shared_ptr->combined.io_address == 0x03D0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                    (shared_ptr->combined.io_address == 0x03D0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                    (shared_ptr->combined.io_address == 0x03D0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                    (shared_ptr->combined.io_address == 0x03D4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                    (shared_ptr->combined.io_address == 0x03D4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                    (shared_ptr->combined.io_address == 0x03D4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                    (shared_ptr->combined.io_address == 0x03D4 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                    (shared_ptr->combined.io_address == 0x03D8 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                    (shared_ptr->combined.io_address == 0x03D8 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                    (shared_ptr->combined.io_address == 0x03D8 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                    (shared_ptr->combined.io_address == 0x03D8 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                    (shared_ptr->combined.io_address == 0x03DC && shared_ptr->combined.io_byteenable == 1)?     12 :
                                    (shared_ptr->combined.io_address == 0x03DC && shared_ptr->combined.io_byteenable == 2)?     13 :
                                    (shared_ptr->combined.io_address == 0x03DC && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                                15;
                                        
                                    
                top->io_b_writedata = 0;
                top->io_c_writedata = 0;
                top->io_d_writedata = 0;
                
                if(shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC) {
                    top->io_b_read  = 1;
                    top->io_b_write = 0;
                }
                if(shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC) {
                    top->io_c_read  = 1;
                    top->io_c_write = 0;
                }
                if(shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC) {
                    top->io_d_read  = 1;
                    top->io_d_write = 0;
                }
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                (shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC ||
                 shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC ||
                 shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC))
            {
                uint32 val = 0;
                
                if(shared_ptr->combined.io_address == 0x03B0 || shared_ptr->combined.io_address == 0x03B4 || shared_ptr->combined.io_address == 0x03B8 || shared_ptr->combined.io_address == 0x03BC) {
                    val = top->io_b_readdata;
                }
                if(shared_ptr->combined.io_address == 0x03C0 || shared_ptr->combined.io_address == 0x03C4 || shared_ptr->combined.io_address == 0x03C8 || shared_ptr->combined.io_address == 0x03CC) {
                    val = top->io_c_readdata;
                }
                if(shared_ptr->combined.io_address == 0x03D0 || shared_ptr->combined.io_address == 0x03D4 || shared_ptr->combined.io_address == 0x03D8 || shared_ptr->combined.io_address == 0x03DC) {
                    val = top->io_d_readdata;
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
        /*
        uint32 combined.mem_address;
        uint32 combined.mem_data;
        uint32 combined.mem_byteenable;
        uint32 combined.mem_is_write;
        step_t combined.mem_step; 
         
        //avalon slave vga memory 0xA0000 - 0xBFFFF
        input       [16:0]  mem_address,
        input               mem_read,
        output      [7:0]   mem_readdata,
        input               mem_write,
        input       [7:0]   mem_writedata,
        */
        
        if(shared_ptr->combined.mem_step == STEP_REQ && shared_ptr->combined.mem_is_write && shared_ptr->combined.mem_address >= 0x000A0000 && shared_ptr->combined.mem_address < 0x000C0000)
        {
            if(curr_mem_step == STEP_IDLE) {
                curr_mem_byteena_modif = shared_ptr->combined.mem_byteenable;
                curr_mem_step = STEP_REQ;
            }
            
            if(curr_mem_step == STEP_REQ) {
                if((curr_mem_byteena_modif >> 0) & 1) {
                    curr_mem_byteenable = 1;
                    curr_mem_byteena_modif &= 0xE;
                }
                else if((curr_mem_byteena_modif >> 1) & 1) {
                    curr_mem_byteenable = 2;
                    curr_mem_byteena_modif &= 0xC;
                }
                else if((curr_mem_byteena_modif >> 2) & 1) {
                    curr_mem_byteenable = 4;
                    curr_mem_byteena_modif &= 0x8;
                }
                else if((curr_mem_byteena_modif >> 3) & 1) {
                    curr_mem_byteenable = 8;
                    curr_mem_byteena_modif &= 0x0;
                }
                else {
                    shared_ptr->combined.mem_step = STEP_ACK;
                    curr_mem_step = STEP_IDLE;
                }
            }
        }
        
        top->mem_read  = 0;
        top->mem_write = 0;
        
        if(shared_ptr->combined.mem_step == STEP_REQ && shared_ptr->combined.mem_is_write && shared_ptr->combined.mem_address >= 0x000A0000 && shared_ptr->combined.mem_address < 0x000C0000 &&
           curr_mem_step == STEP_REQ)
        {
            if(curr_mem_byteenable != 1 && curr_mem_byteenable != 2 && curr_mem_byteenable != 4 && curr_mem_byteenable != 8) {
                printf("Vvga: combined.curr_mem_byteenable invalid wr: %x\n", curr_mem_byteenable);
                exit(-1);
            }
            
            top->mem_address   = (shared_ptr->combined.mem_address >> 2) & 0x1FFFF;
            
            top->mem_writedata = (curr_mem_byteenable == 1)?    shared_ptr->combined.mem_data & 0xFF :
                                 (curr_mem_byteenable == 2)?    (shared_ptr->combined.mem_data >> 8) & 0xFF :
                                 (curr_mem_byteenable == 4)?    (shared_ptr->combined.mem_data >> 16) & 0xFF :
                                                                (shared_ptr->combined.mem_data >> 24) & 0xFF;
            top->mem_read  = 0;
            top->mem_write = 1;
        }
        
        if(read_mem_cycle == false) {
            
            if(shared_ptr->combined.mem_step == STEP_REQ && shared_ptr->combined.mem_is_write == 0 && shared_ptr->combined.mem_address >= 0x000A0000 && shared_ptr->combined.mem_address < 0x000C0000)
            {
                if(curr_mrd_step == STEP_IDLE) {
                    curr_mrd_byteena_modif = shared_ptr->combined.mem_byteenable;
                    curr_mrd_step = STEP_REQ;
                    
                    shared_ptr->combined.mem_data = 0;
                }
                
                if(curr_mrd_step == STEP_REQ) {
                    if((curr_mrd_byteena_modif >> 0) & 1) {
                        curr_mrd_byteenable = 1;
                        curr_mrd_byteena_modif &= 0xE;
                    }
                    else if((curr_mrd_byteena_modif >> 1) & 1) {
                        curr_mrd_byteenable = 2;
                        curr_mrd_byteena_modif &= 0xC;
                    }
                    else if((curr_mrd_byteena_modif >> 2) & 1) {
                        curr_mrd_byteenable = 4;
                        curr_mrd_byteena_modif &= 0x8;
                    }
                    else if((curr_mrd_byteena_modif >> 3) & 1) {
                        curr_mrd_byteenable = 8;
                        curr_mrd_byteena_modif &= 0x0;
                    }
                    else {
                        shared_ptr->combined.mem_step = STEP_ACK;
                        curr_mrd_step = STEP_IDLE;
                    }
                }
            }
            
            if(shared_ptr->combined.mem_step == STEP_REQ && shared_ptr->combined.mem_is_write == 0 && shared_ptr->combined.mem_address >= 0x000A0000 && shared_ptr->combined.mem_address < 0x000C0000 &&
               curr_mrd_step == STEP_REQ)
            {
                if(curr_mrd_byteenable != 1 && curr_mrd_byteenable != 2 && curr_mrd_byteenable != 4 && curr_mrd_byteenable != 8) {
                    printf("Vvga: curr_mrd_byteenable invalid rd: %x\n", curr_mrd_byteenable);
                    exit(-1);
                }
                
                top->mem_address   = (shared_ptr->combined.mem_address >> 2) & 0x1FFFF;
                
                top->mem_writedata = 0;
                
                top->mem_read = 1;
                top->mem_write= 0;
                
                read_mem_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.mem_step == STEP_REQ && shared_ptr->combined.mem_is_write == 0 && shared_ptr->combined.mem_address >= 0x000A0000 && shared_ptr->combined.mem_address < 0x000C0000 &&
               curr_mrd_step == STEP_REQ)
            {
                uint32 val = top->mem_readdata;
                
                if(curr_mrd_byteenable & 1) val <<= 0;
                if(curr_mrd_byteenable & 2) val <<= 8;
                if(curr_mrd_byteenable & 4) val <<= 16;
                if(curr_mrd_byteenable & 8) val <<= 24;
                
                shared_ptr->combined.mem_data |= val;
                    
                read_mem_cycle = false;
            }
        }
        
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        
        top->clk_26 = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk_26 = 1;
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
    input               clk_26,
    input               rst_n,
    
    //avalon slave for system overlay
    input       [7:0]   sys_address,
    input               sys_read,
    output      [31:0]  sys_readdata,
    input               sys_write,
    input       [31:0]  sys_writedata,
    
    //avalon slave vga io 0x3B0 - 0x3BF
    input       [3:0]   io_b_address,
    input               io_b_read,
    output      [7:0]   io_b_readdata,
    input               io_b_write,
    input       [7:0]   io_b_writedata,
    
    //avalon slave vga io 0x3C0 - 0xCF
    input       [3:0]   io_c_address,
    input               io_c_read,
    output      [7:0]   io_c_readdata,
    input               io_c_write,
    input       [7:0]   io_c_writedata,
    
    //avalon slave vga io 0x3D0 - 0x3DF
    input       [3:0]   io_d_address,
    input               io_d_read,
    output      [7:0]   io_d_readdata,
    input               io_d_write,
    input       [7:0]   io_d_writedata,
    
    //avalon slave vga memory 0xA0000 - 0xBFFFF
    input       [16:0]  mem_address,
    input               mem_read,
    output      [7:0]   mem_readdata,
    input               mem_write,
    input       [7:0]   mem_writedata,
*/
