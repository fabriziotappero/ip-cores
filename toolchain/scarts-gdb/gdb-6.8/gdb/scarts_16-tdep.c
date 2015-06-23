/* SCARTS (16-bit) target-dependent code for GDB, the GNU debugger.
   Copyright (C) 2006, 2007, 2008 Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of GDB.

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


#include <inttypes.h>
#include "demangle.h"
#include "defs.h"
#include "dis-asm.h"
#include "dwarf2-frame.h"
#include "gdb_string.h"
#include "gdbtypes.h"
#include "frame.h"
#include "frame-base.h"
#include "frame-unwind.h"
#include "gdbcmd.h"
#include "gdbcore.h"
#include "inferior.h"
#include "language.h"
#include "objfiles.h"
#include "regcache.h"
#include "reggroups.h"
#include "safe-ctype.h"
#include "symfile.h"
#include "symtab.h"
#include "target.h"
#include "trad-frame.h"
#include "value.h"
#include "arch-utils.h"
#include "block.h"
#include "scarts_16-tdep.h"

struct scarts_16_frame_cache
{
  CORE_ADDR base;
  struct trad_frame_saved_reg *saved_regs;
};

static enum return_value_convention scarts_16_return_value (struct gdbarch  *gdbarch,
                                                          struct type     *type,
                                                          struct regcache *regcache,
                                                          gdb_byte        *readbuf,
                                                          const gdb_byte  *writebuf);

static const gdb_byte *scarts_16_breakpoint_from_pc (struct gdbarch *gdbarch,
                                                   CORE_ADDR      *bp_addr,
                                                   int            *bp_size);

static int scarts_16_print_insn (bfd_vma vma,
                               disassemble_info *info);

static void scarts_16_pseudo_register_read (struct gdbarch  *gdbarch,
                                          struct regcache *regcache,
                                          int              regnum,
                                          gdb_byte        *buf);

static void scarts_16_pseudo_register_write (struct gdbarch  *gdbarch,
                                           struct regcache *regcache,
                                           int              regnum,
                                           const gdb_byte  *buf);

static const char *scarts_16_register_name (struct gdbarch *gdbarch,
                                          int             regnum);

static struct type *scarts_16_register_type (struct gdbarch *arch,
                                           int             regnum);

static void scarts_16_registers_info (struct gdbarch    *gdbarch,
                                    struct ui_file    *file,
                                    struct frame_info *frame,
                                    int                regnum,
                                    int                all);

static int scarts_16_register_reggroup_p (struct gdbarch  *gdbarch,
                                        int              regnum,
                                        struct reggroup *group);

static CORE_ADDR scarts_16_scan_prologue (CORE_ADDR                  start_pc,
                                        CORE_ADDR                  end_pc,
                                        struct frame_info         *next_frame,
                                        struct scarts_16_frame_cache *this_cache);

static CORE_ADDR scarts_16_skip_prologue (struct gdbarch *gdbarch,
                                        CORE_ADDR       pc);

static CORE_ADDR scarts_16_frame_align (struct gdbarch *gdbarch,
                                      CORE_ADDR       sp);

static CORE_ADDR scarts_16_addr_bits_remove (CORE_ADDR addr);

static CORE_ADDR scarts_16_unwind_pc (struct gdbarch    *gdbarch,
                                    struct frame_info *next_frame);

static CORE_ADDR scarts_16_unwind_sp (struct gdbarch    *gdbarch,
                                    struct frame_info *next_frame);

static CORE_ADDR scarts_16_push_dummy_call (struct gdbarch  *gdbarch,
                                          struct value    *function,
                                          struct regcache *regcache,
                                          CORE_ADDR        bp_addr,
                                          int              nargs,
                                          struct value   **args,
                                          CORE_ADDR        sp,
                                          int              struct_return,
                                          CORE_ADDR        struct_addr);

static struct frame_id scarts_16_unwind_dummy_id (struct gdbarch    *gdbarch,
                                                struct frame_info *next_frame);

static unsigned long int scarts_16_fetch_insn (struct frame_info *next_frame,
                                             CORE_ADDR          addr);

static int scarts_16_frame_size (struct frame_info *next_frame,
                               CORE_ADDR          start_addr,
                               CORE_ADDR          end_addr);

static struct trad_frame_cache *scarts_16_frame_unwind_cache (struct frame_info  *next_frame,
                                                            void              **this_prologue_cache);

static void scarts_16_frame_this_id (struct frame_info *next_frame,
                                   void             **this_prologue_cache,
                                   struct frame_id   *this_id);

static void scarts_16_frame_prev_register (struct frame_info  *next_frame,
                                         void              **this_prologue_cache,
                                         int                 regnum,
                                         int                *optimizedp,
                                         enum lval_type     *lvalp,
                                         CORE_ADDR          *addrp,
                                         int                *realregp,
                                         gdb_byte           *bufferp);

static CORE_ADDR scarts_16_frame_base_address (struct frame_info *next_frame,
                                             void             **this_prologue_cache);

static const struct frame_unwind *scarts_16_frame_sniffer (struct frame_info *next_frame);

static struct gdbarch *scarts_16_gdbarch_init (struct gdbarch_info  info,
                                             struct gdbarch_list *arches);

static void scarts_16_dump_tdep (struct gdbarch *gdbarch,
                               struct ui_file *file);


/*----------------------------------------------------------------------------*/
/*!Determine the return convention used for a given type
 *
 * Optionally, fetch or set the return value via "readbuf" or "writebuf"
 * respectively using "regcache" for the register values.
 *
 * Throughout use read_memory(), not target_read_memory(), since the address
 * may be invalid and we want an error reported (read_memory() is
 * target_read_memory() with error reporting).
 *
 * @param[in]  gdbarch   The GDB architecture being used
 * @param[in]  type      The type of the entity to be returned
 * @param[in]  regcache  The register cache
 * @param[in]  readbuf   Buffer into which the return value should be written
 * @param[out] writebuf  Buffer from which the return value should be written
 *
 * @return  The type of return value */
