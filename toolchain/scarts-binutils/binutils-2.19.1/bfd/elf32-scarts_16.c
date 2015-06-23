/* SCARTS_16-specific support for 32-bit ELF
   Copyright 2008, 2009 Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of BFD, the Binary File Descriptor library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

#include "sysdep.h"
#include "bfd.h"
#include "bfdlink.h"
#include "libbfd.h"
#include "elf-bfd.h"
#include "elf/scarts_16.h"
#include "libiberty.h"


static reloc_howto_type scarts_16_elf_howto_table[] =
{
  /* No relocation. */
  HOWTO (R_SCARTS_16_NONE,		/* type */
	 0,				/* rightshift */
	 1,				/* size (0 = byte, 1 = short, 2 = long) */
	 16,				/* bitsize */
	 FALSE,				/* pc_relative */
	 0,				/* bitpos */
	 complain_overflow_bitfield,	/* complain_on_overflow */
	 bfd_elf_generic_reloc,		/* special_function */
	 "R_SCARTS_16_NONE",		/* name */
	 FALSE,				/* partial_inplace */
	 0,				/* src_mask */
	 0,				/* dst_mask */
	 FALSE),			/* pcrel_offset */

  /* A 16-bit absolute relocation. */
  HOWTO (R_SCARTS_16_16,                  /* type */
         0,                             /* rightshift */
         1,                             /* size (0 = byte, 1 = short, 2 = long) */
         16,                            /* bitsize */
         FALSE,                         /* pc_relative */
         0,                             /* bitpos */
         complain_overflow_bitfield,    /* complain_on_overflow */
         bfd_elf_generic_reloc,         /* special_function */
         "R_SCARTS_16_16",                /* name */
         FALSE,                         /* partial_inplace */
         0,                             /* src_mask */
         0xFFFF,                        /* dst_mask */
         FALSE),                        /* pcrel_offset */

  /* A 32-bit absolute relocation. */
  HOWTO (R_SCARTS_16_32,                  /* type */
         0,                             /* rightshift */
         2,                             /* size (0 = byte, 1 = short, 2 = long) */
         32,                            /* bitsize */
         FALSE,                         /* pc_relative */
         0,                             /* bitpos */
         complain_overflow_bitfield,    /* complain_on_overflow */
         bfd_elf_generic_reloc,         /* special_function */
         "R_SCARTS_16_32",                /* name */
         FALSE,                         /* partial_inplace */
         0,                             /* src_mask */
         0xFFFFFFFF,                    /* dst_mask */
         FALSE),                        /* pcrel_offset */

  /* A first byte absolute relocation of 16-bit address. */
  HOWTO (R_SCARTS_16_LO,			/* type */
	 0,				/* rightshift */
	 1,				/* size (0 = byte, 1 = short, 2 = long) */
	 8,				/* bitsize */
	 FALSE,				/* pc_relative */
	 4,				/* bitpos */
	 complain_overflow_dont,	/* complain_on_overflow */
	 bfd_elf_generic_reloc,		/* special_function */
	 "R_SCARTS_16_LO",		/* name */
	 FALSE,				/* partial_inplace */
	 0,				/* src_mask */
	 0xFF0,				/* dst_mask */
	 FALSE),			/* pcrel_offset */

  /* A second byte absolute relocation of 16-bit address. */
  HOWTO (R_SCARTS_16_HI,			/* type */
	 8,				/* rightshift */
	 1,				/* size (0 = byte, 1 = short, 2 = long) */
	 8,				/* bitsize */
	 FALSE,				/* pc_relative */
	 4,				/* bitpos */
	 complain_overflow_dont,	/* complain_on_overflow */
	 bfd_elf_generic_reloc,		/* special_function */
	 "R_SCARTS_16_HI",		/* name */
	 FALSE,				/* partial_inplace */
	 0,				/* src_mask */
	 0xFF0,				/* dst_mask */
	 FALSE),			/* pcrel_offset */

  /* A signed pc-relative relocation of 10-bit address. */
  HOWTO (R_SCARTS_16_PCREL_10,		/* type */
	 1,				/* rightshift */
	 1,				/* size (0 = byte, 1 = short, 2 = long) */
	 10,				/* bitsize */
	 TRUE,				/* pc_relative */
	 0,				/* bitpos */
	 complain_overflow_bitfield,	/* complain_on_overflow */
	 bfd_elf_generic_reloc,		/* special_function */
	 "R_SCARTS_16_PCREL_10",		/* name */
	 FALSE,				/* partial_inplace */
	 0,				/* src_mask */
	 0x3FF,				/* dst_mask */
	 FALSE),			/* pcrel_offset */

  /* GNU extension to record C++ vtable hierarchy. */
  HOWTO (R_SCARTS_16_GNU_VTINHERIT,	/* type */
	 0,				/* rightshift */
	 1,				/* size (0 = byte, 1 = short, 2 = long) */
	 0,				/* bitsize */
	 FALSE,				/* pc_relative */
	 0,				/* bitpos */
	 complain_overflow_dont,	/* complain_on_overflow */
	 NULL,				/* special_function */
	 "R_SCARTS_16_GNU_VTINHERIT",	/* name */
	 FALSE,				/* partial_inplace */
	 0,				/* src_mask */
	 0,				/* dst_mask */
	 FALSE),			/* pcrel_offset */

  /* GNU extension to record C++ vtable member usage. */
  HOWTO (R_SCARTS_16_GNU_VTENTRY,		/* type */
	 0,				/* rightshift */
	 1,				/* size (0 = byte, 1 = short, 2 = long) */
	 0,				/* bitsize */
	 FALSE,				/* pc_relative */
	 0,				/* bitpos */
	 complain_overflow_dont,	/* complain_on_overflow */
	 _bfd_elf_rel_vtable_reloc_fn,	/* special_function */
	 "R_SCARTS_16_GNU_VTENTRY",	/* name */
	 FALSE,				/* partial_inplace */
	 0,				/* src_mask */
	 0,				/* dst_mask */
	 FALSE),			/* pcrel_offset */
};

