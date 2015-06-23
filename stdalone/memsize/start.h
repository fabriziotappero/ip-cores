/*
 * start.h -- startup code
 */


#ifndef _START_H_
#define _START_H_


typedef int (*ISR)(int irq);


void enable(void);
void disable(void);
ISR getISR(int irq);
void setISR(int irq, ISR isr);


#endif /* _START_H_ */
