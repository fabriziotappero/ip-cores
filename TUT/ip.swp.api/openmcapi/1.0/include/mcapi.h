/*
 * Copyright (c) 2010, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Copyright (c) 2011, The Multicore Association All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the <ORGANIZATION> nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef MCAPI_H
#define MCAPI_H

#include <stddef.h>					/* Required for size_t */
#include "mca.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/*
 * MCAPI type definitions
 * (Additional typedefs under the attribute and initialization sections below)
 */
typedef mca_int_t			mcapi_int_t;
typedef mca_int8_t			mcapi_int8_t;
typedef mca_int16_t			mcapi_int16_t;
typedef mca_int32_t			mcapi_int32_t;
typedef mca_int64_t			mcapi_int64_t;
typedef mca_uint_t			mcapi_uint_t;
typedef mca_uint8_t			mcapi_uint8_t;
typedef mca_uint16_t		mcapi_uint16_t;
typedef mca_uint32_t		mcapi_uint32_t;
typedef mca_uint64_t		mcapi_uint64_t;
typedef mca_boolean_t		mcapi_boolean_t;
typedef mca_domain_t		mcapi_domain_t;
typedef mca_node_t			mcapi_node_t;
typedef unsigned int    	mcapi_port_t;				//Changed from int to unsigned int
typedef mca_status_t		mcapi_status_t;
typedef mca_timeout_t		mcapi_timeout_t;
typedef unsigned int		mcapi_priority_t;

/*
 * The mcapi_impl_spec.h header file is vendor/implementation specific,
 * and should contain declarations and definitions specific to a particular
 * implementation.
 *
 * This file must be provided by each implementation.
 *
 * It MUST contain type definitions for the following types, which must be either
 * pointers or 32 bit scalars, allowing simple arithmetic equality comparison (a == b).
 * Implementers may which of these type are used.
 *
 * mcapi_endpoint_t;			Note: The endpoint identifier must be topology unique.
 * mcapi_pktchan_recv_hndl_t;
 * mcapi_pktchan_send_hndl_t;
 * mcapi_sclchan_send_hndl_t;
 * mcapi_sclchan_recv_hndl_t;
 *
 *
 * It MUST contain the following definition:
 * mcapi_param_t;
 *
 * It MUST contain the following definitions:
 *
 * Number of MCAPI reserved ports, starting at port 0. Reserved ports can be used for implementation specific purposes.
 *
 * MCAPI_NUM_RESERVED_PORTS				1	Number of reserved ports starting at port 0
 *
 *
 * Implementation defined MCAPI MIN and MAX values.
 *
 * Implementations may parameterize implementation specific max values,
 * smaller that the MCAPI max values. Implementations must specify what
 * those smaller values are and how they are set.
 *
 * MCAPI_MAX_DOMAIN				Maximum value for domain
 * MCAPI_MAX_NODE				Maximum value for node
 * MCAPI_MAX_PORT				Maximum value for port
 * MCAPI_MAX_MESSAGE_SIZE		Maximum message size
 * MCAPI_MAX_PACKET_SIZE		Maximum packet size
 *
 * Implementations may parameterize implementation specific priority min value
 * and set the number of reserved ports. Implementations must specify what
 * those values are and how they are set.
 *
 * MCAPI_MIN_PORT				Minimum value for port
 * MCAPI_MIN_PRORITY			Minimum priority value
 *
 */
#include "mcapi_impl_spec.h"

typedef int mcapi_version_t; /* XXX remove me */

/* The following constants are not implementation defined */
#define MCAPI_VERSION					2014		/* Version 2.014 (major #
													+ minor # (3-digit)) */
#define MCAPI_TRUE						MCA_TRUE
#define MCAPI_FALSE						MCA_FALSE
#define MCAPI_NULL						MCA_NULL	/* MCAPI Zero value */
#define MCAPI_PORT_ANY					(~0)		/* Create endpoint using the next available port */
#define	MCAPI_TIMEOUT_INFINITE			(~0)		/* Wait forever, no timeout */
#define	MCAPI_TIMEOUT_IMMEDIATE			  0			/* Return immediately, with success or failure */
#define MCAPI_NODE_INVALID 				(~0)		/* Return value for	invalid node */
#define MCAPI_DOMAIN_INVALID			(~0)		/* Return value for	invalid domain */
#define MCAPI_RETURN_VALUE_INVALID		(~0)		/* Invalid return value */
#define MCAPI_MAX_PRORITY				  0			/* Maximum priority value */
#define MCAPI_MAX_STATUS_MSG_LEN		32			/* Maximum status code message length */

/*
 * MCAPI Status codes
 */