/* Map BFD reloc types to SCARTS_16 ELF reloc types.  */

struct scarts_16_reloc_map
{
  bfd_reloc_code_real_type bfd_reloc_val;
  unsigned int scarts_16_reloc_val;
};

static const struct scarts_16_reloc_map scarts_16_reloc_map[] =
{
  { BFD_RELOC_NONE,		R_SCARTS_16_NONE },
  { BFD_RELOC_16,		R_SCARTS_16_16 },
  { BFD_RELOC_32,		R_SCARTS_16_32 },
  { BFD_RELOC_SCARTS_16_LO,	R_SCARTS_16_LO },
  { BFD_RELOC_SCARTS_16_HI,	R_SCARTS_16_HI },
  { BFD_RELOC_SCARTS_16_PCREL_10,	R_SCARTS_16_PCREL_10 },
  { BFD_RELOC_VTABLE_INHERIT,	R_SCARTS_16_GNU_VTINHERIT },
  { BFD_RELOC_VTABLE_ENTRY, 	R_SCARTS_16_GNU_VTENTRY }
};

static reloc_howto_type *
scarts_16_reloc_type_lookup(bfd *abfd ATTRIBUTE_UNUSED, bfd_reloc_code_real_type code)
{
  unsigned int i;
  
  for (i = ARRAY_SIZE(scarts_16_reloc_map); --i;)
    if (scarts_16_reloc_map[i].bfd_reloc_val == code)
      return &scarts_16_elf_howto_table[scarts_16_reloc_map[i].scarts_16_reloc_val];

  return NULL;
}

