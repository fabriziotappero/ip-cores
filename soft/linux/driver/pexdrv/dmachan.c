
#include <linux/kernel.h>
#define __NO_VERSION__
#include <linux/module.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/interrupt.h>
#include <linux/pagemap.h>
#include <linux/interrupt.h>
#include <linux/proc_fs.h>
#include <asm/io.h>

#ifndef _EVENT_H_
#include "event.h"
#endif
#ifndef	 _DMA_CHAN_H_
#include "dmachan.h"
#endif
#ifndef	 _HARDWARE_H_
#include "hardware.h"
#endif

//-----------------------------------------------------------------------------

struct CDmaChannel* CDmaChannelCreate( 	u32 NumberOfChannel,
        void *brd,
        struct device	*dev,
        u32 cbMaxTransferLength,
        u16 idBlockFifo,
        int bScatterGather )
{
    struct CDmaChannel *dma = NULL;

    dma = kzalloc(sizeof(struct CDmaChannel), GFP_KERNEL);
    if(!dma) {
        printk("<0>%s(): Error allocate memory for CDmaChannel object\n", __FUNCTION__);
        return NULL;
    }

    dma->m_NumberOfChannel = NumberOfChannel;
    dma->m_Board = brd;
    dma->m_dev = dev;
    dma->m_UseCount = 0;
    dma->m_DpcForIsr = DmaDpcForIsr;
    dma->m_idBlockFifo = idBlockFifo;

    spin_lock_init( &dma->m_DmaLock );
    init_waitqueue_head( &dma->m_DmaWq );
    tasklet_init( &dma->m_Dpc, dma->m_DpcForIsr, (unsigned long)dma );
    InitKevent( &dma->m_BlockEndEvent );
    InitKevent( &dma->m_BufferEndEvent );

    //printk("<0>%s(%d): COMPLETE.\n", __FUNCTION__, dma->m_NumberOfChannel);

    return dma;
}

//-----------------------------------------------------------------------------

void CDmaChannelDelete(struct CDmaChannel *dma)
{
    //printk("<0>%s()\n", __FUNCTION__);
    if (dma) {
        tasklet_kill( &dma->m_Dpc );
        kfree(dma);
    }
}

//-----------------------------------------------------------------------------

int RequestMemory(struct CDmaChannel *dma, void** ppVirtAddr, u32 size, u32 *pCount, void** pStub, u32 bMemType)
{
    int Status = -ENOMEM;

    //printk("<0>%s(): Channel = %d\n", __FUNCTION__, dma->m_NumberOfChannel);

    // при первом обращении действительно выделяем память,
    // а при повторных только отображаем выделенную память на пользовательское пространство
    if(!dma->m_UseCount)
    {
        dma_addr_t pa = (dma_addr_t)0;

        dma->m_MemType = bMemType;
        dma->m_BlockCount = *pCount;
        dma->m_BlockSize = size;

        // выделяем память под описатели блоков (системный, и логический адрес для каждого блока)
        dma->m_pBufDscr.SystemAddress = (void*)dma_alloc_coherent( dma->m_dev,
                                                                   dma->m_BlockCount * sizeof(SHARED_MEMORY_DESCRIPTION),
                                                                   &pa, GFP_KERNEL);
        if(!dma->m_pBufDscr.SystemAddress)
        {
            printk("<0>%s(): Not memory for buffer descriptions\n", __FUNCTION__);
            return -ENOMEM;
        }

        dma->m_pBufDscr.LogicalAddress = (size_t)pa;
        dma->m_ScatterGatherTableEntryCnt = 0;
    }

    Status = RequestStub(dma, pStub);
    if(Status == 0)
    {
        if(dma->m_MemType == SYSTEM_MEMORY_TYPE) {
            Status = RequestSysBuf(dma, ppVirtAddr);
        } else {
            ReleaseStub(dma);
            dma_free_coherent(dma->m_dev,
                              dma->m_BlockCount * sizeof(SHARED_MEMORY_DESCRIPTION),
                              dma->m_pBufDscr.SystemAddress,
                              dma->m_pBufDscr.LogicalAddress);
            dma->m_pBufDscr.SystemAddress = NULL;
            dma->m_pBufDscr.LogicalAddress = 0;
            printk("<0>%s(): Invalid memory type for DMA data blocks\n", __FUNCTION__);
            return -EINVAL;
        }

        if(Status == 0)
        {
            if(!dma->m_UseCount)
            {
                //printk("<0>%s(): Scatter/Gather Table Entry is %d\n", __FUNCTION__, dma->m_ScatterGatherTableEntryCnt);
                if(dma->m_idBlockFifo == PE_EXT_FIFO_ID)
                    SetScatterGatherListExt(dma);
                else {
                    printk("<0>%s(): Scatter/Gather Table Entry not created\n", __FUNCTION__);
                    //SetScatterGatherList(dma);
                }
                *pCount = dma->m_BlockCount;
                dma->m_pStub = (PAMB_STUB)dma->m_StubDscr.SystemAddress;
                dma->m_pStub->lastBlock = -1;
                dma->m_pStub->totalCounter = 0;
                dma->m_pStub->offset = 0;
                dma->m_pStub->state = STATE_STOP;
            }
            dma->m_UseCount++;
        }
        else
        {
            ReleaseStub(dma);
            dma_free_coherent(dma->m_dev, dma->m_BlockCount * sizeof(SHARED_MEMORY_DESCRIPTION),
                              dma->m_pBufDscr.SystemAddress, dma->m_pBufDscr.LogicalAddress);
            dma->m_pBufDscr.SystemAddress = NULL;
            dma->m_pBufDscr.LogicalAddress = 0;
            printk("<0>%s(): Error allocate memory\n", __FUNCTION__);
            return -EINVAL;
        }
    }
    else
{
    if(!dma->m_UseCount)	{
        dma_free_coherent(dma->m_dev,
                          dma->m_BlockCount * sizeof(SHARED_MEMORY_DESCRIPTION),
                          dma->m_pBufDscr.SystemAddress, dma->m_pBufDscr.LogicalAddress);
        dma->m_pBufDscr.SystemAddress = NULL;
        dma->m_pBufDscr.LogicalAddress = 0;
    }
}
return Status;
}

