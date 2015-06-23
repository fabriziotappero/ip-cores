/*
 * command.c -- command interpreter
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "getline.h"
#include "command.h"
#include "asm.h"
#include "disasm.h"
#include "load.h"
#include "boot.h"
#include "cpu.h"
#include "mmu.h"
#include "start.h"


#define MAX_TOKENS	10


typedef struct {
  char *name;
  void (*hlpProc)(void);
  void (*cmdProc)(char *tokens[], int n);
} Command;

extern Command commands[];
extern int numCommands;


static void help(void) {
  printf("valid commands are:\n");
  printf("  help    get help\n");
  printf("  +       add and subtract\n");
  printf("  a       assemble\n");
  printf("  u       unassemble\n");
  printf("  b       set/reset breakpoint\n");
  printf("  c       continue from breakpoint\n");
  printf("  s       single-step\n");
  printf("  #       show/set PC\n");
  printf("  p       show/set PSW\n");
  printf("  r       show/set register\n");
  printf("  d       dump memory\n");
  printf("  mw      show/set memory word\n");
  printf("  mh      show/set memory halfword\n");
  printf("  mb      show/set memory byte\n");
  printf("  t       show/set TLB contents\n");
  printf("  load    load from serial line\n");
  printf("  boot    bootstrap from disk\n");
  printf("type 'help <cmd>' to get help for <cmd>\n");
}


static void help00(void) {
  printf("  help              show a list of commands\n");
  printf("  help <cmd>        show help for <cmd>\n");
}


static void help01(void) {
  printf("  +  <num1> <num2>  add and subtract <num1> and <num2>\n");
}


static void help02(void) {
  printf("  a                 assemble starting at PC\n");
  printf("  a  <addr>         assemble starting at <addr>\n");
}


static void help03(void) {
  printf("  u                 unassemble 16 instrs starting at PC\n");
  printf("  u  <addr>         unassemble 16 instrs starting at <addr>\n");
  printf("  u  <addr> <cnt>   unassemble <cnt> instrs starting at <addr>\n");
}


static void help04(void) {
  printf("  b                 reset break\n");
  printf("  b  <addr>         set break at <addr>\n");
}


static void help05(void) {
  printf("  c                 continue execution\n");
  printf("  c  <cnt>          continue execution <cnt> times\n");
}


static void help06(void) {
  printf("  s                 single-step one instruction\n");
  printf("  s  <cnt>          single-step <cnt> instructions\n");
}


static void help07(void) {
  printf("  #                 show PC\n");
  printf("  #  <addr>         set PC to <addr>\n");
}


static void help08(void) {
  printf("  p                 show PSW\n");
  printf("  p  <data>         set PSW to <data>\n");
}


static void help09(void) {
  printf("  r                 show all registers\n");
  printf("  r  <reg>          show register <reg>\n");
  printf("  r  <reg> <data>   set register <reg> to <data>\n");
}


static void help10(void) {
  printf("  d                 dump 256 bytes starting at PC\n");
  printf("  d  <addr>         dump 256 bytes starting at <addr>\n");
  printf("  d  <addr> <cnt>   dump <cnt> bytes starting at <addr>\n");
}


static void help11(void) {
  printf("  mw                show memory word at PC\n");
  printf("  mw <addr>         show memory word at <addr>\n");
  printf("  mw <addr> <data>  set memory word at <addr> to <data>\n");
}


static void help12(void) {
  printf("  mh                show memory halfword at PC\n");
  printf("  mh <addr>         show memory halfword at <addr>\n");
  printf("  mh <addr> <data>  set memory halfword at <addr> to <data>\n");
}


static void help13(void) {
  printf("  mb                show memory byte at PC\n");
  printf("  mb <addr>         show memory byte at <addr>\n");
  printf("  mb <addr> <data>  set memory byte at <addr> to <data>\n");
}


static void help14(void) {
  printf("  t                 show TLB contents\n");
  printf("  t  <i>            show TLB contents at <i>\n");
  printf("  t  <i> p <data>   set TLB contents at <i> to page <data>\n");
  printf("  t  <i> f <data>   set TLB contents at <i> to frame <data>\n");
}


static void help15(void) {
  printf("  load <n>          load/start S-records from serial line <n>\n");
  printf("  load <n> *        load S-records from serial line <n>\n");
}


static void help16(void) {
  printf("  boot <n>          load/start first sector of disk <n>\n");
  printf("  boot <n> *        load first sector of disk <n>\n");
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
  instr = mmuReadWord(pc);
  printf("PC   %08X     [PC]   %08X   %s\n",
         pc, instr, disasm(instr, pc));
}


static void showBreak(void) {
  Word brk;

  brk = cpuGetBreak();
  printf("brk  ");
  if (cpuTestBreak()) {
    printf("%08X", brk);
  } else {
    printf("--------");
  }
  printf("\n");
}


static void showPSW(void) {
  Word psw;
  int i;

  psw = cpuGetPSW();
  printf("     xxxx  V  UPO  IPO  IACK   MASK\n");
  printf("PSW  ");
  for (i = 31; i >= 0; i--) {
    if (i == 27 || i == 26 || i == 23 || i == 20 || i == 15) {
      printf("  ");
    }
    printf("%c", psw & (1 << i) ? '1' : '0');
  }
  printf("\n");
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
    printf("no help available for '%s', sorry\n", tokens[1]);
  } else {
    help00();
  }
}


static void doArith(char *tokens[], int n) {
  Word num1, num2, num3, num4;

  if (n == 3) {
    if (!getHexNumber(tokens[1], &num1)) {
      printf("illegal first number\n");
      return;
    }
    if (!getHexNumber(tokens[2], &num2)) {
      printf("illegal second number\n");
      return;
    }
    num3 = num1 + num2;
    num4 = num1 - num2;
    printf("add = %08X, sub = %08X\n", num3, num4);
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
      printf("illegal address\n");
      return;
    }
  } else {
    help02();
    return;
  }
  addr &= 0xFFFFFFFC;
  psw = cpuGetPSW();
  while (1) {
    sprintf(prompt, "ASM # %08X: ", addr);
    line = getLine(prompt);
    if (*line == '\0' || *line == '\n') {
      break;
    }
    addHist(line);
    msg = asmInstr(line, addr, &instr);
    if (msg != NULL) {
      printf("%s\n", msg);
    } else {
      mmuWriteWord(addr, instr);
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
      printf("illegal address\n");
      return;
    }
    count = 16;
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &count)) {
      printf("illegal count\n");
      return;
    }
    if (count == 0) {
      return;
    }
  } else {
    help03();
    return;
  }
  addr &= 0xFFFFFFFC;
  psw = cpuGetPSW();
  for (i = 0; i < count; i++) {
    instr = mmuReadWord(addr);
    printf("%08X:  %08X    %s\n",
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
    showBreak();
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    addr &= 0xFFFFFFFC;
    cpuSetBreak(addr);
    showBreak();
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
      printf("illegal count\n");
      return;
    }
  } else {
    help05();
    return;
  }
  for (i = 0; i < count; i++) {
    cpuRun();
  }
  addr = cpuGetPC();
  printf("break at %08X\n", addr);
  showPC();
}


static void doStep(char *tokens[], int n) {
  Word count, i;

  if (n == 1) {
    count = 1;
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &count) || count == 0) {
      printf("illegal count\n");
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
      printf("illegal address\n");
      return;
    }
    addr &= 0xFFFFFFFC;
    cpuSetPC(addr);
    showPC();
  } else {
    help07();
  }
}


static void explainPSW(Word data) {
  int i;

  printf("interrupt vector                   : %s (%s)\n",
         data & PSW_V ? "on " : "off",
         data & PSW_V ? "RAM" : "ROM");
  printf("current user mode                  : %s (%s)\n",
         data & PSW_UM ? "on " : "off",
         data & PSW_UM ? "user" : "kernel");
  printf("previous user mode                 : %s (%s)\n",
         data & PSW_PUM ? "on " : "off",
         data & PSW_PUM ? "user" : "kernel");
  printf("old user mode                      : %s (%s)\n",
         data & PSW_OUM ? "on " : "off",
         data & PSW_OUM ? "user" : "kernel");
  printf("current interrupt enable           : %s (%s)\n",
         data & PSW_IE ? "on " : "off",
         data & PSW_IE ? "enabled" : "disabled");
  printf("previous interrupt enable          : %s (%s)\n",
         data & PSW_PIE ? "on " : "off",
         data & PSW_PIE ? "enabled" : "disabled");
  printf("old interrupt enable               : %s (%s)\n",
         data & PSW_OIE ? "on " : "off",
         data & PSW_OIE ? "enabled" : "disabled");
  printf("last interrupt acknowledged        : %02X  (%s)\n",
         (data & PSW_PRIO_MASK) >> 16,
         exceptionToString((data & PSW_PRIO_MASK) >> 16));
  for (i = 15; i >= 0; i--) {
    printf("%-35s: %s (%s)\n",
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
    explainPSW(data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &data)) {
      printf("illegal data\n");
      return;
    }
    data &= 0x0FFFFFFF;
    cpuSetPSW(data);
    showPSW();
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
        printf("$%-2d  %08X     ", reg, data);
      }
      printf("\n");
    }
    showPSW();
    showBreak();
    showPC();
  } else if (n == 2) {
    if (!getDecNumber(tokens[1], &reg) || reg < 0 || reg >= 32) {
      printf("illegal register number\n");
      return;
    }
    data = cpuGetReg(reg);
    printf("$%-2d  %08X\n", reg, data);
  } else if (n == 3) {
    if (!getDecNumber(tokens[1], &reg) || reg < 0 || reg >= 32) {
      printf("illegal register number\n");
      return;
    }
    if (!getHexNumber(tokens[2], &data)) {
      printf("illegal data\n");
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
      printf("illegal address\n");
      return;
    }
    count = 16 * 16;
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &count)) {
      printf("illegal count\n");
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
  lo = addr & 0xFFFFFFF0;
  hi = addr + count - 1;
  if (hi < lo) {
    /* wrap-around */
    hi = 0xFFFFFFFF;
  }
  lines = (hi - lo + 16) >> 4;
  curr = lo;
  for (i = 0; i < lines; i++) {
    printf("%08X:  ", curr);
    for (j = 0; j < 16; j++) {
      tmp = curr + j;
      if (tmp < addr || tmp > hi) {
        printf("  ");
      } else {
        c = mmuReadByte(tmp);
        printf("%02X", c);
      }
      printf(" ");
    }
    printf("  ");
    for (j = 0; j < 16; j++) {
      tmp = curr + j;
      if (tmp < addr || tmp > hi) {
        printf(" ");
      } else {
        c = mmuReadByte(tmp);
        if (c >= 32 && c <= 126) {
          printf("%c", c);
        } else {
          printf(".");
        }
      }
    }
    printf("\n");
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
    data = mmuReadWord(addr);
    printf("%08X:  %08X\n", addr, data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    data = mmuReadWord(addr);
    printf("%08X:  %08X\n", addr, data);
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &tmpData)) {
      printf("illegal data\n");
      return;
    }
    data = tmpData;
    mmuWriteWord(addr, data);
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
    data = mmuReadHalf(addr);
    printf("%08X:  %04X\n", addr, data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    data = mmuReadHalf(addr);
    printf("%08X:  %04X\n", addr, data);
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &tmpData)) {
      printf("illegal data\n");
      return;
    }
    data = (Half) tmpData;
    mmuWriteHalf(addr, data);
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
    data = mmuReadByte(addr);
    printf("%08X:  %02X\n", addr, data);
  } else if (n == 2) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    data = mmuReadByte(addr);
    printf("%08X:  %02X\n", addr, data);
  } else if (n == 3) {
    if (!getHexNumber(tokens[1], &addr)) {
      printf("illegal address\n");
      return;
    }
    if (!getHexNumber(tokens[2], &tmpData)) {
      printf("illegal data\n");
      return;
    }
    data = (Byte) tmpData;
    mmuWriteByte(addr, data);
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
      printf("TLB[%02d]    page  %08X    frame  %08X  %c  %c\n",
             index, tlbEntry.page, tlbEntry.frame,
             tlbEntry.write ? 'w' : '-',
             tlbEntry.valid ? 'v' : '-');
    }
    printf("Index   (1)  %08X\n", mmuGetIndex());
    printf("EntryHi (2)  %08X\n", mmuGetEntryHi());
    printf("EntryLo (3)  %08X\n", mmuGetEntryLo());
    printf("BadAddr (4)  %08X\n", mmuGetBadAddr());
    mmuAccs = mmuGetBadAccs();
    printf("BadAccs (5)  %08X (%s %s)\n",
           mmuAccs,
           (mmuAccs & MMU_ACCS_WRITE) ? "write" : "read",
           mmuAccsWidth[mmuAccs & 0x03]);
  } else if (n == 2) {
    if (!getDecNumber(tokens[1], &index) || index < 0 || index >= TLB_SIZE) {
      printf("illegal TLB index\n");
      return;
    }
    tlbEntry = mmuGetTLB(index);
    printf("TLB[%02d]    page  %08X    frame  %08X  %c  %c\n",
           index, tlbEntry.page, tlbEntry.frame,
           tlbEntry.write ? 'w' : '-',
           tlbEntry.valid ? 'v' : '-');
  } else if (n == 3) {
    help14();
  } else if (n == 4) {
    if (!getDecNumber(tokens[1], &index) || index < 0 || index >= TLB_SIZE) {
      printf("illegal TLB index\n");
      return;
    }
    if (!getHexNumber(tokens[3], &data)) {
      printf("illegal data\n");
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
      printf("TLB selector is not one of 'p' or 'f'\n");
      return;
    }
    mmuSetTLB(index, tlbEntry);
    printf("TLB[%02d]    page  %08X    frame  %08X  %c  %c\n",
           index, tlbEntry.page, tlbEntry.frame,
           tlbEntry.write ? 'w' : '-',
           tlbEntry.valid ? 'v' : '-');
  } else {
    help14();
  }
}


