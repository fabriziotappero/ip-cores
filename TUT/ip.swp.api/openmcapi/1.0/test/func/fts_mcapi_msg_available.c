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
*       MCAPI_FTS_Tx_2_13_1
*
*   DESCRIPTION
*
*       Testing mcapi_msg_available with one message on the endpoint.
*
*           Node 0 – Create endpoint, check for message count on endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_13_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t              count;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Check the number of messages on the endpoint. */
    count =
        mcapi_msg_available(mcapi_struct->local_endp, &mcapi_struct->status);

    /* There should be no data on the endpoint. */
    if ( (count != 0) || (mcapi_struct->status != MCAPI_SUCCESS) )
    {
        mcapi_struct->status = -1;
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_13_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_13_2
*
*   DESCRIPTION
*
*       Testing mcapi_msg_available with one message on the endpoint.
*
*           Node 1 – Create endpoint, transmit one packet to Node 1
*
*           Node 0 – Create endpoint, indicate to Node 0 to transmit
*                    one message, check for message count on endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_13_2)
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
            /* Issue a NO OP to cause just one message to be sent. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Check the number of messages on the endpoint. */
                while (mcapi_msg_available(mcapi_struct->local_endp,
                                           &mcapi_struct->status) == 0)
                {
                    if (mcapi_struct->status != MCAPI_SUCCESS)
                        break;

                    MCAPID_Sleep(250);
                }

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Make the call to receive the data. */
                    mcapi_msg_recv(mcapi_struct->local_endp, buffer,
                                   MCAPID_MGMT_PKT_LEN, &rx_len, &mcapi_struct->status);
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

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_13_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_13_3
*
*   DESCRIPTION
*
*       Testing mcapi_msg_available with two messages on the endpoint.
*
*           Node 1 – Create endpoint, transmit two packets to Node 1
*
*           Node 0 – Create endpoint, indicate to Node 0 to transmit
*                    two messages, check for message count on endpoint
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_13_3)
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
            /* Issue a NO OP to cause a message to be sent. */
            mcapi_struct->status =
                MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                       mcapi_struct->local_endp, 0,
                                       MCAPI_DEFAULT_PRIO);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Issue a second NO OP to cause another message to be sent. */
                mcapi_struct->status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_NO_OP, 1024,
                                           mcapi_struct->local_endp, 0,
                                           MCAPI_DEFAULT_PRIO);

                if (mcapi_struct->status == MCAPI_SUCCESS)
                {
                    /* Check the number of messages on the endpoint. */
                    while (mcapi_msg_available(mcapi_struct->local_endp,
                                               &mcapi_struct->status) != 2)
                    {
                        if (mcapi_struct->status != MCAPI_SUCCESS)
                            break;

                        MCAPID_Sleep(250);
                    }

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Make the call to receive the data. */
                        mcapi_msg_recv(mcapi_struct->local_endp, buffer,
                                       MCAPID_MGMT_PKT_LEN, &rx_len,
                                       &mcapi_struct->status);

                        if (mcapi_struct->status == MCAPI_SUCCESS)
                        {
                            /* Make the call to receive the data. */
                            mcapi_msg_recv(mcapi_struct->local_endp, buffer,
                                           MCAPID_MGMT_PKT_LEN, &rx_len,
                                           &mcapi_struct->status);
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

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_13_3 */
