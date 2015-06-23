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

#include <mcapi.h>

#define WAIT_TIMEOUT 0xFFFFFFFF

#define mcapi_assert_success(s) \
	if (s != MCAPI_SUCCESS) { printf("%s:%d status %d\n", __FILE__, __LINE__, s); abort(); }

const int tx_port = 1000;
const int rx_port = 1001;

mcapi_pktchan_recv_hndl_t	send_handle;
mcapi_pktchan_recv_hndl_t	recv_handle;

static void connect(int local, int remote)
{
	mcapi_endpoint_t local_send_endpoint; 
	mcapi_endpoint_t local_recv_endpoint;
	mcapi_endpoint_t remote_recv_endpoint;
	mcapi_request_t  request;
	mcapi_request_t  send_request;
	mcapi_request_t  recv_request;
	mcapi_status_t   status;
	size_t           size;
	
	printf("Node %d: Creating tx port %d\n", local, tx_port);
	local_send_endpoint = mcapi_create_endpoint(tx_port, &status);
	mcapi_assert_success(status);

	printf("Node %d: Creating rx port %d\n", local, rx_port);
	local_recv_endpoint = mcapi_create_endpoint(rx_port, &status);
	mcapi_assert_success(status);

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
	mcapi_open_pktchan_send_i(&send_handle, local_send_endpoint, &send_request,
							  &status);

	printf("Node %d: Opening receive endpoint\n", local);
	mcapi_open_pktchan_recv_i(&recv_handle, local_recv_endpoint, &recv_request,
							  &status);

	mcapi_wait(&send_request, &size, &status, WAIT_TIMEOUT);	
	mcapi_assert_success(status);

	mcapi_wait(&recv_request, &size, &status, WAIT_TIMEOUT);	
	mcapi_assert_success(status);
	
	printf("Node %d: MCAPI negotiation complete! \n", local);
}

void startup(unsigned int local, unsigned int remote)
{
	mcapi_status_t status;
	mcapi_version_t version;

	printf("Node %d: MCAPI Initialized\n",local);
	mcapi_initialize(local, &version, &status);
	mcapi_assert_success(status);

	connect(local, remote);
}

void demo(unsigned int node, int loop)
{
	char outgoing[16];
	char *incoming;
	size_t bytes;
	mcapi_status_t status;

	do {
		memset(outgoing, 0, 16);
		sprintf(outgoing, "hi from node %d", node);

		mcapi_pktchan_send(send_handle, outgoing, strlen(outgoing)+1,
			&status);
		mcapi_assert_success(status);

		mcapi_pktchan_recv(recv_handle, (void *)&incoming, &bytes,
			&status);
		printf("received message: %s\n", incoming);

		mcapi_pktchan_free(incoming, &status);
		mcapi_assert_success(status);

		sleep(1);
	} while (loop);
}
