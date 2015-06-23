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

extern MCAPI_BUF_QUEUE      MCAPI_Buf_Wait_List;

/*************************************************************************
*
*   FUNCTION
*
*       pkt_rcv
*
*   DESCRIPTION
*
*       Receive a packet over a connected channel.  Called by both
*       blocking and non-blocking transmission routines.
*
*   INPUTS
*
*       receive_handle          The local handle that is receiving the data.
*       **buffer                A pointer to a pointer that will be set to the
*                               memory address of the incoming buffer.
*       *received_size          The number of bytes received.
*       *request                A pointer to memory that will be filled in
*                               with data relevant to the operation, so the
*                               status of the operation can later be checked.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*       timeout                 The amount of time to block for the operation
*                               to complete.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void pkt_rcv(mcapi_pktchan_recv_hndl_t receive_handle, void **buffer,
             size_t *received_size, mcapi_request_t *request,
             mcapi_status_t *mcapi_status, mcapi_uint32_t timeout)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *rx_endp_ptr = MCAPI_NULL;
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;
    MCAPI_BUFFER        *rx_buf = MCAPI_NULL;

    /* Validate mcapi_status. */
    if (mcapi_status)
    {
        /* Validate the input parameters. */
        if ( (request) && (received_size) && (buffer) )
        {
            /* Initialize bytes received to zero. */
            *received_size = 0;
            request->mcapi_byte_count = 0;

            /* Lock the global data structure. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get a pointer to the endpoint that is receiving data. */
            rx_endp_ptr = mcapi_decode_local_endpoint(node_data, &node_id,
                                                      &port_id,
                                                      receive_handle,
                                                      mcapi_status);

            /* Ensure the receive endpoint is valid. */
            if (rx_endp_ptr)
            {
                /* Ensure this is a receive endpoint. */
                if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_RX)
                {
                    /* Ensure the handle is for a packet channel. */
                    if (rx_endp_ptr->mcapi_chan_type == MCAPI_CHAN_PKT_TYPE)
                    {
                        /* Initialize the request structure. */
                        mcapi_init_request(request, MCAPI_REQ_RX_FIN);

                        /* Set up the request structure. */
                        request->mcapi_target_endp = receive_handle;
                        request->mcapi_chan_type = MCAPI_CHAN_PKT_TYPE;

                        /* Set the request structure's buffer to the
                         * application's buffer that will be filled in when
                         * data is received.
                         */
                        request->mcapi_pkt = buffer;

                        /* Check if there is data on the endpoint. */
                        if (rx_endp_ptr->mcapi_rx_queue.head)
                        {
                            /* Remove the buffer from the queue. */
                            rx_buf =
                                mcapi_dequeue(&rx_endp_ptr->mcapi_rx_queue);

                            /* Set the user buffer to the incoming buffer. */
                            *buffer = &rx_buf->buf_ptr[MCAPI_HEADER_LEN];

                            /* Set the size of the incoming buffer. */
                            *received_size = rx_buf->buf_size - MCAPI_HEADER_LEN;

                            /* Add the receive buffer structure to the list of
                             * buffers waiting to be freed by the application.
                             */
                            mcapi_enqueue(&MCAPI_Buf_Wait_List, rx_buf);

                            /* Set the number of bytes in the request structure. */
                            request->mcapi_byte_count = *received_size;

                            /* Indicate completion of the operation. */
                            *mcapi_status =
                                request->mcapi_status = MCAPI_SUCCESS;
                        }

                        /* If there is no data waiting on the endpoint, ensure the
                         * endpoint is still part of a connection before blocking for
                         * data.
                         */
                        else if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED)
                        {
                            /* If this is a blocking request, suspend until the
                             * operation has completed or been canceled.
                             */
                            if (timeout)
                            {
                                MCAPI_Suspend_Task(node_data, request,
                                                   &request->mcapi_cond,
                                                   MCAPI_TIMEOUT_INFINITE);

                                /* Return the number of bytes received. */
                                *received_size = request->mcapi_byte_count;

                                /* Set the return status. */
                                *mcapi_status = request->mcapi_status;
                            }

                            /* This is a non-blocking receive. */
                            else
                            {
                                /* Add the application's request structure to
                                 * the list of pending requests for the node.
                                 */
                                mcapi_enqueue(&node_data->mcapi_local_req_queue, request);

                                /* Indicate completion of the operation. */
                                *mcapi_status = MCAPI_SUCCESS;
                            }
                        }

                        /* The connection has been closed. */
                        else
                        {
                            *mcapi_status = MCAPI_ERR_CHAN_INVALID;
                        }
                    }

                    /* The handle is for a scalar channel. */
                    else
                    {
                        *mcapi_status = MCAPI_ERR_CHAN_TYPE;
                    }
                }

                /* Attempting to receive on a send handle. */
                else if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_TX)
                {
                    *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                }

                /* The receive side has been closed. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_INVALID;
                }
            }

            else
            {
                *mcapi_status = MCAPI_ERR_CHAN_INVALID;
            }

            /* Unlock the global data structure. */
            mcapi_unlock_node_data();
        }

        /* The request structure is invalid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }

}
