#include <cstdio>
#include <cstdlib>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vdriver_sd.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

//------------------------------------------------------------------------------

typedef unsigned long long uint64;

//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    
    //--------------------------------------------------------------------------
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vdriver_sd *top = new Vdriver_sd();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("main.vcd");

    //reset
    bool dump_enabled = true;
    vluint64_t halfcycle = 0;
    
    top->clk = 0; top->rst_n = 1; top->eval(); if(dump_enabled) { tracer->dump(halfcycle); } halfcycle++;
    top->clk = 0; top->rst_n = 0; top->eval(); if(dump_enabled) { tracer->dump(halfcycle); } halfcycle++;
    top->rst_n = 1;
    
    //--------------------------------------------------------------------------
    
    while(!Verilated::gotFinish()) {
        
        
        //----------------------------------------------------------------------
        top->clk = 0;
        top->eval();
        
        if(dump_enabled) tracer->dump(halfcycle); halfcycle++;
        
        top->clk = 1;
        top->eval();
        
        if(dump_enabled) tracer->dump(halfcycle); halfcycle++;
        
        
        tracer->flush();
        //usleep(1);
        
        if(halfcycle > 1000) break;
    }
    top->final();
    delete top;
    return 0;
}

/*
    input               clk,
    input               rst_n,
    
    //
    input       [1:0]   avs_address,
    input               avs_read,
    output      [31:0]  avs_readdata,
    input               avs_write,
    input       [31:0]  avs_writedata,
    
    //
    output      [31:0]  avm_address,
    input               avm_waitrequest,
    output              avm_read,
    input       [31:0]  avm_readdata,
    input               avm_readdatavalid,
    output              avm_write,
    output      [31:0]  avm_writedata,
    
    //
    output reg          sd_clk,
    inout               sd_cmd,
    inout       [3:0]   sd_dat
*/
