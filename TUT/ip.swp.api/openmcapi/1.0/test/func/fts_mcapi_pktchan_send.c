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
*       fts_main.c
*
*
*************************************************************************/

#include "fts_defs.h"
#include "support_suite/mcapid_support.h"

extern MCAPI_MUTEX      MCAPID_FTS_Mutex;

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_18_1
*
*   DESCRIPTION
*
*       Testing mcapi_pktchan_send - send data over open connection.
*
*           Node 0 – Create endpoint, open receive side, wait for data
*
*           Node 1 – Create endpoint, open send side, get endpoint on
*                    Node 0, issue connection, send data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_18_1)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;
    char                        buffer[MCAPID_MSG_LEN];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the local endpoint as the sender. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp, &request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Get the receive side endpoint. */
        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, mcapi_struct->foreign_endp,
                                     &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Connect the two endpoints. */
            mcapi_connect_pktchan_i(mcapi_struct->local_endp, rx_endp,
                                    &mcapi_struct->request,
                                    &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                           MCAPI_FTS_TIMEOUT);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Send some data. */
                    mcapi_pktchan_send(mcapi_struct->pkt_tx_handle, buffer,
                                       MCAPID_MSG_LEN, &mcapi_struct->status);
                }

                /* Close the send side. */
                mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                              &request, &status);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_18_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_18_2
*
*   DESCRIPTION
*
*       Testing mcapi_pktchan_send - send data over closed connection.
*
*           Node 0 – Create endpoint, open receive side, wait for
*                    connection, close receive side.
*
*           Node 1 – Create endpoint, open send side, get endpoint on
*                    Node 0, issue connection, send data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_18_2)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;
    char                        buffer[MCAPID_MSG_LEN];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the local endpoint as the sender. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp, &request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Get the receive side endpoint. */
        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, mcapi_struct->foreign_endp,
                                     &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Connect the two endpoints. */
            mcapi_connect_pktchan_i(mcapi_struct->local_endp, rx_endp,
                                    &mcapi_struct->request,
                                    &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                           MCAPI_FTS_TIMEOUT);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Close the send side. */
                    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                                  &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the close to complete. */
                        mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                   MCAPI_FTS_TIMEOUT);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Send some data. */
                            mcapi_pktchan_send(mcapi_struct->pkt_tx_handle, buffer,
                                               MCAPID_MSG_LEN, &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_ERR_CHAN_INVALID)
                            {
                                mcapi_struct->status = MCAPI_SUCCESS;
                            }

                            else
                            {
                                mcapi_struct->status = -1;
                            }
                        }
                    }
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_18_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_18_3
*
*   DESCRIPTION
*
*       Testing mcapi_pktchan_send - no buffers remaining in the
*       system.
*
*           Node 0 – Create an endpoint, open receive side, wait for
*                    connection.  Create an endpoint, send enough message
*                    data to Node 1 to exhaust all receive buffers
*
*           Node 1 – Create an endpoint, issue get endpoint require for
*                    Node 0, open send side, issue connection.  Create an
*                    endpoint, issue get endpoint request for Node 0, wait
*                    for all buffers to be used up, attempt to transmit a
*                    packet to Node 0 over the established connection.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_18_3)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    MCAPID_STRUCT               mcapi_msg_struct;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_request_t             request;
    char                        buffer[MCAPID_MSG_LEN];
    int                         i, j;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Create a new endpoint for sending/receiving control messages. */
    mcapi_msg_struct.local_endp =
        mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the management server for the foreign node. */
        mcapi_struct->status =
            MCAPID_Get_Service("mgmt_svc", &mcapi_msg_struct.foreign_endp);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that an endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(&mcapi_msg_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                       mcapi_msg_struct.local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for a response. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(&mcapi_msg_struct);

                /* If the endpoint was created. */
                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Exhaust all local buffers. */
                    for (i = 0; i < TEST_BUF_COUNT; i ++)
                    {
                        /* Issue a NO OP to cause the other side to send an ACK. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(&mcapi_msg_struct, MCAPID_NO_OP, 1024,
                                                   mcapi_msg_struct.local_endp, 0,
                                                   MCAPI_DEFAULT_PRIO);

                        if (mcapi_struct->status != MCAPI_SUCCESS)
                        {
                            break;
                        }
                    }

                    /* Try to send a packet. */
                    mcapi_pktchan_send(mcapi_struct->pkt_tx_handle, buffer,
                                         MCAPID_MSG_LEN, &mcapi_struct->status);

                    /* Ensure the proper error code was returned. */
                    if (mcapi_struct->status == MCAPI_ERR_TRANSMISSION)
                    {
                        mcapi_struct->status = MCAPI_SUCCESS;
                    }

                    else
                    {
                        mcapi_struct->status = -1;
                    }

                    /* Receive all the pending data. */
                    for (j = 0; j < i; j ++)
                    {
                        mcapi_msg_recv_i(mcapi_msg_struct.local_endp, buffer, MCAPID_MSG_LEN,
                                         &mcapi_msg_struct.request, &status);

                        if (status == MCAPI_SUCCESS)
                        {
                            /* Wait for data. */
                            mcapi_wait(&mcapi_msg_struct.request, &rx_len, &status, MCAPI_FTS_TIMEOUT);

                            if (status != MCAPI_SUCCESS)
                                break;
                        }

                        else
                        {
                            break;
                        }
                    }

                    /* Tell the other side to delete the endpoint. */
                    status =
                        MCAPID_TX_Mgmt_Message(&mcapi_msg_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                               mcapi_msg_struct.local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response before releasing the mutex. */
                        status = MCAPID_RX_Mgmt_Response(&mcapi_msg_struct);
                    }
                }
            }
        }

        /* Delete the control endpoint. */
        mcapi_delete_endpoint(mcapi_msg_struct.local_endp, &status);
    }

    /* Close the send side. */
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                  &request, &mcapi_struct->status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_18_3 */
