/*
 * command.c -- command interpreter
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "except.h"
#include "command.h"
#include "asm.h"
#include "disasm.h"
#include "cpu.h"
#include "trace.h"
#include "mmu.h"
#include "memory.h"
#include "timer.h"
#include "dspkbd.h"
#include "serial.h"
#include "disk.h"
#include "output.h"
#include "shutdown.h"
#include "graph.h"


#define MAX_TOKENS	10


static Bool quit;


typedef struct {
  char *name;
  void (*hlpProc)(void);
  void (*cmdProc)(char *tokens[], int n);
} Command;

extern Command commands[];
extern int numCommands;


static void help(void) {
  cPrintf("valid commands are:\n");
  cPrintf("  help    get help\n");
  cPrintf("  +       add and subtract\n");
  cPrintf("  a       assemble\n");
  cPrintf("  u       unassemble\n");
  cPrintf("  b       set/reset breakpoint\n");
  cPrintf("  c       continue from breakpoint\n");
  cPrintf("  s       single-step\n");
  cPrintf("  #       show/set PC\n");
  cPrintf("  p       show/set PSW\n");
  cPrintf("  r       show/set register\n");
  cPrintf("  d       dump memory\n");
  cPrintf("  mw      show/set memory word\n");
  cPrintf("  mh      show/set memory halfword\n");
  cPrintf("  mb      show/set memory byte\n");
  cPrintf("  t       show/set TLB contents\n");
  cPrintf("  l       list trace buffer\n");
  cPrintf("  i       initialize hardware\n");
  cPrintf("  q       quit simulator\n");
  cPrintf("type 'help <cmd>' to get help for <cmd>\n");
}


static void help00(void) {
  cPrintf("  help              show a list of commands\n");
  cPrintf("  help <cmd>        show help for <cmd>\n");
}


static void help01(void) {
  cPrintf("  +  <num1> <num2>  add and subtract <num1> and <num2>\n");
}


static void help02(void) {
  cPrintf("  a                 assemble starting at PC\n");
  cPrintf("  a  <addr>         assemble starting at <addr>\n");
}


static void help03(void) {
  cPrintf("  u                 unassemble 16 instrs starting at PC\n");
  cPrintf("  u  <addr>         unassemble 16 instrs starting at <addr>\n");
  cPrintf("  u  <addr> <cnt>   unassemble <cnt> instrs starting at <addr>\n");
}


static void help04(void) {
  cPrintf("  b                 reset break\n");
  cPrintf("  b  <addr>         set break at <addr>\n");
}


static void help05(void) {
  cPrintf("  c                 continue execution\n");
  cPrintf("  c  <cnt>          continue execution <cnt> times\n");
}


static void help06(void) {
  cPrintf("  s                 single-step one instruction\n");
  cPrintf("  s  <cnt>          single-step <cnt> instructions\n");
}


static void help07(void) {
  cPrintf("  #                 show PC\n");
  cPrintf("  #  <addr>         set PC to <addr>\n");
}


static void help08(void) {
  cPrintf("  p                 show PSW\n");
  cPrintf("  p  <data>         set PSW to <data>\n");
}


static void help09(void) {
  cPrintf("  r                 show all registers\n");
  cPrintf("  r  <reg>          show register <reg>\n");
  cPrintf("  r  <reg> <data>   set register <reg> to <data>\n");
}


static void help10(void) {
  cPrintf("  d                 dump 256 bytes starting at PC\n");
  cPrintf("  d  <addr>         dump 256 bytes starting at <addr>\n");
  cPrintf("  d  <addr> <cnt>   dump <cnt> bytes starting at <addr>\n");
}


static void help11(void) {
  cPrintf("  mw                show memory word at PC\n");
  cPrintf("  mw <addr>         show memory word at <addr>\n");
  cPrintf("  mw <addr> <data>  set memory word at <addr> to <data>\n");
}


static void help12(void) {
  cPrintf("  mh                show memory halfword at PC\n");
  cPrintf("  mh <addr>         show memory halfword at <addr>\n");
  cPrintf("  mh <addr> <data>  set memory halfword at <addr> to <data>\n");
}


static void help13(void) {
  cPrintf("  mb                show memory byte at PC\n");
  cPrintf("  mb <addr>         show memory byte at <addr>\n");
  cPrintf("  mb <addr> <data>  set memory byte at <addr> to <data>\n");
}


static void help14(void) {
  cPrintf("  t                 show TLB contents\n");
  cPrintf("  t  <i>            show TLB contents at <i>\n");
  cPrintf("  t  <i> p <data>   set TLB contents at <i> to page <data>\n");
  cPrintf("  t  <i> f <data>   set TLB contents at <i> to frame <data>\n");
}


static void help15(void) {
  cPrintf("  l                 list 16 trace entries starting at -16\n");
  cPrintf("  l <i>             list 16 trace entries starting at <i>\n");
  cPrintf("  l <i> <cnt>       list <cnt> trace entries starting at <i>\n");
}


static void help16(void) {
  cPrintf("  i                 initialize hardware\n");
}


static void help17(void) {
  cPrintf("  q                 quit simulator\n");
}


static Bool getHexNumber(char *str, Word *valptr) {
  char *end;

  *valptr = strtoul(str, &end, 16);
  return *end == '\0';
}


static Bool getDecNumber(char *str, int *valptr) {
  char *end;

  *valptr = strtoul(str, &end, 10);
  return *end == '\0';
}


static void showPC(void) {
  Word pc, psw;
  Word instr;

  pc = cpuGetPC();
  psw = cpuGetPSW();
  instr = mmuReadWord(pc, psw & PSW_UM);
  cPrintf("PC   %08X     [PC]   %08X   %s\n",
          pc, instr, disasm(instr, pc));
}


static void showBreakAndTotal(void) {
  Word brk;
  Word tot;

  brk = cpuGetBreak();
  tot = cpuGetTotal();
  cPrintf("Brk  ");
  if (cpuTestBreak()) {
    cPrintf("%08X", brk);
  } else {
    cPrintf("--------");
  }
  cPrintf("     Total  %08X   instructions\n", tot);
}


static void showIRQ(void) {
  Word irq;
  int i;

  irq = cpuGetIRQ();
  cPrintf("IRQ                            ");
  for (i = 15; i >= 0; i--) {
    cPrintf("%c", irq & (1 << i) ? '1' : '0');
  }
  cPrintf("\n");
}


static void showPSW(void) {
  Word psw;
  int i;

  psw = cpuGetPSW();
  cPrintf("     xxxx  V  UPO  IPO  IACK   MASK\n");
  cPrintf("PSW  ");
  for (i = 31; i >= 0; i--) {
    if (i == 27 || i == 26 || i == 23 || i == 20 || i == 15) {
      cPrintf("  ");
    }
    cPrintf("%c", psw & (1 << i) ? '1' : '0');
  }
  cPrintf("\n");
}


static void doHelp(char *tokens[], int n) {
  int i;

  if (n == 1) {
    help();
  } else if (n == 2) {
    for (i = 0; i < numCommands; i++) {
      if (strcmp(commands[i].name, tokens[1]) == 0) {
        (*commands[i].hlpProc)();
        return;
      }
    }
    cPrintf("no help available for '%s', sorry\n", tokens[1]);
  } else {
    help00();
  }
}


static void doArith(char *tokens[], int n) {
  Word num1, num2, num3, num4;

  if (n == 3) {
    if (!getHexNumber(tokens[1], &num1)) {
      cPrintf("illegal first number\n");
      return;
    }
    if (!getHexNumber(tokens[2], &num2)) {
      cPrintf("illegal second number\n");
      return;
    }
    num3 = num1 + num2;
    num4 = num1 - num2;
    cPrintf("add = %08X, sub = %08X\n", num3, num4);
  } else {
    help01();
  }
}


static void doAssemble(char *tokens[], int n) {
  Word addr;
  Word psw;
  char prompt[30];
  char *line;
  char *msg;
  Word instr;

  if (n == 1) {
    addr = cpuGetPC();
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
  } else {
    help02();
    return;
  }
  addr &= ~0x00000003;
  psw = cpuGetPSW();
  while (1) {
    sprintf(prompt, "ASM # %08X: ", addr);
    line = cGetLine(prompt);
    if (*line == '\0' || *line == '\n') {
      break;
    }
    cAddHist(line);
    msg = asmInstr(line, addr, &instr);
    if (msg != NULL) {
      cPrintf("%s\n", msg);
    } else {
      mmuWriteWord(addr, instr, psw & PSW_UM);
      addr += 4;
    }
  }
}


static void doUnassemble(char *tokens[], int n) {
  Word addr, count;
  Word psw;
  int i;
  Word instr;

  if (n == 1) {
    addr = cpuGetPC();
    count = 16;
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    count = 16;
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &count)) {
      cPrintf("illegal count\n");
      return;
    }
    if (count == 0) {
      return;
    }
  } else {
    help03();
    return;
  }
  addr &= ~0x00000003;
  psw = cpuGetPSW();
  for (i = 0; i < count; i++) {
    instr = mmuReadWord(addr, psw & PSW_UM);
    cPrintf("%08X:  %08X    %s\n",
            addr, instr, disasm(instr, addr));
    if (addr + 4 < addr) {
      /* wrap-around */
      break;
    }
    addr += 4;
  }
}


