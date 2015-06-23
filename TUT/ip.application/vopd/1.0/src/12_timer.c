/**
 *
 * @file   12_timer.c
 * @author Lasse Lehtonen
 *
 * @brief VOPD - timer node.
 *
 */


#include "common.h"

#include <mcapi.h>

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <getopt.h>

const int LOCAL    = 12;

const int REMOTE1  = 0;
const int TX_PORT1 = 28;
const int RX_PORT1 = 29;
const int TX_DATA1 = 8;

const int REMOTE2  = 6;
const int TX_PORT2 = 30;
const int RX_PORT2 = 31;
const int TX_DATA2 = 8;





mcapi_pktchan_recv_hndl_t       send_handle1;
mcapi_pktchan_recv_hndl_t       send_handle2;


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
   int count = 0;
   

   mcapi_initialize(LOCAL, &version, &status);
   mcapi_assert_success(status);
   printf("Node %d: MCAPI Initialized\n", LOCAL);

   
   connect_fwd(LOCAL, TX_PORT2, &send_handle2, REMOTE2, RX_PORT2);
   connect_fwd(LOCAL, TX_PORT1, &send_handle1, REMOTE1, RX_PORT1);


   atexit(cleanup);
   sigaction(SIGQUIT, &action, &oldactions[SIGQUIT]);
   sigaction(SIGABRT, &action, &oldactions[SIGABRT]);
   sigaction(SIGTERM, &action, &oldactions[SIGTERM]);
   sigaction(SIGINT,  &action, &oldactions[SIGINT]);

   while(1) {
      
      
      count = (count+1) % 10;
      memset(outgoing1, 0, TX_DATA1);
      sprintf(outgoing1, "Node %d: timer (%d)", LOCAL, count);

      mcapi_pktchan_send(send_handle1, outgoing1, TX_DATA1,
                         &status);
      mcapi_assert_success(status);      

      
      memset(outgoing2, 0, TX_DATA2);
      sprintf(outgoing2, "Node %d: timer (%d)", LOCAL, count);

      mcapi_pktchan_send(send_handle2, outgoing2, TX_DATA2,
                         &status);
      mcapi_assert_success(status);     

      sleep(1);
      
   }
 
   return 0;
}

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

