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
*       MCAPI_FTS_Tx_2_34_1
*
*   DESCRIPTION
*
*       Testing mcapi_wait while getting a foreign endpoint - timeout
*       occurs before endpoint created
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
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
        /* Wait for the call to timeout. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, 250);

        if ( (finished == MCAPI_FALSE) &&
             (mcapi_struct->status == MCAPI_TIMEOUT) )
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

} /* MCAPI_FTS_Tx_2_34_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_2
*
*   DESCRIPTION
*
*       Testing mcapi_wait while getting a foreign endpoint - request
*       canceled
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion, request canceled.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_2)
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
        /* Indicate that the request should be canceled in 1000 milliseconds. */
        mcapi_struct->status =
            MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_CANCEL_REQUEST, 0,
                                   mcapi_struct->local_endp, 1000,
                                   MCAPI_DEFAULT_PRIO);

        /* Wait for the other thread to cancel the request. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                              MCAPI_FTS_TIMEOUT);

        if ( (finished == MCAPI_FALSE) &&
             (mcapi_struct->status == MCAPI_ERR_REQUEST_CANCELLED) )
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

} /* MCAPI_FTS_Tx_2_34_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_3
*
*   DESCRIPTION
*
*       Testing mcapi_wait while getting a foreign endpoint - endpoint
*       retrieved
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request for non-existent endpoint
*                    on Node 0, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_3)
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
                                   mcapi_struct->local_endp, 500,
                                   MCAPI_DEFAULT_PRIO);

        /* Wait for the endpoint to be created. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                              MCAPI_FTS_TIMEOUT);

        if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_3 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_4
*
*   DESCRIPTION
*
*       Testing mcapi_wait while getting a foreign endpoint - endpoint
*       retrieved, two requests outstanding
*
*           Node 0 – Wait for get endpoint request, create endpoint
*
*           Node 1 – Issue get endpoint request to Node 0, issue a second
*                    get from another thread, wait for completion by both
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    mcapi_endpoint_t    endpoint = 0xffffffff;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

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
                /* Wait for the endpoint to be created. */
                finished = mcapi_wait(&svc_struct.request, &rx_len, &mcapi_struct->status,
                                      MCAPI_FTS_TIMEOUT);

                if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_4 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_5
*
*   DESCRIPTION
*
*       Testing mcapi_wait for completed transmission using
*       mcapi_msg_send_i.
*
*           Node 0 – Create an endpoint, wait for data
*
*           Node 1 – Issue get endpoint request, transmit data, wait
*                    for completed transmission
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_5)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MSG_LEN];
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
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_5 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_6
*
*   DESCRIPTION
*
*       Testing mcapi_wait receiving data using mcapi_msg_recv_i -
*       incomplete.
*
*           Node 1 – Create endpoint, issue receive request, wait for
*                    timeout
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_6)
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
            mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status, 250);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
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

} /* MCAPI_FTS_Tx_2_34_6 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_7
*
*   DESCRIPTION
*
*       Testing mcapi_wait receiving data using mcapi_msg_recv_i -
*       complete.
*
*           Node 0 - Create endpoint, wait for other side to issue call
*                    to receive data, send data to Node 1.
*
*           Node 1 – Create endpoint, issue receive request, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_7)
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
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 1000, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the data. */
                finished =
                    mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_7 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_8
