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
*       mcapi_find_node
*
*   DESCRIPTION
*
*       Finds a specific node in a list of nodes.
*
*   INPUTS
*
*       target_id               The node ID of the target node.
*       *node_data              A pointer to the global node list.
*
*   OUTPUTS
*
*       Index into the global data structure of the respective node or
*       -1 if the node does not exist.
*
*************************************************************************/
int mcapi_find_node(mcapi_node_t target_id, MCAPI_GLOBAL_DATA *node_data)
{
    int     i;

    /* Find a matching entry in the list of nodes. */
    for (i = 0; i < MCAPI_NODE_COUNT; i++)
    {
        /* If the Node ID matches the target ID. */
        if ( (node_data->mcapi_node_list[i].mcapi_state != MCAPI_NODE_UNUSED) &&
             (node_data->mcapi_node_list[i].mcapi_node_id == target_id) )
            break;
    }

    if (i != MCAPI_NODE_COUNT)
        return (i);
    else
        return (-1);

}

