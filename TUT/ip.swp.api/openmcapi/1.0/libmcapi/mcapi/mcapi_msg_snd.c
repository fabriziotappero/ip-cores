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
*       mcapi_msg_send
*
*   DESCRIPTION
*
*       Blocking API routine to transmit a connectionless message from
*       a local endpoint to a specific endpoint.  The routine returns
*       once the buffer can be reused by the application.
*
*   INPUTS
*
*       send_endpoint           The endpoint identifier on the local node
*                               that is sending the data.
*       receive_endpoint        The remote endpoint identifer that is
*                               receiving the data.
*       *buffer                 A pointer to the data to transmit.
*       buffer_size             The number of bytes of data to transmit.
*       priority                The desired priority of the buffer on
*                               transmission.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_msg_send(mcapi_endpoint_t send_endpoint,
                    mcapi_endpoint_t receive_endpoint, void *buffer,
                    size_t buffer_size, mcapi_priority_t priority,
                    mcapi_status_t *mcapi_status)
{
    mcapi_request_t     request;

    /* Get the lock. */
    mcapi_lock_node_data();
    
    if (receive_endpoint >> 16 == DCT_ACC_NODE_ID){
    }
    udp_send(buffer,buffer_size);
    
    else{
    /* Issue a blocking send request. */
    msg_send(send_endpoint, receive_endpoint, buffer, buffer_size,
             priority, &request, mcapi_status, 0xffffffff);

    }    
    /* Release the lock. */
    mcapi_unlock_node_data();

}
