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

extern mcapi_endpoint_t     MCAPI_CTRL_RX_Endp;
extern mcapi_endpoint_t     MCAPI_CTRL_TX_Endp;
extern MCAPI_BUF_QUEUE      MCAPI_RX_Queue[MCAPI_PRIO_COUNT];

static void mcapi_connect_endpoints(MCAPI_GLOBAL_DATA *, unsigned char *,
                                    mcapi_status_t *);
static void mcapi_setup_connection(MCAPI_GLOBAL_DATA *, MCAPI_ENDPOINT *,
                                   unsigned char *, mcapi_status_t *, mcapi_uint16_t);
static void send_connect_response(unsigned char *, mcapi_status_t);

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_process_ctrl_msg
*
*   DESCRIPTION
*
*       Processes incoming control messages sent from other nodes in
*       the system.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(mcapi_process_ctrl_msg)
{
    mcapi_status_t          mcapi_status;
    unsigned char           buffer[MCAPI_CONTROL_MSG_LEN];
    mcapi_request_t         *request, mcapi_request;
    size_t                  rx_size;
    MCAPI_GLOBAL_DATA       *node_data;
    mcapi_node_t            node_id;
    mcapi_port_t            port_id;
    MCAPI_ENDPOINT          *endp_ptr;
    mcapi_endpoint_t        endpoint;

    /* This loop is active while the node is up and running. */
    for (;;)
    {
        /* Wait for data on the endpoint. */
        mcapi_msg_recv(MCAPI_CTRL_RX_Endp, &buffer,
                       MCAPI_CONTROL_MSG_LEN,
                       &rx_size, &mcapi_status);

        /* If a control message was received. */
        if ( (mcapi_status == MCAPI_SUCCESS) && (rx_size) )
        {
            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Determine the type of message. */
            switch (MCAPI_GET16(buffer, MCAPI_PROT_TYPE))
            {
                case MCAPI_GETENDP_REQUEST:

                    /* Extract the target port from the packet. */
                    port_id = MCAPI_GET16(buffer, MCAPI_GETENDP_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data,
                                                         MCAPI_Node_ID,
                                                         port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* Set the type. */
                        MCAPI_PUT16(buffer, MCAPI_PROT_TYPE,
                                    MCAPI_GETENDP_RESPONSE);

                        /* Set the status. */
                        MCAPI_PUT32(buffer, MCAPI_GETENDP_STATUS, MCAPI_SUCCESS);

                        /* Extract the destination endpoint. */
                        endpoint = MCAPI_GET32(buffer, MCAPI_GETENDP_ENDP);

                        /* Put the target endpoint in the buffer. */
                        MCAPI_PUT32(buffer, MCAPI_GETENDP_ENDP,
                                    mcapi_encode_endpoint(endp_ptr->mcapi_node_id,
                                    endp_ptr->mcapi_port_id));

                        /* Send the packet back to the caller. */
                        msg_send(MCAPI_CTRL_TX_Endp, endpoint, buffer,
                                 MCAPI_GET_ENDP_LEN, MCAPI_DEFAULT_PRIO,
                                 &mcapi_request, &mcapi_status, 0xffffffff);
                    }

                    /* The endpoint has not been created. */
                    else
                    {
                        /* Decode the requestor's information. */
                        mcapi_decode_endpoint(MCAPI_GET32(buffer, MCAPI_GETENDP_ENDP),
                                              &node_id, &port_id);

                        /* Ensure another thread on this same remote node
                         * is not already waiting for the endpoint to be
                         * created.
                         */
                        request = node_data->mcapi_foreign_req_queue.flink;

                        /* Check each request. */
                        while (request)
                        {
                            /* If this is an endpoint request for the same endpoint
                             * from the same node, do not add it again since all
                             * tasks waiting for this endpoint will be resumed by
                             * one call.
                             */
                            if ( (request->mcapi_type == MCAPI_REQ_CREATED) &&
                                 (request->mcapi_target_node_id == MCAPI_Node_ID) &&
                                 (request->mcapi_target_port_id ==
                                  MCAPI_GET16(buffer, MCAPI_GETENDP_PORT)) &&
                                 (request->mcapi_requesting_node_id == node_id) )
                            {
                                request->mcapi_pending_count ++;
                                break;
                            }

                            request = request->mcapi_next;
                        }

                        /* If the remote node is not already pending creation
                         * of the target endpoint.
                         */
                        if (!request)
                        {
                            /* Reserve a global request structure. */
                            request = mcapi_get_free_request_struct();

                            /* If a free structure is available. */
                            if (request)
                            {
                                /* Set the type. */
                                request->mcapi_type = MCAPI_REQ_CREATED;

                                /* Set up the request structure. */
                                request->mcapi_target_port_id =
                                    MCAPI_GET16(buffer, MCAPI_GETENDP_PORT);
                                request->mcapi_target_node_id = MCAPI_Node_ID;
                                request->mcapi_requesting_node_id = node_id;
                                request->mcapi_requesting_port_id = port_id;
                                request->mcapi_status = MCAPI_PENDING;
                                request->mcapi_pending_count = 1;

                                /* Add the structure to the wait list. */
                                mcapi_enqueue(&node_data->mcapi_foreign_req_queue, request);
                            }

                            /* Otherwise, send an error to the caller. */
                            else
                            {
                                /* Set an error. */
                                MCAPI_PUT32(buffer, MCAPI_GETENDP_STATUS,
                                            (mcapi_uint32_t)MCAPI_ERR_REQUEST_LIMIT);

                                /* Set the type. */
                                MCAPI_PUT16(buffer, MCAPI_PROT_TYPE,
                                            MCAPI_GETENDP_RESPONSE);

                                /* Extract the destination endpoint. */
                                endpoint = MCAPI_GET32(buffer, MCAPI_GETENDP_ENDP);

                                /* Put the target endpoint in the packet. */
                                MCAPI_PUT32(buffer, MCAPI_GETENDP_ENDP,
                                            mcapi_encode_endpoint(MCAPI_Node_ID, port_id));

                                /* Send the packet back to the caller. */
                                msg_send(MCAPI_CTRL_TX_Endp, endpoint, buffer,
                                         MCAPI_GET_ENDP_LEN, MCAPI_DEFAULT_PRIO,
                                         &mcapi_request, &mcapi_status, 0xffffffff);
                            }
                        }
                    }

                    break;

                case MCAPI_GETENDP_RESPONSE:

                    /* Extract the status from the packet. */
                    mcapi_status = MCAPI_GET32(buffer, MCAPI_GETENDP_STATUS);

                    /* Wake the task that requested this data. */
                    mcapi_check_resume(MCAPI_REQ_CREATED,
                                       MCAPI_GET32(buffer, MCAPI_GETENDP_ENDP),
                                       MCAPI_NULL, 0, mcapi_status);

                    break;

                case MCAPI_CANCEL_MSG:

                    /* Decode the requestor's information. */
                    mcapi_decode_endpoint(MCAPI_GET32(buffer, MCAPI_GETENDP_ENDP),
                                          &node_id, &port_id);

                    /* Find the request message in the list. */
                    request = node_data->mcapi_foreign_req_queue.flink;

                    /* Check each request. */
                    while (request)
                    {
                        /* If this request matches. */
                        if ( (request->mcapi_type == MCAPI_REQ_CREATED) &&
                             (request->mcapi_target_node_id == MCAPI_Node_ID) &&
                             (request->mcapi_target_port_id ==
                              MCAPI_GET16(buffer, MCAPI_GETENDP_PORT)) &&
                             (request->mcapi_requesting_node_id == node_id) )
                        {
                            /* Decrement the number of tasks pending completion
                             * of this request.
                             */
                            request->mcapi_pending_count --;

                            /* If this was the only task waiting for the request
                             * to complete.
                             */
                            if (request->mcapi_pending_count == 0)
                            {
                                /* Remove the request from the list. */
                                mcapi_remove(&node_data->mcapi_foreign_req_queue, request);
                            }

                            break;
                        }

                        /* Get the next request. */
                        request = request->mcapi_next;
                    }

                    break;

                case MCAPI_CONNECT_REQUEST:

                    /* If the node ID of the send side is the local node,
                     * connect the send side.  The requestor should only
                     * send the connection request to the send side.
                     */
                    if (MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE) == MCAPI_Node_ID)
                    {
                        /* Send a SYN request to the receive side. */
                        mcapi_connect_endpoints(node_data, buffer, &mcapi_status);

                        /* If the connection is not possible, send an error
                         * to the caller.
                         */
                        if (mcapi_status != MCAPI_SUCCESS)
                        {
                            /* Send the response. */
                            send_connect_response(buffer, mcapi_status);
                        }
                    }

                    break;

                case MCAPI_CONNECT_SYN:

                    /* Extract the node ID and port ID. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_NODE);
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data, node_id,
                                                         port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* Make the call to set up the connection. */
                        mcapi_setup_connection(node_data, endp_ptr, buffer,
                                               &mcapi_status, MCAPI_RX_SIDE);
                    }

                    /* The endpoint is not valid. */
                    else
                    {
                        mcapi_status = MCAPI_ERR_ENDP_INVALID;
                    }

                    /* Set the type to ACK. */
                    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_CONNECT_ACK);

                    /* Set the status. */
                    MCAPI_PUT32(buffer, MCAPI_CNCT_STATUS, mcapi_status);

                    /* Send the status response to the transmit node. */
                    msg_send(MCAPI_CTRL_TX_Endp,
                             mcapi_encode_endpoint(MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE),
                             MCAPI_RX_CONTROL_PORT), buffer,
                             MCAPI_CONNECT_MSG_LEN, MCAPI_DEFAULT_PRIO,
                             &mcapi_request, &mcapi_status, 0xffffffff);

                    /* If the request was successful. */
                    if (mcapi_status == MCAPI_SUCCESS)
                    {
                        /* If the open call has been made from the application,
                         * send the open request to the send side.
                         */
                        if ( (endp_ptr) &&
                             (endp_ptr->mcapi_state & MCAPI_ENDP_RX) )
                        {
                            /* Send the open call to the other side. */
                            mcapi_tx_open(buffer, endp_ptr,
                                          endp_ptr->mcapi_foreign_node_id,
                                          endp_ptr->mcapi_foreign_port_id,
                                          endp_ptr->mcapi_node_id,
                                          endp_ptr->mcapi_port_id, MCAPI_OPEN_RX,
                                          MCAPI_GET16(buffer, MCAPI_CNCT_CHAN_TYPE),
                                          &mcapi_status);
                        }
                    }

                    break;

                case MCAPI_CONNECT_ACK:

                    /* Extract the node ID and port ID. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE);
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data, node_id,
                                                         port_id);

                    /* Get the status from the packet. */
                    mcapi_status = MCAPI_GET32(buffer, MCAPI_CNCT_STATUS);

                    /* Ensure the endpoint wasn't deleted while waiting for
                     * the ACK from the other side.
                     */
                    if (endp_ptr)
                    {
                        /* If the status is success, open the connection. */
                        if (mcapi_status == MCAPI_SUCCESS)
                        {
                            mcapi_setup_connection(node_data, endp_ptr, buffer,
                                                   &mcapi_status, MCAPI_TX_SIDE);

                            /* If the open call has been made by the application,
                             * send the open request to the receive side.
                             */
                            if (endp_ptr->mcapi_state & MCAPI_ENDP_TX)
                            {
                                /* Send the open call to the other side. */
                                mcapi_tx_open(buffer, endp_ptr,
                                              endp_ptr->mcapi_node_id,
                                              endp_ptr->mcapi_port_id,
                                              endp_ptr->mcapi_foreign_node_id,
                                              endp_ptr->mcapi_foreign_port_id,
                                              MCAPI_OPEN_TX,
                                              MCAPI_GET16(buffer, MCAPI_CNCT_CHAN_TYPE),
                                              &mcapi_status);
                            }
                        }

                        /* The other side could not open the connection. */
                        else
                        {
                            /* Clear the "connecting" flag since this connection
                             * could not be made.
                             */
                            endp_ptr->mcapi_state &= ~MCAPI_ENDP_CONNECTING;
                        }
                    }

                    /* Send the response to the requestor.  If the endpoint was
                     * deleted, it's OK to report success to the connection
                     * requestor since an error will be returned to the
                     * RX side when it tries to open.
                     */
                    send_connect_response(buffer, mcapi_status);

                    break;

                case MCAPI_OPEN_TX:

                    mcapi_status = MCAPI_SUCCESS;

                    /* Extract the node ID and port ID. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_NODE);
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data, node_id,
                                                         port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* Set the state to indicate the send side has
                         * opened.
                         */
                        endp_ptr->mcapi_state |= MCAPI_ENDP_TX_ACKED;

                        /* If the receive side has also opened. */
                        if (endp_ptr->mcapi_state & MCAPI_ENDP_RX_ACKED)
                        {
                            /* Indicate that the connection is complete. */
                            endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTED;

                            /* Check if any tasks are waiting for the receive side
                             * to be opened.
                             */
                            mcapi_check_resume(MCAPI_REQ_RX_OPEN,
                                               endp_ptr->mcapi_endp_handle,
                                               MCAPI_NULL, 0, mcapi_status);
                        }
                    }

                    else
                    {
                        mcapi_status = MCAPI_ERR_ENDP_INVALID;
                    }

                    /* Set the type to TX_ACK. */
                    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_OPEN_TX_ACK);

                    /* Put the status in the packet. */
                    MCAPI_PUT32(buffer, MCAPI_CNCT_STATUS, mcapi_status);

                    /* Send a status back to the send side so they
                     * know whether the connection should proceed.
                     */
                    msg_send(MCAPI_CTRL_TX_Endp,
                             mcapi_encode_endpoint(MCAPI_GET16(buffer,
                             MCAPI_CNCT_TX_NODE), MCAPI_RX_CONTROL_PORT),
                             buffer, MCAPI_CONNECT_MSG_LEN,
                             MCAPI_DEFAULT_PRIO,
                             &mcapi_request, &mcapi_status, 0xffffffff);

                    break;

                case MCAPI_OPEN_RX:

                    mcapi_status = MCAPI_SUCCESS;

                    /* Extract the node ID and port ID. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE);
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data, node_id,
                                                         port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* Set the state to indicate the other side has
                         * opened.
                         */
                        endp_ptr->mcapi_state |= MCAPI_ENDP_RX_ACKED;

                        /* If the send side has opened and been ACKed. */
                        if (endp_ptr->mcapi_state & MCAPI_ENDP_TX_ACKED)
                        {
                            /* Indicate that the connection is completed. */
                            endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTED;

                            /* Check if any tasks are waiting for the send side
                             * to be opened.
                             */
                            mcapi_check_resume(MCAPI_REQ_TX_OPEN,
                                               endp_ptr->mcapi_endp_handle,
                                               MCAPI_NULL, 0, mcapi_status);
                        }
                    }

                    else
                    {
                        mcapi_status = MCAPI_ERR_ENDP_INVALID;
                    }

                    /* Set the type to RX_ACK. */
                    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_OPEN_RX_ACK);

                    /* Put the status in the packet. */
                    MCAPI_PUT32(buffer, MCAPI_CNCT_STATUS, mcapi_status);

                    /* Send a status back to the receive side so they
                     * know whether the connection should proceed.
                     */
                    msg_send(MCAPI_CTRL_TX_Endp,
                             mcapi_encode_endpoint(MCAPI_GET16(buffer,
                             MCAPI_CNCT_RX_NODE), MCAPI_RX_CONTROL_PORT),
                             buffer, MCAPI_CONNECT_MSG_LEN,
                             MCAPI_DEFAULT_PRIO,
                             &mcapi_request, &mcapi_status, 0xffffffff);

                    break;

                case MCAPI_OPEN_RX_ACK:

                    /* Extract the node ID and port ID. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_NODE);
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data, node_id,
                                                         port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* Extract the status from the packet. */
                        mcapi_status = MCAPI_GET32(buffer, MCAPI_CNCT_STATUS);

                        /* If the ACK is successful. */
                        if (mcapi_status == MCAPI_SUCCESS)
                        {
                            /* Set the flag indicating that the RX side is
                             * open.
                             */
                            endp_ptr->mcapi_state |= MCAPI_ENDP_RX_ACKED;

                            /* If both sides have issued successful open calls. */
                            if (endp_ptr->mcapi_state & MCAPI_ENDP_TX_ACKED)
                            {
                                /* Indicate that the connection is connected. */
                                endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTED;

                                /* Check if any tasks are waiting for the receive side
                                 * to be opened.
                                 */
                                mcapi_check_resume(MCAPI_REQ_RX_OPEN,
                                                   endp_ptr->mcapi_endp_handle,
                                                   MCAPI_NULL, 0, mcapi_status);
                            }
                        }

                        else
                        {
                            /* Clear the flag. */
                            endp_ptr->mcapi_state &= ~MCAPI_ENDP_RX;

                            /* Check if any tasks are waiting for the receive side
                             * to be opened.
                             */
                            mcapi_check_resume(MCAPI_REQ_RX_OPEN,
                                               endp_ptr->mcapi_endp_handle,
                                               MCAPI_NULL, 0, mcapi_status);
                        }
                    }

                    break;

                case MCAPI_OPEN_TX_ACK:

                    /* Extract the status from the packet. */
                    mcapi_status = MCAPI_GET32(buffer, MCAPI_CNCT_STATUS);

                    /* Extract the node ID and port ID. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE);
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr =
                        mcapi_find_local_endpoint(node_data, node_id, port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* If the status of the ACK is success. */
                        if (mcapi_status == MCAPI_SUCCESS)
                        {
                            /* Set the state to indicate that the TX side
                             * is open.
                             */
                            endp_ptr->mcapi_state |= MCAPI_ENDP_TX_ACKED;

                            /* If both sides have issued successful open calls. */
                            if (endp_ptr->mcapi_state & MCAPI_ENDP_RX_ACKED)
                            {
                                /* Indicate that the connection is connected. */
                                endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTED;

                                /* Check if any tasks are waiting for the send side
                                 * to be opened.
                                 */
                                mcapi_check_resume(MCAPI_REQ_TX_OPEN,
                                                   endp_ptr->mcapi_endp_handle,
                                                   MCAPI_NULL, 0, mcapi_status);
                            }
                        }

                        else
                        {
                            /* Clear the transmit and connecting flags. */
                            endp_ptr->mcapi_state &= ~MCAPI_ENDP_TX;

                            /* Check if any tasks are waiting for the send side
                             * to be opened.
                             */
                            mcapi_check_resume(MCAPI_REQ_TX_OPEN,
                                               endp_ptr->mcapi_endp_handle,
                                               MCAPI_NULL, 0, mcapi_status);
                        }
                    }

                    break;

                case MCAPI_CONNECT_RESPONSE:

                    /* Get the status. */
                    mcapi_status = MCAPI_GET32(buffer, MCAPI_CNCT_STATUS);

                    /* Get the transmit node. */
                    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE);

                    /* Get the transmit port. */
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_PORT);

                    /* Check if any tasks are waiting for this connection
                     * to be created.
                     */
                    mcapi_check_resume(MCAPI_REQ_CONNECTED,
                                       mcapi_encode_endpoint(node_id, port_id),
                                       MCAPI_NULL, 0, mcapi_status);

                    break;

                case MCAPI_CONNECT_FIN:

                    /* Extract the port ID. */
                    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_FIN_PORT);

                    /* Get a pointer to the endpoint. */
                    endp_ptr = mcapi_find_local_endpoint(node_data, MCAPI_Node_ID,
                                                         port_id);

                    /* If the endpoint was found. */
                    if (endp_ptr)
                    {
                        /* Clear the "connected" flag since the other side
                         * has shutdown the read/write side.
                         */
                        endp_ptr->mcapi_state &= ~MCAPI_ENDP_CONNECTED;
                        endp_ptr->mcapi_state &= ~MCAPI_ENDP_CONNECTING;

                        /* Resume any threads that are suspended on this endpoint
                         * for any reason.
                         */
                        mcapi_check_resume(MCAPI_REQ_CLOSED,
                                           endp_ptr->mcapi_endp_handle, MCAPI_NULL,
                                           0, MGC_MCAPI_ERR_NOT_CONNECTED);

                    }

                    break;

                default:

                    break;
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* The application has called mcapi_finalize().  Exit the loop. */
        else
        {
            break;
        }
    }

    /* Terminate this task. */
    MCAPI_Cleanup_Task();

    return NULL;
}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_connect_endpoints
*
*   DESCRIPTION
*
*       Issues a request to an endpoint to connect the endpoint.
*
*   INPUTS
*
*       *node_data              A pointer to the global node data.
*       *buffer                 A pointer to the buffer containing
*                               the request.  This buffer will be
*                               reused to send the SYN to the receive
*                               endpoint.
*       *status                 A pointer that will be filled in with
*                               the status of the request.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
static void mcapi_connect_endpoints(MCAPI_GLOBAL_DATA *node_data,
                                    unsigned char *buffer,
                                    mcapi_status_t *mcapi_status)
{
    MCAPI_ENDPOINT      *endp_ptr;
    mcapi_node_t        local_node_id, foreign_node_id;
    mcapi_port_t        local_port_id;
    mcapi_request_t     request;

    /* Get the local node. */
    local_node_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE);

    /* Get the local port. */
    local_port_id = MCAPI_GET16(buffer, MCAPI_CNCT_TX_PORT);

    /* Get the foreign node. */
    foreign_node_id = MCAPI_GET16(buffer, MCAPI_CNCT_RX_NODE);

    /* Get a pointer to the endpoint. */
    endp_ptr = mcapi_find_local_endpoint(node_data, local_node_id,
                                         local_port_id);

    /* If the endpoint was found. */
    if (endp_ptr)
    {
        /* If the endpoint is not already connected. */
        if (!(endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING))
        {
            /* Set the type to connected so another node doesn't
             * try to issue a connection while this connection
             * is in progress.
             */
            endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTING;

            /* Clear the disconnected status in case it is set. */
            endp_ptr->mcapi_state &= ~MCAPI_ENDP_DISCONNECTED;

            /* Set the packet type. */
            MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_CONNECT_SYN);

            /* Send a message to the foreign node to see if
             * the connection can be made.
             */
            msg_send(MCAPI_CTRL_TX_Endp,
                     mcapi_encode_endpoint(foreign_node_id,
                     MCAPI_RX_CONTROL_PORT), buffer,
                     MCAPI_CONNECT_MSG_LEN, MCAPI_DEFAULT_PRIO,
                     &request, mcapi_status, 0xffffffff);
        }

        /* This endpoint is already connected. */
        else
        {
            *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
        }
    }

    /* This endpoint is not a valid endpoint. */
    else
    {
        *mcapi_status = MCAPI_ERR_ENDP_INVALID;
    }

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_setup_connection
*
*   DESCRIPTION
*
*       Sets up a connection over an endpoint.
*
*   INPUTS
*
*       *node_data              A pointer to the global node data.
*       *buffer                 A pointer to the buffer containing the
*                               connection SYN.
*       *mcapi_status           A pointer that will be filled in with
*                               the status of the operation.
*       connect_side            The local node's side of the connection:
*                               MCAPI_TX_SIDE or MCAPI_RX_SIDE.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
static void mcapi_setup_connection(MCAPI_GLOBAL_DATA *node_data,
                                   MCAPI_ENDPOINT *endp_ptr, unsigned char *buffer,
                                   mcapi_status_t *mcapi_status,
                                   mcapi_uint16_t connect_side)
{
    int                 node_idx;
    MCAPI_NODE          *node_ptr;

    /* If the endpoint is not already connected.  Note that the
     * transmit side is set to connected when the initial connect
     * request is made.
     */
    if ( (connect_side == MCAPI_TX_SIDE) ||
         (!(endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING)) )
    {
        /* Get the index of the local node. */
        node_idx = mcapi_find_node(endp_ptr->mcapi_node_id, node_data);

        if (node_idx != -1)
        {
            /* Get a pointer to the node structure. */
            node_ptr = &node_data->mcapi_node_list[node_idx];

            /* Set up routes between the two endpoints. */
            endp_ptr->mcapi_route =
                mcapi_find_route(endp_ptr->mcapi_node_id, node_ptr);

            /* Ensure the receive side is reachable from this node. */
            if (endp_ptr->mcapi_route)
            {
                /* Ensure the attributes of both endpoints match. */

                /* Set the state of the send endpoint. */
                endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTING;

                /* Clear the disconnected status in case it is set. */
                endp_ptr->mcapi_state &= ~MCAPI_ENDP_DISCONNECTED;

                /* Get the index of the local node. */
                if (connect_side == MCAPI_TX_SIDE)
                {
                    /* Get the receive node. */
                    endp_ptr->mcapi_foreign_node_id =
                        MCAPI_GET16(buffer, MCAPI_CNCT_RX_NODE);

                    /* Get the receive port. */
                    endp_ptr->mcapi_foreign_port_id =
                        MCAPI_GET16(buffer, MCAPI_CNCT_RX_PORT);

                    /* Set the state indicating that this side is connecting
                     * as a sender.
                     */
                    endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTING_TX;
                }

                else
                {
                    /* Get the receive node. */
                    endp_ptr->mcapi_foreign_node_id =
                        MCAPI_GET16(buffer, MCAPI_CNCT_TX_NODE);

                    /* Get the receive port. */
                    endp_ptr->mcapi_foreign_port_id =
                        MCAPI_GET16(buffer, MCAPI_CNCT_TX_PORT);

                    /* Set the state indicating that this side is connecting
                     * as a receiver.
                     */
                    endp_ptr->mcapi_state |= MCAPI_ENDP_CONNECTING_RX;
                }

                /* Set the channel type. */
                endp_ptr->mcapi_chan_type =
                    MCAPI_GET16(buffer, MCAPI_CNCT_CHAN_TYPE);

                /* Extract the requestor's node ID and port ID. */
                endp_ptr->mcapi_req_node_id =
                    MCAPI_GET16(buffer, MCAPI_CNCT_REQ_NODE);

                endp_ptr->mcapi_req_port_id =
                    MCAPI_GET16(buffer, MCAPI_CNCT_REQ_PORT);
            }

            /* The node is not reachable from this node. */
            else
            {
                *mcapi_status = MCAPI_ERR_ENDP_INVALID;
            }
        }

        /* The node is not reachable from this node. */
        else
        {
            *mcapi_status = MCAPI_ERR_ENDP_INVALID;
        }
    }

    else
    {
        *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
    }

}

