/*
 * Reading of bootdesc forged at build time.
 *
 * Copyright (C) 2007 - 2009 Bahadir Balban
 */

#include <bootdesc.h>
#include <bootm.h>
#include <init.h>
#include <linker.h>
#include L4LIB_INC_ARCH(syslib.h)

extern unsigned long pager_offset;

struct svc_image *bootdesc_get_image_byname(char *name)
{
	for (int i = 0; i < initdata.bootdesc->total_images; i++)
		if (!strncmp(initdata.bootdesc->images[i].name, name, strlen(name)))
			return &initdata.bootdesc->images[i];
	return 0;
}

void read_boot_params()
{
	int npages = 0;
	struct bootdesc *bootdesc;

	/*
	 * End of the executable image is where bootdesc resides
	 */
	bootdesc = (struct bootdesc *)__end;

	/* Check if bootdesc is on an unmapped page */
	if (is_page_aligned(bootdesc))
		l4_map_helper(bootdesc - pager_offset, 1);

	/* Allocate bootdesc sized structure */
	initdata.bootdesc = alloc_bootmem(bootdesc->desc_size, 0);

	/* Copy bootdesc to initdata */
	memcpy(initdata.bootdesc, bootdesc,
	       bootdesc->desc_size);

	if (npages > 0)
		l4_unmap_helper((void *)page_align_up(__end), npages);
}
