/**
 *
 * @file   common.c
 * @author Lasse Lehtonen
 *
 * @brief VOPD - Common stuff for all nodes.
 *
 */


#include "common.h"

#include <assert.h>
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h> 

void connect_fwd(int local, int tx_port, mcapi_pktchan_recv_hndl_t* send_hndl,
                 int remote, int rx_port)
{
   mcapi_endpoint_t local_send_endpoint; 
   
   mcapi_endpoint_t remote_recv_endpoint;
   mcapi_request_t  request;
   mcapi_request_t  send_request;
   
   mcapi_status_t   status;
   size_t           size;

   
   printf("Node %d: Creating tx port %d\n", local, tx_port);
   local_send_endpoint = mcapi_create_endpoint(tx_port, &status);
   mcapi_assert_success(status);

   printf("Node %d: Creating remote rx port %d\n", local, rx_port);
   remote_recv_endpoint = mcapi_get_endpoint(remote, rx_port, &status);
   mcapi_assert_success(status);

   printf("Node %d: Connecting %d:%d to %d:%d\n",local, local, tx_port,
          remote, rx_port);
   mcapi_connect_pktchan_i(local_send_endpoint, remote_recv_endpoint,
                           &request, &status);
   mcapi_assert_success(status);

   mcapi_wait(&request, &size, &status, WAIT_TIMEOUT);     
   mcapi_assert_success(status);

   printf("Node %d: Connection complete\n", local);

   printf("Node %d: Opening send endpoint\n", local);
   mcapi_open_pktchan_send_i(send_hndl, local_send_endpoint, &send_request,
                             &status);

   mcapi_wait(&send_request, &size, &status, WAIT_TIMEOUT);        
   mcapi_assert_success(status);

   printf("Node %d: MCAPI forward connection complete! \n", local);
   
}



void connect_rev(int local, int rx_port, mcapi_pktchan_recv_hndl_t* recv_hndl)
{
   mcapi_endpoint_t local_recv_endpoint;
   mcapi_request_t  recv_request;
   mcapi_status_t   status;
   size_t           size;

   printf("Node %d: Creating local rx port %d\n", local, rx_port);
   local_recv_endpoint = mcapi_create_endpoint(rx_port, &status);
   mcapi_assert_success(status);

   printf("Node %d: Opening receive endpoint\n", local);
   mcapi_open_pktchan_recv_i(recv_hndl, local_recv_endpoint, &recv_request,
                             &status);

   mcapi_wait(&recv_request, &size, &status, WAIT_TIMEOUT);        
   mcapi_assert_success(status);

   printf("Node %d: MCAPI reverse connection complete! \n", local);

}


void cleanup()
{
   mcapi_status_t status;
   mcapi_finalize(&status);
}

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