//-----------------------------------------------------------------------------

void ReleaseMemory(struct CDmaChannel *dma)
{
    //printk("<0>%s(): Entered. Channel = %d\n", __FUNCTION__, dma->m_NumberOfChannel);

    if(!dma->m_UseCount) {
        printk("<0> %s: Memory not allocated.\n", __FUNCTION__);
        return;
    }

    ReleaseStub( dma );
    ReleaseSGList( dma );
    ReleaseSysBuf( dma );

    dma_free_coherent(dma->m_dev,
                      dma->m_BlockCount * sizeof(SHARED_MEMORY_DESCRIPTION),
                      dma->m_pBufDscr.SystemAddress, dma->m_pBufDscr.LogicalAddress);

    dma->m_pBufDscr.SystemAddress = NULL;
    dma->m_pBufDscr.LogicalAddress = 0;
    dma->m_UseCount--;
}

//-----------------------------------------------------------------------------

int SetScatterGatherListExt(struct CDmaChannel *dma)
{
    int Status = 0;
    u32 iBlock = 0;
    //u32 ii = 0;
    u32 iEntry = 0;
    u32 iBlkEntry = 0;
    u64 *pDscrBuf = NULL;
    u16* pNextDscr = NULL;
    u32 DscrSize = 0;
    SHARED_MEMORY_DESCRIPTION *pMemDscr = (SHARED_MEMORY_DESCRIPTION*)dma->m_pBufDscr.SystemAddress;
    DMA_CHAINING_DESCR_EXT	*pSGTEx = NULL;

    //printk("<0>%s()\n", __FUNCTION__);

    Status = RequestSGList(dma);
    if(Status < 0)
        return Status;

    //получим адрес таблицы для хранения цепочек DMA
    dma->m_pScatterGatherTableExt = (DMA_CHAINING_DESCR_EXT*)dma->m_SGTableDscr.SystemAddress;
    pSGTEx = dma->m_pScatterGatherTableExt;

    DscrSize = DSCR_BLOCK_SIZE*sizeof(DMA_CHAINING_DESCR_EXT);

    //обнулим таблицу дескрипторов DMA
    memset(pSGTEx, 0, dma->m_ScatterGatherBlockCnt*DscrSize);

    //printk("<0>%s(): m_SGTableDscr.SystemAddress = %p\n", __FUNCTION__, dma->m_SGTableDscr.SystemAddress );
    //printk("<0>%s(): m_SGTableDscr.LogicalAddress = %zx\n", __FUNCTION__, dma->m_SGTableDscr.LogicalAddress );

    //заполним значениями таблицу цепочек DMA
    for(iBlock=0, iEntry=0; iBlock < dma->m_BlockCount; iBlock++) {

        //адрес и размер DMA блока
        u64	address = pMemDscr[iBlock].LogicalAddress;
        u64	DmaSize = dma->m_BlockSize - 0x1000;


        //заполним поля элментов таблицы дескрипторов
        pSGTEx[iEntry].AddrByte1  = (u8)((address >> 8) & 0xFF);
        pSGTEx[iEntry].AddrByte2  = (u8)((address >> 16) & 0xFF);
        pSGTEx[iEntry].AddrByte3  = (u8)((address >> 24) & 0xFF);
        pSGTEx[iEntry].AddrByte4  = (u8)((address >> 32) & 0xFF);
        pSGTEx[iEntry].SizeByte1  = (u8)((DmaSize >> 8) & 0xFF);
        pSGTEx[iEntry].SizeByte2  = (u8)((DmaSize >> 16) & 0xFF);
        pSGTEx[iEntry].SizeByte3  = (u8)((DmaSize >> 24) & 0xFF);
        pSGTEx[iEntry].Cmd.JumpNextDescr = 1; //перейти к следующему дескриптору
        pSGTEx[iEntry].Cmd.JumpNextBlock = 0; //перейти к следующему блоку дескрипторов
        pSGTEx[iEntry].Cmd.JumpDescr0 = 0;
        pSGTEx[iEntry].Cmd.Res0 = 0;
        pSGTEx[iEntry].Cmd.EndOfTrans = 1;
        pSGTEx[iEntry].Cmd.Res = 0;
        pSGTEx[iEntry].SizeByte1 |= dma->m_DmaDirection;

        {
            //u32 *ptr=(u32*)&pSGTEx[iEntry];
            //printk("<0>%s(): %d: Entry Addr: %p, Data Addr: %llx  %.8X %.8X\n",
            //       __FUNCTION__, iEntry, &pSGTEx[iEntry], address, ptr[1], ptr[0]);
        }

        if(((iEntry+2)%DSCR_BLOCK_SIZE) == 0)
        {
            size_t NextDscrBlockAddr = 0;
            DMA_NEXT_BLOCK *pNextBlock = NULL;

            pSGTEx[iEntry].Cmd.JumpNextBlock = 1;
            pSGTEx[iEntry].Cmd.JumpNextDescr = 0;

            //NextDscrBlockAddr = virt_to_bus((void*)&pSGTEx[iEntry+2]);
            NextDscrBlockAddr = (size_t)((u8*)dma->m_SGTableDscr.LogicalAddress + sizeof(DMA_CHAINING_DESCR_EXT)*(iEntry +2));

            //printk("<0>%s(): NextDscrBlock [PA]: %x\n", __FUNCTION__, NextDscrBlockAddr);
            //printk("<0>%s(): NextDscrBlock [VA]: %p\n", __FUNCTION__, &pSGTEx[iEntry+2]);

            pNextBlock = (DMA_NEXT_BLOCK*)&pSGTEx[iEntry+1];

            //printk("<0>%s(): pNextBlock: %p\n", __FUNCTION__, pNextBlock);

            pNextBlock->NextBlkAddr = (NextDscrBlockAddr >> 8) & 0xFFFFFF;
            pNextBlock->Signature = 0x4953;
            pNextBlock->Crc = 0;
            iEntry++;
        }
        iEntry++;
    }

    //printk("<0>%s(): iEntry = %d\n", __FUNCTION__, iEntry);

    if(((iEntry % DSCR_BLOCK_SIZE)) != 0)
    {
        DMA_NEXT_BLOCK *pNextBlock = NULL;
        u32 i = 0;

        pSGTEx[iEntry-1].Cmd.JumpNextDescr = 0;

        pNextBlock = (DMA_NEXT_BLOCK*)(&pSGTEx[iEntry]);
        pNextBlock->NextBlkAddr = (dma->m_SGTableDscr.LogicalAddress >> 8);

        i = (DSCR_BLOCK_SIZE * dma->m_ScatterGatherBlockCnt) - 1;
        pNextBlock = (DMA_NEXT_BLOCK*)(&pSGTEx[i]);

        //printk("<0>%s(): %d: pNextBlock: %p\n", __FUNCTION__, i, pNextBlock );

        pNextBlock->NextBlkAddr = 0;
        pNextBlock->Signature = 0x4953;
        pNextBlock->Crc = 0;
    }

    //printk("<0>%s(): DmaDirection = %d, DmaLocalAddress = 0x%X\n", __FUNCTION__, dma->m_DmaDirection, dma->m_DmaLocalAddress);

    //for( ii=0; ii<dma->m_ScatterGatherBlockCnt*DSCR_BLOCK_SIZE; ii++ )
    //{
    //u32 *ptr=(u32*)&pSGTEx[ii];
    //printk("<0>%s(): %d: %.8X %.8X\n", __FUNCTION__, ii, ptr[1], ptr[0]);

    //}

    pDscrBuf = (u64*)dma->m_pScatterGatherTableExt;

    for(iBlkEntry = 0; iBlkEntry < dma->m_ScatterGatherBlockCnt; iBlkEntry++)
    {
        u32 ctrl_code = 0xFFFFFFFF;

        for(iBlock = 0; iBlock < DSCR_BLOCK_SIZE; iBlock++)
        {
            u16 data0 = (u16)(pDscrBuf[iBlock] & 0xFFFF);
            u16 data1 = (u16)((pDscrBuf[iBlock] >> 16) & 0xFFFF);
            u16 data2 = (u16)((pDscrBuf[iBlock] >> 32) & 0xFFFF);
            u16 data3 = (u16)((pDscrBuf[iBlock] >> 48) & 0xFFFF);
            if(iBlock == DSCR_BLOCK_SIZE-1)
            {
                ctrl_code = ctrl_code ^ data0 ^ data1 ^ data2 ^ data3;
                /*
                printk("<0>%s(): DSCR_BLCK[%d] - NextBlkAddr = 0x%8X, Signature = 0x%4X, Crc = 0x%4X\n", __FUNCTION__,
                       iBlkEntry,
                       (u32)(pDscrBuf[iBlock] << 8),
                       (u16)((pDscrBuf[iBlock] >> 32) & 0xFFFF),
                       (u16)ctrl_code);
*/
            }
            else
            {
                u32 ctrl_tmp = 0;
                ctrl_code = ctrl_code ^ data0 ^ data1 ^ data2 ^ data3;
                ctrl_tmp = ctrl_code << 1;
                ctrl_tmp |= (ctrl_code & 0x8000) ? 0: 1;
                ctrl_code = ctrl_tmp;

                //printk("<0>%s(): %d(%d) - PciAddr = 0x%8X, Cmd = 0x%2X, DmaLength = %d(%2X %2X %2X)\n",  __FUNCTION__,
                //									iBlock, iBlkEntry,
                //									(u32)(pDscrBuf[iBlock] << 8),
                //									(u8)(pDscrBuf[iBlock] >> 32),
                //									(u32)((pDscrBuf[iBlock] >> 41) << 9),
                //									(u8)(pDscrBuf[iBlock] >> 56),
                //									(u8)(pDscrBuf[iBlock] >> 48),
                //									(u8)(pDscrBuf[iBlock] >> 40));
                //printk("<0>%s(): JumpNextDescr = %d, JumpNextBlock = %d, JumpDescr0 = %d, EndOfTrans = %d, Signature = 0x%08X, Crc = 0x%08X\n",
                //									__FUNCTION__, m_pScatterGatherTable[iEntry].Cmd.EndOfChain,
                //									m_pScatterGatherTable[iEntry].Cmd.EndOfTrans,
                //									m_pScatterGatherTable[iEntry].Signature,
                //									m_pScatterGatherTable[iEntry].Crc
                //									);
            }
        }
        pNextDscr = (u16*)pDscrBuf;
        pNextDscr[255] |= (u16)ctrl_code;
        pDscrBuf += DSCR_BLOCK_SIZE;
    }
    return 0;
}

