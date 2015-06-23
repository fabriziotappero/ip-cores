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

/************************************************************************
*
*   FILENAME
*
*       support.h
*
*
*************************************************************************/

#ifndef  _MCAPID_SUPPORT_H_
#define  _MCAPID_SUPPORT_H_

#include <mcapi.h>

/* Registration service macros. */
#define MCAPID_SVC_LEN          64                      /* The maximum length of a service name. */
#define MCAPID_MAX_SERVICES     64                      /* The maximum number of simultaneous registered services. */
#define MCAPID_REG_MSG_LEN      MCAPID_SVC_LEN + 4 + 4  /* The length of a registration message. */
#define MCAPID_REG_SERVER_NODE  1 /* XXX always? */
#define MCAPID_REG_SERVER_PORT  20000

/* Registration service packet offsets. */
#define MCAPID_SVCREG_TYPE_OFFSET   0
#define MCAPID_SVCREG_PORT_OFFSET   4
#define MCAPID_SVCREG_NODE_OFFSET   8
#define MCAPID_SVCREG_RXENDP_OFFSET 12
#define MCAPID_SVCREG_STATUS_OFFSET 16
#define MCAPID_SVCREG_NAME_OFFSET   20

/* Registration request types. */
#define MCAPID_REG_SVC              0   /* Register an endpoint for a service. */
#define MCAPID_REM_SVC              1   /* Unregister an endpoint with a service. */
#define MCAPID_GET_SVC              2   /* Get the endpoint registered for a service. */

typedef struct _MCAPID_SERVICE_STRUCT_
{
    char                service[MCAPID_SVC_LEN];
    mcapi_port_t        port;
    mcapi_node_t        node;
    mcapi_uint32_t      avail;
} MCAPID_SERVICE_STRUCT;

/* MCAPID_STRUCT type values. */
#define MCAPI_CHAN_PKT_TX_TYPE      0   /* TX side of packet channel. */
#define MCAPI_CHAN_PKT_RX_TYPE      1   /* RX side of packet channel. */
#define MCAPI_CHAN_SCL_TX_TYPE      2   /* TX side of scalar channel. */
#define MCAPI_CHAN_SCL_RX_TYPE      3   /* RX side of scalar channel. */
#define MCAPI_MSG_TX_TYPE           4   /* Client side of message. */
#define MCAPI_MSG_RX_TYPE           5   /* Server side of message. */

typedef struct _MCAPID_USER_STRUCT_
{
    /* Provided by the user. */
    int                 type;           /* See types listed above. */
    mcapi_port_t        local_port;     /* The port ID of the local side or MCAPI_PORT_ANY. */
    char                *service;       /* The name of the service to register (server) or get (client). */
    int                 retry;          /* The number of times to attempt to get a service as a client. */
    char                test_name[16];
    void *              (*func)(void *argv);
    MCAPI_THREAD_PTR_ENTRY(thread_entry);
} MCAPID_USER_STRUCT;

typedef struct _MCAPID_STRUCT_
{
    /* Provided by the user. */
    int                 type;           /* See types listed above. */
    mcapi_port_t        local_port;     /* The port ID of the local side or MCAPI_PORT_ANY. */
    mcapi_node_t        node;
    char                *service;       /* The name of the service to register (server) or get (client). */
    int                 retry;          /* The number of times to attempt to get a service as a client. */
    void *              (*func)(void *argv);
    MCAPI_THREAD_PTR_ENTRY(thread_entry);

    /* Returned to the user. */
    mcapi_endpoint_t    local_endp;
    mcapi_endpoint_t    foreign_endp;
    mcapi_status_t      status;         /* The status of the test. */
    mcapi_request_t     request;        /* The request structure to use to check the status of the open call. */
    mcapi_sclchan_send_hndl_t   scl_tx_handle;
    mcapi_sclchan_recv_hndl_t   scl_rx_handle;
    mcapi_pktchan_send_hndl_t   pkt_tx_handle;
    mcapi_pktchan_recv_hndl_t   pkt_rx_handle;

    MCAPI_THREAD        task_ptr;
    int                 state;
    void                *app_spec;      /* Application specific data structure area. */
} MCAPID_STRUCT;

int MCAPID_Create_Service(MCAPID_STRUCT *);
void MCAPID_Destroy_Service(MCAPID_STRUCT *, int);
mcapi_status_t MCAPID_Get_Service(char *, mcapi_endpoint_t *);
mcapi_status_t MCAPID_Register_Service(char *, mcapi_node_t node, mcapi_port_t port);
mcapi_status_t MCAPID_Remove_Service(char *, mcapi_node_t node, mcapi_port_t port);
mcapi_status_t MCAPID_Create_Thread(MCAPI_THREAD_PTR_ENTRY(thread_entry), MCAPID_STRUCT *);
void MCAPID_Finished(void);
void MCAPID_Cleanup(MCAPID_STRUCT *);
void MCAPID_Sleep(unsigned);
unsigned long MCAPID_Time(void);

MCAPI_THREAD_ENTRY(MCAPID_Registration_Server);

#endif /* _MCAPID_SUPPORT_H_ */
