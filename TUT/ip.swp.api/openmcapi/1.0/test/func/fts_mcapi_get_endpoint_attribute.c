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
*       MCAPI_FTS_Tx_2_7_1
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_attribute get MCAPI_ATTR_ENDP_PRIO for
*       unconnected endpoint.
*
*           Node 1 – Create endpoint, get MCAPI_ATTR_ENDP_PRIO.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_7_1)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_priority_t    priority;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the priority of the endpoint. */
    mcapi_get_endpoint_attribute(mcapi_struct->local_endp, MCAPI_ATTR_ENDP_PRIO,
                                 (void*)&priority, sizeof(priority),
                                 &mcapi_struct->status);

    /* Ensure the proper value was returned. */
    if ( (mcapi_struct->status != MCAPI_SUCCESS) ||
         (priority != MCAPI_DEFAULT_PRIO) )
    {
        mcapi_struct->status = -1;
    }

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_7_1 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_7_2
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_attribute for MCAPI_ATTR_NO_BUFFERS.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0, open send
*           side of connection, issue connection, get MCAPI_ATTR_NO_BUFFERS.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_7_2)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_status_t      status;
    mcapi_uint32_t      buf_count;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the number of buffers on the endpoint. */
    mcapi_get_endpoint_attribute(mcapi_struct->local_endp, MCAPI_ATTR_NO_BUFFERS,
                                 (void*)&buf_count, sizeof(buf_count),
                                 &mcapi_struct->status);

    /* Ensure the proper value was returned. */
    if ( (mcapi_struct->status != MCAPI_SUCCESS) ||
         (buf_count != TEST_BUF_COUNT) )
    {
        mcapi_struct->status = -1;
    }

    /* Close the send side of the connection. */
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                  &mcapi_struct->request, &status);

    /* Let the control task run. */
    MCAPID_Sleep(1000);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_7_2 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_7_3
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_attribute for MCAPI_ATTR_BUFFER_SIZE.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0, open send
*           side of connection, issue connection, get MCAPI_ATTR_BUFFER_SIZE.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_7_3)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_status_t      status;
    mcapi_uint32_t      buf_count;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the buffer size of buffers on the endpoint. */
    mcapi_get_endpoint_attribute(mcapi_struct->local_endp, MCAPI_ATTR_BUFFER_SIZE,
                                 (void*)&buf_count, sizeof(buf_count),
                                 &mcapi_struct->status);

    /* Ensure the proper value was returned. */
    if ( (mcapi_struct->status != MCAPI_SUCCESS) ||
         (buf_count != MCAPI_MAX_DATA_LEN) )
    {
        mcapi_struct->status = -1;
    }

    /* Close the send side of the connection. */
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                  &mcapi_struct->request, &status);

    /* Let the control task run. */
    MCAPID_Sleep(1000);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_7_3 */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Tx_2_7_4
*
*   DESCRIPTION
*
*       Testing mcapi_get_endpoint_attribute for
*       MCAPI_ATTR_RECV_BUFFERS_AVAILABLE.
*
*           Node 0 – Creates endpoint on boot up, open receive side of
*           connection.
*
*           Node 1 – Create endpoint, get endpoint on Node 0, open send
*           side of connection, issue connection, get
*           MCAPI_ATTR_RECV_BUFFERS_AVAILABLE.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Tx_2_7_4)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    mcapi_status_t      status;
    mcapi_uint32_t      buf_count;

    /* Don't let any other test run while this test is running. */
    MCAPI_Obtain_Mutex(&MCAPID_FTS_Mutex);

    /* Get the number of buffers available for receiving data on the
     * endpoint.
     */
    mcapi_get_endpoint_attribute(mcapi_struct->local_endp,
                                 MCAPI_ATTR_RECV_BUFFERS_AVAILABLE,
                                 (void*)&buf_count, sizeof(buf_count),
                                 &mcapi_struct->status);

    /* Ensure the proper value was returned. */
    if (mcapi_struct->status != MCAPI_SUCCESS)
    {
        mcapi_struct->status = -1;
    }

    /* Close the send side of the connection. */
    mcapi_packetchan_send_close_i(mcapi_struct->pkt_tx_handle,
                                  &mcapi_struct->request, &status);

    /* Let the control task run. */
    MCAPID_Sleep(1000);

    /* Set the state of the test to completed. */
    mcapi_struct->state = 0;

    /* Allow the next test to run. */
    MCAPI_Release_Mutex(&MCAPID_FTS_Mutex);

} /* MCAPI_FTS_Tx_2_7_4 */