//-----------------------------------------------------------------------------
/*
u32 NexDscrAddress(void *pVirtualAddress)
{
    return (u32)(virt_to_bus(pVirtualAddress)>>4);
}
*/
//-----------------------------------------------------------------------------
// размещение в системном адресном пространстве памяти,
// доступной для операций ПДП и отображаемой в пользовательское пространство
//-----------------------------------------------------------------------------

int RequestSysBuf(struct CDmaChannel *dma, void **pMemPhysAddr)
{
    u32 iBlock = 0;
    u32 order = 0;
    SHARED_MEMORY_DESCRIPTION *pMemDscr = (SHARED_MEMORY_DESCRIPTION*)dma->m_pBufDscr.SystemAddress;

    //printk("<0>%s()\n", __FUNCTION__);

    order = get_order(dma->m_BlockSize);

    for(iBlock = 0; iBlock < dma->m_BlockCount; iBlock++)
    {
        dma_addr_t 	 LogicalAddress;
        void 		*pSystemAddress = NULL;
        u32 *buffer = NULL;
        int iii=0;

        pSystemAddress = dma_alloc_coherent(  dma->m_dev, dma->m_BlockSize, &LogicalAddress, GFP_KERNEL );
        //pSystemAddress = (void*)__get_free_pages(GFP_KERNEL, order);
        if(!pSystemAddress) {
            printk("<0>%s(): Not enought memory for %i block location. m_BlockSize = %X, BlockOrder = %d\n",
                   __FUNCTION__, (int)iBlock, (int)dma->m_BlockSize, (int)order );
            return -ENOMEM;
        }

        pMemDscr[iBlock].SystemAddress = pSystemAddress;
        pMemDscr[iBlock].LogicalAddress = LogicalAddress;
        //pMemDscr[iBlock].LogicalAddress = virt_to_bus(pSystemAddress);

        lock_pages( pMemDscr[iBlock].SystemAddress, dma->m_BlockSize );

        pMemPhysAddr[iBlock] = (void*)pMemDscr[iBlock].LogicalAddress;

        buffer = (u32*)pMemDscr[iBlock].SystemAddress;
        for(iii=0; iii<dma->m_BlockSize/4; iii++) {
            buffer[iii] = 0x12345678;
        }

        //printk("<0>%s(): %i: %p\n", __FUNCTION__, iBlock, pMemPhysAddr[iBlock]);
    }

    dma->m_BlockCount = iBlock;
    dma->m_ScatterGatherTableEntryCnt = iBlock;

    return 0;
}

