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
#include "checks.h"
#include "code.h"
#include "exprs.h"
#include "optab.h"
#include "segtab.h"
#include "symtab.h"

int check_premature(void)
{
  if (args_to_match > 0)
    {
      fprintf(stderr, "not enough valid items in line %lu\n", line_count);
      error_count++;
      return 1;
    }
  return 0;
}

int check_arg_count(void)
{
  if (args_to_match == 0)
    {
      fprintf(stderr, "too many items in line %lu\n", line_count);
      error_count++;
      return 1;
    } 
  else if (args_to_match == -1)
    {
      fprintf(stderr, "no valid mnemonic in line %lu\n", line_count);
      args_to_match = -2;
      error_count++;
      return 1;
    }
  else if ((args_to_match & 1) == 0)
    {
      fprintf(stderr, "missing colon in line %lu\n", line_count);
      error_count++;
      return 1;
    } 

  return 0;
}

int check_org_advances(struct seg *seg, uint32_t org)
{
  if (seg->pos > org)
    {
      fprintf(stderr, "trying to move .org backwards in line %lu\n", line_count);
      error_count++;
      return 1;
    }
  return 0;
}

int check_colon_ok(void)
{
 if ((args_to_match & 1) != 0)
    {
      fprintf(stderr, "superfluous colon in line %lu\n", line_count);
      error_count++;
      return 1;
    } 

  return 0;
}

int check_arg_type(struct seg* seg, uint32_t pos, uint8_t index, char type)
{
  if (((type == 'r')
       && (get_arg_type(seg, pos, index) != 'r'))
      || ((type == 'n')
	  && (get_arg_type(seg, pos, index) != 'n')
	  && (get_arg_type(seg, pos, index) != 'a')))
       
    {
      fprintf(stderr, "wrong argtype `%c' in line %lu\n", type, line_count);
      error_count++;
      return 1;
    }
  return 0;
}

int check_sym_dup(const char *s)
{
  if (get_sym(s) != NULL)
    {
      fprintf(stderr, "duplicate symbol `%s' in line %lu\n", s, line_count);
      error_count++;
      return 1;
    }
  return 0;
}

int check_code_size(void)
{
  if (get_seg(SEG_TEXT)->pos > codesize)
    {
      fprintf(stderr,
	      "code (%lu instrucions) is too large for instruction ROM (%lu instructions)\n",
	      get_seg(SEG_TEXT)->pos, codesize);
      error_count++;
      return 1;
    }
  return 0;
}

int check_data_size(void)
{
  if (output_mode == MODE_DOWNLOAD
      && get_seg(SEG_DATA)->pos > 0)
    {
      fprintf(stderr,
	      "initialized data (%lu words) not supported for download format\n",
	      get_seg(SEG_DATA)->pos, romsize);
      error_count++;
      return 1;
    }

  if (get_seg(SEG_DATA)->pos > romsize)
    {
      fprintf(stderr,
	      "initialized data (%lu words) is too large for data ROM (%lu words)\n",
	      get_seg(SEG_DATA)->pos, romsize);
      error_count++;
      return 1;
    }

  if ((get_seg(SEG_DATA)->pos+get_seg(SEG_BSS)->pos) > datasize)
    {
      fprintf(stderr,
	      "data (%lu words) is too large for RAM (%lu words)\n",
	      (get_seg(SEG_DATA)->pos+get_seg(SEG_BSS)->pos), datasize);
      error_count++;
      return 1;
    }
  return 0;
}

int check_mnemonic(struct seg* seg, uint32_t pos)
{
  if (0)
    {
      fprintf(stderr, "mnemonic reserved, but not supported\n");
      error_count++;
      return 1;
    }
  return 0;
}

int check_ranges(struct seg* seg, uint32_t pos)
{
  uint8_t count = get_arg_count(seg, pos);
  uint8_t index;
  int retval = 0;

  for (index = 0; index < count; index++)
    {
      switch (get_arg_type(seg, pos, index))
	{
	case 'r': 
	  if ((get_regnum(seg, pos, index) < get_arg_min(seg, pos, index))
	      || (get_regnum(seg, pos, index) > get_arg_max(seg, pos, index)))
	    {
	      fprintf(stderr, "invalid register: r%d\n", get_regnum(seg, pos, index));
	      error_count++;
	      retval = 1;
	    }
	  break;
	case 'n': 
	  if (get_expr(seg, pos, index) == NULL)
	    {
	      fprintf(stderr, "missing expression, probably confused by prior errors\n");
	      error_count++;
	      retval = 1;
	    }
	  else if ((expr_evaluate(get_expr(seg, pos, index)) < get_arg_min(seg, pos, index))
	      || (expr_evaluate(get_expr(seg, pos, index)) > get_arg_max(seg, pos, index)))
	    {
	      fprintf(stderr, "number out of range [%ld..%ld]: %lld\n",
		      get_arg_min(seg, pos, index), get_arg_max(seg, pos, index),
		      expr_evaluate(get_expr(seg, pos, index)));
	      error_count++;
	      retval = 1;
	    }
	  break;
	case 'a':
	  if ((expr_evaluate(get_expr(seg, pos, index)) < get_arg_min(seg, pos, index))
	      || (expr_evaluate(get_expr(seg, pos, index)) > get_arg_max(seg, pos, index)))
	    {
	      fprintf(stderr, "relative address out of range [%ld..%ld]: %lld\n",
		      get_arg_min(seg, pos, index), get_arg_max(seg, pos, index),
		      expr_evaluate(get_expr(seg, pos, index)));
	      error_count++;
	      retval = 1;
	    }
	  break;
	default:
	  fprintf(stderr, "invalid operand constraint: %c\n",
		  get_arg_type(seg, pos, index));
	  error_count++;
	  retval = 1;
	}
    }

  return retval;
}

