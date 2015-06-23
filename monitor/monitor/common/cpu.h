/*
 * cpu.h -- execute instructions
 */


#ifndef _CPU_H_
#define _CPU_H_


#define PSW_V		0x08000000	/* interrupt vector bit in PSW */
#define PSW_UM		0x04000000	/* user mode enable bit in PSW */
#define PSW_PUM		0x02000000	/* previous value of PSW_UM */
#define PSW_OUM		0x01000000	/* old value of PSW_UM */
#define PSW_IE		0x00800000	/* interrupt enable bit in PSW */
#define PSW_PIE		0x00400000	/* previous value of PSW_IE */
#define PSW_OIE		0x00200000	/* old value of PSW_IE */
#define PSW_PRIO_MASK	0x001F0000	/* bits to encode IRQ prio in PSW */


Word cpuGetPC(void);
void cpuSetPC(Word addr);

Word cpuGetReg(int regnum);
void cpuSetReg(int regnum, Word value);

Word cpuGetPSW(void);
void cpuSetPSW(Word value);

Bool cpuTestBreak(void);
Word cpuGetBreak(void);
void cpuSetBreak(Word addr);
void cpuResetBreak(void);

char *exceptionToString(int exception);

void cpuStep(void);
void cpuRun(void);


#endif /* _CPU_H_ */
