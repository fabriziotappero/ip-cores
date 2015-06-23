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
*       mcapi_tests.c
*
*
*************************************************************************/

#include <stdio.h>
#include <mcapi.h>
#include <openmcapi_cfg.h>
#include <openmcapi.h>
#include "mcapid.h"
#include "support_suite/mcapid_support.h"

#define  FUNC_FRONTEND_NODE_ID    0
#define  MCAPID_TIMEOUT         5000

MCAPI_MUTEX     MCAPI_TEST_Mutex;
MCAPI_MUTEX     MCAPI_TEST_Wait_Mutex;

MCAPI_THREAD_ENTRY(MCAPI_TEST_Multithread_Wait);
MCAPI_THREAD_ENTRY(MCAPI_TEST_Send_Data);

void MCAPI_TEST_mcapi_initialize(void);
void MCAPI_TEST_mcapi_finalize(void);
void MCAPI_TEST_mcapi_get_node_id(int);
void MCAPI_TEST_mcapi_create_endpoint(int type);
void MCAPI_TEST_mcapi_get_endpoint_i(int type);
void MCAPI_TEST_mcapi_get_endpoint(int type);
void MCAPI_TEST_mcapi_delete_endpoint(int type);
void MCAPI_TEST_mcapi_get_endpoint_attribute(int type);
void MCAPI_TEST_mcapi_set_endpoint_attribute(int type);
void MCAPI_TEST_mcapi_msg_send_i(int type);
void MCAPI_TEST_mcapi_msg_send(int type);
void MCAPI_TEST_mcapi_msg_recv_i(int type);
void MCAPI_TEST_mcapi_msg_recv(int type);
void MCAPI_TEST_mcapi_msg_available(int type);
void MCAPI_TEST_mcapi_connect_pktchan_i(int type);
void MCAPI_TEST_mcapi_open_pktchan_recv_i(int type);
void MCAPI_TEST_mcapi_open_pktchan_send_i(int type);
void MCAPI_TEST_mcapi_pktchan_send_i(int type);
void MCAPI_TEST_mcapi_pktchan_send(int type);
void MCAPI_TEST_mcapi_pktchan_recv_i(int type);
void MCAPI_TEST_mcapi_pktchan_recv(int type);
void MCAPI_TEST_mcapi_pktchan_available(int type);
void MCAPI_TEST_mcapi_pktchan_free(int type);
void MCAPI_TEST_mcapi_packetchan_recv_close_i(int type);
void MCAPI_TEST_mcapi_packetchan_send_close_i(int type);
void MCAPI_TEST_mcapi_connect_sclchan_i(int type);
void MCAPI_TEST_mcapi_open_sclchan_recv_i(int type);
void MCAPI_TEST_mcapi_open_sclchan_send_i(int type);
void MCAPI_TEST_mcapi_sclchan_send_uint64(int type);
void MCAPI_TEST_mcapi_sclchan_send_uint32(int type);
void MCAPI_TEST_mcapi_sclchan_send_uint16(int type);
void MCAPI_TEST_mcapi_sclchan_send_uint8(int type);
void MCAPI_TEST_mcapi_sclchan_recv_uint64(int type);
void MCAPI_TEST_mcapi_sclchan_recv_uint32(int type);
void MCAPI_TEST_mcapi_sclchan_recv_uint16(int type);
void MCAPI_TEST_mcapi_sclchan_recv_uint8(int type);
void MCAPI_TEST_mcapi_sclchan_available(int type);
void MCAPI_TEST_mcapi_sclchan_recv_close_i(int type);
void MCAPI_TEST_mcapi_sclchan_send_close_i(int type);
void MCAPI_TEST_mcapi_test(int type);
void MCAPI_TEST_mcapi_wait(int type);
void MCAPI_TEST_mcapi_cancel(int type);
void MCAPI_TEST_mcapi_wait_any(int type);
void MCAPI_TEST_Error(void);
void MCAPI_TEST_Finished(void);
void MCAPID_Sleep(unsigned);

#define MCAPI_TEST_PRE_INIT     0
#define MCAPI_TEST_POST_INIT    1

/* The timeout in milliseconds. */
#define MCAPI_TEST_TIMEOUT      2000

#define MCAPI_TEST_NO_SEND          0
#define MCAPI_TEST_CREATE_ENDP      7
#define MCAPI_TEST_RX_MSG           18
#define MCAPI_TEST_RX_PKT           19
#define MCAPI_TEST_RX_SCLR          20

unsigned        MCAPI_TEST_Errors = 0;
mcapi_uint16_t  MCAPI_TEST_Endpoint_Port;

mcapi_endpoint_t            MCAPI_Rx_Endpoint;
mcapi_pktchan_send_hndl_t   MCAPI_Rx_Pkt_Handle;
mcapi_sclchan_send_hndl_t   MCAPI_Rx_Scl_Handle;
mcapi_port_t                MCAPI_TEST_Array[MCAPI_MAX_ENDPOINTS];
int                         MCAPI_TEST_Array_Count;
mcapi_request_t             *MCAPI_TEST_Wait_Request = MCAPI_NULL;
mcapi_request_t             *MCAPI_TEST_Wait_Any_Request[15] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int                         MCAPI_TEST_Send_Type = MCAPI_TEST_NO_SEND;
mcapi_status_t              MCAPI_TEST_Wait_Status;
int                         MCAPI_TEST_Wait_Finished;
mcapi_timeout_t             MCAPI_TEST_Wait_Timeout;
size_t                      MCAPI_TEST_Wait_Any_Count;
MCAPID_STRUCT               MCAPID_TX_Task;
MCAPID_STRUCT               MCAPID_Wait_Task;

extern mcapi_uint16_t       MCAPI_Next_Port;
extern MCAPI_GLOBAL_DATA    MCAPI_Global_Struct;

