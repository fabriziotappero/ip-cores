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


#define GNU_SOURCE
#define _GNU_SOURCE

#ifndef PARAMS
#define PARAMS(ARGS) ARGS
#endif

#include <assert.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>

#include "modules.h"
#include "scarts_32-codemem.h"
#include "scarts_32-datamem.h"
#include "scarts_32-iss.h"
#include "scarts_32-mad.h"
#include "scarts-op.h"
#include "scarts_32-plugins.h"
#include "scarts_32-desc.h"
#include "scarts_32-tdep.h"

/* Macros for mapping the Processor Control Module plugin registers. */
#undef PROC_CTRL_STATUS_C
#define PROC_CTRL_STATUS_C      (*(uint8_t *const)  (plugin_proc_ctrl->get_mem() + PROC_CTRL_STATUS_C_BOFF))
#undef PROC_CTRL_CONFIG_C
#define PROC_CTRL_CONFIG_C      (*(uint8_t *const)  (plugin_proc_ctrl->get_mem() + PROC_CTRL_CONFIG_C_BOFF))
#undef PROC_CTRL_INTPROT
#define PROC_CTRL_INTPROT       (*(uint16_t *const) (plugin_proc_ctrl->get_mem() + PROC_CTRL_INTPROT_BOFF))
#undef PROC_CTRL_INTMASK
#define PROC_CTRL_INTMASK       (*(uint16_t *const) (plugin_proc_ctrl->get_mem() + PROC_CTRL_INTMASK_BOFF))
#undef PROC_CTRL_FPW
#define PROC_CTRL_FPW           (*(uint32_t *const) (plugin_proc_ctrl->get_mem() + PROC_CTRL_FPW_BOFF))
#undef PROC_CTRL_FPX
#define PROC_CTRL_FPX           (*(uint32_t *const) (plugin_proc_ctrl->get_mem() + PROC_CTRL_FPX_BOFF))
#undef PROC_CTRL_FPY
#define PROC_CTRL_FPY           (*(uint32_t *const) (plugin_proc_ctrl->get_mem() + PROC_CTRL_FPY_BOFF))
#undef PROC_CTRL_FPZ
#define PROC_CTRL_FPZ           (*(uint32_t *const) (plugin_proc_ctrl->get_mem() + PROC_CTRL_FPZ_BOFF))
#undef PROC_CTRL_SAVE_STATUS_C
#define PROC_CTRL_SAVE_STATUS_C (*(uint8_t *const)  (plugin_proc_ctrl->get_mem() + PROC_CTRL_SAVE_STATUS_C_BOFF))
#undef PROGRAMMER_CONFIG_C
#define PROGRAMMER_CONFIG_C     (*(uint8_t *const)  (plugin_programmer->get_mem() + PROGRAMMER_CONFIG_C_BOFF))


static int32_t          cond;
static int32_t          carry, old_carry;
static uint32_t         regfile[SCARTS_TOTAL_NUM_REGS];
static uint32_t         vectab[SCARTS_NUM_VECTORS];
static scarts_plugin_t *plugin_programmer;
static scarts_plugin_t *plugin_proc_ctrl;

static int is_addr_aligned (uint32_t addr, uint8_t alignment);
static int load_data       (uint32_t addr, uint32_t *data, enum scarts_access_mode mode);
static int store_data      (uint32_t addr, uint32_t data, enum scarts_access_mode mode);

static int
is_addr_aligned (uint32_t addr, uint8_t alignment)
{
  if ((addr % alignment) != 0)
  {
    error ("Unaligned memory access at 0x%X", addr);
    return 0;
  }

  return 1;
}

static int
load_data (uint32_t vma, uint32_t* data, enum scarts_access_mode mode)
{
  int i;
  uint8_t size, temp;
  uint32_t addr, result;
  scarts_datamem_read_fptr_t read_fptr;
  scarts_datamem_write_fptr_t write_fptr;
  enum scarts_mem_type mem_type;

  result = *data = 0;

  switch (mode)
  {
    case WORD:
    {
      if (!is_addr_aligned (vma, SCARTS_WORD_SIZE))
        return SIGBUS;

      size = 4;
      break;
    }
    case HWORD:
    case HWORDU:
    {
      if (!is_addr_aligned (vma, SCARTS_WORD_SIZE / 2))
        return SIGBUS;

      size = 2;
      break;
    }
    case BYTE:
    case BYTEU:
    {
      size = 1;
      break;
    }
    default:
    {
      error ("Unsupported access mode.");
      return SIGILL;
    }
  }

  mem_type = scarts_datamem_vma_decode (vma, &read_fptr, &write_fptr, &addr);
  if (mem_type == SCARTS_NOMEM)
  {
    error ("Memory access at 0x%X is out of bounds.", vma);
    return SIGSEGV;
  }

  for (i = 0; i < size; ++i)
  {
    (void) (*read_fptr) (addr + i, &temp);
    result |= temp << (i * 8);
  }

  *data = result;
  return 0;
}

