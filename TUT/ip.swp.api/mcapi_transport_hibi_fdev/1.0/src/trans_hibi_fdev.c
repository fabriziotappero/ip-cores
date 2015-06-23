// **************************************************************************
// File             : trans_hibi_fdev.c
// Author           : matilail
// Date             : 10.04.2013
// Decription       : MCAPI transport layer implementation for NIOS II
//					  With hibi_pe_dma file device
//                    (modified from The Multicore Association example
//                    shared memory implementation)
// **************************************************************************



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







#include <string.h> /* for memcpy */
#include <assert.h> /* for assertions */
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <stddef.h>  /* for size_t */
#include "includes.h"

#include "mcapi_trans.h" /* the transport API */
#include "trans_hibi_fdev.h"

#include <hibi_pe_dma_defines.h>

#include "hibi_mappings.h"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   Constants and defines                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
#define MAGIC_NUM 0xdeadcafe
#define MSG_HEADER 1
#define MSG_PORT 0




//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   Function prototypes (private)                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////   


mcapi_boolean_t mcapi_trans_decode_handle_internal (uint32_t handle, uint16_t *node_index,
                                           uint16_t *endpoint_index);

uint32_t mcapi_trans_encode_handle_internal (uint16_t node_index,uint16_t endpoint_index);

void mcapi_trans_signal_handler ( int sig );

mcapi_boolean_t mcapi_trans_add_node (mcapi_uint_t node_num);

mcapi_boolean_t mcapi_trans_send_internal (uint16_t sn,uint16_t se, uint16_t rn, uint16_t re, 
                                  char* buffer, size_t buffer_size,mcapi_boolean_t blocking,uint64_t scalar);

mcapi_boolean_t mcapi_trans_recv_internal (uint16_t rn, uint16_t re, void** buffer, size_t buffer_size, 
                                  size_t* received_size,mcapi_boolean_t blocking,uint64_t* scalar);

void mcapi_trans_recv_internal_ (uint16_t rn, uint16_t re, void** buffer, size_t buffer_size,
                                size_t* received_size,int qindex,uint64_t* scalar);

mcapi_boolean_t mcapi_trans_get_endpoint_internal (mcapi_endpoint_t *e, mcapi_uint_t node_num, 
                                                   mcapi_uint_t port_num);

void mcapi_trans_open_channel_internal (uint16_t n, uint16_t e);

void mcapi_trans_close_channel_internal (uint16_t n, uint16_t e);

void mcapi_trans_connect_channel_internal (mcapi_endpoint_t send_endpoint, mcapi_endpoint_t receive_endpoint,
                                  channel_type type); 
void setup_request_internal (mcapi_endpoint_t* endpoint,mcapi_request_t* request,mcapi_status_t* mcapi_status,
                  mcapi_boolean_t completed, size_t size,void** buffer,mcapi_request_type type);

void check_receive_request (mcapi_request_t *request);

void cancel_receive_request (mcapi_request_t *request);

void check_get_endpt_request (mcapi_request_t *request);

void check_open_request (mcapi_request_t *request);

int get_private_data_index ();

mcapi_boolean_t mcapi_trans_get_node_index(mcapi_uint_t n);

void mcapi_trans_display_state_internal (void* handle);

/* queue management */
void print_queue (queue q);

int mcapi_trans_pop_queue (queue *q);

int mcapi_trans_push_queue (queue *q);

mcapi_boolean_t mcapi_trans_empty_queue (queue q); 

mcapi_boolean_t mcapi_trans_full_queue (queue q);

void mcapi_trans_compact_queue (queue* q);

mcapi_boolean_t mcapi_trans_create_endpoint_(mcapi_endpoint_t* ep, mcapi_uint_t node_num, mcapi_uint_t port_num,
                                             mcapi_boolean_t anonymous);

void transport_sm_yield_internal();



void mcapi_trans_initialize_database();

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   Data                                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

/* Database for store endpoint and channel information */
mcapi_database c_db_impl;
mcapi_database* c_db = &c_db_impl;

/* the debug level */
int mcapi_debug = 0;

/* global my node id number */
mcapi_uint_t my_node_id = 255;

int cfg_fdev = 0;
//int cpu0_dev;

typedef struct {
  mcapi_endpoint_t recv_ep;
  int pkt_fdev;
} pkt_chan;

typedef struct {
  mcapi_endpoint_t recv_ep;
  int scl_fdev;
} scl_chan;



pkt_chan pkt_channels[MAX_CHANNELS];
scl_chan scl_channels[MAX_CHANNELS];



int scl_chan_idx, pkt_chan_idx  = 0;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   mcapi_trans API                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
/***************************************************************************
  NAME: mcapi_trans_get_node_num
  DESCRIPTION: gets the node_num (not the transport's node index!)
  PARAMETERS: node_num: the node_num pointer to be filled in
  RETURN VALUE: boolean indicating success (the node num was found) or failure 
   (couldn't find the node num).
***************************************************************************/
mcapi_boolean_t mcapi_trans_get_node_num(mcapi_uint_t* node) 
{
  //int i;
  
  /* the database does not need to be locked, but it's okay if it is */
  /* The database is locked whenever d[i].pid is set.  Here, we're just
     reading it. */

  //i = get_private_data_index();


  //if (d[i].pid == 0) {
  // return MCAPI_FALSE;
  //} else {
  // *node = d[i].node_num;
  //}
  *node = my_node_id; //LM
  return MCAPI_TRUE;
}


/***************************************************************************
  NAME: mcapi_trans_initialize    OK
  DESCRIPTION: initializes the transport layer
  PARAMETERS: node_num: the node number
  RETURN VALUE: boolean: success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_initialize(mcapi_uint_t node_num)
{

	mcapi_boolean_t rc = MCAPI_TRUE;
  
	mcapi_trans_initialize_database();
  
	//rc = mcapi_trans_initialize_();
	if (rc) {
		/* add the node */
		rc = mcapi_trans_add_node(node_num);
	}
 

	my_node_id = node_num;
	
	// open file device for receiving channel configurations
	cfg_fdev = open(dev_names[my_node_id], O_RDWR, 0x700);
	ioctl(cfg_fdev,SET_HIBI_RX_ADDR, (void*) (hibiEndAddresses[my_node_id] ));
	ioctl(cfg_fdev,SET_HIBI_RX_PACKETS,(void*) 4);
	ioctl(cfg_fdev,SET_HIBI_RX_BLOCKING,(void*) HIBI_READ_BLOCKING_MODE);

	//create task to poll this
	
	
	//printf("opening devices \n");
	/*for(i = 0; i < FDEV_COUNT ; i++)
	{
		fdevs[i] = open(dev_names[i], O_RDWR, 0x700);
		if (fdevs[i] == -1) rc = MCAPI_FALSE;

	}
*/
  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_initialize_database
  DESCRIPTION: Initializes the global mcapi_database structure. Does not
               initialize buffer contents, but other variables are
               initialized.
  PARAMETERS: -
  RETURN VALUE: -
***************************************************************************/
/**
 * NOTICE: The mcapi_database can be *huge* depending on the defines in
 * mcapi_config.h. If the processor's data memory is too small for the
 * database, this function *will* overwrite heap, stack and/or other
 * variables. You have been warned.
 */
void mcapi_trans_initialize_database() {

  /* initialize the whole mcapi_database */
  int i = 0;
  c_db->num_nodes = 0;
  for (i = 0; i < MAX_NODES; i++) {
      int j = 0;
      node_entry* node = &(c_db->nodes[i]);
      node->node_num = 0;
      node->finalized = MCAPI_FALSE; /* TODO: is this the correct value? */
      node->valid = MCAPI_FALSE;
      node->node_d.num_endpoints = 0;
      for (j = 0; j < MAX_ENDPOINTS; j++) {
          int k = 0;
          endpoint_entry* end = &(node->node_d.endpoints[j]);
          end->port_num = 0;
          end->valid = MCAPI_FALSE;
          end->anonymous = MCAPI_FALSE;
          end->open = MCAPI_FALSE;
          end->connected = MCAPI_FALSE;
          end->num_attributes = 0;
          for (k = 0; k < MAX_ATTRIBUTES; k++) {
              attribute_entry* attr = &(end->attributes[k]);
              attr->valid = MCAPI_FALSE;
              attr->attribute_num = 0;
              attr->bytes = 0;
              attr->attribute_d = NULL;
          }
          queue* epQueue = &(end->recv_queue);
          epQueue->send_endpt = 0;
          epQueue->recv_endpt = 0;
          epQueue->channel_type = 0;
          epQueue->num_elements = 0;
          epQueue->head = 0;
          epQueue->tail = 0;        
          for (k = 0; k < MAX_QUEUE_ENTRIES; k++) {
              buffer_descriptor* bufferDesc = &(epQueue->elements[k]);
              bufferDesc->request = 0;
              bufferDesc->b = 0;
              bufferDesc->invalid = MCAPI_FALSE;
          }
      }
  }
  for (i = 0; i < MAX_BUFFERS; i++) {
      buffer_entry* buffer = &(c_db->buffers[i]);
      buffer->magic_num = 0;
      buffer->size = 0;
      buffer->in_use = MCAPI_FALSE;
#ifndef __TCE__
      buffer->scalar = 0;
#else
      buffer->scalar.hi = 0;
      buffer->scalar.lo = 0;
#endif
  }
}

