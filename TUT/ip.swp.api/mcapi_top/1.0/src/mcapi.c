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

#include <mcapi.h>
#include <mcapi_trans.h>
#include <mcapi_config.h> /* for MCAPI version */

#include <string.h> /* for strncpy */


/* FIXME: (errata B5) anyone can get an endpoint handle and call receive on it.  should
   this be an error?  It seems like only the node that owns the receive
   endpoint should be able to call receive. */


/* The following 3 functions are useful for debugging but are not part of the spec */
char* mcapi_display_status (mcapi_status_t status) {
 switch (status) {
 case (MCAPI_INCOMPLETE):     return "MCAPI_INCOMPLETE"; break;
 case (MCAPI_SUCCESS):        return "MCAPI_SUCCESS"; break;
 case (MCAPI_ENO_INIT):       return "MCAPI_ENO_INIT"; break;     
 case (MCAPI_EMESS_LIMIT):    return "MCAPI_EMESS_LIMIT"; break;   
 case (MCAPI_ENO_BUFFER):     return "MCAPI_ENO_BUFFER"; break;    
 case (MCAPI_ENO_REQUEST):    return "MCAPI_ENO_REQUEST"; break;  
 case (MCAPI_ENO_MEM):        return "MCAPI_ENO_MEM"; break;     
 case (MCAPI_ENO_FINAL):      return "MCAPI_ENO_FINAL"; break;   
 case (MCAPI_ENODE_NOTINIT):  return "MCAPI_ENODE_NOTINIT"; break; 
 case (MCAPI_EEP_NOTALLOWED): return "MCAPI_EEP_NOTALLOWED"; break;
 case (MCAPI_EPORT_NOTVALID): return "MCAPI_EPORT_NOTVALID"; break; 
 case (MCAPI_ENODE_NOTVALID): return "MCAPI_ENODE_NOTVALID"; break;
 case (MCAPI_ENOT_OWNER):     return "MCAPI_ENOT_OWNER"; break; 
 case (MCAPI_ECHAN_OPEN):     return "MCAPI_ECHAN_OPEN"; break;
 case (MCAPI_ENO_ENDPOINT):   return "MCAPI_ENO_ENDPOINT"; break;
 case (MCAPI_ECONNECTED):     return "MCAPI_ECONNECTED"; break;   
 case (MCAPI_EATTR_INCOMP):   return "MCAPI_EATTR_INCOMP"; break;
 case (MCAPI_ECHAN_TYPE):     return "MCAPI_ECHAN_TYPE"; break;   
 case (MCAPI_EDIR):           return "MCAPI_EDIR"; break;        
 case (MCAPI_ENOT_HANDLE):    return "MCAPI_ENOT_HANDLE"; break; 
 case (MCAPI_ENOT_ENDP):      return "MCAPI_ENOT_ENDP"; break; 
 case (MCAPI_EPACK_LIMIT):    return "MCAPI_EPACK_LIMIT"; break;
 case (MCAPI_ENOT_VALID_BUF): return "MCAPI_ENOT_VALID_BUF"; break;
 case (MCAPI_ENOT_OPEN):      return "MCAPI_ENOT_OPEN"; break; 
 case (MCAPI_EREQ_CANCELED):  return "MCAPI_EREQ_CANCELED"; break; 
 case (MCAPI_ENOTREQ_HANDLE): return "MCAPI_ENOTREQ_HANDLE"; break; 
 case (MCAPI_EENDP_ISCREATED):return "MCAPI_EENDP_ISCREATED"; break; 
 case (MCAPI_EENDP_LIMIT):    return "MCAPI_EENDP_LIMIT"; break; 
 case (MCAPI_ENOT_CONNECTED): return "MCAPI_ENOT_CONNECTED"; break; 
 case (MCAPI_ESCL_SIZE):      return "MCAPI_ESCL_SIZE"; break; 
 case (MCAPI_EPRIO):          return "MCAPI_EPRIO"; break; 
 case (MCAPI_INITIALIZED):    return "MCAPI_INITIALIZED"; break;
 case (MCAPI_EPARAM):         return "MCAPI_EPARAM"; break;
 case (MCAPI_ETRUNCATED):     return "MCAPI_ETRUNCATED"; break;
 case (MCAPI_EREQ_TIMEOUT):   return "MCAPI_EREQ_TIMEOUT"; break;
 default : return "UNKNOWN";
 };
}

void mcapi_set_debug_level (int d) {
  mcapi_trans_set_debug_level (d);
}

void mcapi_display_state (void* handle) {
  mcapi_trans_display_state(handle);
}


/***********************************************************************
NAME
mcapi_initialize - Initializes the MCAPI implementation.
DESCRIPTION
mcapi_initialize() initializes the MCAPI environment on a given MCAPI node. 
It has to be called by each node using MCAPI.  mcapi_version is set to the 
to the implementation version number. A node is a process, a thread, or a 
processor (or core) with an independent program counter running a piece 
of code. In other words, an MCAPI node is an independent thread of 
control. An MCAPI node can call mcapi_initialize() once per node, and it 
is an error to call mcapi_initialize() multiple times from a given node. 
A given MCAPI implementation will specify what is a node (i.e., what 
thread of control - process, thread, or other -- is a node)  in that  
implementation. A thread and process are just two examples of threads 
of control, and there could be other. 
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENO_INIT The MCAPI environment could not be initialized.
MCAPI_INITIALIZED The MCAPI environment has already been initialized.
MCAPI_ENODE_NOTVALID The parameter is not a valid node.
MCAPI_EPARAM Incorrect mcapi_status or mcapi_version parameter.
NOTE
SEE ALSO 
mcapi_finalize()	
************************************************************************/
void mcapi_initialize(
                      MCAPI_IN mcapi_node_t node_id, 
                      MCAPI_OUT mcapi_version_t* mcapi_version, 
                      MCAPI_OUT mcapi_status_t* mcapi_status)
{
  if (!valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (!valid_version_param(mcapi_version)) {
      *mcapi_status = MCAPI_EPARAM;
    } else {
      (void)strncpy(*mcapi_version,MCAPI_VERSION,sizeof(MCAPI_VERSION));
      if (!mcapi_trans_valid_node(node_id)) {
        *mcapi_status = MCAPI_ENODE_NOTVALID;
      } else if (mcapi_trans_initialized(node_id)) {
        *mcapi_status = MCAPI_INITIALIZED;
      } else if (!mcapi_trans_initialize(node_id)) {
        *mcapi_status = MCAPI_ENO_INIT;
      } 
    }
  }
}

/***********************************************************************
NAME
mcapi_finalize - Finalizes the MCAPI implementation.
DESCRIPTION
mcapi_finalize() finalizes the MCAPI environment on a given MCAPI node. 
It has to be called by each node using MCAPI.  It is an error to call 
mcapi_finalize() without first calling mcapi_initialize().  An MCAPI 
node can call mcapi_finalize() once for each call to 
mcapi_initialize(), but it is an error to call mcapi_finalize() 
multiple times from a given node unless mcapi_initialize() has been 
called prior to each mcapi_finalize() call.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENO_FINAL The MCAPI environment could not be finalized.
MCAPI_EPARAM  Incorrect mcapi_status_ parameter.
NOTE
SEE ALSO
   mcapi_initialize()
************************************************************************/
void mcapi_finalize(
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_finalize()) {
      *mcapi_status = MCAPI_ENO_FINAL;
    }
  }
}

/***********************************************************************
NAME
mcapi_get_node_id - return the node number associated with the local node
DESCRIPTION
Returns the node id associated with the local node.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENODE_NOTINIT The node is not initialized.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO 
************************************************************************/
mcapi_uint_t mcapi_get_node_id(
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  mcapi_uint_t node;
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if  (!mcapi_trans_get_node_num(&node)) {
      *mcapi_status = MCAPI_ENODE_NOTINIT;
    } 
  }
  
  return node;
}

