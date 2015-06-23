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

#ifndef _OUTPUT_H_
#define _OUTPUT_H_

#include <stdint.h>
#include <stdio.h>

char *itob(uint32_t, uint8_t);
void print_download(FILE *, FILE *, FILE *);
void print_intel(FILE *, FILE *, FILE *);
void print_mif(FILE *, FILE *, FILE *);

#endif /* _OUTPUT_H_ */