/***************************************************************************
  NAME:mcapi_trans_finalize TODO: file_dev
  DESCRIPTION: cleans up the semaphore and shared memory resources.
  PARAMETERS: none
  RETURN VALUE: boolean: success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_finalize () 
{
	int i = 0;

	// close file devices
	for(i = 0; i < FDEV_COUNT; i++)
	{
		close(fdevs[i]);
	}


	return MCAPI_TRUE;
}



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   mcapi_trans API: error checking routines               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
/***************************************************************************
  NAME: mcapi_trans_channel_type OK
  DESCRIPTION: Given an endpoint, returns the type of channel (if any)
   associated with it.
  PARAMETERS: endpoint: the endpoint to be checked
  RETURN VALUE: the type of the channel (pkt,scalar or none)
***************************************************************************/
channel_type mcapi_trans_channel_type (mcapi_endpoint_t endpoint)
 {
  uint16_t n,e;
  int rc;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  //mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  rc = c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type;
 
  /* unlock the database */
  //mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_send_endpoint OK
  DESCRIPTION:checks if the given endpoint is a send endpoint
  PARAMETERS: endpoint: the endpoint to be checked
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_send_endpoint (mcapi_endpoint_t endpoint) 
{
  uint16_t n,e;
  int rc = MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  if ((c_db->nodes[n].node_d.endpoints[e].connected) &&
      (c_db->nodes[n].node_d.endpoints[e].recv_queue.recv_endpt == endpoint)) {
   /* this endpoint has already been marked as a receive endpoint */
    mcapi_dprintf(2," mcapi_trans_send_endpoint ERROR: this endpoint (%x) has already been connected as a receive endpoint\n",
                  endpoint); 
    rc = MCAPI_FALSE;
  } 
  
  /* unlock the database */
  //mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_recv_endpoint OK
  DESCRIPTION:checks if the given endpoint can be or is already a receive endpoint 
  PARAMETERS: endpoint: the endpoint to be checked
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_recv_endpoint (mcapi_endpoint_t endpoint) 
{
  uint16_t n,e;
  int rc = MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  //mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  if ((c_db->nodes[n].node_d.endpoints[e].connected) &&
      (c_db->nodes[n].node_d.endpoints[e].recv_queue.send_endpt == endpoint)) {
   /* this endpoint has already been marked as a send endpoint */ 
    mcapi_dprintf(2," mcapi_trans_recv_endpoint ERROR: this endpoint (%x) has already been connected as a send endpoint\n",
                  endpoint); 
    rc = MCAPI_FALSE;
  }
  
  /* unlock the database */
  //mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_valid_port OK
  DESCRIPTION:checks if the given port_num is a valid port_num for this system
  PARAMETERS: port_num: the port num to be checked
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_port(mcapi_uint_t port_num)
{
  return MCAPI_TRUE;
}

/***************************************************************************
  NAME:mcapi_trans_valid_node   OK
  DESCRIPTION: checks if the given node_num is a valid node_num for this system
  PARAMETERS: node_num: the node num to be checked
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_node(mcapi_uint_t node_num)
{
  return MCAPI_TRUE;
}
   
/***************************************************************************
  NAME: mcapi_trans_valid_endpoint  OK
  DESCRIPTION: checks if the given endpoint handle refers to a valid endpoint
  PARAMETERS: endpoint
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_endpoint (mcapi_endpoint_t endpoint)
{
  uint16_t n,e;
  int rc = MCAPI_FALSE;
  
  /* lock the database */
  //  mcapi_trans_access_database_pre();

  if (mcapi_trans_decode_handle_internal(endpoint,&n,&e)) {
    rc = c_db->nodes[n].node_d.endpoints[e].valid;
  }

  mcapi_dprintf(3,"mcapi_trans_valid_endpoint endpoint=0x%lx (database indices: n=%d,e=%d) rc=%d\n",endpoint,n,e,rc);

  /* unlock the database */
  //  mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_endpoint_exists OK
  DESCRIPTION: checks if an endpoint has been created for this port id
  PARAMETERS: port id
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_endpoint_exists (uint32_t port_num)
{
  uint32_t n,i,node_num;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  if (port_num == MCAPI_PORT_ANY) {
    return rc;
  }

  /* lock the database */
  //mcapi_trans_access_database_pre();
  
  rv = mcapi_trans_get_node_num(&node_num);
  //assert(rv);
  n = mcapi_trans_get_node_index(node_num);

  /* Note: we can't just iterate for i < num_endpoints because endpoints can
     be deleted which would fragment the endpoints array. */
  for (i = 0; i < MAX_ENDPOINTS; i++) {
    if (c_db->nodes[n].node_d.endpoints[i].valid && 
        c_db->nodes[n].node_d.endpoints[i].port_num == port_num) {
      rc = MCAPI_TRUE;
      break;
    }
  }  
  
  /* unlock the database */
  //mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_valid_endpoints OK
  DESCRIPTION: checks if the given endpoint handles refer to valid endpoints
  PARAMETERS: endpoint1, endpoint2
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_endpoints (mcapi_endpoint_t endpoint1, 
                                             mcapi_endpoint_t endpoint2)
{
  uint16_t n1,e1;
  uint16_t n2,e2;
  mcapi_boolean_t rc = MCAPI_FALSE;
  
  /* lock the database */
  //mcapi_trans_access_database_pre();

  // decode_internal already tests for validity.
  if (mcapi_trans_decode_handle_internal(endpoint1,&n1,&e1) && 
      mcapi_trans_decode_handle_internal(endpoint2,&n2,&e2)) {
    rc = MCAPI_TRUE;
  }
    
  /* unlock the database */
  //  mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_pktchan_recv_isopen  OK
  DESCRIPTION:checks if the channel is open for a given handle 
  PARAMETERS: receive_handle
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_pktchan_recv_isopen (mcapi_pktchan_recv_hndl_t receive_handle)
 {
  uint16_t n,e;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  //  mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(receive_handle,&n,&e);
  //assert(rv);
  rc = (c_db->nodes[n].node_d.endpoints[e].open);
  
    /* unlock the database */
  // mcapi_trans_access_database_post();
  
  return rc;
}


/***************************************************************************
  NAME:mcapi_trans_pktchan_send_isopen OK
  DESCRIPTION:checks if the channel is open for a given handle 
  PARAMETERS: send_handle
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_pktchan_send_isopen (mcapi_pktchan_send_hndl_t send_handle)
 {
  uint16_t n,e;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  //mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(send_handle,&n,&e);
  //assert(rv);
  rc =  (c_db->nodes[n].node_d.endpoints[e].open);
  
  /* unlock the database */
  //mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_sclchan_recv_isopen OK
  DESCRIPTION:checks if the channel is open for a given handle 
  PARAMETERS: receive_handle
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_sclchan_recv_isopen (mcapi_sclchan_recv_hndl_t receive_handle)
 {
  uint16_t n,e;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  //mcapi_trans_access_database_pre();
  
  rv = mcapi_trans_decode_handle_internal(receive_handle,&n,&e);
  //assert(rv);
  rc = (c_db->nodes[n].node_d.endpoints[e].open);
  
  /* unlock the database */
  //mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_sclchan_send_isopen OK
  DESCRIPTION:checks if the channel is open for a given handle 
  PARAMETERS: send_handle
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_sclchan_send_isopen (mcapi_sclchan_send_hndl_t send_handle)
 {
  uint16_t n,e;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(send_handle,&n,&e);
  //assert(rv);
  rc = (c_db->nodes[n].node_d.endpoints[e].open);
  
    /* unlock the database */
  // mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_endpoint_channel_isopen  OK
  DESCRIPTION:checks if a channel is open for a given endpoint 
  PARAMETERS: endpoint
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_endpoint_channel_isopen (mcapi_endpoint_t endpoint)
{
  uint16_t n,e;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  rc =  (c_db->nodes[n].node_d.endpoints[e].open);

  /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_endpoint_isowner  OK
  DESCRIPTION:checks if the given endpoint is owned by the calling node
  PARAMETERS: endpoint
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_endpoint_isowner (mcapi_endpoint_t endpoint)
{
  uint16_t n,e;
  mcapi_uint_t node_num;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  rv = mcapi_trans_get_node_num(&node_num);
  //assert(rv);

  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  rc = ((c_db->nodes[n].node_d.endpoints[e].valid) && 
          (c_db->nodes[n].node_num == node_num));
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_channel_connected   OK
  DESCRIPTION:checks if the given endpoint channel is connected 
  PARAMETERS: endpoint
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_channel_connected (mcapi_endpoint_t endpoint)
{
   uint16_t n,e;
   int rc = MCAPI_FALSE;
   mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

   rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  rc = ((c_db->nodes[n].node_d.endpoints[e].valid) && 
        (c_db->nodes[n].node_d.endpoints[e].connected));
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_compatible_endpoint_attributes OK  
  DESCRIPTION:checks if the given endpoints have compatible attributes
  PARAMETERS: send_endpoint,recv_endpoint 
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_compatible_endpoint_attributes (mcapi_endpoint_t send_endpoint, 
                                                             mcapi_endpoint_t recv_endpoint)
{ 
  /* FIXME: (errata A3) currently un-implemented */
  return MCAPI_TRUE;
}

/***************************************************************************
  NAME:mcapi_trans_valid_pktchan_send_handle Ok
  DESCRIPTION:checks if the given pkt channel send handle is valid
  PARAMETERS: handle
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_pktchan_send_handle( mcapi_pktchan_send_hndl_t handle)
 {
  uint16_t n,e;
  channel_type type;
  
  int rc = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  type =MCAPI_PKT_CHAN;
  if (mcapi_trans_decode_handle_internal(handle,&n,&e)) {
    if (c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type == type) {
      rc = MCAPI_TRUE;
    } else {
      mcapi_dprintf(2," mcapi_trans_valid_pktchan_send_handle node=%d,port=%d returning false channel_type != MCAPI_PKT_CHAN\n",
                    c_db->nodes[n].node_num,c_db->nodes[n].node_d.endpoints[e].port_num);
    }
  }
  rc = MCAPI_TRUE;
  /* unlock the database */
  // mcapi_trans_access_database_post();
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_valid_pktchan_recv_handle OK
  DESCRIPTION:checks if the given pkt channel recv handle is valid 
  PARAMETERS: handle
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_pktchan_recv_handle( mcapi_pktchan_recv_hndl_t handle)
{
  uint16_t n,e;
  channel_type type;
  int rc = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  type = MCAPI_PKT_CHAN;
  if (mcapi_trans_decode_handle_internal(handle,&n,&e)) {
    if (c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type == type) {
      rc = MCAPI_TRUE;
    } else {
      mcapi_dprintf(2," mcapi_trans_valid_pktchan_recv_handle node=%d,port=%d returning false channel_type != MCAPI_PKT_CHAN\n",
                    c_db->nodes[n].node_num,c_db->nodes[n].node_d.endpoints[e].port_num);
    }
  }
  rc = MCAPI_TRUE;
  /* unlock the database */
  // mcapi_trans_access_database_post();
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_valid_sclchan_send_handle OK
  DESCRIPTION: checks if the given scalar channel send handle is valid 
  PARAMETERS: handle
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_sclchan_send_handle( mcapi_sclchan_send_hndl_t handle)
{
  uint16_t n,e;
  channel_type type;
  int rc = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  type = MCAPI_SCL_CHAN;
  if (mcapi_trans_decode_handle_internal(handle,&n,&e)) {
    if (c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type == type) { 
      rc = MCAPI_TRUE;
    } else {
      mcapi_dprintf(2," mcapi_trans_valid_sclchan_send_handle node=%d,port=%d returning false channel_type != MCAPI_SCL_CHAN\n",
                    c_db->nodes[n].node_num,c_db->nodes[n].node_d.endpoints[e].port_num);
    }
  }
    
  /* unlock the database */
  // mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_valid_sclchan_recv_handle OK
  DESCRIPTION:checks if the given scalar channel recv handle is valid 
  PARAMETERS: 
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_sclchan_recv_handle( mcapi_sclchan_recv_hndl_t handle)
{
  uint16_t n,e;
  channel_type type;

  int rc = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  type= MCAPI_SCL_CHAN;
  if (mcapi_trans_decode_handle_internal(handle,&n,&e)) {
    if (c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type == type) {
      rc = MCAPI_TRUE;
    } else {
      mcapi_dprintf(2," mcapi_trans_valid_sclchan_recv_handle node=%d,port=%d returning false channel_type != MCAPI_SCL_CHAN\n",
                    c_db->nodes[n].node_num,c_db->nodes[n].node_d.endpoints[e].port_num);
    }
  }
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_initialized OK
  DESCRIPTION: checks if the given node_id has called initialize
  PARAMETERS: node_id
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_initialized (mcapi_node_t node_id)
{  
  //int i;
  mcapi_boolean_t rc = MCAPI_FALSE;

  /* if (mcapi_trans_initialize()) { */
/*     /\* lock the database *\/ */
/*     // mcapi_trans_access_database_pre_nocheck(); */
    
/*     for (i = 0; i < MAX_NODES; i++) { */
/*       if ((c_db->nodes[i].valid) && (c_db->nodes[i].node_num == node_id)) */
/*         rc = MCAPI_TRUE; */
/*         break; */
/*     } */

/*     /\* unlock the database *\/ */
/*     // mcapi_trans_access_database_post_nocheck(); */
/*   } */

  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_num_endpoints OK
  DESCRIPTION: returns the current number of endpoints for the calling node
  PARAMETERS:  none
  RETURN VALUE: num_endpoints
***************************************************************************/
mcapi_uint32_t mcapi_trans_num_endpoints()
{
  int rc = 0;
  uint32_t node_num,node_index;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_get_node_num(&node_num);
  //assert(rv);

  node_index = mcapi_trans_get_node_index(node_num);

  rc = c_db->nodes[node_index].node_d.num_endpoints;
  /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_valid_priority OK
  DESCRIPTION:checks if the given priority level is valid
  PARAMETERS: priority
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_valid_priority(mcapi_priority_t priority)
{
  return ((priority >=0) && (priority <= MCAPI_MAX_PRIORITY));
}

/***************************************************************************
  NAME:mcapi_trans_connected OK
  DESCRIPTION: checks if the given endpoint is connected
  PARAMETERS: endpoint
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_connected(mcapi_endpoint_t endpoint)
{
  mcapi_boolean_t rc = MCAPI_FALSE;
  uint16_t n,e;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();
  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  rc = (c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type != MCAPI_NO_CHAN);
  /* unlock the database */
  // mcapi_trans_access_database_post();
  return rc;
}

/***************************************************************************
  NAME:valid_status_param
  DESCRIPTION: checks if the given status is a valid status parameter
  PARAMETERS: status
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t valid_status_param (mcapi_status_t* mcapi_status)
{
  return (mcapi_status != NULL);
}

/***************************************************************************
  NAME:valid_version_param OK
  DESCRIPTION: checks if the given version is a valid version parameter
  PARAMETERS: version
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t valid_version_param (mcapi_version_t* mcapi_version)
{
  return (mcapi_version != NULL);
}


/***************************************************************************
  NAME:valid_buffer_param OK
  DESCRIPTION:checks if the given buffer is a valid buffer parameter
  PARAMETERS: buffer
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t valid_buffer_param (void* buffer)
{
  return (buffer != NULL);
}


/***************************************************************************
  NAME: valid_request_param OK
  DESCRIPTION:checks if the given request is a valid request parameter
  PARAMETERS: request
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t valid_request_param (mcapi_request_t* request)
{
  return (request != NULL);
}


/***************************************************************************
  NAME:valid_size_param OK
  DESCRIPTION: checks if the given size is a valid size parameter
  PARAMETERS: size
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t valid_size_param (size_t* size)
{
  return (size != NULL);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   mcapi_trans API: endpoints                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
/***************************************************************************
  NAME:mcapi_trans_create_endpoint  OK
  DESCRIPTION: This function just looks up the node_num and calls 
       mcapi_trans_create_endpoint_.  NOTE: the reason I separated create_endpoint
       into these two functions is because it's useful for the testharness to be
       able to explicitly create multiple nodes and multiple endpoints on those
       nodes within the same process/thread.  This is very useful for testing and
       this decoupling allows that.  See ./tests/valid_endpoint.c.
  PARAMETERS: 
       ep - the endpoint to be filled in
       port_num - the port id (only valid if !anonymous)
       anonymous - whether or not this should be an anonymous endpoint
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_create_endpoint(mcapi_endpoint_t* ep, mcapi_uint_t port_num,
                                            mcapi_boolean_t anonymous)
{
  mcapi_uint_t node_num;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  rv = mcapi_trans_get_node_num(&node_num);
  //assert (rv);
  return mcapi_trans_create_endpoint_(ep,node_num,port_num,anonymous);
}

/***************************************************************************
  NAME:mcapi_trans_create_endpoint_  OK
  DESCRIPTION:create endpoint <node_num,port_num> and return it's handle 
  PARAMETERS: 
       ep - the endpoint to be filled in
       port_num - the port id (only valid if !anonymous)
       anonymous - whether or not this should be an anonymous endpoint
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_create_endpoint_(mcapi_endpoint_t* ep, mcapi_uint_t node_num, mcapi_uint_t port_num,
                                              mcapi_boolean_t anonymous)
{
  int i, node_index, endpoint_index;
  mcapi_boolean_t rc = MCAPI_FALSE;

  node_num = my_node_id;
 
  /* lock the database */
  // mcapi_trans_access_database_pre();

  node_index = mcapi_trans_get_node_index (node_num);

  /* make sure there's room - mcapi should have already checked this */
  //assert (c_db->nodes[node_index].node_d.num_endpoints < MAX_ENDPOINTS);
   
  
  /* create the endpoint */
  /* find the first available endpoint index */
  endpoint_index = MAX_ENDPOINTS;
  for (i = 0; i < MAX_ENDPOINTS; i++) {
    if (! c_db->nodes[node_index].node_d.endpoints[i].valid) {
      endpoint_index = i;
      break;
    }
  }
  
  //assert(node_index < MAX_NODES);
  //assert(endpoint_index < MAX_ENDPOINTS);
  //assert (c_db->nodes[node_index].node_d.endpoints[endpoint_index].valid == MCAPI_FALSE);
  /* initialize the endpoint entry */  
  c_db->nodes[node_index].node_d.endpoints[endpoint_index].valid = MCAPI_TRUE;
  c_db->nodes[node_index].node_d.endpoints[endpoint_index].port_num = port_num;
  c_db->nodes[node_index].node_d.endpoints[endpoint_index].open = MCAPI_FALSE;
  c_db->nodes[node_index].node_d.endpoints[endpoint_index].anonymous = anonymous;
  c_db->nodes[node_index].node_d.endpoints[endpoint_index].num_attributes = 0;
  
  c_db->nodes[node_index].node_d.num_endpoints++; 
  
  /* set the handle */ 
  //*ep = mcapi_trans_encode_handle_internal (node_index,endpoint_index);
  
  *ep = node_num;
  *ep = node_num << 16;
  *ep = *ep | port_num;
  //printf("my_ep=%x\n",*ep);
  //dprintf(" mcapi_trans_create_endpoint (node_num=%x port_num=%d) ep=%x, node_index=%d, endpoint_index=%d\n",
  //            node_num,port_num,*ep,node_index,endpoint_index);
  rc = MCAPI_TRUE;
  
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
  
  //Open device for local endpoint to receive messages
   //int fdev = 0;
   fdevs[node_num] = open(dev_names[node_num], O_RDWR, 0x700);

  ioctl(fdevs[node_num],SET_HIBI_RX_ADDR,(void*) (hibiBaseAddresses[node_num] | port_num)  );
  ioctl(fdevs[node_num],SET_HIBI_RX_PACKETS,(void*) DEFAULT_MSG_SIZE);
  ioctl(fdevs[node_num],SET_HIBI_RX_BLOCKING,(void*) HIBI_READ_BLOCKING_MODE);

  return rc;
}


/***************************************************************************
  NAME:mcapi_trans_get_endpoint_i
  DESCRIPTION:non-blocking get endpoint for the given <node_num,port_num> 
  PARAMETERS: 
     endpoint - the endpoint handle to be filled in
     node_num - the node id
     port_num - the port id
     request - the request handle to be filled in when the task is complete
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_get_endpoint_i( mcapi_endpoint_t* endpoint,mcapi_uint_t node_num,
                                 mcapi_uint_t port_num, mcapi_request_t* request,
                                 mcapi_status_t* mcapi_status)
{
  
  mcapi_boolean_t valid =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_TRUE : MCAPI_FALSE; 
  mcapi_boolean_t completed = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  if (valid) {
    /* try to get the endpoint */
    if (mcapi_trans_get_endpoint_internal (endpoint,node_num,port_num)) {
      completed = MCAPI_TRUE;
    } else {
      request->node_num = node_num;
      request->port_num = port_num;
    }
  }

  setup_request_internal(endpoint,request,mcapi_status,completed,0,NULL,GET_ENDPT);

  /* unlock the database */
   // mcapi_trans_access_database_post();
}
/***************************************************************************
  NAME:mcapi_trans_get_endpoint_internal
  DESCRIPTION:get endpoint for the given <node_num,port_num> 
  PARAMETERS: 
     endpoint - the endpoint handle to be filled in
     node_num - the node id
     port_num - the port id
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_get_endpoint_internal (mcapi_endpoint_t *e, mcapi_uint_t node_num, 
                                                   mcapi_uint_t port_num) 
{
   int i,j;
   int rc = MCAPI_FALSE;
   
   /* the database should already be locked */

   mcapi_dprintf(2," mcapi_trans_get_endpoint_internal node_num=%d, port_num=%d\n",
                 node_num,port_num);
   
   for (i = 0; i < c_db->num_nodes; i++) {
     if (c_db->nodes[i].node_num == node_num) { 
       for (j = 0; j < c_db->nodes[i].node_d.num_endpoints; j++) {
         if ((c_db->nodes[i].node_d.endpoints[j].valid) && 
             (c_db->nodes[i].node_d.endpoints[j].port_num == port_num)) {
           /* return the handle */
           *e = mcapi_trans_encode_handle_internal (i,j);
           rc = MCAPI_TRUE;
         }
       }
     }
   }
   return rc;
}

/***************************************************************************
  NAME:mcapi_trans_get_endpoint
  DESCRIPTION:blocking get endpoint for the given <node_num,port_num> 
  PARAMETERS: 
     endpoint - the endpoint handle to be filled in
     node_num - the node id
     port_num - the port id
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
void mcapi_trans_get_endpoint(mcapi_endpoint_t *e, mcapi_uint_t node_num, 
                                         mcapi_uint_t port_num)
{
  *e = node_num;
  *e = node_num << 16;
  *e = *e | port_num;

  
  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  //while(!mcapi_trans_get_endpoint_internal (e,node_num,port_num)) {
    /* yield */
    //mcapi_dprintf(5," mcapi_trans_get_endpoint - attempting to yield\n");
    //transport_sm_yield_internal();
  //}
 
   /* lock the database */
  // mcapi_trans_access_database_post(); 
}


/***************************************************************************
  NAME: mcapi_trans_delete_endpoint
  DESCRIPTION:delete the given endpoint
  PARAMETERS: endpoint
  RETURN VALUE: none
***************************************************************************/
 void mcapi_trans_delete_endpoint( mcapi_endpoint_t endpoint)
{
  uint16_t n,e;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
    /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(endpoint,&n,&e);
  //assert(rv);
  
  mcapi_dprintf(2," mcapi_trans_delete_endpoint_internal node_num=%d, port_num=%d\n",
                c_db->nodes[n].node_num,c_db->nodes[n].node_d.endpoints[e].port_num);

  /* remove the endpoint */
  c_db->nodes[n].node_d.num_endpoints--;
  /* zero out the old endpoint entry in the shared memory database */
  memset (&c_db->nodes[n].node_d.endpoints[e],0,sizeof(endpoint_entry));

  /* unlock the database */
  // mcapi_trans_access_database_post();
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   mcapi_trans API: messages                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
/***************************************************************************
  NAME: mcapi_trans_msg_send OK
  DESCRIPTION: sends a connectionless message from one endpoint to another (blocking)
  PARAMETERS: 
     send_endpoint - the sending endpoint's handle
     receive_endpoint - the receiving endpoint's handle
     buffer - the user supplied buffer
     buffer_size - the size in bytes of the buffer
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_msg_send( mcapi_endpoint_t  send_endpoint, 
                                      mcapi_endpoint_t  receive_endpoint, char* buffer, 
                                      size_t buffer_size)
{
  mcapi_request_t request;
  mcapi_status_t status = MCAPI_SUCCESS;
  size_t size;
  

  /* use non-blocking followed by wait */
  mcapi_trans_msg_send_i (send_endpoint,receive_endpoint,buffer,buffer_size,&request,&status);
  mcapi_trans_wait (&request,&size,&status,MCAPI_INFINITE);

  if (status == MCAPI_SUCCESS) {
    return MCAPI_TRUE;
  }
  return MCAPI_FALSE;
}

/***************************************************************************
  NAME: mcapi_trans_msg_send_i
  DESCRIPTION: sends a connectionless message from one endpoint to another (non-blocking)
  PARAMETERS: 
     send_endpoint - the sending endpoint's handle
     receive_endpoint - the receiving endpoint's handle
     buffer - the user supplied buffer
     buffer_size - the size in bytes of the buffer
     request - the request handle to be filled in when the task is complete
  RETURN VALUE:none
***************************************************************************/
 void mcapi_trans_msg_send_i( mcapi_endpoint_t  send_endpoint, mcapi_endpoint_t  receive_endpoint, 
                            char* buffer, size_t buffer_size, mcapi_request_t* request,
                             mcapi_status_t* mcapi_status) 
{
  int port_id,node_id ,fdev = 0;
  uint16_t sn,se;
  uint16_t rn,re;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  mcapi_dprintf(2,"  mcapi_trans_msg_send_i se=%x re=%x\n",send_endpoint,receive_endpoint);
  
  /* lock the database */
  // mcapi_trans_access_database_pre();
  
   
  
  if (!completed) {    
    completed = MCAPI_TRUE; /* sends complete immediately */
    /* these function calls were in asserts */
    rv = mcapi_trans_decode_handle_internal(send_endpoint,&sn,&se);
    //assert(rv);
    rv = mcapi_trans_decode_handle_internal(receive_endpoint,&rn,&re);
    //assert(rv);
    
    /* FIXME: (errata B1) is it really an error to send/recv a message with a _connected_ endpoint? */
    //assert (c_db->nodes[sn].node_d.endpoints[se].recv_queue.channel_type == MCAPI_NO_CHAN);
    //assert (c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_NO_CHAN);
  
    
    
    //printf("TRANS: Sending message...\n");
    // TODO: FILE_DEVICE send_data
    port_id = receive_endpoint & 0x0000FFFF;
    node_id = receive_endpoint >> 16;
	
	fdev = open(dev_names[node_id], O_RDWR, 0x700);


    if(port_id != 0)
    {
    	lseek(fdevs[node_id], port_id, SEEK_SET);
    }
    write(fdevs[node_id], buffer , buffer_size);
  
	close(fdevs[node_id]);
  
    //if (!mcapi_trans_send_internal (sn,se,rn,re,buffer,buffer_size,MCAPI_FALSE,0)) {
      /* assume couldn't get a buffer */
    // *mcapi_status = MCAPI_ENO_BUFFER;
    //}
  
  }
  
  //setup_request_internal(&receive_endpoint,request,mcapi_status,completed,buffer_size,NULL,SEND);

  /* unlock the database */
    // mcapi_trans_access_database_post();
 }

/***************************************************************************
  NAME:mcapi_trans_msg_recv
  DESCRIPTION:receives a message from this endpoints receive queue (blocking)
  PARAMETERS: 
     receive_endpoint - the receiving endpoint
     buffer - the user supplied buffer to copy the message into
     buffer_size - the size of the user supplied buffer
     received_size - the actual size of the message received
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_msg_recv( mcapi_endpoint_t  receive_endpoint,  char* buffer, 
                          size_t buffer_size, size_t* received_size)
{
  
  
  mcapi_request_t request;
  mcapi_status_t status = MCAPI_SUCCESS;

  mcapi_dprintf(2,"  mcapi_trans_msg_recv re=%x\n",receive_endpoint);

  /* use non-blocking followed by wait */
  mcapi_trans_msg_recv_i (receive_endpoint,buffer,buffer_size,&request,&status);
  // TODO: this wait never finishes on TTA. WHY???
//  mcapi_trans_wait (&request,received_size,&status,MCAPI_INFINITE);

  if (status == MCAPI_SUCCESS) {
    return MCAPI_TRUE;
  }
  return MCAPI_FALSE;

}

/***************************************************************************
  NAME:mcapi_trans_msg_recv_i
  DESCRIPTION:receives a message from this endpoints receive queue (non-blocking)
  PARAMETERS: 
     receive_endpoint - the receiving endpoint
     buffer - the user supplied buffer to copy the message into
     buffer_size - the size of the user supplied buffer
     received_size - the actual size of the message received
     request - the request to be filled in when the task is completed.
  RETURN VALUE:MCAPI_TRUE/MCAPI_FALSE indicating success or failure
***************************************************************************/
void mcapi_trans_msg_recv_i( mcapi_endpoint_t  receive_endpoint,  char* buffer, 
                             size_t buffer_size, mcapi_request_t* request,
                             mcapi_status_t* mcapi_status) 
{

  
  uint16_t rn,re,rp;
  //size_t received_size = 0;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  mcapi_dprintf(2,"  mcapi_trans_msg_recv_i re=%x\n",receive_endpoint);
 
  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(receive_endpoint,&rn,&re);
    //assert(rv);
    /* FIXME: (errata B1) is it really an error recv a message with a _connected_ endpoint? */
    //assert (c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_NO_CHAN);
    

    //if (mcapi_trans_recv_internal(rn,re,(void*)&buffer,buffer_size,&received_size,MCAPI_FALSE,NULL)) {
    // completed = MCAPI_TRUE;
    // buffer_size = received_size;
    //}   
  }
  
  rn = receive_endpoint & 0x0000FFFF;
  rp = receive_endpoint  >> 16;

  ioctl(fdevs[rn],SET_HIBI_RX_ADDR,(void*) (hibiBaseAddresses[rn] | rp));
  ioctl(fdevs[rn],SET_HIBI_RX_PACKETS,(void*) DEFAULT_MSG_SIZE);
  ioctl(fdevs[rn],SET_HIBI_RX_BLOCKING,(void*) HIBI_READ_BLOCKING_MODE);

  
  // TODO: FILE_DEV get received data from hibi_pe_dma
  read(fdevs[rp], (char*) &buffer, buffer_size);
  
  // initialize msg channel
  //initCh(hibi_address_table[my_node_id] + receive_endpoint & 0x0000FFFF, receive_endpoint & 0x0000FFFF, (int)(rx_data), buffer_size);

  setup_request_internal(&receive_endpoint,request,mcapi_status,completed,buffer_size,(void**)((void*)&buffer),RECV);
  

  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME: mcapi_trans_msg_available
  DESCRIPTION: counts the number of messages in the endpoints receive queue
  PARAMETERS:  endpoint
  RETURN VALUE: the number of messages in the queue
***************************************************************************/
mcapi_uint_t mcapi_trans_msg_available( mcapi_endpoint_t receive_endpoint)
{
  uint16_t rn,re;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(receive_endpoint,&rn,&re);
  //assert(rv);   
  


  //rc = c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements;

  /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   mcapi_trans API: packet channels                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
/***************************************************************************
  NAME:mcapi_trans_connect_pktchan_i
  DESCRIPTION: connects a packet channel
  PARAMETERS: 
    send_endpoint - the sending endpoint handle
    receive_endpoint - the receiving endpoint handle
    request - the request to be filled in when the task is complete
    mcapi_status -
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_connect_pktchan_i( mcapi_endpoint_t  send_endpoint, 
                                   mcapi_endpoint_t  receive_endpoint, 
                                    mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  
  int port_id, node_id =0;
  char buffer;

  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  if (!completed) {
    mcapi_trans_connect_channel_internal (send_endpoint,receive_endpoint,MCAPI_PKT_CHAN);
    completed = MCAPI_TRUE;
  }
  setup_request_internal(&receive_endpoint,request,mcapi_status,completed,0,NULL,0);


  port_id = receive_endpoint & 0x0000FFFF;
  node_id = receive_endpoint >> 16;


  // Open file device for packet channel and store receive endpoint
  pkt_channels[pkt_chan_idx].pkt_fdev = open((void*) fdevs[node_id], O_RDWR, 0x700);
  pkt_channels[pkt_chan_idx].recv_ep = receive_endpoint;
  pkt_chan_idx++;
  
  //Send connect message to receive nodes config channel TODO:set correct size
  write(fdevs[node_id],(void*) 11 ,  4);
  
  // Receive acknoledge
  read(cfg_fdev, (char*) &buffer, 1);
  
    /* unlock the database */
  // mcapi_trans_access_database_post();
}
 
/***************************************************************************
  NAME: mcapi_trans_open_pktchan_recv_i
  DESCRIPTION: opens the receive endpoint on a packet channel
  PARAMETERS:     
    recv_handle - the receive channel handle to be filled in
    receive_endpoint - the receiving endpoint handle
    request - the request to be filled in when the task is complete
    mcapi_status
  RETURN VALUE: none
***************************************************************************/
 void mcapi_trans_open_pktchan_recv_i( mcapi_pktchan_recv_hndl_t* recv_handle, 
                                       mcapi_endpoint_t receive_endpoint, 
                                       mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  uint16_t rn,re;
   /* if errors were found at the mcapi layer, then the request is considered complete */
   mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
   mcapi_boolean_t rv = MCAPI_FALSE;
   
   completed = MCAPI_TRUE;
   /* lock the database */
   // mcapi_trans_access_database_pre();
   
   if (!completed) {
       rv = mcapi_trans_decode_handle_internal(receive_endpoint,&rn,&re);
     //assert(rv);
     
     mcapi_trans_open_channel_internal (rn,re);
     
     /* fill in the channel handle */
     *recv_handle = mcapi_trans_encode_handle_internal(rn,re);
     
	 // TODO: read(configure)
	 
     
     /* has the channel been connected yet? */
     if ( c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_PKT_CHAN) {
       completed = MCAPI_TRUE;
     }
     
     mcapi_dprintf(2," mcapi_trans_open_pktchan_recv_i (node_num=%d,port_num=%d) handle=%x\n",
                   c_db->nodes[rn].node_num,c_db->nodes[rn].node_d.endpoints[re].port_num,*recv_handle); 
   }

   //setup_request_internal(&receive_endpoint,request,mcapi_status,completed,0,NULL,OPEN_PKTCHAN);
   
   /* unlock the database */
   // mcapi_trans_access_database_post();
   *mcapi_status = MCAPI_SUCCESS;
} 


/***************************************************************************
  NAME: mcapi_trans_open_pktchan_send_i
  DESCRIPTION: opens the send endpoint on a packet channel
  PARAMETERS:     
    send_handle - the send channel handle to be filled in
    receive_endpoint - the receiving endpoint handle
    request - the request to be filled in when the task is complete
    mcapi_status
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_open_pktchan_send_i( mcapi_pktchan_send_hndl_t* send_handle, 
                                      mcapi_endpoint_t send_endpoint,mcapi_request_t* request,
                                      mcapi_status_t* mcapi_status)
{
  uint16_t sn,se;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(send_endpoint,&sn,&se);
    //assert(rv);
    
    /* mark the endpoint as open */
    c_db->nodes[sn].node_d.endpoints[se].open = MCAPI_TRUE;
    
    /* fill in the channel handle */
    *send_handle = mcapi_trans_encode_handle_internal(sn,se);

    /* has the channel been connected yet? */
    if ( c_db->nodes[sn].node_d.endpoints[se].recv_queue.channel_type == MCAPI_PKT_CHAN) {
      completed = MCAPI_TRUE;
    }
      
    mcapi_dprintf(2," mcapi_trans_open_pktchan_send_i (node_num=%d,port_num=%d) handle=%x\n",
                  c_db->nodes[sn].node_num,c_db->nodes[sn].node_d.endpoints[se].port_num,*send_handle);
  }

  setup_request_internal(&send_endpoint,request,mcapi_status,completed,0,NULL,OPEN_PKTCHAN);

  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME:mcapi_trans_pktchan_send_i
  DESCRIPTION: sends a packet on a packet channel (non-blocking)
  PARAMETERS: 
    send_handle - the send channel handle
    buffer - the buffer
    size - the size in bytes of the buffer
    request - the request handle to be filled in when the task is complete
    mcapi_status -
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_pktchan_send_i( mcapi_pktchan_send_hndl_t send_handle, 
                                void* buffer, size_t size, mcapi_request_t* request,
                                 mcapi_status_t* mcapi_status)
{
  int i;
  uint16_t sn,se,rn,re;
   /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE; 
  mcapi_boolean_t rv = MCAPI_FALSE;

  mcapi_dprintf(2,"  mcapi_trans_pktchan_send_i send_handle=%x\n",send_handle);

  /* lock the database */
  // mcapi_trans_access_database_pre();
  completed = MCAPI_FALSE;

  if (!completed) {  
    rv = mcapi_trans_decode_handle_internal(send_handle,&sn,&se);
    //assert(rv);   
    rv = mcapi_trans_decode_handle_internal(c_db->nodes[sn].node_d.endpoints[se].recv_queue.recv_endpt,&rn,&re);
    //assert(rv);
 
    /*   if (!mcapi_trans_send_internal (sn,se,rn,re,(char*)buffer,size,MCAPI_FALSE,0)) { */
    /*       *mcapi_status = MCAPI_ENO_BUFFER; */
    /*     } */

    
  for(i=0; i < pkt_chan_idx;) {
	if (pkt_channels[i].recv_ep == re) break;
	i++;
  }
  
  write(pkt_channels[i].pkt_fdev, buffer , size);


    completed = MCAPI_TRUE;
  }

  setup_request_internal(&send_handle,request,mcapi_status,completed,size,NULL,SEND);
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME:mcapi_trans_pktchan_send
  DESCRIPTION: sends a packet on a packet channel (blocking)
  PARAMETERS: 
    send_handle - the send channel handle
    buffer - the buffer
    size - the size in bytes of the buffer
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_pktchan_send( mcapi_pktchan_send_hndl_t send_handle, 
                                         void* buffer, size_t size)
{
  mcapi_request_t request;
  mcapi_status_t status = MCAPI_SUCCESS;

  mcapi_dprintf(2,"  mcapi_trans_pktchan_send re=%x\n",send_handle);

  /* use non-blocking followed by wait */
  mcapi_trans_pktchan_send_i (send_handle,buffer,size,&request,&status);
  mcapi_trans_wait (&request,&size,&status,MCAPI_INFINITE);
  status = MCAPI_SUCCESS;
  if (status == MCAPI_SUCCESS) {
    return MCAPI_TRUE;
  }
  return MCAPI_FALSE;
}


/***************************************************************************
  NAME:mcapi_trans_pktchan_recv_i
  DESCRIPTION: receives a packet on a packet channel (non-blocking)
  PARAMETERS: 
    receive_handle - the send channel handle
    buffer - a pointer to a pointer to a buffer 
    request - the request handle to be filled in when the task is complete
    mcapi_status -
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_pktchan_recv_i( mcapi_pktchan_recv_hndl_t receive_handle,  
                                 void** buffer, mcapi_request_t* request,
                                 mcapi_status_t* mcapi_status)
{
  uint16_t rn,re,rp;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  size_t size = MAX_PKT_SIZE; 

  /* lock the database */
  // mcapi_trans_access_database_pre();

  completed = MCAPI_FALSE;
  
  if (!completed) {  
    rv = mcapi_trans_decode_handle_internal(receive_handle,&rn,&re);
    //assert(rv);
    
    /* *buffer will be filled in the with a ptr to an mcapi buffer */
    //*buffer = NULL;
    //*buffer = rx_data;
    
    //decode handle

    ioctl(fdevs[rn],SET_HIBI_RX_ADDR,(void*) (hibiBaseAddresses[rn] | rp)  );
    ioctl(fdevs[rn],SET_HIBI_RX_PACKETS,(void*) DEFAULT_MSG_SIZE);
    ioctl(fdevs[rn],SET_HIBI_RX_BLOCKING,(void*) HIBI_READ_BLOCKING_MODE);


    // TODO: FILE_DEV
    read(fdevs[0], (char*) &buffer, 1);

  
    //if (mcapi_trans_recv_internal (rn,re,buffer,MAX_PKT_SIZE,&size,MCAPI_FALSE,NULL)) {
    completed = MCAPI_TRUE;
    //}
  }

  setup_request_internal(&receive_handle,request,mcapi_status,completed,size,buffer,RECV);
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME:mcapi_trans_pktchan_recv
  DESCRIPTION: receives a packet on a packet channel (blocking)
  PARAMETERS: 
    send_handle - the send channel handle
    buffer - the buffer
    received_size - the size in bytes of the buffer
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE (only returns MCAPI_FALSE if it couldn't get a buffer)
***************************************************************************/
mcapi_boolean_t mcapi_trans_pktchan_recv( mcapi_pktchan_recv_hndl_t receive_handle, 
                              void** buffer, size_t* received_size)
{
  
  mcapi_request_t request;
  mcapi_status_t status = MCAPI_SUCCESS;

  mcapi_dprintf(2,"  mcapi_trans_pktchan_recv re=%x\n",receive_handle);

  /* use non-blocking followed by wait */
  mcapi_trans_pktchan_recv_i (receive_handle,buffer,&request,&status);
  mcapi_trans_wait (&request,received_size,&status,MCAPI_INFINITE);
  status = MCAPI_SUCCESS;
  if (status == MCAPI_SUCCESS) {
    return MCAPI_TRUE;
  }
  return MCAPI_FALSE;
}

/***************************************************************************
  NAME: mcapi_trans_pktchan_available
  DESCRIPTION: counts the number of elements in the endpoint receive queue
    identified by the receive handle.
  PARAMETERS: receive_handle - the receive channel handle
  RETURN VALUE: the number of elements in the receive queue
***************************************************************************/
mcapi_uint_t mcapi_trans_pktchan_available( mcapi_pktchan_recv_hndl_t receive_handle)
{
  uint16_t rn,re;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(receive_handle,&rn,&re);
  //assert(rv); 
  rc = c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements;

  /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_pktchan_free
  DESCRIPTION: frees the given buffer
  PARAMETERS: buffer pointer
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE indicating success or failure (buffer not found)
***************************************************************************/
mcapi_boolean_t mcapi_trans_pktchan_free( void* buffer)
{
  
   int rc = MCAPI_TRUE;
   buffer_entry* b_e;

   /* lock the database */
  // mcapi_trans_access_database_pre();

  /* optimization - just do pointer arithmetic on the buffer pointer to get
     the base address of the buffer_entry structure. */
  b_e = buffer-9;
  if (b_e->magic_num == MAGIC_NUM) {
    memset(b_e,0,sizeof(buffer_entry));
  } else {
    /* didn't find the buffer */
    rc = MCAPI_FALSE;
  }
  
  /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}


/***************************************************************************
  NAME:mcapi_trans_pktchan_recv_close_i
  DESCRIPTION: non-blocking close of the receiving end of the packet channel
  PARAMETERS: receive_handle
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_pktchan_recv_close_i( mcapi_pktchan_recv_hndl_t  receive_handle,
                                       mcapi_request_t* request, mcapi_status_t* mcapi_status)
{
  uint16_t rn,re;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(receive_handle,&rn,&re);
    //assert(rv);
    mcapi_trans_close_channel_internal (rn,re);
    completed = MCAPI_TRUE;    
  }
  setup_request_internal(&receive_handle,request,mcapi_status,completed,0,NULL,0);
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}


/***************************************************************************
  NAME:mcapi_trans_pktchan_send_close_i
  DESCRIPTION: non-blocking close of the sending end of the packet channel
  PARAMETERS: receive_handle
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_pktchan_send_close_i( mcapi_pktchan_send_hndl_t  send_handle,
                                       mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  uint16_t sn,se;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  if (!completed) {    
     rv = mcapi_trans_decode_handle_internal(send_handle,&sn,&se);
     //assert(rv);
     mcapi_trans_close_channel_internal (sn,se);
     completed = MCAPI_TRUE;     
   }
  
  setup_request_internal(&send_handle,request,mcapi_status,completed,0,NULL,0);
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   mcapi_trans API: scalar channels                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

/***************************************************************************
  NAME:mcapi_trans_connect_sclchan_i
  DESCRIPTION: connects a scalar channel between the given two endpoints
  PARAMETERS: 
      send_endpoint - the sending endpoint
      receive_endpoint - the receiving endpoint
      request - the request
      mcapi_status - the status
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_connect_sclchan_i( mcapi_endpoint_t  send_endpoint, 
                                    mcapi_endpoint_t  receive_endpoint, 
                                    mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  int node_id, port_id = 0;
  char buffer;

  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  if (!completed) {
    mcapi_trans_connect_channel_internal (send_endpoint,receive_endpoint,MCAPI_SCL_CHAN);
    completed = MCAPI_TRUE;
  }
  setup_request_internal(&receive_endpoint,request,mcapi_status,completed,0,NULL,0);
  

  port_id = receive_endpoint & 0x0000FFFF;
  node_id = receive_endpoint >> 16;

  // Open file device for packet channel and store receive endpoint
  scl_channels[scl_chan_idx].scl_fdev = open((void*)fdevs[node_id], O_RDWR, 0x700);
  scl_channels[scl_chan_idx].recv_ep = receive_endpoint;
  scl_chan_idx++;
  
  //Send connect message to receive nodes config channel TODO: Set correct size
  write(fdevs[node_id],(void*) 11 , 4);
  
  // Receive acknoledge
  read(cfg_fdev, (char*) &buffer, 1);
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME: mcapi_trans_open_sclchan_recv_i
  DESCRIPTION: opens the receive endpoint on a packet channel
  PARAMETERS:     
    recv_handle - the receive channel handle to be filled in
    receive_endpoint - the receiving endpoint handle
    request - the request to be filled in when the task is complete
    mcapi_status
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_open_sclchan_recv_i( mcapi_sclchan_recv_hndl_t* recv_handle, 
                                      mcapi_endpoint_t receive_endpoint, 
                                      mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  uint16_t rn,re;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(receive_endpoint,&rn,&re);
    //assert(rv);
    
    mcapi_trans_open_channel_internal (rn,re);
   
    /* fill in the channel handle */
    *recv_handle = mcapi_trans_encode_handle_internal(rn,re);
    
    /* has the channel been connected yet? */
    if ( c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_SCL_CHAN){
      completed = MCAPI_TRUE;
    }
    
    mcapi_dprintf(2," mcapi_trans_open_sclchan_recv_i (node_num=%d,port_num=%d) handle=%x\n",
                  c_db->nodes[rn].node_num,c_db->nodes[rn].node_d.endpoints[re].port_num,*recv_handle);
  }

  setup_request_internal(&receive_endpoint,request,mcapi_status,completed,0,NULL,OPEN_SCLCHAN);

  /* unlock the database */
  // mcapi_trans_access_database_post();
}


/***************************************************************************
  NAME: mcapi_trans_open_sclchan_send_i
  DESCRIPTION: opens the receive endpoint on a packet channel
  PARAMETERS:     
    send_handle - the receive channel handle to be filled in
    receive_endpoint - the receiving endpoint handle
    request - the request to be filled in when the task is complete
    mcapi_status
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_open_sclchan_send_i( mcapi_sclchan_send_hndl_t* send_handle, 
                                      mcapi_endpoint_t  send_endpoint, 
                                      mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  uint16_t sn,se;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();
  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(send_endpoint,&sn,&se);
    //assert(rv);
    
    /* mark the endpoint as open */
    c_db->nodes[sn].node_d.endpoints[se].open = MCAPI_TRUE;

    /* fill in the channel handle */
    *send_handle = mcapi_trans_encode_handle_internal(sn,se);

    /* has the channel been connected yet? */
    if ( c_db->nodes[sn].node_d.endpoints[se].recv_queue.channel_type == MCAPI_SCL_CHAN){
      completed = MCAPI_TRUE;
    }
    
    mcapi_dprintf(2," mcapi_trans_open_sclchan_send_i (node_num=%d,port_num=%d) handle=%x\n",
                  c_db->nodes[sn].node_num,c_db->nodes[sn].node_d.endpoints[se].port_num,*send_handle);
  }

  setup_request_internal(&send_endpoint,request,mcapi_status,completed,0,NULL,OPEN_SCLCHAN);
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME:mcapi_trans_sclchan_send
  DESCRIPTION: sends a packet on a packet channel (blocking)
  PARAMETERS: 
    send_handle - the send channel handle
    buffer - the buffer
    size - the size in bytes of the buffer
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE
***************************************************************************/
mcapi_boolean_t mcapi_trans_sclchan_send(
    mcapi_sclchan_send_hndl_t send_handle, uint64_t dataword, uint32_t size)
{  
  int i = 0;
  uint16_t sn,se,rn,re;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  mcapi_dprintf(2,"  mcapi_trans_sclchan_send send_handle=%x\n",send_handle);
  
  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  rv = mcapi_trans_decode_handle_internal(send_handle,&sn,&se);
  //assert(rv);
  rv = mcapi_trans_decode_handle_internal(c_db->nodes[sn].node_d.endpoints[se].recv_queue.recv_endpt,&rn,&re);
  //assert(rv);
  
  rc = mcapi_trans_send_internal (sn,se,rn,re,NULL,size,MCAPI_TRUE,dataword); 
  
 for(i=0; i < scl_chan_idx;) {
	if (pkt_channels[i].recv_ep == re) break;
	i++;
  }
  
  write(scl_channels[i].scl_fdev, &dataword , size);

  /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}


/***************************************************************************
  NAME:mcapi_trans_sclchan_recv
  DESCRIPTION: receives a packet on a packet channel (blocking)
  PARAMETERS: 
    send_handle - the send channel handle
    buffer - the buffer
    received_size - the size in bytes of the buffer
  RETURN VALUE: MCAPI_TRUE/MCAPI_FALSE (only returns MCAPI_FALSE if it couldn't get a buffer)
***************************************************************************/
mcapi_boolean_t mcapi_trans_sclchan_recv(
    mcapi_sclchan_recv_hndl_t receive_handle, uint64_t *data,uint32_t size)
{
  uint16_t rn,re;
  size_t received_size;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();
  
  rv = mcapi_trans_decode_handle_internal(receive_handle,&rn,&re);
  //assert(rv);
  
  
  if (mcapi_trans_recv_internal (rn,re,NULL,size,&received_size,MCAPI_TRUE,data) &&
      received_size == size) {
    rc = MCAPI_TRUE;
  }

  
  /* FIXME: (errata A2) if size != received_size then we shouldn't remove the item from the
     endpoints receive queue */
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
  
  return rc;
}

/***************************************************************************
  NAME: mcapi_trans_sclchan_available
  DESCRIPTION: counts the number of elements in the endpoint receive queue
    identified by the receive handle.
  PARAMETERS: receive_handle - the receive channel handle
  RETURN VALUE: the number of elements in the receive queue
***************************************************************************/
mcapi_uint_t mcapi_trans_sclchan_available_i( mcapi_sclchan_recv_hndl_t receive_handle)
{
  uint16_t rn,re;
  int rc = MCAPI_FALSE;
  mcapi_boolean_t rv = MCAPI_FALSE;
   
  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(receive_handle,&rn,&re);
  //assert(rv); 
  rc = c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements;


    /* unlock the database */
  // mcapi_trans_access_database_post();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_sclchan_recv_close_i
  DESCRIPTION: non-blocking close of the receiving end of the scalar channel
  PARAMETERS: 
    receive_handle -
    request -
    mcapi_status -
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_sclchan_recv_close_i( mcapi_sclchan_recv_hndl_t  recv_handle,
                                       mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  uint16_t rn,re;
   /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE; 
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();
  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(recv_handle,&rn,&re);
    //assert(rv);
    mcapi_trans_close_channel_internal (rn,re);
    completed = MCAPI_TRUE;    
  }  
  setup_request_internal(&recv_handle,request,mcapi_status,completed,0,NULL,0);
  /* unlock the database */
  // mcapi_trans_access_database_post();
}


/***************************************************************************
  NAME:mcapi_trans_sclchan_send_close_i
  DESCRIPTION: non-blocking close of the sending end of the scalar channel
  PARAMETERS: 
    send_handle -
    request -
    mcapi_status -
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_sclchan_send_close_i( mcapi_sclchan_send_hndl_t send_handle,
                                       mcapi_request_t* request,mcapi_status_t* mcapi_status)
{
  uint16_t sn,se;
  /* if errors were found at the mcapi layer, then the request is considered complete */
  mcapi_boolean_t completed =  (*mcapi_status == MCAPI_SUCCESS) ? MCAPI_FALSE : MCAPI_TRUE;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();
  if (!completed) {    
    rv = mcapi_trans_decode_handle_internal(send_handle,&sn,&se);
    //assert(rv);
    mcapi_trans_close_channel_internal (sn,se);
    completed = MCAPI_TRUE;
  }
  setup_request_internal(&send_handle,request,mcapi_status,completed,0,NULL,0);
  /* unlock the database */
  // mcapi_trans_access_database_post();
}



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   test and wait functions                                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

/***************************************************************************
  NAME:mcapi_trans_test_i
  DESCRIPTION: Tests if the request has completed yet (non-blocking).
  PARAMETERS: 
    request -
    size -
    mcapi_status -
  RETURN VALUE: TRUE/FALSE indicating if the request has completed.
***************************************************************************/
mcapi_boolean_t mcapi_trans_test_i( mcapi_request_t* request, size_t* size,
                                    mcapi_status_t* mcapi_status)  
{

  /* FIXME: (errata B6) need to be able to set EREQ_CANCELED just like wait does */
  mcapi_boolean_t rc;
  
  rc = MCAPI_FALSE;
  
  mcapi_dprintf(3,"mcapi_trans_test_i request:0x%lx\n",(long unsigned int) request);
  if (request->valid == MCAPI_FALSE) {
    *mcapi_status = MCAPI_ENOTREQ_HANDLE;
    rc = MCAPI_FALSE;
  } else if (request->cancelled) {
    *mcapi_status = MCAPI_EREQ_CANCELED;
    rc = MCAPI_FALSE;
  } else if (!(request->completed)) {
    /* try to complete the request */
    /*  receives to an empty channel or get_endpt for an endpt that
        doesn't yet exist are the only two types of non-blocking functions
        that don't complete immediately for this implementation */
    switch (request->type) {
    case (RECV) : 
      check_receive_request (request); break;
    case (GET_ENDPT) :
      check_get_endpt_request (request);break;
    default:
      //assert(0);
      break;
    };
  }

  if (request->completed) {
    *size = request->size;
    *mcapi_status = request->status;
    rc = MCAPI_TRUE;
  }
  
  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_wait
  DESCRIPTION:Tests if the request has completed yet (non-blocking).
  PARAMETERS: 
    send_handle -
    request -
    mcapi_status -
  RETURN VALUE:  TRUE indicating the request has completed or FALSE
    indicating the request has been cancelled.
***************************************************************************/
mcapi_boolean_t mcapi_trans_wait( mcapi_request_t* request, size_t* size,
                                  mcapi_status_t* mcapi_status,
                                  mcapi_timeout_t timeout) 
{
  mcapi_timeout_t time = 0;
  mcapi_boolean_t rc;
  while(1) {
    time++;
    rc = mcapi_trans_test_i(request,size,mcapi_status);
    if (request->completed) {
      return rc;
    }
    /* yield */
    mcapi_dprintf(5," mcapi_trans_wait - attempting to yield\n");
    /* we don't have the lock, it's safe to just yield */
    //sched_yield();
    if ((timeout !=  MCAPI_INFINITE) && (time >= timeout)) {
      *mcapi_status = MCAPI_EREQ_TIMEOUT;
      return MCAPI_FALSE;
    }
  }
}

/***************************************************************************
  NAME:mcapi_trans_wait_any
  DESCRIPTION:Tests if any of the requests have completed yet (blocking).
      Note: the request is now cleared if it has been completed or cancelled.
  PARAMETERS: 
    send_handle -
    request -
    mcapi_status -
  RETURN VALUE: TRUE indicating one of the requests has completed or FALSE
    indicating one of the requests has been cancelled.
***************************************************************************/
mcapi_boolean_t mcapi_trans_wait_any(size_t number, mcapi_request_t** requests, size_t* size,
                                  mcapi_status_t* mcapi_status,
                                  mcapi_timeout_t timeout) 
{
  mcapi_timeout_t time = 0;
  mcapi_boolean_t rc;
  unsigned int i;
  while(1) {
    time++;
    for (i = 0; i < number; i++) {
      rc = mcapi_trans_test_i(requests[i],size,mcapi_status);
      if (requests[i]->completed) {
        return rc;
      }
      /* yield */
      mcapi_dprintf(5," mcapi_trans_wait_any - attempting to yield\n");
      /* we don't have the lock, it's safe to just yield */
      //sched_yield();
      if ((timeout !=  MCAPI_INFINITE) && (time >= timeout)) {
        *mcapi_status = MCAPI_EREQ_TIMEOUT;
        return MCAPI_FALSE;
      }
    }
  }
}

/***************************************************************************
  NAME:mcapi_trans_cancel
  DESCRIPTION: Cancels the given request
  PARAMETERS: 
    request -
    mcapi_status -
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_cancel(mcapi_request_t* request,mcapi_status_t* mcapi_status) 
{
  if (request->valid == MCAPI_FALSE) {
    *mcapi_status = MCAPI_ENOTREQ_HANDLE;
    return;
  } else if (request->cancelled) {
    /* this reqeust has already been cancelled */
    mcapi_dprintf(1," mcapi_trans_cancel - request was already cancelled\n");
    *mcapi_status = MCAPI_EREQ_CANCELED;
    return;
  } else if (!(request->completed)) {
    /* cancel the request */
    request->cancelled = MCAPI_TRUE;
    switch (request->type) {
    case (RECV) : 
      cancel_receive_request (request); break;
    case (GET_ENDPT) :
      break;
    default:
      //assert(0);
      break;
    };
  } else {
    /* it's too late, the request has already completed */
    mcapi_dprintf(1," mcapi_trans_cancel - request has already completed\n");
  }
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   misc helper functions                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

/***************************************************************************
  NAME:mcapi_trans_signal_handler 
  DESCRIPTION: The purpose of this function is to catch signals so that we
   can clean up our shared memory and sempaphore resources cleanly.
  PARAMETERS: the signal
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_signal_handler ( int sig ) 
{
 /*  /\* Since this handler is established for more than one kind of signal,  */
/*      it might still get invoked recursively by delivery of some other kind */
/*      of signal.  Use a static variable to keep track of tha *\/ */
  
/*   if (fatal_error_in_progress) */
/*     raise (sig); */
/*   fatal_error_in_progress = 1; */
  
/*   /\* clean up ipc resources *\/ */
/*   fprintf(stderr,"FAIL: received signal, freeing semaphore and shared memory\n"); */
/*   mcapi_trans_finalize(); */
  
/*   /\* Now reraise the signal.  We reactivate the signal's */
/*      default handling, which is to terminate the process. */
/*      We could just call exit or abort, */
/*      but reraising the signal sets the return status */
/*      from the process correctly. *\/ */
/*   signal (sig, SIG_DFL); */
/*   raise (sig); */
}

/***************************************************************************
  NAME: print_tid
  DESCRIPTION: Displays the thread id.
  PARAMETERS: t - opaque pthread_t handle
  RETURN VALUE: string representing the TID value
***************************************************************************/
//const char *print_tid(pthread_t t) {
//  static char buffer[100];
//  char *p = buffer;
//  
//#ifdef __linux
//  /* We know that pthread_t is an unsigned long */
//  sprintf(p, "%lu", t);
//#else
//  /* Just print out the contents of the pthread_t */ {
//    char *const tend = (char *) ((&t)+1);
//    char *tp = (char *) &t;
//    while (tp < tend) {
//      p += sprintf (p, "%02x", *tp);
//      tp++;
//      if (tp < tend)
//        *p++ = ':';
//    }
//  }
//#endif
//  return buffer;
//}

/***************************************************************************
  NAME: mcapi_trans_set_debug_level
  DESCRIPTION: Sets the debug level which controls verbosity.
  PARAMETERS: d - the desired level
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_set_debug_level (int d) 
{ 
  //if (!WITH_DEBUG) {
    //printf("ERROR mcapi_trans_set_debug_level : This library was built without debug support.\n");
  //printf("If you want to enable debugging, re-build with the --enable-debug option.\n");
  //} else {
  mcapi_debug = d;
  //}
  }

/***************************************************************************
  NAME: get_private_data_index
  DESCRIPTION: Retuns the index for this <pid,tid> into the private globals array.
  PARAMETERS: none
  RETURN VALUE: The index.
***************************************************************************/
int get_private_data_index () {
/* { */
/*   /\* note: an optimization to searching this structure would be for */
/*      mcapi_initialize to return a handle that we could just use to  */
/*      index.  *\/ */
/*   int i; */
/*   int pid; */
  
/*   pthread_t tid; */
/*   pid = getpid(); */
/*   tid = pthread_self(); */
/*   //assert(pid); */
/*   for (i = 0; i < MAX_ENDPOINTS; i++) { */
/*     if ((d[i].pid == pid) && (pthread_equal(d[i].tid,tid))) { */
/*       return i; */
/*     } */
/*     if (d[i].pid == 0) { */
/*       break; */
/*     } */
/*   } */
/*   fprintf(stderr,"FAIL: PID:%u TID:%s (has initialize been called yet?)\n",pid,print_tid(tid));   */
  return 0;
}

/***************************************************************************
  NAME: setup_request_internal
  DESCRIPTION: Sets up the request for a non-blocking function.
  PARAMETERS: 
     handle - 
     request -
     mcapi_status -
     completed - whether the request has already been completed or not (usually
       it has - receives to an empty queue or get_endpoint for endpoints that 
       don't yet exist are the two main cases where completed will be false)
     size - 
     buffer - the buffer
     type - the type of the request
  RETURN VALUE:
***************************************************************************/
void setup_request_internal (mcapi_endpoint_t* handle,mcapi_request_t* request,
                             mcapi_status_t* mcapi_status, mcapi_boolean_t completed, 
                             size_t size,void** buffer,mcapi_request_type type) 
{

  int i,qindex;
  uint16_t n,e; 
  mcapi_boolean_t rv = MCAPI_FALSE;

  if (!valid_request_param (request)) {
    return;
  }

  /* the database should already be locked */
  request->valid = MCAPI_TRUE;
  request->status = *mcapi_status;
  request->size = size;
  request->cancelled = MCAPI_FALSE;
  request->completed = completed;
  
  /* this is hacky, there's probably a better way to do this */
  if ((buffer != NULL) && (!completed)) {
    rv = mcapi_trans_decode_handle_internal(*handle,&n,&e);
    //assert(rv);
    if ( c_db->nodes[n].node_d.endpoints[e].recv_queue.channel_type == MCAPI_PKT_CHAN) {
      /* packet buffer means system buffer, so save the users pointer to the buffer */
      request->buffer_ptr = buffer;
    } else {
      /* message buffer means user buffer, so save the users buffer */
      request->buffer = *buffer;
    }
  }
  request->type = type;
  request->handle = *handle;

  /* save the pointer so that we can fill it in (the endpoint may not have been created yet) 
     an alternative is to make buffer a void* and use it for everything (messages, endpoints, etc.) */
  if (request->type == GET_ENDPT) {
    request->endpoint = handle; 
  }

  /* if this was a non-blocking receive to an empty queue, then reserve the next buffer */
  if ((type == RECV) && (!completed)) {
    rv = mcapi_trans_decode_handle_internal(*handle,&n,&e);
    //assert(rv);
    /*find the queue entry that doesn't already have a request associated with it */
    for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
      /* walk from head to tail */
      qindex = (c_db->nodes[n].node_d.endpoints[e].recv_queue.head + i) % (MAX_QUEUE_ENTRIES); 
      if ((!c_db->nodes[n].node_d.endpoints[e].recv_queue.elements[qindex].request) && 
          (!c_db->nodes[n].node_d.endpoints[e].recv_queue.elements[qindex].invalid)) {
        mcapi_dprintf(4," receive request reserving qindex=%i\n",qindex);
        c_db->nodes[n].node_d.endpoints[e].recv_queue.elements[qindex].request = request; 
        break;
      }      
    }
    if (i == MAX_QUEUE_ENTRIES) {
      /* all of this endpoint's buffers already have reqeusts associated with them */
      *mcapi_status = MCAPI_ENO_REQUEST;
      request->completed = MCAPI_TRUE;
    }   
  }
}

/***************************************************************************
  NAME:mcapi_trans_display_state
  DESCRIPTION: This function is useful for debugging.  If the handle is null,
   we'll print out the state of the entire database.  Otherwise, we'll print out
   only the state of the endpoint that the handle refers to.
  PARAMETERS: 
     handle
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_display_state (void* handle)
{
  /* lock the database */
  // mcapi_trans_access_database_pre_nocheck();  
  mcapi_trans_display_state_internal(handle);
  /* unlock the database */
  // mcapi_trans_access_database_post_nocheck();
}

/***************************************************************************
  NAME:mcapi_trans_display_state_internal
  DESCRIPTION: This function is useful for debugging.  If the handle is null,
   we'll print out the state of the entire database.  Otherwise, we'll print out
   only the state of the endpoint that the handle refers to.  Expects the database
   to be locked.
  PARAMETERS: 
     handle
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_display_state_internal (void* handle)
{
#ifdef __TCE__
    return;
#else
  uint16_t n,e,a;
  mcapi_endpoint_t* endpoint = (mcapi_endpoint_t*)handle;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  printf("DISPLAY STATE:\n");

  
  if (handle != NULL) {
   /* print the data for the given endpoint */
   rv = mcapi_trans_decode_handle_internal(*endpoint,&n,&e);
   //assert(rv); 
   printf("node: %u, port: %u, receive queue (num_elements=%i):\n",
          (unsigned)c_db->nodes[n].node_num,(unsigned)c_db->nodes[n].node_d.endpoints[e].port_num, 
          (unsigned)c_db->nodes[n].node_d.endpoints[e].recv_queue.num_elements);
  
   printf("    endpoint: %d\n",e);
   printf("      valid:%d\n",c_db->nodes[n].node_d.endpoints[e].valid);
   printf("      anonymous:%d\n",c_db->nodes[n].node_d.endpoints[e].anonymous);
   printf("      open:%d\n",c_db->nodes[n].node_d.endpoints[e].open);
   printf("      connected:%d\n",c_db->nodes[n].node_d.endpoints[e].connected);
   printf("      num_attributes:%d\n",(unsigned)c_db->nodes[n].node_d.endpoints[e].num_attributes);
   for (a = 0; a < c_db->nodes[n].node_d.endpoints[e].num_attributes; a++) {
     printf("        attribute:%d\n",a);
     printf("          valid:%d\n",c_db->nodes[n].node_d.endpoints[e].attributes[a].valid);
     printf("          attribute_num:%d\n",c_db->nodes[n].node_d.endpoints[e].attributes[a].attribute_num);
     printf("          bytes:%i\n",(unsigned)c_db->nodes[n].node_d.endpoints[e].attributes[a].bytes);
   }
   print_queue(c_db->nodes[n].node_d.endpoints[e].recv_queue);
  } else {
    /* print the whole database */
    for (n = 0; n < c_db->num_nodes; n++) {
      printf("n=%d\n",n);
      printf("node: %u\n",(unsigned)c_db->nodes[n].node_num);
      printf("  valid:%d\n",c_db->nodes[n].valid);
      printf("  finalized:%d\n",c_db->nodes[n].finalized);
      printf("  num_endpoints:%d\n",c_db->nodes[n].node_d.num_endpoints);
      for (e = 0; e < c_db->nodes[n].node_d.num_endpoints; e++) {
        printf("    e=%d\n",e);
        printf("    endpoint: %u\n",(unsigned)c_db->nodes[n].node_d.endpoints[e].port_num);
        printf("      valid:%d\n",c_db->nodes[n].node_d.endpoints[e].valid);
        printf("      anonymous:%d\n",c_db->nodes[n].node_d.endpoints[e].anonymous);
        printf("      open:%d\n",c_db->nodes[n].node_d.endpoints[e].open);
        printf("      connected:%d\n",c_db->nodes[n].node_d.endpoints[e].connected);
        printf("      num_attributes:%u\n",(unsigned)c_db->nodes[n].node_d.endpoints[e].num_attributes);
        for (a = 0; a < c_db->nodes[n].node_d.endpoints[e].num_attributes; a++) {
          printf("        a=%d\n",a);
          printf("        attribute:%d\n",a);
          printf("          valid:%d\n",c_db->nodes[n].node_d.endpoints[e].attributes[a].valid);
          printf("          attribute_num:%d\n",c_db->nodes[n].node_d.endpoints[e].attributes[a].attribute_num);
          printf("          bytes:%u\n",(unsigned)c_db->nodes[n].node_d.endpoints[e].attributes[a].bytes);
        }
        print_queue(c_db->nodes[n].node_d.endpoints[e].recv_queue);
      }
    }
  }
  printf("\n\n");
#endif
}


