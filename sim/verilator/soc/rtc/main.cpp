#include <cstdio>
#include <cstdlib>

#include "Vrtc.h"
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

uint32  address_base;
uint32  address;
uint32  byteena;
uint32  value_base;
uint32  value;
state_t state = S_IDLE;
uint32  shifted;
uint32  shifted_read;
uint32  length;
uint32  value_read;

uint32  delay;

void check_byteena(uint32 byteena) {
    if(byteena == 0 || byteena == 5 || byteena == 9 || byteena == 10 || byteena == 11 || byteena == 13) {
        printf("ERROR: invalid byteena: %x\n", byteena);
        exit(-1);
    }
    
    if((byteena & 0xC) != 0) {
        printf("ERROR: access to byteena: %x\n", byteena);
        exit(-1);
    }
    
    value_read = 0;
    address_base = address;
    value_base = value;
    shifted_read = 0;
    
    shifted = 0;
    for(uint32 i=0; i<4; i++) {
        if(byteena & 1) break;
        
        shifted++;
        address++;
        byteena >>= 1;
        value >>= 8;
    }
    
    length = 0;
    for(uint32 i=0; i<4; i++) {
        if(byteena & 1) length++;
        
        byteena >>= 1;
    }
}

bool is_address_ok(uint32 address) {
    if(address >= 0x0070 && address <= 0x071) return true;
    
    return false;
}

bool next_record() {
    static FILE *fp = NULL;
    
    if(fp == NULL) {
        fp = fopen("./../../../../backup/run-3/track.txt", "rb");
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

uint32 fdd_type = 0x40;
uint32 hd_cylinders = 1024;
uint32 hd_heads = 16;
uint32 hd_spt = 63;
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
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vrtc *top = new Vrtc();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("rtc.vcd");
    
    bool dump = true;
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    uint32 cycle = 0;
    
    for(uint32 i=0; i<128; i++) {
        
        top->mgmt_write = 1;
        top->mgmt_address = i;
        top->mgmt_writedata = cmos[i];
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
    }
    top->mgmt_write = 0;
    
    while(!Verilated::gotFinish()) {
        
        //----------------------------------------------------------------------
        
        if(state == S_IDLE) {
            bool res = next_record();
            if(res == false) {
                printf("End of file.\n");
                break;
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
            top->io_address = address & 0x1;
            top->io_read = 1;
            
            state = S_IO_READ_2;
        }
        else if(state == S_IO_READ_2) {
            length--;
            shifted_read++;
            
            uint32 top_readdata = 0;
                
            top_readdata = top->io_readdata & 0xFF;
            
            if(length > 0) {
                address++;
                
                top->io_address = address & 0x1;
                
                value_read |= (top_readdata & 0xFF) << 24;
                value_read >>= 8;
                
                top->io_read = 0;
                state = S_IO_READ_3;
            }
            else {
                top->io_read = 0;
                
                value_read |= (top_readdata & 0xFF) << 24;
                value_read >>= 8*(4 - shifted_read - shifted);
                
                if(value_read != value_base) {
                    printf("mismatch io rd %08x %x %08x != %08x\n", address_base, byteena, value_base, value_read);
                    
                    static int ign_cnt = 0;
                    ign_cnt++;
//if(! ((address_base ==  && byteena == )))
//if(ign_cnt >= 2)
//exit(0);
                }
                
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_IO_READ_3) {
            top->io_read = 1;
            
            state = S_IO_READ_2;            
        }
        else if(state == S_IO_WRITE_1) {
            top->io_address = address & 1;
            top->io_write = 1;
            top->io_writedata = value & 0xFF;
            
            state = S_IO_WRITE_2;
        }
        else if(state == S_IO_WRITE_2) {
            length--;
            
            if(length > 0) {
                address++;
                value >>= 8;
                
                top->io_address = address & 0x1;
                top->io_writedata = value & 0xFF;
                
                top->io_write = 0;
                state = S_IO_WRITE_3;
            }
            else {
                top->io_write = 0;
            
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_IO_WRITE_3) {
            top->io_write = 0;
            
            state = S_IO_WRITE_2;
        }
        
        //----------------------------------------------------------------------
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
        
        if(top->irq) {
            printf("ERROR: irq signaled.\n");
            exit(-1);
        }
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
