/*
 * The disk layout of our simple unix-like filesystem.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */

#ifndef __C0FS_LAYOUT_H__
#define __C0FS_LAYOUT_H__

#include <l4lib/types.h>
#include <l4/lib/list.h>
#include <l4/macros.h>
#include <l4/config.h>
#include INC_GLUE(memory.h)

/*
 *
 * Filesystem layout:
 *
 * |---------------|
 * |    Group 0    |
 * |---------------|
 * |    Group 1    |
 * |---------------|
 * |      ...      |
 * |---------------|
 * |    Group n    |
 * |---------------|
 *
 *
 * Group layout:
 *
 * |---------------|
 * |  Superblock   |
 * |---------------|
 * |  Inode table  |
 * |---------------|
 * |  Data blocks  |
 * |---------------|
 *
 * or
 *
 * |---------------|
 * |  Data blocks  |
 * |---------------|
 *
 */

#define BLOCK_SIZE		PAGE_SIZE
#define BLOCK_BITS		PAGE_BITS
#define GROUP_SIZE		SZ_8MB
#define INODE_TABLE_SIZE	((GROUP_SIZE / BLOCK_SIZE) / 2)
#define INODE_BITMAP_SIZE	(INODE_TABLE_SIZE >> 5)


struct sfs_superblock {
	u32 magic;		/* Filesystem magic number */
	u64 fssize;		/* Total size of filesystem */
	u32 total;		/* To */
	u32 groupmap[];		/* Bitmap of all fs groups */
};

struct sfs_group_table {
	u32 total;
	u32 free;
	u32 groupmap[];
};

struct sfs_inode_table {
	u32 total;
	u32 free;
	u32 inodemap[INODE_BITMAP_SIZE];
	struct sfs_inode inode[INODE_TABLE_SIZE];
};

/*
 * The purpose of an inode:
 *
 * 1) Uniquely identify a file or a directory.
 * 2) Keep file/directory metadata.
 * 3) Provide access means to file blocks/directory contents.
 */
#define INODE_DIRECT_BLOCKS	5
struct sfs_inode_blocks {
	int  szidx;		/* Direct array index size */
	unsigned long indirect;
	unsigned long indirect2;
	unsigned long indirect3;
	unsigned long direct[];
};

struct sfs_inode {
	u32 unum;	/* Unit number this inode is in */
	u32 inum;	/* Inode number */
	u32 mode;	/* File permissions */
	u32 owner;	/* File owner */
	u64 atime;	/* Last access time */
	u64 mtime;	/* Last content modification */
	u64 ctime;	/* Last inode modification */
	u64 size;	/* Size of contents */
	struct sfs_inode_blocks blocks;
} __attribute__ ((__packed__));

struct sfs_dentry {
	u32 inum;	/* Inode number */
	u32 nlength;	/* Name length */
	u8  name[];	/* Name string */
} __attribute__ ((__packed__));


void sfs_register_type(struct link *);

#endif /* __C0FS_LAYOUT_H__ */