/***************************************************************************
  NAME:check_get_endpt_request
  DESCRIPTION: Checks if the request to get an endpoint has been completed or not.
  PARAMETERS: the request pointer (to be filled in)
  RETURN VALUE: none
***************************************************************************/
void check_get_endpt_request (mcapi_request_t *request) 
{
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  if (mcapi_trans_get_endpoint_internal (request->endpoint, request->node_num, 
                                         request->port_num)) {
    request->completed = MCAPI_TRUE;
    request->status = MCAPI_SUCCESS;
  }
  
  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME: cancel_receive_request
  DESCRIPTION: Cancels an outstanding receive request.  This is a little tricky
     because we have to preserve FIFO which means we have to shift all other
     outstanding receive requests down.
  PARAMETERS: 
     request -
  RETURN VALUE: none
***************************************************************************/
void cancel_receive_request (mcapi_request_t *request) 
{
  uint16_t rn,re;
  int i,last,start,curr;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(request->handle,&rn,&re);
  //assert(rv);
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    if (c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].request == request) {
      /* we found the request, now clear the reservation */
      mcapi_dprintf(5,"cancel_receive_request - cancelling request at index %i\n BEFORE:",i);
      print_queue(c_db->nodes[rn].node_d.endpoints[re].recv_queue);
      c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].request = NULL;
      break;
    }
  }

  /* we should have found the outstanding request */
  //assert (i != MAX_QUEUE_ENTRIES);

  /* shift all pending reservations down*/
  start = i;
  last = start;
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    curr = (i+start)%MAX_QUEUE_ENTRIES;
    /* don't cross over the head or the tail */
    if ((curr == c_db->nodes[rn].node_d.endpoints[re].recv_queue.tail) &&
        (curr != start)) {
      break;
    }
    if ((curr == c_db->nodes[rn].node_d.endpoints[re].recv_queue.head) &&
        (curr != start)) {
      break;
    }
    if (c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[curr].request) {
     mcapi_dprintf(5,"cancel_receive_request - shifting request at index %i to index %i\n",curr,last);
     c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[last].request = 
        c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[curr].request;
      c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[curr].request = NULL;
      last = curr;
    }
  }
  
  request->cancelled = MCAPI_TRUE;

  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME: check_receive_request
  DESCRIPTION: Checks if the given non-blocking receive request has completed.
     This is a little tricky because we can't just pop from the head of the
     endpoints receive queue.  We have to locate the reservation that was 
     made in the queue (to preserve FIFO) at the time the request was made.
  PARAMETERS: the request pointer (to be filled in
  RETURN VALUE: none
***************************************************************************/
void check_receive_request (mcapi_request_t *request) 
{
  uint16_t rn,re;
  int i;
  size_t size;
  mcapi_boolean_t rv = MCAPI_FALSE;

  /* lock the database */
  // mcapi_trans_access_database_pre();

  rv = mcapi_trans_decode_handle_internal(request->handle,&rn,&re);
  //assert(rv);
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    if (c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].request == request) {
      /* we found the request, check to see if there is valid data in the receive queue entry */ 
      if (c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].b) {
        /* clear the request reservation */
        c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].request = NULL;
        /* the buffer better still exist */
        //assert (c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].b->in_use);
        /* update the request */
        request->completed = MCAPI_TRUE;
        request->status = MCAPI_SUCCESS;
        /* first take the entry out of the queue  this has the potential to fragment our
           receive queue since we may not be removing from the head */
        if ( c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_PKT_CHAN) {
          /* packet buffer means system buffer, so save the users pointer to the buffer */
            mcapi_trans_recv_internal_ (rn,re,request->buffer_ptr,request->size,&request->size,i,NULL); 
        } else {
          /* message buffer means user buffer, so save the users buffer */
          size = request->size;
          mcapi_trans_recv_internal_ (rn,re,&request->buffer,request->size,&request->size,i,NULL); 
          if (request->size > size) {
            request->size = size;
            request->status = MCAPI_ETRUNCATED;
          } 
        }
        /* now update the receive queue state */
        c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements--;
        /* mark this entry as invalid so that the "bubble" won't be re-used */
        c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[i].invalid = MCAPI_TRUE;
        mcapi_trans_compact_queue (&c_db->nodes[rn].node_d.endpoints[re].recv_queue);
        mcapi_dprintf(4," receive request (test/wait) popped from qindex=%i, num_elements=%i, head=%i, tail=%i\n",
                      i,c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements,
                      c_db->nodes[rn].node_d.endpoints[re].recv_queue.head,
                      c_db->nodes[rn].node_d.endpoints[re].recv_queue.tail);
      }
      break;
    }
  }
  /* we should have found the outstanding request */
  //assert (i != MAX_QUEUE_ENTRIES);

  /* unlock the database */
  // mcapi_trans_access_database_post();
}

