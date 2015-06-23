#include <stdio.h>
#include <block.h>
#include <l4/lib/math.h>
#include <l4/macros.h>
#include <l4/types.h>
#include INC_GLUE(memory.h)

/*
 * Romfs superblock descriptor:
 *
 * All words are Big-Endian.
 *
 * Word 0: | - | r | o | m |
 * Word 1: | 1 | f | s | - |
 * Word 2: |      Size     | The number of bytes in this fs.
 * Word 3: |    Checksum   | The checksum of first 512 bytes.
 * Word 4: |  Volume Name  | The name of volume, padded to 16-byte boundary.
 * Rest:   |  File Headers | The rest of the data.
 */
struct romfs_superblock {
	u32 word0;
	u32 word1;
	u32 size;
	u32 checksum;
	char name[0];
};

struct romfs_inode {
	unsigned long mdata_size;	/* Size of metadata */
	unsigned long data_offset;	/* Offset of data from start of fs */
};

static u32
romfs_checksum(void *data)
{
	u32 sum = 0;
	u32 *ptr = data;

	size >>= 2;
	while (size > 0) {
		sum += be32_to_cpu(*ptr++);
		size--;
	}
	return sum;
}

int romfs_fill_super(struct superblock *sb)
{
	char buf[PAGE_SIZE];
	struct romfs_superblock *romfs_sb = (struct romfs_superblock *)buf;
	unsigned long vroot_offset;
	struct vnode *vroot;

	/* Read first page from block device */
	bdev_readpage(0, buf);

	/* Check superblock sanity */
	if (strcmp(be32_to_cpu(romfs_sb->word0), ROMFS_SB_WORD0)) {
		printf("Bad magic word 0\n");
	}
	if (strcmp(be32_to_cpu(romfs_sb->word1), ROMFS_SB_WORD1)) {
		printf("Bad magic word 1\n");
	}
	if (romfs_checksum(romfs_sb, min(romfs_sb->size, PAGE_SIZE))) {
		printf("Bad checksum.\n");
	}

	/* Copy some params to generic superblock */
	sb->size = be32_to_cpu(romfs_sb->size);
	sb->magic = ROMFS_MAGIC;
	sb->ops = romfs_ops;

	/* Offset of first vnode, which is the root vnode */
	vroot_offset = align_up(strnlen(romfs_sb->name, ROMFS_MAXNAME) + 1, 16);
	if (!(vroot = romfs_read_vnode(s, vroot_offset))) {
		printf("Error, could not get root inode.\n");
	}

	/* Get the dirent for this vnode */
	if (!(sb->root = new_dentry(vroot))) {
		printf("Error: Could not get new dentry for root vnode.\n");
	}

}


