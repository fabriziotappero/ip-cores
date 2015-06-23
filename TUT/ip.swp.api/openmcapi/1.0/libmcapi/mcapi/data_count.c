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
*       mcapi_check_data
*
*   DESCRIPTION
*
*       Counts the number of packets on an endpoint waiting to be
*       received by the application layer.
*
*   INPUTS
*
*       *endp_ptr               Endpoint on which to check for data.
*       *msg_count              The number of receive calls that will
*                               complete successfully.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_check_data(MCAPI_ENDPOINT *endp_ptr, mcapi_uint_t *msg_count)
{
    MCAPI_BUFFER    *cur_buf;

    /* Get a pointer to the first message in the queue. */
    cur_buf = endp_ptr->mcapi_rx_queue.head;

    /* While there are messages on the receive queue. */
    while (cur_buf)
    {
        /* Increment the number of messages pending on the endpoint. */
        (*msg_count) ++;

        /* Get next message. */
        cur_buf = (MCAPI_BUFFER*)(cur_buf->next_buf);
    }

}
