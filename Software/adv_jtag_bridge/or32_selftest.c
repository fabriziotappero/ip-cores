/* or32_selftest.c -- JTAG protocol bridge between GDB and Advanced debug module.
   Copyright(C) 2001 Marko Mlinar, markom@opencores.org
   Code for TCP/IP copied from gdb, by Chris Ziomkowski
   Refactoring and USB support by Nathan Yawn, (C) 2008-2010
   
   This file contains functions which perform high-level transactions
   on a JTAG chain and debug unit, such as setting a value in the TAP IR
   or doing a burst write through the wishbone module of the debug unit.
   It uses the protocol for the Advanced Debug Interface (adv_dbg_if).
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. 
*/


#include <stdio.h>
#include <stdlib.h>  // for exit()
#include <stdint.h>

#include "or32_selftest.h"
#include "dbg_api.h"
#include "errcodes.h"


// Define your system parameters here
//#define HAS_CPU1  // stall cpu1 (as well as cpu0)
//#define HAS_MEMORY_CONTROLLER // init the SDRAM controller
#define MC_BASE_ADDR     0x93000000
#define SDRAM_BASE       0x00000000
//#define SDRAM_SIZE       0x04000000
#define SDRAM_SIZE 0x400
#define SRAM_BASE        0x00000000
#define SRAM_SIZE        0x04000000
#define FLASH_BASE_ADDR  0xf0000000

// Define the tests to be performed here
#define TEST_SRAM
//#define TEST_SDRAM
#define TEST_OR1K
//#define TEST_8051  // run a test on an 8051 on CPU1


// Defines which depend on user-defined values, don't change these
#define FLASH_BAR_VAL    FLASH_BASE_ADDR
#define SDRAM_BASE_ADDR  SDRAM_BASE
#define SDRAM_BAR_VAL    SDRAM_BASE_ADDR
#define SDRAM_AMR_VAL    (~(SDRAM_SIZE -1))

#define CHECK(x) check(__FILE__, __LINE__, (x))
void check(char *fn, int l, int i);

void check(char *fn, int l, int i) {
  if (i != 0) {
    fprintf(stderr, "%s:%d: Jtag error %d occured; exiting.\n", fn, l, i);
    exit(1);
  }
}


////////////////////////////////////////////////////////////
// Self-test functions
///////////////////////////////////////////////////////////
int dbg_test() 
{
  int success;

  success = stall_cpus();
  if(success == APP_ERR_NONE) {

#ifdef HAS_MEMORY_CONTROLLER
    // Init the memory contloller
    init_mc();
    // Init the SRAM addresses in the MC
    init_sram();
#endif



#ifdef TEST_SDRAM
    success |= test_sdram();
    success |= test_sdram_2();
#endif

#ifdef TEST_SRAM
    success |= test_sram();
#endif
  
#ifdef TEST_OR1K
    success |= test_or1k_cpu0();
#endif

#if ((defined TEST_8051) && (defined HAS_CPU1)) 
    success |= test_8051_cpu1();
#endif

    return success;
  }

  return APP_ERR_TEST_FAIL;
}


int stall_cpus(void) 
{
  unsigned char stalled;

#ifdef HAS_CPU1
  printf("Stall 8051 - ");
  CHECK(dbg_cpu1_write_reg(0, 0x01)); // stall 8051
#endif

  printf("Stall or1k - ");
  CHECK(dbg_cpu0_write_ctrl(0, 0x01));      // stall or1k


#ifdef HAS_CPU1
  CHECK(dbg_cpu1_read_ctrl(0, &stalled));
  if (!(stalled & 0x1)) {
    printf("8051 is not stalled!\n");   // check stall 8051
    return APP_ERR_TEST_FAIL;
  }
#endif

  CHECK(dbg_cpu0_read_ctrl(0, &stalled));
  if (!(stalled & 0x1)) {
    printf("or1k is not stalled!\n");   // check stall or1k
    return APP_ERR_TEST_FAIL;
  }

  printf("CPU(s) stalled.\n");

  return APP_ERR_NONE;
}


