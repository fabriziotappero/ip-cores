/* jsp_server.c -- Server for the JTAG serial port
   Copyright(C) 2010 Nathan Yawn <nyawn@opencores.org>

   This file is part the advanced debug unit / bridge.  It acts as a
   telnet server, to send and receive data for the JTAG Serial Port
   (JSP)

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */


#include <stdio.h>
#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <string.h>
#include <pthread.h>
#include <errno.h>
#include <netinet/in.h>
#include <unistd.h>

#include "dbg_api.h"
#include "hardware_monitor.h"
#include "errcodes.h"


#define debug(...) // fprintf(stderr, __VA_ARGS__ )

int jsp_server_fd = -1;
int jsp_client_fd = -1;
int jsp_pipe_fds[2];

/* Some convenient net address info to have around */
char jsp_ipstr[INET6_ADDRSTRLEN];
char *jsp_ipver;
int jsp_portnum;
char jsp_hostname[256];

/* Buffers for network data. Simple, static char arrays. */
#define JSP_BUFFER_SIZE 256
char jsp_tohw_buf[JSP_BUFFER_SIZE];
int jsp_tohw_rd_idx = 0;
int jsp_tohw_wr_idx = 0;
int jsp_tohw_count = 0;

char jsp_fromhw_buf[JSP_BUFFER_SIZE];
int jsp_fromhw_rd_idx = 0;
int jsp_fromhw_wr_idx = 0;
int jsp_fromhw_count = 0;

/* Other local data */
int jsp_server_running = 0;
int jsp_target_is_running = 0;

pthread_t jsp_server_thread;
void *jsp_server(void *arg);

void jsp_server_close(void);
void jsp_client_close(void);

void jsp_print_welcome(int fd);
void jsp_queue_data_from_client(int fd);
void jsp_send_data_to_client(int fd);
void jsp_hardware_transact(void);
void jsp_send_all(int fd, char *buf, int len);

/*----------------------------------------------------------*/
/* Public API                                               */
/*----------------------------------------------------------*/

void jsp_init(int portNum)
{
  int status;
  struct addrinfo hints;
  struct addrinfo *servinfo;  // will point to the results of getaddrinfo
  int optval; /* Socket options */
  char portnum[6];  /* portNum as a string */
  void *addr;

  debug("JSP Server initializing\n");

  jsp_server_fd      = -1;
  jsp_client_fd      = -1;
  jsp_portnum = portNum;

  memset(portnum, '\0', sizeof(portnum));
  snprintf(portnum, 5, "%i", portNum);

  /* Get the address info for the local host */
  memset(&hints, 0, sizeof hints); // make sure the struct is empty
  hints.ai_family = AF_UNSPEC;     // don't care IPv4 or IPv6
  hints.ai_socktype = SOCK_STREAM; // TCP stream sockets
  hints.ai_flags = AI_PASSIVE;     // fill in my IP for me
  
  if ((status = getaddrinfo(NULL, portnum, &hints, &servinfo)) != 0) {
    fprintf(stderr, "getaddrinfo error: %s\n", gai_strerror(status));
    return;
  }


  /* *** TODO: Select the appropriate servinfo in the linked list
   * For now, we just use the first entry in servinfo.
     struct addrinfo *servinfo, *p;
     for(p = servinfo;p != NULL; p = p->ai_next) {
     if (p->ai_family == AF_INET) { // IPv4
     } else { // IPv6
     }
     }
  */


  /* Save the IP address, for convenience (different fields in IPv4 and IPv6) */
  if (servinfo->ai_family == AF_INET) { // IPv4
    struct sockaddr_in *ipv4 = (struct sockaddr_in *)servinfo->ai_addr;
    addr = &(ipv4->sin_addr);
    jsp_ipver = "IPv4";
  } else { // IPv6
    struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)servinfo->ai_addr;
    addr = &(ipv6->sin6_addr);
    jsp_ipver = "IPv6";
  }

  /* convert the IP to a string */
  inet_ntop(servinfo->ai_family, addr, jsp_ipstr, sizeof(jsp_ipstr));

  /* Find out what our name is, save for convenience */
  if (gethostname (jsp_hostname, sizeof(jsp_hostname)) < 0)
    {
      fprintf (stderr, "Warning: Unable to get hostname for JSP server: %s\n", strerror(errno));
      jsp_hostname[0] = '\0';  /* This is not a fatal error. */
    }

  /* Create the socket */
  jsp_server_fd = socket (servinfo->ai_family, servinfo->ai_socktype, servinfo->ai_protocol);
  if (jsp_server_fd < 0)
    {
      fprintf (stderr, "Error: JSP could not create server socket: %s\n", strerror(errno));
      return;
    }

  /* Set this socket to reuse its address. */
  optval = 1;
  if (setsockopt(jsp_server_fd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof (optval)) == -1)
    {
      fprintf (stderr, "Cannot set SO_REUSEADDR option on server socket %d: %s\n", jsp_server_fd, strerror(errno));
      jsp_server_close();
      return;
    }

  /* Bind the socket to the local address */
  if (bind (jsp_server_fd, servinfo->ai_addr, servinfo->ai_addrlen) < 0)
    {
      fprintf (stderr, "Error: Unable to bind JSP server socket %d to port %d: %s\n", jsp_server_fd, portNum, strerror(errno));
      jsp_server_close();
      return;
    }

  /* Set us up as a server, with a maximum backlog of 1 connection */
  if (listen (jsp_server_fd, 1) < 0)
    {
      fprintf (stderr, "Warning: Unable to set JSP backlog on server socket %d to %d: %s\n", jsp_server_fd, 1, strerror(errno));
      jsp_server_close();
      return;
    }

  fprintf(stderr, "JSP server listening on host %s (%s), port %i, address family %s\n", 
	  jsp_hostname, jsp_ipstr, jsp_portnum, jsp_ipver);

  /* Register for stall/unstall events from the target monitor thread. Also creates pipe
   * for sending stall/unstall command to the target monitor, unused by us. */
  if(0 > register_with_monitor_thread(jsp_pipe_fds)) {  // pipe_fds[0] is for writing to monitor, [1] is to read from it
    fprintf(stderr, "JSP server failed to register with monitor thread, exiting");
    jsp_server_close();
    return;
  }

}


