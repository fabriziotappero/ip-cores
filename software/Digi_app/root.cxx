/*
* uTosNet_spi Digi application

* root.cxx
* File created by:
*	Simon Falsig
*	University of Southern Denmark
*	Copyright 2010
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU Lesser General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU Lesser General Public License for more details.
*
*	You should have received a copy of the GNU Lesser General Public License
*	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/


#include <stdio.h>
#include <stdlib.h>
#include <tx_api.h>
#include <sockapi.h>
#include <pthread.h>
#include <netoserr.h>
#include <string> 
#include <appservices.h>
#include <wxroot.h>

#include "spi_master_api.h"
#include "gpiomux_def.h"
#include "appconf.h"
#include "iam.hh"
#include "Npttypes.h"
#include "cliapi.h"			//Needed for custom cli functions


#define APP_SPI_MASTER_GPIO_CS      0
#define APP_SPI_MASTER_GPIO_CLK     5
#define APP_SPI_MASTER_GPIO_RXD     3
#define APP_SPI_MASTER_GPIO_TXD     7


#define MAX_CONNECTIONS 16		//The maximum number of simultaneous connections, may be adjusted
#define PACKETSIZE 8			//Do not change

#define DO_COMMIT_READ_PRE (1<<28)
#define DO_READ (1<<27)
#define DO_COMMIT_READ_POST (1<<26)
#define DO_COMMIT_WRITE_PRE (1<<12)
#define DO_WRITE (1<<11)
#define DO_COMMIT_WRITE_POST (1<<10)

enum THREAD_STATUS_TYPES
{
	FREE,
	RUNNING,
	TERMINATED
};

struct sockAddrIn
{
   short			sin_family;				// address family
   unsigned short   sin_port;				// port
   struct			in_addr  sin_addr;		// ip address
   char				sin_zero[8];

   /*
    * Adding constructors to sockaddr_in structure
    */
   sockAddrIn(){sin_family = AF_INET;}

   sockAddrIn(unsigned short port,unsigned long addr = 0)
    {
       sin_family = AF_INET;
       sin_port   = port;
       sin_addr.s_addr = addr;   
   };
};


THREAD_STATUS_TYPES threadInUse[MAX_CONNECTIONS];
SOCKET clientSockets[MAX_CONNECTIONS];
sockAddrIn* clientSockaddrs[MAX_CONNECTIONS];

/*
 * Server thread function 
 */
void netServer(unsigned long port);


/*
 * Network Read thread function 
 */
void netRead(unsigned long threadIndex);


/*
 * FPGA Write thread function
 */
void fpgaWrite(unsigned long comHandle);


int readDebug(int fd, int n, char * args[]); 		//Custom cli functions
int readDebugHelp(int fd, int n, char * args[]);	//

/*
 * Set this to 1 to run the system POST tests during startup.
 */
const int APP_POST = 0;

/*
 * Set this to 1 to run the manufacturing burn in tests.
 */
int APP_BURN_IN_TEST = 0; 

/*
 * Thread size
 */
#define STACK_SIZE      4096

/*
 * Thread control blocks
 */
TX_THREAD		net_server;
TX_THREAD		fpga_write;
TX_THREAD		*net_read[MAX_CONNECTIONS];

/*
 * Message queues
 */
TX_QUEUE		inMsg;

/*
 * Global variables
 */
unsigned int currentReceiverIndex = MAX_CONNECTIONS;
char* currentReceiverData;
int debug[2];



/*
 *
 *  Function: void applicationTcpDown (void)
 *
 *  Description:
 *
 *      This routine will be called by the NET+OS root thread once every 
 *      clock tick while it is waiting for the TCP/IP stack to come up.  
 *      
 *      This routone is called to print the application name and then 
 *      to print the '.' every second.
 *      
 *      This function will not be called once the stack has started.
 *
 *      This function uses the global C++ object PrintApplicationDown app_down.
 *
 *  Parameters:
 *
 *      none
 *
 *  Return Values:
 *
 *      none
 *
 */
extern "C"
void applicationTcpDown (void)
{
}



/*
 *
 *  Function: void applicationStart (void)
 *
 *  Description:
 *
 *      This routine is responsible for starting the user application.  It should 
 *      create any threads or other resources the application needs.
 *
 *      ThreadX, the NET+OS device drivers, and the TCP/IP stack will be running
 *      when this function is called.
 *
 *      This function uses global C++ object: 
 *              PrintApplicationDown app_down.
 *
 *  Parameters:
 *
 *      none
 *
 *  Return Values:
 *
 *      none
 *
 */

