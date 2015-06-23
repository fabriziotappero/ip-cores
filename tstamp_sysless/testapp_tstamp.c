#include "xparameters.h"
#include "xreg405.h"
#include "stdio.h"
#include "xuartns550_l.h"
#include "xutil.h"
#include "xpseudo_asm.h"

/**
   requires following in system.mhs:

   PARAMETER C_APU_CONTROL = 0x1E01
   PARAMETER C_APU_UDI_1 = 0xC07605
**/

//volatile unsigned __attribute__((section(".bram"))) bram[0x1000];
volatile unsigned *bram = (unsigned*)0xcc000000;

int main() {
  char c;
  int a, b, i;

#if 1
  /* initialize caches (I.J.Krakora's warning) */
  XCache_EnableDCache(0x80000001);
  XCache_EnableICache(0x80000001);
#endif

   XUartNs550_SetBaud(XPAR_RS232_UART_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ, 9600);
   XUartNs550_mSetLineControlReg(XPAR_RS232_UART_BASEADDR, XUN_LCR_8_DATA_BITS);
   xil_printf("Zaciname.\r\n");

#if 1
  /* enable APU */
  unsigned int msr_data;
  msr_data = mfmsr();
  msr_data = msr_data | XREG_MSR_APU_AVAILABLE | XREG_MSR_APU_ENABLE;
  mtmsr(msr_data);
#endif
  
  for (i = 0; i < 0x400; i++) {
    if (bram[i] != 0)
      xil_printf("|%02x: 0x%08x\r\n", i, bram[i]);
    bram[i] = 0;
  }

  xil_printf("Go!\r\n");
  for (;;) {
    c = getchar();
    xil_printf("*before\r\n");

    UDI0FCM_IMM_GPR_GPR(0, 0xdeadbeef, b);

    xil_printf("*after\r\n");
    for (i = 0; i < 0x400; i++)
      if (bram[i] != 0)
	xil_printf("%02x: 0x%08x\r\n", i, bram[i]);

    xil_printf("--\r\n");
  }

  return 0;
}
