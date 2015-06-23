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
*       mcapi_data_available
*
*   DESCRIPTION
*
*       Non-blocking API routine to check for data on an endpoint.
*
*   INPUTS
*
*       *rx_endp_ptr            A pointer to the endpoint being checked
*                               for data.
*       type                    The type of channel; packet or scalar.
*       *msg_count              A pointer to the number of receive calls
*                               that will complete without blocking.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The number of receive operations that are guaranteed to not block
*       waiting for incoming data.
*
*************************************************************************/
void mcapi_data_available(MCAPI_ENDPOINT *rx_endp_ptr, mcapi_uint32_t type,
                          mcapi_uint_t *msg_count,
                          mcapi_status_t *mcapi_status)
{
    /* Validate the status parameter. */
    if (mcapi_status)
    {
        /* Ensure this is a receive handle. */
        if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_RX)
        {
            /* Check if the endpoint is connected. */
            if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED)
            {
                /* Ensure this is a macthing channel type. */
                if (rx_endp_ptr->mcapi_chan_type == type)
                {
                    /* Count the number of packets on the channel. */
                    mcapi_check_data(rx_endp_ptr, msg_count);

                    /* The return value is success whether there is data
                     * on the endpoint or not.
                     */
                    *mcapi_status = MCAPI_SUCCESS;
                }

                /* This is a scalar channel. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_TYPE;
                }
            }

            /* The connection has not been made yet. */
            else
            {
                *mcapi_status = MGC_MCAPI_ERR_NOT_CONNECTED;
            }
        }

        /* Data cannot be received on a send handle. */
        else if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_TX)
        {
            *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
        }

        /* The receive handle has been closed. */
        else
        {
            *mcapi_status = MCAPI_ERR_CHAN_INVALID;
        }
    }

}