static void doBreak(char *tokens[], int n) {
  Word addr;

  if (n == 1) {
    cpuResetBreak();
    showBreakAndTotal();
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    addr &= ~0x00000003;
    cpuSetBreak(addr);
    showBreakAndTotal();
  } else {
    help04();
  }
}


static void doContinue(char *tokens[], int n) {
  Word count, i;
  Word addr;

  if (n == 1) {
    count = 1;
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &count) || count == 0) {
      cPrintf("illegal count\n");
      return;
    }
  } else {
    help05();
    return;
  }
  cPrintf("CPU is running, press ^C to interrupt...\n");
  for (i = 0; i < count; i++) {
    cpuRun();
  }
  addr = cpuGetPC();
  cPrintf("Break at %08X\n", addr);
  showPC();
}


static void doStep(char *tokens[], int n) {
  Word count, i;

  if (n == 1) {
    count = 1;
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &count) || count == 0) {
      cPrintf("illegal count\n");
      return;
    }
  } else {
    help06();
    return;
  }
  for (i = 0; i < count; i++) {
    cpuStep();
  }
  showPC();
}


static void doPC(char *tokens[], int n) {
  Word addr;

  if (n == 1) {
    showPC();
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    addr &= ~0x00000003;
    cpuSetPC(addr);
    showPC();
  } else {
    help07();
  }
}