/***************************************************************************
  NAME:mcapi_trans_connect_channel_internal
  DESCRIPTION: connects a channel
  PARAMETERS: 
     send_endpoint
     receive_endpoint
     type
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_connect_channel_internal (mcapi_endpoint_t send_endpoint,
                                  mcapi_endpoint_t receive_endpoint,channel_type type) 
{
  uint16_t sn,se;
  uint16_t rn,re;
  mcapi_boolean_t rv = MCAPI_FALSE;
  
  /* the database should already be locked */

  rv = mcapi_trans_decode_handle_internal(send_endpoint,&sn,&se);
  //assert(rv);
  rv = mcapi_trans_decode_handle_internal(receive_endpoint,&rn,&re);
  //assert(rv);

  /* update the send endpoint */
  c_db->nodes[sn].node_d.endpoints[se].connected = MCAPI_TRUE;
  c_db->nodes[sn].node_d.endpoints[se].recv_queue.recv_endpt = receive_endpoint;
  c_db->nodes[sn].node_d.endpoints[se].recv_queue.send_endpt = send_endpoint; 
  c_db->nodes[sn].node_d.endpoints[se].recv_queue.channel_type = type;

  /* update the receive endpoint */
  c_db->nodes[rn].node_d.endpoints[re].connected = MCAPI_TRUE;
  c_db->nodes[rn].node_d.endpoints[re].recv_queue.send_endpt = send_endpoint;
  c_db->nodes[rn].node_d.endpoints[re].recv_queue.recv_endpt = receive_endpoint;
  c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type = type;


  mcapi_dprintf(1," channel_type=%d connected sender (node=%d,port=%d) to receiver (node=%d,port=%d)\n", 
                type,c_db->nodes[sn].node_num,c_db->nodes[sn].node_d.endpoints[se].port_num,
                c_db->nodes[rn].node_num,c_db->nodes[rn].node_d.endpoints[re].port_num);
  
}