/***********************************************************************
NAME
mcapi_create_endpoint - create an endpoint.
DESCRIPTION
mcapi_create_endpoint() is used to create endpoints, using the node_id 
of the local node calling the API function and specific port_id, 
returning a reference to a globally unique endpoint which can later be 
referenced by name using mcapi_get_endpoint() (see Section 4.2.3).  The 
port_id can be set to MCAPI_PORT ANY to request the next available 
endpoint on the local node. 
MCAPI supports a simple static naming scheme to create endpoints based 
on global tuple names. Other nodes can access the created endpoint by 
calling mcapi_get_endpoint() and specifying the appropriate node and 
port id's. Enpoints can be passed on to other endpoints and an 
endpoint created using MCAPI_PORT ANY has to be passed on to other 
endpoints by the creator, to facilitate communication.
Static naming allows the programmer to define an MCAPI communication 
topology at compile time.  This facilitates simple initialization. 
Section 7.1 illustrates an example of initialization and bootstrapping 
using static naming. Creating endpoints using MCAPI_PORT ANY provides 
a convenient method to create endpoints without having to specify the 
port_id. 
RETURN VALUE
On success, an endpoint is returned and *mcapi_status is set to 
MCAPI_SUCCESS. On error, MCAPI_NULL is returned and *mcapi_status is 
set to the appropriate error defined below.
ERRORS
MCAPI_EPORT_NOTVALID The parameter is not a valid port.
MCAPI_EENDP_ISCREATED  The endpoint is already created.
MCAPI_ENODE_NOTINIT The node is not initialized.
MCAPI_EENDP_LIMIT Exceeded maximum number of endpoints allowed.
MCAPI_EEP_NOTALLOWED Endpoints cannot be created on this node.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The node number can only be set using the mcapi_intialize() function.
SEE ALSO
   mcapi_initialize() 
************************************************************************/
mcapi_endpoint_t mcapi_create_endpoint(
 	MCAPI_IN mcapi_port_t port_id, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  mcapi_endpoint_t e;
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (mcapi_trans_endpoint_exists (port_id)) {
      *mcapi_status = MCAPI_EENDP_ISCREATED;
    } else if (mcapi_trans_num_endpoints () == MAX_ENDPOINTS) {
      *mcapi_status = MCAPI_EENDP_LIMIT;
    } else if (!mcapi_trans_valid_port(port_id)) {
      *mcapi_status = MCAPI_EPORT_NOTVALID;  
    } else if (!mcapi_trans_create_endpoint(&e,port_id,MCAPI_FALSE))  {
      *mcapi_status = MCAPI_EEP_NOTALLOWED;
    }
  }
  return e;
}


/***********************************************************************
NAME
mcapi_get_endpoint_i - obtain the endpoint associated with a given tuple.
DESCRIPTION
mcapi_get_endpoint_i() allows other nodes ("third parties") to get the 
endpoint identifier for the endpoint associated with a global tuple name 
<node_id, port_id>.  This function is non-blocking and will return 
immediately.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_EPORT_NOTVALID The parameter is not a valid port.
MCAPI_ENODE_NOTVALID The parameter is not a valid node.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
Use the mcapi_test(), mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO
  mcapi_get_node_id() 
************************************************************************/
void mcapi_get_endpoint_i(
                          MCAPI_IN mcapi_node_t node_id, 
                          MCAPI_IN mcapi_port_t port_id, 
                          MCAPI_OUT mcapi_endpoint_t* endpoint, 
                          MCAPI_OUT mcapi_request_t* request, 
                          MCAPI_OUT mcapi_status_t* mcapi_status)
{
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_node (node_id)){
      *mcapi_status = MCAPI_ENODE_NOTVALID;
    } else if ( ! mcapi_trans_valid_port (port_id)) {
      *mcapi_status = MCAPI_EPORT_NOTVALID;
    } 
    mcapi_trans_get_endpoint_i (endpoint,node_id,port_id,request,mcapi_status); 
  }
}

/***********************************************************************
NAME
mcapi_get_endpoint - obtain the endpoint associated with a given tuple.
DESCRIPTION
mcapi_get_endpoint() allows other nodes ("third parties") to get the 
endpoint identifier for the endpoint associated with a global tuple name 
<node_id, port_id>.  This function will block until the specified remote 
endpoint has been created via the mcapi_create_endpoint() call. 
RETURN VALUE
On success, an endpoint is returned and *mcapi_status is set to 
MCAPI_SUCCESS. On error, MCAPI_NULL is returned and *mcapi_status is set 
to the appropriate error defined below.
ERRORS
MCAPI_EPORT_NOTVALID The parameter is not a valid port.
MCAPI_ENODE_NOTVALID The parameter is not a valid node.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO 
************************************************************************/
mcapi_endpoint_t mcapi_get_endpoint(
 	MCAPI_IN mcapi_node_t node_id, 
 	MCAPI_IN mcapi_port_t port_id, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{ 
  mcapi_endpoint_t e;

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_node (node_id)){
      *mcapi_status = MCAPI_ENODE_NOTVALID;
    } else if ( ! mcapi_trans_valid_port (port_id)) {
      *mcapi_status = MCAPI_EPORT_NOTVALID;
    } else {
      mcapi_trans_get_endpoint (&e,node_id,port_id);
    }
  }
  
  return e;
}

/***********************************************************************
NAME
mcapi_delete_endpoint - delete an endpoint.
DESCRIPTION
Deletes an MCAPI endpoint. Pending messages are discarded.  If an 
endpoint has been connected to a packet or scalar channel, the 
appropriate close method must be called before deleting the endpoint.  
Delete is a blocking  operation. Since the connection is closed before 
deleting the endpoint, the delete method does not require any 
cross-process synchronization and is guaranteed to return in a timely 
manner (operation will return without having to block on any IPC to any 
remote nodes). It is an error to attempt to delete an endpoint that has 
not been closed. Only the node that created an endpoint can delete it.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS.  On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ECHAN_OPEN A channel is open, deletion is not allowed.
MCAPI_ENOT_OWNER An endpoint can only be deleted by its creator.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
mcapi_create_endpoint() 
************************************************************************/
void mcapi_delete_endpoint(
 	MCAPI_IN mcapi_endpoint_t endpoint, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if ( ! mcapi_trans_valid_endpoint(endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if (!mcapi_trans_endpoint_isowner (endpoint)) {
      *mcapi_status = MCAPI_ENOT_OWNER;
    } else if ( mcapi_trans_endpoint_channel_isopen (endpoint)) {
      *mcapi_status = MCAPI_ECHAN_OPEN;
    } else {
      /* delete the endpoint */
      mcapi_trans_delete_endpoint (endpoint);
    }
  }
}

/***********************************************************************
NAME
mcapi_get_endpoint_attribute - get endpoint attributes.
DESCRIPTION
mcapi_get_endpoint_attribute() allows the programmer to query endpoint 
attributes related to buffer management or quality of service.  
attribute_num indicates which one of the endpoint attributes is being 
referenced. attribute points to a structure or scalar to be filled with 
the value of the attribute specified by attribute_num.  attribute size 
is the size in bytes of the structure or scalar. See Section 3.2 and the 
example mcapi.h for a description of attributes.  The 
mcapi_get_endpoint_attribute() function returns the requested attribute 
value by reference.
It is an error to attempt a connection between endpoints whose attributes 
are set in an incompatible way (for now, whether attributes are compatible 
or not is implementation defined).  It is also an error to attempt to 
change the attributes of endpoints that are connected.
RETURN VALUE
On success, *attribute is filled with the requested attribute and 
*mcapi_status is set to MCAPI_SUCCESS.  On error, *mcapi_status is 
set to an error code and *attribute is not modified.
ERRORS
MCAPI_ENOT_ENDP Argument is not an endpoint descriptor.
MCAPI_EATTR_NUM Unknown attribute number.
MCAPI_EATTR_SIZE Incorrect attribute size.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
mcapi_set_endpoint_attribute() 
************************************************************************/
void mcapi_get_endpoint_attribute(
 	MCAPI_IN mcapi_endpoint_t endpoint, 
 	MCAPI_IN mcapi_uint_t attribute_num, 
 	MCAPI_OUT void* attribute, 
 	MCAPI_IN size_t attribute_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata A3) Not implemented */
}

/***********************************************************************
NAME
mcapi_set_endpoint_attribute - set endpoint attributes.
DESCRIPTION
mcapi_set_endpoint_attribute() allows the programmer to assign endpoint 
attributes related to buffer management or quality of service.  
attribute_num indicates which one of the endpoint attributes is being 
referenced. attribute points to a structure or scalar to be filled with 
the value of the attribute specified by attribute_num.  attribute size is 
the size in bytes of the structure or scalar. See Section 3.2 and mcapi.h 
for a description of attributes.
It is an error to attempt a connection between endpoints whose attributes 
are set in an incompatible way (for now, whether attributes are compatible 
or not is implementation defined).  It is also an error to attempt to 
change the attributes of endpoints that are connected.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not an endpoint descriptor.
MCAPI_EATTR_NUM Unknown attribute number.
MCAPI_EATTR_SIZE Incorrect attribute size.
MCAPI_EPARAM Incorrect mcapi_status parameter.
MCAPI_ECONNECTED Attribute changes not allowed on connected endpoints.
MCAPI_EREAD_ONLY Attribute cannot be modified.
NOTE
SEE ALSO
mcapi_get_endpoint_attribute() 
4.3	MCAPI Messages
MCAPI Messages facilitate connectionless transfer of data buffers.  The 
messaging API provides a "user-specified buffer" communications interface 
- the programmer specifies a buffer of data to be sent on the send side, 
and the user specifies an empty buffer to be filled with incoming data on 
the receive side.  The implementation must be able to transfer messages to 
and from any buffer the programmer specifies, although the implementation 
may use extra buffering internally to queue up data between the sender 
and receiver.
************************************************************************/
void mcapi_set_endpoint_attribute(
 	MCAPI_IN mcapi_endpoint_t endpoint, 
 	MCAPI_IN mcapi_uint_t attribute_num, 
 	MCAPI_IN const void* attribute, 
 	MCAPI_IN size_t attribute_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata A3) not implemented */
}


