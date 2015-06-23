/*
 * Definitions for ELF Sections
 * Based on Portable Formats Specification v1.1
 *
 * Copyright (C) 2008 Bahadir Balban
 */

#ifndef __ELFSECT_H__
#define __ELFSECT_H__

#include <l4/types.h>

/* Special section indices */
#define SHN_UNDEF			0
#define SHN_LORESERVE			0xFF00
#define SHN_LOPROC			0xFF00
#define SHN_HIPROC			0xFF1F
#define SHN_ABS				0xFFF1
#define SHN_COMMON			0xFFF2
#define SHN_HIRESERVE			0xFFFF


struct elf_section_header {
	u32	sh_name;	/* Index to section header str table for name */
	u32	sh_type;	/* Categorises section's semantics */
	u32	sh_flags;	/* Flags that define various attributes */
	u32	sh_addr;	/* Virtual address for section */
	u32	sh_offset;	/* Offset to contents from file beginning */
	u32	sh_size;	/* Size of section (note SHT_NOBITS) */
	u32	sh_link;
	u32	sh_info;	/* Extra section info */
	u32	sh_addralign;	/* Section alignment in power of 2 */
	u32	sh_entsize;	/* Size of each entry if fixed */
} __attribute__((__packed__));

/* Section type codes */
#define SHT_NULL			0	/* Inactive */
#define SHT_PROGBITS			1	/* Program contents */
#define SHT_SYMTAB			2	/* Symbol table */
#define SHT_STRTAB			3	/* String table */
#define SHT_RELA			4	/* Relocation entries */
#define SHT_HASH			5	/* Symbol hash table */
#define SHT_DYNAMIC			6	/* Dynamic linking info */
#define SHT_NOTE			7	/* Optional, additional info */
#define SHT_NOBITS			8	/* Does not occupy file space */
#define SHT_REL				9	/* Relocation entries */
#define SHT_SHLIB			10	/* Reserved */
#define SHT_DYNSYM			11	/* Symbols for dynamic linking */
#define SHT_LOPROC		0x70000000	/* Reserved for processors */
#define SHT_HIPROC		0x7FFFFFFF	/* Reserved for processors */
#define SHT_LOUSER		0x80000000	/* Reserved for user progs */
#define SHT_HIUSER		0xFFFFFFFF	/* Reserved for user progs */

/* Section attribute flags */
#define SHF_WRITE		(1 << 0)	/* Writeable */
#define SHF_ALLOC		(1 << 1)	/* Occupies actual memory */
#define SHF_EXECINSTR		(1 << 2)	/* Executable */
#define SHF_MASCPROC		0xF0000000	/* Reserved for processors */

#endif /* __ELFSECT_H__ */
