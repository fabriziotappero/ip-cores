#include <linux/module.h>
#include <linux/errno.h>
#include <linux/kernel.h>
#include <linux/pci.h>
#include <linux/wrapper.h>

#include <asm/uaccess.h>
#include <spartan_kint.h> //IOCTL definitions
 
// define vendor and device ID here - currently this definitions specify reference designs from insight electronic
#ifdef __SDRAM__
#define OC_PCI_VENDOR 0x1597
#define OC_PCI_DEVICE 0x0300
#endif
#ifdef __VGA__
#define OC_PCI_VENDOR 0x1895
#define OC_PCI_DEVICE 0x0001
#endif
#ifdef __OC_TEST__
#define OC_PCI_VENDOR 0x1895
#define OC_PCI_DEVICE 0x0001
#define __VGA__
#endif

// if someone wants specific major number assigned to spartan board - specify it here 
// if 0 is used, kernel assigns it automaticaly
#ifdef __SDRAM__
#define REQUESTED_MAJOR 0 
#endif

#ifdef __VGA__
#define REQUESTED_MAJOR 0
#endif

// if compiling module for kernel 2.4 - leave this defined
// for kernel 2.2 - comment this out
#define KERNEL_VER_24

#ifndef SEEK_SET
	#define SEEK_SET 0
	#define SEEK_CUR 1
	#define SEEK_END 2
#endif

// io.h needed just for kernel 2.2
#ifndef KERNEL_VER_24
	#include <asm/io.h>
#endif

// memory mapped or IO mapped region definitions
#define SPARTAN_MEM_MAPPED 0
#define SPARTAN_IO_MAPPED 1

#ifdef __VGA__
#ifdef __OC_TEST__
    #define VIDEO_SZ (16384)
#else
    #define VIDEO_SZ (640*480)
#endif
#endif

// structure for holding board information
// (6 base addresses, mapping, page etc.
static struct our_dev
{
	int major ;
	u32 bases[6] ;
	u8 num_of_bases ;
	u32 base_size[6] ;
	u32 offset ;
	u32 page_addr ;
	u32 base_page_offset ;
	int current_resource ;
	int base_map[6] ; 
	u32 video_base ;
	u32 video_vbase ;
	u32 video_size ;
	struct pci_dev *ppci_spartan_dev ; 
} pspartan_dev ;

// function prototypes
int spartan_open(struct inode *inode, struct file *filp);
 
int spartan_release(struct inode *inode, struct file *filp);

ssize_t spartan_read(struct file *filp, char *buf, size_t count, loff_t *offset ) ;
ssize_t spartan_write(struct file *filp, const char *buf, size_t count, loff_t *offset) ;
int	spartan_ioctl(struct inode *pnode, struct file *filp, unsigned int cmd, unsigned long arg) ;
loff_t  spartan_seek(struct file *filp, loff_t offset, int what) ;

// file operations structure - different for kernels 2.2 and 2.4
static struct file_operations *pspartan_fops ;
static struct file_operations spartan_fops = {
	#ifdef KERNEL_VER_24
	NULL,
	#endif
	spartan_seek,
	spartan_read,
	spartan_write,
	NULL,
	NULL,
	spartan_ioctl,
	NULL,
	spartan_open,
	NULL,
	spartan_release,
} ;		     

int open_mem_mapped(void) ;

// seek file operation function
loff_t  spartan_seek(struct file *filp, loff_t offset, int origin)
{
	loff_t requested_offset ;
	int resource_num = pspartan_dev.current_resource ;

	switch (origin)
	{
		case SEEK_CUR:requested_offset = pspartan_dev.offset + offset ; break ;
		case SEEK_END:requested_offset = pspartan_dev.base_size[resource_num] + offset ; break ;
		default:requested_offset  = offset ; break ;
	}
	
	if ((requested_offset < 0) || (requested_offset > pspartan_dev.base_size[resource_num]))
		return -EFAULT ;

	pspartan_dev.offset = requested_offset ;

	return requested_offset ; 				 
}