int jsp_server_start(void)
{

  jsp_server_running = 1;
 
  debug("Starting JSP server\n");

  // Create the JSP server thread
  if(pthread_create(&jsp_server_thread, NULL, jsp_server, NULL))
    {
      fprintf(stderr, "Failed to create JSP server thread!\n");
      return 0;
    }

  return 1;
}


int jsp_server_stop(void)
{
  /*** NOTE: Since we currently don't use select() in front of the accept()
   *** in the server thread, this won't actually work unless/until a client
   *** is connected.  Otherwise, the server thread will be blocked on the
   *** accept() (though closing the server socket may break it out.)
   ***/

  jsp_server_running = 0;
  jsp_server_close();
  return 1;
}

/*--------------------------------------------------------------------*/
/* Main server thread                                                 */
/*--------------------------------------------------------------------*/


void *jsp_server(void *arg)
{
  struct sockaddr_storage their_addr;
  struct timeval tv, *tvp;
  fd_set  readset;
  socklen_t addr_size;
  int nfds, flags;
  int ret;
  char cmd;

  fprintf(stderr, "JSP server thread running!\n");

  while(jsp_server_running)
    {
      /* Listen for an incoming connection */
      addr_size = sizeof their_addr;
      jsp_client_fd = accept(jsp_server_fd, (struct sockaddr *)&their_addr, &addr_size);

      if(jsp_client_fd == -1)
	{
	  perror("Error in accept() in JSP server thread");
	}
      else
	{
	  debug("JSP server got connection!\n");

	  // Clear the in/out buffers
	  jsp_tohw_rd_idx = 0;
	  jsp_tohw_wr_idx = 0;
	  jsp_tohw_count = 0;
	  jsp_fromhw_rd_idx = 0;
	  jsp_fromhw_wr_idx = 0;
	  jsp_fromhw_count = 0;

	  /* New client should be non-blocking. */
	  flags = fcntl (jsp_client_fd, F_GETFL);
	  if (flags < 0)
	    {
	      fprintf (stderr, "Warning: Unable to get flags for JSP client socket %d: %s\n", jsp_client_fd, strerror(errno));
	      // Not really fatal.
	    }
	  else {
	    flags |= O_NONBLOCK;
	    if (fcntl (jsp_client_fd, F_SETFL, flags) < 0)
	      {
		fprintf (stderr, "Warning: Unable to set flags for JSP client socket %d to 0x%08x: %s\n", jsp_client_fd, flags, strerror(errno));
		// Also not really fatal.
	      }
	  }

	  jsp_print_welcome(jsp_client_fd);
	}

      /* Send/receive data on the new connection for as long as it's valid */
      while(jsp_server_running && (jsp_client_fd != -1))
	{
	  /* if target not running, block on data from client or monitor thread */
	  /* if target running, just poll (don't block */
	  if(jsp_target_is_running) {
	    tv.tv_sec = 0;  // Set this each loop, it may be changed by the select() call
	    tv.tv_usec = 0;  // instant timeout when polling
	    tvp = &tv;
	  } else {
	    tvp = NULL;
	  }

	  FD_ZERO(&readset);
	  FD_SET(jsp_client_fd, &readset);
	  FD_SET(jsp_pipe_fds[1], &readset);
	  nfds = jsp_client_fd;
	  if(jsp_pipe_fds[1] > nfds) nfds = jsp_pipe_fds[1];
	  nfds++;

	  ret = select(nfds, &readset, NULL, NULL, tvp);

	  if(ret == -1)  // error
	    {
		perror("select()");
	    }
	  else if(ret != 0)  // fd ready (ret == 0 on timeout)
	    {
	      debug("JSP thread got data\n");

	      if(FD_ISSET(jsp_pipe_fds[1], &readset))
		{
		  ret = read(jsp_pipe_fds[1], &cmd, 1);
		  debug("JSP server got monitor status \'%c\' (0x%X)\n", cmd, cmd);
		  if(ret == 1)
		    {
		      if(cmd == 'H')  
			{
			  jsp_target_is_running = 0;
			}
		      else if(cmd == 'R')  
			{
			  jsp_target_is_running = 1;
			}
		      else
			{
			  fprintf(stderr, "JSP server got unknown monitor status \'%c\' (0x%X)\n", cmd, cmd);
			}
		    }
		  else
		    {
		      fprintf(stderr, "JSP server failed to read from ready monitor pipe!\n");
		    }
		}  // if FD_ISSET(jsp_pipe_fds[1])

	      if(FD_ISSET(jsp_client_fd, &readset))
		{
		  jsp_queue_data_from_client(jsp_client_fd);
		}
	    }   // else if (ret != 0)


	  /* Send any buffered output data to the client */
	  jsp_send_data_to_client(jsp_client_fd);

	  /* If target running, transact with the JSP to send/receive buffered data */
	  if(jsp_target_is_running)
	    {
	      jsp_hardware_transact();
	    }

	}  /* while client connection is valid */

    } /* while(jsp_server_running) */

  jsp_client_close();

  return arg;  // unused
}