void init_mc(void)
{
  uint32_t insn;

  printf("Initialize Memory Controller (SDRAM)\n");
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_BAR_0, FLASH_BAR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_AMR_0, FLASH_AMR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_WTR_0, FLASH_WTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RTR_0, FLASH_RTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x40000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_BAR_4, SDRAM_BAR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_AMR_4, SDRAM_AMR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_CCR_4, 0x00bf0005));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RATR, SDRAM_RATR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RCDR, SDRAM_RCDR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RCTR, SDRAM_RCTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_REFCTR, SDRAM_REFCTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_PTR, SDRAM_PTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RRDR, SDRAM_RRDR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RIR, SDRAM_RIR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x5e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x5e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x7e000033));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x7e000033));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_CCR_4, 0xc0bf0005));
  
  CHECK(dbg_wb_read32(MC_BASE_ADDR+MC_CCR_4, &insn));
  printf("expected %x, read %x\n", 0xc0bf0005, insn);
}


void init_sram(void)
{
  // SRAM initialized to 0x40000000
  printf("Initialize Memory Controller (SRAM)\n");
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_BAR_1, SRAM_BASE & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_AMR_1, ~(SRAM_SIZE - 1) & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_CCR_1, 0xc020001f));
}



int test_sdram(void) 
{
  uint32_t insn;
  unsigned long i;
  uint32_t data4_out[0x08];
  uint32_t data4_in[0x08];
  uint16_t data2_out[0x10];
  uint16_t data2_in[0x10];
  uint8_t data1_out[0x20];
  uint8_t data1_in[0x20];
          
  printf("Start SDRAM WR\n");
  for (i=0x10; i<(SDRAM_SIZE+SDRAM_BASE); i=i<<1) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+i, i);
    CHECK(dbg_wb_write32(SDRAM_BASE+i, i));
  }
  
  printf("Start SDRAM RD\n");
  for (i=0x10; i<(SDRAM_SIZE+SDRAM_BASE); i=i<<1) {
    CHECK(dbg_wb_read32(SDRAM_BASE+i, &insn));
    //printf("0x%x: 0x%x\n", SDRAM_BASE+i, insn);
    if (i != insn) {
      printf("SDRAM test FAIL\n");
      return APP_ERR_TEST_FAIL;
    }
  }

  printf("32-bit block write from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  for (i=0; i<(0x20/4); i++) {
    data4_out[i] = data4_in[i] = ((4*i+3)<<24) | ((4*i+2)<<16) | ((4*i+1)<<8) | (4*i);
    //printf("data_out = %0x\n", data4_out[i]);
  }
    
  //printf("Press a key for write\n"); getchar();
  CHECK(dbg_wb_write_block32(SDRAM_BASE, &data4_out[0], 0x20));

  // 32-bit block read is used for checking
  printf("32-bit block read from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  CHECK(dbg_wb_read_block32(SDRAM_BASE, &data4_out[0], 0x20));
  for (i=0; i<(0x20/4); i++) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+(i*4), data_out[i]);
    if (data4_in[i] != data4_out[i]) {
      printf("SDRAM data differs. Expected: 0x%0x, read: 0x%0x\n", data4_in[i], data4_out[i]);
      return APP_ERR_TEST_FAIL;
    }
  }

 
  printf("16-bit block write from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  for (i=0; i<(0x20/2); i++) {
    data2_out[i] = data2_in[i] = ((4*i+1)<<8) | (4*i);
    //printf("data_out = %0x\n", data_out[i]);
  }
  CHECK(dbg_wb_write_block16(SDRAM_BASE, &data2_out[0], 0x20));

  // 16-bit block read is used for checking
  printf("16-bit block read from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  CHECK(dbg_wb_read_block16(SDRAM_BASE, &data2_out[0], 0x20));
  for (i=0; i<(0x20/2); i++) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+(i*4), data_out[i]);
    if (data2_in[i] != data2_out[i]) {
      printf("SDRAM data differs. Expected: 0x%0x, read: 0x%0x\n", data2_in[i], data2_out[i]);
      return APP_ERR_TEST_FAIL;
    }
  }

  printf("8-bit block write from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  for (i=0; i<(0x20/1); i++) {
    data1_out[i] = data1_in[i] = (4*i);
    //printf("data_out = %0x\n", data_out[i]);
  }
  CHECK(dbg_wb_write_block8(SDRAM_BASE, &data1_out[0], 0x20));

  // 32-bit block read is used for checking
  printf("8-bit block read from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  CHECK(dbg_wb_read_block8(SDRAM_BASE, &data1_out[0], 0x20));
  for (i=0; i<(0x20/1); i++) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+(i*4), data_out[i]);
    if (data1_in[i] != data1_out[i]) {
      printf("SDRAM data differs. Expected: 0x%0x, read: 0x%0x\n", data1_in[i], data1_out[i]);
      return APP_ERR_TEST_FAIL;
    }
  }

  printf("SDRAM OK!\n");
  return APP_ERR_NONE;
}


