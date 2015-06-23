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
#include "mcapid.h"

extern MCAPI_MUTEX      MCAPID_FTS_Mutex;

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_1
*
*   DESCRIPTION
*
*       Testing mcapi_cancel while getting a foreign endpoint.
*
*           Node 0 – Waits for get endpoint request, wait for request to
*           be canceled, create endpoint
*
*           Node 1 – Issue get endpoint request to Node 0, cancel request
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set endpoint to 0xffffffff for testing purposes. */
    endpoint = 0xffffffff;

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(0, 1024, &endpoint, &mcapi_struct->request,
                         &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Cancel the request. */
        mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

        /* Indicate that the endpoint should be created. */
        status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                   mcapi_struct->local_endp, 500, MCAPI_DEFAULT_PRIO);

        /* Wait for a response. */
        if (status == MCAPI_SUCCESS)
        {
            /* Wait for a response. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            MCAPID_Sleep(1000);

            /* Ensure the endpoint pointer was not updated when the
             * endpoint was created.
             */
            if (endpoint != 0xffffffff)
            {
                mcapi_struct->status = -1;
            }

            /* Tell the other side to delete the endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response before releasing the mutex. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_1 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_2
*
*   DESCRIPTION
*
*       Testing mcapi_cancel while getting a foreign endpoint with
*       multiple threads waiting for the request.
*
*           Node 0 – Waits for get endpoint request, wait for request to
*           be canceled, create endpoint
*
*           Node 1 – Issue get endpoint request to Node 0, cause another
*                    thread to also wait for completion of the request,
*                    cancel request
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    mcapi_endpoint_t    endpoint;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set up the structure for getting the local management server. */
    svc_struct.type = MCAPI_MSG_TX_TYPE;
    svc_struct.local_port = MCAPI_PORT_ANY;
    svc_struct.node = FUNC_FRONTEND_NODE_ID;
    svc_struct.service = "lcl_mgmt";
    svc_struct.thread_entry = MCAPI_NULL;

    /* Create the client service. */
    MCAPID_Create_Service(&svc_struct);

    /* Set endpoint to 0xffffffff for testing purposes. */
    endpoint = 0xffffffff;

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(0, 1024, &endpoint, &svc_struct.request,
                         &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Cause another thread to wait on the request too. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_WAIT_REQUEST, 0,
                                   svc_struct.local_endp, 0,
                                   MCAPI_DEFAULT_PRIO);

        /* Let the thread wait. */
        MCAPID_Sleep(1000);

        /* Cancel the request. */
        mcapi_cancel(&svc_struct.request, &mcapi_struct->status);

        /* Wait for a response from the thread waiting for the request. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(&svc_struct);

        if (mcapi_struct->status != MCAPI_ERR_REQUEST_CANCELLED)
        {
            mcapi_struct->status = -1;
        }

        else
        {
            /* Indicate that the endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for a response. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                MCAPID_Sleep(1000);

                /* Ensure the endpoint pointer was not updated when the
                 * endpoint was created.
                 */
                if (endpoint != 0xffffffff)
                {
                    mcapi_struct->status = -1;
                }

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for a response before releasing the mutex. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_2 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_3
*
*   DESCRIPTION
*
*       Testing mcapi_cancel for mcapi_msg_recv_i().
*
*           Node 0 – Wait for message receive request to be canceled,
*                    transmit data to endpoint
*
*           Node 1 – Issue message receive call on endpoint, cancel request
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    rx_endp;
    mcapi_status_t      status;
    char                buffer[MCAPID_MGMT_PKT_LEN];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        memset(buffer, 0, MCAPID_MGMT_PKT_LEN);

        /* Make the call to receive data on this endpoint. */
        mcapi_msg_recv_i(rx_endp, buffer, MCAPID_MGMT_PKT_LEN,
                         &mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Cancel the request. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            /* Indicate that an endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                       mcapi_struct->local_endp, 500, MCAPI_DEFAULT_PRIO);

            /* Wait for a response. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Indicate that a message should be sent. */
                    mcapi_struct->status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP,
                                               1024, rx_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the data. */
                        MCAPID_Sleep(1000);

                        /* Ensure the data is still on the endpoint waiting to
                         * be received.
                         */
                        if (mcapi_msg_available(rx_endp, &status) != 1)
                        {
                            mcapi_struct->status = -1;
                        }
                    }

                    /* Tell the other side to delete the endpoint. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response before releasing the mutex. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_3 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_4
*
*   DESCRIPTION
*
*       Testing mcapi_cancel for mcapi_open_pktchan_recv_i().
*
*           Node 0 – Wait for open packet channel request to be canceled,
*                    open connection
*
*           Node 1 – Issue call to open receive side of packet channel,
*                    cancel request, ensure endpoint is reusable for channel
*                    connection or message send/recv
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len = 0;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open receive side of a packet channel. */
        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                  &mcapi_struct->request,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Cancel the request. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that an endpoint should be created. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                                           1024, mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Indicate that the send side should be opened. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                                   1024, mcapi_struct->local_endp, 0,
                                                   MCAPI_DEFAULT_PRIO);

                        /* Wait for a response. */
                        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_pktchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Try to close the receive side. */
                                mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                              &mcapi_struct->request,
                                                              &mcapi_struct->status);

                                /* An error should be returned since the call to open
                                 * the receive side was canceled.
                                 */
                                if (mcapi_struct->status == MCAPI_ERR_CHAN_NOTOPEN)
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

                    /* Indicate that the send side should be closed. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                               MCAPID_MGMT_CLOSE_TX_SIDE_PKT, 1024,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1024, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_4 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_5
*
*   DESCRIPTION
*
*       Testing mcapi_cancel for mcapi_open_pktchan_send_i().
*
*           Node 0 – Wait for open packet channel request to be canceled,
*                    open connection
*
*           Node 1 – Issue call to open send side of packet channel,
*                    cancel request, ensure endpoint is reusable for channel
*                    connection or message send/recv
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_5)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len = 0;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open send side of a packet channel. */
        mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle, tx_endp,
                                  &mcapi_struct->request,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Cancel the request. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that an endpoint should be created. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                                           1024, mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Indicate that the receive side should be opened. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_PKT,
                                                   1024, mcapi_struct->local_endp, 0,
                                                   MCAPI_DEFAULT_PRIO);

                        /* Wait for a response. */
                        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_pktchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Try to close the send side. */
                                mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                                              &mcapi_struct->request,
                                                              &mcapi_struct->status);

                                /* An error should be returned since the call to open
                                 * the receive side was canceled.
                                 */
                                if (mcapi_struct->status == MCAPI_ERR_CHAN_NOTOPEN)
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

                    /* Indicate that the receive side should be closed. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                               MCAPID_MGMT_CLOSE_RX_SIDE_PKT, 1024,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1024, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_5 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_6
*
*   DESCRIPTION
*
*       Testing mcapi_cancel for mcapi_pktchan_recv_i().
*
*           Node 0 – Wait for packet channel receive request to be canceled,
*                    transmit data to endpoint
*
*           Node 1 – Issue call to receive data over packet channel,
*                    cancel request
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_6)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len = 0;
    mcapi_status_t      status;
    char                *buffer;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that an endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                                   1024, mcapi_struct->local_endp, 0,
                                   MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for a response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the send side should be opened. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Get the foreign endpoint. */
            tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                         &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Connect the two endpoints. */
                mcapi_connect_pktchan_i(tx_endp, rx_endp,
                                        &mcapi_struct->request,
                                        &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the connection. */
                    mcapi_wait(&mcapi_struct->request, &rx_len,
                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                    /* Open receive side of a packet channel. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                              &mcapi_struct->request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Issue a call to receive a packet. */
                        mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                             (void**)&buffer,
                                             &mcapi_struct->request,
                                             &mcapi_struct->status);

                        /* Cancel the call to receive a packet. */
                        mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

                        /* Tell the other side to send some data. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_TX_PKT,
                                                   1024, mcapi_struct->local_endp,
                                                   0, MCAPI_DEFAULT_PRIO);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the response. */
                            mcapi_struct->status =
                                MCAPID_RX_Mgmt_Response(mcapi_struct);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Ensure the data is still on the endpoint waiting to
                                 * be received.
                                 */
                                if (mcapi_pktchan_available(mcapi_struct->pkt_rx_handle,
                                                            &mcapi_struct->status) != 1)
                                {
                                    mcapi_struct->status = -1;
                                }
                            }
                        }

                        /* Close the receive side. */
                        mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                      &mcapi_struct->request,
                                                      &mcapi_struct->status);
                    }
                }
            }

            /* Indicate that the send side should be closed. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_CLOSE_TX_SIDE_PKT, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }

            /* Indicate that an endpoint should be deleted. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                       1024, mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_6 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_7
*
*   DESCRIPTION
*
*       Testing mcapi_cancel for mcapi_open_sclchan_recv_i().
*
*           Node 0 – Wait for open scalar channel request to be canceled,
*                    open connection
*
*           Node 1 – Issue call to open receive side of scalar channel,
*                    cancel request, ensure endpoint is reusable for channel
*                    connection or message send/recv
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_7)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len = 0;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open receive side of a scalar channel. */
        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle, rx_endp,
                                  &mcapi_struct->request,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Cancel the request. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that an endpoint should be created. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                                           1024, mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Indicate that the send side should be opened. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                                   1024, mcapi_struct->local_endp, 0,
                                                   MCAPI_DEFAULT_PRIO);

                        /* Wait for a response. */
                        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Try to close the receive side. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &mcapi_struct->request,
                                                           &mcapi_struct->status);

                                /* An error should be returned since the call to open
                                 * the receive side was canceled.
                                 */
                                if (mcapi_struct->status == MCAPI_ERR_CHAN_NOTOPEN)
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

                    /* Indicate that the send side should be closed. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                               MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1024, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_7 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_36_8
*
*   DESCRIPTION
*
*       Testing mcapi_cancel for mcapi_open_sclchan_send_i().
*
*           Node 0 – Wait for open scalar channel request to be canceled,
*                    open connection
*
*           Node 1 – Issue call to open send side of scalar channel,
*                    cancel request, ensure endpoint is reusable for channel
*                    connection or message send/recv
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_36_8)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len = 0;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open send side of a scalar channel. */
        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle, tx_endp,
                                  &mcapi_struct->request,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Cancel the request. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that an endpoint should be created. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                                           1024, mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Indicate that the receive side should be opened. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                                   1024, mcapi_struct->local_endp, 0,
                                                   MCAPI_DEFAULT_PRIO);

                        /* Wait for a response. */
                        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Try to close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &mcapi_struct->request,
                                                           &mcapi_struct->status);

                                /* An error should be returned since the call to open
                                 * the receive side was canceled.
                                 */
                                if (mcapi_struct->status == MCAPI_ERR_CHAN_NOTOPEN)
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

                    /* Indicate that the receive side should be closed. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                               MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1024, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_36_8 */