extern "C"
void applicationStart (void)

{
    void *stack;
    char *app_name;
    int rc,prio;

#ifdef NETOS_GNU_TOOLS
	using namespace std;
#endif

	/* Initialize the system services for the application. */
	initAppServices();
 
 
	/* 	
	 * Create queues for messaging between socket threads and fpga communication thread
	 */
	if(tx_queue_create(&inMsg, (char*)"Incoming Message Queue", TX_1_ULONG , (void*)0x300000, 4*MAX_CONNECTIONS) != SUCCESS)
	{
		netosFatalError ((char *)"Error creating Incoming Message Queue!", 5, 5);
	}

	int i=0;
	currentReceiverData = new char[PACKETSIZE+2+32];
	while(((int)(&currentReceiverData[i]))%32) i++;		//Buffers used for reading from SPI need to be on a 32 byte boundary
	currentReceiverData = &currentReceiverData[i];

	/*
	 * Add CLI debug stuff
	 */
	NaCliCmd_t userTable;
	
	userTable.command_name = "rd";
	userTable.command_func = readDebug;
	userTable.help_func = readDebugHelp;
	
	naCliAddUserTable(&userTable);
	
	/*
	 * Setup SPI communication
	 */
    NAconfigureGPIOpin(APP_SPI_MASTER_GPIO_CS, NA_GPIO_FUNC4_STATE, 0);      
    NAconfigureGPIOpin(APP_SPI_MASTER_GPIO_CLK, NA_GPIO_FUNC4_STATE, 0);
    NAconfigureGPIOpin(APP_SPI_MASTER_GPIO_RXD, NA_GPIO_FUNC4_STATE, 0);
    NAconfigureGPIOpin(APP_SPI_MASTER_GPIO_TXD, NA_GPIO_FUNC4_STATE, 0);

	NASpiDeviceConfigType spiDevice0 = {0, NULL, NULL, NA_SPI_MODE2, NA_SPI_MSB, 4000000, 2000, "SPI1"};	//2, 4000000

	NASpiRegisterDevice(&spiDevice0);

	/*
	 * Start threads
	 */
	prio = 16;


 	stack = malloc (STACK_SIZE);
	if (stack == NULL)
	{
		netosFatalError ((char *)"Unable to allocate thread stack.", 5, 5);
	}
	rc = tx_thread_create (&net_server,		 					/* control block for thread*/
	                        (char *)"Network Server thread",  	/* thread name*/
	                        netServer, 		     				/* entry function*/
	                        50000, 	            				/* parameter - port*/
	                        stack,              				/* start of stack*/
	                        STACK_SIZE,         				/* size of stack*/
	                        prio,               				/* priority*/
	                        prio,               				/* preemption threshold */
	                        1,                  				/* time slice threshold*/
	                        TX_AUTO_START);     				/* start immediately*/
	if (rc != TX_SUCCESS)
	{
	    netosFatalError ((char *)"Unable to create thread.", 5, 5);
	}



	stack = malloc (STACK_SIZE);
	if (stack == NULL)
	{
		netosFatalError ((char *)"Unable to allocate thread stack.", 5, 5);
	}
	rc = tx_thread_create (&fpga_write, 						/* control block for thread*/
	                        (char *)"Write to FPGA Thread",  	/* thread name*/
	                        fpgaWrite,  						/* entry function*/
	                        (unsigned long) 0,	 				/* parameter*/
	                        stack,              				/* start of stack*/
	                        STACK_SIZE,         				/* size of stack*/
	                        prio,  		           				/* priority*/
	                        prio,  		           				/* preemption threshold */
	                        1,                  				/* time slice threshold*/
	                        TX_AUTO_START);     				/* start immediately*/
	if (rc != TX_SUCCESS)
	{
	    netosFatalError ((char *)"Unable to create thread.", 5, 5);
    }


	/*
	 * Necessary threads started, suspend this thread
	 */
	tx_thread_suspend(tx_thread_identify());
}


/*
 *
 *  Function: void netServer()
 *
 *  Description:
 *
 *      This is the netServer thread function. 
 *		It waits for connections, accepts these, and spawns a new socket
 * 		and thread to handle them.
 * 		Old threads are automatically cleaned up when the socket is
 * 		disconnected.
 *
 */
