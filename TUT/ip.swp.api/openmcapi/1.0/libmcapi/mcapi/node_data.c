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

MCAPI_GLOBAL_DATA       MCAPI_Global_Struct;

extern MCAPI_MUTEX      MCAPI_Mutex;

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_lock_node_data
*
*   DESCRIPTION
*
*       Obtains the lock in the system to access the MCAPI_GLOBAL_DATA
*       data structure.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_lock_node_data(void)
{
    MCAPI_Obtain_Mutex(&MCAPI_Mutex);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_unlock_node_data
*
*   DESCRIPTION
*
*       Releases the lock in the system to access the MCAPI_GLOBAL_DATA
*       data structure.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_unlock_node_data(void)
{
    MCAPI_Release_Mutex(&MCAPI_Mutex);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_get_node_data
*
*   DESCRIPTION
*
*       Get a pointer the MCAPI_GLOBAL_DATA data structure.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       Pointer to the MCAPI_GLOBAL_DATA structure.
*
*************************************************************************/
MCAPI_GLOBAL_DATA *mcapi_get_node_data(void)
{
    return (&MCAPI_Global_Struct);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_init_node_data
*
*   DESCRIPTION
*
*       Initializes MCAPI_Global_Struct containing node data global to
*       this node only.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_init_node_data(void)
{
    int             i;

    /* Create the MCAPI semaphore. */
    MCAPI_Create_Mutex(&MCAPI_Mutex, "MCAPI");

    /* Initialize the node count to zero. */
    MCAPI_Global_Struct.mcapi_node_count = 0;

    /* Set the local request queue head and tail to null. */
    MCAPI_Global_Struct.mcapi_local_req_queue.flink = MCAPI_NULL;
    MCAPI_Global_Struct.mcapi_local_req_queue.blink = MCAPI_NULL;

    /* Set the foreign request queue head and tail to null. */
    MCAPI_Global_Struct.mcapi_foreign_req_queue.flink = MCAPI_NULL;
    MCAPI_Global_Struct.mcapi_foreign_req_queue.blink = MCAPI_NULL;

    /* Set the state of each node in the list to unused. */
    for (i = 0; i < MCAPI_NODE_COUNT; i++)
    {
        MCAPI_Global_Struct.mcapi_node_list[i].mcapi_state = MCAPI_NODE_UNUSED;
    }

}


