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

#ifndef _UI_H_
#define _UI_H_

#include <stdint.h>
#include <stdio.h>
#include <getopt.h>

#define MODE_DRYRUN   0
#define MODE_DOWNLOAD 1
#define MODE_INTEL    2
#define MODE_MIF      3

extern int8_t  output_mode;

extern uint32_t codesize;
extern uint32_t datasize;
extern uint32_t romsize;
extern uint16_t filler;

extern int nostart;
extern int noend;

#define DEFAULT_MODE     MODE_MIF
#define DEFAULT_CODESIZE 8192
#define DEFAULT_DATASIZE 8192
#define DEFAULT_ROMSIZE  256
#define DEFAULT_FILLER   0xFFFF

extern const char * const options;
extern const struct option long_options [];

#endif /* _UI_H_ */