int test_sdram_2(void)
{
  uint32_t insn;

  printf("SDRAM test 2: \n");
  CHECK(dbg_wb_write32(SDRAM_BASE+0x00, 0x12345678));
  CHECK(dbg_wb_read32(SDRAM_BASE+0x00, &insn));
  printf("expected %x, read %x\n", 0x12345678, insn);
  if (insn != 0x12345678) return APP_ERR_TEST_FAIL;
  
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0000, 0x11112222));
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0000, &insn));
  printf("expected %x, read %x\n", 0x11112222, insn);
  if (insn != 0x11112222) return APP_ERR_TEST_FAIL;

  CHECK(dbg_wb_write32(SDRAM_BASE+0x0004, 0x33334444));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0008, 0x55556666));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x000c, 0x77778888));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0010, 0x9999aaaa));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0014, 0xbbbbcccc));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0018, 0xddddeeee));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x001c, 0xffff0000));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0020, 0xdeadbeef));
  
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0000, &insn));
  printf("expected %x, read %x\n", 0x11112222, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0004, &insn));
  printf("expected %x, read %x\n", 0x33334444, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0008, &insn));
  printf("expected %x, read %x\n", 0x55556666, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x000c, &insn));
  printf("expected %x, read %x\n", 0x77778888, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0010, &insn));
  printf("expected %x, read %x\n", 0x9999aaaa, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0014, &insn));
  printf("expected %x, read %x\n", 0xbbbbcccc, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0018, &insn));
  printf("expected %x, read %x\n", 0xddddeeee, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x001c, &insn));
  printf("expected %x, read %x\n", 0xffff0000, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0020, &insn));
  printf("expected %x, read %x\n", 0xdeadbeef, insn);
    
  if (insn != 0xdeadbeef) {
    printf("SDRAM test 2 FAILED\n");
    return APP_ERR_TEST_FAIL;
  }
    else
    printf("SDRAM test 2 passed\n");

  return APP_ERR_NONE;
}


int test_sram(void)
{
  //unsigned long insn;
  uint32_t ins;
  uint32_t insn[9];
  insn[0] = 0x11112222;
  insn[1] = 0x33334444;
  insn[2] = 0x55556666;
  insn[3] = 0x77778888;
  insn[4] = 0x9999aaaa;
  insn[5] = 0xbbbbcccc;
  insn[6] = 0xddddeeee;
  insn[7] = 0xffff0000;
  insn[8] = 0xdedababa;

  printf("SRAM test: \n");
  //dbg_wb_write_block32(0x0, insn, 9);
  
  CHECK(dbg_wb_write32(SRAM_BASE+0x0000, 0x11112222));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0004, 0x33334444));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0008, 0x55556666));
  CHECK(dbg_wb_write32(SRAM_BASE+0x000c, 0x77778888));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0010, 0x9999aaaa));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0014, 0xbbbbcccc));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0018, 0xddddeeee));
  CHECK(dbg_wb_write32(SRAM_BASE+0x001c, 0xffff0000));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0020, 0xdedababa));
  

  CHECK(dbg_wb_read32(SRAM_BASE+0x0000, &ins));
  printf("expected %x, read %x\n", 0x11112222, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0004, &ins));
  printf("expected %x, read %x\n", 0x33334444, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0008, &ins));
  printf("expected %x, read %x\n", 0x55556666, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x000c, &ins));
  printf("expected %x, read %x\n", 0x77778888, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0010, &ins));
  printf("expected %x, read %x\n", 0x9999aaaa, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0014, &ins));
  printf("expected %x, read %x\n", 0xbbbbcccc, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0018, &ins));
  printf("expected %x, read %x\n", 0xddddeeee, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x001c, &ins));
  printf("expected %x, read %x\n", 0xffff0000, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0020, &ins));
  printf("expected %x, read %x\n", 0xdedababa, ins);
 
  if (ins != 0xdedababa) {
    printf("SRAM test failed!!!\n");
    return APP_ERR_TEST_FAIL;
  }
    else
    printf("SRAM test passed\n");

  return APP_ERR_NONE;
}