/***************************************************************************
  NAME:mcapi_trans_send_internal
  DESCRIPTION: Attempts to send a message from one endpoint to another
  PARAMETERS: 
    sn - the send node index (only used for verbose debug print)
    se - the send endpoint index (only used for verbose debug print)
    rn - the receive node index
    re - the receive endpoint index
    buffer -
    buffer_size -
    blocking - whether or not this is a blocking send (currently not used!)
  RETURN VALUE: true/false indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_send_internal (
    uint16_t sn,uint16_t se, uint16_t rn, uint16_t re, 
    char* buffer, size_t buffer_size,mcapi_boolean_t blocking,uint64_t scalar)
{
  int qindex,i;
  buffer_entry* db_buff = NULL;
  
  mcapi_dprintf(3," mcapi_trans_send_internal sender (node=%d,port=%d) to receiver (node=%d,port=%d)\n", 
                c_db->nodes[sn].node_num,c_db->nodes[sn].node_d.endpoints[se].port_num,
                c_db->nodes[rn].node_num,c_db->nodes[rn].node_d.endpoints[re].port_num);

  /* The database should already be locked! */

  /* Note: the blocking parameter is not used.
     I'm not sure if I'm implementing blocking sends correctly.  They can still 
     return ENO_BUFFER, so it doesn't look from the spec like they are supposed to block 
     until a buffer is free.  A blocking receive blocks on an empty queue until there is 
     something available, but a blocking send does not block on a full queue.  Is that correct? */
  if (mcapi_trans_full_queue(c_db->nodes[rn].node_d.endpoints[re].recv_queue)) {
    /* we couldn't get space in the endpoints receive queue, try to compact the queue */
    mcapi_trans_compact_queue(&c_db->nodes[rn].node_d.endpoints[re].recv_queue);
    return MCAPI_FALSE;
  }
     
  /* find a free mcapi buffer (we only have to worry about this on the sending side) */
  for (i = 0; i < MAX_BUFFERS; i++) {
    if (!c_db->buffers[i].in_use) {
      c_db->buffers[i].in_use = MCAPI_TRUE;
      c_db->buffers[i].magic_num = MAGIC_NUM;
      db_buff = &c_db->buffers[i];
      break;
    }
  }
  if (i == MAX_BUFFERS) {
    /* we couldn't get a free buffer */
    mcapi_dprintf(2," ERROR mcapi_trans_send_internal: No more buffers available - try freeing some buffers. \n");
    return MCAPI_FALSE;
  }

  /* now go about updating buffer into the database... */
  /* find the next index in the circular queue */
  qindex = mcapi_trans_push_queue(&c_db->nodes[rn].node_d.endpoints[re].recv_queue);
  mcapi_dprintf(4," send pushing %u byte buffer to qindex=%i, num_elements=%i, head=%i, tail=%i\n",
                buffer_size,qindex,c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements,
                c_db->nodes[rn].node_d.endpoints[re].recv_queue.head,
                c_db->nodes[rn].node_d.endpoints[re].recv_queue.tail);
  /* printf(" send pushing to qindex=%i\n",qindex); */ 
  if (c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_SCL_CHAN ) {
    db_buff->scalar = scalar;
  } else {
    /* copy the buffer parm into a mcapi buffer */
    memcpy (db_buff->buff,buffer,buffer_size);
  }
  /* set the size */
  db_buff->size = buffer_size;
  /* update the ptr in the receive_endpoints queue to point to our mcapi buffer */
  c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b = db_buff;

  
  return MCAPI_TRUE;
}

