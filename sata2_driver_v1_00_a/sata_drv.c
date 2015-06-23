/*
 * sata-drv.c
 *
 * Linux block device driver for Ashwin Mendon's SATA controller.
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

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>
#include <linux/sched.h>
#include <linux/kernel.h>	/* printk() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */
#include <linux/errno.h>	/* error codes */
#include <linux/types.h>	/* size_t */
#include <linux/fcntl.h>	/* O_ACCMODE */
#include <linux/hdreg.h>	/* HDIO_GETGEO */
#include <linux/kdev_t.h>
#include <linux/vmalloc.h>
#include <linux/genhd.h>
#include <linux/blkdev.h>
#include <linux/buffer_head.h>	/* invalidate_bdev */
#include <linux/bio.h>
#include <linux/delay.h>	/* udelay() */
#include "sata_drv.h"

MODULE_LICENSE("Dual BSD/GPL");

static int sata_major = 0;
module_param(sata_major, int, 0);
static int hardsect_size = HARDSECT_SIZE;
module_param(hardsect_size, int, 0);
static int nsectors = N_SECTORS;	/* How big the drive is */
module_param(nsectors, int, 0);
static int ndevices = 1;
module_param(ndevices, int, 0);

/*
 * The different "request modes" we can use.
 */
enum {
	RM_SIMPLE  = 0,	/* The extra-simple request function */
	RM_FULL    = 1,	/* The full-blown version */
	RM_NOQUEUE = 2,	/* Use make_request */
};
static int request_mode = RM_NOQUEUE;
module_param(request_mode, int, 0);

static struct sata_dev *Devices = NULL;


void read_sectors(struct sata_dev *dev, int sector_addr, int sector_count, unsigned int dma_phy_addr);
void write_sectors(struct sata_dev *dev, int sector_addr, int sector_count, unsigned int dma_phy_addr);

void read_sectors(struct sata_dev *dev, int sector_addr, int sector_count, unsigned int dma_phy_addr) 
{

	// DDR Read Space Start Address 
	dev->scp->npi_wr_addr_reg = dma_phy_addr;
	// Clear SATA Control Register 
	dev->scp->ctrl_reg = REG_CLEAR;

	// Input Sector Address, Count and Command to Sata Core
	dev->scp->sector_addr_reg = sector_addr;
	dev->scp->sector_count_reg = sector_count;
	dev->scp->cmd_reg = (READ_CMD);
	// Trigger SATA Core
	dev->scp->ctrl_reg = (NEW_CMD);

	// Wait for Command Completion 
	while ((dev->scp->status_reg & SATA_CORE_DONE) != SATA_CORE_DONE);

	//Time to Read Sectors from Disk 
#ifdef CONFIG_RCS_SATA_DEBUG
	printk("Number of clock cycles to complete this read: %d\n",dev->scp->sector_timer_reg);
#endif

	while ((dev->scp->status_reg & NPI_DONE) != NPI_DONE);
}


void write_sectors(struct sata_dev *dev, int sector_addr, int sector_count, unsigned int dma_phy_addr) 
{
	// DDR Write Space Start Address 
	dev->scp->npi_rd_addr_reg = dma_phy_addr;
	// Clear SATA Control Register 
	dev->scp->ctrl_reg = REG_CLEAR;

	// Input Sector Address, Count, DATA and Command to Sata Core
	dev->scp->sector_addr_reg = sector_addr;
	dev->scp->sector_count_reg = sector_count;
	//scp->wr_data_reg     = write_data;
	dev->scp->cmd_reg = (WRITE_CMD);
	// Trigger SATA Core
	dev->scp->ctrl_reg = (NEW_CMD);
	// Wait for Command Completion 

	while ((dev->scp->status_reg & SATA_CORE_DONE) != SATA_CORE_DONE);

	//Time to Write Sectors from Disk 
#ifdef CONFIG_RCS_SATA_DEBUG
	printk("Number of clock cycles to complete this write: %d\n",dev->scp->sector_timer_reg);
#endif
}


/*
 * Handle an I/O request.
 */
