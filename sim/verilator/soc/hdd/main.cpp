#include <cstdio>
#include <cstdlib>

#include "Vhdd.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

//------------------------------------------------------------------------------

typedef unsigned int uint32;
typedef unsigned char uint8;

//------------------------------------------------------------------------------

enum state_t {
    S_IDLE,
    
    S_IO_READ_1,
    S_IO_READ_2,
    S_IO_READ_3,
    
    S_IO_WRITE_1,
    S_IO_WRITE_2,
    S_IO_WRITE_3,
    
    S_DELAY
};

uint32  address;
uint32  byteena;
uint32  value;
state_t state = S_IDLE;

uint32  delay;

void check_byteena(uint32 byteena) {
    if(byteena == 0 || byteena == 5 || byteena == 9 || byteena == 10 || byteena == 11 || byteena == 13) {
        printf("ERROR: invalid byteena: %x\n", byteena);
        exit(-1);
    }
    
    if(address == 0x03F4 && byteena != 0x4) {
        printf("ERROR: read not from 0x3F6.\n");
        exit(-1);
    }
}

bool is_address_ok(uint32 address) {
    if(address >= 0x01F0 && address <= 0x01F7) return true;
    if(address >= 0x03F4 && address <= 0x03F7) return true;
    
    return false;
}

bool next_record() {
    static FILE *fp = NULL;
    
    if(fp == NULL) {
        fp = fopen("./../../../../backup/run-5-win311-32file/track.txt", "rb");
        if(fp == NULL) {
            printf("ERROR: can not open file.\n");
            exit(-1);
        }
    }
    
    do {
        char line[256];
        memset(line, 0, sizeof(line));
    
        char *res = fgets(line, sizeof(line), fp);
        if(res == NULL) {
            fclose(fp);
            fp = NULL;
            return false;
        }
    
//printf("line: %s\n", line);
    
        int count;
    
        count = sscanf(line, "io rd %x %x %x", &address, &byteena, &value);
        if(count == 3 && is_address_ok(address)) {
            check_byteena(byteena);
            state = S_IO_READ_1;
printf("line: %s", line);
            return true;
        }
        count = sscanf(line, "io wr %x %x %x", &address, &byteena, &value);
        if(count == 3 && is_address_ok(address)) {
            check_byteena(byteena);
            state = S_IO_WRITE_1;
printf("line: %s", line);
            return true;
        }
        
    } while(true);
    
    return false;
}

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

int main(int argc, char **argv) {
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
    
    uint32 cycle = 0;
    
    
//#error initialize mgmt for hd_cylinders ...
    
    for(uint32 i=0; i<128; i++) {
        
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
    top->mgmt_write = 0;
    
    uint32 loop_run = 0;
    while(!Verilated::gotFinish()) {
        loop_run++;
        //if(loop_run > 111920000) dump = true;
        
        //----------------------------------------------------------------------
        
        if(state == S_IDLE) {
            bool res = next_record();
            if(res == false) {
                printf("End of file.\n");
                break;
            }
        }
        
        if(top->irq) {
            printf("ERROR: irq set.\n");
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
        }
        else if(sd_command != 0) {
                
            if(sd_command == 2) { //read
                
                FILE *fp = fopen("/home/alek/temp/bochs-run/hd_copy_for_sim.img", "rb");
                
                for(uint32 i=0; i<sd_sector_count*128; i++) {
                    
                    fseek(fp, (sd_address*512)+(i*4), SEEK_SET);
                    
                    uint32 val;
                    fread(&val, 4, 1, fp);
                    
                    //printf("pos: %d %08x\n", (sd_address*512)+(i*4), val);
                    
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
                
                //getchar();
            }
            
        }
        
        
        //----------------------------------------------------------------------
        
        if(state == S_DELAY) {
            delay--;
            
            if(delay == 0) {
                state = S_IDLE;
            }
        }
        else if(state == S_IO_READ_1) {
            if(address >= 0x01F0 && address <= 0x01F7) {
                top->io_address = (address >> 2) & 0x1;
                top->io_byteenable = byteena & 0xF;
                top->io_read = 1;
            }
            else if(address >= 0x03F4 && address <= 0x03F6) {
                top->ide_3f6_read = 1;
            }
            else {
                printf("ERROR: invalid io rd address: %08x\n", address);
                exit(-1);
            }
            state = S_IO_READ_2;
        }
        else if(state == S_IO_READ_2) {
            uint32 top_readdata = 0;
                
            if(address >= 0x01F0 && address <= 0x01F7)      top_readdata = top->io_readdata & 0xFFFFFFFF;
            else if(address >= 0x03F4 && address <= 0x03F7) top_readdata = (top->ide_3f6_readdata & 0xFF) << 16;
            
            top->io_read = 0;
            top->ide_3f6_read = 0;
 
            //clear index pulse
            if(address == 0x01F4 && byteena == 0x8) {
                top_readdata &= ~0x02000000;
                value &= ~0x02000000;
            }
            
            if(byteena == 3) top_readdata &= 0x0000FFFF;
            
            if(top_readdata != value) {
                printf("mismatch io rd %08x %x %08x != %08x, loop: %d\n", address, byteena, value, top_readdata, loop_run);
                
                static int ign_cnt = 0;
                ign_cnt++;
                
//if(! ((address == 0x01F4 && byteena == 0x8)))
//if(ign_cnt >= 5)
exit(0);
            }
                
            delay = 200;
            state = S_DELAY;
        }
        else if(state == S_IO_WRITE_1) {
            if(address >= 0x01F0 && address <= 0x01F7) {
                top->io_address = (address >> 2) & 0x1;
                top->io_write = 1;
                top->io_writedata = value;
                top->io_byteenable = byteena & 0xF;
            }
            else if(address >= 0x03F4 && address <= 0x03F7) {
                top->ide_3f6_write = 1;
                top->ide_3f6_writedata = (value >> 8*2) & 0xFF;
            }
            else {
                printf("ERROR: invalid io wr address: %08x\n", address);
                exit(-1);
            }
            state = S_IO_WRITE_2;
        }
        else if(state == S_IO_WRITE_2) {
            
            top->io_write = 0;
            top->ide_3f6_write = 0;
            
            delay = 200;
            state = S_DELAY;
        }
                
        //----------------------------------------------------------------------
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
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
