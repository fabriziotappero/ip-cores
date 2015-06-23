#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vhdd.h"
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

uint32 hd_cylinders = 1024;
uint32 hd_heads = 16;
uint32 hd_spt = 63;
uint32 hd_total_sectors = hd_cylinders * hd_heads * hd_spt;

unsigned int identify[256] = {
    0x0040,                                         //word 0
    (hd_cylinders > 16383)? 16383 : hd_cylinders,   //word 1
    0x0000,                                         //word 2 reserved
    hd_heads,                                       //word 3
    (unsigned short)(512 * hd_spt),                 //word 4
    512,                                            //word 5
    hd_spt,                                         //word 6
    0x0000,                                         //word 7 vendor specific
    0x0000,                                         //word 8 vendor specific
    0x0000,                                         //word 9 vendor specific
    ('B' << 8) | 'X',                               //word 10
    ('H' << 8) | 'D',                               //word 11
    ('0' << 8) | '0',                               //word 12
    ('0' << 8) | '1',                               //word 13
    ('1' << 8) | ' ',                               //word 14
    (' ' << 8) | ' ',                               //word 15
    (' ' << 8) | ' ',                               //word 16
    (' ' << 8) | ' ',                               //word 17
    (' ' << 8) | ' ',                               //word 18
    (' ' << 8) | ' ',                               //word 19
    3,                                              //word 20 buffer type
    512,                                            //word 21 cache size
    4,                                              //word 22 number of ecc bytes
    0,0,0,0,                                        //words 23..26 firmware revision
    ('H' << 8) | 'D',                               //words 27..46 model number
    ('m' << 8) | 'o',
    ('d' << 8) | 'e',
    ('l' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    (' ' << 8) | ' ',
    16,                                             //word 47 max multiple sectors
    1,                                              //word 48 dword io
    1<<9,                                           //word 49 lba supported
    0x0000,                                         //word 50 reserved
    0x0200,                                         //word 51 pio timing
    0x0200,                                         //word 52 pio timing
    0x0007,                                         //word 53 valid fields
    (hd_cylinders > 16383)? 16383 : hd_cylinders,   //word 54
    hd_heads,                                       //word 55
    hd_spt,                                         //word 56
    hd_total_sectors & 0xFFFF,                      //word 57
    hd_total_sectors >> 16,                         //word 58
    0x0000,                                         //word 59 multiple sectors
    hd_total_sectors & 0xFFFF,                      //word 60
    hd_total_sectors >> 16,                         //word 61
    0x0000,                                         //word 62 single word dma modes
    0x0000,                                         //word 63 multiple word dma modes
    0x0000,                                         //word 64 pio modes
    120,120,120,120,                                //word 65..68
    0,0,0,0,0,0,0,0,0,0,0,                          //word 69..79
    0x007E,                                         //word 80 ata modes
    0x0000,                                         //word 81 minor version number
    1<<14,                                          //word 82 supported commands
    (1<<14) | (1<<13) | (1<<12) | (1<<10),          //word 83
    1<<14,                                          //word 84
    1<<14,                                          //word 85
    (1<<14) | (1<<13) | (1<<12) | (1<<10),          //word 86
    1<<14,                                          //word 87
    0x0000,                                         //word 88
    0,0,0,0,                                        //word 89..92
    1 | (1<<14) | 0x2000,                           //word 93
    0,0,0,0,0,0,                                    //word 94..99
    hd_total_sectors & 0xFFFF,                      //word 100
    hd_total_sectors >> 16,                         //word 101
    0,                                              //word 102
    0,                                              //word 103

    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//word 104..127

    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,                //word 128..255
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

//------------------------------------------------------------------------------

uint32 sd_address;
uint32 sd_sector_count;
uint32 sd_command;

bool sd_mutex = false;
uint32 sd_waiting = 0;

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
    
    Vhdd *top = new Vhdd();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("hdd.vcd");
    
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
    0x00.[31:0]:    identify write
    0x01.[16:0]:    media cylinders
    0x02.[4:0]:     media heads
    0x03.[8:0]:     media spt
    0x04.[13:0]:    media sectors per cylinder = spt * heads
    0x05.[31:0]:    media sectors total
    0x06.[31:0]:    media sd base
    */
    
    for(uint32 i=0; i<128; i++) {
        
        top->mgmt_address = 0;
        top->mgmt_write = 1;
        top->mgmt_writedata = ((unsigned int)identify[2*i+1] << 16) | (unsigned int)identify[2*i+0];
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
    }
    
    for(uint32 i=0; i<6; i++) {
        top->mgmt_address = i+1;
        top->mgmt_write   = 1;
        top->mgmt_writedata = (i==0)? hd_cylinders : (i==1)? hd_heads : (i==2)? hd_spt : (i==3)? hd_heads * hd_spt : (i==4)? hd_total_sectors : 0;
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
    }
    top->mgmt_write = 0;
    
    printf("hdd main_plugin.cpp\n");
    while(!Verilated::gotFinish()) {
    
        //----------------------------------------------------------------------
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //avalon slave
        input               io_address,
        input       [3:0]   io_byteenable,
        input               io_read,
        output reg  [31:0]  io_readdata,
        input               io_write,
        input       [31:0]  io_writedata, 
        
        //ide shared port 0x3F6
        input               ide_3f6_read,
        output reg  [7:0]   ide_3f6_readdata,
        input               ide_3f6_write,
        input       [7:0]   ide_3f6_writedata,
        */
        
        top->io_read      = 0;
        top->io_write     = 0;
        
        top->ide_3f6_read = 0;
        top->ide_3f6_write= 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && (shared_ptr->combined.io_address == 0x01F0 || shared_ptr->combined.io_address == 0x01F4)) {
            top->io_address    = (shared_ptr->combined.io_address == 0x01F0)? 0 : 1;
            top->io_byteenable = shared_ptr->combined.io_byteenable;
            top->io_writedata  = shared_ptr->combined.io_data;
            
            top->io_read  = 0;
            top->io_write = 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
            
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write && shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 0x4) {
            top->ide_3f6_writedata = (shared_ptr->combined.io_data >> 16) & 0xFF;
            
            top->ide_3f6_read = 0;
            top->ide_3f6_write= 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && (shared_ptr->combined.io_address == 0x01F0 || shared_ptr->combined.io_address == 0x01F4)) {
                top->io_address    = (shared_ptr->combined.io_address == 0x01F0)? 0 : 1;
                top->io_byteenable = shared_ptr->combined.io_byteenable;
                top->io_writedata  = 0;
                
                top->io_read  = 1;
                top->io_write = 0;
                
                read_cycle = true;
            }
            
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 0x4) {
                top->ide_3f6_writedata = 0;
                
                top->ide_3f6_read = 1;
                top->ide_3f6_write= 0;
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && (shared_ptr->combined.io_address == 0x01F0 || shared_ptr->combined.io_address == 0x01F4)) {
                uint32 val = top->io_readdata;
                
                if((shared_ptr->combined.io_byteenable & 1) == 0) val &= 0xFFFFFF00;
                if((shared_ptr->combined.io_byteenable & 2) == 0) val &= 0xFFFF00FF;
                if((shared_ptr->combined.io_byteenable & 4) == 0) val &= 0xFF00FFFF;
                if((shared_ptr->combined.io_byteenable & 8) == 0) val &= 0x00FFFFFF;
                
                shared_ptr->combined.io_data = val;
                    
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
            
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 && shared_ptr->combined.io_address == 0x03F4 && shared_ptr->combined.io_byteenable == 0x4) {
                uint32 val = (top->ide_3f6_readdata & 0xFF) << 16;
                
                shared_ptr->combined.io_data = val;
                
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
        }
        
        //----------------------------------------------------------------------
        
        if(top->irq) {
            printf("ERROR: hdd irq set.\n");
            exit(-1);
        }
        
        //----------------------------------------------------------------------
        
        top->sd_master_waitrequest = 0;
        top->sd_master_readdatavalid = 0;
        
        if(top->sd_master_read) {
            sd_mutex = true;
            top->sd_master_readdata = 2;
        }
        else if(sd_mutex) {
            top->sd_master_readdatavalid = 1;
            sd_mutex = false;
        }
        
        if(top->sd_master_write) {
printf("sd_master %08x %08x\n", top->sd_master_address, top->sd_master_writedata);
            
            if(top->sd_master_address == 0x00000004) sd_address      = top->sd_master_writedata;
            if(top->sd_master_address == 0x00000008) sd_sector_count = top->sd_master_writedata;
            if(top->sd_master_address == 0x0000000C) sd_command      = top->sd_master_writedata;
            
            sd_waiting = 1000; //10000;
        }
        else if(sd_command != 0) {
            
            if(sd_waiting > 0) {
                sd_waiting--;
            }
            else if(sd_command == 2) { //read
                
                FILE *fp = fopen("/home/alek/temp/bochs-run/hd_copy_for_sim.img", "rb");
                
                //usleep(500*1000);
                
                for(uint32 i=0; i<sd_sector_count*128; i++) {
                    
                    fseek(fp, (sd_address*512)+(i*4), SEEK_SET);
                    
                    uint32 val;
                    fread(&val, 4, 1, fp);
                    
                    top->sd_slave_write = 1;
                    top->sd_slave_writedata = val;
                    
                    top->clk = 0;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    top->clk = 1;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    tracer->flush();
                }
                
                top->sd_slave_write = 0;
                sd_command = 0;
                
                for(uint32 i=0; i<30; i++) {
                    top->clk = 0;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    top->clk = 1;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    tracer->flush();
                }
                
                fclose(fp);
            }
            else if(sd_command == 3) { //write
                
                FILE *fp = fopen("/home/alek/temp/bochs-run/hd_copy_for_sim.img", "r+b");
                
                //usleep(500*1000);
                
                bool wait = false;
                for(uint32 i=0; i<sd_sector_count*128*2; i++) {
                    
                    top->sd_slave_read = (wait == false)? 1 : 0;
                    
                    top->clk = 0;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    top->clk = 1;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    tracer->flush();
                    
                    if(wait) {
                        wait = (wait == false)? true : false;
                        continue;
                    }
                    
                    //--- write
                    
                    fseek(fp, (sd_address*512)+(i*4/2), SEEK_SET);
                    
                    uint32 val = top->sd_slave_readdata;
                    fwrite(&val, 4, 1, fp);
                    
                    wait = (wait == false)? true : false;
                }
                
                top->sd_slave_read = 0;
                sd_command = 0;
                
                for(uint32 i=0; i<30; i++) {
                    top->clk = 0;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    top->clk = 1;
                    top->eval();
                    if(dump) tracer->dump(cycle++);
                    
                    tracer->flush();
                }
                
                fclose(fp);
            }
        }
        
        //----------------------------------------------------------------------
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
        
        usleep(10);
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
    
    //irq
    output reg          irq,
    
    //avalon slave
    input               io_address,
    input       [3:0]   io_byteenable,
    input               io_read,
    output reg  [31:0]  io_readdata,
    input               io_write,
    input       [31:0]  io_writedata, 
    
    //ide shared port 0x3F6
    input               ide_3f6_read,
    output reg  [7:0]   ide_3f6_readdata,
    input               ide_3f6_write,
    input       [7:0]   ide_3f6_writedata,
    
    //master to control sd
    output      [31:0]  sd_master_address,
    input               sd_master_waitrequest,
    output              sd_master_read,
    input               sd_master_readdatavalid,
    input       [31:0]  sd_master_readdata,
    output              sd_master_write,
    output      [31:0]  sd_master_writedata,
    
    //slave with data from/to sd
    input       [8:0]   sd_slave_address,
    input               sd_slave_read,
    output reg  [31:0]  sd_slave_readdata,
    input               sd_slave_write,
    input       [31:0]  sd_slave_writedata,
    
    //management slave
    //0x00.[31:0]:    identify write
    //0x01.[16:0]:    media cylinders
    //0x02.[4:0]:     media heads
    //0x03.[8:0]:     media spt
    //0x04.[13:0]:    media sectors per cylinder = spt * heads
    //0x05.[31:0]:    media sectors total
    //0x06.[31:0]:    media sd base
    
    input       [2:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
*/
