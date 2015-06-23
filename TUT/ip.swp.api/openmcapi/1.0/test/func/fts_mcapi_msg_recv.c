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
*       MCAPI_FTS_Tx_2_11_1
*
*   DESCRIPTION
*
*       Testing mcapi_msg_recv for each priority:
*
*           Node 1 – Create an endpoint, indicate to Node 0 to transmit
*                    data with a specific priority, issue a receive call on
*                    the endpoint
*
*           Node 0 – Transmit data using the indicated priority to the
*                    target endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_11_1)
{
    int                 i;
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created for sending data
     * to this node.
     */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    /* Wait for a response. */
    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(mcapi_struct->status);

    /* If the endpoint was created. */
    /* Traverse through all priorities. */
    for (i = 0; i < MCAPI_PRIO_COUNT; i ++)
    {
        /* Issue a NO OP call with a 1000 millisecond pause to cause
         * the other side to cause Node 0 to send just an ACK.
         */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                   mcapi_struct->local_endp, 1000, i);
        status_assert(mcapi_struct->status);

        /* Wait for the ACK. */
        mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                       &rx_len, &mcapi_struct->status);
        status_assert(mcapi_struct->status);
    }

    /* Tell the other side to delete the endpoint. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
    status_assert(status);

    /* Wait for the response. */
    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_11_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_11_2
*
*   DESCRIPTION
*
*       Testing mcapi_msg_recv with receive length too small.
*
*           Node 1 – Transmit data to Node 1
*
*           Node 0 – Create an endpoint, indicate to Node 0 to transmit
*                    data, issue a receive call on the endpoint specifying
*                    too small a receive buffer size
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_11_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created for sending data
     * to this node.
     */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    /* Wait for a response. */
    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Issue a NO OP to cause the other side to send one packet only. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the ACK specifying too small a buffer size to
                 * receive the data.
                 */
                mcapi_msg_recv(mcapi_struct->local_endp, buffer, 1, &rx_len,
                               &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_ERR_MSG_TRUNCATED)
                {
                    mcapi_struct->status = MCAPI_SUCCESS;
                }

                else
                {
                    mcapi_struct->status = -1;
                }

                /* Receive the buffer. */
                mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                               &rx_len, &status);
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

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_11_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_11_3
*
*   DESCRIPTION
*
*       Testing mcapi_msg_recv blocking for data to become available.
*
*           Node 1 – Wait for Node 1 to issue the receive request, transmit
*                    data to Node 1
*
*           Node 0 – Create an endpoint, indicate to Node 0 to transmit
*                    data in 1000 ms, issue a receive call on the endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_11_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created for sending data
     * to this node.
     */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    /* Wait for a response. */
    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Issue a NO OP to cause one message to be sent only. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 1000,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the data. */
                mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                               &rx_len, &mcapi_struct->status);
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

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_11_3 */
