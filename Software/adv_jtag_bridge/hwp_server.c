/* hwp_server.c -- Server for hardware watchpoint handling
   Copyright(C) 2010 Nathan Yawn <nyawn@opencores.org>

   This file is part the advanced debug unit / bridge.  GDB does not
   have support for the OR1200's advanced hardware watchpoints.  This
   acts as a server for a client program that can read and set them. 

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
#include <netinet/in.h>
#include <unistd.h>
#include <netdb.h>
#include <string.h>
#include <pthread.h>
#include <errno.h>

#include "spr-defs.h"
#include "dbg_api.h"
#include "hardware_monitor.h"
#include "errcodes.h"


#define debug(...) // fprintf(stderr, __VA_ARGS__ )

#define HWP_BUF_MAX 256

/*! Data structure for RSP buffers. Can't be null terminated, since it may
  include zero bytes */
struct rsp_buf
{
  char  data[HWP_BUF_MAX];
  int   len;
};

int hwp_server_fd = -1;
int hwp_client_fd = -1;
int hwp_pipe_fds[2];

/* Some convenient net address info to have around */
char hwp_ipstr[INET6_ADDRSTRLEN];
char *hwp_ipver;
int hwp_portnum;
char hwp_hostname[256];

/* Other local data */
int hwp_server_running = 0;
int hwp_target_is_running = 0;
int use_cached_dmr2 = 0;
uint32_t cached_dmr2 = 0;

/* To track which watchpoints are in use by an external program,
 * so that the RSP server can have the unused ones for GDB
 */
#define HWP_MAX_WP 8
unsigned char hwp_in_use[HWP_MAX_WP];

/*! String to map hex digits to chars */
static const char hexchars[]="0123456789abcdef";

pthread_t hwp_server_thread;
void *hwp_server(void *arg);

void hwp_server_close(void);
void hwp_client_close(void);
void hwp_client_request(void);

struct rsp_buf *hwp_get_packet(void);
void put_hwp_rsp_char(int fd, char c);
int get_hwp_rsp_char(int fd);
void hwp_read_reg(struct rsp_buf *buf);
void hwp_write_reg (struct rsp_buf *buf);
void hwp_put_str_packet (int fd, const char *str);
void hwp_put_packet (int fd, struct rsp_buf *buf);
unsigned long int hwp_hex2reg (char *buf);
void hwp_reg2hex (unsigned long int val, char *buf);
int hwp_hex(int c);
void hwp_report_run(void);
void hwp_report_stop(void);
void hwp_set_in_use(unsigned int wp, unsigned char inuse);

/*----------------------------------------------------------*/
/* Public API                                               */
/*----------------------------------------------------------*/

