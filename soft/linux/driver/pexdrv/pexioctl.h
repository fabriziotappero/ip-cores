#ifndef _PEXIOCTL_H_
#define _PEXIOCTL_H_

#define PEX_DEVICE_NAME "pexdevice"

#include <linux/types.h>

#define MAX_STRING_LEN  255
#define PEX_DEVICE_TYPE             'x'
#define PEX_MAKE_IOCTL(t,c) _IO((t), (c))

//-----------------------------------------------------------------------------
// ioctl requests command code
typedef enum _PEX_NUM_FUNC {

    PEX_BOARD_INFO = 1,
    PEX_MEM_ALLOC = 2,
    PEX_MEM_FREE = 3,
    PEX_STUB_ALLOC = 4,
    PEX_STUB_FREE = 5,

    PEX_MEMIO_SET = 10,
    PEX_MEMIO_FREE = 11,
    PEX_MEMIO_START = 12,
    PEX_MEMIO_STOP = 13,
    PEX_MEMIO_STATE = 14,
    PEX_WAIT_BUFFER = 15,
    PEX_WAIT_BLOCK = 16,
    PEX_SET_SRC = 17,
    PEX_SET_DIR = 18,
    PEX_SET_DRQ = 19,
    PEX_RESET_FIFO = 20,
    PEX_DONE = 21,
    PEX_ADJUST = 22


} PEX_NUM_FUNC;

//-----------------------------------------------------------------------------
// ioctl requests code
#define IOCTL_PEX_BOARD_INFO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_BOARD_INFO)

#define IOCTL_PEX_MEM_ALLOC \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEM_ALLOC)

#define IOCTL_PEX_MEM_FREE \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEM_FREE)

#define IOCTL_PEX_STUB_ALLOC \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_STUB_ALLOC)

#define IOCTL_PEX_STUB_FREE \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_STUB_FREE)

#define IOCTL_AMB_SET_MEMIO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEMIO_SET)

#define IOCTL_AMB_FREE_MEMIO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEMIO_FREE)

#define IOCTL_AMB_START_MEMIO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEMIO_START)

#define IOCTL_AMB_STOP_MEMIO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEMIO_STOP)

#define IOCTL_AMB_STATE_MEMIO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_MEMIO_STATE)

#define IOCTL_AMB_WAIT_DMA_BUFFER \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_WAIT_BUFFER)

#define IOCTL_AMB_WAIT_DMA_BLOCK \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_WAIT_BLOCK)

#define IOCTL_AMB_SET_SRC_MEM \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_SET_SRC)

#define IOCTL_AMB_SET_DIR_MEM \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_SET_DIR)

#define IOCTL_AMB_SET_DRQ_MEM \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_SET_DRQ)

#define IOCTL_AMB_RESET_FIFO \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_RESET_FIFO)

#define IOCTL_AMB_DONE \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_DONE)

#define IOCTL_AMB_ADJUST \
            PEX_MAKE_IOCTL(PEX_DEVICE_TYPE, PEX_ADJUST)

//-----------------------------------------------------------------------------
// memory block structure
struct memory_block {
        size_t	phys;
        void*	virt;
        size_t	size;
};

//-----------------------------------------------------------------------------
// memory block structure
struct memory_descriptor {
        size_t dma_channel;
        size_t total_blocks;
        struct memory_block *blocks;
};

//-----------------------------------------------------------------------------
// stub memory structure
struct stub_descriptor {
        size_t dma_channel;
        struct memory_block stub;
};

//-----------------------------------------------------------------------------
// Extended FIFO Id
#define PE_EXT_FIFO_ID	0x0018

//-----------------------------------------------------------------------------
// type of memory
enum {
    USER_MEMORY_TYPE	= 0,
    SYSTEM_MEMORY_TYPE	= 1
};

//-----------------------------------------------------------------------------
//  state of DMA channel
enum {
    STATE_RUN = 1,
    STATE_STOP = 2,
    STATE_DESTROY = 3,
    STATE_BREAK = 4
};

//-----------------------------------------------------------------------------
//  direction of DMA transfer
enum {
    TRANSFER_DIR_TO_DEVICE = 0x0,	// From Host to Device
    TRANSFER_DIR_FROM_DEVICE = 0x1	// From Device to Host
};

//-----------------------------------------------------------------------------
enum {
        BRDstrm_DIR_IN = 0x1,                           // To HOST
        BRDstrm_DIR_OUT = 0x2,                          // From HOST
        BRDstrm_DIR_INOUT = 0x3                         // Both Directions
};

//-----------------------------------------------------------------------------
// returns the number of pages spanned by the size.
#define PAGES_SPANNED(Size) (((Size) + (PAGE_SIZE - 1)) >> PAGE_SHIFT)

//-----------------------------------------------------------------------------
// Shared Memory between kernel and user mode description
typedef struct _SHARED_MEMORY_DESCRIPTION {
    void*			SystemAddress;	// INOUT - system memory address
    size_t			LogicalAddress; // OUT - logical memory address
    size_t			dummy;          // OUT - logical memory address
} SHARED_MEMORY_DESCRIPTION, *PSHARED_MEMORY_DESCRIPTION;

//-----------------------------------------------------------------------------
// Stub Structure
typedef struct _AMB_STUB {
    u32	lastBlock;		// Number of Block which was filled last Time
    u32	totalCounter;           // Total Counter of all filled Block
    u32	offset;			// First Unfilled Byte
    u32	state;			// CBUF local state
} AMB_STUB, *PAMB_STUB;

//-----------------------------------------------------------------------------
// Descriptor Structure (PE_EXT_FIFO)
// PCI Address (byte 0)	= 0 always
// DMA Length (byte 0)	= 0 always
typedef struct _DMA_CHAINING_DESCR_EXT {

    u8	AddrByte1;				// PCI Address (byte 1)
    u8	AddrByte2;				// PCI Address (byte 2)
    u8	AddrByte3;				// PCI Address (byte 3)
    u8	AddrByte4;				// PCI Address (byte 4)

    struct {
        u8 JumpNextDescr : 1;	// Jump to Next Descriptor
        u8 JumpNextBlock : 1;	// Jump to Next Block
        u8 JumpDescr0	 : 1;	// Jump to Descriptor 0
        u8 Res0		 : 1;	// reserved
        u8 EndOfTrans	 : 1;	// End of Transfer
        u8 Res		 : 3;	// reserved
    } Cmd;							// Descriptor Command

    u8	SizeByte1;				// DMA Length (byte 1), bit 0: 0 - TRANSFER_DIR_TO_DEVICE, 1 - TRANSFER_DIR_FROM_DEVICE
    u8	SizeByte2;				// DMA Length (byte 2)
    u8	SizeByte3;				// DMA Length (byte 3)

} DMA_CHAINING_DESCR_EXT, *PDMA_CHAINING_DESCR_EXT;

//-----------------------------------------------------------------------------
// Next descriptor block
typedef struct _DMA_NEXT_BLOCK {

    u32	NextBlkAddr;
    u16 Signature;				// 0x4953
    u16 Crc;					// control code

} DMA_NEXT_BLOCK, *PDMA_NEXT_BLOCK;

#define DSCR_BLOCK_SIZE 64

//-----------------------------------------------------------------------------

#endif