// ioctl for device
// currently just a few operations are supported here - defined in spartan_kint.h header
int     spartan_ioctl(struct inode *pnode, struct file *filp, unsigned int cmd, unsigned long arg) 
{
	int error = 0;
	int size = _IOC_SIZE(cmd) ;
	unsigned long base ;
	unsigned long base_size ;
	int i;

	if (_IOC_TYPE(cmd) != SPARTAN_IOC_NUM) return -EINVAL ;
	if (_IOC_NR(cmd) > SPARTAN_IOC_MAX_NUM) return -EINVAL ;

	// Writes through pointers not allowed - writes only through argument 
	if (_IOC_DIR(cmd) & _IOC_WRITE) return -EINVAL ;
	else if (_IOC_DIR(cmd) & _IOC_READ)
		error = verify_area(VERIFY_WRITE, (void *) arg, size) ;
	
	if (error)
		return error ;

	switch (cmd){
		case SPARTAN_IOC_CURRESGET:
			// current resource - they start at 1
			return (pspartan_dev.current_resource + 1) ;  
		case SPARTAN_IOC_CURRESSET:
			// check if resource is in a range of implemented resources
			if (arg < 0 )
				return -EINVAL ;

			// unmap previous resource if it was mapped
			if (pspartan_dev.current_resource >= 0)
			{
				iounmap((void *)pspartan_dev.page_addr) ;
			}	

			if (arg == 0)
			{
				// previous resource unmaped - that's all
				pspartan_dev.current_resource = -1 ;
				return 0 ;	
			}

			if (pspartan_dev.num_of_bases < arg)
				return -ENODEV ;

			// IO mapped not supported yet
			if (pspartan_dev.base_map[arg] == SPARTAN_IO_MAPPED)
			{
				// set current resource to none, since it was unmapped
				pspartan_dev.current_resource = -1 ;
				return -ENODEV ;
			}
			pspartan_dev.current_resource= (int)(arg-1) ;
			// remap new resource
			if ( (error = open_mem_mapped()) )
			{
				pspartan_dev.current_resource = -1 ;
				return error ;
			}
			return 0 ;
		case SPARTAN_IOC_CURBASE:
			// check if any resource is currently activated
			if (pspartan_dev.current_resource>=0)
				base = pspartan_dev.bases[pspartan_dev.current_resource] ;
			else
				base = 0x00000000 ;
			
			*(unsigned long *)arg = base ;
			return 0 ;
		case SPARTAN_IOC_CURBASEMAP:
			// check if any resource is currently activated
			if (pspartan_dev.current_resource>=0)
				base = pspartan_dev.page_addr ;
			else
				base = 0x00000000 ;
	
			*(unsigned long *)arg = base ;

			return 0 ;	
		case SPARTAN_IOC_CURBASESIZE:	
			// check if any resource is currently activated
			if (pspartan_dev.current_resource>=0)
				base_size = pspartan_dev.base_size[pspartan_dev.current_resource] ;
			else
				base_size = 0x00000000 ;
			
			*(unsigned long *)arg = base_size ;
			return 0 ;					
		case SPARTAN_IOC_NUMOFRES:	
			return (pspartan_dev.num_of_bases) ;
#ifdef __VGA__		
		case SPARTAN_IOC_VIDEO_BASE:
			*((unsigned long *)arg) = pspartan_dev.video_base;
			put_user(pspartan_dev.video_base, ((unsigned long *)arg));
			return 0 ;

		case SPARTAN_IOC_VIDEO_VBASE:
			*(unsigned long *)arg = pspartan_dev.video_vbase;
			put_user(pspartan_dev.video_vbase, ((unsigned long *)arg));
			return 0 ;
		
		case SPARTAN_IOC_VIDEO_SIZE:
			*(unsigned long *)arg = pspartan_dev.video_size;
			put_user(pspartan_dev.video_size, ((unsigned long *)arg));
			return 0;

		case SPARTAN_IOC_SET_VIDEO_BUFF:
			for(i = 0; i < VIDEO_SZ; i++) {
				get_user(*((char *)(pspartan_dev.video_vbase +  i)), ((char *)(arg + i)));	
			}

			return 0;
        case SPARTAN_IOC_GET_VIDEO_BUFF:
            for(i = 0; i < VIDEO_SZ; i++) {
                put_user(*((char *)(pspartan_dev.video_vbase +  i)), ((char *)(arg + i))) ;
            }

            return 0 ;
#endif
		default:
			return -EINVAL ;
	}
}