int hwp_init(int portNum)
{
  int status;
  struct addrinfo hints;
  struct addrinfo *servinfo;  // will point to the results of getaddrinfo
  int optval; /* Socket options */
  char portnum[6];  /* portNum as a string */
  void *addr;
  int i, errcode;
  uint32_t regaddr, tmp;

  debug("HWP Server initializing\n");

  /* First thing's first:  Check if there are any HWP. 
  * Read all DCR, mark which are present.*/
  status = 0;
  for(i = 0; i < HWP_MAX_WP; i++)
    {
      regaddr = SPR_DCR(i);
      errcode = dbg_cpu0_read(regaddr, &tmp);
      if(errcode != APP_ERR_NONE)
	{
	  fprintf(stderr, "ERROR reading DCR %i at startup! %s\n", i,  get_err_string(errcode));
	  hwp_set_in_use(i, 1);
	}
      else
	{
	  if(tmp & 0x1)  /* HWP present */
	    {
	      hwp_set_in_use(i, 0);
	      status++;
	    }
	  else  /* HWP not implemented */
	    {
	      hwp_set_in_use(i, 1);
	    }
	}
      debug("HWP %i is %s\n", i, hwp_in_use[i] ? "absent":"present");
    }

  if(status <= 0)
    {
      fprintf(stderr, "No watchpoint hardware found, HWP server not starting\n");
      return 0;
    }
  else
    {
      fprintf(stderr, "HWP server initializing with %i watchpoints available\n", status);

      /* We have watchpoint hardware.  Initialize the server. */
      hwp_server_fd      = -1;
      hwp_client_fd      = -1;
      hwp_portnum = portNum;
      
      memset(portnum, '\0', sizeof(portnum));
      snprintf(portnum, 5, "%i", portNum);
      
      /* Get the address info for the local host */
      memset(&hints, 0, sizeof hints); // make sure the struct is empty
      hints.ai_family = AF_UNSPEC;     // don't care IPv4 or IPv6
      hints.ai_socktype = SOCK_STREAM; // TCP stream sockets
      hints.ai_flags = AI_PASSIVE;     // fill in my IP for me
      
      if ((status = getaddrinfo(NULL, portnum, &hints, &servinfo)) != 0) {
	fprintf(stderr, "getaddrinfo error: %s\n", gai_strerror(status));
	return 0;
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
	hwp_ipver = "IPv4";
      } else { // IPv6
	struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)servinfo->ai_addr;
	addr = &(ipv6->sin6_addr);
	hwp_ipver = "IPv6";
      }
      
      /* convert the IP to a string */
      inet_ntop(servinfo->ai_family, addr, hwp_ipstr, sizeof(hwp_ipstr));
      
      /* Find out what our name is, save for convenience */
      if (gethostname (hwp_hostname, sizeof(hwp_hostname)) < 0)
	{
	  fprintf (stderr, "Warning: Unable to get hostname for HWP server: %s\n", strerror(errno));
	  hwp_hostname[0] = '\0';  /* This is not a fatal error. */
	}
      
      /* Create the socket */
      hwp_server_fd = socket (servinfo->ai_family, servinfo->ai_socktype, servinfo->ai_protocol);
      if (hwp_server_fd < 0)
	{
	  fprintf (stderr, "Error: HWP could not create server socket: %s\n", strerror(errno));
	  return 0;
	}
      
      /* Set this socket to reuse its address. */
      optval = 1;
      if (setsockopt(hwp_server_fd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof (optval)) == -1)
	{
	  fprintf (stderr, "Cannot set SO_REUSEADDR option on server socket %d: %s\n", hwp_server_fd, strerror(errno));
	  hwp_server_close();
	  return 0;
	}
      
      /* Bind the socket to the local address */
      if (bind (hwp_server_fd, servinfo->ai_addr, servinfo->ai_addrlen) < 0)
	{
	  fprintf (stderr, "Error: Unable to bind HWP server socket %d to port %d: %s\n", hwp_server_fd, portNum, strerror(errno));
	  hwp_server_close();
	  return 0;
	}
      
      /* Set us up as a server, with a maximum backlog of 1 connection */
      if (listen (hwp_server_fd, 1) < 0)
	{
	  fprintf (stderr, "Warning: Unable to set HWP backlog on server socket %d to %d: %s\n", hwp_server_fd, 1, strerror(errno));
	  hwp_server_close();
	  return 0;
	}
      
      fprintf(stderr, "HWP server listening on host %s (%s), port %i, address family %s\n", 
	      hwp_hostname, hwp_ipstr, hwp_portnum, hwp_ipver);
      
      /* Register for stall/unstall events from the target monitor thread. Also creates pipe
       * for sending stall/unstall command to the target monitor, unused by us. */
      if(0 > register_with_monitor_thread(hwp_pipe_fds)) {  // pipe_fds[0] is for writing to monitor, [1] is to read from it
	fprintf(stderr, "HWP server failed to register with monitor thread, exiting");
	hwp_server_close();
	return 0;
      }
    }

  return 1;
}


