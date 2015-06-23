/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY */
/*   Copyright (C) 2004 GAISLER RESEARCH */

/*   This program is free software; you can redistribute it and/or modify */
/*   it under the terms of the GNU General Public License as published by */
/*   the Free Software Foundation; either version 2 of the License, or */
/*   (at your option) any later version. */

/*   See the file COPYING for the full details of the license. */
/*****************************************************************************/

#include "rmapapi.h"

int build_rmap_hdr(struct rmap_pkt *pkt, char *hdr, int *size)
{
        int i;
        int type;
        int write;
        int srcspalen;
        if ((pkt->type != readcmd) && (pkt->type != writecmd) && (pkt->type != rmwcmd) &&
            (pkt->type != readrep) && (pkt->type != writerep) && (pkt->type != rmwrep)) {
                return 1;
        }
        if ((pkt->verify != yes) && (pkt->verify != no)) {
                return 1;
        }
        if ((pkt->ack != yes) && (pkt->ack != no)) {
                return 2;
        }
        if ((pkt->incr != yes) && (pkt->incr != no)) {
                return 3;
        }
        if ( (pkt->dstspalen < 0) || (pkt->dstspalen > 228) ) {
                return 4;
        }
        if ( (pkt->srcspalen < 0) || (pkt->srcspalen > 12) ) {
                return 5;
        }
        if( (pkt->destkey < 0) || (pkt->destkey > 255) ) {
                return 6;
        }
        if( (pkt->destaddr < 0) || (pkt->destaddr > 255) ) {
                return 7;
        }
        if( (pkt->destkey < 0) || (pkt->destkey > 255) ) {
                return 8;
        }
        if( (pkt->srcaddr < 0) || (pkt->srcaddr > 255) ) {
                return 9;
        }
        if( (pkt->tid < 0) || (pkt->tid > 65535) ) {
                return 10;
        }
        if( (pkt->len < 0) || (pkt->len > 16777215) ) {
                return 11;
        }
        if( (pkt->status < 0) || (pkt->status > 12) ) {
                return 12;
        }
        if ((pkt->type == writecmd) || (pkt->type == writerep)) {
                write = 1;
        } else {
                write = 0;
        }
        if ((pkt->type == writecmd) || (pkt->type == readcmd) || (pkt->type == rmwcmd)) {
                type = 1;
                *size = pkt->dstspalen + 15;
                srcspalen = pkt->srcspalen/4;
                if ( (pkt->srcspalen % 4) != 0) {
                        srcspalen = srcspalen + 1;
                }
                *size = srcspalen * 4 + *size;
                for(i = 0; i < pkt->dstspalen; i++) {
                        hdr[i] = pkt->dstspa[i];
                }
                hdr[pkt->dstspalen] = (char)pkt->destaddr;
                hdr[pkt->dstspalen+1] = (char)0x01;
                hdr[pkt->dstspalen+2] = (char)0;
                hdr[pkt->dstspalen+2] = hdr[pkt->dstspalen+2] | (type << 6) | 
                        (write << 5) | (pkt->verify << 4) | (pkt->ack << 3) | (pkt->incr << 2) | srcspalen;
                hdr[pkt->dstspalen+3] = (char)pkt->destkey;
                for(i = 0; i < pkt->srcspalen; i++) {
                        hdr[pkt->dstspalen+3+i] = pkt->srcspa[i];
                }
                hdr[pkt->dstspalen+4+pkt->srcspalen] = (char)pkt->srcaddr;
                hdr[pkt->dstspalen+5+pkt->srcspalen] = (char)((pkt->tid >> 8) & 0xFF);
                hdr[pkt->dstspalen+6+pkt->srcspalen] = (char)(pkt->tid & 0xFF);
                hdr[pkt->dstspalen+7+pkt->srcspalen] = (char)0;
                hdr[pkt->dstspalen+8+pkt->srcspalen] = (char)((pkt->addr >> 24) & 0xFF);
                hdr[pkt->dstspalen+9+pkt->srcspalen] = (char)((pkt->addr >> 16) & 0xFF);
                hdr[pkt->dstspalen+10+pkt->srcspalen] = (char)((pkt->addr >> 8) & 0xFF);
                hdr[pkt->dstspalen+11+pkt->srcspalen] = (char)(pkt->addr & 0xFF);
                hdr[pkt->dstspalen+12+pkt->srcspalen] = (char)((pkt->len >> 16) & 0xFF);
                hdr[pkt->dstspalen+13+pkt->srcspalen] = (char)((pkt->len >> 8) & 0xFF);
                hdr[pkt->dstspalen+14+pkt->srcspalen] = (char)(pkt->len & 0xFF);
        } else {
                type = 0;
                if (pkt->type == writerep) {
                        *size = pkt->srcspalen + 7;
                } else {
                        *size = pkt->srcspalen + 11;
                }
                srcspalen = pkt->srcspalen/4;
                if ( (pkt->srcspalen % 4) != 0) {
                        srcspalen = srcspalen + 1;
                }
                for(i = 0; i < pkt->srcspalen; i++) {
                        hdr[i] = pkt->srcspa[i];
                }
                hdr[pkt->srcspalen] = (char)pkt->srcaddr;
                hdr[pkt->srcspalen+1] = (char)0x01;
                hdr[pkt->srcspalen+2] = (char)0;
                hdr[pkt->srcspalen+2] = hdr[pkt->srcspalen+2] | (type << 6) | 
                        (write << 5) | (pkt->verify << 4) | (pkt->ack << 3) | (pkt->incr << 2) | srcspalen;
                hdr[pkt->srcspalen+3] = (char)pkt->status;
                hdr[pkt->srcspalen+4] = (char)pkt->destaddr;
                hdr[pkt->srcspalen+5] = (char)((pkt->tid >> 8) & 0xFF);
                hdr[pkt->srcspalen+6] = (char)(pkt->tid & 0xFF);
                if (pkt->type != writerep) {
                        hdr[pkt->srcspalen+7] = (char)0;
                        hdr[pkt->srcspalen+8] = (char)((pkt->len >> 16) & 0xFF);
                        hdr[pkt->srcspalen+9] = (char)((pkt->len >> 8) & 0xFF);
                        hdr[pkt->srcspalen+10] = (char)(pkt->len & 0xFF);
                }
        }
        return 0;
}



