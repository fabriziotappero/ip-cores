/*
 * $Id: memory.h,v 1.2 2004-07-03 14:35:52 arniml Exp $
 *
 */

#ifndef _MEMORY_H_
#define _MEMORY_H_

#include "types.h"

typedef UINT32			offs_t;


UINT8 program_read_byte_8(UINT16);

UINT8 cpu_readop(UINT16);

UINT8 cpu_readop_arg(UINT16);

UINT8 io_read_byte_8(UINT8);

void io_write_byte_8(UINT8, UINT8);

int read_hex_file(char *, UINT16);

#endif
