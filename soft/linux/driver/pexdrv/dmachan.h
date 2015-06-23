//****************** File DmaChannel.h *********************************
//  class CDmaChannel definition
//
//	Copyright (c) 2007, Instrumental Systems,Corp.
//  Written by Dorokhin Andrey
//
//  History:
//  28-10-07 - builded
//
//*******************************************************************

#ifndef		_DMA_CHAN_H_
#define		_DMA_CHAN_H_

#include "pexioctl.h"

#define PE_EXT_FIFO_ID	0x0018

typedef void (*TASKLET_ROUTINE)(unsigned long);

struct CDmaChannel
{
    u32							m_NumberOfChannel;
    u16							m_idBlockFifo;

    void 						*m_Board;				// PCI device object
    struct device                                       *m_dev;					// PCI device object
    struct  tasklet_struct                              m_Dpc;                                  // the DPC object
    wait_queue_head_t                                   m_DmaWq;
    spinlock_t                                          m_DmaLock;				// spinlock

    KEVENT						m_BlockEndEvent;
    KEVENT						m_BufferEndEvent;

    AMB_STUB                                            m_State;

    u32							m_AdmNum;
    u32							m_TetrNum;
    u32							m_DmaDirection;
    u32							m_DmaLocalAddress;
    u32							m_DmaCycling;

    u32							m_CycleNum;
    u32							m_BlocksRemaining;
    u32							m_CurBlockNum;

    u32							m_UseCount;

    u32							m_AdjustMode;
    u32							m_DoneBlock;
    u32							m_DoneFlag;

    u32							m_preBlockCount1;
    u32							m_preBlockCount2;
    u32							m_preBlockCount3;

    u32							m_MemType;
    AMB_STUB                                            *m_pStub;

    SHARED_MEMORY_DESCRIPTION	m_StubDscr;		//Содержит описатель управляющего блока

    u32							m_BlockCount;	//Количество блоков для DMA
    u32							m_BlockSize;	//Размер одного блока DMA

    SHARED_MEMORY_DESCRIPTION                           m_pBufDscr;	//Описатель для адресов блоков DMA каждый элемент содержит

    DMA_CHAINING_DESCR_EXT                              *m_pScatterGatherTableExt; 		//Содержит массив для организации цепочек DMA (v2)
    u32							m_ScatterGatherBlockCnt;  		//Количество элементов-дескрипторов цепочек DMA
    SHARED_MEMORY_DESCRIPTION                           m_SGTableDscr;			   		//Описатель массива цепочек DMA
    u32							m_ScatterGatherTableEntryCnt; 	//Количество блоков для DMA

    TASKLET_ROUTINE                                     m_DpcForIsr;
};

struct CDmaChannel* CDmaChannelCreate( 	u32 NumberOfChannel,
                                        void *m_Board,
                                        struct device	*dev,
                                        u32 cbMaxTransferLength,
                                        u16 idBlockFifo,
                                        int bScatterGather );
void CDmaChannelDelete(struct CDmaChannel *dma);
int RequestMemory(struct CDmaChannel *dma, void **ppMemPhysAddr, u32 size, u32 *pCount, void **pStubPhysAddr, u32 bMemType);
void ReleaseMemory(struct CDmaChannel *dma);
int RequestSysBuf(struct CDmaChannel *dma, void **pMemPhysAddr);
void ReleaseSysBuf(struct CDmaChannel *dma);
int RequestSGList(struct CDmaChannel *dma);
void ReleaseSGList(struct CDmaChannel *dma);
int RequestStub(struct CDmaChannel *dma, void **pStubPhysAddr);
void ReleaseStub(struct CDmaChannel *dma);
int SetScatterGatherListExt(struct CDmaChannel *dma);
void FreeUserAddress(struct CDmaChannel *dma);
u32 NextDmaTransfer(struct CDmaChannel *dma);
int SetScatterGatherList(struct CDmaChannel *dma);
int SetDmaDirection(struct CDmaChannel *dma, u32 DmaDirection);
void SetDmaLocalAddress(struct CDmaChannel *dma, u32 Address);
void SetLocalBusWidth(struct CDmaChannel *dma, u32 Param);
void ReferenceBlockEndEvent(struct CDmaChannel *dma, void* hBlockEndEvent);
void DereferenceBlockEndEvent(struct CDmaChannel *dma);
void SetAdmTetr(struct CDmaChannel *dma, u32 AdmNum, u32 TetrNum);
void Adjust(struct CDmaChannel *dma, u32 mode);
void GetState(struct CDmaChannel *dma, u32 *BlockNum, u32 *BlockNumTotal, u32 *OffsetInBlock, u32 *DmaChanState);
int CompleteDmaTransfer(struct CDmaChannel *dma);
int WaitBlockEndEvent(struct CDmaChannel *dma, u32 msTimeout);
int WaitBufferEndEvent(struct CDmaChannel *dma, u32 msTimeout);
u32 GetAdmNum(struct CDmaChannel *dma);
u32 GetTetrNum(struct CDmaChannel *dma);
void GetSGStartParams(struct CDmaChannel *dma, u64* SGTableAddress, u32* LocalAddress, u32* DmaDirection);
int StartDmaTransfer(struct CDmaChannel *dma, u32 IsCycling);
u32 SetDoneBlock(struct CDmaChannel *dma, long numBlk);
void DmaDpcForIsr( unsigned long Context );

#endif //_DMA_CHANNEL_H_

//
// End of File
//
