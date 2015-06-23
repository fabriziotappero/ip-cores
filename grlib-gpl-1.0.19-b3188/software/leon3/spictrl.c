/*
 * Simple loopback test for SPICTRL 
 *
 * Copyright (c) 2008 Gaisler Research AB
 *
 * This test requires that the SPISEL input is HIGH
 *
 */

#include "testmod.h"

/* Register offsets */
#define SPIC_CAP_OFF    0x00
#define SPIC_MODE_OFF   0x20

/* Register fields */
/* Mode register */
#define SPIC_LOOP (1 << 30)
#define SPIC_CPOL (1 << 29)
#define SPIC_CPHA (1 << 28)
#define SPIC_DIV16 (1 << 27)
#define SPIC_REV (1 << 26)
#define SPIC_MS (1 << 25)
#define SPIC_EN (1 << 24)
#define SPIC_LEN 20
#define SPIC_PM 16
#define SPIC_CG 7
/* Event and Mask registers */
#define SPIC_LT (1 << 14)
#define SPIC_OV (1 << 12)
#define SPIC_UN (1 << 11)
#define SPIC_MME (1 << 10)
#define SPIC_NE (1 << 9)
#define SPIC_NF (1 << 8)
/* Command register */
#define SPIC_LST (1 << 22)

/* Reset values */
#define MODE_RESVAL  0
#define EVENT_RESVAL 0
#define MASK_RESVAL  0
#define CMD_RESVAL   0
#define TD_RESVAL    0

struct spictrlregs {
  volatile unsigned int mode;
  volatile unsigned int event;
  volatile unsigned int mask;
  volatile unsigned int com;
  volatile unsigned int td;
  volatile unsigned int rd;
  /* volatile unsigned int slvsel; */
};

/*
 * spictrl_test(int addr)
 *
 * Writes fifo depth + 1 words in loopback mode. Writes
 * one more word and checks LT and OV status
 *
 */
int spictrl_test(int addr)
{
  int i;
  int data;
  int fdepth;
  
  
  volatile unsigned int *capreg;
  struct spictrlregs *regs;
  

  report_device(0x0102D000);

  capreg = (int*)addr;
  regs = (struct spictrlregs*)(addr + SPIC_MODE_OFF);

  report_subtest(1);

  /*
   * Check register reset values
   */
  if (regs->mode != MODE_RESVAL)
    fail(0);
  if (regs->event != EVENT_RESVAL)
    fail(1);
  if (regs->mask != MASK_RESVAL)
    fail(2);
  if (regs->com != CMD_RESVAL)
    fail(3);
  if (regs->td != TD_RESVAL)
    fail(4);
  /* RD register is not reset and therefore not read */

  report_subtest(2);

  /* 
   * Configure core in loopback and write FIFO depth + 1
   * words
   */
  fdepth = (*capreg >> 8) & 0xff;

  regs->mode = SPIC_LOOP | SPIC_MS | SPIC_EN;

  /* Check event bits */
  if (regs->event & SPIC_LT)
    fail(5);
  if (regs->event & SPIC_OV)
    fail(6);
  if (regs->event & SPIC_UN)
    fail(7);
  if (regs->event & SPIC_MME)
    fail(8);
  if (regs->event & SPIC_NE)
    fail(9);
  if (!(regs->event & SPIC_NF))
    fail(10);
     
  data = 0xaaaaaaaa;
  for (i = 0; i <= fdepth; i++) {
    regs->td = data;
    data = ~data;
  }
  
  /* Multiple master error */
  if (regs->event & SPIC_MME) 
    fail(11);

  /* Wait for first word to be transferred */
  while (!(regs->event & SPIC_NF))
    ;

  if (!(regs->event & SPIC_NE))
    fail(12);

  /* Write one more word to trigger overflow, set LST */
  regs->td = data;
  regs->com = SPIC_LST;

  while (!(regs->event & SPIC_LT))
    ;

  if (!(regs->event & SPIC_OV))
    fail(13);

  /* Verify that words transferred correctly */
  data = 0xaaaaaaaa;
  for (i = 0; i <= fdepth; i++) {
    if (regs->rd != data)
      fail(14+7);
    data = ~data;
  }
    
  /* Deactivate core */
  regs->mode = 0;

  return 0;
}
