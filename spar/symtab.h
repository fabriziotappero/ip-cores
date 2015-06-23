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

#ifndef _SYMTAB_H_
#define _SYMTAB_H_

#include <stdint.h>

#define SYMTAB_SIZE 4096

uint32_t hash_string (const char *);
char *trim_string (char *);
char *localize_string (char *);

struct sym_info
{
  const char *symbol;
  uint8_t type;
  uint32_t addr;
  struct sym_info *next;
};

void init_symtab(void);

void push_sym(const char *, uint8_t, uint32_t);
struct sym_info *get_sym(const char *);
void reloc_syms(uint8_t type, uint32_t offset);

#endif /* _SYMTAB_H_ */
