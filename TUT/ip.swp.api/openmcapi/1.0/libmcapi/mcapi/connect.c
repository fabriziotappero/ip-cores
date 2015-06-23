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
extern mcapi_endpoint_t MCAPI_CTRL_TX_Endp;

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_connect
*
*   DESCRIPTION
*
*       Connect two endpoints.
*
*   INPUTS
*
*       send_endpoint           The sending endpoint of the connection.
*       receive_endpoint        The receiving endpoint of the connection.
*       type                    The type of connection; packet or scalar.
*       *request                A pointer to memory that will be filled in
*                               with data relevant to the operation, so the
*                               status of the operation can later be checked.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_connect(mcapi_endpoint_t send_endpoint,
                   mcapi_endpoint_t receive_endpoint, mcapi_uint32_t type,
                   mcapi_request_t *request, mcapi_status_t *mcapi_status)
{
    mcapi_node_t        rx_node, tx_node;
    mcapi_port_t        rx_port, tx_port;
    MCAPI_GLOBAL_DATA   *node_data;
    unsigned char       buffer[MCAPI_CONNECT_MSG_LEN];
    mcapi_endpoint_t    dest_endpoint;
    MCAPI_ENDPOINT      *local_endp;
    mcapi_request_t     local_request;

    /* Validate the status parameter. */
    if (mcapi_status)
    {
        /* Validate the request input parameter. */
        if (request)
        {
            /* Initialize status to success. */
            *mcapi_status = MCAPI_SUCCESS;

            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Decode the send endpoint. */
            mcapi_decode_endpoint(send_endpoint, &tx_node, &tx_port);

            /* Decode the receive endpoint. */
            mcapi_decode_endpoint(receive_endpoint, &rx_node, &rx_port);

            /* Initialize the request structure. */
            mcapi_init_request(request, MCAPI_REQ_CONNECTED);

            /* Set up the request structure. */
            request->mcapi_target_endp = send_endpoint;

            /* If the send endpoint is local, ensure it is valid to
             * attempt a connection.
             */
            if (tx_node == MCAPI_Node_ID)
            {
                /* Get a pointer to the endpoint structure. */
                local_endp =
                    mcapi_find_local_endpoint(node_data, tx_node, tx_port);

                /* If the endpoint has not been created on the node. */
                if (!local_endp)
                {
                    *mcapi_status = request->mcapi_status = MCAPI_ERR_ENDP_INVALID;
                }

                /* If the endpoint is already connected set an error. */
                else if (local_endp->mcapi_state & MCAPI_ENDP_CONNECTING)
                {
                    *mcapi_status = request->mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                }

                /* If the endpoint has been opened as a conflicting channel
                 * type.
                 */
                else if ( (local_endp->mcapi_chan_type != 0) &&
                          (local_endp->mcapi_chan_type != type) )
                {
                    *mcapi_status = request->mcapi_status = MCAPI_ERR_CHAN_TYPE;
                }
            }

            /* If the receive endpoint is local, ensure it is valid to
             * attempt a connection.
             */
            if ( (*mcapi_status == MCAPI_SUCCESS) && (rx_node == MCAPI_Node_ID) )
            {
                /* Get a pointer to the endpoint structure. */
                local_endp =
                    mcapi_find_local_endpoint(node_data, rx_node, rx_port);

                /* If the endpoint has not been created on the node. */
                if (!local_endp)
                {
                    *mcapi_status = request->mcapi_status = MCAPI_ERR_ENDP_INVALID;
                }

                /* If the endpoint is already connected, set an error. */
                else if (local_endp->mcapi_state & MCAPI_ENDP_CONNECTING)
                {
                    *mcapi_status = request->mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                }

                /* If the endpoint has been opened as a conflicting channel
                 * type.
                 */
                else if ( (local_endp->mcapi_chan_type != 0) &&
                          (local_endp->mcapi_chan_type != type) )
                {
                    *mcapi_status = request->mcapi_status = MCAPI_ERR_CHAN_TYPE;
                }
            }

            /* If an error has not occurred. */
            if (*mcapi_status == MCAPI_SUCCESS)
            {
                /* Put the protocol type in the header. */
                MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_CONNECT_REQUEST);

                /* Set the connection request node. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_REQ_NODE, MCAPI_Node_ID);

                /* Set the connection request port. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_REQ_PORT,
                            MCAPI_RX_CONTROL_PORT);

                /* Set the send node. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_TX_NODE, tx_node);

                /* Set the send port. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_TX_PORT, tx_port);

                /* Set the receive node. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_RX_NODE, rx_node);

                /* Set the receive port. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_RX_PORT, rx_port);

                /* Set the type field. */
                MCAPI_PUT16(buffer, MCAPI_CNCT_CHAN_TYPE, type);

                /* Initialize status to all zero. */
                MCAPI_PUT32(buffer, MCAPI_CNCT_STATUS, 0);

                /* Encode the endpoint to which this packet will be sent. */
                dest_endpoint =
                    mcapi_encode_endpoint(tx_node, MCAPI_RX_CONTROL_PORT);

                /* Send a message to the send node to open a connection.
                 * The send node will then issue a three-way handshake with
                 * the receive node and report the status back to the
                 * connector, so there is no need to send a request to the
                 * receiver too.
                 */
                msg_send(MCAPI_CTRL_TX_Endp, dest_endpoint, buffer,
                         MCAPI_CONNECT_MSG_LEN, MCAPI_DEFAULT_PRIO,
                         &local_request, mcapi_status, 0);

                /* If the connection request could be sent. */
                if (*mcapi_status == MCAPI_SUCCESS)
                {
                    /* Add the application's request structure to
                     * the list of pending requests for the node.
                     */
                    mcapi_enqueue(&node_data->mcapi_local_req_queue, request);
                }

                else
                {
                    request->mcapi_status = *mcapi_status;
                }
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* The request structure is invalid. */
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
*       mcapi_open
*
*   DESCRIPTION
*
*       Open the send or receive side of a connection.
*
*   INPUTS
*
*       send_endpoint           The sending endpoint of the connection.
*       type                    The type of channel; packet or scalar.
*       *request                A pointer to memory that will be filled in
*                               with data relevant to the operation, so the
*                               status of the operation can later be checked.
*       flag                    MCAPI_ENDP_TX for opening the send side.
*                               MCAPI_ENDP_RX for opening the receive side.
*       request_type            MCAPI_REQ_TX_OPEN for opening send side.
*                               MCAPI_REQ_RX_OPEN for opening receive side.
*       pkt_type                MCAPI_OPEN_TX for opening send side.
*                               MCAPI_OPEN_RX for opening receive side.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_open(mcapi_endpoint_t local_endpoint, mcapi_uint32_t type,
                mcapi_request_t *request, mcapi_uint32_t flag,
                mcapi_uint16_t request_type, mcapi_uint16_t pkt_type,
                mcapi_status_t *mcapi_status)
{
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *endp_ptr = MCAPI_NULL;
    unsigned char       buffer[MCAPI_CONNECT_MSG_LEN];

    /* Validate the mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate the request input parameter. */
        if (request)
        {
            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Decode the local endpoint. */
            endp_ptr =
                mcapi_decode_local_endpoint(node_data, &node_id, &port_id,
                                            local_endpoint, mcapi_status);

            /* Ensure the endpoint is valid. */
            if (endp_ptr)
            {
                /* Ensure the endpoint is not already open and connected. */
                if (!(endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED))
                {
                    /* Ensure this endpoint has not already been opened. */
                    if ( (!(endp_ptr->mcapi_state & MCAPI_ENDP_TX)) &&
                         (!(endp_ptr->mcapi_state & MCAPI_ENDP_RX)) )
                    {
                        /* If a connect has been issued already, send a message
                         * to the other side that this side is opening.
                         */
                        if (endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING)
                        {
                            /* Ensure the type of open matches the connect. */
                            if (endp_ptr->mcapi_chan_type == type)
                            {
                                /* Initialize the status. */
                                *mcapi_status = MCAPI_SUCCESS;

                                /* If the send side is being opened. */
                                if (flag == MCAPI_ENDP_TX)
                                {
                                    /* Ensure the endpoint has not been opened for
                                     * receiving or connected as a receiver.
                                     */
                                    if ( (!(endp_ptr->mcapi_state & MCAPI_ENDP_RX)) &&
                                         (!(endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING_RX)) )
                                    {
                                        /* Send the open request to the other side. */
                                        mcapi_tx_open(buffer, endp_ptr,
                                                      endp_ptr->mcapi_node_id,
                                                      endp_ptr->mcapi_port_id,
                                                      endp_ptr->mcapi_foreign_node_id,
                                                      endp_ptr->mcapi_foreign_port_id,
                                                      pkt_type, type, mcapi_status);
                                    }

                                    else
                                    {
                                        *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                                    }
                                }

                                /* The receive side is being opened. */
                                else
                                {
                                    /* Ensure the endpoint has not been opened for
                                     * sending or connected as a sender.
                                     */
                                    if ( (!(endp_ptr->mcapi_state & MCAPI_ENDP_TX)) &&
                                         (!(endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING_TX)) )
                                    {
                                        /* Send the open request to the other side. */
                                        mcapi_tx_open(buffer, endp_ptr,
                                                      endp_ptr->mcapi_foreign_node_id,
                                                      endp_ptr->mcapi_foreign_port_id,
                                                      endp_ptr->mcapi_node_id,
                                                      endp_ptr->mcapi_port_id, pkt_type,
                                                      type, mcapi_status);
                                    }

                                    else
                                    {
                                        *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                                    }
                                }

                                /* If an error has not occurred. */
                                if (*mcapi_status == MCAPI_SUCCESS)
                                {
                                    /* Initialize the request structure. */
                                    mcapi_init_request(request, request_type);

                                    /* Set up the request structure. */
                                    request->mcapi_target_endp = local_endpoint;

                                    /* Add the application's request structure to
                                     * the list of pending requests for the node.
                                     */
                                    mcapi_enqueue(&node_data->mcapi_local_req_queue, request);

                                    /* Set the state indicating that this side
                                     * has been opened.
                                     */
                                    endp_ptr->mcapi_state |= flag;
                                }
                            }

                            /* The endpoint is of a conflicting channel type. */
                            else
                            {
                                *mcapi_status = MCAPI_ERR_CHAN_TYPE;
                            }
                        }

                        /* The call to connect has not been made yet. */
                        else
                        {
                            /* Initialize the request structure. */
                            mcapi_init_request(request, request_type);

                            /* Set up the request structure. */
                            request->mcapi_target_endp = local_endpoint;

                            /* Add the application's request structure to
                             * the list of pending requests for the node.
                             */
                            mcapi_enqueue(&node_data->mcapi_local_req_queue, request);

                            /* Set the state indicating that this side
                             * has been opened.
                             */
                            endp_ptr->mcapi_state |= flag;

                            /* Store the type. */
                            endp_ptr->mcapi_chan_type = type;

                            /* Return a status indicating that the endpoint
                             * is still waiting to be officially connected.
                             */
                            *mcapi_status = MGC_MCAPI_ERR_NOT_CONNECTED;
                        }
                    }

                    /* The endpoint has been opened already. */
                    else
                    {
                        /* If the types don't match. */
                        if ( ((flag == MCAPI_ENDP_TX) &&
                              (endp_ptr->mcapi_state & MCAPI_ENDP_RX)) ||
                             ((flag == MCAPI_ENDP_RX) &&
                              (endp_ptr->mcapi_state & MCAPI_ENDP_TX)) )
                        {
                            *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                        }

                        else
                        {
                            *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                        }
                    }
                }

                /* The endpoint has not been connected yet. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                }
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* Request is invalid. */
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
*       mcapi_close
*
*   DESCRIPTION
*
*       Non-blocking API routine to close the local side of a
*       channel.  Close calls are required on both the send and receive
*       side to properly close the channel.  Pending packets at the
*       receiver are discarded when the receive side is closed.
*       Attempts to transmit more data from a closed send side will
*       elicit an error.
*
*   INPUTS
*
*       *tx_endp_ptr            A pointer to the endpoint being closed for
*                               send.
*       type                    The type of channel; packet or scalar.
*       *request                A pointer to memory that will be filled in
*                               with data relevant to the operation, so the
*                               status of the operation can later be checked.
*       flag                    MCAPI_ENDP_TX for closing the send side.
*                               MCAPI_ENDP_RX for closing the receive side.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_close(MCAPI_ENDPOINT *endp_ptr, mcapi_uint32_t type,
                 mcapi_request_t *request, mcapi_uint32_t flag,
                 mcapi_status_t *mcapi_status)
{
    MCAPI_BUFFER    *cur_buf;

    /* Validate the mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate the request input parameter. */
        if (request)
        {
            /* Ensure this endpoint is the proper type. */
            if (endp_ptr->mcapi_chan_type == type)
            {
                /* Initialize status. */
                *mcapi_status = MCAPI_SUCCESS;

                /* If shutting down the send side. */
                if (flag == MCAPI_ENDP_TX)
                {
                    /* If the send side is not open. */
                    if (!(endp_ptr->mcapi_state & MCAPI_ENDP_TX))
                    {
                        /* If this is the receive side of the connection. */
                        if (endp_ptr->mcapi_state & MCAPI_ENDP_RX)
                        {
                            *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                        }

                        else
                        {
                            *mcapi_status = MCAPI_ERR_CHAN_NOTOPEN;
                        }
                    }

                    if (*mcapi_status == MCAPI_SUCCESS)
                    {
                        /* If any tasks are waiting for this side to open,
                         * resume so they know the endpoint has closed
                         * before opening.
                         */
                        mcapi_check_resume(MCAPI_REQ_TX_OPEN,
                                           endp_ptr->mcapi_endp_handle,
                                           MCAPI_NULL, 0, MCAPI_ERR_CHAN_NOTOPEN);
                    }
                }

                else
                {
                    /* If this is the receive side of the connection. */
                    if (endp_ptr->mcapi_state & MCAPI_ENDP_RX)
                    {
                        /* Remove the first buffer from the receive queue. */
                        cur_buf = mcapi_dequeue(&endp_ptr->mcapi_rx_queue);

                        /* If there is data pending on the endpoint,
                         * free it. The buffers are freed even if the
                         * close message cannot be sent since all the
                         * buffers could presumably be sitting on the
                         * incoming queue.
                         */
                        while (cur_buf)
                        {
                            /* Free the buffer. */
                            ((MCAPI_INTERFACE*)(cur_buf->mcapi_dev_ptr))->
                                mcapi_recover_buffer(cur_buf);

                            /* Get the next buffer. */
                            cur_buf = mcapi_dequeue(&endp_ptr->mcapi_rx_queue);
                        }

                        /* If any tasks are waiting for this side to open,
                         * resume so they know the endpoint has closed
                         * before opening.
                         */
                        mcapi_check_resume(MCAPI_REQ_RX_OPEN,
                                           endp_ptr->mcapi_endp_handle,
                                           MCAPI_NULL, 0, MCAPI_ERR_CHAN_NOTOPEN);
                    }

                    /* If this endpoint is open for sending. */
                    else if (endp_ptr->mcapi_state & MCAPI_ENDP_TX)
                    {
                        *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                    }

                    else
                    {
                        *mcapi_status = MCAPI_ERR_CHAN_NOTOPEN;
                    }
                }

                /* If an error has not occurred. */
                if (*mcapi_status == MCAPI_SUCCESS)
                {
                    /* Initialize the request structure. */
                    mcapi_init_request(request, MCAPI_REQ_CLOSED);

                    /* Set the status to success. */
                    request->mcapi_status = MCAPI_SUCCESS;

                    /* Encode the endpoint. */
                    request->mcapi_target_endp = endp_ptr->mcapi_endp_handle;

                    /* If the other side has not already shut down the
                     * connection, send a FIN.
                     */
                    if (endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING)
                    {
                        mcapi_tx_fin_msg(endp_ptr, mcapi_status);
                    }

                    else
                    {
                        /* The close has completed. */
                        *mcapi_status = MCAPI_SUCCESS;
                    }

                    /* Set the disconnected flag. */
                    endp_ptr->mcapi_state =
                        (MCAPI_ENDP_DISCONNECTED | MCAPI_ENDP_OPEN);

                    /* Clear the channel type. */
                    endp_ptr->mcapi_chan_type = 0;

                    /* Resume any threads that are suspended on this endpoint for
                     * any reason.
                     */
                    mcapi_check_resume(MCAPI_REQ_CLOSED, endp_ptr->mcapi_endp_handle,
                                       MCAPI_NULL, 0, MGC_MCAPI_ERR_NOT_CONNECTED);
                }
            }

            /* The endpoint is of a conflicting channel type. */
            else
            {
                *mcapi_status = MCAPI_ERR_CHAN_TYPE;
            }
        }

        /* Request is invalid. */
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
*       mcapi_tx_open
*
*   DESCRIPTION
*
*       Sends the open message to the other side of the connection.
*
*   INPUTS
*
*       *buffer                 A pointer to the buffer to use for
*                               transmission.
*       *endp_ptr               A pointer to the endpoint sending data.
*       send_node               The send node to put in the packet.
*       send_port               The send port to put in the packet.
*       recv_node               The receive node to put in the packet.
*       recv_port               The receive port to put in the packet.
*       pkt_type                The type of packet to send;
*                                   MCAPI_OPEN_RX - open receive side
*                                   MCAPI_OPEN_TX - open send side
*       type                    The channel type.
*       *mcapi_status           A pointer to the status of the final
*                               send call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_tx_open(unsigned char *buffer, MCAPI_ENDPOINT *endp_ptr,
                   mcapi_node_t send_node, mcapi_port_t send_port,
                   mcapi_node_t recv_node, mcapi_port_t recv_port,
                   mcapi_uint16_t pkt_type, mcapi_uint16_t type,
                   mcapi_status_t *mcapi_status)
{
    mcapi_request_t     request;
    mcapi_endpoint_t    dest_endpoint;

    /* Set the send node. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_TX_NODE, send_node);

    /* Set the send port. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_TX_PORT, send_port);

    /* Set the receive node. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_RX_NODE, recv_node);

    /* Set the receive port. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_RX_PORT, recv_port);

    /* Put the protocol type in the header. */
    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, pkt_type);

    /* Set the connection request node. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_REQ_NODE, endp_ptr->mcapi_req_node_id);

    /* Set the connection request port. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_REQ_PORT, endp_ptr->mcapi_req_port_id);

    /* Set the type field. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_CHAN_TYPE, type);

    /* Initialize status to all zero. */
    MCAPI_PUT32(buffer, MCAPI_CNCT_STATUS, 0);

    /* Encode the endpoint to which this packet will
     * be sent.
     */
    dest_endpoint =
        mcapi_encode_endpoint(endp_ptr->mcapi_foreign_node_id,
                              MCAPI_RX_CONTROL_PORT);

    /* Send a message to the send node to open a
     * connection.
     */
    msg_send(MCAPI_CTRL_TX_Endp, dest_endpoint, buffer,
             MCAPI_CONNECT_MSG_LEN, MCAPI_DEFAULT_PRIO,
             &request, mcapi_status, 0);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_tx_fin_msg
*
*   DESCRIPTION
*
*       Sends the fin message to the other side of the connection.
*
*   INPUTS
*
*       *endp_ptr               A pointer to the endpoint sending data.
*       *mcapi_status           A pointer to the status of the final
*                               send call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_tx_fin_msg(MCAPI_ENDPOINT *endp_ptr, mcapi_status_t *mcapi_status)
{
    unsigned char   buffer[MCAPI_FIN_MSG_LEN];
    mcapi_request_t request;

    /* Put the protocol type in the header. */
    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_CONNECT_FIN);

    /* Set the other side's port. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_FIN_PORT,
                endp_ptr->mcapi_foreign_port_id);

    /* Set the receive side node. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_FIN_TX_NODE, endp_ptr->mcapi_node_id);

    /* Set the receive side port. */
    MCAPI_PUT16(buffer, MCAPI_CNCT_FIN_TX_PORT, endp_ptr->mcapi_port_id);

    /* Send a message to this side that the
     * connection should be closed.
     */
    msg_send(MCAPI_CTRL_TX_Endp, mcapi_encode_endpoint(endp_ptr->
             mcapi_foreign_node_id, MCAPI_RX_CONTROL_PORT),
             buffer, MCAPI_FIN_MSG_LEN, MCAPI_DEFAULT_PRIO,
             &request, mcapi_status, 0);

}
