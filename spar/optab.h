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

#ifndef _OPTAB_H_
#define _OPTAB_H_

#include <stdint.h>

#include "code.h"
#include "segtab.h"

struct arg_info
{
  char type;
  uint8_t width;
  uint8_t offset;
  int32_t min;
  int32_t max;
};

struct op_info
{
  uint16_t opcode;
  int8_t argc;
  struct arg_info argv [CODE_MAX_ARGS];
};

uint16_t get_op_code(struct seg *, uint32_t);
int8_t   get_arg_count(struct seg *, uint32_t);
char     get_arg_type(struct seg *, uint32_t, uint8_t);
uint8_t  get_arg_width(struct seg *, uint32_t, uint8_t);
uint8_t  get_arg_offset(struct seg *, uint32_t, uint8_t);
int32_t  get_arg_min(struct seg *, uint32_t, uint8_t);
int32_t  get_arg_max(struct seg *, uint32_t, uint8_t);

extern const struct op_info optab [];

#define DATA       0
#define ADD        1
#define SUB        2
#define ADDC       3
#define SUBC       4
#define AND        5
#define OR         6
#define XOR        7
#define MUL        8
#define DIV        9
#define UDIV      10
#define LDIL      11
#define LDIH      12
#define LDIB      13

#define MOV       14
#define MOD       15
#define UMOD      16
#define NOT       17
#define NEG       18
#define CMP       19
#define ADDI      20
#define CMPI      21
#define SHL       22
#define SHR       23
#define SAR       24
#define ROLC      25
#define RORC      26
#define BSET      27
#define BCLR      28
#define BTEST     29

#define LOAD      30
#define STORE     31
#define LOADL     32
#define LOADH     33
#define LOADB     34
#define STOREL    35
#define STOREH    36
#define CALL      37

#define BR        38
#define BRZ       39
#define BRNZ      40
#define BRLE      41
#define BRLT      42
#define BRGE      43
#define BRGT      44
#define BRULE     45
#define BRULT     46
#define BRUGE     47
#define BRUGT     48
#define SEXT      49
#define LDVEC     50
#define STVEC     51

#define JMP       52
#define JMPZ      53
#define JMPNZ     54
#define JMPLE     55
#define JMPLT     56
#define JMPGE     57
#define JMPGT     58
#define JMPULE    59
#define JMPULT    60
#define JMPUGE    61
#define JMPUGT    62

#define INTR      63
#define GETIRA    64
#define SETIRA    65
#define GETFL     66
#define SETFL     67
#define GETSHFL   68
#define SETSHFL   69

#define RETI      70
#define NOP       71
#define SEI       72
#define CLI       73
#define ERROR     74

#define ALIGN     75
#define COMM      76
#define LCOMM     77
#define ORG       78
#define SKIP      79

#endif /* _OPTAB_H_ */
