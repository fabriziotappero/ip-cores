#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vpit.h"
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
    
    Vpit *top = new Vpit();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("pit.vcd");
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    bool dump = false;
    uint64 cycle = 0;
    bool read_cycle = false;
    
    int CYCLES_IN_SYSCLOCK = 2;
    
    /*
    0.[7:0]: cycles in sysclock 1193181 Hz
    */
    top->mgmt_address = 0;
    top->mgmt_write   = 1;
    top->mgmt_writedata = CYCLES_IN_SYSCLOCK;
    
    top->clk = 0;
    top->eval();
    cycle++; if(dump) tracer->dump(cycle);
    
    top->clk = 1;
    top->eval();
    cycle++; if(dump) tracer->dump(cycle);
    
    tracer->flush();
    top->mgmt_write = 0;
    
    printf("pit main_plugin.cpp\n");
    
    int sleep_counter = 0;
    
    while(!Verilated::gotFinish()) {
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //io slave 040h-043h
        input       [1:0]   io_address,
        input               io_read,
        output reg  [7:0]   io_readdata,
        input               io_write,
        input       [7:0]   io_writedata,
        
        //speaker port 61h
        input               speaker_61h_read,
        output      [7:0]   speaker_61h_readdata,
        input               speaker_61h_write,
        input       [7:0]   speaker_61h_writedata,
        */
        
        top->io_read      = 0;
        top->io_write     = 0;
        
        top->speaker_61h_read = 0;
        top->speaker_61h_write= 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && shared_ptr->combined.io_address == 0x0040) {
            if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                printf("Vpit: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                exit(-1);
            }

            top->io_address    = (shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_byteenable == 4)?     2 :
                                                                                3;
            top->io_writedata  = (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                 (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                 (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                (shared_ptr->combined.io_data >> 24) & 0xFF;
            top->io_read  = 0;
            top->io_write = 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
            
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 0x2) {
            top->speaker_61h_writedata = (shared_ptr->combined.io_data >> 8) & 0xFF;
            
            top->speaker_61h_read = 0;
            top->speaker_61h_write= 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x0040) {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vpit: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->io_address = (shared_ptr->combined.io_byteenable == 1)?     0 :
                                  (shared_ptr->combined.io_byteenable == 2)?     1 :
                                  (shared_ptr->combined.io_byteenable == 4)?     2 :
                                                                                 3;
                top->io_writedata  = 0;
                
                top->io_read  = 1;
                top->io_write = 0;
                
                read_cycle = true;
            }
            
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 0x2) {
                top->speaker_61h_writedata = 0;
                
                top->speaker_61h_read = 1;
                top->speaker_61h_write= 0;
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x0040) {
                uint32 val = top->io_readdata;
                
                if(shared_ptr->combined.io_byteenable & 1) val <<= 0;
                if(shared_ptr->combined.io_byteenable & 2) val <<= 8;
                if(shared_ptr->combined.io_byteenable & 4) val <<= 16;
                if(shared_ptr->combined.io_byteenable & 8) val <<= 24;
                
                shared_ptr->combined.io_data = val;
                    
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
            
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 0x2) {
                uint32 val = top->speaker_61h_readdata << 8;
                
                shared_ptr->combined.io_data = val;
                
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
        }
        
        //----------------------------------------------------------------------
        
        if(top->irq) {
            shared_ptr->pit_irq_step = STEP_REQ;
        }
        else {
            shared_ptr->pit_irq_step = STEP_IDLE;
        }
        
        //----------------------------------------------------------------------

//if((cycle % 5000) == 0) printf("-- %d\n", cycle);
        
        
        //----------------------------------------------------------------------
        
        top->clk = 0;
        top->eval();
        cycle++; if(dump) tracer->dump(cycle);
        
        top->clk = 1;
        top->eval();
        cycle++; if(dump) tracer->dump(cycle);
        
        tracer->flush();
        
        sleep_counter++;
        if((sleep_counter % 20) == 0) usleep(1);
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
    
    output              irq,
    
    //io slave 040h-043h
    input       [1:0]   io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //speaker port 61h
    input               speaker_61h_read,
    output      [7:0]   speaker_61h_readdata,
    input               speaker_61h_write,
    input       [7:0]   speaker_61h_writedata,
    
    //speaker output
    output reg          speaker_enable,
    output              speaker_out,
    
    //mgmt slave
    //0.[7:0]: cycles in sysclock 1193181 Hz
    
    input               mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
*/
