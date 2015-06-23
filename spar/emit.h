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

#ifndef _EMIT_H_
#define _EMIT_H_

#include <stdint.h>

#include "segtab.h"

void emit_op(struct seg*, struct op);

void emit_nop(struct seg *);
void emit_zero(struct seg *);

void emit_data(struct seg *, char *);

void emit_ldil(struct seg *, uint16_t, char *);
void emit_ldih(struct seg *, uint16_t, char *);
void emit_ldib(struct seg *, uint16_t, char *);
void emit_load(struct seg *, uint16_t, uint16_t);
void emit_store(struct seg *, uint16_t, uint16_t);
void emit_cmp(struct seg *, uint16_t, uint16_t);
void emit_addi(struct seg *, uint16_t, char*);
void emit_jmp(struct seg *, uint16_t);
void emit_brnz(struct seg *, char*);


#endif /* _EMIT_H_ */
