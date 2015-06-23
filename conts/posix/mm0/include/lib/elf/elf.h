/*
 * Definitions for Executable Linking Format
 * Based on Portable Formats Specification v1.1
 *
 * Copyright (C) 2008 Bahadir Balban
 */

#ifndef __ELF_H__
#define __ELF_H__

#include <l4/types.h>

/* ELF identification indices */
#define EI_MAG0		0
#define EI_MAG1		1
#define EI_MAG2		2
#define EI_MAG3		3
#define EI_CLASS	4
#define EI_DATA		5
#define EI_VERSION	6
#define EI_PAD		7

/* Size of ELF identification field */
#define EI_NIDENT	16

/* Values for ELF identification fields */
#define ELFMAG0		0x7f
#define ELFMAG1		'E'
#define ELFMAG2		'L'
#define ELFMAG3		'F'

/* Values for the ELF Class field */
#define ELFCLASSNONE	0
#define ELFCLASS32	1
#define ELFCLASS64	2

/* Values for the ELF Data field */
#define ELFDATANONE	0
#define ELFDATA2LSB	1
#define ELFDATA2MSB	2


struct elf_header {
	u8 	e_ident[EI_NIDENT];	/* ELF identification */
	u16	e_type;			/* Object file type */
	u16	e_machine;		/* Machine architecture */
	u32	e_version;		/* Object file version */
	u32	e_entry;		/* Virtual entry address */
	u32	e_phoff;		/* Program header offset */
	u32	e_shoff;		/* Section header offset */
	u32	e_flags;		/* Processor specific flags */
	u16	e_ehsize;		/* ELF header size */
	u16	e_phentsize;		/* Program header entry size */
	u16	e_phnum;		/* Number of program headers */
	u16	e_shentsize;		/* Section header entry size */
	u16	e_shnum;		/* Number of section headers */
	u16	e_shstrndx;		/* Shtable index for strings */
} __attribute__((__packed__));


int elf_parse_executable(struct tcb *task, struct vm_file *file,
			 struct exec_file_desc *efd);

#endif /* __ELF_H__ */
