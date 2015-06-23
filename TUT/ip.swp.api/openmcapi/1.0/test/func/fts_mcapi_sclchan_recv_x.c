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
*       MCAPI_FTS_Tx_2_29_1
*
*   DESCRIPTION
*
*       Testing mcapi_sclchan_recv_uint64, mcapi_sclchan_recv_uint32,
*       mcapi_sclchan_recv_uint16, mcapi_sclchan_recv_uint8 - receive data
*       over open connection.
*
*       For each scalar size:
*
*           Node 0 – Create endpoint, open send side, wait for connection,
*                    send data
*
*           Node 1 – Create endpoint, open receive side, get endpoint on
*                    Node 0, open connection, wait for data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_29_1)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp, rx_endp;
    mcapi_request_t             request;
    int                         i;
    mcapi_uint64_t              recv_64bit;
    mcapi_uint32_t              recv_32bit;
    mcapi_uint16_t              recv_16bit;
    mcapi_uint8_t               recv_8bit;

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
                /* Indicate that the endpoint should be opened as a sender. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                           1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* If the receive side was opened. */
                    if (mcapi_struct->status ==MGC_MCAPI_ERR_NOT_CONNECTED)
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
                                    /* Wait for the open to return successfully. */
                                    mcapi_wait(&request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Test each scalar size. */
                                    for (i = MCAPID_TX_64_BIT_SCL; i <= MCAPID_TX_8_BIT_SCL; i ++)
                                    {
                                        /* Tell the other side to send some data. */
                                        mcapi_struct->status =
                                            MCAPID_TX_Mgmt_Message(mcapi_struct, i, 1024,
                                                                   mcapi_struct->local_endp,
                                                                   0, MCAPI_DEFAULT_PRIO);

                                        if (mcapi_struct->status == MCAPI_SUCCESS)
                                        {
                                            /* Wait for the response. */
                                            mcapi_struct->status =
                                                MCAPID_RX_Mgmt_Response(mcapi_struct);

                                            if (mcapi_struct->status == MCAPI_SUCCESS)
                                            {
                                                /* Receive the proper scalar size. */
                                                switch (i)
                                                {
                                                    case MCAPID_TX_64_BIT_SCL:

                                                        recv_64bit =
                                                            mcapi_sclchan_recv_uint64(mcapi_struct->scl_rx_handle,
                                                                                      &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_64bit != MCAPI_FTS_64BIT_SCALAR) )
                                                        {
                                                             mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    case MCAPID_TX_32_BIT_SCL:

                                                        recv_32bit =
                                                            mcapi_sclchan_recv_uint32(mcapi_struct->scl_rx_handle,
                                                                                      &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_32bit != MCAPI_FTS_32BIT_SCALAR) )
                                                        {
                                                             mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    case MCAPID_TX_16_BIT_SCL:

                                                        recv_16bit =
                                                            mcapi_sclchan_recv_uint16(mcapi_struct->scl_rx_handle,
                                                                                      &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_16bit != MCAPI_FTS_16BIT_SCALAR) )
                                                        {
                                                             mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    case MCAPID_TX_8_BIT_SCL:

                                                        recv_8bit =
                                                            mcapi_sclchan_recv_uint8(mcapi_struct->scl_rx_handle,
                                                                                     &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_8bit != MCAPI_FTS_8BIT_SCALAR) )
                                                        {
                                                             mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    default:

                                                        break;
                                                }

                                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                                    break;
                                            }

                                            else
                                                break;
                                        }

                                        else
                                            break;
                                    }

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

        /* Delete the endpoint used in the connection. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_29_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_29_2
*
*   DESCRIPTION
*
*       Testing mcapi_pktchan_recv_uint64, mcapi_pktchan_recv_uint32,
*       mcapi_pktchan_recv_uint16, mcapi_pktchan_recv_uint8 - receive data
*       over closed connection - no data on endpoint when closed.
*
*       For each data size:
*
*           Node 0 – Create endpoint, open send side, wait for connection,
*                    close send side
*
*           Node 1 – Create endpoint, open receive side, get endpoint on
*                    Node 0, open connection, wait for data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_29_2)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp, rx_endp;
    mcapi_request_t             request;
    int                         i;
    mcapi_uint64_t              recv_64bit;
    mcapi_uint32_t              recv_32bit;
    mcapi_uint16_t              recv_16bit;
    mcapi_uint8_t               recv_8bit;

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
                /* Indicate that the endpoint should be opened as a sender. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                           1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for a response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* If the receive side was opened. */
                    if (mcapi_struct->status ==MGC_MCAPI_ERR_NOT_CONNECTED)
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
                                    /* Wait for the open to return successfully. */
                                    mcapi_wait(&request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Tell the other side to close the send side. */
                                    mcapi_struct->status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_CLOSE_TX_SIDE_SCL,
                                                               1024, mcapi_struct->local_endp,
                                                               0, MCAPI_DEFAULT_PRIO);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the response. */
                                        mcapi_struct->status =
                                            MCAPID_RX_Mgmt_Response(mcapi_struct);
                                    }

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Test each scalar size. */
                                        for (i = MCAPID_TX_64_BIT_SCL; i <= MCAPID_TX_8_BIT_SCL; i ++)
                                        {
                                            /* Receive the proper scalar size. */
                                            switch (i)
                                            {
                                                case MCAPID_TX_64_BIT_SCL:

                                                    recv_64bit =
                                                        mcapi_sclchan_recv_uint64(mcapi_struct->scl_rx_handle,
                                                                                  &mcapi_struct->status);

                                                    /* If success was returned with the wrong value,
                                                     * set an error.
                                                     */
                                                    if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                         (recv_64bit != MCAPI_FTS_64BIT_SCALAR) )
                                                    {
                                                        mcapi_struct->status = -1;
                                                    }

                                                    break;

                                                case MCAPID_TX_32_BIT_SCL:

                                                    recv_32bit =
                                                        mcapi_sclchan_recv_uint32(mcapi_struct->scl_rx_handle,
                                                                                  &mcapi_struct->status);

                                                    /* If success was returned with the wrong value,
                                                     * set an error.
                                                     */
                                                    if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                         (recv_32bit != MCAPI_FTS_32BIT_SCALAR) )
                                                    {
                                                        mcapi_struct->status = -1;
                                                    }

                                                    break;

                                                case MCAPID_TX_16_BIT_SCL:

                                                    recv_16bit =
                                                        mcapi_sclchan_recv_uint16(mcapi_struct->scl_rx_handle,
                                                                                  &mcapi_struct->status);

                                                    /* If success was returned with the wrong value,
                                                     * set an error.
                                                     */
                                                    if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                         (recv_16bit != MCAPI_FTS_16BIT_SCALAR) )
                                                    {
                                                        mcapi_struct->status = -1;
                                                    }

                                                    break;

                                                case MCAPID_TX_8_BIT_SCL:

                                                    recv_8bit =
                                                        mcapi_sclchan_recv_uint8(mcapi_struct->scl_rx_handle,
                                                                                 &mcapi_struct->status);

                                                    /* If success was returned with the wrong value,
                                                     * set an error.
                                                     */
                                                    if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                         (recv_8bit != MCAPI_FTS_8BIT_SCALAR) )
                                                    {
                                                        mcapi_struct->status = -1;
                                                    }

                                                    break;

                                                default:

                                                    break;
                                            }

                                            /* An error should have been returned. */
                                            if (mcapi_struct->status == MCAPI_ERR_CHAN_INVALID)
                                            {
                                                mcapi_struct->status = MCAPI_SUCCESS;
                                            }

                                            else
                                                break;
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

} /* MCAPI_FTS_Tx_2_29_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_29_3
*
*   DESCRIPTION
*
*       Testing mcapi_sclchan_recv_uint64, mcapi_sclchan_recv_uint32,
*       mcapi_sclchan_recv_uint16, mcapi_sclhan_recv_uint8 - receive data
*       over closed connection - data on endpoint when closed.
*
*       For each scalar size:
*
*           Node 0 – Create endpoint, open send side, wait for connection,
*                    send data, close send side
*
*           Node 1 – Create endpoint, open receive side, get endpoint on
*                    Node 0, open connection, wait for data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_29_3)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp, rx_endp;
    mcapi_request_t             request;
    int                         i;
    mcapi_uint64_t              recv_64bit;
    mcapi_uint32_t              recv_32bit;
    mcapi_uint16_t              recv_16bit;
    mcapi_uint8_t               recv_8bit;

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
                /* Test each scalar size. */
                for (i = MCAPID_TX_64_BIT_SCL; i <= MCAPID_TX_8_BIT_SCL; i ++)
                {
                    /* Indicate that the endpoint should be opened as a sender. */
                    mcapi_struct->status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                               1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                        /* If the receive side was opened. */
                        if (mcapi_struct->status ==MGC_MCAPI_ERR_NOT_CONNECTED)
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
                                    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                              rx_endp, &request,
                                                              &mcapi_struct->status);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the open to return successfully. */
                                        mcapi_wait(&request, &rx_len,
                                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                        /* Tell the other side to send some data. */
                                        mcapi_struct->status =
                                            MCAPID_TX_Mgmt_Message(mcapi_struct, i, 1024,
                                                                   mcapi_struct->local_endp,
                                                                   0, MCAPI_DEFAULT_PRIO);

                                        if (mcapi_struct->status == MCAPI_SUCCESS)
                                        {
                                            /* Wait for the response. */
                                            mcapi_struct->status =
                                                MCAPID_RX_Mgmt_Response(mcapi_struct);

                                            if (mcapi_struct->status == MCAPI_SUCCESS)
                                            {
                                                /* Tell the other side to close the send side. */
                                                mcapi_struct->status =
                                                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1024,
                                                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
                                            }

                                            if (mcapi_struct->status == MCAPI_SUCCESS)
                                            {
                                                /* Wait for the response. */
                                                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                            }

                                            if (mcapi_struct->status == MCAPI_SUCCESS)
                                            {
                                                /* Receive the proper scalar size. */
                                                switch (i)
                                                {
                                                    case MCAPID_TX_64_BIT_SCL:

                                                        recv_64bit =
                                                            mcapi_sclchan_recv_uint64(mcapi_struct->scl_rx_handle,
                                                                                      &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_64bit != MCAPI_FTS_64BIT_SCALAR) )
                                                        {
                                                            mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    case MCAPID_TX_32_BIT_SCL:

                                                        recv_32bit =
                                                            mcapi_sclchan_recv_uint32(mcapi_struct->scl_rx_handle,
                                                                                      &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_32bit != MCAPI_FTS_32BIT_SCALAR) )
                                                        {
                                                            mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    case MCAPID_TX_16_BIT_SCL:

                                                        recv_16bit =
                                                            mcapi_sclchan_recv_uint16(mcapi_struct->scl_rx_handle,
                                                                                      &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_16bit != MCAPI_FTS_16BIT_SCALAR) )
                                                        {
                                                            mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    case MCAPID_TX_8_BIT_SCL:

                                                        recv_8bit =
                                                            mcapi_sclchan_recv_uint8(mcapi_struct->scl_rx_handle,
                                                                                     &mcapi_struct->status);

                                                        /* If success was returned with the wrong value,
                                                         * set an error.
                                                         */
                                                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                                                             (recv_8bit != MCAPI_FTS_8BIT_SCALAR) )
                                                        {
                                                            mcapi_struct->status = -1;
                                                        }

                                                        break;

                                                    default:

                                                        break;
                                                }

                                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                                    break;
                                            }

                                            else
                                                break;
                                        }

                                        else
                                            break;
                                    }

                                    /* Close the receive side. */
                                    mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                               &request, &status);
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

} /* MCAPI_FTS_Tx_2_29_3 */
