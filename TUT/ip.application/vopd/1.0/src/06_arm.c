/**
 *
 * @file   06_vid.c
 * @author Lasse Lehtonen
 * 
 * @brief VOPD - arm node.
 *
 */


#include "common.h"

#include <mcapi.h>

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <getopt.h>


const int LOCAL   = 6;
const int REMOTE  = 7;
const int TX_PORT = 14;
const int RX_PORT = 15;
const int TX_DATA = 16;//386;

const int IN_PORT = 31;

mcapi_pktchan_recv_hndl_t       send_handle;
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

   char   outgoing[TX_DATA];
   int    count = 0;
   
   char*  incoming;
   size_t bytes;

   mcapi_initialize(LOCAL, &version, &status);
   mcapi_assert_success(status);
   printf("Node %d: MCAPI Initialized\n", LOCAL);

   connect_rev(LOCAL, IN_PORT, &recv_handle);
   connect_fwd(LOCAL, TX_PORT, &send_handle, REMOTE, RX_PORT);

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
      memset(outgoing, 0, TX_DATA);
      sprintf(outgoing, "Node %d: arm (%d)", LOCAL, count);

      mcapi_pktchan_send(send_handle, outgoing, TX_DATA,
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

