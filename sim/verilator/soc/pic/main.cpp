#include <cstdio>
#include <cstdlib>

#include "Vpic.h"
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

uint32  interrupt_input = 0;
uint32  interrupt_vector = 0;
bool    interrupt_ack = false;

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

bool is_address_ok(uint32 address) {
    if(address >= 0x0020 && address <= 0x021) return true;
    if(address >= 0x00A0 && address <= 0x0A1) return true;
    
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
        
        uint32 irq_signal = 0;
        count = sscanf(line, "raise_irq %d", &irq_signal);
        if(count == 1) {
            interrupt_input |= (1 << irq_signal);
printf("line: %s", line);
            delay = 5;
            state = S_DELAY;
            return true;
        }
        
        count = sscanf(line, "lower_irq %d", &irq_signal);
        if(count == 1) {
            interrupt_input &= ~(1 << irq_signal);
printf("line: %s", line);
            delay = 5;
            state = S_DELAY;
            return true;
        }
        
        count = sscanf(line, "IAC %d", &irq_signal);
        if(count == 1) {
            interrupt_ack = true;
            interrupt_vector = irq_signal;
printf("line: %s", line);
            delay = 5;
            state = S_DELAY;
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
    
    Vpic *top = new Vpic();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("pic.vcd");
    
    bool dump = true;
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    uint32 cycle = 0;
    while(!Verilated::gotFinish()) {
        
        //----------------------------------------------------------------------
        
        top->interrupt_done = 0;
        
        if(state == S_IDLE) {
            bool res = next_record();
            if(res == false) {
                printf("End of file.\n");
                break;
            }
            
            top->interrupt_input = interrupt_input & 0xFFFF;
            
            if(interrupt_ack) {
                if(top->interrupt_do == 0) {
                    printf("ERROR: interrupt_do not set for: %d\n", interrupt_vector);
                    exit(-1);
                }
                
                if(top->interrupt_vector != interrupt_vector) {
                    printf("ERROR: interrupt_vector %d != %d\n", interrupt_vector, top->interrupt_vector);
                    exit(-1);
                }
                
                top->interrupt_done = 1;
                interrupt_ack = false;
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
            if(address >= 0x00A0 && address <= 0x00A1) {
                top->slave_address = address & 0x1;
                top->slave_read = 1;
            }
            else if(address >= 0x0020 && address <= 0x0021) {
                top->master_address = address & 0x1;
                top->master_read = 1;
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
                
            if(address >= 0x00A0 && address <= 0x00A1)      top_readdata = top->slave_readdata & 0xFF;
            else if(address >= 0x0020 && address <= 0x0021) top_readdata = top->master_readdata & 0xFF;
            
            if(length > 0) {
                address++;
                
                if(address >= 0x00A0 && address <= 0x00A1)      top->slave_address  = address & 0x1;
                else if(address >= 0x0020 && address <= 0x0021) top->master_address = address & 0x1;
                else {
                    printf("ERROR: invalid io rd address: %08x\n", address);
                    exit(-1);
                }
                
                value_read |= (top_readdata & 0xFF) << 24;
                value_read >>= 8;
                
                top->slave_read = 0;
                top->master_read = 0;
                state = S_IO_READ_3;
            }
            else {
                top->slave_read = 0;
                top->master_read = 0;
                
                value_read |= (top_readdata & 0xFF) << 24;
                value_read >>= 8*(4 - shifted_read - shifted);
                
                if(value_read != value_base) {
                    printf("mismatch io rd %08x %x %08x != %08x\n", address_base, byteena, value_base, value_read);
                    
//if(! ((address_base ==  && byteena == )))
exit(0);
                }
                
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_IO_READ_3) {
            if(address >= 0x00A0 && address <= 0x00A1)      top->slave_read = 1;
            else if(address >= 0x0020 && address <= 0x0021) top->master_read = 1;
            
            state = S_IO_READ_2;            
        }
        else if(state == S_IO_WRITE_1) {
            if(address >= 0x00A0 && address <= 0x00A1) {
                top->slave_address = address & 0x1;
                top->slave_write = 1;
                top->slave_writedata = value & 0xFF;
            }
            else if(address >= 0x0020 && address <= 0x0021) {
                top->master_address = address & 0x1;
                top->master_write = 1;
                top->master_writedata = value & 0xFF;
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
                
                if(address >= 0x00A0 && address <= 0x00A1) {
                    top->slave_address = address & 0x1;
                    top->slave_writedata = value & 0xFF;
                }
                else if(address >= 0x0020 && address <= 0x0021) {
                    top->master_address = address & 0x1;
                    top->master_writedata = value & 0xFF;
                }
                else {
                    printf("ERROR: invalid io wr address: %08x\n", address);
                    exit(-1);
                }
                
                top->slave_write = 0;
                top->master_write = 0;
                state = S_IO_WRITE_3;
            }
            else {
                top->slave_write = 0;
                top->master_write = 0;
            
                delay = 5;
                state = S_DELAY;
            }
        }
        else if(state == S_IO_WRITE_3) {
            if(address >= 0x00A0 && address <= 0x00A1)      top->slave_write = 1;
            else if(address >= 0x0020 && address <= 0x0021) top->master_write = 1;
            
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
