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

#ifndef _SPAR_H_
#define _SPAR_H_

#include <stdint.h>
#include <stdlib.h>

extern char *command;

extern uint32_t line_count;
extern uint32_t file_count;
extern uint32_t error_count;

extern int      seen_op;
extern int8_t   args_to_match;

void *xmalloc(size_t) __attribute__((malloc));
void *xrealloc(void *, size_t) __attribute__((malloc));
char *xstrdup(const char *) __attribute__((malloc));
char *xsprintf(const char *, ...) __attribute__((malloc));

#endif /* _SPAR_H_ */
