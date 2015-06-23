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
#include "segtab.h"

static struct seg segtab[4];
static uint8_t current_segnum;

void init_seg(uint8_t segnum, uint32_t size)
{
  int i;

  segtab[segnum].max = size;
  segtab[segnum].code = xmalloc(segtab[segnum].max*sizeof(struct op));

  for (i = 0; i < segtab[segnum].max; i++)
    set_listing(&segtab[segnum], i, "");
}

void set_current_segnum(uint8_t segnum)
{
  current_segnum = segnum;
}

uint8_t get_current_segnum(void)
{
  return current_segnum;
}

struct seg *get_current_seg(void)
{
  return &segtab[current_segnum];
}

struct seg *get_seg(uint8_t segnum)
{
  return &segtab[segnum];
}

void adjust_segsize(struct seg *seg, uint32_t size)
{
  if (size >= seg->max-1)
    {
      uint32_t i;

      seg->code = xrealloc(seg->code, 2*seg->max*sizeof(struct op));
      for (i = seg->max; i < 2*seg->max; i++)
	{
	  set_listing(seg, i, "");
	}
      seg->max *= 2;
    }
}