/***********************************************************************
NAME
mcapi_msg_send_i - sends a (connectionless) message from a send endpoint 
to a receive endpoint.
DESCRIPTION
Sends a (connectionless) message from a send endpoint to a receive 
endpoint. It is a non-blocking function, and returns immediately. 
send_endpoint, is a local endpoint identifying the send endpoint, 
receive_endpoint identifies a receive endpoint. buffer is the application 
provided buffer, buffer_size is the buffer size in bytes, priority 
determines the message priority and request is the identifier used to 
determine if the send operation has completed on the sending endpoint 
and the buffer can be reused by the application. Furthermore, this 
method will abandon the send and return MCAPI_ENO_MEM if the system 
cannot allocate enough memory at the send endpoint to queue up the 
outgoing message.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not an endpoint descriptor.
MCAPI_EMESS_LIMIT The message size exceeds the maximum size allowed by the 
MCAPI implementation.
MCAPI_ENO_BUFFER No more message buffers available.
MCAPI_ENO_REQUEST No more request handles available.
MCAPI_ENO_MEM  No memory available.
MCAPI_EPRIO Incorrect priority level.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test(), mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_msg_send_i(
 	MCAPI_IN mcapi_endpoint_t send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_IN mcapi_priority_t priority, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* MCAPI_ENO_BUFFER, MCAPI_ENO_REQUEST, and MCAPI_ENO_MEM handled at the transport layer */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_priority (priority)){
      *mcapi_status = MCAPI_EPRIO;
    } else if (!mcapi_trans_valid_endpoints(send_endpoint,receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP; /* FIXME (errata A1) */
    } else if (buffer_size > MAX_MSG_SIZE) {
      *mcapi_status = MCAPI_EMESS_LIMIT;
    }
    mcapi_trans_msg_send_i (send_endpoint,receive_endpoint,buffer,buffer_size,request,mcapi_status);
  }
}


/***********************************************************************
NAME
mcapi_msg_send - sends a (connectionless) message from a send endpoint to 
a receive endpoint.
DESCRIPTION
Sends a (connectionless) message from a send endpoint to a receive endpoint. 
It is a blocking function, and returns once the buffer can be reused by the 
application. send_endpoint is a local endpoint identifying the send endpoint, 
receive_endpoint identifies a receive endpoint. buffer is the application 
provided buffer and buffer_size is the buffer size in bytes, and priority 
determines the message priority
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below. Success means that the entire 
buffer has been sent. 
ERRORS
MCAPI_ENOT_ENDP Argument is not an endpoint descriptor.
MCAPI_EMESS_LIMIT The message size exceeds the maximum size allowed by the 
MCAPI implementation.
MCAPI_ENO_BUFFER No more message buffers available.
MCAPI_EPRIO Incorrect priority level.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO 
************************************************************************/
void mcapi_msg_send(
 	MCAPI_IN mcapi_endpoint_t  send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_IN mcapi_priority_t priority, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{  

  /* FIXME: (errata B1) is it an error to send a message to a connected endpoint? */

  /* MCAPI_ENO_BUFFER handled at the transport layer */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_priority (priority)) {
      *mcapi_status = MCAPI_EPRIO;
    } else if (!mcapi_trans_valid_endpoints(send_endpoint,receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP; /* FIXME (errata A1) */
    } else if (buffer_size > MAX_MSG_SIZE) {
      *mcapi_status = MCAPI_EMESS_LIMIT;
    } else if ( !mcapi_trans_msg_send (send_endpoint,receive_endpoint,buffer,buffer_size)) {
      /* assume couldn't get a buffer */
      *mcapi_status = MCAPI_ENO_BUFFER;
    } 
  }
}


/***********************************************************************
NAME
mcapi_msg_recv_i - receives a (connectionless) message from a receive 
endpoint.
DESCRIPTION
Receives a (connectionless) message from a receive endpoint. It is a 
non-blocking function, and returns immediately. receive_endpoint is a 
local endpoint identifying the receive endpoint. buffer is the 
application provided buffer, and buffer_size is the buffer size in bytes. 
request is the identifier used to determine if the receive operation has 
completed (all the data is in the buffer). 
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ETRUNCATED The message size exceeds the buffer_size.
MCAPI_ENO_REQUEST No more request handles available.
MCAPI_EPARAM Incorrect buffer, request and/or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_msg_recv_i(
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint,  
 	MCAPI_OUT void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* MCAPI_ENO_REQUEST handled at the transport layer */
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! valid_buffer_param(buffer)) {
      *mcapi_status = MCAPI_EPARAM;
    } else   if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (!mcapi_trans_valid_endpoint(receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    }
    mcapi_trans_msg_recv_i(receive_endpoint,buffer,buffer_size,request,mcapi_status);
  }
}



