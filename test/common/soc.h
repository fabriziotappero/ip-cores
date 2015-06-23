/**
    @file soc.h
    @brief Hardware-dependent function library.
    
    This file encapsulates hardware access from the rest of the program for
    easier porting.
*/

#ifndef SOC_H_INCLUDED
#define SOC_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>

/*-- SoC configuration macros ------------------------------------------------*/
/* These may optionally be set at the makefile */

#ifndef CLOCK_RATE
/** Default clock rate is that of Terasic's DE-1 board */
#define CLOCK_RATE (50e6)
#endif  

#ifndef TIMER0_PRESCALER
/** By default the prescaler is set to count periods of 20us @ 50MHz */
#define TIMER0_PRESCALER (1000)
#endif

/*-- Public functions --------------------------------------------------------*/



/*-- SoC ----------------------------------------------------------*/


/**
    Set up all the MCU peripherals with a standard cofiguration.
    This includes:
    -# Timer 0 set to count seconds (when prescaler set to 20us).
    -# UART in default configuration (19200-8-N-1).
*/
extern void soc_init(void);

/**
    Read millisecond counter.
    
    @return Number of milliseconds elapsed since last call to mcu_init.
*/
extern uint32_t soc_get_msecs(void);



/*-- CPU ----------------------------------------------------------*/

/**
    Enable or disable interrupts globally with EA flag.
    Does not affect any other interrupt flag.
    
    @arg enable 1 to enable interrupts, 0 to disable.
*/
extern void cpu_enable_interrupts(uint8_t enable);

/*-- Timer 0 ------------------------------------------------------*/

/**
    Initialize Timer 0. 
    This function does not start the timer, only:
        -# Loads the T0ARL flag.
        -# Clears the T0IRQ flag.
        -# Loads the reload register.
        
    @arg reload Value for reload register, or 0xffff to not use reload mode.
*/
extern void timer0_init(uint16_t reload);

/**
    Start or stop Timer 0 by setting flag T0CEN.
    
    @arg enable 1 to start the timer, 0 to stop it.
*/
extern void timer0_enable(uint8_t enable);


/**
    Read value of Timer 0 counter register.
    Will make sure the value read is consistent.
    
    @return Value of Timer 0 counter register.
*/
extern uint16_t timer0_counter(void);

/**
    Enable or disable Timer 0 interrupt.
    Does not affect global EA flag.
    
    @arg enable 1 to enable interrupt, 0 to disable.
*/
extern void timer0_enable_irq(uint8_t enable);


/*-- Interrupt function prototypes --------------------------------*/

/* 
    NOTE:
    SDCC requires that the prototype of all irq functions be present in the
    file that contains the main function.
*/

/**
    Interrupt response function for IRQ1 (Timer 0).
*/
void timer0_isr(void) __interrupt(1);

#endif