/*---------------------------------------------------------------------------*/

static enum return_value_convention
scarts_16_return_value (struct gdbarch  *gdbarch,
                      struct type     *type,
                      struct regcache *regcache,
                      gdb_byte        *readbuf,
                      const gdb_byte  *writebuf)
{
  unsigned int rv_size;
  ULONGEST     tmp;

  rv_size = TYPE_LENGTH (type);

  if (readbuf)
  {
    regcache_cooked_read_unsigned (regcache, 0, &tmp);
    store_unsigned_integer (readbuf, rv_size, tmp);
  }

  if (writebuf)
  {
    regcache_cooked_write_unsigned (regcache, 0, unpack_long (type, writebuf));
  }

  return RETURN_VALUE_REGISTER_CONVENTION;
}


/*---------------------------------------------------------------------------*/
/* !Determine the instruction to use for a breakpoint.
 *
 * Given the address at which to insert a breakpoint (bp_addr), what will that
 * breakpoint be?
 *
 * We use the ILLOP instruction to stop program execution of the simulator.
 *
 * @param[in]  gdbarch  The GDB architecture being used
 * @param[in]  bp_addr  The breakpoint address in question
 * @param[out] bp_size  The size of instruction selected
 *
 * @return  The chosen breakpoint instruction */
/*---------------------------------------------------------------------------*/

static const gdb_byte *
scarts_16_breakpoint_from_pc (struct gdbarch *gdbarch,
                            CORE_ADDR      *bp_addr,
                            int            *bp_size)
{
  static const gdb_byte breakpoint[] = SCARTS_ILLOP_INSN_STRUCT;

  *bp_addr += SCARTS_CODEMEM_LMA;
  *bp_size  = SCARTS_INSN_SIZE;
  return breakpoint;
}


