#ifndef _BRD_INFO_H_
#define _BRD_INFO_H_

//-----------------------------------------------------------------------------
// board configuration data structure

struct board_info {
	size_t	PhysAddress[6];
	void*	VirtAddress[6];
	size_t	Size[6];
	size_t	InterruptLevel;
	size_t	InterruptVector;
	unsigned short vendor_id;
	unsigned short device_id;
};
/*
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
*/
#endif