/***********************************************************************
NAME
mcapi_msg_recv - receives a (connectionless) message from a receive endpoint.
DESCRIPTION
Receives a (connectionless) message from a receive endpoint. It is a 
blocking function, and returns once a message is available and the received 
data filled into the buffer. receive_endpoint is a local endpoint identifying 
the receive endpoint. buffer is the application provided buffer, and 
buffer_size is the buffer size in bytes.  The received_size parameter is 
filled with the actual size of the received message.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ETRUNCATED The message size exceeds the buffer_size.
MCAPI_EPARAM Incorrect buffer and/or mcapi_status parameter.
NOTE
SEE ALSO 
************************************************************************/
void mcapi_msg_recv(
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint,  
 	MCAPI_OUT void* buffer, 
 	MCAPI_IN size_t buffer_size, 
 	MCAPI_OUT size_t* received_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata B1) is it an error to try to receive a message on a connected endpoint?  */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else  {
    *mcapi_status = MCAPI_SUCCESS;
    if (! valid_buffer_param(buffer)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (!mcapi_trans_valid_endpoint(receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else {
      mcapi_trans_msg_recv(receive_endpoint,buffer,buffer_size,received_size);
      if (*received_size > buffer_size) {
        *received_size = buffer_size;
        *mcapi_status = MCAPI_ETRUNCATED;
      }  
    }
  }
}


/***********************************************************************
NAME
mcapi_msg_available - checks if messages are available on a receive 
endpoint.
DESCRIPTION
Checks if messages are available on a receive endpoint.  The function 
returns in a timely fashion.  The number of "available" incoming messages 
is defined as the number of mcapi_msg_recv() operations that are guaranteed 
to not block waiting for incoming data. receive_endpoint is a local 
identifier for the receive endpoint. The call only checks the availability 
of messages and does not de-queue them. mcapi_msg_available() can only be 
used  to check availability on endpoints on the node local to the caller. 
RETURN VALUE
On success, the number of available messages is returned and *mcapi_status 
is set to MCAPI_SUCCESS. On error, MCAPI_NULL is returned and *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The status code must be checked to distinguish between no messages and an  
error condition.
SEE ALSO 
4.4	MCAPI Packet Channels
MCAPI packet channels transfer data packets between a pair of connected 
endpoints.   A connection between two endpoints is established via a 
two-phase process.  First, some node in the system calls 
mcapi_connect_pktchan_i() to define a connection between two endpoints.  
This function returns immediately.  In the second phase, both sender and 
receiver open their end of the channel by invoking 
mcapi_open_pktchan_send_i() and mcapi_open_pktchan_recv_i(), respectively.  
The connection is synchronized when both the sender and receiver open 
functions have completed.  In order to avoid deadlock situations, the 
open functions are non-blocking.
This two-phased binding approach has several important benefits.  The 
"connect" call can be made by any node in the system, which allows the 
programmer to define the entire channel topology in a single piece of 
code.  This code could even be auto-generated by some static connection 
tool.  This makes it easy to change the channel topology without having 
to modify multiple source files.  This approach also allows the sender 
and receiver to do their work without any knowledge of what remote nodes 
they are connected to.  This allows for better modularity and application 
scaling.
Packet channels provide a "system-specified buffer" interface.  The 
programmer specifies the address of a buffer of data to be sent on the 
send side, but the receiver's recv method returns a buffer of data at an 
address chosen by the system.  This is different from the "user-specified 
buffer" interface use by MCAPI messaging - with messages the programmer 
chooses the buffer in which data is received, and with packet channels 
the system chooses the buffer.
************************************************************************/
mcapi_uint_t mcapi_msg_available(
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  mcapi_uint_t rc = 0;
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if( !mcapi_trans_valid_endpoint(receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else {
      rc = mcapi_trans_msg_available(receive_endpoint);
    }
  }
  return rc;
}

/***********************************************************************
NAME
mcapi_connect_pktchan_i - connects send & receive side endpoints.
DESCRIPTION
Connects a pair of endpoints into a unidirectional FIFO channel.  The 
connect operation can be performed by the sender, the receiver, or by a 
third party. The connect can happen once at the start of the program, or 
dynamically at run time. 
Connect is a non-blocking function. Synchronization to ensure the channel 
has been created is provided by the open call discussed later. 
Attempts to make multiple connections to a single endpoint will be detected 
as errors.  The type of channel connected to an endpoint must match the type 
of open call invoked by that endpoint; the open function will return an error 
if the opened channel type does not match the connected channel type, or if 
the attributes of the endpoints are incompatible.
It is an error to attempt a connection between endpoints whose attributes 
are set in an incompatible way (for now, whether attributes are compatible 
or not is implementation defined).  It is also an error to attempt to change 
the attributes of endpoints that are connected.
RETURN VALUE
On success *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ECONNECTED A channel connection has already been established for 
one or both of the specified endpoints.
MCAPI_ENO_REQUEST No more request handles available.
MCAPI_EATTR_INCOMP Connection of endpoints with incompatible attributes 
not allowed.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status and mcapi_cancel() function to cancel the operation.
SEE ALSO
************************************************************************/
void mcapi_connect_pktchan_i(
 	MCAPI_IN mcapi_endpoint_t  send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t  receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* MCAPI_ENO_REQUEST handled at the transport layer */

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if ( ! mcapi_trans_valid_endpoints(send_endpoint,receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if (( mcapi_trans_channel_connected (send_endpoint)) ||  
               ( mcapi_trans_channel_connected (receive_endpoint))) {
      *mcapi_status = MCAPI_ECONNECTED;
    } else if (! mcapi_trans_compatible_endpoint_attributes (send_endpoint,receive_endpoint)) {
      *mcapi_status = MCAPI_EATTR_INCOMP;
    } 
    mcapi_trans_connect_pktchan_i (send_endpoint,receive_endpoint,request,mcapi_status);
  }
}
  
  

/***********************************************************************
NAME
mcapi_open_pktchan_recv_i - Creates a typed, local representation of the 
channel. It also provides synchronization for channel creation between 
two endpoints. Opens are required on both receive and send endpoints.
DESCRIPTION
Opens the receive end of a packet channel. The corresponding calls are 
required on both sides for synchronization to ensure that the channel 
has been created. It is a non-blocking function, and the recv_handle is 
filled in upon successful completion. No specific ordering of calls 
between sender and receiver is required since the call is non-blocking.  
receive_endpoint is the endpoint associated with the channel.  The open 
call returns a typed, local handle for the connected channel that is 
used for channel receive operations.
RETURN VALUE
On success, a valid request is returned by and *mcapi_status is set to 
MCAPI_SUCCESS. On error *mcapi_status is set to the appropriate error 
defined below. 
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ENOT_CONNECTED The channel is not connected (cannot be opened).
MCAPI_ECHAN_TYPE Attempt to open a packet channel on an endpoint that 
has been connected with a different channel type.
MCAPI_EDIR Attempt to open a send handle on a port that was connected 
as a receiver, or vice versa.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_open_pktchan_recv_i(
 	MCAPI_OUT mcapi_pktchan_recv_hndl_t* recv_handle, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status) 
{
  /* FIXME: (errata B2) shouldn't this function also check  MCAPI_ENO_REQUEST, there are several
     non-blocking functions that don't check for this - is that intentional or an
     oversight in the spec? */

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;   
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_endpoint(receive_endpoint) ) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if ( mcapi_trans_channel_type (receive_endpoint) == MCAPI_SCL_CHAN) {
      *mcapi_status = MCAPI_ECHAN_TYPE;
    } else if (! mcapi_trans_recv_endpoint (receive_endpoint)) {
      *mcapi_status = MCAPI_EDIR;
    } else if ( !mcapi_trans_connected (receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_CONNECTED;
    }
    mcapi_trans_open_pktchan_recv_i(recv_handle,receive_endpoint,request,mcapi_status);
  }
}

/***********************************************************************
NAME
mcapi_open_pktchan_send_i - Creates a typed, local representation of the 
channel. It also provides synchronization for channel creation between two 
endpoints. Opens are required on both receive and send endpoints.
DESCRIPTION
Opens the send end of a packet channel. The corresponding calls are 
required on both sides for synchronization to ensure that the channel 
has been created. It is a non-blocking function, and the send_handle is 
filled in upon successful completion. No specific ordering of calls 
between sender and receiver is required since the call is non-blocking.  
send_endpoint is the endpoint associated with the channel.  The open call 
returns a typed, local handle for the connected endpoint that is used by 
channel send operations.
RETURN VALUE
On success, a valid request is returned and *mcapi_status is set to 
MCAPI_SUCCESS. On error, *mcapi_status is set to the appropriate error 
defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ECHAN_TYPE Attempt to open a packet channel on an endpoint that has 
been connected with a different channel type.
MCAPI_EDIR Attempt to open a send handle on a port that was connected 
as a receiver, or vice versa.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status and mcapi_cancel() function to cancel the operation.
SEE ALSO
************************************************************************/
void mcapi_open_pktchan_send_i(
 	MCAPI_OUT mcapi_pktchan_send_hndl_t* send_handle, 
 	MCAPI_IN mcapi_endpoint_t  send_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata B2) shouldn't this function also check  MCAPI_ENO_REQUEST? */
  /* FIXME: (errata B4) shouldn't this function also check MCAPI_ENOT_CONNECTED?  I do, but it's not in the spec */

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_endpoint(send_endpoint) ) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if ( mcapi_trans_channel_type (send_endpoint) == MCAPI_SCL_CHAN){
      *mcapi_status = MCAPI_ECHAN_TYPE;
    } else if (! mcapi_trans_send_endpoint (send_endpoint)) {
      *mcapi_status = MCAPI_EDIR;
    } else if ( !mcapi_trans_connected (send_endpoint)) {
        // TODO: the status is not updated before this?
//      *mcapi_status = MCAPI_ENOT_CONNECTED;
    }
    mcapi_trans_open_pktchan_send_i(send_handle,send_endpoint,request,mcapi_status);
  }
}

/*********************************************************************** 
NAME
mcapi_pktchan_send_i - sends a (connected) packet on a channel.
DESCRIPTION
Sends a packet on a connected channel. It is a non-blocking function, 
and returns immediately. buffer is the application provided buffer and 
size is the buffer size. request is the identifier used to determine if 
the send operation has completed on the sending endpoint and the buffer 
can be reused. While this method returns immediately, data transfer will 
not complete until there is sufficient free space in the channels receive 
buffer. A subsequent call to mcapi_wait() will block until space becomes 
available at the receiver, the send operation has completed, and the send 
buffer is available for reuse. Furthermore, this method will abandon the 
send and return MCAPI_ENO_MEM if the system cannot allocate enough 
memory at the send endpoint to queue up the outgoing packet.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPACK_LIMIT The packet size exceeds the maximum size 
allowed by the MCAPI implementation.
MCAPI_ENO_BUFFER No more packet buffers available.
MCAPI_ENO_REQUEST No more request handles available.
MCAPI_ENO_MEM  No memory available.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() 
functions to query the status and mcapi_cancel() function to cancel the 
operation.
SEE ALSO
************************************************************************/
void mcapi_pktchan_send_i(
 	MCAPI_IN mcapi_pktchan_send_hndl_t send_handle, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t size, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* MCAPI_ENO_BUFFER, MCAPI_ENO_REQUEST and MCAPI_ENO_MEM handled at the transport layer */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_pktchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if ( size > MAX_PKT_SIZE) {
      *mcapi_status = MCAPI_EPACK_LIMIT; 
    }
    mcapi_trans_pktchan_send_i(send_handle,buffer,size,request,mcapi_status);
  }
}

/*********************************************************************** 
NAME
mcapi_pktchan_send - sends a (connected) packet on a channel.
DESCRIPTION
Sends a packet on a connected channel.  It is a blocking function, and 
returns once the buffer can be reused.  send_handle is the efficient local 
send handle which represents the send endpoint associated with the channel.  
buffer is the application provided buffer and size is the buffer size.  Since 
channels behave like FIFPs, this method will block if there is no free space 
in the channel's receive buffer.  When sufficient space becomes available 
(due to receive calls), the funciton will complete.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPACK_LIMIT The packet size exceeds the maximum size 
allowed by the MCAPI implementation.
MCAPI_ENO_BUFFER No more packet buffers available.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
************************************************************************/
void mcapi_pktchan_send(
 	MCAPI_IN mcapi_pktchan_send_hndl_t send_handle, 
 	MCAPI_IN void* buffer, 
 	MCAPI_IN size_t size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! mcapi_trans_valid_pktchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if ( size > MAX_PKT_SIZE) {
      *mcapi_status = MCAPI_EPACK_LIMIT; 
    } else  {
      if (!mcapi_trans_pktchan_send (send_handle,buffer,size)) {
        *mcapi_status = MCAPI_ENO_BUFFER;
      }
    }
  }
}
    