int hwp_server_start(void)
{

  hwp_server_running = 1;
 
  debug("Starting HWP server\n");

  // Create the HWP server thread
  if(pthread_create(&hwp_server_thread, NULL, hwp_server, NULL))
    {
      fprintf(stderr, "Failed to create HWP server thread!\n");
      return 0;
    }

  return 1;
}


int hwp_server_stop(void)
{
  /*** NOTE: Since we currently don't use select() in front of the accept()
   *** in the server thread, this won't actually work unless/until a client
   *** is connected.  Otherwise, the server thread will be blocked on the
   *** accept() (though closing the server socket may break it out.)
   ***/

  hwp_server_running = 0;
  hwp_server_close();
  return 1;
}

/*--------------------------------------------------------------------*/
/* Main server thread                                                 */
/*--------------------------------------------------------------------*/


void *hwp_server(void *arg)
{
  struct sockaddr_storage their_addr;
  struct timeval *tvp;
  fd_set  readset;
  socklen_t addr_size;
  int nfds, flags;
  int ret;
  char cmd;

  fprintf(stderr, "HWP server thread running!\n");

  while(hwp_server_running)
    {
      /* Listen for an incoming connection */
      addr_size = sizeof their_addr;
      hwp_client_fd = accept(hwp_server_fd, (struct sockaddr *)&their_addr, &addr_size);

      if(hwp_client_fd == -1)
	{
	  perror("Error in accept() in HWP server thread");
	}
      else
	{
	  debug("HWP server got connection!\n");

	  /* Do new client init stuff here */
	  use_cached_dmr2 = 0;

	  /* New client should be non-blocking. */
	  flags = fcntl (hwp_client_fd, F_GETFL);
	  if (flags < 0)
	    {
	      fprintf (stderr, "Warning: Unable to get flags for HWP client socket %d: %s\n", hwp_client_fd, strerror(errno));
	      // Not really fatal.
	    }
	  else {
	    flags |= O_NONBLOCK;
	    if (fcntl (hwp_client_fd, F_SETFL, flags) < 0)
	      {
		fprintf (stderr, "Warning: Unable to set flags for HWP client socket %d to 0x%08x: %s\n", hwp_client_fd, flags, strerror(errno));
		// Also not really fatal.
	      }
	  }
	}

      /* Send/receive data on the new connection for as long as it's valid */
      while(hwp_server_running && (hwp_client_fd != -1))
	{
	  /* if target not running, block on data from client or monitor thread */
	  /* if target running, just poll (don't block) */
	  // if(hwp_target_is_running) {
	  //  tv.tv_sec = 0;  // Set this each loop, it may be changed by the select() call
	  //  tv.tv_usec = 0;  // instant timeout when polling
	  //  tvp = &tv;
	  //} else {
	    tvp = NULL;
	    //}

	  FD_ZERO(&readset);
	  FD_SET(hwp_client_fd, &readset);
	  FD_SET(hwp_pipe_fds[1], &readset);
	  nfds = hwp_client_fd;
	  if(hwp_pipe_fds[1] > nfds) nfds = hwp_pipe_fds[1];
	  nfds++;

	  ret = select(nfds, &readset, NULL, NULL, tvp);

	  if(ret == -1)  // error
	    {
		perror("select()");
	    }
	  else if(ret != 0)  // fd ready (ret == 0 on timeout)
	    {
	      debug("HWP thread got data\n");

	      if(FD_ISSET(hwp_pipe_fds[1], &readset))
		{
		  ret = read(hwp_pipe_fds[1], &cmd, 1);
		  debug("HWP server got monitor status \'%c\' (0x%X)\n", cmd, cmd);
		  if(ret == 1)
		    {
		      if(cmd == 'H')  
			{
			  // Save state so we can tell client on request
			  hwp_target_is_running = 0;
			}
		      else if(cmd == 'R')  
			{
			  // Save state so we can tell client on request
			  hwp_target_is_running = 1;
			  use_cached_dmr2 = 0;
			}
		      else
			{
			  fprintf(stderr, "HWP server got unknown monitor status \'%c\' (0x%X)\n", cmd, cmd);
			}
		    }
		  else
		    {
		      fprintf(stderr, "HWP server failed to read from ready monitor pipe!\n");
		    }
		}  // if FD_ISSET(hwp_pipe_fds[1])

	      if(FD_ISSET(hwp_client_fd, &readset))
		{
		  hwp_client_request();
		}
	    }   // else if (ret != 0)

	}  /* while client connection is valid */

    } /* while(hwp_server_running) */

  hwp_client_close();

  return arg;  // unused
}

