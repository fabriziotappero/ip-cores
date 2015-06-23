// udp_lite.c - LM




#include <stdio.h>      /* for printf() and fprintf() */
#include <sys/socket.h> /* for socket() and bind() */
#include <arpa/inet.h>  /* for sockaddr_in and inet_ntoa() */
#include <stdlib.h>     /* for atoi() and exit() */
#include <string.h>     /* for memset() */
#include <unistd.h>     /* for close() */

#define ServPort 6000


int sock;                        /* Socket */
struct sockaddr_in ServAddr; /* Local address */
struct sockaddr_in ClntAddr; /* Client address */
unsigned int cliAddrLen;         /* Length of incoming message */
char Buffer[maxBuffer];        /* Buffer for echo string */
unsigned short ServPort;     /* Server port */
int recvMsgSize;                 /* Size of received message */

void create_socket()
{
    

   
    /* Create socket for sending/receiving datagrams */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
        DieWithError("socket() failed");

    /* Construct local address structure */
    memset(&ServAddr, 0, sizeof(ServAddr));   /* Zero out structure */
    ServAddr.sin_family = AF_INET;                /* Internet address family */
    ServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    ServAddr.sin_port = htons(ServPort);      /* Local port */

    /* Bind to the local address */
    if (bind(sock, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr)) < 0)
        DieWithError("bind() failed");
  
}


 
void udp_send(buffer, buffer_size)
{
    

   /* Send datagrams to the client */
    if (sendto(sock, buffer, buffer_size, 0, 
	       (struct sockaddr *) &ClntAddr, sizeof(ClntAddr)) != MsgSize)
            DieWithError("sendto() sent a different number of bytes than expected");
    }
    /* NOT REACHED */
}

void udp_recv(){
  
  /* Block until receive message from a client */
  if ((recvMsgSize = recvfrom(sock, Buffer, maxBuffer, 0,
  (struct sockaddr *) &echoClntAddr, &cliAddrLen)) < 0)
    DieWithError("recvfrom() failed");
}
