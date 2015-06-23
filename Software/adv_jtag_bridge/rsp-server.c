/* rsp-server.c -- Remote Serial Protocol server for GDB

Copyright (C) 2008 Embecosm Limited
Copyright (C) 2008-2010 Nathan Yawn <nyawn@opencores.net>

Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

This file was part of Or1ksim, the OpenRISC 1000 Architectural Simulator.
Adapted for adv_jtag_bridge by Nathan Yawn

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.  
*/

/* This program is commented throughout in a fashion suitable for processing
   with Doxygen. */

/* System includes */
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <poll.h>
#include <netinet/tcp.h>
#include <string.h>
#include <netinet/in.h>

/* Package includes */
#include "except.h"
#include "spr-defs.h"
#include "dbg_api.h"
#include "errcodes.h"
#include "hardware_monitor.h"
#include "hwp_server.h"

/* Define to log each packet */
#define RSP_TRACE  0

/*! Name of the RSP service */
#define OR1KSIM_RSP_SERVICE  "jtag-rsp"

/*! Protocol used by Or1ksim */
#define OR1KSIM_RSP_PROTOCOL  "tcp"

/* Indices of GDB registers that are not GPRs. Must match GDB settings! */
#define PPC_REGNUM  (MAX_GPRS + 0)	/*!< Previous PC */
#define NPC_REGNUM  (MAX_GPRS + 1)	/*!< Next PC */
#define SR_REGNUM   (MAX_GPRS + 2)	/*!< Supervision Register */
#define NUM_REGS    (MAX_GRPS + 3)	/*!< Total GDB registers */

/*! Trap instruction for OR32 */
#define OR1K_TRAP_INSTR  0x21000001

/*! Definition of GDB target signals. Data taken from the GDB 6.8
    source. Only those we use defined here. */
enum target_signal {
  TARGET_SIGNAL_NONE =  0,
  TARGET_SIGNAL_INT  =  2,
  TARGET_SIGNAL_ILL  =  4,
  TARGET_SIGNAL_TRAP =  5,
  TARGET_SIGNAL_FPE  =  8,
  TARGET_SIGNAL_BUS  = 10,
  TARGET_SIGNAL_SEGV = 11,
  TARGET_SIGNAL_ALRM = 14,
  TARGET_SIGNAL_USR2 = 31,
  TARGET_SIGNAL_PWR  = 32
};

/*! The maximum number of characters in inbound/outbound buffers.  
 * The max is 16kB, and larger buffers make for faster
 * transfer times, so use the max.  If your setup is prone
 * to JTAG communication errors, you may want to use a smaller
 * size. 
 */
#define GDB_BUF_MAX  (16*1024) // ((NUM_REGS) * 8 + 1)

/*! Size of the matchpoint hash table. Largest prime < 2^10 */
#define MP_HASH_SIZE  1021

/*! String to map hex digits to chars */
static const char hexchars[]="0123456789abcdef";

/*! Data structure for RSP buffers. Can't be null terminated, since it may
  include zero bytes */
struct rsp_buf
{
  char  data[GDB_BUF_MAX];
  int   len;
};

/*! Enumeration of different types of matchpoint. These have explicit values
    matching the second digit of 'z' and 'Z' packets. */
enum mp_type {
  BP_MEMORY   = 0,
  BP_HARDWARE = 1,
  WP_WRITE    = 2,
  WP_READ     = 3,
  WP_ACCESS   = 4
};

/*! Data structure for a matchpoint hash table entry */
struct mp_entry
{
  enum mp_type       type;		/*!< Type of matchpoint */
  unsigned long int  addr;		/*!< Address with the matchpoint */
  unsigned long int  instr;		/*!< Substituted instruction */
  struct mp_entry   *next;		/*!< Next entry with this hash */
};

/* Data to interface the GDB handler thread with the target handler thread */
int pipe_fds[2];  // Descriptors for the pipe from the poller thread to the GDB interface thread

// Work-around for the current OR1200 implementation; After setting the NPC,
// it always reads back 0 until the next instruction is executed.  This
// is a problem with the way we handle memory breakpoints (resetting the NPC),
// so we cache the last value we set the NPC to, incase we need it.
unsigned char use_cached_npc = 0;
unsigned int cached_npc = 0;

/*! Central data for the RSP connection */
static struct
{
  int                client_waiting;	/*!< Is client waiting a response? */
  int                target_running;    /*!< Is target hardware running? --NAY */
  int                single_step_mode;
  int                proto_num;		/*!< Number of the protocol used */
  int                server_fd;		/*!< FD for new connections */
  int                client_fd;		/*!< FD for talking to GDB */
  int                sigval;		/*!< GDB signal for any exception */
  unsigned long int  start_addr;	/*!< Start of last run */
  struct mp_entry   *mp_hash[MP_HASH_SIZE];	/*!< Matchpoint hash table */
} rsp;

/* Forward declarations of static functions */
void  rsp_exception (unsigned long int except);
static void               rsp_server_request ();
static void               rsp_client_request ();
static void               rsp_server_close ();
static void               rsp_client_close ();
static void               put_packet (struct rsp_buf *buf);
static void               put_str_packet (const char *str);
static struct rsp_buf    *get_packet ();
static void               put_rsp_char (char  c);
static int                get_rsp_char ();
static int                rsp_unescape (char *data,
					int   len);
static void               mp_hash_init ();
static void               mp_hash_add (enum mp_type       type,
				       unsigned long int  addr,
				       unsigned long int  instr);
static struct mp_entry   *mp_hash_lookup (enum mp_type       type,
					  unsigned long int  addr);
static struct mp_entry   *mp_hash_delete (enum mp_type       type,
					  unsigned long int  addr);
static int                hex (int  c);
static void               reg2hex (unsigned long int  val,
				   char              *buf);
static unsigned long int  hex2reg (char *buf);
static void               ascii2hex (char *dest,
				     char *src);
static void               hex2ascii (char *dest,
				     char *src);
static unsigned int       set_npc (unsigned long int  addr);
static void               rsp_report_exception ();
static void               rsp_continue (struct rsp_buf *buf);
static void               rsp_continue_with_signal (struct rsp_buf *buf);
static void               rsp_continue_generic (unsigned long int  except);
static void               rsp_read_all_regs ();
static void               rsp_write_all_regs (struct rsp_buf *buf);
static void               rsp_read_mem (struct rsp_buf *buf);
static void               rsp_write_mem (struct rsp_buf *buf);
static void               rsp_read_reg (struct rsp_buf *buf);
static void               rsp_write_reg (struct rsp_buf *buf);
static void               rsp_query (struct rsp_buf *buf);
static void               rsp_command (struct rsp_buf *buf);
static void               rsp_set (struct rsp_buf *buf);
static void               rsp_restart ();
static void               rsp_step (struct rsp_buf *buf);
static void               rsp_step_with_signal (struct rsp_buf *buf);
static void               rsp_step_generic (unsigned long int  except);
static void               rsp_vpkt (struct rsp_buf *buf);
static void               rsp_write_mem_bin (struct rsp_buf *buf);
static void               rsp_remove_matchpoint (struct rsp_buf *buf);
static void               rsp_insert_matchpoint (struct rsp_buf *buf);

void set_stall_state(int stall);

/*---------------------------------------------------------------------------*/
/*!Initialize the Remote Serial Protocol connection

   This involves setting up a socket to listen on a socket for attempted
   connections from a single GDB instance (we couldn't be talking to multiple
   GDBs at once!).

   The service is specified either as a port number in the Or1ksim configuration
   (parameter rsp_port in section debug, default 51000) or as a service name
   in the constant OR1KSIM_RSP_SERVICE.

   The protocol used for communication is specified in OR1KSIM_RSP_PROTOCOL. */
/*---------------------------------------------------------------------------*/
void
rsp_init (int portNum)
{
  struct protoent    *protocol;		/* Protocol number */
  struct hostent     *host_entry;	/* Our host entry */
  struct sockaddr_in  sock_addr;	/* Socket address */

  int                 optval;		/* Socket options */
  int                 flags;		/* Socket flags */
  char                name[256];	/* Our name */


  /* Clear out the central data structure */
  rsp.client_waiting =  0;		/* GDB client is not waiting for us */
  rsp.proto_num      = -1;		/* i.e. invalid */
  rsp.server_fd      = -1;		/* i.e. invalid */
  rsp.client_fd      = -1;		/* i.e. invalid */
  rsp.sigval         =  0;		/* No exception */
  rsp.start_addr     = EXCEPT_RESET;	/* Default restart point */

  /* Set up the matchpoint hash table */
  mp_hash_init ();

  /* Get the protocol number of TCP and save it for future use */
  protocol = getprotobyname (OR1KSIM_RSP_PROTOCOL);
  if (NULL == protocol)
    {
      fprintf (stderr, "Warning: RSP unable to load protocol \"%s\": %s\n",
	       OR1KSIM_RSP_PROTOCOL, strerror (errno));
      return;
    }

  rsp.proto_num = protocol->p_proto;	/* Saved for future client use */

  /* 0 is used as the RSP port number to indicate that we should use the
     service name instead. */
  if (0 == portNum)
    {
      struct servent *service =
	getservbyname (OR1KSIM_RSP_SERVICE, protocol->p_name);

      if (NULL == service)
	{
	  fprintf (stderr, "Warning: RSP unable to find service \"%s\": %s\n",
		   OR1KSIM_RSP_SERVICE, strerror (errno));
	  return;
	}

      portNum = ntohs (service->s_port);
    }

  /* Create the socket using the TCP protocol */
  rsp.server_fd = socket (PF_INET, SOCK_STREAM, protocol->p_proto);
  if (rsp.server_fd < 0)
    {
      fprintf (stderr, "Warning: RSP could not create server socket: %s\n",
	       strerror (errno));
      return;
    }

  /* Set this socket to reuse its address. This allows the server to keep
     trying before a GDB session has got going. */
  optval = 1;
  if (setsockopt(rsp.server_fd, SOL_SOCKET,
		 SO_REUSEADDR, &optval, sizeof (optval)) < 0)
    {
      fprintf (stderr, "Cannot set SO_REUSEADDR option on server socket %d: "
	       "%s\n", rsp.server_fd, strerror (errno));
      rsp_server_close();
      return;
    }

  /* The server should be non-blocking. Get the current flags and then set the
     non-blocking flags */
  flags = fcntl (rsp.server_fd, F_GETFL);
  if (flags < 0)
    {
      fprintf (stderr, "Warning: Unable to get flags for RSP server socket "
	       "%d: %s\n", rsp.server_fd, strerror (errno));
      rsp_server_close();
      return;
    }

  flags |= O_NONBLOCK;
  if (fcntl (rsp.server_fd, F_SETFL, flags) < 0)
    {
      fprintf (stderr, "Warning: Unable to set flags for RSP server socket "
	       "%d to 0x%08x: %s\n", rsp.server_fd, flags, strerror (errno));
      rsp_server_close();
      return;
    }

  /* Find out what our name is */
  if (gethostname (name, sizeof (name)) < 0)
    {
      fprintf (stderr, "Warning: Unable to get hostname for RSP server: %s\n",
	       strerror (errno));
      rsp_server_close();
      return;
    }

  /* Find out what our address is */
  host_entry = gethostbyname (name);
  if (NULL == host_entry)
    {
      fprintf (stderr, "Warning: Unable to get host entry for RSP server: "
	       "%s\n", strerror (errno));
      rsp_server_close();
      return;
    }

  /* Bind our socket to the appropriate address */
  memset (&sock_addr, 0, sizeof (sock_addr));
  sock_addr.sin_family = host_entry->h_addrtype;
  sock_addr.sin_port   = htons (portNum);

  if (bind (rsp.server_fd,
	    (struct sockaddr *)&sock_addr, sizeof (sock_addr)) < 0)
    {
      fprintf (stderr, "Warning: Unable to bind RSP server socket %d to port "
	       "%d: %s\n", rsp.server_fd, portNum,
	       strerror (errno));
      rsp_server_close();
      return;
    }

  /* Mark us as a passive port, with a maximum backlog of 1 connection (we
     never connect simultaneously to more than one RSP client!) */
  if (listen (rsp.server_fd, 1) < 0)
    {
      fprintf (stderr, "Warning: Unable to set RSP backlog on server socket "
	       "%d to %d: %s\n", rsp.server_fd, 1, strerror (errno));
      rsp_server_close();
      return;
    }

}	/* rsp_init () */