/*--------------------------------------------------------------------*/
/* Helper functions                                                   */
/*--------------------------------------------------------------------*/

void hwp_server_close(void)
{
  if (hwp_server_fd != -1)
    {
      close(hwp_server_fd);
      hwp_server_fd = -1;
    }
}


void hwp_client_close(void)
{  
  if (hwp_client_fd != -1)
    {
      close (hwp_client_fd);
      hwp_client_fd = -1;
    }
}	/* hwp_client_close () */


void hwp_client_request(void)
{
  struct rsp_buf *buf = hwp_get_packet ();	/* Message sent to us */

  // Null packet means we hit EOF or the link was closed for some other
  // reason. Close the client and return
  if (NULL == buf)
    {
      hwp_client_close ();
      return;
    }

  debug("HWP Packet received %s: %d chars\n", buf->data, buf->len );

  switch (buf->data[0])
    {
 
    case '?':
      // Different meaning than RSP: in RSP, this always returns an 'S' packet.
      // here, we want to know running / stopped.
      if(hwp_target_is_running) {
	hwp_report_run();
      } else {
	hwp_report_stop();
      }
      return;
 

      /*
	case 'g':
	rsp_read_all_regs ();
	return;

	case 'G':
	rsp_write_all_regs (buf);
	return;
      */


    case 'p':
      /* Read a register */
      hwp_read_reg(buf);
      return;

    case 'P':
      /* Write a register */
      hwp_write_reg(buf);
      return;

      /*
	case 'q':
	// Any one of a number of query packets
	rsp_query (buf);
	return;
	
	case 'Q':
	// Any one of a number of set packets
	rsp_set (buf);
	return;
      */
 
    default:
      /* Unknown commands are ignored */
      fprintf (stderr, "Warning: Unknown HWP request %s\n", buf->data);
      return;
    }
}	/* hwp_client_request () */


/*---------------------------------------------------------------------------*/
/*!Get a packet from the GDB client
  
   Modeled on the stub version supplied with GDB. The data is in a static
   buffer. The data should be copied elsewhere if it is to be preserved across
   a subsequent call to get_packet().

   Unlike the reference implementation, we don't deal with sequence
   numbers. GDB has never used them, and this implementation is only intended
   for use with GDB 6.8 or later. Sequence numbers were removed from the RSP
   standard at GDB 5.0.

   @return  A pointer to the static buffer containing the data                */
/*---------------------------------------------------------------------------*/
struct rsp_buf *hwp_get_packet(void)
{
  static struct rsp_buf  buf;		/* Survives the return */

