/*
 * cpu.c -- execute instructions
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "instr.h"
#include "cpu.h"
#include "mmu.h"
#include "start.h"


#define RR(n)		r[n]
#define WR(n,d)		((void) ((n) != 0 ? r[n] = (d) : (d)))

#define BREAK		((OP_TRAP << 26) | 0x0001)


/**************************************************************/


static Word pc;			/* program counter */
static Word psw;		/* processor status word */
static Word r[32];		/* general purpose registers */

static Bool breakSet;		/* breakpoint set if true */
static Word breakAddr;		/* if breakSet, this is where */


/**************************************************************/


Word cpuGetPC(void) {
  return pc;
}


void cpuSetPC(Word addr) {
  pc = addr;
}


Word cpuGetReg(int regnum) {
  return RR(regnum & 0x1F);
}


void cpuSetReg(int regnum, Word value) {
  WR(regnum & 0x1F, value);
}


Word cpuGetPSW(void) {
  return psw;
}


void cpuSetPSW(Word value) {
  psw = value;
}


Bool cpuTestBreak(void) {
  return breakSet;
}


Word cpuGetBreak(void) {
  return breakAddr;
}


void cpuSetBreak(Word addr) {
  breakAddr = addr;
  breakSet = true;
}


void cpuResetBreak(void) {
  breakSet = false;
}


/**************************************************************/


static char *cause[32] = {
  /*  0 */  "serial line 0 xmt interrupt",
  /*  1 */  "serial line 0 rcv interrupt",
  /*  2 */  "serial line 1 xmt interrupt",
  /*  3 */  "serial line 1 rcv interrupt",
  /*  4 */  "keyboard interrupt",
  /*  5 */  "unknown interrupt",
  /*  6 */  "unknown interrupt",
  /*  7 */  "unknown interrupt",
  /*  8 */  "disk interrupt",
  /*  9 */  "unknown interrupt",
  /* 10 */  "unknown interrupt",
  /* 11 */  "unknown interrupt",
  /* 12 */  "unknown interrupt",
  /* 13 */  "unknown interrupt",
  /* 14 */  "timer 0 interrupt",
  /* 15 */  "timer 1 interrupt",
  /* 16 */  "bus timeout exception",
  /* 17 */  "illegal instruction exception",
  /* 18 */  "privileged instruction exception",
  /* 19 */  "divide instruction exception",
  /* 20 */  "trap instruction exception",
  /* 21 */  "TLB miss exception",
  /* 22 */  "TLB write exception",
  /* 23 */  "TLB invalid exception",
  /* 24 */  "illegal address exception",
  /* 25 */  "privileged address exception",
  /* 26 */  "unknown exception",
  /* 27 */  "unknown exception",
  /* 28 */  "unknown exception",
  /* 29 */  "unknown exception",
  /* 30 */  "unknown exception",
  /* 31 */  "unknown exception"
};


char *exceptionToString(int exception) {
  if (exception < 0 ||
      exception >= sizeof(cause)/sizeof(cause[0])) {
    return "<exception number out of bounds>";
  }
  return cause[exception];
}


/**************************************************************/


static Byte stepType[64] = {
  /*          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  */
  /* 0x00 */  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  /* 0x10 */  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  /* 0x20 */  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 4, 3, 4, 1, 0,
  /* 0x30 */  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
};


static Bool evalCond(int cc, Word a, Word b) {
  switch (cc) {
    case 0:
      /* equal */
      if (a == b) {
        return true;
      }
      break;
    case 1:
      /* not equal */
      if (a != b) {
        return true;
      }
      break;
    case 2:
      /* less or equal (signed) */
      if ((signed int) a <= (signed int) b) {
        return true;
      }
      break;
    case 3:
      /* less or equal (unsigned) */
      if (a <= b) {
        return true;
      }
      break;
    case 4:
      /* less than (signed) */
      if ((signed int) a < (signed int) b) {
        return true;
      }
      break;
    case 5:
      /* less than (unsigned) */
      if (a < b) {
        return true;
      }
      break;
    case 6:
      /* greater or equal (signed) */
      if ((signed int) a >= (signed int) b) {
        return true;
      }
      break;
    case 7:
      /* greater or equal (unsigned) */
      if (a >= b) {
        return true;
      }
      break;
    case 8:
      /* greater than (signed) */
      if ((signed int) a > (signed int) b) {
        return true;
      }
      break;
    case 9:
      /* greater than (unsigned) */
      if (a > b) {
        return true;
      }
      break;
    default:
      /* this should never happen */
      printf("cannot compute condition code %d\n", cc);
      break;
  }
  return false;
}