static reloc_howto_type *
scarts_16_reloc_name_lookup(bfd *abfd ATTRIBUTE_UNUSED, const char *r_name)
{
  unsigned int i;
  
  for (i = 0; i < (sizeof(scarts_16_elf_howto_table) / sizeof(scarts_16_elf_howto_table[0])); i++)
    if (scarts_16_elf_howto_table[i].name != NULL && strcasecmp(scarts_16_elf_howto_table[i].name, r_name) == 0)
      return &scarts_16_elf_howto_table[i];
  
  return NULL;
}

/* Look through the relocs for a section during the first phase.
   Since we don't do .gots or .plts, we just need to consider the
   virtual table relocs for gc. */

static bfd_boolean
scarts_16_elf_check_relocs(bfd *abfd, struct bfd_link_info *info, asection *sec, const Elf_Internal_Rela *relocs)
{
  Elf_Internal_Shdr *symtab_hdr;
  struct elf_link_hash_entry **sym_hashes, **sym_hashes_end;
  const Elf_Internal_Rela *rel;
  const Elf_Internal_Rela *rel_end;
  
  if (info->relocatable)
    return TRUE;
  
  symtab_hdr = &elf_tdata(abfd)->symtab_hdr;
  sym_hashes = elf_sym_hashes(abfd);
  sym_hashes_end = sym_hashes + symtab_hdr->sh_size / sizeof(Elf32_External_Sym);
  if (!elf_bad_symtab(abfd))
    sym_hashes_end -= symtab_hdr->sh_info;
  
  rel_end = relocs + sec->reloc_count;
  for (rel = relocs; rel < rel_end; rel++)
  {
    struct elf_link_hash_entry *h;
    unsigned long r_symndx;
    
    r_symndx = ELF32_R_SYM(rel->r_info);
    if (r_symndx < symtab_hdr->sh_info)
      h = NULL;
    else
    {
      h = sym_hashes[r_symndx - symtab_hdr->sh_info];
      
      while (h->root.type == bfd_link_hash_indirect || h->root.type == bfd_link_hash_warning)
        h = (struct elf_link_hash_entry *) h->root.u.i.link;
    }
    
    switch (ELF32_R_TYPE(rel->r_info))
    {
        /* This relocation describes the C++ object vtable hierarchy.
	   Reconstruct it for later use during GC. */
        case R_SCARTS_16_GNU_VTINHERIT:
          if (!bfd_elf_gc_record_vtinherit(abfd, sec, h, rel->r_offset))
            return FALSE;
          break;

        /* This relocation describes which C++ vtable entries are actually used.
	   Record for later use during GC. */
        case R_SCARTS_16_GNU_VTENTRY:
          if (!bfd_elf_gc_record_vtentry(abfd, sec, h, rel->r_addend))
            return FALSE;
        break;
    }
  }
  
  return TRUE;
}

/* Perform a single relocation. By default we use the standard BFD
   routines, but a few relocs, we have to do them ourselves. */

static bfd_reloc_status_type
scarts_16_final_link_relocate(reloc_howto_type *howto, bfd *input_bfd, asection *input_section, bfd_byte *contents, Elf_Internal_Rela *rel, bfd_vma relocation, asection *symbol_section)
{
  bfd_reloc_status_type r = bfd_reloc_ok;

  switch (howto->type)
  {
    case R_SCARTS_16_16:
    case R_SCARTS_16_32:
    case R_SCARTS_16_LO:
    case R_SCARTS_16_HI:
      if (input_section != NULL && ((input_section->flags & SEC_CODE) | (input_section->flags & SEC_DATA))
       && symbol_section != NULL && (symbol_section->flags & SEC_CODE))
      {
        relocation >>= 1;
        rel->r_addend >>= 1;
      }

    default:
      r = _bfd_final_link_relocate(howto, input_bfd, input_section, contents, rel->r_offset, relocation, rel->r_addend);
      break;
  }

  return r;
}

/* Store the machine number in the flags field. */

