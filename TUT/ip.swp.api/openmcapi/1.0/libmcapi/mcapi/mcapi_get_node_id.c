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
*       mcapi_get_node_id
*
*   DESCRIPTION
*
*       API routine to retrieve the node ID associated with the local node.
*
*   INPUTS
*
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The unique ID of the local node.
*
*************************************************************************/
mcapi_node_t mcapi_get_node_id(mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    mcapi_node_t        node_id = 0;
    int                 i;

    /* Validate the status pointer. */
    if (mcapi_status)
    {
        /* Get the lock. */
        mcapi_lock_node_data();

        /* Get a pointer to the global node list. */
        node_data = mcapi_get_node_data();

        /* Get the index of the node associated with the node ID. */
        i = mcapi_find_node(MCAPI_Node_ID, node_data);

        /* If the node was found. */
        if (i != -1)
        {
            /* Return the node ID. */
            node_id = MCAPI_Node_ID;

            *mcapi_status = MCAPI_SUCCESS;
        }

        /* The local node has not been initialized yet. */
        else
        {
            *mcapi_status = MCAPI_ERR_NODE_NOTINIT;
        }

        mcapi_unlock_node_data();
    }

    return (node_id);

}