/************************************************************************
*
*   FUNCTION
*
*      nu_tf_kern_3_init
*
*   DESCRIPTION
*
*      Executes the MCAPI API test suite.
*
*************************************************************************/
int mcapi_test_start(int argc, char *argv[])
{
    unsigned        cur_error_count;

    /* Create the application mutex. */
    MCAPI_Create_Mutex(&MCAPI_TEST_Mutex, "mctest");

    /* Create the application wait mutex. */
    MCAPI_Create_Mutex(&MCAPI_TEST_Wait_Mutex, "mcwait");

    MCAPID_Create_Thread(&MCAPI_TEST_Send_Data, &MCAPID_TX_Task);
    MCAPID_Create_Thread(&MCAPI_TEST_Multithread_Wait, &MCAPID_Wait_Task);

#if 0
    /* Test routine before initializing. */
    MCAPI_TEST_mcapi_get_node_id(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_create_endpoint(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_get_endpoint_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_get_endpoint(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_delete_endpoint(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_get_endpoint_attribute(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_set_endpoint_attribute(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_msg_send_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_msg_send(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_msg_recv_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_msg_recv(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_msg_available(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_connect_pktchan_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_open_pktchan_recv_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_open_pktchan_send_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_pktchan_send_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_pktchan_send(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_pktchan_recv_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_pktchan_recv(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_pktchan_available(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_pktchan_free(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_packetchan_recv_close_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_packetchan_send_close_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_connect_sclchan_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_open_sclchan_recv_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_open_sclchan_send_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_send_uint64(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_send_uint32(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_send_uint16(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_send_uint8(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_recv_uint64(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_recv_uint32(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_recv_uint16(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_recv_uint8(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_available(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_recv_close_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_sclchan_send_close_i(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_test(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_wait(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_cancel(MCAPI_TEST_PRE_INIT);
    MCAPI_TEST_mcapi_wait_any(MCAPI_TEST_PRE_INIT);
#endif

    cur_error_count = MCAPI_TEST_Errors;

    /* Test routines after initializing. */
    MCAPI_TEST_mcapi_initialize();

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_initialize Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_finalize();

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_finalize Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_get_node_id(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_get_node_id Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_create_endpoint(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_create_endpoint Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_get_endpoint_i(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_get_endpoint_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_get_endpoint(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_get_endpoint Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_delete_endpoint(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_delete_endpoint Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_get_endpoint_attribute(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_get_endpoint_attribute Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_set_endpoint_attribute(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_set_endpoint_attribute Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_msg_send_i(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_msg_send_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_msg_send(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_msg_send Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_msg_recv_i(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_msg_recv_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_msg_recv(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_msg_recv Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_msg_available(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_msg_available Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_connect_pktchan_i(MCAPI_TEST_POST_INIT);

    /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_connect_pktchan_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_open_pktchan_recv_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_open_pktchan_recv_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_open_pktchan_send_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_open_pktchan_send_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_pktchan_send_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_pktchan_send_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_pktchan_send(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_pktchan_send Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_pktchan_recv_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_pktchan_recv_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_pktchan_recv(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_pktchan_recv Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_pktchan_available(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_pktchan_available Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_pktchan_free(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_pktchan_free Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_packetchan_recv_close_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_packetchan_recv_close_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_packetchan_send_close_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_packetchan_send_close_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_connect_sclchan_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_connect_sclchan_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_open_sclchan_recv_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_open_sclchan_recv_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_open_sclchan_send_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_open_sclchan_send_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_send_uint64(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_send_uint64 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_send_uint32(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_send_uint32 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_send_uint16(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_send_uint16 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_send_uint8(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_send_uint8 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_recv_uint64(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_recv_uint64 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_recv_uint32(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_recv_uint32 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_recv_uint16(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_recv_uint16 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_recv_uint8(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_recv_uint8 Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_available(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_available Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_recv_close_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_recv_close_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_sclchan_send_close_i(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_sclchan_send_close_i Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_test(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_test Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_wait(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_wait Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_wait_any(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_wait_any Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPI_TEST_mcapi_cancel(MCAPI_TEST_POST_INIT);

   /* Output the number of errors */
    printf("MCAPI_TEST_mcapi_cancel Error Count:         %u\r\n", MCAPI_TEST_Errors - cur_error_count);
    cur_error_count = MCAPI_TEST_Errors;

    MCAPID_Cleanup(&MCAPID_TX_Task);
    MCAPID_Cleanup(&MCAPID_Wait_Task);

    printf("MCAPI API Test Finished - Total Error Count:         %u\r\n", MCAPI_TEST_Errors);

    return MCAPI_TEST_Errors;
} /* MCAPID_Test_Init */

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_initialize
*
*   DESCRIPTION
*
*      Tests mcapi_initialize input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_initialize(void)
{
    mcapi_status_t  mcapi_status;
    mcapi_version_t mcapi_version;

    /* 1.1.2.1 - Test an invalid version. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, 0, &mcapi_status);

    if (mcapi_status != MCAPI_ERR_PARAMETER)
        MCAPI_TEST_Error();

    /* 1.1.2.2 - Test invalid version and status. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, 0, 0);

    /* 1.1.3.1 - Test an invalid status. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, 0);

    /* 1.1.4.1 - Successfully initialize. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if ( (mcapi_status != MCAPI_SUCCESS) || (mcapi_version != MCAPI_VERSION) )
        MCAPI_TEST_Error();

    /* 1.1.5.1 - Attempt to initialize again. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_ERR_NODE_INITIALIZED)
        MCAPI_TEST_Error();

    /* Let the MCAPI tasks start back up. */
    MCAPID_Sleep(2000);

    /* Call the routine to un-initialize. */
    mcapi_finalize(&mcapi_status);

    /* Let the MCAPI tasks get deleted. */
    MCAPID_Sleep(2000);

    /* 1.1.5.2 - Attempt to initialize again. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Let the control task get created and run. */
    MCAPID_Sleep(2000);
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_finalize
*
*   DESCRIPTION
*
*      Tests mcapi_finalize input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_finalize(void)
{
    mcapi_status_t              mcapi_status;
    mcapi_version_t             mcapi_version;
    mcapi_endpoint_t            send_endpoint, recv_endpoint,
                                send_endpoint2, recv_endpoint2;
    mcapi_request_t             request, connect_request, send_request,
                                send_request2, recv_request;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    size_t                      size;
    mcapi_endpoint_t            endpoint;
    char                        buffer[128];
    char                        *pkt_ptr;

    /* 1.43.1.1 - Invalid status. */
    mcapi_finalize(MCAPI_NULL);


    /* 1.43.2.1 - Test with no outstanding requests in the system. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* 1.43.3.1 - Open packet channel connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the scalar channel. */
    mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the scalar channel. */
    mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* 1.43.3.2 - Open scalar channel connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create an endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* 1.43.3.3 - Open endpoint. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    /* 1.43.3.4 - Half open channel connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    /* 1.43.3.5 - Half open scalar connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* 1.43.3.6 - Half open packet connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the scalar channel. */
    mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* 1.43.3.7 - Half open scalar connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    /* 1.43.3.8 - Half open packet connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the receive side of the scalar channel. */
    mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    /* 1.43.3.9 - Half open scalar connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Make a call to get an endpoint that doesn't exist. */
    mcapi_get_endpoint_i(FUNC_FRONTEND_NODE_ID, 20000, &endpoint, &request,
                         &mcapi_status);

    /* 1.43.4.1 - Outstanding get endpoint request. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    MCAPI_Rx_Endpoint = recv_endpoint;
    MCAPI_TEST_Send_Type = MCAPI_TEST_RX_MSG;

    MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.5.1 - Outstanding blocking receive request. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, &mcapi_status);

    /* 1.43.5.2 - Outstanding non-blocking receive request. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    MCAPI_Rx_Pkt_Handle = pkt_recv_handle;
    MCAPI_TEST_Send_Type = MCAPI_TEST_RX_PKT;

    MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.5.3 - Pending blocking receive on packet channel. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    mcapi_pktchan_recv_i(pkt_recv_handle, (void**)&pkt_ptr, &request,
                         &mcapi_status);

    /* 1.43.5.4 - Pending non-blocking receive on packet channel. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the scalar channel. */
    mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the scalar channel. */
    mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    MCAPI_Rx_Scl_Handle = scl_recv_handle;
    MCAPI_TEST_Send_Type = MCAPI_TEST_RX_SCLR;

    MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.5.5 - Pending blocking receive on scalar channel. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Send two packets. */
    mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, MCAPI_DEFAULT_PRIO,
                   &mcapi_status);
    mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, MCAPI_DEFAULT_PRIO,
                   &mcapi_status);

    /* 1.43.6.1 - Outstanding message. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);
    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Send two packets. */
    mcapi_pktchan_send(pkt_send_handle, buffer, 128, &mcapi_status);
    mcapi_pktchan_send(pkt_send_handle, buffer, 128, &mcapi_status);

    /* 1.43.6.2 - Outstanding packet. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the scalar channel. */
    mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the scalar channel. */
    mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Send two packets. */
    mcapi_sclchan_send_uint8(scl_send_handle, 128, &mcapi_status);
    mcapi_sclchan_send_uint8(scl_send_handle, 128, &mcapi_status);

    /* 1.43.6.3 - Pending blocking receive on scalar channel. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Send two packets. */
    mcapi_pktchan_send(pkt_send_handle, buffer, 128, &mcapi_status);
    mcapi_pktchan_send(pkt_send_handle, buffer, 128, &mcapi_status);

    /* Receive two packets. */
    mcapi_pktchan_recv(pkt_recv_handle, (void**)&pkt_ptr, &size, &mcapi_status);
    mcapi_pktchan_recv(pkt_recv_handle, (void**)&pkt_ptr, &size, &mcapi_status);

    /* 1.43.7.1 - Unfreed buffer. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Make a call to get an endpoint that doesn't exist. */
    mcapi_get_endpoint_i(FUNC_FRONTEND_NODE_ID, 20000, &endpoint, &request,
                         &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.1 - Waiting for an outstanding get endpoint request. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.2 - Waiting for outstanding non-blocking receive request. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &recv_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.3 - Waiting to open the RX side of a packet connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &send_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.4 - Waiting to open the TX side of a packet connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Receive a packet. */
    mcapi_pktchan_recv_i(pkt_recv_handle, (void**)&pkt_ptr, &request,
                         &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.5 - Waiting to receive data on a packet connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the receive side of the scalar channel. */
    mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &recv_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.6 - Waiting to open the RX side of a scalar connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the scalar channel. */
    mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Request = &send_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = MCAPI_FALSE;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.8.7 - Waiting to open the TX side of a scalar connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Make a call to get an endpoint that doesn't exist. */
    mcapi_get_endpoint_i(FUNC_FRONTEND_NODE_ID, 20000, &endpoint, &request,
                         &mcapi_status);

    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Make a call to receive data on the endpoint. */
    mcapi_msg_recv_i(recv_endpoint, buffer, 128, &recv_request, &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Any_Request[0] = &request;
    MCAPI_TEST_Wait_Any_Request[1] = &recv_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = 0;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;
    MCAPI_TEST_Wait_Any_Count = 2;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.9.1 - Waiting for endpoint creation and data receipt on packet channel */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Any_Request[0] = &recv_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = 0;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;
    MCAPI_TEST_Wait_Any_Count = 1;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.9.2 - Waiting to open the RX side of a packet connection. */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Create a receive endpoint. */
    recv_endpoint2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint2, recv_endpoint2, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the scalar channel. */
    mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint2, &send_request2,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Any_Request[0] = &send_request;
    MCAPI_TEST_Wait_Any_Request[1] = &send_request2;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = 0;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;
    MCAPI_TEST_Wait_Any_Count = 2;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.9.3 - Waiting to open the TX side of a packet connection and scalar
     * connection.
     */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();


    /* Create a receive endpoint. */
    recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a packet channel. */
    mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the send side of the packet channel. */
    mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                              &mcapi_status);

    /* Open the receive side of the packet channel. */
    mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                              &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Receive a packet. */
    mcapi_pktchan_recv_i(pkt_recv_handle, (void**)&pkt_ptr, &request,
                         &mcapi_status);

    /* Create a receive endpoint. */
    recv_endpoint2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Create a send endpoint. */
    send_endpoint2 = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

    /* Connect the two endpoints over a scalar channel. */
    mcapi_connect_sclchan_i(send_endpoint2, recv_endpoint2, &connect_request,
                            &mcapi_status);

    if (mcapi_status == MCAPI_SUCCESS)
    {
        mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
    }

    else
    {
        MCAPI_TEST_Error();
    }

    /* Open the receive side of the scalar channel. */
    mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint2, &recv_request,
                              &mcapi_status);

    /* Cause another thread to also wait for this request to finish. */
    MCAPI_TEST_Wait_Any_Request[0] = &request;
    MCAPI_TEST_Wait_Any_Request[1] = &recv_request;
    MCAPI_TEST_Wait_Status = MCAPI_ERR_REQUEST_CANCELLED;
    MCAPI_TEST_Wait_Finished = 0;
    MCAPI_TEST_Wait_Timeout = MCAPI_TIMEOUT_INFINITE;
    MCAPI_TEST_Wait_Any_Count = 2;

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);

    MCAPID_Sleep(2000);

    /* 1.43.9.4 - Waiting to receive data on a packet connection and open
     * the RX side of a scalar connection.
     */
    mcapi_finalize(&mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

    /* Reinitialize the system. */
    mcapi_initialize(FUNC_FRONTEND_NODE_ID, &mcapi_version, &mcapi_status);

    if (mcapi_status != MCAPI_SUCCESS)
        MCAPI_TEST_Error();

    MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_get_node_id
*
*   DESCRIPTION
*
*      Tests mcapi_get_node_id input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_get_node_id(int type)
{
    mcapi_status_t  mcapi_status;

    /* 1.2.1.1 - Test before the node is initialized. */
    if (type == MCAPI_TEST_PRE_INIT)
    {
        /* Get the node ID before the node is initialized. */
        mcapi_get_node_id(&mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_NOTINIT)
            MCAPI_TEST_Error();
    }

    /* Test with a successfully initialize node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.2.2.1 - Test an invalid status parameter. */
        mcapi_get_node_id(0);

        /* 1.2.3.1 - Get the node ID. */
        mcapi_get_node_id(&mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_create_endpoint
*
*   DESCRIPTION
*
*      Tests mcapi_create_endpoint input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_create_endpoint(int type)
{
    mcapi_status_t      mcapi_status;
    mcapi_port_t        port = 0;
    mcapi_endpoint_t    endpoint;
    int                 i, count;
    mcapi_node_t        node_id;

    /* 1.3.1.1 - Test before the node is initialized. */
    if (type == MCAPI_TEST_PRE_INIT)
    {
        /* Try to create a port before the node is initialized. */
        endpoint = mcapi_create_endpoint(port, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_NOTINIT)
            MCAPI_TEST_Error();
    }

    /* Test with a successfully initialize node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.3.2.1 - Create an endpoint of greater than 16-bits. */
        endpoint = mcapi_create_endpoint(65536, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PORT_INVALID)
            MCAPI_TEST_Error();

        /* 1.3.2.2 - Test with invalid port ID and invalid status. */
        endpoint = mcapi_create_endpoint(65536, 0);

        /* 1.3.3.1 - Test with invalid status. */
        endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, 0);

        count = MCAPI_Global_Struct.mcapi_node_list[0].mcapi_endpoint_count;

        /* Create the endpoints that will be used for the rest of the
         * tests.
         */
        for (i = 0; i < (MCAPI_MAX_ENDPOINTS - count); i ++)
        {
            endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

            if (mcapi_status != MCAPI_SUCCESS)
            {
                MCAPI_TEST_Error();
                break;
            }

            /* Store the endpoint port number. */
            mcapi_decode_endpoint(endpoint, &node_id, &MCAPI_TEST_Array[i]);
        }

        MCAPI_TEST_Array_Count = i;
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_get_endpoint_i
*
*   DESCRIPTION
*
*      Tests mcapi_get_endpoint_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_get_endpoint_i(int type)
{
    mcapi_endpoint_t    endpoint;
    mcapi_request_t     request;
    mcapi_status_t      mcapi_status;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.4.1.1 - Test with an invalid node - no route can be found to
         * transmit the request; therefore, we will not suspend for the
         * node to be created.
         */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_RX_CONTROL_PORT,
                             &endpoint, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_INVALID)
            MCAPI_TEST_Error();

        /* 1.4.1.2 - Test with an invalid node and port ID. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_Next_Port,
                             &endpoint, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_INVALID)
            MCAPI_TEST_Error();

        /* 1.4.1.3 - Test with an invalid node, port ID and endpoint. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_Next_Port,
                             0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.1.4 - Test with an invalid node, port ID, endpoint and request. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_Next_Port,
                             0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.1.5 - Test with an invalid node, port ID, endpoint, request and
         * status.
         */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_Next_Port, 0, 0, 0);

        /* 1.4.2.1 - Test with an invalid endpoint structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT,
                             0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.2.2 - Test with an invalid endpoint structure and request. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT,
                             0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.2.3 - Test with an invalid endpoint structure, request
         * and status.
         */
        mcapi_get_endpoint_i(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT, 0, 0, 0);

        /* 1.4.2.4 - Test with an invalid node and endpoint structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_RX_CONTROL_PORT, 0,
                             &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.3.1 - Test with an invalid request structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT,
                             &endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.3.2 - Test with an invalid request and status. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT,
                             &endpoint, 0, 0);

        /* 1.4.3.3 - Test with an invalid node ID and request structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_RX_CONTROL_PORT,
                             &endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.3.4 - Test with an invalid node ID, port and request structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, 65536,
                             &endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.4.4.1 - Test with an invalid status structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT,
                             &endpoint, &request, 0);

        /* 1.4.4.2 - Test with an invalid node ID and status structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, MCAPI_RX_CONTROL_PORT,
                             &endpoint, &request, 0);

        /* 1.4.4.3 - Test with an invalid node ID, port ID and status structure. */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, 65536,
                             &endpoint, &request, 0);

        /* 1.4.4.4 - Test with an invalid node ID, port ID, endpoint and
         * status structure.
         */
        mcapi_get_endpoint_i(MCAPI_Node_ID + 100, 65536, 0, &request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_get_endpoint
*
*   DESCRIPTION
*
*      Tests mcapi_get_endpoint input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_get_endpoint(int type)
{
    mcapi_endpoint_t    endpoint;
    mcapi_status_t      mcapi_status;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.5.1.1 - Test with invalid node ID.  A route to the node
         * will not be found, so an error will be returned.
         */
        mcapi_get_endpoint(MCAPI_Node_ID + 100, MCAPI_RX_CONTROL_PORT,
                           &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_INVALID)
            MCAPI_TEST_Error();

        /* 1.5.1.2 - Test with invalid node ID, invalid port ID.  A route
         * to the node will not be found, so an error will be returned.
         */
        mcapi_get_endpoint(MCAPI_Node_ID + 100, MCAPI_Next_Port, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_INVALID)
            MCAPI_TEST_Error();

        /* 1.5.1.3 - Test with invalid node ID, invalid port ID and invalid
         * status.
         */
        endpoint = mcapi_get_endpoint(MCAPI_Node_ID + 100, MCAPI_Next_Port, 0);

        if (endpoint != 0)
            MCAPI_TEST_Error();

        /* 1.5.2.1 - Test with an invalid status structure. */
        endpoint = mcapi_get_endpoint(MCAPI_Node_ID, MCAPI_RX_CONTROL_PORT, 0);

        if (endpoint != 0)
            MCAPI_TEST_Error();

        /* 1.5.2.2 - Test with an invalid status and node ID structure. */
        endpoint = mcapi_get_endpoint(MCAPI_Node_ID + 100, MCAPI_RX_CONTROL_PORT, 0);

        if (endpoint != 0)
            MCAPI_TEST_Error();
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_delete_endpoint
*
*   DESCRIPTION
*
*      Tests mcapi_delete_endpoint input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_delete_endpoint(int type)
{
    int                         i, j;
    mcapi_endpoint_t            endpoint[3];
    mcapi_status_t              mcapi_status;
    mcapi_pktchan_recv_hndl_t   rcv_handle;
    mcapi_pktchan_send_hndl_t   snd_handle;
    mcapi_request_t             request, connect_request;
    mcapi_request_t             recv_request, send_request;
    size_t                      size;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.6.1.1 - Invalid endpoint. */
        mcapi_delete_endpoint(mcapi_encode_endpoint(MCAPI_Node_ID,
                              MCAPI_TEST_Array[MCAPI_TEST_Array_Count] + 1), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.6.1.2 - Invalid endpoint, invalid status. */
        mcapi_delete_endpoint(0xffffffff, 0);

        /* Get two endpoints. */
        for (i = MCAPI_TEST_Array_Count - 1, j = 0;
             (i >= 0) && (j < 2);
             i --, j ++)
        {
            endpoint[j] = mcapi_get_endpoint(MCAPI_Node_ID,
                                             MCAPI_TEST_Array[i],
                                             &mcapi_status);
        }

        /* Connect two endpoints. */
        mcapi_connect_pktchan_i(endpoint[0], endpoint[1], &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.6.1.3 - Connected endpoint, invalid status */
        mcapi_delete_endpoint(endpoint[0], 0);

        /* 1.6.1.3 - Connected endpoint, invalid status. */
        mcapi_delete_endpoint(endpoint[1], 0);

        /* 1.6.1.4 - Attempt to delete one of the half connected endpoints. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
        else
            MCAPI_TEST_Array_Count --;

        /* 1.6.1.4 - Attempt to delete the other half connected endpoints. */
        mcapi_delete_endpoint(endpoint[1], &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
        else
            MCAPI_TEST_Array_Count --;

        /* Get two more endpoints. */
        for (i = MCAPI_TEST_Array_Count - 1, j = 0;
             (i >= 0) && (j < 2);
             i --, j ++)
        {
            endpoint[j] = mcapi_get_endpoint(MCAPI_Node_ID,
                                             MCAPI_TEST_Array[i],
                                             &mcapi_status);
        }

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(endpoint[1], endpoint[0], &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open one endpoint for receive. */
        mcapi_open_pktchan_recv_i(&rcv_handle, endpoint[0], &recv_request,
                                  &mcapi_status);

        /* 1.6.1.5 - Attempt to delete receive endpoint. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_OPEN)
            MCAPI_TEST_Error();

        /* 1.6.1.6 - Receive endpoint, invalid status. */
        mcapi_delete_endpoint(endpoint[0], 0);

        /* Open one endpoint for send. */
        mcapi_open_pktchan_send_i(&snd_handle, endpoint[1], &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.6.1.7 - Attempt to delete the send endpoint. */
        mcapi_delete_endpoint(endpoint[1], &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_OPEN)
            MCAPI_TEST_Error();

        /* 1.6.1.8 - Send endpoint, invalid status. */
        mcapi_delete_endpoint(endpoint[1], 0);

        /* Close the receive endpoint. */
        mcapi_packetchan_recv_close_i(rcv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.6.1.9 - Attempt to delete receive endpoint with invalid status. */
        mcapi_delete_endpoint(endpoint[0], 0);

        /* 1.6.1.10 - Delete receive endpoint. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
        else
            MCAPI_TEST_Array_Count --;

        /* Close the send endpoint. */
        mcapi_packetchan_send_close_i(snd_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.6.1.11 - Attempt to delete send endpoint with invalid status. */
        mcapi_delete_endpoint(endpoint[1], 0);

        /* 1.6.1.12 - Delete send endpoint. */
        mcapi_delete_endpoint(endpoint[1], &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
        else
            MCAPI_TEST_Array_Count --;

        /* 1.6.2.1 - Invalid status parameter. */
        mcapi_delete_endpoint(0, 0);

        /* Get three endpoints. */
        for (j = 0, i = MCAPI_TEST_Array_Count - 1; (i >= 0) && (j < 3); i --, j ++)
        {
            endpoint[j] = mcapi_get_endpoint(MCAPI_Node_ID,
                                             MCAPI_TEST_Array[i],
                                             &mcapi_status);
        }

        /* Delete the open endpoints that were created by this application. */
        for (i = MCAPI_TEST_Array_Count - 1; i >= 0; i --)
        {
            /* Get the endpoint. */
            endpoint[0] = mcapi_get_endpoint(MCAPI_Node_ID, MCAPI_TEST_Array[i],
                                             &mcapi_status);

            /* Delete the endpoint. */
            mcapi_delete_endpoint(endpoint[0], &mcapi_status);

            if (mcapi_status != MCAPI_SUCCESS)
                MCAPI_TEST_Error();
            else
                MCAPI_TEST_Array_Count --;
        }
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_get_endpoint_attribute
*
*   DESCRIPTION
*
*      Tests mcapi_get_endpoint_attribute input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_get_endpoint_attribute(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            endpoint;
    mcapi_uint32_t              priority;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the endpoint. */
        mcapi_delete_endpoint(endpoint, &mcapi_status);

        /* 1.7.1.1 - Get the priority of a closed endpoint. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.7.1.2 - Invalid endpoint, invalid attribute number. */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.7.1.3 - Invalid endpoint, invalid attribute number, invalid
         * attribute.
         */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, 0, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.7.1.4 - Invalid endpoint, invalid attribute number, invalid
         * attribute, invalid attribute size.
         */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.7.1.5 - Invalid endpoint, invalid attribute number, invalid
         * attribute, invalid attribute size, invalid status.
         */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, 0, 0, 0);

        /* Create a new endpoint. */
        endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.7.2.1 - Get an unknown attribute. */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ATTR_NUM)
            MCAPI_TEST_Error();

        /* 1.7.2.2 - Get an unknown attribute with invalid attribute pointer. */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, 0, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.7.2.3 - Get an unknown attribute with invalid attribute pointer
         * and invalid attribute size pointer.
         */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.7.2.4 - Get an unknown attribute with invalid attribute pointer,
         * invalid attribute size pointer and invalid status.
         */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, 0, 0, 0);

        /* 1.7.3.1 - Pass an invalid attribute pointer. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     0, sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.7.3.2 - Pass an invalid attribute pointer and invalid attribute
         * size.
         */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.7.3.3 - Pass an invalid attribute pointer, invalid attribute
         * size and invalid status.
         */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO, 0, 0, 0);

        /* Close the endpoint. */
        mcapi_delete_endpoint(endpoint, &mcapi_status);

        /* 1.7.3.4 - Pass an invalid endpoint and attribute. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO, 0,
                                     sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.7.4.1 - Pass an invalid size for priority attribute. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ATTR_SIZE)
            MCAPI_TEST_Error();

        /* 1.7.4.2 - Pass an invalid size and status. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t), 0);

        /* Close the endpoint. */
        mcapi_delete_endpoint(endpoint, &mcapi_status);

        /* 1.7.4.3 - Pass an invalid endpoint and size. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.7.4.4 - Pass an invalid endpoint, attribute number and size. */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff, (void*)&priority,
                                     sizeof(mcapi_uint8_t), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.7.5.1 - Pass an invalid status. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority), 0);

        /* Close the endpoint. */
        mcapi_delete_endpoint(endpoint, &mcapi_status);

        /* 1.7.5.2 - Pass an invalid endpoint and status. */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority), 0);

        /* 1.7.5.3 - Pass an invalid endpoint, attribute and status. */
        mcapi_get_endpoint_attribute(endpoint, 0xffffffff,
                                     (void*)&priority, sizeof(priority), 0);

        /* 1.7.5.4 - Pass an invalid endpoint, attribute, attribute pointer
         * and status.
         */
        mcapi_get_endpoint_attribute(endpoint, MCAPI_ATTR_ENDP_PRIO,
                                     0, sizeof(priority), 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_set_endpoint_attribute
*
*   DESCRIPTION
*
*      Tests mcapi_set_endpoint_attribute input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_set_endpoint_attribute(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            endpoint[2];
    mcapi_uint32_t              priority = 1;
    mcapi_request_t             request, connect_request;
    mcapi_pktchan_recv_hndl_t   rcv_handle;
    mcapi_pktchan_send_hndl_t   snd_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        endpoint[0] = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        endpoint[1] = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the endpoint. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        /* 1.8.1.1 - Invalid endpoint. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.8.1.2 - Invalid endpoint, invalid attribute number. */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.8.1.3 - Invalid endpoint, invalid attribute number, invalid
         * attribute.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0,
                                     sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.4 - Invalid endpoint, invalid attribute number, invalid
         * attribute, invalid attribute size.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0,
                                     0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.5 - Invalid endpoint, invalid attribute number, invalid
         * attribute, invalid attribute size, invalid status.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0, 0, 0);

        /* Create a new endpoint. */
        endpoint[0] = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(endpoint[1], endpoint[0], &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

            if (mcapi_status != MCAPI_SUCCESS)
                MCAPI_TEST_Error();
        }

        else
            MCAPI_TEST_Error();

        /* 1.8.1.6 - Set the priority of a connected endpoint. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.8.1.7 - Set the priority of a connected endpoint, invalid
         * attribute.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, (void*)&priority,
                                     sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.8.1.8 - Set the priority of a connected endpoint, invalid
         * attribute, invalid attribute pointer.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0,
                                     sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.9 - Set the priority of a connected endpoint, invalid
         * attribute, invalid attribute pointer, invalid attribute size.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0, 0,
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.10 - Set the priority of a connected endpoint, invalid
         * attribute, invalid attribute pointer, invalid attribute size,
         * invalid status.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0, 0, 0);

        /* Open one endpoint for receive. */
        mcapi_open_pktchan_recv_i(&rcv_handle, endpoint[0], &recv_request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        /* 1.8.1.11 - Set the priority of an open receive endpoint. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.8.1.12 - Set the priority of an open receive endpoint, invalid
         * attribute number.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.8.1.13 - Set the priority of an open receive endpoint, invalid
         * attribute number, invalid attribute pointer.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0,
                                     sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.14 - Set the priority of an open receive endpoint, invalid
         * attribute number, invalid attribute pointer, invalid attribute size.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0, 0,
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.15 - Set the priority of an open receive endpoint, invalid
         * attribute number, invalid attribute pointer, invalid attribute size,
         * invalid status.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0, 0, 0);

        /* Open one endpoint for send. */
        mcapi_open_pktchan_send_i(&snd_handle, endpoint[1], &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);

            if (mcapi_status != MCAPI_SUCCESS)
                MCAPI_TEST_Error();
        }

        else
            MCAPI_TEST_Error();

        /* 1.8.1.16 - Set the priority of an open send endpoint. */
        mcapi_set_endpoint_attribute(endpoint[1], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.8.1.17 - Set the priority of an open send endpoint, invalid
         * attribute number.
         */
        mcapi_set_endpoint_attribute(endpoint[1], 0xffffffff,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.8.1.18 - Set the priority of an open send endpoint, invalid
         * attribute number, invalid attribute pointer.
         */
        mcapi_set_endpoint_attribute(endpoint[1], 0xffffffff, 0, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.19 - Set the priority of an open send endpoint, invalid
         * attribute number, invalid attribute pointer, invalid attribute size.
         */
        mcapi_set_endpoint_attribute(endpoint[1], 0xffffffff, 0, 0,
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.1.20 - Set the priority of an open send endpoint, invalid
         * attribute number, invalid attribute pointer, invalid attribute size,
         * invalid status.
         */
        mcapi_set_endpoint_attribute(endpoint[1], 0xffffffff, 0, 0, 0);

        /* Close the receive endpoint. */
        mcapi_packetchan_recv_close_i(rcv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
            MCAPI_TEST_Error();

        /* 1.8.1.21 - Set the priority of a closed channel endpoint. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        /* Close the send endpoint. */
        mcapi_packetchan_send_close_i(snd_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
            MCAPI_TEST_Error();

        /* Let the other side process the close requests. This task and the control task run
         * at the same priority in Linux, and all buffers are expected to be available for
         * subsequent tests upon exit of this test, so let the control task run.
         */
        MCAPID_Sleep(1000);

        /* 1.8.1.22 - Set the priority of a closed channel endpoint. */
        mcapi_set_endpoint_attribute(endpoint[1], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        /* 1.8.2.1 - Set an unknown attribute. */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff,
                                     (void*)&priority, sizeof(priority),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ATTR_NUM)
            MCAPI_TEST_Error();

        /* 1.8.2.2 - Set an unknown attribute, invalid attribute pointer. */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff,
                                     0, sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.2.3 - Set an unknown attribute, invalid attribute pointer,
         * invalid attribute size.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff,
                                     0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.2.4 - Set an unknown attribute, invalid attribute pointer,
         * invalid attribute size, invalid status.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0, 0, 0);

        /* 1.8.3.1 - Pass an invalid attribute pointer. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     0, sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.3.2 - Pass an invalid attribute pointer and invalid size. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.3.3 - Pass an invalid attribute pointer, invalid size and
         * invalid status.
         */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     0, 0, 0);

        /* Close the first endpoint. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        /* 1.8.3.4 - Pass an invalid endpoint and attribute pointer. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     0, sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        endpoint[0] = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        priority = MCAPI_PRIO_COUNT;

        /* 1.8.3.5 - Pass an invalid priority attribute. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority), &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.8.4.1 - Pass an invalid size for priority attribute. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ATTR_SIZE)
            MCAPI_TEST_Error();

        /* 1.8.4.2 - Pass an invalid size and status */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t), 0);

        /* Close the first endpoint. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        /* 1.8.4.3 - Pass an invalid endpoint and size. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t),
                                     &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.8.4.4 - Pass an invalid endpoint, size and status. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(mcapi_uint8_t), 0);

        /* Create a new endpoint. */
        endpoint[0] = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.8.5.1 - Pass an invalid status. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority), 0);

        /* Close the first endpoint. */
        mcapi_delete_endpoint(endpoint[0], &mcapi_status);

        /* 1.8.5.2 - Pass an invalid endpoint and status. */
        mcapi_set_endpoint_attribute(endpoint[0], MCAPI_ATTR_ENDP_PRIO,
                                     (void*)&priority, sizeof(priority), 0);

        /* 1.8.5.3 - Pass an invalid endpoint, attribute number and status. */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff,
                                     (void*)&priority, sizeof(priority), 0);

        /* 1.8.5.4 - Pass an invalid endpoint, attribute number, attribute pointer
         * and status.
         */
        mcapi_set_endpoint_attribute(endpoint[0], 0xffffffff, 0,
                                     sizeof(priority), 0);

        /* Close the second endpoint. */
        mcapi_delete_endpoint(endpoint[1], &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_msg_send_i
*
*   DESCRIPTION
*
*      Tests mcapi_msg_send_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_msg_send_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, recv_endpoint;
    mcapi_request_t             request, connect_request;
    char                        buffer[MCAPI_MAX_DATA_LEN];
    size_t                      size;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.10.1.1 - Invalid send endpoint. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* Construct a receive endpoint using a foreign node that
         * doesn't exist.
         */
        recv_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 100, 1000);

        /* 1.10.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.10.1.3 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.4 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.5 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, -1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.6 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid priority, invalid request,
         * invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.10.1.7 - Try to send data over connected endpoints. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.10.1.8 - Try to send data over connected endpoints with an invalid
         * receive endpoint.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1,
                       &mcapi_status);

        /* The fin may or may not have reached the send side by this point,
         * so there are two possible valid return values.
         */
        if ( (mcapi_status != MCAPI_ERR_ENDP_INVALID) && (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.10.1.9 - Try to send data over connected endpoints with an invalid
         * receive endpoint and invalid buffer.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.10 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer and invalid buffer size.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.11 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size and invalid
         * priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.12 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size, invalid
         * priority, and invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.10.1.13 - Try to send data over a half open connection. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Delete the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.10.1.14 - Try to send data over connected endpoints with an invalid
         * receive endpoint.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        /* There are two valid return values here since the fin may or may not
         * have reached the send side yet.
         */
        if ( (mcapi_status != MCAPI_ERR_ENDP_INVALID) && (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.10.1.15 - Try to send data over connected endpoints with an invalid
         * receive endpoint and invalid buffer.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.16 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer and invalid buffer size.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.17 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size and invalid
         * priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.1.18 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size, invalid
         * priority, and invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Close the send side. */
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        /* The close could return an error if the fin already reached the send
         * side.  This is acceptable behaviour.
         */
        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint on a non-existent foreign node. */
        recv_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 100, 1000);

        /* 1.10.2.1 - Invalid receive endpoint - invalid foreign node encoded
         * in the endpoint.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_INVALID)
            MCAPI_TEST_Error();

#ifdef MCAPI_FOREIGN_TEST

        /* Encode a non-existent port on a valid foreign node. */
        recv_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.10.2.2 - Invalid receive endpoint - valid foreign node, invalid port
         * ID - will succeed since local node doesn't know that the foreign port
         * is not open.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

#endif

        /* 1.10.2.3 - Invalid receive endpoint, invalid buffer. */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.2.4 - Invalid receive endpoint, invalid buffer, invalid buffer
         * size.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.2.5 - Invalid receive endpoint, invalid buffer, invalid buffer size,
         * invalid priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.2.6 - Invalid receive endpoint, invalid buffer, invalid buffer size,
         * invalid priority, invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.10.2.7 - Try to send data over a half open connection. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.10.2.8 - Try to send data over connected endpoints with an invalid
         * buffer.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.2.9 - Try to send data over connected endpoints with an invalid buffer
         * and invalid buffer size.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.2.10 - Try to send data over connected endpoints with an invalid
         * buffer, invalid buffer size and invalid priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.2.11 - Try to send data over connected endpoints with an invalid
         * buffer, invalid buffer size, invalid priority, invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task process the close requests. */
        MCAPID_Sleep(1000);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.10.1.7 - Try to send data over connected endpoints. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the send side of the scalar channel. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.10.1.13 - Try to send data over a half open connection. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the receive side of the scalar channel. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.10.1.14 - Try to send data over an open connection. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task process the close requests. */
        MCAPID_Sleep(1000);

        /* 1.10.3.1 - Specify an invalid buffer structure with a valid size -
         * Can send a null buffer if the size is zero.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 0, 1, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        /* 1.10.3.2 - Specify an invalid buffer, invalid size. */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.3.3 - Specify an invalid buffer, invalid size. */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                       &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.3.4 - Specify an invalid buffer, invalid size, invalid priority. */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.10.3.5 - Specify an invalid buffer, invalid size, invalid priority,
         * invalid request, invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.10.3.6 - Specify an invalid send endpoint, invalid buffer, invalid size,
         * invalid priority, invalid request, invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Create a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.10.4.1 - Specify a larger send size than valid with a valid buffer. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                       1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_MSG_SIZE)
            MCAPI_TEST_Error();

        /* 1.10.4.2 - Specify a larger send size than valid, invalid priority. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PRIORITY)
            MCAPI_TEST_Error();

        /* 1.10.4.3 - Specify a larger send size than valid, invalid priority,
         * invalid status.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                       MCAPI_PRIO_COUNT, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.10.4.4 - Specify invalid send endpoint and larger send size than valid. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                       1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.10.4.5 - Specify invalid send endpoint, invalid receive endpoint and
         * larger send size than valid.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                       1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* 1.10.5.1 - Specify an invalid priority. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PRIORITY)
            MCAPI_TEST_Error();

        /* 1.10.5.2 - Specify an invalid priority, invalid status. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128,
                       MCAPI_PRIO_COUNT, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.10.5.3 - Specify an invalid send endpoint, invalid priority. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.10.5.4 - Specify an invalid send endpoint, invalid receive endpoint,
         * invalid priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.10.5.5 - Specify an invalid send endpoint, invalid receive endpoint,
         * invalid buffer, invalid priority.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128,
                       MCAPI_PRIO_COUNT, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* 1.10.6.1 - Specify an invalid status structure. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.10.6.2 - Specify an invalid status structure, invalid send endpoint. */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.10.6.3 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, buffer, 128, 1, 0);

        /* 1.10.6.4 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint, invalid buffer.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, 128, 1, 0);

        /* 1.10.6.5 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint, invalid buffer, invalid buffer size.
         */
        mcapi_msg_send(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_msg_send
*
*   DESCRIPTION
*
*      Tests mcapi_msg_send input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_msg_send(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, recv_endpoint;
    char                        buffer[MCAPI_MAX_DATA_LEN];
    size_t                      size;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             request, connect_request;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.9.1.1 - Invalid send endpoint. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* Construct a receive endpoint using a foreign node that
         * doesn't exist.
         */
        recv_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 100, 1000);

        /* 1.9.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.9.1.3 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.4 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.5 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.6 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid priority, invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.7 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid priority, invalid request,
         * invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.9.1.7 - Try to send data over connected endpoints. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.9.1.8 - Try to send data over connected endpoints with an invalid
         * receive endpoint.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        /* There are two possible valid return statuses since the send side may
         * not have yet received the fin message.
         */
        if ( (mcapi_status != MCAPI_ERR_ENDP_INVALID) && (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.9.1.9 - Try to send data over connected endpoints with an invalid
         * receive endpoint and invalid buffer.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.10 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer and invalid buffer size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.11 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size and invalid
         * priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.12 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size, invalid
         * priority and invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.13 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size, invalid
         * priority, invalid request and invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.9.1.14 - Try to send data over a half open connection. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Delete the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.9.1.15 - Try to send data over connected endpoints with an invalid
         * receive endpoint.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        /* There are two possible valid return values since the send side may not
         * have received the fin yet.
         */
        if ( (mcapi_status != MCAPI_ERR_ENDP_INVALID) && (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.9.1.16 - Try to send data over connected endpoints with an invalid
         * receive endpoint and invalid buffer.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.17 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer and invalid buffer size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.18 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size and invalid
         * priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.19 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size, invalid
         * priority and invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.1.20 - Try to send data over connected endpoints with an invalid
         * receive endpoint, invalid buffer, invalid buffer size, invalid
         * priority, invalid request and invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Close the send side. */
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint on a non-existent foreign node. */
        recv_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 100, 1000);

        /* 1.9.2.1 - Invalid receive endpoint - invalid foreign node encoded
         * in the endpoint.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_NODE_INVALID)
            MCAPI_TEST_Error();

#ifdef MCAPI_FOREIGN_TEST

        /* Encode a non-existent port on a valid foreign node. */
        recv_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.9.2.2 - Invalid receive endpoint - valid foreign node, invalid port
         * ID - will succeed since local node doesn't know that the foreign port
         * is not open.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

#endif

        /* 1.9.2.3 - Invalid receive endpoint, invalid buffer. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.4 - Invalid receive endpoint, invalid buffer, invalid buffer
         * size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.5 - Invalid receive endpoint, invalid buffer, invalid buffer size,
         * invalid priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.6 - Invalid receive endpoint, invalid buffer, invalid buffer size,
         * invalid priority, invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.7 - Invalid receive endpoint, invalid buffer, invalid buffer size,
         * invalid priority, invalid request, invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.9.2.8 - Try to send data over a half open connection. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.9.2.9 - Try to send data over connected endpoints with an invalid
         * buffer.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.10 - Try to send data over connected endpoints with an invalid buffer
         * and invalid buffer size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.11 - Try to send data over connected endpoints with an invalid
         * buffer, invalid buffer size and invalid priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.12 - Try to send data over connected endpoints with an invalid
         * buffer, invalid buffer size, invalid priority and invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.2.13 - Try to send data over connected endpoints with an invalid
         * buffer, invalid buffer size, invalid priority, invalid request and
         * invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.9.1.7 - Try to send data over connected endpoints. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the send side of the scalar channel. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.9.1.7 - Try to send data over a half open connection. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the receive side of the scalar channel. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.9.1.14 - Try to send data over an open connection. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        /* 1.9.3.1 - Specify an invalid buffer structure with a valid buffer
         * size - a null buffer is valid if the size of data is zero.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 0, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        /* 1.9.3.2 - Specify an invalid buffer, invalid size. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.3.3 - Specify an invalid buffer, invalid size. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.3.4 - Specify an invalid buffer, valid size. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 0, 1,
                         &request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        /* 1.9.3.5 - Specify an invalid buffer, invalid size, invalid priority. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.3.6 - Specify an invalid buffer, invalid size, invalid priority,
         * invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.3.7 - Specify an invalid buffer, invalid size, invalid priority,
         * invalid request, invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.9.3.7 - Specify an invalid send endpoint, invalid buffer, invalid size,
         * invalid priority, invalid request, invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Create a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.9.4.1 - Specify a larger send size than valid. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                         1, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_MSG_SIZE)
            MCAPI_TEST_Error();

        /* 1.9.4.2 - Specify a larger send size than valid, invalid priority. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PRIORITY)
            MCAPI_TEST_Error();

        /* 1.9.4.3 - Specify a larger send size than valid, invalid priority,
         * invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.4.4 - Specify a larger send size than valid, invalid priority,
         * invalid request, invalid status.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.9.4.5 - Specify invalid send endpoint and larger send size than valid. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                         1, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.9.4.6 - Specify invalid send endpoint, invalid receive endpoint and
         * larger send size than valid.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, MCAPI_MAX_DATA_LEN + 1,
                         1, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.9.5.1 - Specify an invalid priority. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PRIORITY)
            MCAPI_TEST_Error();

        /* 1.9.5.2 - Specify an invalid priority, invalid request. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128,
                         MCAPI_PRIO_COUNT, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.5.3 - Specify an invalid priority, invalid request, invalid status. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128,
                         MCAPI_PRIO_COUNT, 0, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.9.5.4 - Specify an invalid send endpoint, invalid priority. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128,
                         MCAPI_PRIO_COUNT,  &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.9.5.5 - Specify an invalid send endpoint, invalid receive endpoint,
         * invalid priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.9.5.6 - Specify an invalid send endpoint, invalid receive endpoint,
         * invalid buffer, invalid priority.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128,
                         MCAPI_PRIO_COUNT, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* 1.9.6.1 - Specify an invalid request structure. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.6.2 - Specify an invalid request and status. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         0, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.9.6.3 - Specify an invalid request, and send endpoint. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.9.6.4 - Specify an invalid request, invalid send endpoint, invalid
         * receive endpoint.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.6.5 - Specify an invalid request, invalid send endpoint, invalid
         * receive endpoint, invalid buffer.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.9.6.6 - Specify an invalid request, invalid send endpoint, invalid
         * receive endpoint, invalid buffer, invalid buffer size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.9.7.1 - Specify an invalid status structure. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.9.7.2 - Specify an invalid status structure, invalid send endpoint. */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.9.7.3 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, buffer, 128, 1,
                         &request, 0);

        /* 1.9.7.4 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint, invalid buffer.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, 128, 1,
                         &request, 0);

        /* 1.9.7.5 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint, invalid buffer, invalid buffer size.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         &request, 0);

        /* 1.9.7.6 - Specify an invalid status structure, invalid send endpoint,
         * invalid receive endpoint, invalid buffer, invalid buffer size,
         * invalid request.
         */
        mcapi_msg_send_i(send_endpoint, recv_endpoint, 0, MCAPI_MAX_DATA_LEN + 1, 1,
                         0, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_msg_recv_i
*
*   DESCRIPTION
*
*      Tests mcapi_msg_recv_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_msg_recv_i(int type)
{
    mcapi_status_t      mcapi_status;
    mcapi_endpoint_t    send_endpoint, recv_endpoint;
    mcapi_request_t     request, connect_request;
    char                buffer[128];
    size_t              size;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.12.1.1 - Try to receive data on the closed endpoint. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.12.1.2 - Try to receive data on the closed endpoint, invalid
         * buffer.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.3 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid size.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.4 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid size, invalid request.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.5 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid size, invalid request, invalid status.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, 0);

        /* Create another receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.12.1.6 - Try to receive data over connected endpoints. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.12.1.7 - Try to receive data over connected endpoints, invalid buffer. */
        mcapi_msg_recv_i(recv_endpoint, 0, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.8 - Try to receive data over connected endpoints, invalid buffer,
         * invalid buffer size.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.9 - Try to receive data over connected endpoints, invalid buffer,
         * invalid buffer size, invalid request.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.10 - Try to receive data over connected endpoints, invalid buffer,
         * invalid buffer size, invalid request.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, 0);

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.12.1.6 - Try to receive receive over a half open connection. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request,
                         &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.12.1.11 - Try to receive data over an open connection. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* 1.12.1.12 - Try to receive data over an open connection, invalid buffer. */
        mcapi_msg_recv_i(recv_endpoint, 0, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.13 - Try to receive data over an open connection, invalid buffer,
         * invalid buffer size.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.14 - Try to receive data over an open connection, invalid buffer,
         * invalid buffer size, invalid request.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.1.15 - Try to receive data over an open connection, invalid buffer,
         * invalid buffer size, invalid request, invalid status.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, 0);

        /* Close the send and receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.12.1.6 - Try to receive data over connected endpoints. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request,
                         &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the send side of the scalar channel. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.12.1.6 - Try to receive data over a half open connection. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request,
                         &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Open the receive side of the scalar channel. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.12.1.11 - Try to receive data over an open connection. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request,
                         &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        /* 1.12.2.1 - Specify an invalid buffer structure. */
        mcapi_msg_recv_i(recv_endpoint, 0, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.2.2 - Specify an invalid buffer structure, invalid buffer size. */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.2.3 - Specify an invalid buffer structure, invalid buffer size,
         * invalid request.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.2.4 - Specify an invalid buffer structure, invalid buffer size,
         * invalid request, invalid status.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, 0, 0);

        /* 1.12.3.1 - Specify an invalid buffer size. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.3.2 - Specify an invalid buffer size, invalid request. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.3.3 - Specify an invalid buffer size, invalid request, invalid
         * status.
         */
        mcapi_msg_recv_i(recv_endpoint, buffer, 0, 0, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.12.3.4 - Specify an invalid buffer size, invalid receive endpoint. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create another receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.12.4.1 - Specify an invalid request structure. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.4.2 - Specify an invalid request structure, invalid status. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, 0, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.12.4.3 - Specify an invalid request structure, invalid receive
         * endpoint.
         */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.12.4.4 - Specify an invalid request structure, invalid receive
         * endpoint, invalid buffer.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Create another receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.12.5.1 - Specify an invalid status structure. */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.12.5.2 - Specify an invalid status structure, invalid receive
         * endpoint.
         */
        mcapi_msg_recv_i(recv_endpoint, buffer, 128, &request, 0);

        /* 1.12.5.3 - Specify an invalid status structure, invalid receive
         * endpoint, invalid buffer.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 128, &request, 0);

        /* 1.12.5.4 - Specify an invalid status structure, invalid receive
         * endpoint, invalid buffer, invalid buffer size.
         */
        mcapi_msg_recv_i(recv_endpoint, 0, 0, &request, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_msg_recv
*
*   DESCRIPTION
*
*      Tests mcapi_msg_recv input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_msg_recv(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, recv_endpoint;
    mcapi_request_t             request, connect_request;
    char                        buffer[128];
    size_t                      size;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.11.1.1 - Invalid receive endpoint. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.11.1.2 - Invalid receive endpoint, invalid buffer. */
        mcapi_msg_recv(recv_endpoint, 0, 128, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.1.3 - Invalid receive endpoint, invalid buffer, invalid buffer
         * size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.1.4 - Invalid receive endpoint, invalid buffer, invalid buffer
         * size, invalid receive size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.1.5 - Invalid receive endpoint, invalid buffer, invalid buffer
         * size, invalid receive size, invalid status.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, 0);

        /* Create another receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.11.1.6 - Try to receive data over connected endpoints. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) || (size != 0) )
            MCAPI_TEST_Error();

        /* 1.11.1.7 - Try to receive data over connected endpoints, invalid
         * buffer.
         */
        mcapi_msg_recv(recv_endpoint, 0, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_PARAMETER) || (size != 0) )
            MCAPI_TEST_Error();

        /* 1.11.1.8 - Try to receive data over connected endpoints, invalid
         * buffer, invalid buffer size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_PARAMETER) || (size != 0) )
            MCAPI_TEST_Error();

        /* 1.11.1.9 - Try to receive data over connected endpoints, invalid
         * buffer, invalid buffer size, invalid received size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.1.10 - Try to receive data over connected endpoints, invalid
         * buffer, invalid buffer size, invalid received size, invalid status.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, 0);

        /* 1.11.1.6 - Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to receive over a half open connection. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) || (size != 0) )
            MCAPI_TEST_Error();

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.11.1.11 - Try to receive data over an open connection. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) || (size != 0) )
            MCAPI_TEST_Error();

        /* 1.11.1.12 - Try to receive data over an open connection, invalid
         * buffer.
         */
        mcapi_msg_recv(recv_endpoint, 0, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_PARAMETER) || (size != 0) )
            MCAPI_TEST_Error();

        /* 1.11.1.13 - Try to receive data over an open connection, invalid
         * buffer, invalid buffer size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_PARAMETER) || (size != 0) )
            MCAPI_TEST_Error();

        /* 1.11.1.14 - Try to receive data over an open connection, invalid
         * buffer, invalid buffer size, invalid received size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.1.15 - Try to receive data over an open connection, invalid
         * buffer, invalid buffer size, invalid received size, invalid status.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, 0);

        /* Close the send and receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.11.1.6 - Try to receive data over connected endpoints. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) || (size != 0) )
            MCAPI_TEST_Error();

        /* Open the send side of the scalar channel. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.11.1.6 - Try to receive data over a half open connection. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) || (size != 0) )
            MCAPI_TEST_Error();

        /* Open the receive side of the scalar channel. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.11.1.11 - Try to receive data over an open connection. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, &mcapi_status);

        if ( (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) || (size != 0) )
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Let the control task run. */
        MCAPID_Sleep(1000);

        /* 1.11.2.1 - Specify an invalid buffer structure. */
        mcapi_msg_recv(recv_endpoint, 0, 128, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.2.2 - Specify an invalid buffer structure, invalid buffer size. */
        mcapi_msg_recv(recv_endpoint, 0, 0, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.2.3 - Specify an invalid buffer structure, invalid buffer size,
         * invalid received size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.2.4 - Specify an invalid buffer structure, invalid buffer size,
         * invalid received size, invalid status.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, 0, 0);

        /* 1.11.3.1 - Specify an invalid buffer size. */
        mcapi_msg_recv(recv_endpoint, buffer, 0, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.3.2 - Specify an invalid buffer size, invalid received size. */
        mcapi_msg_recv(recv_endpoint, buffer, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.3.3 - Specify an invalid buffer size, invalid received size,
         * invalid status.
         */
        mcapi_msg_recv(recv_endpoint, buffer, 0, 0, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.11.3.4 - Specify an invalid buffer size, invalid receive endpoint. */
        mcapi_msg_recv(recv_endpoint, buffer, 0, &size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Open the receive side back up. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.11.4.1 - Specify an invalid received size. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.4.2 - Specify an invalid received size, invalid status. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, 0, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.11.4.3 - Specify an invalid received size, invalid receive endpoint. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* 1.11.4.4 - Specify an invalid received size, invalid receive endpoint,
         * invalid buffer.
         */
        mcapi_msg_recv(recv_endpoint, 0, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();

        /* Open the receive side back up. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.11.5.1 - Specify an invalid status structure. */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, 0);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.11.5.2 - Specify an invalid status structure, invalid receive
         * endpoint.
         */
        mcapi_msg_recv(recv_endpoint, buffer, 128, &size, 0);

        /* 1.11.5.3 - Specify an invalid status structure, invalid receive
         * endpoint, invalid buffer.
         */
        mcapi_msg_recv(recv_endpoint, 0, 128, &size, 0);

        /* 1.11.5.4 - Specify an invalid status structure, invalid receive
         * endpoint, invalid buffer, invalid buffer size.
         */
        mcapi_msg_recv(recv_endpoint, 0, 0, &size, 0);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_msg_available
*
*   DESCRIPTION
*
*      Tests mcapi_msg_available input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_msg_available(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, recv_endpoint;
    mcapi_request_t             request, connect_request;
    size_t                      size;
    mcapi_uint_t                byte_count;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);

        /* 1.13.1.1 - Check if data is available on a closed endpoint. */
        byte_count = mcapi_msg_available(recv_endpoint, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_ENDP_INVALID) )
            MCAPI_TEST_Error();

        /* 1.13.1.2 - Check if data is available on a closed endpoint, invalid
         * status.
         */
        byte_count = mcapi_msg_available(recv_endpoint, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();

        /* Create another receive endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.13.1.3 - Check if data is available on a packet connected endpoint. */
        byte_count = mcapi_msg_available(recv_endpoint, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.13.1.4 - Check if data is available on a packet connected endpoint,
         * invalid status.
         */
        byte_count = mcapi_msg_available(recv_endpoint, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.13.1.5 - Check if data is available on an open endpoint. */
        byte_count = mcapi_msg_available(recv_endpoint, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.13.1.6 - Check if data is available on an open endpoint, invalid
         * status.
         */
        byte_count = mcapi_msg_available(recv_endpoint, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Close the endpoints. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, recv_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.13.1.3 - Check if data is available on a scalar connected endpoint. */
        byte_count = mcapi_msg_available(recv_endpoint, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.13.1.4 - Check if data is available on a scalar connected endpoint,
         * invalid status.
         */
        byte_count = mcapi_msg_available(recv_endpoint, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();

        /* Open the receive side of the scalar channel. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, recv_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.13.1.5 - Check if data is available on a receive open endpoint. */
        byte_count = mcapi_msg_available(recv_endpoint, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_CHAN_CONNECTED) )
            MCAPI_TEST_Error();

        /* 1.13.1.6 - Check if data is available on a receive open endpoint,
         * invalid status.
         */
        byte_count = mcapi_msg_available(recv_endpoint, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Close the endpoints. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.13.2.1 - Specify an invalid status structure. */
        byte_count = mcapi_msg_available(recv_endpoint, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();

        /* Close the endpoint. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_connect_pktchan_i
*
*   DESCRIPTION
*
*      Tests mcapi_connect_pktchan_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_connect_pktchan_i(int type)
{
    mcapi_status_t      mcapi_status;
    mcapi_endpoint_t    send_endpoint, receive_endpoint;
    mcapi_request_t     request, connect_request, send_request, recv_request;
    size_t              size;
    mcapi_pktchan_recv_hndl_t   recv_handle;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   scal_recv_handle;
    mcapi_sclchan_send_hndl_t   scal_send_handle;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.14.1.1 - Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Attempt to issue the connect with an invalid send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.14.1.2 - Attempt to connect again over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the send side of the scalar. */
        mcapi_open_sclchan_send_i(&scal_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* 1.14.1.3 - Attempt to connect again over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the scalar connection. */
        mcapi_sclchan_send_close_i(scal_send_handle, &request, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);



        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Open a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.14.1.4 - Attempt to connect again over a half open connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the send side of the packet connection. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.14.1.5 - Attempt to connect again over a open connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);


        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.14.1.6 - Attempt to connect with an invalid local receive
         * and send endpoint.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create an invalid foreign endpoint with an invalid foreign
         * node.
         */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.14.1.7 - Attempt to connect with an invalid send endpoint,
         * invalid foreign receive endpoint with invalid foreign node.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#ifdef MCAPI_FOREIGN_TEST

        /* Create an invalid endpoint on a valid foreign node. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.1.8 - Attempt to connect with an invalid send endpoint,
         * invalid foreign endpoint, valid foreign node.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#endif

        /* Open a new receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.14.1.9 - Invalid send endpoint, invalid receive endpoint,
         * invalid request.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.14.1.10 - Invalid send endpoint, invalid receive endpoint,
         * invalid request, invalid status.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_TEST_FOREIGN

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create an invalid foreign send endpoint, valid node, invalid
         * endpoint.
         */
        send_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.2.1 - Connect to an invalid foreign send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* On the foreign send node, connect the foreign send side as a
         * scalar.
         */

        /* 1.14.2.2 - Connect with a half-connected scalar send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign node side, open the send side of the scalar
         * connection.
         */

        /* 1.14.2.3 - Connect with a fully connected send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign node side, close the scalar connection. */


        /* On the foreign node side, connect foreign send side as packet
         * channel.
         */

        /* 1.14.2.4 - Connect again with half-connected packet send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign node side, open the foreign send side of the packet
         * channel.
         */

        /* 1.14.2.5 - Connect again with connected packet send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

#endif

        /* Create an invalid foreign send endpoint with an invalid node. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.14.2.6 - Invalid foreign send endpoint, invalid receive
         * endpoint.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.14.2.7 - Invalid foreign send endpoint, invalid receive
         * endpoint, invalid request.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.14.2.8 - Invalid foreign send endpoint, invalid receive
         * endpoint, invalid request, invalid mcapi_status.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_FOREIGN_TEST

        /* Get a valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* Create an invalid foreign send endpoint, invalid node. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.14.3.1 - Connect over invalid foreign send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Create an invalid foreign send endpoint, valid node, invalid port. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.3.2 - Connect over invalid foreign send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get a valid foreign send endpoint. */
        send_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_TX_Port);

        /* On the foreign send node, connect the send endpoint as a scalar
         * connection.
         */

        /* 1.14.3.3 - Connect with half-open scalar send side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign send node, open the send side of the scalar channel. */

        /* 1.14.3.4 - Connect with connected scalar send side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign node, close the send side of the scalar channel. */


        /* On the foreign send node, connect the send endpoint with a packet
         * connection.
         */

        /* 1.14.3.5 - Connect with half-open packet send side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign send node, open the send side of the connection. */

        /* 1.14.3.6 - Connect with connect packet send side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign node, close the send side of the packet channel. */

        /* Create an invalid foreign receive endpoint, invalid node. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.14.3.7 - Connect over invalid foreign receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Create an invalid foreign receive endpoint, valid node, invalid port. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.3.8 - Connect over invalid foreign receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get a valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* On the foreign receive node, connect the receive endpoint with a scalar
         * connection.
         */

        /* 1.14.3.9 - Connect with half-open scalar receive side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive node, open the receive side of the scalar channel. */

        /* 1.14.3.10 - Connect with connected scalar receive side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive node, close the receive side of the scalar
         * channel.
         */


        /* On the foreign receive node, connect the receive endpoint with a
         * packet connection.
         */

        /* 1.14.3.11 - Connect with half-open packet receive side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive node, open the receive side of the connection. */

        /* 1.14.3.12 - Connect with connect packet receive side. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive node, close the receive side of the packet
         * channel.
         */

#endif

        /* Create an invalid foreign send endpoint with invalid node ID. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 100, 1000);

        /* Create an invalid foreign receive endpoint with invalid node ID. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 100, 1000);

        /* 1.14.3.13 - Connect with invalid foreign send endpoint, invalid
         * foreign receive endpoint, invalid request.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.14.3.14 - Connect with invalid foreign send endpoint, invalid
         * foreign receive endpoint, invalid request, invalid mcapi_status.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_TEST_FOREIGN

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create an invalid foreign receive endpoint, valid node, invalid
         * endpoint.
         */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.4.1 - Connect to an invalid foreign receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get a valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* On the foreign receive node, connect the receive side as a scalar. */

        /* 1.14.4.2 - Connect with a half-connected scalar receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive side, open the receive side of the scalar
         * connection.
         */

        /* 1.14.4.3 - Connect with a fully connected receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive side, close the connection. */


        /* On the foreign receive side, connect receive side as packet channel. */

        /* 1.14.4.4 - Connect again with half-connected packet receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive side, open the receive side of the packet
         * channel.
         */

        /* 1.14.4.5 - Connect again with connected packet send endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive side, close the connection. */

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
#endif

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.14.5.1 - Attempt to issue the connect with an invalid receive
         * endpoint.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.14.5.2 - Attempt to connect again over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the receive side of the scalar. */
        mcapi_open_sclchan_recv_i(&scal_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.14.5.3 - Attempt to connect again over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the scalar connection. */
        mcapi_sclchan_recv_close_i(scal_recv_handle, &request, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);


        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Open a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.14.5.4 - Attempt to connect again over a half open connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the receive side of the packet connection. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.14.5.5 - Attempt to connect again over a open connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);


        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.14.5.6 - Attempt to connect with an invalid local send
         * endpoint.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create an invalid foreign endpoint with an invalid foreign
         * node.
         */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.14.5.7 - Attempt to connect with an invalid foreign send endpoint
         * with invalid foreign node.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#ifdef MCAPI_FOREIGN_TEST

        /* Create an invalid endpoint on a valid foreign node. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.5.8 - Attempt to connect with an invalid foreign send endpoint,
         * valid foreign node.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#endif

        /* Open a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.14.5.9 - Invalid send endpoint, invalid receive endpoint,
         * invalid request.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.14.5.10 - Invalid send endpoint, invalid receive endpoint,
         * invalid request, invalid mcapi_status.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_FOREIGN_TEST

        /* Get a valid send endpoint. */
        send_endpoint =
            mcapi_encode_endpoint(FOREIGN_NODE_ID, Foreign_TX_Port);

        /* Create an invalid receive endpoint, invalid node. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.14.6.1 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create an invalid receive endpoint, invalid port. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.14.6.2 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* Foreign receive node connects receive endpoint as scalar. */

        /* 1.14.6.3 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Foreign receive node opens receive side of scalar. */

        /* 1.14.6.4 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Foreign receive node closes receive side of scalar. */


        /* Foreign receive node connects receive endpoint as packet. */

        /* 1.14.6.5 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Foreign receive node opens receive side of packet channel. */

        /* 1.14.6.6 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Foreign receive node closes receive side of packet channel. */

#endif

        /* Open a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Open a new receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.14.7.1 - Invalid request. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.14.7.2 - Invalid request, invalid mcapi_status. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, 0);


        /* Close send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.14.7.3 - Invalid send endpoint, invalid request, invalid mcapi_status. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, 0, 0);


        /* Open send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.14.8.1 - Invalid mcapi_status. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request, 0);


        /* Close send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.14.8.2 - Invalid send endpoint, invalid mcapi_status. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request, 0);


        /* Close receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.14.8.3 - Invalid send endpoint, invalid receive endpoint, invalid
         * mcapi_status.
         */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_open_pktchan_recv_i
*
*   DESCRIPTION
*
*      Tests mcapi_open_pktchan_recv_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_open_pktchan_recv_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_pktchan_recv_hndl_t   recv_handle;
    mcapi_pktchan_send_hndl_t   send_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.15.1.1 - Invalid receive handle. */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, &recv_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.15.1.2 - Invalid receive handle, invalid receive endpoint. */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, &recv_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.15.1.3 - 1.15.1.3  Invalid rx handle, invalid receive endpoint,
         * invalid request.
         */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.15.1.4 - Invalid rx handle, invalid receive endpoint,
         * invalid request, invalid status.
         */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, 0, 0);


        /* 1.15.2.1 - Invalid receive endpoint. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* 1.15.2.2 - Invalid receive endpoint, invalid request. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.15.2.3 - Invalid receive endpoint, invalid request, invalid
         * status.
         */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, 0, 0);


        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* 1.15.2.4 Valid rx handle, endpoint opened for packet tx */

        /* Open the endpoint for packet tx. */
        mcapi_open_pktchan_send_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Try to open as a receive endpoint. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for tx. */
        mcapi_packetchan_send_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* 1.15.2.5 Valid rx handle, endpoint opened for scalar tx */

        /* Open the endpoint as a tx scalar. */
        mcapi_open_sclchan_send_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Try to open as a receive endpoint. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for tx. */
        mcapi_sclchan_send_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* 1.15.2.6 Valid rx handle, endpoint opened for scalar rx */

        /* Open the endpoint as a rx scalar. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Try to open as a receive endpoint. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* 1.15.2.7 Valid rx handle, endpoint connected for scalar rx */

        /* Open the send side of the scalar. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Try to open as a receive endpoint. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* 1.15.3.1 - Invalid request. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.15.3.2 - Invalid request, invalid status. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, 0, 0);


        /* 1.15.3.3 - Invalid receive handle, invalid request, invalid status. */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, 0, 0);


        /* 1.15.4.1 - Invalid status. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &recv_request, 0);


        /* 1.15.4.2 - Invalid receive handle, invalid status. */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, &recv_request, 0);


        /* Delete the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.15.4.3 - Invalid receive handle, invalid receive endpoint, invalid
         * status.
         */
        mcapi_open_pktchan_recv_i(0, receive_endpoint, &recv_request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_open_pktchan_send_i
*
*   DESCRIPTION
*
*      Tests mcapi_open_pktchan_send_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_open_pktchan_send_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_pktchan_recv_hndl_t   recv_handle;
    mcapi_pktchan_send_hndl_t   send_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.16.1.1 - Invalid send handle. */
        mcapi_open_pktchan_send_i(0, send_endpoint, &send_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.16.1.2 - Invalid send handle, invalid send endpoint. */
        mcapi_open_pktchan_send_i(0, send_endpoint, &send_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.16.1.3 - Invalid send handle, invalid send endpoint,
         * invalid request.
         */
        mcapi_open_pktchan_send_i(0, send_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.16.1.4 - Invalid send handle, invalid send endpoint,
         * invalid request, invalid status.
         */
        mcapi_open_pktchan_send_i(0, send_endpoint, 0, 0);


        /* 1.16.2.1 - Invalid send endpoint. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* 1.16.2.2 - Invalid send endpoint, invalid request. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.16.2.3 - Invalid send endpoint, invalid request, invalid
         * status.
         */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, 0, 0);


        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.16.2.4 Valid tx handle, endpoint opened for packet rx */

        /* Open the endpoint for packet rx. */
        mcapi_open_pktchan_recv_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to open as a send endpoint. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for rx. */
        mcapi_packetchan_recv_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* 1.16.2.5 Valid tx handle, endpoint opened for scalar rx */

        /* Open the endpoint as a rx scalar. */
        mcapi_open_sclchan_recv_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to open as a send endpoint. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for rx. */
        mcapi_sclchan_recv_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* 1.16.2.6 Valid tx handle, endpoint opened for scalar tx */

        /* Open the endpoint as a tx scalar. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to open as a send endpoint. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* 1.16.2.7 Valid tx handle, endpoint connected for scalar tx */

        /* Open the recv side of the scalar. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Try to open as a send endpoint. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* 1.16.3.1 - Invalid request. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.16.3.2 - Invalid send, invalid status. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, 0, 0);


        /* 1.16.3.3 - Invalid send handle, invalid request, invalid status. */
        mcapi_open_pktchan_send_i(0, send_endpoint, 0, 0);


        /* 1.16.4.1 - Invalid status. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request, 0);


        /* 1.16.4.2 - Invalid send handle, invalid status. */
        mcapi_open_pktchan_send_i(0, send_endpoint, &send_request, 0);


        /* Delete the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.16.4.3 - Invalid send handle, invalid send endpoint, invalid
         * status.
         */
        mcapi_open_pktchan_send_i(0, send_endpoint, &send_request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_pktchan_send_i
*
*   DESCRIPTION
*
*      Tests mcapi_pktchan_send_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_pktchan_send_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    char                        buffer[MCAPI_MAX_DATA_LEN];
    size_t                      size;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   receive_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.1.1 - Invalid send endpoint. */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.17.1.3 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer.
         */
        mcapi_pktchan_send_i(send_handle, 0, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.1.4 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid size.
         */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, &request,
                             &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.1.5 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid size, invalid request.
         */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.1.6 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid request, invalid status.
         */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0, 0);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* wait for the close to be received. */
        MCAPID_Sleep(2000);

        /* 1.17.1.7 - Invalid tx handle (rx side closed). */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.17.1.8 - Invalid tx handle (tx opened, rx not opened, no connection. */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.17.1.9 - Invalid tx handle (no connection) */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.1.10 - Scalar tx handle. */
        mcapi_pktchan_send_i(scl_send_handle, buffer, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.2.1 - Invalid buffer. */
        mcapi_pktchan_send_i(send_handle, 0, 128, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.2.2 - Invalid buffer, zero size. */
        mcapi_pktchan_send_i(send_handle, 0, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();



        /* 1.17.2.3 - Invalid buffer, invalid size. */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, &request,
                             &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.2.4 - Invalid buffer, invalid size, invalid request */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.2.5 - Invalid buffer, invalid size, invalid request,
         * invalid status
         */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0, 0);


        /* 1.17.3.1 - Invalid size. */
        mcapi_pktchan_send_i(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, &request,
                             &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PKT_SIZE)
            MCAPI_TEST_Error();


        /* 1.17.3.2 - Valid zero size with valid buffer. */
        mcapi_pktchan_send_i(send_handle, buffer, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();


        /* 1.17.3.3 - Invalid size, invalid request. */
        mcapi_pktchan_send_i(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0,
                             &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.3.4 - Invalid size, invalid request, invalid status. */
        mcapi_pktchan_send_i(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0, 0);


        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.3.5 - Invalid tx handle, invalid size, invalid request, invalid
         * status.
         */
        mcapi_pktchan_send_i(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0, 0);

        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.17.4.1 - Invalid request. */
        mcapi_pktchan_send_i(send_handle, buffer, 128, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.17.4.2 - Invalid status, invalid request. */
        mcapi_pktchan_send_i(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0, 0);


        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.4.3 - Invalid request, invalid status, invalid send handle. */
        mcapi_pktchan_send_i(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0, 0);


        /* 1.17.4.4 - Invalid send handle, invalid buffer, invalid request,
         * invalid status.
         */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0, 0);

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.17.5.1 - Invalid status. */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, 0);


        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.17.5.2 - Invalid tx handle, invalid status. */
        mcapi_pktchan_send_i(send_handle, buffer, 128, &request, 0);


        /* 1.17.5.3 - Invalid tx handle, invalid buffer, invalid status. */
        mcapi_pktchan_send_i(send_handle, 0, 128, &request, 0);


        /* 1.17.5.4 - Invalid tx handle, invalid buffer, invalid size, invalid
         * status.
         */
        mcapi_pktchan_send_i(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, &request, 0);

        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_pktchan_send
*
*   DESCRIPTION
*
*      Tests mcapi_pktchan_send input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_pktchan_send(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    char                        buffer[MCAPI_MAX_DATA_LEN];
    size_t                      size;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   receive_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.18.1.1 - Invalid send endpoint. */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.18.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.18.1.3 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer.
         */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.18.1.4 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid size.
         */
        mcapi_pktchan_send(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.18.1.5 - Invalid send endpoint, invalid receive endpoint, invalid
         * buffer, invalid buffer size, invalid status.
         */
        mcapi_pktchan_send(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        /* 1.18.1.6 - Invalid tx handle (rx side closed). */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.18.1.7 - Invalid tx handle (tx opened, rx not opened, no connection. */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.18.1.8 - Invalid tx handle (no connection) */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.18.1.9 - Scalar tx handle. */
        mcapi_pktchan_send(scl_send_handle, buffer, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.18.2.1 - Invalid buffer. */
        mcapi_pktchan_send(send_handle, 0, 128, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.18.2.2 - Invalid buffer, zero size. */
        mcapi_pktchan_send(send_handle, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();


        /* 1.18.2.3 - Invalid buffer, invalid size. */
        mcapi_pktchan_send(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.18.2.4 - Invalid buffer, invalid size, invalid status */
        mcapi_pktchan_send(send_handle, 0, MCAPI_MAX_DATA_LEN + 1, 0);


        /* 1.18.3.1 - Invalid size. */
        mcapi_pktchan_send(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PKT_SIZE)
            MCAPI_TEST_Error();


        /* 1.18.3.2 - Invalid size. */
        mcapi_pktchan_send(send_handle, buffer, 0, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();


        /* 1.18.3.3 - Invalid size, invalid status. */
        mcapi_pktchan_send(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0);


        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.18.3.4 - Invalid tx handle, invalid size, invalidn status. */
        mcapi_pktchan_send(send_handle, buffer, MCAPI_MAX_DATA_LEN + 1, 0);

        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.18.4.1 - Invalid status. */
        mcapi_pktchan_send(send_handle, buffer, 128, 0);


        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.18.4.2 - Invalid tx handle, invalid status. */
        mcapi_pktchan_send(send_handle, buffer, 128, 0);


        /* 1.18.4.3 - Invalid tx handle, invalid buffer, invalid status. */
        mcapi_pktchan_send(send_handle, 0, 128, 0);

        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_pktchan_recv_i
*
*   DESCRIPTION
*
*      Tests mcapi_pktchan_recv_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_pktchan_recv_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    char                        *buffer;
    size_t                      size;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   receive_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.19.1.1 - Try to receive data on the closed handle. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.19.1.2 - Try to receive data on the closed endpoint, invalid
         * buffer.
         */
        mcapi_pktchan_recv_i(receive_handle, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.19.1.3 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid request.
         */
        mcapi_pktchan_recv_i(receive_handle, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.19.1.4 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid request, invalid status.
         */
        mcapi_pktchan_recv_i(receive_handle, 0, 0, 0);

        /* Close the transmit side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        /* 1.19.1.5 - TX side closed. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.19.1.6 - Connected, TX not open. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a scalar connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.19.1.7 - Scalar RX handle. */
        mcapi_pktchan_recv_i(scl_recv_handle, (void**)&buffer, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the scalar connection. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.19.2.1 - Invalid buffer. */
        mcapi_pktchan_recv_i(receive_handle, 0, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.19.2.2 - Invalid buffer, invalid request. */
        mcapi_pktchan_recv_i(receive_handle, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.19.2.3 - Invalid buffer, invalid request, invalid status. */
        mcapi_pktchan_recv_i(receive_handle, 0, 0, 0);


        /* 1.19.3.1 - Invalid request. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.19.3.2 - Invalid request, invalid status. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, 0, 0);


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.19.3.3 - Invalid request, invalid status, invalid rx handle. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, 0, 0);

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.19.4.1 - Invalid status. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, &request, 0);


        /* Close the rx handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.19.4.2 - Invalid status, invalid rx handle. */
        mcapi_pktchan_recv_i(receive_handle, (void**)&buffer, &request, 0);


        /* 1.19.4.3 - Invalid status, invalid rx handle. */
        mcapi_pktchan_recv_i(receive_handle, 0, &request, 0);

        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_pktchan_recv
*
*   DESCRIPTION
*
*      Tests mcapi_pktchan_recv input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_pktchan_recv(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    char                        *buffer;
    size_t                      size;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   receive_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;
    size_t                      rx_size;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.20.1.1 - Try to receive data on the closed handle. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, &rx_size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.20.1.2 - Try to receive data on the closed endpoint, invalid
         * buffer.
         */
        mcapi_pktchan_recv(receive_handle, 0, &rx_size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.20.1.3 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid rx size.
         */
        mcapi_pktchan_recv(receive_handle, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.20.1.4 - Try to receive data on the closed endpoint, invalid
         * buffer, invalid rx_size, invalid status.
         */
        mcapi_pktchan_recv_i(receive_handle, 0, 0, 0);

        /* Close the transmit side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);

        else
        {
            MCAPI_TEST_Error();
        }

        MCAPID_Sleep(2000);

        /* 1.20.1.5 - TX side closed. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, &rx_size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.20.1.6 - Connected, TX not open. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, &rx_size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a scalar connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.20.1.7 - Scalar RX handle. */
        mcapi_pktchan_recv(scl_recv_handle, (void**)&buffer, &rx_size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the scalar connection. */
        mcapi_sclchan_recv_close_i(receive_endpoint, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(send_endpoint, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.20.2.1 - Invalid buffer. */
        mcapi_pktchan_recv(receive_handle, 0, &rx_size, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.20.2.2 - Invalid buffer, invalid rx_size. */
        mcapi_pktchan_recv(receive_handle, 0, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.20.2.3 - Invalid buffer, invalid rx_size, invalid status. */
        mcapi_pktchan_recv(receive_handle, 0, 0, 0);


        /* 1.20.3.1 - Invalid rx_size. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.20.3.2 - Invalid rx_size, invalid status. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, 0, 0);


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.20.3.3 - Invalid rx_size, invalid status, invalid rx handle. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, 0, 0);

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.20.4.1 - Invalid status. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, &rx_size, 0);


        /* Close the rx handle. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.20.4.2 - Invalid status, invalid rx handle. */
        mcapi_pktchan_recv(receive_handle, (void**)&buffer, &rx_size, 0);


        /* 1.20.4.3 - Invalid status, invalid rx handle. */
        mcapi_pktchan_recv(receive_handle, 0, &rx_size, 0);

        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_pktchan_available
*
*   DESCRIPTION
*
*      Tests mcapi_pktchan_available input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_pktchan_available(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    size_t                      size;
    mcapi_uint_t                byte_count;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   receive_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.21.1.1 - Invalid rx handle. */
        byte_count = mcapi_pktchan_available(receive_handle, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();


        /* 1.21.1.2 - Invalid rx handle, invalid status */
        byte_count = mcapi_pktchan_available(receive_handle, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Connect the two endpoints as a scalar. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.21.1.3 - Pass in a scalar endpoint. */
        byte_count = mcapi_pktchan_available(scl_recv_handle, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&receive_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        /* 1.21.1.5 - Connection not made yet. */
        byte_count = mcapi_pktchan_available(receive_handle, &mcapi_status);

        if (mcapi_status != MGC_MCAPI_ERR_NOT_CONNECTED)
            MCAPI_TEST_Error();


        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.21.1.6 - Pass in a tx handle. */
        byte_count = mcapi_pktchan_available(send_handle, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();


        /* 1.21.2.1 - Invalid status. */
        byte_count = mcapi_pktchan_available(receive_handle, 0);

        /* Close the endpoints. */
        mcapi_packetchan_recv_close_i(receive_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Delete the endpoints. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_pktchan_free
*
*   DESCRIPTION
*
*      Tests mcapi_pktchan_free input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_pktchan_free(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, recv_endpoint;
    mcapi_request_t             request, connect_request;
    char                        buffer[MCAPI_MAX_DATA_LEN];
    char                        *recv_buf1;
    size_t                      size;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        recv_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, recv_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, recv_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.22.1.1 - Null buffer. */
        mcapi_pktchan_free(0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_BUF_INVALID)
            MCAPI_TEST_Error();


        /* Send some data to the endpoint. */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        /* Receive the data. */
        mcapi_pktchan_recv(recv_handle, (void**)&recv_buf1, &size, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            /* Free the buffer. */
            mcapi_pktchan_free((void*)recv_buf1, &mcapi_status);

            /* 1.22.1.2 - Attempt to free the buffer again. */
            mcapi_pktchan_free((void*)recv_buf1, &mcapi_status);

            if (mcapi_status != MCAPI_ERR_BUF_INVALID)
                MCAPI_TEST_Error();
        }


        /* 1.22.1.3 - Invalid buffer, invalid status. */
        mcapi_pktchan_free(0, 0);


        /* Send some data to the endpoint. */
        mcapi_pktchan_send(send_handle, buffer, 128, &mcapi_status);

        /* Receive the data. */
        mcapi_pktchan_recv(recv_handle, (void**)&recv_buf1, &size, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            /* 1.22.2.1 - Valid buffer, invalid status. */
            mcapi_pktchan_free((void*)recv_buf1, 0);

            /* Free the buffer. */
            mcapi_pktchan_free((void*)recv_buf1, &mcapi_status);

            if (mcapi_status != MCAPI_SUCCESS)
                MCAPI_TEST_Error();
        }

        /* Close the endpoints. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Delete the endpoints. */
        mcapi_delete_endpoint(recv_endpoint, &mcapi_status);
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_packetchan_recv_close_i
*
*   DESCRIPTION
*
*      Tests mcapi_packetchan_recv_close_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_packetchan_recv_close_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_pktchan_recv_hndl_t   recv_handle;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   scl_send_handle;
    mcapi_sclchan_send_hndl_t   scl_recv_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);

        /* 1.23.1.1 - Invalid rx handle. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.23.1.2 - tx handle. */
        mcapi_packetchan_recv_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the send and receive sides. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Open a scalar connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.23.1.3 - Use a scalar receive handle. */
        mcapi_packetchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);


        /* 1.23.1.4 - Invalid rx handle, invalid request. */
        mcapi_packetchan_recv_close_i(recv_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.23.1.5 - Invalid rx handle, invalid request, invalid status. */
        mcapi_packetchan_recv_close_i(recv_handle, 0, 0);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.23.2.1 - Invalid request. */
        mcapi_packetchan_recv_close_i(recv_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.23.2.2 - Invalid request, invalid status. */
        mcapi_packetchan_recv_close_i(recv_handle, 0, 0);


        /* 1.23.3.1 - Invalid status. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, 0);


        /* Close the receive handle. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);

        /* 1.23.3.2 - Invalid status, invalid receive handle. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, 0);

        /* Close the connection. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_packetchan_send_close_i
*
*   DESCRIPTION
*
*      Tests mcapi_packetchan_send_close_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_packetchan_send_close_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_pktchan_recv_hndl_t   recv_handle;
    mcapi_pktchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   scl_recv_handle;
    mcapi_sclchan_send_hndl_t   scl_send_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.24.1.1 - Invalid tx handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.24.1.2 - rx handle. */
        mcapi_packetchan_send_close_i(recv_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the send and receive sides. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Open a scalar connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&scl_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&scl_recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.24.1.3 - Use a scalar send handle. */
        mcapi_packetchan_send_close_i(scl_send_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_sclchan_recv_close_i(scl_recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(scl_send_handle, &request, &mcapi_status);


        /* 1.24.1.4 - Invalid tx handle, invalid request. */
        mcapi_packetchan_send_close_i(send_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.24.1.5 - Invalid tx handle, invalid request, invalid status. */
        mcapi_packetchan_send_close_i(send_handle, 0, 0);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.24.2.1 - Invalid request. */
        mcapi_packetchan_send_close_i(send_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.24.2.2 - Invalid request, invalid status. */
        mcapi_packetchan_send_close_i(send_handle, 0, 0);


        /* 1.24.3.1 - Invalid status. */
        mcapi_packetchan_send_close_i(send_handle, &request, 0);


        /* Close the send handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.24.3.2 - Invalid status, invalid receive handle. */
        mcapi_packetchan_send_close_i(send_handle, &request, 0);

        /* Close the connection. */
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_connect_sclchan_i
*
*   DESCRIPTION
*
*      Tests mcapi_connect_sclchan_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_connect_sclchan_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request;
    size_t                      size;
    mcapi_request_t             connect_request, send_request, recv_request;
    mcapi_sclchan_recv_hndl_t   recv_handle;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.25.1.1 - Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Attempt to issue the connect with an invalid send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.25.1.2 - Attempt to connect again over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* 1.25.1.3 - Attempt to connect again over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the packet connection. */
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Open a scalar connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.25.1.4 - Attempt to connect again over a half open connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the send side of the scalar connection. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.25.1.5 - Attempt to connect again over a open connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);


        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.25.1.6 - Attempt to connect with an invalid local receive
         * and send endpoint.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create an invalid foreign endpoint with an invalid foreign
         * node.
         */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.1.7 - Attempt to connect with an invalid send endpoint,
         * invalid foreign receive endpoint with invalid foreign node.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#ifdef MCAPI_FOREIGN_TEST

        /* Create an invalid endpoint on a valid foreign node. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.1.8 - Attempt to connect with an invalid send endpoint,
         * invalid foreign endpoint, valid foreign node.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#endif

        /* Open a new receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.25.1.9 - Invalid send endpoint, invalid receive endpoint,
         * invalid request.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.25.1.10 - Invalid send endpoint, invalid receive endpoint,
         * invalid request, invalid status.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_TEST_FOREIGN

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create an invalid foreign send endpoint, valid node, invalid
         * endpoint.
         */
        send_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.2.1 - Connect to an invalid foreign send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* On the foreign send node, connect the foreign send side as a
         * packet channel.
         */

        /* 1.25.2.2 - Connect with a half-connected packet send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign node side, open the send side of the packet
         * connection.
         */

        /* 1.25.2.3 - Connect with a fully connected send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign node side, close the packet connection. */


        /* On the foreign node side, connect foreign send side as scalar
         * channel.
         */

        /* 1.25.2.4 - Connect again with half-connected scalar send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign node side, open the foreign send side of the scalar
         * channel.
         */

        /* 1.25.2.5 - Connect again with connected scalar send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

#endif

        /* Create an invalid foreign send endpoint with an invalid node. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.2.6 - Invalid foreign send endpoint, invalid receive
         * endpoint.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

        /* 1.25.2.7 - Invalid foreign send endpoint, invalid receive
         * endpoint, invalid request.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.25.2.8 - Invalid foreign send endpoint, invalid receive
         * endpoint, invalid request, invalid mcapi_status.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_FOREIGN_TEST

        /* Get a valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* Create an invalid foreign send endpoint, invalid node. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.3.1 - Connect over invalid foreign send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Create an invalid foreign send endpoint, valid node, invalid port. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.3.2 - Connect over invalid foreign send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get a valid foreign send endpoint. */
        send_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_TX_Port);

        /* On the foreign send node, connect the send endpoint as a packet
         * connection.
         */

        /* 1.25.3.3 - Connect with half-open packet send side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign send node, open the send side of the packet channel. */

        /* 1.25.3.4 - Connect with connected packet send side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign node, close the send side of the packet channel. */


        /* On the foreign send node, connect the send endpoint with a scalar
         * connection.
         */

        /* 1.25.3.5 - Connect with half-open scalar send side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign send node, open the send side of the connection. */

        /* 1.25.3.6 - Connect with connect scalar send side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign node, close the send side of the scalar channel. */

        /* Create an invalid foreign receive endpoint, invalid node. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.3.7 - Connect over invalid foreign receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Create an invalid foreign receive endpoint, valid node, invalid port. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.3.8 - Connect over invalid foreign receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get a valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* On the foreign receive node, connect the receive endpoint with a packet
         * connection.
         */

        /* 1.25.3.9 - Connect with half-open packet receive side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive node, open the receive side of the packet channel. */

        /* 1.25.3.10 - Connect with connected packet receive side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive node, close the receive side of the packet
         * channel.
         */


        /* On the foreign receive node, connect the receive endpoint with a
         * scalar connection.
         */

        /* 1.25.3.11 - Connect with half-open scalar receive side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive node, open the receive side of the connection. */

        /* 1.25.3.12 - Connect with connect scalar receive side. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive node, close the receive side of the scalar
         * channel.
         */

#endif

        /* Create an invalid foreign send endpoint with invalid node ID. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* Create an invalid foreign receive endpoint with invalid node ID. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.3.13 - Connect with invalid foreign send endpoint, invalid
         * foreign receive endpoint, invalid request.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.25.3.14 - Connect with invalid foreign send endpoint, invalid
         * foreign receive endpoint, invalid request, invalid mcapi_status.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_TEST_FOREIGN

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create an invalid foreign receive endpoint, valid node, invalid
         * endpoint.
         */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.4.1 - Connect to an invalid foreign receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get a valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* On the foreign receive node, connect the receive side as a packet. */

        /* 1.25.4.2 - Connect with a half-connected packet receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive side, open the receive side of the packet
         * connection.
         */

        /* 1.25.4.3 - Connect with a fully connected receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive side, close the connection. */


        /* On the foreign receive side, connect receive side as scalar channel. */

        /* 1.25.4.4 - Connect again with half-connected scalar receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* On the foreign receive side, open the receive side of the scalar
         * channel.
         */

        /* 1.25.4.5 - Connect again with connected scalar send endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* On the foreign receive side, close the connection. */

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
#endif

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.25.5.1 - Attempt to issue the connect with an invalid receive
         * endpoint.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect over a packet channel. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.25.5.2 - Attempt to connect again over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the receive side of the packet. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.25.5.3 - Attempt to connect again over a scalar channel. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the packet connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Open a scalar connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.25.5.4 - Attempt to connect again over a half open connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Open the receive side of the scalar connection. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.25.5.5 - Attempt to connect again over a open connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);


        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.25.5.6 - Attempt to connect with an invalid local send
         * endpoint.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create an invalid foreign endpoint with an invalid foreign
         * node.
         */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.5.7 - Attempt to connect with an invalid foreign send endpoint
         * with invalid foreign node.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#ifdef MCAPI_FOREIGN_TEST

        /* Create an invalid endpoint on a valid foreign node. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.5.8 - Attempt to connect with an invalid foreign send endpoint,
         * valid foreign node.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();

#endif

        /* Open a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.25.5.9 - Invalid send endpoint, invalid receive endpoint,
         * invalid request.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.25.5.10 - Invalid send endpoint, invalid receive endpoint,
         * invalid request, invalid mcapi_status.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, 0);


#ifdef MCAPI_FOREIGN_TEST

        /* Get a valid send endpoint. */
        send_endpoint =
            mcapi_encode_endpoint(FOREIGN_NODE_ID, Foreign_TX_Port);

        /* Create an invalid receive endpoint, invalid node. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* 1.25.6.1 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Create an invalid receive endpoint, invalid port. */
        receive_endpoint = mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, 1000);

        /* 1.25.6.2 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* Get valid foreign receive endpoint. */
        receive_endpoint =
            mcapi_encode_endpoint(MCAPI_FOREIGN_NODE, MCAPI_Foreign_RX_Port);

        /* Foreign receive node connects receive endpoint as packet. */

        /* 1.25.6.3 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Foreign receive node opens receive side of packet. */

        /* 1.25.6.4 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Foreign receive node closes receive side of packet. */


        /* Foreign receive node connects receive endpoint as scalar. */

        /* 1.25.6.5 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* Foreign receive node opens receive side of scalar channel. */

        /* 1.25.6.6 - Connect valid send endpoint, invalid receive endpoint. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();

        else
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Foreign receive node closes receive side of scalar channel. */

#endif

        /* Open a new send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Open a new receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.25.7.1 - Invalid request. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.25.7.2 - Invalid request, invalid mcapi_status. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, 0);


        /* Close send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.25.7.3 - Invalid send endpoint, invalid request, invalid mcapi_status. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, 0, 0);


        /* Open send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.25.8.1 - Invalid mcapi_status. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request, 0);


        /* Close send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.25.8.2 - Invalid send endpoint, invalid mcapi_status. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request, 0);


        /* Close receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.25.8.3 - Invalid send endpoint, invalid receive endpoint, invalid
         * mcapi_status.
         */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_open_sclchan_recv_i
*
*   DESCRIPTION
*
*      Tests mcapi_open_sclchan_recv_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_open_sclchan_recv_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_sclchan_recv_hndl_t   recv_handle;
    mcapi_sclchan_send_hndl_t   send_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.26.1.1 - Invalid receive handle. */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, &recv_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.26.1.2 - Invalid receive handle, invalid receive endpoint. */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, &recv_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.26.1.3 - 1.26.1.3  Invalid rx handle, invalid receive endpoint,
         * invalid request.
         */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.26.1.4 - Invalid rx handle, invalid receive endpoint,
         * invalid request, invalid status.
         */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, 0, 0);


        /* 1.26.2.1 - Invalid receive endpoint. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* 1.26.2.2 - Invalid receive endpoint, invalid request. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.26.2.3 - Invalid receive endpoint, invalid request, invalid
         * status.
         */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, 0, 0);


        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* 1.26.2.4 Valid rx handle, endpoint opened for packet tx */

        /* Open the endpoint for packet tx. */
        mcapi_open_sclchan_send_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Try to open as a receive endpoint. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for tx. */
        mcapi_sclchan_send_close_i(recv_handle, &request, &mcapi_status);


        /* 1.26.2.5 Valid rx handle, endpoint opened for packet tx */

        /* Open the endpoint as a tx packet. */
        mcapi_open_pktchan_send_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Try to open as a scalar receive endpoint. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for tx. */
        mcapi_packetchan_send_close_i(recv_handle, &request, &mcapi_status);


        /* 1.26.2.6 Valid rx handle, endpoint opened for packet rx */

        /* Open the endpoint as a rx packet. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Try to open as a scalar receive endpoint. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* 1.26.2.7 Valid rx handle, endpoint connected for packet rx */

        /* Open the send side of the packet. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Try to open as a scalar receive endpoint. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);


        /* 1.26.3.1 - Invalid request. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.26.3.2 - Invalid request, invalid status. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, 0, 0);


        /* 1.26.3.3 - Invalid receive handle, invalid request, invalid status. */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, 0, 0);


        /* 1.26.4.1 - Invalid status. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint, &recv_request, 0);


        /* 1.26.4.2 - Invalid receive handle, invalid status. */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, &recv_request, 0);


        /* Delete the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.26.4.3 - Invalid receive handle, invalid receive endpoint, invalid
         * status.
         */
        mcapi_open_sclchan_recv_i(0, receive_endpoint, &recv_request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_open_sclchan_send_i
*
*   DESCRIPTION
*
*      Tests mcapi_open_sclchan_send_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_open_sclchan_send_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   recv_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.27.1.1 - Invalid send handle. */
        mcapi_open_sclchan_send_i(0, send_endpoint, &send_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* 1.27.1.2 - Invalid send handle, invalid send endpoint. */
        mcapi_open_sclchan_send_i(0, send_endpoint, &send_request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.27.1.3 - Invalid send handle, invalid send endpoint,
         * invalid request.
         */
        mcapi_open_sclchan_send_i(0, send_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.27.1.4 - Invalid send handle, invalid send endpoint,
         * invalid request, invalid status.
         */
        mcapi_open_sclchan_send_i(0, send_endpoint, 0, 0);


        /* 1.27.2.1 - Invalid send endpoint. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_ENDP_INVALID)
            MCAPI_TEST_Error();


        /* 1.27.2.2 - Invalid send endpoint, invalid request. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.27.2.3 - Invalid send endpoint, invalid request, invalid
         * status.
         */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, 0, 0);


        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* 1.27.2.4 Valid tx handle, endpoint opened for scalar rx */

        /* Open the endpoint for scalar rx. */
        mcapi_open_sclchan_recv_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to open as a send endpoint. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for rx. */
        mcapi_sclchan_recv_close_i(send_handle, &request, &mcapi_status);


        /* 1.27.2.5 Valid tx handle, endpoint opened for packet rx */

        /* Open the endpoint as a rx packet. */
        mcapi_open_pktchan_recv_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to open as a send endpoint. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the endpoint for rx. */
        mcapi_packetchan_recv_close_i(send_handle, &request, &mcapi_status);


        /* 1.27.2.6 Valid tx handle, endpoint opened for packet tx */

        /* Open the endpoint as a tx packet. */
        mcapi_open_pktchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Try to open as a send endpoint. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();


        /* 1.27.2.7 Valid tx handle, endpoint connected for packet tx */

        /* Open the recv side of the packet. */
        mcapi_open_pktchan_recv_i(&recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Try to open as a send endpoint. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &request,
                                  &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_CONNECTED)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_packetchan_send_close_i(send_handle, &request, &mcapi_status);
        mcapi_packetchan_recv_close_i(recv_handle, &request, &mcapi_status);


        /* 1.27.3.1 - Invalid request. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.27.3.2 - Invalid send, invalid status. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, 0, 0);


        /* 1.27.3.3 - Invalid send handle, invalid request, invalid status. */
        mcapi_open_sclchan_send_i(0, send_endpoint, 0, 0);


        /* 1.27.4.1 - Invalid status. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request, 0);


        /* 1.27.4.2 - Invalid send handle, invalid status. */
        mcapi_open_sclchan_send_i(0, send_endpoint, &send_request, 0);


        /* Delete the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* 1.27.4.3 - Invalid send handle, invalid send endpoint, invalid
         * status.
         */
        mcapi_open_sclchan_send_i(0, send_endpoint, &send_request, 0);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_send_uint64
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_send_uint64 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_send_uint64(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint64_t              buffer = 200000;
    size_t                      size;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.28.1.1 - Invalid send endpoint. */
        mcapi_sclchan_send_uint64(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.28.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_sclchan_send_uint64(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        /* 1.28.1.3 - Invalid tx handle (rx side closed). */
        mcapi_sclchan_send_uint64(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.28.1.4 - Invalid tx handle (tx opened, rx not opened, no connection. */
        mcapi_sclchan_send_uint64(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.28.1.5 - Invalid tx handle (no connection) */
        mcapi_sclchan_send_uint64(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.28.1.6 - Packet tx handle. */
        mcapi_sclchan_send_uint64(pkt_send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.28.2.1 - Invalid status. */
        mcapi_sclchan_send_uint64(send_handle, buffer, 0);


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.28.2.2 - Invalid tx handle, invalid status. */
        mcapi_sclchan_send_uint64(send_handle, buffer, 0);

        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_send_uint32
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_send_uint32 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_send_uint32(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint32_t              buffer = 65535;
    size_t                      size;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.29.1.1 - Invalid send endpoint. */
        mcapi_sclchan_send_uint32(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.29.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_sclchan_send_uint32(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        /* 1.29.1.3 - Invalid tx handle (rx side closed). */
        mcapi_sclchan_send_uint32(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.29.1.4 - Invalid tx handle (tx opened, rx not opened, no connection. */
        mcapi_sclchan_send_uint32(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.29.1.5 - Invalid tx handle (no connection) */
        mcapi_sclchan_send_uint32(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.29.1.6 - Packet tx handle. */
        mcapi_sclchan_send_uint32(pkt_send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.29.2.1 - Invalid status. */
        mcapi_sclchan_send_uint32(send_handle, buffer, 0);


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.29.2.2 - Invalid tx handle, invalid status. */
        mcapi_sclchan_send_uint32(send_handle, buffer, 0);

        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_send_uint16
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_send_uint16 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_send_uint16(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint16_t              buffer = 16000;
    size_t                      size;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.30.1.1 - Invalid send endpoint. */
        mcapi_sclchan_send_uint16(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.30.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_sclchan_send_uint16(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        /* 1.30.1.3 - Invalid tx handle (rx side closed). */
        mcapi_sclchan_send_uint16(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.30.1.4 - Invalid tx handle (tx opened, rx not opened, no connection. */
        mcapi_sclchan_send_uint16(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.30.1.5 - Invalid tx handle (no connection) */
        mcapi_sclchan_send_uint16(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.30.1.6 - Packet tx handle. */
        mcapi_sclchan_send_uint16(pkt_send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.30.2.1 - Invalid status. */
        mcapi_sclchan_send_uint16(send_handle, buffer, 0);


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.30.2.2 - Invalid tx handle, invalid status. */
        mcapi_sclchan_send_uint16(send_handle, buffer, 0);

        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_send_uint8
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_send_uint8 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_send_uint8(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint8_t               buffer = 128;
    size_t                      size;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.31.1.1 - Invalid send endpoint. */
        mcapi_sclchan_send_uint8(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.31.1.2 - Invalid send endpoint, invalid receive endpoint. */
        mcapi_sclchan_send_uint8(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        /* 1.31.1.3 - Invalid tx handle (rx side closed). */
        mcapi_sclchan_send_uint8(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* 1.31.1.4 - Invalid tx handle (tx opened, rx not opened, no connection. */
        mcapi_sclchan_send_uint8(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* 1.31.1.5 - Invalid tx handle (no connection) */
        mcapi_sclchan_send_uint8(send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.31.1.6 - Packet tx handle. */
        mcapi_sclchan_send_uint8(pkt_send_handle, buffer, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send and receive side. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* 1.31.2.1 - Invalid status. */
        mcapi_sclchan_send_uint8(send_handle, buffer, 0);


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.31.2.2 - Invalid tx handle, invalid status. */
        mcapi_sclchan_send_uint8(send_handle, buffer, 0);

        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_recv_uint64
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_recv_uint64 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_recv_uint64(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint64_t              buffer;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.32.1.1 - Try to receive data on the closed handle. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();


        buffer = 0;

        /* 1.32.1.2 - Try to receive data on the closed endpoint, invalid status. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        /* Close the transmit side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        buffer = 0;

        /* 1.32.1.3 - TX side closed. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        buffer = 0;

        /* 1.32.1.4 - Connected, TX not open. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Send 32-bits of data. */
        mcapi_sclchan_send_uint32(send_handle, 100000, &mcapi_status);


        buffer = 0;

        /* 1.32.1.5 - 32-bit send, 64-bit receive. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 16-bits of data. */
        mcapi_sclchan_send_uint16(send_handle, 65530, &mcapi_status);

        buffer = 0;

        /* 1.32.1.6 - 16-bit send, 64-bit receive. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 8-bits of data. */
        mcapi_sclchan_send_uint8(send_handle, 128, &mcapi_status);

        buffer = 0;

        /* 1.32.1.7 - 8-bit send, 64-bit receive. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.32.1.8 - Packet RX handle. */
        buffer = mcapi_sclchan_recv_uint64(pkt_recv_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_TYPE) )
            MCAPI_TEST_Error();

        /* Close the packet connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.32.2.1 - Invalid status. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the rx handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.32.2.2 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.32.2.3 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint64(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the receive endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Close the send endpoint. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_recv_uint32
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_recv_uint32 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_recv_uint32(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint32_t              buffer;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.33.1.1 - Try to receive data on the closed handle. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();


        buffer = 0;

        /* 1.33.1.2 - Try to receive data on the closed endpoint, invalid status. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        /* Close the transmit side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        buffer = 0;

        /* 1.33.1.3 - TX side closed. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        buffer = 0;

        /* 1.33.1.4 - Connected, TX not open. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Send 64-bits of data. */
        mcapi_sclchan_send_uint64(send_handle, 1000000, &mcapi_status);

        buffer = 0;

        /* 1.33.1.5 - 64-bit send, 32-bit receive. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 16-bits of data. */
        mcapi_sclchan_send_uint16(send_handle, 65530, &mcapi_status);

        buffer = 0;

        /* 1.33.1.6 - 16-bit send, 32-bit receive. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 8-bits of data. */
        mcapi_sclchan_send_uint8(send_handle, 128, &mcapi_status);

        buffer = 0;

        /* 1.33.1.7 - 8-bit send, 32-bit receive. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.33.1.8 - Packet RX handle. */
        buffer = mcapi_sclchan_recv_uint32(pkt_recv_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_TYPE) )
            MCAPI_TEST_Error();

        /* Close the packet connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.33.2.1 - Invalid status. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        /* Close the rx handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.33.2.2 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.33.2.3 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint32(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_recv_uint16
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_recv_uint16 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_recv_uint16(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint16_t              buffer;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.34.1.1 - Try to receive data on the closed handle. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();


        buffer = 0;

        /* 1.34.1.2 - Try to receive data on the closed endpoint, invalid status. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        /* Close the transmit side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        buffer = 0;

        /* 1.34.1.3 - TX side closed. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        buffer = 0;

        /* 1.34.1.4 - Connected, TX not open. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Send 64-bits of data. */
        mcapi_sclchan_send_uint64(send_handle, 1000000, &mcapi_status);

        buffer = 0;

        /* 1.34.1.5 - 64-bit send, 16-bit receive. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 32-bits of data. */
        mcapi_sclchan_send_uint32(send_handle, 1000000, &mcapi_status);

        buffer = 0;

        /* 1.34.1.6 - 32-bit send, 16-bit receive. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 8-bits of data. */
        mcapi_sclchan_send_uint8(send_handle, 128, &mcapi_status);

        buffer = 0;

        /* 1.34.1.7 - 8-bit send, 16-bit receive. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.34.1.8 - Packet RX handle. */
        buffer = mcapi_sclchan_recv_uint16(pkt_recv_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_TYPE) )
            MCAPI_TEST_Error();

        /* Close the packet connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.34.2.1 - Invalid status. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the rx handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.34.2.2 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.34.2.3 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint16(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_recv_uint8
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_recv_uint8 input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_recv_uint8(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_uint8_t               buffer;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a send endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create a receive endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.35.1.1 - Try to receive data on the closed handle. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();


        buffer = 0;

        /* 1.35.1.2 - Try to receive data on the closed endpoint, invalid status. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        /* Close the transmit side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);


        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        MCAPID_Sleep(2000);

        buffer = 0;

        /* 1.35.1.3 - TX side closed. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        buffer = 0;

        /* 1.35.1.4 - Connected, TX not open. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Send 64-bits of data. */
        mcapi_sclchan_send_uint64(send_handle, 1000000, &mcapi_status);

        buffer = 0;

        /* 1.35.1.5 - 64-bit send, 8-bit receive. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 32-bits of data. */
        mcapi_sclchan_send_uint32(send_handle, 1000000, &mcapi_status);

        buffer = 0;

        /* 1.35.1.6 - 32-bit send, 8-bit receive. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();


        /* Send 16-bits of data. */
        mcapi_sclchan_send_uint8(send_handle, 200, &mcapi_status);

        buffer = 0;

        /* 1.35.1.7 - 16-bit send, 8-bit receive. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_GENERAL) )
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the send side of the packet channel. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        /* Open the receive side of the packet channel. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        buffer = 0;

        /* 1.35.1.8 - Packet RX handle. */
        buffer = mcapi_sclchan_recv_uint8(pkt_recv_handle, &mcapi_status);

        if ( (buffer != 0) || (mcapi_status != MCAPI_ERR_CHAN_TYPE) )
            MCAPI_TEST_Error();

        /* Close the packet connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Make a connection. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint, &connect_request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint, &recv_request,
                                  &mcapi_status);

        /* Open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint, &send_request,
                                  &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&send_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        buffer = 0;

        /* 1.35.2.1 - Invalid status. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        /* Close the rx handle. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.35.2.2 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        buffer = 0;

        /* 1.35.2.3 - Invalid status, invalid rx handle. */
        buffer = mcapi_sclchan_recv_uint8(receive_handle, 0);

        if (buffer != 0)
            MCAPI_TEST_Error();

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_available
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_available input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_available(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    size_t                      size;
    mcapi_uint_t                byte_count;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_sclchan_recv_hndl_t   receive_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);

        /* 1.36.1.1 - Invalid rx handle. */
        byte_count = mcapi_sclchan_available(receive_handle, &mcapi_status);

        if ( (byte_count != 0) || (mcapi_status != MCAPI_ERR_CHAN_INVALID) )
            MCAPI_TEST_Error();


        /* 1.36.1.2 - Invalid rx handle, invalid status */
        byte_count = mcapi_sclchan_available(receive_handle, 0);

        if (byte_count != 0)
            MCAPI_TEST_Error();


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);


        /* Connect the two endpoints as a packet. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.36.1.3 - Pass in a packet endpoint. */
        byte_count = mcapi_sclchan_available(pkt_recv_handle, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&receive_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        /* 1.36.1.5 - Connection not made yet. */
        byte_count = mcapi_sclchan_available(receive_handle, &mcapi_status);

        if (mcapi_status != MGC_MCAPI_ERR_NOT_CONNECTED)
            MCAPI_TEST_Error();


        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);

        /* 1.36.1.6 - Pass in a tx handle. */
        byte_count = mcapi_sclchan_available(send_handle, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();


        /* 1.36.2.1 - Invalid status. */
        byte_count = mcapi_sclchan_available(receive_handle, 0);


        /* Close the endpoints. */
        mcapi_sclchan_recv_close_i(receive_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Delete the endpoints. */
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_recv_close_i
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_recv_close_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_recv_close_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_sclchan_recv_hndl_t   recv_handle;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);

        /* 1.37.1.1 - Invalid rx handle. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.37.1.2 - tx handle. */
        mcapi_sclchan_recv_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the send and receive sides. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Open a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.37.1.3 - Use a packet receive handle. */
        mcapi_sclchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);


        /* 1.37.1.4 - Invalid rx handle, invalid request. */
        mcapi_sclchan_recv_close_i(recv_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.37.1.5 - Invalid rx handle, invalid request, invalid status. */
        mcapi_sclchan_recv_close_i(recv_handle, 0, 0);


        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.37.2.1 - Invalid request. */
        mcapi_sclchan_recv_close_i(recv_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.37.2.2 - Invalid request, invalid status. */
        mcapi_sclchan_recv_close_i(recv_handle, 0, 0);


        /* 1.37.3.1 - Invalid status. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, 0);


        /* Close the receive handle. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);

        /* 1.37.3.2 - Invalid status, invalid receive handle. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, 0);

        /* Close the connection. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* Delete the endpoints. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
        mcapi_delete_endpoint(send_endpoint, &mcapi_status);

        /* The delete operation should be successful. */
        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_sclchan_send_close_i
*
*   DESCRIPTION
*
*      Tests mcapi_sclchan_send_close_i input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_sclchan_send_close_i(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request, connect_request;
    mcapi_sclchan_recv_hndl_t   recv_handle;
    mcapi_sclchan_send_hndl_t   send_handle;
    mcapi_pktchan_recv_hndl_t   pkt_recv_handle;
    mcapi_pktchan_send_hndl_t   pkt_send_handle;
    size_t                      size;
    mcapi_request_t             recv_request, send_request;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Create another new endpoint. */
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);

        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }


        /* Close the send side. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.38.1.1 - Invalid tx handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the receive side. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.38.1.2 - rx handle. */
        mcapi_sclchan_send_close_i(recv_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_DIRECTION)
            MCAPI_TEST_Error();

        /* Close the send and receive sides. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* Open a packet connection. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_pktchan_send_i(&pkt_send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_pktchan_recv_i(&pkt_recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.38.1.3 - Use a packet send handle. */
        mcapi_sclchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_TYPE)
            MCAPI_TEST_Error();

        /* Close the connection. */
        mcapi_packetchan_recv_close_i(pkt_recv_handle, &request, &mcapi_status);
        mcapi_packetchan_send_close_i(pkt_send_handle, &request, &mcapi_status);

        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);

        /* Create a new endpoint. */
        send_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);
        receive_endpoint = mcapi_create_endpoint(MCAPI_PORT_ANY, &mcapi_status);



        /* 1.38.1.4 - Invalid tx handle, invalid request. */
        mcapi_sclchan_send_close_i(send_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_CHAN_INVALID)
            MCAPI_TEST_Error();


        /* 1.38.1.5 - Invalid tx handle, invalid request, invalid status. */
        mcapi_sclchan_send_close_i(send_handle, 0, 0);


        /* Connect the two endpoints. */
        mcapi_connect_sclchan_i(send_endpoint, receive_endpoint,
                                &connect_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&connect_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* Successfully open the send side. */
        mcapi_open_sclchan_send_i(&send_handle, send_endpoint,
                                  &send_request, &mcapi_status);

        /* Successfully open the receive side. */
        mcapi_open_sclchan_recv_i(&recv_handle, receive_endpoint,
                                  &recv_request, &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            mcapi_wait(&recv_request, &size, &mcapi_status, MCAPID_TIMEOUT);
        }

        else
        {
            MCAPI_TEST_Error();
        }

        /* 1.38.2.1 - Invalid request. */
        mcapi_sclchan_send_close_i(send_handle, 0, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_PARAMETER)
            MCAPI_TEST_Error();


        /* 1.38.2.2 - Invalid request, invalid status. */
        mcapi_sclchan_send_close_i(send_handle, 0, 0);


        /* 1.38.3.1 - Invalid status. */
        mcapi_sclchan_send_close_i(send_handle, &request, 0);


        /* Close the send handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, &mcapi_status);

        /* 1.38.3.2 - Invalid status, invalid receive handle. */
        mcapi_sclchan_send_close_i(send_handle, &request, 0);

        /* Close the connection. */
        mcapi_sclchan_recv_close_i(recv_handle, &request, &mcapi_status);


        mcapi_delete_endpoint(send_endpoint, &mcapi_status);
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);
    }
}


/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_test
*
*   DESCRIPTION
*
*      Tests mcapi_test input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_test(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_request_t             request;
    size_t                      size;
    mcapi_boolean_t             finished;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.39.1.1 - Invalid request. */
        finished = mcapi_test(0, &size, &mcapi_status);

        if ( (finished != MCAPI_FALSE) || (mcapi_status != MCAPI_ERR_REQUEST_INVALID) )
            MCAPI_TEST_Error();


        /* 1.39.1.2 - Invalid request, invalid size. */
        finished = mcapi_test(0, 0, &mcapi_status);

        if ( (finished != MCAPI_FALSE) || (mcapi_status != MCAPI_ERR_REQUEST_INVALID) )
            MCAPI_TEST_Error();


        /* 1.39.1.3 - Invalid request, invalid size, invalid status */
        finished = mcapi_test(0, 0, 0);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();


        /* 1.39.2.1 - Invalid size. */
        finished = mcapi_test(&request, 0, &mcapi_status);

        if ( (finished != MCAPI_FALSE) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.39.2.2 - Invalid size, invalid status. */
        finished = mcapi_test(&request, 0, 0);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();


        /* 1.39.3.1 - Invalid status. */
        finished = mcapi_test(&request, &size, 0);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();


        /* 1.39.3.2 - Invalid status, invalid request. */
        finished = mcapi_test(0, &size, 0);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_wait
*
*   DESCRIPTION
*
*      Tests mcapi_wait input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_wait(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_request_t             request;
    size_t                      size;
    mcapi_boolean_t             finished;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.40.1.1 - Invalid request. */
        finished = mcapi_wait(0, &size, &mcapi_status, MCAPID_TIMEOUT);

        if ( (finished != MCAPI_FALSE) || (mcapi_status != MCAPI_ERR_REQUEST_INVALID) )
            MCAPI_TEST_Error();


        /* 1.40.1.2 - Invalid request, invalid size. */
        finished = mcapi_wait(0, 0, &mcapi_status, MCAPID_TIMEOUT);

        if ( (finished != MCAPI_FALSE) || (mcapi_status != MCAPI_ERR_REQUEST_INVALID) )
            MCAPI_TEST_Error();


        /* 1.40.1.3 - Invalid request, invalid size, invalid status */
        finished = mcapi_wait(0, 0, 0, MCAPID_TIMEOUT);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();


        /* 1.40.2.1 - Invalid size. */
        finished = mcapi_wait(&request, 0, &mcapi_status, MCAPID_TIMEOUT);

        if ( (finished != MCAPI_FALSE) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.40.2.2 - Invalid size, invalid status. */
        finished = mcapi_wait(&request, 0, 0, MCAPID_TIMEOUT);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();


        /* 1.40.3.1 - Invalid status. */
        finished = mcapi_wait(&request, &size, 0, MCAPID_TIMEOUT);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();


        /* 1.40.3.2 - Invalid status, invalid request. */
        finished = mcapi_wait(0, &size, 0, MCAPID_TIMEOUT);

        if (finished != MCAPI_FALSE)
            MCAPI_TEST_Error();
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_cancel
*
*   DESCRIPTION
*
*      Tests mcapi_cancel input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_cancel(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_endpoint_t            send_endpoint, receive_endpoint;
    mcapi_request_t             request;
    size_t                      size;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.42.1.1 - NULL request. */
        mcapi_cancel(MCAPI_NULL, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_REQUEST_INVALID)
            MCAPI_TEST_Error();


        /* Make the call to get an endpoint that doesn't exist. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, 1000, &receive_endpoint, &request,
                             &mcapi_status);

        /* Cancel the call. */
        mcapi_cancel(&request, &mcapi_status);

        /* 1.42.1.2 - Invalid request (request already canceled) */
        mcapi_cancel(&request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_REQUEST_INVALID)
            MCAPI_TEST_Error();


        /* Make the call to get an endpoint that doesn't exist. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, 1000, &receive_endpoint, &request,
                             &mcapi_status);

        MCAPI_Obtain_Mutex(&MCAPI_TEST_Mutex);

        /* Cause the endpoint to be created. */
        MCAPI_TEST_Endpoint_Port = 1000;
        MCAPI_TEST_Send_Type = MCAPI_TEST_CREATE_ENDP;

        MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

        /* Wait for the endpoint to be created. */
        mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);

        /* 1.42.1.3 - Attempt to cancel the completed call. */
        mcapi_cancel(&request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_REQUEST_INVALID)
            MCAPI_TEST_Error();

        /* Delete the endpoint. */
        mcapi_delete_endpoint(receive_endpoint, &mcapi_status);


        /* Create a non-existent foreign endpoint. */
        send_endpoint = mcapi_encode_endpoint(MCAPI_Node_ID + 1, 1000);

        /* Make a call to connect two endpoints that don't exist. */
        mcapi_connect_pktchan_i(send_endpoint, receive_endpoint, &request,
                                &mcapi_status);

        if (mcapi_status == MCAPI_SUCCESS)
        {
            /* Wait for the connection to complete. */
            mcapi_wait(&request, &size, &mcapi_status, MCAPID_TIMEOUT);

            /* This should not have returned success. */
            MCAPI_TEST_Error();
        }

        /* Attempt to cancel a request that could not complete. */
        mcapi_cancel(&request, &mcapi_status);

        if (mcapi_status != MCAPI_ERR_REQUEST_INVALID)
            MCAPI_TEST_Error();


        /* 1.42.1.5 - Invalid request, invalid status. */
        mcapi_cancel(MCAPI_NULL, MCAPI_NULL);


        /* Make the call to get an endpoint that doesn't exist. */
        mcapi_get_endpoint_i(MCAPI_Node_ID, 1000, &receive_endpoint, &request,
                             &mcapi_status);

        /* 1.42.1.1 - Valid request, invalid status */
        mcapi_cancel(&request, 0);

        mcapi_cancel(&request, &mcapi_status);

        if (mcapi_status != MCAPI_SUCCESS)
            MCAPI_TEST_Error();
    }
}

/************************************************************************
*
*   FUNCTION
*
*      MCAPI_TEST_mcapi_wait_any
*
*   DESCRIPTION
*
*      Tests mcapi_wait_any input parameters.
*
*************************************************************************/
void MCAPI_TEST_mcapi_wait_any(int type)
{
    mcapi_status_t              mcapi_status;
    mcapi_request_t             *requests[15];
    size_t                      size;
    mcapi_int_t                 finished;

    /* Test with a successfully initialized node. */
    if (type == MCAPI_TEST_POST_INIT)
    {
        /* 1.41.1.1 - Invalid number. */
        finished = mcapi_wait_any(0, requests, &size, MCAPID_TIMEOUT,
                                  &mcapi_status);

        if ( (finished != 0) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.41.1.2 - Invalid number, invalid requests. */
        finished = mcapi_wait_any(0, 0, &size, MCAPID_TIMEOUT, &mcapi_status);

        if ( (finished != 0) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.41.1.3 - Invalid number, invalid requests, invalid size. */
        finished = mcapi_wait_any(0, 0, 0, MCAPID_TIMEOUT, &mcapi_status);

        if ( (finished != 0) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.41.1.4 - Invalid number, invalid requests, invalid size,
         * invalid status.
         */
        finished = mcapi_wait_any(0, 0, 0, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();


        /* 1.41.2.1 - Invalid requests. */
        finished = mcapi_wait_any(1, 0, &size, MCAPID_TIMEOUT, &mcapi_status);

        if ( (finished != 0) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.41.2.2 - Invalid requests, invalid size. */
        finished = mcapi_wait_any(1, 0, 0, MCAPID_TIMEOUT, &mcapi_status);

        if ( (finished != 0) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.41.2.3 - Invalid requests, invalid size, invalid status. */
        finished = mcapi_wait_any(1, 0, 0, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();


        /* 1.41.3.1 - Invalid size. */
        finished = mcapi_wait_any(1, requests, 0, MCAPID_TIMEOUT,
                                  &mcapi_status);

        if ( (finished != 0) || (mcapi_status != MCAPI_ERR_PARAMETER) )
            MCAPI_TEST_Error();


        /* 1.41.3.2 - Invalid size, invalid status. */
        finished = mcapi_wait_any(1, requests, 0, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();


        /* 1.41.3.3 - Invalid size, invalid status, invalid number. */
        finished = mcapi_wait_any(0, requests, 0, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();


        /* 1.41.4.1 - Invalid status. */
        finished = mcapi_wait_any(1, requests, &size, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();


        /* 1.41.4.2 - Invalid status, invalid size. */
        finished = mcapi_wait_any(0, requests, &size, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();


        /* 1.41.4.3 - Invalid status, invalid size, invalid requests. */
        finished = mcapi_wait_any(0, 0, &size, MCAPID_TIMEOUT, 0);

        if (finished != 0)
            MCAPI_TEST_Error();
    }
}

MCAPI_THREAD_ENTRY(MCAPI_TEST_Multithread_Wait)
{
    mcapi_status_t  mcapi_status;
    int             status;
    size_t          size;
    mcapi_boolean_t finished;

    for (;;)
    {
        status = MCAPI_Obtain_Mutex(&MCAPI_TEST_Wait_Mutex);

        if (status != 0)
            MCAPI_TEST_Error();

        status = -1;

        if (MCAPI_TEST_Wait_Request)
        {
            finished = mcapi_wait(MCAPI_TEST_Wait_Request, &size, &mcapi_status,
                                  MCAPI_TEST_Wait_Timeout);

            if ( (mcapi_status != MCAPI_TEST_Wait_Status) ||
                 (MCAPI_TEST_Wait_Finished != finished) )
                MCAPI_TEST_Error();

            MCAPI_TEST_Wait_Request = MCAPI_NULL;

            status = MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);
        }

        else if (MCAPI_TEST_Wait_Any_Request[0])
        {
            finished = mcapi_wait_any(MCAPI_TEST_Wait_Any_Count,
                                      MCAPI_TEST_Wait_Any_Request, &size,
                                      MCAPI_TEST_Wait_Timeout, &mcapi_status);

            if ( (mcapi_status != MCAPI_TEST_Wait_Status) ||
                 (MCAPI_TEST_Wait_Finished != finished) )
                MCAPI_TEST_Error();

            MCAPI_TEST_Wait_Any_Request[0] = MCAPI_NULL;

            status = MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);
        }

        else
        {
            status = MCAPI_Release_Mutex(&MCAPI_TEST_Wait_Mutex);
            MCAPID_Sleep(1000);
        }

        if (status != 0)
            MCAPI_TEST_Error();
    }
}

MCAPI_THREAD_ENTRY(MCAPI_TEST_Send_Data)
{
    char            buffer[128];
    mcapi_status_t  mcapi_status;
    int             status, send_type;
    size_t          size;
    char            *pkt_ptr;

    for (;;)
    {
        MCAPID_Sleep(1000);

        status = MCAPI_Obtain_Mutex(&MCAPI_TEST_Mutex);

        if (status != 0)
            MCAPI_TEST_Error();

        status = -1;

        send_type = MCAPI_TEST_Send_Type;

        /* Reset the send type. */
        MCAPI_TEST_Send_Type = MCAPI_TEST_NO_SEND;

        switch (send_type)
        {
            case MCAPI_TEST_CREATE_ENDP:

                status = MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

                /* Create the endpoint. */
                mcapi_create_endpoint(MCAPI_TEST_Endpoint_Port, &mcapi_status);

                break;

            case MCAPI_TEST_RX_MSG:

                status = MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

                /* Receive the data. */
                mcapi_msg_recv(MCAPI_Rx_Endpoint, buffer, 128, &size,
                               &mcapi_status);

                break;

            case MCAPI_TEST_RX_PKT:

                status = MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

                /* Receive the data. */
                mcapi_pktchan_recv(MCAPI_Rx_Pkt_Handle, (void**)&pkt_ptr, &size,
                                   &mcapi_status);

                break;

            case MCAPI_TEST_RX_SCLR:

                status = MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);

                /* Receive the data. */
                mcapi_sclchan_recv_uint8(MCAPI_Rx_Scl_Handle, &mcapi_status);

                break;

            default:

                status = MCAPI_Release_Mutex(&MCAPI_TEST_Mutex);
                break;

        }

        if (status != 0)
            MCAPI_TEST_Error();
    }
}

void MCAPI_TEST_Error(void)
{
    MCAPI_TEST_Errors ++;
    printf("!!!Error Count:         %u\r\n", MCAPI_TEST_Errors);
}