//-----------------------------------------------------------------------------

void ReleaseSysBuf(struct CDmaChannel *dma)
{
    u32 iBlock = 0;
    //u32 order = 0;
    SHARED_MEMORY_DESCRIPTION *pMemDscr = (SHARED_MEMORY_DESCRIPTION*)dma->m_pBufDscr.SystemAddress;

    //printk("<0>%s()\n", __FUNCTION__);

    //order = get_order(dma->m_BlockSize);

    if(!dma->m_UseCount) {
        printk("<0> ReleaseSysBuf(): Memory not allocated.\n");
        return;
    }

    for(iBlock = 0; iBlock < dma->m_BlockCount; iBlock++)
    {
        unlock_pages( pMemDscr[iBlock].SystemAddress, dma->m_BlockSize );

        dma_free_coherent( dma->m_dev, dma->m_BlockSize, pMemDscr[iBlock].SystemAddress, pMemDscr[iBlock].LogicalAddress );
        //free_pages((size_t)pMemDscr[iBlock].SystemAddress, order);

        pMemDscr[iBlock].SystemAddress = NULL;
        pMemDscr[iBlock].LogicalAddress = 0;
    }
}

//-----------------------------------------------------------------------------

int RequestStub(struct CDmaChannel *dma, void **pStubPhysAddr)
{
    dma_addr_t LogicalAddress = 0;
    u32	StubSize = 0;

    //printk("<0>%s()\n", __FUNCTION__ );

    if(!dma)
        return -EINVAL;

    StubSize = sizeof(AMB_STUB) > PAGE_SIZE ? sizeof(AMB_STUB) : PAGE_SIZE;

    //printk("<0>%s() 0\n", __FUNCTION__ );

    if(!dma->m_UseCount)
    {
        void *pStub = dma_alloc_coherent( dma->m_dev, StubSize, &LogicalAddress, GFP_KERNEL );
        if(!pStub)
        {
            printk("<0>%s(): Not enought memory for stub\n", __FUNCTION__);
            return -ENOMEM;
        }

        lock_pages( pStub, StubSize );

        //printk("<0>%s() 1\n", __FUNCTION__ );

        dma->m_StubDscr.SystemAddress = pStub;
        dma->m_StubDscr.LogicalAddress = LogicalAddress;
        dma->m_pStub = (AMB_STUB*)pStub; 	  //может быть в этом нет необходимости,
        //но в дальнейшем в модуле используется dma->m_pStub
    }

    //printk("<0>%s() 2\n", __FUNCTION__ );

    pStubPhysAddr[0] = (void*)dma->m_StubDscr.LogicalAddress;

    //printk("<0>%s(): Stub physical address: %zx\n", __FUNCTION__, dma->m_StubDscr.LogicalAddress);
    //printk("<0>%s(): Stub virtual address: %p\n", __FUNCTION__, dma->m_StubDscr.SystemAddress);

    return 0;
}