enum mcapi_status_codes {
	MCAPI_SUCCESS = 1,				// Indicates operation was successful
	MCAPI_PENDING,					// Indicates operation is pending without errors
	MCAPI_TIMEOUT,					// The operation timed out
	MCAPI_ERR_PARAMETER,			// Incorrect parameter
	MCAPI_ERR_DOMAIN_INVALID,		// The parameter is not a valid domain
	MCAPI_ERR_NODE_INVALID,			// The parameter is not a valid node
	MCAPI_ERR_NODE_INITFAILED,		// The MCAPI node could not be initialized
	MCAPI_ERR_NODE_INITIALIZED,		// MCAPI node is already initialized
	MCAPI_ERR_NODE_NOTINIT,			// The MCAPI node is not initialized
	MCAPI_ERR_NODE_FINALFAILED,		// The MCAPI could not be finalized
	MCAPI_ERR_PORT_INVALID,			// The parameter is not a valid port
	MCAPI_ERR_ENDP_INVALID,			// The parameter is not a valid endpoint descriptor
	MCAPI_ERR_ENDP_EXISTS,			// The endpoint is already created
	MCAPI_ERR_ENDP_GET_LIMIT,		// Endpoint get reference count is to high
	MCAPI_ERR_ENDP_DELETED,			// The endpoint has been deleted
	MCAPI_ERR_ENDP_NOTOWNER,		// An endpoint can only be deleted by its creator
	MCAPI_ERR_ENDP_REMOTE,			// Certain operations are only allowed on the node local endpoints
	MCAPI_ERR_ATTR_INCOMPATIBLE,	// Connection of endpoints with incompatible attributes not allowed
	MCAPI_ERR_ATTR_SIZE,			// Incorrect attribute size
	MCAPI_ERR_ATTR_NUM,				// Incorrect attribute number
	MCAPI_ERR_ATTR_VALUE,			// Incorrect attribute vale
	MCAPI_ERR_ATTR_NOTSUPPORTED,	// Attribute not supported by the implementation
	MCAPI_ERR_ATTR_READONLY,		// Attribute is read only
	MCAPI_ERR_MSG_SIZE,				// The message size exceeds the maximum size allowed by the MCAPI implementation
	MCAPI_ERR_MSG_TRUNCATED,		// The message size exceeds the buffer size
	MCAPI_ERR_CHAN_OPEN,			// A channel is open, certain operations are not allowed
	MCAPI_ERR_CHAN_TYPE,			// Attempt to open a packet/scalar channel on an endpoint that has been connected with a different channel type
	MCAPI_ERR_CHAN_DIRECTION,		// Attempt to open a send handle on a port that was connected as a receiver, or vice versa
	MCAPI_ERR_CHAN_CONNECTED,		// A channel connection has already been established for one or both of the specified endpoints
	MCAPI_ERR_CHAN_OPENPENDING,		// An open request is pending
	MCAPI_ERR_CHAN_CLOSEPENDING,	// A close request is pending.
	MCAPI_ERR_CHAN_NOTOPEN,			// The channel is not open (cannot be closed)
	MCAPI_ERR_CHAN_INVALID,			// Argument is not a channel handle
	MCAPI_ERR_PKT_SIZE,				// The packet size exceeds the maximum size allowed by the MCAPI implementation
	MCAPI_ERR_TRANSMISSION,			// Transmission failure
	MCAPI_ERR_PRIORITY,				// Incorrect priority level
	MCAPI_ERR_BUF_INVALID,			// Not a valid buffer descriptor
	MCAPI_ERR_MEM_LIMIT,			// Out of memory
	MCAPI_ERR_REQUEST_INVALID,		// Argument is not a valid request handle
	MCAPI_ERR_REQUEST_LIMIT,		// Out of request handles
	MCAPI_ERR_REQUEST_CANCELLED,	// The request was already canceled
	MCAPI_ERR_WAIT_PENDING,			// A wait is pending
	MCAPI_ERR_GENERAL,				// To be used by implementations for error conditions not covered by the other status codes
	MCAPI_STATUSCODE_END			// This should always be last
};

void mcapi_cancel(mcapi_request_t *, mcapi_status_t *);
void mcapi_connect_pktchan_i(mcapi_endpoint_t, mcapi_endpoint_t, mcapi_request_t *,
                             mcapi_status_t *);
void mcapi_connect_sclchan_i(mcapi_endpoint_t, mcapi_endpoint_t, mcapi_request_t *,
                             mcapi_status_t *);
void mcapi_delete_endpoint(mcapi_endpoint_t, mcapi_status_t *);
void mcapi_finalize(mcapi_status_t *);
void mcapi_get_endpoint_attribute(mcapi_endpoint_t, mcapi_uint_t, void *, size_t,
                                  mcapi_status_t *);
void mcapi_get_endpoint_i(mcapi_node_t, mcapi_port_t, mcapi_endpoint_t *,
                          mcapi_request_t *, mcapi_status_t *);
void mcapi_initialize(mcapi_node_t, mcapi_version_t *, mcapi_status_t *);
void mcapi_msg_recv_i(mcapi_endpoint_t, void *, size_t, mcapi_request_t *,
                      mcapi_status_t *);
