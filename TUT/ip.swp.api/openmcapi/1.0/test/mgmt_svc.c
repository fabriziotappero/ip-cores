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

/*
*   FILENAME
*
*       mgmt_svc.c
*
*
*************************************************************************/

#include <stdio.h>
#include "mgmt_svc.h"
#include "support_suite/mcapid_support.h"
#include "mcapid.h"

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Mgmt_Service
*
*   DESCRIPTION
*
*       This function processes incoming packets instructing the node
*       to create an endpoint, delete an endpoint, etc.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPID_Mgmt_Service)
{
    size_t                      rx_len;
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    unsigned char               buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_pktchan_send_hndl_t   tx_handle;
    mcapi_pktchan_recv_hndl_t   rx_handle;
    int                         tx_handle_in_use = MCAPI_FALSE,
                                rx_handle_in_use = MCAPI_FALSE;
    mcapi_sclchan_send_hndl_t   tx_handle_scl;
    mcapi_sclchan_recv_hndl_t   rx_handle_scl;
    int                         tx_handle_scl_in_use = MCAPI_FALSE,
                                rx_handle_scl_in_use = MCAPI_FALSE;
    mcapi_request_t             pkt_tx_request, pkt_rx_request,
                                scl_tx_request, scl_rx_request;
    mcapi_endpoint_t            endpoint;
    mcapi_node_t                this_node;
    mcapi_status_t              status;
    mcapi_port_t                port;
    mcapi_priority_t            prio;
    mcapi_boolean_t             complete;
    mcapi_request_t             request;
    size_t                      size;

    this_node = mcapi_get_node_id(&status);

    for (;;)
    {
        /* Wait for a message. */
        mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                       &rx_len, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Sleep the appropriate amount of time - this gives the other side
             * time to issue a command before the management task causes an
             * action.
             */
            MCAPID_Sleep(mcapi_get32(buffer, MCAPID_MGMT_PAUSE_OFFSET));

            /* Determine the type of message. */
            switch (mcapi_get32(buffer, MCAPID_MGMT_TYPE_OFFSET))
            {
                /* Create an endpoint. */
                case MCAPID_MGMT_CREATE_ENDP:

                    port = mcapi_get32(buffer, MCAPID_MGMT_FOREIGN_PORT_OFFSET);

                    /* Create the endpoint with specified port ID. */
                    mcapi_create_endpoint(port, &mcapi_struct->status);
                    if (mcapi_struct->status != MCAPI_SUCCESS)
                        printf("error creating endport %d (%d)\n", port,
                               mcapi_struct->status);

                    break;

                /* Delete an endpoint. */
                case MCAPID_MGMT_DELETE_ENDP:

                    port = mcapi_get32(buffer, MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                    mcapi_get_endpoint_i(this_node, port, &endpoint, &request,
                                         &status);
                    complete = mcapi_wait(&request, &size, &status, 0);

                    if (complete && (status == MCAPI_SUCCESS))
                    {
                        /* Delete the endpoint. */
                        mcapi_delete_endpoint(endpoint, &mcapi_struct->status);
                        if (mcapi_struct->status != MCAPI_SUCCESS)
                            printf("error deleting endport %d (%d)\n", port,
                                   mcapi_struct->status);
                    }
                    else
                    {
                        printf("%s: tried to delete a non-existent endpoint!\n",
                               __func__);
                    }

                    break;

                /* Send a blocking message. */
                case MCAPID_MGMT_TX_BLCK_MSG:

                    port = mcapi_get32(buffer, MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                    mcapi_get_endpoint_i(this_node, port, &endpoint, &request,
                                         &status);
                    complete = mcapi_wait(&request, &size, &status, 0);

                    if (complete && (status == MCAPI_SUCCESS))
                    {
                        prio = mcapi_get32(buffer, MCAPID_MGMT_PRIO_OFFSET);

                        /* Send this packet back to the other side. */
                        mcapi_msg_send(endpoint,
                                       mcapi_get32(buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                                       buffer, rx_len, prio,
                                       &mcapi_struct->status);
                    }
                    else
                    {
                        printf("%s: tried to delete a non-existent endpoint!\n",
                               __func__);
                    }

                    break;

                /* Send a non-blocking message. */
                case MCAPID_MGMT_TX_NONBLCK_MSG:

                    port = mcapi_get32(buffer, MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                    mcapi_get_endpoint_i(this_node, port, &endpoint, &request,
                                         &status);
                    complete = mcapi_wait(&request, &size, &status, 0);

                    if (complete && (status == MCAPI_SUCCESS))
                    {
                        prio = mcapi_get32(buffer, MCAPID_MGMT_PRIO_OFFSET);

                        /* Send this packet back to the other side. */
                        mcapi_msg_send_i(endpoint,
                                         mcapi_get32(buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                                         buffer, rx_len, prio,
                                         &mcapi_struct->request,
                                         &mcapi_struct->status);
                    }
                    else
                    {
                        printf("%s: tried to send msg to a non-existent "
                               "endpoint!\n", __func__);
                    }

                    break;

                /* Open a local endpoint as a sender. */
                case MCAPID_MGMT_OPEN_TX_SIDE_PKT:

                    /* Only one transmit handle can be open on the
                     * management service thread at a time.
                     */
                    if (tx_handle_in_use == MCAPI_FALSE)
                    {
                        port = mcapi_get32(buffer,
                                           MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                        mcapi_get_endpoint_i(this_node, port, &endpoint,
                                             &request, &status);
                        complete = mcapi_wait(&request, &size, &status, 0);

                        if (complete && (status == MCAPI_SUCCESS))
                        {
                            mcapi_open_pktchan_send_i(&tx_handle,
                                                      endpoint,
                                                      &pkt_tx_request,
                                                      &mcapi_struct->status);

                            if ( (mcapi_struct->status == MCAPI_SUCCESS) ||
                                 (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED) )
                            {
                                tx_handle_in_use = MCAPI_TRUE;
                            }
                        }
                        else
                        {
                            printf("%s: tried to open a non-existent "
                                   "endpoint (for pktchan send)!\n", __func__);
                        }
                    }

                    else
                    {
                        mcapi_struct->status = -1;
                    }

                    break;

                /* Open a local endpoint as a receiver. */
                case MCAPID_MGMT_OPEN_RX_SIDE_PKT:

                    /* Only one receive handle can be open on the management
                     * service thread at a time.
                     */
                    if (rx_handle_in_use == MCAPI_FALSE)
                    {
                        port = mcapi_get32(buffer,
                                           MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                        mcapi_get_endpoint_i(this_node, port, &endpoint,
                                             &request, &status);
                        complete = mcapi_wait(&request, &size, &status, 0);

                        if (status == MCAPI_SUCCESS)
                        {
                            mcapi_open_pktchan_recv_i(&rx_handle,
                                                      endpoint,
                                                      &pkt_rx_request,
                                                      &mcapi_struct->status);

                            if ( (mcapi_struct->status == MCAPI_SUCCESS) ||
                                 (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED) )
                            {
                                rx_handle_in_use = MCAPI_TRUE;
                            }
                        }
                        else
                        {
                            printf("%s: tried to open a non-existent "
                                   "endpoint (for pktchan recv)!\n", __func__);
                        }
                    }

                    else
                    {
                        mcapi_struct->status = -1;
                    }

                    break;

                /* Close the send side. */
                case MCAPID_MGMT_CLOSE_TX_SIDE_PKT:

                    mcapi_packetchan_send_close_i(tx_handle, &mcapi_struct->request,
                                                  &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        tx_handle_in_use = MCAPI_FALSE;
                    }

                    break;

                /* Close the receive side. */
                case MCAPID_MGMT_CLOSE_RX_SIDE_PKT:

                    mcapi_packetchan_recv_close_i(rx_handle, &mcapi_struct->request,
                                                  &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        rx_handle_in_use = MCAPI_FALSE;
                    }

                    break;

                case MCAPID_TX_PKT:

                    mcapi_pktchan_send(tx_handle, buffer, MCAPID_MGMT_PKT_LEN,
                                       &mcapi_struct->status);

                    break;

                /* Open a local endpoint as a sender. */
                case MCAPID_MGMT_OPEN_TX_SIDE_SCL:

                    /* Only one transmit handle can be open on the management
                     * service thread at a time.
                     */
                    if (tx_handle_scl_in_use == MCAPI_FALSE)
                    {
                        port = mcapi_get32(buffer,
                                           MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                        mcapi_get_endpoint_i(this_node, port, &endpoint,
                                             &request, &status);
                        complete = mcapi_wait(&request, &size, &status, 0);

                        if (complete && (status == MCAPI_SUCCESS))
                        {
                            mcapi_open_sclchan_send_i(&tx_handle_scl,
                                                      endpoint,
                                                      &scl_tx_request,
                                                      &mcapi_struct->status);

                            if ( (mcapi_struct->status == MCAPI_SUCCESS) ||
                                 (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED) )
                            {
                                tx_handle_scl_in_use = MCAPI_TRUE;
                            }
                        }
                        else
                        {
                            printf("%s: tried to open a non-existent "
                                   "endpoint (for scalars)!\n", __func__);
                        }
                    }

                    else
                    {
                        mcapi_struct->status = -1;
                    }

                    break;

                /* Open a local endpoint as a receiver. */
                case MCAPID_MGMT_OPEN_RX_SIDE_SCL:

                    /* Only one receive handle can be open on the management
                     * service thread at a time.
                     */
                    if (rx_handle_scl_in_use == MCAPI_FALSE)
                    {
                        port = mcapi_get32(buffer,
                                           MCAPID_MGMT_FOREIGN_PORT_OFFSET);
                        mcapi_get_endpoint_i(this_node, port, &endpoint,
                                             &request, &status);
                        complete = mcapi_wait(&request, &size, &status, 0);

                        if (complete && (status == MCAPI_SUCCESS))
                        {
                            mcapi_open_sclchan_recv_i(&rx_handle_scl,
                                                      endpoint,
                                                      &scl_rx_request,
                                                      &mcapi_struct->status);

                            if ( (mcapi_struct->status == MCAPI_SUCCESS) ||
                                 (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED) )
                            {
                                rx_handle_scl_in_use = MCAPI_TRUE;
                            }
                        }
                        else
                        {
                            printf("%s: tried to open a non-existent "
                                   "endpoint (for scalars)!\n", __func__);
                        }
                    }

                    else
                    {
                        mcapi_struct->status = -1;
                    }

                    break;

                /* Close the send side. */
                case MCAPID_MGMT_CLOSE_TX_SIDE_SCL:

                    mcapi_sclchan_send_close_i(tx_handle_scl, &mcapi_struct->request,
                                               &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        tx_handle_scl_in_use = MCAPI_FALSE;
                    }

                    break;

                /* Close the receive side. */
                case MCAPID_MGMT_CLOSE_RX_SIDE_SCL:

                    mcapi_sclchan_recv_close_i(rx_handle_scl, &mcapi_struct->request,
                                               &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        rx_handle_scl_in_use = MCAPI_FALSE;
                    }

                    break;

                /* Send a 64-bit scalar. */
                case MCAPID_TX_64_BIT_SCL:

                    mcapi_sclchan_send_uint64(tx_handle_scl, MCAPID_64BIT_SCALAR,
                                              &mcapi_struct->status);

                    break;

                /* Send a 32-bit scalar. */
                case MCAPID_TX_32_BIT_SCL:

                    mcapi_sclchan_send_uint32(tx_handle_scl, MCAPID_32BIT_SCALAR,
                                              &mcapi_struct->status);

                    break;

                /* Send a 16-bit scalar. */
                case MCAPID_TX_16_BIT_SCL:

                    mcapi_sclchan_send_uint16(tx_handle_scl, MCAPID_16BIT_SCALAR,
                                              &mcapi_struct->status);

                    break;

                /* Send a 8-bit scalar. */
                case MCAPID_TX_8_BIT_SCL:

                    mcapi_sclchan_send_uint8(tx_handle_scl, MCAPID_8BIT_SCALAR,
                                             &mcapi_struct->status);

                    break;

                case MCAPID_NO_OP:

                    /* NO OP just ACKs back a successful response. */
                    mcapi_struct->status = MCAPI_SUCCESS;

                    break;

                default:

                    mcapi_struct->status = -1;
                    break;
            }

            /* Put the status in the packet. */
            mcapi_put32(buffer, MCAPID_MGMT_STATUS_OFFSET, mcapi_struct->status);

            prio = mcapi_get32(buffer, MCAPID_MGMT_PRIO_OFFSET);

            /* Send the response using the specified priority. */
            mcapi_msg_send(mcapi_struct->local_endp,
                           mcapi_get32(buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                           buffer, rx_len, prio, &mcapi_struct->status);
        }

        /* The service has been shut down. */
        else
        {
            /* Terminate this task. */
            MCAPI_Cleanup_Task();

            break;
        }
    }

} /* MCAPID_Mgmt_Service */

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_TX_Mgmt_Message
*
*   DESCRIPTION
*
*       Transmit a service message to the management endpoint.
*
*************************************************************************/
mcapi_status_t MCAPID_TX_Mgmt_Message(MCAPID_STRUCT *mcapi_struct,
                                      mcapi_uint32_t type,
                                      mcapi_port_t foreign_port,
                                      mcapi_endpoint_t local_endp,
                                      mcapi_uint32_t pause,
                                      mcapi_uint32_t priority)
{
    unsigned char   buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_status_t  status;

    /* Set the type of service to complete. */
    mcapi_put32(buffer, MCAPID_MGMT_TYPE_OFFSET, type);

    /* Set the port of the foreign endpoint to use. */
    mcapi_put32(buffer, MCAPID_MGMT_FOREIGN_PORT_OFFSET, foreign_port);

    /* Zero out status. */
    mcapi_put32(buffer, MCAPID_MGMT_STATUS_OFFSET, 0);

    /* Set the millisecond pause before performing the service. */
    mcapi_put32(buffer, MCAPID_MGMT_PAUSE_OFFSET, pause);

    /* Set the endpoint to respond to on this node. */
    mcapi_put32(buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET, local_endp);

    /* Set the priority the receiver should use when responding. */
    mcapi_put32(buffer, MCAPID_MGMT_PRIO_OFFSET, priority);

    /* If this is a cancel or wait request, store the address of the request
     * being canceled in the status field of the packet.
     */
    if ( (type == MCAPID_CANCEL_REQUEST) || (type == MCAPID_WAIT_REQUEST) )
    {
        mcapi_put32(buffer, MCAPID_MGMT_STATUS_OFFSET,
                    (mcapi_uint32_t)&mcapi_struct->request);
    }

    /* Send the request. */
    mcapi_msg_send(mcapi_struct->local_endp, mcapi_struct->foreign_endp,
                   buffer, MCAPID_MGMT_PKT_LEN, priority, &status);

    return (status);

} /* MCAPID_TX_Mgmt_Message */

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_RX_Mgmt_Response
*
*   DESCRIPTION
*
*       Receives the response to a service message from the management
*       endpoint.
*
*************************************************************************/
mcapi_status_t MCAPID_RX_Mgmt_Response(MCAPID_STRUCT *mcapi_struct)
{
    unsigned char   buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_status_t  status, cncl_stat;
    mcapi_request_t request;
    size_t          rx_len;

    /* Receive the message. */
    mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                     &request, &status);

    if (status == MCAPI_SUCCESS)
    {
        mcapi_wait(&request, &rx_len, &status, 5000);

        if (status == MCAPI_SUCCESS)
        {
            /* Extract the status of the operation. */
            status = mcapi_get32(buffer, MCAPID_MGMT_STATUS_OFFSET);
        }

        else
        {
            mcapi_cancel(&request, &cncl_stat);
        }
    }

    return (status);

} /* MCAPID_RX_Mgmt_Response */
