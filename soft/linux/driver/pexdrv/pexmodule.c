
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/ioport.h>
#include <linux/list.h>
#include <linux/pci.h>
#include <linux/proc_fs.h>
#include <linux/interrupt.h>
#include <asm/io.h>

#include <asm/uaccess.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/poll.h>
#include <linux/pci.h>
#include <linux/interrupt.h>

#include "pexmodule.h"
#include "hardware.h"
#include "pexioctl.h"
#include "ioctlrw.h"
#include "ambpexregs.h"
#include "pexproc.h"

//-----------------------------------------------------------------------------

MODULE_AUTHOR("Vladimir Karakozov. karakozov@gmail.com");
MODULE_LICENSE("GPL");

//-----------------------------------------------------------------------------

static dev_t devno = MKDEV(0, 0);
static struct class *pex_class = NULL;
static LIST_HEAD(device_list);
static int boards_count = 0;
static struct mutex pex_mutex;
int dbg_trace = 1;
int err_trace = 1;

//-----------------------------------------------------------------------------

static int free_memory(struct pex_device *brd)
{
    struct list_head *pos, *n;
    struct mem_t *m = NULL;
    int unlocked = 0;

    spin_lock(&brd->m_MemListLock);

    list_for_each_safe(pos, n, &brd->m_MemList) {

        m = list_entry(pos, struct mem_t, list);

        unlocked = unlock_pages(m->cpu_addr, m->size);

        dma_free_coherent(&brd->m_pci->dev, m->size, m->cpu_addr, m->dma_handle);

        dbg_msg(dbg_trace, "%s(): %d: PA = 0x%zx, VA = %p, SZ = 0x%zx, PAGES = %d\n",
                __FUNCTION__, atomic_read(&brd->m_MemListCount), (size_t)m->dma_handle, m->cpu_addr, m->size, unlocked );

        list_del(pos);

        atomic_dec(&brd->m_MemListCount);

        kfree(m);
    }

    spin_unlock(&brd->m_MemListLock);

    return 0;
}

//-----------------------------------------------------------------------------

static struct pex_device *file_to_device( struct file *file )
{
    return (struct pex_device*)file->private_data;
}

//-----------------------------------------------------------------------------

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
static struct pex_device *inode_to_device( struct list_head *head, struct inode *inode )
{
    struct list_head *p;
    struct pex_device *entry;
    unsigned int minor = MINOR(inode->i_rdev);

    list_for_each(p, head) {
        entry = list_entry(p, struct pex_device, m_list);
        if(entry->m_BoardIndex == minor)
            return entry;
    }

    return NULL;
}
#endif

//-----------------------------------------------------------------------------

static int pex_device_fasync(int fd, struct file *file, int mode)
{
    struct pex_device *pDevice = file->private_data;
    if(!pDevice)
        return -ENODEV;

    return 0;
}

//-----------------------------------------------------------------------------

static unsigned int pex_device_poll(struct file *filp, poll_table *wait)
{
    unsigned int mask = 0;

    struct pex_device *pDevice = file_to_device(filp);
    if(!pDevice)
        return -ENODEV;

    return mask;
}

//-----------------------------------------------------------------------------

static int pex_device_open( struct inode *inode, struct file *file )
{
    struct pex_device *pDevice = container_of(inode->i_cdev, struct pex_device, m_cdev);
    if(!pDevice) {
        err_msg(err_trace, "%s(): Open device failed\n", __FUNCTION__);
        return -ENODEV;
    }

    file->private_data = (void*)pDevice;

    dbg_msg(dbg_trace, "%s(): Open device %s\n", __FUNCTION__, pDevice->m_name);

    return 0;
}

//-----------------------------------------------------------------------------

static int pex_device_close( struct inode *inode, struct file *file )
{
    struct pex_device *pDevice = container_of(inode->i_cdev, struct pex_device, m_cdev);
    if(!pDevice) {
        err_msg(err_trace, "%s(): Close device failed\n", __FUNCTION__);
        return -ENODEV;
    }

    file->private_data = NULL;

    dbg_msg(dbg_trace, "%s(): Close device %s\n", __FUNCTION__, pDevice->m_name);

    return 0;
}

//-----------------------------------------------------------------------------

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,37)
static long pex_device_ioctl( struct file *file, unsigned int cmd, unsigned long arg )
#else
static int pex_device_ioctl( struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg )
#endif
{
    int error = 0;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,37)
    struct pex_device *pDevice = file_to_device(file);