*
*   DESCRIPTION
*
*       Testing mcapi_wait receiving data using mcapi_msg_recv_i -
*       call canceled.
*
*           Node 0 - Create endpoint, wait for other side to cancel call
*                    to receive data, send data to Node 1.
*
*           Node 1 – Create endpoint, issue receive request, cancel call,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_8)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    char                buffer[MCAPID_MGMT_PKT_LEN];
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;

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
                /* Wait for the data. */
                finished = mcapi_wait(&svc_struct.request, &rx_len,
                                      &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_8 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_9
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_connect_pktchan_i - completed
*
*           Node 0 – Create an endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, issue
*                    connection, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_9)
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
                        /* The connect call will return successfully. */
                        finished =
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_9 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_10
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_pktchan_recv_i - timed out
*
*           Node 1 – Create endpoint, open receive side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_10)
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
        /* Wait for completion to timeout. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, 250);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
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

} /* MCAPI_FTS_Tx_2_34_10 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_11
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_11)
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
                        /* Open the receive side. */
                        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        /* Wait for the completion. */
                        finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                              MCAPI_FTS_TIMEOUT);

                        if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_11 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_12
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_pktchan_recv_i - canceled
*
*           Node 1 – Create endpoint, open receive side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_12)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;

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
            /* Wait for the call to be canceled. */
            finished = mcapi_wait(&svc_struct.request, &rx_len,
                                  &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_12 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_13
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_pktchan_send_i - timed out
*
*           Node 1 – Create endpoint, open send side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_13)
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
        /* Wait for completion to timeout. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, 250);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
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

} /* MCAPI_FTS_Tx_2_34_13 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_14
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_pktchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side.
*
*           Node 1 – Create endpoint, connect, open send side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_14)
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
                        /* Open the send side. */
                        mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        /* Wait for the completion. */
                        finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                              MCAPI_FTS_TIMEOUT);

                        if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_14 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_15
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_pktchan_send_i - canceled
*
*           Node 1 – Create endpoint, open send side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_15)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;

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
            /* Wait for the call to be canceled. */
            finished = mcapi_wait(&svc_struct.request, &rx_len,
                                  &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_15 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_16
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side, wait for data.
*
*           Node 1 – Create endpoint, open send side, connect, send data,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_16)
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
        /* Wait for completion. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

        if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_16 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_17
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_i - timed out
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_17)
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
                                /* Wait for the completion. */
                                finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                                                      &mcapi_struct->status, 250);

                                if ( (finished == MCAPI_FALSE) &&
                                     (mcapi_struct->status == MCAPI_TIMEOUT) )
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

} /* MCAPI_FTS_Tx_2_34_17 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_18
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side, send data.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_18)
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
                                                               1000, MCAPI_DEFAULT_PRIO);

                                    if (mcapi_struct->status == MCAPI_SUCCESS)
                                    {
                                        /* Wait for the response. */
                                        mcapi_struct->status =
                                            MCAPID_RX_Mgmt_Response(mcapi_struct);

                                        if (mcapi_struct->status == MCAPI_SUCCESS)
                                        {
                                            /* Test for the completion. */
                                            finished = mcapi_wait(&mcapi_struct->request,
                                                                  &rx_len,
                                                                  &mcapi_struct->status,
                                                                  MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_18 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_19
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_i - canceled
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, issue
*                    receive call, cancel receive call, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_19)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_status_t      status;
    mcapi_boolean_t     finished;
    mcapi_request_t     request;
    mcapi_endpoint_t    tx_endp, rx_endp;
    char                *buffer;

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
                                        /* Test for the completion. */
                                        finished = mcapi_wait(&svc_struct.request,
                                                              &rx_len,
                                                              &mcapi_struct->status,
                                                              MCAPI_FTS_TIMEOUT);

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

    /* Destroy the client service that will cancel the call. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_19 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_20
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_close_i - tx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open receive side, close receive
*                    side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_20)
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
            /* Wait for the completion to time out. */
            finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                  MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_20 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_21
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_close_i - tx opened,
*       not connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, open receive side, wait for Node 0 to
*                    open send side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_21)
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
                        /* Wait for the completion to time out. */
                        finished = mcapi_wait(&request, &rx_len,
                                              &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_21 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_22
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_close_i - tx opened,
*       connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, issue connection, open receive side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_22)
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
                                        finished = mcapi_wait(&request, &rx_len,
                                                              &mcapi_struct->status,
                                                              MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_22 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_23
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_close_i - rx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open send side, close send
*                    side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_23)
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
            finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                  MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_23 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_24
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_close_i - rx opened,
*       not connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, open send side, wait for Node 0 to
*                    open receive side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_24)
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
                        finished = mcapi_wait(&request, &rx_len,
                                              &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_24 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_25
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_pktchan_send_close_i - rx opened,
*       connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, issue connection, open send side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_25)
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
                                        finished = mcapi_wait(&request, &rx_len,
                                                              &mcapi_struct->status,
                                                              MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_25 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_26
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_connect_sclchan_i - completed
*
*           Node 0 – Create an endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, issue
*                    connection, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_26)
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
                        /* The connect call will return successfully. */
                        finished =
                            mcapi_wait(&mcapi_struct->request, &rx_len,
                                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

        /* Delete the extra endpoint. */
        mcapi_delete_endpoint(rx_endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_26 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_27
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_sclchan_recv_i - timed out
*
*           Node 1 – Create endpoint, open receive side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_27)
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
        /* Wait for completion to timeout. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, 250);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
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

} /* MCAPI_FTS_Tx_2_34_27 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_28
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_recv_i - complete
*
*           Node 0 - Create endpoint, open send side.
*
*           Node 1 – Create endpoint, connect, open receive side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_28)
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
                        /* Open the receive side. */
                        mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        /* Wait for the completion. */
                        finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                              MCAPI_FTS_TIMEOUT);

                        if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_28 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_29
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_sclchan_recv_i - canceled
*
*           Node 1 – Create endpoint, open receive side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_29)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;

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
            /* Wait for the call to be canceled. */
            finished = mcapi_wait(&svc_struct.request, &rx_len,
                                  &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_29 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_30
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_sclchan_send_i - timed out
*
*           Node 1 – Create endpoint, open send side, wait for
*                    open to time out
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_30)
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
        /* Wait for completion to timeout. */
        finished = mcapi_wait(&mcapi_struct->request, &rx_len,
                              &mcapi_struct->status, 250);

        if ( (mcapi_struct->status == MCAPI_TIMEOUT) &&
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

} /* MCAPI_FTS_Tx_2_34_30 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_31
*
*   DESCRIPTION
*
*       Testing mcapi_test over mcapi_open_sclchan_send_i - complete
*
*           Node 0 - Create endpoint, open receive side.
*
*           Node 1 – Create endpoint, connect, open send side, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_31)
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
                        /* Open the send side. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &request, &mcapi_struct->status);

                        /* Wait for the completion. */
                        finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                              MCAPI_FTS_TIMEOUT);

                        if ( (finished != MCAPI_TRUE) ||
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

} /* MCAPI_FTS_Tx_2_34_31 */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_32
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_open_sclchan_send_i - canceled
*
*           Node 1 – Create endpoint, open send side, cancel, wait for
*                    completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_32)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv, svc_struct;
    size_t              rx_len;
    mcapi_boolean_t     finished;

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
            /* Wait for the call to be canceled. */
            finished = mcapi_wait(&svc_struct.request, &rx_len,
                                  &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

    /* Destroy the client service. */
    MCAPID_Destroy_Service(&svc_struct, 1);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_34_32 */
#endif

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_33
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_sclchan_recv_close_i - tx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open receive side, close receive
*                    side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_33)
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
            /* Wait for the completion to time out. */
            finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                  MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_33 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_34
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_sclchan_recv_close_i - tx opened,
*       not connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, open receive side, wait for Node 0 to
*                    open send side, wait for completion
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_34)
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
                        /* Wait for the completion to time out. */
                        finished = mcapi_wait(&request, &rx_len,
                                              &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_34 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_35
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_pktchan_recv_close_i - tx opened,
*       connected
*
*           Node 0 - Create endpoint, open send side
*
*           Node 1 – Create endpoint, issue connection, open receive side,
*                    wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_35)
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
                                        finished = mcapi_wait(&request, &rx_len,
                                                              &mcapi_struct->status,
                                                              MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_35 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_36
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_sclchan_send_close_i - rx not
*       opened, not connected
*
*           Node 1 – Create endpoint, open send side, close send
*                    side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_36)
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
            finished = mcapi_wait(&request, &rx_len, &mcapi_struct->status,
                                  MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_36 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_37
*
*   DESCRIPTION
*
*       Testing mcapi_wait over mcapi_sclchan_send_close_i - rx opened,
*       not connected
*
*           Node 0 - Create endpoint, open receive side
*
*           Node 1 – Create endpoint, open send side, wait for Node 0 to
*                    open receive side, wait for completion.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_37)
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
                        finished = mcapi_wait(&request, &rx_len,
                                              &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_37 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_34_38
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
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_34_38)
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
                                        finished = mcapi_wait(&request, &rx_len,
                                                              &mcapi_struct->status,
                                                              MCAPI_FTS_TIMEOUT);

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

} /* MCAPI_FTS_Tx_2_34_38 */
