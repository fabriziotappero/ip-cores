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
*       mcapi_wait_any
*
*   DESCRIPTION
*
*       Blocking API routine that waits for any non-blocking operation in
*       a list of operations to complete.  The routine returns if any of
*       the specific operations has completed or been canceled, or if the
*       call to mcapi_wait_any times out on completion of the respective
*       operation.
*
*   INPUTS
*
*       number                  The number of non-blocking operations in
*                               the *requests array.
*       **requests              A pointer to an array of number request
*                               structures, each filled in by the specific
*                               operation waiting for completion.
*       *size                   A pointer to memory that will be filled in
*                               with the number of bytes sent/received if
*                               the operation in question is a send or
*                               receive operation.
*       timeout                 The number milliseconds to wait for
*                               completion of the respective operation
*                               before returning from mcapi_wait_any().
*                               A value of MCAPI_TIMEOUT_INFINITE indicates no
*                               timeout.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The index into the requests array indicating which operation
*       completed.
*
*************************************************************************/
mcapi_int_t mcapi_wait_any(size_t number, mcapi_request_t **requests,
                           size_t *size, mcapi_timeout_t timeout,
                           mcapi_status_t *mcapi_status)
{
    int                 i, j;
    MCAPI_GLOBAL_DATA   *node_data;
    mcapi_int_t         req_idx = 0;
    MCAPI_COND_STRUCT   condition;
    mcapi_request_t     *req_ptr;
    mcapi_request_t     *req_list[MCAPI_FREE_REQUEST_COUNT];

    /* Validate the mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate the input parameters. */
        if ( (number > 0) && (size) && (requests) )
        {
            /* Check if any of the requests are already complete. */
            for (i = 0; i < number; i ++)
            {
                /* Ensure the request is valid. */
                if (requests[i])
                {
                    /* Check this request. */
                    mcapi_test(requests[i], size, mcapi_status);

                    /* If the request structure is not valid. */
                    if (*mcapi_status == MCAPI_ERR_REQUEST_INVALID)
                    {
                        break;
                    }

                    /* If the request has completed or been canceled. */
                    else if (*mcapi_status != MCAPI_PENDING)
                    {
                        req_idx = i;
                        break;
                    }
                }

                /* The request is either invalid or null. */
                else
                {
                    *mcapi_status = MCAPI_ERR_REQUEST_INVALID;
                    break;
                }
            }

            /* If none of the requests has completed. */
            if ( (*mcapi_status != MCAPI_ERR_REQUEST_INVALID) &&
                 (i == number) )
            {
                /* Initialize the status to indicate that the operation
                 * timed out.
                 */
                *mcapi_status = MCAPI_TIMEOUT;

                /* Get the lock. */
                mcapi_lock_node_data();

                /* Get a pointer to the global node list. */
                node_data = mcapi_get_node_data();

                /* Initialize the OS specific conditions for waking this
                 * task.
                 */
                MCAPI_Init_Condition(&condition);

                /* Add each request structure to the list. */
                for (i = 0; i < number; i ++)
                {
                    /* Get a new request structure. */
                    req_ptr = mcapi_get_free_request_struct();

                    if (req_ptr)
                    {
                        /* Replicate the target request structure. */
                        memcpy(req_ptr, requests[i], sizeof(mcapi_request_t));

                        /* Save a pointer to this structure since it will
                         * get removed from the global list if the request
                         * completes successfully.
                         */
                        req_list[i] = req_ptr;

                        /* Set the OS specific condition for identifying this task
                         * for resume.
                         */
                        MCAPI_Set_Condition(req_ptr, &condition);

                        /* Add the request to the queue of pending requests. */
                        mcapi_enqueue(&node_data->mcapi_local_req_queue, req_ptr);
                    }

                    /* There are no request structures available. */
                    else
                    {
                        *mcapi_status = MCAPI_ERR_REQUEST_LIMIT;

                        /* Remove any requests that were put on the queue.  If all
                         * requests cannot be serviced, then no requests get
                         * serviced.
                         */
                        for (j = 0; j < i; j ++)
                        {
                            /* Remove this entry. */
                            mcapi_remove(&node_data->mcapi_local_req_queue, req_list[j]);

                            /* Clear the OS specific condition. */
                            MCAPI_Clear_Condition(req_list[j]);

                            /* Return this request structure to the free list. */
                            mcapi_release_request_struct(req_list[j]);
                        }

                        break;
                    }
                }

                /* If all requests can be serviced with this call. */
                if (*mcapi_status != MCAPI_ERR_REQUEST_LIMIT)
                {
                    /* Suspend this task, passing in MCAPI_NULL as the
                     * request structure since all request structures have
                     * been added to the list.
                     */
                    MCAPI_Suspend_Task(node_data, MCAPI_NULL, &condition, timeout);

                    /* Initialize the index so we know when the first completed
                     * request has been found.
                     */
                    req_idx = -1;

                    /* Remove each request structure from the list of waiting tasks. */
                    for (i = 0; i < number; i ++)
                    {
                        /* Clear the OS specific condition for resuming the thread. */
                        MCAPI_Clear_Condition(req_list[i]);

                        /* If the wait operation timed out before the operation being
                         * tested could finish.
                         */
                        if (req_list[i]->mcapi_status == MCAPI_PENDING)
                        {
                            /* Remove the request from the list. */
                            mcapi_remove(&node_data->mcapi_local_req_queue, req_list[i]);
                        }

                        /* Remove the request from the queue of pending requests. */
                        mcapi_remove(&node_data->mcapi_local_req_queue, req_list[i]);

                        /* If a request structure has not been found already
                         * and the status is not "pending".
                         */
                        if ( (req_idx == -1) &&
                             (req_list[i]->mcapi_status != MCAPI_PENDING) )
                        {
                            /* Return the status of the request. */
                            *mcapi_status = req_list[i]->mcapi_status;

                            /* Set the status of the original request structure
                             * in case this request was not on the global list.
                             */
                            requests[i]->mcapi_status = *mcapi_status;

                            /* Return the index into the request structure. */
                            req_idx = i;

                            /* If the status is successful, and the request was
                             * to send or receive data, return the number of
                             * bytes sent or received.
                             */
                            if ( (*mcapi_status == MCAPI_SUCCESS) &&
                                 ((req_list[i]->mcapi_type == MCAPI_REQ_TX_FIN) ||
                                  (req_list[i]->mcapi_type == MCAPI_REQ_RX_FIN)) )
                            {
                                *size = req_list[i]->mcapi_byte_count;
                            }
                        }

                        /* Indicate that this request structure can be reused. */
                        mcapi_release_request_struct(req_list[i]);
                    }

                    /* If no matching index was found, return MCAPI_NULL. */
                    if (req_idx == -1)
                    {
                        req_idx = 0;
                    }
                }

                /* Release the lock. */
                mcapi_unlock_node_data();
            }
        }

        /* The request pointer or size value is not valid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }

    return (req_idx);

}