static int
scarts_16_print_insn (bfd_vma memaddr, disassemble_info *info)
{
  memaddr += SCARTS_CODEMEM_LMA;
  return print_insn_scarts_16 (memaddr, info);
}


/*----------------------------------------------------------------------------*/
/*!Read a pseudo register
 *
 * Since we have no pseudo registers this is a null function for now.
 *
 * @param[in]  gdbarch   The GDB architecture to consider
 * @param[in]  regcache  The cached register values as an array
 * @param[in]  regnum    The register to read
 * @param[out] buf       A buffer to put the result in */
/*---------------------------------------------------------------------------*/

static void
scarts_16_pseudo_register_read (struct gdbarch  *gdbarch,
                              struct regcache *regcache,
                              int              regnum,
                              gdb_byte        *buf)
{
  return;
}


/*----------------------------------------------------------------------------*/
/*!Write a pseudo register
 *
 * Since we have no pseudo registers this is a null function for now.
 *
 * @param[in] gdbarch   The GDB architecture to consider
 * @param[in] regcache  The cached register values as an array
 * @param[in] regnum    The register to read
 * @param[in] buf       A buffer with the value to write */
/*---------------------------------------------------------------------------*/

static void
scarts_16_pseudo_register_write (struct gdbarch  *gdbarch,
                               struct regcache *regcache,
                               int              regnum,
                               const gdb_byte  *buf)
{
  return;
}


/*----------------------------------------------------------------------------*/
/*!Return the register name for the OpenRISC 1000 architecture
 *
 * This version converted to ANSI C, made static and incorporates the static
 * table of register names (this is the only place it is referenced).
 *
 * @param[in] gdbarch  The GDB architecture being used
 * @param[in] regnum   The register number
 *
 * @return  The textual name of the register */
/*---------------------------------------------------------------------------*/

static const char *
scarts_16_register_name (struct gdbarch *gdbarch,
                       int             regnum)
{
  static char *scarts_16_gdb_reg_names[SCARTS_TOTAL_NUM_REGS] =
  {
      /* General Purpose Registers */
      "r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7",
      "r8",  "r9",  "r10", "r11", "r12", "r13", "RTS", "RTE",

      /* Special Purpose Registers */
      "FPW (PC)", "FPX", "FPY (FP)", "FPZ (SP)",
  };

  return scarts_16_gdb_reg_names[regnum];
}


/*----------------------------------------------------------------------------*/
/*!Identify the type of a register
 *
 * @todo I don't fully understand exactly what this does, but I think this
 * makes sense!
 *
 * @param[in] arch     The GDB architecture to consider
 * @param[in] regnum   The register to identify
 *
 * @return  The type of the register */
/*---------------------------------------------------------------------------*/

static struct type *
scarts_16_register_type (struct gdbarch *arch,
                       int             regnum)
{
  if (regnum >= 0 && regnum < SCARTS_NUM_GP_REGS)
  {
    switch (regnum)
    {
      case SCARTS_RTS_REGNUM:
      case SCARTS_RTE_REGNUM:
        return builtin_type_void_func_ptr;
      default:
        return builtin_type_uint32;
    }
  }
  else if (regnum >= SCARTS_NUM_GP_REGS && regnum < SCARTS_TOTAL_NUM_REGS)
  {
    switch (regnum)
    {
      case SCARTS_PC_REGNUM:
        return builtin_type_void_func_ptr;
      default:
        return builtin_type_void_data_ptr;
    }
  }

  return builtin_type_uint32;
}


/*----------------------------------------------------------------------------*/
/*!Handle the "info register" command
 *
 * Print the identified register, unless it is -1, in which case print all
 * the registers. If all is 1 means all registers, otherwise only the core
 * GPRs.
 *
 * @param[in] gdbarch  The GDB architecture being used
 * @param[in] file     File handle for use with any custom I/O
 * @param[in] frame    Frame info for use with custom output
 * @param[in] regnum   Register of interest, or -1 if all registers
 * @param[in] all      1 if all means all, 0 if all means just GPRs
 *
 * @return  The aligned stack frame address */
