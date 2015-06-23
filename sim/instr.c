/*
 * instr.c -- instruction encoding
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "instr.h"


/*
 * This is the ECO32 machine instruction set.
 * The table below needs no particular order
 * and may have gaps in the instruction encoding.
 */
Instr instrTbl[] = {
  { "add",   FORMAT_RRY, OP_ADD  },
  { "sub",   FORMAT_RRY, OP_SUB  },
  { "mul",   FORMAT_RRY, OP_MUL  },
  { "mulu",  FORMAT_RRX, OP_MULU },
  { "div",   FORMAT_RRY, OP_DIV  },
  { "divu",  FORMAT_RRX, OP_DIVU },
  { "rem",   FORMAT_RRY, OP_REM  },
  { "remu",  FORMAT_RRX, OP_REMU },
  { "and",   FORMAT_RRX, OP_AND  },
  { "or",    FORMAT_RRX, OP_OR   },
  { "xor",   FORMAT_RRX, OP_XOR  },
  { "xnor",  FORMAT_RRX, OP_XNOR },
  { "sll",   FORMAT_RRX, OP_SLL  },
  { "slr",   FORMAT_RRX, OP_SLR  },
  { "sar",   FORMAT_RRX, OP_SAR  },
  { "ldhi",  FORMAT_RHH, OP_LDHI },
  { "beq",   FORMAT_RRB, OP_BEQ  },
  { "bne",   FORMAT_RRB, OP_BNE  },
  { "ble",   FORMAT_RRB, OP_BLE  },
  { "bleu",  FORMAT_RRB, OP_BLEU },
  { "blt",   FORMAT_RRB, OP_BLT  },
  { "bltu",  FORMAT_RRB, OP_BLTU },
  { "bge",   FORMAT_RRB, OP_BGE  },
  { "bgeu",  FORMAT_RRB, OP_BGEU },
  { "bgt",   FORMAT_RRB, OP_BGT  },
  { "bgtu",  FORMAT_RRB, OP_BGTU },
  { "j",     FORMAT_J,   OP_J    },
  { "jr",    FORMAT_JR,  OP_JR   },
  { "jal",   FORMAT_J,   OP_JAL  },
  { "jalr",  FORMAT_JR,  OP_JALR },
  { "trap",  FORMAT_N,   OP_TRAP },
  { "rfx",   FORMAT_N,   OP_RFX  },
  { "ldw",   FORMAT_RRS, OP_LDW  },
  { "ldh",   FORMAT_RRS, OP_LDH  },
  { "ldhu",  FORMAT_RRS, OP_LDHU },
  { "ldb",   FORMAT_RRS, OP_LDB  },
  { "ldbu",  FORMAT_RRS, OP_LDBU },
  { "stw",   FORMAT_RRS, OP_STW  },
  { "sth",   FORMAT_RRS, OP_STH  },
  { "stb",   FORMAT_RRS, OP_STB  },
  { "mvfs",  FORMAT_RH,  OP_MVFS },
  { "mvts",  FORMAT_RH,  OP_MVTS },
  { "tbs",   FORMAT_N,   OP_TBS  },
  { "tbwr",  FORMAT_N,   OP_TBWR },
  { "tbri",  FORMAT_N,   OP_TBRI },
  { "tbwi",  FORMAT_N,   OP_TBWI }
};


Instr *instrCodeTbl[64];


static int instrCompare(const void *instr1, const void *instr2) {
  return strcmp(((Instr *) instr1)->name, ((Instr *) instr2)->name);
}


void initInstrTable(void) {
  int i;

  /* first sort instruction table alphabetically */
  qsort(instrTbl, sizeof(instrTbl)/sizeof(instrTbl[0]),
        sizeof(instrTbl[0]), instrCompare);
  /* then initialize instruction code table */
  for (i = 0; i < 64; i++) {
    instrCodeTbl[i] = NULL;
  }
  for (i = 0; i < sizeof(instrTbl)/sizeof(instrTbl[0]); i++) {
    instrCodeTbl[instrTbl[i].opcode] = &instrTbl[i];
    if (instrTbl[i].format == FORMAT_RRX ||
        instrTbl[i].format == FORMAT_RRY) {
      /* enter the immediate variant of this instruction also */
      instrCodeTbl[instrTbl[i].opcode + 1] = &instrTbl[i];
    }
  }
}


Instr *lookupInstr(char *name) {
  int lo, hi, tst;
  int res;

  lo = 0;
  hi = sizeof(instrTbl) / sizeof(instrTbl[0]) - 1;
  while (lo <= hi) {
    tst = (lo + hi) / 2;
    res = strcmp(instrTbl[tst].name, name);
    if (res == 0) {
      return &instrTbl[tst];
    }
    if (res < 0) {
      lo = tst + 1;
    } else {
      hi = tst - 1;
    }
  }
  return NULL;
}
