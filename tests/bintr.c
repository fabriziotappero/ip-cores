#include "tv80_env.h"

/*
 * This test covers interrupt handling routines.  The actual interrupt code
 * is in assembly, in bintr_crt0.asm.
 *
 * The test generates five interrupts, and clears the interrupt after
 * each one.
 *
 * The isr routine uses the two writes to intr_cntdwn to first clear
 * assertion of the current interrupt and then disable the countdown
 * timer.
 */

unsigned char foo;
volatile unsigned char test_pass;
static unsigned char triggers;
int phase;
int loop;
char done;
char nmi_trig;

void nmi_isr (void)
{
  nmi_trig++;

  switch (phase) {
    // nmi test
  case 1 :
    if (nmi_trig > 5) {
      phase += 1;
      nmi_trig = 0;
      //intr_cntdwn = 255;
      //intr_cntdwn = 0;
      print ("Final interrupt\n");
      intr_cntdwn = 32;
      nmi_cntdwn = 0;
    } else
      nmi_cntdwn = 32;
    break;
  }
}

void isr (void)
{
  triggers++;

  switch (phase) {
    // int test
  case 0 :
    if (triggers > 5) {
      phase += 1;
      triggers = 0;
      intr_cntdwn = 0;
      print ("Starting NMIs\n");
      nmi_cntdwn = 64;
    } else {
      intr_cntdwn = 32;
      
    }
    break;


  case 2 :
    intr_cntdwn = 0;
    test_pass = 1;
    break;
  }
}

int main ()
{
  //int i;
  unsigned char check;

  test_pass = 0;
  triggers = 0;
  nmi_trig = 0;

  phase = 0;

  // start interrupt countdown
  print ("Starting interrupts\n");
  intr_cntdwn = 64;
  set_timeout (50000);

  for (loop=0; loop<1024; loop++) {
    if (test_pass)
      break;
    check = sim_ctl_port;
  }

  if (test_pass)
    sim_ctl (SC_TEST_PASSED);
  else
    sim_ctl (SC_TEST_FAILED);

  return 0;
}