void netServer(unsigned long port)
{
    void *stack[MAX_CONNECTIONS];
    int rc, prio = 16, currentThreadIndex;
    int bufsize = 65536;

    
    for(int n=0; n<MAX_CONNECTIONS; n++)
    {
    	threadInUse[n] = FREE;
    	clientSockaddrs[n] = new sockAddrIn;
    }
     
	SOCKET serverSocket;
	serverSocket = socket(AF_INET, SOCK_STREAM, 0);
	if(serverSocket == -1)
	{
		printf("Socket Creation Error %d\n", getErrno());
		return;
	}

	int error = 0;
	const int onValue = 1;	
	const int offValue = 0;	
	error += setsockopt(serverSocket, SOL_SOCKET, SO_SNDBUF, (char*)&bufsize, sizeof(bufsize));
	error += setsockopt(serverSocket, SOL_SOCKET, SO_RCVBUF, (char*)&bufsize, sizeof(bufsize));
	error += setsockopt(serverSocket, SOL_SOCKET, SO_BIO, (char*)&onValue, sizeof(onValue));
	error += setsockopt(serverSocket, SOL_SOCKET, SO_NONBLOCK, (char*)&offValue, sizeof(offValue));
	if(error != 0)
	{
		printf("Error setting Socket options %d\n", getErrno());
		return;
	}
	
	sockAddrIn sin(50000, INADDR_ANY);
	if(bind(serverSocket, (sockaddr *) &sin, sizeof(sin)) == -1)
	{
		printf("Error binding Socket %d\n", getErrno());
		return;
	}
	
	if(listen(serverSocket, MAX_CONNECTIONS) == -1)
	{
		printf("Error listening on Socket %d\n", getErrno());
		return;
	}
	
	int sinClientSize = sizeof(sockAddrIn);

	while(1)
	{
		for(int n=0; n<MAX_CONNECTIONS; n++)
		{
			if(threadInUse[n] == TERMINATED)
			{
				free(stack[n]);
				tx_thread_delete(net_read[n]);
				delete net_read[n];
				threadInUse[n] = FREE;
			}
		}
		
		currentThreadIndex = -1;
		for(int n=0; n<MAX_CONNECTIONS; n++)
		{
			if(threadInUse[n] == FREE)
			{
				currentThreadIndex = n;
				n = MAX_CONNECTIONS;
			}
		}
		
		if(currentThreadIndex > -1)
		{
			if((clientSockets[currentThreadIndex] = accept(serverSocket, (sockaddr*)clientSockaddrs[currentThreadIndex], &sinClientSize)) == -1)
			{
				printf("Error accepting client connection %d\n", getErrno());
				return;
			}
			net_read[currentThreadIndex] = new TX_THREAD;
			
			stack[currentThreadIndex] = malloc(STACK_SIZE);
			if (stack[currentThreadIndex] == NULL)
			{
				netosFatalError ((char *)"Unable to allocate thread stack.", 5, 5);
			}
			rc = tx_thread_create (net_read[currentThreadIndex],		/* control block for thread*/
			                        (char *)"Network Read thread",  	/* thread name*/
			                        netRead, 		     				/* entry function*/
			                        (unsigned long)currentThreadIndex,	/* parameter - port*/
			                        stack[currentThreadIndex],			/* start of stack*/
			                        STACK_SIZE,         				/* size of stack*/
			                        prio,               				/* priority*/
			                        prio,               				/* preemption threshold */
			                        1,                  				/* time slice threshold*/
			                        TX_AUTO_START);     				/* start immediately*/
			if (rc != TX_SUCCESS)
			{
			    netosFatalError ((char *)"Unable to create thread.", 5, 5);
			}
			else
			{
				threadInUse[currentThreadIndex] = RUNNING;
			}
		}
	    	    
		tx_thread_relinquish();
	}
}


/*
 *
 *  Function: void fpgaWrite()
 *
 *  Description:
 *
 *      This is the fpgaWrite thread function. 
 *		It accepts read/write requests from a message queue, and forwards these
 * 		to the FPGA over the SPI interface.
 *
 */
