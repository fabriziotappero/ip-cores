/* SCARTS (32-bit) target-dependent code for the GNU simulator.
   Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003
   Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of the GNU simulators.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */


#ifndef PARAMS
#define PARAMS(ARGS) ARGS
#endif

#include <signal.h>
#include <stdlib.h>
#include <gdb/callback.h>
#include <gdb/remote-sim.h>

#include "scarts_32-tdep.h"
#include "scarts_32-sim.h"
#include "scarts_32-iss.h"
#include "scarts_32-mad.h"

#ifdef HAVE_CONFIG_H
#include "tconfig.h"
#endif

volatile int async_sim_stop = 0;
struct sim_state scarts_sim_state = {NULL, sim_stopped, SIGTRAP};

static host_callback *scarts_callback = NULL;
static int _sim_write (SIM_DESC sd, SIM_ADDR mem, unsigned char *buf, int length);

static int
_sim_write (SIM_DESC       sd,
            SIM_ADDR       mem,
            unsigned char *buf,
            int            length)
{
  int i;

  for (i = 0; i < length; ++i)
  {
    if (scarts_mem_write (mem + i, buf[i]) == 0)
      return i;
  }

  return length;
}

/* Destory a simulator instance.

   QUITTING is non-zero if we cannot hang on errors.

   This may involve freeing target memory and closing any open files
   and mmap'd areas.  You cannot assume sim_kill has already been
   called. */
void
sim_close (SIM_DESC sd,
           int      quitting)
{
  return;
}

/* Prepare to run the simulated program.

   ABFD, if not NULL, provides initial processor state information.
   ARGV and ENV, if non NULL, are NULL terminated lists of pointers.

   Hardware simulator: This function shall initialize the processor
   registers to a known value.  The program counter and possibly stack
   pointer shall be set using information obtained from ABFD (or
   hardware reset defaults).  ARGV and ENV, dependant on the target
   ABI, may be written to memory.

   Process simulator: After a call to this function, a new process
   instance shall exist. The TEXT, DATA, BSS and stack regions shall
   all be initialized, ARGV and ENV shall be written to process
   address space (according to the applicable ABI) and the program
   counter and stack pointer set accordingly. */
SIM_RC
sim_create_inferior (SIM_DESC     sd,
                     struct bfd  *abfd,
                     char       **argv,
                     char       **env)
{
  return SIM_RC_OK;
}

/* Passthru for other commands that the simulator might support.
   Simulators should be prepared to deal with any combination of NULL
   or empty CMD. */
void
sim_do_command (SIM_DESC  sd,
                char     *cmd)
{
  return;
}

/* Fetch register REGNO storing its raw (target endian) value in the
   LENGTH byte buffer BUF. Return the actual size of the register or
   zero if REGNO is not applicable.

   If LENGTH does not match the size of REGNO no data is transfered
   (the actual register size is still returned). */
int
sim_fetch_register (SIM_DESC       sd,
                    int            regno,
                    unsigned char *buf,
                    int            length)
{
  if (regno < 0 || regno >= SCARTS_TOTAL_NUM_REGS)
    return 0;

  /* All registers are SCARTS_WORD_SIZE bytes long. */
  if (length != SCARTS_WORD_SIZE)
    return SCARTS_WORD_SIZE;

  *((uint32_t *) buf) = scarts_regfile_read (regno);
  return SCARTS_WORD_SIZE;
}

/* Print whatever statistics the simulator has collected.
   VERBOSE is currently unused and must always be zero. */
void
sim_info (SIM_DESC sd,
          int      verbose)
{
  return;
}

/* Load program PROG into the simulators memory.

   If ABFD is non-NULL, the bfd for the file has already been opened.
   The result is a return code indicating success.

   Hardware simulator: Normally, each program section is written into
   memory according to that sections LMA using physical (direct)
   addressing.  The exception being systems, such as PPC/CHRP, which
   support more complicated program loaders.  A call to this function
   should not effect the state of the processor registers.  Multiple
   calls to this function are permitted and have an accumulative
   effect. */
SIM_RC
sim_load (SIM_DESC    sd,
          char       *prog,
          struct bfd *abfd,
          int         from_tty)
{
#ifndef SIM_HANDLES_LMA
#define SIM_HANDLES_LMA 0
#endif

  sim_load_file (sd, "", scarts_callback, prog, abfd, 1, SIM_HANDLES_LMA, _sim_write);
  return SIM_RC_OK;
}

/* Create a fully initialized simulator instance.

   (This function is called when the simulator is selected from the
   gdb command line.)

   KIND specifies how the simulator shall be used.  Currently there
   are only two kinds: stand-alone and debug.

   CALLBACK specifies a standard host callback (defined in callback.h).

   ABFD, when non NULL, designates a target program.  The program is
   not loaded.

   ARGV is a standard ARGV pointer such as that passed from the
   command line.  The syntax of the argument list is is assumed to be
   ``SIM-PROG { SIM-OPTION } [ TARGET-PROGRAM { TARGET-OPTION } ]''.
   The trailing TARGET-PROGRAM and args are only valid for a
   stand-alone simulator.

   On success, the result is a non NULL descriptor that shall be
   passed to the other sim_foo functions.  While the simulator
   configuration can be parameterized by (in decreasing precedence)
   ARGV's SIM-OPTION, ARGV's TARGET-PROGRAM and the ABFD argument, the
   successful creation of the simulator shall not dependent on the
   presence of any of these arguments/options.

   Hardware simulator: The created simulator shall be sufficiently
   initialized to handle, with out restrictions any client requests
   (including memory reads/writes, register fetch/stores and a
   resume). */