// helper function for memory remaping
int open_mem_mapped(void)
{
	int resource_num = pspartan_dev.current_resource ;
	unsigned long num_of_pages = 0 ;
	unsigned long base = pspartan_dev.bases[resource_num] ;
	unsigned long size = pspartan_dev.base_size[resource_num] ;

	if (!(num_of_pages = (unsigned long)(size/PAGE_SIZE))) ;
		num_of_pages++ ;

	pspartan_dev.base_page_offset = base & ~PAGE_MASK ;

	if ((pspartan_dev.base_page_offset + size) < (num_of_pages*PAGE_SIZE)) 
		num_of_pages++ ;
	
	// remap memory mapped space
	pspartan_dev.page_addr = (unsigned long)ioremap(base & PAGE_MASK, num_of_pages * PAGE_SIZE) ;
	
	if (pspartan_dev.page_addr == 0x00000000)
		return -ENOMEM ;
	
	return 0 ;
}

// add io mapped resource handler here
int open_io_mapped( void ) 
{
	return 0 ;
}

// open file operation function
int spartan_open(struct inode *inode, struct file *filp)
{
	if (MOD_IN_USE)
		return -EBUSY ;

	pspartan_fops = &spartan_fops ;
	filp->f_op = pspartan_fops ;
	pspartan_dev.offset = 0 ;
	pspartan_dev.current_resource = -1 ;	
	MOD_INC_USE_COUNT ;
	return 0 ;
}
 
// release - called by close on file descriptor
int spartan_release(struct inode *inode, struct file *filp)
{
	// unmap any remaped pages
	if (pspartan_dev.current_resource >= 0)
		iounmap((void *)pspartan_dev.page_addr) ;

	pspartan_dev.current_resource = -1 ;

	MOD_DEC_USE_COUNT ;
	return 0 ;
}

// memory mapped resource read function
ssize_t spartan_read(struct file *filp, char *buf, size_t count, loff_t *offset_out ) 
{
				
	unsigned long current_address = pspartan_dev.page_addr + pspartan_dev.base_page_offset + pspartan_dev.offset ;
	unsigned long actual_count ;
	unsigned long offset = pspartan_dev.offset ;
	int resource_num = pspartan_dev.current_resource ;
	int i;
	unsigned int value;
        unsigned int *kern_buf ;
        unsigned int *kern_buf_tmp ;

	unsigned long size   = pspartan_dev.base_size[resource_num] ;
	int result ;

	if (pspartan_dev.current_resource < 0)
		return -ENODEV ;
	
	if (offset == size)
		return 0 ;
 
	if ( (offset + count) > size )
		actual_count = size - offset ;
	else
		actual_count = count ;
 
	// verify range if it is OK to copy from
	if ((result = verify_area(VERIFY_WRITE, buf, actual_count)))
		return result ;
 
    kern_buf = kmalloc(actual_count, GFP_KERNEL | GFP_DMA) ;
    kern_buf_tmp = kern_buf ;
    if (kern_buf <= 0)
        return 0 ;
    
    memcpy_fromio(kern_buf, current_address, actual_count) ;
	i = actual_count/4;
	while(i--) {
	
//		value = readl(current_address);	
        value = *(kern_buf) ;
		put_user(value, ((unsigned int *)buf));	
		buf += 4;
        ++kern_buf ;
//		current_address += 4;
	}

    kfree(kern_buf_tmp);
	pspartan_dev.offset = pspartan_dev.offset + actual_count ;
 
	*(offset_out) = pspartan_dev.offset ;
 
	return actual_count ;  
 }		

// memory mapped resource write function
ssize_t spartan_write(struct file *filp, const char *buf, size_t count, loff_t *offset_out) 
{
	unsigned long current_address = pspartan_dev.page_addr + pspartan_dev.base_page_offset + pspartan_dev.offset ;
	unsigned long actual_count ;
	unsigned long offset = pspartan_dev.offset ;
	int resource_num = pspartan_dev.current_resource ;
 	int i;
	int value;
	unsigned long size   = pspartan_dev.base_size[resource_num] ;
	int result ;
    int *kern_buf ;
    int *kern_buf_tmp ;
 
	if (pspartan_dev.current_resource < 0)
		return -ENODEV ;

	if (offset == size)
		return 0 ;
 
	if ( (offset + count) > size )
		actual_count = size - offset ;
	else
		actual_count = count ;
 
	// verify range if it is OK to copy from
	if ((result = verify_area(VERIFY_READ, buf, actual_count)))
		return result ;
 
    kern_buf = kmalloc(actual_count, GFP_KERNEL | GFP_DMA) ;
    kern_buf_tmp = kern_buf ;
    if (kern_buf <= 0)
        return 0 ;
    
	i = actual_count/4;
	while(i--) {
		get_user(value, ((int *)buf));
		//writel(value, current_address);
        *kern_buf = value ;
		buf += 4;
		//current_address += 4;
        ++kern_buf ;
	}

    memcpy_toio(current_address, kern_buf_tmp, actual_count) ;
    kfree(kern_buf_tmp) ;

	pspartan_dev.offset = pspartan_dev.offset + actual_count ;
 
	*(offset_out) = pspartan_dev.offset ;
 
	return actual_count ; 
}