static int
store_data (uint32_t vma, uint32_t data, enum scarts_access_mode mode)
{
  int i;
  uint8_t size;
  uint32_t addr;
  scarts_datamem_read_fptr_t read_fptr;
  scarts_datamem_write_fptr_t write_fptr;
  enum scarts_mem_type mem_type;

  switch (mode)
  {
    case WORD:
    {
      if (!is_addr_aligned (vma, SCARTS_WORD_SIZE))
        return SIGBUS;

      size = 4;
      break;
    }
    case HWORD:
    case HWORDU:
    {
      if (!is_addr_aligned (vma, SCARTS_WORD_SIZE / 2))
        return SIGBUS;

      size = 2;
      break;
    }
    case BYTE:
    case BYTEU:
    {
      size = 1;
      break;
    }
    default:
    {
      error ("Unsupported access mode.");
      return SIGILL;
    }
  }

  mem_type = scarts_datamem_vma_decode (vma, &read_fptr, &write_fptr, &addr);
  if (mem_type == SCARTS_NOMEM)
  {
    error ("Memory access at 0x%X is out of bounds.", vma);
    return SIGSEGV;
  }

  for (i = 0; i < size; ++i)
  {
    (void) (*write_fptr) (addr + i, (uint8_t) (data >> (i * 8)));
  }

  return 0;
}

void
scarts_init (void)
{
  scarts_load_plugins ();
  plugin_programmer = scarts_get_plugin (PROGRAMMER_BADDR);
  if (plugin_programmer != NULL)
  {
    if (plugin_programmer->set_codemem_read_fptr == NULL)
    {
      /* Function 'set_codemem_read_fptr' is mandatory for the Programmer Module plugin. */
      error ("Unable to find function 'set_codemem_read_fptr' in Programmer Module plugin.");
      exit (EXIT_FAILURE);
    }

    plugin_programmer->set_codemem_read_fptr (scarts_codemem_read);

    if (plugin_programmer->set_codemem_write_fptr == NULL)
    {
      /* Function 'set_codemem_write_fptr' is mandatory for the Programmer Module plugin. */
      error ("Unable to find function 'set_codemem_write_fptr' in Programmer Module plugin.");
      exit (EXIT_FAILURE);
    }

    plugin_programmer->set_codemem_write_fptr (scarts_codemem_write);

    if (plugin_programmer->set_datamem_read_fptr == NULL)
    {
      /* Function 'set_datamem_read_fptr' is mandatory for the Programmer Module plugin. */
      error ("Unable to find function 'set_datamem_read_fptr' in Programmer Module plugin.");
      exit (EXIT_FAILURE);
    }

    plugin_programmer->set_datamem_read_fptr (scarts_datamem_read);

    if (plugin_programmer->set_datamem_write_fptr == NULL)
    {
      /* Function 'set_datamem_write_fptr' is mandatory for the Programmer Module plugin. */
      error ("Unable to find function 'set_datamem_write_fptr' in Programmer Module plugin.");
      exit (EXIT_FAILURE);
    }

    plugin_programmer->set_datamem_write_fptr (scarts_datamem_write);
  }

  plugin_proc_ctrl = scarts_get_plugin (PROC_CTRL_BADDR);
  if (plugin_proc_ctrl == NULL)
  {
    /* The System Control Module plugin is mandatory. */
    error ("Unable to find System Control Module plugin.");
    exit (EXIT_FAILURE);
  }

  scarts_bootmem_init ();
  regfile[SCARTS_PC_REGNUM] = SCARTS_BOOTMEM_VMA;
}

int
scarts_mem_read (uint32_t lma, uint8_t* value)
{
  uint16_t temp;
  uint32_t addr;
  scarts_codemem_read_fptr_t codemem_read_fptr;
  scarts_codemem_write_fptr_t codemem_write_fptr;
  scarts_datamem_read_fptr_t datamem_read_fptr;
  scarts_datamem_write_fptr_t datamem_write_fptr;
  enum scarts_mem_type mem_type;

  mem_type = scarts_lma_decode (lma,
                                &codemem_read_fptr,
                                &codemem_write_fptr,
                                &datamem_read_fptr,
                                &datamem_write_fptr,
                                &addr);

  if (mem_type == SCARTS_NOMEM)
  {
    /* If the LMA could not be decoded properly, the following scenario might
       have occurred: the GDB has passed the VMA of a function pointer whose
       address got determined from the data memory beforehand. */
    mem_type = scarts_codemem_vma_decode (lma * SCARTS_INSN_SIZE,
                                          &codemem_read_fptr,
                                          &codemem_write_fptr,
                                          &addr);

    if (mem_type == SCARTS_NOMEM)
    {
      error ("Memory access at 0x%X is out of bounds.", lma);
      return SIGSEGV;
    }
  }

  switch (mem_type)
  {
    case SCARTS_BOOTMEM:
    case SCARTS_CODEMEM:
    {
      if ((*codemem_read_fptr) (addr, &temp) == 0)
        return 0;

      if ((lma & 1) == 0)
        *value = temp & 0x00FF;
      else
        *value = (temp >> 8) & 0x00FF;

      break;
    }
    default:
      break;
  }

  switch (mem_type)
  {
    case SCARTS_DATAMEM:
    case SCARTS_PLUGIN:
    {
      if ((*datamem_read_fptr) (addr, value) == 0)
        return 0;

      break;
    }
    default:
      break;
  }

  return 1;
}

