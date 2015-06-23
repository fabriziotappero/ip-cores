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

#ifndef _CODE_H_
#define _CODE_H_

#include <stdint.h>

#define CODE_MAX_ARGS    3
#define CODE_MAX_LISTLEN 32

struct arg
{
  char mode;
  union
  {
    uint16_t regnum;
    char *expr;
  } val;
};

struct op
{
  uint16_t op;
  struct arg args [CODE_MAX_ARGS];
  uint16_t code;
  char listing [CODE_MAX_LISTLEN];
};

#include "segtab.h"

void        set_op(struct seg *, uint32_t, uint16_t);
uint16_t    get_op(struct seg *, uint32_t);
void        set_mode(struct seg *, uint32_t, uint8_t, char);
char        get_mode(struct seg *, uint32_t, uint8_t);
void        set_regnum(struct seg *, uint32_t, uint8_t, uint16_t);
uint16_t    get_regnum(struct seg *, uint32_t, uint8_t);
void        set_expr(struct seg *, uint32_t, uint8_t, char *);
char *      get_expr(struct seg *, uint32_t, uint8_t);
void        set_code(struct seg *, uint32_t, uint16_t);
uint16_t    get_code(struct seg *, uint32_t);
void        set_listing(struct seg *, uint32_t, const char *);
void        trace_listing(struct seg *, uint32_t, const char *);
const char *get_listing(struct seg *, uint32_t);

#endif /* _CODE_H_ */
