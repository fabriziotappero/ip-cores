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

extern MCAPI_MUTEX              MCAPID_FTS_Mutex;
extern MCAPI_GLOBAL_DATA        MCAPI_Global_Struct;

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_3_1
*
*   DESCRIPTION
*
*       Testing mcapi_create_endpoint to ensure the global port ID
*       counter rolls over properly.
*
*           Node 1 – Create and delete endpoints with port ID
*           MCAPI_PORT_ANY.  Ensure the port ID is reset to
*           CFG_MULTIOS_IPC_MCAPI_ENDP_PORT_INIT when the value rolls
*           over.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_3_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_uint32_t      i, res_count;
    mcapi_endpoint_t    first_endpoint, endp;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Save the current number of endpoints that exist in the system. */
    res_count = MCAPI_Global_Struct.mcapi_node_list[0].mcapi_endpoint_count;

    /* Create an delete enough endpoints to cause the global port ID counter
     * to roll over.
     */
    for (i = 0; i <= 65535 - res_count; i ++)
    {
        /* Create an endpoint. */
        endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Delete the endpoint. */
            mcapi_delete_endpoint(endp, &mcapi_struct->status);
        }

        else
        {
            break;
        }

        /* Store the first value. */
        if (i == 0)
        {
            first_endpoint = endp;
        }
    }

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Create an endpoint and ensure it matches the first endpoint; ie,
         * the global counter rolled over properly.
         */
        endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            if (first_endpoint != endp)
            {
                mcapi_struct->status = -1;
            }

            /* Delete the endpoint. */
            mcapi_delete_endpoint(endp, &status);
        }
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_3_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_3_2
*
*   DESCRIPTION
*
*       Testing mcapi_create_endpoint with duplicate port ID.
*
*           Node 1 – Attempt to create two endpoints with the same port
*           ID.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_3_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint;
    mcapi_status_t      status;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Create a valid endpoint. */
    endpoint = mcapi_create_endpoint(1024, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* Attempt to create the same endpoint again. */
        mcapi_create_endpoint(1024, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_ERR_ENDP_EXISTS)
        {
            mcapi_struct->status = MCAPI_SUCCESS;
        }

        /* Delete the endpoint. */
        mcapi_delete_endpoint(endpoint, &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_3_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_3_3
*
*   DESCRIPTION
*
*       Testing mcapi_create_endpoint using up all available
*       endpoint structures.
*
*           Node 1 – Create endpoints until all structures are used up.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_3_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_endpoint_t    endpoint[MCAPI_MAX_ENDPOINTS],
                        bad_endpoint;
    mcapi_status_t      status;
    mcapi_uint32_t      i, j, res_count;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Save the count of the number of endpoints that exist in the system at this
     * moment.
     */
    res_count = MCAPI_Global_Struct.mcapi_node_list[0].mcapi_endpoint_count;

    /* Use up all endpoint structures. */
    for (i = 0;
         i < MCAPI_MAX_ENDPOINTS - res_count;
         i ++)
    {
        endpoint[i] = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

        if (mcapi_struct->status != MCAPI_SUCCESS)
        {
            break;
        }
    }

    /* Attempt to create one more endpoint. */
    bad_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_ERR_GENERAL)
    {
        mcapi_struct->status = MCAPI_SUCCESS;
    }

    else
    {
        mcapi_struct->status = -1;

        /* If the all succeeded, delete the endpoint. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            mcapi_delete_endpoint(bad_endpoint, &status);
        }
    }

    /* Delete all the endpoints. */
    for (j = 0; j < i; j ++)
    {
        mcapi_delete_endpoint(endpoint[j], &status);
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_3_3 */
