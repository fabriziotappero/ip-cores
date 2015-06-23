
#include <linux/kernel.h>
#define __NO_VERSION__
#include <linux/module.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/pagemap.h>
#include <linux/interrupt.h>
#include <linux/proc_fs.h>
//#include <linux/atomic.h>
#include <asm/io.h>

#include "pexmodule.h"
#include "pexioctl.h"
#include "hardware.h"
#include "ambpexregs.h"
#include "brd_info.h"

//--------------------------------------------------------------------

int ioctl_board_info(struct pex_device *brd, unsigned long arg)
{
    struct board_info bi;
    int error = 0;

    down(&brd->m_BoardSem);

    dbg_msg(dbg_trace, "%s(): get board information\n", __FUNCTION__);

    memset(&bi, 0, sizeof(struct board_info));

    bi.PhysAddress[0] = brd->m_BAR0.physical_address;
    bi.VirtAddress[0] = brd->m_BAR0.virtual_address;
    bi.Size[0] = brd->m_BAR0.size;

    bi.PhysAddress[1] = brd->m_BAR1.physical_address;
    bi.VirtAddress[1] = brd->m_BAR1.virtual_address;
    bi.Size[1] = brd->m_BAR1.size;

    bi.InterruptLevel = 0;
    bi.InterruptVector = brd->m_Interrupt;
    bi.vendor_id = brd->m_pci->vendor;
    bi.device_id = brd->m_pci->device;

    if(copy_to_user((void*)arg, &bi, sizeof(struct board_info))) {
        err_msg(err_trace, "%s(): Error copy board info to user space\n", __FUNCTION__);
        error = -EINVAL;
    }

    up(&brd->m_BoardSem);

    return error;
}

//--------------------------------------------------------------------

int ioctl_memory_alloc(struct pex_device *brd, unsigned long arg)
{
    struct memory_block mb = {0};
    dma_addr_t dma_handle = {0};
    int error = 0;
    int i = 0;

    down(&brd->m_BoardSem);

    if(copy_from_user((void*)&mb, (void*)arg, sizeof(struct memory_block))) {
        err_msg(err_trace, "%s(): Error copy block descriptor from user space\n", __FUNCTION__);
        error = -EINVAL;
        goto do_exit;
    }

    if(mb.size == 0) {
        err_msg(err_trace, "%s(): Invalid block size.\n", __FUNCTION__);
        goto do_exit;
    }

    mb.virt = allocate_memory_block(brd, mb.size, &dma_handle);
        if(!mb.virt) {
            err_msg(err_trace, "%s(): Error allocate block %d.\n", __FUNCTION__, i);
            error = -ENOMEM;
            goto do_exit;
        }
        mb.phys = dma_handle;

    if(copy_to_user((void*)arg, &mb, sizeof(struct memory_block))) {
        err_msg(err_trace, "%s(): Error copy block descriptor to user space\n", __FUNCTION__);
        error = -EINVAL;
    }

do_exit:
    up(&brd->m_BoardSem);

    return error;
}

//--------------------------------------------------------------------

int ioctl_memory_free(struct pex_device *brd, unsigned long arg)
{
    struct memory_block mb = {0};
    int error = 0;
    int i = 0;

    down(&brd->m_BoardSem);

    if(copy_from_user((void*)&mb, (void*)arg, sizeof(struct memory_block))) {
        err_msg(err_trace, "%s(): Error copy block descriptor from user space\n", __FUNCTION__);
        error = -EINVAL;
        goto do_exit;
    }

    if(mb.size == 0 || mb.phys == 0 || mb.virt == 0) {
        err_msg(err_trace, "%s(): Invalid block parameters.\n", __FUNCTION__);
        goto do_exit;
    }

    error = free_memory_block(brd, mb);
    if(error < 0) {
        err_msg(err_trace, "%s(): Error free block %d.\n", __FUNCTION__, i);
        goto do_exit;
    }

do_exit:
    up(&brd->m_BoardSem);

    return error;
}

//--------------------------------------------------------------------

