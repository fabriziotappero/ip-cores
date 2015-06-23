/*
 * Copyright (c) 2011, The Multicore Association All rights reserved.
 *
 * Copyright (c) 2011, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 * (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * (3) Neither the name of the Multicore Association nor the names of its
 *     contributors may be used to endorse or promote products derived from
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * mcapi_impl_spec.h
 *
 * Version 2.014, February 2011
 *
 */

#ifndef MCAPI_IMPL_SPEC_H
#define MCAPI_IMPL_SPEC_H

#include <openmcapi_cfg.h>
#include <mgc_mcapi_impl_os.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/* XXX remove me */
#define MGC_MCAPI_ERR_NOT_CONNECTED (MCAPI_STATUSCODE_END+1)

/*
 * MCAPI implementation specific type definitions
 */
typedef unsigned int    	mcapi_endpoint_t;
typedef unsigned int		mcapi_pktchan_recv_hndl_t;
typedef unsigned int		mcapi_pktchan_send_hndl_t;
typedef unsigned int		mcapi_sclchan_send_hndl_t;
typedef unsigned int		mcapi_sclchan_recv_hndl_t;

typedef struct {
    /* XXX */
} mcapi_node_attributes_t;

typedef struct {
} mcapi_param_t;

/*
 * NOTE: Application code should consider this type opaque, and must not
 * directly access these members.
 */
typedef struct
{
    mcapi_cond_t    mcapi_cond;
    mcapi_cond_t    *mcapi_cond_ptr;
} MCAPI_COND_STRUCT;

/* Data structure that is used in non-blocking operations.  The fields are
 * populated for later use to check the status of the original non-blocking
 * call.
 *
 * NOTE: Application code should consider this type opaque, and must not
 * directly access these members.
 */
struct _mcapi_request
{
    struct _mcapi_request   *mcapi_next;
    struct _mcapi_request   *mcapi_prev;
    mcapi_status_t          mcapi_status;
    mcapi_uint8_t           mcapi_type;
    mcapi_uint8_t           mcapi_chan_type;
    mcapi_node_t            mcapi_requesting_node_id; /* The node ID of the node
                                                       * making the call. */
    mcapi_port_t            mcapi_requesting_port_id;
    mcapi_endpoint_t        mcapi_target_endp;
    mcapi_endpoint_t        *mcapi_endp_ptr;        /* The application's
                                                     * pointer to an endpoint
                                                     * structure. */

    mcapi_node_t            mcapi_target_node_id;   /* The target node ID. */

    mcapi_port_t            mcapi_target_port_id;   /* The target endpoint
                                                     * port. */
    size_t                  mcapi_byte_count;
    void                    *mcapi_buffer;          /* Application buffer to
                                                     * fill in. */

    size_t                  mcapi_buf_size;         /* Application buffer
                                                     * size. */

    void                    **mcapi_pkt;            /* Application packet
                                                     * pointer to fill in. */
    mcapi_uint32_t          mcapi_pending_count;
    MCAPI_COND_STRUCT       mcapi_cond;
};
typedef struct  _mcapi_request      mcapi_request_t;


/* Number of MCAPI reserved ports, starting at port 0. Reserved ports can be
 * used for implementation specific purposes.
 */
#define MCAPI_NUM_RESERVED_PORTS				2

/* Implementation defined MCAPI MIN and MAX values.
 *
 * Implementations may parameterize implementation specific max values,
 * smaller that the MCAPI max values. Implementations must specify what
 * those smaller values are and how they are set.
 *
 */
#define MCAPI_MAX_DOMAIN			(2 << 14) - 1	/* Maximum value for domain */
#define MCAPI_MAX_NODE				 (2 << 7) - 1	/* Maximum value for node */
#define MCAPI_MAX_PORT				 (2 << 7) - 1	/* Maximum value for port */
#define MCAPI_MAX_MESSAGE_SIZE		(2 << 31) - 1	/* Maximum message size */
#define MCAPI_MAX_PACKET_SIZE		(2 << 31) - 1	/* Maximum packet size */

/*
 * Implementations may parameterize implementation specific priority min value
 * and set the number of reserved ports. Implementations must specify what
 * those values are and how they are set.
 */
#define MCAPI_MIN_PORT	 MCAPI_NUM_RESERVED_PORTS	/* Minimum value for port */
#define MCAPI_MIN_PRORITY			(2 << 31) - 1	/* XXX Minimum priority value */

/*
 * Implementation specific MCAPI endpoint status attributes
 */
#define	MCAPI_ENDP_ATTR_STATUS_CREATED			0x00010000	/* The endpoint is created */


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* MCAPI_IMPL_SPEC_H */
