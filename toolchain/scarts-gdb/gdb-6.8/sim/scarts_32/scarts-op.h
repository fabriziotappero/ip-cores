/* SCARTS target-dependent code for the GNU simulator.
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


#ifndef __SCARTS_OP_H__
#define __SCARTS_OP_H__

typedef union
{
  struct
  {
    uint16_t reg : 4;
    int16_t  val : 8;
    uint16_t op  : 4;
  } ldiop __attribute__((packed));

  struct
  {
    uint16_t reg : 4;
    int16_t  val : 7;
    uint16_t op  : 5;
  } imm7op __attribute__((packed));

  struct
  {
    uint16_t reg : 4;
    int16_t  val : 6;
    uint16_t op  : 6;
  } imm6op __attribute__((packed));

  struct
  {
    uint16_t reg : 4;
    int16_t  val : 5;
    uint16_t op  : 7;
  } imm5op __attribute__((packed));

  struct
  {
    uint16_t reg : 4;
    uint16_t val : 4;
    uint16_t op  : 8;
  } imm4op __attribute__((packed));

  struct
  {
    uint16_t reg1 : 4;
    uint16_t reg2 : 4;
    uint16_t op   : 8;
  } binop __attribute__((packed));

  struct
  {
    uint16_t reg : 4;
    uint16_t op  : 12;
  } unop __attribute__((packed));

  struct
  {
    int16_t  dest : 10;
    uint16_t op   :  6;
  } jmpiop __attribute__((packed));

  struct
  {
    uint16_t op : 16;
  } nulop __attribute__((packed));

  uint16_t raw;
} __attribute__((packed)) scarts_op_t;

#endif

