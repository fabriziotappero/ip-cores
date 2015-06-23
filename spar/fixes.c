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

#include "spar.h"
#include "ui.h"
#include "code.h"
#include "exprs.h"
#include "fixes.h"
#include "optab.h"
#include "segtab.h"
#include "symtab.h"

int fix_operands(struct seg *seg, uint32_t pos)
{
  uint8_t count = get_arg_count(seg, pos);
  uint8_t index;
  int retval = 0;

  for (index = 0; index < count; index++)
    {
      if (get_arg_type(seg, pos, index) == 'a')
	{
	  set_expr(seg, pos, index,
		   xsprintf("(%s)-%d", get_expr(seg, pos, index), pos));
	}
    }

  return retval;
}

int fix_code(struct seg *seg, uint32_t pos)
{
  uint8_t count = get_arg_count(seg, pos);
  uint8_t index;
  uint16_t data;

  data = get_op_code(seg, pos);
  for (index = 0; index < count; index++)
    {
      switch (get_arg_type(seg, pos, index))
	{
	case 'r': 
	  data |= (get_regnum(seg, pos, index)
		   & ((uint16_t)0xFFFF >> (16-get_arg_width(seg, pos, index))))
				       << get_arg_offset(seg, pos, index);
	  break;
	case 'n':
	case 'a':
	  data |= (expr_evaluate(get_expr(seg, pos, index))
		   & ((uint16_t)0xFFFF >> (16-get_arg_width(seg, pos, index))))
				       << get_arg_offset(seg, pos, index);
	  break;
	}
    }
  set_code(seg, pos, data);

  return 0;
}