/*---------------------------------------------------------------------------*/
/*!Look for action on RSP

   This function is called when the processor has stalled, which, except for
   initialization, must be due to an interrupt.

   If we have no RSP client, we poll the RSP server for a client requesting to
   join. We can make no progress until the client is available.

   Then if the cause is an interrupt, and the interrupt not been notified to
   GDB, a packet reporting the cause of the interrupt is sent.

   The function then polls the RSP client port (if open)
   for available input. It then processes the GDB RSP request and return.

   If an error occurs when polling the RSP server, other than an interrupt, a
   warning message is printed out and the RSP server and client (if open)
   connections are closed.

   If an error occurs when polling the RSP client, other than an interrupt, a
   warning message is printed out and the RSP client connection is closed.

   Polling is always blocking (i.e. timeout -1).                             */
/*---------------------------------------------------------------------------*/
int handle_rsp (void)
{
  struct pollfd  fds[2];	/* The FD to poll for */
  char monitor_status;
  uint32_t drrval;
  uint32_t ppcval;
  int ret;

  /* Give up if no RSP server port (this should not occur) */
  if (-1 == rsp.server_fd)
    {
      fprintf (stderr, "Warning: No RSP server port open\n");
      return 0;
    }

  /* If we have no RSP client, poll the server until we get one. */
  while (-1 == rsp.client_fd)
    {
      /* Poll for a client on the RSP server socket */
      fds[0].fd     = rsp.server_fd;	/* FD for the server socket */
      fds[0].events = POLLIN;		/* Poll for input activity */

      /* Poll is always blocking. We can't do anything more until something
	 happens here. */
      switch (poll (fds, 1, -1))
	{
	case -1:
	  /* Error. Only one we ignore is an interrupt */
	  if (EINTR != errno)
	    {
	      fprintf (stderr, "Warning: poll for RSP failed: closing "
		       "server connection: %s\n", strerror (errno));
	      rsp_client_close();
	      rsp_server_close();
	      return 0;
	    }
	  break;

	case 0:
	  /* Timeout. This can't occur! */
	  fprintf (stderr, "Warning: Unexpected RSP server poll timeout\n");
	  break;

	default:
	  /* Is the poll due to input available? If we succeed ignore any
	     outstanding reports of exceptions. */
	  if (POLLIN == (fds[0].revents & POLLIN))
	    {
	      rsp_server_request ();
	      rsp.client_waiting = 0;		/* No longer waiting */
	    }
	  else
	    {
	      /* Error leads to closing the client and server */
	      fprintf (stderr, "Warning: RSP server received flags "
		       "0x%08x: closing server connection\n", fds[0].revents);
	      rsp_client_close();
	      rsp_server_close();
	      return 0;
	    }
	}
    }

  
  /* Poll the RSP client socket for a message from GDB */
  /* Also watch for a message from the hardware poller thread.
     This might be easier if we used ppoll() and sent a Signal, instead
     of using a pipe?  */

  fds[0].fd     = rsp.client_fd;	/* FD for the client socket */
  fds[0].events = POLLIN;		/* Poll for input activity */

  fds[1].fd = pipe_fds[1];
  fds[1].events = POLLIN;

  /* Poll is always blocking. We can't do anything more until something
     happens here. */
  //fprintf(stderr, "Polling...\n");
  switch (poll (fds, 2, -1))
    {
    case -1:
      /* Error. Only one we ignore is an interrupt */
      if (EINTR != errno)
	{
	  fprintf (stderr, "Warning: poll for RSP failed: closing "
		   "server connection: %s\n", strerror (errno));
	  rsp_client_close();
	  rsp_server_close();
	  return 0;
	}

      return 1;

    case 0:
      /* Timeout. This can't occur! */
      fprintf (stderr, "Warning: Unexpected RSP client poll timeout\n");
      return 1;

    default:
      /* Is the client activity due to input available? */
      if (POLLIN == (fds[0].revents & POLLIN))
	{
	  rsp_client_request ();
	}
      else if(POLLIN == (fds[1].revents & POLLIN))
	{
	  //fprintf(stderr, "Got pipe event from monitor thread\n");
	  ret = read(pipe_fds[1], &monitor_status, 1);  // Read the monitor status
	  // *** TODO: Check return value of read()
	  if(monitor_status == 'H')
	    {
	      if(rsp.target_running)  // ignore if a duplicate event
		{
		  rsp.target_running = 0;
		  // Log the exception so it can be sent back to GDB
		  dbg_cpu0_read(SPR_DRR, &drrval);  // Read the DRR, find out why we stopped
		  rsp_exception(drrval);  // Send it to be translated and stored
		  
		  /* If we have an unacknowledged exception and a client is available, tell
		     GDB. If this exception was a trap due to a memory breakpoint, then
		     adjust the NPC. */
		  if (rsp.client_waiting)
		    { 
		      // Read the PPC
		      dbg_cpu0_read(SPR_PPC, &ppcval);
		    
		      // This is structured the way it is to avoid the read of DMR2 unless it's necessary.
		      if (TARGET_SIGNAL_TRAP == rsp.sigval)
			{
			  if(NULL != mp_hash_lookup (BP_MEMORY, ppcval))  // Is this a breakpoint we set? (we also get a TRAP on single-step)
			    {	  
			      //fprintf(stderr, "Resetting NPC to PPC\n");
			      set_npc(ppcval);
			    }
			  else 
			    {
			      uint32_t dmr2val;
			      dbg_cpu0_read(SPR_DMR2, &dmr2val);  // We need this to check for a hardware breakpoint
			      if((dmr2val & SPR_DMR2_WBS) != 0)  // Is this a hardware breakpoint?
				{	  
				  //fprintf(stderr, "Resetting NPC to PPC\n");
				  set_npc(ppcval);
				}
			    }
			}
		      
		      rsp_report_exception();
		      rsp.client_waiting = 0;		/* No longer waiting */
		    }
		}
	    }
	  else if(monitor_status == 'R')
	    {
	      rsp.target_running = 1;
	      // If things are added here, be sure to ignore if this event is a duplicate
	    }
	  else
	    {
	      fprintf(stderr, "RSP server got unknown status \'%c\' (0x%X) from target monitor!\n", monitor_status, monitor_status);
	    }
	}
      else
	{
	  /* Error leads to closing the client, but not the server. */
	  fprintf (stderr, "Warning: RSP client received flags "
		   "0x%08x: closing client connection\n", fds[0].revents);
	  rsp_client_close();
	}
    }

  return 1;
}	/* handle_rsp () */


//---------------------------------------------------------------------------
//!Note an exception for future processing
//
//   The simulator has encountered an exception. Record it here, so that a
//   future call to handle_exception will report it back to the client. The
//   signal is supplied in Or1ksim form and recorded in GDB form.

//   We flag up a warning if an exception is already pending, and ignore the
//   earlier exception.

//   @param[in] except  The exception                          
//---------------------------------------------------------------------------

void rsp_exception (unsigned long int  except)
{
  int  sigval;			// GDB signal equivalent to exception

  switch (except)
    {
    case SPR_DRR_RSTE:    sigval = TARGET_SIGNAL_PWR;  break;
    case SPR_DRR_BUSEE:   sigval = TARGET_SIGNAL_BUS;  break;
    case SPR_DRR_DPFE:      sigval = TARGET_SIGNAL_SEGV; break;
    case SPR_DRR_IPFE:      sigval = TARGET_SIGNAL_SEGV; break;
    case SPR_DRR_TTE:     sigval = TARGET_SIGNAL_ALRM; break;
    case SPR_DRR_AE:    sigval = TARGET_SIGNAL_BUS;  break;
    case SPR_DRR_IIE:  sigval = TARGET_SIGNAL_ILL;  break;
    case SPR_DRR_IE:      sigval = TARGET_SIGNAL_INT;  break;
    case SPR_DRR_DME: sigval = TARGET_SIGNAL_SEGV; break;
    case SPR_DRR_IME: sigval = TARGET_SIGNAL_SEGV; break;
    case SPR_DRR_RE:    sigval = TARGET_SIGNAL_FPE;  break;
    case SPR_DRR_SCE:  sigval = TARGET_SIGNAL_USR2; break;
    case SPR_DRR_FPE:      sigval = TARGET_SIGNAL_FPE;  break;
    case SPR_DRR_TE:     sigval = TARGET_SIGNAL_TRAP; break;

    // In the current OR1200 hardware implementation, a single-step does not create a TRAP,
    // the DSR reads back 0.  GDB expects a TRAP, so...
    case 0:            sigval = TARGET_SIGNAL_TRAP; break;

    default:
      fprintf (stderr, "Warning: Unknown RSP exception %lu: Ignored\n", except);
      return;
    }

  if ((0 != rsp.sigval) && (sigval != rsp.sigval))
    {
      fprintf (stderr, "Warning: RSP signal %d received while signal "
	       "%d pending: Pending exception replaced\n", sigval, rsp.sigval);
    }

  rsp.sigval         = sigval;		// Save the signal value

} // rsp_exception () 



/*---------------------------------------------------------------------------*/
/*!Handle a request to the server for a new client

   We may already have a client. If we do, we will accept an immediately close
   the new client.                                                           */
