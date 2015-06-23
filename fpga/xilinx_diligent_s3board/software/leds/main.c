#include "hardware.h"
#include "7seg.h"

/**
Delay function.
*/
void delay(unsigned int c, unsigned int d) {
  volatile int i, j;
  for (i = 0; i<c; i++) {
    for (j = 0; j<d; j++) {
      nop();
      nop();
    }
  }
}

/**
This one is executed onece a second. it counts seconds, minues, hours - hey
it shoule be a clock ;-)
it does not count days, but i think you'll get the idea.
*/
volatile int irq_counter, offset;

wakeup interrupt (WDT_VECTOR) INT_Watchdog(void) {

  irq_counter++;
  if (irq_counter == 300) {
    irq_counter = 0;
    offset = (offset+1) % 20;
  }
  DispStr  (offset, "OPENMSP430 IN ACTION    ");
}


/**
Main function with some blinking leds
*/
int main(void) {
  int i;
    int o = 0;
    irq_counter = 0;
    offset      = 0;

    WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

    P1OUT  = 0x00;                     // Port data output
    P2OUT  = 0x00;

    P1DIR  = 0x00;                     // Port direction register
    P2DIR  = 0x00;
    P3DIR  = 0xff;

    P1IES  = 0x00;                     // Port interrupt enable (0=dis 1=enabled)
    P2IES  = 0x00;
    P1IE   = 0x00;                     // Port interrupt Edge Select (0=pos 1=neg)
    P2IE   = 0x00;

    WDTCTL = WDTPW | WDTTMSEL | WDTCNTCL;// | WDTIS1  | WDTIS0 ;          // Configure watchdog interrupt

    IE1 |= 0x01;
    eint();                            //enable interrupts


    while (1) {                         // Main loop, never ends...
        for (i=0; i<8; i++, o++) {
            P3OUT = (1<<i) | (0x80>>(o&7));
	    delay(0x0007, 0xffff);
        }
    }
}