int
scarts_mem_write (uint32_t lma, uint8_t value)
{
  uint16_t temp;
  uint32_t addr;
  scarts_codemem_read_fptr_t codemem_read_fptr;
  scarts_codemem_write_fptr_t codemem_write_fptr;
  scarts_datamem_read_fptr_t datamem_read_fptr;
  scarts_datamem_write_fptr_t datamem_write_fptr;
  enum scarts_mem_type mem_type;

  mem_type = scarts_lma_decode (lma,
                                &codemem_read_fptr,
                                &codemem_write_fptr,
                                &datamem_read_fptr,
                                &datamem_write_fptr,
                                &addr);

  if (mem_type == SCARTS_NOMEM)
  {
    error ("Memory access at 0x%X is out of bounds.", lma);
    return SIGSEGV;
  }

  switch (mem_type)
  {
    case SCARTS_BOOTMEM:
    case SCARTS_CODEMEM:
    {
      if ((*codemem_read_fptr) (addr, &temp) == 0)
        return 0;

      if ((lma & 1) == 0)
      {
        temp &= 0xFF00;
        temp |= value;
      }
      else
      {
        temp &= 0x00FF;
        temp |= (value << 8);
      }

      (*codemem_write_fptr) (addr, temp);
      break;
    }
    default:
      break;
  }

  switch (mem_type)
  {
    case SCARTS_DATAMEM:
    case SCARTS_PLUGIN:
    {
      if ((*datamem_write_fptr) (addr, value) == 0)
        return 0;

      break;
    }
    default:
      break;
  }

  return 1;
}

uint32_t
scarts_regfile_read (int regno)
{
  if (regno >= 0 && regno < SCARTS_NUM_GP_REGS)
  {
    return regfile[regno];
  }
  else if (regno >= SCARTS_NUM_GP_REGS && regno < SCARTS_TOTAL_NUM_REGS)
  {
    switch (regno)
    {
      case SCARTS_FP_REGNUM:
        return PROC_CTRL_FPY;
      case SCARTS_SP_REGNUM:
        return PROC_CTRL_FPZ;
      default:
        return regfile[regno];
    }
  }
}

void
scarts_regfile_write (int regno, uint32_t value)
{
  if (regno >= 0 && regno < SCARTS_NUM_GP_REGS)
  {
    regfile[regno] = value;
  }
  else if (regno >= SCARTS_NUM_GP_REGS && regno < SCARTS_TOTAL_NUM_REGS)
  {
    switch (regno)
    {
      case SCARTS_FP_REGNUM:
        PROC_CTRL_FPY = value;
        break;
      case SCARTS_SP_REGNUM:
        PROC_CTRL_FPZ = value;
        break;
      default:
        regfile[regno] = value;
        break;
    }
  }
}

void
scarts_reset (void)
{
  uint32_t old_pc;

  cond = 0;
  carry = old_carry = 0;
  old_pc = regfile[SCARTS_PC_REGNUM];

  memset (regfile, 0, SCARTS_WORD_SIZE * SCARTS_TOTAL_NUM_REGS);
  memset (vectab, 0, SCARTS_WORD_SIZE * SCARTS_NUM_VECTORS);
  scarts_reset_plugins ();

  regfile[SCARTS_PC_REGNUM] = old_pc;
}

