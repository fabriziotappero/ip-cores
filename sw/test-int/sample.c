#include "openfire.h"

// --- prototypes ---
void interrupt_handler(void) __attribute__((interrupt_handler));

// -------------------------------------
void interrupt_handler(void)
{
   uart1_printchar('.');
}

// -------------------------------------
void main(void)
{
  int n;
  uart1_printline("inicio del test\r\n");
  
  uart1_printline("setting interrupt handler\r\n");
  asm volatile ("la  r6, r0, interrupt_handler	\n\t" \
		"sw  r6, r1, r0			\n\t" \
		"lhu r7, r1, r0			\n\t" \
		"shi r7, r0, 0x12		\n\t" \
		"shi r6, r0, 0x16 		\n\t" \
		"la  r6, r0, 0x2		\n\t" \
		"mts rmsr, r6			\n\t" );
  
  uart1_printline("configure timer1\r\n");
  *(unsigned long *) TIMER1_PORT = TIMER1_CONTROL | 50000000L;	// pulse each 2 seconds
  
  uart1_printline("enable interrupts for timer1\r\n");
  *(unsigned long *) INTERRUPT_ENABLE = INTERRUPT_TIMER1; 

  uart1_printline("working...");
  
  while(1)
  {
    for(n = 0; n < 1000000; n++);
    uart1_printchar('+');
  }
  	
  
}

