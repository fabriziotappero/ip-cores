/*
 * Definitions for ELF Symbol tables, symbols
 * Based on Portable Formats Specification v1.1
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#ifndef __ELFSYM_H__
#define __ELFSYM_H__

#include <l4/types.h>

struct elf_symbol_entry {
	u32	st_name;	/* Index into string table */
	u32	st_value;	/* Symbol value; address, aboslute etc. */
	u32	st_size;	/* Number of bytes contained in object */
	u8	st_info;	/* Type and binding attributes */
	u8	st_other;	/* Unused, 0 */
	u16	st_shndx;	/* Section header index associated with entry */
} __attribute__((__packed__));

/* To manipulate binding and type attributes on st_info field */
#define ELF32_ST_BIND(i)	((i) >> 4)
#define ELF32_ST_TYPE(i)	((i) & 0xF)
#define ELF32_ST_INFO(b, t)	(((b) << 4) + ((t) & 0xF))

/* Symbol binding codes */
#define STB_LOCAL		0
#define STB_GLOBAL		1
#define STB_WEAK		2
#define STB_LOPROC		13
#define STB_HIPROC		15

/* Symbol types */
#define STT_NOTYPE		0
#define STT_OBJECT		1
#define STT_FUNC		2
#define STT_SECTION		3
#define STT_FILE		4
#define STT_LOPROC		13
#define STT_HIPROC		15

/* Relocation structures */
struct elf_rel {
	u32	r_offset;
	u32	r_info;
} __attribute__((__packed__));

struct elf_rela {
	u32	r_offset;
	u32	r_info;
	s32	r_addend;
} __attribute__((__packed__));

/* Macros to manipulate r_info field */
#define ELF32_R_SYM(i)			((i) >> 8)
#define ELF32_R_TYPE(i)			((u8)(i))
#define ELF32_R_INFO(s,t)		(((s) << 8) + (u8)(t))

#endif /* __ELFSYM_H__ */