void fpgaWrite(unsigned long comHandle)
{
	char* writeBuffer;
	char* readBuffer;
	char* temp;
	unsigned long currentIndex;
	int i=0;
	
	readBuffer = new char[PACKETSIZE+2+32];
	
	while(((int)(&readBuffer[i]))%32) i++;
	
	readBuffer = &readBuffer[i];
	
	while(1)
	{
		if(tx_queue_receive(&inMsg, &writeBuffer, TX_NO_WAIT) == TX_SUCCESS)
		{
			currentIndex = writeBuffer[PACKETSIZE];
			for(int n=0; n<PACKETSIZE; n++)
			{
				readBuffer[n] = 0;
			}

			NASpiReadWrite("SPI1", (char*)writeBuffer, (char*)readBuffer, PACKETSIZE);

			if(((int*)writeBuffer)[0] & DO_COMMIT_READ_PRE)
			{
				((int*)writeBuffer)[0] &= ~(DO_COMMIT_READ_PRE + DO_COMMIT_WRITE_PRE + DO_WRITE + DO_COMMIT_WRITE_POST);

				do
				{
					tx_thread_relinquish();
					NASpiReadWrite("SPI1", (char*)writeBuffer, (char*)readBuffer, PACKETSIZE);
					debug[0] = ((int*)readBuffer)[0];
					debug[1] = ((int*)readBuffer)[1];
				}
				while(((unsigned int*)readBuffer)[0] > 1);
			}

			if(((int*)writeBuffer)[0] & DO_READ)
			{
				while(currentReceiverIndex != MAX_CONNECTIONS)
				{
					tx_thread_relinquish();
				}

				temp = readBuffer;
				readBuffer = currentReceiverData;
				currentReceiverData = temp;
				currentReceiverIndex = currentIndex;
			}
		}
		tx_thread_relinquish();
	}
}

/*
 *
 *  Function: void netRead(unsigned long threadIndex)
 *
 *  Description:
 *
 *      This is the netRead thread function. 
 *		It is spawned for every new connection made to the netServer, and
 * 		handles the necessary communication.
 *
 *  Parameters:
 * 
 *		threadIndex	-	The global index of the thread. Used for indexing into
 * 						the global thread status variables.
 * 
 */
void netRead(unsigned long threadIndex)
{
	char* buffer;
	int temp;
	char backupTemp;
	
	buffer = new char[PACKETSIZE + 2];
	buffer[PACKETSIZE] = '\0';
	bool doRead, doWrite;
		 
	while(1)
	{
        if((temp = recv(clientSockets[threadIndex], buffer, PACKETSIZE, 0)) < 1)
        {
			threadInUse[threadIndex] = TERMINATED;
        	delete [] buffer;
        	closesocket(clientSockets[threadIndex]);
        	tx_thread_terminate(tx_thread_identify());
        }
        else
        {
        	for(int n=0; n<(PACKETSIZE/4); n++)
        	{
        		backupTemp = buffer[n*4];
        		buffer[n*4] = buffer[n*4+3];
        		buffer[n*4+3] = backupTemp;
        		backupTemp = buffer[n*4+2];
        		buffer[n*4+2] = buffer[n*4+1];
        		buffer[n*4+1] = backupTemp;
        	}
        	
        	buffer[PACKETSIZE+1] = '\0';
			buffer[PACKETSIZE] = threadIndex;

			doRead = ((int*)buffer)[0] & DO_READ;
			doWrite = ((int*)buffer)[0] & DO_WRITE;
			
			if(doWrite && (temp < 8))
			{
				((int*)buffer)[0] &= ~(DO_COMMIT_WRITE_PRE + DO_WRITE + DO_COMMIT_WRITE_POST);
			}
			
			if(!doRead)
			{
				((int*)buffer)[0] &= ~(DO_COMMIT_READ_PRE);
			}				
						
			tx_queue_send(&inMsg, &buffer, TX_NO_WAIT);

			if(doRead)
			{
				while(currentReceiverIndex != threadIndex)
				{
					tx_thread_relinquish();
				}

        		backupTemp = (&(currentReceiverData[4]))[0];
        		(&(currentReceiverData[4]))[0] = (&(currentReceiverData[4]))[3];
        		(&(currentReceiverData[4]))[3] = backupTemp;
        		backupTemp = (&(currentReceiverData[4]))[2];
        		(&(currentReceiverData[4]))[2] = (&(currentReceiverData[4]))[1];
        		(&(currentReceiverData[4]))[1] = backupTemp;

				send(clientSockets[threadIndex], (&(currentReceiverData[4])), 4, 0);

				currentReceiverIndex = MAX_CONNECTIONS;
			}
        }
	    
		tx_thread_relinquish();
	}
}


int readDebug(int fd, int n, char * args[])
{
	naCliPrintf(fd, "Read values: %.8x  |  %.8x\n\r", debug[0], debug[1]);
	
	return 0;
}

int readDebugHelp(int fd, int n, char * args[])
{
	naCliPrintf(fd, "Prints the six first integers in the read-array from the SPI transfer");
	
	return 0;
}

