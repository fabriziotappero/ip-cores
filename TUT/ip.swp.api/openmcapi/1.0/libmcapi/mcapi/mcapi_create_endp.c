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

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_create_endpoint
*
*   DESCRIPTION
*
*       API routine to create an endpoint on the local node.  If the port
*       ID field is set to MCAPI_PORT_ANY, an endpoint will be created using
*       the next available port in the system.
*
*   INPUTS
*
*       port_id                 The port ID of the endpoint, or MCAPI_PORT_ANY
*                               to create an endpoint with the next available
*                               port ID.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The newly created endpoint.
*
*************************************************************************/
mcapi_endpoint_t mcapi_create_endpoint(mcapi_port_t port_id,
                                       mcapi_status_t *mcapi_status)
{
    mcapi_endpoint_t    endpoint = 0;
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_NODE          *node_ptr = MCAPI_NULL;
    int                 node_idx;

    /* Ensure mcapi_status is valid. */
    if (mcapi_status)
    {
        /* Ensure the port ID is only 16-bits in length. */
        if ( (port_id == MCAPI_PORT_ANY) || (port_id <= 65535) )
        {
            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get a pointer to the local node. */
            node_idx = mcapi_find_node(MCAPI_Node_ID, node_data);

            /* If the node has been initialized. */
            if (node_idx != -1)
            {
                /* Get a pointer to the node structure. */
                node_ptr = &node_data->mcapi_node_list[node_idx];

                /* Create the endpoint. */
                endpoint = create_endpoint(node_ptr, port_id, mcapi_status);
            }

            /* The node has not been initialized. */
            else
            {
                *mcapi_status = MCAPI_ERR_NODE_NOTINIT;
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* Ports can be only 16-bits in length. */
        else
        {
            *mcapi_status = MCAPI_ERR_PORT_INVALID;
        }
    }

    return (endpoint);

}
