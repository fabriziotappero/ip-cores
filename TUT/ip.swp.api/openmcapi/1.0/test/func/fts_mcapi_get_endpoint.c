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
*       MCAPI_FTS_Tx_2_5_1
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint for foreign endpoint, endpoint not
*       created upon issuance of request.
*
*           Node 0 – Waits for get endpoint request, then creates endpoint.
*           Node 1 – Issues get endpoint request.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_5_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Indicate that the endpoint should be created. */
    status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_CREATE_ENDP,
                                    1024, mcapi_struct->local_endp, 2000,
                                    MCAPI_DEFAULT_PRIO);
    status_assert(status);

    /* Get the foreign endpoint. */
    endpoint = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &status);
    status_assert(status);

    /* If the endpoint was created. */
    if (endpoint != 0xffffffff)
    {
        /* Tell the other side to delete the endpoint. */
        status = MCAPID_TX_Mgmt_Message(mcapi_struct, MCAPID_MGMT_DELETE_ENDP,
                                        1024, mcapi_struct->local_endp, 0,
                                        MCAPI_DEFAULT_PRIO);
        status_assert(status);

        /* Wait for the response before releasing the mutex. */
        status = MCAPID_RX_Mgmt_Response(mcapi_struct);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_5_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_5_2
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint for foreign endpoint.  Endpoint already
*       exists upon issuance of request.
*
*           Node 0 – Creates endpoint.
*           Node 1 – Issues get endpoint request.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_5_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint = 0xffffffff;
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
            endpoint = mcapi_get_endpoint(FUNC_BACKEND_NODE_ID, 1024, &mcapi_struct->status);

            if ( (mcapi_struct->status == MCAPI_SUCCESS) && (endpoint != 0xffffffff) )
            {
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

} /* MCAPI_FTS_Tx_2_5_2 */