/***********************************************************************
NAME
mcapi_pktchan_recv_i - receives a (connected) packet on a channel.
DESCRIPTION
Receives a packet on a connected channel. It is a non-blocking function, 
and returns immediately. receive_handle is the receive endpoint.  At some 
point in the future, when the receive operation completes, the buffer 
parameter is filled with the address of a system-supplied buffer containing 
the received packet.  After the receive request has completed and the 
application is finished with buffer, buffer should be returned to the system 
by calling mcapi_pktchan_free(). request is the identifier used to determine 
if the receive operation has completed and buffer is ready for use; the 
mcapi_test() , mcapi_wait() or mcapi_wait_any() function will return the 
actual size of the received packet.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPACKLIMIT The packet size exceeds the maximum size allowed by the 
MCAPI implementation.
MCAPI_ENO_BUFFER No more packet buffers available.
MCAPI_ENO_REQUEST No more request handles available.
MCAPI_EPARAM Incorrect buffer, request and/or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO
************************************************************************/
void mcapi_pktchan_recv_i(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle,  
 	MCAPI_OUT void** buffer, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{ 
  /* MCAPI_EPACKLIMIT, MCAPI_ENO_BUFFER, and MCAPI_ENO_REQUEST are handled at the transport layer */

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else   if (! valid_buffer_param(buffer)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_pktchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }
    mcapi_trans_pktchan_recv_i (receive_handle,buffer,request,mcapi_status);
  }
}

/***********************************************************************
NAME
mcapi_pktchan_recv - receives a data packet on a (connected) channel.
DESCRIPTION
Receives a packet on a connected channel. It is a blocking function, and 
returns when the data has been written to the buffer. receive_handle is 
the efficient local representation of the receive endpoint associated with 
the channel.  buffer is filled with a pointer to the system-supplied 
receive buffer and received_size is filled with the size of the packet in 
that buffer.  When the application finishes with buffer, it must return 
it to the system by calling mcapi_pktchan_free(). 
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error, 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPACKLIMIT The package size exceeds the maximum size allowed by 
the MCAPI implementation.
MCAPI_ENO_BUFFER No more packet buffers available.
MCAPI_EPARAM Incorrect buffer and/or mcapi_status parameter.
NOTE
SEE ALSO
************************************************************************/
void mcapi_pktchan_recv(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT void** buffer, 
 	MCAPI_OUT size_t* received_size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;   
    if (! valid_buffer_param(buffer)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_pktchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else  {
      if (mcapi_trans_pktchan_recv (receive_handle,buffer,received_size)) {
        if ( *received_size > MAX_PKT_SIZE) {
          *mcapi_status = MCAPI_EPACK_LIMIT;
        } 
      } else {
        *mcapi_status = MCAPI_ENO_BUFFER;
      }
    }
  }
}

/***********************************************************************
NAME
mcapi_pktchan_available - checks if packets are available on a receive 
endpoint.
DESCRIPTION
Checks if packets are available on a receive endpoint.   This function 
returns in a timely fashion.  The number of available packets is defined 
as the number of receive operations that could be performed without 
blocking to wait for incoming data.  receive_handle is the efficient 
local handle for the packet channel. The call only checks the 
availability of messages and does not de-queue them.
RETURN VALUE
On success, the number of available packets are returned and *mcapi_status 
is set to MCAPI_SUCCESS. On error, MCAPI_NULL is returned and *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The status code must be checked to distinguish between no messages and 
an error condition.
SEE ALSO
************************************************************************/
mcapi_uint_t mcapi_pktchan_available(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status) 
{
  int num = 0;

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_pktchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else {
      num = mcapi_trans_pktchan_available(receive_handle);
    }
  }
  return num;
}

/***********************************************************************
NAME
mcapi_pktchan_free - releases a packet buffer obtained from a 
mcapi_pktchan_recv() call.
DESCRIPTION
When a user is finished with a packet buffer obtained from 
mcapi_pktchan_recv_i() or mcapi_pktchan_recv(), they should invoke this 
function to return the buffer to the system.  Buffers can be freed in any 
order. This function is guaranteed to return in a timely fashion.
RETURN VALUE
On success *mcapi_status is set to MCAPI_SUCCESS. On error, *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_VALID_BUF Argument is not a valid buffer descriptor.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
   mcapi_pktchan_recv(),    mcapi_pktchan_recv_i() 
************************************************************************/
void mcapi_pktchan_free(
 	MCAPI_IN void* buffer, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (!mcapi_trans_pktchan_free (buffer)) {
      *mcapi_status = MCAPI_ENOT_VALID_BUF;
    }
  }
}


/***********************************************************************
NAME
mcapi_packetchan_recv_close_i - closes channel on a receive endpoint.
DESCRIPTION
Closes the receive side of a channel. The sender makes the send-side 
call and the receiver makes the receive-side call. The corresponding 
calls are required on both sides to ensure that the channel has been 
properly closed. It is a non-blocking function, and returns immediately. 
receive_handle is the receive endpoint identifier. All pending packets 
are discarded, and any attempt to send more packets will give an error.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_ENOT_OPEN The endpoint is not open.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_pktchan_recv_close_i(
 	MCAPI_IN mcapi_pktchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{

  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;  
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_pktchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_pktchan_recv_isopen (receive_handle)) {
      *mcapi_status = MCAPI_ENOT_OPEN;
    }
    mcapi_trans_pktchan_recv_close_i (receive_handle,request,mcapi_status);
  }
}


/***********************************************************************
NAME
mcapi_pktchan_send_close_i - closes channel on a send endpoint.
DESCRIPTION
Closes the send side of a channel. The sender makes the send-side call 
and the receiver makes the receive-side call. The corresponding calls 
are required on both sides to ensure that the channel has been properly 
closed. It is a non-blocking function, and returns immediately. 
send_handle is the send endpoint identifier. Pending packets at the 
receiver are not discarded.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_ENOT_OPEN The endpoint is not open.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_pktchan_send_close_i(
 	MCAPI_IN mcapi_pktchan_send_hndl_t send_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_pktchan_recv_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_pktchan_send_isopen (send_handle)) {
      *mcapi_status = MCAPI_ENOT_OPEN;
    } if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    }  
    mcapi_trans_pktchan_send_close_i (send_handle,request,mcapi_status);
  }
}


/***********************************************************************
NAME
mcapi_connect_sclchan_i - connects a pair of scalar channel endpoints.
DESCRIPTION
Connects a pair of endpoints.  The connect operation can be performed by 
the sender, the receiver, or by a third party. The connect can happen 
once at the start of the program, or dynamically at run time. 
mcapi_connect_sclchan_i() is a non-blocking function. Synchronization 
to ensure the channel has been created is provided by the open call 
discussed later. 
Note that this function behaves like the packetchannel connect call.
Attempts to make multiple connections to a single endpoint will be 
detected as errors.  The type of channel connected to an endpoint must 
match the type of open call invoked by that endpoint; the open 
function will return an error if the opened channel type does not 
match the connected channel type, or if the attributes of the endpoints 
are incompatible.
It is an error to attempt a connection between endpoints whose 
attributes are set in an incompatible way (for now, whether attributes 
are compatible or not is implementation defined).  It is also an error 
to attempt to change the attributes of endpoints that are connected.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not a valid endpoint descriptor.
MCAPI_ECONNECTED A channel connection has already been established for 
one or both of the specified endpoints.
MCAPI_EATTR_INCOMP Connection of endpoints with incompatible attributes 
not allowed.
MCAPI_ENO_REQUEST No more request handles available.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void  mcapi_connect_sclchan_i(
 	MCAPI_IN mcapi_endpoint_t send_endpoint, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if ( ! mcapi_trans_valid_endpoints(send_endpoint,receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if (( mcapi_trans_channel_connected (send_endpoint)) ||  
               ( mcapi_trans_channel_connected (receive_endpoint))) {
      *mcapi_status = MCAPI_ECONNECTED;
    } else if (! mcapi_trans_compatible_endpoint_attributes (send_endpoint,receive_endpoint)) {
      *mcapi_status = MCAPI_EATTR_INCOMP;
    } 
    mcapi_trans_connect_sclchan_i (send_endpoint,receive_endpoint,request,mcapi_status);
  }
}


/***********************************************************************
NAME
mcapi_open_sclchan_recv_i - Creates a typed, local representation of a 
scalar channel. 
DESCRIPTION
Opens the receive end of a scalar channel. It also provides 
synchronization for channel creation between two endpoints. The 
corresponding calls are required on both sides to synchronize the 
endpoints. It is a non-blocking function, and the recv_handle is filled 
in upon successful completion.  No specific ordering of calls between 
sender and receiver is required since the call is non-blocking.   
receive_endpoint is the local endpoint identifier. The call returns a 
local handle for the connected channel.
RETURN VALUE
On success, a channel handle is returned by reference and *mcapi_status 
is set to MCAPI_SUCCESS. On error, *mcapi_status is set to the 
appropriate error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not an endpoint descriptor.
MCAPI_ENOT_CONNECTED The channel is not connected (cannot be opened).
MCAPI_ECHAN_TYPE Attempt to open a packet channel on an endpoint that 
has been connected with a different channel type.
MCAPI_EDIR Attempt to open a send handle on a port that was connected 
as a receiver, or vice versa.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_open_sclchan_recv_i(
 	MCAPI_OUT mcapi_sclchan_recv_hndl_t* receive_handle, 
 	MCAPI_IN mcapi_endpoint_t receive_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status) 
{
  /* FIXME: (errata B2) shouldn't this function also check  MCAPI_ENO_REQUEST? */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;  
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_endpoint(receive_endpoint) ) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if ( mcapi_trans_channel_type (receive_endpoint) == MCAPI_PKT_CHAN) {
      *mcapi_status = MCAPI_ECHAN_TYPE;
    } else if (! mcapi_trans_recv_endpoint (receive_endpoint)) {
      *mcapi_status = MCAPI_EDIR;
    } else if ( !mcapi_trans_connected (receive_endpoint)) {
      *mcapi_status = MCAPI_ENOT_CONNECTED;
    }
    mcapi_trans_open_sclchan_recv_i(receive_handle,receive_endpoint,request,mcapi_status);
  }
}