/*---------------------------------------------------------------------------*/

static void
scarts_16_registers_info (struct gdbarch    *gdbarch,
                        struct ui_file    *file,
                        struct frame_info *frame,
                        int                regnum,
                        int                all)
{
  if (regnum == -1)
  {
    unsigned int n = all ? SCARTS_NUM_REGS : SCARTS_NUM_GP_REGS;

    for (regnum = 0; regnum < n; regnum++)
    {
      if (*(scarts_16_register_name (gdbarch, regnum)) != '\0')
      {
        scarts_16_registers_info (gdbarch, file, frame, regnum, all);
      }
    }
  }
  else
  {
    if (*(scarts_16_register_name (gdbarch, regnum)) == '\0')
    {
      error ("Invalid register number");
    }
    else
    {
      default_print_registers_info (gdbarch, file, frame, regnum, all);
    }
  }
}


/*----------------------------------------------------------------------------*/
/*!Identify if a register belongs to a specified group
 *
 * Return true if the specified register is a member of the specified
 * register group.
 *
 * These are the groups of registers that can be displayed via "info reg".
 *
 * @param[in] gdbarch  The GDB architecture to consider
 * @param[in] regnum   The register to consider
 * @param[in] group    The group to consider
 *
 * @return  True (1) if regnum is a member of group */
/*---------------------------------------------------------------------------*/

static int
scarts_16_register_reggroup_p (struct gdbarch  *gdbarch,
                             int              regnum,
                             struct reggroup *group)
{
  struct gdbarch_tdep *tdep = gdbarch_tdep (gdbarch);

  if (group == all_reggroup)
    return (regnum >= 0 && regnum < SCARTS_TOTAL_NUM_REGS && (scarts_16_register_name (gdbarch, regnum)[0] != '\0'));

  /* Registers displayed via 'info registers'. */
  if (group == general_reggroup)
    return (regnum >= 0 && regnum < tdep->num_gp_regs);

  /* Registers displayed via 'info float' or 'info vector'. */
  else if (group == float_reggroup || group == vector_reggroup)
    return 0;

  return default_register_reggroup_p (gdbarch, regnum, group);
}


/*----------------------------------------------------------------------------*/
/*!Skip a function prolog
 *
 * If the input address, PC, is in a function prologue, return the address of
 * the end of the prologue, otherwise return the input  address.
 *
 * @param[in] gdbarch  The GDB architecture being used
 * @param[in] pc       Current program counter
 *
 * @return  The address of the end of the prolog if the PC is in a function
 * prologue, otherwise the input  address. */
/*--------------------------------------------------------------------------*/

static CORE_ADDR
scarts_16_skip_prologue (struct gdbarch *gdbarch,
                       CORE_ADDR       pc)
{
  CORE_ADDR start_addr, end_addr;

  /* Determine the end of the prologue from the line number information held
   * for debugging purposes in the symbol table (symbol-and-line information,
   * SAL). */
  if (find_pc_partial_function (pc, NULL, &start_addr, &end_addr))
  {
    CORE_ADDR pc_after_prologue = skip_prologue_using_sal (start_addr);

    /* Return the PC or the PC after the prologue, whichever is greater. */
    if (pc_after_prologue != 0)
      return max (pc, pc_after_prologue);
  }

  return pc;
}


/*----------------------------------------------------------------------------*/
/*!Align the stack frame
 *
 * SCARTS uses a falling stack frame, so this aligns down to the
 * nearest SCARTS_STACK_ALIGN bytes.
 *
 * @param[in] gdbarch  The GDB architecture being used
 * @param[in] sp       Current stack pointer
 *
 * @return  The aligned stack frame address */
/*---------------------------------------------------------------------------*/

