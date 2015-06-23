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

#ifndef _SEGTAB_H_
#define _SEGTAB_H_

#include <stdint.h>

#define SEG_INITSIZE 1024

struct seg
{
  struct op *code;
  uint32_t max;
  uint32_t pos;
};

#include "code.h"

#define SEG_TEXT  0
#define SEG_DATA  1
#define SEG_BSS   2
#define SEG_PILE  3

void init_seg(uint8_t, uint32_t);

void set_current_segnum(uint8_t);
uint8_t get_current_segnum(void);

struct seg *get_current_seg(void);
struct seg *get_seg(uint8_t);

void adjust_segsize(struct seg *, uint32_t);

#endif /* _SEGTAB_H_ */
