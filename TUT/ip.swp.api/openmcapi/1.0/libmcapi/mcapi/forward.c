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
*       mcapi_forward
*
*   DESCRIPTION
*
*       Forwards an MCAPI packet to another node.
*
*   INPUTS
*
*       *node_data              A pointer to the global structure holding
*                               data about the local node.
*       *mcapi_buf_ptr          A pointer to the buffer to be forwarded.
*       dest_node               The final destination node.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_forward(MCAPI_GLOBAL_DATA *node_data, MCAPI_BUFFER *mcapi_buf_ptr,
                   mcapi_node_t dest_node)
{
    MCAPI_ROUTE     *route_ptr;
    mcapi_status_t  status = -1;
    MCAPI_NODE      *node_ptr;
    int             node_idx;

    /* Get the index of the local node. */
    node_idx = mcapi_find_node(MCAPI_Node_ID, node_data);

    if (node_idx != -1)
    {
        /* Get a pointer to the local node. */
        node_ptr = &node_data->mcapi_node_list[node_idx];

        /* Find a route to the destination. */
        route_ptr = mcapi_find_route(dest_node, node_ptr);

        /* If a route was found. */
        if (route_ptr)
        {
            /* Pass the data to the transport layer driver. */
            status =
                route_ptr->mcapi_rt_int->mcapi_tx_output(mcapi_buf_ptr,
                                                         mcapi_buf_ptr->buf_size,
                                                         MCAPI_GET16(mcapi_buf_ptr->buf_ptr,
                                                         MCAPI_PRIO_OFFSET), MCAPI_NULL);
        }
    }

    /* If the packet could not be forwarded. */
    if (status != MCAPI_SUCCESS)
    {
        ((MCAPI_INTERFACE*)(mcapi_buf_ptr->mcapi_dev_ptr))->
            mcapi_recover_buffer(mcapi_buf_ptr);
    }

}
