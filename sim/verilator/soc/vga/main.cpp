#include <cstdio>
#include <cstring>
#include <cstdlib>

#include "Vvga.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

//------------------------------------------------------------------------------

typedef unsigned int uint32;
typedef unsigned char uint8;

//------------------------------------------------------------------------------

enum state_t {
    S_IDLE,
    
    S_MEM_READ_1,
    S_MEM_READ_2,
    S_MEM_READ_3,
    
    S_MEM_WRITE_1,
    S_MEM_WRITE_2,
    S_MEM_WRITE_3,
    
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
        if(count == 3 && address >= 0x03B0 && address <= 0x03DF) {
            check_byteena(byteena);
            state = S_IO_READ_1;
            return true;
        }
        count = sscanf(line, "io wr %x %x %x", &address, &byteena, &value);
        if(count == 3 && address >= 0x03B0 && address <= 0x03DF) {
            check_byteena(byteena);
            state = S_IO_WRITE_1;
            return true;
        }
        count = sscanf(line, "vga rd %x %x %x", &address, &byteena, &value);
        if(count == 3 && address >= 0x000A0000 && address <= 0x000BFFFF) {
            check_byteena(byteena);
            state = S_MEM_READ_1;
            return true;
        }
        count = sscanf(line, "vga wr %x %x %x", &address, &byteena, &value);
        if(count == 3 && address >= 0x000A0000 && address <= 0x000BFFFF) {
            check_byteena(byteena);
            state = S_MEM_WRITE_1;
            return true;
        }
    } while(true);
    
    return false;
}


