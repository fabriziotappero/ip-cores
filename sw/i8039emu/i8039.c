/****************************************************************************
 *                      Intel 8039 Portable Emulator                        *
 *                                                                          *
 *                   Copyright (C) 1997 by Mirko Buffoni                    *
 *  Based on the original work (C) 1997 by Dan Boris, an 8048 emulator      *
 *      You are not allowed to distribute this software commercially        *
 *        Please, notify me, if you make any changes to this file           *
 *                                                                          *
 *    Adapted for the T48 uController project, 2004 by Arnim Laeuger        *
 *      See http://www.opencores.org/projects.cgi/web/t48/overview          *
 *                                                                          *
 * $Id: i8039.c 295 2009-04-01 19:32:48Z arniml $
 *                                                                          *
 *  **** Change Log ****                                                    *
 *                                                                          *
 *  TLP (19-Jun-2001)                                                       *
 *   - Changed Ports 1 and 2 to quasi bidirectional output latched ports    *
 *   - Added the Port 1 & 2 output latch data to the debugger window        *
 *  TLP (02-Jan-2002)                                                       *
 *   - External IRQs no longer go pending (sampled as a level state)        *
 *   - Timer IRQs do not go pending if Timer interrupts are disabled        *
 *   - Timer IRQs made pending, were incorrectly being cleared if the       *
 *      external interrupt was being serviced                               *
 *   - External interrupts now take precedence when simultaneous            *
 *      internal and external interrupt requests occur                      *
 *   - 'DIS TCNTI' now removes pending timer IRQs                           *
 *   - Nested IRQs of any sort are no longer allowed                        *
 *   - T_flag was not being set in the right place of execution, which      *
 *      could have lead to it being incorrectly set after being cleared     *
 *   - Counter overflows now also set the T_flag                            *
 *   - Added the Timer/Counter register to the debugger window              *
 *  TLP (09-Jan-2002)                                                       *
 *   - Changed Interrupt system to instant servicing                        *
 *   - The Timer and Counter can no longer be 'on' simultaneously           *
 *   - Added Save State                                                     *
 *  TLP (15-Feb-2002)                                                       *
 *   - Corrected Positive signal edge sensing (used on the T1 input)        *
 ****************************************************************************/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "i8039.h"


/*** Cycle times for the jump on condition instructions, are unusual.
     Condition is tested during the first cycle, so if condition is not
     met, second address fetch cycle may not really be taken. For now we
     just use the cycle counts as listed in the i8048 user manual.
***/

#if 0
#define ADJUST_CYCLES { inst_cycles -= 1; } /* Possible real cycles setting */
#else
#define ADJUST_CYCLES { }                   /* User Manual cycles setting */
#endif



/* HJB 01/05/99 changed to positive values to use pending_irq as a flag */
#define I8039_NO_INT        0   /* No Interrupts pending or executing   */
#define I8039_EXTERNAL_INT  1   /* Execute a normal external interrupt  */
#define I8039_TIMCNT_INT    2   /* Execute a Timer/Counter interrupt    */


/* Layout of the registers in the debugger */
static UINT8 i8039_reg_layout[] = {
    I8039_PC, I8039_SP, I8039_PSW, I8039_A, I8039_TC, I8039_P1, I8039_P2, -1,
    I8039_R0, I8039_R1, I8039_R2, I8039_R3, I8039_R4, I8039_R5, I8039_R6, I8039_R7, 0
};

/* Layout of the debugger windows x,y,w,h */
static UINT8 i8039_win_layout[] = {
     0, 0,80, 2,    /* register window (top rows) */
     0, 3,24,19,    /* disassembler window (left colums) */
    25, 3,55, 9,    /* memory #1 window (right, upper middle) */
    25,13,55, 9,    /* memory #2 window (right, lower middle) */
     0,23,80, 1,    /* command line window (bottom rows) */
};


static int Ext_IRQ(void);
static int Timer_IRQ(void);

#define M_RDMEM(A)      I8039_RDMEM(A)
#define M_RDOP(A)       I8039_RDOP(A)
#define M_RDOP_ARG(A)   I8039_RDOP_ARG(A)
#define M_IN(A)         I8039_In(A)
#define M_OUT(A,V)      I8039_Out(A,V)

#define port_r(A)       I8039_In(I8039_p0 + A)
#define port_w(A,V)     I8039_Out(I8039_p0 + A,V)
#define test_r(A)       I8039_In(I8039_t0 + A)
#define test_w(A,V)     I8039_Out(I8039_t0 + A,V)
#define bus_r()         I8039_In(I8039_bus)
#define bus_w(V)        I8039_Out(I8039_bus,V)

#define C_FLAG          0x80
#define A_FLAG          0x40
#define F_FLAG          0x20
#define B_FLAG          0x10

typedef struct
{
    PAIR    PREVPC;         /* previous program counter */
    PAIR    PC;             /* program counter */
    UINT8   A, SP, PSW;
    UINT8   RAM[256];
    UINT8   bus, f1;        /* Bus data, and flag1 */
    UINT8   P1, P2;         /* Internal Port 1 and 2 latched outputs */

    UINT8   pending_irq, irq_executing, masterClock, regPtr;
    UINT8   t_flag, timer, timerON, countON, xirq_en, tirq_en;
    UINT16  A11, A11ff;
    UINT8   irq_state, irq_extra_cycles;
    int     (*irq_callback)(int irqline);
} I8039_Regs;

static I8039_Regs R;
int    i8039_ICount;
int    inst_cycles;
static UINT8 Old_T1;

/* The opcode table now is a combination of cycle counts and function pointers */
typedef struct {
    unsigned cycles;
    void (*function) (void);
}   s_opcode;