/*---------------------------------------------------------------------------*/
static void
rsp_server_request ()
{
  struct sockaddr_in  sock_addr;	/* The socket address */
  socklen_t           len;		/* Size of the socket address */
  int                 fd;		/* The client FD */
  int                 flags;		/* fcntl () flags */
  int                 optval;		/* Option value for setsockopt () */
  uint32_t            tmp;

  /* Get the client FD */
  len = sizeof (sock_addr);
  fd  = accept (rsp.server_fd, (struct sockaddr *)&sock_addr, &len);
  if (fd < 0)
    {
      /* This is can happen, because a connection could have started, and then
         terminated due to a protocol error or user initiation before the
         accept could take place.

	 Two of the errors we can ignore (a retry is permissible). All other
	 errors, we assume the server port has gone tits up and close. */

      if ((errno != EWOULDBLOCK) && (errno != EAGAIN))
	{
	  fprintf (stderr, "Warning: RSP server error creating client: "
		   "closing connection %s\n", strerror (errno));
	  rsp_client_close ();
	  rsp_server_close ();
	}

      return;
    }

  /* If we already have a client, then immediately close the new one */
  if (-1 != rsp.client_fd)
    {
      fprintf (stderr, "Warning: Additional RSP client request refused\n");
      close (fd);
      return;
    }

  /* We have a new client, which should be non-blocking. Get the current flags
     and then set the non-blocking flags */
  flags = fcntl (fd, F_GETFL);
  if (flags < 0)
    {
      fprintf (stderr, "Warning: Unable to get flags for RSP client socket "
	       "%d: %s\n", fd, strerror (errno));
      close (fd);
      return;
    }

  flags |= O_NONBLOCK;
  if (fcntl (fd, F_SETFL, flags) < 0)
    {
      fprintf (stderr, "Warning: Unable to set flags for RSP client socket "
	       "%d to 0x%08x: %s\n", fd, flags, strerror (errno));
      close (fd);
      return;
    }

  /* Turn of Nagel's algorithm for the client socket. This means the client
     sends stuff immediately, it doesn't wait to fill up a packet. */
  optval = 0;
  len    = sizeof (optval);
  if (setsockopt (fd, rsp.proto_num, TCP_NODELAY, &optval, len) < 0)
    {
      fprintf (stderr, "Warning: Unable to disable Nagel's algorithm for "
	       "RSP client socket %d: %s\n", fd, strerror (errno));
      close (fd);
      return;
    }

  /* Register for stall/unstall events from the target monitor thread. Also creates pipe
   * for sending stall/unstall command to the target monitor. */
  if(0 > register_with_monitor_thread(pipe_fds)) {  // pipe_fds[0] is for writing to monitor, [1] is to read from it
    fprintf(stderr, "RSP server failed to register with monitor thread, exiting");
    rsp_server_close();
    close (fd);
    return;
  }

  /* We have a new client socket */
  rsp.client_fd = fd;

  /* Now that we have a valid client connection, set up the CPU for GDB
   * Stall the CPU...it starts off running. */
  set_stall_state(1);
  rsp.target_running = 0;  // This prevents an initial exception report to GDB (which it's not expecting)
  rsp.single_step_mode = 0;

  /* Set up the CPU to break to the debug unit on exceptions. */
  dbg_cpu0_read(SPR_DSR, &tmp);
  dbg_cpu0_write(SPR_DSR, tmp|SPR_DSR_TE|SPR_DSR_FPE|SPR_DSR_RE|SPR_DSR_IIE|SPR_DSR_AE|SPR_DSR_BUSEE);

  /* Enable TRAP exception, but don't otherwise change the SR */
  dbg_cpu0_read(SPR_SR, &tmp);
  dbg_cpu0_write(SPR_SR, tmp|SPR_SR_SM);  // We set 'supervisor mode', which also enables TRAP exceptions

}	/* rsp_server_request () */


/*---------------------------------------------------------------------------*/
/*!Deal with a request from the GDB client session

   In general, apart from the simplest requests, this function replies on
   other functions to implement the functionality.                           */
/*---------------------------------------------------------------------------*/
static void
rsp_client_request ()
{
  struct rsp_buf *buf = get_packet ();	/* Message sent to us */

  // Null packet means we hit EOF or the link was closed for some other
  // reason. Close the client and return
  if (NULL == buf)
    {
      rsp_client_close ();
      return;
    }

#if RSP_TRACE
  printf ("Packet received %s: %d chars\n", buf->data, buf->len );
  fflush (stdout);
#endif

  // Check if target is running.
  // If running, only process async BREAK command
  if(rsp.target_running)
    {
      if(buf->data[0] == 0x03)  // 0x03 is the ctrl-C "break" command from GDB
	{
	  // Send the STALL command to the target  
	  set_stall_state (1);
	}
      else
	{
	  // Send a response to GDB indicating the target is not stalled: "Target not stopped"
	  put_str_packet("O6154677274656e20746f73206f74707064650a0d");  // Need to hex-encode warning string (I think...)
	  fprintf(stderr, "WARNING:  Received GDB command 0x%X (%c) while target running!\n", buf->data[0], buf->data[0]);
	}
      return;
    }

  switch (buf->data[0])
    {
    case 0x03:
      fprintf(stderr, "Warning:  asynchronous BREAK received while target stopped.\n");
      return;

    case '!':
      /* Request for extended remote mode */
      put_str_packet ("OK");
      return;

    case '?':
      /* Return last signal ID */
      rsp_report_exception();
      return;

    case 'A':
      /* Initialization of argv not supported */
      fprintf (stderr, "Warning: RSP 'A' packet not supported: ignored\n");
      put_str_packet ("E01");
      return;

    case 'b':
      /* Setting baud rate is deprecated */
      fprintf (stderr, "Warning: RSP 'b' packet is deprecated and not "
	       "supported: ignored\n");
      return;

    case 'B':
      /* Breakpoints should be set using Z packets */
      fprintf (stderr, "Warning: RSP 'B' packet is deprecated (use 'Z'/'z' "
	       "packets instead): ignored\n");
      return;

    case 'c':
      /* Continue */
      rsp_continue (buf);
      return;

    case 'C':
      /* Continue with signal */
      rsp_continue_with_signal (buf);
      return;

    case 'd':
      /* Disable debug using a general query */
      fprintf (stderr, "Warning: RSP 'd' packet is deprecated (define a 'Q' "
	       "packet instead: ignored\n");
      return;

    case 'D':
      /* Detach GDB. Do this by closing the client. The rules say that
	 execution should continue. TODO. Is this really then intended
	 meaning? Or does it just mean that only vAttach will be recognized
	 after this? */
      put_str_packet ("OK");
      rsp_client_close ();
      set_stall_state (0);
      return;

    case 'F':
      /* File I/O is not currently supported */
      fprintf (stderr, "Warning: RSP file I/O not currently supported: 'F' "
	       "packet ignored\n");
      return;

    case 'g':
      rsp_read_all_regs ();
      return;

    case 'G':
      rsp_write_all_regs (buf);
      return;
      
    case 'H':
      /* Set the thread number of subsequent operations. For now ignore
	 silently and just reply "OK" */
      put_str_packet ("OK");
      return;

    case 'i':
      /* Single instruction step */
      rsp_step (buf);
      return;

    case 'I':
      /* Single instruction step with signal */
       rsp_step_with_signal (buf);
      return;

    case 'k':
      /* Kill request. Do nothing for now. */
      return;

    case 'm':
      /* Read memory (symbolic) */
      rsp_read_mem (buf);
      return;

    case 'M':
      /* Write memory (symbolic) */
      rsp_write_mem (buf);
      return;

    case 'p':
      /* Read a register */
      rsp_read_reg (buf);
      return;

    case 'P':
      /* Write a register */
      rsp_write_reg (buf);
      return;

    case 'q':
      /* Any one of a number of query packets */
      rsp_query (buf);
      return;

    case 'Q':
      /* Any one of a number of set packets */
      rsp_set (buf);
      return;

    case 'r':
      /* Reset the system. Deprecated (use 'R' instead) */
      fprintf (stderr, "Warning: RSP 'r' packet is deprecated (use 'R' "
	       "packet instead): ignored\n");
      return;

    case 'R':
      /* Restart the program being debugged. */
      rsp_restart ();
      return;

    case 's':
      /* Single step (one high level instruction). This could be hard without
	 DWARF2 info */
      rsp_step (buf);
      return;

    case 'S':
      /* Single step (one high level instruction) with signal. This could be
	 hard without DWARF2 info */
      rsp_step_with_signal (buf);
      return;

    case 't':
      /* Search. This is not well defined in the manual and for now we don't
	 support it. No response is defined. */
      fprintf (stderr, "Warning: RSP 't' packet not supported: ignored\n");
      return;

    case 'T':
      /* Is the thread alive. We are bare metal, so don't have a thread
	 context. The answer is always "OK". */
      put_str_packet ("OK");
      return;

    case 'v':
      /* Any one of a number of packets to control execution */
      rsp_vpkt (buf);
      return;

    case 'X':
      /* Write memory (binary) */
      rsp_write_mem_bin (buf);
      return;

    case 'z':
      /* Remove a breakpoint/watchpoint. */
      rsp_remove_matchpoint (buf);
      return;

    case 'Z':
      /* Insert a breakpoint/watchpoint. */
      rsp_insert_matchpoint (buf);
      return;

    default:
      /* Unknown commands are ignored */
      fprintf (stderr, "Warning: Unknown RSP request %s\n", buf->data);
      return;
    }
}	/* rsp_client_request () */


/*---------------------------------------------------------------------------*/
/*!Close the server if it is open                                            */
/*---------------------------------------------------------------------------*/
static void
rsp_server_close ()
{
  if (-1 != rsp.server_fd)
    {
      close (rsp.server_fd);
      rsp.server_fd = -1;
    }
}	/* rsp_server_close () */


/*---------------------------------------------------------------------------*/
/*!Close the client if it is open                                            */
/*---------------------------------------------------------------------------*/
static void
rsp_client_close ()
{  
  // If target is running, stop it so we can modify SPRs
  if(rsp.target_running) {
    set_stall_state(1);
  }

  // Clear the DSR: don't transfer control to the debug unit for any reason
  dbg_cpu0_write(SPR_DSR, 0);

  // If target was running, restart it.
  // rsp.target_running is changed in this thread, so it won't have changed due to the above stall command.
  if(rsp.target_running) {
    set_stall_state(0);
  }

  // Unregister with the target handler thread.  MUST BE DONE AFTER THE LAST set_stall_state()!
  unregister_with_monitor_thread(pipe_fds);

  if (-1 != rsp.client_fd)
    {
      close (rsp.client_fd);
      rsp.client_fd = -1;
    }
}	/* rsp_client_close () */


/*---------------------------------------------------------------------------*/
/*!Send a packet to the GDB client

   Modeled on the stub version supplied with GDB. Put out the data preceded by
   a '$', followed by a '#' and a one byte checksum. '$', '#', '*' and '}' are
   escaped by preceding them with '}' and then XORing the character with
   0x20.

   @param[in] buf  The data to send                                          */
/*---------------------------------------------------------------------------*/
static void
put_packet (struct rsp_buf *buf)
{
  int  ch;				/* Ack char */

  /* Construct $<packet info>#<checksum>. Repeat until the GDB client
     acknowledges satisfactory receipt. */
  do
    {
      unsigned char checksum = 0;	/* Computed checksum */
      int           count    = 0;	/* Index into the buffer */

#if RSP_TRACE
      printf ("Putting %s\n", buf->data);
      fflush (stdout);
#endif

      put_rsp_char ('$');		/* Start char */

      /* Body of the packet */
      for (count = 0; count < buf->len; count++)
	{
	  unsigned char  ch = buf->data[count];

	  /* Check for escaped chars */
	  if (('$' == ch) || ('#' == ch) || ('*' == ch) || ('}' == ch))
	    {
	      ch       ^= 0x20;
	      checksum += (unsigned char)'}';
	      put_rsp_char ('}');
	    }

	  checksum += ch;
	  put_rsp_char (ch);
	}

      put_rsp_char ('#');		/* End char */

      /* Computed checksum */
      put_rsp_char (hexchars[checksum >> 4]);
      put_rsp_char (hexchars[checksum % 16]);

      /* Check for ack of connection failure */
      ch = get_rsp_char ();
      if (-1 == ch)
	{
	  return;			/* Fail the put silently. */
	}
    }
  while ('+' != ch);

}	/* put_packet () */


/*---------------------------------------------------------------------------*/
/*!Convenience to put a constant string packet

   param[in] str  The text of the packet                                     */
