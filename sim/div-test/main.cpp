/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstdlib>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vmain.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

//------------------------------------------------------------------------------

typedef unsigned int        uint32;
typedef unsigned char       uint8;
typedef unsigned long long  uint64;

//------------------------------------------------------------------------------


int main(int argc, char **argv) {
    
    //--------------------------------------------------------------------------
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vmain *top = new Vmain();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("main.vcd");

    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    //--------------------------------------------------------------------------
    
    bool dump_enabled = true;
    
    int cycle = 0;
    
    int pnom[]  = { 0,1,2,3, 0,1,2,3, 0,1,2,3, 0,1,2,3, 0,1,-2,-1, 0,1,-2,-1,  0, 1,-2,-1,  0, 1,-2,-1 };
    int pden[]  = { 0,0,0,0, 1,1,1,1, 2,2,2,2, 3,3,3,3, 0,0, 0, 0, 1,1, 1, 1, -2,-2,-2,-2, -1,-1,-1,-1 };
        
    int nom[]   = { 0,1,2,3, 0,1,2,3, 0,1,2,3, 0,1,2,3,  0,1,4|2,4|3, 0,1,4|2,4|3, 0,  1,  4|2,4|3, 0,  1,  4|2,4|3 };
    int denom[] = { 0,0,0,0, 1,1,1,1, 2,2,2,2, 3,3,3,3,  0,0,0,  0,   1,1,1,  1,   4|2,4|2,4|2,4|2, 4|2,4|2,4|2,4|2 };
    
    int index = 0;
    bool running = false;
    
    while(!Verilated::gotFinish()) {
        
        top->start = 0;
        top->dividend = 0;
        top->divisor = 0;
        
        if(running == false) {
            top->start = 1;
            top->dividend = nom[index];
            top->divisor  = denom[index];
            running = true;
        }
        
        if(top->ready) {
            printf("%02d / %02d = q: %02d r: %02d\n", pnom[index], pden[index], top->quotient, top->remainder);
            running = false;
            index++;
            
            if(index == 32) {
                printf("END\n");
                break;
            }
        }
        
        top->clk = 0;
        top->eval();
        
        cycle++;
        if(dump_enabled) tracer->dump(cycle);
        
        top->clk = 1;
        top->eval();
        
        cycle++;
        if(dump_enabled) tracer->dump(cycle);
        
        tracer->flush();
        //usleep(1);
    }
    delete top;
    return 0;
}

/*
    input               clk,
    input               rst_n,
    
    input               start,
    input       [2:0]  dividend,
    input       [2:0]  divisor,
    
    output              ready,
    output      [1:0]  quotient,
    output      [1:0]  remainder
*/