#define POSITIVE_EDGE_T1  (( (int)(T1-Old_T1) > 0) ? 1 : 0)
#define NEGATIVE_EDGE_T1  (( (int)(Old_T1-T1) > 0) ? 1 : 0)

#define M_Cy    ((R.PSW & C_FLAG) >> 7)
#define M_Cn    (!M_Cy)
#define M_Ay    ((R.PSW & A_FLAG))
#define M_An    (!M_Ay)
#define M_F0y   ((R.PSW & F_FLAG))
#define M_F0n   (!M_F0y)
#define M_By    ((R.PSW & B_FLAG))
#define M_Bn    (!M_By)

#define intRAM  R.RAM
#define regPTR  R.regPtr

#define R0  intRAM[regPTR  ]
#define R1  intRAM[regPTR+1]
#define R2  intRAM[regPTR+2]
#define R3  intRAM[regPTR+3]
#define R4  intRAM[regPTR+4]
#define R5  intRAM[regPTR+5]
#define R6  intRAM[regPTR+6]
#define R7  intRAM[regPTR+7]


INLINE void CLR (UINT8 flag) { R.PSW &= ~flag; }
INLINE void SET (UINT8 flag) { R.PSW |= flag;  }


/* Get next opcode argument and increment program counter */
INLINE unsigned M_RDMEM_OPCODE (void)
{
    unsigned retval;
    retval=M_RDOP_ARG(R.PC.w.l);
    R.PC.w.l++;
    return retval;
}

INLINE void push(UINT8 d)
{
    intRAM[8+R.SP++] = d;
    R.SP  = R.SP & 0x0f;
    R.PSW = R.PSW & 0xf8;
    R.PSW = R.PSW | (R.SP >> 1);
}

INLINE UINT8 pull(void) {
    R.SP  = (R.SP + 15) & 0x0f;     /*  if (--R.SP < 0) R.SP = 15;  */
    R.PSW = R.PSW & 0xf8;
    R.PSW = R.PSW | (R.SP >> 1);
    /* regPTR = ((M_By) ? 24 : 0);  regPTR should not change */
    return intRAM[8+R.SP];
}

INLINE void daa_a(void)
{
    if ((R.A & 0x0f) > 0x09 || (R.PSW & A_FLAG))
        R.A += 0x06;
    if ((R.A & 0xf0) > 0x90 || (R.PSW & C_FLAG))
    {
        R.A += 0x60;
        SET(C_FLAG);
    } else CLR(C_FLAG);
}

INLINE void M_ADD(UINT8 dat)
{
    UINT16 temp;

    CLR(C_FLAG | A_FLAG);
    if ((R.A & 0xf) + (dat & 0xf) > 0xf) SET(A_FLAG);
    temp = R.A + dat;
    if (temp > 0xff) SET(C_FLAG);
    R.A  = temp & 0xff;
}

INLINE void M_ADDC(UINT8 dat)
{
    UINT16 temp;

    CLR(A_FLAG);
    if ((R.A & 0xf) + (dat & 0xf) + M_Cy > 0xf) SET(A_FLAG);
    temp = R.A + dat + M_Cy;
    CLR(C_FLAG);
    if (temp > 0xff) SET(C_FLAG);
    R.A  = temp & 0xff;
}

INLINE void M_CALL(UINT16 addr)
{
    push(R.PC.b.l);
    push((R.PC.b.h & 0x0f) | (R.PSW & 0xf0));
    R.PC.w.l = addr;

}

INLINE void M_XCHD(UINT8 addr)
{
    UINT8 dat = R.A & 0x0f;
    R.A &= 0xf0;
    R.A |= intRAM[addr] & 0x0f;
    intRAM[addr] &= 0xf0;
    intRAM[addr] |= dat;
}


INLINE void M_ILLEGAL(void)
{
    logerror("I8039:  PC = %04x,  Illegal opcode = %02x\n", R.PC.w.l-1, M_RDMEM(R.PC.w.l-1));
}

INLINE void M_UNDEFINED(void)
{
    logerror("I8039:  PC = %04x,  Unimplemented opcode = %02x\n", R.PC.w.l-1, M_RDMEM(R.PC.w.l-1));
}

#define INT_RAM_MASK 0xff

static void illegal(void)    { M_ILLEGAL(); }

