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
*       msg_recv
*
*   DESCRIPTION
*
*       Send a connectionless message to an endpoint.  Called by both
*       blocking and non-blocking transmission routines.
*
*   INPUTS
*
*       receive_endpoint        The local endpoint identifer that is
*                               receiving the data.
*       *buffer                 A pointer to memory that will be filled in
*                               with the received data.
*       buffer_size             The number of bytes that will fit in *buffer.
*       *bytes_recv             The numer of bytes received.
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
void msg_recv(mcapi_endpoint_t receive_endpoint, void *buffer,
              size_t buffer_size, size_t *bytes_recv,
              mcapi_request_t *request, mcapi_status_t *mcapi_status,
              mcapi_uint32_t timeout)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *rx_endp_ptr = MCAPI_NULL;
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;
    MCAPI_BUFFER        *cur_buf;

    /* Validate the mcapi_status parameter. */
    if (mcapi_status)
    {
        /* Validate the input parameters. */
        if ( (request) && (bytes_recv) && (buffer) && (buffer_size) )
        {
            /* Set bytes received to zero. */
            *bytes_recv = 0;
            request->mcapi_byte_count = 0;

            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get a pointer to the endpoint. */
            rx_endp_ptr = mcapi_decode_local_endpoint(node_data, &node_id,
                                                      &port_id,
                                                      receive_endpoint,
                                                      mcapi_status);

            /* Ensure the receive endpoint is valid. */
            if (rx_endp_ptr)
            {
                /* Ensure the receive endpoint is not part of a
                 * connection.
                 */
                if (!(rx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING))
                {
                    /* Initialize the request structure. */
                    mcapi_init_request(request, MCAPI_REQ_RX_FIN);

                    /* Set up the request structure. */
                    request->mcapi_target_endp = receive_endpoint;
                    request->mcapi_chan_type = MCAPI_MSG_TYPE;

                    /* Set the request structure's buffer to the
                     * application's buffer that will be filled in when
                     * data is received.
                     */
                    request->mcapi_buffer = buffer;

                    /* Set the size of the application's buffer. */
                    request->mcapi_buf_size = buffer_size;

                    /* Check if there is data on the endpoint. */
                    if (rx_endp_ptr->mcapi_rx_queue.head)
                    {
                        /* Ensure all the data will fit in the user buffer. */
                        if (rx_endp_ptr->mcapi_rx_queue.head->buf_size -
                            MCAPI_HEADER_LEN <= buffer_size)
                        {
                            /* Copy the data into the user buffer. */
                            *bytes_recv = msg_recv_copy_data(rx_endp_ptr, buffer);

                            /* Remove the buffer from the receive queue. */
                            cur_buf = mcapi_dequeue(&rx_endp_ptr->mcapi_rx_queue);

                            /* Return the receive buffer to the pool of available buffers. */
                            ((MCAPI_INTERFACE*)(cur_buf->mcapi_dev_ptr))->
                                mcapi_recover_buffer(cur_buf);

                            /* Set the status. */
                            *mcapi_status = request->mcapi_status = MCAPI_SUCCESS;

                            /* Store the number of bytes received. */
                            request->mcapi_byte_count = *bytes_recv;
                        }

                        /* The data is too large for the buffer. */
                        else
                        {
                            *mcapi_status = request->mcapi_status =
                                MCAPI_ERR_MSG_TRUNCATED;
                        }
                    }

                    /* If this is a blocking request, suspend until the
                     * operation has completed or been canceled.
                     */
                    else if (timeout)
                    {
                        MCAPI_Suspend_Task(node_data, request, &request->mcapi_cond,
                                           MCAPI_TIMEOUT_INFINITE);

                        /* Return the number of bytes received. */
                        *bytes_recv = request->mcapi_byte_count;

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

                /* This endpoint is part of a connected channel. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                }
            }

            /* The endpoint is invalid. */
            else
            {
                *mcapi_status = MCAPI_ERR_ENDP_INVALID;
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* The request structure is not valid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }

}

/*************************************************************************
*
*   FUNCTION
*
*       msg_recv_copy_data
*
*   DESCRIPTION
*
*       Copies data from the receive queue into the user buffer and
*       sets the statuses accordingly.
*
*   INPUTS
*
*       *rx_endp_ptr            A pointer to the endpoint structure on which
*                               data is being received.
*       *buffer                 A pointer to memory that will be filled in
*                               with the received data.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
size_t msg_recv_copy_data(MCAPI_ENDPOINT *rx_endp_ptr, void *buffer)
{
    MCAPI_BUFFER    *cur_buf;

    /* Get the head buffer from the receive queue. */
    cur_buf = rx_endp_ptr->mcapi_rx_queue.head;

    /* Copy the data into the user buffer, removing the MCAPI header. */
    memcpy(buffer, &cur_buf->buf_ptr[MCAPI_HEADER_LEN],
           cur_buf->buf_size - MCAPI_HEADER_LEN);

    return (cur_buf->buf_size - MCAPI_HEADER_LEN);

}