#else
    struct pex_device *pDevice = inode_to_device(&device_list, inode);
#endif
    if(!pDevice) {
        err_msg(err_trace, "%s(): ioctl device failed\n", __FUNCTION__);
        return -ENODEV;
    }

    mutex_lock(&pDevice->m_BoardMutex);

    switch(cmd) {
    case IOCTL_PEX_BOARD_INFO:
        error = ioctl_board_info(pDevice, arg);
        break;
    case IOCTL_PEX_MEM_ALLOC:
        error = ioctl_memory_alloc(pDevice, arg);
        break;
    case IOCTL_PEX_MEM_FREE:
        error = ioctl_memory_free(pDevice, arg);
        break;
    case IOCTL_PEX_STUB_ALLOC:
        error = ioctl_stub_alloc(pDevice, arg);
        break;
    case IOCTL_PEX_STUB_FREE:
        error = ioctl_stub_free(pDevice, arg);
        break;
    case IOCTL_AMB_SET_MEMIO:
        error = ioctl_set_mem(pDevice, arg);
        break;
    case IOCTL_AMB_FREE_MEMIO:
        error = ioctl_free_mem(pDevice, arg);
        break;
    case IOCTL_AMB_START_MEMIO:
        error = ioctl_start_mem(pDevice, arg);
        break;
    case IOCTL_AMB_STOP_MEMIO:
        error = ioctl_stop_mem(pDevice, arg);
        break;
    case IOCTL_AMB_STATE_MEMIO:
        error = ioctl_state_mem(pDevice, arg);
        break;
    case IOCTL_AMB_WAIT_DMA_BUFFER:
        error = ioctl_wait_dma_buffer(pDevice, arg);
        break;
    case IOCTL_AMB_WAIT_DMA_BLOCK:
        error = ioctl_wait_dma_block(pDevice, arg);
        break;
    case IOCTL_AMB_SET_SRC_MEM:
        error = ioctl_set_src_mem(pDevice, arg);
        break;
    case IOCTL_AMB_SET_DIR_MEM:
        error = ioctl_set_dir_mem(pDevice, arg);
        break;
    case IOCTL_AMB_SET_DRQ_MEM:
        error = ioctl_set_drq_mem(pDevice, arg);
        break;
    case IOCTL_AMB_RESET_FIFO:
        error = ioctl_reset_fifo(pDevice, arg);
        break;
    case IOCTL_AMB_DONE:
        error = ioctl_done(pDevice, arg);
        break;
    case IOCTL_AMB_ADJUST:
        error = ioctl_adjust(pDevice, arg);
        break;

    default:
        dbg_msg(dbg_trace, "%s(): Unknown command\n", __FUNCTION__);
        error = -EINVAL;
        break;
    }

    mutex_unlock(&pDevice->m_BoardMutex);

    return error;
}

//-----------------------------------------------------------------------------

static inline int private_mapping_ok(struct vm_area_struct *vma)
{
    return vma->vm_flags & VM_MAYSHARE;
}

//-----------------------------------------------------------------------------

static int pex_device_mmap(struct file *file, struct vm_area_struct *vma)
{
    size_t size = vma->vm_end - vma->vm_start;

    if (!private_mapping_ok(vma))
        return -ENOSYS;

    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

    if (remap_pfn_range(vma,
                        vma->vm_start,
                        vma->vm_pgoff,
                        size,
                        vma->vm_page_prot)) {
        err_msg(err_trace, "%s(): error in remap_page_range.\n", __FUNCTION__ );
        return -EAGAIN;
    }
    return 0;
}

//-----------------------------------------------------------------------------

static ssize_t pex_device_aio_read(struct kiocb *iocb, const struct iovec *iov, unsigned long count, loff_t off)
{
    struct pex_device *pDevice = file_to_device(iocb->ki_filp);
    if(!pDevice) {
        err_msg(err_trace, "%s(): ioctl device failed\n", __FUNCTION__);
        return -ENODEV;
    }
    return -ENOSYS;
}

//-----------------------------------------------------------------------------

static ssize_t pex_device_aio_write(struct kiocb *iocb, const struct iovec *iov, unsigned long count, loff_t off)
{
    struct pex_device *pDevice = file_to_device(iocb->ki_filp);
    if(!pDevice) {
        err_msg(err_trace, "%s(): ioctl device failed\n", __FUNCTION__);
        return -ENODEV;
    }
    return -ENOSYS;
}

