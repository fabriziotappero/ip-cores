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

extern mcapi_uint8_t        MCAPI_Init;
extern MCAPI_BUF_QUEUE      MCAPI_RX_Queue;
extern MCAPI_INTERFACE      MCAPI_Interface_List[];
extern MCAPI_MUTEX          MCAPI_Mutex;
extern mcapi_endpoint_t     MCAPI_CTRL_RX_Endp;
extern mcapi_endpoint_t     MCAPI_CTRL_TX_Endp;
extern MCAPI_BUF_QUEUE      MCAPI_Buf_Wait_List;

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_finalize
*
*   DESCRIPTION
*
*       API routine to shut down the MCAPI module on a node.
*
*   INPUTS
*
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_finalize(mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_BUFFER        *cur_buf;
    MCAPI_ENDPOINT      *endp_ptr;
    int                 i, j;
    mcapi_request_t     *request;

    /* Validate the status pointer. */
    if (mcapi_status)
    {
        /* If the node is initialized. */
        if (MCAPI_Init)
        {
            /* Delete the control endpoints. */
            mcapi_delete_endpoint(MCAPI_CTRL_RX_Endp, mcapi_status);
            mcapi_delete_endpoint(MCAPI_CTRL_TX_Endp, mcapi_status);

            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get the index of the node associated with the node ID. */
            i = mcapi_find_node(MCAPI_Node_ID, node_data);

            /* If the node was found. */
            if (i != -1)
            {
                /* Close each open endpoint in the system. */
                for (j = 0; j < MCAPI_MAX_ENDPOINTS; j++)
                {
                    endp_ptr = &node_data->mcapi_node_list[i].mcapi_endpoint_list[j];

                    if (endp_ptr->mcapi_state != MCAPI_ENDP_CLOSED)
                    {
                        /* If this endpoint is part of an open connection. */
                        if ( (endp_ptr->mcapi_state & MCAPI_ENDP_TX) ||
                             (endp_ptr->mcapi_state & MCAPI_ENDP_RX) )
                        {
                            /* Close the connection. */
                            mcapi_tx_fin_msg(endp_ptr, mcapi_status);
                        }

                        /* Set the state to closed. */
                        endp_ptr->mcapi_state = MCAPI_ENDP_CLOSED;

                        /* Cancel any threads blocking on this endpoint and
                         * set an error in the request structure.
                         */
                        mcapi_check_resume(MCAPI_REQ_DELETED,
                                           endp_ptr->mcapi_endp_handle,
                                           MCAPI_NULL, 0, MCAPI_ERR_REQUEST_CANCELLED);

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

                        /* Decrement the number of used endpoints on this node. */
                        node_data->mcapi_node_list[i].mcapi_endpoint_count --;
                    }
                }

                /* Get a pointer to the first entry in the local request
                 * queue.
                 */
                request = mcapi_dequeue(&node_data->mcapi_local_req_queue);

                /* Resume all tasks pending outstanding requests. */
                while (request)
                {
                    /* Resume this thread indicating that the request has
                     * been canceled.
                     */
                    mcapi_resume(node_data, request, MCAPI_ERR_REQUEST_CANCELLED);

                    /* Get the next request structure. */
                    request = mcapi_dequeue(&node_data->mcapi_local_req_queue);
                }

                /* Get a pointer to the first entry in the foreign request
                 * queue.
                 */
                request = mcapi_dequeue(&node_data->mcapi_foreign_req_queue);

                /* Inform all foreign nodes pending outstanding requests. */
                while (request)
                {
                    /* Indicate that the node has shut down. */
                    request->mcapi_status = MCAPI_ERR_NODE_INVALID;

                    /* Send the response to the foreign node. */
                    mcapi_tx_response(node_data, request);

                    /* Get the next request structure. */
                    request = mcapi_dequeue(&node_data->mcapi_foreign_req_queue);
                }

                /* Get a pointer to the first buffer on the wait list. */
                cur_buf = mcapi_dequeue(&MCAPI_Buf_Wait_List);

                /* Free each buffer on this list. */
                while (cur_buf)
                {
                    /* Return the buffer to the list of free buffers. */
                    ((MCAPI_INTERFACE*)(cur_buf->mcapi_dev_ptr))->
                        mcapi_recover_buffer(cur_buf);

                    /* Get a pointer to the next buffer. */
                    cur_buf = mcapi_dequeue(&MCAPI_Buf_Wait_List);
                }

                /* Shut down each interface. Drop the global lock first to
                 * avoid deadlocks with transport-level threads. */
                mcapi_unlock_node_data();
                for (j = 0; j < MCAPI_INTERFACE_COUNT; j++)
                {
                    /* Shut down the interface. */
                    MCAPI_Interface_List[j].mcapi_ioctl(MCAPI_FINALIZE_DRIVER,
                                                        MCAPI_NULL, 0);
                }
                mcapi_lock_node_data();

                /* Remove the first buffer from the pending RX list. */
                cur_buf = mcapi_dequeue(&MCAPI_RX_Queue);

                /* Free all buffers that are pending processing. */
                while (cur_buf)
                {
                    /* Put the buffer on the appropriate free list. */
                    ((MCAPI_INTERFACE*)(cur_buf->mcapi_dev_ptr))->
                        mcapi_recover_buffer(cur_buf);

                    /* Get the next buffer. */
                    cur_buf = mcapi_dequeue(&MCAPI_RX_Queue);
                }

                /* Shut down the OS. */
                MCAPI_Exit_OS();

                /* Set the initialization variable to indicate that MCAPI
                 * is not initialized on this node.
                 */
                MCAPI_Init = 0;

                /* Set the state to finalized. */
                node_data->mcapi_node_list[i].mcapi_state = MCAPI_NODE_FINALIZED;

                *mcapi_status = MCAPI_SUCCESS;
            }

            else
            {
                *mcapi_status = MCAPI_ERR_NODE_FINALFAILED;
            }

            /* Release the lock. */
            mcapi_unlock_node_data();

            if (*mcapi_status == MCAPI_SUCCESS)
            {
                /* Delete the MCAPI mutex. */
                MCAPI_Delete_Mutex(&MCAPI_Mutex);
            }
        }

        else
        {
            *mcapi_status = MCAPI_SUCCESS;
        }
    }

}