  /* Keep getting packets, until one is found with a valid checksum */
  while (1)
    {
      unsigned char  checksum;		/* The checksum we have computed */
      int            count;		/* Index into the buffer */
      int 	     ch;		/* Current character */

      /* Wait around for the start character ('$'). Ignore all other
	 characters */
      ch = get_hwp_rsp_char(hwp_client_fd);
      while (ch != '$')
	{
	  if (-1 == ch)
	    {
	      return  NULL;		/* Connection failed */
	    }

	  ch = get_hwp_rsp_char(hwp_client_fd);
	}

      /* Read until a '#' or end of buffer is found */
      checksum =  0;
      count    =  0;
      while (count < HWP_BUF_MAX - 1)
	{
	  ch = get_hwp_rsp_char(hwp_client_fd);

	  /* Check for connection failure */
	  if (-1 == ch)
	    {
	      return  NULL;
	    }

	  /* If we hit a start of line char begin all over again */
	  if ('$' == ch)
	    {
	      checksum =  0;
	      count    =  0;

	      continue;
	    }

	  /* Break out if we get the end of line char */
	  if ('#' == ch)
	    {
	      break;
	    }

	  /* Update the checksum and add the char to the buffer */

	  checksum        = checksum + (unsigned char)ch;
	  buf.data[count] = (char)ch;
	  count           = count + 1;
	}

      /* Mark the end of the buffer with EOS - it's convenient for non-binary
	 data to be valid strings. */
      buf.data[count] = 0;
      buf.len         = count;

      /* If we have a valid end of packet char, validate the checksum */
      if ('#' == ch)
	{
	  unsigned char  xmitcsum;	/* The checksum in the packet */

	  ch = get_hwp_rsp_char(hwp_client_fd);
	  if (-1 == ch)
	    {
	      return  NULL;		/* Connection failed */
	    }
	  xmitcsum = hwp_hex(ch) << 4;

	  ch = get_hwp_rsp_char(hwp_client_fd);
	  if (-1 == ch)
	    {
	      return  NULL;		/* Connection failed */
	    }

	  xmitcsum += hwp_hex(ch);

	  /* If the checksums don't match print a warning, and put the
	     negative ack back to the client. Otherwise put a positive ack. */
	  if (checksum != xmitcsum)
	    {
	      fprintf (stderr, "Warning: Bad HWP RSP checksum: Computed "
		       "0x%02x, received 0x%02x\n", checksum, xmitcsum);

	      put_hwp_rsp_char (hwp_client_fd, '-');	/* Failed checksum */
	    }
	  else
	    {
	      put_hwp_rsp_char (hwp_client_fd, '+');	/* successful transfer */
	      break;
	    }
	}
      else
	{
	  fprintf (stderr, "Warning: HWP RSP packet overran buffer\n");
	}
    }

  return &buf;				/* Success */

}	/* hwp_get_packet () */


/*---------------------------------------------------------------------------*/
/*Single character get/set routines                                          */
/*---------------------------------------------------------------------------*/
void put_hwp_rsp_char(int fd, char  c)
{
  if (-1 == fd)
    {
      fprintf (stderr, "Warning: Attempt to write '%c' to unopened HWP RSP client: Ignored\n", c);
      return;
    }

  /* Write until successful (we retry after interrupts) or catastrophic
     failure. */
  while (1)
    {
      switch (write(fd, &c, sizeof (c)))
	{
	case -1:
	  /* Error: only allow interrupts or would block */
	  if ((EAGAIN != errno) && (EINTR != errno))
	    {
	      fprintf (stderr, "Warning: Failed to write to HWP RSP client: Closing client connection: %s\n",
		       strerror (errno));
	      hwp_client_close();
	      return;
	    }
      
	  break;

	case 0:
	  break;		/* Nothing written! Try again */

	default:
	  return;		/* Success, we can return */
	}
    }
}	/* put_hwp_rsp_char() */



int get_hwp_rsp_char(int fd)
{
  unsigned char  c;		/* The character read */

  if (-1 == fd)
    {
      fprintf (stderr, "Warning: Attempt to read from unopened HWP RSP client: Ignored\n");
      return  -1;
    }

  /* Read until successful (we retry after interrupts) or catastrophic
     failure. */
  while (1)
    {
      switch (read (fd, &c, sizeof (c)))
	{
	case -1:
	  /* Error: only allow interrupts or would block */
	  if ((EAGAIN != errno) && (EINTR != errno))
	    {
	      fprintf (stderr, "Warning: Failed to read from HWP RSP client: Closing client connection: %s\n",
		       strerror (errno));
	      hwp_client_close();
	      return  -1;
	    }
      
	  break;

	case 0:
	  // EOF
	  hwp_client_close();
	  return  -1;

	default:
	  return  c & 0xff;	/* Success, we can return (no sign extend!) */
	}
    }
}	/* get_hwp_rsp_char() */


