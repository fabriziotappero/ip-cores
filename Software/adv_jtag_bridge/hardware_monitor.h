
#ifndef _HARDWARE_MONITOR_H_
#define _HARDWARE_MONITOR_H_

/* Communication between servers (such as the RSP server) and the target
 * monitor is done via 2 pipes, created using pipe().  One pipe, pipe_fds[0],
 * is used by the server to command the target monitor thread to stall or 
 * unstall the CPU.  This is done by sending single-letter commands; sending "S"
 * commands the monitor thread to stall the CPU, sending "U" commands the monitor
 * to unstall the CPU.
 *
 * Feedback is sent back to servers using pipe_fds[1]. When the CPU transitions
 * from the stalled state to the run state, an "R" is sent to all registered
 * servers.  When the CPU goes from running to stopped, an "H" is sent to indicate
 * the halt state.
 */

/* This should be called once at initialization */
int start_monitor_thread(void);

/* This is called to create a  pair of shared pipes with the monitor thread.
 * The pipes should NOT have already been created before calling this function,
 * but the pipe_fds array must be already allocated.  pipe_fds[0] is for 
 * communicating server->monitor, pipe_fds[1] is for monitor->server.
 */
int register_with_monitor_thread(int pipe_fds[2]);

/* Un-share a set of pipes with the monitor.  The pipes may be closed
 * after this call returns.
 */
void unregister_with_monitor_thread(int pipe_fds[2]);


#endif