static void explainPSW(Word data) {
  int i;

  cPrintf("interrupt vector                   : %s (%s)\n",
          data & PSW_V ? "on " : "off",
          data & PSW_V ? "RAM" : "ROM");
  cPrintf("current user mode                  : %s (%s)\n",
          data & PSW_UM ? "on " : "off",
          data & PSW_UM ? "user" : "kernel");
  cPrintf("previous user mode                 : %s (%s)\n",
          data & PSW_PUM ? "on " : "off",
          data & PSW_PUM ? "user" : "kernel");
  cPrintf("old user mode                      : %s (%s)\n",
          data & PSW_OUM ? "on " : "off",
          data & PSW_OUM ? "user" : "kernel");
  cPrintf("current interrupt enable           : %s (%s)\n",
          data & PSW_IE ? "on " : "off",
          data & PSW_IE ? "enabled" : "disabled");
  cPrintf("previous interrupt enable          : %s (%s)\n",
          data & PSW_PIE ? "on " : "off",
          data & PSW_PIE ? "enabled" : "disabled");
  cPrintf("old interrupt enable               : %s (%s)\n",
          data & PSW_OIE ? "on " : "off",
          data & PSW_OIE ? "enabled" : "disabled");
  cPrintf("last interrupt acknowledged        : %02d  (%s)\n",
          (data & PSW_PRIO_MASK) >> 16,
          exceptionToString((data & PSW_PRIO_MASK) >> 16));
  for (i = 15; i >= 0; i--) {
    cPrintf("%-35s: %s (%s)\n",
            exceptionToString(i),
            data & (1 << i) ? "on " : "off",
            data & (1 << i) ? "enabled" : "disabled");
  }
}


