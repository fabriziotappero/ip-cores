/*
 * disk.h -- disk simulation
 */


#ifndef _DISK_H_
#define _DISK_H_


#define SECTOR_SIZE	512	/* sector size in bytes */

#define DISK_CTRL	0	/* control register */
#define DISK_CNT	4	/* sector count register */
#define DISK_SCT	8	/* disk sector register */
#define DISK_CAP	12	/* disk capacity register */

#define DISK_STRT	0x01	/* a 1 written here starts the disk command */
#define DISK_IEN	0x02	/* enable disk interrupt */
#define DISK_WRT	0x04	/* command type: 0 = read, 1 = write */
#define DISK_ERR	0x08	/* 0 = ok, 1 = error; valid when DONE = 1 */
#define DISK_DONE	0x10	/* 1 = disk has finished the command */
#define DISK_READY	0x20	/* 1 = capacity valid, disk accepts command */

#define DISK_DELAY_USEC	10000	/* seek start/settle + rotational delay */
#define DISK_SEEK_USEC	50000	/* full disk seek time */
#define DISK_START_USEC	1000000	/* disk startup time (until DISK_READY) */


Word diskRead(Word addr);
void diskWrite(Word addr, Word data);

void diskReset(void);
void diskInit(char *diskImageName);
void diskExit(void);


#endif /* _DISK_H_ */
