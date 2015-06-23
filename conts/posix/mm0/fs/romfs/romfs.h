#ifndef __ROMFS_H__
#define __ROMFS_H__

#define ROMFS_MAGIC	0x7275

#define ROMFS_FTYPE_MSK		0xF	/* File mask */
#define ROMFS_FTYPE_HRD		0	/* Hard link */
#define ROMFS_FTYPE_DIR		1	/* Directory */
#define ROMFS_FTYPE_REG 	2	/* Regular file */
#define ROMFS_FTYPE_SYM 	3	/* Symbolic link */
#define ROMFS_FTYPE_BLK 	4	/* Block device */
#define ROMFS_FTYPE_CHR 	5	/* Char device */
#define ROMFS_FTYPE_SCK 	6	/* Socket */
#define ROMFS_FTYPE_FIF 	7	/* FIFO */
#define ROMFS_FTYPE_EXE 	8	/* Executable */

#define ROMFS_NAME_ALIGN	16	/* Alignment size of names */

#define ROMFS_SB_WORD0	"-rom"
#define ROMFS_SB_WORD1	"1fs-"

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


#endif /* __ROMFS_H__ */