/*---------------------------------------------------------------------------*/
static void
put_str_packet (const char *str)
{
  struct rsp_buf  buf;
  int             len = strlen (str);

  /* Construct the packet to send, so long as string is not too big,
     otherwise truncate. Add EOS at the end for convenient debug printout */

  if (len >= GDB_BUF_MAX)
    {
      fprintf (stderr, "Warning: String %s too large for RSP packet: "
	       "truncated\n", str);
      len = GDB_BUF_MAX - 1;
    }

  strncpy (buf.data, str, len);
  buf.data[len] = 0;
  buf.len       = len;

  put_packet (&buf);

}	/* put_str_packet () */


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
static struct rsp_buf *
get_packet ()
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
      ch = get_rsp_char ();
      while (ch != '$')
	{
	  if (-1 == ch)
	    {
	      return  NULL;		/* Connection failed */
	    }

	  // 0x03 is a special case, an out-of-band break when running
	  if(ch == 0x03)
	    {
	      buf.data[0] = ch;
	      buf.len     = 1;
	      return &buf;
	    }

	  ch = get_rsp_char ();
	}

      /* Read until a '#' or end of buffer is found */
      checksum =  0;
      count    =  0;
      while (count < GDB_BUF_MAX - 1)
	{
	  ch = get_rsp_char ();

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

	  ch = get_rsp_char ();
	  if (-1 == ch)
	    {
	      return  NULL;		/* Connection failed */
	    }
	  xmitcsum = hex (ch) << 4;

	  ch = get_rsp_char ();
	  if (-1 == ch)
	    {
	      return  NULL;		/* Connection failed */
	    }

	  xmitcsum += hex (ch);

	  /* If the checksums don't match print a warning, and put the
	     negative ack back to the client. Otherwise put a positive ack. */
	  if (checksum != xmitcsum)
	    {
	      fprintf (stderr, "Warning: Bad RSP checksum: Computed "
		       "0x%02x, received 0x%02x\n", checksum, xmitcsum);

	      put_rsp_char ('-');	/* Failed checksum */
	    }
	  else
	    {
	      put_rsp_char ('+');	/* successful transfer */
	      break;
	    }
	}
      else
	{
	  fprintf (stderr, "Warning: RSP packet overran buffer\n");
	}
    }

  return &buf;				/* Success */

}	/* get_packet () */


/*---------------------------------------------------------------------------*/
/*!Put a single character out onto the client socket

   This should only be called if the client is open, but we check for safety.

   @param[in] c  The character to put out                                    */
/*---------------------------------------------------------------------------*/
static void
put_rsp_char (char  c)
{
  if (-1 == rsp.client_fd)
    {
      fprintf (stderr, "Warning: Attempt to write '%c' to unopened RSP "
	       "client: Ignored\n", c);
      return;
    }

  /* Write until successful (we retry after interrupts) or catastrophic
     failure. */
  while (1)
    {
      switch (write (rsp.client_fd, &c, sizeof (c)))
	{
	case -1:
	  /* Error: only allow interrupts or would block */
	  if ((EAGAIN != errno) && (EINTR != errno))
	    {
	      fprintf (stderr, "Warning: Failed to write to RSP client: "
		       "Closing client connection: %s\n",
		       strerror (errno));
	      rsp_client_close ();
	      return;
	    }
      
	  break;

	case 0:
	  break;		/* Nothing written! Try again */

	default:
	  return;		/* Success, we can return */
	}
    }
}	/* put_rsp_char () */


/*---------------------------------------------------------------------------*/
/*!Get a single character from the client socket

   This should only be called if the client is open, but we check for safety.

   @return  The character read, or -1 on failure                             */
/*---------------------------------------------------------------------------*/
static int
get_rsp_char ()
{
  unsigned char  c;		/* The character read */

  if (-1 == rsp.client_fd)
    {
      fprintf (stderr, "Warning: Attempt to read from unopened RSP "
	       "client: Ignored\n");
      return  -1;
    }

  /* Read until successful (we retry after interrupts) or catastrophic
     failure. */
  while (1)
    {
      switch (read (rsp.client_fd, &c, sizeof (c)))
	{
	case -1:
	  /* Error: only allow interrupts or would block */
	  if ((EAGAIN != errno) && (EINTR != errno))
	    {
	      fprintf (stderr, "Warning: Failed to read from RSP client: "
		       "Closing client connection: %s\n",
		       strerror (errno));
	      rsp_client_close ();
	      return  -1;
	    }
      
	  break;

	case 0:
	  // EOF
	  rsp_client_close ();
	  return  -1;

	default:
	  return  c & 0xff;	/* Success, we can return (no sign extend!) */
	}
    }
}	/* get_rsp_char () */


/*---------------------------------------------------------------------------*/
/*!"Unescape" RSP binary data

   '#', '$' and '}' are escaped by preceding them by '}' and oring with 0x20.

   This function reverses that, modifying the data in place.

   @param[in] data  The array of bytes to convert
   @para[in]  len   The number of bytes to be converted

   @return  The number of bytes AFTER conversion                             */
/*---------------------------------------------------------------------------*/
static int
rsp_unescape (char *data,
	      int   len)
{
  int  from_off = 0;		/* Offset to source char */
  int  to_off   = 0;		/* Offset to dest char */

  while (from_off < len)
    {
      /* Is it escaped */
      if ( '}' == data[from_off])
	{
	  from_off++;
	  data[to_off] = data[from_off] ^ 0x20;
	}
      else
	{
	  data[to_off] = data[from_off];
	}

      from_off++;
      to_off++;
    }

  return  to_off;

}	/* rsp_unescape () */


/*---------------------------------------------------------------------------*/
/*!Initialize the matchpoint hash table

   This is an open hash table, so this function clears all the links to
   NULL.                                                                     */
/*---------------------------------------------------------------------------*/
static void
mp_hash_init ()
{
  int  i;

  for (i = 0; i < MP_HASH_SIZE; i++)
    {
      rsp.mp_hash[i] = NULL;
    }
}	/* mp_hash_init () */


/*---------------------------------------------------------------------------*/
/*!Add an entry to the matchpoint hash table

   Add the entry if it wasn't already there. If it was there do nothing. The
   match just be on type and addr. The instr need not match, since if this is
   a duplicate insertion (perhaps due to a lost packet) they will be
   different.

   @param[in] type   The type of matchpoint
   @param[in] addr   The address of the matchpoint
   @para[in]  instr  The instruction to associate with the address           */
/*---------------------------------------------------------------------------*/
static void
mp_hash_add (enum mp_type       type,
	     unsigned long int  addr,
	     unsigned long int  instr)
{
  int              hv    = addr % MP_HASH_SIZE;
  struct mp_entry *curr;

  /* See if we already have the entry */
  for(curr = rsp.mp_hash[hv]; NULL != curr; curr = curr->next)
    {
      if ((type == curr->type) && (addr == curr->addr))
	{
	  return;		/* We already have the entry */
	}
    }

  /* Insert the new entry at the head of the chain */
  curr = malloc (sizeof (*curr));

  curr->type  = type;
  curr->addr  = addr;
  curr->instr = instr;
  curr->next  = rsp.mp_hash[hv];

  rsp.mp_hash[hv] = curr;

}	/* mp_hash_add () */


/*---------------------------------------------------------------------------*/
/*!Look up an entry in the matchpoint hash table

   The match must be on type AND addr.

   @param[in] type   The type of matchpoint
   @param[in] addr   The address of the matchpoint

   @return  The entry deleted, or NULL if the entry was not found            */
/*---------------------------------------------------------------------------*/
static struct mp_entry *
mp_hash_lookup (enum mp_type       type,
		unsigned long int  addr)
{
  int              hv   = addr % MP_HASH_SIZE;
  struct mp_entry *curr;

  /* Search */
  for (curr = rsp.mp_hash[hv]; NULL != curr; curr = curr->next)
    {
      if ((type == curr->type) && (addr == curr->addr))
	{
	  return  curr;		/* The entry found */
	}
    }

  /* Not found */
  return  NULL;
      
}	/* mp_hash_lookup () */


/*---------------------------------------------------------------------------*/
/*!Delete an entry from the matchpoint hash table

   If it is there the entry is deleted from the hash table. If it is not
   there, no action is taken. The match must be on type AND addr.

   The usual fun and games tracking the previous entry, so we can delete
   things.

   @note  The deletion DOES NOT free the memory associated with the entry,
          since that is returned. The caller should free the memory when they
          have used the information.

   @param[in] type   The type of matchpoint
   @param[in] addr   The address of the matchpoint

   @return  The entry deleted, or NULL if the entry was not found            */
/*---------------------------------------------------------------------------*/
static struct mp_entry *
mp_hash_delete (enum mp_type       type,
		unsigned long int  addr)
{
  int              hv   = addr % MP_HASH_SIZE;
  struct mp_entry *prev = NULL;
  struct mp_entry *curr;

  /* Search */
  for (curr  = rsp.mp_hash[hv]; NULL != curr; curr = curr->next)
    {
      if ((type == curr->type) && (addr == curr->addr))
	{
	  /* Found - delete. Method depends on whether we are the head of
	     chain. */
	  if (NULL == prev)
	    {
	      rsp.mp_hash[hv] = curr->next;
	    }
	  else
	    {
	      prev->next = curr->next;
	    }

	  return  curr;		/* The entry deleted */
	}

      prev = curr;
    }

  /* Not found */
  return  NULL;
      
}	/* mp_hash_delete () */


/*---------------------------------------------------------------------------*/
/*!Utility to give the value of a hex char

   @param[in] ch  A character representing a hexadecimal digit. Done as -1,
                  for consistency with other character routines, which can use
                  -1 as EOF.

   @return  The value of the hex character, or -1 if the character is
            invalid.                                                         */
/*---------------------------------------------------------------------------*/
static int
hex (int  c)
{
  return  ((c >= 'a') && (c <= 'f')) ? c - 'a' + 10 :
          ((c >= '0') && (c <= '9')) ? c - '0' :
          ((c >= 'A') && (c <= 'F')) ? c - 'A' + 10 : -1;

}	/* hex () */


/*---------------------------------------------------------------------------*/
/*!Convert a register to a hex digit string

   The supplied 32-bit value is converted to an 8 digit hex string according
   the target endianism. It is null terminated for convenient printing.

   @param[in]  val  The value to convert
   @param[out] buf  The buffer for the text string                           */
/*---------------------------------------------------------------------------*/
static void
reg2hex (unsigned long int  val,
	 char              *buf)
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

}	/* reg2hex () */


/*---------------------------------------------------------------------------*/
/*!Convert a hex digit string to a register value

   The supplied 8 digit hex string is converted to a 32-bit value according
   the target endianism

   @param[in] buf  The buffer with the hex string

   @return  The value to convert                                             */
/*---------------------------------------------------------------------------*/
static unsigned long int
hex2reg (char *buf)
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
      val |= hex (buf[n]) << nyb_shift;
    }

  return val;

}	/* hex2reg () */


/*---------------------------------------------------------------------------*/
/*!Convert an ASCII character string to pairs of hex digits

   Both source and destination are null terminated.

   @param[out] dest  Buffer to store the hex digit pairs (null terminated)
   @param[in]  src   The ASCII string (null terminated)                      */
/*---------------------------------------------------------------------------*/
static void  ascii2hex (char *dest,
			char *src)
{
  int  i;

  /* Step through converting the source string */
  for (i = 0; src[i] != '\0'; i++)
    {
      char  ch = src[i];

      dest[i * 2]     = hexchars[ch >> 4 & 0xf];
      dest[i * 2 + 1] = hexchars[ch      & 0xf];
    }

  dest[i * 2] = '\0';
	
}	/* ascii2hex () */


