/* tc-scarts_32.h -- Header file for tc-scarts_32.c.
   Copyright 2001, 2002, 2003, 2005, 2007 Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of GAS, the GNU Assembler.

   GAS is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   GAS is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with GAS; see the file COPYING.  If not, write to
   the Free Software Foundation, 51 Franklin Street - Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* By convention, you should define this macro in the '.h' file. For example,
   'tc-m68k.h' defines TC_M68K. You might have to use this if it is necessary
   to add CPU specific code to the object format file. */
#define TC_SCARTS_32

/* A string to use on the header line of a listing. The default value
   is simply "GAS LISTING". */
#define LISTING_HEADER			"SCARTS_32 GAS LISTING"

/* This macro is the BFD target name to use when creating the output file.
   This will normally depend upon the OBJ_FMT macro. */
#define TARGET_FORMAT			"elf32-scarts_32"

/* This macro is the BFD architecture to pass to bfd_set_arch_mach. */
#define TARGET_ARCH			bfd_arch_scarts_32

/* This macro is the BFD machine number to pass to bfd_set_arch_mach.
   If it is not defined, GAS will use 0. */
extern unsigned long scarts_32_mach;
#define TARGET_MACH			(scarts_32_mach)

/* You should define this macro to be non-zero if the target is big endian,
   and zero if the target is little endian. */
#define TARGET_BYTES_BIG_ENDIAN		0

/* .-foo gets turned into PC relative relocs. */
#define DIFF_EXPR_OK			1

/* Permit temporary numeric labels. */
#define LOCAL_LABELS_FB			1

/* Values passed to md_apply_fix don't include the symbol value.  */
#define MD_APPLY_SYM_VALUE(FIX)		0

/* We don't need to handle .word strangely.  */
#define WORKING_DOT_WORD

/* GAS will call this for each fixup that passes the TC_VALIDATE_FIX test when
   linkrelax is not set. It should store the correct value in the object file.
   struct fix *fixP is the fixup md_apply_fix is operating on. valueT *valP is
   the value to store into the object files, or at least is the generic code's
   best guess. Specifically, *valP is the value of the fixup symbol, perhaps
   modified by MD_APPLY_SYM_VALUE, plus fixP->fx_offset (symbol addend), less
   MD_PCREL_FROM_SECTION for pc-relative fixups. segT seg is the section the
   fix is in. fixup_segment performs a generic overflow check on *valP after
   md_apply_fix returns. If the overflow check is relevant for the target
   machine, then md_apply_fix should modify *valP, typically to the value
   stored in the object file. */
#define md_apply_fix			scarts_32_md_apply_fix

/* This should just call either number_to_chars_bigendian or number_to_chars_
   littleendian, whichever is appropriate. On targets like the MIPS which
   support options to change the endianness, which function to call is a
   runtime decision. On other targets, md_number_to_chars can be a simple
   macro. */
#define md_number_to_chars		number_to_chars_littleendian

/* GAS will call this to generate a reloc. GAS will pass the resulting reloc to
   bfd_install_relocation. This currently works poorly, as bfd_install_relocation
   often does the wrong thing, and instances of tc_gen_reloc have been written
   to work around the problems, which in turns makes it difficult to fix
   bfd_install_relocation. */
#define tc_gen_reloc			gas_cgen_tc_gen_reloc

/* If this macro returns non-zero, it guarantees that a relocation will be emitted
   even when the value can be resolved locally, as fixup_segment tries to reduce
   the number of relocations emitted. For example, a fixup expression against an
   absolute symbol will normally not require a reloc. */

extern int scarts_32_force_relocation (struct fix *);
#define TC_FORCE_RELOCATION(FIX) scarts_32_force_relocation(FIX)

/* Call md_pcrel_from_section(), not md_pcrel_from().  */

/* If you define this macro, it should return the position from which the PC
   relative adjustment for a PC relative fixup should be made. On many
   processors, the base of a PC relative instruction is the next instruction,
   so this macro would return the length of an instruction, plus the address of
   the PC relative fixup. */
extern long md_pcrel_from_section (struct fix *, segT);
#define MD_PCREL_FROM_SECTION(FIX, SEC) md_pcrel_from_section(FIX, SEC)