// initialization function - different for 2.2 and 2.4 kernel because of different pci_dev structure
int init_module(void)
{
	int result ;
	u32 base_address ;
	unsigned long size ;
	unsigned short num_of_bases ;
	u16 wvalue ;
	struct pci_dev *ppci_spartan_dev = NULL ;
	struct resource spartan_resource ;
	struct page *page;
	int sz ;

	if(!pci_present())
	{
		printk("<1> Kernel reports no PCI bus support!\n " );
		return -ENODEV;  
	}

	if((ppci_spartan_dev = pci_find_device(OC_PCI_VENDOR, OC_PCI_DEVICE, ppci_spartan_dev))==NULL )
	{
		printk("<1> Device not found!\n " );
		return -ENODEV ;
	}
	
	pspartan_dev.ppci_spartan_dev = ppci_spartan_dev ;

#ifdef KERNEL_VER_24
	//printk("<1> Board found at address 0x%08X\n", ppci_spartan_dev->resource[0].start) ;
	// copy implemented base addresses to private structure

	spartan_resource = ppci_spartan_dev->resource[0] ;
	base_address     =  spartan_resource.start ;
	printk("<1> First base address register found at %08X \n ", base_address ); 
	num_of_bases = 0 ;
	while ((base_address != 0x00000000) && (num_of_bases < 6))
	{
		pspartan_dev.bases[num_of_bases] = spartan_resource.start ;
		pspartan_dev.base_size[num_of_bases] = spartan_resource.end - spartan_resource.start + 1 ;
		// check if resource is IO mapped
		if (spartan_resource.flags & IORESOURCE_IO)
			pspartan_dev.base_map[num_of_bases] = SPARTAN_IO_MAPPED ;
		else
			pspartan_dev.base_map[num_of_bases] = SPARTAN_MEM_MAPPED ;

		num_of_bases++ ;
		spartan_resource = ppci_spartan_dev->resource[num_of_bases] ;
		base_address = spartan_resource.start ;
	}

	result = pci_read_config_word(ppci_spartan_dev, PCI_COMMAND, &wvalue) ;
	if (result <  0)
	{
		printk("<1> Read from command register failed! \n " );
		return result ;
	}		     

	result = pci_write_config_word(ppci_spartan_dev, PCI_COMMAND, wvalue | PCI_COMMAND_MEMORY | PCI_COMMAND_IO) ;
 
	if (result <  0)
	{
		printk("<1>Write to command register failed! \n " );
		return result ;
	}
		      
#else

	printk("<1> Board found at address 0x%08X\n", ppci_spartan_dev->base_address[0]);

	// now go through base addresses of development board 
	// and see what size they are - first disable devices response
	result = pci_read_config_word(ppci_spartan_dev, PCI_COMMAND, &wvalue) ;
	if (result <  0)
	{
		printk("<1> Read from command register failed! \n " );
		return result ;	
	}

	// write masked config value back to command register to 
	// disable devices response! mask value
	result = pci_write_config_word(ppci_spartan_dev, PCI_COMMAND, wvalue & ~PCI_COMMAND_IO & ~PCI_COMMAND_MEMORY) ;

	if (result <  0)
	{
		printk("<1>Write to command register failed! \n " );
		return result ;
	}			

	// write to base address registers and read back until all 0s are read
	base_address = ppci_spartan_dev->base_address[0] ;
	num_of_bases = 0 ;
	while ((base_address != 0x00000000) && (num_of_bases < 6))
	{
		// copy non-zero base address to private structure
		pspartan_dev.bases[num_of_bases] = ppci_spartan_dev->base_address[num_of_bases] ;

		// write to current register
		result = pci_write_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_0 + (num_of_bases * 4), 0xFFFFFFFF) ;
 
		if (result <  0)
		{
			printk("<1>Write to BAR%d failed! \n ", num_of_bases);
			return result ;
		}								 
		
		result = pci_read_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_0 + (num_of_bases * 4), &base_address) ;
		if (result <  0)
		{
			printk("<1>Read from BAR%d failed! \n ", num_of_bases);
			return result ;
		}		 

		// calculate size of this base address register's range
		size = 0xFFFFFFFF - base_address ;
	
		// store size in structure
		pspartan_dev.base_size[num_of_bases] = size + 1;
	
		// set base address back to original value
		base_address = pspartan_dev.bases[num_of_bases] ;

		// now write original base address back to this register
		result = pci_write_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_0 + (num_of_bases * 4), base_address) ;

		if (result <  0)
		{
			printk("<1>Write to BAR%d failed! \n ", num_of_bases);
			return result ;
		}		     
		num_of_bases++ ;
		// read new base address
		base_address = ppci_spartan_dev->base_address[num_of_bases] ;
					
	}
	// write original value back to command register!
	result = pci_write_config_word(ppci_spartan_dev, PCI_COMMAND, wvalue) ;
 
	if (result <  0)
	{
		printk("<1>Write to command register failed! \n " );
		return result ;
	}			   
