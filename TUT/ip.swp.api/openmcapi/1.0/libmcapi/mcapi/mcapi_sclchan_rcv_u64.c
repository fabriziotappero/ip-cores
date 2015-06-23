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
*       mcapi_sclchan_recv_uint64
*
*   DESCRIPTION
*
*       Blocking API routine to receive a 64-bit scalar on a connected
*       channel.
*
*   INPUTS
*
*       receive_handle          The local receive handle identifer.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
mcapi_uint64_t mcapi_sclchan_recv_uint64(mcapi_sclchan_recv_hndl_t receive_handle,
                                         mcapi_status_t *mcapi_status)
{
    MCAPI_SCALAR    scalar;

    /* Initialize the value to zero. */
    scalar.mcapi_scal.scal_uint64 = 0;

    /* Receive 64-bits. */
    scal_rcv(receive_handle, &scalar, MCAPI_SCALAR_UINT64, mcapi_status);

    /* Return the data. */
    return (scalar.mcapi_scal.scal_uint64);

}