static CORE_ADDR
scarts_16_frame_align (struct gdbarch *gdbarch,
                     CORE_ADDR       sp)
{
  return align_down (sp, SCARTS_STACK_ALIGN);
}


static CORE_ADDR
scarts_16_addr_bits_remove (CORE_ADDR addr)
{
  return (addr >= SCARTS_CODEMEM_LMA) ? addr - SCARTS_CODEMEM_LMA : addr;
}

/*----------------------------------------------------------------------------*/
/*!Unwind the program counter from a stack frame
 *
 * This just uses the built in frame unwinder
 *
 * @param[in] gdbarch     The GDB architecture being used
 * @param[in] next_frame  Frame info for the NEXT frame
 *
 * @return  The program counter for THIS frame */
/*---------------------------------------------------------------------------*/

static CORE_ADDR
scarts_16_unwind_pc (struct gdbarch    *gdbarch,
                   struct frame_info *next_frame)
{
  return frame_unwind_register_unsigned (next_frame, SCARTS_PC_REGNUM);
}


/*----------------------------------------------------------------------------*/
/*!Unwind the stack pointer from a stack frame
 *
 * This just uses the built in frame unwinder
 *
 * @param[in] gdbarch     The GDB architecture being used
 * @param[in] next_frame  Frame info for the NEXT frame
 *
 * @return  The stack pointer for THIS frame */
/*---------------------------------------------------------------------------*/

static CORE_ADDR
scarts_16_unwind_sp (struct gdbarch    *gdbarch,
                   struct frame_info *next_frame)
{
  return frame_unwind_register_unsigned (next_frame, SCARTS_SP_REGNUM);
}

/*----------------------------------------------------------------------------*/
/*!Create a dummy stack frame

   The arguments are placed in registers and/or pushed on the stack as per the
   SCARTS ABI.

   @param[in] gdbarch        The architecture to use
   @param[in] function       Pointer to the function that will be called
   @param[in] regcache       The register cache to use
   @param[in] bp_addr        Breakpoint address
   @param[in] nargs          Number of ags to push
   @param[in] args           The arguments
   @param[in] sp             The stack pointer
   @param[in] struct_return  True (1) if this returns a structure
   @param[in] struct_addr    Address for returning structures

   @return  The updated stack pointer */
/*---------------------------------------------------------------------------*/

static CORE_ADDR scarts_16_push_dummy_call (struct gdbarch  *gdbarch,
                                          struct value    *function,
                                          struct regcache *regcache,
                                          CORE_ADDR        bp_addr,
                                          int              nargs,
                                          struct value   **args,
                                          CORE_ADDR        sp,
                                          int              struct_return,
                                          CORE_ADDR        struct_addr)
{
   return 0;
}


/*----------------------------------------------------------------------------*/
/*!Unwind a dummy stack frame

   @param[in] gdbarch     The architecture to use
   @param[in] next_frame  Information about the next frame

   @return  Frame ID of the preceding frame */
/*---------------------------------------------------------------------------*/

static struct frame_id scarts_16_unwind_dummy_id (struct gdbarch    *gdbarch,
                                                struct frame_info *next_frame)
{
  return frame_id_build (0, 0);
}


/*----------------------------------------------------------------------------*/
/*!Initialize a prologue (unwind) cache

   Build up the information (saved registers etc) for the given frame if it
   does not already exist.

   @param[in]     next_frame           The NEXT frame (i.e. inner from here,
                                       the one THIS frame called)
   @param[in,out] this_prologue_cache  The prologue cache. If not supplied, we
                                       build it.

   @return  The prolog cache (duplicates the return through the argument) */
/*---------------------------------------------------------------------------*/

static struct trad_frame_cache *
scarts_16_frame_unwind_cache (struct frame_info  *next_frame,
                            void              **this_prologue_cache)
{
  struct trad_frame_cache *info;

  if (*this_prologue_cache != NULL)
    return *this_prologue_cache;

  info = trad_frame_cache_zalloc (next_frame);
  *this_prologue_cache = info;

  return info;
}