int ioctl_stub_alloc(struct pex_device *brd, unsigned long arg)
{
/*
    struct stub_descriptor stub = {0};
    struct dma_channel *dma = NULL;
    void *cpu_addr = NULL;
    dma_addr_t dma_handle = {0};
    int locked = 0;
    int error = -EINVAL;

    down(&brd->m_BoardSem);

    if(copy_from_user((void*)&stub, (void*)arg, sizeof(struct stub_descriptor))) {
        err_msg(err_trace, "%s(): Error copy stub descriptor from user space\n", __FUNCTION__);
        error = -EINVAL;
        goto do_exit;
    }

    if(stub.dma_channel >= MAX_NUMBER_OF_DMACHANNELS) {
        err_msg(err_trace, "%s(): Invalid DMA channel number.\n", __FUNCTION__);
        error = -EINVAL;
        goto do_exit;
    }

    dma = &brd->m_DMA[stub.dma_channel];

    spin_lock(&dma->m_MemListLock);

    cpu_addr = dma_alloc_coherent(&dma->m_pci->dev, PAGE_SIZE, &dma_handle, GFP_KERNEL);
    if(!cpu_addr) {
        err_msg(err_trace, "%s(): Error allocate physical memory for stub.\n", __FUNCTION__);
        error = -ENOMEM;
        goto do_unlock;
    }

    dma->m_MemStub.dma_handle = dma_handle;
    dma->m_MemStub.cpu_addr = cpu_addr;
    dma->m_MemStub.size = PAGE_SIZE;

    stub.stub.phys = dma_handle;
    stub.stub.size = PAGE_SIZE;
    stub.stub.virt = NULL;

    locked = lock_pages(dma->m_MemStub.cpu_addr, dma->m_MemStub.size);

    dbg_msg(dbg_trace, "%s(): PA = 0x%zx, VA = %p, SZ = 0x%zx, PAGES = %d\n",
            __FUNCTION__, (size_t)dma->m_MemStub.dma_handle, dma->m_MemStub.cpu_addr, dma->m_MemStub.size, locked );

    if(copy_to_user((void*)arg, &stub, sizeof(struct stub_descriptor))) {
        err_msg(err_trace, "%s(): Error copy stub descriptor to user space\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_mem;
    }

    spin_unlock(&dma->m_MemListLock);

    return 0;

do_free_mem:
    dma_free_coherent(&dma->m_pci->dev, PAGE_SIZE, cpu_addr, dma_handle);

do_unlock:
    spin_unlock(&dma->m_MemListLock);

do_exit:
    up(&brd->m_BoardSem);

    return error;
*/
    return -ENOSYS;
}

//--------------------------------------------------------------------

int ioctl_stub_free(struct pex_device *brd, unsigned long arg)
{
    down(&brd->m_BoardSem);

    dbg_msg(err_trace, "%s(): ioctl not implemented.\n", __FUNCTION__);

    up(&brd->m_BoardSem);

    return -ENOSYS;
}

//--------------------------------------------------------------------

