#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vpic.h"
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
    
    Vpic *top = new Vpic();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("pic.vcd");
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    bool dump = false;
    uint64 cycle = 0;
    bool read_cycle = false;
    
    int irq_counter = 0;
    
    printf("pic main_plugin.cpp\n");
    while(!Verilated::gotFinish()) {
    
        //----------------------------------------------------------------------
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //master pic 0020-0021
        input               master_address,
        input               master_read,
        output reg  [7:0]   master_readdata,
        input               master_write,
        input       [7:0]   master_writedata,
        
        //slave pic 00A0-00A1
        input               slave_address,
        input               slave_read,
        output reg  [7:0]   slave_readdata,
        input               slave_write,
        input       [7:0]   slave_writedata,
        */
        
        top->master_read = 0;
        top->master_write= 0;
        
        top->slave_read  = 0;
        top->slave_write = 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write &&
            ((shared_ptr->combined.io_address == 0x0020 && ((shared_ptr->combined.io_byteenable >> 2) & 3) == 0) || (shared_ptr->combined.io_address == 0x00A0 && ((shared_ptr->combined.io_byteenable >> 2) & 3) == 0)))
        {
            if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                printf("Vpic rd: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                exit(-1);
            }
            
            top->master_address = (shared_ptr->combined.io_address == 0x0020 && shared_ptr->combined.io_byteenable == 1)?     0 : 1;
            top->slave_address  = (shared_ptr->combined.io_address == 0x00A0 && shared_ptr->combined.io_byteenable == 1)?     0 : 1;
                                 
            top->master_writedata = (shared_ptr->combined.io_byteenable == 1)? shared_ptr->combined.io_data & 0xFF : (shared_ptr->combined.io_data >> 8) & 0xFF;
            top->slave_writedata  = (shared_ptr->combined.io_byteenable == 1)? shared_ptr->combined.io_data & 0xFF : (shared_ptr->combined.io_data >> 8) & 0xFF;
            
            if(shared_ptr->combined.io_address == 0x0020) {
                top->master_read = 0;
                top->master_write = 1;
            }
            if(shared_ptr->combined.io_address == 0x00A0) {
                top->slave_read = 0;
                top->slave_write = 1;
            }
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                ((shared_ptr->combined.io_address == 0x0020 && ((shared_ptr->combined.io_byteenable >> 2) & 3) == 0) || (shared_ptr->combined.io_address == 0x00A0 && ((shared_ptr->combined.io_byteenable >> 2) & 3) == 0)))
            {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vpic wr: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->master_address =(shared_ptr->combined.io_address == 0x0020 && shared_ptr->combined.io_byteenable == 1)?     0 : 1;
                top->slave_address  =(shared_ptr->combined.io_address == 0x00A0 && shared_ptr->combined.io_byteenable == 1)?     0 : 1;
                
                top->master_writedata = 0;
                top->slave_writedata  = 0;
                
                if(shared_ptr->combined.io_address == 0x0020) {
                    top->master_read = 1;
                    top->master_write = 0;
                }
                if(shared_ptr->combined.io_address == 0x00A0) {
                    top->slave_read = 1;
                    top->slave_write = 0;
                }
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                ((shared_ptr->combined.io_address == 0x0020 && ((shared_ptr->combined.io_byteenable >> 2) & 3) == 0) || (shared_ptr->combined.io_address == 0x00A0 && ((shared_ptr->combined.io_byteenable >> 2) & 3) == 0)))
            {
                uint32 val = 0;
                
                if(shared_ptr->combined.io_address == 0x0020) {
                    val = top->master_readdata;
                }
                if(shared_ptr->combined.io_address == 0x00A0) {
                    val = top->slave_readdata;
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
        
        top->interrupt_input =
            ((shared_ptr->pit_irq_step      == STEP_REQ)? 1 << 0 : 0) |
            ((shared_ptr->rtc_irq_step      == STEP_REQ)? 1 << 8 : 0) |
            ((shared_ptr->floppy_irq_step   == STEP_REQ)? 1 << 6 : 0) |
            ((shared_ptr->keyboard_irq_step == STEP_REQ)? 1 << 1 : 0) |
            ((shared_ptr->mouse_irq_step    == STEP_REQ)? 1 << 12 : 0);
        
        //----------------------------------------------------------------------
        
        shared_ptr->irq_do_vector = top->interrupt_vector;
        shared_ptr->irq_do        = (top->interrupt_do && shared_ptr->irq_done == STEP_IDLE)? STEP_REQ : STEP_IDLE;
        
        top->interrupt_done = 0;
        
        if(shared_ptr->irq_done == STEP_REQ) {
            top->interrupt_done = 1;
            shared_ptr->irq_done = STEP_IDLE;
            
            printf("irq_done: do: %02x done: %02x count: %d\n", shared_ptr->irq_do_vector, shared_ptr->irq_done_vector, ++irq_counter);
            
//if(shared_ptr->irq_do_vector == 0x5F) dump = 1;
        }
        
//if(shared_ptr->bochs486_pc.instr_counter >= 24820000) dump = 1;
        
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
    
    //master pic 0020-0021
    input               master_address,
    input               master_read,
    output reg  [7:0]   master_readdata,
    input               master_write,
    input       [7:0]   master_writedata,
    
    //slave pic 00A0-00A1
    input               slave_address,
    input               slave_read,
    output reg  [7:0]   slave_readdata,
    input               slave_write,
    input       [7:0]   slave_writedata,
    
    //interrupt input
    input       [15:0]  interrupt_input,
    
    //interrupt output
    output reg          interrupt_do,
    output reg  [7:0]   interrupt_vector,
    input               interrupt_done
*/
