/*
 * Test application for I2CMST
 *
 * Copyright (c) 2008 Gaisler Research AB
 *
 * This test requires that the I2C bus is pulled HIGH and
 * that a memory model with address 0x50 is attached to the
 * bus. The prescale register is by default set to 0x0003
 * which means that correct I2C timing will likely not be
 * attained.
 *
 */

#include "testmod.h"

/* Register fields */
/* Control register */
#define CTR_EN  (1 << 7)  /* Enable core */
#define CTR_IEN (1 << 6)  /* Interrupt enable */
/* Command register */
#define CR_STA (1 << 7)   /* Generate start condition */
#define CR_STO (1 << 6)   /* Generate stop condition */
#define CR_RD  (1 << 5)   /* Read from slave */
#define CR_WR  (1 << 4)   /* Write to slave */
#define CR_ACK (1 << 3)   /* ACK, when a receiver send ACK (ACK = 0) 
			     or NACK (ACK = 1) */
#define CR_IACK (1 << 0)  /* Interrupt acknowledge */
/* Status register */
#define SR_RXACK (1 << 7) /* Receibed acknowledge from slave */
#define SR_BUSY  (1 << 6) /* I2C bus busy */
#define SR_AL    (1 << 5) /* Arbitration lost */
#define SR_TIP   (1 << 1) /* Transfer in progress */
#define SR_IF    (1 << 0) /* Interrupt flag */

/* Reset values */
#define PRER_RESVAL 0xffff
#define CTR_RESVAL  0
#define RXR_RESVAL  0
#define SR_RESVAL   0

#define PRESCALER   0x0003

#define I2CMEM_ADDR 0x50
#define TEST_DATA   0x55

struct i2cmstregs {
  volatile unsigned int prer;
  volatile unsigned int ctr;
  volatile unsigned int xr;
  volatile unsigned int csr;
};

/*
 * i2cmst_test(int addr)
 *
 * Checks register reset values
 * Writes one byte and then reads it back.
 *
 */
int i2cmst_test(int addr)
{
  int i;

  struct i2cmstregs *regs;

  report_device(0x01028000);
  report_subtest(1);
  
  /* Check register reset values */
  if (regs->prer != PRER_RESVAL)
    fail(0);

  if (regs->ctr != CTR_RESVAL)
    fail(1);

  if (regs->xr != RXR_RESVAL)
    fail(2);

  if (regs->csr != SR_RESVAL)
    fail(3);
  
  report_subtest(2);

  regs->prer = PRESCALER;

  regs->ctr = CTR_EN;

  for (i = 0; i < 6; i++) {
    switch(i) {
    case 0:
      /* Address memory */
      regs->xr = I2CMEM_ADDR << 1;
      regs->csr = CR_STA | CR_WR;
      break;
    case 1:
      /* Select memory position 0 */
      regs->xr = 0;
      regs->csr = CR_WR;
      break;
    case 2:
      /* Write data to position 0 */
      regs->xr = TEST_DATA;
      regs->csr = CR_WR | CR_STO;
      break;
    case 3:
      /* Address memory */
      regs->xr = I2CMEM_ADDR << 1;
      regs->csr = CR_STA | CR_WR;
      break;
    case 4:
      /* Select memory position 0 */
      regs->xr = 0;
      regs->csr = CR_WR;
      break;
    case 5:
      /* Address memory for reading */
      regs->xr = (I2CMEM_ADDR << 1) | 1;
      regs->csr = CR_STA | CR_WR;
      break;
    default: 
      break;
    }

    while (regs->csr & SR_TIP)
      ;

    if (regs->csr & SR_RXACK) {
      fail(4+i);
      goto i2cmstfail;
    }
    if (regs->csr & SR_AL) {
      fail(9+i);
      goto i2cmstfail;
    }
  }
  
  /* Read from memory and NAK*/
  regs->csr = CR_RD | CR_STO | CR_ACK;

  while (regs->csr & SR_TIP)
    ;
  
  if (regs->xr != TEST_DATA)
    fail(15);

 i2cmstfail:

  regs->ctr = 0;

  return 0;

}
