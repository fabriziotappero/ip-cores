/*
 * Copyright (c) 2010, Mentor Graphics Corporation
 * All rights reserved.
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



#include <openmcapi.h>

extern mcapi_endpoint_t MCAPI_CTRL_TX_Endp;
extern mcapi_endpoint_t MCAPI_CTRL_RX_Endp;

/*************************************************************************
*
*   FUNCTION
*
*       get_endpoint
*
*   DESCRIPTION
*
*       Retrieves the endpoint identifier associated with a specific node
*       ID and port ID.
*
*   INPUTS
*
*       node_id                 The unique ID of the node on which the target
*                               endpoint resides.
*       port_id                 The port ID of the target endpoint.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*       timeout                 The amount of time to block for the operation
*                               to complete.
*
*   OUTPUTS
*
*       The endpoint identifier associated with the node ID / port ID
*       combination.
*
*************************************************************************/
void get_remote_endpoint(mcapi_node_t node_id, mcapi_port_t port_id,
                         mcapi_status_t *mcapi_status,
                         mcapi_uint32_t timeout)
{
    mcapi_endpoint_t    dest_endpoint;
    unsigned char       buffer[MCAPI_GET_ENDP_LEN];
    mcapi_request_t     request;

    /* Set the type. */
    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_GETENDP_REQUEST);

    /* Set the port. */
    MCAPI_PUT16(buffer, MCAPI_GETENDP_PORT, port_id);

    /* Insert the endpoint to which the receiver should respond
     * in the packet.
     */
    MCAPI_PUT32(buffer, MCAPI_GETENDP_ENDP, MCAPI_CTRL_RX_Endp);

    /* Encode the destination endpoint. */
    dest_endpoint =
        mcapi_encode_endpoint(node_id, MCAPI_RX_CONTROL_PORT);

    /* Send the message. */
    msg_send(MCAPI_CTRL_TX_Endp, dest_endpoint, buffer,
             MCAPI_GET_ENDP_LEN, MCAPI_DEFAULT_PRIO,
             &request, mcapi_status, timeout);

}
