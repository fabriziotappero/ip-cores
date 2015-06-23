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
*       msg_send
*
*   DESCRIPTION
*
*       Send a connectionless message to an endpoint.  Called by both
*       blocking and non-blocking transmission routines.
*
*   INPUTS
*
*       send_endpoint           The endpoint identifier on the local node
*                               that is sending the data.
*       receive_endpoint        The remote endpoint identifer that is
*                               receiving the data.
*       *buffer                 A pointer to the data to transmit.
*       buffer_size             The number of bytes of data to transmit.
*       priority                The desired priority of the buffer on
*                               transmission.
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
void msg_send(mcapi_endpoint_t send_endpoint, mcapi_endpoint_t receive_endpoint,
              void *buffer, size_t buffer_size, mcapi_priority_t priority,
              mcapi_request_t *request, mcapi_status_t *mcapi_status,
              mcapi_uint32_t timeout)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *tx_endp_ptr = MCAPI_NULL;
    mcapi_port_t        tx_port_id, rx_port_id;
    mcapi_node_t        tx_node_id, rx_node_id;
    MCAPI_BUFFER        *tx_buf;
    int                 tx_node_idx;

    /* Validate the status input parameter. */
    if (mcapi_status)
    {
        /* Validate the input parameters. */
        if ( (request) && ((buffer) || ((!buffer) && (buffer_size == 0))) )
        {
            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get a pointer to the endpoint that is sending data. */
            tx_endp_ptr = mcapi_decode_local_endpoint(node_data, &tx_node_id,
                                                      &tx_port_id,
                                                      send_endpoint,
                                                      mcapi_status);

            /* Ensure the transmit endpoint is valid and unconnected. */
            if (tx_endp_ptr)
            {
                /* Ensure the send endpoint is not connected. */
                if (!(tx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING))
                {
                    /* Check the priority. */
                    if (priority < MCAPI_PRIO_COUNT)
                    {
                        /* Decode the receive side node and port IDs. */
                        mcapi_decode_endpoint(receive_endpoint, &rx_node_id,
                                              &rx_port_id);

                        /* Get the index of the local node. */
                        tx_node_idx = mcapi_find_node(tx_node_id, node_data);

                        if (tx_node_idx != -1)
                        {
                            /* Find a route to the destination. */
                            tx_endp_ptr->mcapi_route =
                                mcapi_find_route(rx_node_id,
                                                 &node_data->mcapi_node_list[tx_node_idx]);

                            /* If a route was found. */
                            if (tx_endp_ptr->mcapi_route)
                            {
                                /* Ensure the length of the buffer is valid. */
                                if (buffer_size + MCAPI_HEADER_LEN <=
                                    tx_endp_ptr->mcapi_route->mcapi_rt_int->mcapi_max_buf_size)
                                {
                                    /* Get a transmission buffer for tracking when
                                     * the outgoing data has been successfully sent.
                                     */
                                    tx_buf = tx_endp_ptr->mcapi_route->mcapi_rt_int->
                                        mcapi_get_buffer(rx_node_id, buffer_size +
                                                         MCAPI_HEADER_LEN, priority);

                                    if (tx_buf)
                                    {
                                        /* Save a pointer to the tx interface. */
                                        tx_buf->mcapi_dev_ptr =
                                            (MCAPI_POINTER)(tx_endp_ptr->mcapi_route->mcapi_rt_int);

                                        /* Initialize the request structure. */
                                        mcapi_init_request(request, MCAPI_REQ_TX_FIN);

                                        /* Set up the request structure. */
                                        request->mcapi_target_endp = send_endpoint;

                                        /* Set the source node in the packet. */
                                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_SRC_NODE_OFFSET,
                                                    tx_endp_ptr->mcapi_node_id);

                                        /* Set the source port in the packet. */
                                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_SRC_PORT_OFFSET,
                                                    tx_endp_ptr->mcapi_port_id);

                                        /* Set the destination node in the packet. */
                                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_DEST_NODE_OFFSET,
                                                    rx_node_id);

                                        /* Set the destination port in the packet. */
                                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_DEST_PORT_OFFSET,
                                                    rx_port_id);

                                        /* Set the priority of the packet. */
                                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_PRIO_OFFSET,
                                                    tx_endp_ptr->mcapi_priority);

                                        /* Zero out the unused bits. */
                                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_UNUSED_OFFSET, 0);

                                        /* Copy the data into the MCAPI buffer. */
                                        memcpy(&tx_buf->buf_ptr[MCAPI_HEADER_LEN], buffer,
                                               buffer_size);

                                        /* Set the length of the data in the buffer. */
                                        tx_buf->buf_size = buffer_size + MCAPI_HEADER_LEN;

                                        /* Fill in the fields for the foreign node. */
                                        tx_endp_ptr->mcapi_foreign_node_id = rx_node_id;
                                        tx_endp_ptr->mcapi_foreign_port_id = rx_port_id;

                                        /* Pass the data to the transport layer driver. */
                                        *mcapi_status =
                                            tx_endp_ptr->mcapi_route->
                                                mcapi_rt_int->mcapi_tx_output(tx_buf,
                                                                              buffer_size,
                                                                              priority,
                                                                              tx_endp_ptr);

                                        /* The data was transmitted. */
                                        if (*mcapi_status == MCAPI_SUCCESS)
                                        {
                                            /* Set the status to success. */
                                            request->mcapi_status = MCAPI_SUCCESS;

                                            /* Record the number of bytes sent. */
                                            request->mcapi_byte_count = buffer_size;
                                        }

                                        /* The data could not be transmitted. */
                                        else
                                        {
                                            request->mcapi_status = *mcapi_status;

                                            /* Indicate that no data was sent. */
                                            request->mcapi_byte_count = 0;

                                            /* Return the buffer to the list of free
                                             * buffers.
                                             */
                                            ((MCAPI_INTERFACE*)(tx_buf->mcapi_dev_ptr))->
                                                mcapi_recover_buffer(tx_buf);
                                        }
                                    }

                                    /* There are no transmission buffers available to
                                     * process this request.
                                     */
                                    else
                                    {
                                        *mcapi_status = MCAPI_ERR_TRANSMISSION;
                                    }
                                }

                                /* Message size exceeds the maximum size allowed. */
                                else
                                {
                                    *mcapi_status = MCAPI_ERR_MSG_SIZE;
                                }
                            }

                            /* Return an error indicating that the node
                             * is not reachable.
                             */
                            else
                            {
                                *mcapi_status = MCAPI_ERR_NODE_INVALID;
                            }
                        }

                        /* The endpoint is not valid. */
                        else
                        {
                            *mcapi_status = MCAPI_ERR_ENDP_INVALID;
                        }
                    }

                    /* The priority is not valid. */
                    else
                    {
                        *mcapi_status = MCAPI_ERR_PRIORITY;
                    }
                }

                /* One or both endpoints are connected to a channel. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                }
            }

            /* The endpoint is not valid. */
            else
            {
                *mcapi_status = MCAPI_ERR_ENDP_INVALID;
            }
        }

        /* The buffer parameter is invalid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }

}
