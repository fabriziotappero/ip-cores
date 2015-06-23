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
*       mcapi_cancel
*
*   DESCRIPTION
*
*       Blocking API routine to cancel an outstanding non-blocking
*       operation.  Any pending calls to mcapi_wait() or mcapi_wait_any()
*       for the specific operation will also be canceled.
*
*   INPUTS
*
*       *request                A pointer to the request structure filled
*                               in by the specific operation being canceled.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_cancel(mcapi_request_t *request, mcapi_status_t *mcapi_status)
{
    mcapi_request_t     *req_ptr;
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *endp_ptr;
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;
    mcapi_status_t      local_status;

    /* Validate the mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate request. */
        if (request)
        {
            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get a pointer to a request structure matching this one. */
            req_ptr =
                mcapi_find_request(request, &node_data->mcapi_local_req_queue);

            /* At least one request was found. */
            if (req_ptr)
            {
                *mcapi_status = MCAPI_SUCCESS;

                /* There could be other tasks suspended on the same request.
                 * Find each one and resume.
                 */
                while (req_ptr)
                {
                    /* If the status is pending, cancel the operation. */
                    if (req_ptr->mcapi_status == MCAPI_PENDING)
                    {
                        /* If this is a get endpoint request for a foreign
                         * endpoint.
                         */
                        if ( (req_ptr->mcapi_type == MCAPI_REQ_CREATED) &&
                             (req_ptr->mcapi_target_node_id != MCAPI_Node_ID) )
                        {
                            /* Set the status to canceled. */
                            req_ptr->mcapi_status = MCAPI_ERR_REQUEST_CANCELLED;

                            /* Cancel the outstanding operation. */
                            mcapi_tx_response(node_data, req_ptr);
                        }

                        else
                        {
                            switch (req_ptr->mcapi_type)
                            {
                                /* Cancel the attempt at opening the receive / send
                                 * side of the connection.
                                 */
                                case MCAPI_REQ_RX_OPEN:
                                case MCAPI_REQ_TX_OPEN:

                                    /* Get a pointer to the local endpoint. */
                                    endp_ptr =
                                        mcapi_decode_local_endpoint(node_data, &node_id,
                                                                    &port_id,
                                                                    request->mcapi_target_endp,
                                                                    &local_status);

                                    if (endp_ptr)
                                    {
                                        /* Set the disconnected flag. */
                                        endp_ptr->mcapi_state =
                                            (MCAPI_ENDP_DISCONNECTED | MCAPI_ENDP_OPEN);

                                        /* Clear the channel type. */
                                        endp_ptr->mcapi_chan_type = 0;
                                    }

                                    break;

                                default:

                                    break;
                            }
                        }
                    }

                    /* Resume the request. */
                    mcapi_resume(node_data, req_ptr, MCAPI_ERR_REQUEST_CANCELLED);

                    /* Find another matching request. */
                    req_ptr =
                        mcapi_find_request(request, &node_data->mcapi_local_req_queue);
                }
            }

            /* If no matching request was found, return an error. */
            else
            {
                /* If the request that was passed in is pending, set
                 * the status to canceled.
                 */
                if (request->mcapi_status == MCAPI_PENDING)
                {
                    request->mcapi_status = MCAPI_ERR_REQUEST_CANCELLED;

                    /* This request structure does not get stored on
                     * the node's request list.
                     */
                    *mcapi_status = MCAPI_SUCCESS;
                }

                else
                {
                    *mcapi_status = MCAPI_ERR_REQUEST_INVALID;
                }
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* Request is not valid. */
        else
        {
            *mcapi_status = MCAPI_ERR_REQUEST_INVALID;
        }
    }

}
