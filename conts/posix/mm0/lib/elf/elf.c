/*
 * ELF manipulation routines
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <memory.h>
#include <vm_area.h>
#include <l4/api/errno.h>
#include <lib/elf/elf.h>
#include <lib/elf/elfprg.h>
#include <lib/elf/elfsym.h>
#include <lib/elf/elfsect.h>


int elf_probe(struct elf_header *header)
{
	/* Test that it is a 32-bit little-endian ELF file */
	if (header->e_ident[EI_MAG0] == ELFMAG0 &&
	    header->e_ident[EI_MAG1] == ELFMAG1 &&
	    header->e_ident[EI_MAG2] == ELFMAG2 &&
	    header->e_ident[EI_MAG3] == ELFMAG3 &&
	    header->e_ident[EI_CLASS] == ELFCLASS32 &&
	    header->e_ident[EI_DATA] == ELFDATA2LSB)
		return 0;
	else
		return -1;
}

/*
 * Sets or expands a segment region if it has the given type and flags
 * For expansion we assume any new section must come consecutively
 * after the existing segment, otherwise we ignore it for simplicity.
 */
int elf_test_expand_segment(struct elf_section_header *section,
			    unsigned int sec_type, unsigned int sec_flags,
			    unsigned int sec_flmask, unsigned long *start,
			    unsigned long *end, unsigned long *offset)
{
	if (section->sh_type == sec_type &&
	    (section->sh_flags & sec_flmask) == sec_flags) {
		/* Set new section */
		if (!*start) {
			BUG_ON(*offset || *end);
			*offset = section->sh_offset;
			*start = section->sh_addr;
			*end = section->sh_addr + section->sh_size;
		/* Expand existing section from the end */
		} else if (*end == section->sh_addr)
			*end = section->sh_addr + section->sh_size;
	}

	return 0;
}

/*
 * Sift through sections and copy their marks to tcb and efd
 * if they are recognised and loadable sections. Test the
 * assigned segment marks and return an error if they're invalid.
 */
int elf_mark_segments(struct elf_section_header *sect_header, int nsections,
		      struct tcb *task, struct exec_file_desc *efd)
{
	for (int i = 0; i < nsections; i++) {
		struct elf_section_header *section = &sect_header[i];

		/* Text + read-only data segments */
		elf_test_expand_segment(section, SHT_PROGBITS,
					SHF_ALLOC, SHF_ALLOC | SHF_WRITE,
					&task->text_start, &task->text_end,
					&efd->text_offset);

		/* Data segment */
		elf_test_expand_segment(section, SHT_PROGBITS, SHF_ALLOC |
					SHF_WRITE, SHF_ALLOC | SHF_WRITE,
					&task->data_start, &task->data_end,
					&efd->data_offset);

		/* Bss segment */
		elf_test_expand_segment(section, SHT_NOBITS, SHF_ALLOC |
					SHF_WRITE, SHF_ALLOC | SHF_WRITE,
					&task->bss_start, &task->bss_end,
					&efd->bss_offset);
	}

	/* Test anomalies with the mappings */

	/* No text */
	if (!task->text_start) {
		printf("%s: Error: Could not find a text "
		       "segment in ELF file.\n", __FUNCTION__);
		return -ENOEXEC;
	}

	/* Warn if no data or bss but it's not an error */
	if (!task->data_start || !task->bss_start) {
		printf("%s: NOTE: Could not find a data and/or "
		       "bss segment in ELF file.\n", __FUNCTION__);
	}

	/* Data and text are on the same page and not on a page boundary */
	if (!((is_page_aligned(task->data_start) &&
	      task->data_start == task->text_end) ||
	      (page_align(task->data_start) > page_align(task->text_end))))
	if ((task->data_start - task->text_end) < PAGE_SIZE &&
	    !is_page_aligned(task->text_end)) {
		printf("%s: Error: Distance between data and text"
		       " sections are less than page size (%d bytes)\n",
		       __FUNCTION__, PAGE_SIZE);
		return -ENOEXEC;
	}

	return 0;
}

/*
 * Loading an ELF file:
 *
 * This first probes and detects that the given file is a valid elf file.
 * Then it looks at the program header table to find the first (probably
 * only) segment that has type LOAD. Then it looks at the section header
 * table, to find out about every loadable section that is part of this
 * aforementioned loadable program segment. Each section is marked in the
 * efd and tcb structures for further memory mappings.
 */
int elf_parse_executable(struct tcb *task, struct vm_file *file,
			 struct exec_file_desc *efd)
{
	struct elf_header elf_header, *elf_headerp = pager_map_page(file, 0);
	struct elf_program_header *prg_header_start, *prg_header_load;
	struct elf_section_header *sect_header;
	unsigned long sect_offset, sect_size;
	unsigned long prg_offset, prg_size;
	int err = 0;

	/* Test that it is a valid elf file */
	if ((err = elf_probe(elf_headerp)) < 0)
		return err;

	/* Copy the elf header and unmap first page */
	memcpy(&elf_header, elf_headerp, sizeof(elf_header));
	pager_unmap_page(elf_headerp);

	/* Find the markers for section and program header tables */
	sect_offset = elf_header.e_shoff;
	sect_size = elf_header.e_shentsize * elf_header.e_shnum;

	prg_offset = elf_header.e_phoff;
	prg_size = elf_header.e_phentsize * elf_header.e_phnum;

	/* Get the program header table */
	prg_header_start = (struct elf_program_header *)
			   pager_map_file_range(file, prg_offset, prg_size);

	/* Get the first loadable segment. We currently just stare at it */
	for (int i = 0; i < elf_header.e_phnum; i++) {
		if (prg_header_start[i].p_type == PT_LOAD) {
			prg_header_load = &prg_header_start[i];
			break;
		}
	}

	/* Get the section header table */
	sect_header = (struct elf_section_header *)
		      pager_map_file_range(file, sect_offset, sect_size);

	/* Copy segment marks from ELF file to task + efd. Return errors */
	err = elf_mark_segments(sect_header, elf_header.e_shnum, task, efd);

	/* Unmap program header table */
	pager_unmap_pages(prg_header_start, __pfn(page_align_up(prg_size)));

	/* Unmap section header table */
	pager_unmap_pages(sect_header, __pfn(page_align_up(sect_size)));

	return err;
}