static void add_a_n(void)    { M_ADD(M_RDMEM_OPCODE()); }
static void add_a_r0(void)   { M_ADD(R0); }
static void add_a_r1(void)   { M_ADD(R1); }
static void add_a_r2(void)   { M_ADD(R2); }
static void add_a_r3(void)   { M_ADD(R3); }
static void add_a_r4(void)   { M_ADD(R4); }
static void add_a_r5(void)   { M_ADD(R5); }
static void add_a_r6(void)   { M_ADD(R6); }
static void add_a_r7(void)   { M_ADD(R7); }
static void add_a_xr0(void)  { M_ADD(intRAM[R0 & INT_RAM_MASK]); }
static void add_a_xr1(void)  { M_ADD(intRAM[R1 & INT_RAM_MASK]); }
static void adc_a_n(void)    { M_ADDC(M_RDMEM_OPCODE()); }
static void adc_a_r0(void)   { M_ADDC(R0); }
static void adc_a_r1(void)   { M_ADDC(R1); }
static void adc_a_r2(void)   { M_ADDC(R2); }
static void adc_a_r3(void)   { M_ADDC(R3); }
static void adc_a_r4(void)   { M_ADDC(R4); }
static void adc_a_r5(void)   { M_ADDC(R5); }
static void adc_a_r6(void)   { M_ADDC(R6); }
static void adc_a_r7(void)   { M_ADDC(R7); }
static void adc_a_xr0(void)  { M_ADDC(intRAM[R0 & INT_RAM_MASK]); }
static void adc_a_xr1(void)  { M_ADDC(intRAM[R1 & INT_RAM_MASK]); }
static void anl_a_n(void)    { R.A &= M_RDMEM_OPCODE(); }
static void anl_a_r0(void)   { R.A &= R0; }
static void anl_a_r1(void)   { R.A &= R1; }
static void anl_a_r2(void)   { R.A &= R2; }
static void anl_a_r3(void)   { R.A &= R3; }
static void anl_a_r4(void)   { R.A &= R4; }
static void anl_a_r5(void)   { R.A &= R5; }
static void anl_a_r6(void)   { R.A &= R6; }
static void anl_a_r7(void)   { R.A &= R7; }
static void anl_a_xr0(void)  { R.A &= intRAM[R0 & INT_RAM_MASK]; }
static void anl_a_xr1(void)  { R.A &= intRAM[R1 & INT_RAM_MASK]; }
static void anl_bus_n(void)  { bus_w( bus_r() & M_RDMEM_OPCODE() ); }
static void anl_p1_n(void)   { R.P1 &= M_RDMEM_OPCODE(); port_w( 1, R.P1 ); }
static void anl_p2_n(void)   { R.P2 &= M_RDMEM_OPCODE(); port_w( 2, R.P2 ); }
static void anld_p4_a(void)  { port_w( 4, port_r(4) & M_RDMEM_OPCODE() ); }
static void anld_p5_a(void)  { port_w( 5, port_r(5) & M_RDMEM_OPCODE() ); }
static void anld_p6_a(void)  { port_w( 6, port_r(6) & M_RDMEM_OPCODE() ); }
static void anld_p7_a(void)  { port_w( 7, port_r(7) & M_RDMEM_OPCODE() ); }
static void call(void)       { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | R.A11); }
static void call_1(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x100 | R.A11); }
static void call_2(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x200 | R.A11); }
static void call_3(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x300 | R.A11); }
static void call_4(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x400 | R.A11); }
static void call_5(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x500 | R.A11); }
static void call_6(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x600 | R.A11); }
static void call_7(void)     { UINT8 i=M_RDMEM_OPCODE(); M_CALL(i | 0x700 | R.A11); }
static void clr_a(void)      { R.A=0; }
static void clr_c(void)      { CLR(C_FLAG); }
static void clr_f0(void)     { CLR(F_FLAG); }
static void clr_f1(void)     { R.f1 = 0; }
static void cpl_a(void)      { R.A ^= 0xff; }
static void cpl_c(void)      { R.PSW ^= C_FLAG; }
static void cpl_f0(void)     { R.PSW ^= F_FLAG; }
static void cpl_f1(void)     { R.f1 ^= 1; }
static void dec_a(void)      { R.A--; }
static void dec_r0(void)     { R0--; }
static void dec_r1(void)     { R1--; }
static void dec_r2(void)     { R2--; }
static void dec_r3(void)     { R3--; }
static void dec_r4(void)     { R4--; }
static void dec_r5(void)     { R5--; }
static void dec_r6(void)     { R6--; }
static void dec_r7(void)     { R7--; }
static void dis_i(void)      { R.xirq_en = 0; }
static void dis_tcnti(void)  { R.tirq_en = 0; R.pending_irq &= ~I8039_TIMCNT_INT; }
static void djnz_r0(void)   { UINT8 i=M_RDMEM_OPCODE(); R0--; if (R0 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r1(void)   { UINT8 i=M_RDMEM_OPCODE(); R1--; if (R1 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r2(void)   { UINT8 i=M_RDMEM_OPCODE(); R2--; if (R2 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r3(void)   { UINT8 i=M_RDMEM_OPCODE(); R3--; if (R3 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r4(void)   { UINT8 i=M_RDMEM_OPCODE(); R4--; if (R4 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r5(void)   { UINT8 i=M_RDMEM_OPCODE(); R5--; if (R5 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r6(void)   { UINT8 i=M_RDMEM_OPCODE(); R6--; if (R6 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void djnz_r7(void)   { UINT8 i=M_RDMEM_OPCODE(); R7--; if (R7 != 0) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void en_i(void)       { R.xirq_en = 1; if (R.irq_state == I8039_EXTERNAL_INT) { R.irq_extra_cycles += Ext_IRQ(); } }
static void en_tcnti(void)   { R.tirq_en = 1; }
static void ento_clk(void)   { M_UNDEFINED(); }
static void in_a_p1(void)    { R.A = port_r(1) & R.P1; }
static void in_a_p2(void)    { R.A = port_r(2) & R.P2; }
static void ins_a_bus(void)  { R.A = bus_r(); }
static void inc_a(void)      { R.A++; }
static void inc_r0(void)     { R0++; }
static void inc_r1(void)     { R1++; }
static void inc_r2(void)     { R2++; }
static void inc_r3(void)     { R3++; }
static void inc_r4(void)     { R4++; }
static void inc_r5(void)     { R5++; }
static void inc_r6(void)     { R6++; }
static void inc_r7(void)     { R7++; }
static void inc_xr0(void)    { intRAM[R0 & INT_RAM_MASK]++; }
static void inc_xr1(void)    { intRAM[R1 & INT_RAM_MASK]++; }

/* static void jmp(void)     { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | R.A11; }
 */

static void jmp(void)
{
    UINT8 i=M_RDOP(R.PC.w.l);
    UINT16 oldpc,newpc;

    oldpc = R.PC.w.l-1;
    R.PC.w.l = i | R.A11;
    newpc = R.PC.w.l;
    if (newpc == oldpc) { if (i8039_ICount > 0) i8039_ICount = 0; } /* speed up busy loop */
    else if (newpc == oldpc-1 && M_RDOP(newpc) == 0x00) /* NOP - Gyruss */
        { if (i8039_ICount > 0) i8039_ICount = 0; }
}

static void jmp_1(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x100 | R.A11; }
static void jmp_2(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x200 | R.A11; }
static void jmp_3(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x300 | R.A11; }
static void jmp_4(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x400 | R.A11; }
static void jmp_5(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x500 | R.A11; }
static void jmp_6(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x600 | R.A11; }
static void jmp_7(void)      { UINT8 i=M_RDOP(R.PC.w.l); R.PC.w.l = i | 0x700 | R.A11; }
static void jmpp_xa(void)    { UINT16 addr = (R.PC.w.l & 0xf00) | R.A; R.PC.w.l = (R.PC.w.l & 0xf00) | M_RDMEM(addr); }
static void jb_0(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x01) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_1(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x02) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_2(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x04) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_3(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x08) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_4(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x10) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_5(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x20) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_6(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x40) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jb_7(void)       { UINT8 i=M_RDMEM_OPCODE(); if (R.A & 0x80) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jf0(void)        { UINT8 i=M_RDMEM_OPCODE(); if (M_F0y) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jf1(void)        { UINT8 i=M_RDMEM_OPCODE(); if (R.f1)  { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jnc(void)        { UINT8 i=M_RDMEM_OPCODE(); if (M_Cn)  { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jc(void)         { UINT8 i=M_RDMEM_OPCODE(); if (M_Cy)  { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jni(void)        { UINT8 i=M_RDMEM_OPCODE(); if (R.irq_state == I8039_EXTERNAL_INT) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jnt_0(void)      { UINT8 i=M_RDMEM_OPCODE(); if (!test_r(0)) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jt_0(void)       { UINT8 i=M_RDMEM_OPCODE(); if (test_r(0))  { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jnt_1(void)      { UINT8 i=M_RDMEM_OPCODE(); if (!test_r(1)) { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jt_1(void)       { UINT8 i=M_RDMEM_OPCODE(); if (test_r(1))  { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jnz(void)        { UINT8 i=M_RDMEM_OPCODE(); if (R.A != 0)   { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jz(void)         { UINT8 i=M_RDMEM_OPCODE(); if (R.A == 0)   { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; } else ADJUST_CYCLES }
static void jtf(void)        { UINT8 i=M_RDMEM_OPCODE(); if (R.t_flag)   { R.PC.w.l = ((R.PC.w.l-1) & 0xf00) | i; R.t_flag = 0; } else ADJUST_CYCLES }

static void mov_a_n(void)    { R.A = M_RDMEM_OPCODE(); }
static void mov_a_r0(void)   { R.A = R0; }
static void mov_a_r1(void)   { R.A = R1; }
static void mov_a_r2(void)   { R.A = R2; }
static void mov_a_r3(void)   { R.A = R3; }
static void mov_a_r4(void)   { R.A = R4; }
static void mov_a_r5(void)   { R.A = R5; }
static void mov_a_r6(void)   { R.A = R6; }
static void mov_a_r7(void)   { R.A = R7; }
static void mov_a_psw(void)  { R.A = R.PSW | 0x08; }
static void mov_a_xr0(void)  { R.A = intRAM[R0 & INT_RAM_MASK]; }
static void mov_a_xr1(void)  { R.A = intRAM[R1 & INT_RAM_MASK]; }
static void mov_r0_a(void)   { R0 = R.A; }
static void mov_r1_a(void)   { R1 = R.A; }
static void mov_r2_a(void)   { R2 = R.A; }
static void mov_r3_a(void)   { R3 = R.A; }
static void mov_r4_a(void)   { R4 = R.A; }
static void mov_r5_a(void)   { R5 = R.A; }
static void mov_r6_a(void)   { R6 = R.A; }
static void mov_r7_a(void)   { R7 = R.A; }
static void mov_psw_a(void)  { R.PSW = R.A | 0x08; regPTR = ((M_By) ? 24 : 0); R.SP = (R.PSW & 7) << 1; }
static void mov_r0_n(void)   { R0 = M_RDMEM_OPCODE(); }
static void mov_r1_n(void)   { R1 = M_RDMEM_OPCODE(); }
static void mov_r2_n(void)   { R2 = M_RDMEM_OPCODE(); }
static void mov_r3_n(void)   { R3 = M_RDMEM_OPCODE(); }
static void mov_r4_n(void)   { R4 = M_RDMEM_OPCODE(); }
static void mov_r5_n(void)   { R5 = M_RDMEM_OPCODE(); }
static void mov_r6_n(void)   { R6 = M_RDMEM_OPCODE(); }
static void mov_r7_n(void)   { R7 = M_RDMEM_OPCODE(); }
static void mov_a_t(void)    { R.A = R.timer; }
static void mov_t_a(void)    { R.timer = R.A; }
static void mov_xr0_a(void)  { intRAM[R0 & INT_RAM_MASK] = R.A; }
static void mov_xr1_a(void)  { intRAM[R1 & INT_RAM_MASK] = R.A; }
static void mov_xr0_n(void)  { intRAM[R0 & INT_RAM_MASK] = M_RDMEM_OPCODE(); }
static void mov_xr1_n(void)  { intRAM[R1 & INT_RAM_MASK] = M_RDMEM_OPCODE(); }
static void movd_a_p4(void)  { R.A = port_r(4); }
static void movd_a_p5(void)  { R.A = port_r(5); }
static void movd_a_p6(void)  { R.A = port_r(6); }
static void movd_a_p7(void)  { R.A = port_r(7); }
static void movd_p4_a(void)  { port_w(4, R.A); }
static void movd_p5_a(void)  { port_w(5, R.A); }
static void movd_p6_a(void)  { port_w(6, R.A); }
static void movd_p7_a(void)  { port_w(7, R.A); }
static void movp_a_xa(void)  { R.A = M_RDMEM((R.PC.w.l & 0x0f00) | R.A); }
static void movp3_a_xa(void) { R.A = M_RDMEM(0x300 | R.A); }
static void movx_a_xr0(void) { R.A = M_IN(R0); }
static void movx_a_xr1(void) { R.A = M_IN(R1); }
static void movx_xr0_a(void) { M_OUT(R0, R.A); }
static void movx_xr1_a(void) { M_OUT(R1, R.A); }
static void nop(void) { }
static void orl_a_n(void)    { R.A |= M_RDMEM_OPCODE(); }
static void orl_a_r0(void)   { R.A |= R0; }
static void orl_a_r1(void)   { R.A |= R1; }
static void orl_a_r2(void)   { R.A |= R2; }
static void orl_a_r3(void)   { R.A |= R3; }
static void orl_a_r4(void)   { R.A |= R4; }
static void orl_a_r5(void)   { R.A |= R5; }
static void orl_a_r6(void)   { R.A |= R6; }
static void orl_a_r7(void)   { R.A |= R7; }
static void orl_a_xr0(void)  { R.A |= intRAM[R0 & INT_RAM_MASK]; }
static void orl_a_xr1(void)  { R.A |= intRAM[R1 & INT_RAM_MASK]; }
static void orl_bus_n(void)  { bus_w( bus_r() | M_RDMEM_OPCODE() ); }
static void orl_p1_n(void)   { R.P1 |= M_RDMEM_OPCODE(); port_w(1, R.P1); }
static void orl_p2_n(void)   { R.P2 |= M_RDMEM_OPCODE(); port_w(2, R.P2); }
static void orld_p4_a(void)  { port_w(4, port_r(4) | R.A ); }
static void orld_p5_a(void)  { port_w(5, port_r(5) | R.A ); }
static void orld_p6_a(void)  { port_w(6, port_r(6) | R.A ); }
static void orld_p7_a(void)  { port_w(7, port_r(7) | R.A ); }
static void outl_bus_a(void) { bus_w(R.A); }
static void outl_p1_a(void)  { port_w(1, R.A); R.P1 = R.A; }
static void outl_p2_a(void)  { port_w(2, R.A); R.P2 = R.A; }
static void ret(void)    { R.PC.w.l = ((pull() & 0x0f) << 8); R.PC.w.l |= pull(); }

static void retr(void)
{
    UINT8 i=pull();
    R.PC.w.l = ((i & 0x0f) << 8) | pull();
    R.PSW = (R.PSW & 0x0f) | (i & 0xf0);    /* Stack is already changed by pull */
    regPTR = ((M_By) ? 24 : 0);

    R.irq_executing = I8039_NO_INT;

    R.A11 = R.A11ff;

    /* Take an interrupt if a request is still being made */
    if (R.irq_state == I8039_EXTERNAL_INT) {
        R.irq_extra_cycles += Ext_IRQ();            /* Service External IRQ */
    }
    else if (R.pending_irq == I8039_TIMCNT_INT) {
        R.irq_extra_cycles += Timer_IRQ();          /* Service pending Timer/Counter IRQ */
    }
}
static void rl_a(void)       { UINT8 i=R.A & 0x80; R.A <<= 1; if (i) R.A |= 0x01; else R.A &= 0xfe; }
/* NS990113 */
static void rlc_a(void)      { UINT8 i=M_Cy; if (R.A & 0x80) SET(C_FLAG); else CLR(C_FLAG); R.A <<= 1; if (i) R.A |= 0x01; else R.A &= 0xfe; }
static void rr_a(void)       { UINT8 i=R.A & 1; R.A >>= 1; if (i) R.A |= 0x80; else R.A &= 0x7f; }
/* NS990113 */
static void rrc_a(void)      { UINT8 i=M_Cy; if (R.A & 1) SET(C_FLAG); else CLR(C_FLAG); R.A >>= 1; if (i) R.A |= 0x80; else R.A &= 0x7f; }
static void sel_mb0(void)   { R.A11 = 0; R.A11ff = 0; }
static void sel_mb1(void)    { R.A11ff = 0x800; R.A11 = 0x800; }
static void sel_rb0(void)    { CLR(B_FLAG); regPTR = 0;  }
static void sel_rb1(void)    { SET(B_FLAG); regPTR = 24; }
static void stop_tcnt(void)  { R.timerON = R.countON = 0; }
static void strt_cnt(void)   { R.countON = 1; R.timerON = 0; Old_T1 = test_r(1); }  /* NS990113 */
static void strt_t(void)     { R.timerON = 1; R.countON = 0; R.masterClock = 0; }   /* NS990113 */
static void swap_a(void)     { UINT8 i=R.A >> 4; R.A <<= 4; R.A |= i; }
static void xch_a_r0(void)   { UINT8 i=R.A; R.A=R0; R0=i; }
static void xch_a_r1(void)   { UINT8 i=R.A; R.A=R1; R1=i; }
static void xch_a_r2(void)   { UINT8 i=R.A; R.A=R2; R2=i; }
static void xch_a_r3(void)   { UINT8 i=R.A; R.A=R3; R3=i; }
static void xch_a_r4(void)   { UINT8 i=R.A; R.A=R4; R4=i; }
static void xch_a_r5(void)   { UINT8 i=R.A; R.A=R5; R5=i; }
static void xch_a_r6(void)   { UINT8 i=R.A; R.A=R6; R6=i; }
static void xch_a_r7(void)   { UINT8 i=R.A; R.A=R7; R7=i; }
static void xch_a_xr0(void)  { UINT8 i=R.A; R.A=intRAM[R0 & INT_RAM_MASK]; intRAM[R0 & INT_RAM_MASK]=i; }
static void xch_a_xr1(void)  { UINT8 i=R.A; R.A=intRAM[R1 & INT_RAM_MASK]; intRAM[R1 & INT_RAM_MASK]=i; }
static void xchd_a_xr0(void) { M_XCHD(R0 & INT_RAM_MASK); }
static void xchd_a_xr1(void) { M_XCHD(R1 & INT_RAM_MASK); }
static void xrl_a_n(void)    { R.A ^= M_RDMEM_OPCODE(); }
static void xrl_a_r0(void)   { R.A ^= R0; }
static void xrl_a_r1(void)   { R.A ^= R1; }
static void xrl_a_r2(void)   { R.A ^= R2; }
static void xrl_a_r3(void)   { R.A ^= R3; }
static void xrl_a_r4(void)   { R.A ^= R4; }
static void xrl_a_r5(void)   { R.A ^= R5; }
static void xrl_a_r6(void)   { R.A ^= R6; }
static void xrl_a_r7(void)   { R.A ^= R7; }
static void xrl_a_xr0(void)  { R.A ^= intRAM[R0 & INT_RAM_MASK]; }
static void xrl_a_xr1(void)  { R.A ^= intRAM[R1 & INT_RAM_MASK]; }

static s_opcode opcode_main[256]=
{
    {1, nop        },{0, illegal    },{2, outl_bus_a },{2, add_a_n    },{2, jmp        },{1, en_i       },{0, illegal    },{1, dec_a      },
    {2, ins_a_bus  },{2, in_a_p1    },{2, in_a_p2    },{0, illegal    },{2, movd_a_p4  },{2, movd_a_p5  },{2, movd_a_p6  },{2, movd_a_p7  },
    {1, inc_xr0    },{1, inc_xr1    },{2, jb_0       },{2, adc_a_n    },{2, call       },{1, dis_i      },{2, jtf        },{1, inc_a      },
    {1, inc_r0     },{1, inc_r1     },{1, inc_r2     },{1, inc_r3     },{1, inc_r4     },{1, inc_r5     },{1, inc_r6     },{1, inc_r7     },
    {1, xch_a_xr0  },{1, xch_a_xr1  },{0, illegal    },{2, mov_a_n    },{2, jmp_1      },{1, en_tcnti   },{2, jnt_0      },{1, clr_a      },
    {1, xch_a_r0   },{1, xch_a_r1   },{1, xch_a_r2   },{1, xch_a_r3   },{1, xch_a_r4   },{1, xch_a_r5   },{1, xch_a_r6   },{1, xch_a_r7   },
    {1, xchd_a_xr0 },{1, xchd_a_xr1 },{2, jb_1       },{0, illegal    },{2, call_1     },{1, dis_tcnti  },{2, jt_0       },{1, cpl_a      },
    {0, illegal    },{2, outl_p1_a  },{2, outl_p2_a  },{0, illegal    },{2, movd_p4_a  },{2, movd_p5_a  },{2, movd_p6_a  },{2, movd_p7_a  },
    {1, orl_a_xr0  },{1, orl_a_xr1  },{1, mov_a_t    },{2, orl_a_n    },{2, jmp_2      },{1, strt_cnt   },{2, jnt_1      },{1, swap_a     },
    {1, orl_a_r0   },{1, orl_a_r1   },{1, orl_a_r2   },{1, orl_a_r3   },{1, orl_a_r4   },{1, orl_a_r5   },{1, orl_a_r6   },{1, orl_a_r7   },
    {1, anl_a_xr0  },{1, anl_a_xr1  },{2, jb_2       },{2, anl_a_n    },{2, call_2     },{1, strt_t     },{2, jt_1       },{1, daa_a      },
    {1, anl_a_r0   },{1, anl_a_r1   },{1, anl_a_r2   },{1, anl_a_r3   },{1, anl_a_r4   },{1, anl_a_r5   },{1, anl_a_r6   },{1, anl_a_r7   },
    {1, add_a_xr0  },{1, add_a_xr1  },{1, mov_t_a    },{0, illegal    },{2, jmp_3      },{1, stop_tcnt  },{0, illegal    },{1, rrc_a      },
    {1, add_a_r0   },{1, add_a_r1   },{1, add_a_r2   },{1, add_a_r3   },{1, add_a_r4   },{1, add_a_r5   },{1, add_a_r6   },{1, add_a_r7   },
    {1, adc_a_xr0  },{1, adc_a_xr1  },{2, jb_3       },{0, illegal    },{2, call_3     },{1, ento_clk   },{2, jf1        },{1, rr_a       },
    {1, adc_a_r0   },{1, adc_a_r1   },{1, adc_a_r2   },{1, adc_a_r3   },{1, adc_a_r4   },{1, adc_a_r5   },{1, adc_a_r6   },{1, adc_a_r7   },
    {2, movx_a_xr0 },{2, movx_a_xr1 },{0, illegal    },{2, ret        },{2, jmp_4      },{1, clr_f0     },{2, jni        },{0, illegal    },
    {2, orl_bus_n  },{2, orl_p1_n   },{2, orl_p2_n   },{0, illegal    },{2, orld_p4_a  },{2, orld_p5_a  },{2, orld_p6_a  },{2, orld_p7_a  },
    {2, movx_xr0_a },{2, movx_xr1_a },{2, jb_4       },{2, retr       },{2, call_4     },{1, cpl_f0     },{2, jnz        },{1, clr_c      },
    {2, anl_bus_n  },{2, anl_p1_n   },{2, anl_p2_n   },{0, illegal    },{2, anld_p4_a  },{2, anld_p5_a  },{2, anld_p6_a  },{2, anld_p7_a  },
    {1, mov_xr0_a  },{1, mov_xr1_a  },{0, illegal    },{2, movp_a_xa  },{2, jmp_5      },{1, clr_f1     },{0, illegal    },{1, cpl_c      },
    {1, mov_r0_a   },{1, mov_r1_a   },{1, mov_r2_a   },{1, mov_r3_a   },{1, mov_r4_a   },{1, mov_r5_a   },{1, mov_r6_a   },{1, mov_r7_a   },
    {2, mov_xr0_n  },{2, mov_xr1_n  },{2, jb_5       },{2, jmpp_xa    },{2, call_5     },{1, cpl_f1     },{2, jf0        },{0, illegal    },
    {2, mov_r0_n   },{2, mov_r1_n   },{2, mov_r2_n   },{2, mov_r3_n   },{2, mov_r4_n   },{2, mov_r5_n   },{2, mov_r6_n   },{2, mov_r7_n   },
    {0, illegal    },{0, illegal    },{0, illegal    },{0, illegal    },{2, jmp_6      },{1, sel_rb0    },{2, jz         },{1, mov_a_psw  },
    {1, dec_r0     },{1, dec_r1     },{1, dec_r2     },{1, dec_r3     },{1, dec_r4     },{1, dec_r5     },{1, dec_r6     },{1, dec_r7     },
    {1, xrl_a_xr0  },{1, xrl_a_xr1  },{2, jb_6       },{2, xrl_a_n    },{2, call_6     },{1, sel_rb1    },{0, illegal    },{1, mov_psw_a  },
    {1, xrl_a_r0   },{1, xrl_a_r1   },{1, xrl_a_r2   },{1, xrl_a_r3   },{1, xrl_a_r4   },{1, xrl_a_r5   },{1, xrl_a_r6   },{1, xrl_a_r7   },
    {0, illegal    },{0, illegal    },{0, illegal    },{2, movp3_a_xa },{2, jmp_7      },{1, sel_mb0    },{2, jnc        },{1, rl_a       },
    {2, djnz_r0    },{2, djnz_r1    },{2, djnz_r2    },{2, djnz_r3    },{2, djnz_r4    },{2, djnz_r5    },{2, djnz_r6    },{2, djnz_r7    },
    {1, mov_a_xr0  },{1, mov_a_xr1  },{2, jb_7       },{0, illegal    },{2, call_7     },{1, sel_mb1    },{2, jc         },{1, rlc_a      },
    {1, mov_a_r0   },{1, mov_a_r1   },{1, mov_a_r2   },{1, mov_a_r3   },{1, mov_a_r4   },{1, mov_a_r5   },{1, mov_a_r6   },{1, mov_a_r7   }
};


/****************************************************************************
 * Reset registers to their initial values
 ****************************************************************************/
void i8039_reset (void *param)
{
    R.PC.w.l = 0;
    R.SP  = 0;
    R.A   = 0;
    R.PSW = 0x08;       /* Start with Carry SET, Bit 4 is always SET */
    memset(R.RAM, 0x0, 128);
    R.P1  = 0xff;
    R.P2  = 0xff;
    R.bus = 0;
    R.irq_executing = I8039_NO_INT;
    R.pending_irq   = I8039_NO_INT;

    R.A11ff   = R.A11     = 0;
    R.tirq_en = R.xirq_en = 0;
    R.timerON = R.countON = 0;
    R.timerON = 1;  /* Mario Bros. doesn't work without this */
    R.irq_extra_cycles = 0;
    R.masterClock = 0;

    /* print dump header */
    printf("  Addr | Instruction        |  PC  Accu SP PSW BUS F1 P1 P2 A11 RAM\n");
    printf(" ------+--------------------+---------------------------------------\n");
}


/****************************************************************************
 * Shut down CPU emulation
 ****************************************************************************/
static void i8039_exit (void)
{
    /* nothing to do ? */
}

/****************************************************************************
 * Issue an interrupt if necessary
 ****************************************************************************/
static int Ext_IRQ(void)
{
    int extra_cycles = 0;

    if (R.xirq_en) {
        if (R.irq_executing == I8039_NO_INT) {
/*          logerror("I8039:  EXT INTERRUPT being serviced\n"); */
            R.irq_executing = I8039_EXTERNAL_INT;
            push(R.PC.b.l);
            push((R.PC.b.h & 0x0f) | (R.PSW & 0xf0));
            R.PC.w.l = 0x03;
            R.A11ff = R.A11;
            R.A11   = 0;

            extra_cycles = 2;       /* 2 clock cycles used */

            if (R.timerON)  /* NS990113 */
                R.masterClock += extra_cycles;
            if (R.irq_callback) (*R.irq_callback)(0);
        }
    }

    return extra_cycles;
}

static int Timer_IRQ(void)
{
    int extra_cycles = 0;

    if (R.tirq_en) {
        if (R.irq_executing == I8039_NO_INT) {
/*          logerror("I8039:  TIMER/COUNTER INTERRUPT\n"); */
            R.irq_executing = I8039_TIMCNT_INT;
            R.pending_irq &= ~I8039_TIMCNT_INT;
            push(R.PC.b.l);
            push((R.PC.b.h & 0x0f) | (R.PSW & 0xf0));
            R.PC.w.l = 0x07;
            R.A11ff = R.A11;
            R.A11   = 0;

            extra_cycles = 2;       /* 2 clock cycles used */

            if (R.timerON)  /* NS990113 */
                R.masterClock += extra_cycles;
        }
        else {
            if (R.irq_executing == I8039_EXTERNAL_INT) {
                R.pending_irq |= I8039_TIMCNT_INT;
            }
        }
    }

    R.t_flag = 1;

    return extra_cycles;
}


static void dump_machine_state(void)
{
  int i;

  printf("  | %04X  %02X  %02X %02X", (UINT32)R.PC.w.l, (UINT32)R.A, (UINT32)(R.SP >> 1), (UINT32)R.PSW);
  printf("  %02X  %X  %02X %02X",     (UINT32)R.bus, (UINT32)R.f1, (UINT32)R.P1, (UINT32)R.P2);
  printf(" %X  ",                     (UINT32)(R.A11ff >> 11));

  for (i = 0; i < 256; i++)
    printf(" %02X", R.RAM[i]);

  printf("\n");
}


enum {ACCU_IDLE, ACCU_HAS_AA, ACCU_HAS_55, ACCU_PASS, ACCU_FAIL};

/****************************************************************************
 * Execute cycles CPU cycles. Return number of cycles really executed
 ****************************************************************************/
int i8039_execute(int cycles, int dump)
{
    unsigned opcode, T1;
    int count, i;
    char buffer[64];
    char string[32];

    static int accu        = 0;
    static int accu_state  = ACCU_IDLE;

    i8039_ICount = (cycles - R.irq_extra_cycles);
    R.irq_extra_cycles = 0;

    if ((accu_state == ACCU_PASS) || (accu_state == ACCU_FAIL)) {
      printf("End of simulation detected\n");

      return(accu_state == ACCU_PASS ? 0 : -1);
    }

    do
    {
        R.PREVPC = R.PC;


        opcode=M_RDOP(R.PC.w.l);

        buffer[0] = '\0';
        Dasm8039(buffer, R.PC.w.l);
        sprintf(string, "  %04X : %s", R.PC.w.l, buffer);
        for (i = strlen(string); i < 26; i++)
          string[i] = ' ';
        string[i <= 31 ? i : 31] = '\0';
        printf("%s", string);

/*      logerror("I8039:  PC = %04x,  opcode = %02x\n", R.PC.w.l, opcode); */

        R.PC.w.l++;
        inst_cycles = opcode_main[opcode].cycles;
        (*(opcode_main[opcode].function))();
        i8039_ICount -= inst_cycles; /*/ */

        if (dump == 1) {
          /* dump machine state information */
          dump_machine_state();
        } else
          printf("\n");

        /* end-of-simulation check */
        if (accu != R.A) {
          accu = R.A;

          switch (accu_state) {
            case ACCU_IDLE:
              accu_state = accu == 0xaa ? ACCU_HAS_AA : ACCU_IDLE;
              break;

            case ACCU_HAS_AA:
              accu_state = accu == 0x55 ? ACCU_HAS_55 : ACCU_IDLE;
              break;

            case ACCU_HAS_55:
              switch (accu) {
                case 0x01:
                  accu_state = ACCU_PASS;
                  break;
                case 0x00:
                  accu_state = ACCU_FAIL;
                  break;
                default:
                  accu_state = ACCU_IDLE;
                  break;
              }
              break;

            case ACCU_PASS:
            case ACCU_FAIL:
              break;

            default:
              accu_state = ACCU_IDLE;
              break;
          }
        }




        if (R.countON)  /* NS990113 */
        {
            for ( ; inst_cycles > 0; inst_cycles-- )
            {
                T1 = test_r(1);
                if (NEGATIVE_EDGE_T1)
                {
                    R.timer++;
                    if (R.timer == 0) {
                        count = Timer_IRQ();    /* Handle Counter IRQ */
                        i8039_ICount -= count;
                    }
                }
                Old_T1 = T1;
            }
        }

        if (R.timerON) {
            R.masterClock += opcode_main[opcode].cycles;
            if (R.masterClock >= 32) {  /* NS990113 */
                R.masterClock -= 32;
                R.timer++;
                if (R.timer == 0) {
                    count = Timer_IRQ();    /* Handle Timer IRQ */
                    i8039_ICount -= count;
                }
            }
        }
    } while (i8039_ICount > 0 && accu_state != ACCU_PASS && accu_state != ACCU_FAIL);

    i8039_ICount -= R.irq_extra_cycles;
    R.irq_extra_cycles = 0;

    return cycles - i8039_ICount;
}

/****************************************************************************
 * Get all registers in given buffer
 ****************************************************************************/
static void i8039_get_context (void *dst)
{
    if( dst )
        *(I8039_Regs*)dst = R;
}


/****************************************************************************
 * Set all registers to given values
 ****************************************************************************/
static void i8039_set_context (void *src)
{
    if( src )
    {
        R = *(I8039_Regs*)src;
        regPTR = ((M_By) ? 24 : 0);
        R.SP = (R.PSW << 1) & 0x0f;
    }
    /* Handle forced Interrupts throught the Debugger */
    if (R.irq_state != I8039_NO_INT) {
        R.irq_extra_cycles += Ext_IRQ();        /* Handle External IRQ */
    }
    if (R.timer == 0) {
        R.irq_extra_cycles += Timer_IRQ();      /* Handle Timer IRQ */
    }
}


/****************************************************************************
 * Set IRQ line state
 ****************************************************************************/
void set_irq_line(int irqline, int state)
{
    if (state != CLEAR_LINE) {
        R.irq_state = I8039_EXTERNAL_INT;
        R.irq_extra_cycles += Ext_IRQ();        /* Handle External IRQ */
    }
    else {
        R.irq_state = I8039_NO_INT;
    }
}
