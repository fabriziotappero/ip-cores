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
*       mcapi_msg_available
*
*   DESCRIPTION
*
*       Non-blocking API routine to check for a connectionless message on
*       a local endpoint.
*
*   INPUTS
*
*       receive_endpoint        The local endpoint identifer being checked
*                               for incoming data.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The number of mcapi_msg_recv() operations that are guaranteed
*       to not block waiting for incoming data.
*
*************************************************************************/
mcapi_uint_t mcapi_msg_available(mcapi_endpoint_t receive_endpoint,
                                 mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *rx_endp_ptr = MCAPI_NULL;
    mcapi_uint_t        msg_count = 0;
    mcapi_port_t        rx_port_id;
    mcapi_node_t        rx_node_id;

    /* Ensure the status pointer is valid. */
    if (mcapi_status)
    {
        /* Get the lock. */
        mcapi_lock_node_data();

        /* Get a pointer to the global node list. */
        node_data = mcapi_get_node_data();

        /* Get a pointer to the endpoint. */
        rx_endp_ptr = mcapi_decode_local_endpoint(node_data, &rx_node_id,
                                                  &rx_port_id, receive_endpoint,
                                                  mcapi_status);

        /* Ensure the receive endpoint is valid. */
        if (*mcapi_status == MCAPI_SUCCESS)
        {
            /* Ensure the receive endpoint is not part of a
             * connection.
             */
            if (!(rx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING))
            {
                /* Check for data on the endpoint. */
                mcapi_check_data(rx_endp_ptr, &msg_count);

                /* The status is success regardless of whether there is data
                 * pending on the endpoint.
                 */
                *mcapi_status = MCAPI_SUCCESS;
            }

            /* The endpoint is part of a connection and cannot receive
             * messages.
             */
            else
            {
                *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
            }
        }

        /* Release the lock. */
        mcapi_unlock_node_data();
    }

    return (msg_count);

}