/*----------------------------------------------------------------------------*/
/*!Find the frame ID of this frame
 *
 * Given a GDB frame (called by THIS frame), determine the address of oru
 * frame and from this create a new GDB frame struct. The info required is
 * obtained from the prologue cache for THIS frame.
 *
 * @param[in] next_frame           The NEXT frame (i.e. inner from here, the
 *                                 one THIS frame called)
 * @param[in] this_prologue_cache  Any cached prologue for THIS function.
 * @param[out]this_id              Frame ID of our own frame.
 *
 * @return  Frame ID for THIS frame */
/*---------------------------------------------------------------------------*/

static void
scarts_16_frame_this_id (struct frame_info *next_frame,
                       void             **this_prologue_cache,
                       struct frame_id   *this_id)
{
  struct trad_frame_cache *info = scarts_16_frame_unwind_cache (next_frame, this_prologue_cache);
  trad_frame_get_id (info, this_id);
}


/*----------------------------------------------------------------------------*/
/*!Get a register from THIS frame
 *
 * Given a pointer to the NEXT frame, return the details of a register in the
 * PREVIOUS frame.
 *
 * @param[in] next_frame            The NEXT frame (i.e. inner from here, the
 *                                  one THIS frame called).
 * @param[in]  this_prologue_cache  Any cached prologue associated with THIS
 *                                  frame, which may therefore tell us about
 *                                  registers in the PREVIOUS frame.
 * @param[in]  regnum               The register of interest in the PREVIOUS
 *                                  frame.
 * @param[out] optimizedp           True (1) if the register has been
 *                                  optimized out.
 * @param[out] lvalp                What sort of l-value (if any) does the
 *                                  register represent.
 * @param[out] addrp                Address in THIS frame where the register's
 *                                  value may be found (-1 if not available).
 * @param[out] realregp             Register in this frame where the
 *                                  register's value may be found (-1 if not
 *                                  available).
 * @param[out] bufferp              If non-NULL, buffer where the value held
 *                                  in the register may be put */
/*--------------------------------------------------------------------------*/

static void
scarts_16_frame_prev_register (struct frame_info  *next_frame,
                             void              **this_prologue_cache,
                             int                 regnum,
                             int                *optimizedp,
                             enum lval_type     *lvalp,
                             CORE_ADDR          *addrp,
                             int                *realregp,
                             gdb_byte           *bufferp)
{
  struct trad_frame_cache *info = scarts_16_frame_unwind_cache (next_frame, this_prologue_cache);
  trad_frame_get_register (info, next_frame, regnum, optimizedp, lvalp, addrp, realregp, bufferp);
}


/*----------------------------------------------------------------------------*/
/*!Return the base address of the frame
 *
 * The commenting in the GDB source code could mean our stack pointer or our
 * frame pointer, since we have a falling stack, but index within the frame
 * using negative offsets from the FP.
 *
 * This seems to be the function used to determine the value of $fp, but the
 * value required seems to be the stack pointer, so we return that, even if
 * the value of $fp will be wrong.
 *
 * @param[in] next_frame            The NEXT frame (i.e. inner from here, the
 *                                  one THIS frame called).
 * @param[in]  this_prologue_cache  Any cached prologue for THIS function.
 *
 * @return  The frame base address */
/*---------------------------------------------------------------------------*/

static CORE_ADDR
scarts_16_frame_base_address (struct frame_info *next_frame,
                            void             **this_prologue_cache)
{
  return frame_unwind_register_unsigned (next_frame, SCARTS_SP_REGNUM);
}


static CORE_ADDR
scarts_16_frame_locals_address (struct frame_info *next_frame,
                              void             **this_prologue_cache)
{
  return frame_unwind_register_unsigned (next_frame, SCARTS_FP_REGNUM);
}