int ioctl_set_mem(struct pex_device *brd, unsigned long arg)
{
    int error = 0;
    u32 i = 0;
    u32 AdmNumber = 0;
    u32 TetrNumber = 0;
    u32 Address = 0;
    u32 tmpSize = 0;
    struct CDmaChannel *dma = NULL;
    AMB_MEM_DMA_CHANNEL MemDscr = {0};
    PAMB_MEM_DMA_CHANNEL pKernMemDscr = NULL;
    PAMB_MEM_DMA_CHANNEL pUserMemDscr = &MemDscr;

    down(&brd->m_BoardSem);

    dbg_msg(dbg_trace, "%s(): Started\n", __FUNCTION__);

    if( copy_from_user((void *)pUserMemDscr, (void *)arg, sizeof(AMB_MEM_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy descriptor from user space\n", __FUNCTION__);
        error = -EFAULT;
        goto do_exit;
    }

    tmpSize = sizeof(AMB_MEM_DMA_CHANNEL)+(pUserMemDscr->BlockCnt-1)*sizeof(void*);

    pKernMemDscr = kzalloc(tmpSize, GFP_KERNEL);
    if(!pKernMemDscr) {
        err_msg(err_trace, "%s(): Error allocate descriptor in kernel space\n", __FUNCTION__);
        error = -ENOMEM;
        goto do_free_mem;
    }

    memcpy(pKernMemDscr, pUserMemDscr, tmpSize);

    if(pKernMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS) {
        err_msg(err_trace, "%s(): Invalid DMA channel number\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_mem;
    }

    if(!(brd->m_DmaChanMask & (1 << pKernMemDscr->DmaChanNum))) {
        err_msg(err_trace, "%s(): Invalid stream number\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_mem;
    }

    i = pKernMemDscr->DmaChanNum;
    dma = brd->m_DmaChannel[i];

    dbg_msg(dbg_trace, "%s(): 1\n", __FUNCTION__);

    error = SetDmaDirection(dma, pKernMemDscr->Direction);
    if(error != 0) {
        err_msg(err_trace, "%s(): Error in SetDmaDirection()\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_mem;
    }

    dbg_msg(dbg_trace, "%s(): 2\n", __FUNCTION__);

    Adjust(dma,0);

    dbg_msg(dbg_trace, "%s(): 3\n", __FUNCTION__);

    pKernMemDscr->BlockSize = (pKernMemDscr->BlockSize >> 12) << 12;
    if(!pKernMemDscr->BlockSize) {
        err_msg(err_trace, "%s(): BlockSize is zero\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_mem;
    }

    AdmNumber = pKernMemDscr->LocalAddr >> 16;
    TetrNumber = pKernMemDscr->LocalAddr & 0xff;
    Address = AdmNumber*ADM_SIZE + TetrNumber*TETRAD_SIZE + TRDadr_DATA*REG_SIZE;

    //SetDmaLocalAddress(dma, Address);
    //SetAdmTetr(dma, AdmNumber, TetrNumber);
    //error = SetDmaMode(brd, i, AdmNumber, TetrNumber);

    dbg_msg(dbg_trace, "%s(): 4\n", __FUNCTION__);

    error = RequestMemory( dma, pKernMemDscr->pBlock, pKernMemDscr->BlockSize,
                            (u32*)&pKernMemDscr->BlockCnt, &pKernMemDscr->pStub, pKernMemDscr->MemType );
    if(error < 0) {
        err_msg(err_trace, "%s(): Error in RequestMemory()\n", __FUNCTION__);
        error = -ENOMEM;
        goto do_free_mem;
    }

    dbg_msg(dbg_trace, "%s(): 5\n", __FUNCTION__);

    if(copy_to_user((void*)arg, (void*)pKernMemDscr, tmpSize)) {
        err_msg(err_trace, "%s(): Error copy descriptor to user space\n", __FUNCTION__);
        error = -EFAULT;
    }

do_free_mem:
    kfree(pKernMemDscr);

do_exit:
    up(&brd->m_BoardSem);

    return error;
}

//--------------------------------------------------------------------

int ioctl_free_mem(struct pex_device *brd, size_t arg)
{
    u32 i = 0;
    int error = 0;
    AMB_MEM_DMA_CHANNEL MemDscr = {0};
    PAMB_MEM_DMA_CHANNEL pMemDscr = &MemDscr;

    down(&brd->m_BoardSem);

    if( copy_from_user((void *)pMemDscr, (void *)arg, sizeof(AMB_MEM_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy descriptor from user space\n", __FUNCTION__);
        error = -EFAULT;
        goto do_exit;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS) {
        err_msg(err_trace, "%s(): Invalid DMA channel number\n", __FUNCTION__);
        error = -EINVAL;
        goto do_exit;
    }

    i = pMemDscr->DmaChanNum;
    ReleaseMemory(brd->m_DmaChannel[i]);

    if(copy_to_user (( void *)arg, (void *)&MemDscr, sizeof(AMB_MEM_DMA_CHANNEL) + (pMemDscr->BlockCnt - 1) * sizeof(void*) )) {
        err_msg(err_trace, "%s(): Error copy descriptor to user space\n", __FUNCTION__);
        error = -EFAULT;
        goto do_exit;
    }

do_exit:
    up(&brd->m_BoardSem);

    return error;
}

//--------------------------------------------------------------------

int ioctl_start_mem(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    AMB_START_DMA_CHANNEL StartDscr;
    PAMB_START_DMA_CHANNEL pStartDscr = &StartDscr;

    printk("<0>ioctl_start_mem: Entered.\n");
    down(&brd->m_BoardSem);

    if( copy_from_user((void *)&StartDscr, (void *)arg, sizeof(AMB_START_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pStartDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS) {
        printk("<0>%s(): too large stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    if(!(brd->m_DmaChanMask & (1 << pStartDscr->DmaChanNum))) {
        printk("<0>%s(): invalid stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    Status = StartDmaTransfer(brd->m_DmaChannel[pStartDscr->DmaChanNum], pStartDscr->IsCycling);
    Status = HwStartDmaTransfer(brd, pStartDscr->DmaChanNum);

    up(&brd->m_BoardSem);
    printk("<0>ioctl_start_mem: exit Status=0x%.8X \n", Status );

    return Status;
}

//--------------------------------------------------------------------

int ioctl_stop_mem(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i;
    AMB_STATE_DMA_CHANNEL StopDscr;
    PAMB_STATE_DMA_CHANNEL pStopDscr = &StopDscr;

    down(&brd->m_BoardSem);

    // get the user buffer
    if( copy_from_user((void *)&StopDscr, (void *)arg, sizeof(AMB_STATE_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    //printk("<0>IoctlStopMem: Entered.\n");

    if(pStopDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlStopMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pStopDscr->DmaChanNum;
    if(pStopDscr->Timeout)
        Status = WaitBlockEndEvent(brd->m_DmaChannel[i], pStopDscr->Timeout);
    else
        Status = 0;
    /*
        PIRP CurrentIrp = m_DmaChannel[i].GetQueueIrp();
        if(CurrentIrp)
                CancelIrp(CurrentIrp, WambpIrpCancelCallback);
*/
    HwCompleteDmaTransfer(brd, i);
    //FreezeState(brd->m_DmaChannel[i]);
    GetState( brd->m_DmaChannel[i], (u32*)&pStopDscr->BlockNum,
              (u32*)&pStopDscr->BlockCntTotal, (u32*)&pStopDscr->OffsetInBlock,
              (u32*)&pStopDscr->DmaChanState);

    if(copy_to_user (( void *)arg, (void *)&StopDscr, sizeof(AMB_STATE_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data to userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_state_mem(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i=0;
    AMB_STATE_DMA_CHANNEL StateDscr;
    PAMB_STATE_DMA_CHANNEL pStateDscr = &StateDscr;

    down(&brd->m_BoardSem);

    // get the user buffer
    if( copy_from_user((void *)&StateDscr, (void *)arg, sizeof(AMB_STATE_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    //printk("<0>IoctlStateMem: Entered.\n");

    if(pStateDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlStateMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pStateDscr->DmaChanNum;
    if(pStateDscr->Timeout)
        Status = WaitBlockEndEvent(brd->m_DmaChannel[i], pStateDscr->Timeout);
    else
        Status = 0;

    //FreezeState(brd->m_DmaChannel[i]);
    GetState(brd->m_DmaChannel[i], 	(u32*)&pStateDscr->BlockNum,
             (u32*)&pStateDscr->BlockCntTotal,
             (u32*)&pStateDscr->OffsetInBlock,
             (u32*)&pStateDscr->DmaChanState);

    if(copy_to_user (( void *)arg, (void *)&StateDscr, sizeof(AMB_STATE_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data to userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_set_dir_mem(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i;
    AMB_SET_DMA_CHANNEL MemDscr;
    PAMB_SET_DMA_CHANNEL pMemDscr = &MemDscr;

    printk("<0>IoctlSetDirMem: Entered.\n");
    down(&brd->m_BoardSem);

    // get the user buffer
    if( copy_from_user((void *)&MemDscr, (void *)arg, sizeof(AMB_SET_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlSetDirMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pMemDscr->DmaChanNum;
    Status = SetDmaDirection(brd->m_DmaChannel[i], pMemDscr->Param);

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_set_src_mem(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i;
    u32 AdmNumber = 0;
    u32 TetrNumber = 0;
    u32 Address = 0;
    AMB_SET_DMA_CHANNEL MemDscr;
    PAMB_SET_DMA_CHANNEL pMemDscr = &MemDscr;

    printk("<0>IoctlSetSrcMem: Entered.\n");
    down(&brd->m_BoardSem);

    // get the user buffer
    if( copy_from_user((void *)&MemDscr, (void *)arg, sizeof(AMB_SET_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlSetSrcMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pMemDscr->DmaChanNum;
    //AdmNumber = pMemDscr->Param >> 16;
    //TetrNumber = pMemDscr->Param & 0xff;
    //Address = AdmNumber * ADM_SIZE + TetrNumber * TETRAD_SIZE + TRDadr_DATA * REG_SIZE;

    AdmNumber=0;
    TetrNumber=0;
    Address = pMemDscr->Param;
    SetDmaLocalAddress(brd->m_DmaChannel[i], Address);
    SetAdmTetr(brd->m_DmaChannel[i], AdmNumber, TetrNumber);
    //Status = SetDmaMode(brd, i, AdmNumber, TetrNumber);
    Status=0;

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_set_drq_mem(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i;
    u32 AdmNum = 0;
    u32 TetrNum = 0;
    AMB_SET_DMA_CHANNEL MemDscr;
    PAMB_SET_DMA_CHANNEL pMemDscr = &MemDscr;

    down(&brd->m_BoardSem);

    //printk("<0>IoctlSetSrcMem: Entered.\n");

    // get the user buffer
    if( copy_from_user((void *)&MemDscr, (void *)arg, sizeof(AMB_SET_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlSetDrqMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pMemDscr->DmaChanNum;
    AdmNum = GetAdmNum( brd->m_DmaChannel[i] );
    TetrNum = GetTetrNum( brd->m_DmaChannel[i] );
    Status = SetDrqFlag( brd, AdmNum, TetrNum, pMemDscr->Param );

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_adjust(struct pex_device *brd, size_t arg)
{
    u32 i;
    AMB_SET_DMA_CHANNEL MemDscr;
    PAMB_SET_DMA_CHANNEL pMemDscr = &MemDscr;

    down(&brd->m_BoardSem);

    //printk("<0>%s()\n", __FUNCTION__);

    if( copy_from_user((void *)&MemDscr, (void *)arg, sizeof(AMB_SET_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlSetDrqMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }
    if(!(brd->m_DmaChanMask & (1 << pMemDscr->DmaChanNum)))
    {
        printk("<0>%s(): invalid stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pMemDscr->DmaChanNum;
    Adjust(brd->m_DmaChannel[i], pMemDscr->Param);

    up(&brd->m_BoardSem);

    return 0;
}

//--------------------------------------------------------------------

int ioctl_done(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i;
    u32 done_flag;
    AMB_SET_DMA_CHANNEL MemDscr;
    PAMB_SET_DMA_CHANNEL pMemDscr = &MemDscr;

    down(&brd->m_BoardSem);

    //printk("<0>%s()\n", __FUNCTION__);

    // get the user buffer
    if( copy_from_user((void *)&MemDscr, (void *)arg, sizeof(AMB_SET_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>IoctlSetDrqMem: too large stream number\n");
        up(&brd->m_BoardSem);
        return -EINVAL;
    }
    if(!(brd->m_DmaChanMask & (1 << pMemDscr->DmaChanNum)))
    {
        printk("<0>%s(): invalid stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pMemDscr->DmaChanNum;
    done_flag = SetDoneBlock(brd->m_DmaChannel[i], pMemDscr->Param);
    if(done_flag)
        Status = Done(brd, i);

    up(&brd->m_BoardSem);

    return 0;
}

//--------------------------------------------------------------------

int ioctl_reset_fifo(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    AMB_SET_DMA_CHANNEL MemDscr;
    PAMB_SET_DMA_CHANNEL pMemDscr = &MemDscr;

    down(&brd->m_BoardSem);

    // get the user buffer
    if( copy_from_user((void *)&MemDscr, (void *)arg, sizeof(AMB_SET_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(pMemDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>%s(): too large stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }
    if(!(brd->m_DmaChanMask & (1 << pMemDscr->DmaChanNum)))
    {
        printk("<0>%s(): invalid stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    Status = ResetFifo(brd, pMemDscr->DmaChanNum);

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_get_dma_channel_info(struct pex_device *brd, size_t arg)
{
    AMB_GET_DMA_INFO DmaInfo = {0};

    down(&brd->m_BoardSem);

    // get the user buffer
    if( copy_from_user((void *)&DmaInfo, (void *)arg, sizeof(AMB_GET_DMA_INFO))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    if(DmaInfo.DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>%s(): too large stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }
    if(!(brd->m_DmaChanMask & (1 << DmaInfo.DmaChanNum)))
    {
        printk("<0>%s(): invalid stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    DmaInfo.Direction = brd->m_DmaDir[DmaInfo.DmaChanNum];
    DmaInfo.FifoSize = brd->m_DmaFifoSize[DmaInfo.DmaChanNum];
    DmaInfo.MaxDmaSize = brd->m_MaxDmaSize[DmaInfo.DmaChanNum];

    if(copy_to_user (( void *)arg, (void *)&DmaInfo, sizeof(AMB_GET_DMA_INFO))) {
                err_msg(err_trace, "%s(): Error copy data to userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    up(&brd->m_BoardSem);

    return 0;
}

//--------------------------------------------------------------------

int ioctl_wait_dma_buffer(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i=0;
    AMB_STATE_DMA_CHANNEL StateDscr;
    PAMB_STATE_DMA_CHANNEL pStateDscr = &StateDscr;

    down ( &brd->m_BoardSem );

    // get the user buffer
    if( copy_from_user((void *)&StateDscr, (void *)arg, sizeof(AMB_STATE_DMA_CHANNEL))) {
                err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    //printk("<0>%s(): DMA %d\n", __FUNCTION__, pStateDscr->DmaChanNum);

    if(pStateDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>%s(): too large stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pStateDscr->DmaChanNum;

    Status = WaitBufferEndEvent(brd->m_DmaChannel[i], pStateDscr->Timeout);

    GetState(brd->m_DmaChannel[i], 	(u32*)&pStateDscr->BlockNum,
             (u32*)&pStateDscr->BlockCntTotal,
             (u32*)&pStateDscr->OffsetInBlock,
             (u32*)&pStateDscr->DmaChanState);

    if(copy_to_user (( void *)arg, (void *)&StateDscr, sizeof(AMB_STATE_DMA_CHANNEL))) {
                err_msg(err_trace, "%s(): Error copy data to userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------

int ioctl_wait_dma_block(struct pex_device *brd, size_t arg)
{
    int Status = -EINVAL;
    u32 i=0;
    AMB_STATE_DMA_CHANNEL StateDscr;
    PAMB_STATE_DMA_CHANNEL pStateDscr = &StateDscr;

    down ( &brd->m_BoardSem );

    // get the user buffer
    if( copy_from_user((void *)&StateDscr, (void *)arg, sizeof(AMB_STATE_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data from userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    printk("<0>%s(): DMA %d\n", __FUNCTION__, pStateDscr->DmaChanNum);

    if(pStateDscr->DmaChanNum >= MAX_NUMBER_OF_DMACHANNELS)
    {
        printk("<0>%s(): too large stream number\n", __FUNCTION__);
        up(&brd->m_BoardSem);
        return -EINVAL;
    }

    i = pStateDscr->DmaChanNum;

    Status = WaitBlockEndEvent(brd->m_DmaChannel[i], pStateDscr->Timeout);

    GetState(brd->m_DmaChannel[i], 	(u32*)&pStateDscr->BlockNum,
             (u32*)&pStateDscr->BlockCntTotal,
             (u32*)&pStateDscr->OffsetInBlock,
             (u32*)&pStateDscr->DmaChanState);

    if(copy_to_user (( void *)arg, (void *)&StateDscr, sizeof(AMB_STATE_DMA_CHANNEL))) {
        err_msg(err_trace, "%s(): Error copy data to userspace\n", __FUNCTION__ );
        up(&brd->m_BoardSem);
        return -EFAULT;
    }

    up(&brd->m_BoardSem);

    return Status;
}

//--------------------------------------------------------------------



