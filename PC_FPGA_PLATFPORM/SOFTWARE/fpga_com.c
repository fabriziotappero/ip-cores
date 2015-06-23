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


#include <stdio.h>

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "fpga_com.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

const size_t MAX_MTU = 64 * 1024; 

static void die_perror( const char *call ) {
    perror( call );
    exit(-1);
}


void fpga_con_init( fpga_con_t *con, const void *daddr, int lport, int dport ) {
    

    
    /*set up local socket address*/
    memset( &con->l_sockaddr, 0, sizeof( con->l_sockaddr ));
    con->l_sockaddr.sin_family = AF_INET;
    con->l_sockaddr.sin_addr.s_addr = INADDR_ANY;
    con->l_sockaddr.sin_port = htons(lport);
    
    /*setup dest socket address*/
    memset( &con->d_sockaddr, 0, sizeof( con->d_sockaddr ));
    con->d_sockaddr.sin_family = AF_INET;
    con->d_sockaddr.sin_addr.s_addr = inet_addr( daddr );
    con->d_sockaddr.sin_port = htons(dport);
    
/*    create my socket*/
    con->s = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
    if( con->s < 0 ) {
	die_perror( "socket" );
    }
 
/*    bind it to local socket*/
    int r = bind( con->s, (struct sockaddr *)&con->l_sockaddr, sizeof(con->l_sockaddr));
    if( r < 0 ) {
	die_perror( "bind" );
    }
    con->mtu = 1500;
}

size_t fpga_con_get_mtu( fpga_con_t *con ) {
 
    return con->mtu;
}

void fpga_con_set_mtu( fpga_con_t *con, size_t mtu ) {
 
    if( mtu > MAX_MTU ) {
        printf( "fpga_con_set_mtu: mtu > MAX_MTU\n" );
        exit(-1);
    }
    con->mtu = mtu;
}


ssize_t fpga_con_send( fpga_con_t *con, const void *buf, size_t len ) {
    
    
    ssize_t rsend = sendto( con->s, buf, len, 0, (struct sockaddr*)&con->d_sockaddr, sizeof(con->d_sockaddr));
    if( rsend < 0 ) {
	die_perror( "sendto" );
    }
    
    return rsend;
}


/* send lut initialization packet sequence: rst, conf, empty*/
void fpga_con_send_init_packet( fpga_con_t *con ) {
    uint8_t buf[4];
    
    buf[0] = 255;
    fpga_con_send( con, buf, 1);
    
    buf[0] = 15;
    fpga_con_send( con, buf, 1);
    
    fpga_con_send( con, buf, 0);
}

/*blocking receive: this call will block until a packet is received*/
ssize_t fpga_con_block_recv( fpga_con_t *con, void *dbuf, size_t dsize ) {
        
    ssize_t rrecv = recv( con->s, dbuf, dsize, 0 );
    
    if( rrecv < 0 ) {
	die_perror( "recv" );
    }
    
    return rrecv;
}


static __inline size_t mymin( size_t a, size_t b ) {
    return a < b ? a : b;
}

//const static size_t MTU = 1500;
const static size_t PH_SIZE = 1;


// static __inline size_t pack( uint8_t *buf, uint8_t ht, size_t buf_size, void *src, size_t src_size ) {
//     assert( src_size + PH_SIZR <= buf_size );
//     
//     buf[0] = ht;
//     memcpy( buf + PH_SIZE, src, src_size );
//     
//     return src_size + PH_SIZE;
// }

// TODO; check how large the impact of doing the byte swappin on unaligned values really is
// there is no simple way around it (like in the receiving direction).
static __inline void swappy_16( void *dest, void *src, size_t n ) {
    uint16_t *idest = (uint16_t*)dest;
    uint16_t *isrc = (uint16_t*)src;
    
    for( size_t i = 0; i < n / 2; i++ ) {
        idest[i] = __bswap_16(isrc[i]);
    }
}

static __inline void swappy_32( void *dest, void *src, size_t n ) {
    uint32_t *idest = (uint32_t*)dest;
    uint32_t *isrc = (uint32_t*)src;
    
    for( size_t i = 0; i < n / 4; i++ ) {
        idest[i] = __bswap_32(isrc[i]);
    }
    
}


static __inline void swappy_64( void *dest, void *src, size_t n ) {
    uint64_t *idest = (uint64_t*)dest;
    uint64_t *isrc = (uint64_t*)src;
    
    for( size_t i = 0; i < n / 8; i++ ) {
        idest[i] = __bswap_64(isrc[i]);
    }
}

#define BS_NONE  (0)
#define BS_16  (1)
#define BS_32  (2)
#define BS_64  (3)

static __inline size_t pack_and_send( fpga_con_t *con, uint8_t *buf, size_t buf_size, uint8_t ht, void *src, size_t src_size, int swap ) {
    const size_t pack_size = src_size + PH_SIZE;
    
    assert( pack_size <= buf_size );
    
    buf[0] = ht;
    
    switch( swap ) { 
    case BS_NONE:
        memcpy( buf + PH_SIZE, src, src_size );
        break;
        
    case BS_16:
        swappy_16( buf + PH_SIZE, src, src_size );
        break;
        
    case BS_32:
        swappy_32( buf + PH_SIZE, src, src_size );
        break;
    
        
    case BS_64:
        swappy_64( buf + PH_SIZE, src, src_size );
        break;
     
    default:
        assert(0);
    }
        
    fpga_con_send( con, buf, pack_size );
    
    return src_size + PH_SIZE;    
}




