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

#include "spar.h"
#include "expand.h"
#include "code.h"
#include "optab.h"

void expand_mod(void)
{
  struct op o = get_current_seg()->code[get_current_seg()->pos];

  if ((o.op == MOD) || (o.op == UMOD))
    {
      if (o.args[0].val.regnum != o.args[2].val.regnum)
	{
	  struct seg* seg = get_current_seg();

	  set_op(seg, seg->pos, MOV);
	  set_mode(seg, seg->pos, 0, 'r');
	  set_regnum(seg, seg->pos, 0, o.args[2].val.regnum);
	  set_mode(seg, seg->pos, 1, 'r');
	  set_regnum(seg, seg->pos, 1, o.args[0].val.regnum);
	  set_listing(seg, seg->pos, xsprintf("mov\tr%d, r%d",
					      o.args[2].val.regnum,
					      o.args[0].val.regnum));

	  seg->pos++;
	  adjust_segsize(seg, seg->pos+1);

	  set_op(seg, seg->pos, o.op);
	  set_mode(seg, seg->pos, 0, 'r');
	  set_regnum(seg, seg->pos, 0, o.args[2].val.regnum);
	  set_mode(seg, seg->pos, 1, 'r');
	  set_regnum(seg, seg->pos, 1, o.args[1].val.regnum);
	  set_mode(seg, seg->pos, 2, 'r');
	  set_regnum(seg, seg->pos, 2, 0); /* this should never be used */
	  set_listing(seg, seg->pos, xsprintf("%s\tr%d, r%d, r%d",
					      o.op == MOD ? "mod" : "umod",
					      o.args[2].val.regnum,
					      o.args[1].val.regnum,
					      o.args[2].val.regnum));
	}
    }
}
