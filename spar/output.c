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

#include "spar.h"
#include "ui.h"
#include "output.h"
#include "segtab.h"
#include "code.h"

char *itob(uint32_t val, uint8_t width)
{
  char *retval = xmalloc(width+1);
  retval[width] = '\0';
  while (width-- > 0)
    {
      retval[width] = (val & 1) ? '1' : '0';
      val >>= 1;
    }
  return retval;
}

void print_download(FILE *f, FILE *r0, FILE *r1)
{
  struct seg *seg = get_current_seg();
  uint32_t pos;
 
  if (!nostart)
    {
      fprintf(f, "%c%c", 'U', '\n');
    }
  for (pos = 0; pos < seg->pos; pos++)
    {
      uint16_t data = get_code(seg, pos);
      fprintf(f, "%c%c%c%c%c%c",
	      (uint8_t)((pos >> 8) & 0xFF),
	      (uint8_t)(pos & 0xFF),
	      0,
	      (uint8_t)((data >> 8) & 0xFF),
	      (uint8_t)(data & 0xFF),
	      '\n');
    }
  for ( ; pos < codesize; pos++)
    {
      fprintf(f, "%c%c%c%c%c%c",
	      (uint8_t)((pos >> 8) & 0xFF),
	      (uint8_t)(pos & 0xFF),
	      0,
	      (uint8_t)((filler >> 8) & 0xFF),
	      (uint8_t)(filler & 0xFF),
	      '\n');
    }
  if (!noend)
    {
      fprintf(f, "%c%c%c", 0x55, 0xFF, 1);
    }
}

void print_intel(FILE *f, FILE *r0, FILE *r1)
{
  struct seg *seg;
  uint32_t pos;
 
  /* instructions */
  seg = get_seg(SEG_PILE);
  for (pos = 0; pos < seg->pos; pos++)
    {
      uint16_t data = get_code(seg, pos);
      uint8_t chksum = -(2 + ((pos >> 8) & 0xFF) + (pos & 0xFF)
			 + ((data >> 8) & 0xFF) + (data & 0xFF));
      fprintf(f, ":%02x%04x%02x%04x%02x%c",
	      2, (uint16_t)pos, 0, data, chksum, '\n');
    }
  for ( ; pos < codesize; pos++)
    {
      uint8_t chksum = -(2 + ((pos >> 8) & 0xFF) + (pos & 0xFF)
			 + ((filler >> 8) & 0xFF) + (filler & 0xFF));
      fprintf(f, ":%02x%04x%02x%04x%02x%c",
	      2, (uint16_t)pos, 0, filler, chksum, '\n');
    }
  fprintf(f, ":00000001ff\n");

  /* even ROM adresses */
  seg = get_seg(SEG_DATA);
  for (pos = 0; pos < seg->pos; pos+=2)
    {
      uint16_t data = get_code(seg, pos);
      uint8_t chksum = -(1 + ((pos/2 >> 8) & 0xFF) + (pos/2 & 0xFF)
			 + (data & 0xFF));
      fprintf(r0, ":%02x%04x%02x%02x%02x%c",
	      1, (uint16_t)pos/2, 0, data & 0xFF, chksum, '\n');
    }
  for ( ; pos < romsize; pos+=2)
    {
      uint8_t chksum = -(1 + ((pos/2 >> 8) & 0xFF) + (pos/2 & 0xFF)
			 + (filler & 0xFF));
      fprintf(r0, ":%02x%04x%02x%02x%02x%c",
	      1, (uint16_t)pos/2, 0, filler & 0xFF, chksum, '\n');
    }
  fprintf(r0, ":00000001ff\n");

  /* odd ROM adresses */
  seg = get_seg(SEG_DATA);
  for (pos = 1; pos < seg->pos; pos+=2)
    {
      uint16_t data = get_code(seg, pos);
      uint8_t chksum = -(1 + ((pos/2 >> 8) & 0xFF) + (pos/2 & 0xFF)
			 + (data & 0xFF));
      fprintf(r1, ":%02x%04x%02x%02x%02x%c",
	      1, (uint16_t)pos/2, 0, data & 0xFF, chksum, '\n');
    }
  for ( ; pos < romsize; pos+=2)
    {
      uint8_t chksum = -(1 + ((pos/2 >> 8) & 0xFF) + (pos/2 & 0xFF)
			 + ((filler >> 8) & 0xFF) + (filler & 0xFF));
      fprintf(r1, ":%02x%04x%02x%02x%02x%c",
	      1, (uint16_t)pos/2, 0, filler & 0xFF, chksum, '\n');
    }
  fprintf(r1, ":00000001ff\n");
}

