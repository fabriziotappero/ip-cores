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
*       MCAPI_FTS_Tx_2_10_1
*
*   DESCRIPTION
*
*       Testing mcapi_msg_send for each priority:
*
*           Node 0 – Create an endpoint
*           Node 1 – Issue get endpoint request, then transmit data using
*           each supported priority to the target endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_10_1)
{
    int                 i;
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MSG_LEN];
    size_t              rx_len;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Store the endpoint to which the other side should reply. */
    mcapi_put32((unsigned char*)buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET, mcapi_struct->local_endp);

    /* Traverse through all the priorities. */
    for (i = 0; i < MCAPI_PRIO_COUNT; i++)
    {
        /* Send a message. */
        mcapi_msg_send(mcapi_struct->local_endp, mcapi_struct->foreign_endp,
                       buffer, MCAPID_MSG_LEN, i, &mcapi_struct->status);

        /* Wait for a response. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MSG_LEN,
                           &rx_len, &mcapi_struct->status);

            if (mcapi_struct->status != MCAPI_SUCCESS)
            {
                break;
            }
        }

        else
        {
            break;
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_10_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_10_2
*
*   DESCRIPTION
*
*       Testing mcapi_msg_send for each priority to a closed receive
*       endpoint:
*
*           Node 0 – Create an endpoint, then close it after the other
*                    side has issued successful get request
*           Node 1 – Issue get endpoint request, then transmit data
*                    using each supported priority to the target endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_10_2)
{
    int                 i;
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that the endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    /* Wait for a response. */
    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Get the endpoint. */
            endpoint = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Tell the other side to delete the endpoint. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Traverse through all the priorities. */
                        for (i = 0; i < MCAPI_PRIO_COUNT; i++)
                        {
                            /* Send a message to a closed endpoint. */
                            mcapi_msg_send(mcapi_struct->local_endp, endpoint,
                                           buffer, MCAPID_MGMT_PKT_LEN, i, &status);

                            /* Make the call to receive data. */
                            mcapi_msg_recv_i(mcapi_struct->local_endp, buffer,
                                             MCAPID_MGMT_PKT_LEN, &mcapi_struct->request,
                                             &status);

                            /* No data should be received. */
                            mcapi_wait(&mcapi_struct->request, &rx_len, &status, MCAPI_FTS_TIMEOUT);

                            if (status != MCAPI_TIMEOUT)
                            {
                                mcapi_struct->status = -1;
                                break;
                            }

                            mcapi_cancel(&mcapi_struct->request, &status);
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

} /* MCAPI_FTS_Tx_2_10_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_10_3
*
*   DESCRIPTION
*
*       Testing mcapi_msg_send when no buffers remain in the system
*       for transmission.
*
*           Node 0 – Create an endpoint, send enough data to Node 1 to
*           exhaust all receive buffers
*
*           Node 1 – Create an endpoint, issue get endpoint request for
*           Node 0, wait for all buffers to be used up, attempt to
*           retransmit a message to Node 0
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_10_3)
{
    int                 i, j;
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MSG_LEN];
    mcapi_status_t      status;
    size_t              rx_len;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that the endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    /* Wait for a response. */
    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(mcapi_struct->status);

    /* If the endpoint was created. */
    for (i = 0; i < TEST_BUF_COUNT; i ++)
    {
        /* Issue a NO OP to cause the other side to send an ACK. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                   mcapi_struct->local_endp, 0,
                                   MCAPI_DEFAULT_PRIO);
        if (mcapi_struct->status != MCAPI_SUCCESS)
        {
            break;
        }
    }

    /* Try to send a buffer of data. */
    mcapi_msg_send(mcapi_struct->local_endp, mcapi_struct->foreign_endp,
                   buffer, MCAPID_MSG_LEN, MCAPI_DEFAULT_PRIO,
                   &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MCAPI_ERR_TRANSMISSION);

    /* Receive all the pending data. */
    for (j = 0; j < i; j ++)
    {
        mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MSG_LEN,
                         &mcapi_struct->request, &status);
        status_assert(status);

        /* Wait for data. */
        mcapi_wait(&mcapi_struct->request, &rx_len, &status, MCAPI_FTS_TIMEOUT);
        status_assert(status);
    }

    /* Tell the other side to delete the endpoint. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
    status_assert(status);

    /* Wait for a response before releasing the mutex. */
    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_10_3 */
