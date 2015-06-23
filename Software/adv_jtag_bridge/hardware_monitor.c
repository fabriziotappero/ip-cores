/* hardware_monitor.c -- Monitors and controls CPU stall state
   Copyright(C) 2010 Nathan Yawn <nyawn@opencores.org>

   This file was part the advanced debug unit / bridge.  It coordinates
   the CPU stall activity for the RSP server, the JSP server, and anything
   else that wants to stall the CPU, or know when it's running.

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
#include <unistd.h>
#include <sys/select.h>
#include <pthread.h>
#include <string.h> // for memcpy()
#include <errno.h>

#include "dbg_api.h"
#include "errcodes.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

#define MAX_MONITOR_CONNECTIONS 5

int monitor_thread_running = 0;
int target_is_running = 0;

typedef struct fdstruct 
{
  int server_to_monitor_fds[2];
  int monitor_to_server_fds[2];
} fdstruct_t;

int num_monitor_connections = 0;
fdstruct_t connections[MAX_MONITOR_CONNECTIONS];

/* This mutex must be held when modify num_monitor_connections or the connections[] array.
 * The lock should no be released until the two are consistent with each other. */
pthread_mutex_t pipes_mutex = PTHREAD_MUTEX_INITIALIZER;

pthread_t target_handler_thread;
void *target_handler(void *arg);

void stall_cpu(int stall);
void notify_listeners(char *outstr, int length);

/*----------------------------------------------------------------------------*/
/* Public API functions                                                       */

int start_monitor_thread(void)
{
  // The target usually starts off running.  If it's not, then we'll just poll in the monitor thread,
  // detect it's stalled, and set this correctly
  target_is_running = 1;

  // Create the harware target polling thread
  if(pthread_create(&target_handler_thread, NULL, target_handler, NULL))
    {
      fprintf(stderr, "Failed to create target handler thread!\n");
      return 0;
    }

  // Set a variable that shows we're running
  monitor_thread_running = 1;

  return 1;
}


int register_with_monitor_thread(int pipe_fds[2])
{

  // Fail if monitor thread not running
  if(!monitor_thread_running)
    return 0;

  if(num_monitor_connections >= MAX_MONITOR_CONNECTIONS)
    return 0;


  pthread_mutex_lock(&pipes_mutex);

  // We need two pairs of pipes, one for each direction of communication
  if(0 > pipe(connections[num_monitor_connections].server_to_monitor_fds)) {  // pipe_fds[0] is for reading, [1] is for writing
    perror("Error creating pipes: ");
    return 0;
  }

  if(0 > pipe(connections[num_monitor_connections].monitor_to_server_fds)) {  // pipe_fds[0] is for reading, [1] is for writing
    perror("Error creating second pipes: ");
    return 0;
  }

  pipe_fds[0] = connections[num_monitor_connections].server_to_monitor_fds[1];
  pipe_fds[1] = connections[num_monitor_connections].monitor_to_server_fds[0];

  num_monitor_connections++;
  pthread_mutex_unlock(&pipes_mutex);

  return 1;
}

void unregister_with_monitor_thread(int pipe_fds[2])
{
  int i;
  int found = 0;

  // Don't bother with invalid pipe IDs.
  if((pipe_fds[0] < 0) || (pipe_fds[1] < 0))
    return;

  pthread_mutex_lock(&pipes_mutex);

  for(i = 0; i < num_monitor_connections; i++)
    {
      if(connections[i].server_to_monitor_fds[1] == pipe_fds[0] &&
	 connections[i].monitor_to_server_fds[0] == pipe_fds[1])
	{  
	  found = 1;
	  close(connections[i].server_to_monitor_fds[0]);
	  close(connections[i].server_to_monitor_fds[1]);
	  close(connections[i].monitor_to_server_fds[0]);
	  close(connections[i].monitor_to_server_fds[1]);
	  pipe_fds[0] = -1;
	  pipe_fds[1] = -1;  // in case of multiple unregister attempts
	  // Because we just add new connections to the end of the array, we have to
	  // reshuffle when we delete one out of the middle.  We do this by taking
	  // the last entry and moving it to the newly vacated spot.  Don't bother
	  // if we're removing the last entry.
	  if(i != (num_monitor_connections-1))
	    {
	      memcpy(&connections[i], &connections[num_monitor_connections-1], sizeof(fdstruct_t));
	    }
	  num_monitor_connections--;  
	  break;
	}
    }

  pthread_mutex_unlock(&pipes_mutex);

  if(!found)
    {
      fprintf(stderr, "Warning:  monitor thread did not find pipe set for unregistration! fd[0] is 0x%X, fd[1] is 0x%X\n", pipe_fds[0], pipe_fds[1]);
    }

}



///////////////////////////////////////////////////////////////////////////
//  Thread to poll for break on remote processor.

// Polling algorithm:
// Set timeout to 1/4 second.  This allows new pipe sets to be registered easily.
// poll/select on all valid incoming pipe fds
// If data, run all commands, send feedback to all registered servers, loop back to timeout determination
// if no data and target running, poll target state, send feedback if stopped


