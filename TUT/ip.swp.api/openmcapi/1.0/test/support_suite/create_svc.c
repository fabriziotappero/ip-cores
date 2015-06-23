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
*       create_svc.c
*
*
*************************************************************************/
#include "mcapid_support.h"

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Create_Service
*
*   DESCRIPTION
*
*       This function loops through a list of structures, performing
*       service requests based on the type of endpoint in each structure.
*       For each structure, a local endpoint is created and one of the
*       following functions performed:
*
*       Packet / Scalar Channel Client - If a service is specified, get
*       the endpoint associated with the service, create a connection,
*       and open the send side of the connection.
*
*       Packet / Scalar Channel Server - If a service is specified,
*       register the service with the registration node and open the
*       receive side of the connection.
*
*       Client Message - If a service is specified, get the endpoint
*       associated with the service.
*
*       Server Message - If a service is specified, register the service
*       with the registration node.
*
*   INPUTS
*
*       *mcapi_struct           A pointer to an array of MCAPID_STRUCT
*                               structures populated as follows:
*
*                               type - MCAPI_CHAN_PKT_TX_TYPE,
*                                      MCAPI_CHAN_PKT_RX_TYPE,
*                                      MCAPI_CHAN_SCL_TX_TYPE,
*                                      MCAPI_CHAN_SCL_RX_TYPE,
*                                      MCAPI_MSG_TX_TYPE,
*                                      MCAPI_MSG_RX_TYPE
*
*                               local_port - The local port to use or
*                               MCAPI_ANY_PORT if unspecified.
*
*                               *service - The name of the service to
*                               register if type is a _RX_; otherwise,
*                               the name of the service to get.
*
*                               retry - If type is _TX_, the number of
*                               times to retry the service get request.
*
*       count                   The number of elements in the mcapi_struct
*                               structure.
*
*   RETURN
*
*       None.  The status field of each MCAPID_STRUCT parameter will be
*       set according to the status of that service request.
*
*************************************************************************/
int MCAPID_Create_Service(MCAPID_STRUCT *mcapi_struct)
{
    mcapi_request_t request;
    int             retry;
    size_t          size;
    mcapi_status_t  status;
    static int      next_free_port = 20; /* arbitrary */
    int             rc = 0;

    /* Can't use MCAPI_PORT_ANY, because we need to know the port in order to
     * register it. */
    if (mcapi_struct->local_port == MCAPI_PORT_ANY) {
        mcapi_struct->local_port = next_free_port++;
    }

    /* Create the local endpoint. */
    mcapi_struct->local_endp = mcapi_create_endpoint(mcapi_struct->local_port,
                                                       &mcapi_struct->status);

    if (mcapi_struct->status == MCAPI_SUCCESS)
    {
        /* If a service was specified. */
        if (mcapi_struct->service)
        {
            /* Operate on the service field based on the type of endpoint. */
            switch (mcapi_struct->type)
            {
                /* Client type endpoints get services. */
                case MCAPI_CHAN_PKT_TX_TYPE:
                case MCAPI_CHAN_SCL_TX_TYPE:
                case MCAPI_MSG_TX_TYPE:

                    retry = mcapi_struct->retry;

                    do
                    {
                        /* Get the foreign endpoint. */
                        mcapi_struct->status =
                            MCAPID_Get_Service(mcapi_struct->service,
                                               &mcapi_struct->foreign_endp);

                        if (retry > 0)
                            retry --;

                        /* All attempts have been made. */
                        else if (retry != 0xffffffff)
                            break;

                    } while ( (mcapi_struct->status != MCAPI_SUCCESS) &&
                              (mcapi_struct->status != MCAPI_ERR_GENERAL) );

                    break;

                /* Server type endpoints register services. */
                case MCAPI_CHAN_PKT_RX_TYPE:
                case MCAPI_CHAN_SCL_RX_TYPE:
                case MCAPI_MSG_RX_TYPE:

                    /* Register the service. */
                    mcapi_struct->status =
                        MCAPID_Register_Service(mcapi_struct->service,
                                                mcapi_struct->node,
                                                mcapi_struct->local_port);

                    break;

                default:

                    break;
            }
        }

        /* If the service was registered / retrieved. */
        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Operate on the structure based on the type of endpoint being
             * created.
             */
            switch (mcapi_struct->type)
            {
                /* The TX side of a packet channel. */
                case MCAPI_CHAN_PKT_TX_TYPE:

                    /* If a service was specified. */
                    if (mcapi_struct->service)
                    {
                        /* Issue the connection. */
                        mcapi_connect_pktchan_i(mcapi_struct->local_endp,
                                                mcapi_struct->foreign_endp,
                                                &request, &mcapi_struct->status);

                        /* Wait for the connection to complete. */
                        mcapi_wait(&request, &size, &mcapi_struct->status,
                                   MCAPI_TIMEOUT_INFINITE);
                    }

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the TX side. */
                        mcapi_open_pktchan_send_i(&mcapi_struct->pkt_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &mcapi_struct->request,
                                                  &mcapi_struct->status);
                        mcapi_wait(&mcapi_struct->request, &size,
                                   &mcapi_struct->status, MCAPI_TIMEOUT_INFINITE);
                    }

                    break;

                case MCAPI_CHAN_PKT_RX_TYPE:

                    /* Open the RX side. */
                    mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                              mcapi_struct->local_endp,
                                              &mcapi_struct->request,
                                              &mcapi_struct->status);
                    mcapi_wait(&mcapi_struct->request, &size,
                               &mcapi_struct->status, MCAPI_TIMEOUT_INFINITE);

                    break;

                case MCAPI_CHAN_SCL_TX_TYPE:

                    /* If a service was specified. */
                    if (mcapi_struct->service)
                    {
                        /* Issue the connection. */
                        mcapi_connect_sclchan_i(mcapi_struct->local_endp,
                                                mcapi_struct->foreign_endp,
                                                &request, &mcapi_struct->status);

                        /* Wait for the connection to complete. */
                        mcapi_wait(&request, &size, &mcapi_struct->status,
                                   MCAPI_TIMEOUT_INFINITE);
                    }

                    if (mcapi_struct->status == MCAPI_SUCCESS)
                    {
                        /* Open the TX side. */
                        mcapi_open_sclchan_send_i(&mcapi_struct->scl_tx_handle,
                                                  mcapi_struct->local_endp,
                                                  &mcapi_struct->request,
                                                  &mcapi_struct->status);
                        mcapi_wait(&mcapi_struct->request, &size,
                                   &mcapi_struct->status, MCAPI_TIMEOUT_INFINITE);
                    }

                    break;

                case MCAPI_CHAN_SCL_RX_TYPE:

                    /* Open the RX side. */
                    mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                              mcapi_struct->local_endp,
                                              &mcapi_struct->request,
                                              &mcapi_struct->status);

                    break;

                default:

                    break;
            }

            if (mcapi_struct->thread_entry)
            {
                /* Start the service locally. */
                MCAPID_Create_Thread(mcapi_struct->thread_entry, mcapi_struct);
            }
            else if (mcapi_struct->func)
            {
                rc = (int)mcapi_struct->func(mcapi_struct);
            }
        }

        /* If an error occurred. */
        if ( (mcapi_struct->status != MCAPI_SUCCESS) &&
             (mcapi_struct->status != MGC_MCAPI_ERR_NOT_CONNECTED) )
        {
            /* Delete the endpoint since the service could not be
             * registered / retrieved.  The call has failed for this
             * instance of the MCAPID_STRUCT.
             */
            mcapi_delete_endpoint(mcapi_struct->local_endp, &status);
        }
    }

    return rc;
} /* MCAPID_Create_Service */
