/*
 * asm.c -- assembler
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "instr.h"
#include "asm.h"


#define MAX_TOKENS	10


static char *msgs[] = {
  /*  0 */  "too many tokens on line",
  /*  1 */  "empty line",
  /*  2 */  "unknown instruction name",
  /*  3 */  "unknown instruction format",
  /*  4 */  "excess tokens on line",
  /*  5 */  "too few operands",
  /*  6 */  "illegal register",
  /*  7 */  "illegal immediate value",
  /*  8 */  "immediate value out of range",
  /*  9 */  "target is not aligned",
  /* 10 */  "target cannot be reached"
};


static Bool asmReg(char *token, int *reg) {
  char *end;

  if (*token != '$') {
    return false;
  }
  *reg = strtoul(token + 1, &end, 10);
  if (*end != '\0') {
    return false;
  }
  if (*reg < 0 || *reg >= 32) {
    return false;
  }
  return true;
}


static Bool asmNum(char *token, unsigned int *val) {
  char *end;

  *val = strtoul(token, &end, 16);
  return *end == '\0';
}


char *asmInstr(char *line, Word addr, Word *instrPtr) {
  char *tokens[MAX_TOKENS];
  int n;
  char *p;
  Instr *instr;
  Word result;
  int r1, r2, r3;
  unsigned int uimm;
  signed int simm;

  /* separate tokens */
  n = 0;
  p = strtok(line, " \t\n,");
  while (p != NULL) {
    if (n == MAX_TOKENS) {
      return msgs[0];
    }
    tokens[n++] = p;
    p = strtok(NULL, " \t\n,");
  }
  if (n == 0) {
    return msgs[1];
  }
  /* lookup mnemonic */
  instr = lookupInstr(tokens[0]);
  if (instr == NULL) {
    return msgs[2];
  }
  /* do processing according to format */
  switch (instr->format) {
    case FORMAT_N:
      /* no operands (but may get a constant operand) */
      if (n > 2) {
        return msgs[4];
      }
      if (n < 1) {
        return msgs[5];
      }
      if (n == 2) {
        if (!asmNum(tokens[1], &uimm)) {
          return msgs[7];
        }
      } else {
        uimm = 0;
      }
      result = ((Word) instr->opcode << 26) |
               (uimm & MASK(26));
      break;
    case FORMAT_RH:
      /* one register and a half operand */
      if (n > 3) {
        return msgs[4];
      }
      if (n < 3) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmNum(tokens[2], &uimm)) {
        return msgs[7];
      }
      if (uimm >= (unsigned) (1 << 16)) {
        return msgs[8];
      }
      result = ((Word) instr->opcode << 26) |
               (r1 << 16) |
               (uimm & MASK(16));
      break;
    case FORMAT_RHH:
      /* one register and a half operand */
      /* ATTENTION: high-order 16 bits encoded */
      if (n > 3) {
        return msgs[4];
      }
      if (n < 3) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmNum(tokens[2], &uimm)) {
        return msgs[7];
      }
      uimm >>= 16;
      if (uimm >= (unsigned) (1 << 16)) {
        return msgs[8];
      }
      result = ((Word) instr->opcode << 26) |
               (r1 << 16) |
               (uimm & MASK(16));
      break;
    case FORMAT_RRH:
      /* two registers and a half operand */
      if (n > 4) {
        return msgs[4];
      }
      if (n < 4) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmReg(tokens[2], &r2)) {
        return msgs[6];
      }
      if (!asmNum(tokens[3], &uimm)) {
        return msgs[7];
      }
      if (uimm >= (unsigned) (1 << 16)) {
        return msgs[8];
      }
      result = ((Word) instr->opcode << 26) |
               (r2 << 21) |
               (r1 << 16) |
               (uimm & MASK(16));
      break;
    case FORMAT_RRS:
      /* two registers and a signed half operand */
      if (n > 4) {
        return msgs[4];
      }
      if (n < 4) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmReg(tokens[2], &r2)) {
        return msgs[6];
      }
      if (!asmNum(tokens[3], (unsigned int *) &simm)) {
        return msgs[7];
      }
      if (simm >= (signed) (1 << 15) ||
          simm < - (signed) (1 << 15)) {
        return msgs[8];
      }
      result = ((Word) instr->opcode << 26) |
               (r2 << 21) |
               (r1 << 16) |
               (simm & MASK(16));
      break;
    case FORMAT_RRR:
      /* three register operands */
      if (n > 4) {
        return msgs[4];
      }
      if (n < 4) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmReg(tokens[2], &r2)) {
        return msgs[6];
      }
      if (!asmReg(tokens[3], &r3)) {
        return msgs[6];
      }
      result = ((Word) instr->opcode << 26) |
               (r2 << 21) |
               (r3 << 16) |
               (r1 << 11);
      break;
    case FORMAT_RRX:
      /* either FORMAT_RRR or FORMAT_RRH */
      if (n > 4) {
        return msgs[4];
      }
      if (n < 4) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmReg(tokens[2], &r2)) {
        return msgs[6];
      }
      if (*tokens[3] == '$') {
        /* FORMAT_RRR */
        if (!asmReg(tokens[3], &r3)) {
          return msgs[6];
        }
        result = ((Word) instr->opcode << 26) |
                 (r2 << 21) |
                 (r3 << 16) |
                 (r1 << 11);
      } else {
        /* FORMAT_RRH */
        if (!asmNum(tokens[3], &uimm)) {
          return msgs[7];
        }
        if (uimm >= (unsigned) (1 << 16)) {
          return msgs[8];
        }
        result = (((Word) instr->opcode + 1) << 26) |
                 (r2 << 21) |
                 (r1 << 16) |
                 (uimm & MASK(16));
      }
      break;
    case FORMAT_RRY:
      /* either FORMAT_RRR or FORMAT_RRS */
      if (n > 4) {
        return msgs[4];
      }
      if (n < 4) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmReg(tokens[2], &r2)) {
        return msgs[6];
      }
      if (*tokens[3] == '$') {
        /* FORMAT_RRR */
        if (!asmReg(tokens[3], &r3)) {
          return msgs[6];
        }
        result = ((Word) instr->opcode << 26) |
                 (r2 << 21) |
                 (r3 << 16) |
                 (r1 << 11);
      } else {
        /* FORMAT_RRS */
        if (!asmNum(tokens[3], (unsigned int *) &simm)) {
          return msgs[7];
        }
        if (simm >= (signed) (1 << 15) ||
            simm < - (signed) (1 << 15)) {
          return msgs[8];
        }
        result = (((Word) instr->opcode + 1) << 26) |
                 (r2 << 21) |
                 (r1 << 16) |
                 (simm & MASK(16));
      }
      break;
    case FORMAT_RRB:
      /* two registers and a 16 bit signed offset operand */
      if (n > 4) {
        return msgs[4];
      }
      if (n < 4) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      if (!asmReg(tokens[2], &r2)) {
        return msgs[6];
      }
      if (!asmNum(tokens[3], (unsigned int *) &simm)) {
        return msgs[7];
      }
      if ((simm & 0x00000003) != 0) {
        return msgs[9];
      }
      simm -= addr + 4;
      simm /= 4;
      if (simm >= (signed) (1 << 15) ||
          simm < - (signed) (1 << 15)) {
        return msgs[10];
      }
      result = ((Word) instr->opcode << 26) |
               (r1 << 21) |
               (r2 << 16) |
               (simm & MASK(16));
      break;
    case FORMAT_J:
      /* no registers and a 26 bit signed offset operand */
      if (n > 2) {
        return msgs[4];
      }
      if (n < 2) {
        return msgs[5];
      }
      if (!asmNum(tokens[1], (unsigned int *) &simm)) {
        return msgs[7];
      }
      if ((simm & 0x00000003) != 0) {
        return msgs[9];
      }
      simm -= addr + 4;
      simm /= 4;
      if (simm >= (signed) (1 << 25) ||
          simm < - (signed) (1 << 25)) {
        return msgs[10];
      }
      result = ((Word) instr->opcode << 26) |
               (simm & MASK(26));
      break;
    case FORMAT_JR:
      /* one register operand */
      if (n > 2) {
        return msgs[4];
      }
      if (n < 2) {
        return msgs[5];
      }
      if (!asmReg(tokens[1], &r1)) {
        return msgs[6];
      }
      result = ((Word) instr->opcode << 26) |
               (r1 << 21);
      break;
    default:
      return msgs[3];
  }
  /* line successfully assembled */
  *instrPtr = result;
  return NULL;
}
