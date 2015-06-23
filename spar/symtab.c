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
#include <string.h>

#include "spar.h"
#include "symtab.h"

static struct sym_info *symtab[SYMTAB_SIZE];

uint32_t hash_string (const char *str)
{
  uint32_t hash;
  const char *ptr = str;
  size_t len = strlen(str);
  for (hash = 0; len; len--, ptr++)
    {
      hash = 31 * hash + *ptr;
    }
  return hash;
}

char *trim_string (char *str)
{
  while ((str[0] == ' ') || (str[0] == '\t'))
    {
      str++;
    }
  while ((str[strlen(str)-1] == ' ')
	 || (str[strlen(str)-1] == '\t'))
    {
      str[strlen(str)-1] = '\0';
    }
  return str;
}

char *localize_string (char *str)
{
  if (str[0] == '.')
    {
      char *buf = xmalloc(strlen(str)+10);
      sprintf(buf, "%s@%08lx", str, file_count);
      return buf;
    }
  return str;
}

void init_symtab(void)
{
  int i;
  for (i = 0; i < SYMTAB_SIZE; i++)
    {
      symtab[i] = NULL;
    }
}

void push_sym(const char *symbol, uint8_t type, uint32_t addr)
{
  uint32_t pos;
  struct sym_info *sym;

  pos = hash_string(symbol) % SYMTAB_SIZE;
  sym = xmalloc(sizeof(struct sym_info));
  sym->symbol = symbol;
  sym->type = type;
  sym->addr = addr;
  sym->next = symtab[pos];
  symtab[pos] = sym;  
}

struct sym_info *get_sym(const char *symbol)
{
  uint32_t pos;
  struct sym_info *sym;

  pos = hash_string(symbol) % SYMTAB_SIZE;
  sym = symtab[pos];

  while ((sym != NULL) && (strcmp(sym->symbol, symbol) != 0))
    {
      sym = sym->next;
    }

  return sym;
}

void reloc_syms(uint8_t type, uint32_t offset)
{
  uint32_t pos;
  struct sym_info *sym;

  for (pos = 0; pos < SYMTAB_SIZE; pos++)
    {
      for (sym = symtab[pos]; sym != NULL; sym = sym->next)
	{
	  if (sym->type == type)
	    {
	      sym->addr += offset;
	    }
	}
    }
}
