/*
see README.txt for details.

chris <cliechti@gmx.net>
*/
#include "hardware.h"
#include <stdlib.h>
#include <stdio.h>
#include "swuart.h"
//#include "fll.h"

volatile int rxdata;

/**
Delay function.
*/
void delay(unsigned int d) {
   while(d--) {
      nop();
      nop();
   }
}

/**
Main function with init an an endless loop that is synced with the
interrupts trough the lowpower mode.
*/
int main(void) {
    int reading = 0;
    int pos = 0;
    char buf[40];
    int led = 0;
    
    WDTCTL = WDTCTL_INIT;               //Init watchdog timer

    P1OUT  = P1OUT_INIT;                //Init output data of port1
    P1SEL  = P1SEL_INIT;                //Select port or module -function on port1
    P1DIR  = P1DIR_INIT;                //Init port direction register of port1
    P1IES  = P1IES_INIT;                //init port interrupts
    P1IE   = P1IE_INIT;

    P2OUT  = P2OUT_INIT;                //Init output data of port2
    P2SEL  = P2SEL_INIT;                //Select port or module -function on port2
    P2DIR  = P2DIR_INIT;                //Init port direction register of port2
    P2IES  = P2IES_INIT;                //init port interrupts
    P2IE   = P2IE_INIT;

    P3DIR  = 0xff;
    P3OUT  = 0xff;                      //light LED during init
//    delay(65535);                       //Wait for watch crystal startup
    delay(10);
//  fllInit();                          //Init FLL to desired frequency using the 32k768 cystal as reference.
    P3OUT  = 0x00;                      //switch off LED
    
    TACTL  = TACTL_AFTER_FLL;           //setup timer (still stopped)
    CCTL0  = CCIE|CAP|CM_2|CCIS_1|SCS;  //select P2.2 with UART signal
    CCTL1  = 0;                         //
    CCTL2  = 0;                         //
    TACTL |= MC1;                       //start timer
    
    eint();                             //enable interrupts
    
    printf("\r\n====== openMSP430 in action ======\r\n");   //say hello
    printf("\r\nSimple Line Editor Ready\r\n");   //say hello
    
    while (1) {                         //main loop, never ends...
        printf("> ");                   //show prompt
        reading = 1;
        while (reading) {               //loop and read characters
            LPM0;                       //sync, wakeup by irq

	    led++;                      // Some lighting...
	    if (led==9) {
	      led = 0;
	    }
	    P3OUT = (0x01 << led);

            switch (rxdata) {
                //process RETURN key
                case '\r':
                //case '\n':
                    printf("\r\n");     //finish line
                    buf[pos++] = 0;     //to use printf...
                    printf(":%s\r\n", buf);
                    reading = 0;        //exit read loop
                    pos = 0;            //reset buffer
                    break;
                //backspace
                case '\b':
                    if (pos > 0) {      //is there a char to delete?
                        pos--;          //remove it in buffer
                        putchar((int)'\b');  //go back
                        putchar((int)' ');   //erase on screen
                        putchar((int)'\b');  //go back
                    }
                    break;
                //other characters
                default:
                    //only store characters if buffer has space
                    if (pos < sizeof(buf)) {
                        putchar(rxdata);     //echo
                        buf[pos++] = (char)rxdata; //store
                    }
            }
        }
    }
}

interrupt (TIMERA0_VECTOR) INT_ccr0(void) {

  int rx_done;
  rx_done = ccr0();

  if (rx_done!=-1) {
    LPM0_EXIT;
    rxdata = rx_done;
  }
}
