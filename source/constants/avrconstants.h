//
// Excerpt from iom103.h
//
#ifndef _AVRCONSTANTS_H
#define _AVRCONSTANTS_H

 
/* Watchdog Timer Control Register */
#define WDTCR     0x21

/* Timer2 Output Compare Register */
#define OCR2      0x23

/* Timer/Counter 2 */
#define TCNT2     0x24
 
/* Timer/Counter 2 Control register */ 
#define TCCR2     0x25

/* T/C 1 Input Capture Register */
#define ICR1L     0x26
#define ICR1H     0x27

/* Timer/Counter1 Output Compare Register B */ 
#define OCR1BL    0x28
#define OCR1BH    0x29

/* Timer/Counter1 Output Compare Register A */
#define OCR1AL    0x2A
#define OCR1AH    0x2B

/* Timer/Counter 1 */
#define TCNT1L    0x2C
#define TCNT1H    0x2D
 
/* Timer/Counter 1 Control and Status Register */
#define TCCR1B    0x2E
 
/* Timer/Counter 1 Control Register */
#define TCCR1A    0x2F
 
/* Timer/Counter 0 Asynchronous Control & Status Register */
#define ASSR      0x30

/* Output Compare Register 0 */
#define OCR0      0x31

/* Timer/Counter 0 */
#define TCNT0     0x32
 
/* Timer/Counter 0 Control Register */
#define TCCR0     0x33

/* MCU Status Register */
#define MCUSR     0x34
 
/* MCU general Control Register */
#define MCUCR     0x35
 
/* Timer/Counter Interrupt Flag Register */
#define TIFR      0x36
 
/* Timer/Counter Interrupt MaSK register */
#define TIMSK     0x37
 
/* External Interrupt Flag Register */
#define EIFR      0x38
 
/* External Interrupt MaSK register */
#define EIMSK      0x39
 
/* External Interrupt Control Register */
#define EICR      0x3A

/* RAM Page Z select register */
#define RAMPZ     0x3B
 
/* XDIV Divide control register */
#define XDIV      0x3C

/* Stack Pointer */
#define SPL      0x3D
#define SPH      0x3E

/* Status REGister */
#define SREG      0x3F

#endif
