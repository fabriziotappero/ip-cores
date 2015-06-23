/*
 * cpu.h -- CPU simulation
 */


#ifndef _CPU_H_
#define _CPU_H_


#define IRQ_TIMER_1		15	/* timer 1 interrupt */
#define IRQ_TIMER_0		14	/* timer 0 interrupt */
#define IRQ_DISK		8	/* disk interrupt */
#define IRQ_KEYBOARD		4	/* keyboard interrupt */
#define IRQ_SERIAL_1_RCVR	3	/* line 1 receiver interrupt */
#define IRQ_SERIAL_1_XMTR	2	/* line 1 transmitter interrupt */
#define IRQ_SERIAL_0_RCVR	1	/* line 0 receiver interrupt */
#define IRQ_SERIAL_0_XMTR	0	/* line 0 transmitter interrupt */

#define PSW_V		0x08000000	/* interrupt vector bit in PSW */
#define PSW_UM		0x04000000	/* user mode enable bit in PSW */
#define PSW_PUM		0x02000000	/* previous value of PSW_UM */
#define PSW_OUM		0x01000000	/* old value of PSW_UM */
#define PSW_IE		0x00800000	/* interrupt enable bit in PSW */
#define PSW_PIE		0x00400000	/* previous value of PSW_IE */
#define PSW_OIE		0x00200000	/* old value of PSW_IE */
#define PSW_PRIO_MASK	0x001F0000	/* bits to encode IRQ prio in PSW */
#define PSW_PRIO_SHFT	16		/* shift count to reach these bits */
#define PSW_IRQ_MASK	0x0000FFFF	/* IRQ mask bits */


Word cpuGetPC(void);
void cpuSetPC(Word addr);

Word cpuGetReg(int regnum);
void cpuSetReg(int regnum, Word value);

Word cpuGetPSW(void);
void cpuSetPSW(Word value);

Word cpuGetIRQ(void);

Bool cpuTestBreak(void);
Word cpuGetBreak(void);
void cpuSetBreak(Word addr);
void cpuResetBreak(void);

Word cpuGetTotal(void);

void cpuStep(void);
void cpuRun(void);
void cpuHalt(void);

void cpuSetInterrupt(int priority);
void cpuResetInterrupt(int priority);

void cpuReset(void);
void cpuInit(Word initialPC);
void cpuExit(void);


#endif /* _CPU_H_ */
