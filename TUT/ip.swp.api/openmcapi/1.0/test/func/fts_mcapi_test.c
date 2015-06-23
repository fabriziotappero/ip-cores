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
*       MCAPI_FTS_Tx_2_33_1
*
*   DESCRIPTION
*
*       Testing mcapi_test while getting a foreign endpoint - endpoint
*       does not yet exist
*
*           Node 0 – Waits for get endpoint request, create endpoint
*
*           Node 1 – Issues get endpoint request, test for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    int                 deleted = 0;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Check the status. */
    finished = mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MCAPI_PENDING);
    general_assert(finished == MCAPI_FALSE);

    /* Indicate that the endpoint should be created in 500 milliseconds. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 500, MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    unsigned long start = MCAPID_Time();

    for (;;)
    {
        timeout_assert(start, 5);

        /* The wait call should return success eventually. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (finished == MCAPI_TRUE) &&
             (mcapi_struct->status == MCAPI_SUCCESS) )
        {
            /* Tell the other side to delete the endpoint. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);
            status_assert(mcapi_struct->status);
            deleted = 1;

            /* Wait for a response before releasing the mutex. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            break;
        }

        /* Let the other side create the endpoint. */
        MCAPID_Sleep(250);
    }

    if (!deleted)
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_2
*
*   DESCRIPTION
*
*       Testing mcapi_test while getting a foreign endpoint - endpoint
*       already exists
*
*           Node 0 – Create endpoint
*
*           Node 1 – Issues get endpoint request, test for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that the endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    /* Get the response. */
    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(mcapi_struct->status);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* This is an arbitrary wait to allow for the get_endpoint message
     * round trip. */
    MCAPID_Sleep(100);

    /* The test call should return success almost immediately. */
    finished = mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);
    status_assert(mcapi_struct->status);
    general_assert(finished == MCAPI_TRUE);

    /* Tell the other side to delete the endpoint. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    /* Wait for a response before releasing the mutex. */
    status = MCAPID_RX_Mgmt_Response(mcapi_struct);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_3
