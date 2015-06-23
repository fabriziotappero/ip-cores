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

/* Check to see if this file has been included already.  */
#ifndef  _MCAPID_MGMT_SVC_H_
#define  _MCAPID_MGMT_SVC_H_

#include <mcapi.h>
#include "support_suite/mcapid_support.h"

/* Management service macros. */
#define MCAPID_MGMT_PKT_LEN             24

/* Management service packet offsets. */
#define MCAPID_MGMT_TYPE_OFFSET         0
#define MCAPID_MGMT_FOREIGN_PORT_OFFSET 4
#define MCAPID_MGMT_LOCAL_ENDP_OFFSET   8
#define MCAPID_MGMT_PAUSE_OFFSET        12
#define MCAPID_MGMT_STATUS_OFFSET       16
#define MCAPID_MGMT_PRIO_OFFSET         20

/* Management request types. */
#define MCAPID_MGMT_CREATE_ENDP         0
#define MCAPID_MGMT_DELETE_ENDP         1
#define MCAPID_MGMT_TX_BLCK_MSG         2
#define MCAPID_MGMT_TX_NONBLCK_MSG      3
#define MCAPID_MGMT_OPEN_TX_SIDE_PKT    4
#define MCAPID_MGMT_OPEN_RX_SIDE_PKT    5
#define MCAPID_MGMT_CLOSE_TX_SIDE_PKT   6
#define MCAPID_MGMT_CLOSE_RX_SIDE_PKT   7
#define MCAPID_TX_PKT                   8
#define MCAPID_RX_PKT                   9
#define MCAPID_MGMT_OPEN_TX_SIDE_SCL    10
#define MCAPID_MGMT_OPEN_RX_SIDE_SCL    11
#define MCAPID_MGMT_CLOSE_TX_SIDE_SCL   12
#define MCAPID_MGMT_CLOSE_RX_SIDE_SCL   13
#define MCAPID_RX_64_BIT_SCL            14
#define MCAPID_RX_32_BIT_SCL            15
#define MCAPID_RX_16_BIT_SCL            16
#define MCAPID_RX_8_BIT_SCL             17
#define MCAPID_TX_64_BIT_SCL            18
#define MCAPID_TX_32_BIT_SCL            19
#define MCAPID_TX_16_BIT_SCL            20
#define MCAPID_TX_8_BIT_SCL             21
#define MCAPID_NO_OP                    22
#define MCAPID_CANCEL_REQUEST           23
#define MCAPID_WAIT_REQUEST             24

/* Dummy values used for testing. */
#define MCAPID_8BIT_SCALAR      255
#define MCAPID_16BIT_SCALAR     65535
#define MCAPID_32BIT_SCALAR     2000000000
#define MCAPID_64BIT_SCALAR     2000000000

/* Message transmission macros. */
#define MCAPID_MSG_LEN                  512

mcapi_status_t MCAPID_TX_Mgmt_Message(MCAPID_STRUCT *mcapi_struct,
                                      mcapi_uint32_t type,
                                      mcapi_port_t foreign_port,
                                      mcapi_endpoint_t local_endp,
                                      mcapi_uint32_t pause,
                                      mcapi_uint32_t priority);
mcapi_status_t MCAPID_RX_Mgmt_Response(MCAPID_STRUCT *);
MCAPI_THREAD_ENTRY(MCAPID_Mgmt_Service);

#endif /* _MCAPID_MGMT_SVC_H_ */