/***********************************************************************
NAME
mcapi_open_sclchan_send_i - Creates a typed, local representation of a 
scalar channel.
DESCRIPTION
Opens the send end of a scalar channel. . It also provides 
synchronization for channel creation between two endpoints.  The 
corresponding calls are required on both sides to synchronize the 
endpoints. It is a non-blocking function, and the send_handle is filled 
in upon successful completion.   No specific ordering of calls between 
sender and receiver is required since the call is non-blocking.  
send_endpoint is the local endpoint identifier. The call returns a 
local handle for connected channel.
RETURN VALUE
On success, a channel handle is returned by reference and *mcapi_status 
is set to MCAPI_SUCCESS. On error, *mcapi_status is set to the appropriate 
error defined below.
ERRORS
MCAPI_ENOT_ENDP Argument is not an endpoint descriptor.
MCAPI_ECHAN_TYPE Attempt to open a packet channel on an endpoint that has 
been connected with a different channel type.
MCAPI_EDIR Attempt to open a send handle on a port that was connected as 
a receiver, or vice versa.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_open_sclchan_send_i(
 	MCAPI_OUT mcapi_sclchan_send_hndl_t* send_handle, 
 	MCAPI_IN mcapi_endpoint_t send_endpoint, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;  
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_endpoint(send_endpoint) ) {
      *mcapi_status = MCAPI_ENOT_ENDP;
    } else if  (mcapi_trans_channel_type (send_endpoint) == MCAPI_PKT_CHAN){
      *mcapi_status = MCAPI_ECHAN_TYPE;
    } else if (! mcapi_trans_send_endpoint (send_endpoint)) {
      *mcapi_status = MCAPI_EDIR;
    } else if ( !mcapi_trans_connected (send_endpoint)) {
      *mcapi_status = MCAPI_ENOT_CONNECTED;
    }
    /* FIXME:(errata B2) shouldn't this function also check  MCAPI_ENO_REQUEST  */
    /* FIXME: (errata B4) shouldn't this function also check  MCAPI_ENOT_CONNECTED.  
       I do, but it's not in the spec */
    mcapi_trans_open_sclchan_send_i(send_handle,send_endpoint,request,mcapi_status);
  } 
}

/***********************************************************************
NAME
mcapi_sclchan_send_uint64 - sends a (connected) 64-bit scalar on a channel.
DESCRIPTION
Sends a scalar on a connected channel. It is a blocking function, and 
returns immediately unless the buffer is full. send_handle is the send 
endpoint identifier. dataword is the scalar. Since channels behave like 
FIFOs, this method will block if there is no free space in the channel's 
receive buffer. When sufficient space becomes available 
(due to receive calls), the function will complete.  
RETURN VALUE 
On success, *mcapi_status is set to MCAPI_SUCCESS. On error *mcapi_status is 
set to the appropriate error defined below.  Optionally, implementations may 
choose to always set *mcapi_status to MCAPI_SUCCESS for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
************************************************************************/
void mcapi_sclchan_send_uint64(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint64_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata B3) this function needs to check MCAPI_ENO_BUFFER */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }  else if (!mcapi_trans_sclchan_send (send_handle,dataword,8)) {
      *mcapi_status = MCAPI_ENO_BUFFER;  /* MR: added this  */
    } 
  }
}




/***********************************************************************
NAME
mcapi_sclchan_send_uint32 - sends a (connected) 32-bit scalar on a 
channel.
DESCRIPTION
Sends a scalar on a connected channel. It is a blocking function, and 
returns immediately unless the buffer is full. send_handle is the send 
endpoint identifier. dataword is the scalar. Since channels behave like 
FIFOs, this method will block if there is no free space in the channel's 
receive buffer. When sufficient space becomes available 
(due to receive calls), the function will complete.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error 
*mcapi_status is set to the appropriate error defined below.  
Optionally, implementations may choose to always set *mcapi_status to 
MCAPI_SUCCESS for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
************************************************************************/
void mcapi_sclchan_send_uint32(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint32_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata B3) this function needs to check MCAPI_ENO_BUFFER */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
#ifdef __TCE__
    uint64_t data64;
    data64.lo = dataword;

    if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }  else if (!mcapi_trans_sclchan_send (send_handle,data64,4)) {
      *mcapi_status = MCAPI_ENO_BUFFER;
    } 
#else
    if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }  else if (!mcapi_trans_sclchan_send (send_handle,dataword,4)) {
      *mcapi_status = MCAPI_ENO_BUFFER;
    } 
#endif
  }
}
 
/***********************************************************************
NAME
mcapi_sclchan_send_uint16 - sends a (connected) 16-bit scalar on a channel.
DESCRIPTION
Sends a scalar on a connected channel. It is a blocking function, and 
returns immediately unless the buffer is full. send_handle is the send 
endpoint identifier. dataword is the scalar. Since channels behave like 
FIFOs, this method will block if there is no free space in the channel's 
receive buffer. When sufficient space becomes available (due to receive 
calls), the function will complete.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error *mcapi_status 
is set to the appropriate error defined below.  Optionally, implementations 
may choose to always set *mcapi_status to MCAPI_SUCCESS for performance 
reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
************************************************************************/
void mcapi_sclchan_send_uint16(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint16_t dataword, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{ 
  /* FIXME: (errata B3) this function needs to check MCAPI_ENO_BUFFER */
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;

#ifdef __TCE__
    uint64_t data64;
    data64.lo = dataword;
    if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }  else if (!mcapi_trans_sclchan_send (send_handle,data64,2)) {
      *mcapi_status = MCAPI_ENO_BUFFER; 
    }
#else
    if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }  else if (!mcapi_trans_sclchan_send (send_handle,dataword,2)) {
      *mcapi_status = MCAPI_ENO_BUFFER; 
    }
#endif
  }
}


/***********************************************************************
NAME
mcapi_sclchan_send_uint8 - sends a (connected) 8-bit scalar on a channel.
DESCRIPTION
Sends a scalar on a connected channel. It is a blocking function, and 
returns immediately unless the buffer is full. send_handle is the send 
endpoint identifier. dataword is the scalar. Since channels behave like 
FIFOs, this method will block if there is no free space in the channel's 
receive buffer. When sufficient space becomes available (due to receive 
calls), the function will complete.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error *mcapi_status 
is set to the appropriate error defined below.  Optionally, 
implementations may choose to always set *mcapi_status to MCAPI_SUCCESS 
for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
************************************************************************/
void mcapi_sclchan_send_uint8(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle,  
 	MCAPI_IN mcapi_uint8_t dataword, 
        MCAPI_OUT mcapi_status_t* mcapi_status)
{
  /* FIXME: (errata B3) this function needs to check MCAPI_ENO_BUFFER */
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;

#ifdef __TCE__
    uint64_t data64;
    data64.lo = dataword;
 if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
    *mcapi_status = MCAPI_ENOT_HANDLE;
  }  else if (!mcapi_trans_sclchan_send (send_handle,data64,1)) {
    *mcapi_status = MCAPI_ENO_BUFFER;    
  }
#else
 if (! mcapi_trans_valid_sclchan_send_handle(send_handle) ) {
    *mcapi_status = MCAPI_ENOT_HANDLE;
  }  else if (!mcapi_trans_sclchan_send (send_handle,dataword,1)) {
    *mcapi_status = MCAPI_ENO_BUFFER;    
  }
#endif
}
}