*
*   DESCRIPTION
*
*       Testing mcapi_test while getting a foreign endpoint - endpoint
*       does not yet exist and get operation is canceled
*
*           Node 0 – Waits for get endpoint request, create endpoint
*
*           Node 1 – Issues get endpoint request, cancel request, test
*                    for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that the endpoint should be created in 500 milliseconds. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                   mcapi_struct->local_endp, 500, MCAPI_DEFAULT_PRIO);

        /* Wait for a response. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Cancel the get operation. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            /* The wait call should return canceled immediately. */
            finished =
                mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

            if ( (finished == MCAPI_FALSE) &&
                 (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }

            /* Wait for the response that the endpoint has been created. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Ensure the endpoint was not updated. */
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

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_3 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_4
*
*   DESCRIPTION
*
*       Testing mcapi_test for completed transmission using
*       mcapi_msg_send_i.
*
*           Node 0 – Create an endpoint, wait for data
*
*           Node 1 – Issue get endpoint request, transmit data, check
*                    for completed transmission
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    unsigned char       buffer[MCAPID_MSG_LEN];
    size_t              rx_len;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Store the endpoint to which the other side should reply. */
    mcapi_put32((unsigned char*)buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET, mcapi_struct->local_endp);

    /* Send a message. */
    mcapi_msg_send_i(mcapi_struct->local_endp, mcapi_struct->foreign_endp,
                     buffer, MCAPID_MSG_LEN, 0, &mcapi_struct->request,
                     &mcapi_struct->status);

    /* Wait for a response. */
    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Test if the data was sent. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        /* If the test does not return success or the correct number of bytes
         * transmitted.
         */
        if ( (finished != MCAPI_TRUE) ||
             (mcapi_struct->status != MCAPI_SUCCESS) ||
             (rx_len != MCAPID_MSG_LEN) )
        {
            mcapi_struct->status = -1;
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_4 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_5
*
*   DESCRIPTION
*
*       Testing mcapi_test receiving data using mcapi_msg_recv_i -
*       incomplete.
*
*           Node 1 – Create endpoint, issue receive request, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_5)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Make the call to receive the data. */
    mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                     &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the data. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_PENDING) &&
             (finished == MCAPI_FALSE) )
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_5 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_6
*
*   DESCRIPTION
*
*       Testing mcapi_test receiving data using mcapi_msg_recv_i -
*       complete.
*
*           Node 0 - Create endpoint, wait for other side to issue call
*                    to receive data, send data to Node 1.
*
*           Node 1 – Create endpoint, issue receive request, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_6)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

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
            /* Make the call to receive the data. */
            mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                             &mcapi_struct->request, &mcapi_struct->status);

            /* Cause the other side to send data. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_TX_BLCK_MSG, 1024,
                                       mcapi_struct->local_endp, 1000, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Test for the data. */
                    finished =
                        mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

                    if ( (finished != MCAPI_TRUE) ||
                         (mcapi_struct->status != MCAPI_SUCCESS) )
                    {
                        mcapi_struct->status = -1;
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

} /* MCAPI_FTS_Tx_2_33_6 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_7
*
*   DESCRIPTION
*
*       Testing mcapi_test receiving data using mcapi_msg_recv_i -
*       call canceled.
*
*           Node 0 - Create endpoint, wait for other side to cancel call
*                    to receive data, send data to Node 1.
*
*           Node 1 – Create endpoint, issue receive request, cancel call,
*                    test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_7)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

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
            /* Make the call to receive the data. */
            mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                             &mcapi_struct->request, &mcapi_struct->status);

            /* Cancel the call. */
            mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

            /* Cause the other side to send data. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_TX_BLCK_MSG, 1024,
                                       mcapi_struct->local_endp, 1000, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Test for the data. */
                    finished =
                        mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

                    if ( (finished == MCAPI_FALSE) &&
                         (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
                    {
                        mcapi_struct->status = MCAPI_SUCCESS;
                    }

                    else
                    {
                        mcapi_struct->status = -1;
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

} /* MCAPI_FTS_Tx_2_33_7 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_8
*
*   DESCRIPTION
*
*       Testing mcapi_connect_pktchan_i - completed
*
*           Node 0 – Create an endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, issue
*                    connection, test for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_8)
{
    MCAPID_STRUCT           *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                  rx_len;
    mcapi_status_t          status;
    mcapi_endpoint_t        tx_endp, rx_endp;
    mcapi_boolean_t         finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for the test. */
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
                /* Get the foreign endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_pktchan_i(tx_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        unsigned long start = MCAPID_Time();

                        for (;;)
                        {
                            timeout_assert(start, 5);

                            /* The connect call will return successfully. */
                            finished =
                                mcapi_test(&mcapi_struct->request, &rx_len,
                                           &mcapi_struct->status);

                            if (finished == MCAPI_FALSE)
                            {
                                MCAPID_Sleep(250);
                            }

                            else
                            {
                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                {
                                    mcapi_struct->status = -1;
                                }

                                break;
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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_8 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_9
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_recv_i - incomplete
*
*           Node 1 – Create endpoint, open receive side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_9)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Check for completion. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_PENDING) &&
             (finished == MCAPI_FALSE) )
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        mcapi_cancel(&mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_9 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_10
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_10)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the foreign endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect two endpoints. */
                    mcapi_connect_pktchan_i(tx_endp, mcapi_struct->local_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        unsigned long start = MCAPID_Time();

                        /* Open the receive side. */
                        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        for (;;)
                        {
                            timeout_assert(start, 5);

                            /* Test for the completion. */
                            finished =
                                mcapi_test(&request, &rx_len, &mcapi_struct->status);

                            if (finished == MCAPI_FALSE)
                            {
                                MCAPID_Sleep(250);
                            }

                            else
                            {
                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                {
                                    mcapi_struct->status = -1;
                                }

                                break;
                            }
                        }

                        /* Close the receive side. */
                        mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                      &request, &status);
                    }
                }

                /* Tell the other side to close the send side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_10 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_11
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_recv_i - canceled
*
*           Node 1 – Create endpoint, open receive side, cancel, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_11)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cancel. */
        mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Check for completion. */
            finished =
                mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == MCAPI_FALSE) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_11 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_12
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_send_i - incomplete
*
*           Node 1 – Create endpoint, open send side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_12)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Check for completion. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_PENDING) &&
             (finished == MCAPI_FALSE) )
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        mcapi_cancel(&mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_12 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_13
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side.
*
*           Node 1 – Create endpoint, connect, open send side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_13)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the foreign endpoint. */
                rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect two endpoints. */
                    mcapi_connect_pktchan_i(mcapi_struct->local_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        unsigned long start = MCAPID_Time();

                        /* Open the send side. */
                        mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        for (;;)
                        {
                            timeout_assert(start, 5);

                            /* Test for the completion. */
                            finished =
                                mcapi_test(&request, &rx_len, &mcapi_struct->status);

                            if (finished == MCAPI_FALSE)
                            {
                                MCAPID_Sleep(250);
                            }

                            else
                            {
                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                {
                                    mcapi_struct->status = -1;
                                }

                                break;
                            }
                        }

                        /* Close the send side. */
                        mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                                      &request, &status);
                    }
                }

                /* Tell the other side to close the receive side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_RX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_13 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_14
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_send_i - canceled
*
*           Node 1 – Create endpoint, open send side, cancel, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_14)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cancel. */
        mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Check for completion. */
            finished =
                mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == MCAPI_FALSE) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_14 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_15
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side, wait for data.
*
*           Node 1 – Create endpoint, open send side, connect, send data,
*                    test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_15)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    char                buffer[MCAPID_MSG_LEN];
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Send some data. */
    mcapi_pktchan_send_i(mcapi_struct->pkt_tx_handle, buffer, MCAPID_MSG_LEN,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Check for completion. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (mcapi_struct->status != MCAPI_SUCCESS) || (rx_len != MCAPID_MSG_LEN) )
        {
            mcapi_struct->status = -1;
        }
    }

    /* Close the send side. */
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                  &mcapi_struct->request, &status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_15 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_16
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_recv_i - incomplete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_16)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;
    char                *buffer;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the foreign endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect two endpoints. */
                    mcapi_connect_pktchan_i(tx_endp, mcapi_struct->local_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the receive side. */
                        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        /* Wait for the receive side to open. */
                        mcapi_wait(&request, &rx_len, &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Issue a receive call. */
                            mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                                 (void**)&buffer, &mcapi_struct->request,
                                                 &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Test for the completion. */
                                finished = mcapi_test(&mcapi_struct->request, &rx_len,
                                                      &mcapi_struct->status);

                                if ( (finished == MCAPI_FALSE) &&
                                     (mcapi_struct->status == MCAPI_PENDING) )
                                {
                                    mcapi_struct->status = MCAPI_SUCCESS;
                                }

                                else
                                {
                                    mcapi_struct->status = -1;
                                }

                                /* Cancel the receive call. */
                                mcapi_cancel(&mcapi_struct->request, &status);
                            }

                            /* Close the receive side. */
                            mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                          &request, &status);
                        }
                    }
                }

                /* Tell the other side to close the send side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_16 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_17
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side, send data.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_17)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp, rx_endp;
    char                *buffer;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* This test requires an extra endpoint. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that a remote endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                   mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            /* If the endpoint was created. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the endpoint should be opened as a sender. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                /* Wait for the response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect two endpoints. */
                        mcapi_connect_pktchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Open the receive side. */
                            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                                      rx_endp, &request,
                                                      &mcapi_struct->status);

                            /* Wait for the receive side to open. */
                            mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                       MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Issue a receive call. */
                                mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                                     (void**)&buffer,
                                                     &mcapi_struct->request,
                                                     &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
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
                                            /* Test for the completion. */
                                            finished = mcapi_test(&mcapi_struct->request,
                                                                  &rx_len,
                                                                  &mcapi_struct->status);

                                            if ( (finished != MCAPI_TRUE) ||
                                                 (mcapi_struct->status != MCAPI_SUCCESS) )
                                            {
                                                mcapi_struct->status = -1;
                                            }

                                            /* The buffer must be freed. */
                                            else
                                            {
                                                mcapi_pktchan_free(buffer, &status);
                                            }
                                        }
                                    }
                                }

                                /* Close the receive side. */
                                mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                              &request, &status);
                            }
                        }
                    }

                    /* Tell the other side to close the send side. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                               MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                               1024, mcapi_struct->local_endp,
                                               0, MCAPI_DEFAULT_PRIO);

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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_17 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_18
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, cancel receive call, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_18)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp, rx_endp;
    char                *buffer;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* This test requires an extra endpoint. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that a remote endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                   mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            /* If the endpoint was created. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the endpoint should be opened as a sender. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                /* Wait for the response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect two endpoints. */
                        mcapi_connect_pktchan_i(tx_endp, rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Open the receive side. */
                            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                                      rx_endp, &request,
                                                      &mcapi_struct->status);

                            /* Wait for the receive side to open. */
                            mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                       MCAPI_FTS_TIMEOUT);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Issue a receive call. */
                                mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                                     (void**)&buffer,
                                                     &mcapi_struct->request,
                                                     &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Cancel the receive call. */
                                    mcapi_cancel(&mcapi_struct->request,
                                                 &mcapi_struct->status);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Test for the completion. */
                                        finished = mcapi_test(&mcapi_struct->request,
                                                              &rx_len,
                                                              &mcapi_struct->status);

                                        if ( (finished != MCAPI_FALSE) ||
                                             (mcapi_struct->status != MCAPI_ERR_REQUEST_CANCELLED) )
                                        {
                                            mcapi_struct->status = -1;
                                        }

                                        else
                                        {
                                            mcapi_struct->status = MCAPI_SUCCESS;
                                        }
                                    }
                                }

                                /* Close the receive side. */
                                mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                              &request, &status);
                            }
                        }
                    }

                    /* Tell the other side to close the send side. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                               MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                               1024, mcapi_struct->local_endp,
                                               0, MCAPI_DEFAULT_PRIO);

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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_18 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_19
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_recv_close_i - tx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open receive side, close receive
*                    side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_19)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                      &request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Test for the completion. */
            finished = mcapi_test(&request, &rx_len, &mcapi_struct->status);

            if ( (finished != MCAPI_TRUE) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_19 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_20
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_recv_close_i - tx opened,
*       not connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, open receive side, wait for Node 0 to
*                    open send side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_20)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the receive side. */
                mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                          mcapi_struct->local_endp,
                                          &mcapi_struct->request,
                                          &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Close the receive side. */
                    mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                  &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Test for the completion. */
                        finished = mcapi_test(&request, &rx_len,
                                              &mcapi_struct->status);

                        if ( (finished != MCAPI_TRUE) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
                        }
                    }
                }

                /* Tell the other side to close the send side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_20 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_21
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_recv_close_i - tx opened,
*       connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, issue connection, open receive side,
*                    test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_21)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the send side endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_pktchan_i(tx_endp, mcapi_struct->local_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection to open. */
                        mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                                   MCAPI_FTS_TIMEOUT);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side. */
                            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                                      mcapi_struct->local_endp,
                                                      &request, &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the receive side to open. */
                                mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                           MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Close the receive side. */
                                    mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                                  &request, &mcapi_struct->status);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Test for the completion. */
                                        finished = mcapi_test(&request, &rx_len,
                                                              &mcapi_struct->status);

                                        if ( (finished != MCAPI_TRUE) ||
                                             (mcapi_struct->status != MCAPI_SUCCESS) )
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                /* Tell the other side to close the send side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_21 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_22
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_close_i - rx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open send side, close send
*                    side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_22)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Close the send side. */
        mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                      &request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Test for the completion. */
            finished = mcapi_test(&request, &rx_len, &mcapi_struct->status);

            if ( (finished != MCAPI_TRUE) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_22 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_23
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_close_i - rx opened,
*       not connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, open send side, wait for Node 0 to
*                    open receive side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_23)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the send side. */
                mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                          mcapi_struct->local_endp,
                                          &mcapi_struct->request,
                                          &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Close the send side. */
                    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                                  &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Test for the completion. */
                        finished = mcapi_test(&request, &rx_len,
                                              &mcapi_struct->status);

                        if ( (finished != MCAPI_TRUE) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
                        }
                    }
                }

                /* Tell the other side to close the receive side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_RX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_23 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_24
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_close_i - rx opened,
*       connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, issue connection, open send side,
*                    test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_24)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the receive side endpoint. */
                rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_pktchan_i(mcapi_struct->local_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection to open. */
                        mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                                   MCAPI_FTS_TIMEOUT);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the send side. */
                            mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                                      mcapi_struct->local_endp,
                                                      &request, &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the send side to open. */
                                mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                           MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Close the send side. */
                                    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                                                  &request, &mcapi_struct->status);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Test for the completion. */
                                        finished = mcapi_test(&request, &rx_len,
                                                              &mcapi_struct->status);

                                        if ( (finished != MCAPI_TRUE) ||
                                             (mcapi_struct->status != MCAPI_SUCCESS) )
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                /* Tell the other side to close the receive side. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                           MCAPID_MGMT_CLOSE_RX_SIDE_PKT,
                                           1024, mcapi_struct->local_endp,
                                           0, MCAPI_DEFAULT_PRIO);

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

} /* MCAPI_FTS_Tx_2_33_24 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_25
*
*   DESCRIPTION
*
*       Testing mcapi_connect_sclchan_i - completed
*
*           Node 0 – Create an endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, issue
*                    connection, test for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_25)
{
    MCAPID_STRUCT           *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                  rx_len;
    mcapi_status_t          status;
    mcapi_endpoint_t        tx_endp, rx_endp;
    mcapi_boolean_t         finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for the test. */
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
                /* Get the foreign endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_sclchan_i(tx_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        unsigned long start = MCAPID_Time();

                        for (;;)
                        {
                            timeout_assert(start, 5);

                            /* The connect call will return successfully. */
                            finished =
                                mcapi_test(&mcapi_struct->request, &rx_len,
                                           &mcapi_struct->status);

                            if (finished == MCAPI_FALSE)
                            {
                                MCAPID_Sleep(250);
                            }

                            else
                            {
                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                {
                                    mcapi_struct->status = -1;
                                }

                                break;
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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_25 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_26
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_recv_i - incomplete
*
*           Node 1 – Create endpoint, open receive side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_26)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Check for completion. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_PENDING) &&
             (finished == MCAPI_FALSE) )
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        mcapi_cancel(&mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_26 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_27
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_27)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the foreign endpoint. */
                tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect two endpoints. */
                    mcapi_connect_sclchan_i(tx_endp, mcapi_struct->local_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        unsigned long start = MCAPID_Time();

                        /* Open the receive side. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        for (;;)
                        {
                            timeout_assert(start, 5);

                            /* Test for the completion. */
                            finished =
                                mcapi_test(&request, &rx_len, &mcapi_struct->status);

                            if (finished == MCAPI_FALSE)
                            {
                                MCAPID_Sleep(250);
                            }

                            else
                            {
                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                {
                                    mcapi_struct->status = -1;
                                }

                                break;
                            }
                        }

                        /* Close the receive side. */
                        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                   &request, &status);
                    }
                }

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

} /* MCAPI_FTS_Tx_2_33_27 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_28
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_recv_i - canceled
*
*           Node 1 – Create endpoint, open receive side, cancel, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_28)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cancel. */
        mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Check for completion. */
            finished =
                mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == MCAPI_FALSE) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_28 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_29
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_send_i - incomplete
*
*           Node 1 – Create endpoint, open send side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_29)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Check for completion. */
        finished =
            mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_PENDING) &&
             (finished == MCAPI_FALSE) )
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        mcapi_cancel(&mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_29 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_30
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side.
*
*           Node 1 – Create endpoint, connect, open send side, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_30)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Get the foreign endpoint. */
                rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect two endpoints. */
                    mcapi_connect_sclchan_i(mcapi_struct->local_endp, rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        unsigned long start = MCAPID_Time();

                        /* Open the send side. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        for (;;)
                        {
                            timeout_assert(start, 5);

                            /* Test for the completion. */
                            finished =
                                mcapi_test(&request, &rx_len, &mcapi_struct->status);

                            if (finished == MCAPI_FALSE)
                            {
                                MCAPID_Sleep(250);
                            }

                            else
                            {
                                if (mcapi_struct->status != MCAPI_SUCCESS)
                                {
                                    mcapi_struct->status = -1;
                                }

                                break;
                            }
                        }

                        /* Close the send side. */
                        mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                   &request, &status);
                    }
                }

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

} /* MCAPI_FTS_Tx_2_33_30 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_31
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_send_i - canceled
*
*           Node 1 – Create endpoint, open send side, cancel, test for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_31)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cancel. */
        mcapi_cancel(&mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Check for completion. */
            finished =
                mcapi_test(&mcapi_struct->request, &rx_len, &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == MCAPI_FALSE) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_31 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_32
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_sclchan_recv_close_i - tx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open receive side, close receive
*                    side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_32)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                   &request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Test for the completion. */
            finished = mcapi_test(&request, &rx_len, &mcapi_struct->status);

            if ( (finished != MCAPI_TRUE) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_32 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_33
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_sclchan_recv_close_i - tx opened,
*       not connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, open receive side, wait for Node 0 to
*                    open send side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_33)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the receive side. */
                mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                          mcapi_struct->local_endp,
                                          &mcapi_struct->request,
                                          &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Close the receive side. */
                    mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                               &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Test for the completion. */
                        finished = mcapi_test(&request, &rx_len,
                                              &mcapi_struct->status);

                        if ( (finished != MCAPI_TRUE) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
                        }
                    }
                }

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

} /* MCAPI_FTS_Tx_2_33_33 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_34
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_sclchan_recv_close_i - tx opened,
*       connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, issue connection, open receive side,
*                    test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_34)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

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
                        /* Wait for the connection to open. */
                        mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                                   MCAPI_FTS_TIMEOUT);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      mcapi_struct->local_endp,
                                                      &request, &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the receive side to open. */
                                mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                           MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Close the receive side. */
                                    mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                               &request, &mcapi_struct->status);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Test for the completion. */
                                        finished = mcapi_test(&request, &rx_len,
                                                              &mcapi_struct->status);

                                        if ( (finished != MCAPI_TRUE) ||
                                             (mcapi_struct->status != MCAPI_SUCCESS) )
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

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

} /* MCAPI_FTS_Tx_2_33_34 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_35
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_sclchan_send_close_i - rx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open send side, close send
*                    side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_35)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Close the send side. */
        mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                   &request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Test for the completion. */
            finished = mcapi_test(&request, &rx_len, &mcapi_struct->status);

            if ( (finished != MCAPI_TRUE) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_33_35 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_36
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_sclchan_send_close_i - rx opened,
*       not connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, open send side, wait for Node 0 to
*                    open receive side, test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_36)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the send side. */
                mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                          mcapi_struct->local_endp,
                                          &mcapi_struct->request,
                                          &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Close the send side. */
                    mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                               &request, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Test for the completion. */
                        finished = mcapi_test(&request, &rx_len,
                                              &mcapi_struct->status);

                        if ( (finished != MCAPI_TRUE) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
                        }
                    }
                }

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

} /* MCAPI_FTS_Tx_2_33_36 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_33_37
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_sclchan_send_close_i - rx opened,
*       connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, issue connection, open send side,
*                    test for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_33_37)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that a remote endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                               mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        /* If the endpoint was created. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be opened as a receiver. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                       1024, mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            /* Wait for the response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

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
                        /* Wait for the connection to open. */
                        mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                                   MCAPI_FTS_TIMEOUT);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the send side. */
                            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                      mcapi_struct->local_endp,
                                                      &request, &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Wait for the send side to open. */
                                mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                           MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Close the send side. */
                                    mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                               &request, &mcapi_struct->status);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Test for the completion. */
                                        finished = mcapi_test(&request, &rx_len,
                                                              &mcapi_struct->status);

                                        if ( (finished != MCAPI_TRUE) ||
                                             (mcapi_struct->status != MCAPI_SUCCESS) )
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

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

} /* MCAPI_FTS_Tx_2_33_37 */
