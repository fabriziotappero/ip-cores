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

extern MCAPI_INTERFACE  MCAPI_Interface_List[];

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_delete_endpoint
*
*   DESCRIPTION
*
*       API routine to delete a specific endpoint on the local node.
*       An endpoint can be deleted only by the node that created the
*       endpoint.  All pending incoming messages will be discarded
*       upon deletion.  If the endpoint is a packet or scalar, the
*       connection must be closed before deleting the endpoint.
*
*   INPUTS
*
*       endpoint                The endpoint identifier on the local node
*                               to delete.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The endpoint identifier associated with the node ID / port ID
*       combination.
*
*************************************************************************/
void mcapi_delete_endpoint(mcapi_endpoint_t endpoint,
                           mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *endp_ptr = MCAPI_NULL;
    int                 node_idx;
    mcapi_node_t        node_id;
    mcapi_port_t        port_id;
    MCAPI_BUFFER        *cur_buf;

    /* Ensure mcapi_status is valid. */
    if (mcapi_status)
    {
        /* Get the lock. */
        mcapi_lock_node_data();

        /* Get a pointer to the global node list. */
        node_data = mcapi_get_node_data();

        /* Get a pointer to the endpoint. */
        endp_ptr = mcapi_decode_local_endpoint(node_data, &node_id, &port_id,
                                               endpoint, mcapi_status);

        /* Ensure the endpoint is valid. */
        if (*mcapi_status == MCAPI_SUCCESS)
        {
            /* Ensure the endpoint is not part of a connected channel. */
            if ( (!(endp_ptr->mcapi_state & MCAPI_ENDP_TX)) &&
                 (!(endp_ptr->mcapi_state & MCAPI_ENDP_RX)) )
            {
                /* Get a pointer to the node structure. */
                node_idx = mcapi_find_node(node_id, node_data);

                if (node_idx != -1)
                {
                    /* Decrement the number of used endpoints on this node. */
                    node_data->mcapi_node_list[node_idx].mcapi_endpoint_count --;

                    /* If the endpoint is part of a half-open connection. */
                    if (endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING)
                    {
                        /* Close the connection. */
                        mcapi_tx_fin_msg(endp_ptr, mcapi_status);
                    }

                    /* Cancel any threads blocking on this endpoint and set an
                     * error in the request structure.
                     */
                    mcapi_check_resume(MCAPI_REQ_DELETED, endpoint, MCAPI_NULL, 0,
                                       MCAPI_ERR_PORT_INVALID);

                    /* Set the state of the entry to closed. */
                    endp_ptr->mcapi_state = MCAPI_ENDP_CLOSED;

                    /* Remove the first buffer from the receive queue. */
                    cur_buf = mcapi_dequeue(&endp_ptr->mcapi_rx_queue);

                    /* If there is data pending on the endpoint, free it. */
                    while (cur_buf)
                    {
                        /* Remove the buffer from the receive queue and place
                         * it on the free list.
                         */
                        ((MCAPI_INTERFACE*)(cur_buf->mcapi_dev_ptr))->
                            mcapi_recover_buffer(cur_buf);

                        /* Get the next buffer. */
                        cur_buf = mcapi_dequeue(&endp_ptr->mcapi_rx_queue);
                    }

                    *mcapi_status = MCAPI_SUCCESS;
                }

                else
                {
                    *mcapi_status = MCAPI_ERR_ENDP_INVALID;
                }
            }

            /* Channel must be closed before deleting an endpoint. */
            else
            {
                *mcapi_status = MCAPI_ERR_CHAN_OPEN;
            }
        }

        /* Release the lock. */
        mcapi_unlock_node_data();
    }

}
