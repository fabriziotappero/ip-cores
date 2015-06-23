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
*       MCAPI_FTS_Tx_2_35_1
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any while getting a foreign endpoint - timeout
*       occurs before endpoint created
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, 250,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_TIMEOUT)
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        /* Cancel the request. */
        mcapi_cancel(&mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_2
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any while getting a foreign endpoint - request
*       canceled
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion, request canceled.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that the request should be canceled in 1000 milliseconds. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                   mcapi_struct->local_endp, 1000,
                                   MCAPI_DEFAULT_PRIO);

        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                  &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
             (finished == 0) )
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        /* Wait for a response that the cancel was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (status != MCAPI_SUCCESS)
        {
            mcapi_struct->status = -1;
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_3
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any while getting a foreign endpoint - endpoint
*       retrieved
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

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
                                   mcapi_struct->local_endp, 500,
                                   MCAPI_DEFAULT_PRIO);

        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                  &mcapi_struct->status);

        if ( (finished != 0) ||
             (mcapi_struct->status != MCAPI_SUCCESS) )
        {
            mcapi_struct->status = -1;
        }

        /* Wait for a response that the creation was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be deleted. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was deleted. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_3 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_4
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any while getting a foreign endpoint - endpoint
*       retrieved, two requests outstanding
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request to Node 0, issue a second
*                    get from another thread, wait for completion by both
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    mcapi_endpoint_t    endpoint = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

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

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &svc_struct.request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Indicate that the thread should suspend on the request. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_WAIT_REQUEST, 0,
                                   svc_struct.local_endp, 0,
                                   MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be created in 1000 milliseconds. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                       mcapi_struct->local_endp, 1000,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                req_ptr[0] = &svc_struct.request;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (finished != 0) ||
                     (mcapi_struct->status != MCAPI_SUCCESS) )
                {
                    mcapi_struct->status = -1;
                }

                /* Wait for a response that the wait was successful. */
                status = MCAPID_RX_Mgmt_Response(&svc_struct);

                /* Wait for a response that the creation was successful. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (status == MCAPI_SUCCESS)
                {
                    /* Indicate that the endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response that the endpoint was deleted. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
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

} /* MCAPI_FTS_Tx_2_35_4 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_5
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any for completed transmission using
*       mcapi_msg_send_i.
*
*           Node 0 – Create an endpoint, wait for data
*
*           Node 1 – Issue get endpoint request, transmit data, wait
*                    for completed transmission
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_5)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MSG_LEN];
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

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
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                  &mcapi_struct->status);

        /* If the test does not return success or the correct number of bytes
         * transmitted.
         */
        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_5 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_6
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any receiving data using mcapi_msg_recv_i -
*       incomplete.
*
*           Node 1 – Create endpoint, issue receive request, wait for
*                    timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_6)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Make the call to receive the data. */
    mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                     &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, 250,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_TIMEOUT)
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

} /* MCAPI_FTS_Tx_2_35_6 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_7
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any receiving data using mcapi_msg_recv_i -
*       complete.
*
*           Node 0 - Create endpoint, wait for other side to issue call
*                    to receive data, send data to Node 1.
*
*           Node 1 – Create endpoint, issue receive request, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_7)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

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
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 1000, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                req_ptr[0] = &mcapi_struct->request;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (finished != 0) ||
                     (mcapi_struct->status != MCAPI_SUCCESS) )
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
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_7 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_8
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any receiving data using mcapi_msg_recv_i -
*       call canceled.
*
*           Node 0 - Create endpoint, wait for other side to cancel call
*                    to receive data, send data to Node 1.
*
*           Node 1 – Create endpoint, issue receive request, cancel call,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_8)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

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
                             &svc_struct.request, &mcapi_struct->status);

            /* Cause the call to be canceled. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                       svc_struct.local_endp, 1000, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                req_ptr[0] = &svc_struct.request;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (finished == 0) &&
                     (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
                {
                    mcapi_struct->status = MCAPI_SUCCESS;
                }

                else
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
                /* Wait for the response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_8 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_9
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_connect_pktchan_i - completed
*
*           Node 0 – Create an endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, issue
*                    connection, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_9)
{
    MCAPID_STRUCT           *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                  rx_len;
    mcapi_status_t          status;
    mcapi_endpoint_t        tx_endp, rx_endp;
    mcapi_boolean_t         finished;
    mcapi_request_t         *req_ptr[1];

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
                        req_ptr[0] = &mcapi_struct->request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_9 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_10
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_pktchan_recv_i - timed out
*
*           Node 1 – Create endpoint, open receive side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_10)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, 250,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_TIMEOUT)
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

} /* MCAPI_FTS_Tx_2_35_10 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_11
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_11)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;
    mcapi_request_t     *req_ptr[1];

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

                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
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

} /* MCAPI_FTS_Tx_2_35_11 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_12
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_pktchan_recv_i - canceled
*
*           Node 1 – Create endpoint, open receive side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_12)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set up the structure for getting the local management server. */
    svc_struct.type = MCAPI_MSG_TX_TYPE;
    svc_struct.local_port = MCAPI_PORT_ANY;
    svc_struct.node = FUNC_FRONTEND_NODE_ID;
    svc_struct.service = "lcl_mgmt";
    svc_struct.thread_entry = MCAPI_NULL;

    /* Create the client service that will cancel the call. */
    MCAPID_Create_Service(&svc_struct);

    /* Open the receive side. */
    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                              mcapi_struct->local_endp,
                              &svc_struct.request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cause the call to be canceled in 1 second. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                   svc_struct.local_endp, 1000, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &svc_struct.request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == 0) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_12 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_13
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_pktchan_send_i - timed out
*
*           Node 1 – Create endpoint, open send side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_13)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, 250,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_TIMEOUT)
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

} /* MCAPI_FTS_Tx_2_35_13 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_14
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_pktchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side.
*
*           Node 1 – Create endpoint, connect, open send side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_14)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;
    mcapi_request_t     *req_ptr[1];

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
                        /* Open the send side. */
                        mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
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

} /* MCAPI_FTS_Tx_2_35_14 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_15
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_pktchan_send_i - canceled
*
*           Node 1 – Create endpoint, open send side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_15)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set up the structure for getting the local management server. */
    svc_struct.type = MCAPI_MSG_TX_TYPE;
    svc_struct.local_port = MCAPI_PORT_ANY;
    svc_struct.node = FUNC_FRONTEND_NODE_ID;
    svc_struct.service = "lcl_mgmt";
    svc_struct.thread_entry = MCAPI_NULL;

    /* Create the client service that will cancel the call. */
    MCAPID_Create_Service(&svc_struct);

    /* Open the send side. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              mcapi_struct->local_endp,
                              &svc_struct.request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cause the call to be canceled in 1 second. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                   svc_struct.local_endp, 1000, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &svc_struct.request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == 0) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_15 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_16
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side, wait for data.
*
*           Node 1 – Create endpoint, open send side, connect, send data,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_16)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    char                buffer[MCAPID_MSG_LEN];
    mcapi_status_t      status;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Send some data. */
    mcapi_pktchan_send_i(mcapi_struct->pkt_tx_handle, buffer, MCAPID_MSG_LEN,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                  &mcapi_struct->status);

        if ( (finished != 0) ||
             (mcapi_struct->status != MCAPI_SUCCESS) ||
             (rx_len != MCAPID_MSG_LEN) )
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

} /* MCAPI_FTS_Tx_2_35_16 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_17
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_i - timed out
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_17)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;
    char                *buffer;
    mcapi_request_t     *req_ptr[1];

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
                                req_ptr[0] = &mcapi_struct->request;

                                /* Wait for the call to timeout. */
                                finished = mcapi_wait_any(1, req_ptr,
                                                          &rx_len, 250,
                                                          &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_TIMEOUT)
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

} /* MCAPI_FTS_Tx_2_35_17 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_18
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side, send data.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_18)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp, rx_endp;
    char                *buffer;
    mcapi_request_t     *req_ptr[1];

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
                                                               1000, MCAPI_DEFAULT_PRIO);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the response. */
                                        mcapi_struct->status =
                                            MCAPID_RX_Mgmt_Response(mcapi_struct);

                                        if (mcapi_struct->status == MCAPI_SUCCESS)
                                        {
                                            req_ptr[0] = &mcapi_struct->request;

                                            /* Wait for the call to timeout. */
                                            finished = mcapi_wait_any(1,
                                                                      req_ptr,
                                                                      &rx_len,
                                                                      MCAPI_FTS_TIMEOUT,
                                                                      &mcapi_struct->status);

                                            if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_18 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_19
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_i - canceled
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, cancel receive call, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_19)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp, rx_endp;
    char                *buffer;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set up the structure for getting the local management server. */
    svc_struct.type = MCAPI_MSG_TX_TYPE;
    svc_struct.local_port = MCAPI_PORT_ANY;
    svc_struct.node = FUNC_FRONTEND_NODE_ID;
    svc_struct.service = "lcl_mgmt";
    svc_struct.thread_entry = MCAPI_NULL;

    /* Create the client service that will cancel the call. */
    MCAPID_Create_Service(&svc_struct);

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
                                                     &svc_struct.request,
                                                     &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Cause the call to be canceled in 1 second. */
                                    mcapi_struct->status =
                                        MCAPID_TX_Mgmt_Message(&svc_struct,
                                                               MCAPID_CANCEL_REQUEST, 0,
                                                               svc_struct.local_endp, 1000,
                                                               MCAPI_DEFAULT_PRIO);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        req_ptr[0] = &svc_struct.request;

                                        /* Wait for the call to timeout. */
                                        finished = mcapi_wait_any(1, req_ptr,
                                                                  &rx_len,
                                                                  MCAPI_FTS_TIMEOUT,
                                                                  &mcapi_struct->status);

                                        if ( (finished != 0) ||
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

    /* Destroy the client service that will cancel the call. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_19 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_20
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_close_i - tx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open receive side, close receive
*                    side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_20)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
            req_ptr[0] = &request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_20 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_21
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_close_i - tx opened,
*       not connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, open receive side, wait for Node 0 to
*                    open send side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_21)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_21 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_22
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_close_i - tx opened,
*       connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, issue connection, open receive side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_22)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;
    mcapi_request_t     *req_ptr[1];

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
                                        req_ptr[0] = &request;

                                        /* Wait for the call to timeout. */
                                        finished = mcapi_wait_any(1, req_ptr,
                                                                  &rx_len,
                                                                  MCAPI_FTS_TIMEOUT,
                                                                  &mcapi_struct->status);

                                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_22 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_23
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_send_close_i - rx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open send side, close send
*                    side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_23)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
            req_ptr[0] = &request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_23 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_24
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_send_close_i - rx opened,
*       not connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, open send side, wait for Node 0 to
*                    open receive side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_24)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_24 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_25
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_send_close_i - rx opened,
*       connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, issue connection, open send side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_25)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;
    mcapi_request_t     *req_ptr[1];

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
                                        req_ptr[0] = &request;

                                        /* Wait for the call to timeout. */
                                        finished = mcapi_wait_any(1, req_ptr,
                                                                  &rx_len,
                                                                  MCAPI_FTS_TIMEOUT,
                                                                  &mcapi_struct->status);

                                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_25 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_26
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_connect_sclchan_i - completed
*
*           Node 0 – Create an endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, issue
*                    connection, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_26)
{
    MCAPID_STRUCT           *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                  rx_len;
    mcapi_status_t          status;
    mcapi_endpoint_t        tx_endp, rx_endp;
    mcapi_boolean_t         finished;
    mcapi_request_t         *req_ptr[1];

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
                        req_ptr[0] = &mcapi_struct->request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_26 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_27
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_sclchan_recv_i - timed out
*
*           Node 1 – Create endpoint, open receive side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_27)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the receive side. */
    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, 250,
                                  &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
             (finished == 0) )
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

} /* MCAPI_FTS_Tx_2_35_27 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_28
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_sclchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_28)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;
    mcapi_request_t     *req_ptr[1];

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
                        /* Open the receive side. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
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

} /* MCAPI_FTS_Tx_2_35_28 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_29
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_sclchan_recv_i - canceled
*
*           Node 1 – Create endpoint, open receive side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_29)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set up the structure for getting the local management server. */
    svc_struct.type = MCAPI_MSG_TX_TYPE;
    svc_struct.local_port = MCAPI_PORT_ANY;
    svc_struct.node = FUNC_FRONTEND_NODE_ID;
    svc_struct.service = "lcl_mgmt";
    svc_struct.thread_entry = MCAPI_NULL;

    /* Create the client service that will cancel the call. */
    MCAPID_Create_Service(&svc_struct);

    /* Open the receive side. */
    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                              mcapi_struct->local_endp,
                              &svc_struct.request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cause the call to be canceled in 1 second. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                   svc_struct.local_endp, 1000, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &svc_struct.request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == 0) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_29 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_30
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_sclchan_send_i - timed out
*
*           Node 1 – Create endpoint, open send side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_30)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &mcapi_struct->request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        req_ptr[0] = &mcapi_struct->request;

        /* Wait for the call to timeout. */
        finished = mcapi_wait_any(1, req_ptr, &rx_len, 250,
                                  &mcapi_struct->status);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
             (finished == 0) )
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

} /* MCAPI_FTS_Tx_2_35_30 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_31
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_sclchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side.
*
*           Node 1 – Create endpoint, connect, open send side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_31)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;
    mcapi_request_t     *req_ptr[1];

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
                        /* Open the send side. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
                             (mcapi_struct->status != MCAPI_SUCCESS) )
                        {
                            mcapi_struct->status = -1;
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

} /* MCAPI_FTS_Tx_2_35_31 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_32
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_open_sclchan_send_i - canceled
*
*           Node 1 – Create endpoint, open send side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_32)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[1];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Set up the structure for getting the local management server. */
    svc_struct.type = MCAPI_MSG_TX_TYPE;
    svc_struct.local_port = MCAPI_PORT_ANY;
    svc_struct.node = FUNC_FRONTEND_NODE_ID;
    svc_struct.service = "lcl_mgmt";
    svc_struct.thread_entry = MCAPI_NULL;

    /* Create the client service that will cancel the call. */
    MCAPID_Create_Service(&svc_struct);

    /* Open the send side. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &svc_struct.request,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Cause the call to be canceled in 1 second. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                   svc_struct.local_endp, 1000, MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &svc_struct.request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == 0) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }
        }
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_32 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_33
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_sclchan_recv_close_i - tx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open receive side, close receive
*                    side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_33)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
            req_ptr[0] = &request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_33 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_34
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_sclchan_recv_close_i - tx opened,
*       not connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, open receive side, wait for Node 0 to
*                    open send side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_34)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_34 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_35
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_pktchan_recv_close_i - tx opened,
*       connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, issue connection, open receive side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_35)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp;
    mcapi_request_t     *req_ptr[1];

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
                                        req_ptr[0] = &request;

                                        /* Wait for the call to timeout. */
                                        finished = mcapi_wait_any(1, req_ptr,
                                                                  &rx_len,
                                                                  MCAPI_FTS_TIMEOUT,
                                                                  &mcapi_struct->status);

                                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_35 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_36
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_sclchan_send_close_i - rx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open send side, close send
*                    side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_36)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
            req_ptr[0] = &request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(1, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_36 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_37
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any over mcapi_sclchan_send_close_i - rx opened,
*       not connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, open send side, wait for Node 0 to
*                    open receive side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_37)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_request_t     *req_ptr[1];

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
                        req_ptr[0] = &request;

                        /* Wait for the call to timeout. */
                        finished = mcapi_wait_any(1, req_ptr, &rx_len,
                                                  MCAPI_FTS_TIMEOUT,
                                                  &mcapi_struct->status);

                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_37 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_38
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_sclchan_send_close_i - rx opened,
*       connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, issue connection, open send side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_38)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    rx_endp;
    mcapi_request_t     *req_ptr[1];

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
                                        req_ptr[0] = &request;

                                        /* Wait for the call to timeout. */
                                        finished = mcapi_wait_any(1, req_ptr,
                                                                  &rx_len,
                                                                  MCAPI_FTS_TIMEOUT,
                                                                  &mcapi_struct->status);

                                        if ( (finished != 0) ||
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

} /* MCAPI_FTS_Tx_2_35_38 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_39
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the same types, operate on
*       first request – timeout
*
*           Node 1 – Issue get endpoint request for 2 non-existent endpoints
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_39)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1, endpoint2;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the first foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the second foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint2,
                             &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &request1;
            req_ptr[1] = &request2;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, 250,
                                      &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_TIMEOUT)
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }

            /* Cancel the second request. */
            mcapi_cancel(&request2, &status);
        }

        /* Cancel the first request. */
        mcapi_cancel(&request1, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_39 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_40
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the same types, operate on
*       first request – canceled
*
*           Node 1 – Issue get endpoint request for 2 non-existent endpoints
*                    on Node 0, wait for completion, first request canceled.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_40)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff, endpoint2 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the first foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the second foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint2,
                             &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the request should be canceled in 1000 milliseconds. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                       mcapi_struct->local_endp, 1000,
                                       MCAPI_DEFAULT_PRIO);

            req_ptr[0] = &mcapi_struct->request;
            req_ptr[1] = &request2;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == 0) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                /* Cancel the first request. */
                mcapi_cancel(&mcapi_struct->request, &status);

                mcapi_struct->status = -1;
            }

            /* Cancel the second request. */
            mcapi_cancel(&request2, &status);
        }

        else
        {
            /* Cancel the first request. */
            mcapi_cancel(&mcapi_struct->request, &status);
        }

        /* Wait for a response that the cancel was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_40 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_41
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the same types, operate on
*       first request – complete
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_41)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff, endpoint2 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the first foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the second foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint2,
                             &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be created in 500 milliseconds. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                       mcapi_struct->local_endp, 500,
                                       MCAPI_DEFAULT_PRIO);

            req_ptr[0] = &request1;
            req_ptr[1] = &request2;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 0) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                /* Cancel the first request. */
                mcapi_cancel(&request1, &status);

                mcapi_struct->status = -1;
            }

            /* Wait for a response that the creation was successful. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (status == MCAPI_SUCCESS)
            {
                /* Indicate that the endpoint should be deleted. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for a response that the endpoint was deleted. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }

            /* Cancel the second request. */
            mcapi_cancel(&request2, &status);
        }

        else
        {
            /* Cancel the first request. */
            mcapi_cancel(&request1, &status);
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_41 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_42
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any while getting 2 foreign endpoints - second
*       request canceled
*
*           Node 1 – Issue get endpoint request for 2 non-existent endpoints
*                    on Node 0, wait for completion, second request canceled.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_42)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff, endpoint2 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the first foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the second foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint2,
                             &mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the request should be canceled in 1000 milliseconds. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                       mcapi_struct->local_endp, 1000,
                                       MCAPI_DEFAULT_PRIO);

            req_ptr[0] = &request1;
            req_ptr[1] = &mcapi_struct->request;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                 (finished == 1) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                /* Cancel the second request. */
                mcapi_cancel(&mcapi_struct->request, &status);

                mcapi_struct->status = -1;
            }

            /* Cancel the first request. */
            mcapi_cancel(&request1, &status);
        }

        else
        {
            /* Cancel the first request. */
            mcapi_cancel(&mcapi_struct->request, &status);
        }

        /* Wait for a response that the cancel was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_42 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_43
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – complete
*
*           Node 0 – Wait for get endpoint requests, create second endpoint
*
*           Node 1 – Issue get endpoint request for 2 non-existent endpoints
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_43)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff, endpoint2 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the first foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the second foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint2,
                             &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the endpoint should be created in 500 milliseconds. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                       mcapi_struct->local_endp, 500,
                                       MCAPI_DEFAULT_PRIO);

            req_ptr[0] = &request1;
            req_ptr[1] = &request2;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 1) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                /* Cancel the second request. */
                mcapi_cancel(&request2, &status);

                mcapi_struct->status = -1;
            }

            /* Wait for a response that the creation was successful. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (status == MCAPI_SUCCESS)
            {
                /* Indicate that the endpoint should be deleted. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1025,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for a response that the endpoint was deleted. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }

            /* Cancel the first request. */
            mcapi_cancel(&request1, &status);
        }

        else
        {
            /* Cancel the first request. */
            mcapi_cancel(&request1, &status);
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_43 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_44
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – timeout
*
*           Node 1 – Issue get endpoint request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_44)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    char                buffer[MCAPID_MGMT_PKT_LEN];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get a foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Issue a receive message call. */
        mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                         &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &request1;
            req_ptr[1] = &request2;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, 250,
                                      &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_TIMEOUT)
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }

            /* Cancel the second request. */
            mcapi_cancel(&request2, &status);
        }

        /* Cancel the first request. */
        mcapi_cancel(&request1, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_44 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_45
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – canceled
*
*           Node 1 – Issue get endpoint request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for first request to be canceled
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_45)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request2;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get a foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                             &mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Issue a receive message call. */
            mcapi_msg_recv_i(rx_endp, buffer, MCAPID_MGMT_PKT_LEN,
                             &request2, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the request should be canceled in 1000 milliseconds. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                           mcapi_struct->local_endp, 1000,
                                           MCAPI_DEFAULT_PRIO);

                req_ptr[0] = &mcapi_struct->request;
                req_ptr[1] = &request2;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                     (finished == 0) )
                {
                    mcapi_struct->status = MCAPI_SUCCESS;
                }

                else
                {
                    /* Cancel the first request. */
                    mcapi_cancel(&mcapi_struct->request, &status);

                    mcapi_struct->status = -1;
                }

                /* Cancel the second request. */
                mcapi_cancel(&request2, &status);
            }

            else
            {
                /* Cancel the first request. */
                mcapi_cancel(&mcapi_struct->request, &status);
            }

            /* Wait for a response that the cancel was successful. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_45 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_46
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – complete
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for first request to be complete
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_46)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get the first foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                             &request1, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Issue a receive message call. */
            mcapi_msg_recv_i(rx_endp, buffer, MCAPID_MGMT_PKT_LEN,
                             &request2, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the endpoint should be created in 500 milliseconds. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                           mcapi_struct->local_endp, 500,
                                           MCAPI_DEFAULT_PRIO);

                req_ptr[0] = &request1;
                req_ptr[1] = &request2;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (finished != 0) ||
                     (mcapi_struct->status != MCAPI_SUCCESS) )
                {
                    /* Cancel the first request. */
                    mcapi_cancel(&request1, &status);

                    mcapi_struct->status = -1;
                }

                /* Wait for a response that the creation was successful. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (status == MCAPI_SUCCESS)
                {
                    /* Indicate that the endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response that the endpoint was deleted. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }

                /* Cancel the second request. */
                mcapi_cancel(&request2, &status);
            }

            else
            {
                /* Cancel the first request. */
                mcapi_cancel(&request1, &status);
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_46 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_47
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – canceled
*
*           Node 1 – Issue get endpoint request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for second request to be canceled
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_47)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_endpoint_t    rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Get a foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                             &request1, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Issue a receive message call. */
            mcapi_msg_recv_i(rx_endp, buffer, MCAPID_MGMT_PKT_LEN,
                             &mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the request should be canceled in 1000 milliseconds. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                           mcapi_struct->local_endp, 1000,
                                           MCAPI_DEFAULT_PRIO);

                req_ptr[0] = &request1;
                req_ptr[1] = &mcapi_struct->request;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                     (finished == 1) )
                {
                    mcapi_struct->status = MCAPI_SUCCESS;
                }

                else
                {
                    /* Cancel the second request. */
                    mcapi_cancel(&mcapi_struct->request, &status);

                    mcapi_struct->status = -1;
                }
            }

            /* Cancel the first request. */
            mcapi_cancel(&request1, &status);

            /* Wait for a response that the cancel was successful. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_47 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_48
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – complete
*
*           Node 0 – Wait for get data request, send data
*
*           Node 1 – Issue get endpoin9t request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for second request to be complete
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_48)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint1 = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    char                buffer[MCAPID_MGMT_PKT_LEN];

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the first foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint1,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Issue a receive message call. */
        mcapi_msg_recv_i(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                         &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that data should be sent in 500 milliseconds. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 500,
                                       MCAPI_DEFAULT_PRIO);

            req_ptr[0] = &request1;
            req_ptr[1] = &request2;

            /* Wait for the call to succeed. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            if ( (finished != 1) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                /* Cancel the second request. */
                mcapi_cancel(&request2, &status);

                mcapi_struct->status = -1;
            }
        }

        /* Cancel the first request. */
        mcapi_cancel(&request1, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_48 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_49
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – timeout
*
*           Node 1 – Open receive side of packet channel, open send side
*                    of packet channel, wait for timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_49)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    mcapi_endpoint_t    rx_endp, tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Two extra endpoints are required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open the receive side of the packet channel. */
            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                      &request1, &mcapi_struct->status);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the send side of the packet channel. */
                mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle, tx_endp,
                                          &request2, &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    req_ptr[0] = &request1;
                    req_ptr[1] = &request2;

                    /* Wait for the call to timeout. */
                    finished = mcapi_wait_any(2, req_ptr, &rx_len, 250,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_TIMEOUT)
                    {
                        mcapi_struct->status = MCAPI_SUCCESS;
                    }

                    else
                    {
                        mcapi_struct->status = -1;
                    }

                    /* Cancel the second request. */
                    mcapi_cancel(&request2, &status);
                }

                /* Cancel the first request. */
                mcapi_cancel(&request1, &status);
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(tx_endp, &status);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_49 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_50
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – canceled
*
*           Node 1 – Open receive side of packet channel, open send side of
*                    packet channel, cancel first request, wait for
*                    cancellation.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_50)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request2;
    mcapi_endpoint_t    rx_endp, tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Two extra endpoints are required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open the receive side of the packet channel. */
            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                      &mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the send side of the packet channel. */
                mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle, tx_endp,
                                          &request2, &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Indicate that the request should be canceled in 1000 milliseconds. */
                    mcapi_struct->status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                               mcapi_struct->local_endp, 1000,
                                               MCAPI_DEFAULT_PRIO);

                    req_ptr[0] = &mcapi_struct->request;
                    req_ptr[1] = &request2;

                    /* Wait for the call to timeout. */
                    finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                              MCAPI_FTS_TIMEOUT,
                                              &mcapi_struct->status);

                    if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                         (finished == 0) )
                    {
                        mcapi_struct->status = MCAPI_SUCCESS;
                    }

                    else
                    {
                        /* Cancel the first request. */
                        mcapi_cancel(&mcapi_struct->request, &status);

                        mcapi_struct->status = -1;
                    }

                    /* Wait for a response that the cancel was successful. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* Cancel the second request. */
                    mcapi_cancel(&request2, &status);
                }

                else
                {
                    /* Cancel the first request. */
                    mcapi_cancel(&mcapi_struct->request, &status);
                }
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(tx_endp, &status);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_50 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_51
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – complete
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for first request to be complete
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_51)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    mcapi_endpoint_t    rx_endp, tx_endp, foreign_tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Get the foreign endpoint. */
            foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Two extra endpoints are required for this test. */
                rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the receive side of the packet channel. */
                        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                                  &request1, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Open the send side of the packet channel. */
                            mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle, tx_endp,
                                                      &request2, &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                /* Issue the connection. */
                                mcapi_connect_pktchan_i(foreign_tx_endp, rx_endp,
                                                        &mcapi_struct->request,
                                                        &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the connect to complete. */
                                    mcapi_wait(&mcapi_struct->request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Indicate that the send side should be opened in
                                     * 500 milliseconds.
                                     */
                                    mcapi_struct->status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                                               1024, mcapi_struct->local_endp,
                                                               500, MCAPI_DEFAULT_PRIO);

                                    req_ptr[0] = &request1;
                                    req_ptr[1] = &request2;

                                    /* Wait for the open to complete. */
                                    finished = mcapi_wait_any(2, req_ptr,
                                                              &rx_len,
                                                              MCAPI_FTS_TIMEOUT,
                                                              &mcapi_struct->status);

                                    if ( (finished != 0) ||
                                         (mcapi_struct->status != MCAPI_SUCCESS) )
                                    {
                                        /* Cancel the first request. */
                                        mcapi_cancel(&request1, &status);

                                        mcapi_struct->status = -1;
                                    }

                                    else
                                    {
                                        /* Wait for a response that the open was successful. */
                                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                        if (status == MCAPI_SUCCESS)
                                        {
                                            /* Indicate that the send side should be closed. */
                                            status =
                                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                       MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                                                       1024, mcapi_struct->local_endp,
                                                                       0, MCAPI_DEFAULT_PRIO);

                                            if (status == MCAPI_SUCCESS)
                                            {
                                                /* Wait for a response that the close was successful. */
                                                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                            }
                                        }

                                        /* Close the receive side. */
                                        mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                                      &mcapi_struct->request,
                                                                      &status);
                                    }
                                }

                                /* Cancel the second request. */
                                mcapi_cancel(&request2, &status);
                            }

                            else
                            {
                                /* Cancel the first request. */
                                mcapi_cancel(&request1, &status);
                            }
                        }

                        /* Delete the extra endpoint. */
                        mcapi_delete_endpoint(tx_endp, &status);

                    }

                    /* Delete the extra endpoint. */
                    mcapi_delete_endpoint(rx_endp, &status);
                }
            }

            /* Indicate that the endpoint should be deleted. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was deleted. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_51 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_52
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – canceled
*
*           Node 1 – Open receive side of packet channel, open send side of
*                    packet channel, cancel second request, wait for
*                    cancellation.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_52)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1;
    mcapi_endpoint_t    rx_endp, tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Two extra endpoints are required for this test. */
    rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open the receive side of the packet channel. */
            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                      &request1, &mcapi_struct->status);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                /* Open the send side of the packet channel. */
                mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle, tx_endp,
                                          &mcapi_struct->request, &mcapi_struct->status);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Indicate that the request should be canceled in 1000 milliseconds. */
                    mcapi_struct->status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                               mcapi_struct->local_endp, 1000,
                                               MCAPI_DEFAULT_PRIO);

                    req_ptr[0] = &request1;
                    req_ptr[1] = &mcapi_struct->request;

                    /* Wait for the call to timeout. */
                    finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                              MCAPI_FTS_TIMEOUT,
                                              &mcapi_struct->status);

                    if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                         (finished == 1) )
                    {
                        mcapi_struct->status = MCAPI_SUCCESS;
                    }

                    else
                    {
                        /* Cancel the second request. */
                        mcapi_cancel(&mcapi_struct->request, &status);

                        mcapi_struct->status = -1;
                    }

                    /* Wait for a response that the cancel was successful. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* Cancel the first request. */
                    mcapi_cancel(&request1, &status);
                }

                else
                {
                    /* Cancel the first request. */
                    mcapi_cancel(&request1, &status);
                }
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(tx_endp, &status);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_52 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_53
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – complete
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for a non-existent endpoint
*                    on Node 0, and issue a receive message request, wait
*                    for second request to be complete
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_53)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    mcapi_endpoint_t    rx_endp, tx_endp, foreign_rx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Get the foreign endpoint. */
            foreign_rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Two extra endpoints are required for this test. */
                rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the receive side of the packet channel. */
                        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle, rx_endp,
                                                  &request1, &mcapi_struct->status);

                        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                        {
                            /* Open the send side of the packet channel. */
                            mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle, tx_endp,
                                                      &request2, &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                /* Issue the connection. */
                                mcapi_connect_pktchan_i(tx_endp, foreign_rx_endp,
                                                        &mcapi_struct->request,
                                                        &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the connect to complete. */
                                    mcapi_wait(&mcapi_struct->request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Indicate that the receive side should be opened in
                                     * 500 milliseconds.
                                     */
                                    mcapi_struct->status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_OPEN_RX_SIDE_PKT,
                                                               1024, mcapi_struct->local_endp,
                                                               500, MCAPI_DEFAULT_PRIO);

                                    req_ptr[0] = &request1;
                                    req_ptr[1] = &request2;

                                    /* Wait for the open to complete. */
                                    finished = mcapi_wait_any(2, req_ptr,
                                                              &rx_len,
                                                              MCAPI_FTS_TIMEOUT,
                                                              &mcapi_struct->status);

                                    if ( (finished != 1) ||
                                         (mcapi_struct->status != MCAPI_SUCCESS) )
                                    {
                                        /* Cancel the second request. */
                                        mcapi_cancel(&request2, &status);

                                        mcapi_struct->status = -1;
                                    }

                                    else
                                    {
                                        /* Wait for a response that the open was successful. */
                                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                                        if (status == MCAPI_SUCCESS)
                                        {
                                            /* Indicate that the receive side should be closed. */
                                            status =
                                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                       MCAPID_MGMT_CLOSE_RX_SIDE_PKT,
                                                                       1024, mcapi_struct->local_endp,
                                                                       0, MCAPI_DEFAULT_PRIO);

                                            if (status == MCAPI_SUCCESS)
                                            {
                                                /* Wait for a response that the close was successful. */
                                                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                            }
                                        }

                                        /* Close the send side. */
                                        mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                                                      &mcapi_struct->request,
                                                                      &status);
                                    }
                                }

                                /* Cancel the first request. */
                                mcapi_cancel(&request1, &status);
                            }

                            else
                            {
                                /* Cancel the first request. */
                                mcapi_cancel(&request1, &status);
                            }
                        }

                        /* Delete the extra endpoint. */
                        mcapi_delete_endpoint(tx_endp, &status);

                    }

                    /* Delete the extra endpoint. */
                    mcapi_delete_endpoint(rx_endp, &status);
                }
            }

            /* Indicate that the endpoint should be deleted. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was deleted. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_53 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_54
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – timeout
*
*           Node 1 – Open receive side of packet channel, open send side
*                    of packet channel, wait for timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_54)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    mcapi_endpoint_t    rx_endp1, rx_endp2;
    char                *buffer;
    mcapi_endpoint_t    foreign_tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the foreign endpoint should be opened as the sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp,
                                       500, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was created. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                         &mcapi_struct->status);
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Two extra endpoints are required for this test. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Issue the connection. */
                mcapi_connect_pktchan_i(foreign_tx_endp, rx_endp1,
                                        &mcapi_struct->request,
                                        &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the connect to complete. */
                    mcapi_wait(&mcapi_struct->request, &rx_len,
                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                    /* Open the receive side of the packet channel. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                              rx_endp1, &mcapi_struct->request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Issue a receive request. */
                        mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                             (void **)&buffer, &request1,
                                             &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side of the scalar channel. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      rx_endp2, &request2,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                req_ptr[0] = &request1;
                                req_ptr[1] = &request2;

                                /* Wait for the requests to timeout. */
                                finished = mcapi_wait_any(2, req_ptr,
                                                          &rx_len, 250,
                                                          &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_TIMEOUT)
                                {
                                    mcapi_struct->status = MCAPI_SUCCESS;
                                }

                                /* Cancel the second request. */
                                mcapi_cancel(&request2, &status);
                            }

                            /* Cancel the first request. */
                            mcapi_cancel(&request1, &status);

                            /* Close the receive side. */
                            mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                          &mcapi_struct->request,
                                                          &status);
                        }
                    }
                }

                /* Delete the extra endpoint. */
                mcapi_delete_endpoint(rx_endp2, &status);
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(rx_endp1, &status);
        }
    }

    /* Indicate that the send side should be closed. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                    1024, mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the close was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the endpoint should be deleted. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was deleted. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_54 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_55
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – cancel
*
*           Node 1 – Open receive side of packet channel, open send side
*                    of packet channel, wait for cancellation
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_55)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request2;
    mcapi_endpoint_t    rx_endp1, rx_endp2;
    char                *buffer;
    mcapi_endpoint_t    foreign_tx_endp;

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

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the foreign endpoint should be opened as the sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_TX_SIDE_PKT, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was created. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                         &mcapi_struct->status);
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Two extra endpoints are required for this test. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Issue the connection. */
                mcapi_connect_pktchan_i(foreign_tx_endp, rx_endp1,
                                        &mcapi_struct->request,
                                        &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the connect to complete. */
                    mcapi_wait(&mcapi_struct->request, &rx_len,
                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                    /* Open the receive side of the packet channel. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                              rx_endp1, &mcapi_struct->request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Issue a receive request. */
                        mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                             (void **)&buffer, &svc_struct.request,
                                             &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side of the scalar channel. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      rx_endp2, &request2,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                req_ptr[0] = &svc_struct.request;
                                req_ptr[1] = &request2;

                                /* Indicate that the request should be canceled in
                                 * 1000 milliseconds.
                                 */
                                mcapi_struct->status =
                                    MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                                           mcapi_struct->local_endp, 1000,
                                                           MCAPI_DEFAULT_PRIO);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the request to be cancelled. */
                                    finished = mcapi_wait_any(2, req_ptr,
                                                              &rx_len,
                                                              MCAPI_FTS_TIMEOUT,
                                                              &mcapi_struct->status);

                                    if ( (finished == 0) &&
                                         (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
                                    {
                                        mcapi_struct->status = MCAPI_SUCCESS;
                                    }

                                    else
                                    {
                                        /* Cancel the first request. */
                                        mcapi_cancel(&svc_struct.request, &status);

                                        mcapi_struct->status = -1;
                                    }
                                }

                                /* Cancel the second request. */
                                mcapi_cancel(&request2, &status);
                            }

                            else
                            {
                                /* Cancel the first request. */
                                mcapi_cancel(&svc_struct.request, &status);
                            }

                            /* Close the receive side. */
                            mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                          &mcapi_struct->request,
                                                          &status);
                        }
                    }
                }

                /* Delete the extra endpoint. */
                mcapi_delete_endpoint(rx_endp2, &status);
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(rx_endp1, &status);
        }
    }

    /* Indicate that the send side should be closed. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                    1024, mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the close was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the endpoint should be deleted. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was deleted. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_55 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_56
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – complete
*
*           Node 0 - Create endpoint, open send side of packet channel,
*                    send data to other side
*
*           Node 1 – Open receive side of packet channel, open send side
*                    of packet channel, wait for data
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_56)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;
    mcapi_endpoint_t    rx_endp1, rx_endp2;
    char                *buffer;
    mcapi_endpoint_t    foreign_tx_endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the foreign endpoint should be opened as the sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp,
                                       0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was created. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                         &mcapi_struct->status);
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Two extra endpoints are required for this test. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Issue the connection. */
                mcapi_connect_pktchan_i(foreign_tx_endp, rx_endp1,
                                        &mcapi_struct->request,
                                        &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the connect to complete. */
                    mcapi_wait(&mcapi_struct->request, &rx_len,
                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                    /* Open the receive side of the packet channel. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                              rx_endp1, &mcapi_struct->request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Issue a receive request. */
                        mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                             (void **)&buffer, &request1,
                                             &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side of the scalar channel. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      rx_endp2, &request2,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                req_ptr[0] = &request1;
                                req_ptr[1] = &request2;

                                /* Indicate that a packet should be sent. */
                                mcapi_struct->status =
                                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_TX_PKT, 1024,
                                                           mcapi_struct->local_endp, 1000,
                                                           MCAPI_DEFAULT_PRIO);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the packet. */
                                    finished = mcapi_wait_any(2, req_ptr,
                                                              &rx_len,
                                                              MCAPI_FTS_TIMEOUT,
                                                              &mcapi_struct->status);

                                    if ( (finished != 0) ||
                                         (mcapi_struct->status != MCAPI_SUCCESS) )
                                    {
                                        mcapi_struct->status = -1;

                                        /* Cancel the first request. */
                                        mcapi_cancel(&request1, &status);
                                    }

                                    else
                                    {
                                        /* Free the buffer. */
                                        mcapi_pktchan_free(buffer, &status);
                                    }
                                }

                                /* Cancel the second request. */
                                mcapi_cancel(&request2, &status);
                            }

                            else
                            {
                                /* Cancel the first request. */
                                mcapi_cancel(&request1, &status);
                            }

                            /* Close the receive side. */
                            mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                          &mcapi_struct->request,
                                                          &status);
                        }
                    }
                }

                /* Delete the extra endpoint. */
                mcapi_delete_endpoint(rx_endp2, &status);
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(rx_endp1, &status);
        }
    }

    /* Indicate that the send side should be closed. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                    1024, mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the close was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the endpoint should be deleted. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was deleted. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_56 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_57
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – cancel
*
*           Node 1 – Open receive side of packet channel, open send side
*                    of packet channel, wait for cancellation
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_57)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1;
    mcapi_endpoint_t    rx_endp1, rx_endp2;
    char                *buffer;
    mcapi_endpoint_t    foreign_tx_endp;

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

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the foreign endpoint should be opened as the sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_TX_SIDE_PKT, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was created. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                         &mcapi_struct->status);
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Two extra endpoints are required for this test. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Issue the connection. */
                mcapi_connect_pktchan_i(foreign_tx_endp, rx_endp1,
                                        &mcapi_struct->request,
                                        &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the connect to complete. */
                    mcapi_wait(&mcapi_struct->request, &rx_len,
                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                    /* Open the receive side of the packet channel. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                              rx_endp1, &mcapi_struct->request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Issue a receive request. */
                        mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                             (void **)&buffer, &request1,
                                             &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side of the scalar channel. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      rx_endp2, &svc_struct.request,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                req_ptr[0] = &request1;
                                req_ptr[1] = &svc_struct.request;

                                /* Indicate that the request should be canceled in
                                 * 1000 milliseconds.
                                 */
                                mcapi_struct->status =
                                    MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                                           mcapi_struct->local_endp, 1000,
                                                           MCAPI_DEFAULT_PRIO);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the request to be cancelled. */
                                    finished = mcapi_wait_any(2, req_ptr,
                                                              &rx_len,
                                                              MCAPI_FTS_TIMEOUT,
                                                              &mcapi_struct->status);

                                    if ( (finished == 1) &&
                                         (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
                                    {
                                        mcapi_struct->status = MCAPI_SUCCESS;
                                    }

                                    else
                                    {
                                        /* Cancel the second request. */
                                        mcapi_cancel(&svc_struct.request, &status);

                                        mcapi_struct->status = -1;
                                    }
                                }
                            }

                            /* Cancel the first request. */
                            mcapi_cancel(&request1, &status);

                            /* Close the receive side. */
                            mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                          &mcapi_struct->request,
                                                          &status);
                        }
                    }
                }

                /* Delete the extra endpoint. */
                mcapi_delete_endpoint(rx_endp2, &status);
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(rx_endp1, &status);
        }
    }

    /* Indicate that the send side should be closed. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                    1024, mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the close was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the endpoint should be deleted. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was deleted. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_57 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_58
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – complete
*
*           Node 1 – Open receive side of packet channel, open send side
*                    of packet channel, wait for scalar receive side to open
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_58)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request2, request1;
    mcapi_endpoint_t    rx_endp1, rx_endp2;
    char                *buffer;
    mcapi_endpoint_t    foreign_tx_endp1, foreign_tx_endp2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Indicate that the foreign endpoint should be opened as the sender. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                       MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                       1024, mcapi_struct->local_endp,
                                       0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was created. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp1 = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                          &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Indicate that an endpoint should be created. */
                        mcapi_struct->status =
                            MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                   MCAPID_MGMT_CREATE_ENDP, 1025,
                                                   mcapi_struct->local_endp, 0,
                                                   MCAPI_DEFAULT_PRIO);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for a response that the endpoint was created. */
                            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Get the second foreign endpoint. */
                                foreign_tx_endp2 = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID,
                                                                      1025,
                                                                      &mcapi_struct->status);
                            }
                        }
                    }
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Two extra endpoints are required for this test. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Issue the packet connection. */
                mcapi_connect_pktchan_i(foreign_tx_endp1, rx_endp1,
                                        &mcapi_struct->request,
                                        &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Wait for the connect to complete. */
                    mcapi_wait(&mcapi_struct->request, &rx_len,
                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                    /* Open the receive side of the packet channel. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                              rx_endp1, &mcapi_struct->request,
                                              &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open to complete. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Issue a receive request. */
                        mcapi_pktchan_recv_i(mcapi_struct->pkt_rx_handle,
                                             (void **)&buffer, &request1,
                                             &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Open the receive side of the scalar channel. */
                            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                      rx_endp2, &request2,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                /* Issue the scalar connection. */
                                mcapi_connect_sclchan_i(foreign_tx_endp2, rx_endp2,
                                                        &mcapi_struct->request,
                                                        &mcapi_struct->status);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Wait for the connect to complete. */
                                    mcapi_wait(&mcapi_struct->request, &rx_len,
                                               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                    /* Indicate that the foreign endpoint should be opened
                                     * as the sender in 500 milliseconds.
                                     */
                                    mcapi_struct->status =
                                        MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                               MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                                               1025, mcapi_struct->local_endp,
                                                               500, MCAPI_DEFAULT_PRIO);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        req_ptr[0] = &request1;
                                        req_ptr[1] = &request2;

                                        /* Wait for the request to be complete. */
                                        finished = mcapi_wait_any(2, req_ptr,
                                                                  &rx_len,
                                                                  MCAPI_FTS_TIMEOUT,
                                                                  &mcapi_struct->status);

                                        if ( (finished != 1) ||
                                             (mcapi_struct->status != MCAPI_SUCCESS) )
                                        {
                                            mcapi_struct->status = -1;
                                        }
                                    }
                                }

                                /* Close the receive side of the scalar channel. */
                                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                           &mcapi_struct->request,
                                                           &status);
                            }

                            /* Cancel the first request. */
                            mcapi_cancel(&request1, &status);
                        }

                        /* Close the receive side of the packet channel. */
                        mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                                      &mcapi_struct->request,
                                                      &status);
                    }
                }

                /* Delete the extra endpoint. */
                mcapi_delete_endpoint(rx_endp2, &status);
            }

            /* Delete the extra endpoint. */
            mcapi_delete_endpoint(rx_endp1, &status);
        }
    }

    /* Indicate that the send side should be closed. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT,
                                    1024, mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the close was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the endpoint should be deleted. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was deleted. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the send side should be closed. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_SCL,
                                    1025, mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the close was successful. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that the endpoint should be deleted. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1025,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was deleted. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_58 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_59
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – timeout
*
*           Node 1 – Make a call to open the send side of a scalar channel,
*                    get non-existent endpoint on Node 0, wait for timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_59)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the send side of a scalar channel. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp, &request1,
                              &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Get a foreign endpoint. */
        mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                             &request2, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            req_ptr[0] = &request1;
            req_ptr[1] = &request2;

            /* Wait for the call to timeout. */
            finished = mcapi_wait_any(2, req_ptr, &rx_len, 250,
                                      &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_TIMEOUT)
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }

            /* Cancel the second request. */
            mcapi_cancel(&request2, &status);
        }

        /* Cancel the first request. */
        mcapi_cancel(&request1, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_59 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_60
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       first request – canceled
*
*           Node 1 – Make a call to open the send side of a scalar channel,
*                    get non-existent endpoint on Node 0, wait for
*                    cancellation
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_60)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff, tx_endp;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this test. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open the send side of a scalar channel. */
        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                  tx_endp, &mcapi_struct->request,
                                  &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Get a foreign endpoint. */
            mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint,
                                 &request2, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the request should be canceled in 1000 milliseconds. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                           mcapi_struct->local_endp, 1000,
                                           MCAPI_DEFAULT_PRIO);

                req_ptr[0] = &mcapi_struct->request;
                req_ptr[1] = &request2;

                /* Wait for the request to be canceled. */
                finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                     (finished == 0) )
                {
                    mcapi_struct->status = MCAPI_SUCCESS;
                }

                else
                {
                    /* Cancel the first request. */
                    mcapi_cancel(&mcapi_struct->request, &status);

                    mcapi_struct->status = -1;
                }

                /* Cancel the second request. */
                mcapi_cancel(&request2, &status);
            }

            else
            {
                /* Cancel the first request. */
                mcapi_cancel(&mcapi_struct->request, &status);
            }

            /* Wait for a response that the cancel was successful. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_60 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_61
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the same types, operate on
*       first request – complete
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_61)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff, tx_endp, foreign_rx_endp;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                               1024, mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for a response that the endpoint was created. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Get the foreign endpoint. */
            foreign_rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024,
                                                 &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* An extra endpoint is required for this test. */
                tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_sclchan_i(tx_endp, foreign_rx_endp,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection to open. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Open the send side of a scalar channel. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  tx_endp, &request1,
                                                  &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Get a foreign endpoint. */
                            mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint,
                                                 &request2, &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                /* Indicate that the foreign endpoint should be opened
                                 * as the receiver.
                                 */
                                mcapi_struct->status =
                                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                           MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                                           1024, mcapi_struct->local_endp,
                                                           500, MCAPI_DEFAULT_PRIO);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    req_ptr[0] = &request1;
                                    req_ptr[1] = &request2;

                                    /* Wait for the call to complete. */
                                    finished = mcapi_wait_any(2, req_ptr,
                                                              &rx_len,
                                                              MCAPI_FTS_TIMEOUT,
                                                              &mcapi_struct->status);

                                    if ( (finished != 0) ||
                                         (mcapi_struct->status != MCAPI_SUCCESS) )
                                    {
                                        /* Cancel the first request. */
                                        mcapi_cancel(&request1, &status);

                                        mcapi_struct->status = -1;
                                    }

                                    /* Wait for a response that the open was successful. */
                                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                }

                                /* Cancel the second request. */
                                mcapi_cancel(&request2, &status);

                                /* Indicate that the receive side should be closed. */
                                status = MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                                MCAPID_MGMT_CLOSE_RX_SIDE_SCL,
                                                                1024, mcapi_struct->local_endp,
                                                                0, MCAPI_DEFAULT_PRIO);

                                if (status == MCAPI_SUCCESS)
                                {
                                    /* Wait for a response that the close was successful. */
                                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                }
                            }

                            else
                            {
                                /* Cancel the first request. */
                                mcapi_cancel(&request1, &status);
                            }

                            /* Close the send side of the scalar channel. */
                            mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                       &mcapi_struct->request,
                                                       &status);
                        }
                    }

                    /* Delete the extra endpoint. */
                    mcapi_delete_endpoint(tx_endp, &status);
                }
            }

            /* Indicate that the endpoint should be deleted. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response that the endpoint was deleted. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_61 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_62
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any while getting two of different type, operate
*       on second request - canceled
*
*           Node 1 – Make a call to open the send side of a scalar channel,
*                    get non-existent endpoint on Node 0, wait for
*                    cancellation
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_62)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint, tx_endp;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An additional endpoint is required for this test. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open the send side of a scalar channel. */
        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                  tx_endp, &request1, &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Get a foreign endpoint. */
            mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                                 &mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the request should be canceled in 1000 milliseconds. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                           mcapi_struct->local_endp, 1000,
                                           MCAPI_DEFAULT_PRIO);

                req_ptr[0] = &request1;
                req_ptr[1] = &mcapi_struct->request;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) &&
                     (finished == 1) )
                {
                    mcapi_struct->status = MCAPI_SUCCESS;
                }

                else
                {
                    /* Cancel the second request. */
                    mcapi_cancel(&mcapi_struct->request, &status);

                    mcapi_struct->status = -1;
                }

                /* Cancel the first request. */
                mcapi_cancel(&request1, &status);
            }

            else
            {
                /* Cancel the first request. */
                mcapi_cancel(&mcapi_struct->request, &status);
            }

            /* Wait for a response that the cancel was successful. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_62 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_63
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - Two of the different types, operate on
*       second request – complete
*
*           Node 0 – Wait for get endpoint requests, create endpoint
*
*           Node 1 – Make a call to open the send side of a scalar channel,
*                    get non-existent endpoint on Node 0, wait for get
*                    endpoint to complete
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_63)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint, tx_endp;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     *req_ptr[2];
    mcapi_request_t     request1, request2;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An additional endpoint is required for this test. */
    tx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Open the send side of a scalar channel. */
        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                  tx_endp, &request1, &mcapi_struct->status);

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Get a foreign endpoint. */
            mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1025, &endpoint,
                                 &request2, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the endpoint should be created in 500 milliseconds. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                           mcapi_struct->local_endp, 500,
                                           MCAPI_DEFAULT_PRIO);

                req_ptr[0] = &request1;
                req_ptr[1] = &request2;

                /* Wait for the call to timeout. */
                finished = mcapi_wait_any(2, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                if ( (finished != 1) ||
                     (mcapi_struct->status != MCAPI_SUCCESS) )
                {
                    /* Cancel the second request. */
                    mcapi_cancel(&request2, &status);

                    mcapi_struct->status = -1;
                }

                /* Wait for a response that the creation was successful. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                status_assert(status);

                /* Indicate that the endpoint should be deleted. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1025,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);
                status_assert(status);

                /* Wait for a response that the endpoint was deleted. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                status_assert(status);

                /* Cancel the first request. */
                mcapi_cancel(&request1, &status);
            }

            else
            {
                /* Cancel the first request. */
                mcapi_cancel(&request1, &status);
            }
        }

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(tx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_63 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_64
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - one of each type – timeout
*
*           Node 1 – Get foreign endpoint, issue call to receive message,
*                    open receive side of packet channel, open send side
*                    of packet channel, make call to receive data on packet
*                    channel, open receive side of scalar channel, open
*                    send side of scalar channel – wait for timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_64)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t            endpoint, rx_endp1, rx_endp2, rx_endp3,
                                rx_endp4, tx_endp1, tx_endp2, foreign_tx_endp1;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_boolean_t             finished;
    mcapi_request_t             *req_ptr[7];
    mcapi_request_t             request1, request2, request3, request4,
                                request5, request6, request7;
    mcapi_pktchan_recv_hndl_t   rx_handle;
    char                        *pkt_ptr;
    char                        buffer[MCAPID_MSG_LEN];
    int                         i;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get a foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &request1, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Create an endpoint for receiving messages. */
    rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Make the call to receive data on this endpoint. */
    mcapi_msg_recv_i(rx_endp1, buffer, MCAPID_MSG_LEN, &request2,
                     &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Create an endpoint for the receive side of a packet channel. */
    rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Open receive side of a packet channel. */
    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                              rx_endp2, &request3, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MGC_MCAPI_ERR_NOT_CONNECTED);

    /* Create an endpoint for the send side of a packet channel. */
    tx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Open send side of a packet channel. */
    mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                              tx_endp1, &request4, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MGC_MCAPI_ERR_NOT_CONNECTED);

    /* Indicate that an endpoint should be created. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    /* Wait for a response. */
    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(mcapi_struct->status);

    /* Indicate that the send side should be opened. */
    mcapi_struct->status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT, 1025,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);
    status_assert(mcapi_struct->status);

    /* Wait for a response. */
    mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert_code(mcapi_struct->status, MGC_MCAPI_ERR_NOT_CONNECTED);

    /* Get the foreign endpoint. */
    foreign_tx_endp1 = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1025,
                                          &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Create an endpoint for the receive side of a packet channel. */
    rx_endp3 =
        mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Connect the two endpoints. */
    mcapi_connect_pktchan_i(foreign_tx_endp1, rx_endp3,
                            &mcapi_struct->request,
                            &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Wait for the connection. */
    mcapi_wait(&mcapi_struct->request, &rx_len,
               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

    /* Open receive side of a packet channel. */
    mcapi_open_pktchan_recv_i(&rx_handle, rx_endp3,
                              &mcapi_struct->request,
                              &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Wait for the open. */
    mcapi_wait(&mcapi_struct->request, &rx_len,
               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

    /* Wait for data on the channel. */
    mcapi_pktchan_recv_i(rx_handle, (void**)&pkt_ptr, &request5,
                         &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Create an endpoint for the receive side of a scalar channel. */
    rx_endp4 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Open receive side of a scalar channel. */
    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                              rx_endp4, &request6, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MGC_MCAPI_ERR_NOT_CONNECTED);

    /* Create an endpoint for the send side of a scalar channel. */
    tx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Open send side of a scalar channel. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              tx_endp2, &request7, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MGC_MCAPI_ERR_NOT_CONNECTED);

    req_ptr[0] = &request1;
    req_ptr[1] = &request2;
    req_ptr[2] = &request3;
    req_ptr[3] = &request4;
    req_ptr[4] = &request5;
    req_ptr[5] = &request6;
    req_ptr[6] = &request7;

    /* Wait for the call to timeout. */
    finished =
        mcapi_wait_any(7, req_ptr, &rx_len, 250, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_TIMEOUT)
    {
        mcapi_struct->status = MCAPI_SUCCESS;
    }

    /* Cancel each request. */
    for (i = 0; i < 7; i ++)
    {
        mcapi_cancel(req_ptr[i], &status);
    }

    /* Close the receive side of the packet channel. */
    mcapi_packetchan_recv_close_i(rx_handle, &mcapi_struct->request, &status);

    /* Delete each endpoint. */
    mcapi_delete_endpoint(rx_endp1, &status);
    status_assert(status);
    mcapi_delete_endpoint(rx_endp2, &status);
    status_assert(status);
    mcapi_delete_endpoint(rx_endp3, &status);
    status_assert(status);
    mcapi_delete_endpoint(rx_endp4, &status);
    status_assert(status);
    mcapi_delete_endpoint(tx_endp1, &status);
    status_assert(status);
    mcapi_delete_endpoint(tx_endp2, &status);
    status_assert(status);

    /* Indicate that the send side should be closed. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT, 1025,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that an endpoint should be deleted. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1025,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_64 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_65
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - one of each type, operate on last request
*       until all requests operated on – cancel
*
*           Node 1 – Get foreign endpoint, issue call to receive message,
*                    open receive side of packet channel, open send side
*                    of packet channel, make call to receive data on packet
*                    channel, open receive side of scalar channel, open
*                    send side of scalar channel – remove requests from
*                    list one by one as cancel occurs until no requests
*                    remain
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_65)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    mcapi_endpoint_t            endpoint, rx_endp1, rx_endp2, rx_endp3,
                                rx_endp4, tx_endp1, tx_endp2, foreign_tx_endp1;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_boolean_t             finished;
    mcapi_request_t             *req_ptr[7];
    mcapi_request_t             request1, request2, request3, request4,
                                request5, request6, request7;
    mcapi_pktchan_recv_hndl_t   rx_handle;
    char                        *pkt_ptr;
    char                        buffer[MCAPID_MSG_LEN];
    int                         i;

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

    /* Get a foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for receiving messages. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Make the call to receive data on this endpoint. */
            mcapi_msg_recv_i(rx_endp1, buffer, MCAPID_MSG_LEN, &request2,
                             &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for the receive side of a packet channel. */
        rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open receive side of a packet channel. */
            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                      rx_endp2, &request3, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Create an endpoint for the send side of a packet channel. */
        tx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open send side of a packet channel. */
            mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                      tx_endp1, &request4, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Indicate that an endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                   mcapi_struct->local_endp, 0,
                                   MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for a response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the send side should be opened. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT, 1025,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Get the foreign endpoint. */
            foreign_tx_endp1 = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1025,
                                                  &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Create an endpoint for the receive side of a packet channel. */
                rx_endp3 =
                    mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_pktchan_i(foreign_tx_endp1, rx_endp3,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Open receive side of a packet channel. */
                        mcapi_open_pktchan_recv_i(&rx_handle, rx_endp3,
                                                  &mcapi_struct->request,
                                                  &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the open. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Wait for data on the channel. */
                            mcapi_pktchan_recv_i(rx_handle, (void**)&pkt_ptr, &request5,
                                                 &mcapi_struct->status);
                        }
                    }
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for the receive side of a scalar channel. */
        rx_endp4 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open receive side of a scalar channel. */
            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                      rx_endp4, &request6, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Create an endpoint for the send side of a scalar channel. */
        tx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open send side of a scalar channel. */
            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                      tx_endp2, &request7, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        req_ptr[0] = &request1;
        req_ptr[1] = &request2;
        req_ptr[2] = &request3;
        req_ptr[3] = &request4;
        req_ptr[4] = &request5;
        req_ptr[5] = &request6;
        req_ptr[6] = &request7;

        for (i = 6; i >= 0; i --)
        {
            /* Store the request to cancel. */
            memcpy(&svc_struct.request, req_ptr[i], sizeof(mcapi_request_t));

            /* Cause the call to be canceled. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(&svc_struct, MCAPID_CANCEL_REQUEST, 0,
                                       svc_struct.local_endp, 500, MCAPI_DEFAULT_PRIO);

            /* Wait for the call to be canceled. */
            finished = mcapi_wait_any(i + 1, req_ptr, &rx_len,
                                      MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            /* If the request was canceled. */
            if ( (finished == i) &&
                 (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            /* Otherwise, manually cancel the remaining requests. */
            else
            {
                mcapi_struct->status = -1;

                /* Cancel each remaining request. */
                for (; i >= 0; i --)
                {
                    mcapi_cancel(req_ptr[i], &status);
                }

                break;
            }
        }
    }

    /* Close the receive side of the packet channel. */
    mcapi_packetchan_recv_close_i(rx_handle, &mcapi_struct->request, &status);

    /* Delete each endpoint. */
    mcapi_delete_endpoint(rx_endp1, &status);
    mcapi_delete_endpoint(rx_endp2, &status);
    mcapi_delete_endpoint(rx_endp3, &status);
    mcapi_delete_endpoint(rx_endp4, &status);
    mcapi_delete_endpoint(tx_endp1, &status);
    mcapi_delete_endpoint(tx_endp2, &status);

    /* Indicate that the send side should be closed. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT, 1025,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Indicate that an endpoint should be deleted. */
    status =
        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1025,
                               mcapi_struct->local_endp, 0,
                               MCAPI_DEFAULT_PRIO);

    if (status == MCAPI_SUCCESS)
    {
        /* Wait for a response. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_65 */
#endif

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_35_66
*
*   DESCRIPTION
*
*       Testing mcapi_wait_any - one of each type, operate on last request
*       until all requests operated on – completed
*
*           Node 1 – Get foreign endpoint, issue call to receive message,
*                    open receive side of packet channel, open send side
*                    of packet channel, make call to receive data on packet
*                    channel, open receive side of scalar channel, open
*                    send side of scalar channel – complete requests one
*                    by one as cancel occurs until no requests remain
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_35_66)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    mcapi_endpoint_t            endpoint, rx_endp1, rx_endp2, rx_endp3,
                                rx_endp4, tx_endp1, tx_endp2,
                                foreign_tx_endp1, foreign_tx_endp,
                                foreign_rx_endp, local_endp;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_boolean_t             finished;
    mcapi_request_t             *req_ptr[7];
    mcapi_request_t             request1, request2, request3, request4,
                                request5, request6, request7;
    mcapi_pktchan_recv_hndl_t   rx_handle;
    char                        *pkt_ptr;
    char                        buffer[MCAPID_MSG_LEN];
    int                         i;

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

    /* Get a foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &request1, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for receiving messages. */
        rx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Make the call to receive data on this endpoint. */
            mcapi_msg_recv_i(rx_endp1, buffer, MCAPID_MSG_LEN, &request2,
                             &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for the receive side of a packet channel. */
        rx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open receive side of a packet channel. */
            mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                      rx_endp2, &request3, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Create an endpoint for the send side of a packet channel. */
        tx_endp1 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open send side of a packet channel. */
            mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                      tx_endp1, &request4, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Indicate that an endpoint should be created. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1025,
                                   mcapi_struct->local_endp, 0,
                                   MCAPI_DEFAULT_PRIO);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for a response. */
            mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Indicate that the send side should be opened. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_OPEN_TX_SIDE_PKT, 1025,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }

        if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
        {
            /* Get the foreign endpoint. */
            foreign_tx_endp1 = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1025,
                                                  &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Create an endpoint for the receive side of a packet channel. */
                rx_endp3 =
                    mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Connect the two endpoints. */
                    mcapi_connect_pktchan_i(foreign_tx_endp1, rx_endp3,
                                            &mcapi_struct->request,
                                            &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the connection. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Open receive side of a packet channel. */
                        mcapi_open_pktchan_recv_i(&rx_handle, rx_endp3,
                                                  &mcapi_struct->request,
                                                  &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the open. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Wait for data on the channel. */
                            mcapi_pktchan_recv_i(rx_handle, (void**)&pkt_ptr, &request5,
                                                 &mcapi_struct->status);
                        }
                    }
                }
            }
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for the receive side of a scalar channel. */
        rx_endp4 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open receive side of a scalar channel. */
            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                      rx_endp4, &request6, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Create an endpoint for the send side of a scalar channel. */
        tx_endp2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open send side of a scalar channel. */
            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                      tx_endp2, &request7, &mcapi_struct->status);
        }
    }

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        req_ptr[0] = &request1;
        req_ptr[1] = &request2;
        req_ptr[2] = &request3;
        req_ptr[3] = &request4;
        req_ptr[4] = &request5;
        req_ptr[5] = &request6;
        req_ptr[6] = &request7;

        i = 7;

        /* Initialize status. */
        mcapi_struct->status = MCAPI_SUCCESS;

        /* Open receive side of scalar connection and issue connection. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Indicate that an endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1026,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the foreign endpoint. */
                    foreign_rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1026,
                                                         &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(tx_endp2, foreign_rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Indicate that the receive side should be opened. */
                            mcapi_struct->status =
                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                       MCAPID_MGMT_OPEN_RX_SIDE_SCL,
                                                       1026, mcapi_struct->local_endp, 500,
                                                       MCAPI_DEFAULT_PRIO);

                            /* Wait for the call to complete. */
                            finished = mcapi_wait_any(i + 1, req_ptr,
                                                      &rx_len,
                                                      MCAPI_FTS_TIMEOUT,
                                                      &mcapi_struct->status);

                            /* If the request was canceled. */
                            if ( (finished != i) ||
                                 (mcapi_struct->status != MCAPI_SUCCESS) )
                            {
                                mcapi_struct->status = -1;
                            }

                            /* Wait for a response to the open request. */
                            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                            if (status == MCAPI_SUCCESS)
                            {
                                /* Indicate that the receive side should be closed. */
                                status =
                                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                           MCAPID_MGMT_CLOSE_RX_SIDE_SCL, 1026,
                                                           mcapi_struct->local_endp, 0,
                                                           MCAPI_DEFAULT_PRIO);

                                if (status == MCAPI_SUCCESS)
                                {
                                    /* Wait for a response. */
                                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                }
                            }
                        }
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1026,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Open send side of scalar connection and issue connection. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Indicate that an endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1026,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1026,
                                                         &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_sclchan_i(foreign_tx_endp, rx_endp4,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Indicate that the send side should be opened. */
                            mcapi_struct->status =
                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                       MCAPID_MGMT_OPEN_TX_SIDE_SCL,
                                                       1026, mcapi_struct->local_endp, 500,
                                                       MCAPI_DEFAULT_PRIO);

                            /* Wait for the call to complete. */
                            finished = mcapi_wait_any(i + 1, req_ptr,
                                                      &rx_len,
                                                      MCAPI_FTS_TIMEOUT,
                                                      &mcapi_struct->status);

                            /* If the request was canceled. */
                            if ( (finished != i) ||
                                 (mcapi_struct->status != MCAPI_SUCCESS) )
                            {
                                mcapi_struct->status = -1;
                            }

                            /* Wait for a response to the open request. */
                            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                            if (status == MCAPI_SUCCESS)
                            {
                                /* Indicate that the send side should be closed. */
                                status =
                                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                           MCAPID_MGMT_CLOSE_TX_SIDE_SCL, 1026,
                                                           mcapi_struct->local_endp, 0,
                                                           MCAPI_DEFAULT_PRIO);

                                if (status == MCAPI_SUCCESS)
                                {
                                    /* Wait for a response. */
                                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                }
                            }
                        }
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1026,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Send data over packet channel connection. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Indicate that data should be transmitted over the connection. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_TX_PKT, 1025,
                                       mcapi_struct->local_endp, 500,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the call to complete. */
                finished = mcapi_wait_any(i + 1, req_ptr, &rx_len,
                                          MCAPI_FTS_TIMEOUT,
                                          &mcapi_struct->status);

                /* If the request was canceled. */
                if ( (finished != i) ||
                     (mcapi_struct->status != MCAPI_SUCCESS) )
                {
                    mcapi_struct->status = -1;
                }

                else
                {
                    mcapi_pktchan_free(pkt_ptr, &status);
                }

                /* Wait for a response to the transmission request. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }

            /* Indicate that the send side should be closed. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CLOSE_TX_SIDE_PKT, 1025,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }

            /* Indicate that an endpoint should be deleted. */
            status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1025,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                status = MCAPID_RX_Mgmt_Response(mcapi_struct);
            }
        }

        /* Open receive side of packet connection and issue connection. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Indicate that an endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1026,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the foreign endpoint. */
                    foreign_rx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1026,
                                                         &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_pktchan_i(tx_endp1, foreign_rx_endp,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Indicate that the receive side should be opened. */
                            mcapi_struct->status =
                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                       MCAPID_MGMT_OPEN_RX_SIDE_PKT,
                                                       1026, mcapi_struct->local_endp, 500,
                                                       MCAPI_DEFAULT_PRIO);

                            /* Wait for the call to complete. */
                            finished = mcapi_wait_any(i + 1, req_ptr,
                                                      &rx_len,
                                                      MCAPI_FTS_TIMEOUT,
                                                      &mcapi_struct->status);

                            /* If the request was canceled. */
                            if ( (finished != i) ||
                                 (mcapi_struct->status != MCAPI_SUCCESS) )
                            {
                                mcapi_struct->status = -1;
                            }

                            /* Wait for a response to the open request. */
                            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                            if (status == MCAPI_SUCCESS)
                            {
                                /* Indicate that the receive side should be closed. */
                                status =
                                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                           MCAPID_MGMT_CLOSE_RX_SIDE_PKT, 1026,
                                                           mcapi_struct->local_endp, 0,
                                                           MCAPI_DEFAULT_PRIO);

                                if (status == MCAPI_SUCCESS)
                                {
                                    /* Wait for a response. */
                                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                }
                            }
                        }
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1026,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Open send side of packet connection and issue connection. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Indicate that an endpoint should be created. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1026,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Get the foreign endpoint. */
                    foreign_tx_endp = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1026,
                                                         &mcapi_struct->status);

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Connect the two endpoints. */
                        mcapi_connect_pktchan_i(foreign_tx_endp, rx_endp2,
                                                &mcapi_struct->request,
                                                &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Wait for the connection. */
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                            /* Indicate that the send side should be opened. */
                            mcapi_struct->status =
                                MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                       MCAPID_MGMT_OPEN_TX_SIDE_PKT,
                                                       1026, mcapi_struct->local_endp, 500,
                                                       MCAPI_DEFAULT_PRIO);

                            /* Wait for the call to complete. */
                            finished = mcapi_wait_any(i + 1, req_ptr,
                                                      &rx_len,
                                                      MCAPI_FTS_TIMEOUT,
                                                      &mcapi_struct->status);

                            /* If the request was canceled. */
                            if ( (finished != i) ||
                                 (mcapi_struct->status != MCAPI_SUCCESS) )
                            {
                                mcapi_struct->status = -1;
                            }

                            /* Wait for a response to the open request. */
                            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                            if (status == MCAPI_SUCCESS)
                            {
                                /* Indicate that the send side should be closed. */
                                status =
                                    MCAPID_TX_Mgmt_Message(mcapi_struct,
                                                           MCAPID_MGMT_CLOSE_TX_SIDE_PKT, 1026,
                                                           mcapi_struct->local_endp, 0,
                                                           MCAPI_DEFAULT_PRIO);

                                if (status == MCAPI_SUCCESS)
                                {
                                    /* Wait for a response. */
                                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                                }
                            }
                        }
                    }

                    /* Indicate that an endpoint should be deleted. */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1026,
                                               mcapi_struct->local_endp, 0,
                                               MCAPI_DEFAULT_PRIO);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Wait for a response. */
                        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                    }
                }
            }
        }

        /* Send message to open receive endpoint. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Create foreign endpoint. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1026,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for a response. */
                mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Save the local endpoint. */
                    local_endp = mcapi_struct->local_endp;

                    /* Set the receive endpoint. */
                    mcapi_struct->local_endp = rx_endp1;

                    /* Cause the other side to send a message to the other endpoint. */
                    mcapi_struct->status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_TX_BLCK_MSG, 1026,
                                               mcapi_struct->local_endp, 500,
                                               MCAPI_DEFAULT_PRIO);

                    /* Wait for the call to complete. */
                    finished = mcapi_wait_any(i + 1, req_ptr, &rx_len,
                                              MCAPI_FTS_TIMEOUT,
                                              &mcapi_struct->status);

                    /* If the request was canceled. */
                    if ( (finished != i) ||
                         (mcapi_struct->status != MCAPI_SUCCESS) )
                    {
                        mcapi_struct->status = -1;
                    }

                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);

                    /* Restore the local endpoint. */
                    mcapi_struct->local_endp = local_endp;

                    /* Cause the other side to delete the endpoint */
                    status =
                        MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1026,
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

        /* Create foreign endpoint. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;

            /* Create foreign endpoint. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                       mcapi_struct->local_endp, 500,
                                       MCAPI_DEFAULT_PRIO);

            /* Wait for the call to complete. */
            finished = mcapi_wait_any(i + 1, req_ptr, &rx_len,
                                      MCAPI_FTS_TIMEOUT,
                                      &mcapi_struct->status);

            /* If the request was canceled. */
            if ( (finished != i) ||
                 (mcapi_struct->status != MCAPI_SUCCESS) )
            {
                mcapi_struct->status = -1;
            }

            /* Wait for the response. */
            status = MCAPID_RX_Mgmt_Response(mcapi_struct);

            if (status == MCAPI_SUCCESS)
            {
                /* Cause the other side to delete the endpoint */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            i --;
        }

        /* Cancel each remaining request. */
        for (; i >= 0; i --)
        {
            mcapi_cancel(req_ptr[i], &status);
        }
    }

    /* Close the channels. */
    mcapi_packetchan_recv_close_i(rx_handle, &mcapi_struct->request, &status);
    mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle, &mcapi_struct->request, &status);
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle, &mcapi_struct->request, &status);
    mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle, &mcapi_struct->request, &status);
    mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle, &mcapi_struct->request, &status);

    /* Delete each endpoint. */
    mcapi_delete_endpoint(rx_endp1, &status);
    mcapi_delete_endpoint(rx_endp2, &status);
    mcapi_delete_endpoint(rx_endp3, &status);
    mcapi_delete_endpoint(rx_endp4, &status);
    mcapi_delete_endpoint(tx_endp1, &status);
    mcapi_delete_endpoint(tx_endp2, &status);

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_35_66 */
#endif
