/*
Copyright (c) 2008, The Multicore Association
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

(1) Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
 
(2) Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution. 

(3) Neither the name of the Multicore Association nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef MCAPI_H
#define MCAPI_H

#include <stddef.h>  /* for size_t */
#include <stdint.h> /*uint_t,etc.*/

#include <mcapi_datatypes.h>

#ifdef __GNUC__
#define MCAPI_DECL_ALIGNED __attribute__ ((aligned (32))) 
#else
#error "MCAPI_DECL_ALIGNED alignment macro currently only suports GNU compiler"
#endif

#define MCAPI_BUF_ALIGN 4096
#define MCAPI_VERSION "1.061Rel1"


/* useful functions not part of current MCA published API ... */
extern char* mcapi_display_status (mcapi_status_t status);
extern void mcapi_display_state (void* handle);
extern void mcapi_set_debug_level (int d); 

/* API */
extern void mcapi_initialize(
 	MCAPI_IN mcapi_node_t node_id, 
 	MCAPI_OUT mcapi_version_t* mcapi_version, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_finalize(
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint_t mcapi_get_node_id(
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_endpoint_t mcapi_create_endpoint(
 	MCAPI_IN mcapi_port_t port_id, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_get_endpoint_i(
 	MCAPI_IN mcapi_node_t node_id, 
 	MCAPI_IN mcapi_port_t port_id, 
 	MCAPI_OUT mcapi_endpoint_t* endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_endpoint_t mcapi_get_endpoint(
 	MCAPI_IN mcapi_node_t node_id, 
 	MCAPI_IN mcapi_port_t port_id, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_delete_endpoint(
 	MCAPI_IN mcapi_endpoint_t endpoint, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_get_endpoint_attribute(
 	MCAPI_IN mcapi_endpoint_t endpoint, 
 	MCAPI_IN mcapi_uint_t attribute_num, 
 	MCAPI_OUT void* attribute, 
 	MCAPI_IN size_t attribute_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_set_endpoint_attribute(
 	MCAPI_IN mcapi_endpoint_t endpoint, 
 	MCAPI_IN mcapi_uint_t attribute_num, 
 	MCAPI_IN const void* attribute, 
 	MCAPI_IN size_t attribute_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_msg_send_i(
 	MCAPI_IN mcapi_endpoint_t send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_IN mcapi_priority_t priority, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_msg_send(
 	MCAPI_IN mcapi_endpoint_t  send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_IN mcapi_priority_t priority, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_msg_recv_i(
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint,  
 	MCAPI_OUT void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_msg_recv(
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint,  
 	MCAPI_OUT void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_OUT size_t* received_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint_t mcapi_msg_available(
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_connect_pktchan_i(
 	MCAPI_IN mcapi_endpoint_t  send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_open_pktchan_recv_i(
 	MCAPI_OUT mcapi_pktchan_recv_hndl_t* recv_handle, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 ); 

extern void mcapi_open_pktchan_send_i(
 	MCAPI_OUT mcapi_pktchan_send_hndl_t* send_handle, 
 	MCAPI_IN mcapi_endpoint_t  send_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_send_i(
 	MCAPI_IN mcapi_pktchan_send_hndl_t send_handle, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t size, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_send(
 	MCAPI_IN mcapi_pktchan_send_hndl_t send_handle, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_recv_i(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle,  
 	MCAPI_OUT void** buffer, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_recv(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT void** buffer, 
 	MCAPI_OUT size_t* received_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint_t mcapi_pktchan_available(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_free(
 	MCAPI_IN void* buffer, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_recv_close_i(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_pktchan_send_close_i(
 	MCAPI_IN mcapi_pktchan_send_hndl_t send_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void  mcapi_connect_sclchan_i(
 	MCAPI_IN mcapi_endpoint_t send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_open_sclchan_recv_i(
 	MCAPI_OUT mcapi_sclchan_recv_hndl_t* receive_handle, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 ); 

extern void mcapi_open_sclchan_send_i(
 	MCAPI_OUT mcapi_sclchan_send_hndl_t* send_handle, 
 	MCAPI_IN mcapi_endpoint_t send_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_sclchan_send_uint64(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint64_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_sclchan_send_uint32(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint32_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_sclchan_send_uint16(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint16_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_sclchan_send_uint8(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint8_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint64_t mcapi_sclchan_recv_uint64(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint32_t mcapi_sclchan_recv_uint32(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint16_t mcapi_sclchan_recv_uint16(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint8_t mcapi_sclchan_recv_uint8(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_uint_t mcapi_sclchan_available (
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_sclchan_recv_close_i(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern void mcapi_sclchan_send_close_i(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_boolean_t mcapi_test(
 	MCAPI_IN mcapi_request_t* request, 
 	MCAPI_OUT size_t* size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

extern mcapi_boolean_t mcapi_wait(
 	MCAPI_IN mcapi_request_t* request, 
 	MCAPI_OUT size_t* size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status, 
 	MCAPI_IN mcapi_timeout_t timeout
 );

extern mcapi_int_t mcapi_wait_any(
 	MCAPI_IN size_t number, 
 	MCAPI_IN mcapi_request_t** requests, 
 	MCAPI_OUT size_t* size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status, 
 	MCAPI_IN mcapi_timeout_t timeout
 );

extern void mcapi_cancel(
 	MCAPI_IN mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status
 );

#endif