SIM_DESC
sim_open (SIM_OPEN_KIND   kind,
          host_callback  *callback,
          struct bfd     *abfd,
          char          **argv)
{
  scarts_callback = callback;

  scarts_init ();
  return &scarts_sim_state;
}

/* Fetch LENGTH bytes of the simulated program's memory.  Start fetch
   at virtual address MEM and store in BUF.  Result is number of bytes
   read, or zero if error.  */
int
sim_read (SIM_DESC       sd,
          SIM_ADDR       mem,
          unsigned char *buf,
          int            length)
{
  int i;
  uint8_t temp;

  for (i = 0; i < length; ++i)
  {
    if (scarts_mem_read (mem + i, &temp) == 0)
      return i;

    buf[i] = temp;
  }

  return length;
}

/* Run (or resume) the simulated program.

   STEP, when non-zero indicates that only a single simulator cycle
   should be emulated.

   SIGGNAL, if non-zero is a (HOST) SIGRC value indicating the type of
   event (hardware interrupt, signal) to be delivered to the simulated
   program.

   Hardware simulator: If the SIGRC value returned by
   sim_stop_reason() is passed back to the simulator via SIGGNAL then
   the hardware simulator shall correctly deliver the hardware event
   indicated by that signal.  If a value of zero is passed in then the
   simulation will continue as if there were no outstanding signal.
   The effect of any other SIGGNAL value is is implementation
   dependant.

   Process simulator: If SIGRC is non-zero then the corresponding
   signal is delivered to the simulated program and execution is then
   continued.  A zero SIGRC value indicates that the program should
   continue as normal. */
void
sim_resume (SIM_DESC sd,
            int      step,
            int      siggnal)
{
  uint16_t insn;
  uint32_t addr;
  scarts_codemem_read_fptr_t read_fptr;
  scarts_codemem_write_fptr_t write_fptr;

  async_sim_stop = 0;

  while (!async_sim_stop)
  {
    insn = 0;

    /* Read the current instruction from the PC. */
    scarts_codemem_vma_decode (scarts_regfile_read (SCARTS_PC_REGNUM), &read_fptr, &write_fptr, &addr);
    (void) (*read_fptr) (addr, &insn);

    /* The SCARTS_ILLOP_INSN is interpreted as a breakpoint. */
    if (insn == SCARTS_ILLOP_INSN)
    {
      sd->sim_stop_reason = sim_stopped;
      sd->sigrc = SIGTRAP;
      return;
    }

    sd->sigrc = scarts_tick();

    if (step || sd->sigrc != 0)
      /* Execute only a single simulator step. */
      break;
  }

  async_sim_stop = 0;

  sd->sim_stop_reason = sim_stopped;
  sd->sigrc = (sd->sigrc != 0 ? sd->sigrc : SIGTRAP);
}

void
sim_set_callbacks (host_callback *callback)
{
  return;
}

void
sim_size (int i)
{
  return;
}

/* Asynchronous request to stop the simulation.
   A nonzero return indicates that the simulator is able to handle
   the request */
int
sim_stop (SIM_DESC sd)
{
  async_sim_stop = 1;
  return sim_stopped;
}

/* Fetch the REASON why the program stopped.

   SIM_EXITED: The program has terminated. SIGRC indicates the target
   dependant exit status.

   SIM_STOPPED: The program has stopped.  SIGRC uses the host's signal
   numbering as a way of identifying the reaon: program interrupted by
   user via a sim_stop request (SIGINT); a breakpoint instruction
   (SIGTRAP); a completed single step (SIGTRAP); an internal error
   condition (SIGABRT); an illegal instruction (SIGILL); Access to an
   undefined memory region (SIGSEGV); Mis-aligned memory access
   (SIGBUS).  For some signals information in addition to the signal
   number may be retained by the simulator (e.g. offending address),
   that information is not directly accessable via this interface.

   SIM_SIGNALLED: The program has been terminated by a signal. The
   simulator has encountered target code that causes the the program
   to exit with signal SIGRC.

   SIM_RUNNING, SIM_POLLING: The return of one of these values
   indicates a problem internal to the simulator. */
void
sim_stop_reason (SIM_DESC       sd,
                 enum sim_stop *reason,
                 int           *sigrc)
{
  *reason = sd->sim_stop_reason;
  *sigrc  = sd->sigrc;
}

/* Store register REGNO from the raw (target endian) value in BUF.
   Return the actual size of the register or zero if REGNO is not
   applicable.

   If LENGTH does not match the size of REGNO no data is transfered
   (the actual register size is still returned). */
int
sim_store_register (SIM_DESC       sd,
                    int            regno,
                    unsigned char *buf,
                    int            length)
{
  if (regno < 0 || regno >= SCARTS_TOTAL_NUM_REGS)
    return 0;

  /* All registers are SCARTS_WORD_SIZE bytes long. */
  if (length != SCARTS_WORD_SIZE)
    return SCARTS_WORD_SIZE;

  scarts_regfile_write (regno, *((uint32_t *) buf));
  return SCARTS_WORD_SIZE;
}

int
sim_trace (SIM_DESC sd)
{
  return 0;
}

/* Store LENGTH bytes from BUF into the simulated program's
   memory. Store bytes starting at virtual address MEM. Result is
   number of bytes write, or zero if error.  */
int
sim_write (SIM_DESC       sd,
           SIM_ADDR       mem,
           unsigned char *buf,
           int            length)
{
  return _sim_write (sd, mem, buf, length);
}