void *target_handler(void *arg)
{
  struct timeval tv;
  fd_set  readset;
  int i, fd, ret, nfds;
  char cmd;
  unsigned char target_status;

  debug("Target handler thread started!\n");

  while(1)
    {
      // Set this each loop, it may be changed by the select() call
      tv.tv_sec = 0;
      tv.tv_usec = 250000;  // 1/4 second timeout when polling

      FD_ZERO(&readset);
      nfds = 0;

      pthread_mutex_lock(&pipes_mutex);
      for(i = 0; i < num_monitor_connections; i++)
	{
	  fd = connections[i].server_to_monitor_fds[0];
	  FD_SET(fd, &readset);
	  if(fd > nfds)
	    nfds = fd;
	}
      pthread_mutex_unlock(&pipes_mutex);
      nfds++;

      // We do not hold the pipes_mutex during the select(), so it is possible that some of
      // the pipes in the readset will go away while we block.  This is fine, as we re-take
      // the lock below and iterate through the (changed) connections[] array, which will
      // ignore any pipes which have closed, even if they are in the readset.

      ret = select(nfds, &readset, NULL, NULL, &tv);

      if(ret == -1)  // error
	{
	  // We may get an EBADF if a server un-registers its pipes while we're in the select() 
	  // (very likely).  So, ignore EBADF unless there's a problem that needs debugged.
	  if(errno != EBADF)
	    perror("select()");
	  else
	    {
	      debug("Monitor thread got EBADF in select().  Server unregistration, or real problem?");
	    }
	}
      else if(ret != 0)  // fd ready (ret == 0 on timeout)
	{
	  debug("Monitor thread got data\n");
	  pthread_mutex_lock(&pipes_mutex);
	  for(i = 0; i < num_monitor_connections; i++)
	    {
	      debug("Monitor checking incoming connection %i\n", i);
	      fd = connections[i].server_to_monitor_fds[0];
	      if(FD_ISSET(fd, &readset))
		{
		  ret = read(fd, &cmd, 1);
		  debug("Target monitor thread got command \'%c\' (0x%X)\n", cmd, cmd);
		  if(ret == 1)
		    {
		      if(cmd == 'S')  
			{
			  if(target_is_running)  stall_cpu(1); 
			  notify_listeners("H", 1);
			}
		      else if(cmd == 'U')  
			{
			  if(!target_is_running) stall_cpu(0);
			  notify_listeners("R", 1);
			}
		      else
			{
			  fprintf(stderr, "Target monitor thread got unknown command \'%c\' (0x%X)\n", cmd, cmd);
			}
		    }
		  else
		    {
		      fprintf(stderr, "Monitor thread failed to read from ready descriptor!\n");
		    }
		}  // if FD_ISSET()
	    }  // for i = 0 to num_monitor_connections
	  pthread_mutex_unlock(&pipes_mutex);

	  // We got a command.  Either the target is now stalled and we don't need to poll,
	  // or the target just started and we should wait a bit before polling.
	  continue;

	}  // else if (ret != 0)


      if(target_is_running)
	{
	  debug("Monitor polling hardware!\n");
	  // Poll target hardware
	  ret = dbg_cpu0_read_ctrl(0, &target_status);
	  if(ret != APP_ERR_NONE)
	    fprintf(stderr, "ERROR 0x%X while polling target CPU status\n", ret);
	  else {
	    if(target_status & 0x01)  // Did we get the stall bit?  Bit 0 is STALL bit.
	      {
		debug("Monitor poll found CPU stalled!\n");
		target_is_running = 0;
		pthread_mutex_lock(&pipes_mutex);
		notify_listeners("H", 1);
		pthread_mutex_unlock(&pipes_mutex);
	      }
	  }
	}  // if(target_is_running)


    }  // while(1), main loop

  fprintf(stderr, "Target monitor thread exiting!!");

  return arg;
}



///////////////////////////////////////////////////////////////////////////////
// Helper functions for the monitor thread

void stall_cpu(int stall)
{
  int retval = 0;
  unsigned char data = (stall>0)? 1:0;

  // Actually start or stop the CPU hardware
  retval = dbg_cpu0_write_ctrl(0, data);  // 0x01 is the STALL command bit
  if(retval != APP_ERR_NONE)
    fprintf(stderr, "ERROR 0x%X sending async STALL to target.\n", retval);

  target_is_running = !data;

  return;
}

/* Lock the pipes_mutex before calling this! */
void notify_listeners(char *outstr, int length)
{
  int i;
  int ret;

  for(i = 0; i < num_monitor_connections; i++)
    {
      ret = write(connections[i].monitor_to_server_fds[1], outstr, length);
      if(ret < 0) {
	perror("Error notifying listener in target monitor");
      }
      else if(ret == 0) {
	fprintf(stderr, "Monitor thread wrote 0 bytes attempting to notify server\n");
      }
    }
}
