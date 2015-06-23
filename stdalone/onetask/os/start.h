/*
 * start.h -- startup code
 */


#ifndef _START_H_
#define _START_H_


typedef void (*ISR)(int irq, unsigned int *registers);


void enable(void);
void disable(void);
ISR getISR(int irq);
void setISR(int irq, ISR isr);
void startTask(unsigned int physStackTop);
void setTLB(int index, unsigned int entryHi, unsigned int entryLo);


#endif /* _START_H_ */
