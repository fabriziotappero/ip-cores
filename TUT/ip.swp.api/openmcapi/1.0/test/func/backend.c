/*
 * Copyright (c) 2011, Mentor Graphics Corporation
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

#include <stdio.h>
#include <mcapi.h>
#include "fts_defs.h"
#include "support_suite/mcapid_support.h"
#include "mcapid.h"

MCAPID_STRUCT   MCAPID_Reg_Struct, MCAPID_Mgmt_Struct, MCAPID_Echo_Struct[4];

unsigned        MCAPID_Failures = 0;

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Msg_Server
*
*   DESCRIPTION
*
*       Listen on an endpoint for incoming messages, and echo back the
*       data.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Msg_Echo_Server)
{
    MCAPID_STRUCT       *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                buffer[MCAPID_MSG_LEN];
    size_t              rx_len;
    mcapi_status_t      status;

    for (;;)
    {
        /* Wait for a message. */
        mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MSG_LEN, &rx_len,
                       &status);

        if (status == MCAPI_SUCCESS)
        {
            /* Echo the message. */
            mcapi_msg_send(mcapi_struct->local_endp,
                           mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                           buffer, MCAPID_MSG_LEN,
                           MCAPI_DEFAULT_PRIO, &status);
        }
    }

} /* MCAPI_FTS_Msg_Echo_Server */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Pkt_Server
*
*   DESCRIPTION
*
*       Open the receive side of a connection, wait for a connection,
*       listen on an endpoint for incoming messages.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Pkt_Server)
{
    MCAPID_STRUCT               *mcapi_struct = (MCAPID_STRUCT*)argv;
    char                        *buffer;
    size_t                      rx_len;

    for (;;)
    {
        /* Wait for a connection to be established. */
        mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                   MCAPI_TIMEOUT_INFINITE);

        for (;;)
        {
            /* Wait for an incoming message. */
            mcapi_pktchan_recv(mcapi_struct->pkt_rx_handle, (void**)&buffer,
                               &rx_len, &mcapi_struct->status);

            /* If data was received. */
            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                /* Free the buffer. */
                mcapi_pktchan_free(buffer, &mcapi_struct->status);
            }

            /* If the connection has been closed. */
            else
            {
                /* Close the receive side. */
                mcapi_packetchan_recv_close_i(mcapi_struct->pkt_rx_handle,
                                              &mcapi_struct->request,
                                              &mcapi_struct->status);

                break;
            }
        }

        /* Open the local endpoint back up as the receiver. */
        mcapi_open_pktchan_recv_i(&mcapi_struct->pkt_rx_handle,
                                  mcapi_struct->local_endp,
                                  &mcapi_struct->request, &mcapi_struct->status);
    }

} /* MCAPI_FTS_Pkt_Server */

