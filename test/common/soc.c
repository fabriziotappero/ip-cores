/**
    @file soc.c
    @brief Hardware-dependent function library.
    
*/

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "../include/light52.h"
#include "soc.h"

/*-- Local macros ------------------------------------------------------------*/

/** How many Timer 0 counts are there in a millisecond period */
#define TIMER0_COUNTS_PER_MS (uint32_t)((CLOCK_RATE/1000)/TIMER0_PRESCALER)

/*-- Static data -------------------------------------------------------------*/

/** 
    Counter of seconds elapsed since last call to mcu_init. 
    Updated by timer 0 irq routine.
*/
volatile uint32_t seconds;

/*-- Public functions --------------------------------------------------------*/

/*-- SoC ----------------------------------------------------------*/

void soc_init(void){
    seconds = 0;
    /* Set up timer 0 to trigger an interrupt every second... */
    timer0_init(CLOCK_RATE/TIMER0_PRESCALER);
    /* ...enable interrupts globally, plus the timer interrupt only... */ 
    timer0_enable_irq(1);
    cpu_enable_interrupts(1);
    /* ...and (re)start the timer */
    timer0_enable(1);
}

uint32_t soc_get_msecs(void){
    uint32_t msecs;
    /* First, get the elapsed milliseconds of the current second */ 
    msecs = timer0_counter();           /* Get the counter... */
    msecs = msecs/TIMER0_COUNTS_PER_MS; /* ...and convert it to milliseconds */
    /* Then, add the number of full seconds elapsed */
    msecs = msecs + seconds*1000;
    return msecs;
}


/*-- CPU ----------------------------------------------------------*/

void cpu_enable_interrupts(uint8_t enable){
    EA = enable & 0x01;
}

/*-- Timer --------------------------------------------------------*/

void timer0_init(uint16_t reload){
    if(reload!=0xffff){
        T0CH = (uint8_t)(reload >> 8);
        T0CL = (uint8_t)(reload & 0xff);
        T0ARL = 1;
    }
    else{
        T0ARL = 0;
    };
    T0IRQ = 1; /* Clear IRQ flag by writing a 1 on it */
}

void timer0_enable(uint8_t enable){
    T0CEN = enable & 0x01;
}

uint16_t timer0_counter(void){
    volatile uint8_t h, l0, l1;
    uint16_t value;
    bool retried = false;
    
    /* Read the counter register... */
    h = T0H;
    l0 = T0L;
    l1 = T0L;
    /* ...and make sure we didn't catch it incrementing */
    if(l0!=l1){
        /* If we did, read it again. 
           Enough if the counter does not run too fast. */
        h = T0H;
        l0 = T0L;
    }

    value = ((uint16_t)h)<<8 | (uint16_t)l0;
    return value;
}

void timer0_enable_irq(uint8_t enable){
    ET0 = enable & 0x01;
}

/*-- Interrupt routines ------------------------------------------------------*/

void timer0_isr(void) __interrupt(1) {
    static uint8_t q = 0;
    
    T0IRQ = 1; /* Clear IRQ flag by writing a 1 on it */
    P1 = q;
    q++;
    
    seconds++;
}

/*-- STDCLIB replacement functions -------------------------------------------*/

/** 
    Stdclib putchar replacement function.
    Relies on polling for simplicity and does CR to CRLF expansion.
    
    @arg c Character to be displayed. Character '\n' will be expanded to '\n\r'.
*/
void putchar (char c) { 
    while (!TXRDY);
    SBUF = c;
    if(c=='\n'){
        while (!TXRDY);
        SBUF = '\r';
    }
}