/*---------------------------------------------------------------------------*/
/*!Read a single register

   The registers follow the GDB sequence for OR1K: GPR0 through GPR31, PC
   (i.e. SPR NPC) and SR (i.e. SPR SR). The register is returned as a
   sequence of bytes in target endian order.

   Each byte is packed as a pair of hex digits.

   @param[in] buf  The original packet request. Reused for the reply.        */
/*---------------------------------------------------------------------------*/
void hwp_read_reg(struct rsp_buf *buf)
{
  unsigned int  regnum;
  uint32_t tmp;
  unsigned int errcode = APP_ERR_NONE;

  /* Break out the fields from the data */
  if (1 != sscanf (buf->data, "p%x", &regnum))
    {
      fprintf (stderr, "Warning: Failed to recognize HWP RSP read register command: \'%s\'\n", buf->data);
      hwp_put_str_packet (hwp_client_fd, "E01");
      return;
    }

  if((regnum == SPR_DMR2) && use_cached_dmr2)  // Should we use the cached DMR2 value?
    {
      tmp = cached_dmr2;
      errcode = APP_ERR_NONE;
      fprintf(stderr, "Using cached DMR2 value 0x%X\n", tmp);
    }
  else
    {
      /* Get the relevant register.  We assume the client is not GDB,
       * and that no register number translation is needed. 
       */
      errcode = dbg_cpu0_read(regnum, &tmp);
    }

  if(errcode == APP_ERR_NONE) {
    hwp_reg2hex(tmp, buf->data);
    buf->len = strlen (buf->data);
    debug("Read reg 0x%x, got %s (0x%X), len %i\n", regnum, buf->data, tmp, buf->len);
    hwp_put_packet (hwp_client_fd, buf);
  }
  else {
    fprintf(stderr, "Error reading HWP register: %s\n", get_err_string(errcode));
    hwp_put_str_packet(hwp_client_fd, "E01");
  }

}	/* hwp_read_reg() */

    
/*---------------------------------------------------------------------------*/
/*!Write a single register

   The registers follow the GDB sequence for OR1K: GPR0 through GPR31, PC
   (i.e. SPR NPC) and SR (i.e. SPR SR). The register is specified as a
   sequence of bytes in target endian order.

   Each byte is packed as a pair of hex digits.

   @param[in] buf  The original packet request.                              */
/*---------------------------------------------------------------------------*/
void hwp_write_reg (struct rsp_buf *buf)
{
  unsigned int  regnum;
  char          valstr[9];		/* Allow for EOS on the string */
  unsigned int  errcode = APP_ERR_NONE;
  int dcridx;
  uint32_t val, cc, ct;

  /* Break out the fields from the data */
  if (2 != sscanf (buf->data, "P%x=%8s", &regnum, valstr))
    {
      fprintf (stderr, "Warning: Failed to recognize RSP write register command: %s\n", buf->data);
      hwp_put_str_packet (hwp_client_fd, "E01");
      return;
    }
  
  /* Set the relevant register.  We assume that the client is not
   * GDB, and no register number translation is needed. */
  val =  hwp_hex2reg(valstr);
  errcode = dbg_cpu0_write(regnum, val);

  if(errcode == APP_ERR_NONE) {
    debug("Wrote reg 0x%X with val 0x%X (%s)\n", regnum, hwp_hex2reg(valstr), valstr);
    hwp_put_str_packet (hwp_client_fd, "OK");
  }
  else {
    fprintf(stderr, "Error writing register: %s\n", get_err_string(errcode));
    hwp_put_str_packet(hwp_client_fd, "E01");
  }

  /* A bit of hackery: Determine if this write enables a comparison on a DCR.
   * If so, then we mark this HWP as in use, so that GDB/RSP cannot use it.
   * Note that there's no point making the HWP client check which watchpoints are in
   * use - GDB only sets HWP as it is starting the CPU, and clears them
   * immediately after a stop.  So as far as the HWP client would see, GDB/RSP
   * never uses any watchpoints.
   */
  
  if((regnum >= SPR_DCR(0)) && (regnum <= SPR_DCR(7)))
    {
      dcridx = regnum - SPR_DCR(0);
      /* If the 'compare condition' (cc) or 'compare to' (ct) are 0,
       * then matching is disabled and we can mark this HWP not in use.
       */ 
      cc = val & 0x0E;
      ct = val & 0xE0;
      if ((cc == 0) || (ct == 0))
	hwp_set_in_use(dcridx, 0);
      else
	hwp_set_in_use(dcridx, 1);
    }

}	/* hwp_write_reg() */

