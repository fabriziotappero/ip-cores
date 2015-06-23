/*
    Linux Driver for Enterpoint's Raggedstone1 FPGA PCI Board
    This demo driver allows access to the Board's 7segment displays.
    
    License: GPL
    See file "GPL" for details

*/

#ifndef MODULE
#define MODULE
#endif

#include <linux/version.h>             /* >= 2.6.14 LINUX_VERSION_CODE */
// #include <linux/config.h>              /* needed to get LINUX_VERSION_CODE >= 2.6.13 */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/pci.h>
#include <linux/fs.h>
#include <linux/ioctl.h>



MODULE_AUTHOR("Manuel Bessler");
MODULE_DESCRIPTION("Raggedstone1 FPGA PCI Development Board Driver");

#ifdef MODULE_LICENSE
MODULE_LICENSE("GPL");
#endif

#define VENDOR_ID 0x10ee
#define DEVICE_ID 0x0100

#define MAJOR_NUM 100
#define IOCTL_SETDPY _IOR(MAJOR_NUM, 0, u16)
#define DEVICE_NAME "fpga"

#define SUCCESS 0

unsigned long memstart = 0, memlen = 0;
void * vaddr = 0;
u16 lastwrite = 0;
static int Device_Open = 0;


int device_ioctl(
    struct inode *inode,
    struct file *file,
    unsigned int ioctl_num,/* The number of the ioctl */
    unsigned long ioctl_param) /* The parameter to it */
{
    u16 display_val;
    printk (KERN_INFO "device_ioctl(%p,%p,ioctl_param=0x%x)\n", inode, file, (u16)ioctl_param);

    switch (ioctl_num) 
    {
	case IOCTL_SETDPY:
	    printk(KERN_INFO "executing IOCTL_SETDPY\n");
	    display_val = (u16) ioctl_param;
	    writew(display_val, vaddr);
	    break;
    }
    return SUCCESS;
}

/* This function is called whenever a process attempts 
 * to open the device file */
static int device_open(struct inode *inode, 
                       struct file *file)
{
  printk ("device_open(%p)\n", file);
  /* We don't want to talk to two processes at the 
   * same time */
  if (Device_Open)
    return -EBUSY;
  Device_Open++;
//#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)
//  MOD_INC_USE_COUNT;
//#endif
  return SUCCESS;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
static int device_close(struct inode *inode, struct file *file)
#else
static void device_close(struct inode *inode, struct file *file)
#endif
{
  printk ("device_release(%p,%p)\n", inode, file);
  Device_Open --;
//#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)
//  MOD_DEC_USE_COUNT;
//#endif
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
  return 0;
#endif
}

struct file_operations Fops = {
    open: device_open,
    release: device_close,
    ioctl: device_ioctl
};






static struct pci_device_id  pci_device_id_DevicePCI[] =
{
  {VENDOR_ID, DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
  {}  // end of list
};

int device_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
  int ret;
  ret = pci_enable_device(dev);
  if (ret < 0)
  {
    printk(KERN_WARNING "DevicePCI: unable to initialize PCI device\n");
    return ret;
  }

  ret = pci_request_regions(dev, "MyPCIDevice");
  if (ret < 0)
  {
    printk(KERN_WARNING "DevicePCI: unable to reserve PCI resources\n");
    pci_disable_device(dev);
    return ret;
  }

  memstart = pci_resource_start(dev, 0); // 0 for BAR0
  memlen = pci_resource_len(dev, 0);
  printk(KERN_WARNING "DevicePCI: memstart=0x%lx memlen=0x%lx\n", memstart, memlen);

  vaddr = ioremap(memstart, memlen);
	lastwrite =	readw(vaddr);
  printk(KERN_WARNING "DevicePCI: vaddr=0x%08X current=0x%08X\n", (u32) vaddr, (u32) lastwrite);
//	writew(vaddr, );
//      writew(0xDEAD, vaddr+i);

  printk(KERN_INFO "DevicePCI: device_probe successful\n");
  
  /* Register the character device (atleast try) */
  ret = register_chrdev(MAJOR_NUM, DEVICE_NAME, &Fops);

  /* Negative values signify an error */
  if (ret < 0) 
  {
    printk (KERN_INFO "%s failed with %d\n",
            "Sorry, registering the character device ",
            ret);
    return ret;
  }
  else
  {
      printk (KERN_INFO "%s The major device number is %d.\n",
	      "Registeration is a success", 
    	      MAJOR_NUM);
      printk (KERN_INFO "If you want to talk to the device driver,\n");
      printk (KERN_INFO "you'll have to create a device file. \n");
      printk (KERN_INFO "We suggest you use:\n");
      printk (KERN_INFO "mknod /dev/%s c %d 0\n", DEVICE_NAME, 
	      MAJOR_NUM);
      printk (KERN_INFO "The device file name is important, because\n");
      printk (KERN_INFO "the ioctl program assumes that's the\n");
      printk (KERN_INFO "file you'll use.\n");
  }
  
  return ret;
}

void device_remove(struct pci_dev *dev)
{
  unregister_chrdev(MAJOR_NUM, DEVICE_NAME);
 
  iounmap(vaddr);
//  release_mem_region(memstart, memlen);

  pci_release_regions(dev);
  pci_disable_device(dev);
  printk(KERN_INFO "DevicePCI: device removed\n");
}

struct pci_driver  pci_driver_DevicePCI =
{
  name: "MyPCIDevice",
  id_table: pci_device_id_DevicePCI,
  probe: device_probe,
  remove: device_remove
};

static int init_module_DevicePCI(void)
{
  printk(KERN_INFO "DevicePCI: init\n");
  return pci_module_init(&pci_driver_DevicePCI);
}

void cleanup_module_DevicePCI(void)
{
  printk(KERN_INFO "DevicePCI: cleanup\n");
  pci_unregister_driver(&pci_driver_DevicePCI);
}

module_init(init_module_DevicePCI);
module_exit(cleanup_module_DevicePCI);




