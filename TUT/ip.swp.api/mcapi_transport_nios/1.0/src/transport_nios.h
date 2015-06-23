/*
Copyright (c) 2008, The Multicore Association
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

(1) Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
 
(2) Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution. 

(3) Neither the name of the Multicore Association nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// **************************************************************************
// File             : transport_nios.h
// Author           : Lauri Matilainen
// Date             : 17.09.2010
// Decription       : FUNCAPI transport layer implementation for NIOS II
//                    (modified from The Multicore Association example
//                    shared memory implementation)
// Version history  : 17.09.2005    Lauri Matilainen    1st mod version
//
//
//
//  
// **************************************************************************



#ifndef _TRANSPORT_NIOS_H_
#define _TRANSPORT_NIOS_H_

#include "mcapi_datatypes.h"
#include "mcapi_config.h"

#include <stdarg.h> /* for va_list */
#include <stdio.h> /* for the inlined dprintf routine */


/*******************************************************************
  definitions and constants
*******************************************************************/    
/* the debug level */
extern int mcapi_debug;

/* we leave one empty element so that the array implementation 
   can tell the difference between empty and full */

#define MAX_QUEUE_ENTRIES (MAX_QUEUE_ELEMENTS + 1)


/*******************************************************************
  mcapi_trans data types
*******************************************************************/    
/* buffer entry is used for msgs, pkts and scalars */
/* NOTE: if you change the buffer_entry data structure then you also
   need to update the pointer arithmetic in mcapi_trans_pktchan_free */
typedef struct {
  uint32_t magic_num;
  uint32_t size; /* size (in bytes) of the buffer */
  mcapi_boolean_t in_use;
  char buff [MAX_PKT_SIZE];
  uint64_t scalar;
} buffer_entry;

typedef struct {
  mcapi_request_t* request; /* holds a reservation for an outstanding receive request */
  buffer_entry* b;          /* the pointer to the actual buffer entry in the buffer pool */
  mcapi_boolean_t invalid;
} buffer_descriptor;


typedef struct {
  mcapi_boolean_t valid;
  uint16_t attribute_num;
  uint32_t bytes;
  void* attribute_d;  
} attribute_entry;

typedef struct {  
  /* the next 3 data members are only valid for channels */
  mcapi_endpoint_t send_endpt;
  mcapi_endpoint_t recv_endpt;
  uint8_t channel_type;

  uint32_t num_elements;
  uint16_t head;
  uint16_t tail;
  buffer_descriptor elements[MAX_QUEUE_ENTRIES+1];
}queue;


typedef struct {
  uint32_t port_num;
  mcapi_boolean_t valid;
  mcapi_boolean_t anonymous;
  mcapi_boolean_t open;
  mcapi_boolean_t connected;
  uint32_t num_attributes;
  attribute_entry attributes [MAX_ATTRIBUTES];
  queue recv_queue;
} endpoint_entry;

typedef struct {
  uint16_t num_endpoints;
  endpoint_entry endpoints[MAX_ENDPOINTS];
} node_descriptor;

typedef struct {
  uint32_t node_num;
  mcapi_boolean_t finalized;
  mcapi_boolean_t valid;
  node_descriptor node_d;
} node_entry;


typedef struct {
  uint16_t num_nodes;
  node_entry nodes[MAX_NODES];
  buffer_entry buffers [MAX_BUFFERS];
} mcapi_database;


/* debug printing */
/* Inline this (and define in header) so that it can be compiled out if WITH_DEBUG is 0 */
inline void mcapi_dprintf(int level,const char *format, ...) {
  if (WITH_DEBUG) {
    va_list ap;
    va_start(ap,format);
    if (level <= mcapi_debug){
      printf("MCAPI_DEBUG:");
      /* call variatic printf */
      vprintf(format,ap);
    }
    va_end(ap);
  }
}



#endif
