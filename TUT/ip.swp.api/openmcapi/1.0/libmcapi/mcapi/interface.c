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

MCAPI_INTERFACE MCAPI_Interface_List[MCAPI_INTERFACE_COUNT];
extern MCAPI_INT_INIT   MCAPI_Int_Init_List[];

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_init_interfaces
*
*   DESCRIPTION
*
*       Initialize all interfaces on the local node.
*
*   INPUTS
*
*       node_id                 The node ID of the local node.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS           Initialization was successful.
*       interface error         An error occurred.
*
*************************************************************************/
mcapi_status_t mcapi_init_interfaces(mcapi_node_t node_id)
{
    int             i = 0, j = 0;
    mcapi_status_t  status = MCAPI_SUCCESS;
    mcapi_uint32_t  prio_count;

    /* Initialize each interface in the system. */
    while ( (MCAPI_Int_Init_List[i].mcapi_init != MCAPI_NULL) &&
            (j < MCAPI_INTERFACE_COUNT) )
    {
        /* Initialize the interface. */
        status =
            MCAPI_Int_Init_List[i].mcapi_init(node_id, &MCAPI_Interface_List[j]);

        /* If this interface was initialized successfully. */
        if (status == MCAPI_SUCCESS)
        {
            /* Determine the number of priorities supported by this interface. */
            status = MCAPI_Interface_List[j].mcapi_ioctl(MCAPI_ATTR_NO_PRIORITIES,
                                                         (void*)&prio_count,
                                                         sizeof(mcapi_uint32_t));

            /* If there are enough priority queues available to support the
             * number of priorities provided by the driver.
             */
            if ( (status == MCAPI_SUCCESS) &&
                 (prio_count <= MCAPI_PRIO_COUNT) )
            {
                /* Move on to the next interface structure. */
                j ++;
            }

            else
            {
                status = MCAPI_ERR_PRIORITY;
                break;
            }
        }

        /* The interface could not be initialized.  Report the error
         * to the application.
         */
        else if (status != 1)
        {
            break;
        }

        i ++;
    }

    /* Only return an error code if an error occurred.  It is not an error
     * to attempt to initialize the loopback interface when it is not present.
     */
    if (status == 1)
    {
        status = MCAPI_SUCCESS;
    }

    return (status);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_find_interface
*
*   DESCRIPTION
*
*       Find an interface based on name.
*
*   INPUTS
*
*       name                        The unique name of the interface.
*
*   OUTPUTS
*
*       A pointer to the interface structure.
*
*************************************************************************/
MCAPI_INTERFACE *mcapi_find_interface(char *name)
{
    int             i;
    MCAPI_INTERFACE *int_ptr = MCAPI_NULL;

    /* Search the interface list. */
    for (i = 0; i < MCAPI_INTERFACE_COUNT; i ++)
    {
        /* If the names match. */
        if (strcmp(MCAPI_Interface_List[i].mcapi_int_name, name) == 0)
        {
            /* Return this interface. */
            int_ptr = &MCAPI_Interface_List[i];

            break;
        }
    }

    return (int_ptr);

}