void print_mif(FILE *f, FILE *r0, FILE *r1)
{
  struct seg *seg;
  uint32_t pos;
 
  /* instructions */
  seg = get_seg(SEG_PILE);

  fprintf(f, "DEPTH=%lu;\n", codesize);
  fprintf(f, "WIDTH=16;\n");
  fprintf(f, "ADDRESS_RADIX=HEX;\n");
  fprintf(f, "DATA_RADIX=BIN;\n\n");
  fprintf(f, "CONTENT\nBEGIN\n\n");

  fprintf(f, "%% Assembly output\t%%\n");

  for (pos = 0; pos < seg->pos; pos++)
    {
      uint16_t data = get_code(seg, pos);
      fprintf(f, "%4x:\t%s;\t%% %s\t%%\n", (uint16_t)pos,
	      itob(data, 16), get_listing(seg, pos));
    }

  if (seg->pos < codesize)
    {
      fprintf(f, "\n[%4x..%4x]:\t%s;\t%% Filler\t%%\n",
	      (uint16_t)seg->pos, (uint16_t)(codesize-1),
	      itob(filler, 16));
    }

  fprintf(f, "\nEND;\n");

  /* even ROM addresses */
  seg = get_seg(SEG_DATA);

  fprintf(r0, "DEPTH=%lu;\n", romsize/2);
  fprintf(r0, "WIDTH=8;\n");
  fprintf(r0, "ADDRESS_RADIX=HEX;\n");
  fprintf(r0, "DATA_RADIX=BIN;\n\n");
  fprintf(r0, "CONTENT\nBEGIN\n\n");

  fprintf(r0, "%% Assembly output\t%%\n");

  for (pos = 0; pos < seg->pos; pos += 2)
    {
      uint16_t data = get_code(seg, pos);
      fprintf(r0, "%4x:\t%s;\t%% %s\t%%\n", (uint16_t)pos/2,
	      itob(data, 8), get_listing(seg, pos));
    }

  if (seg->pos < romsize)
    {
      fprintf(r0, "\n[%4x..%4x]:\t%s;\t%% Filler\t%%\n",
	      (uint16_t)seg->pos/2, (uint16_t)(romsize/2-1),
	      itob(filler, 8));
    }

  fprintf(r0, "\nEND;\n");

  /* odd ROM addresses */
  seg = get_seg(SEG_DATA);

  fprintf(r1, "DEPTH=%lu;\n", romsize/2);
  fprintf(r1, "WIDTH=8;\n");
  fprintf(r1, "ADDRESS_RADIX=HEX;\n");
  fprintf(r1, "DATA_RADIX=BIN;\n\n");
  fprintf(r1, "CONTENT\nBEGIN\n\n");

  fprintf(r1, "%% Assembly output\t%%\n");

  for (pos = 1; pos < seg->pos; pos += 2)
    {
      uint16_t data = get_code(seg, pos);
      fprintf(r1, "%4x:\t%s;\t%% %s\t%%\n", (uint16_t)pos/2,
	      itob(data, 8), get_listing(seg, pos));
    }

  if (seg->pos < romsize)
    {
      fprintf(r1, "\n[%4x..%4x]:\t%s;\t%% Filler\t%%\n",
	      (uint16_t)seg->pos/2, (uint16_t)(romsize/2-1),
	      itob(filler, 8));
    }

  fprintf(r1, "\nEND;\n");
}
