/*
 * Definitions for ELF program headers
 * Based on Portable Formats Specification v1.1
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#ifndef __ELFPRG_H__
#define __ELFPRG_H__

#include <l4/types.h>

struct elf_program_header {
	u32	p_type;		/* Type of segment */
	u32	p_offset;	/* Segment file offset */
	u32	p_vaddr;	/* Virtual start address */
	u32	p_paddr;	/* Physical start address */
	u32	p_filesz;	/* Size in stored file */
	u32	p_memsz;	/* Size in memory image */
	u32	p_flags;	/* Segment attributes */
	u32	p_align;	/* Alignment requirement */
} __attribute__((__packed__));

/* Program segment type definitions */
#define PT_NULL				0
#define PT_LOAD				1
#define PT_DYNAMIC			2
#define PT_INTERP			3
#define PT_NOTE				4
#define PT_SHLIB			5
#define PT_PHDR				6
#define PT_LOPROC			0x70000000
#define PT_HIPROC			0x7FFFFFFF


#endif /* __ELFPRG_H__ */