/*---------------------------------------------------------------------------*/
/*!Convenience to put a constant string packet

   param[in] str  The text of the packet                                     */
/*---------------------------------------------------------------------------*/
void hwp_put_str_packet (int fd, const char *str)
{
  struct rsp_buf  buf;
  int             len = strlen (str);

  /* Construct the packet to send, so long as string is not too big,
     otherwise truncate. Add EOS at the end for convenient debug printout */

  if (len >= HWP_BUF_MAX)
    {
      fprintf (stderr, "Warning: String %s too large for HWP RSP packet: truncated\n", str);
      len = HWP_BUF_MAX - 1;
    }

  strncpy (buf.data, str, len);
  buf.data[len] = 0;
  buf.len       = len;

  hwp_put_packet (fd, &buf);

}	/* hwp_put_str_packet () */

/*---------------------------------------------------------------------------*/
/*!Send a packet to the GDB client

   Modeled on the stub version supplied with GDB. Put out the data preceded by
   a '$', followed by a '#' and a one byte checksum. '$', '#', '*' and '}' are
   escaped by preceding them with '}' and then XORing the character with
   0x20.

   @param[in] buf  The data to send                                          */
/*---------------------------------------------------------------------------*/
void hwp_put_packet (int fd, struct rsp_buf *buf)
{
  int  ch;				/* Ack char */

  /* Construct $<packet info>#<checksum>. Repeat until the GDB client
     acknowledges satisfactory receipt. */
  do
    {
      unsigned char checksum = 0;	/* Computed checksum */
      int           count    = 0;	/* Index into the buffer */

      debug("Putting %s\n", buf->data);

      put_hwp_rsp_char (fd, '$');		/* Start char */

      /* Body of the packet */
      for (count = 0; count < buf->len; count++)
	{
	  unsigned char  ch = buf->data[count];

	  /* Check for escaped chars */
	  if (('$' == ch) || ('#' == ch) || ('*' == ch) || ('}' == ch))
	    {
	      ch       ^= 0x20;
	      checksum += (unsigned char)'}';
	      put_hwp_rsp_char (fd, '}');
	    }

	  checksum += ch;
	  put_hwp_rsp_char (fd, ch);
	}

      put_hwp_rsp_char (fd, '#');		/* End char */

      /* Computed checksum */
      put_hwp_rsp_char (fd, hexchars[checksum >> 4]);
      put_hwp_rsp_char (fd, hexchars[checksum % 16]);

      /* Check for ack or connection failure */
      ch = get_hwp_rsp_char (fd);
      if (-1 == ch)
	{
	  return;			/* Fail the put silently. */
	}
    }
  while ('+' != ch);

}	/* hwp_put_packet() */


unsigned long int hwp_hex2reg (char *buf)
{
  int                n;		/* Counter for digits */
  unsigned long int  val = 0;	/* The result */

  for (n = 0; n < 8; n++)
    {
#ifdef WORDSBIGENDIAN
      int  nyb_shift = n * 4;
#else
      int  nyb_shift = 28 - (n * 4);
#endif
      val |= hwp_hex(buf[n]) << nyb_shift;
    }

  return val;

}	/* hwp_hex2reg() */


