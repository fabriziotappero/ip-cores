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
*       mcapi_encode_handle
*
*   DESCRIPTION
*
*       Encodes a handle using the index of the respective node and
*       endpoint.
*
*   INPUTS
*
*       node_idx                The index into the global data structure
*                               of the node to which the handle applies.
*       endp_idx                The index into the node's endpoint list
*                               to which the handle applies.
*
*   OUTPUTS
*
*       The 32-bit encoded handle.
*
*************************************************************************/
mcapi_endpoint_t mcapi_encode_handle(mcapi_uint16_t node_idx,
                                     mcapi_uint16_t endp_idx)
{
    mcapi_endpoint_t    handle;

    /* Put the node index in the handle. */
    handle = node_idx;

    /* Move the node ID left 16-bits. */
    handle <<= 16;

    /* Add the endpoint index to the lower 16-bits of the handle. */
    handle |= endp_idx;

    return (handle);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_decode_handle
*
*   DESCRIPTION
*
*       Decodes a handle to retrieve the index of the respective node and
*       endpoint.
*
*   INPUTS
*
*       handle                  The encoded handle.
*       *node_idx               A pointer to memory that will hold the
*                               decoded node index into the global data
*                               structure.
*       *endp_idx               A pointer to memory that will hold the
*                               decoded endpoint index into the endpoint
*                               list of the respective node.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_decode_handle(mcapi_endpoint_t handle, int *node_idx, int *endp_idx)
{
    /* Extract the high 16-bits by chopping off the low 16-bits and moving
     * the remaining data over 16-bits.
     */
    *node_idx = (handle & 0xffff0000) >> 16;

    /* Extract the low 16-bits by chopping off the high 16-bits. */
    *endp_idx = (handle & 0x0000ffff);

}