/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Scl_Server
*
*   DESCRIPTION
*
*       Open the receive side of a connection, wait for a connection,
*       listen on an endpoint for incoming messages.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Scl_Server)
{
    MCAPID_STRUCT   *mcapi_struct = (MCAPID_STRUCT*)argv;
    size_t          rx_len;
    char            buffer[MCAPID_MGMT_PKT_LEN];
    mcapi_uint32_t  type;
    mcapi_uint64_t  recv_64;
    mcapi_uint32_t  recv_32;
    mcapi_uint16_t  recv_16;
    mcapi_uint8_t   recv_8;
    mcapi_status_t  status;

    for (;;)
    {
        /* Wait for a message indicating the type of receive to perform. */
        mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                       &rx_len, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            type = mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_TYPE_OFFSET);

            /* Check the receive type to ensure it is valid. */
            if ( (type == MCAPID_RX_64_BIT_SCL) ||
                 (type == MCAPID_RX_32_BIT_SCL) ||
                 (type == MCAPID_RX_16_BIT_SCL) ||
                 (type == MCAPID_RX_8_BIT_SCL) )
            {
                /* Send a successful status. */
                status = MCAPI_SUCCESS;
            }

            else
            {
                /* Send an error, but continue with opening the receive
                 * side and closing in case the other side wants to send
                 * data over a closed connection.
                 */
                status = -1;
            }

            /* Put the status in the packet. */
            mcapi_put32((unsigned char*)buffer, MCAPID_MGMT_STATUS_OFFSET, status);

            /* Send the response. */
            mcapi_msg_send(mcapi_struct->local_endp,
                           mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                           buffer, rx_len, MCAPI_DEFAULT_PRIO,
                           &mcapi_struct->status);

            /* Open the local endpoint up as the receiver. */
            mcapi_open_sclchan_recv_i(&mcapi_struct->scl_rx_handle,
                                      mcapi_struct->local_endp,
                                      &mcapi_struct->request,
                                      &mcapi_struct->status);

            /* Wait for a connection to be established. */
            mcapi_wait(&mcapi_struct->request, &rx_len, &mcapi_struct->status,
                       MCAPI_TIMEOUT_INFINITE);

            if (mcapi_struct->status == MCAPI_SUCCESS)
            {
                switch (type)
                {
                    case MCAPID_RX_64_BIT_SCL:

                        /* Wait for an incoming message. */
                        recv_64 = mcapi_sclchan_recv_uint64(mcapi_struct->scl_rx_handle,
                                                            &mcapi_struct->status);

                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                             (recv_64 != MCAPI_FTS_64BIT_SCALAR) )
                        {
                            MCAPID_Failures ++;
                        }

                        /* Close the receive side. */
                        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                   &mcapi_struct->request,
                                                   &mcapi_struct->status);

                        break;

                    case MCAPID_RX_32_BIT_SCL:

                        /* Wait for an incoming message. */
                        recv_32 = mcapi_sclchan_recv_uint32(mcapi_struct->scl_rx_handle,
                                                            &mcapi_struct->status);

                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                             (recv_32 != MCAPI_FTS_32BIT_SCALAR) )
                        {
                            MCAPID_Failures ++;
                        }

                        /* Close the receive side. */
                        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                   &mcapi_struct->request,
                                                   &mcapi_struct->status);

                        break;

                    case MCAPID_RX_16_BIT_SCL:

                        /* Wait for an incoming message. */
                        recv_16 = mcapi_sclchan_recv_uint16(mcapi_struct->scl_rx_handle,
                                                            &mcapi_struct->status);

                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                             (recv_16 != MCAPI_FTS_16BIT_SCALAR) )
                        {
                            MCAPID_Failures ++;
                        }

                        /* Close the receive side. */
                        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                   &mcapi_struct->request,
                                                   &mcapi_struct->status);

                        break;

                    case MCAPID_RX_8_BIT_SCL:

                        /* Wait for an incoming message. */
                        recv_8 = mcapi_sclchan_recv_uint8(mcapi_struct->scl_rx_handle,
                                                          &mcapi_struct->status);

                        if ( (mcapi_struct->status == MCAPI_SUCCESS) &&
                             (recv_8 != MCAPI_FTS_8BIT_SCALAR) )
                        {
                            MCAPID_Failures ++;
                        }

                        /* Close the receive side. */
                        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                   &mcapi_struct->request,
                                                   &mcapi_struct->status);

                        break;

                    default:

                        /* Close the receive side. */
                        mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                                   &mcapi_struct->request,
                                                   &mcapi_struct->status);

                        break;
                }

                /* Put the status in the packet. */
                mcapi_put32((unsigned char*)buffer, MCAPID_MGMT_STATUS_OFFSET, mcapi_struct->status);

                /* Send the response. */
                mcapi_msg_send(mcapi_struct->local_endp,
                               mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                               buffer, rx_len, MCAPI_DEFAULT_PRIO,
                               &mcapi_struct->status);
            }

            else
            {
                /* Close the receive side. */
                mcapi_sclchan_recv_close_i(mcapi_struct->scl_rx_handle,
                                           &mcapi_struct->request,
                                           &mcapi_struct->status);
            }
        }
    }

} /* MCAPI_FTS_Scl_Server */

#ifdef LCL_MGMT_UNBROKEN
/************************************************************************
*
*   FUNCTION
*
*       MCAPI_FTS_Local_Services
*
*   DESCRIPTION
*
*       This function processes incoming packets instructing the node
*       to create an endpoint, delete an endpoint, etc.
*
*************************************************************************/
MCAPI_THREAD_ENTRY(MCAPI_FTS_Local_Services)
{
    size_t          rx_len;
    MCAPID_STRUCT   *mcapi_struct = (MCAPID_STRUCT*)argv;
    char            buffer[MCAPID_MGMT_PKT_LEN];

    for (;;)
    {
        /* Wait for a message. */
        mcapi_msg_recv(mcapi_struct->local_endp, buffer, MCAPID_MGMT_PKT_LEN,
                       &rx_len, &mcapi_struct->status);

        if (mcapi_struct->status == MCAPI_SUCCESS)
        {
            /* Sleep the appropriate amount of time - this gives the other side
             * time to issue a command before the management task causes an
             * action.
             */
            MCAPID_Sleep(mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_PAUSE_OFFSET));

            /* Determine the type of message. */
            switch (mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_TYPE_OFFSET))
            {
                case MCAPID_CANCEL_REQUEST:

                    /* Cancel the pending local request. */
                    mcapi_cancel((mcapi_request_t*)(mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_STATUS_OFFSET)),
                                 &mcapi_struct->status);

                    break;

                case MCAPID_WAIT_REQUEST:

                    /* Wait for the specified request. */
                    mcapi_wait((mcapi_request_t*)(mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_STATUS_OFFSET)),
                               &rx_len, &mcapi_struct->status, MCAPI_TIMEOUT_INFINITE);

                    break;

                default:

                    mcapi_struct->status = -1;
                    break;
            }

            /* Put the status in the packet. */
            mcapi_put32((unsigned char*)buffer, MCAPID_MGMT_STATUS_OFFSET, mcapi_struct->status);

            /* Send the response using the specified priority. */
            mcapi_msg_send(mcapi_struct->local_endp,
                           mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_LOCAL_ENDP_OFFSET),
                           buffer, rx_len, mcapi_get32((unsigned char*)buffer, MCAPID_MGMT_PRIO_OFFSET),
                           &mcapi_struct->status);
        }
    }

} /* MCAPI_FTS_Local_Services */
#endif

