
#ifndef _PEXDEV_H_
#define _PEXDEV_H_

#include <linux/cdev.h>
#include <linux/sched.h>
#include <linux/version.h>
#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,37)
#include <linux/semaphore.h>
#endif

//-----------------------------------------------------------------------------

#ifndef _EVENT_H_
    #include "event.h"
#endif
#ifndef	 _DMA_CHAN_H_
    #include "dmachan.h"
#endif
#ifndef _STREAMLL_H_
    #include "streamll.h"
#endif
#ifndef _MEMORY_H_
    #include "memory.h"
#endif

//-----------------------------------------------------------------------------

#define PEX_DRIVER_NAME             "pex_driver"
#define MAX_NUMBER_OF_DMACHANNELS   4
#define NUMBER_OF_PLDS              4
#define IRQ_NUMBER                  1
#define NUM_TETR_IRQ                8

//-----------------------------------------------------------------------------

struct pex_device {

    struct list_head        m_list;
    char                    m_name[128];
    atomic_t                m_TotalIRQ;
    dev_t                   m_devno;
    struct class           *m_class;
    struct device          *m_device;
    struct pci_dev         *m_pci;

    struct address_t        m_BAR0;
    struct address_t        m_BAR1;

    spinlock_t              m_BoardLock;
    struct mutex            m_BoardMutex;
    struct semaphore        m_BoardSem;
    u32                     m_Interrupt;
    u32                     m_DmaIrqEnbl;
    u32                     m_FlgIrqEnbl;
    u32                     m_BoardIndex;
    wait_queue_head_t       m_WaitQueue;
    struct timer_list       m_TimeoutTimer;
    atomic_t                m_IsTimeout;
    struct cdev             m_cdev;

    spinlock_t              m_MemListLock;
    atomic_t                m_MemListCount;
    struct list_head        m_MemList;

    struct CDmaChannel     *m_DmaChannel[MAX_NUMBER_OF_DMACHANNELS];	//
    u32                     m_PldStatus[NUMBER_OF_PLDS];			//
    u32                     m_MemOpUseCount;	// счетчик использования диапазона памяти (PE_MAIN on AMBPEX8)
    u16                     m_BlockCnt;
    u32                     m_DmaChanMask;
    u32                     m_DmaChanEnbl[MAX_NUMBER_OF_DMACHANNELS];
    u32                     m_DmaFifoSize[MAX_NUMBER_OF_DMACHANNELS];
    u32                     m_DmaDir[MAX_NUMBER_OF_DMACHANNELS];
    u32                     m_MaxDmaSize[MAX_NUMBER_OF_DMACHANNELS];
    u16                     m_BlockFifoId[MAX_NUMBER_OF_DMACHANNELS];
    u32                     m_FifoAddr[MAX_NUMBER_OF_DMACHANNELS];
    u32                     m_TetrIrq[NUM_TETR_IRQ];
    u32                     m_primChan;
};

//-----------------------------------------------------------------------------

extern int dbg_trace;
extern int err_trace;

#ifndef PRINTK
#define PRINTK(S...) printk(S)
#endif

#define dbg_msg(flag, S...) do { if(flag) PRINTK(KERN_DEBUG S); } while(0)
#define err_msg(flag, S...) do { if(flag) PRINTK(KERN_ERR S); } while(0)

//-----------------------------------------------------------------------------

#endif //_PEXDEV_H_
