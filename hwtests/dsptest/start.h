/*
 * start.h -- startup and support routines
 */


#ifndef _START_H_
#define _START_H_


int cin(void);
void cout(char c);

Word getTLB_HI(int index);
Word getTLB_LO(int index);
void setTLB(int index, Word entryHi, Word entryLo);
void wrtRndTLB(Word entryHi, Word entryLo);
Word probeTLB(Word entryHi);
void wait(int n);


#endif /* _START_H_ */
