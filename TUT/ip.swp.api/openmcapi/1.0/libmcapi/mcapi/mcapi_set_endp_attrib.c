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
*       mcapi_set_endpoint_attribute
*
*   DESCRIPTION
*
*       API routine to set attributes specific to a local endpoint.
*
*   INPUTS
*
*       endpoint                The endpoint identifier on the local node
*                               of which to set the attribute.
*       attribute_num           The attribute to set.
*       *attribute              The new value of the attribute being set.
*       attribute_size          The number of bytes contained in *attribute.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_set_endpoint_attribute(mcapi_endpoint_t endpoint,
                                  mcapi_uint_t attribute_num,
                                  void *attribute,
                                  size_t attribute_size,
                                  mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *endp_ptr = MCAPI_NULL;
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;

    /* Validate mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate attribute input parameter. */
        if (attribute)
        {
            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the global node list. */
            node_data = mcapi_get_node_data();

            /* Get a pointer to the endpoint. */
            endp_ptr = mcapi_decode_local_endpoint(node_data, &node_id, &port_id,
                                                   endpoint, mcapi_status);

            /* Ensure the endpoint is valid. */
            if ( (*mcapi_status == MCAPI_SUCCESS) &&
                 (endp_ptr->mcapi_state != MCAPI_ENDP_CLOSED) )
            {
                /* Ensure the endpoint is not already connected. */
                if (!(endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTING))
                {
                    switch (attribute_num)
                    {
                        case MCAPI_ATTR_ENDP_PRIO:

                            /* If the priority is the correct size */
                            if (attribute_size == sizeof(endp_ptr->mcapi_priority))
                            {
                                /* Ensure the priority is valid. */
                                if (*(mcapi_uint32_t*)attribute < MCAPI_PRIO_COUNT)
                                {
                                    /* Update the priority of the endpoint. */
                                    endp_ptr->mcapi_priority = *(mcapi_uint32_t*)attribute;

                                    *mcapi_status = MCAPI_SUCCESS;
                                }

                                else
                                {
                                    *mcapi_status = MCAPI_ERR_PARAMETER;
                                }
                            }

                            /* The priority value is the wrong size. */
                            else
                            {
                                *mcapi_status = MCAPI_ERR_ATTR_SIZE;
                            }

                            break;

                    default:

                        /* If there is a route associated with the endpoint. */
                        if (endp_ptr->mcapi_route)
                        {
                            /* If there is an interfae associated with the
                             * route.
                             */
                            if (endp_ptr->mcapi_route->mcapi_rt_int)
                            {
                                /* Call the interface-specific ioctl command. */
                                *mcapi_status =
                                    endp_ptr->mcapi_route->mcapi_rt_int->mcapi_ioctl(attribute_num,
                                                                                     attribute,
                                                                                     attribute_size);
                            }
                        }

                        else
                        {
                            /* Unknown attribute. */
                            *mcapi_status = MCAPI_ERR_ATTR_NUM;
                        }

                        break;
                    }
                }

                /* Attributes of an endpoint cannot be changed once the
                 * endpoint has been connected.
                 */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_CONNECTED;
                }
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* The pointer for attribute is invalid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }

}
