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
*       mcapi_connect_sclchan_i
*
*   DESCRIPTION
*
*       Non-blocking API routine to establish a scalar channel connection
*       between two endpoints.  The connection can be established by
*       the sender, the receiver, or a third party, but must be called
*       only once for a given set of endpoints.  The type of channel and
*       attributes of both endpoints must match to make a connection.  Once
*       two endpoints are connected, their attributes cannot be changed.
*
*   INPUTS
*
*       send_endpoint           The sending endpoint of the connection.
*       receive_endpoint        The receiving endpoint of the connection.
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
void mcapi_connect_sclchan_i(mcapi_endpoint_t send_endpoint,
                             mcapi_endpoint_t receive_endpoint,
                             mcapi_request_t *request,
                             mcapi_status_t *mcapi_status)
{
    /* Connect the scalar channel. */
    mcapi_connect(send_endpoint, receive_endpoint, MCAPI_CHAN_SCAL_TYPE,
                  request, mcapi_status);

}