//-----------------------------------------------------------------------------

void ReleaseStub(struct CDmaChannel *dma)
{
    u32 StubSize = sizeof(AMB_STUB) > PAGE_SIZE ? sizeof(AMB_STUB) : PAGE_SIZE;

    //printk("<0>%s()\n", __FUNCTION__);

    if(!dma->m_UseCount)
    {
        unlock_pages(dma->m_StubDscr.SystemAddress, StubSize);

        dma_free_coherent(dma->m_dev, StubSize,
                          dma->m_StubDscr.SystemAddress,
                          dma->m_StubDscr.LogicalAddress);
        dma->m_pStub = NULL;
        dma->m_StubDscr.SystemAddress = NULL;
        dma->m_StubDscr.LogicalAddress = 0;
    }
}

//-----------------------------------------------------------------------------
// вызываем только при первичном размещении буфера
//-----------------------------------------------------------------------------

int RequestSGList(struct CDmaChannel *dma)
{
    u32 SGListMemSize = 0;
    u32 SGListSize = 0;
    dma_addr_t PhysicalAddress;

    //printk("<0>%s()\n", __FUNCTION__);

    if(dma->m_idBlockFifo == PE_EXT_FIFO_ID)
    {
        dma->m_ScatterGatherBlockCnt = dma->m_ScatterGatherTableEntryCnt / (DSCR_BLOCK_SIZE-1);
        dma->m_ScatterGatherBlockCnt = (dma->m_ScatterGatherTableEntryCnt % (DSCR_BLOCK_SIZE-1)) ? (dma->m_ScatterGatherBlockCnt+1) : dma->m_ScatterGatherBlockCnt;
        SGListSize = sizeof(DMA_CHAINING_DESCR_EXT) * DSCR_BLOCK_SIZE * dma->m_ScatterGatherBlockCnt;
        //printk("<0>%s(): SGBlockCnt = %d, SGListSize = %d.\n", __FUNCTION__, dma->m_ScatterGatherBlockCnt, SGListSize);
    }

    SGListMemSize = (SGListSize >= PAGE_SIZE) ? SGListSize : PAGE_SIZE;

    //	выделяем память под список
    dma->m_SGTableDscr.SystemAddress = dma_alloc_coherent( dma->m_dev, SGListMemSize, &PhysicalAddress, GFP_KERNEL);
    if(!dma->m_SGTableDscr.SystemAddress)
    {
        printk("<0>%s(): Not enought memory for scatter/gather list\n", __FUNCTION__);
        return -ENOMEM;
    }

    dma->m_SGTableDscr.LogicalAddress = PhysicalAddress;

    // закрепляем список в физической памяти
    lock_pages(dma->m_SGTableDscr.SystemAddress, SGListMemSize);

    return 0;
}

//-----------------------------------------------------------------------------