static CORE_ADDR
scarts_16_frame_args_address (struct frame_info *next_frame,
                            void             **this_prologue_cache)
{
  return scarts_16_frame_base_address (next_frame, this_prologue_cache);
}


/*----------------------------------------------------------------------------*/
/*!The SCARTS registered frame sniffer
 *
 * This function just identifies our family of frame sniffing functions.
 *
 * @param[in] next_frame  The "next" (i.e. inner, newer from here, the one
 *                        THIS frame called) frame.
 *
 * @return  A pointer to a struct identifying the sniffing functions */
/*---------------------------------------------------------------------------*/

static const struct frame_unwind *
scarts_16_frame_sniffer (struct frame_info *next_frame)
{
  static const struct frame_unwind scarts_16_frame_unwind =
  {
    .type          = NORMAL_FRAME,
    .this_id       = scarts_16_frame_this_id,
    .prev_register = scarts_16_frame_prev_register,
    .unwind_data   = NULL,
    .sniffer       = NULL,
    .prev_pc       = NULL,
    .dealloc_cache = NULL
  };

  return &scarts_16_frame_unwind;
}

static struct gdbarch *
scarts_16_gdbarch_init (struct gdbarch_info  info,
                      struct gdbarch_list *arches)
{
  static struct frame_base     scarts_16_frame_base;
  struct        gdbarch       *gdbarch;
  struct        gdbarch_tdep  *tdep;
  const struct  bfd_arch_info *binfo;

  binfo                   = info.bfd_arch_info;
  tdep                    = xmalloc (sizeof *tdep);
  tdep->num_gp_regs       = SCARTS_NUM_GP_REGS;
  tdep->num_sp_regs       = SCARTS_NUM_SP_REGS;
  tdep->num_pseudo_regs   = SCARTS_NUM_PSEUDO_REGS;
  tdep->pc_regnum         = SCARTS_PC_REGNUM;
  tdep->fp_regnum         = SCARTS_FP_REGNUM;
  tdep->sp_regnum         = SCARTS_SP_REGNUM;
  tdep->bytes_per_word    = binfo->bits_per_word / binfo->bits_per_byte;
  tdep->bytes_per_address = binfo->bits_per_address / binfo->bits_per_byte;
  gdbarch                 = gdbarch_alloc (&info, tdep);

  /* Target data types. */
  set_gdbarch_short_bit             (gdbarch, 16);
  set_gdbarch_int_bit               (gdbarch, 16);
  set_gdbarch_long_bit              (gdbarch, 32);
  set_gdbarch_long_long_bit         (gdbarch, 64);
  set_gdbarch_float_bit             (gdbarch, 32);
  set_gdbarch_float_format          (gdbarch, floatformats_ieee_single);
  set_gdbarch_double_bit            (gdbarch, 64);
  set_gdbarch_double_format         (gdbarch, floatformats_ieee_double);
  set_gdbarch_long_double_bit       (gdbarch, 64);
  set_gdbarch_long_double_format    (gdbarch, floatformats_ieee_double);
  set_gdbarch_ptr_bit               (gdbarch, binfo->bits_per_address);
  set_gdbarch_addr_bit              (gdbarch, binfo->bits_per_address);
  set_gdbarch_char_signed           (gdbarch, 1);

  /* Information about the target architecture. */
  set_gdbarch_return_value          (gdbarch, scarts_16_return_value);
  set_gdbarch_breakpoint_from_pc    (gdbarch, scarts_16_breakpoint_from_pc);
  set_gdbarch_print_insn            (gdbarch, scarts_16_print_insn);

  /* Register architecture. */
  set_gdbarch_pseudo_register_read  (gdbarch, scarts_16_pseudo_register_read);
  set_gdbarch_pseudo_register_write (gdbarch, scarts_16_pseudo_register_write);
  set_gdbarch_num_regs              (gdbarch, SCARTS_NUM_REGS);
  set_gdbarch_num_pseudo_regs       (gdbarch, SCARTS_NUM_PSEUDO_REGS);
  set_gdbarch_sp_regnum             (gdbarch, SCARTS_SP_REGNUM);
  set_gdbarch_pc_regnum             (gdbarch, SCARTS_PC_REGNUM);
  set_gdbarch_deprecated_fp_regnum  (gdbarch, SCARTS_FP_REGNUM);

