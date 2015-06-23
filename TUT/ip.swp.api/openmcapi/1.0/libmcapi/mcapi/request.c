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

extern mcapi_request_t      MCAPI_Free_Request_Structs[];

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_init_request
*
*   DESCRIPTION
*
*       Initializes a request structure.
*
*   INPUTS
*
*       *request                A pointer to the request to initialize.
*       type                    The type of request.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_init_request(mcapi_request_t *request, mcapi_uint8_t type)
{
    /* Zero out the request structure. */
    memset(request, 0, sizeof(mcapi_request_t));

    /* Initialize the common parameters. */
    request->mcapi_requesting_node_id = MCAPI_Node_ID;
    request->mcapi_type = type;
    request->mcapi_status = MCAPI_PENDING;

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_get_free_request_struct
*
*   DESCRIPTION
*
*       Returns a free request structure to use for a pending request
*       from a foreign node.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       mcapi_request_t
*       MCAPI_NULL
*
*************************************************************************/
mcapi_request_t *mcapi_get_free_request_struct(void)
{
    mcapi_request_t     *request = MCAPI_NULL;
    int                 i;

    /* Traverse the list looking for a free entry. */
    for (i = 0; i < MCAPI_FREE_REQUEST_COUNT; i++)
    {
        /* If this entry is available. */
        if (MCAPI_Free_Request_Structs[i].mcapi_type == 0)
        {
            /* Clear any old data from the structure. */
            memset(&MCAPI_Free_Request_Structs[i], 0, sizeof(mcapi_request_t));

            /* Return a pointer to the request struct. */
            request = &MCAPI_Free_Request_Structs[i];

            break;
        }
    }

    return (request);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_release_request_struct
*
*   DESCRIPTION
*
*       Returns the request structure to the free list.
*
*   INPUTS
*
*       *req_ptr                A pointer to the structure to free.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_release_request_struct(mcapi_request_t *req_ptr)
{
    /* Set the structure to available. */
    req_ptr->mcapi_type = 0;

}