/***********************************************************************
NAME
mcapi_sclchan_recv_uint64 - receives a (connected) 64-bit scalar on a 
channel.
DESCRIPTION
Receives a scalar on a connected channel. It is a blocking function, 
and returns when a scalar is available. receive_handle is the receive 
endpoint identifier.
RETURN VALUE
On success, a value of type uint64_t is returned and *mcapi_status is 
set to MCAPI_SUCCESS. On error, the return value is undefined and 
*mcapi_status is set to the appropriate error defined below.  Optionally, 
implementations may choose to always set *mcapi_status to MCAPI_SUCCESS 
for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
MCAPI_ESCL_SIZE Incorrect scalar size.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The receive scalar size must match the send size.
SEE ALSO 
************************************************************************/
mcapi_uint64_t mcapi_sclchan_recv_uint64(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  uint32_t exp_size = 8; 
#ifdef __TCE__
    uint64_t dataword;
    dataword.lo = 0;
    dataword.hi = 0;
#else
  uint64_t dataword = 0;
#endif
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! mcapi_trans_valid_sclchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    }else if (! mcapi_trans_sclchan_recv (receive_handle,&dataword,exp_size)) {
      *mcapi_status = MCAPI_ESCL_SIZE;
    }
  }
  return dataword;
}

/***********************************************************************
NAME
mcapi_sclchan_recv_uint32 - receives a 32-bit scalar on a (connected) 
channel.
DESCRIPTION
Receives a scalar on a connected channel. It is a blocking function, 
and returns when a scalar is available. receive_handle is the receive 
endpoint identifier.
RETURN VALUE
On success, a value of type uint32_t is returned and *mcapi_status is 
set to MCAPI_SUCCESS. On error, the return value is undefined and 
*mcapi_status is set to the appropriate error defined below.  Optionally, 
implementations may choose to always set *mcapi_status to MCAPI_SUCCESS 
for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
MCAPI_ESCL_SIZE Incorrect scalar size.

NOTE
The receive scalar size must match the send size.
SEE ALSO 
************************************************************************/
mcapi_uint32_t mcapi_sclchan_recv_uint32(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  uint32_t exp_size = 4; 
#ifdef __TCE__
    uint64_t dataword;
    dataword.lo = 0;
    dataword.hi = 0;
#else
  uint64_t dataword = 0;
#endif
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;
    if (! mcapi_trans_valid_sclchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_sclchan_recv (receive_handle,&dataword,exp_size)) {
      *mcapi_status = MCAPI_ESCL_SIZE;
    } 
  }
#ifdef __TCE__
  return dataword.lo;
#else
  return dataword;
#endif
}


/***********************************************************************
NAME
mcapi_sclchan_recv_uint16 - receives a 16-bit scalar on a (connected) 
channel.
DESCRIPTION
Receives a scalar on a connected channel. It is a blocking function, and 
returns when a scalar is available. receive_handle is the receive endpoint 
identifier.
RETURN VALUE
On success, a value of type uint16_t is returned and *mcapi_status is 
set to MCAPI_SUCCESS. On error, the return value is undefined and 
*mcapi_status is set to the appropriate error defined below.  Optionally, 
implementations may choose to always set *mcapi_status to MCAPI_SUCCESS 
for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
MCAPI_ESCL_SIZE Incorrect scalar size.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The receive scalar size must match the send size.
SEE ALSO 
************************************************************************/
mcapi_uint16_t mcapi_sclchan_recv_uint16(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  uint32_t exp_size = 2; 
#ifdef __TCE__
    uint64_t dataword;
    dataword.lo = 0;
    dataword.hi = 0;
#else
  uint64_t dataword = 0;
#endif
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! mcapi_trans_valid_sclchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_sclchan_recv (receive_handle,&dataword,exp_size)) {  
      *mcapi_status = MCAPI_ESCL_SIZE;
    } 
  }
#ifdef __TCE__
  return dataword.lo;
#else
  return dataword;
#endif
}


/***********************************************************************
NAME
mcapi_sclchan_recv_uint8 - receives a (connected) 8-bit scalar on a 
channel.
DESCRIPTION
Receives a scalar on a connected channel. It is a blocking function, 
and returns when a scalar is available. receive_handle is the receive 
endpoint identifier.
RETURN VALUE
On success, a value of type uint8_t is returned and *mcapi_status is set 
to MCAPI_SUCCESS. On error, the return value is undefined and 
*mcapi_status is set to the appropriate error defined below.  Optionally, 
implementations may choose to always set *mcapi_status to MCAPI_SUCCESS 
for performance reasons.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
MCAPI_ESCL_SIZE Incorrect scalar size.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The receive scalar size must match the send size.
SEE ALSO 
************************************************************************/
mcapi_uint8_t mcapi_sclchan_recv_uint8(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  uint32_t exp_size = 1; 
#ifdef __TCE__
    uint64_t dataword;
    dataword.lo = 0;
    dataword.hi = 0;
#else
  uint64_t dataword = 0;
#endif
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! mcapi_trans_valid_sclchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_sclchan_recv (receive_handle,&dataword,exp_size)) {
      *mcapi_status = MCAPI_ESCL_SIZE;
    }
  }
#ifdef __TCE__
  return dataword.lo;
#else
  return dataword;
#endif
}


/***********************************************************************
NAME
mcapi_sclchan_available - checks if scalars are available on a receive
 endpoint.
DESCRIPTION
Checks if scalars are available on a receive endpoint. The function returns 
immediately. receive_endpoint is the receive endpoint identifier. The call 
only checks the availability of messages does not de-queue them.
RETURN VALUE
On success, the number of available scalars are returned and *mcapi_status 
is set to MCAPI_SUCCESS. On error, MCAPI_NULL is returned and *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
The status code must be checked to distinguish between no messages and an 
error condition.
SEE ALSO
************************************************************************/
mcapi_uint_t mcapi_sclchan_available (
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  int num = 0;
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! mcapi_trans_valid_sclchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else {
      num = mcapi_trans_sclchan_available_i(receive_handle);
    }
  }
  return num;
}

/***********************************************************************
NAME
mcapi_ sclchan_recv_close_i - closes channel on a receive endpoint.
DESCRIPTION
Closes the receive side of a channel. The corresponding calls are required 
on both send and receive sides to ensure that the channel is properly 
closed. It is a non-blocking function, and returns immediately. 
 receive_handle is the receive endpoint identifier. All pending scalars 
are discarded, and any attempt to send more scalars will give an error.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_ENOT_OPEN The endpoint is not open.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_sclchan_recv_close_i(
 	MCAPI_IN mcapi_sclchan_recv_hndl_t receive_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_sclchan_recv_handle(receive_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_sclchan_recv_isopen (receive_handle)) {
      *mcapi_status = MCAPI_ENOT_OPEN;
    } 
    mcapi_trans_sclchan_recv_close_i (receive_handle,request,mcapi_status);
  }
}


/***********************************************************************
NAME
mcapi_sclchan_send_close_i - closes channel on a send endpoint.
DESCRIPTION
Closes the send side of a channel. The corresponding calls are required on 
both send and receive sides to ensure that the channel is properly closed. 
It is a non-blocking function, and returns immediately.  send_handle is 
the send endpoint identifier. Pending scalars at the receiver are not 
discarded.
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error 
*mcapi_status is set to the appropriate error defined below.
ERRORS
MCAPI_ENOT_HANDLE Argument is not a channel handle.
MCAPI_ENOT_OPEN The endpoint is not open.
MCAPI_EPARAM Incorrect request or mcapi_status parameter.
NOTE
Use the mcapi_test() , mcapi_wait() and mcapi_wait_any() functions to 
query the status of and mcapi_cancel() function to cancel the operation.
SEE ALSO 
************************************************************************/
void mcapi_sclchan_send_close_i(
 	MCAPI_IN mcapi_sclchan_send_hndl_t send_handle, 
 	MCAPI_OUT mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS;   
    if (! valid_request_param(request)) {
      *mcapi_status = MCAPI_EPARAM;
    } else if (! mcapi_trans_valid_sclchan_recv_handle(send_handle) ) {
      *mcapi_status = MCAPI_ENOT_HANDLE;
    } else if (! mcapi_trans_sclchan_send_isopen (send_handle)) {
      *mcapi_status = MCAPI_ENOT_OPEN;
    } 
    mcapi_trans_sclchan_send_close_i (send_handle,request,mcapi_status);
  }
}


