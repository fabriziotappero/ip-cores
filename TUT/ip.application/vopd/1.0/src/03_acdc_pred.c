/**
 *
 * @file   02_inv_scan.c
 * @author Lasse Lehtonen
 *
 * @brief VOPD - inv_scan node.
 *
 */


#include "common.h"

#include <mcapi.h>

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <getopt.h>

const int LOCAL    = 3;

const int REMOTE1  = 4;
const int TX_PORT1 = 6;
const int RX_PORT1 = 7;
const int TX_DATA1 = 50;//176;

const int REMOTE2  = 5;
const int TX_PORT2 = 8;
const int RX_PORT2 = 9;
const int TX_DATA2 = 370;//688;

const int IN_PORT  = 5;



mcapi_pktchan_recv_hndl_t       send_handle1;
mcapi_pktchan_recv_hndl_t       send_handle2;
mcapi_pktchan_recv_hndl_t       recv_handle;

static struct sigaction oldactions[32];

static void signalled(int signal, siginfo_t *info, void *context)
{
	struct sigaction *action;

	action = &oldactions[signal];

	if ((action->sa_flags & SA_SIGINFO) && action->sa_sigaction)
		action->sa_sigaction(signal, info, context);
	else if (action->sa_handler)
		action->sa_handler(signal);
	
	exit(signal);
}

struct sigaction action = {
	.sa_sigaction = signalled,
	.sa_flags = SA_SIGINFO,
};


int main(int argc, char* argv[])
{
   
   mcapi_status_t status;
   mcapi_version_t version;

   char   outgoing1[TX_DATA1];
   char   outgoing2[TX_DATA2];
   char*  incoming;
   size_t bytes;
   int count = 0;
   

   mcapi_initialize(LOCAL, &version, &status);
   mcapi_assert_success(status);
   printf("Node %d: MCAPI Initialized\n", LOCAL);

   
   connect_fwd(LOCAL, TX_PORT2, &send_handle2, REMOTE2, RX_PORT2);
   connect_fwd(LOCAL, TX_PORT1, &send_handle1, REMOTE1, RX_PORT1);
   connect_rev(LOCAL, IN_PORT, &recv_handle);

   atexit(cleanup);
   sigaction(SIGQUIT, &action, &oldactions[SIGQUIT]);
   sigaction(SIGABRT, &action, &oldactions[SIGABRT]);
   sigaction(SIGTERM, &action, &oldactions[SIGTERM]);
   sigaction(SIGINT,  &action, &oldactions[SIGINT]);

   while(1) {
      
      mcapi_pktchan_recv(recv_handle, (void *)&incoming, &bytes,
                        &status);
      printf("Node %d: received %d bytes :%s\n", LOCAL, bytes, incoming);
      
      mcapi_pktchan_free(incoming, &status);
      mcapi_assert_success(status);
      
      count = (count+1) % 10;
      memset(outgoing1, 0, TX_DATA1);
      sprintf(outgoing1, "Node %d: acdc_pred (%d)", LOCAL, count);

      mcapi_pktchan_send(send_handle1, outgoing1, TX_DATA1,
                         &status);
      mcapi_assert_success(status);      

      
      memset(outgoing2, 0, TX_DATA2);
      sprintf(outgoing2, "Node %d: acdc_pred (%d)", LOCAL, count);

      mcapi_pktchan_send(send_handle2, outgoing2, TX_DATA2,
                         &status);
      mcapi_assert_success(status);      
      
   }
 
   return 0;
}

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

