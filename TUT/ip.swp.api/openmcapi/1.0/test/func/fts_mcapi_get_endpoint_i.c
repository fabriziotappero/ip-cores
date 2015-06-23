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
*       MCAPI_FTS_Tx_2_4_1
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_i for foreign endpoint:
*
*           Node 0 – Waits for get endpoint request, then creates endpoint.
*           Node 1 – Issues get endpoint request, then calls mcapi_wait()
*                    with infinite timeout.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_4_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);

    /* Indicate that the endpoint should be created. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);
    status_assert(status);

    /* Wait for a response. */
    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(status);

    mcapi_wait(&mcapi_struct->request, &rx_len, &status, 5000);
    status_assert(status);

    /* Tell the other side to delete the endpoint. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                    mcapi_struct->local_endp, 0,
                                    MCAPI_DEFAULT_PRIO);
    status_assert(status);

    /* Wait for a response before releasing the mutex. */
    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    status_assert(status);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_4_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_4_2
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_i for foreign endpoint:
*
*           Node 1 – Issues get endpoint request, then calls mcapi_wait()
*                    with 2000 millisecond timeout.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_4_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    size_t              rx_len;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the foreign endpoint. */
    mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                         &mcapi_struct->request, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* The test call should return incomplete. */
        mcapi_test(&mcapi_struct->request, &rx_len, &status);

        if (status != MCAPI_PENDING)
        {
            mcapi_struct->status = -1;
        }

        /* Cancel the get endpoint request. */
        mcapi_cancel(&mcapi_struct->request, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_4_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_4_3
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_i for foreign endpoint:
*
*           Node 0 – Creates endpoint.
*           Node 1 – Issues get endpoint request, then calls mcapi_wait()
*                    with infinite timeout.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_4_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
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
            /* Get the foreign endpoint. */
            mcapi_get_endpoint_i(FUNC_BACKEND_NODE_ID, 1024, &endpoint,
                                 &mcapi_struct->request, &mcapi_struct->status);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* The wait call should return success. */
                mcapi_wait(&mcapi_struct->request, &rx_len,
                           &mcapi_struct->status, 5000);

                /* Tell the other side to delete the endpoint. */
                status =
                    MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP, 1024,
                                           mcapi_struct->local_endp, 0, MCAPI_DEFAULT_PRIO);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for the response before releasing the mutex. */
                    status = MCAPID_RX_Mgmt_Response(mcapi_struct);
                }
            }
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_4_3 */
