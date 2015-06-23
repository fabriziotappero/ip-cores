/**
 *
 * @file   07_idct.c
 * @author Lasse Lehtonen
 *
 * @brief VOPD - idct node.
 *
 */


#include "common.h"

#include <mcapi.h>

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <getopt.h>

const int LOCAL    = 7;

const int REMOTE1  = 8;
const int TX_PORT1 = 16;
const int RX_PORT1 = 17;
const int TX_DATA1 = 361;//472;


const int IN_PORT1  = 13;
const int IN_PORT2  = 15;



mcapi_pktchan_recv_hndl_t       send_handle1;
mcapi_pktchan_recv_hndl_t       recv_handle1;
mcapi_pktchan_recv_hndl_t       recv_handle2;

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
   char*  incoming;
   size_t bytes;
   int count = 0;
   

   mcapi_initialize(LOCAL, &version, &status);
   mcapi_assert_success(status);
   printf("Node %d: MCAPI Initialized\n", LOCAL);

   connect_fwd(LOCAL, TX_PORT1, &send_handle1, REMOTE1, RX_PORT1);
   connect_rev(LOCAL, IN_PORT1, &recv_handle1);
   connect_rev(LOCAL, IN_PORT2, &recv_handle2);

   atexit(cleanup);
   sigaction(SIGQUIT, &action, &oldactions[SIGQUIT]);
   sigaction(SIGABRT, &action, &oldactions[SIGABRT]);
   sigaction(SIGTERM, &action, &oldactions[SIGTERM]);
   sigaction(SIGINT,  &action, &oldactions[SIGINT]);

   while(1) {
      
      mcapi_pktchan_recv(recv_handle1, (void *)&incoming, &bytes,
                        &status);
      printf("Node %d: received %d bytes :%s\n", LOCAL, bytes, incoming);
      
      mcapi_pktchan_free(incoming, &status);
      mcapi_assert_success(status);

      
      mcapi_pktchan_recv(recv_handle2, (void *)&incoming, &bytes,
                        &status);
      printf("Node %d: received %d bytes :%s\n", LOCAL, bytes, incoming);
      
      mcapi_pktchan_free(incoming, &status);
      mcapi_assert_success(status);
      
      count = (count+1) % 10;
      memset(outgoing1, 0, TX_DATA1);
      sprintf(outgoing1, "Node %d: idct (%d)", LOCAL, count);
      mcapi_pktchan_send(send_handle1, outgoing1, TX_DATA1,
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