static void
scarts_16_elf_final_write_processing(bfd *abfd, bfd_boolean linker ATTRIBUTE_UNUSED)
{
  unsigned long val;
  
  switch (bfd_get_mach(abfd))
  {
    default:
      val = E_SCARTS_16_MACH;
      break;
  }
  
  elf_elfheader(abfd)->e_machine = EM_SCARTS_16;
  elf_elfheader(abfd)->e_flags &= ~EF_SCARTS_16_MACH;
  elf_elfheader(abfd)->e_flags |= val;
}

/* Return the section that should be marked against GC for a given relocation. */

static asection *
scarts_16_elf_gc_mark_hook (asection *sec, struct bfd_link_info *info ATTRIBUTE_UNUSED, Elf_Internal_Rela * rel, struct elf_link_hash_entry *h, Elf_Internal_Sym *sym)
{
  if (h != NULL)
  {
    switch (ELF32_R_TYPE(rel->r_info))
    {
      case R_SCARTS_16_GNU_VTINHERIT:
      case R_SCARTS_16_GNU_VTENTRY:
        return NULL;
    }
  }

  return _bfd_elf_gc_mark_hook (sec, info, rel, h, sym);
}

/* Update the got entry reference counts for the section being removed. */

static bfd_boolean
scarts_16_elf_gc_sweep_hook(bfd *abfd ATTRIBUTE_UNUSED, struct bfd_link_info *info ATTRIBUTE_UNUSED, asection *sec ATTRIBUTE_UNUSED, const Elf_Internal_Rela *relocs ATTRIBUTE_UNUSED)
{
  return TRUE;
}

/* Set the right machine number. */

static bfd_boolean
scarts_16_elf_object_p(bfd *abfd)
{
  unsigned int e_set = bfd_mach_scarts_16;
  
  if (elf_elfheader(abfd)->e_machine == EM_SCARTS_16)
  {
    int e_mach = elf_elfheader(abfd)->e_flags & EF_SCARTS_16_MACH;
    switch (e_mach)
    {
      default:
        e_set = bfd_mach_scarts_16;
        break;
    }
  }
  
  return bfd_default_set_arch_mach(abfd, bfd_arch_scarts_16, e_set);
}

/* Relocate a SCARTS_16 ELF section. */