/*---------------------------------------------------------------------------*/
/*!Convert pairs of hex digits to an ASCII character string

   Both source and destination are null terminated.

   @param[out] dest  The ASCII string (null terminated)
   @param[in]  src   Buffer holding the hex digit pairs (null terminated)    */
/*---------------------------------------------------------------------------*/
static void  hex2ascii (char *dest,
			char *src)
{
  int  i;

  /* Step through convering the source hex digit pairs */
  for (i = 0; src[i * 2] != '\0' && src[i * 2 + 1] != '\0'; i++)
    {
      dest[i] = ((hex (src[i * 2]) & 0xf) << 4) | (hex (src[i * 2 + 1]) & 0xf);
    }

  dest[i] = '\0';

}	/* hex2ascii () */


/*---------------------------------------------------------------------------*/
/*!Set the program counter

   This sets the value in the NPC SPR. Not completely trivial, since this is
   actually cached in cpu_state.pc. Any reset of the NPC also involves
   clearing the delay state and setting the pcnext global.

   Only actually do this if the requested address is different to the current
   NPC (avoids clearing the delay pipe).

   @param[in] addr  The address to use                                       */
/*---------------------------------------------------------------------------*/
static unsigned int set_npc (unsigned long int  addr)
{
  int errcode;

  errcode = dbg_cpu0_write(SPR_NPC, addr);
  cached_npc = addr;
  use_cached_npc = 1;

  /*  This was done in the simulator.  Is any of this necessary on the hardware?  --NAY
    if (cpu_state.pc != addr)
    {
    cpu_state.pc         = addr;
    cpu_state.delay_insn = 0;
    pcnext               = addr + 4;
    }
  */
  return errcode;
}	/* set_npc () */


/*---------------------------------------------------------------------------*/
/*!Send a packet acknowledging an exception has occurred

   This is only called if there is a client FD to talk to                    */
/*---------------------------------------------------------------------------*/
static void
rsp_report_exception ()
{
  struct rsp_buf  buf;

  /* Construct a signal received packet */
  buf.data[0] = 'S';
  buf.data[1] = hexchars[rsp.sigval >> 4];
  buf.data[2] = hexchars[rsp.sigval % 16];
  buf.data[3] = 0;
  buf.len     = strlen (buf.data);

  put_packet (&buf);

}	/* rsp_report_exception () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP continue request

   Parse the command to see if there is an address. Uses the underlying
   generic continue function, with EXCEPT_NONE.

   @param[in] buf  The full continue packet                                  */
/*---------------------------------------------------------------------------*/
static void
rsp_continue (struct rsp_buf *buf)
{
  unsigned long int  addr;		/* Address to continue from, if any */

  if (strncmp(buf->data, "c", 2))
    {
      if(1 != sscanf (buf->data, "c%lx", &addr))
	{
	  fprintf (stderr,
		   "Warning: RSP continue address %s not recognized: ignored\n",
		   buf->data);
	}
      else
	{
	  /* Set the address as the value of the next program counter */
	  // TODO Is support for this really that simple?  --NAY
	  set_npc (addr);
	}
    }

  rsp_continue_generic (EXCEPT_NONE);

}	/* rsp_continue () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP continue with signal request

   Currently null. Will use the underlying generic continue function.

   @param[in] buf  The full continue with signal packet                      */
/*---------------------------------------------------------------------------*/
static void
rsp_continue_with_signal (struct rsp_buf *buf)
{
  printf ("RSP continue with signal '%s' received\n", buf->data);

}	/* rsp_continue_with_signal () */


/*---------------------------------------------------------------------------*/
/*!Generic processing of a continue request

   The signal may be EXCEPT_NONE if there is no exception to be
   handled. Currently the exception is ignored.

   The single step flag is cleared in the debug registers and then the
   processor is unstalled.

   @param[in] addr    Address from which to step
   @param[in] except  The exception to use (if any)                          */
/*---------------------------------------------------------------------------*/
static void
rsp_continue_generic (unsigned long int  except)
{
  uint32_t tmp;

  /* Clear Debug Reason Register */
  dbg_cpu0_write(SPR_DRR, 0);
  
  /* Clear any watchpoints indicated in DMR2.  Any write to DMR2 will clear this (undocumented feature). */
  dbg_cpu0_read(SPR_DMR2, &tmp);
  if(tmp & SPR_DMR2_WBS) {  // don't waste the time writing if no hw breakpoints set
    dbg_cpu0_write(SPR_DMR2, tmp);
  }

  /* Clear the single step trigger in Debug Mode Register 1 and set traps to be
     handled by the debug unit in the Debug Stop Register */
  dbg_cpu0_read(SPR_DMR1, &tmp);
  tmp &= ~(SPR_DMR1_ST|SPR_DMR1_BT); // clear single-step and trap-on-branch
  dbg_cpu0_write(SPR_DMR1, tmp);

  // *** TODO Is there ever a situation where the DSR will not be set to give us control on a TRAP?  --NAY

  /* Unstall the processor (also starts the target handler thread) */
  set_stall_state (0);

  /* Note the GDB client is now waiting for a reply. */
  rsp.client_waiting = 1;
  rsp.single_step_mode = 0;
  
}	/* rsp_continue_generic () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP read all registers request

   The registers follow the GDB sequence for OR1K: GPR0 through GPR31, PPC
   (i.e. SPR PPC), NPC (i.e. SPR NPC) and SR (i.e. SPR SR). Each register is
   returned as a sequence of bytes in target endian order.

   Each byte is packed as a pair of hex digits.                              */
