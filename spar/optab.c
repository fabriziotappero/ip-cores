/* This file is part of the assembler "spar" for marca.
   Copyright (C) 2007 Wolfgang Puffitsch

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU Library General Public License as published
   by the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA */

#include <stdint.h>

#include "optab.h"
#include "segtab.h"

const struct op_info optab [] = {

/* #define DATA       0 */
  { 0x0000, 1, { { 'n', 8, 0, -0x80, 0xFF } } },

/* #define ADD        1 */
  { 0x0000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define SUB        2 */
  { 0x1000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define ADDC       3 */
  { 0x2000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define SUBC       4 */
  { 0x3000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define AND        5 */
  { 0x4000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define OR         6 */
  { 0x5000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define XOR        7 */
  { 0x6000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define MUL        8 */
  { 0x7000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define DIV        9 */
  { 0x8000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define UDIV      10 */
  { 0x9000, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 8, 0, 15 } } },
/* #define LDIL      11 */
  { 0xA000, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 8, 4, -128, 255 } } },
/* #define LDIH      12 */
  { 0xB000, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 8, 4, -128, 255 } } },
/* #define LDIB      13 */
  { 0xC000, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 8, 4, -128, 128 } } },

/* #define MOV       14 */
  { 0xD000, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },

  /* mod an umod are a bit of a kludge and need separate unfolding,
     they are 2-operand instructions really */
/* #define MOD       15 */
  { 0xD100, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 16, 0, 15 } } },
/* #define UMOD      16 */
  { 0xD200, 3, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 }, { 'r', 4, 16, 0, 15 } } },

/* #define NOT       17 */
  { 0xD300, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define NEG       18 */
  { 0xD400, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define CMP       19 */
  { 0xD500, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define ADDI      20 */
  { 0xD600, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, -8, 7 } } },
/* #define CMPI      21 */
  { 0xD700, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, -8, 7 } } },
/* #define SHL       22 */
  { 0xD800, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define SHR       23 */
  { 0xD900, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define SAR       24 */
  { 0xDA00, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define ROLC      25 */
  { 0xDB00, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define RORC      26 */
  { 0xDC00, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define BSET      27 */
  { 0xDD00, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, 0, 15 } } },
/* #define BCLR      28 */
  { 0xDE00, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, 0, 15 } } },
/* #define BTEST     29 */
  { 0xDF00, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, 0, 15 } } },

/* #define LOAD      30 */
  { 0xE000, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define STORE     31 */
  { 0xE100, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define LOADL     32 */
  { 0xE200, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define LOADH     33 */
  { 0xE300, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define LOADB     34 */
  { 0xE400, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define STOREL    35 */
  { 0xE500, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define STOREH    36 */
  { 0xE600, 2, { { 'r', 4, 0, 0, 15 }, { 'r', 4, 4, 0, 15 } } },
/* #define CALL      37 */
  { 0xE800, 2, { { 'r', 4, 4, 0, 15 }, { 'r', 4, 0, 0, 15 } } },

/* #define BR        38 */
  { 0xF000, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRZ       39 */
  { 0xF100, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRNZ      40 */
  { 0xF200, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRLE      41 */
  { 0xF300, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRLT      42 */
  { 0xF400, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRGE      43 */
  { 0xF500, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRGT      44 */
  { 0xF600, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRULE     45 */
  { 0xF700, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRULT     46 */
  { 0xF800, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRUGE     47 */
  { 0xF900, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define BRUGT     48 */
  { 0xFA00, 1, { { 'a', 8, 0, -128, 127 } } },
/* #define SEXT      49 */
  { 0xFB00, 2, { { 'r', 4, 4, 0, 15 }, { 'r', 4, 0, 0, 15 } } },
/* #define LDVEC     50 */
  { 0xFC00, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, 0, 15 } } },
/* #define STVEC     51 */
  { 0xFD00, 2, { { 'r', 4, 0, 0, 15 }, { 'n', 4, 4, 0, 15 } } },

/* #define JMP       52 */
  { 0xFE00, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPZ      53 */
  { 0xFE10, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPNZ     54 */
  { 0xFE20, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPLE     55 */
  { 0xFE30, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPLT     56 */
  { 0xFE40, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPGE     57 */
  { 0xFE50, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPGT     58 */
  { 0xFE60, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPULE    59 */
  { 0xFE70, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPULT    60 */
  { 0xFE80, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPUGE    61 */
  { 0xFE90, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define JMPUGT    62 */
  { 0xFEA0, 1, { { 'r', 4, 0, 0, 15 } } },

/* #define INTR      63 */
  { 0xFEB0, 1, { { 'n', 4, 0, 0, 15 } } },
/* #define GETIRA    64 */
  { 0xFEC0, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define SETIRA    65 */
  { 0xFED0, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define GETFL     66 */
  { 0xFEE0, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define SETFL     67 */
  { 0xFEF0, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define GETSHFL   68 */
  { 0xFF00, 1, { { 'r', 4, 0, 0, 15 } } },
/* #define SETSHFL   69 */
  { 0xFF10, 1, { { 'r', 4, 0, 0, 15 } } },

/* #define RETI      70 */
  { 0xFFF0, 0 },
/* #define NOP       71 */
  { 0xFFF1, 0 },
/* #define SEI       72 */
  { 0xFFF2, 0 },
/* #define CLI       73 */
  { 0xFFF3, 0 },
/* #define ERROR     74 */
  { 0xFFFF, 0 },

/* #define ALIGN     75 */
  { 0x0000 }
};

uint16_t get_op_code(struct seg *seg, uint32_t pos)
{
  return optab[seg->code[pos].op].opcode;
}

int8_t   get_arg_count(struct seg *seg, uint32_t pos)
{
  return optab[seg->code[pos].op].argc;
}

char     get_arg_type(struct seg *seg, uint32_t pos, uint8_t index)
{
  return optab[seg->code[pos].op].argv[index].type;
}

uint8_t  get_arg_width(struct seg *seg, uint32_t pos, uint8_t index)
{
  return optab[seg->code[pos].op].argv[index].width;
}
uint8_t  get_arg_offset(struct seg *seg, uint32_t pos, uint8_t index)
{
  return optab[seg->code[pos].op].argv[index].offset;
}
int32_t  get_arg_min(struct seg *seg, uint32_t pos, uint8_t index)
{
  return optab[seg->code[pos].op].argv[index].min;
}
int32_t  get_arg_max(struct seg *seg, uint32_t pos, uint8_t index)
{
  return optab[seg->code[pos].op].argv[index].max;
}
