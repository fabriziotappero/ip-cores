# This shell script emits a C file. -*- C -*-
#   Copyright 2006, 2007, 2008, 2009, 2011
#   Free Software Foundation, Inc.
#
# This file is part of the GNU Binutils.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
# MA 02110-1301, USA.


# This file is sourced from elf32.em, and defines extra open8-elf specific
# routines.

fragment <<EOF

#include "elf32-open8.h"
#include "ldctor.h"

/* The fake file and it's corresponding section meant to hold
   the linker stubs if needed.  */

static lang_input_statement_type *stub_file;
static asection *open8_stub_section;

/* Variables set by the command-line parameters and transfered
   to the bfd without use of global shared variables.  */

static bfd_boolean open8_no_stubs = FALSE;
static bfd_boolean open8_debug_relax = FALSE;
static bfd_boolean open8_debug_stubs = FALSE;
static bfd_boolean open8_replace_call_ret_sequences = TRUE;
static bfd_vma open8_pc_wrap_around = 0x10000000;

/* Transfers information to the bfd frontend.  */

static void
open8_elf_set_global_bfd_parameters (void)
{
  elf32_open8_setup_params (& link_info,
                          stub_file->the_bfd,
                          open8_stub_section,
                          open8_no_stubs,
                          open8_debug_stubs,
                          open8_debug_relax,
                          open8_pc_wrap_around,
                          open8_replace_call_ret_sequences);
}


/* Makes a conservative estimate of the trampoline section size that could
   be corrected later on.  */

static void
open8_elf_${EMULATION_NAME}_before_allocation (void)
{
  int ret;

  gld${EMULATION_NAME}_before_allocation ();

  /* No stubs support for the Open8 at this time.  */
  open8_no_stubs = TRUE;

  open8_elf_set_global_bfd_parameters ();

  /* If generating a relocatable output file, then
     we don't  have to generate the trampolines.  */
  if (link_info.relocatable)
    open8_no_stubs = TRUE;

  if (open8_no_stubs)
    return;

  ret = elf32_open8_setup_section_lists (link_info.output_bfd, &link_info);

  if (ret < 0)
    einfo ("%X%P: can not setup the input section list: %E\n");

  if (ret <= 0)
    return;

  /* Call into the BFD backend to do the real "stub"-work.  */
  if (! elf32_open8_size_stubs (link_info.output_bfd, &link_info, TRUE))
    einfo ("%X%P: can not size stub section: %E\n");
}

/* This is called before the input files are opened.  We create a new
   fake input file to hold the stub section and generate the section itself.  */

static void
open8_elf_create_output_section_statements (void)
{
  flagword flags;

  stub_file = lang_add_input_file ("linker stubs",
                                   lang_input_file_is_fake_enum,
                                   NULL);

  stub_file->the_bfd = bfd_create ("linker stubs", link_info.output_bfd);
  if (stub_file->the_bfd == NULL
      || !bfd_set_arch_mach (stub_file->the_bfd,
                             bfd_get_arch (link_info.output_bfd),
                             bfd_get_mach (link_info.output_bfd)))
    {
      einfo ("%X%P: can not create stub BFD %E\n");
      return;
    }

  /* Now we add the stub section.  */

  flags = (SEC_ALLOC | SEC_LOAD | SEC_READONLY | SEC_CODE
           | SEC_HAS_CONTENTS | SEC_RELOC | SEC_IN_MEMORY | SEC_KEEP);
  open8_stub_section = bfd_make_section_anyway_with_flags (stub_file->the_bfd,
							 ".trampolines",
							 flags);
  if (open8_stub_section == NULL)
    goto err_ret;

  open8_stub_section->alignment_power = 1;

  ldlang_add_file (stub_file);

  return;

  err_ret:
   einfo ("%X%P: can not make stub section: %E\n");
   return;
}

/* Re-calculates the size of the stubs so that we won't waste space.  */

static void
open8_elf_after_allocation (void)
{
  if (!open8_no_stubs && ! RELAXATION_ENABLED)
    {
      /* If relaxing, elf32_open8_size_stubs will be called from
	 elf32_open8_relax_section.  */
      if (!elf32_open8_size_stubs (link_info.output_bfd, &link_info, FALSE))
	einfo ("%X%P: can not size stub section: %E\n");
    }

  gld${EMULATION_NAME}_after_allocation ();

  /* Now build the linker stubs.  */
  if (!open8_no_stubs)
    {
      if (!elf32_open8_build_stubs (&link_info))
	einfo ("%X%P: can not build stubs: %E\n");
    }
}


EOF


PARSE_AND_LIST_PROLOGUE='

#define OPTION_NO_CALL_RET_REPLACEMENT 301
#define OPTION_PMEM_WRAP_AROUND        302
#define OPTION_NO_STUBS                303
#define OPTION_DEBUG_STUBS             304
#define OPTION_DEBUG_RELAX             305
'

PARSE_AND_LIST_LONGOPTS='
  { "no-call-ret-replacement", no_argument,
     NULL, OPTION_NO_CALL_RET_REPLACEMENT},
  { "pmem-wrap-around", required_argument,
    NULL, OPTION_PMEM_WRAP_AROUND},
  { "no-stubs", no_argument,
    NULL, OPTION_NO_STUBS},
  { "debug-stubs", no_argument,
    NULL, OPTION_DEBUG_STUBS},
  { "debug-relax", no_argument,
    NULL, OPTION_DEBUG_RELAX},
'

PARSE_AND_LIST_OPTIONS='
  fprintf (file, _("  --no-call-ret-replacement   "
		   "The relaxation machine normally will\n"
		   "                              "
		   "  substitute two immediately following call/ret\n"
		   "                              "
		   "  instructions by a single jump instruction.\n"
		   "                              "
		   "  This option disables this optimization.\n"));
  fprintf (file, _("  --debug-stubs               "
		   "Used for debugging open8-ld.\n"));
  fprintf (file, _("  --debug-relax               "
		   "Used for debugging open8-ld.\n"));
'

PARSE_AND_LIST_ARGS_CASES='

    case OPTION_PMEM_WRAP_AROUND:
      {
        /* This variable is defined in the bfd library.  */
        if ((!strcmp (optarg,"32k"))      || (!strcmp (optarg,"32K")))
          open8_pc_wrap_around = 32768;
        else if ((!strcmp (optarg,"8k")) || (!strcmp (optarg,"8K")))
          open8_pc_wrap_around = 8192;
        else if ((!strcmp (optarg,"16k")) || (!strcmp (optarg,"16K")))
          open8_pc_wrap_around = 16384;
        else if ((!strcmp (optarg,"64k")) || (!strcmp (optarg,"64K")))
          open8_pc_wrap_around = 0x10000;
        else
          return FALSE;
      }
      break;

    case OPTION_DEBUG_STUBS:
      open8_debug_stubs = TRUE;
      break;

    case OPTION_DEBUG_RELAX:
      open8_debug_relax = TRUE;
      break;

    case OPTION_NO_STUBS:
      open8_no_stubs = TRUE;
      break;

    case OPTION_NO_CALL_RET_REPLACEMENT:
      {
        /* This variable is defined in the bfd library.  */
        open8_replace_call_ret_sequences = FALSE;
      }
      break;
'

#
# Put these extra open8-elf routines in ld_${EMULATION_NAME}_emulation
#
LDEMUL_BEFORE_ALLOCATION=open8_elf_${EMULATION_NAME}_before_allocation
LDEMUL_AFTER_ALLOCATION=open8_elf_after_allocation
LDEMUL_CREATE_OUTPUT_SECTION_STATEMENTS=\
open8_elf_create_output_section_statements
