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

void mcapi_copy_request(mcapi_request_t *dest_req, mcapi_request_t *src_req);
mcapi_boolean_t __mcapi_test(mcapi_request_t *request, size_t *size,
                           mcapi_status_t *mcapi_status);

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_wait
*
*   DESCRIPTION
*
*       Blocking API routine that waits for a non-blocking operation to
*       complete.  The routine returns if the specific operation has
*       completed or been canceled, or if the call to mcapi_wait times
*       out on completion of the respective operation.
*
*   INPUTS
*
*       *request                A pointer to the request structure filled
*                               in by the specific operation waiting for
*                               completion.
*       *size                   A pointer to memory that will be filled in
*                               with the number of bytes sent/received if
*                               the operation in question is a send or
*                               receive operation.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*       timeout                 The number milliseconds to wait for
*                               completion of the respective operation
*                               before returning from mcapi_wait().
*                               A value of MCAPI_TIMEOUT_INFINITE indicates no
*                               timeout.
*
*   OUTPUTS
*
*       MCAPI_TRUE              The operation has completed.
*       MCAPI_FALSE             An error has occurred.
*
*************************************************************************/
mcapi_boolean_t mcapi_wait(mcapi_request_t *request, size_t *size,
                           mcapi_status_t *mcapi_status,
                           mcapi_timeout_t timeout)
{
    MCAPI_GLOBAL_DATA   *node_data;
    mcapi_request_t     req_copy;
    mcapi_boolean_t     ret_val = MCAPI_FALSE;

    /* Ensure the status value is valid. */
    if (mcapi_status)
    {
        /* Get the lock. */
        mcapi_lock_node_data();

        /* Check to see if the request has completed. */
        ret_val = __mcapi_test(request, size, mcapi_status);

        /* If the request has not been completed. */
        if ( (*mcapi_status == MCAPI_PENDING) && (ret_val == MCAPI_FALSE) )
        {
            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Replicate the target request structure. */
            memcpy(&req_copy, request, sizeof(mcapi_request_t));

            /* Suspend until the operation completes or timeout occurs. */
            MCAPI_Suspend_Task(node_data, &req_copy, &req_copy.mcapi_cond,
                               timeout);

            /* Copy the status of the request into the original request
             * structure so a subsequent call to test will pass.  If the
             * original request structure was on the request list, the
             * status will already be set, but not all request structures
             * get put on the list.
             */
            request->mcapi_status = req_copy.mcapi_status;

            /* The wait operation timed out before the operation being
             * tested could finish.
             */
            if (req_copy.mcapi_status == MCAPI_PENDING)
            {
                *mcapi_status = MCAPI_TIMEOUT;

                /* Remove the request from the list. */
                mcapi_remove(&node_data->mcapi_local_req_queue, &req_copy);
            }

            /* The operation completed or was canceled. */
            else
            {
                *mcapi_status = req_copy.mcapi_status;
            }

            /* Only return MCAPI_TRUE if the operation completed
             * successfully.
             */
            if (*mcapi_status == MCAPI_SUCCESS)
            {
                ret_val = MCAPI_TRUE;

                /* If the request was a send or receive, record the number
                 * of bytes sent or received.
                 */
                if ( (req_copy.mcapi_type == MCAPI_REQ_TX_FIN) ||
                     (req_copy.mcapi_type == MCAPI_REQ_RX_FIN) )
                {
                    *size = req_copy.mcapi_byte_count;
                }
            }
        }

        /* Release the lock. */
        mcapi_unlock_node_data();
    }

    return (ret_val);

}
