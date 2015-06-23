/*
 * This is just to allocate some memory as a block device.
 */
#include <init.h>
#include <l4/macros.h>
#include <bootdesc.h>
#include <memfs/memfs.h>
#include L4LIB_INC_ARCH(syslib.h)

void *vfs_rootdev_open(void)
{
	struct svc_image *rootfs_img = bootdesc_get_image_byname("rootfs");
	unsigned long rootfs_size = rootfs_img->phys_end - rootfs_img->phys_start;
	
	BUG_ON(rootfs_size < MEMFS_TOTAL_SIZE);

	/* Map filesystem blocks to virtual memory */
	return l4_map_helper((void *)rootfs_img->phys_start, __pfn(rootfs_size));
}
