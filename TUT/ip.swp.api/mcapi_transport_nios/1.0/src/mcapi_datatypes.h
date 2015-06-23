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

#ifndef MCAPI_DATATYPES_H
#define MCAPI_DATATYPES_H

#include "mcapi_config.h"

#include <stddef.h>  /* for size_t */
#include <stdint.h>

#ifdef __TCE__
     typedef struct {
         int hi;
         int lo;
     } uint64_t;
#endif

/******************************************************************
           definitions and constants 
 ******************************************************************/
#ifndef MCAPI_PORT_ANY
#define MCAPI_PORT_ANY 0xffffffff
#endif

#ifndef MCAPI_INFINITE
#define MCAPI_INFINITE  0xffffffff
#endif

#ifndef MCAPI_MAX_PRIORITY
#define MCAPI_MAX_PRIORITY 10
#endif

#define MCAPI_TRUE 1
#define MCAPI_FALSE 0

#define MCAPI_NULL NULL

#define MCAPI_OUT
/* could define this one as const */
#define MCAPI_IN    

#ifndef MAX_QUEUE_ELEMENTS
#define MAX_QUEUE_ELEMENTS 64 
#endif

/******************************************************************
           datatypes
******************************************************************/ 
/* error codes */
typedef enum {
  MCAPI_INCOMPLETE,
  MCAPI_SUCCESS,
  MCAPI_ENO_INIT,       /* The MCAPI environment could not be initialized.  */
  MCAPI_ENO_FINAL,      /* The MCAPI environment could not be finalized.  */
  MCAPI_ENOT_ENDP,      /* Argument is not an endpoint descriptor.  */
  MCAPI_EMESS_LIMIT,    /* The message size exceeds the maximum size allowed by the MCAPI implementation.  */
  MCAPI_ENO_BUFFER,     /* No more message buffers available.  */
  MCAPI_ENO_REQUEST,    /* No more request handles available.  */
  MCAPI_ENO_MEM,        /* No memory available.  */
  MCAPI_ENODE_NOTINIT,  /* The node is not initialized.  */
  MCAPI_EEP_NOTALLOWED, /* Endpoints cannot be created on this node.  */
  MCAPI_EPORT_NOTVALID, /* The parameter is not a valid port  */
  MCAPI_ENODE_NOTVALID, /* The parameter is not a valid node.  */
  MCAPI_ENO_ENDPOINT,   /* No such endpoint exists  */
  MCAPI_ENOT_OWNER,     /* This node does not own the given endpoint */
  MCAPI_ECHAN_OPEN,     /* A channel is open on this endpoint */
  MCAPI_ECONNECTED,     /* A channel connection has already been established for the given endpoint.*/
  MCAPI_EATTR_INCOMP,   /* Connection of endpoints with incompatible attributes not allowed.*/
  MCAPI_ECHAN_TYPE,     /* Attempt to open a packet channel on an endpoint that has been connected with a different channel type.*/
  MCAPI_EDIR,           /* Attempt to open a send handle on a port that was connected as a receiver, or vice versa.*/
  MCAPI_ENOT_HANDLE,    /* Argument is not a channel handle.*/
  MCAPI_EPACK_LIMIT,    /* The message size exceeds the maximum size allowed by the MCAPI implementation.*/
  MCAPI_ENOT_VALID_BUF, /* Argument is not a valid buffer descriptor} flags; */
  MCAPI_ENOT_OPEN,      /* The endpoint is not open. */
  MCAPI_EREQ_CANCELED,  /* The request has been cancelled */
  MCAPI_ENOTREQ_HANDLE, /* Invalid request handle */
  MCAPI_EENDP_ISCREATED,/* The endpoint has already been created */
  MCAPI_EENDP_LIMIT,    /* Max endpoints already exist - no more can be created at this time */
  MCAPI_ENOT_CONNECTED, /* The endpoint is not connected */
  MCAPI_ESCL_SIZE,      /* Scalar size mismatch - send/recv called with differing sizes */
  MCAPI_EPRIO,          /* Incorrect priority level */
  MCAPI_INITIALIZED,    /* This node has already called initialize */
  MCAPI_EPARAM,         /* Invalid parameter */
  MCAPI_ETRUNCATED,     /* The buffer has been truncated */
  MCAPI_EREQ_TIMEOUT,   /* The request timed out */
} mcapi_status_flags;

/* basic types */     
typedef int32_t  mcapi_int_t;
typedef uint32_t mcapi_uint_t;
typedef uint8_t mcapi_uint8_t;
typedef uint16_t mcapi_uint16_t;
typedef uint32_t mcapi_uint32_t;
typedef uint64_t mcapi_uint64_t;
typedef uint8_t mcapi_boolean_t;

/* mcapi data */         
typedef uint32_t mcapi_status_t;
typedef uint32_t mcapi_endpoint_t;
typedef int  mcapi_node_t;
typedef int  mcapi_port_t;
typedef char mcapi_version_t[20];
typedef int mcapi_priority_t;
typedef int mcapi_timeout_t;
typedef enum {
  OTHER_REQUEST,
  OPEN_PKTCHAN,
  OPEN_SCLCHAN,
  SEND,
  RECV,
  GET_ENDPT
} mcapi_request_type;

typedef struct {
  mcapi_boolean_t valid;
  size_t size;
  mcapi_request_type type;
  void* buffer;
  void** buffer_ptr;
  uint32_t node_num;
  uint32_t port_num;
  mcapi_boolean_t completed;
  mcapi_boolean_t cancelled;
  mcapi_endpoint_t handle;
  mcapi_status_t status;
  mcapi_endpoint_t* endpoint;
} mcapi_request_t;


/* internal handles */     
typedef uint32_t mcapi_pktchan_recv_hndl_t;
typedef uint32_t mcapi_pktchan_send_hndl_t;
typedef uint32_t mcapi_sclchan_send_hndl_t;
typedef uint32_t mcapi_sclchan_recv_hndl_t;


/* enum for channel types */
typedef enum {
  MCAPI_NO_CHAN = 0,
  MCAPI_PKT_CHAN,
  MCAPI_SCL_CHAN,
} channel_type;



#endif