//-----------------------------------------------------------------------------

static irqreturn_t pex_device_isr( int irq, void *pContext )
{
    FIFO_STATUS FifoStatus;  //

    struct pex_device* pDevice = (struct pex_device*)pContext;            // our device

    if(!pDevice->m_DmaIrqEnbl && !pDevice->m_FlgIrqEnbl)
        return IRQ_NONE;

    if(pDevice->m_FlgIrqEnbl)
    {  // прерывание от флагов состояния
        /*
            u32 status = ReadOperationWordReg(pDevice, PEMAINadr_BRD_STATUS);
            err_msg(err_trace, "%s(): BRD_STATUS = 0x%X.\n", __FUNCTION__, status);
            if(status & 0x4000)
            {
                    for(int i = 0; i < NUM_TETR_IRQ; i++)
                            if(pDevice->m_TetrIrq[i] != 0)
                            {
                                    u32 status = ReadAmbMainReg(pDevice, pDevice->m_TetrIrq[i].Address);
                                    KdPrint(("CWambpex::WambpexIsr: TetrIrq = %d, Address = 0x%X, IrqInv = 0x%X, IrqMask = 0x%X, Status = 0x%X.\n",
                                                            i, pDevice->m_TetrIrq[i].Address, pDevice->m_TetrIrq[i].IrqInv, pDevice->m_TetrIrq[i].IrqMask, status));
                                    status ^= pDevice->m_TetrIrq[i].IrqInv;
                                    status &= pDevice->m_TetrIrq[i].IrqMask;
                                    KdPrint(("CWambpex::WambpexIsr: TetrIrq = %d, Address = 0x%X, IrqInv = 0x%X, IrqMask = 0x%X, Status = 0x%X.\n",
                                                            i, pDevice->m_TetrIrq[i].Address, pDevice->m_TetrIrq[i].IrqInv, pDevice->m_TetrIrq[i].IrqMask, status));
                                    if(status)
                                    {
                                            KeInsertQueueDpc(&pDevice->m_TetrIrq[i].Dpc, NULL, NULL);
                                            KdPrint(("CWambpex::WambpexIsr - Tetrad IRQ address = %d\n", pDevice->m_TetrIrq[i].Address));
                                            // сброс статусного бита, вызвавшего прерывание
                                            //pDevice->WriteAmbMainReg(pDevice->m_TetrIrq[i].Address + 0x200);
                                            ULONG CmdAddress = pDevice->m_TetrIrq[i].Address + TRDadr_CMD_ADR * REG_SIZE;
                                            pDevice->WriteAmbMainReg(CmdAddress, 0);
                                            ULONG DataAddress = pDevice->m_TetrIrq[i].Address + TRDadr_CMD_DATA * REG_SIZE;
                                            ULONG Mode0Value = pDevice->ReadAmbMainReg(DataAddress);
                                            Mode0Value &= 0xFFFB;
                                            //pDevice->WriteAmbMainReg(CmdAddress, 0);
                                            pDevice->WriteAmbMainReg(DataAddress, Mode0Value);
                                            break;
                                    }
                            }
                return IRQ_HANDLED;
            }
            else // вообще не наше прерывание !!!
                    return IRQ_NONE;	// we did not interrupt
            */
    }

    if(pDevice->m_DmaIrqEnbl)
    {	// прерывание от каналов ПДП
        u32 i=0;
        u32 FifoAddr = 0;
        u32 iChan = pDevice->m_primChan;
        u32 NumberOfChannel = -1;

        for(i = 0; i < MAX_NUMBER_OF_DMACHANNELS; i++)
        {
            if(pDevice->m_DmaChanMask & (1 << iChan))
            {
                FifoAddr = pDevice->m_FifoAddr[iChan];
                FifoStatus.AsWhole = ReadOperationWordReg(pDevice, PEFIFOadr_FIFO_STATUS + FifoAddr);
                if(FifoStatus.ByBits.IntRql)
                {
                    //err_msg(err_trace, "%s(): - Channel = %d, Fifo Status = 0x%X\n", __FUNCTION__, iChan, FifoStatus.AsWhole);
                    NumberOfChannel = iChan;
                    pDevice->m_primChan = ((pDevice->m_primChan+1) >= MAX_NUMBER_OF_DMACHANNELS) ? 0 : pDevice->m_primChan+1;
                    break;
                }
            }
            iChan = ((iChan+1) >= MAX_NUMBER_OF_DMACHANNELS) ? 0 : iChan+1;
        }

        if(NumberOfChannel != -1)
        {
            u32 flag = 0;

            //err_msg(err_trace, "%s(%d)\n", __FUNCTION__, atomic_read(&pDevice->m_TotalIRQ));

            flag = NextDmaTransfer(pDevice->m_DmaChannel[NumberOfChannel]);
            //if(!flag)
            if( 0 )
            {
                DMA_CTRL_EXT CtrlExt;
                CtrlExt.AsWhole = 0;
                CtrlExt.ByBits.Pause = 1;
                CtrlExt.ByBits.Start = 1;
                WriteOperationWordReg(pDevice, PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
                //err_msg(err_trace, "%s(): - Pause (%d) - m_CurBlockNum = %d, m_DoneBlock = %d\n", __FUNCTION__, atomic_read(&pDevice->m_TotalIRQ),
                //        pDevice->m_DmaChannel[NumberOfChannel]->m_CurBlockNum,
                //        pDevice->m_DmaChannel[NumberOfChannel]->m_DoneBlock);
            }

            //err_msg(err_trace, "%s(): - Flag Clear\n", __FUNCTION__);
            WriteOperationWordReg(pDevice, PEFIFOadr_FLAG_CLR + FifoAddr, 0x10);
            WriteOperationWordReg(pDevice, PEFIFOadr_FLAG_CLR + FifoAddr, 0x00);
            //err_msg(err_trace, "%s(): - Complete\n", __FUNCTION__);

            atomic_inc(&pDevice->m_TotalIRQ);

            return IRQ_HANDLED;
        }
    }
    return IRQ_NONE;	// we did not interrupt
}

//-----------------------------------------------------------------------------

struct file_operations pex_fops = {

    .owner = THIS_MODULE,
    .read = NULL,
    .write = NULL,

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,37)
    .unlocked_ioctl = pex_device_ioctl,
    .compat_ioctl = pex_device_ioctl,
#else
    .ioctl = pex_device_ioctl,
#endif

    .mmap = pex_device_mmap,
    .open = pex_device_open,
    .release = pex_device_close,
    .fasync = pex_device_fasync,
    .poll = pex_device_poll,
    .aio_read =  pex_device_aio_read,
    .aio_write = pex_device_aio_write,
};

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

