/* BFD library support routines for the Open8 architecture.
   Copyright 1999, 2000, 2002, 2005, 2006, 2007, 2008, 2010, 2011
   Free Software Foundation, Inc.

   Contributed by Kirk Hays <khays@hayshaus.com>

   This file is part of BFD, the Binary File Descriptor library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

#include "sysdep.h"
#include "bfd.h"
#include "libbfd.h"

/* This routine is provided two arch_infos and works out which Open8
   machine which would be compatible with both and returns a pointer
   to its info structure.  */

static const bfd_arch_info_type *
compatible (const bfd_arch_info_type * a,
	    const bfd_arch_info_type * b)
{
  /* If a & b are for different architectures we can do nothing.  */
  if (a->arch != b->arch)
    return NULL;

  if (a->mach == b->mach)
    return a;

  return NULL;
}

#define N(addr_bits, machine, print, default, next)			\
  {									\
    8,				/* 8 bits in a word.  */		\
      addr_bits,		/* bits in an address.  */		\
      8,			/* 8 bits in a byte.  */		\
      bfd_arch_open8,							\
      machine,			/* Machine number.  */			\
      "open8",			/* Architecture name.  */		\
      print,			/* Printable name.  */			\
      1,			/* Section align power.  */		\
  default,			/* Is this the default?  */		\
      compatible,							\
      bfd_default_scan,							\
      bfd_arch_default_fill,						\
      next								\
      }

static const bfd_arch_info_type arch_info_struct[] =
  {
    /* Base Architecture - instructions common to all variants, base ABI.  */
    N (16, bfd_mach_open8_1, "open8", TRUE, NULL),
  };

const bfd_arch_info_type bfd_open8_arch =
  N (16, bfd_mach_open8_1, "open8", TRUE, NULL);
