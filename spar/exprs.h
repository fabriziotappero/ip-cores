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

#ifndef _EXPRS_H_
#define _EXPRS_H_

#include <stdint.h>

char *  expr_localize(const char *);
int64_t expr_symcount(const char *) __attribute__((const));
int64_t expr_nevaluate(const char *) __attribute__((const));
int64_t expr_evaluate(const char *) __attribute__((const));

#endif
