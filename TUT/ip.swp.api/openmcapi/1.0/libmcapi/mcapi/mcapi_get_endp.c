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
*       mcapi_get_endpoint
*
*   DESCRIPTION
*
*       Blocking API routine to retrieve the endpoint identifier
*       associated with a specific node ID and port ID.  The routine will
*       block until the specific endpoint has been created.
*
*   INPUTS
*
*       node_id                 The unique ID of the node on which the target
*                               endpoint resides.
*       port_id                 The port ID of the target endpoint.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The endpoint identifier associated with the node ID / port ID
*       combination.
*
*************************************************************************/
mcapi_endpoint_t mcapi_get_endpoint(mcapi_node_t node_id, mcapi_port_t port_id,
                                    mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    mcapi_endpoint_t    endpoint = 0;
    MCAPI_ENDPOINT      *endp_ptr;
    mcapi_request_t     request;

    /* Ensure the status parameter is valid. */
    if (mcapi_status)
    {
        /* Get the lock. */
        mcapi_lock_node_data();

        /* Get a pointer to the global node list. */
        node_data = mcapi_get_node_data();

        /* If the endpoint is located on the local node. */
        if (node_id == MCAPI_Node_ID)
        {
            /* Get a pointer to the endpoint. */
            endp_ptr = mcapi_find_local_endpoint(node_data, node_id,
                                                 port_id);

            /* If the endpoint was found. */
            if (endp_ptr)
            {
                /* Return the endpoint handle. */
                endpoint = endp_ptr->mcapi_endp_handle;

                /* Set the status. */
                *mcapi_status = MCAPI_SUCCESS;
            }

            /* The node has not yet been initialized. */
            else
            {
                *mcapi_status = MCAPI_PENDING;
            }
        }

        /* Otherwise, query the foreign node for the information. */
        else
        {

            /* If the remote endpoint is not ready loop till it becomes
            * available.
            */
            for (;;)
            {
                /* Issue the call to get a remote endpoint. */
                get_remote_endpoint(node_id, port_id, mcapi_status, 0xffffffff);

                if (*mcapi_status == MCAPI_ERR_TRANSMISSION)
                {
                    /* Must drop and re-acquire the lock so we don't block
                     * other threads forever. */
                    mcapi_unlock_node_data();
                    MCAPI_Sleep(1);
                    mcapi_lock_node_data();
                }
                else
                {
                    break;
                }
            }

            /* The get remote endpoint request was successfully sent. */
            if (*mcapi_status == MCAPI_SUCCESS)
            {
                *mcapi_status = MCAPI_PENDING;
            }
        }

        /* If the endpoint is not immediately available. */
        if (*mcapi_status == MCAPI_PENDING)
        {
            /* Initialize the request structure. */
            mcapi_init_request(&request, MCAPI_REQ_CREATED);

            /* Set up the request structure. */
            request.mcapi_target_node_id = node_id;
            request.mcapi_target_port_id = port_id;
            request.mcapi_endp_ptr = &endpoint;

            /* Suspend until the call completes or is canceled. */
            MCAPI_Suspend_Task(node_data, &request, &request.mcapi_cond,
                               MCAPI_TIMEOUT_INFINITE);

            *mcapi_status = request.mcapi_status;
        }

        /* Release the lock. */
        mcapi_unlock_node_data();
    }

    return (endpoint);

}
