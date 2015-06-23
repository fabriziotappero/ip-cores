/*
 * sata_drv.h
 *
 * Definitions for the SATA device driver
 *
 * Author: Bin Huang  <bin.arthur@gmail.com>
 *
 * 2012 (c) Reconfigurable Computing System Lab at University of North
 * Carolina at Charlotte. This file is licensed under
 * the terms of the GNU General Public License version 2. This program
 * is licensed "as is" without any warranty of any kind, whether express
 * or implied. The code originally comes from the book "Linux Device
 * Drivers" by Alessandro Rubini and Jonathan Corbet, published
 * by O'Reilly & Associates.
 */

#include <linux/ioctl.h>
#include "sata_cfg.h"

#define DRIVER_NAME "sata"

/*
 * Minor number and partition management.
 */
#define SATA_MINORS	16
#define MINOR_SHIFT	4
#define DEVNUM(kdevnum)	(MINOR(kdev_t_to_nr(kdevnum)) >> MINOR_SHIFT

/*
 * The internal representation of our device.
 */
struct sata_dev {
        unsigned long long size;        /* Device size in sectors */
        short users;                    /* How many users */
        short media_change;             /* Flag a media change? */
        spinlock_t lock;                /* For mutual exclusion */
        struct request_queue *queue;    /* The device request queue */
        struct gendisk *gd;             /* The gendisk structure */
	SATA_core_t *scp;		/* SATA Core Slave Registers */
};


#define HARDSECT_SIZE		512

/* 
 * N_SECTORS:		
 * 409600 -> 200MB
 * 819200 -> 400MB
 */
#define N_SECTORS		2097152 //1024MB

/*
 * We can tweak our hardware sector size, but the kernel talks to us
 * in terms of small sectors, always.
 */
#define KERNEL_SECTOR_SIZE	512

#define SECTOR_SHIFT		9