static void sata_transfer(struct sata_dev *dev, unsigned long sector,
		unsigned long nsect, char *buffer, int write)
{
	unsigned long offset = sector*KERNEL_SECTOR_SIZE;
	unsigned long nbytes = nsect*KERNEL_SECTOR_SIZE;

	if ((offset + nbytes) > dev->size) {
		printk (KERN_INFO "Beyond-end write (%ld %ld)\n", offset, nbytes);
		return;
	}
	if (write){
#ifdef CONFIG_RCS_SATA_DEBUG
		printk (KERN_INFO "Write request to: \n");
		printk (KERN_INFO "sector = %lu, nsect = %lu, buf_phy_addr = 0x%08lx ... \n ", sector, nsect, virt_to_phys(buffer));
#endif

		write_sectors(dev, sector, nsect, virt_to_phys(buffer));

#ifdef CONFIG_RCS_SATA_DEBUG
		printk (KERN_INFO "Write done.\n");
#endif
	}
	else{
#ifdef CONFIG_RCS_SATA_DEBUG
		printk (KERN_INFO "Read request to: \n");
		printk (KERN_INFO "sector = %lu, nsect = %lu, buf_phy_addr = 0x%08lx ... \n", sector, nsect, virt_to_phys(buffer));
#endif

		read_sectors(dev, sector, nsect, virt_to_phys(buffer));

#ifdef CONFIG_RCS_SATA_DEBUG
		printk (KERN_INFO "Read done\n");
#endif
	}
}


static void sata_request(struct request_queue *q) 
{
	struct request *req;
        
	req = blk_fetch_request(q);
	while (req != NULL) {
		struct sata_dev *dev = req->rq_disk->private_data;
		if (req == NULL || (req->cmd_type != REQ_TYPE_FS)) {
			printk (KERN_NOTICE "Skip non-CMD request\n");
			__blk_end_request_all(req, -EIO);
			continue;
		}
		sata_transfer(dev, blk_rq_pos(req), blk_rq_cur_sectors(req),
				req->buffer, rq_data_dir(req));
		if ( ! __blk_end_request_cur(req, 0) ) {
			req = blk_fetch_request(q);
		}
	}
}


/*
 * Transfer a single BIO.
 */
static int sata_xfer_bio(struct sata_dev *dev, struct bio *bio)
{
	int i;
	struct bio_vec *bvec;
	sector_t sector = bio->bi_sector;

        void *mem;

	// Do each segment independently. 
	bio_for_each_segment(bvec, bio, i) {
		char *buffer = __bio_kmap_atomic(bio, i, KM_USER0);

                mem = kmap(bvec->bv_page);
                kunmap(bvec->bv_page);

		sata_transfer(dev, sector, bio_cur_bytes(bio) >> SECTOR_SHIFT,
				buffer, bio_data_dir(bio) == WRITE);
		sector += bio_cur_bytes(bio) >> SECTOR_SHIFT;
		__bio_kunmap_atomic(bio, KM_USER0);
	}
	return 0; // Always "succeed" 
}


/*
 * The direct make request version.
 */
static int sata_make_request(struct request_queue *q, struct bio *bio)
{
	struct sata_dev *dev = q->queuedata;
	int status;

	status = sata_xfer_bio(dev, bio);
	bio_endio(bio, status);
	return 0;
}


/*
 * Open and close.
 */

static int sata_open(struct block_device *bdev, fmode_t mode)
{
	struct sata_dev *dev = bdev->bd_disk->private_data;
	unsigned long flags;
        
        spin_lock_irqsave(&dev->lock, flags);
        dev->users++;
        spin_unlock_irqrestore(&dev->lock, flags);

        check_disk_change(bdev);
	return 0;
}


static int sata_release(struct gendisk *disk, fmode_t mode)
{
	struct sata_dev *dev = disk->private_data;

	spin_lock(&dev->lock);
	dev->users--;

	spin_unlock(&dev->lock);

	return 0;
}


/*
 * The HDIO_GETGEO ioctl is handled in blkdev_ioctl.
 */
int sata_getgeo (struct block_device *bdev, struct hd_geometry *geo)
{
	long size;
	struct sata_dev *dev = bdev->bd_disk->private_data;

	printk(KERN_INFO "SATA block device driver command : HDIO_GETGEO .\n");
	size = dev->size*(hardsect_size/KERNEL_SECTOR_SIZE);
	geo->cylinders = (size & ~0x3f) >> 6;
	geo->heads = 4;
	geo->sectors = 16;
	geo->start = 0;
	return 0;

}


/*
 * The device operations structure.
 */
static struct block_device_operations sata_ops = 
{
	.owner           = THIS_MODULE,
	.open 	         = sata_open,
	.release 	 = sata_release,
	.getgeo	         = sata_getgeo
};


/*
 * Set up our internal device.
 */
