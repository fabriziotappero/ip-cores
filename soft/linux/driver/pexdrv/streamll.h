
#ifndef _STREAMLL_H_
#define _STREAMLL_H_

typedef struct _AMB_MEM_DMA_CHANNEL {
	size_t	DmaChanNum;		// IN
	size_t	Direction;
	size_t	LocalAddr;
	size_t	MemType;
	size_t	BlockCnt;
	size_t	BlockSize;
	void*	pStub;
	void*	pBlock[1];
} AMB_MEM_DMA_CHANNEL, *PAMB_MEM_DMA_CHANNEL;

typedef struct _AMB_START_DMA_CHANNEL {
	u32	DmaChanNum;		// IN
	u32	IsCycling;
} AMB_START_DMA_CHANNEL, *PAMB_START_DMA_CHANNEL;

typedef struct _AMB_STATE_DMA_CHANNEL {
	u32	DmaChanNum;		// IN
	u32	BlockNum;		// OUT
	u32	BlockCntTotal;	// OUT
	u32	OffsetInBlock;	// OUT
	u32	DmaChanState;	// OUT
	u32	Timeout;		// IN
} AMB_STATE_DMA_CHANNEL, *PAMB_STATE_DMA_CHANNEL;

typedef struct _AMB_SET_DMA_CHANNEL {
	u32	DmaChanNum;		// IN
	u32	Param;
} AMB_SET_DMA_CHANNEL, *PAMB_SET_DMA_CHANNEL;

typedef struct _AMB_GET_DMA_INFO {
	u32	DmaChanNum;		// IN
	u32	Direction;		// OUT
	u32	FifoSize;		// OUT
	u32	MaxDmaSize;		// OUT
} AMB_GET_DMA_INFO, *PAMB_GET_DMA_INFO;

#endif //_STREAMLL_H_