/***************************************************************************
  NAME:  mcapi_trans_recv_internal_
  DESCRIPTION: Removes a message (at the given qindex) from the given 
    receive endpoints queue.  This function is used both by check_receive_request
    and mcapi_trans_recv_internal.  We needed to separate the functionality
    because in order to preserve FIFO, if recv was called to an empty queue we
    had to set a reservation at the head of the queue.  Thus we can't always
    just pop from the head of the queue.
  PARAMETERS: 
    rn - the receive node index
    re - the receive endpoint index
    buffer -
    buffer_size -
    received_size - the actual size (in bytes) of the data received
    qindex - index into the receive endpoints queue that we should remove from
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_recv_internal_ (
    uint16_t rn, uint16_t re, void** buffer, size_t buffer_size,
    size_t* received_size,int qindex,uint64_t* scalar)
{
/*   size_t size; */
/*   int i; */

/*   /\* the database should already be locked! *\/ */
  
/*   mcapi_dprintf(3," mcapi_trans_recv_internal_ for receiver (node=%d,port=%d)\n",  */
/*                 c_db->nodes[rn].node_num,c_db->nodes[rn].node_d.endpoints[re].port_num); */
  
/*   /\* printf(" recv popping from qindex=%i\n",qindex); *\/ */
/*   /\* first make sure buffer is big enough for the message *\/ */
/*   if ((buffer_size) < c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->size) { */
/*     fprintf(stderr,"ERROR: mcapi_trans_recv_internal buffer not big enough - loss of data: buffer_size=%i, element_size=%i\n", */
/*             (int)buffer_size, */
/*             (int)c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->size); */
/*     /\* NOTE: MCAPI_ETRUNCATED will be set by the calling functions by noticing that buffer_size < received_size *\/ */
/*   } */
  