static int setup_device(struct sata_dev *dev, int which)
{
	int retval = 0;
        int try_setup_link = 0;
 
	/*
	 * Initialize data structure.
	 */
	memset (dev, 0, sizeof (struct sata_dev));
	dev->size = nsectors*hardsect_size;

	/* 
         * Remap I/O for SATA controller.
         */

        if( !request_mem_region(SATA_CFG_BASE, SATA_CFG_REMAP_SIZE, DRIVER_NAME)){
                printk(KERN_ERR "Request for SATA configuration memory region failed!\n");
                dev->scp = 0;
                retval = -1;
		goto fail;
        }
	else {
		dev->scp = (SATA_core_t *) ioremap_nocache(SATA_CFG_BASE, SATA_CFG_REMAP_SIZE);  
		if (dev->scp == 0) {
			printk(KERN_ERR
			       "%s: Couldn't ioremap memory at 0x%08X\n",
			       DRIVER_NAME, SATA_CFG_BASE);
			iounmap(dev->scp);
			retval = -EFAULT;
			goto fail;
		}
		else {
#ifdef CONFIG_RCS_SATA_DEBUG
			printk(KERN_INFO "Remap Returned Virtual Address: %x\n",(unsigned int)dev->scp);
#endif
		}
	}

	dev->scp->ctrl_reg = REG_CLEAR;
	dev->scp->cmd_reg  = REG_CLEAR;

	while ((dev->scp->status_reg & SATA_LINK_READY) != SATA_LINK_READY) 
	{
		dev->scp->ctrl_reg = SW_RESET;
		dev->scp->ctrl_reg = REG_CLEAR;

                try_setup_link++;

		udelay(100000);

                //It is very disk specific. For the OCZ SSD, it takes a few resets for the link 
                //to come up but on the Micron SSD or on the Western Digital HD, it comes up 
                //after the first reset. 
                if (try_setup_link == 100) {
#ifdef CONFIG_RCS_SATA_DEBUG
			printk(KERN_INFO "SATA Link is not ready yet.\n");
#endif
                	retval = -ENODEV;
                        goto fail;
                }
	}

	spin_lock_init(&dev->lock);
	
	/*
	 * The I/O queue, depending on whether we are using our own
	 * make_request function or not.
	 */
	switch (request_mode) {
	    case RM_NOQUEUE:
		dev->queue = blk_alloc_queue(GFP_KERNEL);
		if (dev->queue == NULL)
			goto fail;
		blk_queue_make_request(dev->queue, sata_make_request);
		break;

	    case RM_SIMPLE:
		dev->queue = blk_init_queue(sata_request, &dev->lock);
		if (dev->queue == NULL)
		{
			retval = -ENODEV;
			goto fail;
		}
		break;

	    default:
		printk(KERN_NOTICE "Bad request mode %d, using simple\n", request_mode);
	}
	blk_queue_logical_block_size(dev->queue, hardsect_size);
	dev->queue->queuedata = dev;

	/*
	 * And the gendisk structure.
	 */
	dev->gd = alloc_disk(SATA_MINORS);
	if (! dev->gd) {
		printk (KERN_INFO "alloc_disk failure\n");
		retval = -ENODEV;
		goto fail;
	}
	printk (KERN_INFO "alloc_disk success\n");
	dev->gd->major = sata_major;
	dev->gd->first_minor = which*SATA_MINORS;
	dev->gd->fops = &sata_ops;
	dev->gd->queue = dev->queue;
	dev->gd->private_data = dev;
	snprintf (dev->gd->disk_name, 32, "sata%c", which + 'a');
	set_capacity(dev->gd, nsectors*(hardsect_size/KERNEL_SECTOR_SIZE));
	add_disk(dev->gd);

	return 0;               /* success */

fail:
	printk(KERN_INFO "Fail to setup SATA block device.\n");
	printk("SATA controller status: 0x%08x\n", dev->scp->status_reg);
	return retval;
}


static int __init sata_init(void)
{
	int i;
	int retval = 0;

	/*
	 * Get registered.
	 */
	printk(KERN_INFO "Block device driver for sata controller\n");
	sata_major = register_blkdev(sata_major, "sata");
	if (sata_major <= 0) {
		printk(KERN_WARNING "sata: unable to get major number\n");
		return -EBUSY;
	}

	/*
	 * Allocate the device array, and initialize each one.
	 */
	Devices = kmalloc(ndevices*sizeof (struct sata_dev), GFP_KERNEL);
	if (Devices == NULL)
		goto out_unregister;
	for (i = 0; i < ndevices; i++){ 
		retval = setup_device(Devices + i, i);
        }
	return retval;

  out_unregister:
	unregister_blkdev(sata_major, "sata");
	return -ENOMEM;
}


static void sata_exit(void)
{
	int i;

	for (i = 0; i < ndevices; i++) {
		struct sata_dev *dev = Devices + i;

		if (dev->gd) {
			del_gendisk(dev->gd);
			put_disk(dev->gd);
		}
		if (dev->queue) {
			if (request_mode == RM_NOQUEUE)
				blk_put_queue(dev->queue);
			else
				blk_cleanup_queue(dev->queue);
		}
	}
	unregister_blkdev(sata_major, "sata");
	kfree(Devices);
}
	
module_init(sata_init);
module_exit(sata_exit);