int fpga_con_send_charv( fpga_con_t *con, char *buf, size_t n ) {
    
    
    const size_t blocksize = (con->mtu - PH_SIZE);
    uint8_t sb[MAX_MTU];
    
    size_t sent = 0;
    while( sent < n ) {
        const size_t to_copy = mymin( blocksize, n - sent );
        
        pack_and_send( con, sb, con->mtu, FPC_CODE_CHAR, (void*) &buf[sent], to_copy, BS_NONE );
        sent += to_copy;
    }
    
    return 1;
    
}

int fpga_con_send_shortv( fpga_con_t *con, int16_t *buf, size_t n ) {
    
    
    const size_t TSIZE = sizeof( short );
    
    const size_t blocksize = (con->mtu - PH_SIZE) / TSIZE;
    uint8_t sb[MAX_MTU];
    
    size_t sent = 0;
    while( sent < n ) {
        const size_t to_copy = mymin( blocksize, n - sent );
        
        //fpga_con_send( con, (void*) &buf[sent], to_copy * TSIZE );
        pack_and_send( con, sb, con->mtu, FPC_CODE_SHORT, (void*) &buf[sent], to_copy * TSIZE, BS_16 );
        
        sent += to_copy;
        
    }
    return 1;
    
}
int fpga_con_send_intv( fpga_con_t *con, int32_t *buf, size_t n ) {
    
    
    const size_t TSIZE = sizeof( int );
    
    const size_t blocksize = (con->mtu - PH_SIZE) / TSIZE;
    
    uint8_t sb[MAX_MTU];
    
    size_t sent = 0;
    while( sent < n ) {
        const size_t to_copy = mymin( blocksize, n - sent );
        
//         fpga_con_send( con, (void*) &buf[sent], to_copy * TSIZE );
        pack_and_send( con, sb, con->mtu, FPC_CODE_INT, (void*) &buf[sent], to_copy * TSIZE, BS_32 );
        
        sent += to_copy;
        
    }
    
    return 1;
}


int fpga_con_send_longv( fpga_con_t *con, int64_t *buf, size_t n ) {
    
    
    const size_t TSIZE = sizeof( int64_t );
    
    const size_t blocksize = (con->mtu - PH_SIZE) / TSIZE;
    
    uint8_t sb[MAX_MTU];
    
    size_t sent = 0;
    while( sent < n ) {
        const size_t to_copy = mymin( blocksize, n - sent );
        
//         fpga_con_send( con, (void*) &buf[sent], to_copy * TSIZE );
        pack_and_send( con, sb, con->mtu, FPC_CODE_LONG, (void*) &buf[sent], to_copy * TSIZE, BS_64 );
        
        sent += to_copy;
        
    }
    
    return 1;
}

int fpga_con_send_floatv( fpga_con_t *con, float *buf, size_t n ) {
    const size_t TSIZE = sizeof( int );
    
    const size_t blocksize = (con->mtu - PH_SIZE) / TSIZE;
    
    uint8_t sb[MAX_MTU];
    
    size_t sent = 0;
    while( sent < n ) {
        const size_t to_copy = mymin( blocksize, n - sent );
        
//         fpga_con_send( con, (void*) &buf[sent], to_copy * TSIZE );
        pack_and_send( con, sb, con->mtu, FPC_CODE_FLOAT, (void*) &buf[sent], to_copy * TSIZE, BS_32 );
        
        sent += to_copy;
        
    }
    
    return 1;
}

int fpga_con_send_doublev( fpga_con_t *con, double *buf, size_t n ) {
    
    
    const size_t TSIZE = sizeof( double );
    
    const size_t blocksize = (con->mtu - PH_SIZE) / TSIZE;
    
    uint8_t sb[MAX_MTU];
    
    
    size_t sent = 0;
    while( sent < n ) {
        const size_t to_copy = mymin( blocksize, n - sent );
        
//         fpga_con_send( con, (void*) &buf[sent], to_copy * TSIZE );
        pack_and_send( con, sb, con->mtu, FPC_CODE_DOUBLE, (void*) &buf[sent], to_copy * TSIZE, BS_64 );
        sent += to_copy;
    }
    
    return 1;
}

static void fpga_con_rpack( fpga_con_t *con, int code, int size ) {
    char buf[3] = { 120, 0, 0 };
    buf[0] += code;
    
    
    assert( size > 0 && size < 0xffff );
    unsigned short ssize = size;
    
    swappy_16( &buf[1], &ssize, 2);
    
    fpga_con_send(con, buf, 3);
}

void fpga_con_rpack_char( fpga_con_t *con, int size ) {
    fpga_con_rpack( con, FPC_CODE_CHAR, size );
}
void fpga_con_rpack_short( fpga_con_t *con, int size ) {
    fpga_con_rpack( con, FPC_CODE_SHORT, size );
}
void fpga_con_rpack_int( fpga_con_t *con, int size ) {
    fpga_con_rpack( con, FPC_CODE_INT, size);
}
void fpga_con_rpack_long( fpga_con_t *con, int size ) {
    fpga_con_rpack( con, FPC_CODE_LONG, size);
}

void fpga_con_rpack_float( fpga_con_t *con, int size ) {
    fpga_con_rpack( con, FPC_CODE_FLOAT, size );
}
void fpga_con_rpack_double( fpga_con_t *con, int size ) {
    fpga_con_rpack( con, FPC_CODE_DOUBLE, size );
}