void ReleaseSGList(struct CDmaChannel *dma)
{
    u32 SGListMemSize = 0;
    u32 SGListSize = 0;

    //printk("<0>%s()\n", __FUNCTION__);

    if(dma->m_idBlockFifo == PE_EXT_FIFO_ID)
    {
        SGListSize = sizeof(DMA_CHAINING_DESCR_EXT) * DSCR_BLOCK_SIZE * dma->m_ScatterGatherBlockCnt;
    }

    SGListMemSize = (SGListSize >= PAGE_SIZE) ? SGListSize : PAGE_SIZE;

    // закрепляем список в физической памяти
    unlock_pages(dma->m_SGTableDscr.SystemAddress, SGListMemSize);

    dma_free_coherent( dma->m_dev, SGListMemSize,
                       dma->m_SGTableDscr.SystemAddress,
                       dma->m_SGTableDscr.LogicalAddress );

    dma->m_SGTableDscr.SystemAddress = NULL;
    dma->m_SGTableDscr.LogicalAddress = 0;
}

//-----------------------------------------------------------------------------

int StartDmaTransfer(struct CDmaChannel *dma, u32 IsCycling)
{
    //printk("<0>%s()\n", __FUNCTION__);

    dma->m_DmaCycling = IsCycling;
    dma->m_DoneBlock = -1;
    dma->m_DoneFlag = 1;
    dma->m_CycleNum	= 0;
    dma->m_BlocksRemaining	= dma->m_BlockCount;
    dma->m_CurBlockNum = 0;
    dma->m_preBlockCount1 = 1;
    dma->m_preBlockCount2 = 2;
    dma->m_preBlockCount3 = 3;

    if(dma->m_idBlockFifo == PE_EXT_FIFO_ID)
    {
        u64 *pDscrBuf = NULL;
        u32 ctrl_code = ~0;
        u16* pDscr = NULL;
        int iEntry = 0;
        u32 iLastEntry = dma->m_ScatterGatherTableEntryCnt + dma->m_ScatterGatherBlockCnt - 1;
        if(dma->m_ScatterGatherBlockCnt == 1)
            dma->m_pScatterGatherTableExt[iLastEntry - 1].Cmd.JumpDescr0 = dma->m_DmaCycling;
        else
            dma->m_pScatterGatherTableExt[iLastEntry - 1].Cmd.JumpNextBlock = dma->m_DmaCycling;

        //printk("<0>%s(): m_DmaCycling = %d\n", __FUNCTION__, dma->m_DmaCycling);

        pDscrBuf = (u64*)dma->m_pScatterGatherTableExt + DSCR_BLOCK_SIZE * (dma->m_ScatterGatherBlockCnt - 1);
        ctrl_code = 0xFFFFFFFF;
        pDscr = (u16*)pDscrBuf;
        pDscr[255] = 0;
        for(iEntry = 0; iEntry < DSCR_BLOCK_SIZE; iEntry++)
        {
            u16 data0 = (u16)(pDscrBuf[iEntry] & 0xFFFF);
            u16 data1 = (u16)((pDscrBuf[iEntry] >> 16) & 0xFFFF);
            u16 data2 = (u16)((pDscrBuf[iEntry] >> 32) & 0xFFFF);
            u16 data3 = (u16)((pDscrBuf[iEntry] >> 48) & 0xFFFF);
            if(iEntry == DSCR_BLOCK_SIZE-1)
            {
                ctrl_code = ctrl_code ^ data0 ^ data1 ^ data2 ^ data3;
                /*
                printk("<0>%s(): DSCR_BLK[%d] - NextBlkAddr = 0x%08X, Signature = 0x%04X, Crc = 0x%04X\n",
                       __FUNCTION__,
                       dma->m_ScatterGatherBlockCnt-1,
                       (u32)(pDscrBuf[iEntry] << 8),
                       (u16)((pDscrBuf[iEntry] >> 32) & 0xFFFF),
                       (u16)ctrl_code);
*/
            }
            else
            {
                u32 ctrl_tmp = 0;
                ctrl_code = ctrl_code ^ data0 ^ data1 ^ data2 ^ data3;
                ctrl_tmp = ctrl_code << 1;
                ctrl_tmp |= (ctrl_code & 0x8000) ? 0: 1;
                ctrl_code = ctrl_tmp;

                // 3 способа циклического сдвига влево 32-разрядного значения
                // (у нас оказалось не совсем то: значение берется 16-разрядное и старший бит при переносе в младший инвертируется)
                //_rotl(ctrl_code, 1);
                //ctrl_code = (ctrl_code << 1) | (ctrl_code >> 31);
                //__asm {
                //	rol ctrl_code,1
                //}

                //printk("<0>%s(): %d(%d) - PciAddr = 0x%08X, Cmd = 0x%02X, DmaLength = %d(%02X %02X %02X)\n",
                //									__FUNCTION__,
                //									iEntry, dma->m_ScatterGatherBlockCnt-1,
                //									(u32)(pDscrBuf[iEntry] << 8),
                //									(u16)(pDscrBuf[iEntry] >> 32),
                //									(u32)((pDscrBuf[iEntry] >> 41) << 9),
                //									(u8)(pDscrBuf[iEntry] >> 56), (u8)(pDscrBuf[iEntry] >> 48), (u8)(pDscrBuf[iEntry] >> 40));
            }
        }
        pDscr[255] |= (u16)ctrl_code;
    }

    dma->m_pStub->lastBlock = -1;
    dma->m_pStub->totalCounter = 0;
    dma->m_pStub->state = STATE_RUN;

    return 0;
}

