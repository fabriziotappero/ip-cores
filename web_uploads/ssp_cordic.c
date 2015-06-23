/*

Copyright (c) 2003 Launchbird Design Systems, Inc.

C test bench for State Space Processor.
Demonstrates a vectoring cordic.

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

  // Cordic atan factors:

  mem_const[0x00] = 0x2000;  // Cordic atan factor for stage 0.  0010000000000000
  mem_const[0x01] = 0x12E4;  // Cordic atan factor for stage 1.  0001001011100100
  mem_const[0x02] = 0x09FB;  // Cordic atan factor for stage 2.  0000100111111011
  mem_const[0x03] = 0x0511;  // Cordic atan factor for stage 3.  0000010100010001
  mem_const[0x04] = 0x028B;  // Cordic atan factor for stage 4.  0000001010001011
  mem_const[0x05] = 0x0146;  // Cordic atan factor for stage 5.  0000000101000110
  mem_const[0x06] = 0x00A3;  // Cordic atan factor for stage 6.  0000000010100011
  mem_const[0x07] = 0x00A1;  // Cordic atan factor for stage 7.  0000000001010001
  mem_const[0x08] = 0x0029;  // Cordic atan factor for stage 8.  0000000000101001
  mem_const[0x09] = 0x0014;  // Cordic atan factor for stage 9.  0000000000010100
  mem_const[0x0A] = 0x000A;  // Cordic atan factor for stage A.  0000000000001010
  mem_const[0x0B] = 0x0005;  // Cordic atan factor for stage B.  0000000000000101
  mem_const[0x0C] = 0x0003;  // Cordic atan factor for stage C.  0000000000000011
  mem_const[0x0D] = 0x0001;  // Cordic atan factor for stage D.  0000000000000001
  mem_const[0x0E] = 0x0001;  // Cordic atan factor for stage E.  0000000000000001
  mem_const[0x0F] = 0x0000;  // Cordic atan factor for stage F.  0000000000000000

  mem_const[0x10] = 0x8000;  // 180 degrees.

}

// Instruction Memory Initialization

void init_mem_instr() {
  int i = 0;

  // Inputs
  //   r1: real  (cordic x-axis input).
  //   r2: imag  (cordic y-axis input).

  // Cordic Register Usage:
  //   r1: Real input and rcc option.
  //   r2: Imag input and rcc option.
  //   r3: Angle input and rcc option.
  //   r4: Real rc option.
  //   r5: Imag rc option.
  //   r6: Angle rc option.
  //   r7: Shifted real.
  //   r8: Shifted imag.
  //   r9: Atan factor.
  //   rA: Temporary.  Holds input imag for switch comparison.

  // Cordic initial flip stage.
  mem_instr[i++] = 0x5014;  // Sub        r0, r1, r4  -- r4 holds 0 - real.
  mem_instr[i++] = 0x5025;  // Sub        r0, r2, r5  -- r5 holds 0 - imag.
  mem_instr[i++] = 0x0003;  // ShiftLeft  r0, r3      -- Load 0 in angle.
  mem_instr[i++] = 0x7106;  // Constant   #10, r6     -- Load 180 degrees.

  mem_instr[i++] = 0x5100;  // Sub        r1, r0, r9  -- Check if real < 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 0.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x3017;  // Add        r0, r1, r7  -- Move r1 to r7.  Stage 0 does not shift data.
  mem_instr[i++] = 0x3028;  // Add        r0, r2, r8  -- Move r2 to r8.
  mem_instr[i++] = 0x7009;  // Constant   #00, r9     -- Load atan factor 0.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 1.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 1
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 1
  mem_instr[i++] = 0x7019;  // Constant   #01, r9     -- Load atan factor 1.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 2.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 2
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 2
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7029;  // Constant   #02, r9     -- Load atan factor 2.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 3.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 3
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 3
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7039;  // Constant   #03, r9     -- Load atan factor 3.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 4.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 4
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 4
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7049;  // Constant   #04, r9     -- Load atan factor 4.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 5.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 5
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 5
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7059;  // Constant   #05, r9     -- Load atan factor 5.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 6.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 6
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 6
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7069;  // Constant   #06, r9     -- Load atan factor 6.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 7.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 7
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7079;  // Constant   #07, r9     -- Load atan factor 7.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Cordic stage 8.
  mem_instr[i++] = 0x302A;  // Add        r0, r2, rA  -- Save input imag.
  mem_instr[i++] = 0x1107;  // ShiftRight r1, r7      -- ShiftedReal = RealIn >> 8
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1707;  // ShiftRight r7, r7
  mem_instr[i++] = 0x1208;  // ShiftRight r2, r8      -- ShiftedImag = ImagIn >> 8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x1808;  // ShiftRight r8, r8
  mem_instr[i++] = 0x7089;  // Constant   #08, r9     -- Load atan factor 8.

  mem_instr[i++] = 0x3184;  // Add        r1, r8, r4  -- Real options (RealIn +/- ShiftedImag).
  mem_instr[i++] = 0x5181;  // Sub        r1, r8, r1

  mem_instr[i++] = 0x5275;  // Sub        r2, r7, r5  -- Imag options (ImagIn -/+ ShiftedReal).
  mem_instr[i++] = 0x3272;  // Add        r2, r7, r2

  mem_instr[i++] = 0x3396;  // Add        r3, r9, r6  -- Angle options (AngIn +/- AtanFactor).
  mem_instr[i++] = 0x5393;  // Sub        r3, r9, r3

  mem_instr[i++] = 0x50A0;  // Sub        r0, rA, r0  -- Check if imag > 0.
  mem_instr[i++] = 0x6411;  // Switch     r4, r1, r1  -- Select real output.
  mem_instr[i++] = 0x6522;  // Switch     r5, r2, r2  -- Select imag output.
  mem_instr[i++] = 0x6633;  // Switch     r6, r3, r3  -- Select angle output.

  // Halt processor cycle.
  mem_instr[i++] = 0x8000;  // Halt

  printf("Number of Instructions: %d\n", i);

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
  cf_ssp_16_8_sim_init("cf_ssp_cordic.vcd");
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

void processor_cycle(int real, int imag) {
  int real_out, imag_out, angle_out;

  // Load real input into register 1.
  load_write[0] = 1;
  load_addr[0] = 1;
  load_data[0] = (unsigned char) (real & 0xFF);
  load_data[1] = (unsigned char) (real >> 8 & 0xFF);
  sim_cycle();

  // Load imag input into register 2.
  load_write[0] = 1;
  load_addr[0] = 2;
  load_data[0] = (unsigned char) (imag & 0xFF);
  load_data[1] = (unsigned char) (imag >> 8 & 0xFF);
  sim_cycle();

  // Signal processor to start cycle.
  load_write[0] = 0;
  cycle[0] = 1;
  sim_cycle();
  cycle[0] = 0;
  sim_cycle();

  // Cycle processor until done.
  while (!done[0]) sim_cycle();

  // Extract real, imag, and angle results from registers.
  real_out  = (int) reg_1[1] << 8 | (int) reg_1[0];
  imag_out  = (int) reg_2[1] << 8 | (int) reg_2[0];
  angle_out = (int) reg_3[1] << 8 | (int) reg_3[0];

  printf("RealIn: 0x%04X  ImagIn: 0x%04X    RealOut: 0x%04X  ImagOut: 0x%04X  AngleOut: 0x%04X\n", real, imag, real_out, imag_out, angle_out);
}


int main(int argc, char *argv[]) {
  sim_init();
  processor_reset();
  processor_cycle(0x0100, 0x0000);
  processor_cycle(0x0100, 0x0100);
  processor_cycle(0x0000, 0x0100);
  processor_cycle(0xFF00, 0x0100);
  processor_cycle(0xFF00, 0x0000);
  processor_cycle(0xFF00, 0xFF00);
  processor_cycle(0x0000, 0xFF00);
  processor_cycle(0x0100, 0x0000);
  sim_end();
  return 0;
}