static const struct pci_device_id pex_device_id[] = {
{
        .vendor =       INSYS_VENDOR_ID,
        .device =       AMBPEX5_DEVID,
        .subvendor =    PCI_ANY_ID,
        .subdevice =    PCI_ANY_ID,
},

{ },
};

MODULE_DEVICE_TABLE(pci, pex_device_id);

//-----------------------------------------------------------------------------

static int pex_device_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
    int error = 0;
    int i = 0;
    struct pex_device *brd = NULL;

    mutex_lock(&pex_mutex);

    brd = kzalloc(sizeof(struct pex_device), GFP_KERNEL);
    if(!brd) {
        error = -ENOMEM;
        goto do_out;
    }

    INIT_LIST_HEAD(&brd->m_list);
    mutex_init(&brd->m_BoardMutex);
    sema_init(&brd->m_BoardSem, 1);
    spin_lock_init(&brd->m_BoardLock);
    atomic_set(&brd->m_TotalIRQ, 0);
    init_waitqueue_head(&brd->m_WaitQueue);
    init_timer(&brd->m_TimeoutTimer);
    spin_lock_init(&brd->m_MemListLock);
    atomic_set(&brd->m_MemListCount, 0);
    INIT_LIST_HEAD(&brd->m_MemList);
    brd->m_pci = dev;
    brd->m_Interrupt = -1;
    brd->m_DmaIrqEnbl = 0;
    brd->m_FlgIrqEnbl = 0;
    brd->m_class = pex_class;

    set_device_name(brd, dev->device, boards_count);

    dbg_msg(dbg_trace, "%s(): device_id = %x, vendor_id = %x, board name %s\n", __FUNCTION__, dev->device, dev->vendor, brd->m_name);

    error = pci_enable_device(dev);
    if(error) {
        err_msg(err_trace, "%s(): error enabling pci device\n", __FUNCTION__);
        goto do_free_memory;
    }

    if (pci_set_dma_mask(dev, DMA_BIT_MASK(64)) || pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(64))) {
        printk("%s(): error set pci dma mask\n", __FUNCTION__);
        goto do_disable_device;
    }

    pci_set_master(dev);

    brd->m_BAR0.physical_address = pci_resource_start(dev, 0);
    brd->m_BAR0.size = pci_resource_len(dev, 0);
    brd->m_BAR0.virtual_address = ioremap_nocache(brd->m_BAR0.physical_address, brd->m_BAR0.size);
    if(!brd->m_BAR0.virtual_address) {
        error = -ENOMEM;
        err_msg(err_trace, "%s(): error map device memory at bar%d\n", __FUNCTION__, 0);
        goto do_disable_device;
    }

    dbg_msg(dbg_trace, "%s(): map bar0 %zx -> %p\n", __FUNCTION__, brd->m_BAR0.physical_address, brd->m_BAR0.virtual_address);

    brd->m_BAR1.physical_address = pci_resource_start(dev, 1);
    brd->m_BAR1.size = pci_resource_len(dev, 1);
    brd->m_BAR1.virtual_address = ioremap_nocache(brd->m_BAR1.physical_address, brd->m_BAR1.size);
    if(!brd->m_BAR1.virtual_address) {
        error = -ENOMEM;
        err_msg(err_trace, "%s(): error map device memory at bar%d\n", __FUNCTION__, 0);
        goto do_unmap_bar0;
    }

    dbg_msg(dbg_trace, "%s(): map bar1 %zx -> %p\n", __FUNCTION__, brd->m_BAR1.physical_address, brd->m_BAR1.virtual_address);

    error = request_irq(dev->irq, pex_device_isr, IRQF_SHARED, brd->m_name, brd);
    if( error < 0) {
        error = -EBUSY;
        err_msg( err_trace, "%s(): error in request_irq()\n", __FUNCTION__ );
        goto do_unmap_bar1;
    }

    brd->m_Interrupt = dev->irq;

    cdev_init(&brd->m_cdev, &pex_fops);
    brd->m_cdev.owner = THIS_MODULE;
    brd->m_cdev.ops = &pex_fops;
    brd->m_devno = MKDEV(MAJOR(devno), boards_count);

    error = cdev_add(&brd->m_cdev, brd->m_devno, 1);
    if(error) {
        err_msg(err_trace, "%s(): Error add char device %d\n", __FUNCTION__, boards_count);
        error = -EINVAL;
        goto do_free_irq;
    }

    dbg_msg(dbg_trace, "%s(): Add cdev %d\n", __FUNCTION__, boards_count);

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27)
    brd->m_device = device_create(pex_class, NULL, brd->m_devno, "%s%d", "pexdrv", boards_count);