//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vvga *top = new Vvga();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("vga.vcd");
    
    bool dump = true;
    
    //reset
    top->clk_26 = 0; top->rst_n = 1; top->eval();
    top->clk_26 = 1; top->rst_n = 1; top->eval();
    top->clk_26 = 1; top->rst_n = 0; top->eval();
    top->clk_26 = 0; top->rst_n = 0; top->eval();
    top->clk_26 = 0; top->rst_n = 1; top->eval();
    
    uint32 cycle = 0;
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
        else if(state == S_MEM_READ_1) {
            top->mem_address = address & 0x1FFFF;
            top->mem_read = 1;
            
            state = S_MEM_READ_2;
        }
        else if(state == S_MEM_READ_2) {
            length--;
            shifted_read++;
            
            if(length > 0) {
                address++;
                
                top->mem_address = address & 0x1FFFF;
                
                value_read |= (top->mem_readdata & 0xFF) << 24;
                value_read >>= 8;
                
                top->mem_read = 0;
                state = S_MEM_READ_3;
            }
            else {
                top->mem_read = 0;
                
                value_read |= (top->mem_readdata & 0xFF) << 24;
                value_read >>= 8*(4 - shifted_read - shifted);
                
                if(value_read != value_base) {
                    printf("mismatch mem rd %08x %x %08x != %08x\n", address_base, byteena, value_base, value_read);
exit(0);
                }
            
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_MEM_READ_3) {
            top->mem_read = 1;
            state = S_MEM_READ_2;            
        }
        else if(state == S_MEM_WRITE_1) {
            top->mem_address = address & 0x1FFFF;
            top->mem_write = 1;
            top->mem_writedata = value & 0xFF;
            
            state = S_MEM_WRITE_2;
        }
        else if(state == S_MEM_WRITE_2) {
            length--;
            
            if(length > 0) {
                address++;
                
                top->mem_address = address & 0x1FFFF;
                
                value >>= 8;
                top->mem_writedata = value & 0xFF;
                
                top->mem_write = 0;
                state = S_MEM_WRITE_3;
            }
            else {
                top->mem_write = 0;
            
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_MEM_WRITE_3) {
            top->mem_write = 1;
            state = S_MEM_WRITE_2;
        }
        else if(state == S_IO_READ_1) {
            if(address >= 0x03B0 && address <= 0x03BF) {
                top->io_b_address = address & 0xF;
                top->io_b_read = 1;
            }
            else if(address >= 0x03C0 && address <= 0x03CF) {
                top->io_c_address = address & 0xF;
                top->io_c_read = 1;
            }
            else if(address >= 0x03D0 && address <= 0x03DF) {
                top->io_d_address = address & 0xF;
                top->io_d_read = 1;
            }
            else {
                printf("ERROR: invalid io rd address: %08x\n", address);
                exit(-1);
            }
            state = S_IO_READ_2;
        }
        else if(state == S_IO_READ_2) {
            length--;
            shifted_read++;
            
            uint32 top_readdata = 0;
                
            if(address >= 0x03B0 && address <= 0x03BF)      top_readdata = top->io_b_readdata & 0xFF;
            else if(address >= 0x03C0 && address <= 0x03CF) top_readdata = top->io_c_readdata & 0xFF;
            else if(address >= 0x03D0 && address <= 0x03DF) top_readdata = top->io_d_readdata & 0xFF;
            
            if(length > 0) {
                address++;
                
                if(address >= 0x03B0 && address <= 0x03BF)      top->io_b_address = address & 0xF;
                else if(address >= 0x03C0 && address <= 0x03CF) top->io_c_address = address & 0xF;
                else if(address >= 0x03D0 && address <= 0x03DF) top->io_d_address = address & 0xF;
                else {
                    printf("ERROR: invalid io rd address: %08x\n", address);
                    exit(-1);
                }
                
                value_read |= (top_readdata & 0xFF) << 24;
                value_read >>= 8;
                
                top->io_b_read = 0;
                top->io_c_read = 0;
                top->io_d_read = 0;
                state = S_IO_READ_3;
            }
            else {
                top->io_b_read = 0;
                top->io_c_read = 0;
                top->io_d_read = 0;
                
                value_read |= (top_readdata & 0xFF) << 24;
                value_read >>= 8*(4 - shifted_read - shifted);
                
                if(value_read != value_base) {
                    printf("mismatch io rd %08x %x %08x != %08x\n", address_base, byteena, value_base, value_read);
                    
if(! ((address_base == 0x03D8 && byteena == 4) || (address_base == 0x03C8 && byteena == 4)))
exit(0);
                }
                
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_IO_READ_3) {
            if(address >= 0x03B0 && address <= 0x03BF)      top->io_b_read = 1;
            else if(address >= 0x03C0 && address <= 0x03CF) top->io_c_read = 1;
            else if(address >= 0x03D0 && address <= 0x03DF) top->io_d_read = 1;
            
            state = S_IO_READ_2;            
        }
        else if(state == S_IO_WRITE_1) {
            if(address >= 0x03B0 && address <= 0x03BF) {
                top->io_b_address = address & 0xF;
                top->io_b_write = 1;
                top->io_b_writedata = value & 0xFF;
            }
            else if(address >= 0x03C0 && address <= 0x03CF) {
                top->io_c_address = address & 0xF;
                top->io_c_write = 1;
                top->io_c_writedata = value & 0xFF;
            }
            else if(address >= 0x03D0 && address <= 0x03DF) {
                top->io_d_address = address & 0xF;
                top->io_d_write = 1;
                top->io_d_writedata = value & 0xFF;
            }
            else {
                printf("ERROR: invalid io wr address: %08x\n", address);
                exit(-1);
            }
            state = S_IO_WRITE_2;
        }
        else if(state == S_IO_WRITE_2) {
            length--;
            
            if(length > 0) {
                address++;
                value >>= 8;
                
                if(address >= 0x03B0 && address <= 0x03BF) {
                    top->io_b_address = address & 0xF;
                    top->io_b_writedata = value & 0xFF;
                }
                else if(address >= 0x03C0 && address <= 0x03CF) {
                    top->io_c_address = address & 0xF;
                    top->io_c_writedata = value & 0xFF;
                }
                else if(address >= 0x03D0 && address <= 0x03DF) {
                    top->io_d_address = address & 0xF;
                    top->io_d_writedata = value & 0xFF;
                }
                else {
                    printf("ERROR: invalid io wr address: %08x\n", address);
                    exit(-1);
                }
                
                top->io_b_write = 0;
                top->io_c_write = 0;
                top->io_d_write = 0;
                state = S_IO_WRITE_3;
            }
            else {
                top->io_b_write = 0;
                top->io_c_write = 0;
                top->io_d_write = 0;
            
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_IO_WRITE_3) {
            if(address >= 0x03B0 && address <= 0x03BF)      top->io_b_write = 1;
            else if(address >= 0x03C0 && address <= 0x03CF) top->io_c_write = 1;
            else if(address >= 0x03D0 && address <= 0x03DF) top->io_d_write = 1;
            
            state = S_IO_WRITE_2;
        }
        
        //----------------------------------------------------------------------
        
        top->clk_26 = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk_26 = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        //if((cycle % 1000) == 0) printf("half-cycle: %d\n", cycle);
        
        tracer->flush();
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
