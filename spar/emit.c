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

#include <stdlib.h>
#include <stdio.h>

#include "spar.h"
#include "optab.h"
#include "code.h"
#include "emit.h"
#include "exprs.h"
#include "segtab.h"

void emit_op(struct seg *seg, struct op op)
{
  adjust_segsize(seg, seg->pos+1);
  seg->code[seg->pos] = op;
  seg->pos++;
}

void emit_nop(struct seg *seg)
{
  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, NOP);

  trace_listing(seg, seg->pos, "nop");

  seg->pos++;
}

void emit_zero(struct seg *seg)
{
  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, DATA);
  set_expr(seg, seg->pos, 0, "0");
  set_mode(seg, seg->pos, 0, 'n');

  trace_listing(seg, seg->pos, "data 0");

  seg->pos++;
}

void emit_data(struct seg *seg, char *expr)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, DATA);
  set_expr(seg, seg->pos, 0, expr);
  set_mode(seg, seg->pos, 0, 'n');

  snprintf(buf, CODE_MAX_LISTLEN, "data\t%s", expr);
  trace_listing(seg, seg->pos, buf);

  seg->pos++;

  free(buf);
}

void emit_ldil(struct seg *seg, uint16_t reg, char *expr)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, LDIL);
  set_regnum(seg, seg->pos, 0, reg);
  set_mode(seg, seg->pos, 0, 'r');
  set_expr(seg, seg->pos, 1, expr);
  set_mode(seg, seg->pos, 1, 'n');

  snprintf(buf, CODE_MAX_LISTLEN, "ldil\tr%d, %s", reg, expr);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_ldih(struct seg *seg, uint16_t reg, char *expr)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, LDIH);
  set_regnum(seg, seg->pos, 0, reg);
  set_mode(seg, seg->pos, 0, 'r');
  set_expr(seg, seg->pos, 1, expr);
  set_mode(seg, seg->pos, 2, 'n');

  snprintf(buf, CODE_MAX_LISTLEN, "ldih\tr%d, %s", reg, expr);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_ldib(struct seg *seg, uint16_t reg, char *expr)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, LDIB);
  set_regnum(seg, seg->pos, 0, reg);
  set_mode(seg, seg->pos, 0, 'r');
  set_expr(seg, seg->pos, 1, expr);
  set_mode(seg, seg->pos, 1, 'n');

  snprintf(buf, CODE_MAX_LISTLEN, "ldib\tr%d, %s", reg, expr);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_addi(struct seg *seg, uint16_t reg, char *expr)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, ADDI);
  set_regnum(seg, seg->pos, 0, reg);
  set_mode(seg, seg->pos, 0, 'r');
  set_expr(seg, seg->pos, 1, expr);
  set_mode(seg, seg->pos, 1, 'n');

  snprintf(buf, CODE_MAX_LISTLEN, "addi\tr%d, %s", reg, expr);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_cmp(struct seg *seg, uint16_t reg1, uint16_t reg2)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, CMP);
  set_regnum(seg, seg->pos, 0, reg1);
  set_mode(seg, seg->pos, 0, 'r');
  set_regnum(seg, seg->pos, 1, reg2);
  set_mode(seg, seg->pos, 1, 'r');

  snprintf(buf, CODE_MAX_LISTLEN, "cmp\tr%d, r%d", reg1, reg2);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_load(struct seg *seg, uint16_t reg1, uint16_t reg2)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, LOAD);
  set_regnum(seg, seg->pos, 0, reg1);
  set_mode(seg, seg->pos, 0, 'r');
  set_regnum(seg, seg->pos, 1, reg2);
  set_mode(seg, seg->pos, 1, 'r');

  snprintf(buf, CODE_MAX_LISTLEN, "load\tr%d, r%d", reg1, reg2);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_store(struct seg *seg, uint16_t reg1, uint16_t reg2)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, STORE);
  set_regnum(seg, seg->pos, 0, reg1);
  set_mode(seg, seg->pos, 0, 'r');
  set_regnum(seg, seg->pos, 1, reg2);
  set_mode(seg, seg->pos, 1, 'r');

  snprintf(buf, CODE_MAX_LISTLEN, "store\tr%d, r%d", reg1, reg2);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_jmp(struct seg *seg, uint16_t reg)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, JMP);
  set_regnum(seg, seg->pos, 0, reg);
  set_mode(seg, seg->pos, 0, 'r');

  snprintf(buf, CODE_MAX_LISTLEN, "jmp\tr%d", reg);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}

void emit_brnz(struct seg *seg, char *expr)
{
  char *buf = xmalloc(CODE_MAX_LISTLEN);

  adjust_segsize(seg, seg->pos+1);
  set_op(seg, seg->pos, BRNZ);
  set_expr(seg, seg->pos, 0, expr);
  set_mode(seg, seg->pos, 0, 'a');

  snprintf(buf, CODE_MAX_LISTLEN, "brnz\t%s", expr);
  trace_listing(seg, seg->pos, buf);
  seg->pos++;

  free(buf);
}