int test_or1k_cpu0(void)
{
  uint32_t npc, ppc, r1, insn;
  uint8_t stalled;
  uint32_t result;
  int i;

  printf("Testing CPU0 (or1k) - writing instructions\n");
  CHECK(dbg_wb_write32(SDRAM_BASE+0x00, 0xe0000005));   /* l.xor   r0,r0,r0   */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x04, 0x9c200000));   /* l.addi  r1,r0,0x0  */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x08, 0x18400000));   /* l.movhi r2,0x0000  */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0c, 0xa8420030));   /* l.ori   r2,r2,0x30 */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x10, 0x9c210001));   /* l.addi  r1,r1,1    */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x14, 0x9c210001));   /* l.addi  r1,r1,1    */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x18, 0xd4020800));   /* l.sw    0(r2),r1   */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x1c, 0x9c210001));   /* l.addi  r1,r1,1    */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x20, 0x84620000));   /* l.lwz   r3,0(r2)   */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x24, 0x03fffffb));   /* l.j     loop2      */
  CHECK(dbg_wb_write32(SDRAM_BASE+0x28, 0xe0211800));   /* l.add   r1,r1,r3   */

  printf("Setting up CPU0\n");
  CHECK(dbg_cpu0_write((0 << 11) + 17, 0x01));  /* Enable exceptions */
  CHECK(dbg_cpu0_write((6 << 11) + 20, 0x2000));  /* Trap causes stall */
  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE));  /* Set PC */
  CHECK(dbg_cpu0_write((6 << 11) + 16, 1 << 22));  /* Set step bit */
  printf("Starting CPU0!\n");
  for(i = 0; i < 11; i++) {
    CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* 11x Unstall */
    //printf("Starting CPU, waiting for trap...\n");
    do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
    //printf("Got trap.\n");
  }

  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000010, 0x00000028, 5);
  result = npc + ppc + r1;
  
  CHECK(dbg_cpu0_write((6 << 11) + 16, 0));  // Reset step bit 
  CHECK(dbg_wb_read32(SDRAM_BASE + 0x28, &insn));  // Set trap insn in delay slot 
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x28, 0x21000001));
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  // Unstall 
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  // Read NPC 
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  // Read PPC 
  CHECK(dbg_cpu0_read(0x401, &r1));  // Read R1 
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x28, insn));  // Set back original insn 
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000010, 0x00000028, 8);
  result = npc + ppc + r1 + result;

  CHECK(dbg_wb_read32(SDRAM_BASE + 0x24, &insn));  // Set trap insn in place of branch insn 
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x24, 0x21000001));
  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x10));  // Set PC 
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  // Unstall 
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  // Read NPC 
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  // Read PPC 
  CHECK(dbg_cpu0_read(0x401, &r1));  // Read R1 
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x24, insn));  // Set back original insn 
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000028, 0x00000024, 11);
  result = npc + ppc + r1 + result;
  
  CHECK(dbg_wb_read32(SDRAM_BASE + 0x20, &insn));  /* Set trap insn before branch insn */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x20, 0x21000001));
  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x24));  /* Set PC */
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x20, insn));  /* Set back original insn */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000024, 0x00000020, 24);
  result = npc + ppc + r1 + result;

  CHECK(dbg_wb_read32(SDRAM_BASE + 0x1c, &insn));  /* Set trap insn behind lsu insn */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x1c, 0x21000001));
  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x20));  /* Set PC */
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x1c, insn));  /* Set back original insn */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000020, 0x0000001c, 49);
  result = npc + ppc + r1 + result;

  CHECK(dbg_wb_read32(SDRAM_BASE + 0x20, &insn));  /* Set trap insn very near previous one */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x20, 0x21000001));
  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x1c));  /* Set PC */
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x20, insn));  /* Set back original insn */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000024, 0x00000020, 50);
  result = npc + ppc + r1 + result;

  CHECK(dbg_wb_read32(SDRAM_BASE + 0x10, &insn));  /* Set trap insn to the start */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x10, 0x21000001));
  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x20)  /* Set PC */);
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  CHECK(dbg_wb_write32(SDRAM_BASE + 0x10, insn));  /* Set back original insn */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000014, 0x00000010, 99);
  result = npc + ppc + r1 + result;

  CHECK(dbg_cpu0_write((6 << 11) + 16, 1 << 22));  /* Set step bit */
  for(i = 0; i < 5; i++) {
    CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
    //printf("Waiting for trap...");
    do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
    //printf("got trap.\n");
  }
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000028, 0x00000024, 101);
  result = npc + ppc + r1 + result;

  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x24));  /* Set PC */
  for(i = 0; i < 2; i++) {
    CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
    //printf("Waiting for trap...\n");
    do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
    //printf("Got trap.\n");
  }
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000010, 0x00000028, 201);
  result = npc + ppc + r1 + result;
  printf("result = %.8x\n", result ^ 0xdeaddae1);

  if((result ^ 0xdeaddae1) != 0xdeaddead)
    return APP_ERR_TEST_FAIL;

  return APP_ERR_NONE;
}


