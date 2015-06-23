/*
 * start.h -- startup and support routines
 */


#ifndef _START_H_
#define _START_H_


typedef struct {
  Word ic_reg[32];		/* general purpose registers */
  Word ic_tlbhi;		/* TLB EntryHi */
  Word ic_psw;			/* PSW */
} InterruptContext;

typedef void (*ISR)(int irq, InterruptContext *icp);


int cin(void);
void cout(char c);

Word getTLB_HI(int index);
Word getTLB_LO(int index);
void setTLB(int index, Word entryHi, Word entryLo);
void wrtRndTLB(Word entryHi, Word entryLo);
Word probeTLB(Word entryHi);
void wait(int n);
void enable(void);
void disable(void);
Word getMask(void);
Word setMask(Word mask);
ISR getISR(int irq);
ISR setISR(int irq, ISR isr);


#endif /* _START_H_ */
