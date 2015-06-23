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



#ifndef MCAPI_DEFS_H
#define MCAPI_DEFS_H

#include <mcapi.h>
#include <openmcapi_cfg.h>

#ifdef          __cplusplus
extern  "C" {                               /* C declarations in C++     */
#endif /* _cplusplus */

extern mcapi_node_t MCAPI_Node_ID;

#define MCAPI_MSG_TYPE          0
#define MCAPI_CHAN_PKT_TYPE     1
#define MCAPI_CHAN_SCAL_TYPE    2

/* Packet header offsets. */
#define     MCAPI_SRC_NODE_OFFSET       0
#define     MCAPI_SRC_PORT_OFFSET       2
#define     MCAPI_DEST_NODE_OFFSET      4
#define     MCAPI_DEST_PORT_OFFSET      6
#define     MCAPI_PRIO_OFFSET           8
#define     MCAPI_UNUSED_OFFSET         10

/* The length of the MCAPI headers, in bytes. */
#define     MCAPI_HEADER_LEN        12
#define     MCAPI_GET_ENDP_LEN      12
#define     MCAPI_CONNECT_MSG_LEN   20
#define     MCAPI_FIN_MSG_LEN       8

/* Packet types. */
#define     MCAPI_MESSAGE_TYPE      1
#define     MCAPI_PACKET_TYPE       2

/* Protocol types. */
#define     MCAPI_GETENDP_REQUEST   1
#define     MCAPI_GETENDP_RESPONSE  2
#define     MCAPI_CONNECT_REQUEST   3
#define     MCAPI_CONNECT_RESPONSE  4
#define     MCAPI_CONNECT_SYN       5
#define     MCAPI_CONNECT_ACK       6
#define     MCAPI_CANCEL_MSG        7
#define     MCAPI_OPEN_TX           8
#define     MCAPI_OPEN_RX           9
#define     MCAPI_OPEN_TX_ACK       10
#define     MCAPI_OPEN_RX_ACK       11
#define     MCAPI_CONNECT_FIN       12

/* Protocol offsets. */
#define     MCAPI_PROT_TYPE         0

/* Endpoint Request Message offsets. */
#define     MCAPI_GETENDP_PORT      2
#define     MCAPI_GETENDP_ENDP      4
#define     MCAPI_GETENDP_STATUS    8

/* Connection message offsets. */
#define     MCAPI_CNCT_REQ_NODE     2
#define     MCAPI_CNCT_REQ_PORT     4
#define     MCAPI_CNCT_TX_NODE      6
#define     MCAPI_CNCT_TX_PORT      8
#define     MCAPI_CNCT_RX_NODE      10
#define     MCAPI_CNCT_RX_PORT      12
#define     MCAPI_CNCT_CHAN_TYPE    14
#define     MCAPI_CNCT_STATUS       16

/* Connection FIN offsets. */
#define     MCAPI_CNCT_FIN_TX_NODE  2
#define     MCAPI_CNCT_FIN_TX_PORT  4
#define     MCAPI_CNCT_FIN_PORT     6

#define     MCAPI_TX_SIDE           1
#define     MCAPI_RX_SIDE           2

/* Endpoint attributes that can be set/retrieved. */
#define     MCAPI_ATTR_NO_PRIORITIES            1   /* Number of priorities */
#define     MCAPI_ATTR_NO_BUFFERS               2   /* Number of buffers */
#define     MCAPI_ATTR_BUFFER_SIZE              3   /* Buffer size */
#define     MCAPI_ATTR_BUFFER_TYPE              4   /* Buffer type, FIFO */
#define     MCAPI_ATTR_MEMORY_TYPE              5   /* Shared/local (0-copy) */
#define     MCAPI_ATTR_TIMEOUT                  6   /* Timeout */
#define     MCAPI_ATTR_ENDP_PRIO                7   /* Priority on connected endpoint */
#define     MCAPI_ATTR_ENDP_STATUS              8   /* Endpoint status, connected, open etc. */
#define     MCAPI_ATTR_RECV_BUFFERS_AVAILABLE   9   /* Available receive buffers */
#define     MCAPI_FINALIZE_DRIVER               10  /* Shut down the driver. */

/* Identifiers denoting what types of operations a suspended thread wants
 * to be woken up for.
 */
#define     MCAPI_REQ_DELETED       1       /* Endpoint associated with the request has been deleted. */
#define     MCAPI_REQ_CREATED       2       /* Endpoint associated with the request has been created. */
#define     MCAPI_REQ_TX_FIN        3       /* Outgoing data has been sent. */
#define     MCAPI_REQ_RX_FIN        4       /* Incoming data has been received. */
#define     MCAPI_REQ_CONNECTED     5       /* Two endpoints have been connected. */
#define     MCAPI_REQ_RX_OPEN       6       /* The receive end of a connection has been opened. */
#define     MCAPI_REQ_TX_OPEN       7       /* The send end of a connection has been opened. */
#define     MCAPI_REQ_CLOSED        8       /* The local end of a connection has been closed. */

/* States of an MCAPI Node in the global list. */
#define     MCAPI_NODE_UNUSED           0
#define     MCAPI_NODE_INITIALIZED      1
#define     MCAPI_NODE_FINALIZED        2

/* State of an MCAPI Endpoint in the global list. */
#define     MCAPI_ENDP_CLOSED           0x1
#define     MCAPI_ENDP_OPEN             0x2
#define     MCAPI_ENDP_CONNECTING       0x4
#define     MCAPI_ENDP_CONNECTED        0x8
#define     MCAPI_ENDP_TX               0x10
#define     MCAPI_ENDP_RX               0x20
#define     MCAPI_ENDP_TX_ACKED         0x40
#define     MCAPI_ENDP_RX_ACKED         0x80
#define     MCAPI_ENDP_DISCONNECTED     0x100
#define     MCAPI_ENDP_CONNECTING_TX    0x200
#define     MCAPI_ENDP_CONNECTING_RX    0x400

/* Scalar types. */
#define     MCAPI_SCALAR_UINT8          1
#define     MCAPI_SCALAR_UINT16         2
#define     MCAPI_SCALAR_UINT32         3
#define     MCAPI_SCALAR_UINT64         4

#define     MCAPI_REMOVE_REQUEST        0x01

/* An MCAPI buffer structure for data.  Used to check the status
 * of a non-blocking operation.
 */
struct _mcapi_buffer
{
    MCAPI_POINTER  next_buf;
    MCAPI_POINTER  prev_buf;
    unsigned char  buf_ptr[MCAPI_MAX_DATA_LEN];
    mcapi_uint32_t buf_size;
    MCAPI_POINTER  mcapi_dev_ptr;
};

typedef struct _mcapi_buffer MCAPI_BUFFER;

/* Incoming RX queue structure for receiving data on an endpoint. */
struct _mcapi_buf_queue
{
    MCAPI_BUFFER *head;
    MCAPI_BUFFER *tail;
};

typedef struct _mcapi_buf_queue MCAPI_BUF_QUEUE;

typedef struct
{
    unsigned long *mcapi_rx_ptr;
    unsigned       mcapi_extra_data;
} MCAPI_DRIVER;

/* Endpoint data structure.  Holds all data pertinent to an individual
 * endpoint on a node.
 */
struct _mcapi_endpoint
{
    mcapi_node_t            mcapi_node_id;
    mcapi_port_t            mcapi_port_id;
    mcapi_node_t            mcapi_foreign_node_id;
    mcapi_port_t            mcapi_foreign_port_id;
    mcapi_uint32_t          mcapi_state;
    mcapi_uint32_t          mcapi_chan_type;
    mcapi_uint32_t          mcapi_endp_handle;
    mcapi_node_t            mcapi_req_node_id;
    mcapi_port_t            mcapi_req_port_id;
    mcapi_uint32_t          mcapi_priority;
    struct _mcapi_route     *mcapi_route;
    MCAPI_BUF_QUEUE         mcapi_rx_queue;
    MCAPI_DRIVER            mcapi_driver_spec;
};

typedef struct  _mcapi_endpoint     MCAPI_ENDPOINT;

/* An MCAPI interface used to send data to an endpoint. */
struct _mcapi_interface
{
    char            mcapi_int_name[MCAPI_INT_NAME_LEN];
    mcapi_uint32_t  mcapi_max_buf_size;
    mcapi_status_t  (*mcapi_tx_output)(MCAPI_BUFFER *, size_t, mcapi_priority_t, struct _mcapi_endpoint *);
    MCAPI_BUFFER    *(*mcapi_get_buffer)(mcapi_node_t, size_t, mcapi_uint32_t);
    void            (*mcapi_recover_buffer)(MCAPI_BUFFER *);
    mcapi_status_t  (*mcapi_ioctl)(mcapi_uint_t, void *, size_t);
};

typedef struct _mcapi_interface MCAPI_INTERFACE;

typedef struct
{
    mcapi_status_t  (*mcapi_init)(mcapi_node_t, struct _mcapi_interface *);
} MCAPI_INT_INIT;

/* An MCAPI route used to find the interface to use to send data to
 * a remote node.
 */
struct _mcapi_route
{
    mcapi_uint16_t          mcapi_rt_dest_node_id;
    mcapi_uint8_t           mcapi_padN[2];
    struct _mcapi_interface *mcapi_rt_int;
};

typedef struct _mcapi_route MCAPI_ROUTE;

/* Node data structure.  Holds all data pertinent to an individual node
 * in a system.
 */
typedef struct
{
    mcapi_uint16_t      mcapi_node_id;
    mcapi_uint16_t      mcapi_state;
    mcapi_uint32_t      mcapi_endpoint_count;
    mcapi_port_t        mcapi_status_port;
    mcapi_uint8_t       mcapi_padN;
    MCAPI_ENDPOINT      mcapi_endpoint_list[MCAPI_MAX_ENDPOINTS];
    MCAPI_ROUTE         mcapi_route_list[MCAPI_ROUTE_COUNT];
} MCAPI_NODE;

/* A queue of blocking requests within the system. */
typedef struct
{
    mcapi_request_t     *flink;
    mcapi_request_t     *blink;
} MCAPI_REQ_QUEUE;

/* A route initialization structure populated by the system designer
 * at compile-time.
 */
typedef struct
{
    mcapi_uint16_t  mcapi_rt_dest_id;
    char            mcapi_int_name[MCAPI_INT_NAME_LEN];
    mcapi_uint8_t   mcapi_padN[2];
} MCAPI_RT_INIT_STRUCT;

/* The global data structure; ie, MCAPI Database.  This data structure
 * is stored in global memory and is accessible by all nodes in the
 * system.
 */
typedef struct
{
    mcapi_uint32_t          mcapi_node_count;
    MCAPI_RT_INIT_STRUCT    mcapi_route_list[MCAPI_ROUTE_COUNT];
    MCAPI_REQ_QUEUE         mcapi_local_req_queue;
    MCAPI_REQ_QUEUE         mcapi_foreign_req_queue;
    MCAPI_NODE              mcapi_node_list[MCAPI_NODE_COUNT];
} MCAPI_GLOBAL_DATA;

typedef struct
{
    union
    {
        mcapi_uint8_t   scal_uint8;
        mcapi_uint16_t  scal_uint16;
        mcapi_uint32_t  scal_uint32;
        mcapi_uint64_t  scal_uint64;
    } mcapi_scal;

} MCAPI_SCALAR;

/* cntrl_msg.c */
MCAPI_THREAD_ENTRY(mcapi_process_ctrl_msg);

void mcapi_tx_response(MCAPI_GLOBAL_DATA *, mcapi_request_t *);
void mcapi_rx_data(void);

/* node_data.c */
void mcapi_lock_node_data(void);
void mcapi_unlock_node_data(void);
MCAPI_GLOBAL_DATA *mcapi_get_node_data(void);
void mcapi_init_node_data(void);

/* node.c */
int mcapi_find_node(mcapi_node_t, MCAPI_GLOBAL_DATA *);

/* handle.c */
mcapi_endpoint_t mcapi_encode_handle(mcapi_uint16_t, mcapi_uint16_t);
void mcapi_decode_handle(mcapi_endpoint_t, int *, int *);

/* endpoint.c */
int mcapi_find_endpoint(mcapi_port_t, MCAPI_NODE *);
mcapi_endpoint_t mcapi_encode_endpoint(mcapi_node_t, mcapi_port_t);
void mcapi_decode_endpoint(mcapi_endpoint_t, mcapi_node_t *, mcapi_port_t *);
MCAPI_ENDPOINT *mcapi_decode_local_endpoint(MCAPI_GLOBAL_DATA *, mcapi_node_t *,
                                            mcapi_port_t *, mcapi_endpoint_t,
                                            mcapi_status_t *);
MCAPI_ENDPOINT *mcapi_find_local_endpoint(MCAPI_GLOBAL_DATA *, mcapi_node_t ,
                                          mcapi_port_t);

/* suspend.c */
void mcapi_check_resume(int, mcapi_endpoint_t, MCAPI_ENDPOINT *, size_t, mcapi_status_t);
mcapi_request_t *mcapi_find_request(mcapi_request_t *, MCAPI_REQ_QUEUE *);
void mcapi_resume(MCAPI_GLOBAL_DATA *, mcapi_request_t *, mcapi_status_t);

/* get_endp.c */
void get_remote_endpoint(mcapi_node_t, mcapi_port_t, mcapi_status_t *,
                         mcapi_uint32_t);

/* queue.c */
void mcapi_enqueue(void *, void *);
void *mcapi_remove(void *, void *);
void *mcapi_dequeue(void *);

/* msg_snd.c */
void msg_send(mcapi_endpoint_t, mcapi_endpoint_t, void *, size_t, mcapi_priority_t ,
              mcapi_request_t *, mcapi_status_t *mcapi_status, mcapi_uint32_t);

/* msg_rcv.c */
void msg_recv(mcapi_endpoint_t, void *, size_t, size_t *, mcapi_request_t *,
              mcapi_status_t *, mcapi_uint32_t);
size_t msg_recv_copy_data(MCAPI_ENDPOINT *, void *);

/* msg_snd.c */
void pkt_send(mcapi_pktchan_send_hndl_t, void *, size_t, mcapi_request_t *,
              mcapi_status_t *, mcapi_uint32_t);

/* msg_rcv.c */
void pkt_rcv(mcapi_pktchan_recv_hndl_t, void **, size_t *, mcapi_request_t *,
             mcapi_status_t *, mcapi_uint32_t);

/* interface.c */
mcapi_status_t mcapi_init_interfaces(mcapi_node_t);
MCAPI_INTERFACE *mcapi_find_interface(char*);

/* loopback.c */
mcapi_status_t mcapi_loop_init(mcapi_node_t, MCAPI_INTERFACE *);
mcapi_status_t mcapi_loop_tx(MCAPI_BUFFER *, size_t, mcapi_priority_t,
                             MCAPI_ENDPOINT *);
mcapi_status_t mcapi_loop_ioctl(mcapi_uint_t, void *, size_t);

/* route.c */
MCAPI_ROUTE *mcapi_find_route(mcapi_node_t, MCAPI_NODE *);

/* buf_mgmt.c */
void mcapi_recover_buffer(MCAPI_BUFFER *);
MCAPI_BUFFER *mcapi_reserve_buffer(mcapi_node_t, size_t, mcapi_uint32_t);

/* connect.c */
void mcapi_connect(mcapi_endpoint_t, mcapi_endpoint_t, mcapi_uint32_t,
                   mcapi_request_t *, mcapi_status_t *);
void mcapi_open(mcapi_endpoint_t, mcapi_uint32_t, mcapi_request_t *,
                mcapi_uint32_t, mcapi_uint16_t, mcapi_uint16_t,
                mcapi_status_t *);
void mcapi_close(MCAPI_ENDPOINT *, mcapi_uint32_t, mcapi_request_t *,
                 mcapi_uint32_t, mcapi_status_t *);
void mcapi_tx_open(unsigned char *, MCAPI_ENDPOINT *, mcapi_node_t, mcapi_port_t,
                   mcapi_node_t, mcapi_port_t, mcapi_uint16_t, mcapi_uint16_t,
                   mcapi_status_t *);
void mcapi_tx_fin_msg(MCAPI_ENDPOINT *, mcapi_status_t *);

/* tls.c */
unsigned long mcapi_get32(unsigned char *, unsigned int);
void mcapi_put32(unsigned char *, unsigned int, unsigned long);
unsigned long long mcapi_get64(unsigned char *, unsigned int);
void mcapi_put64(unsigned char *, unsigned int, unsigned long long);
unsigned short mcapi_get16(unsigned char *, unsigned int);
void mcapi_put16(unsigned char *, unsigned int, unsigned short);

#define MCAPI_PUT8(bufferP, offset, value) \
  (((unsigned char *)(bufferP))[offset]) = (value)

#define MCAPI_PUT16(bufferP, offset, value) \
  mcapi_put16((unsigned char *)bufferP, offset, (value))

#define MCAPI_PUT32(bufferP, offset, value) \
  mcapi_put32((unsigned char *)bufferP, offset, (value))

#define MCAPI_GET32(bufferP, offset) \
  mcapi_get32((unsigned char *)bufferP, offset)

#define MCAPI_GET16(bufferP, offset) \
  mcapi_get16((unsigned char *)bufferP, offset)

#define MCAPI_GET8(bufferP, offset) \
  (((unsigned char *)(bufferP))[offset])

#define MCAPI_PUT64(bufferP, offset, value) \
  mcapi_put64((unsigned char *)bufferP, offset, (value))

#define MCAPI_GET64(bufferP, offset) \
  mcapi_get64((unsigned char *)bufferP, offset)

/* scal_snd.c */
void scal_send(mcapi_pktchan_send_hndl_t, MCAPI_SCALAR *, mcapi_uint8_t,
               mcapi_status_t *);

/* scal_rcv.c */
void scal_rcv(mcapi_sclchan_recv_hndl_t, MCAPI_SCALAR *, mcapi_uint8_t,
              mcapi_status_t *);

/* data_avail.c */
void mcapi_data_available(MCAPI_ENDPOINT *, mcapi_uint32_t, mcapi_uint_t *,
                          mcapi_status_t *);

/* data_count.c */
void mcapi_check_data(MCAPI_ENDPOINT *, mcapi_uint_t *);

/* create_endpoint.c */
mcapi_endpoint_t create_endpoint(MCAPI_NODE *, mcapi_port_t, mcapi_status_t *);
void mcapi_check_foreign_resume(int, mcapi_endpoint_t, mcapi_status_t);

/* forward.c */
void mcapi_forward(MCAPI_GLOBAL_DATA *, MCAPI_BUFFER *, mcapi_node_t);

/* request.c */
void mcapi_init_request(mcapi_request_t *, mcapi_uint8_t);
mcapi_request_t *mcapi_get_free_request_struct(void);
void mcapi_release_request_struct(mcapi_request_t *);

mcapi_boolean_t __mcapi_test(mcapi_request_t *request, size_t *size,
                             mcapi_status_t *mcapi_status);

/* mcapi_os.c */
mcapi_status_t MCAPI_Resume_Task(mcapi_request_t *);
mcapi_status_t MCAPI_Suspend_Task(MCAPI_GLOBAL_DATA *, mcapi_request_t *,
                                  MCAPI_COND_STRUCT *, mcapi_timeout_t);
mcapi_status_t MCAPI_Init_OS(void);
void MCAPI_Exit_OS(void);
void MCAPI_Cleanup_Task(void);
mcapi_status_t MCAPI_Create_Mutex(MCAPI_MUTEX *, char *);
mcapi_status_t MCAPI_Delete_Mutex(MCAPI_MUTEX *);
mcapi_status_t MCAPI_Obtain_Mutex(MCAPI_MUTEX *);
mcapi_status_t MCAPI_Release_Mutex(MCAPI_MUTEX *);
mcapi_status_t MCAPI_Set_RX_Event(void);
void MCAPI_Init_Condition(MCAPI_COND_STRUCT *);
void MCAPI_Set_Condition(mcapi_request_t *, MCAPI_COND_STRUCT *);
void MCAPI_Clear_Condition(mcapi_request_t *);
mcapi_int_t MCAPI_Lock_RX_Queue(void);
void MCAPI_Unlock_RX_Queue(mcapi_int_t cookie);
void MCAPI_Sleep(unsigned int secs);

/* The name of the shared memory interface. */
#define OPENMCAPI_SHM_NAME "sha_mem"
mcapi_status_t openmcapi_shm_init(mcapi_node_t node_id,
                                  MCAPI_INTERFACE* int_ptr);


#ifdef          __cplusplus
}
#endif /* _cplusplus */

#endif /* MCAPI_DEFS_H */