/*---------------------------------------------------------------------------*/
static void
rsp_read_all_regs ()
{
  struct rsp_buf  buf;			/* Buffer for the reply */
  int             r;			/* Register index */
  uint32_t        regbuf[MAX_GPRS];
  unsigned int    errcode = APP_ERR_NONE;

  // Read all the GPRs in a single burst, for efficiency
  errcode = dbg_cpu0_read_block(SPR_GPR_BASE, regbuf, MAX_GPRS);

  /* Format the GPR data for output */
  for (r = 0; r < MAX_GPRS; r++)
    {
      reg2hex(regbuf[r], &(buf.data[r * 8]));
    }

  /* PPC, NPC and SR have consecutive addresses, read in one burst */
  errcode |= dbg_cpu0_read_block(SPR_NPC, regbuf, 3);

  // Note that reg2hex adds a NULL terminator; as such, they must be
  // put in buf.data in numerical order:  PPC, NPC, SR
  reg2hex(regbuf[2], &(buf.data[PPC_REGNUM * 8]));

  if(use_cached_npc == 1) {  // Hackery to work around CPU hardware quirk 
    reg2hex(cached_npc, &(buf.data[NPC_REGNUM * 8]));
  }
  else {
    reg2hex(regbuf[0], &(buf.data[NPC_REGNUM * 8]));
  }
 
  reg2hex(regbuf[1], &(buf.data[SR_REGNUM  * 8]));

  //fprintf(stderr, "Read SPRs:  0x%08X, 0x%08X, 0x%08X\n", regbuf[0], regbuf[1], regbuf[2]);

  if(errcode == APP_ERR_NONE) {
    /* Finalize the packet and send it */
    buf.data[NUM_REGS * 8] = 0;
    buf.len                = NUM_REGS * 8;
    put_packet (&buf);
  }
  else {
    fprintf(stderr, "Error while reading all registers: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_read_all_regs () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP write all registers request

   The registers follow the GDB sequence for OR1K: GPR0 through GPR31, PPC
   (i.e. SPR PPC), NPC (i.e. SPR NPC) and SR (i.e. SPR SR). Each register is
   supplied as a sequence of bytes in target endian order.

   Each byte is packed as a pair of hex digits.

   @todo There is no error checking at present. Non-hex chars will generate a
         warning message, but there is no other check that the right amount
         of data is present. The result is always "OK".

   @param[in] buf  The original packet request.                              */
/*---------------------------------------------------------------------------*/
static void
rsp_write_all_regs (struct rsp_buf *buf)
{
  int             r;			/* Register index */
  uint32_t        regbuf[MAX_GPRS];
  unsigned int    errcode;

  /* The GPRs */
  for (r = 0; r < MAX_GPRS; r++)
    {
      // Set up the data for a burst access
      regbuf[r] = hex2reg (&(buf->data[r * 8]));
    }

  errcode = dbg_cpu0_write_block(SPR_GPR_BASE, regbuf, MAX_GPRS);

  /* PPC, NPC and SR */
  regbuf[0] = hex2reg (&(buf->data[NPC_REGNUM * 8]));
  regbuf[1] = hex2reg (&(buf->data[SR_REGNUM  * 8]));
  regbuf[2] = hex2reg (&(buf->data[PPC_REGNUM * 8]));

  errcode |= dbg_cpu0_write_block(SPR_NPC, regbuf, 3);

  /*
  tmp = hex2reg (&(buf->data[PPC_REGNUM * 8]));
  dbg_cpu0_write(SPR_PPC, tmp); 

  tmp = hex2reg (&(buf->data[SR_REGNUM  * 8]));
  dbg_cpu0_write(SPR_SR, tmp); 

  tmp = hex2reg (&(buf->data[NPC_REGNUM * 8]));
  dbg_cpu0_write(SPR_NPC, tmp); 
  */

  if(errcode == APP_ERR_NONE)
    put_str_packet ("OK");
  else {
    fprintf(stderr, "Error while writing all registers: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_write_all_regs () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP read memory (symbolic) request

   Syntax is:

     m<addr>,<length>:

   The response is the bytes, lowest address first, encoded as pairs of hex
   digits.

   The length given is the number of bytes to be read.

   @note This function reuses buf, so trashes the original command.

   @param[in] buf  The command received                                      */
/*---------------------------------------------------------------------------*/
static void
rsp_read_mem (struct rsp_buf *buf)
{
  unsigned int    addr;			/* Where to read the memory */
  int             len;			/* Number of bytes to read */
  int             off;			/* Offset into the memory */
  unsigned int errcode = APP_ERR_NONE;

  if (2 != sscanf (buf->data, "m%x,%x:", &addr, &len))
    {
      fprintf (stderr, "Warning: Failed to recognize RSP read memory "
	       "command: %s\n", buf->data);
      put_str_packet ("E01");
      return;
    }

  /* Make sure we won't overflow the buffer (2 chars per byte) */
  if ((len * 2) >= GDB_BUF_MAX)
    {
      fprintf (stderr, "Warning: Memory read %s too large for RSP packet: "
	       "truncated\n", buf->data);
      len = (GDB_BUF_MAX - 1) / 2;
    }

  // Do the memory read into a temporary buffer
  unsigned char *tmpbuf = (unsigned char *) malloc(len);  // *** TODO check return, don't always malloc (use realloc)
  errcode = dbg_wb_read_block8(addr, tmpbuf, len);


  /* Refill the buffer with the reply */
  for (off = 0; off < len; off++)
    {
      unsigned char  ch;		/* The byte at the address */

      /* Check memory area is valid. Not really possible without knowing hardware configuration. */

      // Get the memory direct - no translation.
      ch = tmpbuf[off];
      buf->data[off * 2]     = hexchars[ch >>   4];
      buf->data[off * 2 + 1] = hexchars[ch &  0xf];
    }

  free(tmpbuf);

  if(errcode == APP_ERR_NONE) {
    buf->data[off * 2] = 0;			/* End of string */
    buf->len           = strlen (buf->data);
    put_packet (buf);
  }
  else {
    fprintf(stderr, "Error reading memory: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_read_mem () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP write memory (symbolic) request

   Syntax is:

     m<addr>,<length>:<data>

   The data is the bytes, lowest address first, encoded as pairs of hex
   digits.

   The length given is the number of bytes to be written.

   @note This function reuses buf, so trashes the original command.

   @param[in] buf  The command received                                      */
/*---------------------------------------------------------------------------*/
static void
rsp_write_mem (struct rsp_buf *buf)
{
  unsigned int    addr;			/* Where to write the memory */
  int             len;			/* Number of bytes to write */
  char           *symdat;		/* Pointer to the symboli data */
  int             datlen;		/* Number of digits in symbolic data */
  int             off;			/* Offset into the memory */
  unsigned int    errcode;

  if (2 != sscanf (buf->data, "M%x,%x:", &addr, &len))
    {
      fprintf (stderr, "Warning: Failed to recognize RSP write memory "
	       "command: %s\n", buf->data);
      put_str_packet ("E01");
      return;
    }

  /* Find the start of the data and check there is the amount we expect. */
  symdat = memchr ((const void *)buf->data, ':', GDB_BUF_MAX) + 1;
  datlen = buf->len - (symdat - buf->data);

  /* Sanity check */
  if (len * 2 != datlen)
    {
      fprintf (stderr, "Warning: Write of %d digits requested, but %d digits "
	       "supplied: packet ignored\n", len * 2, datlen );
      put_str_packet ("E01");
      return;
    }

  /* Write the bytes to memory */
  // Put all the data into a single buffer, so it can be burst-written via JTAG.
  // One burst is much faster than many single-byte transactions.
  unsigned char *tmpbuf = (unsigned char *) malloc(len);
  for (off = 0; off < len; off++)
    {
      unsigned char  nyb1 = hex (symdat[off * 2]);
      unsigned char  nyb2 = hex (symdat[off * 2 + 1]);
      tmpbuf[off] = (nyb1 << 4) | nyb2;
    }

  errcode = dbg_wb_write_block8(addr, tmpbuf, len);
  free(tmpbuf);

  /* Can't really check if the memory addresses are valid on hardware. */
  if(errcode == APP_ERR_NONE) {
    put_str_packet ("OK");
  }
  else {
    fprintf(stderr, "Error writing memory: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_write_mem () */


/*---------------------------------------------------------------------------*/
/*!Read a single register

   The registers follow the GDB sequence for OR1K: GPR0 through GPR31, PC
   (i.e. SPR NPC) and SR (i.e. SPR SR). The register is returned as a
   sequence of bytes in target endian order.

   Each byte is packed as a pair of hex digits.

   @param[in] buf  The original packet request. Reused for the reply.        */
/*---------------------------------------------------------------------------*/
static void
rsp_read_reg (struct rsp_buf *buf)
{
  unsigned int  regnum;
  uint32_t tmp;
  unsigned int errcode = APP_ERR_NONE;

  /* Break out the fields from the data */
  if (1 != sscanf (buf->data, "p%x", &regnum))
    {
      fprintf (stderr, "Warning: Failed to recognize RSP read register "
	       "command: \'%s\'\n", buf->data);
      put_str_packet ("E01");
      return;
    }

  /* Get the relevant register */
  if (regnum < MAX_GPRS)
    {
      errcode = dbg_cpu0_read(SPR_GPR_BASE+regnum, &tmp);
    }
  else if (PPC_REGNUM == regnum)
    {
      errcode = dbg_cpu0_read(SPR_PPC, &tmp);
    }
  else if (NPC_REGNUM == regnum)
    {
      if(use_cached_npc) {
	tmp = cached_npc;
      } else {
	errcode = dbg_cpu0_read(SPR_NPC, &tmp);
      }
    }
  else if (SR_REGNUM == regnum)
    {
      errcode = dbg_cpu0_read(SPR_SR, &tmp);
    }
  else
    {
      /* Error response if we don't know the register */
      fprintf (stderr, "Warning: Attempt to read unknown register 0x%x: "
	       "ignored\n", regnum);
      put_str_packet ("E01");
      return;
    }

  if(errcode == APP_ERR_NONE) {
    reg2hex(tmp, buf->data);
    buf->len = strlen (buf->data);
    put_packet (buf);
  }
  else {
    fprintf(stderr, "Error reading register: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_read_reg () */

    
/*---------------------------------------------------------------------------*/
/*!Write a single register

   The registers follow the GDB sequence for OR1K: GPR0 through GPR31, PC
   (i.e. SPR NPC) and SR (i.e. SPR SR). The register is specified as a
   sequence of bytes in target endian order.

   Each byte is packed as a pair of hex digits.

   @param[in] buf  The original packet request.                              */
/*---------------------------------------------------------------------------*/
static void
rsp_write_reg (struct rsp_buf *buf)
{
  unsigned int  regnum;
  char          valstr[9];		/* Allow for EOS on the string */
  unsigned int  errcode = APP_ERR_NONE;

  /* Break out the fields from the data */
  if (2 != sscanf (buf->data, "P%x=%8s", &regnum, valstr))
    {
      fprintf (stderr, "Warning: Failed to recognize RSP write register "
	       "command: %s\n", buf->data);
      put_str_packet ("E01");
      return;
    }
  
  /* Set the relevant register.  Must translate between GDB register numbering and hardware reg. numbers. */
  if (regnum < MAX_GPRS)
    {
      errcode = dbg_cpu0_write(SPR_GPR_BASE+regnum, hex2reg(valstr));
    }
  else if (PPC_REGNUM == regnum)
    {
      errcode = dbg_cpu0_write(SPR_PPC, hex2reg(valstr));
    }
  else if (NPC_REGNUM == regnum)
    {
      errcode = set_npc (hex2reg (valstr));
    }
  else if (SR_REGNUM == regnum)
    {
      errcode = dbg_cpu0_write(SPR_SR, hex2reg(valstr));
    }
  else
    {
      /* Error response if we don't know the register */
      fprintf (stderr, "Warning: Attempt to write unknown register 0x%x: "
	       "ignored\n", regnum);
      put_str_packet ("E01");
      return;
    }

  if(errcode == APP_ERR_NONE) {
    put_str_packet ("OK");
  }
  else {
    fprintf(stderr, "Error writing register: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_write_reg () */

    
/*---------------------------------------------------------------------------*/
/*!Handle a RSP query request

   @param[in] buf  The request                                               */
/*---------------------------------------------------------------------------*/
static void
rsp_query (struct rsp_buf *buf)
{
  if (0 == strcmp ("qC", buf->data))
    {
      /* Return the current thread ID (unsigned hex). A null response
	 indicates to use the previously selected thread. Since we do not
	 support a thread concept, this is the appropriate response. */
      put_str_packet ("");
    }
  else if (0 == strncmp ("qCRC", buf->data, strlen ("qCRC")))
    {
      /* Return CRC of memory area */
      fprintf (stderr, "Warning: RSP CRC query not supported\n");
      put_str_packet ("E01");
    }
  else if (0 == strcmp ("qfThreadInfo", buf->data))
    {
      /* Return info about active threads. We return just '-1' */
      put_str_packet ("m-1");
    }
  else if (0 == strcmp ("qsThreadInfo", buf->data))
    {
      /* Return info about more active threads. We have no more, so return the
	 end of list marker, 'l' */
      put_str_packet ("l");
    }
  else if (0 == strncmp ("qGetTLSAddr:", buf->data, strlen ("qGetTLSAddr:")))
    {
      /* We don't support this feature */
      put_str_packet ("");
    }
  else if (0 == strncmp ("qL", buf->data, strlen ("qL")))
    {
      /* Deprecated and replaced by 'qfThreadInfo' */
      fprintf (stderr, "Warning: RSP qL deprecated: no info returned\n");
      put_str_packet ("qM001");
    }
  else if (0 == strcmp ("qOffsets", buf->data))
    {
      /* Report any relocation */
      put_str_packet ("Text=0;Data=0;Bss=0");
    }
  else if (0 == strncmp ("qP", buf->data, strlen ("qP")))
    {
      /* Deprecated and replaced by 'qThreadExtraInfo' */
      fprintf (stderr, "Warning: RSP qP deprecated: no info returned\n");
      put_str_packet ("");
    }
  else if (0 == strncmp ("qRcmd,", buf->data, strlen ("qRcmd,")))
    {
      /* This is used to interface to commands to do "stuff" */
      rsp_command (buf);
    }
  else if (0 == strncmp ("qSupported", buf->data, strlen ("qSupported")))
    {
      /* Report a list of the features we support. For now we just ignore any
	 supplied specific feature queries, but in the future these may be
	 supported as well. Note that the packet size allows for 'G' + all the
	 registers sent to us, or a reply to 'g' with all the registers and an
	 EOS so the buffer is a well formed string. */

      char  reply[GDB_BUF_MAX];

      sprintf (reply, "PacketSize=%x", GDB_BUF_MAX);
      put_str_packet (reply);
    }
  else if (0 == strncmp ("qSymbol:", buf->data, strlen ("qSymbol:")))
    {
      /* Offer to look up symbols. Nothing we want (for now). TODO. This just
	 ignores any replies to symbols we looked up, but we didn't want to
	 do that anyway! */
      put_str_packet ("OK");
    }
  else if (0 == strncmp ("qThreadExtraInfo,", buf->data,
			 strlen ("qThreadExtraInfo,")))
    {
      /* Report that we are runnable, but the text must be hex ASCI
	 digits. For now do this by steam, reusing the original packet */
      sprintf (buf->data, "%02x%02x%02x%02x%02x%02x%02x%02x%02x",
	       'R', 'u', 'n', 'n', 'a', 'b', 'l', 'e', 0);
      buf->len = strlen (buf->data);
      put_packet (buf);
    }
  else if (0 == strncmp ("qXfer:", buf->data, strlen ("qXfer:")))
    {
      /* For now we support no 'qXfer' requests, but these should not be
	 expected, since they were not reported by 'qSupported' */
      fprintf (stderr, "Warning: RSP 'qXfer' not supported: ignored\n");
      put_str_packet ("");
    }
  else if (0 == strncmp ("qAttached", buf->data, strlen ("qAttached")))
    {
      /* GDB is inquiring whether it created a process or attached to an
       * existing one. We don't support this feature.  Note this packet
       * may have a ':' and a PID included. */
      put_str_packet ("");
    }
  else if (0 == strcmp ("qTStatus", buf->data))
    {
      /* GDB is inquiring whether a trace is running.
       * We don't support the trace feature, so respond with an
       * empty packet.  Note that if we respond 'no' with a "T0"
       * packet, GDB will send us further queries about tracepoints.
       */
      put_str_packet ("");
    }
  else
    {
      fprintf (stderr, "Unrecognized RSP query: ignored\n");
    }
}	/* rsp_query () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP qRcmd request

  The actual command follows the "qRcmd," in ASCII encoded to hex

   @param[in] buf  The request in full                                       */
/*---------------------------------------------------------------------------*/
static void
rsp_command (struct rsp_buf *buf)
{
  char cmd[GDB_BUF_MAX];
  uint32_t tmp;

  hex2ascii (cmd, &(buf->data[strlen ("qRcmd,")]));

  /* Work out which command it is */
  if (0 == strncmp ("readspr ", cmd, strlen ("readspr")))
    {
      unsigned int       regno;

      /* Parse and return error if we fail */
      if( 1 != sscanf (cmd, "readspr %4x", &regno))
	{
	  fprintf (stderr, "Warning: qRcmd %s not recognized: ignored\n",
		   cmd);
	  put_str_packet ("E01");
	  return;
	}

      /* SPR out of range */
      if (regno > MAX_SPRS)
	{
	  fprintf (stderr, "Warning: qRcmd readspr %x too large: ignored\n",
		   regno);
	  put_str_packet ("E01");
	  return;
	}

      /* Construct the reply */
      dbg_cpu0_read(regno, &tmp);  // TODO Check return value of all hardware accesses
      sprintf (cmd, "%8x", tmp);
      ascii2hex (buf->data, cmd);
      buf->len = strlen (buf->data);
      put_packet (buf);
    }
  else if (0 == strncmp ("writespr ", cmd, strlen ("writespr")))
    {
      unsigned int       regno;
      unsigned long int  val;

      /* Parse and return error if we fail */
      if( 2 != sscanf (cmd, "writespr %4x %8lx", &regno, &val))
	{
	  fprintf (stderr, "Warning: qRcmd %s not recognized: ignored\n",
		   cmd);
	  put_str_packet ("E01");
	  return;
	}

      /* SPR out of range */
      if (regno > MAX_SPRS)
	{
	  fprintf (stderr, "Warning: qRcmd writespr %x too large: ignored\n",
		   regno);
	  put_str_packet ("E01");
	  return;
	}

      /* Update the SPR and reply "OK" */
      dbg_cpu0_write(regno, val);
      put_str_packet ("OK");
    }
      
}	/* rsp_command () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP set request

   @param[in] buf  The request                                               */
/*---------------------------------------------------------------------------*/
static void
rsp_set (struct rsp_buf *buf)
{
  if (0 == strncmp ("QPassSignals:", buf->data, strlen ("QPassSignals:")))
    {
      /* Passing signals not supported */
      put_str_packet ("");
    }
  else if ((0 == strncmp ("QTDP",    buf->data, strlen ("QTDP")))   ||
	   (0 == strncmp ("QFrame",  buf->data, strlen ("QFrame"))) ||
	   (0 == strcmp  ("QTStart", buf->data))                    ||
	   (0 == strcmp  ("QTStop",  buf->data))                    ||
	   (0 == strcmp  ("QTinit",  buf->data))                    ||
	   (0 == strncmp ("QTro",    buf->data, strlen ("QTro"))))
    {
      /* All tracepoint features are not supported. This reply is really only
	 needed to 'QTDP', since with that the others should not be
	 generated. */
      put_str_packet ("");
    }
  else
    {
      fprintf (stderr, "Unrecognized RSP set request: ignored\n");
    }
}	/* rsp_set () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP restart request

   For now we just put the program counter back to the one used with the last
   vRun request.                                                             */
/*---------------------------------------------------------------------------*/
static void
rsp_restart ()
{
  set_npc (rsp.start_addr);

}	/* rsp_restart () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP step request

   Parse the command to see if there is an address. Uses the underlying
   generic step function, with EXCEPT_NONE.

   @param[in] buf  The full step packet                          */
/*---------------------------------------------------------------------------*/
static void
rsp_step (struct rsp_buf *buf)
{
  unsigned long int  addr;		/* The address to step from, if any */

  if(strncmp(buf->data, "s", 2))
    {
      if(1 != sscanf (buf->data, "s%lx", &addr))
	{
	  fprintf (stderr,
		   "Warning: RSP step address %s not recognized: ignored\n",
		   buf->data);
	}
      else
	{
	  /* Set the address as the value of the next program counter */
	  // TODO  Is implementing this really just this simple?
	  //set_npc (addr);
	}
    }

  rsp_step_generic (EXCEPT_NONE);

}	/* rsp_step () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP step with signal request

   Currently null. Will use the underlying generic step function.

   @param[in] buf  The full step with signal packet              */
/*---------------------------------------------------------------------------*/
static void
rsp_step_with_signal (struct rsp_buf *buf)
{
  int val;
  printf ("RSP step with signal '%s' received\n", buf->data);
  val = strtoul(&buf->data[1], NULL, 10);
  rsp_step_generic(val);
}	/* rsp_step_with_signal () */


/*---------------------------------------------------------------------------*/
/*!Generic processing of a step request

   The signal may be EXCEPT_NONE if there is no exception to be
   handled. Currently the exception is ignored.

   The single step flag is set in the debug registers and then the processor
   is unstalled.

   @param[in] addr    Address from which to step
   @param[in] except  The exception to use (if any)                          */
/*---------------------------------------------------------------------------*/
static void
rsp_step_generic (unsigned long int  except)
{
  uint32_t tmp;

  /* Clear Debug Reason Register */
  tmp = 0;
  dbg_cpu0_write(SPR_DRR, tmp);  // *** TODO Check return value of all hardware accesses
  
  /* Clear any watchpoint indicators in DMR2.  Any write to DMR2 will do this (undocumented feature) */
  dbg_cpu0_read(SPR_DMR2, &tmp);
  if(tmp & SPR_DMR2_WBS) {  // If no HW breakpoints, don't waste time writing
    dbg_cpu0_write(SPR_DMR2, tmp);
  }

  /* Set the single step trigger in Debug Mode Register 1 and set traps to be
     handled by the debug unit in the Debug Stop Register */
  if(!rsp.single_step_mode)
    { 
      dbg_cpu0_read(SPR_DMR1, &tmp);
      tmp |= SPR_DMR1_ST|SPR_DMR1_BT;
      dbg_cpu0_write(SPR_DMR1, tmp);
      dbg_cpu0_read(SPR_DSR, &tmp);
      if(!(tmp & SPR_DSR_TE)) {
	tmp |= SPR_DSR_TE;
	dbg_cpu0_write(SPR_DSR, tmp);
      }
      rsp.single_step_mode = 1;
    }

  /* Unstall the processor */
  set_stall_state (0);

  /* Note the GDB client is now waiting for a reply. */
  rsp.client_waiting = 1;

}	/* rsp_step_generic () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP 'v' packet

   These are commands associated with executing the code on the target

   @param[in] buf  The request                                               */
/*---------------------------------------------------------------------------*/
static void
rsp_vpkt (struct rsp_buf *buf)
{
  if (0 == strncmp ("vAttach;", buf->data, strlen ("vAttach;")))
    {
      /* Attaching is a null action, since we have no other process. We just
	 return a stop packet (using TRAP) to indicate we are stopped. */
      put_str_packet ("S05");
      return;
    }
  else if (0 == strcmp ("vCont?", buf->data))
    {
      /* For now we don't support this. */
      put_str_packet ("");
      return;
    }
  else if (0 == strncmp ("vCont", buf->data, strlen ("vCont")))
    {
      /* This shouldn't happen, because we've reported non-support via vCont?
	 above */
      fprintf (stderr, "Warning: RSP vCont not supported: ignored\n" );
      return;
    }
  else if (0 == strncmp ("vFile:", buf->data, strlen ("vFile:")))
    {
      /* For now we don't support this. */
      fprintf (stderr, "Warning: RSP vFile not supported: ignored\n" );
      put_str_packet ("");
      return;
    }
  else if (0 == strncmp ("vFlashErase:", buf->data, strlen ("vFlashErase:")))
    {
      /* For now we don't support this. */
      fprintf (stderr, "Warning: RSP vFlashErase not supported: ignored\n" );
      put_str_packet ("E01");
      return;
    }
  else if (0 == strncmp ("vFlashWrite:", buf->data, strlen ("vFlashWrite:")))
    {
      /* For now we don't support this. */
      fprintf (stderr, "Warning: RSP vFlashWrite not supported: ignored\n" );
      put_str_packet ("E01");
      return;
    }
  else if (0 == strcmp ("vFlashDone", buf->data))
    {
      /* For now we don't support this. */
      fprintf (stderr, "Warning: RSP vFlashDone not supported: ignored\n" );
      put_str_packet ("E01");
      return;
    }
  else if (0 == strncmp ("vRun;", buf->data, strlen ("vRun;")))
    {
      /* We shouldn't be given any args, but check for this */
      if (buf->len > strlen ("vRun;"))
	{
	  fprintf (stderr, "Warning: Unexpected arguments to RSP vRun "
		   "command: ignored\n");
	}

      /* Restart the current program. However unlike a "R" packet, "vRun"
	 should behave as though it has just stopped. We use signal
	 5 (TRAP). */
      rsp_restart ();
      put_str_packet ("S05");
    }
  else
    {
      fprintf (stderr, "Warning: Unknown RSP 'v' packet type %s: ignored\n",
	       buf->data);
      put_str_packet ("E01");
      return;
    }
}	/* rsp_vpkt () */


/*---------------------------------------------------------------------------*/
/*!Handle a RSP write memory (binary) request

   Syntax is:

     X<addr>,<length>:

   Followed by the specified number of bytes as raw binary. Response should be
   "OK" if all copied OK, E<nn> if error <nn> has occurred.

   The length given is the number of bytes to be written. However the number
   of data bytes may be greater, since '#', '$' and '}' are escaped by
   preceding them by '}' and oring with 0x20.

   @param[in] buf  The command received                                      */
/*---------------------------------------------------------------------------*/
static void
rsp_write_mem_bin (struct rsp_buf *buf)
{
  unsigned int  addr;			/* Where to write the memory */
  int           len;			/* Number of bytes to write */
  char         *bindat;			/* Pointer to the binary data */
  int           off;			/* Offset to start of binary data */
  int           newlen;			/* Number of bytes in bin data */
  unsigned int  errcode;

  if (2 != sscanf (buf->data, "X%x,%x:", &addr, &len))
    {
      fprintf (stderr, "Warning: Failed to recognize RSP write memory "
	       "command: %s\n", buf->data);
      put_str_packet ("E01");
      return;
    }

  /* Find the start of the data and "unescape" it */
  bindat = memchr ((const void *)buf->data, ':', GDB_BUF_MAX) + 1;
  off    = bindat - buf->data;
  newlen = rsp_unescape (bindat, buf->len - off);

  /* Sanity check */
  if (newlen != len)
    {
      int  minlen = len < newlen ? len : newlen;

      fprintf (stderr, "Warning: Write of %d bytes requested, but %d bytes "
	       "supplied. %d will be written\n", len, newlen, minlen);
      len = minlen;
    }

  /* Write the bytes to memory */
  errcode = dbg_wb_write_block8(addr, (uint8_t *) bindat, len);

  // We can't really verify if the memory target address exists or not.
  // Don't write to non-existant memory unless your system wishbone implementation
  // has a hardware bus timeout.
  if(errcode == APP_ERR_NONE) {
    put_str_packet ("OK");
  }
  else {
    fprintf(stderr, "Error writing memory: %s\n", get_err_string(errcode));
    put_str_packet("E01");
  }

}	/* rsp_write_mem_bin () */

      
/*---------------------------------------------------------------------------*/
/*!Handle a RSP remove breakpoint or matchpoint request

   For now only memory breakpoints are implemented, which are implemented by
   substituting a breakpoint at the specified address. The implementation must
   cope with the possibility of duplicate packets.

   @todo This doesn't work with icache/immu yet

   @param[in] buf  The command received                                      */
/*---------------------------------------------------------------------------*/
static void
rsp_remove_matchpoint (struct rsp_buf *buf)
{
  enum mp_type       type;		/* What sort of matchpoint */
  uint32_t           addr;		/* Address specified */
  int                len;		/* Matchpoint length (not used) */
  struct mp_entry   *mpe;		/* Info about the replaced instr */
  uint32_t           instbuf[1];
  uint32_t           hwp, regaddr, regdata; /* used to clear HWP bit */

  /* Break out the instruction */
  if (3 != sscanf (buf->data, "z%1d,%x,%1d", (int *)&type, &addr, &len))
    {
      fprintf (stderr, "Warning: RSP matchpoint deletion request not "
	       "recognized: ignored\n");
      put_str_packet ("E01");
      return;
    }

  /* Sanity check that the length is 4 */
  if (4 != len)
    {
      fprintf (stderr, "Warning: RSP matchpoint deletion length %d not "
	       "valid: 4 assumed\n", len);
      len = 4;
    }

  /* Sort out the type of matchpoint */
  switch (type)
    {
    case BP_MEMORY:
      /* Memory breakpoint - replace the original instruction. */
      mpe = mp_hash_delete (type, addr);

      /* If the BP hasn't yet been deleted, put the original instruction
	 back. Don't forget to free the hash table entry afterwards. */
      if (NULL != mpe)
	{
	  instbuf[0] = mpe->instr;
	  dbg_wb_write_block32(addr, instbuf, 1);  // *** TODO Check return value
	  free (mpe);
	}

      put_str_packet ("OK");
      break;;
     
    case BP_HARDWARE:
    case WP_WRITE:
    case WP_READ:
    case WP_ACCESS:
      mpe = mp_hash_delete (type, addr);
      /* The wp we used is stored in mpe->instr */
      if(NULL != mpe)
	{
	  hwp = mpe->instr;
	  free (mpe);
	  /* Clear enable bit in DMR2 */
	  regaddr = SPR_DMR2;
	  dbg_cpu0_read(regaddr, &regdata);  // *** TODO Check return value
	  regdata &= ~((0x1 << hwp) << 12);  /* Clear the correct WGB bit */
	  dbg_cpu0_write(regaddr, regdata);  // *** TODO Check return value

	  /* This isn't strictly necessary, but it makes things easier for HWP clients.  This way,
	   * they can read regs and write them back with no changes, and the HWP server won't mark
	   * this watchpoint as 'in use'.  Small performance hit. */
	  regaddr = SPR_DCR(hwp);
	  regdata = 0x01;  /* Disabled */
	  dbg_cpu0_write(regaddr, regdata);

	  hwp_return_watchpoint(hwp); /* mark the wp as unused again */
	  put_str_packet ("OK");
	}
      else
	{
	  /* GDB has been observed to disable the same watchpoint twice, then give an error message
	   * "conflicting enabled responses" after it tries to re-disable a watchpoint that no
	   * longer exists.  So, if GDB tries to disable a HWP that doesn't exist, tell it it has
	   * succeeded - it doesn't exist, so it's certainly disabled now. */
	  put_str_packet ("OK");
	}
      break;

    default:
      fprintf (stderr, "Warning: RSP matchpoint type %d not "
	       "recognized: ignored\n", type);
      put_str_packet ("E01");
      return;

    }
}	/* rsp_remove_matchpoint () */

      
/*---------------------------------------------------------------------------*/
/*!Handle a RSP insert breakpoint or matchpoint request

   For now only memory breakpoints are implemented, which are implemented by
   substituting a breakpoint at the specified address. The implementation must
   cope with the possibility of duplicate packets.

   @todo This doesn't work with icache/immu yet

   @param[in] buf  The command received                                      */
/*---------------------------------------------------------------------------*/
static void
rsp_insert_matchpoint (struct rsp_buf *buf)
{
  enum mp_type       type;		/* What sort of matchpoint */
  uint32_t           addr;		/* Address specified */
  int                len;		/* Matchpoint length (not used) */
  uint32_t           instbuf[1];
  int                hwp;               /* Which hardware watchpoint we use */
  uint32_t           regaddr;           /* Used to set HW watchpoints */
  uint32_t           regdata;           /* ditto */

  /* Break out the instruction */
  if (3 != sscanf (buf->data, "Z%1d,%x,%1d", (int *)&type, &addr, &len))
    {
      fprintf (stderr, "Warning: RSP matchpoint insertion request not "
	       "recognized: ignored\n");
      put_str_packet ("E01");
      return;
    }

  /* Sanity check that the length is 4 */
  if (4 != len)
    {
      fprintf (stderr, "Warning: RSP matchpoint insertion length %d not "
	       "valid: 4 assumed\n", len);
      len = 4;
    }

  /* Sort out the type of matchpoint */
  switch (type)
    {
    case BP_MEMORY:
      /* Memory breakpoint - substitute a TRAP instruction */
      dbg_wb_read_block32(addr, instbuf, 1);  // Get the old instruction.  *** TODO Check return value
      mp_hash_add (type, addr, instbuf[0]);
      instbuf[0] = OR1K_TRAP_INSTR;  // Set the TRAP instruction
      dbg_wb_write_block32(addr, instbuf, 1);  // *** TODO Check return value
      put_str_packet ("OK");
      break;
     
    case BP_HARDWARE:
      //fprintf(stderr, "Setting BP_HARDWARE breakpoint\n");
      hwp = hwp_get_available_watchpoint();
      //fprintf(stderr, "Got wp %i from HWP\n", hwp);
      if(hwp == -1) /* No HWP available */
	{
	  fprintf(stderr, "Warning: no hardware watchpoints available to satisfy GDB request for hardware breakpoint");
	  put_str_packet ("");
	}
      else
	{
	  mp_hash_add(type, addr, hwp);  /* Use the HWP number instead of the instruction data */
	  //fprintf(stderr, "Added MP hash\n");
	  /* Set DVR */
	  regaddr = SPR_DVR(hwp);
	  dbg_cpu0_write(regaddr, addr);  // *** TODO Check return value
	  /* Set DCR */
	  regaddr = SPR_DCR(hwp);
	  regdata = 0x23;  /* Compare to Instr fetch EA, unsigned, == */
	  dbg_cpu0_write(regaddr, regdata);  // *** TODO Check return value
	  /* Set enable bit in DMR2 */
	  regaddr = SPR_DMR2;
	  dbg_cpu0_read(regaddr, &regdata);  // *** TODO Check return value
	  regdata |= (0x1 << hwp) << 12;  /* Set the correct WGB bit */
	  dbg_cpu0_write(regaddr, regdata);  // *** TODO Check return value
	  /* Clear chain in DMR1 */
	  regaddr = SPR_DMR1;
	  dbg_cpu0_read(regaddr, &regdata);  // *** TODO Check return value
	  regdata &= ~(0x3 << (2*hwp));
	  dbg_cpu0_write(regaddr, regdata);  // *** TODO Check return value
	  put_str_packet("OK");
	}
      break;

    case WP_WRITE:
      hwp = hwp_get_available_watchpoint();
      if(hwp == -1) /* No HWP available */
	{	  	  
	  fprintf(stderr, "Warning: no hardware watchpoints available to satisfy GDB request for write watchpoint");
	  put_str_packet ("");
	}
      else
	{
	  mp_hash_add(type, addr, hwp);  /* Use the HWP number instead of the instruction data */
	  /* Set DVR */
	  regaddr = SPR_DVR(hwp);
	  dbg_cpu0_write(regaddr, addr);
	  /* Set DCR */
	  regaddr = SPR_DCR(hwp);
	  regdata = 0x63;  /* Compare to Store EA, unsigned, == */
	  dbg_cpu0_write(regaddr, regdata);
	  /* Set enable bit in DMR2 */
	  regaddr = SPR_DMR2;
	  dbg_cpu0_read(regaddr, &regdata);
	  regdata |= (0x1 << hwp) << 12;  /* Set the correct WGB bit */
	  dbg_cpu0_write(regaddr, regdata);
	  /* Clear chain in DMR1 */
	  regaddr = SPR_DMR1;
	  dbg_cpu0_read(regaddr, &regdata);
	  regdata &= ~(0x3 << (2*hwp));
	  dbg_cpu0_write(regaddr, regdata);
	  put_str_packet("OK");
	}
      break;

    case WP_READ:
      hwp = hwp_get_available_watchpoint();
      if(hwp == -1) /* No HWP available */
	{	  	  
	  fprintf(stderr, "Warning: no hardware watchpoints available to satisfy GDB request for read watchpoint");
	  put_str_packet ("");
	}
      else
	{
	  mp_hash_add(type, addr, hwp);  /* Use the HWP number instead of the instruction data */
	  /* Set DVR */
	  regaddr = SPR_DVR(hwp);
	  dbg_cpu0_write(regaddr, addr);
	  /* Set DCR */
	  regaddr = SPR_DCR(hwp);
	  regdata = 0x43;  /* Compare to Load EA, unsigned, == */
	  dbg_cpu0_write(regaddr, regdata);
	  /* Set enable bit in DMR2 */
	  regaddr = SPR_DMR2;
	  dbg_cpu0_read(regaddr, &regdata);
	  regdata |= (0x1 << hwp) << 12;  /* Set the correct WGB bit */
	  dbg_cpu0_write(regaddr, regdata);
	  /* Clear chain in DMR1 */
	  regaddr = SPR_DMR1;
	  dbg_cpu0_read(regaddr, &regdata);
	  regdata &= ~(0x3 << (2*hwp));
	  dbg_cpu0_write(regaddr, regdata);
	  put_str_packet("OK");
	}
      break;

    case WP_ACCESS:
       hwp = hwp_get_available_watchpoint();
      if(hwp == -1) /* No HWP available */
	{	   
	  fprintf(stderr, "Warning: no hardware watchpoints available to satisfy GDB request for access watchpoint");
	  put_str_packet ("");
	}
      else
	{
	  mp_hash_add(type, addr, hwp);  /* Use the HWP number instead of the instruction data */
	  /* Set DVR */
	  regaddr = SPR_DVR(hwp);
	  dbg_cpu0_write(regaddr, addr);
	  /* Set DCR */
	  regaddr = SPR_DCR(hwp);
	  regdata = 0xC3;  /* Compare to Load or Store EA, unsigned, == */
	  dbg_cpu0_write(regaddr, regdata);
	  /* Set enable bit in DMR2 */
	  regaddr = SPR_DMR2;
	  dbg_cpu0_read(regaddr, &regdata);
	  regdata |= (0x1 << hwp) << 12;  /* Set the correct WGB bit */
	  dbg_cpu0_write(regaddr, regdata);
	  /* Clear chain in DMR1 */
	  regaddr = SPR_DMR1;
	  dbg_cpu0_read(regaddr, &regdata);
	  regdata &= ~(0x3 << (2*hwp));
	  dbg_cpu0_write(regaddr, regdata);
	  put_str_packet("OK");
	}
      break;

    default:
      fprintf (stderr, "Warning: RSP matchpoint type %d not "
	       "recognized: ignored\n", type);
      put_str_packet ("E01");
      break;

    }

}	/* rsp_insert_matchpoint () */
 

// Additions from this point on were added solely to handle hardware,
// and did not come from simulator interface code.

void set_stall_state(int stall)
{
  int ret;

  if(stall == 0)
    {
      use_cached_npc = 0;
    }

  //fprintf(stderr, "RSP server sending stall command 0x%X\n", stall);

  // Actually start or stop the CPU hardware
  if(stall) ret = write(pipe_fds[0], "S", 1); 
  else      ret = write(pipe_fds[0], "U", 1); 
 
  if(!ret) {
    fprintf(stderr, "Warning: target monitor write() to pipe returned 0\n");
  }
  else if(ret < 0) {
    perror("Error in target monitor write to pipe");
  }

  return;
}
