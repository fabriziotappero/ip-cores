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
*       MCAPI_FTS_Tx_2_28_1
*
*   DESCRIPTION
*
*       Testing mcapi_sclchan_send_uint64, mcapi_sclchan_send_uint32,
*       mcapi_sclchan_send_uint16, mcapi_sclchan_send_uint8 - send data
*       over open connection.
*
*       For each scalar size:
*
*           Node 0 – Create endpoint, open receive side, wait for data
*
*           Node 1 – Create endpoint, open send side, get endpoint on
*                    Node 0, issue connection, send data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_28_1)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            rx_endp;
    mcapi_request_t             request;
    int                         i;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Send a scalar of each size to the other side. */
    for (i = MCAPID_RX_64_BIT_SCL; i <= MCAPID_RX_8_BIT_SCL; i ++)
    {
        /* Tell the other side to receive the specified scalar size. */
        mcapi_struct->status = MCAPI_FTS_Specify_Scalar_Size(mcapi_struct, i);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Open the local endpoint as the sender. */
                mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                          mcapi_struct->local_endp,
                                          &request, &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the receive side endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, mcapi_struct->foreign_endp,
                                                 &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            mcapi_wait(&request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Send some data. */
                                switch (i)
                                {
                                    case MCAPID_RX_64_BIT_SCL:

                                        mcapi_sclchan_send_uint64(mcapi_struct->scl_tx_handle,
                                                                  MCAPI_FTS_64BIT_SCALAR,
                                                                  &mcapi_struct->status);

                                        break;

                                    case MCAPID_RX_32_BIT_SCL:

                                        mcapi_sclchan_send_uint32(mcapi_struct->scl_tx_handle,
                                                                  MCAPI_FTS_32BIT_SCALAR,
                                                                  &mcapi_struct->status);

                                        break;

                                    case MCAPID_RX_16_BIT_SCL:

                                        mcapi_sclchan_send_uint16(mcapi_struct->scl_tx_handle,
                                                                  MCAPI_FTS_16BIT_SCALAR,
                                                                  &mcapi_struct->status);

                                        break;

                                    case MCAPID_RX_8_BIT_SCL:

                                        mcapi_sclchan_send_uint8(mcapi_struct->scl_tx_handle,
                                                                 MCAPI_FTS_8BIT_SCALAR,
                                                                 &mcapi_struct->status);

                                        break;

                                    default:

                                        break;
                                }

                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                    break;
                            }

                            /* Close the send side. */
                            mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                       &request, &status);

                            /* Wait for the response that the other side has closed. */
                            status = MCAPID_RX_Mgmt_Response(mcapi_struct);
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

} /* MCAPI_FTS_Tx_2_28_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_28_2
*
*   DESCRIPTION
*
*       Testing mcapi_sclchan_send_uint64, mcapi_sclchan_send_uint32,
*       mcapi_sclchan_send_uint16, mcapi_sclchan_send_uint8 - send data
*       over closed connection.
*
*       For each scalar size:
*
*           Node 0 – Create endpoint, open receive side, wait for connection
*                    to open, close receive side
*
*           Node 1 – Create endpoint, open send side, get endpoint on
*                    Node 0, issue connection, send data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_28_2)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp, rx_endp;
    mcapi_request_t             request;
    int                         i;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An additional endpoint is required for this test. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Tell the other side to receive a bogus scalar size so the
         * receive side is opened.
         */
        mcapi_struct->status =
            MCAPI_FTS_Specify_Scalar_Size(mcapi_struct, 0xffffffff);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            /* An error should be returned since the scalar size was bogus. */
            if (mcapi_struct->status == -1)
            {
                /* Open the local endpoint as the sender. */
                mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                          tx_endp, &request,
                                          &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the receive side endpoint. */
                    rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, mcapi_struct->foreign_endp,
                                                 &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the send side to open. */
                            mcapi_wait(&request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the response that the other side has closed. */
                                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                /* Let the close request get processed. */
                                MCAPID_Sleep(1000);

                                for (i = MCAPID_RX_64_BIT_SCL; i <= MCAPID_RX_8_BIT_SCL; i ++)
                                {
                                    /* Send some data. */
                                    switch (i)
                                    {
                                        case MCAPID_RX_64_BIT_SCL:

                                            mcapi_sclchan_send_uint64(mcapi_struct->scl_tx_handle,
                                                                      MCAPI_FTS_64BIT_SCALAR,
                                                                      &mcapi_struct->status);

                                            break;

                                        case MCAPID_RX_32_BIT_SCL:

                                            mcapi_sclchan_send_uint32(mcapi_struct->scl_tx_handle,
                                                                      MCAPI_FTS_32BIT_SCALAR,
                                                                      &mcapi_struct->status);

                                            break;

                                        case MCAPID_RX_16_BIT_SCL:

                                            mcapi_sclchan_send_uint16(mcapi_struct->scl_tx_handle,
                                                                      MCAPI_FTS_16BIT_SCALAR,
                                                                      &mcapi_struct->status);

                                            break;

                                        case MCAPID_RX_8_BIT_SCL:

                                            mcapi_sclchan_send_uint8(mcapi_struct->scl_tx_handle,
                                                                     MCAPI_FTS_8BIT_SCALAR,
                                                                     &mcapi_struct->status);

                                            break;

                                        default:

                                            break;
                                    }

                                    if (mcapi_struct->status == MCAPI_ERR_CHAN_INVALID)
                                    {
                                        mcapi_struct->status = MCAPI_SUCCESS;
                                    }

                                    else
                                    {
                                        mcapi_struct->status = -1;
                                        break;
                                    }
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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_28_2 */