void mcapi_msg_recv(mcapi_endpoint_t, void *, size_t, size_t *, mcapi_status_t *);
void mcapi_msg_send_i(mcapi_endpoint_t, mcapi_endpoint_t, void *, size_t,
                      mcapi_priority_t, mcapi_request_t *, mcapi_status_t *);
void mcapi_msg_send(mcapi_endpoint_t, mcapi_endpoint_t, void *, size_t,
                    mcapi_priority_t, mcapi_status_t *);
void mcapi_open_pktchan_recv_i(mcapi_pktchan_recv_hndl_t *, mcapi_endpoint_t,
                               mcapi_request_t *, mcapi_status_t *);
void mcapi_open_pktchan_send_i(mcapi_pktchan_send_hndl_t *, mcapi_endpoint_t,
                               mcapi_request_t *, mcapi_status_t *);
void mcapi_open_sclchan_recv_i(mcapi_sclchan_recv_hndl_t *, mcapi_endpoint_t,
                               mcapi_request_t *, mcapi_status_t *);
void mcapi_open_sclchan_send_i(mcapi_sclchan_send_hndl_t *, mcapi_endpoint_t,
                               mcapi_request_t *, mcapi_status_t *);
void mcapi_packetchan_recv_close_i(mcapi_pktchan_recv_hndl_t, mcapi_request_t *,
                                   mcapi_status_t *);
void mcapi_pktchan_recv_i(mcapi_pktchan_recv_hndl_t, void **, mcapi_request_t *,
                          mcapi_status_t *);
void mcapi_pktchan_recv(mcapi_pktchan_recv_hndl_t, void **, size_t *, mcapi_status_t *);
void mcapi_packetchan_send_close_i(mcapi_pktchan_send_hndl_t, mcapi_request_t *,
                                   mcapi_status_t *);
void mcapi_pktchan_send_i(mcapi_pktchan_send_hndl_t, void *, size_t,
                          mcapi_request_t *, mcapi_status_t *);
void mcapi_pktchan_send(mcapi_pktchan_send_hndl_t, void *, size_t, mcapi_status_t *);
void mcapi_sclchan_recv_close_i(mcapi_sclchan_recv_hndl_t, mcapi_request_t *,
                               mcapi_status_t *);
void mcapi_sclchan_send_close_i(mcapi_sclchan_send_hndl_t, mcapi_request_t *,
                                mcapi_status_t *);
void mcapi_sclchan_send_uint16(mcapi_sclchan_send_hndl_t, mcapi_uint16_t,
                               mcapi_status_t *);
void mcapi_sclchan_send_uint32(mcapi_sclchan_send_hndl_t, mcapi_uint32_t,
                               mcapi_status_t *);
void mcapi_sclchan_send_uint64(mcapi_sclchan_send_hndl_t, mcapi_uint64_t,
                               mcapi_status_t *);
void mcapi_sclchan_send_uint8(mcapi_sclchan_send_hndl_t, mcapi_uint8_t,
                              mcapi_status_t *);
void mcapi_set_endpoint_attribute(mcapi_endpoint_t, mcapi_uint_t, void *,
                                  size_t, mcapi_status_t *);

mcapi_endpoint_t mcapi_get_endpoint(mcapi_node_t, mcapi_port_t, mcapi_status_t *);
mcapi_endpoint_t mcapi_create_endpoint(mcapi_port_t, mcapi_status_t *);

mcapi_boolean_t mcapi_test(mcapi_request_t *, size_t *, mcapi_status_t *);
mcapi_boolean_t mcapi_wait(mcapi_request_t *, size_t *, mcapi_status_t *,
                           mcapi_timeout_t);

mcapi_node_t mcapi_get_node_id(mcapi_status_t *);
mcapi_uint_t mcapi_msg_available(mcapi_endpoint_t, mcapi_status_t *);
mcapi_uint_t mcapi_pktchan_available(mcapi_pktchan_recv_hndl_t, mcapi_status_t *);
void mcapi_pktchan_free(void *, mcapi_status_t *);
mcapi_uint_t mcapi_sclchan_available(mcapi_sclchan_recv_hndl_t, mcapi_status_t *);

mcapi_uint16_t mcapi_sclchan_recv_uint16(mcapi_sclchan_recv_hndl_t, mcapi_status_t *);
mcapi_uint32_t mcapi_sclchan_recv_uint32(mcapi_sclchan_recv_hndl_t, mcapi_status_t *);
mcapi_uint64_t mcapi_sclchan_recv_uint64(mcapi_sclchan_recv_hndl_t, mcapi_status_t *);
mcapi_uint8_t mcapi_sclchan_recv_uint8(mcapi_sclchan_recv_hndl_t, mcapi_status_t *);
mcapi_int_t mcapi_wait_any(size_t, mcapi_request_t **, size_t *,
                           mcapi_timeout_t, mcapi_status_t *);

#ifdef          __cplusplus
}
#endif /* _cplusplus */

#endif /* MCAPI_H */
