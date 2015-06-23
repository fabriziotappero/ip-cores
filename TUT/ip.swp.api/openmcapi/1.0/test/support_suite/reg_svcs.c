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

/*
*   FILENAME
*
*       reg_svcs.c
*
*
*************************************************************************/

#include "openmcapi.h" /* XXX remove me */
#include "mcapid_support.h"
#include "mcapid.h"

MCAPID_SERVICE_STRUCT   MCAPID_Registered_Services[MCAPID_MAX_SERVICES];

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Registration_Server
*
*   DESCRIPTION
*
*       This function services incoming registration requests.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPID_Registration_Server)
{
    mcapi_status_t      status;
    mcapi_endpoint_t    rx_endp;
    unsigned char       buffer[MCAPID_REG_MSG_LEN];
    size_t              rx_len;
    int                 i, avail;

    /* Initialize each entry to available. */
    for (i = 0; i < MCAPID_MAX_SERVICES; i ++)
    {
        MCAPID_Registered_Services[i].avail = MCAPI_TRUE;
    }

    /* Create the registration service receive endpoint. */
    rx_endp = mcapi_create_endpoint(MCAPID_REG_SERVER_PORT, &status);

    if (status == MCAPI_SUCCESS)
    {
        for (;;)
        {
            /* Wait for a node to issue a request. */
            mcapi_msg_recv(rx_endp, buffer, MCAPID_REG_MSG_LEN, &rx_len,
                           &status);

            if (status == MCAPI_SUCCESS)
            {
                /* If this is a registration request. */
                if (mcapi_get32(buffer, MCAPID_SVCREG_TYPE_OFFSET) == MCAPID_REG_SVC)
                {
                    /* Initialize the "available" variable. */
                    avail = -1;

                    /* Check that this registration is unique and find an available
                     * slot for the new registration.
                     */
                    for (i = 0; i < MCAPID_MAX_SERVICES; i ++)
                    {
                        /* If this entry is available, save it for later. */
                        if ( (avail == -1) &&
                             (MCAPID_Registered_Services[i].avail == MCAPI_TRUE) )
                        {
                            avail = i;
                        }

                        /* If the two strings match. */
                        if ( (MCAPID_Registered_Services[i].avail == MCAPI_FALSE) &&
                             (strcmp((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET],
                                     MCAPID_Registered_Services[i].service) == 0) )
                        {
                            status = -1;
                            break;
                        }
                    }

                    /* If the registration request was successful and the service
                     * name will fit in the available memory.
                     */
                    if ( (status == MCAPI_SUCCESS) && (avail != -1) &&
                         (strlen((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET]) <= MCAPID_SVC_LEN) )
                    {
                        /* Store the service name. */
                        strcpy(MCAPID_Registered_Services[avail].service,
                               (char*)&buffer[MCAPID_SVCREG_NAME_OFFSET]);

                        /* Store the node and endpoint. */
                        MCAPID_Registered_Services[avail].port =
                            mcapi_get32(buffer, MCAPID_SVCREG_PORT_OFFSET);
                        MCAPID_Registered_Services[avail].node =
                            mcapi_get32(buffer, MCAPID_SVCREG_NODE_OFFSET);

                        /* Indicate that this block is taken. */
                        MCAPID_Registered_Services[avail].avail = MCAPI_FALSE;

                        /* Set status to success. */
                        mcapi_put32(buffer, MCAPID_SVCREG_STATUS_OFFSET, MCAPI_SUCCESS);
                    }

                    /* An error occurred. */
                    else
                    {
                        /* Set the status to an error. */
                        mcapi_put32(buffer, MCAPID_SVCREG_STATUS_OFFSET, 0xffffffff);
                    }
                }

                /* If this is a removal request. */
                else if (mcapi_get32(buffer, MCAPID_SVCREG_TYPE_OFFSET) == MCAPID_REM_SVC)
                {
                    /* Find the target service. */
                    for (i = 0; i < MCAPID_MAX_SERVICES; i ++)
                    {
                        /* If the two strings match. */
                        if (strcmp((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET],
                                   MCAPID_Registered_Services[i].service) == 0)
                        {
                            /* Indicate that this block is free. */
                            MCAPID_Registered_Services[i].avail = MCAPI_TRUE;

                            break;
                        }
                    }

                    /* Return success regardless. */
                    mcapi_put32(buffer, MCAPID_SVCREG_STATUS_OFFSET, MCAPI_SUCCESS);
                }

                /* If this is a registration query. */
                else if (mcapi_get32(buffer, MCAPID_SVCREG_TYPE_OFFSET) == MCAPID_GET_SVC)
                {
                    /* Find the target service. */
                    for (i = 0; i < MCAPID_MAX_SERVICES; i ++)
                    {
                        /* If the two strings match. */
                        if (strcmp((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET],
                                   MCAPID_Registered_Services[i].service) == 0)
                        {
                            /* Store the node and port in the outgoing buffer. */
                            mcapi_put32(buffer, MCAPID_SVCREG_PORT_OFFSET,
                                        MCAPID_Registered_Services[i].port);
                            mcapi_put32(buffer, MCAPID_SVCREG_NODE_OFFSET,
                                        MCAPID_Registered_Services[i].node);

                            /* Set the status to success. */
                            mcapi_put32(buffer, MCAPID_SVCREG_STATUS_OFFSET, MCAPI_SUCCESS);

                            break;
                        }
                    }

                    /* If the service could not be found. */
                    if (i == MCAPID_MAX_SERVICES)
                    {
                        /* Set the status to an error. */
                        mcapi_put32(buffer, MCAPID_SVCREG_STATUS_OFFSET, 0xffffffff);
                    }
                }

                /* Send the reply. */
                mcapi_msg_send(rx_endp, mcapi_get32(buffer, MCAPID_SVCREG_RXENDP_OFFSET),
                               buffer, rx_len, MCAPI_DEFAULT_PRIO, &status);
            }

            else
            {
                /* Terminate this task. */
                MCAPI_Cleanup_Task();

                break;
            }
        }
    }

} /* MCAPID_Registration_Server */

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Remove_Service
*
*   DESCRIPTION
*
*       This function issues a de-registration request for a service/endpoint
*       tuple.
*
*************************************************************************/
mcapi_status_t MCAPID_Remove_Service(char *service, mcapi_node_t node,
                                     mcapi_port_t port)
{
    unsigned char       buffer[MCAPID_REG_MSG_LEN];
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len;
    mcapi_status_t      status, local_status;

    /* Get the registration service endpoint. */
    tx_endp = mcapi_get_endpoint(MCAPID_REG_SERVER_NODE, MCAPID_REG_SERVER_PORT,
                                 &status);

    if (status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for sending the request and receiving the
         * reply.
         */
        rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &status);

        if (status == MCAPI_SUCCESS)
        {
            /* Set the type to indicate a de-registration request. */
            mcapi_put32(buffer, MCAPID_SVCREG_TYPE_OFFSET, MCAPID_REM_SVC);

            /* Store the endpoint to be registered. */
            mcapi_put32(buffer, MCAPID_SVCREG_PORT_OFFSET, port);
            mcapi_put32(buffer, MCAPID_SVCREG_NODE_OFFSET, node);

            /* Store the endpoint to which the reply should be sent. */
            mcapi_put32(buffer, MCAPID_SVCREG_RXENDP_OFFSET, rx_endp);

            /* Store the name of the service. */
            strcpy((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET], service);

            /* Send the message. */
            mcapi_msg_send(rx_endp, tx_endp, buffer, MCAPID_REG_MSG_LEN,
                           MCAPI_DEFAULT_PRIO, &status);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a reply. */
                mcapi_msg_recv(rx_endp, buffer, MCAPID_REG_MSG_LEN, &rx_len,
                               &status);

                if (status == MCAPI_SUCCESS)
                {
                    /* Extract the status of the operation. */
                    status = mcapi_get32(buffer, MCAPID_SVCREG_STATUS_OFFSET);
                }
            }

            /* Delete the endpoint. */
            mcapi_delete_endpoint(rx_endp, &local_status);
        }
    }

    return (status);

} /* MCAPID_Remove_Service */

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Register_Service
*
*   DESCRIPTION
*
*       This function issues a registration request for a service/endpoint
*       tuple.
*
*************************************************************************/
mcapi_status_t MCAPID_Register_Service(char *service, mcapi_node_t node,
                                       mcapi_port_t port)
{
    unsigned char       buffer[MCAPID_REG_MSG_LEN];
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len;
    mcapi_status_t      status, local_status;

    /* Get the registration service endpoint. */
    tx_endp = mcapi_get_endpoint(MCAPID_REG_SERVER_NODE, MCAPID_REG_SERVER_PORT,
                                 &status);

    if (status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for sending the request and receiving the
         * reply.
         */
        rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &status);

        if (status == MCAPI_SUCCESS)
        {
            if (status == MCAPI_SUCCESS)
            {
                /* Set the type to indicate a registration request. */
                mcapi_put32(buffer, MCAPID_SVCREG_TYPE_OFFSET, MCAPID_REG_SVC);

                /* Store the node and port to be registered. */
                mcapi_put32(buffer, MCAPID_SVCREG_NODE_OFFSET, node);
                mcapi_put32(buffer, MCAPID_SVCREG_PORT_OFFSET, port);

                /* Store the endpoint to which the reply should be sent. */
                mcapi_put32(buffer, MCAPID_SVCREG_RXENDP_OFFSET, rx_endp);

                /* Store the name of the service. */
                strcpy((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET], service);

                /* Send the message. */
                mcapi_msg_send(rx_endp, tx_endp, buffer, MCAPID_REG_MSG_LEN,
                               MCAPI_DEFAULT_PRIO, &status);

                if (status == MCAPI_SUCCESS)
                {
                    /* Wait for a reply. */
                    mcapi_msg_recv(rx_endp, buffer, MCAPID_REG_MSG_LEN, &rx_len,
                                   &status);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Extract the status of the operation. */
                        status = mcapi_get32(buffer, MCAPID_SVCREG_STATUS_OFFSET);
                    }
                }
            }

            /* Delete the endpoint. */
            mcapi_delete_endpoint(rx_endp, &local_status);
        }
    }

    return (status);

} /* MCAPID_Register_Service */

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Get_Service
*
*   DESCRIPTION
*
*       This function gets the node and port associated with a service.
*
*************************************************************************/
mcapi_status_t MCAPID_Get_Service(char *service, mcapi_endpoint_t *endp)
{
    unsigned char       buffer[MCAPID_REG_MSG_LEN];
    mcapi_endpoint_t    rx_endp, tx_endp;
    size_t              rx_len;
    mcapi_status_t      status, local_status;

    /* Get the registration service endpoint. */
    tx_endp = mcapi_get_endpoint(MCAPID_REG_SERVER_NODE, MCAPID_REG_SERVER_PORT,
                                 &status);

    if (status == MCAPI_SUCCESS)
    {
        /* Create an endpoint for sending the request and receiving the
         * reply.
         */
        rx_endp = mcapi_create_endpoint(MCAPI_PORT_ANY, &status);

        if (status == MCAPI_SUCCESS)
        {
            /* Set the type to indicate a get request. */
            mcapi_put32(buffer, MCAPID_SVCREG_TYPE_OFFSET, MCAPID_GET_SVC);

            /* Store the endpoint to which the reply should be sent. */
            mcapi_put32(buffer, MCAPID_SVCREG_RXENDP_OFFSET, rx_endp);

            /* Store the name of the service. */
            strcpy((char*)&buffer[MCAPID_SVCREG_NAME_OFFSET], service);

            /* Send the message. */
            mcapi_msg_send(rx_endp, tx_endp, buffer, MCAPID_REG_MSG_LEN,
                           MCAPI_DEFAULT_PRIO, &status);

            if (status == MCAPI_SUCCESS)
            {
                /* Wait for a reply. */
                mcapi_msg_recv(rx_endp, buffer, MCAPID_REG_MSG_LEN, &rx_len,
                               &status);

                if (status == MCAPI_SUCCESS)
                {
                    /* Extract the status. */
                    status = mcapi_get32(buffer, MCAPID_SVCREG_STATUS_OFFSET);

                    if (status == MCAPI_SUCCESS)
                    {
                        /* Extract the node and port. */
                        mcapi_port_t port;
                        mcapi_node_t node;

                        port = mcapi_get32(buffer, MCAPID_SVCREG_PORT_OFFSET);
                        node = mcapi_get32(buffer, MCAPID_SVCREG_NODE_OFFSET);

                        *endp = mcapi_get_endpoint(node, port, &status);
                    }
                }
            }

            /* Delete the endpoint. */
            mcapi_delete_endpoint(rx_endp, &local_status);
        }
    }

    return (status);

} /* MCAPID_Get_Service */

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Finished
*
*   DESCRIPTION
*
*       Infinite loop entered when the demonstration has completed.
*
*************************************************************************/
void MCAPID_Finished(void)
{
    for (;;)
    {
        MCAPID_Sleep(1000);
    }
} /* MCAPID_Finished */
