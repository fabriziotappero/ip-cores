/*

Copyright (c) 2003 Launchbird Design Systems, Inc.

C test bench for State Space Processor.
Demonstrates a first order discrete filter:

  H(z) = Y(z) / X(z) = 0.2 / (1 - 0.8 * (1/z))

  y(k) = 0.2 * x(k) + 0.8 * y(k-1)

State Space Processor is configured for 16-bit data and
an 8-bit instruction memory address bus.

*/

#include <stdio.h>
#include "cf_ssp_16_8.h"

// State Space Processor Inputs

static unsigned char reset[1];
static unsigned char cycle[1];
static unsigned char instr_data[2];
static unsigned char const_data[2];
static unsigned char load_write[1];
static unsigned char load_addr[1];
static unsigned char load_data[2];

// State Space Processor Outputs

static unsigned char done[1];
static unsigned char instr_addr[1];
static unsigned char const_addr[1];
static unsigned char reg_0[2];
static unsigned char reg_1[2];
static unsigned char reg_2[2];
static unsigned char reg_3[2];
static unsigned char reg_4[2];
static unsigned char reg_5[2];
static unsigned char reg_6[2];
static unsigned char reg_7[2];
static unsigned char reg_8[2];
static unsigned char reg_9[2];
static unsigned char reg_a[2];
static unsigned char reg_b[2];
static unsigned char reg_c[2];
static unsigned char reg_d[2];
static unsigned char reg_e[2];
static unsigned char reg_f[2];

// External Constant Coefficient Memory

static unsigned int mem_const[256];

// External Instruction Memory

static unsigned int mem_instr[256];

// Constant Memory Initialization

void init_mem_const() {
  mem_const[0] = 0x00CD;      /* 0.8 ~= 0000000011001101 */
  mem_const[1] = 0x0034;      /* 0.2 ~= 0000000000110100 */
}

// Instruction Memory Initialization

void init_mem_instr() {
  /*
    Register Usage:
      Register 1 : Filter input.
      Register 2 : State and filter output.
      Register 3 : Multiplication constant operand.
      Register 4 : Multiplication accumulator.

    Algorithm:
      1. Multiply y(k-1) * 0.8
         1. Load 0.0 to Reg4
         2. Load 0.8 to Reg3
         3. Multiply (Repeated ShiftRight, AddCond, and ShiftLeft)
         4. Normalize (Repeated ShiftLeft)
         5. Limit Reg4 to Reg2

      2. Multiply x(k) * 0.2
         1. Load 0.0 to Reg4
         2. Load 0.2 to Reg3
         3. Multiply (Repeated ShiftRight, AddCond, and ShiftLeft)
         4. Normalize (Repeated ShiftLeft)

      3. Add (x(k)*0.2) + (y(k-1)*0.8) 
         1. Add Reg4 and Reg2 to Reg2
         2. Limit Reg2 to Reg2
  */

  int i = 0;

  mem_instr[i++] = 0x0004;  // ShiftLeft  r0, r4      -- Load 0.0 to r4.
  mem_instr[i++] = 0x7003;  // Constant   #0, r3      -- Load 0.8 to r3.

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3      -- Shift lsb into Flag.
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4  -- Conditional add basic on Flag.
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2      -- Shift operand left and repeat...
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4
  mem_instr[i++] = 0x0202;  // ShiftLeft  r2, r2
  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4424;  // AddCond    r4, r2, r4

  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4      -- Normalize the mulitplication result.
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x2402;  // Limit      r4, r2      -- Limit and move result to r2.

  mem_instr[i++] = 0x0004;  // ShiftLeft  r0, r4      -- Load 0.0 to r4.
  mem_instr[i++] = 0x7013;  // Constant   #1, r3      -- Load 0.2 to r3.

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3      -- Shift lsb into Flag.
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4  -- Conditional add basic on Flag.
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1      -- Shift operand left and repeat...

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4
  mem_instr[i++] = 0x0101;  // ShiftLeft  r1, r1

  mem_instr[i++] = 0x1303;  // ShiftRight r3, r3
  mem_instr[i++] = 0x4414;  // AddCond    r4, r1, r4

  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4      -- Normalize the mulitplication result.
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x1404;  // ShiftRight r4, r4
  mem_instr[i++] = 0x3422;  // Add        r4, r2, r2  -- Add the 2 multiplication results.
  mem_instr[i++] = 0x2202;  // Limit      r2, r2      -- Limit the addition result.

  mem_instr[i++] = 0x8000;  // Halt                   -- Halt the cycle.

}

// Initialize simulation.

void sim_init() {
  // Init memories.
  init_mem_const();
  init_mem_instr();

  // Clear input data.
  reset[0] = 0;
  cycle[0] = 0;
  instr_data[1] = 0; instr_data[0] = 0;
  const_data[1] = 0; const_data[0] = 0;
  load_write[0] = 0;
  load_addr[0] = 0;
  load_data[1] = 0; load_data[0] = 0;

  // Bind ports.
  cf_ssp_16_8_ports(reset, cycle, instr_data, const_data, load_write, load_addr, load_data,
                    done, instr_addr, const_addr,
                    reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7,
                    reg_8, reg_9, reg_a, reg_b, reg_c, reg_d, reg_e, reg_f);

  // Init model and VCD recording.
  cf_ssp_16_8_sim_init("cf_ssp_16_8.vcd");
}

// End simulation.

void sim_end() {
  // End VCD recording.
  cf_ssp_16_8_sim_end();
}

// Cycle simulation.

void sim_cycle() {
  cf_ssp_16_8_calc();
  cf_ssp_16_8_sim_sample();
  cf_ssp_16_8_cycle_clock();
  // Fetch instruction from instruction memory.
  instr_data[0] = (unsigned char) (mem_instr[instr_addr[0]] & 0xFF);
  instr_data[1] = (unsigned char) (mem_instr[instr_addr[0]] >> 8 & 0xFF);
  // Fetch constant from constant memory.
  const_data[0] = (unsigned char) (mem_const[const_addr[0]] & 0xFF);
  const_data[1] = (unsigned char) (mem_const[const_addr[0]] >> 8 & 0xFF);
}

// Reset Processor

void processor_reset() {
  reset[0] = 1;
  sim_cycle();
  reset[0] = 0;
}

// Cycle Processor

void processor_cycle(int input) {
  int output;

  // Load input into register 1.
  load_write[0] = 1;
  load_addr[0] = 1;
  load_data[1] = input & 128 ? 0xFF : 0x00;
  load_data[0] = (unsigned char) (input & 0xFF);
  sim_cycle();

  // Signal processor to start cycle.
  load_write[0] = 0;
  cycle[0] = 1;
  sim_cycle();
  cycle[0] = 0;
  sim_cycle();

  // Cycle processor until done.
  while (!done[0]) sim_cycle();

  output = (int) reg_2[1] << 8 | (int) reg_2[0];

  printf("Input: %6d  Output: %6d\n", input, output);
}


int main(int argc, char *argv[]) {
  sim_init();
  processor_reset();
  processor_cycle(0);
  processor_cycle(0);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  processor_cycle(64);
  sim_end();
  return 0;
}