// This function does not currently return a useful value
/*
unsigned char test_8051_cpu1(void)
{
  int retval = 1;
  unsigned long result = 0;
    unsigned long npc[3], tmp;

    printf("Testing CPU1 (8051)\n");

    // WRITE ACC
    CHECK(dbg_cpu1_write(0x20e0, 0xa6));

    // READ ACC
    CHECK(dbg_cpu1_read(0x20e0, &tmp));   // select SFR space
    printf("Read  8051   ACC = %0x (expected a6)\n", tmp);
    result = result + tmp;

    // set exception to single step to jump over a loop
    CHECK(dbg_cpu1_write(0x3010, 0xa0)); // set single step and global enable in EER
    CHECK(dbg_cpu1_write(0x3011, 0x40)); // set evec = 24'h000040
    CHECK(dbg_cpu1_write(0x3012, 0x00)); // (already reset value)
    CHECK(dbg_cpu1_write(0x3013, 0x00)); // (already reset value)

    // set HW breakpoint at PC == 0x41
    CHECK(dbg_cpu1_write(0x3020, 0x41)); // DVR0 = 24'h000041
    CHECK(dbg_cpu1_write(0x3023, 0x39)); // DCR0 = valid, == PC
    CHECK(dbg_cpu1_write(0x3001, 0x04)); // DSR = watchpoint

    // flush 8051 instruction cache
    CHECK(dbg_cpu1_write(0x209f, 0x00));

    // Put some instructions in ram (8-bit mode on wishbone)
    CHECK(dbg_wb_write8 (0x40, 0x04));  // inc a
    CHECK(dbg_wb_write8 (0x41, 0x03));  // rr a;
    CHECK(dbg_wb_write8 (0x42, 0x14));  // dec a; 
    CHECK(dbg_wb_write8 (0x43, 0xf5));  // mov 0e5h, a;
    CHECK(dbg_wb_write8 (0x44, 0xe5));

    // unstall just 8051
    CHECK(dbg_cpu1_write_reg(0, 0));

    // read PC
    CHECK(dbg_cpu1_read(0, &npc[0]));
    CHECK(dbg_cpu1_read(1, &npc[1]));
    CHECK(dbg_cpu1_read(2, &npc[2]));
    printf("Read  8051   npc = %02x%02x%02x (expected 41)\n", npc[2], npc[1], npc[0]);
    result = result + (npc[2] << 16) + (npc[1] << 8) + npc[0];

    // READ ACC
    CHECK(dbg_cpu1_read(0x20e0, &tmp));   // select SFR space
    printf("Read  8051   ACC = %0x (expected a7)\n", tmp);
    result = result + tmp;

    // set sigle step to stop execution
    CHECK(dbg_cpu1_write(0x3001, 0x20)); // set single step and global enable in DSR

    // clear DRR
    CHECK(dbg_cpu1_write(0x3000, 0x00)); // set single step and global enable in DRR

    // unstall just 8051
    CHECK(dbg_cpu1_write_reg(0, 0));

    // read PC
    CHECK(dbg_cpu1_read(0, &npc[0]));
    CHECK(dbg_cpu1_read(1, &npc[1]));
    CHECK(dbg_cpu1_read(2, &npc[2]));
    printf("Read  8051   npc = %02x%02x%02x (expected 42)\n", npc[2], npc[1], npc[0]);
    result = result + (npc[2] << 16) + (npc[1] << 8) + npc[0];

    // READ ACC
    CHECK(dbg_cpu1_read(0x20e0, &tmp));   // select SFR space
    printf("Read  8051   ACC = %0x (expected d3)\n", tmp);
    result = result + tmp;

    printf("report (%x)\n", result ^ 0x6c1 ^ 0xdeaddead);
  
    return APP_ERR_NONE;
}
*/