/*************************************************************************
*
*   FUNCTION
*
*       send_connect_response
*
*   DESCRIPTION
*
*       Sends a response to a connection request.
*
*   INPUTS
*
*       *buffer                 A pointer to the buffer containing the
*                               outgoing response.
*       status                  The status to insert in the response.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
static void send_connect_response(unsigned char *buffer, mcapi_status_t status)
{
    mcapi_node_t    node_id;
    mcapi_port_t    port_id;
    mcapi_status_t  mcapi_status;
    mcapi_request_t request;

    /* Get the requestor node. */
    node_id = MCAPI_GET16(buffer, MCAPI_CNCT_REQ_NODE);

    /* Get the requestor port. */
    port_id = MCAPI_GET16(buffer, MCAPI_CNCT_REQ_PORT);

    /* Set the error message in the packet. */
    MCAPI_PUT32(buffer, MCAPI_CNCT_STATUS, status);

    /* Set the type to response. */
    MCAPI_PUT16(buffer, MCAPI_PROT_TYPE, MCAPI_CONNECT_RESPONSE);

    /* Send the error response to the requestor. */
    msg_send(MCAPI_CTRL_TX_Endp,
             mcapi_encode_endpoint(node_id, port_id),
             buffer, MCAPI_CONNECT_MSG_LEN,
             MCAPI_DEFAULT_PRIO,
             &request, &mcapi_status, 0xffffffff);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_tx_response
