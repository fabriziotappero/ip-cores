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

mcapi_node_t            MCAPI_Node_ID;
mcapi_uint8_t           MCAPI_Init = 0;
MCAPI_BUF_QUEUE         MCAPI_Buf_Wait_List;
mcapi_request_t         MCAPI_Free_Request_Structs[MCAPI_FREE_REQUEST_COUNT];
mcapi_endpoint_t        MCAPI_CTRL_TX_Endp;
MCAPI_BUF_QUEUE         MCAPI_RX_Queue[MCAPI_PRIO_COUNT];
MCAPI_MUTEX             MCAPI_RX_Lock;
mcapi_endpoint_t        MCAPI_CTRL_RX_Endp;
mcapi_uint16_t          MCAPI_Next_Port;

extern MCAPI_RT_INIT_STRUCT MCAPI_Route_List[];

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_initialize
*
*   DESCRIPTION
*
*       API routine to initialize an MCAPI node.  This routine must be
*       called by each node using MCAPI.  This routine must be called only
*       once per node.
*
*   INPUTS
*
*       node_id                 The system-wide unique node ID for the
*                               node being initialized.
*       *mcapi_version          A pointer to memory that will be filled
*                               in with the MCAPI implemenation version
*                               value for the system.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_initialize(mcapi_node_t node_id, mcapi_version_t *mcapi_version,
                      mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    int                 i, j, k;

    // initialize udp connection
    udp_init();
    /* Ensure mcapi_status is valid. */
    if (mcapi_status)
    {
        /* Validate the version pointer. */
        if (mcapi_version)
        {
            /* If the node has not already been initialized. */
            if (MCAPI_Init == 0)
            {
                /* Initialize status to success. */
                *mcapi_status = MCAPI_SUCCESS;

                /* Initialize the data for this node. */
                mcapi_init_node_data();

                /* Get the lock. */
                mcapi_lock_node_data();

                /* Initialize the wait list. */
                MCAPI_Buf_Wait_List.head = MCAPI_NULL;
                MCAPI_Buf_Wait_List.tail = MCAPI_NULL;

                /* Set each global request structure in the system to
                 * available.
                 */
                for (i = 0; i < MCAPI_FREE_REQUEST_COUNT; i++)
                {
                    /* Clear out the structure. */
                    memset(&MCAPI_Free_Request_Structs[i], 0,
                           sizeof(mcapi_request_t));
                }

                /* Initialize the receive queue that holds pending
                 * incoming messages.
                 */

                for (i = 0; i < MCAPI_PRIO_COUNT; i++)
                {
                    MCAPI_RX_Queue[i].head = MCAPI_NULL;
                    MCAPI_RX_Queue[i].tail = MCAPI_NULL;
                }

                /* Get a pointer to the global node list. */
                node_data = mcapi_get_node_data();

                /* Find the next available entry in the global list
                 * of nodes.
                 */
                for (i = 0; i < MCAPI_NODE_COUNT; i++)
                {
                    if (node_data->mcapi_node_list[i].mcapi_state ==
                        MCAPI_NODE_UNUSED)
                        break;
                }

                /* If a free entry was found. */
                if (i != MCAPI_NODE_COUNT)
                {
                    /* Ensure this node ID has not already been used. */
                    if (mcapi_find_node(node_id, node_data) == -1)
                    {
                        /* Increment the number of nodes in the system. */
                        node_data->mcapi_node_count ++;

                        /* Fill in the Node ID. */
                        node_data->mcapi_node_list[i].mcapi_node_id =
                            node_id;

                        /* Set the global node ID parameter for this node. */
                        MCAPI_Node_ID = node_id;

                        /* Set the state to MCAPI_NODE_INITIALIZED. */
                        node_data->mcapi_node_list[i].mcapi_state =
                            MCAPI_NODE_INITIALIZED;

                        /* Initialize the next port value to the configured
                         * first available port.
                         */
                        MCAPI_Next_Port = MCAPI_ENDP_PORT_INIT;

                        /* Initialize the open endpoint count to zero. */
                        node_data->mcapi_node_list[i].mcapi_endpoint_count = 0;

                        /* Initialize each endpoint. */
                        for (j = 0; j < MCAPI_MAX_ENDPOINTS; j++)
                        {
                            /* Set the initial state. */
                            node_data->mcapi_node_list[i].mcapi_endpoint_list[j].
                                mcapi_state = MCAPI_ENDP_CLOSED;

                            /* Set the head and tail of the RX queue. */
                            node_data->mcapi_node_list[i].mcapi_endpoint_list[j].
                                mcapi_rx_queue.head = MCAPI_NULL;

                            node_data->mcapi_node_list[i].mcapi_endpoint_list[j].
                                mcapi_rx_queue.tail = MCAPI_NULL;
                        }

                        /* Set the port to which other nodes should send status
                         * messages.
                         */
                        node_data->mcapi_node_list[i].mcapi_status_port =
                            MCAPI_RX_CONTROL_PORT;

                        /* Create an endpoint for receiving control messages.  This
                         * call will only fail if the node is configured as a router
                         * only, in which case it is OK to fail, as the control port
                         * is not necessary.
                         */
                        MCAPI_CTRL_RX_Endp = create_endpoint(&node_data->mcapi_node_list[i],
                                                             MCAPI_RX_CONTROL_PORT,
                                                             mcapi_status);

                        /* Initialize any OS specific data structures. */
                        if (MCAPI_Init_OS() == MCAPI_SUCCESS)
                        {
                            /* Create an endpoint for sending control messages to remote
                             * nodes.  This call will only fail if the node is configured
                             * as a router only, in which case it is OK to fail, as the
                             * control port is not necessary.
                             */
                            MCAPI_CTRL_TX_Endp = create_endpoint(&node_data->mcapi_node_list[i],
                                                                 MCAPI_PORT_ANY,
                                                                 mcapi_status);

                            /* Initialize all interfaces on the node. */
                            *mcapi_status = mcapi_init_interfaces(node_id);
			    
                            if (*mcapi_status == MCAPI_SUCCESS)
                            {
                                /* Set the version. */
                                *mcapi_version = MCAPI_VERSION;

                                /* Indicate that this node has been initialized. */
                                MCAPI_Init = 1;

                                /* Add the respective routes to the node. */
                                for (j = 0, k = 0;
                                     MCAPI_Route_List[j].mcapi_int_name[0] != '0';
                                     j++)
                                {
                                    /* Set the destination of the route. */
                                    node_data->mcapi_node_list[i].mcapi_route_list[k].
                                        mcapi_rt_dest_node_id =
                                        MCAPI_Route_List[j].mcapi_rt_dest_id;

                                    /* Set a pointer to the interface for the route. */
                                    node_data->mcapi_node_list[i].mcapi_route_list[k].mcapi_rt_int =
                                        mcapi_find_interface(MCAPI_Route_List[j].mcapi_int_name);

                                    k++;
                                }
                            }
                        }

                        else
                        {
                            *mcapi_status = MCAPI_ERR_TRANSMISSION;
                        }
                    }

                    /* The Node ID is not unique. */
                    else
                    {
                        *mcapi_status = MCAPI_ERR_NODE_INVALID;
                    }
                }

                /* The Node ID is not the local node's ID. */
                else
                {
                    *mcapi_status = MCAPI_ERR_NODE_INVALID;
                }

                /* Release the lock. */
                mcapi_unlock_node_data();
            }

            /* Initialization has already been called for this node. */
            else
            {
                *mcapi_status = MCAPI_ERR_NODE_INITIALIZED;
            }
        }

        /* The version parameter is invalid. */
        else
        {
            *mcapi_status = MCAPI_ERR_PARAMETER;
        }
    }
    
}