//-----------------------------------------------------------------------------

u32 NextDmaTransfer(struct CDmaChannel *dma)
{
    //printk("<0>%s(): - last block = %d, cycle counter = %d\n", __FUNCTION__, dma->m_pStub->lastBlock, dma->m_CycleNum);

    if(dma->m_pStub->lastBlock + 1 >= (long)dma->m_BlockCount)
        dma->m_pStub->lastBlock = 0;
    else
        dma->m_pStub->lastBlock++;

    dma->m_CurBlockNum++;
    dma->m_pStub->totalCounter++;
    dma->m_BlocksRemaining--;

    tasklet_hi_schedule(&dma->m_Dpc);

    //printk("<0>%s(): tasklet_hi_schedule()\n", __FUNCTION__);
/*
    if(dma->m_AdjustMode && dma->m_DmaCycling)
    {
        u32 next_done_blk = (dma->m_DoneBlock == dma->m_BlockCount-1) ? 0 : (dma->m_DoneBlock + 1);
        u32 next_cur_blk = ((dma->m_CurBlockNum + 1) >= dma->m_BlockCount) ? ((dma->m_CurBlockNum + 1) - dma->m_BlockCount) : (dma->m_CurBlockNum + 1);
        s32 difBlock = next_done_blk - next_cur_blk;

        if(!difBlock)
            dma->m_DoneFlag = 0;

        //printk("%s(): DoneBlock = %d, Nextdb = %d, CurBlock = %d, Nextcb = %d, difBlock = %d, DoneFlag = %d\n",
        //       __FUNCTION__, dma->m_DoneBlock, next_done_blk, dma->m_CurBlockNum, next_cur_blk, difBlock, dma->m_DoneFlag);
    }
*/
    if(dma->m_BlocksRemaining <= 0 && dma->m_DmaCycling)
    {
        dma->m_BlocksRemaining = dma->m_BlockCount;
        dma->m_CurBlockNum = 0;
        dma->m_CycleNum++;
    }

    if(dma->m_preBlockCount1+1 == dma->m_BlockCount)
    {
        dma->m_preBlockCount1 = 0;
    } else {
        dma->m_preBlockCount1++;
    }

    if(dma->m_preBlockCount2+1 == dma->m_BlockCount)
    {
        dma->m_preBlockCount2 = 0;
    } else {
        dma->m_preBlockCount2++;
    }

    if(dma->m_preBlockCount3+1 == dma->m_BlockCount)
    {
        dma->m_preBlockCount3 = 0;
    } else {
        dma->m_preBlockCount3++;
    }


    if(dma->m_AdjustMode && dma->m_DmaCycling)
    {
        if(((dma->m_preBlockCount3 == 0)&&(dma->m_DoneBlock == -1)) || (dma->m_preBlockCount3 == dma->m_DoneBlock)) {
            dma->m_DoneFlag = 0;
            //printk("<0>%s(): m_preBlockCount = %d, m_DoneBlock = %d\n", __FUNCTION__, dma->m_preBlockCount3, dma->m_DoneBlock);
        }
    }

    return dma->m_DoneFlag;
}

//-----------------------------------------------------------------------------

u32 SetDoneBlock(struct CDmaChannel *dma, long numBlk)
{
    if(numBlk != dma->m_DoneBlock)
    {
        dma->m_DoneBlock = numBlk;

        if((dma->m_preBlockCount1 != dma->m_DoneBlock) && (dma->m_preBlockCount2 != dma->m_DoneBlock) && (dma->m_preBlockCount3 != dma->m_DoneBlock)) {

            if(dma->m_AdjustMode && dma->m_DmaCycling && !dma->m_DoneFlag)
            {
                dma->m_DoneFlag = 1;
            }
        }
    }

    //printk("<0>%s(): DoneBlock = %d, DoneFlag = %d\n", __FUNCTION__, dma->m_DoneBlock, dma->m_DoneFlag);

    return dma->m_DoneFlag;
}

//-----------------------------------------------------------------------------

void GetState(struct CDmaChannel *dma, u32 *BlockNum, u32 *BlockNumTotal, u32 *OffsetInBlock, u32 *DmaChanState)
{
    //printk("<0>%s(): - last block = %d, cycle counter = %d\n", __FUNCTION__, dma->m_pStub->lastBlock, dma->m_CycleNum);

    *BlockNum = dma->m_State.lastBlock;
    *BlockNumTotal = dma->m_State.totalCounter;
    *OffsetInBlock = dma->m_State.offset;// регистр подсчета переданных байт в текущем буфере будет реализован позже
    *DmaChanState = dma->m_State.state;
}

//-----------------------------------------------------------------------------

void FreezeState(struct CDmaChannel *dma)
{
    //printk("<0>%s()\n", __FUNCTION__);
}

//-----------------------------------------------------------------------------