*
*   DESCRIPTION
*
*       Transmits a response to a foreign node for a pending request.
*
*   INPUTS
*
*       *node_data              A pointer to the global MCAPI node data
*                               structure.
*       *request                The request structure associated with the
*                               foreign node to resume.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_tx_response(MCAPI_GLOBAL_DATA *node_data, mcapi_request_t *request)
{
    mcapi_status_t      tx_status;
    mcapi_endpoint_t    remote_endp;
    mcapi_request_t     tx_request;
    unsigned char       buffer[MCAPI_GET_ENDP_LEN];

    /* If the get request was successful, send the response. */
    if (request->mcapi_status != MCAPI_ERR_REQUEST_CANCELLED)
    {
        MCAPI_PUT16(buffer, MCAPI_PROT_TYPE,  MCAPI_GETENDP_RESPONSE);

        /* Set the status. */
        MCAPI_PUT32(buffer, MCAPI_GETENDP_STATUS, request->mcapi_status);
    }

    /* If the get request is being canceled, send a cancel message. */
    else
    {
        MCAPI_PUT16(buffer, MCAPI_PROT_TYPE,  MCAPI_CANCEL_MSG);
    }

    /* Put the target port in the buffer. */
    MCAPI_PUT16(buffer, MCAPI_GETENDP_PORT, request->mcapi_target_port_id);

    remote_endp = mcapi_encode_endpoint(request->mcapi_requesting_node_id,
                                        request->mcapi_requesting_port_id);

    /* Put the target endpoint in the packet. */
    MCAPI_PUT32(buffer, MCAPI_GETENDP_ENDP,
                mcapi_encode_endpoint(MCAPI_Node_ID,
                request->mcapi_target_port_id));

    /* Send the packet back to the caller. */
    msg_send(MCAPI_CTRL_TX_Endp, remote_endp, buffer, MCAPI_GET_ENDP_LEN,
             MCAPI_DEFAULT_PRIO, &tx_request, &tx_status,
             0xffffffff);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_rx_data
*
*   DESCRIPTION
*
*       Process incoming data from driver level interfaces.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_rx_data(void)
{
    MCAPI_ENDPOINT      *endp_ptr;
    MCAPI_BUFFER        *mcapi_buf_ptr;
    MCAPI_GLOBAL_DATA   *node_data;
    mcapi_int_t         cookie;
    mcapi_node_t        dest_node;
    mcapi_port_t        dest_port;
    int                 i;

    mcapi_lock_node_data();

    /* Get a pointer to the global node list. */
    node_data = mcapi_get_node_data();

    for (i = 0; i < MCAPI_PRIO_COUNT; i++)
    {
        /* Process all data on the incoming receive queue. */
        while (MCAPI_RX_Queue[i].head)
        {
            /* Disable interrupts - the HISR could add to this queue
             * while we remove from it.
             */
            cookie = MCAPI_Lock_RX_Queue();

            /* Pull the buffer off the queue. */
            mcapi_buf_ptr = mcapi_dequeue(&MCAPI_RX_Queue[i]);

            /* Restore interrupts to the previous level. */
            MCAPI_Unlock_RX_Queue(cookie);

            /* Extract the destination node. */
            dest_node =
                MCAPI_GET16(mcapi_buf_ptr->buf_ptr, MCAPI_DEST_NODE_OFFSET);

            /* Extract the destination port. */
            dest_port =
                MCAPI_GET16(mcapi_buf_ptr->buf_ptr, MCAPI_DEST_PORT_OFFSET);

            /* Decode message header and obtain RX endpoint */
            endp_ptr =
                mcapi_find_local_endpoint(node_data, dest_node, dest_port);

            /* If the packet is for this node. */
            if (endp_ptr)
            {
                /* Enqueue the new buffer onto the receive queue for
                 * the endpoint.
                 */
                mcapi_enqueue(&endp_ptr->mcapi_rx_queue, mcapi_buf_ptr);

                /* Check if any tasks are waiting to receive data on this
                 * endpoint.
                 */
                mcapi_check_resume(MCAPI_REQ_RX_FIN,
                                   endp_ptr->mcapi_endp_handle, endp_ptr,
                                   mcapi_buf_ptr->buf_size - MCAPI_HEADER_LEN,
                                   MCAPI_SUCCESS);
            }

            else
#if (MCAPI_ENABLE_FORWARDING == 1)
            {
                /* Attempt to forward the packet. */
                mcapi_forward(node_data, mcapi_buf_ptr, dest_node);
            }
#else
            {
                /* The packet is not destined for this node, and forwarding
                 * capabilities are disabled.
                 */
                ((MCAPI_INTERFACE*)(mcapi_buf_ptr->mcapi_dev_ptr))->
                    mcapi_recover_buffer(mcapi_buf_ptr);
            }
#endif
        }
    }

    /* Release the lock. */
    mcapi_unlock_node_data();

}
