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
*       destroy_svc.c
*
*
*************************************************************************/
#include "mcapid_support.h"

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Destroy_Service
*
*   DESCRIPTION
*
*       This function loops through a list of structures, deallocating
*       all resources associated with the respective endpoint.
*
*   INPUTS
*
*       *mcapi_struct           A pointer to an array of MCAPID_STRUCT
*                               structures populated by
*                               MCAPID_Create_Service().
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
void MCAPID_Destroy_Service(MCAPID_STRUCT *mcapi_struct, int count)
{
    int     i;

    for (i = 0; i < count; i ++)
    {
        /* Initialize status to success. */
        mcapi_struct[i].status = MCAPI_SUCCESS;

        /* If a service was specified. */
        if (mcapi_struct[i].service)
        {
            /* Operate on the service field based on the type of endpoint. */
            switch (mcapi_struct[i].type)
            {
                /* Server endpoints remove services from the registry. */
                case MCAPI_CHAN_PKT_RX_TYPE:
                case MCAPI_CHAN_SCL_RX_TYPE:
                case MCAPI_MSG_RX_TYPE:

                    /* Remove the service from the registry. */
                    mcapi_struct[i].status =
                        MCAPID_Remove_Service(mcapi_struct[i].service,
                                              mcapi_struct[i].node,
                                              mcapi_struct[i].local_port);

                    break;

                default:

                    break;
            }
        }

        if (mcapi_struct[i].status == MCAPI_SUCCESS)
        {
            /* Operate on the structure based on the type of endpoint being
             * created.
             */
            switch (mcapi_struct[i].type)
            {
                /* The TX side of a packet channel. */
                case MCAPI_CHAN_PKT_TX_TYPE:

                    /* Close the TX side. */
                    mcapi_packetchan_send_close_i(mcapi_struct[i].pkt_tx_handle,
                                                  &mcapi_struct[i].request,
                                                  &mcapi_struct[i].status);

                    break;

                case MCAPI_CHAN_PKT_RX_TYPE:

                    /* Close the RX side. */
                    mcapi_packetchan_recv_close_i(mcapi_struct[i].pkt_rx_handle,
                                                  &mcapi_struct[i].request,
                                                  &mcapi_struct[i].status);

                    break;

                case MCAPI_CHAN_SCL_TX_TYPE:

                    /* Close the TX side. */
                    mcapi_sclchan_send_close_i(mcapi_struct[i].scl_tx_handle,
                                               &mcapi_struct[i].request,
                                               &mcapi_struct[i].status);

                    break;

                case MCAPI_CHAN_SCL_RX_TYPE:

                    /* Close the RX side. */
                    mcapi_sclchan_recv_close_i(mcapi_struct[i].scl_rx_handle,
                                               &mcapi_struct[i].request,
                                               &mcapi_struct[i].status);

                    break;

                default:

                    break;
            }
        }

        /* Delete the local endpoint. */
        mcapi_delete_endpoint(mcapi_struct[i].local_endp, &mcapi_struct[i].status);
    }

} /* MCAPID_Destroy_Service */