void cpuStep(void) {
  Word instr;
  int opcode;
  int reg1, reg2;
  Half immed;
  Word offset;
  Word nextAddr;
  Word nextInstr;
  int i;
  MonitorState stepState;
  MonitorState *origReturn;

  instr = mmuReadWord(pc);
  opcode = (instr >> 26) & 0x3F;
  reg1 = (instr >> 21) & 0x1F;
  reg2 = (instr >> 16) & 0x1F;
  immed = instr & 0x0000FFFF;
  offset = instr & 0x03FFFFFF;
  switch (stepType[opcode]) {
    case 1:
      /* next instruction follows current one immediately */
      nextAddr = pc + 4;
      break;
    case 2:
      /* next instruction conditionally reached by PC relative branch */
      nextAddr = pc + 4;
      if (evalCond(opcode - OP_BEQ, RR(reg1), RR(reg2))) {
        nextAddr += SEXT16(immed) << 2;
      }
      break;
    case 3:
      /* next instruction reached by PC relative jump */
      nextAddr = pc + 4 + (SEXT26(offset) << 2);
      break;
    case 4:
      /* next instruction reached by jump to register contents */
      nextAddr = RR(reg1) & 0xFFFFFFFC;
      break;
    default:
      printf("cannot single-step instruction with opcode 0x%02X\n",
             opcode);
      return;
  }
  nextInstr = mmuReadWord(nextAddr);
  mmuWriteWord(nextAddr, BREAK);
  for (i = 0; i < 32; i++) {
    userContext.reg[i] = RR(i);
  }
  userContext.reg[30] = pc;
  userContext.psw = psw;
  userContext.tlbIndex = mmuGetIndex();
  userContext.tlbHi = mmuGetEntryHi();
  userContext.tlbLo = mmuGetEntryLo();
  userContext.badAddr = mmuGetBadAddr();
  userContext.badAccs = mmuGetBadAccs();
  if (saveState(&stepState)) {
    origReturn = monitorReturn;
    monitorReturn = &stepState;
    resume();
  }
  monitorReturn = origReturn;
  for (i = 0; i < 32; i++) {
    WR(i, userContext.reg[i]);
  }
  pc = userContext.reg[30];
  psw = userContext.psw;
  mmuSetIndex(userContext.tlbIndex);
  mmuSetEntryHi(userContext.tlbHi);
  mmuSetEntryLo(userContext.tlbLo);
  mmuSetBadAddr(userContext.badAddr);
  mmuSetBadAccs(userContext.badAccs);
  mmuWriteWord(nextAddr, nextInstr);
  if (nextAddr == pc) {
    return;
  }
  if ((psw & PSW_PRIO_MASK) >> 16 == 21 &&
      (mmuGetEntryHi() & 0x80000000) == 0) {
    /* TLB user miss */
    printf("unexpected TLB user miss exception occurred\n");
    return;
  } else {
    /* any other exception */
    printf("unexpected %s occurred\n",
           exceptionToString((psw & PSW_PRIO_MASK) >> 16));
    return;
  }
}


void cpuRun(void) {
  Word instr;
  int i;
  MonitorState runState;
  MonitorState *origReturn;

  if (breakSet && breakAddr == pc) {
    /* single-step one instruction */
    cpuStep();
  }
  while (1) {
    if (breakSet) {
      instr = mmuReadWord(breakAddr);
      mmuWriteWord(breakAddr, BREAK);
    }
    for (i = 0; i < 32; i++) {
      userContext.reg[i] = RR(i);
    }
    userContext.reg[30] = pc;
    userContext.psw = psw;
    userContext.tlbIndex = mmuGetIndex();
    userContext.tlbHi = mmuGetEntryHi();
    userContext.tlbLo = mmuGetEntryLo();
    userContext.badAddr = mmuGetBadAddr();
    userContext.badAccs = mmuGetBadAccs();
    if (saveState(&runState)) {
      origReturn = monitorReturn;
      monitorReturn = &runState;
      resume();
    }
    monitorReturn = origReturn;
    for (i = 0; i < 32; i++) {
      WR(i, userContext.reg[i]);
    }
    pc = userContext.reg[30];
    psw = userContext.psw;
    mmuSetIndex(userContext.tlbIndex);
    mmuSetEntryHi(userContext.tlbHi);
    mmuSetEntryLo(userContext.tlbLo);
    mmuSetBadAddr(userContext.badAddr);
    mmuSetBadAccs(userContext.badAccs);
    if (breakSet) {
      mmuWriteWord(breakAddr, instr);
    }
    if (breakSet && breakAddr == pc) {
      return;
    }
    if ((psw & PSW_PRIO_MASK) >> 16 == 21 &&
        (mmuGetEntryHi() & 0x80000000) == 0) {
      /* TLB user miss */
      printf("unexpected TLB user miss exception occurred\n");
      return;
    } else {
      /* any other exception */
      printf("unexpected %s occurred\n",
             exceptionToString((psw & PSW_PRIO_MASK) >> 16));
      return;
    }
  }
}