#else
    brd->m_device = device_create(pex_class, NULL, brd->m_devno, NULL, "%s%d", "pexdrv", boards_count);
#endif
    if(!brd->m_device ) {
        err_msg(err_trace, "%s(): Error create device for board: %s\n", __FUNCTION__, brd->m_name);
        error = -EINVAL;
        goto do_delete_cdev;
    }

    dbg_msg(dbg_trace, "%s(): Create device file for board: %s\n", __FUNCTION__, brd->m_name);

    brd->m_BoardIndex = boards_count;

    InitializeBoard(brd);

    for(i = 0; i < MAX_NUMBER_OF_DMACHANNELS; i++) {

        if(brd->m_DmaChanMask & (1 << i)) {

            brd->m_DmaChannel[i] = CDmaChannelCreate( i,  brd,
                                                      &brd->m_pci->dev,
                                                      brd->m_MaxDmaSize[i],
                                                      brd->m_BlockFifoId[i], 1 );
        }
    }

    pex_register_proc(brd->m_name, pex_proc_info, brd);

    list_add_tail(&brd->m_list, &device_list);

    boards_count++;

    dbg_msg(dbg_trace, "%s(): Board %s - setup complete\n", __FUNCTION__, brd->m_name);

    mutex_unlock(&pex_mutex);

    return error;

do_delete_cdev:
    cdev_del(&brd->m_cdev);

do_free_irq:
    free_irq(brd->m_Interrupt, brd);

do_unmap_bar1:
    iounmap(brd->m_BAR1.virtual_address);

do_unmap_bar0:
    iounmap(brd->m_BAR0.virtual_address);


do_disable_device:
    pci_disable_device(dev);

do_free_memory:
    kfree(brd);

do_out:
    mutex_unlock(&pex_mutex);

    return error;
}

//-----------------------------------------------------------------------------

