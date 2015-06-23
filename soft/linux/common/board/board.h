
#ifndef __BOARD_H__
#define __BOARD_H__

#ifndef __BRD_RESOURCE_H__
#include "brd_resource.h"
#endif
#ifndef __BRD_INFO_H__
#include "brd_info.h"
#endif

#include <vector>
#include <string>
#include <stdint.h>

typedef uint8_t   u8;
typedef uint16_t  u16;
typedef uint32_t  u32;
typedef int32_t   s32;
typedef uint64_t  u64;

#ifndef _CTRL_STRM_H_
#include "ctrlstrm.h"
#endif

#ifdef __VERBOSE__
#include <stdio.h>
#define DEBUG_PRINT(fmt, args...)    fprintf(stderr, fmt, ## args)
#else
#define DEBUG_PRINT(fmt, args...)
#endif

class board {

private:

    virtual int core_open(const char *name) = 0;
    virtual int core_init() = 0;
    virtual int core_reset() = 0;
    virtual int core_close() = 0;
    virtual int core_load_dsp() = 0;
    virtual int core_load_pld() = 0;
    virtual int core_board_info() = 0;
    virtual int core_pld_info() = 0;
    virtual int core_resource() = 0;
    virtual void core_delay(int ms) = 0;

    virtual u32 core_alloc(int DmaChan, BRDctrl_StreamCBufAlloc* sSCA) = 0;
    virtual u32 core_allocate_memory(int DmaChan, void** pBuf, u32 blkSize, 
				     u32 blkNum, u32 isSysMem, u32 dir, 
				     u32 addr, BRDstrm_Stub **pStub ) = 0;
    virtual u32 core_free_memory(int DmaChan) = 0;
    virtual u32 core_start_dma(int DmaChan, int IsCycling) = 0;
    virtual u32 core_stop_dma(int DmaChan) = 0;
    virtual u32 core_state_dma(int DmaChan, u32 msTimeout, int& state, u32& blkNum) = 0;
    virtual u32 core_wait_buffer(int DmaChan, u32 msTimeout) = 0;
    virtual u32 core_wait_block(int DmaChan, u32 msTimeout) = 0;
    virtual u32 core_reset_fifo(int DmaChan) = 0;
    virtual u32 core_set_local_addr(int DmaChan, u32 addr) = 0;
    virtual u32 core_adjust(int DmaChan, u32 mode) = 0;
    virtual u32 core_done(int DmaChan, u32 blockNumber) = 0;

    virtual u32 core_reg_peek_dir( u32 trd, u32 reg ) = 0;
    virtual u32 core_reg_peek_ind( u32 trd, u32 reg ) = 0;
    virtual void core_reg_poke_dir( u32 trd, u32 reg, u32 val ) = 0;
    virtual void core_reg_poke_ind( u32 trd, u32 reg, u32 val ) = 0;
    virtual u32  core_bar0_read( u32 addr ) = 0;
    virtual void core_bar0_write( u32 addr, u32 val ) = 0;
    virtual u32  core_bar1_read( u32 addr ) = 0;
    virtual void core_bar1_write( u32 addr, u32 val ) = 0;

public:
    board();
    virtual ~board();

    int brd_open(const char *name);
    int brd_init();
    int brd_reset();
    int brd_close();
    int brd_load_dsp();
    int brd_load_pld();
    void brd_delay(int ms);

    int brd_board_info();
    int brd_pld_info();
    int brd_resource();

    //! Методы управления каналами DMA BRDSHELL
    u32 dma_alloc(int DmaChan, BRDctrl_StreamCBufAlloc* sSCA);
    u32 dma_allocate_memory(int DmaChan, void** pBuf, u32 blkSize, 
			    u32 blkNum, u32 isSysMem, 
			    u32 dir, u32 addr, BRDstrm_Stub **pStub);
    u32 dma_free_memory(int DmaChan);
    u32 dma_start(int DmaChan, int IsCycling);
    u32 dma_stop(int DmaChan);
    u32 dma_state(int DmaChan, u32 msTimeout, int& state, u32& blkNum);
    u32 dma_wait_buffer(int DmaChan, u32 msTimeout);
    u32 dma_wait_block(int DmaChan, u32 msTimeout);
    u32 dma_reset_fifo(int DmaChan);
    u32 dma_set_local_addr(int DmaChan, u32 addr);
    u32 dma_adjust(int DmaChan, u32 mode);
    u32 dma_done(int DmaChan, u32 blockNumber);

    //-----------------------------

    u32 brd_reg_peek_dir( u32 trd, u32 reg );
    u32 brd_reg_peek_ind( u32 trd, u32 reg );
    void brd_reg_poke_dir( u32 trd, u32 reg, u32 val );
    void brd_reg_poke_ind( u32 trd, u32 reg, u32 val );
    u32  brd_bar0_read( u32 offset );
    void brd_bar0_write( u32 offset, u32 val );
    u32  brd_bar1_read( u32 offset );
    void brd_bar1_write( u32 offset, u32 val );
};

//! Тип конструктора объектов
typedef board* (*board_factory)(void);

#endif //__BOARD_H__
