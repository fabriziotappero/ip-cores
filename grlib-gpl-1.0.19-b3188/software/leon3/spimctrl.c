/*
 * Simple loopback test for SPIMCTRL 
 *
 * Copyright (c) 2008 Gaisler Research AB
 *
 * When running this test all core inputs must be 
 * pulled HIGH.
 *
 */

#include "testmod.h"

/* Register fields */
/* Control register */
#define SPIM_CSN  (1 << 3)
#define SPIM_EAS  (1 << 2)
#define SPIM_IEN  (1 << 1)
#define SPIM_USRC (1 << 0)
/* Status register */
#define SPIM_TO   (1 << 4)
#define SPIM_ERR  (1 << 3)
#define SPIM_INIT (1 << 2)
#define SPIM_BUSY (1 << 1)
#define SPIM_DONE (1 << 0)

struct spimctrlregs {
  volatile unsigned int conf;
  volatile unsigned int ctrl;
  volatile unsigned int stat;
  volatile unsigned int rx;
  volatile unsigned int tx;
};

/*
 * spimctrl_test(unsigned int addr)
 *
 * Shifts out 0x5A and verifies that the received data is
 * 0xFF. This test application requires that the core is
 * initialized. 
 *
 */
int spimctrl_test(unsigned int addr)
{
  struct spimctrlregs *regs;
  
  report_device(0x01045000);

  regs = (struct spimctrlregs*)addr;

  report_subtest(1);
  /* Verify that core is initialized and that the other bits have sensible values */
  if (regs->stat & SPIM_TO)
     fail(0);
  if (regs->stat & SPIM_ERR)
     fail(1);
  if (!(regs->stat & SPIM_INIT))
     fail(2);
  if (regs->stat & SPIM_BUSY)
     fail(3);
  if (regs->stat & SPIM_DONE)
     fail(4);
  if (!(regs->ctrl & SPIM_CSN))
     fail(5);
  if (regs->ctrl & SPIM_EAS)
     fail(6);
  if (regs->ctrl & SPIM_IEN)
     fail(7);
  if (regs->ctrl & SPIM_USRC)
     fail(8);
  
  report_subtest(2);
  /* Transfer one byte */
  
  regs->ctrl = SPIM_USRC;

  if (regs->ctrl != SPIM_USRC)
     fail(0);

  regs->tx = 0x5A;

  while (!(regs->stat & (SPIM_DONE | SPIM_ERR)))
     ;

  if (regs->stat & SPIM_ERR)
     fail(1);
  
  regs->stat = SPIM_DONE;

  if (regs->stat != SPIM_INIT)
     fail(2);

  if (regs->rx != 0xFF)
     fail(3);

  regs->ctrl = 0;

  if (regs->ctrl != SPIM_CSN)
     fail(4);

  return 0;
}
