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



#include <openmcapi.h>

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_get_endpoint_i
*
*   DESCRIPTION
*
*       Non-blocking API routine to retrieve the endpoint identifier
*       associated with a specific node ID and port ID.
*
*   INPUTS
*
*       node_id                 The unique ID of the node on which the target
*                               endpoint resides.
*       port_id                 The port ID of the target endpoint.
*       *endpoint               A pointer to memory that will be filled in
*                               with the endpoint identifier associated
*                               with the node ID / port ID combination.
*       *request                A pointer to memory that will be filled in
*                               with data relevant to the operation, so the
*                               status of the operation can later be checked.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_get_endpoint_i(mcapi_node_t node_id, mcapi_port_t port_id,
                          mcapi_endpoint_t *endpoint,
                          mcapi_request_t *request,
                          mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;

    /* Validate mcapi_status. */
    if (mcapi_status)
    {
        /* Validate the endpoint and request structures. */
        if ( (endpoint) && (request) )
        {
            /* Initialize the request structure. */
            mcapi_init_request(request, MCAPI_REQ_CREATED);

            /* Set up the request structure. */
            request->mcapi_target_node_id = node_id;
            request->mcapi_target_port_id = port_id;

            /* Save the application's pointer that will be filled in
             * once the call completes successfully.
             */
            request->mcapi_endp_ptr = endpoint;

            /* If the endpoint is not local. */
            if (node_id != MCAPI_Node_ID)
            {
                /* Get the lock. */
                mcapi_lock_node_data();

                /* Get a pointer to the global node list. */
                node_data = mcapi_get_node_data();

                /* Issue the call to get a remote endpoint. */
                get_remote_endpoint(node_id, port_id, mcapi_status, 0xffffffff);

                /* If the request was sent. */
                if (*mcapi_status == MCAPI_SUCCESS)
                {
                    /* Add the application's request structure to the list of
                     * pending requests for the node.
                     */
                    mcapi_enqueue(&node_data->mcapi_local_req_queue, request);
                }

                /* Release the lock. */
                mcapi_unlock_node_data();
            }

            else
            {
                /* Set a successful status. */
                *mcapi_status = MCAPI_SUCCESS;
            }
        }

        /* An input parameter is invalid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }

}
