#include <elf/elf.h>
#include <elf/elf32.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arch.h"

/* These symbols are defined by the linker script. */
extern char _start_kernel[];
extern char _end_kernel[];
extern char _start_containers[];
extern char _end_containers[];

/* This is a kernel symbol exported to loader's linker script from kernel build */
extern char bkpt_phys_to_virt[];

int load_elf_image(unsigned long **entry, void *filebuf);

/*
 * Given a section that is a valid elf file, look for sections
 * and recognise special .img.[0-9] section name and run
 * load_elf_image on it.
 */
int load_container_image(void *cont_section)
{
	struct Elf32_Header *elf_header = (struct Elf32_Header *)cont_section;
	struct Elf32_Shdr *sect_header;
	int nsect;
	int nimgs = 0;
	unsigned long *image_entry;

	if (elf32_checkFile(elf_header) < 0) {
		printf("%s: Not a valid elf image.\n", __FUNCTION__);
		return -1;
	}

	sect_header = elf32_getSectionTable(elf_header);
	nsect = elf32_getNumSections(elf_header);

	for (int i = 0; i < nsect; i++) {
		char *sectname = elf32_getSectionName(elf_header, i);
		if (!strncmp(sectname, ".img.", strlen(".img."))) {
			printf("Loading %s section image...\n", sectname);
			load_elf_image(&image_entry, elf32_getSection(elf_header, i));
			nimgs++;
		}
	}
	printf("Total of %d images in this container.\n", nimgs);
	return 0;

}

/*
 * From a given offset, recognise special .cont.[0-9] section name
 * and run load_container_image on it.
 */
int load_container_images(unsigned long start, unsigned long end)
{
	struct Elf32_Header *elf_header = (struct Elf32_Header *)start;
	struct Elf32_Shdr *sect_header;
	int nsect = 0;
	int nconts = 0;

	if (elf32_checkFile(elf_header) < 0) {
		printf("Not a valid elf image.\n");
		return -1;
	}

	sect_header = elf32_getSectionTable(elf_header);
	nsect = elf32_getNumSections(elf_header);

	for (int i = 0; i < nsect; i++) {
		char *sectname = elf32_getSectionName(elf_header, i);
		if (!strncmp(sectname, ".cont.", strlen(".cont."))) {
			nconts++;
			printf("\nLoading section %s from top-level elf file.\n", sectname);
			load_container_image(elf32_getSection(elf_header, i));
		}
	}
	printf("Total of %d container images.\n", nconts);
	return 0;
}


int load_elf_image(unsigned long **entry, void *filebuf)
{
	if (!elf32_checkFile((struct Elf32_Header *)filebuf)) {
		**entry = (unsigned long)elf32_getEntryPoint((struct Elf32_Header *)filebuf);
		printf("Entry point: 0x%lx\n", **entry);
	} else {
		printf("Not a valid elf image.\n");
		return -1;
	}
	if (!elf_loadFile(filebuf, 1)) {
		printf("Elf image seems valid, but unable to load.\n");
		return -1;
	}
	return 0;
}

void arch_start_kernel(void *entry)
{
	printf("elf-loader:\tStarting kernel\n\r");
	void (*func)(unsigned long) = (void (*)(unsigned long)) (*(unsigned long*)entry);
	func(0);
}

int main(void)
{
	unsigned long *kernel_entry;

	printf("ELF Loader: Started.\n");

	printf("Loading the kernel...\n");
	load_elf_image(&kernel_entry, (void *)_start_kernel);

	printf("Loading containers...\n");
	load_container_images((unsigned long)_start_containers,
			      (unsigned long)_end_containers);

	printf("elf-loader:\tkernel entry point is 0x%lx\n", *kernel_entry);
	arch_start_kernel(kernel_entry);

	printf("elf-loader:\tKernel start failed! Looping endless.\n");
	while (1)
		;

	return -1;
}