int WaitBlockEndEvent(struct CDmaChannel *dma, u32 msTimeout)
{
    int status = -ETIMEDOUT;

    //printk("<0>%s(): DMA%d\n", __FUNCTION__, dma->m_NumberOfChannel);

    if( msTimeout < 0 ) {
        status = GrabEvent( &dma->m_BlockEndEvent, -1 );
    } else {
        status = GrabEvent( &dma->m_BlockEndEvent, msTimeout );
    }
    return status;
}

//-----------------------------------------------------------------------------

int WaitBufferEndEvent(struct CDmaChannel *dma, u32 msTimeout)
{
    int status = -ETIMEDOUT;

    //printk("<0>%s(): DMA%d\n", __FUNCTION__, dma->m_NumberOfChannel);

    if( msTimeout < 0 ) {
        status = GrabEvent( &dma->m_BufferEndEvent, -1 );
    } else {
        status = GrabEvent( &dma->m_BufferEndEvent, msTimeout );
    }

    return status;
}

//-----------------------------------------------------------------------------

int CompleteDmaTransfer(struct CDmaChannel *dma)
{
    //printk("<0> %s(): DMA%d\n", __FUNCTION__, dma->m_NumberOfChannel);
    dma->m_pStub->state = STATE_STOP;
    return 0;
}

//-----------------------------------------------------------------------------

void GetSGStartParams(struct CDmaChannel *dma, u64 *SGTableAddress, u32 *LocalAddress, u32 *DmaDirection)
{
    if(dma->m_idBlockFifo == PE_EXT_FIFO_ID)
    {
        *SGTableAddress = dma->m_SGTableDscr.LogicalAddress;
    }

    *LocalAddress = dma->m_DmaLocalAddress;
    *DmaDirection = dma->m_DmaDirection;
}

//-----------------------------------------------------------------------------

void GetStartParams(struct CDmaChannel *dma, u32 *PciAddress, u32 *LocalAddress, u32 *DmaLength)
{
    // возвращает адрес и размер DMA из первого элемента таблицы
    if(dma->m_idBlockFifo == PE_EXT_FIFO_ID)
    {
        u64 *pDscrBuf = (u64*)dma->m_pScatterGatherTableExt;
        *PciAddress = (u32)(pDscrBuf[0] << 16);
        *DmaLength = (u32)((pDscrBuf[0] >> 40) << 8);
    }
    *LocalAddress = dma->m_DmaLocalAddress;
}

//-----------------------------------------------------------------------------

void Adjust(struct CDmaChannel *dma, u32 mode)
{
    //printk("<0>%s()\n", __FUNCTION__);
    dma->m_AdjustMode = mode;
}

//-----------------------------------------------------------------------------

void SetAdmTetr(struct CDmaChannel *dma, u32 AdmNum, u32 TetrNum)
{
    //printk("<0>%s()\n", __FUNCTION__);
    dma->m_AdmNum = AdmNum;
    dma->m_TetrNum = TetrNum;
}

//-----------------------------------------------------------------------------

void SetDmaLocalAddress(struct CDmaChannel *dma, u32 Address)
{
    //printk("<0>%s()\n", __FUNCTION__);
    dma->m_DmaLocalAddress = Address;
}

//-----------------------------------------------------------------------------

int SetDmaDirection(struct CDmaChannel *dma, u32 DmaDirection)
{
    printk("<0>%s()\n", __FUNCTION__);
    switch(DmaDirection)
    {
    case 1:
        dma->m_DmaDirection = TRANSFER_DIR_FROM_DEVICE;
        break;
    case 2:
        dma->m_DmaDirection = TRANSFER_DIR_TO_DEVICE;
        break;
    default:
        return -EINVAL;
    }

    return 0;
}

//-----------------------------------------------------------------------------

u32 GetAdmNum(struct CDmaChannel *dma)
{
    return dma->m_AdmNum;
}

//-----------------------------------------------------------------------------

u32 GetTetrNum(struct CDmaChannel *dma)
{
    return dma->m_TetrNum;
}

//-----------------------------------------------------------------------------

void DmaDpcForIsr( unsigned long Context )
{
    struct CDmaChannel *DmaChannel = (struct CDmaChannel *)Context;
    unsigned long flags = 0;

    spin_lock_irqsave(&DmaChannel->m_DmaLock, flags);

    //printk("<0>%s(): [DMA%d] m_CurBlockNum = %d, m_BlockCount = %d\n",
    //       __FUNCTION__, DmaChannel->m_NumberOfChannel, DmaChannel->m_CurBlockNum, DmaChannel->m_BlockCount );
    DmaChannel->m_State = *DmaChannel->m_pStub;

    SetEvent( &DmaChannel->m_BlockEndEvent );

    if(DmaChannel->m_CurBlockNum >= DmaChannel->m_BlockCount)
    {
        HwCompleteDmaTransfer(DmaChannel->m_Board,DmaChannel->m_NumberOfChannel);
        SetEvent( &DmaChannel->m_BufferEndEvent );
    }

    spin_unlock_irqrestore(&DmaChannel->m_DmaLock, flags);
}
