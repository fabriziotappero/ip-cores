#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vrtc.h"
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

uint32 fdd_type       = 0x40;
uint32 hd_cylinders   = 1024;
uint32 hd_heads       = 16;
uint32 hd_spt         = 63;
bool boot_from_floppy = true;

uint32 translate_byte = 0;

//rtc contents 0-127
unsigned int cmos[128] = {
    0x00, //0x00: SEC BCD
    0x00, //0x01: ALARM SEC BCD
    0x00, //0x02: MIN BCD
    0x00, //0x03: ALARM MIN BCD
    0x12, //0x04: HOUR BCD 24h
    0x12, //0x05: ALARM HOUR BCD 24h
    0x01, //0x06: DAY OF WEEK Sunday=1
    0x03, //0x07: DAY OF MONTH BCD from 1
    0x11, //0x08: MONTH BCD from 1
    0x13, //0x09: YEAR BCD
    0x26, //0x0A: REG A
    0x02, //0x0B: REG B
    0x00, //0x0C: REG C
    0x80, //0x0D: REG D
    0x00, //0x0E: REG E - POST status
    0x00, //0x0F: REG F - shutdown status

    fdd_type, //0x10: floppy drive type; 0-none, 1-360K, 2-1.2M, 3-720K, 4-1.44M, 5-2.88M
    0x00, //0x11: configuration bits; not used
    0xF0, //0x12: hard disk types; 0-none, 1:E-type, F-type 16+
    0x00, //0x13: advanced configuration bits; not used
    0x0D, //0x14: equipment bits
    0x80, //0x15: base memory in 1k LSB
    0x02, //0x16: base memory in 1k MSB
    0x00, //0x17: memory size above 1m in 1k LSB
    0xFC, //0x18: memory size above 1m in 1k MSB
    0x2F, //0x19: extended hd types 1/2; type 47d
    0x00, //0x1A: extended hd types 2/2

    hd_cylinders & 0xFF,        //0x1B: hd 0 configuration 1/9; cylinders low
    (hd_cylinders >> 8) & 0xFF, //0x1C: hd 0 configuration 2/9; cylinders high
    hd_heads,                   //0x1D: hd 0 configuration 3/9; heads
    0xFF,                       //0x1E: hd 0 configuration 4/9; write pre-comp low
    0xFF,                       //0x1F: hd 0 configuration 5/9; write pre-comp high
    0xC8,                       //0x20: hd 0 configuration 6/9; retries/bad map/heads>8
    hd_cylinders & 0xFF,        //0x21: hd 0 configuration 7/9; landing zone low
    (hd_cylinders >> 8) & 0xFF, //0x22: hd 0 configuration 8/9; landing zone high
    hd_spt,                     //0x23: hd 0 configuration 9/9; sectors/track

    0x00, //0x24: hd 1 configuration 1/9
    0x00, //0x25: hd 1 configuration 2/9
    0x00, //0x26: hd 1 configuration 3/9
    0x00, //0x27: hd 1 configuration 4/9
    0x00, //0x28: hd 1 configuration 5/9
    0x00, //0x29: hd 1 configuration 6/9
    0x00, //0x2A: hd 1 configuration 7/9
    0x00, //0x2B: hd 1 configuration 8/9
    0x00, //0x2C: hd 1 configuration 9/9

    (boot_from_floppy)? 0x20u : 0x00u, //0x2D: boot sequence

    0x00, //0x2E: checksum MSB
    0x00, //0x2F: checksum LSB

    0x00, //0x30: memory size above 1m in 1k LSB
    0xFC, //0x31: memory size above 1m in 1k MSB

    0x20, //0x32: IBM century
    0x00, //0x33: ?

    0x00, //0x34: memory size above 16m in 64k LSB
    0x07, //0x35: memory size above 16m in 64k MSB; 128 MB

    0x00, //0x36: ?
    0x20, //0x37: IBM PS/2 century

    0x00,           //0x38: eltorito boot sequence; not used
    translate_byte, //0x39: ata translation policy 1/2
    0x00,           //0x3A: ata translation policy 2/2

    0x00, //0x3B: ?
    0x00, //0x3C: ?

    0x00, //0x3D: eltorito boot sequence; not used

    0x00, //0x3E: ?
    0x00, //0x3F: ?

    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

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
    
    Vrtc *top = new Vrtc();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("rtc.vcd");
    
    bool dump = false;
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    uint64 cycle = 0;
    bool read_cycle = false;
    
    int CYCLES_IN_SECOND = 1000000;
    int CYCLES_IN_122_US = 100;
    
    //128.[26:0]: cycles in second
    //129.[12:0]: cycles in 122.07031 us
    
    for(uint32 i=0; i<130; i++) {
        top->mgmt_write = 1;
        top->mgmt_address = i;
        top->mgmt_writedata = (i==128)? CYCLES_IN_SECOND : (i==129)? CYCLES_IN_122_US : cmos[i];
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
    }
    top->mgmt_write = 0;
    
    printf("rtc main_plugin.cpp\n");
    
    while(!Verilated::gotFinish()) {
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //io slave 0x70-0x71
        input               io_address,
        input               io_read,
        output reg  [7:0]   io_readdata,
        input               io_write,
        input       [7:0]   io_writedata,
        */
        
        top->io_read      = 0;
        top->io_write     = 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && shared_ptr->combined.io_address == 0x0070 &&
            (shared_ptr->combined.io_byteenable == 1 || shared_ptr->combined.io_byteenable == 2))
        {
            top->io_address    = (shared_ptr->combined.io_byteenable == 1)?     0 :
                                                                                1;
            top->io_writedata  = (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                                                                (shared_ptr->combined.io_data >> 8) & 0xFF;
            top->io_read  = 0;
            top->io_write = 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x0070 &&
                (shared_ptr->combined.io_byteenable == 1 || shared_ptr->combined.io_byteenable == 2))
            {
                top->io_address = (shared_ptr->combined.io_byteenable == 1)?     0 :
                                                                                 1;
                top->io_writedata  = 0;
                
                top->io_read  = 1;
                top->io_write = 0;
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x0070 &&
                (shared_ptr->combined.io_byteenable == 1 || shared_ptr->combined.io_byteenable == 2))
            {
                uint32 val = top->io_readdata;
                
                if(shared_ptr->combined.io_byteenable & 1) val <<= 0;
                if(shared_ptr->combined.io_byteenable & 2) val <<= 8;
                
                shared_ptr->combined.io_data = val;
                    
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
        }
        
        //----------------------------------------------------------------------
        
        if(top->irq) {
            shared_ptr->rtc_irq_step = STEP_REQ;
        }
        else {
            shared_ptr->rtc_irq_step = STEP_IDLE;
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
    
    output reg          irq,
    
    //io slave 0x70-0x71
    input               io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //mgmt slave
    //128.[26:0]: cycles in second
    //129.[12:0]: cycles in 122.07031 us
    
    input       [7:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
*/