int
scarts_tick (void)
{
  int i, int_num, decode_steps, result;
  uint16_t unmasked_ints;
  uint32_t data;
  uint32_t addr, next_pc, *pc;
  scarts_codemem_read_fptr_t read_fptr;
  scarts_codemem_write_fptr_t write_fptr;
  scarts_op_t insn;
  enum scarts_mem_type mem_type;

  decode_steps = result = 0;
  data = 0;
  pc = &(regfile[SCARTS_PC_REGNUM]);

  if (plugin_programmer != NULL)
  {
    /* Check if the programmer module issued a soft-reset. */
    if ((PROGRAMMER_CONFIG_C & (1 << PROGRAMMER_CONFIG_C_CLR)))
      scarts_reset ();
  }

  next_pc = *pc;

  /* Call tick() for each plugin. */
  scarts_tick_plugins (pc);

  /* Check if a plugin requested an interrupt. */
  int_num = scarts_get_plugin_int_request ();
  if (int_num != -1)
  {
    /* Set interrupt bit in the Processor Control Module. */
    PROC_CTRL_INTPROT |= (1 << int_num);
  }

  /* Check for pending interrupts (INT0 is non-maskable). */
  unmasked_ints = PROC_CTRL_INTPROT & ((~PROC_CTRL_INTMASK) | 1);
  
  /* Check if the GIE flag is set in the config register. */
  if ((PROC_CTRL_CONFIG_C & (1 << PROC_CTRL_CONFIG_C_GIE)) && unmasked_ints != 0)
  {
    /* There is at least one interrupt pending and not masked. */
    int_num = 0;
    while (!(unmasked_ints & 1))
    {
      unmasked_ints >>= 1;
      int_num++;
    }

    /* De-protocol the interrupt in the protocol register. */
    PROC_CTRL_INTPROT &= ~(1 << int_num);

    /* Save the status register. */
    PROC_CTRL_SAVE_STATUS_C = PROC_CTRL_STATUS_C;

    /* Save the PC as return address for the RTE instruction. */
    regfile[SCARTS_RTE_REGNUM] = *pc;

    /* Disable the GIE flag in the config register. */
    PROC_CTRL_CONFIG_C &= ~(1 << PROC_CTRL_CONFIG_C_GIE);

    /* Jump to the ISR. */
    next_pc = *pc = vectab[int_num];
  }

  mem_type = scarts_codemem_vma_decode (*pc, &read_fptr, &write_fptr, &addr);
  if (mem_type == SCARTS_NOMEM)
  {
     error ("Memory access at 0x%X is out of bounds.", *pc);
     return SIGSEGV;
  }

  (void) (*read_fptr) (addr, &insn.raw);

  switch (insn.ldiop.op)
  {
    case OPC4_LDLI:
      regfile[insn.ldiop.reg] = insn.ldiop.val;
      break;
    case OPC4_LDHI:
      regfile[insn.ldiop.reg] &= 0xFF;
      regfile[insn.ldiop.reg] |= (int32_t) insn.ldiop.val << 8;
      assert(((regfile[insn.ldiop.reg] & 0xFFFF8000) == 0xFFFF8000) || ((regfile[insn.ldiop.reg] & 0xFFFF8000) == 0));
      break;
    case OPC4_LDLIU:
      regfile[insn.ldiop.reg] &= 0xFFFFFF00;
      regfile[insn.ldiop.reg] |= insn.ldiop.val & 0xFF;
      break;
    default:
      decode_steps++;
  }

  switch (insn.imm7op.op)
  {
    case OPC5_CMPI_LT:
      cond = ((int32_t) regfile[insn.imm7op.reg] < (int32_t) insn.imm7op.val);
      break;
    case OPC5_CMPI_GT:
      cond = ((int32_t) regfile[insn.imm7op.reg] > (int32_t) insn.imm7op.val);
      break;
    case OPC5_CMPI_EQ:
      cond = ((int32_t) regfile[insn.imm7op.reg] == (int32_t) insn.imm7op.val);
      break;
    default:
      decode_steps++;
  }

  switch (insn.imm6op.op)
  {
    case OPC6_LDFPW:
      if (result = load_data (PROC_CTRL_FPW + SCARTS_WORD_SIZE * insn.imm6op.val, &data, WORD))
        break;

      regfile[insn.imm6op.reg] = data;
      break;
    case OPC6_LDFPX:
      if (result = load_data (PROC_CTRL_FPX + SCARTS_WORD_SIZE * insn.imm6op.val, &data, WORD))
        break;

      regfile[insn.imm6op.reg] = data;
      break;
    case OPC6_LDFPY:
      if (result = load_data (PROC_CTRL_FPY + SCARTS_WORD_SIZE * insn.imm6op.val, &data, WORD))
        break;

      regfile[insn.imm6op.reg] = data;
      break;
    case OPC6_LDFPZ:
      if (result = load_data (PROC_CTRL_FPZ + SCARTS_WORD_SIZE * insn.imm6op.val, &data, WORD))
        break;

      regfile[insn.imm6op.reg] = data;
      break;
    case OPC6_STFPW:
      result = store_data (PROC_CTRL_FPW + SCARTS_WORD_SIZE * insn.imm6op.val, regfile[insn.imm6op.reg], WORD);
      break;
    case OPC6_STFPX:
      result = store_data (PROC_CTRL_FPX + SCARTS_WORD_SIZE * insn.imm6op.val, regfile[insn.imm6op.reg], WORD);
      break;
    case OPC6_STFPY:
      result = store_data (PROC_CTRL_FPY + SCARTS_WORD_SIZE * insn.imm6op.val, regfile[insn.imm6op.reg], WORD);
      break;
    case OPC6_STFPZ:
      result = store_data (PROC_CTRL_FPZ + SCARTS_WORD_SIZE * insn.imm6op.val, regfile[insn.imm6op.reg], WORD);
      break;
    case OPC6_ADDI:
      carry = ((int64_t) regfile[insn.imm6op.reg] + (int64_t) insn.imm6op.val) >> 32;
      regfile[insn.imm6op.reg] += insn.imm6op.val;
      break;
    case OPC6_ADDI_CT:
      if (cond)
      {
        carry = ((int64_t) regfile[insn.imm6op.reg] + (int64_t) insn.imm6op.val) >> 32;
        regfile[insn.imm6op.reg] += insn.imm6op.val;
      }
      break;
    case OPC6_ADDI_CF:
      if (!cond)
      {
        carry = ((int64_t) regfile[insn.imm6op.reg] + (int64_t) insn.imm6op.val) >> 32;
        regfile[insn.imm6op.reg] += insn.imm6op.val;
      }
      break;
    default:
      decode_steps++;
  }

  switch (insn.imm5op.op)
  {
    case OPC7_LDFPW_INC:
      if (result = load_data (PROC_CTRL_FPW + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPW += SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPW_DEC:
      if (result = load_data (PROC_CTRL_FPW + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPW -= SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPX_INC:
      if (result = load_data (PROC_CTRL_FPX + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPX += SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPX_DEC:
      if (result = load_data (PROC_CTRL_FPX + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPX -= SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPY_INC:
      if (result = load_data (PROC_CTRL_FPY + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPY += SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPY_DEC:
      if (result = load_data (PROC_CTRL_FPY + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPY -= SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPZ_INC:
      if (result = load_data (PROC_CTRL_FPZ + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPZ += SCARTS_WORD_SIZE;
      break;
    case OPC7_LDFPZ_DEC:
      if (result = load_data (PROC_CTRL_FPZ + SCARTS_WORD_SIZE * insn.imm5op.val, &data, WORD))
        break;

      regfile[insn.imm5op.reg] = data;
      PROC_CTRL_FPZ -= SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPW_INC:
      if (result = store_data (PROC_CTRL_FPW + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPW += SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPW_DEC:
      if (result = store_data (PROC_CTRL_FPW + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPW -= SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPX_INC:
      if (result = store_data (PROC_CTRL_FPX + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPX += SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPX_DEC:
      if (result = store_data (PROC_CTRL_FPX + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPX -= SCARTS_WORD_SIZE;
    case OPC7_STFPY_INC:
      if (result = store_data (PROC_CTRL_FPY + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPY += SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPY_DEC:
      if (result = store_data (PROC_CTRL_FPY + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPY -= SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPZ_INC:
      if (result = store_data (PROC_CTRL_FPZ + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPZ += SCARTS_WORD_SIZE;
      break;
    case OPC7_STFPZ_DEC:
      if (result = store_data (PROC_CTRL_FPZ + SCARTS_WORD_SIZE * insn.imm5op.val, regfile[insn.imm5op.reg], WORD))
        break;

      PROC_CTRL_FPZ -= SCARTS_WORD_SIZE;
      break;
    case OPC7_BSET:
      regfile[insn.imm5op.reg] |= 1 << (uint32_t) insn.imm5op.val;
      break;
    case OPC7_BCLR:
      regfile[insn.imm5op.reg] &= ~(1 << (uint32_t) insn.imm5op.val);
      break;
    case OPC7_BSET_CT:
      if (cond)
      {
        regfile[insn.imm5op.reg] |= 1 << (uint32_t) insn.imm5op.val;
      }
      break;
    case OPC7_BCLR_CT:
      if (cond)
      {
        regfile[insn.imm5op.reg] &= ~(1 << (uint32_t) insn.imm5op.val);
      }
      break;
    case OPC7_BSET_CF:
      if (!cond)
      {
        regfile[insn.imm5op.reg] |= 1 << (uint32_t) insn.imm5op.val;
      }
      break;
    case OPC7_BCLR_CF:
      if (!cond)
      {
        regfile[insn.imm5op.reg] &= ~(1 << (uint32_t) insn.imm5op.val);
      }
      break;
    case OPC7_BTEST:
      cond = ((regfile[insn.imm5op.reg] & (1 << (uint32_t) insn.imm5op.val)) != 0);
      break;
    case OPC7_STVEC:
      vectab[insn.imm5op.val + 16] = regfile[insn.imm5op.reg];
      break;
    case OPC7_LDVEC:
      regfile[insn.imm5op.reg] = vectab[insn.imm5op.val + 16];
      break;
    default:
      decode_steps++;
  }

  switch (insn.imm4op.op)
  {
    case OPC8_SLI:
      carry = (regfile[insn.imm4op.reg] >> (32 - (uint32_t) insn.imm4op.val)) & 1;
      regfile[insn.imm4op.reg] <<= (uint32_t) insn.imm4op.val;
      break;
    case OPC8_SRI:
      carry = regfile[insn.imm4op.reg] & (1 << ((uint32_t) insn.imm4op.val - 1));
      regfile[insn.imm4op.reg] >>= (uint32_t) insn.imm4op.val;
      break;
    case OPC8_SRAI:
      carry = regfile[insn.imm4op.reg] & (1 << ((uint32_t) insn.imm4op.val - 1));
      regfile[insn.imm4op.reg] = (int32_t) regfile[insn.imm4op.reg] >> (uint32_t) insn.imm4op.val;
      break;
    case OPC8_TRAP:
      regfile[SCARTS_RTE_REGNUM] = *pc + SCARTS_INSN_SIZE;
      next_pc = vectab[insn.imm4op.val + 16] - SCARTS_INSN_SIZE;
      break;
    case OPC8_SLI_CT:
      if (cond)
      {
        carry = (regfile[insn.imm4op.reg] >> (32 - (uint32_t) insn.imm4op.val)) & 1;
        regfile[insn.imm4op.reg] <<= (uint32_t) insn.imm4op.val;
      }
      break;
    case OPC8_SRI_CT:
      if (cond)
      {
        carry = regfile[insn.imm4op.reg] & (1 << ((uint32_t) insn.imm4op.val - 1));
        regfile[insn.imm4op.reg] >>= (uint32_t) insn.imm4op.val;
      }
      break;
    case OPC8_SRAI_CT:
      if (cond)
      {
        carry = regfile[insn.imm4op.reg] & (1 << ((uint32_t) insn.imm4op.val - 1));
        regfile[insn.imm4op.reg] = (int32_t) regfile[insn.imm4op.reg] >> (uint32_t) insn.imm4op.val;
      }
      break;
    case OPC8_TRAP_CT:
      if (cond)
      {
        regfile[SCARTS_RTE_REGNUM] = *pc + SCARTS_INSN_SIZE;
        next_pc = vectab[insn.imm4op.val + 16] - SCARTS_INSN_SIZE;
      }
      break;
    case OPC8_SLI_CF:
      if (!cond)
      {
        carry = (regfile[insn.imm4op.reg] >> (32 - (uint32_t) insn.imm4op.val)) & 1;
        regfile[insn.imm4op.reg] <<= (uint32_t) insn.imm4op.val;
      }
      break;
    case OPC8_SRI_CF:
      if (!cond)
      {
        carry = regfile[insn.imm4op.reg] & (1 << ((uint32_t) insn.imm4op.val - 1));
        regfile[insn.imm4op.reg] >>= (uint32_t) insn.imm4op.val;
      }
      break;
    case OPC8_SRAI_CF:
      if (!cond)
      {
        carry = regfile[insn.imm4op.reg] & (1 << ((uint32_t) insn.imm4op.val - 1));
        regfile[insn.imm4op.reg] = (int32_t) regfile[insn.imm4op.reg] >> (uint32_t) insn.imm4op.val;
      }
      break;
    case OPC8_TRAP_CF:
      if (!cond)
      {
        regfile[SCARTS_RTE_REGNUM] = *pc + SCARTS_INSN_SIZE;
        next_pc = vectab[insn.imm4op.val + 16] - SCARTS_INSN_SIZE;
      }
      break;
    default:
      decode_steps++;
  }

  switch (insn.binop.op)
  {
    case OPC8_SL:
      carry = (regfile[insn.binop.reg1] >> (32 - regfile[insn.binop.reg2])) & 1;
      regfile[insn.binop.reg1] <<= regfile[insn.binop.reg2];
      break;
    case OPC8_SR:
      carry = regfile[insn.binop.reg1] & (1 << (regfile[insn.binop.reg2] - 1));
      regfile[insn.binop.reg1] >>= regfile[insn.binop.reg2];
      break;
    case OPC8_SRA:
      carry = regfile[insn.binop.reg1] & (1 << (regfile[insn.binop.reg2] - 1));
      regfile[insn.binop.reg1] = (int32_t) regfile[insn.binop.reg1] >> regfile[insn.binop.reg2];
      break;
    case OPC8_SL_CT:
      if (cond)
      {
        carry = (regfile[insn.binop.reg1] >> (32 - regfile[insn.binop.reg2])) & 1;
        regfile[insn.binop.reg1] <<= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SR_CT:
      if (cond)
      {
        carry = regfile[insn.binop.reg1] & (1 << (regfile[insn.binop.reg2] - 1));
        regfile[insn.binop.reg1] >>= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SRA_CT:
      if (cond)
      {
        carry = regfile[insn.binop.reg1] & (1 << (regfile[insn.binop.reg2] - 1));
        regfile[insn.binop.reg1] = (int32_t) regfile[insn.binop.reg1] >> regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SL_CF:
      if (!cond)
      {
        carry = (regfile[insn.binop.reg1] >> (32 - regfile[insn.binop.reg2])) & 1;
        regfile[insn.binop.reg1] <<= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SR_CF:
      if (!cond)
      {
        carry = regfile[insn.binop.reg1] & (1 << (regfile[insn.binop.reg2] - 1));
        regfile[insn.binop.reg1] >>= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SRA_CF:
      if (!cond)
      {
        carry = regfile[insn.binop.reg1] & (1 << (regfile[insn.binop.reg2] - 1));
        regfile[insn.binop.reg1] = (int32_t) regfile[insn.binop.reg1] >> regfile[insn.binop.reg2];
      }
      break;
    case OPC8_CMP_EQ:
      cond = (regfile[insn.binop.reg1] == regfile[insn.binop.reg2]);
      break;
    case OPC8_CMP_LT:
      cond = ((int32_t) regfile[insn.binop.reg1] < (int32_t) regfile[insn.binop.reg2]);
      break;
    case OPC8_CMP_GT:
      cond = ((int32_t) regfile[insn.binop.reg1] > (int32_t) regfile[insn.binop.reg2]);
      break;
    case OPC8_CMPU_LT:
      cond = ((uint32_t) regfile[insn.binop.reg1] < (uint32_t) regfile[insn.binop.reg2]);
      break;
    case OPC8_CMPU_GT:
      cond = ((uint32_t) regfile[insn.binop.reg1] > (uint32_t) regfile[insn.binop.reg2]);
      break;
    case OPC8_MOV:
      regfile[insn.binop.reg1] = regfile[insn.binop.reg2];
      break;
    case OPC8_ADD:
      carry = ((int64_t) regfile[insn.binop.reg1] + (int64_t) regfile[insn.binop.reg2]) >> 32;
      regfile[insn.binop.reg1] += regfile[insn.binop.reg2];
      break;
    case OPC8_ADDC:
      old_carry = carry;
      carry = ((int64_t) regfile[insn.binop.reg1] + (int64_t) regfile[insn.binop.reg2] + old_carry) >> 32;
      regfile[insn.binop.reg1] += regfile[insn.binop.reg2] + old_carry;
      break;
    case OPC8_SUB:
      carry = ((int64_t) regfile[insn.binop.reg1] - (int64_t) regfile[insn.binop.reg2]) >> 32;
      regfile[insn.binop.reg1] -= regfile[insn.binop.reg2];
      break;
    case OPC8_SUBC:
      old_carry = carry;
      carry = ((int64_t) regfile[insn.binop.reg1] - (int64_t) regfile[insn.binop.reg2] - old_carry) >> 32;
      regfile[insn.binop.reg1] -= regfile[insn.binop.reg2] + old_carry;
      break;
    case OPC8_AND:
      regfile[insn.binop.reg1] &= regfile[insn.binop.reg2];
      break;
    case OPC8_OR:
      regfile[insn.binop.reg1] |= regfile[insn.binop.reg2];
      break;
    case OPC8_EOR:
      regfile[insn.binop.reg1] ^= regfile[insn.binop.reg2];
      break;
    case OPC8_MOV_CT:
      if (cond)
      {
        regfile[insn.binop.reg1] = regfile[insn.binop.reg2];
      }
      break;
    case OPC8_ADD_CT:
      if (cond)
      {
        carry = ((int64_t) regfile[insn.binop.reg1] + (int64_t) regfile[insn.binop.reg2]) >> 32;
        regfile[insn.binop.reg1] += regfile[insn.binop.reg2];
      }
      break;
    case OPC8_ADDC_CT:
      if (cond)
      {
        old_carry = carry;
        carry = ((int64_t) regfile[insn.binop.reg1] + (int64_t) regfile[insn.binop.reg2] + old_carry) >> 32;
        regfile[insn.binop.reg1] += regfile[insn.binop.reg2] + old_carry;
      }
      break;
    case OPC8_SUB_CT:
      if (cond)
      {
        carry = ((int64_t) regfile[insn.binop.reg1] - (int64_t) regfile[insn.binop.reg2]) >> 32;
        regfile[insn.binop.reg1] -= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SUBC_CT:
      if (cond)
      {
        old_carry = carry;
        carry = ((int64_t) regfile[insn.binop.reg1] - (int64_t) regfile[insn.binop.reg2] - old_carry) >> 32;
        regfile[insn.binop.reg1] -= regfile[insn.binop.reg2] + old_carry;
      }
      break;
    case OPC8_AND_CT:
      if (cond)
      {
        regfile[insn.binop.reg1] &= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_OR_CT:
      if (cond)
      {
        regfile[insn.binop.reg1] |= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_EOR_CT:
      if (cond)
      {
        regfile[insn.binop.reg1] ^= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_MOV_CF:
      if (!cond)
      {
        regfile[insn.binop.reg1] = regfile[insn.binop.reg2];
      }
      break;
    case OPC8_ADD_CF:
      if (!cond)
      {
        carry = ((int64_t) regfile[insn.binop.reg1] + (int64_t) regfile[insn.binop.reg2]) >> 32;
        regfile[insn.binop.reg1] += regfile[insn.binop.reg2];
      }
      break;
    case OPC8_ADDC_CF:
      if (!cond)
      {
        old_carry = carry;
        carry = ((int64_t) regfile[insn.binop.reg1] + (int64_t) regfile[insn.binop.reg2] + old_carry) >> 32;
        regfile[insn.binop.reg1] += regfile[insn.binop.reg2] + old_carry;
      }
      break;
    case OPC8_SUB_CF:
      if (!cond)
      {
        carry = ((int64_t)regfile[insn.binop.reg1] - (int64_t)regfile[insn.binop.reg2]) >> 32;
        regfile[insn.binop.reg1] -= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_SUBC_CF:
      if (!cond)
      {
        old_carry = carry;
        carry = ((int64_t) regfile[insn.binop.reg1] - (int64_t) regfile[insn.binop.reg2] - old_carry) >> 32;
        regfile[insn.binop.reg1] -= regfile[insn.binop.reg2] + old_carry;
      }
      break;
    case OPC8_AND_CF:
      if (!cond)
      {
        regfile[insn.binop.reg1] &= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_OR_CF:
      if (!cond)
      {
        regfile[insn.binop.reg1] |= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_EOR_CF:
      if (!cond)
      {
        regfile[insn.binop.reg1] ^= regfile[insn.binop.reg2];
      }
      break;
    case OPC8_LDW:
      if (result = load_data (regfile[insn.binop.reg2], &data, WORD))
        break;

      regfile[insn.binop.reg1] = data;
      break;
    case OPC8_LDH:
      if (result = load_data (regfile[insn.binop.reg2], &data, HWORD))
        break;

      regfile[insn.binop.reg1] = data;
      break;
    case OPC8_LDHU:
      if (result = load_data (regfile[insn.binop.reg2], &data, HWORDU))
        break;

      regfile[insn.binop.reg1] = data;
      break;
    case OPC8_LDB:
      if (result = load_data (regfile[insn.binop.reg2], &data, BYTE))
        break;

      regfile[insn.binop.reg1] = data;
      break;
    case OPC8_LDBU:
      if (result = load_data (regfile[insn.binop.reg2], &data, BYTEU))
        break;

      regfile[insn.binop.reg1] = data;
      break;
    case OPC8_STW:
      result = store_data (regfile[insn.binop.reg2], regfile[insn.binop.reg1], WORD);
      break;
    case OPC8_STH:
      result = store_data (regfile[insn.binop.reg2], regfile[insn.binop.reg1], HWORD);
      break;
    case OPC8_STB:
      result = store_data (regfile[insn.binop.reg2], regfile[insn.binop.reg1], BYTE);
      break;
    default:
      decode_steps++;
  }

  switch (insn.jmpiop.op)
  {
    case OPC6_JMPI:
      next_pc += (insn.jmpiop.dest * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      break;
    case OPC6_JMPI_CT:
      if (cond)
      {
        next_pc += (insn.jmpiop.dest * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      }
      break;
    case OPC6_JMPI_CF:
      if (!cond)
      {
        next_pc += (insn.jmpiop.dest * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      }
      break;
    default:
      decode_steps++;
  }

  switch (insn.unop.op)
  {
    case OPC12_RRC:
      old_carry = carry;
      carry = regfile[insn.unop.reg] & 1;
      regfile[insn.unop.reg] >>= 1;
      regfile[insn.unop.reg] |= old_carry << 31;
      break;
    case OPC12_NOT:
      regfile[insn.unop.reg] = ~regfile[insn.unop.reg];
      break;
    case OPC12_NEG:
      regfile[insn.unop.reg] = -regfile[insn.unop.reg];
      break;
    case OPC12_JSR:
      regfile[SCARTS_RTS_REGNUM] = *pc + SCARTS_INSN_SIZE;
      next_pc = (regfile[insn.unop.reg] * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      break;
    case OPC12_JMP:
      next_pc = (regfile[insn.unop.reg] * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      break;
    case OPC12_RRC_CT:
      if (cond)
      {
        old_carry = carry;
        carry = regfile[insn.unop.reg] & 1;
        regfile[insn.unop.reg] >>= 1;
        regfile[insn.unop.reg] |= old_carry << 31;
      }
      break;
    case OPC12_NOT_CT:
      if (cond)
      {
        regfile[insn.unop.reg] = ~regfile[insn.unop.reg];
      }
      break;
    case OPC12_NEG_CT:
      if (cond)
      {
        regfile[insn.unop.reg] = -regfile[insn.unop.reg];
      }
      break;
    case OPC12_JSR_CT:
      if (cond)
      {
        regfile[SCARTS_RTS_REGNUM] = *pc + SCARTS_INSN_SIZE;
        next_pc = (regfile[insn.unop.reg] * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      }
      break;
    case OPC12_JMP_CT:
      if (cond)
      {
        next_pc = (regfile[insn.unop.reg] * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      }
      break;
    case OPC12_RRC_CF:
      if (!cond)
      {
        old_carry = carry;
        carry = regfile[insn.unop.reg] & 1;
        regfile[insn.unop.reg] >>= 1;
        regfile[insn.unop.reg] |= old_carry << 31;
      }
      break;
    case OPC12_NOT_CF:
      if (!cond)
      {
        regfile[insn.unop.reg] = ~regfile[insn.unop.reg];
      }
      break;
    case OPC12_NEG_CF:
      if (!cond)
      {
        regfile[insn.unop.reg] = -regfile[insn.unop.reg];
      }
      break;
    case OPC12_JSR_CF:
      if (!cond)
      {
        regfile[SCARTS_RTS_REGNUM] = *pc + SCARTS_INSN_SIZE;
        next_pc = (regfile[insn.unop.reg] * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      }
      break;
    case OPC12_JMP_CF:
      if (!cond)
      {
        next_pc = (regfile[insn.unop.reg] * SCARTS_INSN_SIZE) - SCARTS_INSN_SIZE;
      }
      break;
    default:
      decode_steps++;
  }

  switch (insn.nulop.op)
  {
    case OPC16_RTS:
      next_pc = regfile[SCARTS_RTS_REGNUM] - SCARTS_INSN_SIZE;
      break;
    case OPC16_RTE:
      PROC_CTRL_CONFIG_C |= (1 << PROC_CTRL_CONFIG_C_GIE);
      PROC_CTRL_STATUS_C = PROC_CTRL_SAVE_STATUS_C;
      next_pc = regfile[SCARTS_RTS_REGNUM] - SCARTS_INSN_SIZE;
      break;
    case OPC16_NOP:
      break;
    case OPC16_ILLOP:
      result = SIGILL;
      break;
    default:
      decode_steps++;
  }
  
  carry = (!!carry) & 1;

  /* Compute the PC. */
  *pc = next_pc;
  *pc += SCARTS_INSN_SIZE;

  if (decode_steps != 8)
  {
    error ("Error in decoder stage (PC: 0x%X)", *pc - SCARTS_INSN_SIZE);
    exit (EXIT_FAILURE);
  }

  return result;
}