/*   /\* set the size *\/ */
/*   size = c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->size; */
  
/*   /\* fill in the size *\/ */
/*   *received_size = size; */
/*   if (buffer_size < size) { */
/*     size = buffer_size; */
/*   }  */
 
/*   mcapi_dprintf(4," receive popping %u byte buffer from qindex=%i, num_elements=%i, head=%i, tail=%i\n", */
/*                 size,qindex,c_db->nodes[rn].node_d.endpoints[re].recv_queue.num_elements, */
/*                 c_db->nodes[rn].node_d.endpoints[re].recv_queue.head, */
/*                 c_db->nodes[rn].node_d.endpoints[re].recv_queue.tail); */
 
/*   /\* copy the buffer out of the receive_endpoint's queue and into the buffer parm *\/ */
/*   if (c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_PKT_CHAN) { */
/*     /\* mcapi supplied buffer (pkt receive), so just update the pointer *\/ */
/*     *buffer = c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->buff; */
/*   } else { */
/*     /\* user supplied buffer, copy it in and free the mcapi buffer *\/ */
/*     if   (c_db->nodes[rn].node_d.endpoints[re].recv_queue.channel_type == MCAPI_SCL_CHAN) { */
/*       /\* scalar receive *\/ */
/*       *scalar = c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->scalar; */
/*     } else { */
/*       /\* msg receive *\/ */
/*       memcpy (*buffer,c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->buff,size); */
/*     } */
/*     /\* free the mcapi message buffer *\/ */
/*     for (i = 0; i < MAX_BUFFERS; i++) { */
/*       if ((c_db->buffers[i].in_use) &&  */
/*           (c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b->buff ==  */
/*            c_db->buffers[i].buff)) { */
/*         c_db->buffers[i].in_use = MCAPI_FALSE; */
/*         break; */
/*       } */
/*       /\* we should have found it *\/ */
/*       //assert (i != MAX_BUFFERS); */
/*     } */
/*   } */
/*   /\* clear the buffer pointer in the receive queue entry *\/ */
/*   c_db->nodes[rn].node_d.endpoints[re].recv_queue.elements[qindex].b = NULL; */

}

/***************************************************************************
  NAME: mcapi_trans_recv_internal
  DESCRIPTION: checks if a message is available, if so performs the pop (from
   the head of the queue) and sends the qindex to be used to mcapi_trans_recv_internal_ 
  PARAMETERS: 
    rn - the receive node index
    re - the receive endpoint index
    buffer -
    buffer_size -
    received_size - the actual size (in bytes) of the data received
    blocking - whether or not this is a blocking receive
  RETURN VALUE: true/false indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_recv_internal (
    uint16_t rn, uint16_t re, void** buffer, 
    size_t buffer_size, size_t* received_size,
    mcapi_boolean_t blocking,uint64_t* scalar)
{
  int qindex;
  
  /* The database should already be locked! */
  
  if ((!blocking) && (mcapi_trans_empty_queue(c_db->nodes[rn].node_d.endpoints[re].recv_queue))) {
    return MCAPI_FALSE;
  } 
  
  while (mcapi_trans_empty_queue(c_db->nodes[rn].node_d.endpoints[re].recv_queue)) {
    mcapi_dprintf(5,"mcapi_trans_recv_internal to empty queue - attempting to yield\n");
    /* we have the lock, use this yield */
    transport_sm_yield_internal();
  }
  
  /* remove the element from the receive endpoints queue */
  qindex = mcapi_trans_pop_queue(&c_db->nodes[rn].node_d.endpoints[re].recv_queue);
  mcapi_trans_recv_internal_ (rn,re,buffer,buffer_size,received_size,qindex,scalar);

  return MCAPI_TRUE;
}

/***************************************************************************
  NAME: mcapi_trans_open_channel_internal
  DESCRIPTION: marks the given endpoint as open
  PARAMETERS: 
    n - the node index
    e - the endpoint index
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_open_channel_internal (uint16_t n, uint16_t e) 
{
  
  /* The database should already be locked! */

  /* mark the endpoint as open */
  c_db->nodes[n].node_d.endpoints[e].open = MCAPI_TRUE;
  
}

/***************************************************************************
  NAME:mcapi_trans_close_channel_internal
  DESCRIPTION: marks the given endpoint as closed
  PARAMETERS: 
    n - the node index
    e - the endpoint index
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_close_channel_internal (uint16_t n, uint16_t e) 
{
  
  /* The database should already be locked! */
  
  /* mark the endpoint as closed */
  c_db->nodes[n].node_d.endpoints[e].open = MCAPI_FALSE;
}

/***************************************************************************
  NAME:transport_sm_yield_internal
  DESCRIPTION: releases the lock, attempts to yield, re-acquires the lock.
  PARAMETERS: none
  RETURN VALUE: none
***************************************************************************/
void transport_sm_yield_internal () 
{  
  /* call this version of sched_yield when you have the lock */
  /* release the lock */
  // mcapi_trans_access_database_post();
  //sched_yield();
  /* re-acquire the lock */
  // mcapi_trans_access_database_pre();
}

/***************************************************************************
  NAME:  mcapi_trans_access_database_pre_nocheck
  DESCRIPTION: The first node that calls initialize can't do the balanced
    lock/unlock checking because it hasn't registered itself yet.  Thus
    the need for a nocheck version of this function.  This function
    acquires the semaphore.
  PARAMETERS: none
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_access_database_pre_nocheck () 
{
  /* acquire the semaphore, this is a blocking function */
  //transport_sm_lock_semaphore(sem_id);
}

/***************************************************************************
  NAME: mcapi_trans_access_database_pre
  DESCRIPTION: This function acquires the semaphore.
  PARAMETERS: none
  RETURN VALUE:none
***************************************************************************/
void mcapi_trans_access_database_pre () 
{
/*   int i = 0; */
/*   int pid = 0; */
/*   pthread_t tid = 0; */
  
/*   /\* first acquire the semaphore, this is a blocking function *\/ */
/*   transport_sm_lock_semaphore(sem_id); */
  
/*   if (mcapi_debug > 5) { */
/*     /\* turn on balanced semaphore lock/unlock checking *\/ */
/*     i = get_private_data_index(); */
/*     assert (d[i].have_lock == MCAPI_FALSE); */
/*     pid = d[i].pid; */
/*     tid = d[i].tid; */
/*     d[i].have_lock = MCAPI_TRUE; */
/*     mcapi_dprintf(7," PID:%d TID%u got lock\n",pid,(unsigned long)tid); */
/*   } */

}

