/*
 * The disk layout of our simple unix-like filesystem.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */

#ifndef __MEMFS_LAYOUT_H__
#define __MEMFS_LAYOUT_H__

#include <l4lib/types.h>
#include <l4/lib/list.h>
#include <l4/macros.h>
#include <l4/config.h>
#include INC_GLUE(memory.h)
#include <memcache/memcache.h>
#include <lib/idpool.h>

/*
 *
 * Filesystem layout:
 *
 * |---------------|
 * |  Superblock   |
 * |---------------|
 *
 * Superblock layout:
 *
 * |---------------|
 * | inode cache   |
 * |---------------|
 * | dentry cache  |
 * |---------------|
 * | block cache   |
 * |---------------|
 *
 */

/*
 * These fixed filesystem limits make it much easier to implement
 * filesystem space allocation.
 */
#define MEMFS_TOTAL_SIZE		SZ_4MB
#define MEMFS_TOTAL_INODES		128
#define MEMFS_TOTAL_BLOCKS		2000
#define MEMFS_FMAX_BLOCKS		120
#define MEMFS_BLOCK_SIZE		PAGE_SIZE
#define MEMFS_MAGIC			0xB
#define MEMFS_NAME			"memfs"
#define MEMFS_NAME_SIZE			8

struct memfs_inode {
	u32 inum;	/* Inode number */
	u32 mode;	/* File permissions */
	u32 owner;	/* File owner */
	u64 atime;	/* Last access time */
	u64 mtime;	/* Last content modification */
	u64 ctime;	/* Last inode modification */
	u64 size;	/* Size of contents */
	void *block[MEMFS_FMAX_BLOCKS]; /* Number of blocks */
};

struct memfs_superblock {
	u32 magic;		/* Filesystem magic number */
	char name[8];
	int fsidx;		/* Index that gets orred to get global vnum */
	u32 blocksize;		/* Filesystem block size */
	u64 fmaxblocks;		/* Maximum number of blocks per file */
	u64 fssize;		/* Total size of filesystem */
	unsigned long root_vnum;	/* The root vnum of this superblock */
	struct link inode_cache_list;	/* Chain of alloc caches */
	struct link block_cache_list;	/* Chain of alloc caches */
	struct id_pool *ipool;			/* Index pool for inodes */
	struct id_pool *bpool;			/* Index pool for blocks */
	struct memfs_inode *inode[MEMFS_TOTAL_INODES];	/* Table of inodes */
	void *block[MEMFS_TOTAL_BLOCKS]; 	/* Table of fs blocks */
} __attribute__ ((__packed__));

#define MEMFS_DNAME_MAX			32
struct memfs_dentry {
	u32 inum;			/* Inode number */
	u32 offset;			/* Dentry offset in its buffer */
	u16 rlength;			/* Record length */
	u8  type;			/* Record type */
	u8  name[MEMFS_DNAME_MAX];	/* Name string */
} __attribute__((__packed__));

extern struct vnode_ops memfs_vnode_operations;
extern struct superblock_ops memfs_superblock_operations;
extern struct file_ops memfs_file_operations;

int memfs_format_filesystem(void *buffer);
struct memfs_inode *memfs_create_inode(struct memfs_superblock *sb);
void memfs_register_fstype(struct link *);
struct superblock *memfs_get_superblock(void *block);
int memfs_generate_superblock(void *block);

void *memfs_alloc_block(struct memfs_superblock *sb);
int memfs_free_block(struct memfs_superblock *sb, void *block);
#endif /* __MEMFS_LAYOUT_H__ */
