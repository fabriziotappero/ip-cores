/*
 * Copyright (C) 2011 Simon A. Berger
 * 
 *  This program is free software; you may redistribute it and/or modify its
 *  under the terms of the GNU Lesser General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 *  for more details.
 */

#include <arpa/inet.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    
const static int FPC_CODE_CHAR = 1;    
const static int FPC_CODE_SHORT = 2;
const static int FPC_CODE_INT = 3;
const static int FPC_CODE_LONG = 5;
const static int FPC_CODE_FLOAT = 4;   
const static int FPC_CODE_DOUBLE = 6;   

typedef struct {
    /* local and remote socket addresses */
    struct sockaddr_in l_sockaddr;
    struct sockaddr_in d_sockaddr;
    
    /* my socket */
    int s;
    size_t mtu;
} fpga_con_t;


void fpga_con_init( fpga_con_t *con, const void *daddr, int lport, int dport );
ssize_t fpga_con_send( fpga_con_t *con, const void *buf, size_t len );
void fpga_con_send_init_packet( fpga_con_t *con );
ssize_t fpga_con_block_recv( fpga_con_t *con, void *dbuf, size_t dsize );



int fpga_con_send_charv( fpga_con_t *con, char *buf, size_t n );
int fpga_con_send_shortv( fpga_con_t *con, int16_t *buf, size_t n );
int fpga_con_send_intv( fpga_con_t *con, int32_t *buf, size_t n );
int fpga_con_send_longv( fpga_con_t *con, int64_t *buf, size_t n );
int fpga_con_send_floatv( fpga_con_t *con, float *buf, size_t n );
int fpga_con_send_doublev( fpga_con_t *con, double *buf, size_t n );


void fpga_con_rpack_char( fpga_con_t *con, int size );
void fpga_con_rpack_short( fpga_con_t *con, int size );
void fpga_con_rpack_int( fpga_con_t *con, int size );
void fpga_con_rpack_long( fpga_con_t *con, int size );
void fpga_con_rpack_float( fpga_con_t *con, int size );
void fpga_con_rpack_double( fpga_con_t *con, int size );

#ifdef __cplusplus
}
#endif