/*--------------------------------------------------------------------*/
/* Helper functions                                                   */
/*--------------------------------------------------------------------*/

void jsp_server_close(void)
{
  if (jsp_server_fd != -1)
    {
      close(jsp_server_fd);
      jsp_server_fd = -1;
    }
}


void jsp_client_close(void)
{  
  if (jsp_client_fd != -1)
    {
      close (jsp_client_fd);
      jsp_client_fd = -1;
    }
}	/* jsp_client_close () */


void jsp_print_welcome(int fd)
{
  char msg[] = "Advanced Debug System JTAG Serial Port Server\n\r";
  char msg2[] = " (";
  char msg3[] = "), port ";
  char portnum[24];

  jsp_send_all(fd, msg, sizeof(msg));
  jsp_send_all(fd, jsp_hostname, strlen(jsp_hostname));
  jsp_send_all(fd, msg2, sizeof(msg2));
  jsp_send_all(fd, jsp_ipstr, strlen(jsp_ipstr));
  jsp_send_all(fd, msg3, sizeof(msg3));
  
  memset(portnum, '\0', sizeof(portnum));
  snprintf(portnum, 23, "%i\n\n\r", jsp_portnum);
  jsp_send_all(fd, portnum, strlen(portnum));
}


void jsp_queue_data_from_client(int fd)
{
  int space_available;
  int bytes_received;

  debug("JSP queueing data from client; Tohw count now %i\n", jsp_tohw_count);

  // First, try to fill from the write index to the end of the array, or the read index, whichever is less
  // This keeps the buffer that recv() writes to linear
  space_available = JSP_BUFFER_SIZE - jsp_tohw_wr_idx;
  if(space_available > (JSP_BUFFER_SIZE - jsp_tohw_count))
    space_available = JSP_BUFFER_SIZE - jsp_tohw_count;

  bytes_received = recv(fd, &jsp_tohw_buf[jsp_tohw_wr_idx], space_available, 0);
  if(bytes_received < 0)
    {
      perror("JSP client socket read failed");
      return;
    }
  else if(bytes_received > 0)
    {
      jsp_tohw_wr_idx = (jsp_tohw_wr_idx + bytes_received) % JSP_BUFFER_SIZE;  // modulo will only happen if wrapping to 0
      jsp_tohw_count += bytes_received;
    }

  // Now, do the same thing again, potentially filling the buffer from index 0 to the read index
  space_available = JSP_BUFFER_SIZE - jsp_tohw_wr_idx;
  if(space_available > (JSP_BUFFER_SIZE - jsp_tohw_count))
    space_available = JSP_BUFFER_SIZE - jsp_tohw_count;

  bytes_received = recv(fd, &jsp_tohw_buf[jsp_tohw_wr_idx], space_available, 0);
  if(bytes_received < 0)
    {
      if(errno != EAGAIN) {
	perror("JSP client socket read failed");
      } else {
	debug("Second JSP client socket read got EAGAIN.\n");
      }
      return;
    }
  else if(bytes_received > 0)
    {
      jsp_tohw_wr_idx = (jsp_tohw_wr_idx + bytes_received) % JSP_BUFFER_SIZE;  // modulo will only happen if wrapping to 0
      jsp_tohw_count += bytes_received;
    }

  debug("JSP queued data from client; Tohw count now %i\n", jsp_tohw_count);
}

