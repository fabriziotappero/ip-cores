/*
 * start.h -- startup and support routines
 */


#ifndef _START_H_
#define _START_H_


typedef struct {
  Word reg[32];			/* general purpose registers */
  Word psw;			/* PSW */
  Word tlbIndex;		/* TLB index register */
  Word tlbHi;			/* TLB EntryHi register */
  Word tlbLo;			/* TLB EntryLo register */
  Word badAddr;			/* bad address register */
} InterruptContext;


int cin(void);
void cout(char c);

void xtest1(InterruptContext *icp);
extern Word xtest1x;
void xtest2(InterruptContext *icp);
extern Word xtest2x;
void xtest3(InterruptContext *icp);
extern Word xtest3x;
void xtest4(InterruptContext *icp);
extern Word xtest4x;
void xtest5(InterruptContext *icp);
extern Word xtest5x;
void xtest6(InterruptContext *icp);
extern Word xtest6x;
void xtest7(InterruptContext *icp);
extern Word xtest7x;
void xtest8(InterruptContext *icp);
extern Word xtest8x;
void xtest9(InterruptContext *icp);
extern Word xtest9x;
void xtest10(InterruptContext *icp);
extern Word xtest10x;
void xtest11(InterruptContext *icp);
extern Word xtest11x;
void xtest12(InterruptContext *icp);
extern Word xtest12x;
void xtest13(InterruptContext *icp);
extern Word xtest13x;
void xtest14(InterruptContext *icp);
extern Word xtest14x;
void xtest15(InterruptContext *icp);
extern Word xtest15x;
void xtest16(InterruptContext *icp);
extern Word xtest16x;
void xtest17(InterruptContext *icp);
extern Word xtest17x;
void xtest18(InterruptContext *icp);
extern Word xtest18x;
void xtest19(InterruptContext *icp);
extern Word xtest19x;
void xtest20(InterruptContext *icp);
extern Word xtest20x;
void xtest21(InterruptContext *icp);
extern Word xtest21x;
void xtest22(InterruptContext *icp);
extern Word xtest22x;
void xtest23(InterruptContext *icp);
extern Word xtest23x;
void xtest24(InterruptContext *icp);
extern Word xtest24x;
void xtest25(InterruptContext *icp);
extern Word xtest25x;
void xtest26(InterruptContext *icp);
extern Word xtest26x;
void xtest27(InterruptContext *icp);
extern Word xtest27x;
void xtest28(InterruptContext *icp);
extern Word xtest28x;
void xtest29(InterruptContext *icp);
extern Word xtest29x;
void xtest30(InterruptContext *icp);
extern Word xtest30x;
void xtest31(InterruptContext *icp);
extern Word xtest31x;
void xtest32(InterruptContext *icp);
extern Word xtest32x;
void xtest33(InterruptContext *icp);
extern Word xtest33x;
void xtest34(InterruptContext *icp);
extern Word xtest34x;
void xtest35(InterruptContext *icp);
extern Word xtest35x;
void xtest36(InterruptContext *icp);
extern Word xtest36x;
void xtest37(InterruptContext *icp);
extern Word xtest37x;

Word getTLB_HI(int index);
Word getTLB_LO(int index);
void setTLB(int index, Word entryHi, Word entryLo);


#endif /* _START_H_ */