void hwp_reg2hex(unsigned long int val, char *buf)
{
  int  n;			/* Counter for digits */

  for (n = 0; n < 8; n++)
    {
#ifdef WORDSBIGENDIAN
      int  nyb_shift = n * 4;
#else
      int  nyb_shift = 28 - (n * 4);
#endif
      buf[n] = hexchars[(val >> nyb_shift) & 0xf];
    }

  buf[8] = 0;			/* Useful to terminate as string */

}	/* hwp_reg2hex() */


int hwp_hex(int c)
{
  return  ((c >= 'a') && (c <= 'f')) ? c - 'a' + 10 :
          ((c >= '0') && (c <= '9')) ? c - '0' :
          ((c >= 'A') && (c <= 'F')) ? c - 'A' + 10 : -1;

}	/* hwp_hex() */

/* ---------------------------------------------------------------------- */
/* Functions to report stop and start to the client.                      */
/* Not strictly correct RSP protocol.                                     */
/*------------------------------------------------------------------------*/

void hwp_report_stop(void)
{
  struct rsp_buf  buf;
  uint32_t ppcval;

  // Read the PPC
  dbg_cpu0_read(SPR_PPC, &ppcval);

  debug("HWP reporting stop, PPC = 0x%X\n", ppcval);

  /* Construct a signal received packet */
  buf.data[0] = 'S';
  buf.data[1] = hexchars[ppcval >> 4];
  buf.data[2] = hexchars[ppcval % 16];
  buf.data[3] = 0;
  buf.len     = strlen (buf.data);

  hwp_put_packet(hwp_client_fd, &buf);

}	/* rsp_report_exception () */


void hwp_report_run(void)
{
  struct rsp_buf  buf;

  // Construct a 'run' packet.  This is completely non-standard, non-RSP, made up.
  buf.data[0] = 'R';
  buf.data[1] = 'U';
  buf.data[2] = 'N';
  buf.data[3] = 0;
  buf.len     = strlen (buf.data);

  hwp_put_packet(hwp_client_fd, &buf);

}  /* hwp_report_run() */

/* Used by the HWP server to indicate which HWP are
 * in long-term use by an external client
 */
void hwp_set_in_use(unsigned int wp, unsigned char inuse)
{
  if(wp < HWP_MAX_WP)
    {
      hwp_in_use[wp] = inuse;
      debug("HWP setting wp %i status to %i\n", wp, inuse); 
    }
  else
    fprintf(stderr, "ERROR! value %i out of range when setting HWP in use!\n", wp);
}

/* Called by the RSP server to get any one unused HWP.
 * This will only be called immediately before a 'step'
 * or 'continue,' and the HWP will be disabled as soon
 * as the CPU returns control to the RSP server.
 * Returns -1 if no HWP available.
 */
int hwp_get_available_watchpoint(void)
{
  int i;
  int ret = -1;

  for(i = 0; i < HWP_MAX_WP; i++)
    {
      if(hwp_in_use[i] == 0)
	{
	  ret = i;
	  hwp_in_use[i] = 1;
	  
	  break;
	}
    }	  
  debug("HWP granting wp %i to GDB/RSP\n", ret);
  return ret;
}

/* Called by the RSP server to indicate it is no longer
 * using a watchpoint previously granted by
 * hwp_get_available_watchpoint()
 */
void hwp_return_watchpoint(int wp)
{
  if(wp >= HWP_MAX_WP)
    {
      fprintf(stderr, "ERROR! WP value %i out of range in hwp_return_watchpoint()!\n", wp);
    }
  else
    {
      if(hwp_in_use[wp] != 0)
	{
	  hwp_in_use[wp] = 0;
	  debug("HWP got wp %i back from GDB/RSP\n", wp);
	}
      else
	fprintf(stderr, "ERROR! hwp_return_watchpoint() returning wp %i, not in use!\n", wp);
    }
}