static void doPSW(char *tokens[], int n) {
  Word data;

  if (n == 1) {
    data = cpuGetPSW();
    showPSW();
    showIRQ();
    explainPSW(data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &data)) {
      cPrintf("illegal data\n");
      return;
    }
    data &= 0x0FFFFFFF;
    cpuSetPSW(data);
    showPSW();
    showIRQ();
    explainPSW(data);
  } else {
    help08();
  }
}


static void doRegister(char *tokens[], int n) {
  int i, j;
  int reg;
  Word data;

  if (n == 1) {
    for (i = 0; i < 8; i++) {
      for (j = 0; j < 4; j++) {
        reg = 8 * j + i;
        data = cpuGetReg(reg);
        cPrintf("$%-2d  %08X     ", reg, data);
      }
      cPrintf("\n");
    }
    showPSW();
    showIRQ();
    showBreakAndTotal();
    showPC();
  } else if (n == 2) {
    if (!getDecNumber(tokens[1], &reg) || reg < 0 || reg >= 32) {
      cPrintf("illegal register number\n");
      return;
    }
    data = cpuGetReg(reg);
    cPrintf("$%-2d  %08X\n", reg, data);
  } else if (n == 3) {
    if (!getDecNumber(tokens[1], &reg) || reg < 0 || reg >= 32) {
      cPrintf("illegal register number\n");
      return;
    }
    if (!getHexNumber(tokens[2], &data)) {
      cPrintf("illegal data\n");
      return;
    }
    cpuSetReg(reg, data);
  } else {
    help09();
  }
}


static void doDump(char *tokens[], int n) {
  Word addr, count;
  Word psw;
  Word lo, hi, curr;
  int lines, i, j;
  Word tmp;
  Byte c;

  if (n == 1) {
    addr = cpuGetPC();
    count = 16 * 16;
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    count = 16 * 16;
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &count)) {
      cPrintf("illegal count\n");
      return;
    }
    if (count == 0) {
      return;
    }
  } else {
    help10();
    return;
  }
  psw = cpuGetPSW();
  lo = addr & ~0x0000000F;
  hi = addr + count - 1;
  if (hi < lo) {
    /* wrap-around */
    hi = 0xFFFFFFFF;
  }
  lines = (hi - lo + 16) >> 4;
  curr = lo;
  for (i = 0; i < lines; i++) {
    cPrintf("%08X:  ", curr);
    for (j = 0; j < 16; j++) {
      tmp = curr + j;
      if (tmp < addr || tmp > hi) {
        cPrintf("  ");
      } else {
        c = mmuReadByte(tmp, psw & PSW_UM);
        cPrintf("%02X", c);
      }
      cPrintf(" ");
    }
    cPrintf("  ");
    for (j = 0; j < 16; j++) {
      tmp = curr + j;
      if (tmp < addr || tmp > hi) {
        cPrintf(" ");
      } else {
        c = mmuReadByte(tmp, psw & PSW_UM);
        if (c >= 32 && c <= 126) {
          cPrintf("%c", c);
        } else {
          cPrintf(".");
        }
      }
    }
    cPrintf("\n");
    curr += 16;
  }
}


static void doMemoryWord(char *tokens[], int n) {
  Word psw;
  Word addr;
  Word data;
  Word tmpData;

  psw = cpuGetPSW();
  if (n == 1) {
    addr = cpuGetPC();
    data = mmuReadWord(addr, psw & PSW_UM);
    cPrintf("%08X:  %08X\n", addr, data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    data = mmuReadWord(addr, psw & PSW_UM);
    cPrintf("%08X:  %08X\n", addr, data);
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &tmpData)) {
      cPrintf("illegal data\n");
      return;
    }
    data = tmpData;
    mmuWriteWord(addr, data, psw & PSW_UM);
  } else {
    help11();
  }
}