#endif
	if (num_of_bases < 1)
		printk("<1>No implemented base address registers found! \n ") ;

	pspartan_dev.current_resource = - 1 ;

	// store number of bases in structure
	pspartan_dev.num_of_bases = num_of_bases ;

	// display information about all base addresses found in this procedure
	for (num_of_bases = 0; num_of_bases < pspartan_dev.num_of_bases; num_of_bases++)
	{
		printk("<1>BAR%d range from %08X to %08X \n ", num_of_bases, pspartan_dev.bases[num_of_bases], pspartan_dev.bases[num_of_bases] + pspartan_dev.base_size[num_of_bases]); 
	}	
#ifdef __VGA__
	for (sz = 0, size = PAGE_SIZE; size < VIDEO_SZ; sz++, size <<= 1);
	pspartan_dev.video_vbase = __get_free_pages(GFP_KERNEL, sz);

	if (pspartan_dev.video_vbase == 0) {
		printk(KERN_ERR "spartan: abort, cannot allocate video memory\n");
		return -EIO;
	}

	pspartan_dev.video_size = PAGE_SIZE * (1 << sz);
	pspartan_dev.video_base = virt_to_bus(pspartan_dev.video_vbase);

	for (page = virt_to_page(pspartan_dev.video_vbase); page <= virt_to_page(pspartan_dev.video_vbase + pspartan_dev.video_size - 1); page++)
		mem_map_reserve(page);

	printk(KERN_INFO "spartan: framebuffer at 0x%lx (phy 0x%lx), mapped to 0x%p, size %dk\n",
	       pspartan_dev.video_base, virt_to_phys(pspartan_dev.video_vbase), pspartan_dev.video_vbase, pspartan_dev.video_size/1024);	
#endif

	result = register_chrdev(REQUESTED_MAJOR, "spartan", &spartan_fops) ;
	if (result < 0)
	{
		printk(KERN_WARNING "spartan: can't get major number %d\n",REQUESTED_MAJOR) ;
		return result ;
	}
	
	printk("<1> Major number for spartan is %d \n", result );
	pspartan_dev.major = result ;

	return 0 ; 
}

// celanup - unregister device
void cleanup_module(void) 
{ 
	int result ;
	int size, sz;

#ifdef __VGA__
	for (sz = 0, size = PAGE_SIZE; size < VIDEO_SZ; sz++, size <<= 1);
	free_pages(pspartan_dev.video_vbase, sz);
#endif
	result = unregister_chrdev(pspartan_dev.major, "spartan") ;
	if (result < 0)
	{
		printk("<1> spartan device with major number %d unregistration failed \n", pspartan_dev.major);
		return ;
	}
	else
	{
		printk("<1> spartan device with major number %d unregistered succesfully \n", pspartan_dev.major);
		return ;
	} 
}

MODULE_LICENSE("GPL") ;