static bfd_boolean
scarts_16_elf_relocate_section(bfd *output_bfd, struct bfd_link_info *info, bfd *input_bfd, asection *input_section, bfd_byte *contents, Elf_Internal_Rela *relocs, Elf_Internal_Sym *local_syms, asection **local_sections)
{
  Elf_Internal_Shdr *symtab_hdr;
  struct elf_link_hash_entry **sym_hashes;
  Elf_Internal_Rela *rel;
  Elf_Internal_Rela *relend;
  
  symtab_hdr = &elf_tdata(input_bfd)->symtab_hdr;
  sym_hashes = elf_sym_hashes(input_bfd);
  relend = relocs + input_section->reloc_count;
  
  for (rel = relocs; rel < relend; rel++)
  {
    reloc_howto_type *howto;
    unsigned long r_symndx;
    Elf_Internal_Sym *sym;
    asection *sec;
    struct elf_link_hash_entry *h;
    bfd_vma relocation;
    bfd_reloc_status_type r;
    const char *name = NULL;
    int r_type;
    
    r_type = ELF32_R_TYPE(rel->r_info);
    r_symndx = ELF32_R_SYM(rel->r_info);
    howto = scarts_16_elf_howto_table + ELF32_R_TYPE(rel->r_info);
    h = NULL;
    sym = NULL;
    sec = NULL;
    
    if (r_type == R_SCARTS_16_GNU_VTINHERIT || r_type == R_SCARTS_16_GNU_VTENTRY)
      continue;
    
    if ((unsigned int) r_type > (sizeof scarts_16_elf_howto_table / sizeof(reloc_howto_type)))
      abort();
    
    if (r_symndx < symtab_hdr->sh_info)
    {
      sym = local_syms + r_symndx;
      sec = local_sections[r_symndx];
      relocation = _bfd_elf_rela_local_sym(output_bfd, sym, &sec, rel);
      
      name = bfd_elf_string_from_elf_section(input_bfd, symtab_hdr->sh_link, sym->st_name);
      name = (name == NULL) ? bfd_section_name(input_bfd, sec) : name;
    }
    else
    {
      bfd_boolean unresolved_reloc, warned;
      RELOC_FOR_GLOBAL_SYMBOL(info, input_bfd, input_section, rel, r_symndx, symtab_hdr, sym_hashes, h, sec, relocation, unresolved_reloc, warned);
    }
    
    if (sec != NULL && elf_discarded_section(sec))
    {
      /* For relocs against symbols from removed linkonce sections,
         or sections discarded by a linker script, we just want the
         section contents zeroed.  Avoid any special processing. */
      _bfd_clear_contents(howto, input_bfd, contents + rel->r_offset);
      rel->r_info = 0;
      rel->r_addend = 0;
      continue;
    }
    
    if (info->relocatable)
      continue;
    
    r = scarts_16_final_link_relocate(howto, input_bfd, input_section, contents, rel, relocation, sec);
    if (r != bfd_reloc_ok)
    {
      const char *msg = NULL;
      
      switch (r)
      {
        case bfd_reloc_overflow:
          r = info->callbacks->reloc_overflow(info, (h ? &h->root : NULL), name, howto->name, (bfd_vma) 0, input_bfd, input_section, rel->r_offset);
          break;
        
        case bfd_reloc_undefined:
          r = info->callbacks->undefined_symbol(info, name, input_bfd, input_section, rel->r_offset, TRUE);
          break;
          
        case bfd_reloc_outofrange:
          msg = _("internal error: out of range error");
          break;
        
        case bfd_reloc_notsupported:
          msg = _("internal error: unsupported relocation error");
          break;
        
        case bfd_reloc_dangerous:
          msg = _("internal error: dangerous relocation");
          break;
        
        default:
          msg = _("internal error: unknown error");
          break;
      }
      
      if (msg)
        r = info->callbacks->warning(info, msg, name, input_bfd, input_section, rel->r_offset);
      
      if (!r)
        return FALSE;
    }
  }
  
  return TRUE;
}

/* Set the howto pointer for a SCARTS_16 ELF reloc.  */

static void
scarts_16_info_to_howto_rela(bfd *abfd ATTRIBUTE_UNUSED, arelent *cache_ptr, Elf_Internal_Rela *dst)
{
  unsigned int r_type;
  
  r_type = ELF32_R_TYPE(dst->r_info);
  BFD_ASSERT(r_type < (unsigned int) R_SCARTS_16_max);
  cache_ptr->howto = &scarts_16_elf_howto_table[r_type];
}


#define ELF_ARCH			bfd_arch_scarts_16
#define ELF_MACHINE_CODE		EM_SCARTS_16
#define ELF_MAXPAGESIZE			1

#define TARGET_LITTLE_SYM		bfd_elf32_scarts_16_vec
#define TARGET_LITTLE_NAME		"elf32-scarts_16"

#undef  elf_backend_post_process_headers

#define elf_backend_can_gc_sections	1
#define elf_backend_rela_normal		1

#define bfd_elf32_bfd_reloc_type_lookup		scarts_16_reloc_type_lookup
#define bfd_elf32_bfd_reloc_name_lookup		scarts_16_reloc_name_lookup
#define elf_backend_check_relocs		scarts_16_elf_check_relocs
#define elf_backend_final_write_processing	scarts_16_elf_final_write_processing
#define elf_backend_gc_mark_hook		scarts_16_elf_gc_mark_hook
#define elf_backend_gc_sweep_hook		scarts_16_elf_gc_sweep_hook
#define elf_backend_object_p			scarts_16_elf_object_p
#define elf_backend_relocate_section		scarts_16_elf_relocate_section
#define elf_info_to_howto_rel			NULL
#define elf_info_to_howto			scarts_16_info_to_howto_rela

#include "elf32-target.h"

