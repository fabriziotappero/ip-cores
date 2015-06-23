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
*       scal_send
*
*   DESCRIPTION
*
*       Send a scalar over a connected channel.  Called by both
*       blocking and non-blocking transmission routines.
*
*   INPUTS
*
*       send_handle             The transmission handle.
*       *buffer                 A pointer to the data to transmit.
*       type                    The type of scalar to transmit.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void scal_send(mcapi_pktchan_send_hndl_t send_handle, MCAPI_SCALAR *buffer,
               mcapi_uint8_t type, mcapi_status_t *mcapi_status)
{
    mcapi_port_t        port_id;
    mcapi_node_t        node_id;
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_ENDPOINT      *tx_endp_ptr = MCAPI_NULL;
    MCAPI_BUFFER        *tx_buf;

    if (mcapi_status)
    {
        /* Lock the global data structure. */
        mcapi_lock_node_data();

        /* Get a pointer to the global node list. */
        node_data = mcapi_get_node_data();

        /* Get a pointer to the endpoint that is sending data. */
        tx_endp_ptr = mcapi_decode_local_endpoint(node_data, &node_id,
                                                  &port_id, send_handle,
                                                  mcapi_status);

        /* Ensure the transmit endpoint is valid. */
        if (*mcapi_status == MCAPI_SUCCESS)
        {
            /* Ensure the handle is open for sending. */
            if ( (tx_endp_ptr->mcapi_state & MCAPI_ENDP_TX) &&
                 (tx_endp_ptr->mcapi_state & MCAPI_ENDP_CONNECTED) )
            {
                /* Ensure the handle is for a scalar channel. */
                if (tx_endp_ptr->mcapi_chan_type == MCAPI_CHAN_SCAL_TYPE)
                {
                    /* Get a transmission buffer for tracking when the outgoing
                     * data has been successfully sent.
                     */
                    tx_buf = tx_endp_ptr->mcapi_route->mcapi_rt_int->
                        mcapi_get_buffer(tx_endp_ptr->mcapi_foreign_node_id,
                                         sizeof(mcapi_uint64_t) + MCAPI_HEADER_LEN,
                                         tx_endp_ptr->mcapi_priority);

                    if (tx_buf)
                    {
                        /* Save a pointer to the tx interface. */
                        tx_buf->mcapi_dev_ptr =
                            (MCAPI_POINTER)(tx_endp_ptr->mcapi_route->mcapi_rt_int);

                        /* Set the source node in the packet. */
                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_SRC_NODE_OFFSET,
                                    tx_endp_ptr->mcapi_node_id);

                        /* Set the source port in the packet. */
                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_SRC_PORT_OFFSET,
                                    tx_endp_ptr->mcapi_port_id);

                        /* Set the destination node in the packet. */
                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_DEST_NODE_OFFSET,
                                    tx_endp_ptr->mcapi_foreign_node_id);

                        /* Set the destination port in the packet. */
                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_DEST_PORT_OFFSET,
                                    tx_endp_ptr->mcapi_foreign_port_id);

                        /* Set the priority of the packet. */
                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_PRIO_OFFSET,
                                    tx_endp_ptr->mcapi_priority);

                        /* Zero out the unused bits. */
                        MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_UNUSED_OFFSET, 0);

                        switch (type)
                        {
                            case MCAPI_SCALAR_UINT8:

                                /* Put the 8-bits in the packet in network order. */
                                MCAPI_PUT8(tx_buf->buf_ptr, MCAPI_HEADER_LEN,
                                           buffer->mcapi_scal.scal_uint8);

                                tx_buf->buf_size = sizeof(mcapi_uint8_t);

                                break;

                            case MCAPI_SCALAR_UINT16:

                                /* Put the 16-bits in the packet in network order. */
                                MCAPI_PUT16(tx_buf->buf_ptr, MCAPI_HEADER_LEN,
                                            buffer->mcapi_scal.scal_uint16);

                                tx_buf->buf_size = sizeof(mcapi_uint16_t);

                                break;

                            case MCAPI_SCALAR_UINT32:

                                /* Put the 32-bits in the packet in network order. */
                                MCAPI_PUT32(tx_buf->buf_ptr, MCAPI_HEADER_LEN,
                                            buffer->mcapi_scal.scal_uint32);

                                tx_buf->buf_size = sizeof(mcapi_uint32_t);

                                break;

                            case MCAPI_SCALAR_UINT64:

                                /* Put the 64-bits in the packet in network order. */
                                MCAPI_PUT64(tx_buf->buf_ptr, MCAPI_HEADER_LEN,
                                            buffer->mcapi_scal.scal_uint64);

                                tx_buf->buf_size = sizeof(mcapi_uint64_t);

                                break;

                            default:

                                /* This can never happen. */
                                break;
                        }

                        /* Set the length of the data in the buffer. */
                        tx_buf->buf_size += MCAPI_HEADER_LEN;

                        /* Pass the data to the transport layer driver. */
                        *mcapi_status = tx_endp_ptr->mcapi_route->mcapi_rt_int->
                            mcapi_tx_output(tx_buf, tx_buf->buf_size,
                                            tx_endp_ptr->mcapi_priority,
                                            tx_endp_ptr);

                        /* If the routine cannot complete immediately. */
                        if (*mcapi_status != MCAPI_SUCCESS)
                        {
                            /* Return the transmission buffer to the list of
                             * free buffers in the system.
                             */
                            ((MCAPI_INTERFACE*)(tx_buf->mcapi_dev_ptr))->
                                mcapi_recover_buffer(tx_buf);
                        }
                    }

                    /* There are no transmission buffers available to process this
                     * request.
                     */
                    else
                    {
                        *mcapi_status = MCAPI_ERR_TRANSMISSION;
                    }
                }

                /* The handle is for a packet channel. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_TYPE;
                }
            }

            /* The handle is open for receiving. */
            else
            {
                /* If this is a receive channel. */
                if (tx_endp_ptr->mcapi_state & MCAPI_ENDP_RX)
                {
                    *mcapi_status = MCAPI_ERR_CHAN_DIRECTION;
                }

                /* Otherwise, the connection has been closed. */
                else
                {
                    *mcapi_status = MCAPI_ERR_CHAN_INVALID;
                }
            }
        }

        else
        {
            *mcapi_status = MCAPI_ERR_CHAN_INVALID;
        }

        /* Unlock the global data structure. */
        mcapi_unlock_node_data();
    }

}
