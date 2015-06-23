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

extern mcapi_uint16_t   MCAPI_Next_Port;

/*************************************************************************
*
*   FUNCTION
*
*       create_endpoint
*
*   DESCRIPTION
*
*       Routine to create an endpoint on the local node.  If the port
*       ID field is set to MCAPI_PORT_ANY, an endpoint will be created using
*       the next available port in the system.
*
*   INPUTS
*
*       port_id                 The port ID of the endpoint, or MCAPI_PORT_ANY
*                               to create an endpoint with the next available
*                               port ID.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The newly created endpoint.
*
*************************************************************************/
mcapi_endpoint_t create_endpoint(MCAPI_NODE *node_ptr,
                                 mcapi_port_t port_id,
                                 mcapi_status_t *mcapi_status)
{
    mcapi_endpoint_t    endpoint = 0;
    MCAPI_ENDPOINT      *endp_ptr = MCAPI_NULL;
    int                 i, endp_idx;

#if (MCAPI_MAX_ENDPOINTS != 0)

    /* If there is an available endpoint entry. */
    if (node_ptr->mcapi_endpoint_count < MCAPI_MAX_ENDPOINTS)
    {
        /* Initialize mcapi_status to success. */
        *mcapi_status = MCAPI_SUCCESS;

        /* If a specific port was specified for the new endpoint, check
         * that an endpoint does not already exist that uses that port.
         */
        if (port_id != MCAPI_PORT_ANY)
        {
            /* If a matching endpoint already exists. */
            if (mcapi_find_endpoint(port_id, node_ptr) != -1)
            {
                *mcapi_status = MCAPI_ERR_ENDP_EXISTS;
            }
        }

        /* If a port was not passed in, find a unique port. */
        else
        {
            /* Find a unique port to assign to the endpoint. */
            do
            {
                port_id = MCAPI_Next_Port ++;

                /* Ensure the application has not used this port for
                 * another endpoint.
                 */
                i = mcapi_find_endpoint(port_id, node_ptr);

            } while ( (i != -1) && (port_id != MCAPI_PORT_ANY) );

            /* If an unused port could not be found. */
            if (port_id == MCAPI_PORT_ANY)
            {
                *mcapi_status = MCAPI_ERR_PORT_INVALID;
            }
        }

        /* If the status is still success. */
        if (*mcapi_status == MCAPI_SUCCESS)
        {
            /* Create a hash index. */
            endp_idx = (port_id % MCAPI_MAX_ENDPOINTS);

            /* If this slot is available. */
            if (node_ptr->mcapi_endpoint_list[endp_idx].mcapi_state ==
                MCAPI_ENDP_CLOSED)
            {
                endp_ptr = &node_ptr->mcapi_endpoint_list[endp_idx];
            }

            /* Otherwise, find the next available slot. */
            else
            {
                /* Set the counter variable to zero. */
                i = 0;

                /* Find an empty slot. */
                do
                {
                    /* Move to the next slot. */
                    endp_idx ++;

                    /* If the index has rolled over. */
                    if ( (endp_idx < 0) ||
                         (endp_idx >= MCAPI_MAX_ENDPOINTS) )
                    {
                        endp_idx = 0;
                    }

                    /* If the endpoint entry is unused. */
                    if (node_ptr->mcapi_endpoint_list[endp_idx].
                        mcapi_state == MCAPI_ENDP_CLOSED)
                    {
                        /* Use this entry. */
                        endp_ptr = &node_ptr->mcapi_endpoint_list[endp_idx];
                        break;
                    }

                    i ++;

                } while (i < MCAPI_MAX_ENDPOINTS);
            }

            /* If an available entry was found. */
            if (endp_ptr)
            {
                /* Increment the number of used endpoints on the
                 * node.
                 */
                node_ptr->mcapi_endpoint_count ++;

                /* Clear the endpoint structure. */
                memset(endp_ptr, 0, sizeof(MCAPI_ENDPOINT));

                /* Set the state of the entry to open. */
                endp_ptr->mcapi_state = MCAPI_ENDP_OPEN;

                /* Set the port ID of the entry. */
                endp_ptr->mcapi_port_id = port_id;

                /* Set the node ID of the entry. */
                endp_ptr->mcapi_node_id = node_ptr->mcapi_node_id;

                /* Encode the endpoint. */
                endpoint = mcapi_encode_endpoint(endp_ptr->mcapi_node_id,
                                                 port_id);

                /* Store the handle for future use. */
                endp_ptr->mcapi_endp_handle = endpoint;

                /* Set the priority to the default. */
                endp_ptr->mcapi_priority = MCAPI_DEFAULT_PRIO;

                /* Check if any foreign nodes are waiting for this
                 * endpoint to be created.
                 */
                mcapi_check_foreign_resume(MCAPI_REQ_CREATED, endpoint,
                                           MCAPI_SUCCESS);

                /* Check if any local threads are waiting for this endpoint
                 * to be created.
                 */
                mcapi_check_resume(MCAPI_REQ_CREATED, endpoint,
                                   MCAPI_NULL, 0, MCAPI_SUCCESS);
            }
        }
    }

    /* There are no available endpoint entries in the system. */
    else
    {
        *mcapi_status = MCAPI_ERR_GENERAL; /* XXX document me */
    }

#else

    *mcapi_status = MCAPI_EEP_NOTALLOWED;

#endif

    return (endpoint);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_check_foreign_resume
*
*   DESCRIPTION
*
*       Checks if any pending requests from foreign nodes should be resumed.
*
*   INPUTS
*
*       type                    The type of request to check.
*       endpoint                The endpoint for which the request is
*                               suspended on some action.
*       status                  The status to set in the request structure.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_check_foreign_resume(int type, mcapi_endpoint_t endpoint,
                                mcapi_status_t status)
{
    mcapi_request_t     *request, *next_ptr;
    MCAPI_GLOBAL_DATA   *node_data;

    /* Get a pointer to the global node list. */
    node_data = mcapi_get_node_data();

    /* Get a pointer to the first entry in the request queue. */
    request = node_data->mcapi_foreign_req_queue.flink;

    /* Check each request to see if the operation has been completed. */
    while (request)
    {
        /* Get a pointer to the next entry. */
        next_ptr = request->mcapi_next;

        switch (type)
        {
            /* An endpoint associated with a pending request has been
             * created.
             */
            case MCAPI_REQ_CREATED:

                /* If the request structure is waiting for an endpoint to be
                 * created.
                 */
                if ( (request->mcapi_type == MCAPI_REQ_CREATED) &&
                     (mcapi_encode_endpoint(request->mcapi_target_node_id,
                                            request->mcapi_target_port_id) == endpoint) )
                {
                    /* Remove this item from the list. */
                    mcapi_remove(&node_data->mcapi_foreign_req_queue, request);

                    /* Set the status to success. */
                    request->mcapi_status = MCAPI_SUCCESS;

                    /* Send the response. */
                    mcapi_tx_response(node_data, request);

                    /* Set this request structure back to available. */
                    mcapi_release_request_struct(request);
                }

                break;

            default:

                break;
        }

        /* Get the next request entry in the list. */
        request = next_ptr;
    }

}
