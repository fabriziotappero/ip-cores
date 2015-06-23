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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "code.h"
#include "segtab.h"

void set_op(struct seg *seg, uint32_t pos, uint16_t op)
{
  seg->code[pos].op = op;
}

uint16_t get_op(struct seg *seg, uint32_t pos)
{
  return seg->code[pos].op;
}

void set_mode(struct seg *seg, uint32_t pos, uint8_t index, char mode)
{
  seg->code[pos].args[index].mode = mode;
}

char get_mode(struct seg *seg, uint32_t pos, uint8_t index)
{
  return seg->code[pos].args[index].mode;
}

void set_regnum(struct seg *seg, uint32_t pos, uint8_t index, uint16_t regnum)
{
  seg->code[pos].args[index].val.regnum = regnum;
}

uint16_t get_regnum(struct seg *seg, uint32_t pos, uint8_t index)
{
  return seg->code[pos].args[index].val.regnum;
}

void set_expr(struct seg *seg, uint32_t pos, uint8_t index, char * expr)
{
  seg->code[pos].args[index].val.expr = expr;
}

char *get_expr(struct seg *seg, uint32_t pos, uint8_t index)
{
  return seg->code[pos].args[index].val.expr;
}

void set_code(struct seg *seg, uint32_t pos, uint16_t code)
{
  seg->code[pos].code = code;
}

uint16_t get_code(struct seg *seg, uint32_t pos)
{
  return seg->code[pos].code;
}

void set_listing(struct seg *seg, uint32_t pos, const char *listing)
{
  if (listing != NULL)
    {
      strncpy(seg->code[pos].listing, listing, CODE_MAX_LISTLEN);
      seg->code[pos].listing[CODE_MAX_LISTLEN-1] = '\0';
    }
  else
    {
      seg->code[pos].listing[0] = '\0';
    }
}

void trace_listing(struct seg *seg, uint32_t pos, const char *text)
{
  if (text != NULL)
    {
      strncat(seg->code[pos].listing, text, CODE_MAX_LISTLEN);
      seg->code[pos].listing[CODE_MAX_LISTLEN-1] = '\0';
    }
}

const char *get_listing(struct seg *seg, uint32_t pos)
{
  return seg->code[pos].listing;
}
