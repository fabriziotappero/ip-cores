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
*       MCAPI_FTS_Tx_2_27_1
*
*   DESCRIPTION
*
*       Testing mcapi_open_sclchan_send_i - open send side for endpoint
*       connected as receiver.
*
*           Node 0 – Create an endpoint, open the endpoint as a sender
*
*           Node 1 – Create an endpoint, get endpoint on Node 0, issue
*                    connection, open the endpoint as a sender
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_27_1)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_endpoint_t            tx_endp;
    mcapi_request_t             request;
    mcapi_endpoint_t            endp;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* An extra endpoint is required for this session. */
    endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

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
                            /* Connect the two endpoints. */
                            mcapi_connect_sclchan_i(tx_endp, endp,
                                                    &mcapi_struct->request,
                                                    &mcapi_struct->status);

                            if (mcapi_struct->status == MCAPI_SUCCESS)
                            {
                                mcapi_wait(&mcapi_struct->request, &rx_len,
                                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                                if (mcapi_struct->status == MCAPI_SUCCESS)
                                {
                                    /* Open the local endpoint as the sender too. */
                                    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                              endp, &request,
                                                              &mcapi_struct->status);

                                    /* Check for the correct error. */
                                    if (mcapi_struct->status == MCAPI_ERR_CHAN_DIRECTION)
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

        /* Delete the endpoint used for this session. */
        mcapi_delete_endpoint(endp, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_27_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_27_2
*
*   DESCRIPTION
*
*       Testing mcapi_open_sclchan_send_i - duplicate call
*
*           Node 1 – Create an endpoint, open the endpoint as a sender,
*                    open the endpoint as a sender again
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_27_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_request_t     request;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the local endpoint as the sender. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &request, &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Open the local endpoint as the sender again. */
        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                  mcapi_struct->local_endp,
                                  &mcapi_struct->request, &mcapi_struct->status);

        /* Ensure the proper error code was returned. */
        if (mcapi_struct->status == MCAPI_ERR_CHAN_CONNECTED)
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        else
        {
            mcapi_struct->status = -1;
        }

        /* Close the send side. */
        mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                   &mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_27_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_27_3
*
*   DESCRIPTION
*
*       Testing mcapi_open_sclchan_send_i - reopen the same endpoint -
*       never connected
*
*           Node 1 – Create an endpoint, open the endpoint as a sender,
*                    close, open the endpoint as a sender again
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_27_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_request_t     request;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Open the local endpoint as the sender. */
    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                              mcapi_struct->local_endp,
                              &request, &mcapi_struct->status);

    if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
    {
        /* Close the send side. */
        mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                   &mcapi_struct->request,
                                   &mcapi_struct->status);

        /* Ensure the proper error code was returned. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Open the local endpoint as the sender again. */
            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                      mcapi_struct->local_endp,
                                      &request, &mcapi_struct->status);

            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
            {
                mcapi_struct->status = MCAPI_SUCCESS;
            }

            else
            {
                mcapi_struct->status = -1;
            }

            /* Close the send side. */
            mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                       &mcapi_struct->request, &status);
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_27_3 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_27_4
*
*   DESCRIPTION
*
*       Testing mcapi_open_sclchan_send_i - reopen same endpoint -
*       half connected.
*
*           Node 0 – Create endpoint
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, open
*                    the endpoint as a sender, issue the connection,
*                    close, open the endpoint as a sender again.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_27_4)
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
                        /* Wait for the connect call to return successfully. */
                        mcapi_wait(&mcapi_struct->request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Close the send side. */
                        mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                   &mcapi_struct->request,
                                                   &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Let the control task run. */
                            MCAPID_Sleep(1000);

                            /* Open the local endpoint again as the sender. */
                            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                      mcapi_struct->local_endp, &request,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                mcapi_struct->status = MCAPI_SUCCESS;

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &mcapi_struct->request,
                                                           &status);
                            }

                            else
                            {
                                mcapi_struct->status = -1;
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

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_27_4 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_27_5
*
*   DESCRIPTION
*
*       Testing mcapi_open_sclchan_send_i - reopen same endpoint -
*       previously connected
*
*           Node 0 – Create an endpoint, open receive side
*
*           Node 1 – Create an endpoint, get the endpoint on Node 0, open
*                    the endpoint as a sender, issue the connection,
*                    close, open the endpoint as a sender again
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_27_5)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t                      rx_len;
    mcapi_status_t              status;
    mcapi_request_t             request;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Send a message to the scalar service indicating any type of receive. */
    mcapi_struct->status =
        MCAPI_FTS_Specify_Scalar_Size(mcapi_struct, MCAPID_RX_64_BIT_SCL);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Wait for the response. */
        mcapi_struct->status = MCAPID_RX_Mgmt_Response(mcapi_struct);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Connect the two endpoints. */
            mcapi_connect_sclchan_i(mcapi_struct->local_endp,
                                    mcapi_struct->foreign_endp,
                                    &mcapi_struct->request,
                                    &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                mcapi_wait(&mcapi_struct->request, &rx_len,
                           &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Open the local endpoint as the sender. */
                    mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                              mcapi_struct->local_endp, &request,
                                              &mcapi_struct->status);

                    /* Check for the correct error. */
                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Wait for the open call to return successfully. */
                        mcapi_wait(&request, &rx_len,
                                   &mcapi_struct->status, MCAPI_FTS_TIMEOUT);

                        /* Close the send side. */
                        mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                   &request, &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Let the control task run. */
                            MCAPID_Sleep(1000);

                            /* Open the local endpoint again as the sender. */
                            mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                      mcapi_struct->local_endp,
                                                      &request,
                                                      &mcapi_struct->status);

                            if (mcapi_struct->status == MGC_MCAPI_ERR_NOT_CONNECTED)
                            {
                                mcapi_struct->status = MCAPI_SUCCESS;

                                /* Close the send side. */
                                mcapi_sclchan_send_close_i(mcapi_struct->scl_tx_handle,
                                                           &mcapi_struct->request,
                                                           &status);
                            }
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

} /* MCAPI_FTS_Tx_2_27_5 */
