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
#include <udp_lite.h>
#include <mapping.h>

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_msg_recv
*
*   DESCRIPTION
*
*       Blocking API routine to receive a connectionless message on a
*       local endpoint.
*
*   INPUTS
*
*       receive_endpoint        The local endpoint identifer that is
*                               receiving the data.
*       *buffer                 A pointer to memory that will be filled in
*                               with the received data.
*       buffer_size             The number of bytes that will fit in *buffer.
*       *received_size          The number of bytes received.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_msg_recv(mcapi_endpoint_t receive_endpoint, void *buffer,
                    size_t buffer_size, size_t *received_size,
                    mcapi_status_t *mcapi_status)
{
    mcapi_request_t     request;
    if (receive_endpoint >> 16 == DCT_ACC_NODE_ID){
    
      udp_recv(buffer,buffer_size);
    }
    else{

    /* Call the receive routine, indicating to block. */
    msg_recv(receive_endpoint, buffer, buffer_size, received_size,
             &request, mcapi_status, 0xffffffff);
    }
}
