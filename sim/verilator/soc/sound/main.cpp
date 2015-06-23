#include <cstdio>
#include <cstdlib>
#include <unistd.h>

#include "Vsound.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

//------------------------------------------------------------------------------

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef unsigned long  uint64;

//------------------------------------------------------------------------------

FILE *fp = NULL;
int counter_to_end = 0;

void next_write(uint32 &address, uint32 &value, uint32 &wait) {
    if(fp == NULL) {
        fp = fopen("input.txt", "rb");
        if(fp == NULL) {
            fprintf(stderr, "can not open file\n");
            exit(-1);
        }
    }
    char line[256];
    
    wait = 0;
    while(true) {
    char *result = fgets(line, sizeof(line), fp);
        if(result == NULL) {
            fprintf(stderr, "EOF\n");
            wait = 1;
            counter_to_end = 100000;
            return;
        }
        
        uint32 byteena, val;
        int ret = sscanf(line, "io wr 0228 %d %x", &byteena, &val);
        
        if(ret == 2) {
            if(byteena == 1) {
                address = 0;
                value   = val & 0xFF;
                return;
            }
            else if(byteena == 2) {
                address = 1;
                value = (val >> 8) & 0xFF;
                return;
            }
            else {
                fprintf(stderr, "unknown byteena: %d, val: %08x\n", byteena, val);
            }
        }
        else if(strstr(line, "IAC") != NULL) {
            wait = 1;
            return;
        }
        else {
            fprintf(stderr, "skipping line: %s\n", line);
        }
    }
}
//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vsound *top = new Vsound();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("sound.vcd");
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    bool dump = true;
    uint64 cycle = 0;
    
    int CYCLES_IN_80_US = 2400;
    int CYCLES_IN_SAMPLE = 347;
    
    //256.[12:0]:  cycles in 80us
    //257.[9:0]:   cycles in 1 sample: 96000 Hz
    
    for(uint32 i=256; i<258; i++) {
        top->mgmt_write = 1;
        top->mgmt_address = i;
        top->mgmt_writedata = (i==256)? CYCLES_IN_80_US : CYCLES_IN_SAMPLE;
        
        top->clk = 0;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        if(dump) tracer->dump(cycle++);
        
        tracer->flush();
    }
    top->mgmt_write = 0;
    
    printf("sound main.cpp\n");
    
    uint32 DELAY = 200;
    uint32 delay = DELAY;
    while(!Verilated::gotFinish()) {
        
        top->fm_write = 0;
        if(counter_to_end == 1) break;
        if(counter_to_end > 1) counter_to_end--;
        
        //----------------------------------------------------------------------
        
        if(delay == 0 && counter_to_end == 0) {
            uint32 address, value, wait;
            
            next_write(address, value, wait);
            
            if(wait == 0) {
                top->fm_address   = address;
                top->fm_write     = 1;
                top->fm_writedata = value;
            
                delay = DELAY;
            }
            else {
                delay = 10*DELAY;
            }
        }
        else {
            delay--;
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
module sound(
    input               clk,
    input               rst_n,
    
    output              irq,
    
    //speaker input
    input               speaker_enable,
    input               speaker_out,
    
    //io slave 220h-22Fh
    input       [3:0]   io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //fm music io slave 388h-389h
    input               fm_address,
    input               fm_read,
    output      [7:0]   fm_readdata,
    input               fm_write,
    input       [7:0]   fm_writedata,

    //dma
    output              dma_soundblaster_req,
    input               dma_soundblaster_ack,
    input               dma_soundblaster_terminal,
    input       [7:0]   dma_soundblaster_readdata,
    output      [7:0]   dma_soundblaster_writedata,
    
    //sound interface master
    output      [2:0]   avm_address,
    input               avm_waitrequest,
    output              avm_write,
    output      [31:0]  avm_writedata,
    
    //mgmt slave
    
    //0-255.[15:0]: cycles in period
    //256.[12:0]:  cycles in 80us
    //257.[9:0]:   cycles in 1 sample: 96000 Hz

    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);
*/
