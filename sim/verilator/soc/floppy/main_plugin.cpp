#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vfloppy.h"
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
    
    Vfloppy *top = new Vfloppy();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("floppy.vcd");
    
    bool dump = false;
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    uint64 cycle = 0;
    bool read_cycle = false;
    
    /*
    0x00.[0]:      media present
    0x01.[0]:      media writeprotect
    0x02.[7:0]:    media cylinders
    0x03.[7:0]:    media sectors per track
    0x04.[31:0]:   media total sector count
    0x05.[1:0]:    media heads
    0x06.[31:0]:   media sd base
    0x07.[15:0]:   media wait cycles: 200000 us / spt
    0x08.[15:0]:   media wait rate 0: 1000 us
    0x09.[15:0]:   media wait rate 1: 1666 us
    0x0A.[15:0]:   media wait rate 2: 2000 us
    0x0B.[15:0]:   media wait rate 3: 500 us
    0x0C.[7:0]:    media type: 8'h20 none; 8'h00 old; 8'hC0 720k; 8'h80 1_44M; 8'h40 2_88M
    */
    
    int floppy_index = -1;
    int floppy_sd_base = 0;
    
    bool floppy_is_160k = false;
    bool floppy_is_180k = false;
    bool floppy_is_320k = false;
    bool floppy_is_360k = false;
    bool floppy_is_720k = false;
    bool floppy_is_1_2m = false;
    bool floppy_is_1_44m= true;
    bool floppy_is_2_88m= false;

    bool floppy_writeprotect = true;
        
    int floppy_cylinders = (floppy_is_2_88m || floppy_is_1_44m || floppy_is_1_2m || floppy_is_720k)? 80 : 40;
    int floppy_spt       =
            (floppy_is_160k)?  8 :
            (floppy_is_180k)?  9 :
            (floppy_is_320k)?  8 :
            (floppy_is_360k)?  9 :
            (floppy_is_720k)?  9 :
            (floppy_is_1_2m)?  15 :
            (floppy_is_1_44m)? 18 :
            (floppy_is_2_88m)? 36 :
                               0;
    int floppy_total_sectors =
            (floppy_is_160k)?  320 :
            (floppy_is_180k)?  360 :
            (floppy_is_320k)?  640 :
            (floppy_is_360k)?  720 :
            (floppy_is_720k)?  1440 :
            (floppy_is_1_2m)?  2400 :
            (floppy_is_1_44m)? 2880 :
            (floppy_is_2_88m)? 5760 :
                               0;
    int floppy_heads = (floppy_is_160k || floppy_is_180k)? 1 : 2;

    int floppy_wait_cycles = 200000000 / floppy_spt;

    int floppy_media =
            (floppy_index < 0)? 0x20 :
            (floppy_is_160k)?   0x00 :
            (floppy_is_180k)?   0x00 :
            (floppy_is_320k)?   0x00 :
            (floppy_is_360k)?   0x00 :
            (floppy_is_720k)?   0xC0 :
            (floppy_is_1_2m)?   0x00 :
            (floppy_is_1_44m)?  0x80 :
            (floppy_is_2_88m)?  0x40 :
                                0x20;

    for(uint32 i=0; i<13; i++) {
        
        top->mgmt_address = 0;
        top->mgmt_write = 1;
        top->mgmt_writedata =
            (i==0)?     (floppy_index >= 0?   1 : 0) :
            (i==1)?     (floppy_writeprotect? 1 : 0) :
            (i==2)?     floppy_cylinders :
            (i==3)?     floppy_spt :
            (i==4)?     floppy_total_sectors :
            (i==5)?     floppy_heads :
            (i==6)?     floppy_sd_base :
            (i==7)?     10000 : //floppy_wait_cycles
            (i==8)?     1000 : //wait rate 0: 1000us
            (i==9)?     1666 : //wait rate 1: 1666us
            (i==10)?    2000 : //wait rate 2: 2000us
            (i==11)?    500  : //wait rate 3 : 500us
                        floppy_media;
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
    }
    top->mgmt_write = 0;
    
    printf("floppy main_plugin.cpp\n");
    while(!Verilated::gotFinish()) {
    
        //----------------------------------------------------------------------
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //avalon slave 3f0-3f8
        input       [2:0]   io_address,
        input               io_read,
        output reg  [7:0]   io_readdata,
        input               io_write,
        input       [7:0]   io_writedata,
        */
        
        top->io_read      = 0;
        top->io_write     = 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && (shared_ptr->combined.io_address == 0x03F0 || shared_ptr->combined.io_address == 0x03F4) &&
            (shared_ptr->combined.io_address == 0x03F0 || ((shared_ptr->combined.io_byteenable >> 2) & 1) == 0))
        {
            if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                printf("Vfloppy: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                exit(-1);
            }
            
            top->io_address    = (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                                                                                                             7;
            top->io_writedata  = (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                 (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                 (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                (shared_ptr->combined.io_data >> 24) & 0xFF;
            top->io_read  = 0;
            top->io_write = 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && (shared_ptr->combined.io_address == 0x03F0 || shared_ptr->combined.io_address == 0x03F4) &&
                (shared_ptr->combined.io_address == 0x03F0 || ((shared_ptr->combined.io_byteenable >> 2) & 1) == 0))
            {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vfloppy: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->io_address= (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x03F0 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                                                                                                             7;
                top->io_writedata  = 0;
                
                top->io_read  = 1;
                top->io_write = 0;
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && (shared_ptr->combined.io_address == 0x03F0 || shared_ptr->combined.io_address == 0x03F4) &&
                (shared_ptr->combined.io_address == 0x03F0 || ((shared_ptr->combined.io_byteenable >> 2) & 1) == 0))
            {
                uint32 val = top->io_readdata;
                
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
        
        if(top->irq) {
            if(shared_ptr->floppy_irq_step == STEP_IDLE) printf("floppy IRQ raise\n");
            shared_ptr->floppy_irq_step = STEP_REQ;
        }
        else {
            if(shared_ptr->floppy_irq_step == STEP_REQ) printf("floppy IRQ lower\n");
            shared_ptr->floppy_irq_step = STEP_IDLE;
        }
        
        //----------------------------------------------------------------------
        
        top->dma_floppy_ack = 0;
        
        if(top->dma_floppy_req != 0) {
            printf("Error: dma_floppy_req : %d\n", top->dma_floppy_req);
            exit(-1);
        }
        
        if(top->ide_3f6_read != 0) {
            printf("Error: ide_3f6_read : %d\n", top->ide_3f6_read);
            exit(-1);
        }
        
        if(top->ide_3f6_write != 0) {
            printf("Error: ide_3f6_write : %d\n", top->ide_3f6_write);
            exit(-1);
        }
        
        if(top->sd_master_read != 0) {
            printf("Error: sd_master_read : %d\n", top->sd_master_read);
            exit(-1);
        }
        
        if(top->sd_master_write != 0) {
            printf("Error: sd_master_write : %d\n", top->sd_master_write);
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
module floppy(
    input               clk,
    input               rst_n,
    
    //dma
    output              dma_floppy_req,
    input               dma_floppy_ack,
    input               dma_floppy_terminal,
    input       [7:0]   dma_floppy_readdata,
    output      [7:0]   dma_floppy_writedata,
    
    //irq
    output reg          irq,
    
    //avalon slave
    input       [2:0]   io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //ide shared port 0x3F6
    output              ide_3f6_read,
    input       [7:0]   ide_3f6_readdata,
    output              ide_3f6_write,
    output      [7:0]   ide_3f6_writedata,
    
    //master to control sd
    output      [31:0]  sd_master_address,
    input               sd_master_waitrequest,
    output              sd_master_read,
    input               sd_master_readdatavalid,
    input       [31:0]  sd_master_readdata,
    output              sd_master_write,
    output      [31:0]  sd_master_writedata,
    
    //slave for sd
    input       [8:0]   sd_slave_address,
    input               sd_slave_read,
    output reg  [7:0]   sd_slave_readdata,
    input               sd_slave_write,
    input       [7:0]   sd_slave_writedata,
    
    //slave for management
    
     0x00.[0]:      media present
     0x01.[0]:      media writeprotect
     0x02.[7:0]:    media cylinders
     0x03.[7:0]:    media sectors per track
     0x04.[31:0]:   media total sector count
     0x05.[1:0]:    media heads
     0x06.[31:0]:   media sd base
     0x07.[15:0]:   media wait cycles: 200000 us / spt
     0x08.[15:0]:   media wait rate 0: 1000 us
     0x09.[15:0]:   media wait rate 1: 1666 us
     0x0A.[15:0]:   media wait rate 2: 2000 us
     0x0B.[15:0]:   media wait rate 3: 500 us
     0x0C.[7:0]:    media type: 8'h20 none; 8'h00 old; 8'hC0 720k; 8'h80 1_44M; 8'h40 2_88M
    
    input       [3:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);
*/
