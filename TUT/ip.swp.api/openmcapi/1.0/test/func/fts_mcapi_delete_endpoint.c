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
*       MCAPI_FTS_Tx_2_6_1
*
*   DESCRIPTION
*
*       Testing mcapi_delete_endpoint with one message on the endpoint
*       waiting to be received.
*
*           Node 0 – Creates endpoint on boot up, transmit one message to
*           Node 1.
*
*           Node 1 – Create endpoint, wait for Node 0 to send data, delete
*           endpoint.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_6_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_status_t      status;

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
            /* Indicate that a blocking TX call should be made from port
             * 1024.
             */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_TX_BLCK_MSG, 1024,
                                       mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for data to be received on the local endpoint. */
                while (mcapi_msg_available(mcapi_struct->local_endp, &status) == 0)
                {
                    MCAPID_Sleep(250);
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

            /* Delete the local endpoint. */
            mcapi_delete_endpoint(mcapi_struct->local_endp, &mcapi_struct->status);
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_6_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_6_2
*
*   DESCRIPTION
*
*       Testing mcapi_delete_endpoint for packet channel connected
*       endpoint.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0, open send
*           side of connection, issue connection, delete send endpoint.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_6_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Delete the local endpoint - the connection was made at start up, so this
     * call should fail.
     */
    mcapi_delete_endpoint(mcapi_struct->local_endp, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MCAPI_ERR_CHAN_OPEN);

    /* Close the send side of the connection. */
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                  &mcapi_struct->request, &status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_6_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_6_3
*
*   DESCRIPTION
*
*       Testing mcapi_delete_endpoint for scalar channel connected
*       endpoint.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0, open send
*           side of connection, issue connection, delete send endpoint.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_6_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;
    mcapi_request_t     request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Connect the two endpoints. */
    mcapi_connect_sclchan_i(mcapi_struct->local_endp,
                            mcapi_struct->foreign_endp,
                            &mcapi_struct->request,
                            &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    mcapi_wait(&mcapi_struct->request, &rx_len,
               &mcapi_struct->status, MCAPI_FTS_TIMEOUT);
    status_assert(mcapi_struct->status);

    /* Open the local endpoint as the sender. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp, &request,
                              &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Delete the local endpoint, which should fail. */
    mcapi_delete_endpoint(mcapi_struct->local_endp, &mcapi_struct->status);
    status_assert_code(mcapi_struct->status, MCAPI_ERR_CHAN_OPEN);

    /* Close the send side of the connection. */
    mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                               &mcapi_struct->request, &mcapi_struct->status);
    status_assert(mcapi_struct->status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_6_3 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_6_4
*
*   DESCRIPTION
*
*       Testing mcapi_delete_endpoint for half open packet connection.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0,
*           issue connection, delete send endpoint.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_6_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the packet server endpoint. */
    mcapi_struct->status =
        MCAPID_Get_Service("pkt_svr", &mcapi_struct->foreign_endp);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(mcapi_struct->local_endp,
                                mcapi_struct->foreign_endp,
                                &mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for the connection to return successfully. */
            mcapi_wait(&mcapi_struct->request, &rx_len,
                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);
        }

        /* Delete the local endpoint.  An endpoint in a half-open connection
         * can be deleted.
         */
        mcapi_delete_endpoint(mcapi_struct->local_endp, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Let the other side process the fin. */
            MCAPID_Sleep(1000);

            /* Create another new endpoint. */
            mcapi_struct->local_endp =
                mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            /* Issue another connection to ensure the connection request for
             * the previous connection was canceled when the endpoint was
             * deleted.
             */
            mcapi_connect_pktchan_i(mcapi_struct->local_endp,
                                    mcapi_struct->foreign_endp,
                                    &mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the connection to return successfully. */
                mcapi_wait(&mcapi_struct->request, &rx_len,
                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                /* Delete the new endpoint. */
                mcapi_delete_endpoint(mcapi_struct->local_endp,
                                      &mcapi_struct->status);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_6_4 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_6_5
*
*   DESCRIPTION
*
*       Testing mcapi_delete_endpoint for half open scalar connection.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0,
*           issue connection, delete send endpoint.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_6_5)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              rx_len;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the packet server endpoint. */
    mcapi_struct->status =
        MCAPID_Get_Service("scl_svr", &mcapi_struct->foreign_endp);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(mcapi_struct->local_endp,
                                mcapi_struct->foreign_endp,
                                &mcapi_struct->request, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Wait for the connection to return successfully. */
            mcapi_wait(&mcapi_struct->request, &rx_len,
                       &mcapi_struct->status, MCAPI_FTS_TIMEOUT);
        }

        /* Delete the local endpoint.  An endpoint in a half-open connection
         * can be deleted.
         */
        mcapi_delete_endpoint(mcapi_struct->local_endp, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Let the other side process the fin. */
            MCAPID_Sleep(1000);

            /* Create another new endpoint. */
            mcapi_struct->local_endp =
                mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

            /* Issue another connection to ensure the connection request for
             * the previous connection was canceled when the endpoint was
             * deleted.
             */
            mcapi_connect_sclchan_i(mcapi_struct->local_endp,
                                    mcapi_struct->foreign_endp,
                                    &mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Wait for the connection to return successfully. */
                mcapi_wait(&mcapi_struct->request, &rx_len,
                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                /* Delete the new endpoint. */
                mcapi_delete_endpoint(mcapi_struct->local_endp,
                                      &mcapi_struct->status);
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_6_5 */
