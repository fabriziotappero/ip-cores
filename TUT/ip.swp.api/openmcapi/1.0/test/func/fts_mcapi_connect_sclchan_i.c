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
*       MCAPI_FTS_Tx_2_25_1
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connect two remote endpoints on
*       the same foreign node.
*
*           Node 0 – Create two endpoints
*
*           Node 1 – Get both endpoints, and issue connect request
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_endpoint_t    tx_endp, rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that a second remote endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the endpoint was created. */
                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the first endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Get the second endpoint. */
                        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1025, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, rx_endp, &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the connection to return successfully. */
                                mcapi_wait(&mcapi_struct->request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);
                            }
                        }
                    }

                    /* Tell the other side to delete the second endpoint. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1025, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }

            /* Tell the other side to delete the first endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_2
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connection performed by
*       receiver node.
*
*           Node 0 – Create an endpoint, get the endpoint on Node 1, open
*                    the endpoint as a receiver, issue connection
*
*           Node 1 – Create an endpoint, open the endpoint as a sender
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_2)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the send side endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the local endpoint as the receiver. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the receive side. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }
            }

            /* Tell the other side to close the send side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_3
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connection performed by
*       sender node.
*
*           Node 0 – Create an endpoint, get the endpoint on Node 1, open
*                    the endpoint as a sender, issue connection
*
*           Node 1 – Create an endpoint, open the endpoint as a receiver
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_3)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the receive side endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the local endpoint as the sender. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }
            }

            /* Tell the other side to close the receive side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_3 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_4
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connect two remote endpoints on
*       the same foreign node - already connected
*
*           Node 0 – Create two endpoints
*
*           Node 1 – Get both endpoints, and issue connect request, issue
*                    connect request again
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_endpoint_t    tx_endp, rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that a second remote endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the endpoint was created. */
                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the first endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Get the second endpoint. */
                        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1025, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, rx_endp, &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the connection to return successfully. */
                                mcapi_wait(&mcapi_struct->request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Connect the two endpoints again. */
                                    mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                                            &mcapi_struct->request,
                                                            &mcapi_struct->status);

                                    /* If both endpoints are local, the routine will return
                                     * an error.
                                     */
                                    if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
                                    {
                                        mcapi_struct->status = MCAPI_SUCCESS;
                                    }

                                    /* Otherwise, the routine will return success until
                                     * the remote endpoints can return an error.
                                     */
                                    else if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the connection to return successfully. */
                                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                        /* An error should have been returned. */
                                        if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
                                        {
                                            mcapi_struct->status = MCAPI_SUCCESS;
                                        }

                                        else
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }

                                    else
                                    {
                                        mcapi_struct->status = -1;
                                    }
                                }
                            }
                        }
                    }

                    /* Tell the other side to delete the second endpoint. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1025, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }

            /* Tell the other side to delete the first endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_4 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_5
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connection performed by
*       receiver node - already connected.
*
*           Node 0 – Create an endpoint, open the endpoint as a sender
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, open
*                    the endpoint as a receiver, issue connection, issue
*                    connection again
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_5)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the send side endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the local endpoint as the receiver. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Connect the two endpoints again. */
                                    mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                            &mcapi_struct->request,
                                                            &mcapi_struct->status);

                                    /* If both endpoints are local, the routine will return
                                     * an error.
                                     */
                                    if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
                                    {
                                        mcapi_struct->status = MCAPI_SUCCESS;
                                    }

                                    /* Otherwise, the routine will return success until
                                     * the remote endpoints can return an error.
                                     */
                                    else if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the connection to return successfully. */
                                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                        /* An error should have been returned. */
                                        if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
                                        {
                                            mcapi_struct->status = MCAPI_SUCCESS;
                                        }

                                        else
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }

                                    else
                                    {
                                        mcapi_struct->status = -1;
                                    }
                                }

                                /* Close the receive side. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }
            }

            /* Tell the other side to close the send side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_5 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_6
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connection performed by
*       sender node - already connected.
*
*           Node 0 – Create an endpoint, open the endpoint as a receiver
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, open
*                    the endpoint as a sender, issue connection, issue
*                    connection again
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_6)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the receive side endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the local endpoint as the sender. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Connect the two endpoints. */
                                    mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                            &mcapi_struct->request,
                                                            &mcapi_struct->status);

                                    /* If both endpoints are local, the routine will return
                                     * an error.
                                     */
                                    if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
                                    {
                                        mcapi_struct->status = MCAPI_SUCCESS;
                                    }

                                    /* Otherwise, the routine will return success until
                                     * the remote endpoints can return an error.
                                     */
                                    else if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the connection to return successfully. */
                                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                        /* An error should have been returned. */
                                        if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
                                        {
                                            mcapi_struct->status = MCAPI_SUCCESS;
                                        }

                                        else
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }

                                    else
                                    {
                                        mcapi_struct->status = -1;
                                    }
                                }

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }
            }

            /* Tell the other side to close the receive side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_6 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_7
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - open send side / open receive
*       side / connect
*
*           Node 0 – Create endpoint, open endpoint as sender
*
*           Node 1 – Create endpoint, wait for Node 0 to open as sender,
*                    open as a receiver, get endpoint on Node 0, issue
*                    connection
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_7)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Open the local endpoint as the receiver. */
                    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                              mcapi_struct->local_endp,
                                              &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                    {
                        /* Get the send side endpoint. */
                        tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the receive side. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &request, &status);
                            }
                        }
                    }

                    /* Tell the other side to close the send side. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }

            /* Tell the other side to delete the endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_7 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_8
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connect / open receive side /
*       open send side
*
*           Node 0 – Create endpoint, wait for Node 1 to open, open
*                    endpoint as sender
*
*           Node 1 – Create endpoint, get endpoint on Node 0, issue
*                    connection and open as a receiver
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_8)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;
    mcapi_endpoint_t            rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for the connection. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that a remote endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                   mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for a response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            /* If the endpoint was created. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Get the send side endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                    &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Open the local endpoint as the receiver. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle, rx_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Indicate that the endpoint should be opened as a sender. */
                            mcapi_struct->status =
                                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for a response. */
                                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                /* If the send side was opened. */
                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the open call to return successfully. */
                                    mcapi_wait(&request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Close the receive side. */
                                    mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                               &request, &status);

                                    /* Tell the other side to close the send side. */
                                    status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_CLOSE_TX_SIDE_SCL,
                                                               1024, mcapi_struct->local_endp,
                                                               0, MCAPI_DEFAULT_PRIO);

                                    if (status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the response. */
                                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                    }
                                }
                            }
                        }
                    }
                }

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }

        /* Delete the endpoint used in the connection. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_8 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_9
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connect / open send side /
*       open receive side
*
*           Node 0 – Create endpoint, wait for Node 1 to open, open
*                    endpoint as receiver
*
*           Node 1 – Create endpoint, get endpoint on Node 0, issue
*                    connection and open as sender
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_9)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp, tx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Create a new endpoint for the send side. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that a remote endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                   mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for a response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            /* If the endpoint was created. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Get the receive side endpoint. */
                rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                    &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Open the local endpoint as the sender. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  tx_endp, &request,
                                                  &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Indicate that the endpoint should be opened as a receiver. */
                            mcapi_struct->status =
                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                       MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                                       mcapi_struct->local_endp, 0,
                                                       MCAPI_DEFAULT_PRIO);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for a response. */
                                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                /* If the send side was opened. */
                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the open call to return successfully. */
                                    mcapi_wait(&request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Close the send side. */
                                    mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                               &request, &status);

                                    /* Tell the other side to close the receive side. */
                                    status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_CLOSE_RX_SIDE_SCL,
                                                               1024, mcapi_struct->local_endp,
                                                               0, MCAPI_DEFAULT_PRIO);

                                    if (status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the response. */
                                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                    }
                                }
                            }
                        }
                    }
                }

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }

        /* Delete the endpoint created for this session. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_9 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_10
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - open send / connect /
*       open receive
*
*           Node 0 – Create endpoint, open endpoint as sender
*
*           Node 1 – Create endpoint, get endpoint on Node 0, wait for
*                    Node 0 to open as sender, issue connection, open
*                    as a receiver
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_10)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the send side endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection to complete. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                        &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Open the local endpoint as the receiver. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      mcapi_struct->local_endp, &request,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the receive side. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &request, &status);
                            }
                        }
                    }

                    /* Tell the other side to close the send side. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }

            /* Tell the other side to delete the endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_10 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_11
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - open receive / connect /
*       open send
*
*           Node 0 – Create endpoint, open endpoint as receiver
*
*           Node 1 – Create endpoint, get endpoint on Node 0, wait for
*                    Node 0 to open as receiver, issue connection,
*                    open as a sender
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_11)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send receive was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the receive side endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the open call to return successfully. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Open the local endpoint as the sender. */
                            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                      mcapi_struct->local_endp, &request,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }

                /* Tell the other side to close the receive side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }

            /* Tell the other side to delete the endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_11 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_12
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - open receive / connect /
*       open send
*
*           Node 0 – Create endpoint, open endpoint as receiver
*
*           Node 1 – Create endpoint, get endpoint on Node 0, wait for
*                    Node 0 to open as receiver, open as a sender,
*                    issue connection
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_12)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the receive was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Open the local endpoint as the sender. */
                    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                              mcapi_struct->local_endp, &request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                    {
                        /* Get the receive side endpoint. */
                        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &request, &status);
                            }
                        }
                    }

                    /* Tell the other side to close the receive side. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }

            /* Tell the other side to delete the endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_12 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_13
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connect two remote endpoints on
*       the same foreign node reusing endpoints from a previous connection
*
*           Node 0 – Create two endpoints, wait for connect, open send
*                    open receive, close send, close receive, wait for
*                    connect
*
*           Node 1 – Get both endpoints, and issue connect request, wait
*                    for connection to close, issue connect request
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_13)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_endpoint_t    tx_endp, rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that a second remote endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the endpoint was created. */
                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the first endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Get the second endpoint. */
                        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1025, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, rx_endp, &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the connection to return successfully. */
                                mcapi_wait(&mcapi_struct->request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Indicate that the first endpoint should be opened as a
                                     * sender.
                                     */
                                    mcapi_struct->status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                                               1024, mcapi_struct->local_endp,
                                                               0, MCAPI_DEFAULT_PRIO);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for a response. */
                                        mcapi_struct->status =
                                            MCAPID_RX_Mgmt_Response(mcapi_struct);

                                        /* If the sender was opened. */
                                        if (mcapi_struct->status == MCAPI_SUCCESS)
                                        {
                                            /* Indicate that the second endpoint should be opened
                                             * as a receiver.
                                             */
                                            mcapi_struct->status =
                                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                       MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                                                       1025, mcapi_struct->local_endp,
                                                                       0, MCAPI_DEFAULT_PRIO);

                                            if (mcapi_struct->status == MCAPI_SUCCESS)
                                            {
                                                /* Wait for a response. */
                                                mcapi_struct->status =
                                                    MCAPID_RX_Mgmt_Response(mcapi_struct);

                                                /* If the receive side was opened. */
                                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                                {
                                                    /* Let the open packets get processed. */
                                                    MCAPID_Sleep(1000);

                                                    /* Tell the other side to close the receive side. */
                                                    status =
                                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                               MCAPID_MGMT_CLOSE_RX_SIDE_SCL,
                                                                               1025,
                                                                               mcapi_struct->local_endp, 0,
                                                                               MCAPI_DEFAULT_PRIO);

                                                    if (status == MCAPI_SUCCESS)
                                                    {
                                                        /* Wait for the response. */
                                                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                                        /* Tell the other side to close the send side. */
                                                        status =
                                                            MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                                   MCAPID_MGMT_CLOSE_TX_SIDE_SCL,
                                                                                   1024, mcapi_struct->local_endp, 0,
                                                                                   MCAPI_DEFAULT_PRIO);

                                                        if (status == MCAPI_SUCCESS)
                                                        {
                                                            /* Wait for the response. */
                                                            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                                            /* Let the close packets get processed. */
                                                            MCAPID_Sleep(1000);

                                                            /* Reconnect the two endpoints. */
                                                            mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                                                                    &mcapi_struct->request,
                                                                                    &mcapi_struct->status);

                                                            if (mcapi_struct->status == MCAPI_SUCCESS)
                                                            {
                                                                /* Wait for the connection to return successfully. */
                                                                mcapi_wait(&mcapi_struct->request, &rx_len,
                                                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);
                                                            }
                                                        }
                                                    }
                                                }

                                                else
                                                {
                                                    /* Tell the other side to close the send side. */
                                                    status =
                                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                               MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                                                               mcapi_struct->local_endp, 0,
                                                                               MCAPI_DEFAULT_PRIO);

                                                    if (status == MCAPI_SUCCESS)
                                                    {
                                                        /* Wait for the response. */
                                                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    /* Tell the other side to delete the second endpoint. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                               1025, mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }

            /* Tell the other side to delete the first endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_13 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_14
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connection performed by
*       receiver node - reusing endpoints from a previous connection
*
*           Node 0 – Create an endpoint, open the endpoint as a sender,
*                    wait for connect request, close endpoint, open the
*                    endpoint as a sender
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0,
*                    open the endpoint as a receiver, issue connection,
*                    close the receiver, open the receive, issue connection
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_14)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the send side endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the local endpoint as the receiver. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the receive side. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }
            }

            /* Tell the other side to close the send side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }

            /* Let the close packet get processed. */
            MCAPID_Sleep(1000);

            /* Indicate that the endpoint should be re-opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Open the local endpoint as the receiver. */
                    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                              mcapi_struct->local_endp,
                                              &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the open call to return successfully. */
                            mcapi_wait(&request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Close the receive side. */
                            mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                       &request, &status);
                        }
                    }
                }
            }

            /* Tell the other side to close the send side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_14 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_25_15
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - connection performed by
*       sender node - reusing endpoints from a previous connection.
*
*           Node 0 – Create an endpoint, open the endpoint as a receiver,
*                    wait for connect request, close endpoint, open the
*                    endpoint as a receiver
*
*           Node 1 – Create an endpoint, get endpoint on Node 0, open the
*                    endpoint as a sender, issue connection, close the
*                    send side, open the send side, issue connection
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_25_15)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* If the send side was opened. */
                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the receive side endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the local endpoint as the sender. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the open call to return successfully. */
                                mcapi_wait(&request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &request, &status);
                            }
                        }
                    }
                }
            }

            /* Tell the other side to close the receive side. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                /* Let the close packet get processed. */
                MCAPID_Sleep(1000);

                /* Indicate that the endpoint should be opened as a receiver. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* If the send side was opened. */
                    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                    {
                        /* Get the receive side endpoint. */
                        rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the local endpoint as the sender. */
                            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                      mcapi_struct->local_endp,
                                                      &request, &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                /* Connect the two endpoints. */
                                mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                        &mcapi_struct->request,
                                                        &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the open call to return successfully. */
                                    mcapi_wait(&request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Close the send side. */
                                    mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                               &request, &status);
                                }
                            }
                        }
                    }
                }

                /* Tell the other side to close the receive side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* Tell the other side to delete the endpoint. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for the response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_25_15 */
