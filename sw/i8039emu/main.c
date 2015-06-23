/*
 * $Id: main.c 295 2009-04-01 19:32:48Z arniml $
 *
 * Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
 *
 * All rights reserved
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version. See also the file COPYING which
 *  came with this application.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "types.h"
#include "memory.h"
#include "i8039.h"


void logerror(char *msg, UINT16 address, UINT8 opcode)
{
}


void print_usage(void) {
  printf("Usage:\n");
  printf(" i8039 -f <hex file> [-x <hex file>] [-d] [-h]\n");
  printf("  -f : Name of hex file for internal ROM\n");
  printf("  -x : Name of hex file for external ROM (optional)\n");
  printf("  -d : Dump machine state\n");
  printf("  -h : Print this help\n");
}


int main(int argc, char *argv[])
{
  int  do_cycles, real_cycles, total_cycles;
  char *hex_file = "";
  char *ext_hex_file = "";
  int  c;
  int  dump = 0;

  /* process options */
  while ((c = getopt(argc, argv, "df:hx:")) != -1) {
    switch (c) {
      case 'd':
        dump = 1;
        break;

      case 'f':
        hex_file = optarg;
        break;

      case 'x':
        ext_hex_file = optarg;
        break;

      case 'h':
        /* fallthrough */

      default:
        print_usage();
        return(0);
        break;
    }
  }

  /* check options */
  if (strlen(hex_file) == 0) {
    print_usage();
    return(1);
  }

  /* read hex file for internal ROM */
  printf("Reading %s\n", hex_file);
  if (!read_hex_file(hex_file, 0)) {
    printf("Error reading file!\n");
    return(1);
  }

  /* read hex fiel for external ROM */
  if (strlen(ext_hex_file) > 0) {
    printf("Reading %s\n", ext_hex_file);
    if (!read_hex_file(ext_hex_file, 0x800)) {
      printf("Error reading file!\n");
      return(1);
    }
  }

  printf("Resetting 8039\n");
  i8039_reset(NULL);

  do_cycles = 52;

  total_cycles = 0;

  do {
    real_cycles = i8039_execute(do_cycles, dump);

    /* activate interrupt */
    set_irq_line(0, HOLD_LINE);
    /* hold interrupt for 3 machine cycles */
    real_cycles += i8039_execute(3, dump);
    set_irq_line(0, CLEAR_LINE);

    if (real_cycles > 0)
      total_cycles += real_cycles;
  } while (real_cycles > 0);

  printf("Emulated %i cycles\n", total_cycles);
  printf("Simulation Result: %s\n", real_cycles == 0 ? "PASS" : "FAIL");

  return(0);
}
