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

#include <getopt.h>

#include "ui.h"

const char * const options = "hvo:0:1:c:d:r:f:inlmse";

const struct option long_options [] = {
  { "help",       no_argument,       0, 'h' },
  { "version",    no_argument,       0, 'v' },
  { "output",     required_argument, 0, 'o' },
  { "rom0file",   required_argument, 0, '0' },
  { "rom1file",   required_argument, 0, '1' },
  { "codesize",   required_argument, 0, 'c' },
  { "datasize",   required_argument, 0, 'd' },
  { "romsize",    required_argument, 0, 'r' },
  { "filler",     required_argument, 0, 'f' },
  { "intel",      no_argument,       0, 'i' },
  { "dryrun",     no_argument,       0, 'n' },
  { "download",   no_argument,       0, 'l' },
  { "nointel",    no_argument,       0, 'm' },
  { "nostart",    no_argument,       0, 's' },
  { "noend",      no_argument,       0, 'e' }
};