static void doLoad(char *tokens[], int n) {
  int serno;

  if (n == 2) {
    if (!getDecNumber(tokens[1], &serno) || serno < 0 || serno > 1) {
      printf("illegal serial line number\n");
      return;
    }
    load(serno, true);
  } else if (n == 3) {
    if (!getDecNumber(tokens[1], &serno) || serno < 0 || serno > 1) {
      printf("illegal serial line number\n");
      return;
    }
    if (strcmp(tokens[2], "*") != 0) {
      help15();
      return;
    }
    load(serno, false);
  } else {
    help15();
  }
}


static void doBoot(char *tokens[], int n) {
  int dskno;

  if (n == 2) {
    if (!getDecNumber(tokens[1], &dskno) || dskno < 0 || dskno > 1) {
      printf("illegal disk number\n");
      return;
    }
    boot(dskno, true);
  } else if (n == 3) {
    if (!getDecNumber(tokens[1], &dskno) || dskno < 0 || dskno > 1) {
      printf("illegal disk number\n");
      return;
    }
    if (strcmp(tokens[2], "*") != 0) {
      help16();
      return;
    }
    boot(dskno, false);
  } else {
    help16();
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
  { "load", help15, doLoad       },
  { "boot", help16, doBoot       },
};

int numCommands = sizeof(commands) / sizeof(commands[0]);


static void doCommand(char *line) {
  char *tokens[MAX_TOKENS];
  int n;
  char *p;
  int i;

  n = 0;
  p = strtok(line, " \t\n");
  while (p != NULL) {
    if (n == MAX_TOKENS) {
      printf("too many tokens on line\n");
      return;
    }
    tokens[n++] = p;
    p = strtok(NULL, " \t\n");
  }
  if (n == 0) {
    return;
  }
  for (i = 0; i < numCommands; i++) {
    if (strcmp(commands[i].name, tokens[0]) == 0) {
      (*commands[i].cmdProc)(tokens, n);
      return;
    }
  }
  help();
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
  printf("\n");
  printf("NOTE: %s %s occurred while executing the command.\n",
         article(*what), what);
  printf("      This event will not alter the state of the CPU.\n");
}


void execCommand(char *line) {
  MonitorState commandState;

  if (saveState(&commandState)) {
    /* initialization */
    monitorReturn = &commandState;
    doCommand(line);
  } else {
    /* an exception was thrown */
    interactiveException((userContext.psw & PSW_PRIO_MASK) >> 16);
  }
  monitorReturn = NULL;
}
