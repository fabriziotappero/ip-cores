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

#ifndef _CHECKS_H_
#define _CHECKS_H_

#include <stdint.h>

#include "segtab.h"

int check_premature(void);
int check_arg_count(void);
int check_arg_type(struct seg *, uint32_t, uint8_t, char);
int check_org_advances(struct seg *, uint32_t);
int check_colon_ok(void);
int check_sym_dup(const char *s);
int check_code_size(void);
int check_data_size(void);
int check_mnemonic(struct seg *, uint32_t);
int check_ranges(struct seg *, uint32_t);

#endif /* _CHECKS_H_ */