static void doMemoryHalf(char *tokens[], int n) {
  Word psw;
  Word addr;
  Half data;
  Word tmpData;

  psw = cpuGetPSW();
  if (n == 1) {
    addr = cpuGetPC();
    data = mmuReadHalf(addr, psw & PSW_UM);
    cPrintf("%08X:  %04X\n", addr, data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    data = mmuReadHalf(addr, psw & PSW_UM);
    cPrintf("%08X:  %04X\n", addr, data);
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &tmpData)) {
      cPrintf("illegal data\n");
      return;
    }
    data = (Half) tmpData;
    mmuWriteHalf(addr, data, psw & PSW_UM);
  } else {
    help12();
  }
}


static void doMemoryByte(char *tokens[], int n) {
  Word psw;
  Word addr;
  Byte data;
  Word tmpData;

  psw = cpuGetPSW();
  if (n == 1) {
    addr = cpuGetPC();
    data = mmuReadByte(addr, psw & PSW_UM);
    cPrintf("%08X:  %02X\n", addr, data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    data = mmuReadByte(addr, psw & PSW_UM);
    cPrintf("%08X:  %02X\n", addr, data);
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      cPrintf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &tmpData)) {
      cPrintf("illegal data\n");
      return;
    }
    data = (Byte) tmpData;
    mmuWriteByte(addr, data, psw & PSW_UM);
  } else {
    help13();
  }
}


static void doTLB(char *tokens[], int n) {
  static char *mmuAccsWidth[4] = { "byte", "half", "word", "????" };
  int index;
  TLB_Entry tlbEntry;
  Word mmuAccs;
  Word data;

  if (n == 1) {
    for (index = 0; index < TLB_SIZE; index++) {
      tlbEntry = mmuGetTLB(index);
      cPrintf("TLB[%02d]    page  %08X    frame  %08X  %c  %c\n",
              index, tlbEntry.page, tlbEntry.frame,
              tlbEntry.write ? 'w' : '-',
              tlbEntry.valid ? 'v' : '-');
    }
    cPrintf("Index   (1)  %08X\n", mmuGetIndex());
    cPrintf("EntryHi (2)  %08X\n", mmuGetEntryHi());
    cPrintf("EntryLo (3)  %08X\n", mmuGetEntryLo());
    cPrintf("BadAddr (4)  %08X\n", mmuGetBadAddr());
    mmuAccs = mmuGetBadAccs();
    cPrintf("BadAccs (5)  %08X (%s %s)\n",
            mmuAccs,
            (mmuAccs & MMU_ACCS_WRITE) ? "write" : "read",
            mmuAccsWidth[mmuAccs & 0x03]);
  } else if (n == 2) {
    if (!getDecNumber(tokens[1], &index) || index < 0 || index >= TLB_SIZE) {
      cPrintf("illegal TLB index\n");
      return;
    }
    tlbEntry = mmuGetTLB(index);
    cPrintf("TLB[%02d]    page  %08X    frame  %08X  %c  %c\n",
            index, tlbEntry.page, tlbEntry.frame,
            tlbEntry.write ? 'w' : '-',
            tlbEntry.valid ? 'v' : '-');
  } else if (n == 3) {
    help14();
  } else if (n == 4) {
    if (!getDecNumber(tokens[1], &index) || index < 0 || index >= TLB_SIZE) {
      cPrintf("illegal TLB index\n");
      return;
    }
    if (!getHexNumber(tokens[3], &data)) {
      cPrintf("illegal data\n");
      return;
    }
    tlbEntry = mmuGetTLB(index);
    if (strcmp(tokens[2], "p") == 0) {
      tlbEntry.page = data & PAGE_MASK;
    } else
    if (strcmp(tokens[2], "f") == 0) {
      tlbEntry.frame = data & PAGE_MASK;
      tlbEntry.write = data & TLB_WRITE ? true : false;
      tlbEntry.valid = data & TLB_VALID ? true : false;
    } else {
      cPrintf("TLB selector is not one of 'p' or 'f'\n");
      return;
    }
    mmuSetTLB(index, tlbEntry);
    cPrintf("TLB[%02d]    page  %08X    frame  %08X  %c  %c\n",
            index, tlbEntry.page, tlbEntry.frame,
            tlbEntry.write ? 'w' : '-',
            tlbEntry.valid ? 'v' : '-');
  } else {
    help14();
  }
}