/***********************************************************************
NAME
mcapi_test - tests if non-blocking operation has completed.
DESCRIPTION
Checks if a non-blocking operation has completed. The function returns 
in a timely fashion. request is the identifier for the non-blocking 
operation. The call only checks the completion of an operation and 
doesn't affect any messages/packets/scalars.  If the specified request 
completes and the pending operation was a send or receive operation, 
the size parameter is set to the number of bytes that were either sent 
or received by the non-blocking transaction.
RETURN VALUE
On success, MCAPI_TRUE is returned and *mcapi_status is set to 
MCAPI_SUCCESS. If the operation has not completed MCAPI_FALSE is 
returned and *mcapi_status is set to MCAPI_INCOMPLETE. On error 
MCAPI_FALSE is returned and *mcapi_status is set to the appropriate 
error defined below.  
ERRORS
MCAPI_ENOTREQ_HANDLE Argument is not a valid request handle.
MCAPI_EPARAM Incorrect size and/or mcapi_status parameter.
NOTE
SEE ALSO
 mcapi_endpoint_t mcapi_get_endpoint_i(), 
 mcapi_msg_send_i(), 
 mcapi_msg_recv_i(), 
 mcapi_connect_pktchan_i(), 
 mcapi_open_pktchan_recv_i(), 
 mcapi_open_pktchan_send_i(), 
 mcapi_pktchan_send_i(), 
 mcapi_pktchan_recv_i(), 
 mcapi_pktchan_recv_close_i(), 
 mcapi_pktchan_send_close_i(), 
 mcapi_connect_sclchan_i(), 
 mcapi_open_sclchan_recv_i(), 
 mcapi_open_sclchan_send_i(), 
 mcapi_sclchan_recv_close_i(), 
 mcapi_sclchan_send_close_i()
************************************************************************/
mcapi_boolean_t mcapi_test(
 	MCAPI_IN mcapi_request_t* request, 
 	MCAPI_OUT size_t* size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  mcapi_boolean_t rc = MCAPI_FALSE;
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_INCOMPLETE;  
    if (! valid_size_param(size)) {
      *mcapi_status = MCAPI_EPARAM;
       rc = MCAPI_TRUE;
    } else {
      rc = mcapi_trans_test_i(request,size,mcapi_status);
    }
  }
  return rc;
}
/***********************************************************************
NAME
mcapi_wait - waits for a non-blocking operation to complete.
DESCRIPTION
Wait until a non-blocking operation has completed. It is a blocking function 
and returns when the operation has completed, has been canceled, or a timeout 
has occurred. request is the identifier for the non-blocking operation. The 
call only waits for the completion of an operation (all buffers referenced in 
the operation have been filled or consumed and can now be safely accessed by 
the application) and doesn't affect any messages/packets/scalars.  The size 
parameter is set to number of bytes that were either sent or received by the 
non-blocking transaction that completed (size is irrelevant for non-blocking 
connect and close calls).  The mcapi_wait() call will return if the request 
is cancelled by a call to mcapi_cancel(), and the returned mcapi_status will 
indicate that the request was cancelled. The units for timeout are 
implementation defined.  If a timeout occurs the returned status will indicate 
that the timeout occurred.    A value of MCAPI_INFINITE for the timeout 
parameter indicates no timeout is requested.
RETURN VALUE
On success, MCAPI_TRUE is returned and *mcapi_status is set to MCAPI_SUCCESS. 
On error MCAPI_FALSE is returned and *mcapi_status is set to the appropriate 
error defined below.  
ERRORS
MCAPI_ENOTREQ_HANDLE Argument is not a valid request handle.
MCAPI_EREQ_CANCELED The request was canceled, by another thread (during the 
waiting)
.
MCAPI_EREQ_TIMEOUT The operation timed out.
MCAPI_EPARAM Incorrect size and/or mcapi_status parameter.
NOTE
SEE ALSO
 mcapi_endpoint_t mcapi_get_endpoint_i(),
 mcapi_msg_send_i(),
 mcapi_msg_recv_i(),
 mcapi_connect_pktchan_i(),
 mcapi_open_pktchan_recv_i(),
 mcapi_open_pktchan_send_i(),
 mcapi_pktchan_send_i(),
 mcapi_pktchan_recv_i(),
 mcapi_pktchan_recv_close_i(),
 mcapi_pktchan_send_close_i(),
 mcapi_connect_sclchan_i(),
 mcapi_open_sclchan_recv_i(),
 mcapi_open_sclchan_send_i(),
 mcapi_sclchan_recv_close_i(),
 mcapi_sclchan_send_close_i()
************************************************************************/
mcapi_boolean_t mcapi_wait(
 	MCAPI_IN mcapi_request_t* request, 
 	MCAPI_OUT size_t* size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status, 
 	MCAPI_IN mcapi_timeout_t timeout)
{
  mcapi_boolean_t rc = MCAPI_FALSE;
 
   if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! valid_size_param(size)) {
      *mcapi_status = MCAPI_EPARAM;
      rc = MCAPI_TRUE;
    } else {
      rc = mcapi_trans_wait(request,size,mcapi_status,timeout);
    }
  }
  return rc;
}

/***********************************************************************
NAME
mcapi_wait_any - waits for any non-blocking operation in a list to complete.
DESCRIPTION
Wait until any non-blocking operation of a list has completed. It is a 
blocking function and returns the index into the requests array (starting 
from 0) indicating which of any outstanding operations has completed. 
number is the number of requests in the array. requests is the array of 
mcapi_request_t identifiers for the non-blocking operations. The call only 
waits for the completion of an operation and doesn't affect any 
messages/packets/scalars.  The size parameter is set to number of bytes 
that were either sent or received by the non-blocking transaction that 
completed (size is irrelevant for non-blocking connect and close calls).  
The mcapi_wait_any() call will return 0 if all the requests are cancelled 
by calls to mcapi_cancel() (during the waiting). The returned status will 
indicate that a request was cancelled. The units for timeout are implementation 
defined.  If a timeout occurs the mcapi_status parameter will indicate that 
a timeout occurred.    A value of MCAPI_INFINITE for the timeout parameter 
indicates no timeout is requested.
RETURN VALUE
On success, the index into the requests array of the mcapi_request_t 
identifier that has completed or has been canceled is returned and 
*mcapi_status is set to MCAPI_SUCCESS. On error MCAPI_NULL is returned 
and *mcapi_status is set to the appropriate error defined below.  
ERRORS
MCAPI_ENOTREQ_HANDLE Argument is not a valid request handle.
MCAPI_EREQ_CANCELED One of the requests was canceled, by another thread 
(during the waiting).
MCAPI_EREQ_TIMEOUT The operation timed out.
MCAPI_EPARAM Incorrect requests, size, and/or mcapi_status parameter.
NOTE
SEE ALSO
 mcapi_endpoint_t mcapi_get_endpoint_i(),
 mcapi_msg_send_i(),
 mcapi_msg_recv_i(),
 mcapi_connect_pktchan_i(),
 mcapi_open_pktchan_recv_i(),
 mcapi_open_pktchan_send_i(),
 mcapi_pktchan_send_i(),
 mcapi_pktchan_recv_i(),
 mcapi_pktchan_recv_close_i(),
 mcapi_pktchan_send_close_i(),
 mcapi_connect_sclchan_i(),
 mcapi_open_sclchan_recv_i(),
 mcapi_open_sclchan_send_i(),
 mcapi_sclchan_recv_close_i(),
 mcapi_sclchan_send_close_i()
************************************************************************/
mcapi_int_t mcapi_wait_any(
 	MCAPI_IN size_t number, 
 	MCAPI_IN mcapi_request_t** requests, 
 	MCAPI_OUT size_t* size, 
 	MCAPI_OUT mcapi_status_t* mcapi_status, 
 	MCAPI_IN mcapi_timeout_t timeout)
{
  mcapi_boolean_t rc = MCAPI_FALSE;
  
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    if (! valid_size_param(size)) {
      *mcapi_status = MCAPI_EPARAM;
      rc = MCAPI_TRUE;
    } else {
      rc = mcapi_trans_wait_any(number,requests,size,mcapi_status,timeout);
    }
  }
  return rc;
}


/***********************************************************************
NAME
mcapi_cancel - cancels an outstanding non-blocking operation.
DESCRIPTION
Cancels an outstanding non-blocking operation. It is a blocking function 
and returns when the operation has been canceled. request is the identifier 
for the non-blocking operation.  Any pending calls to mcapi_wait() or 
mcapi_wait_any() for this request will also be cancelled. The returned 
status of a canceled mcapi_wait() or mcapi_wait_any() call will indicate 
that the request was cancelled.  
RETURN VALUE
On success, *mcapi_status is set to MCAPI_SUCCESS. On error *mcapi_status 
is set to the appropriate error defined below.
ERRORS
MCAPI_ENOTREQ_HANDLE Argument is not a valid request handle (the operation 
may have completed).
MCAPI_EPARAM Incorrect mcapi_status parameter.
NOTE
SEE ALSO
 mcapi_endpoint_t mcapi_get_endpoint_i(),
 mcapi_msg_send_i(),
 mcapi_msg_recv_i(),
 mcapi_connect_pktchan_i(),
 mcapi_open_pktchan_recv_i(),
 mcapi_open_pktchan_send_i(),
 mcapi_pktchan_send_i(),
 mcapi_pktchan_recv_i(),
 mcapi_pktchan_recv_close_i(),
 mcapi_pktchan_send_close_i(),
 mcapi_connect_sclchan_i(),
 mcapi_open_sclchan_recv_i(),
 mcapi_open_sclchan_send_i(),
 mcapi_sclchan_recv_close_i(),
 mcapi_sclchan_send_close_i()
************************************************************************/
void mcapi_cancel(
 	MCAPI_IN mcapi_request_t* request, 
 	MCAPI_OUT mcapi_status_t* mcapi_status)
{
  if (! valid_status_param(mcapi_status)) {
    if (mcapi_status != NULL) {
      *mcapi_status = MCAPI_EPARAM;
    }
  } else {
    *mcapi_status = MCAPI_SUCCESS; 
    mcapi_trans_cancel(request,mcapi_status);
  }
}



