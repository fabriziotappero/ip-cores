//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <time.h>

#include "top_if.h"

#include "Vtop__Syms.h"
#include "verilated.h"

#if VM_TRACE
#include <verilated_vcd_c.h>
#endif

//-----------------------------------------------------------------
// Defines
//-----------------------------------------------------------------
#define MEMORY_START        0x10000000
#define MEMORY_SIZE         (1024 * 1024)

#define OR32_BUBBLE_OPCODE  0xFC000000

#define CPU_INSTANCE        top->v->u_cpu->u1_cpu

//-----------------------------------------------------------------
// Locals
//-----------------------------------------------------------------
static Vtop *top;
static unsigned int         _stop_pc = 0xFFFFFFFF;

#if VM_TRACE
static unsigned int        main_time = 0;
static VerilatedVcdC*      tfp;
#endif

//-----------------------------------------------------------------
// top_init
//-----------------------------------------------------------------
int top_init(void)
{
    top = new Vtop();    

#if VM_TRACE                  
    // If verilator was invoked with --trace
    Verilated::traceEverOn(true);
    VL_PRINTF("Enabling GTKWave Trace Output...\n");
    tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("wave_dump.vcd");
#endif

    // Initial
    top->clk_i = 0;
    top->rst_i = 1;
    top->intr_i = 0;
    top->eval();

    // Reset
    top->clk_i = 1;
    top->rst_i = 1;
    top->eval();

    top->clk_i = 0;
    top->rst_i = 0;
    top->eval();

    return 0;
}

//-----------------------------------------------------------------
// top_load
//-----------------------------------------------------------------
int top_load(unsigned int addr, unsigned char val)
{
    if (addr >= (MEMORY_SIZE - MEMORY_START))
        return -1;

    addr -= MEMORY_START;    

    switch (addr & 0x3)
    {
    case 0:
        top->v->u_ram->u3->ram[addr >> 2] = val;
        break;
    case 1:
        top->v->u_ram->u2->ram[addr >> 2] = val;
        break;
    case 2:
        top->v->u_ram->u1->ram[addr >> 2] = val;
        break;
    case 3:
        top->v->u_ram->u0->ram[addr >> 2] = val;
        break;
    }

    return 0;
}
//-----------------------------------------------------------------
// top_setbreakpoint
//-----------------------------------------------------------------
int top_setbreakpoint(int bp, unsigned int pc)
{
    if (bp != 0)
        return -1;
    else
    {
        _stop_pc = pc;
        return 0;
    }
}
//-----------------------------------------------------------------
// top_run
//-----------------------------------------------------------------
int top_run(unsigned int pc, int cycles, int intr_after_cycles)
{
    int current_cycle = 0;      

    // Run until fault or number of cycles completed
    while (!Verilated::gotFinish() && !top->fault_o && (current_cycle < cycles || cycles == -1)) 
    {
        // CLK->L
        top->clk_i = 0;
        top->eval();

#if VM_TRACE
        if (tfp) tfp->dump (main_time++);
#endif

        // CLK->H
        top->clk_i = 1;
        top->eval();            

#if VM_TRACE
        if (tfp) tfp->dump (main_time++);
#endif

        // Get current executing instruction PC
        unsigned int pc = CPU_INSTANCE->u_exec->get_pc_ex();
        unsigned int opcode = CPU_INSTANCE->u_exec->get_opcode_ex();

#ifdef INST_TRACE
        // Instruction trace - decode instruction opcode to text
        if (opcode != OR32_BUBBLE_OPCODE)
            printf("%08x:   %02x %02x %02x %02x\n", pc, (opcode >> 24) & 0xFF, (opcode >> 16) & 0xFF, (opcode >> 8) & 0xFF, (opcode >> 0) & 0xFF);
#endif

        // Generate interrupt after a certain number of cycles?
        if (intr_after_cycles >= 0 && intr_after_cycles == current_cycle)
        {
            top->intr_i = 1;
            intr_after_cycles = -1;
        }
        else
            top->intr_i = 0;

        current_cycle++;

        // Breakpoint hit?
        if (_stop_pc == pc || top->break_o)
        {
            if (_stop_pc == pc)
                printf("Stopped at breakpoint 0x%x\n", _stop_pc);
            printf("Cycles = %d\n", current_cycle);
            return TOP_RES_BREAKPOINT;
        }
    }

    printf("Cycles = %d\n", current_cycle);

    // Fault
    if (top->fault_o)
    {
        printf("FAULT PC %x!\n", CPU_INSTANCE->u_exec->get_pc_ex());
        return TOP_RES_FAULT;
    }
    // Number of cycles reached
    else if (current_cycle >= cycles)
        return TOP_RES_MAX_CYCLES;
    // No error
    else
        return TOP_RES_OK;
}
//-----------------------------------------------------------------
// top_done
//-----------------------------------------------------------------
void top_done(void)
{
    top->final();
#if VM_TRACE
    if (tfp)
    {
        tfp->close();
        tfp = NULL;
    }
#endif
}
