/*
 * load_ihex.cpp
 *
 *  Created on: Feb 15, 2011
 *      Author: hutch
 */

#include "load_ihex.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>

int inline readline(FILE *fh, char *buf)
{
  int c = 1, cnt = 0;

  if (feof(fh)) {
    *buf = (char) 0;
    return 0;
  }
  while (c) {
    c = fread (buf, 1, 1, fh);
    cnt++;
    if (c && (*buf == '\n')) {
      buf++;
      *buf = (char) 0;
      c = 0;
    }
    else buf++;
  }
  return cnt;
}


int load_ihex(char *filename, uint8_t *buffer, int max)
{
  FILE *fh;
  char line[80];
  char *lp;
  int rlen, addr, rtyp, databyte;
  int rv;
  int dcount = 0;
  int highest = 0;

  fh = fopen (filename, "r");

  rv = readline (fh, line);
    while (strlen(line) > 0) {
      sscanf (line, ":%02x%04x%02x", &rlen, &addr, &rtyp);
      lp = line + 9;
      for (int c=0; c<rlen; c++) {
        sscanf (lp, "%02x", &databyte);
        lp += 2;
        assert ((addr+c) < max);
        buffer[addr+c] = databyte; dcount++;
        //assert (dcount < max);
        if ((addr+c) > highest) highest = addr+c;
      }
      rv = readline (fh, line);
    }

  fclose (fh);
  printf ("ENVMEM  : Read %d bytes from %s\n", dcount, filename);
  return (highest);
}