int mcapi_test_start(int argc, char *argv[])
{
    mcapi_status_t status;
    mcapi_version_t version;

    /* Initialize MCAPI on the node. */
    mcapi_initialize(FUNC_BACKEND_NODE_ID, &version, &status);

    /* If an error occurred, the demo has failed. */
    if (status != MCAPI_SUCCESS) {
        printf("%s\n", "mcapi_initialize() failed!");
        MCAPID_Failures++;
        goto out;
    }

    /* Start the registration server. */
    MCAPID_Create_Thread(&MCAPID_Registration_Server, &MCAPID_Reg_Struct);

    /* Let the registration server come up. */
    MCAPID_Sleep(2000);

    /* The management service. */
    MCAPID_Mgmt_Struct.type = MCAPI_MSG_RX_TYPE;
    MCAPID_Mgmt_Struct.node = FUNC_BACKEND_NODE_ID;
    MCAPID_Mgmt_Struct.local_port = MCAPI_PORT_ANY;
    MCAPID_Mgmt_Struct.service = "mgmt_svc";
    MCAPID_Mgmt_Struct.thread_entry = MCAPID_Mgmt_Service;
    MCAPID_Create_Service(&MCAPID_Mgmt_Struct);

    /* The message echo service. */
    MCAPID_Echo_Struct[0].type = MCAPI_MSG_RX_TYPE;
    MCAPID_Echo_Struct[0].node = FUNC_BACKEND_NODE_ID;
    MCAPID_Echo_Struct[0].local_port = MCAPI_PORT_ANY;
    MCAPID_Echo_Struct[0].service = "msg_echo_svr";
    MCAPID_Echo_Struct[0].thread_entry = MCAPI_FTS_Msg_Echo_Server;
    MCAPID_Create_Service(&MCAPID_Echo_Struct[0]);

    /* The packet discard service. */
    MCAPID_Echo_Struct[1].type = MCAPI_CHAN_PKT_RX_TYPE;
    MCAPID_Echo_Struct[1].node = FUNC_BACKEND_NODE_ID;
    MCAPID_Echo_Struct[1].local_port = MCAPI_PORT_ANY;
    MCAPID_Echo_Struct[1].service = "pkt_svr";
    MCAPID_Echo_Struct[1].thread_entry = MCAPI_FTS_Pkt_Server;
    MCAPID_Create_Service(&MCAPID_Echo_Struct[1]);

    /* The scalar discard service. */
    MCAPID_Echo_Struct[2].type = MCAPI_MSG_RX_TYPE;
    MCAPID_Echo_Struct[2].node = FUNC_BACKEND_NODE_ID;
    MCAPID_Echo_Struct[2].local_port = MCAPI_PORT_ANY;
    MCAPID_Echo_Struct[2].service = "scl_svr";
    MCAPID_Echo_Struct[2].thread_entry = MCAPI_FTS_Scl_Server;
    MCAPID_Create_Service(&MCAPID_Echo_Struct[2]);

#ifdef LCL_MGMT_UNBROKEN
    /* The local services service. */
    MCAPID_Echo_Struct[3].type = MCAPI_MSG_RX_TYPE;
    MCAPID_Echo_Struct[3].node = FUNC_BACKEND_NODE_ID;
    MCAPID_Echo_Struct[3].local_port = MCAPI_PORT_ANY;
    MCAPID_Echo_Struct[3].service = "lcl_mgmt";
    MCAPID_Echo_Struct[3].thread_entry = MCAPI_FTS_Local_Services;
    MCAPID_Create_Service(&MCAPID_Echo_Struct[3]);
#endif

    while (1); /* XXX */

out:
    return MCAPID_Failures;
}