void jsp_send_data_to_client(int fd)
{
  int bytes_written;
  int bytes_available;

  // *** TODO: use sendvec()
  debug("JSP will send data to client. Fromhw count now %i\n", jsp_fromhw_count);

  if(jsp_fromhw_count > 0)
    {
      bytes_available = jsp_fromhw_count;
      if(bytes_available > (JSP_BUFFER_SIZE - jsp_fromhw_rd_idx))
	bytes_available = JSP_BUFFER_SIZE - jsp_fromhw_rd_idx;
      
      bytes_written = send(fd, &jsp_fromhw_buf[jsp_fromhw_rd_idx], bytes_available, 0); 
      if(bytes_written < 0)
	{
	  perror("JSP server failed client socket write");
	}
      else
	{
	  jsp_fromhw_count -= bytes_written;
	  jsp_fromhw_rd_idx = (jsp_fromhw_rd_idx + bytes_written) % JSP_BUFFER_SIZE;
	}
    }

  // Now do it again, in case of buffer wraparound
  if(jsp_fromhw_count > 0)
    {
      bytes_available = jsp_fromhw_count;
      if(bytes_available > (JSP_BUFFER_SIZE - jsp_fromhw_rd_idx))
	bytes_available = JSP_BUFFER_SIZE - jsp_fromhw_rd_idx;
      
      bytes_written = send(fd, &jsp_fromhw_buf[jsp_fromhw_rd_idx], bytes_available, 0); 
      if(bytes_written < 0)
	{
	  perror("JSP server failed client socket write");
	}
      else
	{
	  jsp_fromhw_count -= bytes_written;
	  jsp_fromhw_rd_idx = (jsp_fromhw_rd_idx + bytes_written) % JSP_BUFFER_SIZE;
	}
    }

  debug("JSP sent data to client. Fromhw count now %i\n", jsp_fromhw_count);
}


void jsp_hardware_transact(void)
{
  unsigned int bytes_to_send;
  unsigned int bytes_received = 8;  // can receive up to 8 bytes
  unsigned char sendbuf[8];
  unsigned char rcvbuf[8];
  int i,j;
  int ret;

  debug("JSP about to transact; Tohw buf size now %i, fromhw buf size %i\n", jsp_tohw_count, jsp_fromhw_count);

  // Get data to send, if any
  bytes_to_send = jsp_tohw_count;
  if(bytes_to_send > 8) bytes_to_send = 8;

  j = jsp_tohw_rd_idx;
  for(i = 0; i < bytes_to_send; i++)
    {
      sendbuf[i] = jsp_tohw_buf[j];
      j = (j+1) % JSP_BUFFER_SIZE;
    }

  // Do the transaction
  ret = dbg_serial_sndrcv(&bytes_to_send, sendbuf, &bytes_received, rcvbuf);
  if(ret != APP_ERR_NONE)
    {
      fprintf(stderr, "Error in JSP transaction: %s\n", get_err_string(ret));
    }
  else
    {
      debug("Transacted, bytes sent = %i, received = %i\n", bytes_to_send, bytes_received);

      // Adjust send buffer pointers as necessary - we may not have sent all 8 bytes
      jsp_tohw_count -= bytes_to_send;
      jsp_tohw_rd_idx = (jsp_tohw_rd_idx + bytes_to_send) % JSP_BUFFER_SIZE;
      
      // Queue data received, if any, and adjust the pointers
      for(i = 0; i < bytes_received; i++)
	{
	  jsp_fromhw_buf[jsp_fromhw_wr_idx] = rcvbuf[i];
	  jsp_fromhw_wr_idx = (jsp_fromhw_wr_idx + 1) % JSP_BUFFER_SIZE;
	  jsp_fromhw_count++;
	}
      
      debug("JSP transacted; Tohw buf size now %i, fromhw buf size %i\n", jsp_tohw_count, jsp_fromhw_count);
    }
}

void jsp_send_all(int fd, char *buf, int len)
{
  int total_sent = 0;
  int bytes_sent;

  while(total_sent < len)
    {
      bytes_sent = send(fd, buf, len, 0);
      if(bytes_sent < 0)
	{
	  perror("JSP server socket send failed");
	  break;
	}
      total_sent += bytes_sent;
    }
}
