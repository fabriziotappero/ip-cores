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

extern mcapi_endpoint_t     MCAPI_CTRL_TX_Endp;
extern MCAPI_BUF_QUEUE      MCAPI_Buf_Wait_List;
extern mcapi_endpoint_t     MCAPI_CTRL_RX_Endp;

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_check_resume
*
*   DESCRIPTION
*
*       Checks if any pending requests in the system should be resumed.
*
*   INPUTS
*
*       type                    The type of request to check.
*       endpoint                The endpoint for which the request is
*                               suspended on some action.
*       *endp_ptr               If data was received, a pointer to the
*                               endpoint for which data was received.
*       byte_count              If the type is MCAPI_REQ_TX_FIN or
*                               MCAPI_REQ_RX_FIN, the number of bytes
*                               pending on the endpoint.
*       status                  The status to set in the request structure.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_check_resume(int type, mcapi_endpoint_t endpoint,
                        MCAPI_ENDPOINT *endp_ptr, size_t byte_count,
                        mcapi_status_t status)
{
    mcapi_request_t     *request, *next_ptr;
    MCAPI_GLOBAL_DATA   *node_data;
    MCAPI_BUFFER        *rx_buf;
    mcapi_boolean_t     data_copied = 0;

    /* Get a pointer to the global node list. */
    node_data = mcapi_get_node_data();

    /* Get a pointer to the first entry in the request queue. */
    request = node_data->mcapi_local_req_queue.flink;

    /* Check each request to see if the operation has been completed. */
    while (request)
    {
        /* Get a pointer to the next entry. */
        next_ptr = request->mcapi_next;

        switch (type)
        {
            /* An endpoint associated with a request structure has been
             * deleted.
             */
            case MCAPI_REQ_DELETED:

                /* If the operation is waiting for something to happen
                 * on the send side, and the endpoint matches the send
                 * endpoint.
                 */
                if ( ((request->mcapi_type == MCAPI_REQ_TX_FIN) ||
                      (request->mcapi_type == MCAPI_REQ_TX_OPEN) ||
                      (request->mcapi_type == MCAPI_REQ_CONNECTED)) &&
                      (request->mcapi_target_endp == endpoint) )
                {
                    mcapi_resume(node_data, request, status);
                }

                /* If the operation is waiting for something to happen
                 * on the receive side, and the endpoint matches the receive
                 * endpoint.
                 */
                else if ( ((request->mcapi_type == MCAPI_REQ_RX_FIN) ||
                           (request->mcapi_type == MCAPI_REQ_RX_OPEN) ||
                           (request->mcapi_type == MCAPI_REQ_CONNECTED)) &&
                          (request->mcapi_target_endp == endpoint) )
                {
                    mcapi_resume(node_data, request, status);
                }

                break;

            /* The connection has been closed. */
            case MCAPI_REQ_CLOSED:

                /* No matter what the reason the thread is suspended, if the
                 * connection has been closed, resume the thread.
                 */
                if (request->mcapi_target_endp == endpoint)
                {
                    /* Resume the task. */
                    mcapi_resume(node_data, request, status);
                }

                break;

            /* The send side of an endpoint has been opened. */
            case MCAPI_REQ_TX_OPEN:

                /* If the request structure is waiting for the send side
                 * of the connection to open.
                 */
                if (request->mcapi_target_endp == endpoint)
                {
                    /* Resume the task. */
                    mcapi_resume(node_data, request, status);
                }

                break;

            /* Data associated with a request structure has been transmitted
             * successfully, or the transmit has been canceled.
             */
            case MCAPI_REQ_TX_FIN:

                /* If the request structure is waiting for outgoing data to be
                 * successfully transmitted.
                 */
                if ( (request->mcapi_type == MCAPI_REQ_TX_FIN) &&
                     (request->mcapi_target_endp == endpoint) )
                {
                    /* Indicate the number of bytes transmitted. */
                    request->mcapi_byte_count = byte_count;

                    /* Resume the task. */
                    mcapi_resume(node_data, request, status);
                }

                break;

            /* The receive side of an endpoint has been opened. */
            case MCAPI_REQ_RX_OPEN:

                /* If the request structure is waiting for the receive side
                 * of the connection to open.
                 */
                if (request->mcapi_target_endp == endpoint)
                {
                    /* Resume the task. */
                    mcapi_resume(node_data, request, status);
                }

                break;

            /* Data associated with a request structure has been received
             * successfully, or the receive has been canceled.
             */
            case MCAPI_REQ_RX_FIN:

                /* If the request structure is waiting for data to be
                 * received on the endpoint.
                 */
                if ( (request->mcapi_type == MCAPI_REQ_RX_FIN) &&
                     (request->mcapi_target_endp == endpoint) )
                {
                    switch (request->mcapi_chan_type)
                    {
                        case MCAPI_MSG_TYPE:

                            /* Ensure the data will fit in the buffer. */
                            if (byte_count <= request->mcapi_buf_size)
                            {
                                /* Copy the data into the user buffer. */
                                request->mcapi_byte_count =
                                    msg_recv_copy_data(endp_ptr, request->mcapi_buffer);

                                /* Data has been successfully copied. */
                                data_copied = MCAPI_TRUE;
                            }

                            /* The data is too big for the user buffer.  Leave
                             * the data on the receive queue for a subsequent
                             * receive call.
                             */
                            else
                            {
                                status = MCAPI_ERR_MSG_TRUNCATED;
                            }

                            break;

                        case MCAPI_CHAN_PKT_TYPE:

                            /* Get a pointer to the head buffer. */
                            rx_buf = endp_ptr->mcapi_rx_queue.head;

                            /* Set the user buffer to the incoming buffer. */
                            *(request->mcapi_pkt) =
                                &rx_buf->buf_ptr[MCAPI_HEADER_LEN];

                            /* Set the size of the incoming buffer. */
                            request->mcapi_byte_count =
                                rx_buf->buf_size - MCAPI_HEADER_LEN;

                            /* Data has been successfully copied. */
                            data_copied = MCAPI_TRUE;

                            break;

                        default:

                            break;
                    }

                    /* Resume the task. */
                    mcapi_resume(node_data, request, status);
                }

                break;

            /* An endpoint associated with a pending request has been
             * created.
             */
            case MCAPI_REQ_CREATED:

                /* If the request structure is waiting for an endpoint to be
                 * created.
                 */
                if ( (request->mcapi_type == MCAPI_REQ_CREATED) &&
                     (mcapi_encode_endpoint(request->mcapi_target_node_id,
                                            request->mcapi_target_port_id) == endpoint) )
                {
                    /* If this is a local call, fill in the endpoint pointer. */
                    if (request->mcapi_endp_ptr)
                    {
                        *(request->mcapi_endp_ptr) = endpoint;
                    }

                    mcapi_resume(node_data, request, status);
                }

                break;

            /* A connection between two endpoints has been made. */
            case MCAPI_REQ_CONNECTED:

                /* If the request structure is waiting for a connection
                 * between two endpoints to be made.
                 */
                if ( (request->mcapi_type == MCAPI_REQ_CONNECTED) &&
                     (request->mcapi_target_endp == endpoint) )
                {
                    /* Resume the task. */
                    mcapi_resume(node_data, request, status);
                }

                break;

            default:

                break;
        }

        /* Get the next request entry in the list. */
        request = next_ptr;
    }

    /* Multiple request structures could have been suspended on the same
     * receive operation; therefore, the data must not be removed from
     * the queue until all request structures have been serviced.
     */
    if (data_copied)
    {
        /* Remove the buffer from the receive queue. */
        rx_buf = mcapi_dequeue(&endp_ptr->mcapi_rx_queue);

        if (endp_ptr->mcapi_chan_type == MCAPI_CHAN_PKT_TYPE)
        {
            /* Add the receive buffer structure to the list of
             * buffers waiting to be freed by the application.
             */
            mcapi_enqueue(&MCAPI_Buf_Wait_List, rx_buf);
        }

        else
        {
            /* Return the message buffer to the pool of available buffers. */
            ((MCAPI_INTERFACE*)(rx_buf->mcapi_dev_ptr))->
                mcapi_recover_buffer(rx_buf);
        }
    }

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_resume
*
*   DESCRIPTION
*
*       Resume a specific task.
*
*   INPUTS
*
*       *node_data              A pointer to the global MCAPI node data
*                               structure.
*       *request                The request structure associated with the
*                               task to resume.
*       status                  The status to set in the request structure.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_resume(MCAPI_GLOBAL_DATA *node_data, mcapi_request_t *request,
                  mcapi_status_t status)
{
    /* Set the status so the blocking operation knows if the operation
     * completed successfully.
     */
    request->mcapi_status = status;

    /* Remove this request from the list. */
    mcapi_remove(&node_data->mcapi_local_req_queue, request);

    /* Resume the task. */
    MCAPI_Resume_Task(request);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_find_request
*
*   DESCRIPTION
*
*       Find a matching request structure on the global list.
*
*   INPUTS
*
*       *target_request         The target request to find.
*       *node_data              A pointer to the global node structure
*                               for the system.
*
*   OUTPUTS
*
*       A pointer to the request structure or MCAPI_NULL if the structure
*       could not be found.
*
*************************************************************************/
mcapi_request_t *mcapi_find_request(mcapi_request_t *target_request,
                                    MCAPI_REQ_QUEUE *req_queue)
{
    mcapi_request_t     *req_ptr;

    /* Get a pointer to the first entry in the request queue. */
    req_ptr = req_queue->flink;

    /* Search the list looking for the target entry. */
    while (req_ptr)
    {
        if ( (req_ptr->mcapi_requesting_node_id == target_request->mcapi_requesting_node_id) &&
             (req_ptr->mcapi_type == target_request->mcapi_type) &&
             (req_ptr->mcapi_target_endp == target_request->mcapi_target_endp) &&
             (req_ptr->mcapi_target_node_id == target_request->mcapi_target_node_id) &&
             (req_ptr->mcapi_target_port_id == target_request->mcapi_target_port_id) )
        {
            break;
        }

        /* Get a pointer to the next request structure. */
        req_ptr = req_ptr->mcapi_next;
    }

    return (req_ptr);

}
