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
*       scal_rcv
*
*   DESCRIPTION
*
*       Receive a scalar over a connected channel.
*
*   INPUTS
*
*       receive_handle          The local handle that is receiving the data.
*       *scalar                 A pointer to memory that will be filled with
*                               the received scalar.
*       type                    The type of scalar to be received; u64, u32,
*                               u16, u8.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void scal_rcv(mcapi_sclchan_recv_hndl_t receive_handle, MCAPI_SCALAR *scalar,
              mcapi_uint8_t type, mcapi_status_t *mcapi_status)
{
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *rx_endp_ptr;
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;
    MCAPI_BUFFER        *rx_buf = MCAPI_NULL;
    mcapi_request_t     request;

    /* Validate the incoming status parameter. */
    if (mcapi_status)
    {
        /* Lock the global data structure. */
        mcapi_lock_node_data();

        /* Get a pointer to the global node list. */
        node_data = mcapi_get_node_data();

        /* Get a pointer to the endpoint that is sending data. */
        rx_endp_ptr = mcapi_decode_local_endpoint(node_data, &node_id,
                                                  &port_id, receive_handle,
                                                  mcapi_status);

        /* Ensure the receive endpoint is valid. */
        if (*mcapi_status == MCAPI_SUCCESS)
        {
            /* Ensure this is a receive handle. */
            if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_RX)
            {
                /* Ensure this is a scalar channel. */
                if (rx_endp_ptr->mcapi_chan_type == MCAPI_CHAN_SCAL_TYPE)
                {
                    /* If the endpoint is still connected and there is no data
                     * on the endpoint.
                     */
                    if ( (rx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED) &&
                         (!rx_endp_ptr->mcapi_rx_queue.head) )
                    {
                        /* Initialize the request structure. */
                        mcapi_init_request(&request, MCAPI_REQ_RX_FIN);

                        /* Set up the request structure. */
                        request.mcapi_target_endp = receive_handle;
                        request.mcapi_chan_type = MCAPI_CHAN_SCAL_TYPE;

                        MCAPI_Suspend_Task(node_data, &request, &request.mcapi_cond,
                                           MCAPI_TIMEOUT_INFINITE);

                        /* Set the status. */
                        *mcapi_status = request.mcapi_status;
                    }

                    /* Check if there is data on the endpoint. */
                    if (rx_endp_ptr->mcapi_rx_queue.head)
                    {
                        /* Set the status to success. */
                        *mcapi_status = MCAPI_SUCCESS;

                        /* Get a pointer to the head of the queue. */
                        rx_buf = rx_endp_ptr->mcapi_rx_queue.head;

                        /* Remove the MCAPI header from the packet. */
                        rx_buf->buf_size -= MCAPI_HEADER_LEN;

                        switch (type)
                        {
                            case MCAPI_SCALAR_UINT8:

                                /* Ensure there are 8-bits of data waiting. */
                                if (rx_buf->buf_size == sizeof(mcapi_uint8_t))
                                {
                                    /* Get the 8-bits from the packet in native
                                     * order.
                                     */
                                    scalar->mcapi_scal.scal_uint8 =
                                        MCAPI_GET8(rx_buf->buf_ptr, MCAPI_HEADER_LEN);
                                }

                                /* The application is using the wrong scalar
                                 * receive routine to retrieve this data.
                                 */
                                else
                                {
                                    *mcapi_status = MCAPI_ERR_GENERAL;
                                }

                                break;

                            case MCAPI_SCALAR_UINT16:

                                /* Ensure there are 16-bits of data waiting. */
                                if (rx_buf->buf_size == sizeof(mcapi_uint16_t))
                                {
                                    /* Get the 16-bits from the packet in native
                                     * order.
                                     */
                                    scalar->mcapi_scal.scal_uint16 =
                                        MCAPI_GET16(rx_buf->buf_ptr, MCAPI_HEADER_LEN);
                                }

                                /* The application is using the wrong scalar
                                 * receive routine to retrieve this data.
                                 */
                                else
                                {
                                    *mcapi_status = MCAPI_ERR_GENERAL;
                                }

                                break;

                            case MCAPI_SCALAR_UINT32:

                                /* Ensure there are 32-bits of data waiting. */
                                if (rx_buf->buf_size == sizeof(mcapi_uint32_t))
                                {
                                    /* Get the 32-bits from the packet in native
                                     * order.
                                     */
                                    scalar->mcapi_scal.scal_uint32 =
                                        MCAPI_GET32(rx_buf->buf_ptr, MCAPI_HEADER_LEN);
                                }

                                /* The application is using the wrong scalar
                                 * receive routine to retrieve this data.
                                 */
                                else
                                {
                                    *mcapi_status = MCAPI_ERR_GENERAL;
                                }

                                break;

                            case MCAPI_SCALAR_UINT64:

                                /* Ensure there are 64-bits of data waiting. */
                                if (rx_buf->buf_size == sizeof(mcapi_uint64_t))
                                {
                                    /* Get the 64-bits from the packet in native
                                     * order.
                                     */
                                    scalar->mcapi_scal.scal_uint64 =
                                        MCAPI_GET64(rx_buf->buf_ptr, MCAPI_HEADER_LEN);
                                }

                                /* The application is using the wrong scalar
                                 * receive routine to retrieve this data.
                                 */
                                else
                                {
                                    *mcapi_status = MCAPI_ERR_GENERAL;
                                }

                                break;

                            default:

                                /* This can never happen. */
                                break;
                        }

                        /* Put the buffer back on the free list. */
                        if (*mcapi_status != MCAPI_ERR_GENERAL)
                        {
                            /* Remove the buffer from the receive queue. */
                            rx_buf = mcapi_dequeue(&rx_endp_ptr->mcapi_rx_queue);

                            /* Free the buffer. */
                            ((MCAPI_INTERFACE*)(rx_buf->mcapi_dev_ptr))->
                                mcapi_recover_buffer(rx_buf);
                        }
                    }

                    /* If the endpoint is no longer connected. */
                    else if (!(rx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED))
                    {
                        *mcapi_status = MCAPI_ERR_CHAN_INVALID;
                    }
                }

                /* The channel is a packet channel. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_TYPE;
                }
            }

            /* Attempting to receive on a send handle. */
            else if (rx_endp_ptr->mcapi_state & MCAPI_ENDP_TX)
            {
                *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
            }

            /* The receive side has been closed. */
            else
            {
                *mcapi_status = MCAPI_ERR_CHAN_INVALID;
            }
        }

        else if (*mcapi_status == MCAPI_ERR_ENDP_INVALID)
        {
            *mcapi_status = MCAPI_ERR_CHAN_INVALID;
        }

        /* Unlock the global data structure. */
        mcapi_unlock_node_data();
    }

}
