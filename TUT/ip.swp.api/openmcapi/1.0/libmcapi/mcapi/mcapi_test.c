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

mcapi_boolean_t __mcapi_test(mcapi_request_t *request, size_t *size,
                             mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    mcapi_boolean_t     ret_val = MCAPI_FALSE;
    MCAPI_ENDPOINT      *endp_ptr = MCAPI_NULL;
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;

    /* Validate the mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate request. */
        if (request)
        {
            /* Check if the request has been canceled. */
            if (request->mcapi_status != MCAPI_ERR_REQUEST_CANCELLED)
            {
                /* Validate size. */
                if (size)
                {
                    /* Get a pointer to the global node list. */
                    node_data = mcapi_get_node_data();

                    /* If checking for creation of an endpoint. */
                    if (request->mcapi_type == MCAPI_REQ_CREATED)
                    {
                        /* If the endpoint is local. */
                        if (request->mcapi_target_node_id == MCAPI_Node_ID)
                        {
                            /* Get a pointer to the endpoint. */
                            endp_ptr =
                                mcapi_find_local_endpoint(node_data,
                                                          request->mcapi_target_node_id,
                                                          request->mcapi_target_port_id);

                            /* If the endpoint was found. */
                            if (endp_ptr)
                            {
                                /* Set the status to success. */
                                *mcapi_status = request->mcapi_status =
                                    MCAPI_SUCCESS;

                                /* Set the user's memory to the endpoint. */
                                *(request->mcapi_endp_ptr) = endp_ptr->mcapi_endp_handle;

                                ret_val = MCAPI_TRUE;
                            }

                            /* The endpoint has not been created on the node. */
                            else
                            {
                                *mcapi_status = MCAPI_PENDING;
                            }
                        }

                        /* If the remote request has completed or failed. */
                        else if (request->mcapi_status != MCAPI_PENDING)
                        {
                            *mcapi_status = request->mcapi_status;

                            ret_val = MCAPI_TRUE;
                        }

                        /* The endpoint has not been created. */
                        else
                        {
                            *mcapi_status = MCAPI_PENDING;
                        }
                    }

                    /* Checking for something other than endpoint creation. */
                    else
                    {
                        /* Decode the endpoint. */
                        endp_ptr =
                            mcapi_decode_local_endpoint(node_data, &node_id, &port_id,
                                                        request->mcapi_target_endp, mcapi_status);

                        /* Switch based on the operation being checked. */
                        switch (request->mcapi_type)
                        {
                            case MCAPI_REQ_TX_FIN:

                                /* Ensure the endpoint was found. */
                                if (endp_ptr)
                                {
                                    /* Set the number of bytes transmitted. */
                                    *size = request->mcapi_byte_count;
                                }

                                /* If data was transmitted or an error
                                 * occurred.
                                 */
                                if (request->mcapi_status != MCAPI_PENDING)
                                {
                                    /* Set the status. */
                                    *mcapi_status = request->mcapi_status;

                                    ret_val = MCAPI_TRUE;
                                }

                                /* The data has not been transmitted. */
                                else
                                {
                                    *mcapi_status = MCAPI_PENDING;
                                }

                                break;

                            case MCAPI_REQ_RX_FIN:

                                /* If there is data on this endpoint. */
                                if (endp_ptr)
                                {
                                    /* Data has been received on the endpoint. */
                                    if (request->mcapi_status == MCAPI_SUCCESS)
                                    {
                                        /* Set the status to success. */
                                        *mcapi_status = MCAPI_SUCCESS;

                                        /* Set the number of bytes in the request
                                         * structure.
                                         */
                                        *size = request->mcapi_byte_count;

                                        ret_val = MCAPI_TRUE;
                                    }

                                    /* No data has been received on the endpoint. */
                                    else if (request->mcapi_status == MCAPI_PENDING)
                                    {
                                        /* Set the status. */
                                        *mcapi_status = MCAPI_PENDING;

                                        /* Indicate that no data has been received. */
                                        *size = 0;
                                    }

                                    /* An error occurred. */
                                    else
                                    {
                                        /* Set the status. */
                                        *mcapi_status = request->mcapi_status;

                                        /* Indicate that no data has been received. */
                                        *size = 0;
                                    }
                                }

                                /* The endpoint is invalid, therefore this request
                                 * structure is invalid.
                                 */
                                else
                                {
                                    *mcapi_status = MCAPI_ERR_REQUEST_INVALID;
                                }

                                break;

                            case MCAPI_REQ_CONNECTED:

                                /* If the request is no longer in the pending state. */
                                if (request->mcapi_status != MCAPI_PENDING)
                                {
                                    /* Set the status. */
                                    *mcapi_status = request->mcapi_status;

                                    ret_val = MCAPI_TRUE;
                                }

                                /* The endpoint has not been connected. */
                                else
                                {
                                    *mcapi_status = MCAPI_PENDING;
                                }

                                break;

                            case MCAPI_REQ_RX_OPEN:

                                /* If the endpoint is open for receive. */
                                if ( (endp_ptr) &&
                                     (endp_ptr->mcapi_state & MCAPI_ENDP_RX) &&
                                     (endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED) )
                                {
                                    /* Set the status to success. */
                                    *mcapi_status = request->mcapi_status =
                                        MCAPI_SUCCESS;

                                    ret_val = MCAPI_TRUE;
                                }

                                /* The endpoint is not open for receive. */
                                else
                                {
                                    *mcapi_status = MCAPI_PENDING;
                                }

                                break;

                            case MCAPI_REQ_CLOSED:

                                /* If the endpoint is disconnected. */
                                if ( (endp_ptr) &&
                                     (endp_ptr->mcapi_state & MCAPI_ENDP_DISCONNECTED) )
                                {
                                    /* Set the status to success. */
                                    *mcapi_status = request->mcapi_status =
                                        MCAPI_SUCCESS;

                                    ret_val = MCAPI_TRUE;
                                }

                                /* The endpoint is not open for receive. */
                                else
                                {
                                    *mcapi_status = MCAPI_PENDING;
                                }

                                break;

                            case MCAPI_REQ_TX_OPEN:

                                /* If the endpoint is open for transmit. */
                                if ( (endp_ptr) &&
                                     (endp_ptr->mcapi_state & MCAPI_ENDP_TX) &&
                                     (endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED) )
                                {
                                    /* Set the status to success. */
                                    *mcapi_status = request->mcapi_status =
                                        MCAPI_SUCCESS;

                                    ret_val = MCAPI_TRUE;
                                }

                                /* The endpoint is not open for transmit. */
                                else
                                {
                                    *mcapi_status = MCAPI_PENDING;
                                }

                                break;

                            default:

                                *mcapi_status = MCAPI_ERR_REQUEST_INVALID;
                                break;
                        }
                    }
                }

                /* The size parameter is invalid. */
                else
                {
                    *mcapi_status = MCAPI_ERR_PARAMETER;
                }
            }

            /* The request has been canceled. */
            else
            {
                *mcapi_status = MCAPI_ERR_REQUEST_CANCELLED;
            }
        }

        /* The request parameter is invalid. */
        else
        {
            *mcapi_status = MCAPI_ERR_REQUEST_INVALID;
        }
    }

    return (ret_val);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_test
*
*   DESCRIPTION
*
*       Non-blocking API routine to check if a specified non-blocking
*       routine has completed.  If the specified operation is a send
*       or receive operation, the number of bytes sent/received will
*       be returned.
*
*   INPUTS
*
*       *request                A pointer to the request structure filled
*                               in by the specific operation being tested
*                               for completion.
*       *size                   A pointer to memory that will be filled in
*                               with the number of bytes sent/received if
*                               the operation in question is a send or
*                               receive operation.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       MCAPI_TRUE              The operation has completed.
*       MCAPI_FALSE             The operation has not completed or an
*                               error has occurred.
*
*************************************************************************/
mcapi_boolean_t mcapi_test(mcapi_request_t *request, size_t *size,
                           mcapi_status_t *mcapi_status)
{
    mcapi_boolean_t rc;

    mcapi_lock_node_data();
    rc = __mcapi_test(request, size, mcapi_status);
    mcapi_unlock_node_data();

    return rc;
}