  /* Functions to supply register information. */
  set_gdbarch_register_name         (gdbarch, scarts_16_register_name);
  set_gdbarch_register_type         (gdbarch, scarts_16_register_type);
  set_gdbarch_print_registers_info  (gdbarch, scarts_16_registers_info);
  set_gdbarch_register_reggroup_p   (gdbarch, scarts_16_register_reggroup_p);

  /* Functions to analyse frames. */
  set_gdbarch_skip_prologue         (gdbarch, scarts_16_skip_prologue);
  set_gdbarch_inner_than            (gdbarch, core_addr_lessthan);
  set_gdbarch_frame_align           (gdbarch, scarts_16_frame_align);
  set_gdbarch_frame_red_zone_size   (gdbarch, SCARTS_FRAME_RED_ZONE_SIZE);

  /* Functions to handle addresses. */
  set_gdbarch_addr_bits_remove      (gdbarch, scarts_16_addr_bits_remove);

  /* Functions to access frame data. */
  set_gdbarch_unwind_pc             (gdbarch, scarts_16_unwind_pc);
  set_gdbarch_unwind_sp             (gdbarch, scarts_16_unwind_sp);

  /* Functions handling dummy frames. */
  set_gdbarch_push_dummy_call       (gdbarch, scarts_16_push_dummy_call);
  set_gdbarch_unwind_dummy_id       (gdbarch, scarts_16_unwind_dummy_id);

  /* High level frame base sniffer. */
  scarts_16_frame_base.unwind         = scarts_16_frame_sniffer (NULL);
  scarts_16_frame_base.this_base      = scarts_16_frame_base_address;
  scarts_16_frame_base.this_locals    = scarts_16_frame_locals_address;
  scarts_16_frame_base.this_args      = scarts_16_frame_args_address;
  frame_base_set_default            (gdbarch, &scarts_16_frame_base);

  /* Low level frame sniffers. */
  frame_unwind_append_sniffer       (gdbarch, dwarf2_frame_sniffer);
  frame_unwind_append_sniffer       (gdbarch, scarts_16_frame_sniffer);

  return gdbarch;
}


/*----------------------------------------------------------------------------*/
/*!Dump the target specific data for this architecture
 *
 * @param[in] gdbarch  The architecture of interest
 * @param[in] file     Where to dump the data */
/*---------------------------------------------------------------------------*/

static void
scarts_16_dump_tdep (struct gdbarch *gdbarch,
                   struct ui_file *file)
{
  struct gdbarch_tdep *tdep = gdbarch_tdep (gdbarch);

  if (tdep == NULL)
    return;

  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d general purpose registers\n", tdep->num_gp_regs);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d special purpose registers\n", tdep->num_sp_regs);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d pseudo registers\n",          tdep->num_pseudo_regs);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d is the PC register\n",        tdep->pc_regnum);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d is the FP register\n",        tdep->fp_regnum);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d is the SP register\n",        tdep->sp_regnum);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d bytes per word\n",            tdep->bytes_per_word);
  fprintf_unfiltered (file, "scarts_16_dump_tdep: %d bytes per address\n",         tdep->bytes_per_address);
}


/*----------------------------------------------------------------------------*/
/*!Main entry point for target architecture initialization
 *
 * In this version initializes the architecture via
 * registers_gdbarch_init(). Add a command to set and show special purpose
 * registers. */
/*---------------------------------------------------------------------------*/

void
_initialize_scarts_16_tdep (void)
{
  gdbarch_register (bfd_arch_scarts_16, scarts_16_gdbarch_init, scarts_16_dump_tdep);
}

