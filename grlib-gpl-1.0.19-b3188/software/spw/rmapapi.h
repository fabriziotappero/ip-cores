/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY */
/*   Copyright (C) 2004 GAISLER RESEARCH */

/*   This program is free software; you can redistribute it and/or modify */
/*   it under the terms of the GNU General Public License as published by */
/*   the Free Software Foundation; either version 2 of the License, or */
/*   (at your option) any later version. */

/*   See the file COPYING for the full details of the license. */
/*****************************************************************************/

enum rmap_type {writecmd, readcmd, rmwcmd, writerep, readrep, rmwrep};
enum sel_type {no = 0, yes = 1};

struct rmap_pkt 
{
   enum rmap_type type;
   enum sel_type verify;
   enum sel_type ack;
   enum sel_type incr;
   int destaddr;
   int destkey;
   int srcaddr;
   int tid;
   int addr;
   int len;
   int status;
   int dstspalen;
   char *dstspa;
   int srcspalen;
   char *srcspa;
};

int build_rmap_hdr(struct rmap_pkt *pkt, char *hdr, int *size);

int parse_rmap_pkt(struct rmap_pkt *pkt, char *hdr, int *size);