static void pex_device_remove(struct pci_dev *dev)
{
    struct list_head *pos, *n;
    struct pex_device *brd = NULL;
    int i = 0;

    dbg_msg(dbg_trace, "%s(): device_id = %x, vendor_id = %x\n", __FUNCTION__, dev->device, dev->vendor);

    mutex_lock(&pex_mutex);

    list_for_each_safe(pos, n, &device_list) {

        brd = list_entry(pos, struct pex_device, m_list);

        if(brd->m_pci == dev) {

            free_irq(brd->m_Interrupt, brd);
            dbg_msg(dbg_trace, "%s(): free_irq() - complete\n", __FUNCTION__);
            pex_remove_proc(brd->m_name);
            dbg_msg(dbg_trace, "%s(): pex_remove_proc() - complete\n", __FUNCTION__);
            for(i = 0; i < MAX_NUMBER_OF_DMACHANNELS; i++) {
                if(brd->m_DmaChannel[i]) {
                     CDmaChannelDelete(brd->m_DmaChannel[i]);
                     dbg_msg(dbg_trace, "%s(): free DMA channel %d - complete\n", __FUNCTION__, i);
                }
            }
            free_memory(brd);
            dbg_msg(dbg_trace, "%s(): free_memory() - complete\n", __FUNCTION__);
            device_destroy(pex_class, brd->m_devno);
            dbg_msg(dbg_trace, "%s(): device_destroy() - complete\n", __FUNCTION__);
            cdev_del(&brd->m_cdev);
            dbg_msg(dbg_trace, "%s(): cdev_del() - complete\n", __FUNCTION__);
            iounmap(brd->m_BAR1.virtual_address);
            dbg_msg(dbg_trace, "%s(): iounmap() - complete\n", __FUNCTION__);
            iounmap(brd->m_BAR0.virtual_address);
            dbg_msg(dbg_trace, "%s(): iounmap() - complete\n", __FUNCTION__);
            pci_disable_device(dev);
            dbg_msg(dbg_trace, "%s(): pci_disable_device() - complete\n", __FUNCTION__);
            list_del(pos);
            dbg_msg(dbg_trace, "%s(): list_del() - complete\n", __FUNCTION__);
            kfree(brd);
            dbg_msg(dbg_trace, "%s(): kfree() - complete\n", __FUNCTION__);
        }
    }

    mutex_unlock(&pex_mutex);
}

//-----------------------------------------------------------------------------

static struct pci_driver pex_pci_driver = {

    .name = PEX_DRIVER_NAME,
    .id_table = pex_device_id,
    .probe = pex_device_probe,
    .remove = pex_device_remove,
};

//-----------------------------------------------------------------------------

static int __init pex_module_init(void)
{
    int error = 0;

    dbg_msg(dbg_trace, "%s()\n", __FUNCTION__);

    mutex_init(&pex_mutex);

    error = alloc_chrdev_region(&devno, 0, MAX_PEXDEVICE_SUPPORT, PEX_DRIVER_NAME);
    if(error < 0) {
        err_msg(err_trace, "%s(): Erorr allocate char device regions\n", __FUNCTION__);
        goto do_out;
    }

    dbg_msg(dbg_trace, "%s(): Allocate %d device numbers. Major number = %d\n", __FUNCTION__, MAX_PEXDEVICE_SUPPORT, MAJOR(devno));

    pex_class = class_create(THIS_MODULE, PEX_DRIVER_NAME);
    if(!pex_class) {
        err_msg(err_trace, "%s(): Erorr allocate char device regions\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_chrdev;
    }

    error = pci_register_driver(&pex_pci_driver);
    if(error < 0) {
        err_msg(err_trace, "%s(): Erorr register pci driver\n", __FUNCTION__);
        error = -EINVAL;
        goto do_delete_class;
    }

    return 0;

do_delete_class:
    class_destroy(pex_class);

do_free_chrdev:
    unregister_chrdev_region(devno, MAX_PEXDEVICE_SUPPORT);

do_out:
    return error;
}

//-----------------------------------------------------------------------------

static void __exit pex_module_cleanup(void)
{
    dbg_msg(dbg_trace, "%s()\n", __FUNCTION__);

    pci_unregister_driver(&pex_pci_driver);

    if(pex_class)
        class_destroy(pex_class);

    unregister_chrdev_region(devno, MAX_PEXDEVICE_SUPPORT);
}

//-----------------------------------------------------------------------------

module_init(pex_module_init);
module_exit(pex_module_cleanup);

//-----------------------------------------------------------------------------