static void doList(char *tokens[], int n) {
  int start, count, stop;
  int back;

  if (n == 1) {
    start = 16;
    count = 16;
  } else if (n == 2) {
    if (!getDecNumber(tokens[1], &start) || start >= 0) {
      cPrintf("illegal trace buffer index (must be < 0)\n");
      return;
    }
    start = -start;
    count = 16;
  } else if (n == 3) {
    if (!getDecNumber(tokens[1], &start) || start >= 0) {
      cPrintf("illegal trace buffer index (must be < 0)\n");
      return;
    }
    start = -start;
    if (!getDecNumber(tokens[2], &count) || count <= 0) {
      cPrintf("illegal trace buffer count (must be > 0)\n");
      return;
    }
  } else {
    help15();
    return;
  }
  if (start > TRACE_BUF_SIZE) {
    start = TRACE_BUF_SIZE;
  }
  stop = start - count;
  if (stop < 0) {
    stop = 0;
  }
  for (back = start; back > stop; back--) {
    cPrintf("trace[%5d]:  %s\n", -back, traceShow(back));
  }
}


static void doInit(char *tokens[], int n) {
  if (n == 1) {
    timerReset();
    displayReset();
    keyboardReset();
    serialReset();
    diskReset();
    outputReset();
    shutdownReset();
    graphReset();
    memoryReset();
    mmuReset();
    cpuReset();
  } else {
    help16();
  }
}


static void doQuit(char *tokens[], int n) {
  if (n == 1) {
    quit = true;
  } else {
    help17();
  }
}


Command commands[] = {
  { "help", help00, doHelp       },
  { "+",    help01, doArith      },
  { "a",    help02, doAssemble   },
  { "u",    help03, doUnassemble },
  { "b",    help04, doBreak      },
  { "c",    help05, doContinue   },
  { "s",    help06, doStep       },
  { "#",    help07, doPC         },
  { "p",    help08, doPSW        },
  { "r",    help09, doRegister   },
  { "d",    help10, doDump       },
  { "mw",   help11, doMemoryWord },
  { "mh",   help12, doMemoryHalf },
  { "mb",   help13, doMemoryByte },
  { "t",    help14, doTLB        },
  { "l",    help15, doList       },
  { "i",    help16, doInit       },
  { "q",    help17, doQuit       },
};

int numCommands = sizeof(commands) / sizeof(commands[0]);


static Bool doCommand(char *line) {
  char *tokens[MAX_TOKENS];
  int n;
  char *p;
  int i;

  n = 0;
  p = strtok(line, " \t\n");
  while (p != NULL) {
    if (n == MAX_TOKENS) {
      cPrintf("too many tokens on line\n");
      return false;
    }
    tokens[n++] = p;
    p = strtok(NULL, " \t\n");
  }
  if (n == 0) {
    return false;
  }
  quit = false;
  for (i = 0; i < sizeof(commands)/sizeof(commands[0]); i++) {
    if (strcmp(commands[i].name, tokens[0]) == 0) {
      (*commands[i].cmdProc)(tokens, n);
      return quit;
    }
  }
  help();
  return false;
}


static char *article(char firstLetterOfNoun) {
  switch (firstLetterOfNoun) {
    case 'a':
    case 'e':
    case 'i':
    case 'o':
    case 'u':
      return "An";
    default:
      return "A";
  }
}


static void interactiveException(int exception) {
  char *what;

  what = exceptionToString(exception);
  cPrintf("\n");
  cPrintf("NOTE: %s %s occurred while executing the command.\n",
          article(*what), what);
  cPrintf("      This event will not alter the state of the CPU.\n");
}


Bool execCommand(char *line) {
  jmp_buf myEnvironment;
  int exception;
  Bool quit;

  exception = setjmp(myEnvironment);
  if (exception == 0) {
    /* initialization */
    pushEnvironment(&myEnvironment);
    quit = doCommand(line);
  } else {
    /* an exception was thrown */
    interactiveException(exception);
    quit = false;
  }
  popEnvironment();
  return quit;
}