/***************************************************************************
  NAME:mcapi_trans_access_database_post_nocheck
  DESCRIPTION:The first node that calls initialize can't do the balanced
    lock/unlock checking because it hasn't registered itself yet.  Thus
    the need for a nocheck version of this function.  This function
    releases the semaphore.
  PARAMETERS: none
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_access_database_post_nocheck () 
{
  /* release the semaphore, this should always work */
  //assert (transport_sm_unlock_semaphore(sem_id));
}

/***************************************************************************
  NAME:mcapi_trans_access_database_post
  DESCRIPTION: This function releases the semaphore.
  PARAMETERS: none
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_access_database_post () 
{
  /* int i = 0; */
/*   int pid = 0;; */
/*   pthread_t tid = 0; */
  
/*   if (mcapi_debug > 5) { */
/*     /\* turn on balanced semaphore lock/unlock checking *\/ */
/*     i = get_private_data_index(); */
/*     assert (d[i].have_lock == MCAPI_TRUE); */
/*     pid = d[i].pid; */
/*     tid = d[i].tid;    */
/*     d[i].have_lock = MCAPI_FALSE; */
/*     mcapi_dprintf(7," PID:%d TID%u released lock\n",pid,(unsigned long)tid); */
/*   } */
  
/*   /\* finally, release the semaphore, this should always work *\/ */
/*   assert (transport_sm_unlock_semaphore(sem_id)); */
  
}

/***************************************************************************
  NAME:mcapi_trans_add_node
  DESCRIPTION: Adds a node to the database (called by intialize)
  PARAMETERS: node_num
  RETURN VALUE: true/false indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_add_node (mcapi_uint_t node_num) 
{
  mcapi_boolean_t rc = MCAPI_TRUE;

  /* lock the database */
  //mcapi_trans_access_database_pre_nocheck();

  /* mcapi should have checked that the node doesn't already exist */

  if (c_db->num_nodes == MAX_NODES) {
    rc = MCAPI_FALSE;
  }

  if (rc) {
  /* setup our local (private data) */
  /* we do this while we have the lock because we don't want an inconsistency/
     race condition where the node exists in the database but not yet in
     the transport layer's cached state */
    mcapi_trans_set_node_num(node_num);
 
    /* add the node */
    c_db->nodes[c_db->num_nodes].finalized = MCAPI_FALSE;  
    c_db->nodes[c_db->num_nodes].valid = MCAPI_TRUE;  
    c_db->nodes[c_db->num_nodes].node_num = node_num;
    c_db -> num_nodes++;
  }

  /* unlock the database */
  // mcapi_trans_access_database_post_nocheck();

  return rc;
}

/***************************************************************************
  NAME:mcapi_trans_encode_handle_internal 
  DESCRIPTION:
   Our handles are very simple - a 32 bit integer is encoded with 
   an index (16 bits gives us a range of 0:64K indices).
   Currently, we only have 2 indices for each of: node array and
   endpoint array.
  PARAMETERS: 
   node_index -
   endpoint_index -
  RETURN VALUE: the handle
***************************************************************************/
uint32_t mcapi_trans_encode_handle_internal (uint16_t node_index,uint16_t endpoint_index) 
{
  /* The database should already be locked */
  uint32_t handle = 0;
  uint8_t shift = 16;

  //assert ((node_index < MAX_NODES) && (endpoint_index < MAX_ENDPOINTS));

  handle = node_index;
  handle <<= shift;
  handle |= endpoint_index;

  return handle;
}

/***************************************************************************
  NAME:mcapi_trans_decode_handle_internal
  DESCRIPTION: Decodes the given handle into it's database indices
  PARAMETERS: 
   handle -
   node_index -
   endpoint_index -
  RETURN VALUE: true/false indicating success or failure
***************************************************************************/
mcapi_boolean_t mcapi_trans_decode_handle_internal (uint32_t handle, uint16_t *node_index,
                                                    uint16_t *endpoint_index) 
{
  //int rc = MCAPI_FALSE;
  uint8_t shift = 16;
  
  /* The database should already be locked */
  *node_index              = (handle & 0xffff0000) >> shift;
  *endpoint_index          = (handle & 0x0000ffff);

  if (*node_index >= MAX_NODES || *endpoint_index >= MAX_ENDPOINTS) {
      return MCAPI_FALSE;
  }

  if (*node_index == my_node_id && 
      !(c_db->nodes[*node_index].node_d.endpoints[*endpoint_index].valid)) {
      return MCAPI_FALSE;
  }
  return MCAPI_TRUE;
}

/***************************************************************************
  NAME: mcapi_trans_set_node_num
  DESCRIPTION: sets the node_num
  PARAMETERS: n: the node_num
  RETURN VALUE: boolean indicating success (there was room in our data array) or failure 
   (couldn't find a free entry to set the node_num)
***************************************************************************/
mcapi_boolean_t mcapi_trans_set_node_num(mcapi_uint_t n) 
{
 /*  /\* note: an optimization to searching this structure would be for */
/*      mcapi_initialize to return a handle that we could just use to  */
/*      index.  *\/ */
/*   int i; */
 
/*   for (i = 0; i < MAX_ENDPOINTS; i++) { */
/*     /\* assume pid=0 means this entry is not being used *\/ */
/*     if (!d[i].pid) { */
/*       d[i].pid = getpid(); */
/*       d[i].tid = pthread_self(); */
/*       d[i].node_num = n; */

/*       mcapi_dprintf(1," Adding node: NODE:%u PID:%u TID:%u\n",n,(int)d[i].pid, */
/*                     (unsigned long)d[i].tid); */
      
/*       return MCAPI_TRUE; */
/*     } */
/*   } */
/*   assert(!"we should never get here"); */
  return MCAPI_FALSE;
}

/***************************************************************************
  NAME: mcapi_trans_get_node_index
  DESCRIPTION: Returns the index into our database corresponding to the node_num
  PARAMETERS: n: the node_num
  RETURN VALUE: 
***************************************************************************/
mcapi_boolean_t mcapi_trans_get_node_index(mcapi_uint_t node_num) 
{
 /*  /\* look up the node *\/ */
/*   int i; */
/*   uint32_t node_index = MAX_NODES; */
/*   for (i = 0; i < c_db->num_nodes; i++) { */
/*     if (c_db->nodes[i].node_num == node_num) { */
/*       node_index = i; */
/*       break; */
/*     } */
/*   } */
/*   assert (node_index != MAX_NODES); */
   return node_num;
}































//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                   queue management                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
/***************************************************************************
  NAME: print_queue
  DESCRIPTION: Prints an endpoints receive queue (useful for debugging)
  PARAMETERS: q - the queue
  RETURN VALUE: none
***************************************************************************/
void print_queue (queue q) 
{
#ifdef __TCE__
  return;
#else
  int i,qindex;
  /*print the recv queue from head to tail*/
  printf("      recv_queue:\n");
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    /* walk the queue from the head to the tail */
    qindex = (q.head + i) % (MAX_QUEUE_ENTRIES);   
    printf("          ----------------QINDEX: %i",qindex);
    if (q.head == qindex) { printf("           *** HEAD ***"); }
    if (q.tail == qindex) { printf("           *** TAIL ***"); }
    printf("\n          request:0x%lx\n",(long unsigned int)q.elements[qindex].request);
    if (q.elements[qindex].request) {
      printf("             valid:%u\n",q.elements[qindex].request->valid);
      printf("             size:%u\n",(int)q.elements[qindex].request->size);
      switch (q.elements[qindex].request->type) {
      case (OTHER_REQUEST): printf("             type:OTHER\n"); break;
      case (SEND): printf("             type:SEND\n"); break;
      case (RECV): printf("             type:RECV\n"); break;
      case (GET_ENDPT): printf("             type:GET_ENDPT\n"); break;
      default:  printf("             type:UNKNOWN!!!\n"); break;
      };
      printf("             buffer:[%s]\n",(char*)q.elements[qindex].request->buffer);
      printf("             buffer_ptr:0x%lx\n",(long unsigned int)q.elements[qindex].request->buffer_ptr);
      printf("             completed:%u\n",q.elements[qindex].request->completed);
      printf("             cancelled:%u\n",q.elements[qindex].request->cancelled);
      printf("             handle:0x%i\n",(int)q.elements[qindex].request->handle);
      /*   printf("             status:%s\n",mcapi_display_status(q.elements[qindex].request->status)); */
      printf("             status:%i\n",(int)q.elements[qindex].request->status);
      printf("             endpoint:0x%lx\n",(long unsigned int)q.elements[qindex].request->endpoint);
    }
    printf("          invalid:%u\n",q.elements[qindex].invalid);
    
    printf("          b:0x%lx\n",(long unsigned int)q.elements[qindex].b);
    if (q.elements[qindex].b) {
      printf("             size:%u\n",(unsigned)q.elements[qindex].b->size);
      printf("             in_use:%u\n",q.elements[qindex].b->in_use);
      printf("             buff:[%s]\n\n",(char*)q.elements[qindex].b->buff);
    }
  }   
#endif
}

/***************************************************************************
  NAME: push_queue
  DESCRIPTION: Returns the qindex that should be used for adding an element.
     Also updates the num_elements, and tail pointer.
  PARAMETERS: q - the queue pointer
  RETURN VALUE: the qindex to be used
***************************************************************************/
int mcapi_trans_push_queue(queue* q) 
{
  int i;
  
  if ( (q->tail + 1) % MAX_QUEUE_ENTRIES == q->head) {
    /* assert (q->num_elements ==  MAX_QUEUE_ENTRIES);*/
    //assert(!"push_queue called on full queue\n");
  }
  q->num_elements++;
  i = q->tail;
  q->tail = ++q->tail % MAX_QUEUE_ENTRIES;
  //assert (q->head != q->tail);
  return i;
}

/***************************************************************************
  NAME: pop_queue
  DESCRIPTION: Returns the qindex that should be used for removing an element.
     Also updates the num_elements, and head pointer.  
  PARAMETERS: q - the queue pointer
  RETURN VALUE: the qindex to be used
***************************************************************************/
int mcapi_trans_pop_queue (queue* q) 
{
  int i,qindex;
  int x = 0;

  if (q->head == q->tail) {
    /*assert (q->num_elements ==  0);*/
    //assert (!"pop_queue called on empty queue\n");
  }
  
  /* we can't just pop the first element off the head of the queue, because it
     may be reserved for an earlier recv call, we need to take the first element
     that doesn't already have a request associated with it.  This can fragment
     our queue. */
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    /* walk the queue from the head to the tail */
    qindex = (q->head + i) % (MAX_QUEUE_ENTRIES); 
    if ((!q->elements[qindex].request) &&
        (q->elements[qindex].b)){   
      x = qindex;
      break;
    }      
  }
  if (i == MAX_QUEUE_ENTRIES) {
    /* all of this endpoint's buffers already have requests associated with them */
    //assert(0); /* mcapi_trans_empty_queue should have already checked for this case */
  }

  q->num_elements--;

  /* if we are removing from the front of the queue, then move head */
  if (x == q->head) {
    q->head = ++q->head % MAX_QUEUE_ENTRIES; 
  } else {
    /* we are fragmenting the queue, mark this entry as invalid */
    q->elements[qindex].invalid = MCAPI_TRUE;
  }

  if (q->num_elements > 0) {
    //assert (q->head != q->tail);
  }

  mcapi_trans_compact_queue (q);

  return x;
}

/***************************************************************************
  NAME: compact_queue
  DESCRIPTION: Attempts to compact the queue.  It can become fragmented based 
     on the order that blocking/non-blocking sends/receives/tests come in
  PARAMETERS: q - the queue pointer
  RETURN VALUE: none
***************************************************************************/
void mcapi_trans_compact_queue (queue* q) 
{
  int i;
  int qindex;

  mcapi_dprintf(7,"before mcapi_trans_compact_queue head=%i,tail=%i,num_elements=%i\n",q->head,q->tail,q->num_elements);
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    qindex = (q->head + i) % (MAX_QUEUE_ENTRIES); 
    if ((qindex == q->tail) || 
        (q->elements[qindex].request) || 
        (q->elements[qindex].b)){ 
      break;
    } else {
      /* advance the head pointer */ 
      q->elements[qindex].invalid = MCAPI_FALSE;
      q->head = ++q->head % MAX_QUEUE_ENTRIES; 
      i--;
    } 
  }
  mcapi_dprintf(7,"after mcapi_trans_compact_queue head=%i,tail=%i,num_elements=%i\n",q->head,q->tail,q->num_elements);
  if (q->num_elements > 0) {
    //assert (q->head != q->tail);
  }

}


/***************************************************************************
  NAME: mcapi_trans_empty_queue
  DESCRIPTION: Checks if the queue is empty or not
  PARAMETERS: q - the queue 
  RETURN VALUE: true/false
***************************************************************************/
mcapi_boolean_t mcapi_trans_empty_queue (queue q) 
{
  int i,qindex;
  if  (q.head == q.tail) {
    /* assert (q.num_elements ==  0); */
    return MCAPI_TRUE;
  }
  
  /* if we have any buffers in our queue that don't have
     reservations, then our queue is non-empty */
  for (i = 0; i < MAX_QUEUE_ENTRIES; i++) {
    qindex = (q.head + i) % (MAX_QUEUE_ENTRIES); 
    if ((!q.elements[qindex].request) && 
        (q.elements[qindex].b)){ 
      break;
    }
  }
  if (i == MAX_QUEUE_ENTRIES) {
    return MCAPI_TRUE;
  }

  return MCAPI_FALSE;
}

/***************************************************************************
  NAME: mcapi_trans_full_queue
  DESCRIPTION: Checks if the queue is full or not
  PARAMETERS: q - the queue 
  RETURN VALUE: true/false
***************************************************************************/
mcapi_boolean_t mcapi_trans_full_queue (queue q) 
{  
  if ( (q.tail + 1) % MAX_QUEUE_ENTRIES == q.head) {
    /*  assert (q.num_elements ==  (MAX_QUEUE_ENTRIES -1)); */
    return MCAPI_TRUE;
  }
  return MCAPI_FALSE;
}
 








