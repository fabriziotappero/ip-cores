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
*       mcapi_find_endpoint
*
*   DESCRIPTION
*
*       Finds a specific endpoint in the system.
*
*   INPUTS
*
*       port_id                 The port ID of the target endpoint.
*       *node_ptr               A pointer to the node structure
*                               associated with the endpoint.
*
*   OUTPUTS
*
*       Index into the endpoint list of the respective node or
*       -1 if the endpoint does not exist.
*
*************************************************************************/
int mcapi_find_endpoint(mcapi_port_t port_id, MCAPI_NODE *node_ptr)
{
    int     endp_idx, i = 0;

    /* Compute the hash value. */
    endp_idx = (port_id % MCAPI_MAX_ENDPOINTS);

    /* If this is the matching endpoint. */
    if (node_ptr->mcapi_endpoint_list[endp_idx].mcapi_port_id == port_id)
    {
        /* Ensure the endpoint has not been closed. */
        if (!(node_ptr->mcapi_endpoint_list[endp_idx].mcapi_state & MCAPI_ENDP_OPEN))
        {
            /* Return an error. */
            endp_idx = -1;
        }
    }

    else
    {
        /* Find an empty slot. */
        do
        {
            /* Move to the next slot. */
            endp_idx ++;

            /* If the index has rolled over. */
            if ( (endp_idx < 0) ||
                 (endp_idx >= MCAPI_MAX_ENDPOINTS) )
            {
                endp_idx = 0;
            }

            /* If this is the target endpoint. */
            if (node_ptr->mcapi_endpoint_list[endp_idx].mcapi_port_id == port_id)
            {
                /* Ensure the endpoint has not been closed. */
                if (!(node_ptr->mcapi_endpoint_list[endp_idx].mcapi_state & MCAPI_ENDP_OPEN))
                {
                    /* Return an error. */
                    endp_idx = -1;
                }

                break;
            }

            i ++;

        } while (i < MCAPI_MAX_ENDPOINTS);

        /* If a matching endpoint was not found. */
        if (i >= MCAPI_MAX_ENDPOINTS)
            endp_idx = -1;
    }

    return (endp_idx);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_encode_endpoint
*
*   DESCRIPTION
*
*       Encodes a handle using the index of the respective node and
*       the port ID of the endpoint.
*
*   INPUTS
*
*       node_id                 Node ID of the endpoint.
*       port_id                 Port ID of the endpoint.
*
*   OUTPUTS
*
*       The 32-bit encoded handle.
*
*************************************************************************/
mcapi_endpoint_t mcapi_encode_endpoint(mcapi_node_t node_id,
                                       mcapi_port_t port_id)
{
    mcapi_endpoint_t    handle = 0;

    /* Put the node index in the handle. */
    handle = node_id;

    /* Move the node ID left 16-bits. */
    handle <<= 16;

    /* Add the port ID to the lower 16-bits of the handle. */
    handle |= port_id;

    return (handle);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_decode_endpoint
*
*   DESCRIPTION
*
*       Decodes a handle to retrieve the index of the respective node and
*       endpoint.
*
*   INPUTS
*
*       handle                  The encoded handle.
*       *node_id                A pointer to memory that will hold the
*                               decoded node ID.
*       *endp_id                A pointer to memory that will hold the
*                               decoded endpoint ID.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_decode_endpoint(mcapi_endpoint_t handle, mcapi_node_t *node_id,
                           mcapi_port_t *port_id)
{
    /* Extract the high 16-bits by chopping off the low 16-bits and moving
     * the remaining data over 16-bits.
     */
    *node_id = (handle & 0xffff0000) >> 16;

    /* Extract the low 16-bits by chopping off the high 16-bits. */
    *port_id = (handle & 0x0000ffff);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_decode_local_endpoint
*
*   DESCRIPTION
*
*       Decodes a handle to retrieve a pointer to the MCAPI_ENDPOINT
*       structure associated with a local endpoint.
*
*   INPUTS
*
*       *node_data              A pointer to the global database.
*       *node_id                A pointer to memory that will hold the
*                               decoded node ID.
*       *port_id                A pointer to memory that will hold the
*                               decoded endpoint ID.
*       endpoint                The encoded endpoint.
*       *status                 The status to be filled in.
*
*   OUTPUTS
*
*       A pointer to the endpoint structure or MCAPI_NULL if one
*       does not exist.
*
*************************************************************************/
MCAPI_ENDPOINT *mcapi_decode_local_endpoint(MCAPI_GLOBAL_DATA *node_data,
                                            mcapi_node_t *node_id,
                                            mcapi_port_t *port_id,
                                            mcapi_endpoint_t endpoint,
                                            mcapi_status_t *mcapi_status)
{
    int             node_idx, endp_idx;
    MCAPI_ENDPOINT  *endp_ptr = MCAPI_NULL;

    /* Decode the node and port IDs. */
    mcapi_decode_endpoint(endpoint, node_id, port_id);

    /* Get the index of the node. */
    node_idx = mcapi_find_node(*node_id, node_data);

    /* If the node is valid. */
    if (node_idx != -1)
    {
        /* Get the index of the endpoint. */
        endp_idx =
            mcapi_find_endpoint(*port_id, &node_data->mcapi_node_list[node_idx]);

        /* Validate the endpoint index. */
        if ( (endp_idx >= 0) && (endp_idx < MCAPI_MAX_ENDPOINTS) )
        {
            endp_ptr =
                &node_data->mcapi_node_list[node_idx].mcapi_endpoint_list[endp_idx];

            *mcapi_status = MCAPI_SUCCESS;
        }

        /* The endpoint does not exist. */
        else
        {
            *mcapi_status = MCAPI_ERR_ENDP_INVALID;
        }
    }

    /* The node is not a local node. */
    else
    {
        *mcapi_status = MCAPI_ERR_ENDP_NOTOWNER;
    }

    return (endp_ptr);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_find_local_endpoint
*
*   DESCRIPTION
*
*       Returns the MCAPI_ENDPOINT structure associated with a
*       local node ID, port ID combination.
*
*   INPUTS
*
*       *node_data              A pointer to the global database.
*       node_id                 The node ID of the target endpoint.
*       port_id                 The port ID of the target endpoint.
*
*   OUTPUTS
*
*       A pointer to the endpoint structure or MCAPI_NULL if one
*       does not exist.
*
*************************************************************************/
MCAPI_ENDPOINT *mcapi_find_local_endpoint(MCAPI_GLOBAL_DATA *node_data,
                                          mcapi_node_t node_id,
                                          mcapi_port_t port_id)
{
    int             node_idx, endp_idx;
    MCAPI_ENDPOINT  *endp_ptr = MCAPI_NULL;

    /* Get the index of the local node. */
    node_idx = mcapi_find_node(node_id, node_data);

    /* If the node is local. */
    if (node_idx != -1)
    {
        /* Get a pointer to the local endpoint. */
        endp_idx =
            mcapi_find_endpoint(port_id, &node_data->mcapi_node_list[node_idx]);

        /* If the endpoint exists. */
        if (endp_idx >= 0)
        {
            endp_ptr = &node_data->mcapi_node_list[node_idx].
                mcapi_endpoint_list[endp_idx];
        }
    }

    return (endp_ptr);

}

