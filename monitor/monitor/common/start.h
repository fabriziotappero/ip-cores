/*
 * start.h -- ECO32 ROM monitor startup and support routines
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
  Word badAccs;			/* bad access register */
} UserContext;

typedef struct {
  Word r31;			/* return address */
  Word r29;			/* stack pointer */
  Word r16;			/* local variable */
  Word r17;			/* local variable */
  Word r18;			/* local variable */
  Word r19;			/* local variable */
  Word r20;			/* local variable */
  Word r21;			/* local variable */
  Word r22;			/* local variable */
  Word r23;			/* local variable */
} MonitorState;


void setcon(Byte ctl);
int cinchk(void);
char cin(void);
int coutchk(void);
void cout(char c);

int dskcap(int dskno);
int dskio(int dskno, char cmd, int sct, Word addr, int nscts);

Word getTLB_HI(int index);
Word getTLB_LO(int index);
void setTLB(int index, Word entryHi, Word entryLo);

Bool saveState(MonitorState *msp);

extern MonitorState *monitorReturn;
extern UserContext userContext;

void resume(void);


#endif /* _START_H_ */
