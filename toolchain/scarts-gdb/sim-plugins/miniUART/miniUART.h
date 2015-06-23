/* SCARTS miniUART extension module code for the GNU simulator.
   Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003
   Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of the GNU simulators.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */


#ifndef __PLUGIN_MINIUART_H__
#define __PLUGIN_MINIUART_H__

#include <inttypes.h>
#include "modules.h"

/* See 'man ptmx' on how communication is setup with the
 * pseudo terminal master and slave pair ptmx and pts. */
#define MINIUART_TTY_DEV   "/dev/ptmx"

typedef union
{
  struct
  {
    uint8_t STATUS;
    uint8_t STATUS_C;
    uint8_t CONFIG;
    uint8_t CONFIG_C;
    uint8_t CFG;
    uint8_t CMD;
    uint8_t MSG_LO;
    uint8_t MSG_HI;
    uint8_t UBRS_LO;
    uint8_t UBRS_HI;
  } regfile;

  uint8_t raw[MINI_UART_SIZE];
} miniuart_mem_t;

#endif

