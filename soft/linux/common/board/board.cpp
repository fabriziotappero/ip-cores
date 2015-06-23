
#ifndef __BOARD_H__
#include "board.h"
#endif

//-----------------------------------------------------------------------------

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------

board::board()
{
}

//-----------------------------------------------------------------------------

board::~board()
{
}

//-----------------------------------------------------------------------------

int board::brd_open(const char *name)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_open(name);
}

//-----------------------------------------------------------------------------

int board::brd_init()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_init();
}

//-----------------------------------------------------------------------------

int board::brd_reset()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_reset();
}

//-----------------------------------------------------------------------------

int board::brd_close()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_close();
}

//-----------------------------------------------------------------------------

int board::brd_load_dsp()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_load_dsp();
}

//-----------------------------------------------------------------------------

int board::brd_load_pld()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_load_pld();
}

//-----------------------------------------------------------------------------

int board::brd_board_info()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_board_info();
}

//-----------------------------------------------------------------------------

int board::brd_pld_info()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_pld_info();
}

//-----------------------------------------------------------------------------

int board::brd_resource()
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_resource();
}

//-----------------------------------------------------------------------------

void board::brd_delay(int ms)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    core_delay(ms);
}

/*
std::vector<struct memory_block>* board::dma_alloc(u32 dmaChannel, u32 blockNumber, u32 blockSize)
{
    return core_dma_alloc(dmaChannel, blockNumber, blockSize);
}

//-----------------------------------------------------------------------------

int board::dma_free(u32 dmaChannel)
{
    return core_dma_free(dmaChannel);
}

//-----------------------------------------------------------------------------

int board::dma_start(u32 dmaChannel)
{
    return core_dma_start(dmaChannel);
}

//-----------------------------------------------------------------------------

int board::dma_state(u32 dmaChannel)
{
    return core_dma_state(dmaChannel);
}

//-----------------------------------------------------------------------------

int board::dma_stop(u32 dmaChannel)
{
    return core_dma_stop(dmaChannel);
}

//-----------------------------------------------------------------------------

int board::dma_total()
{
    return core_dma_total();
}

//-----------------------------------------------------------------------------

struct memory_block* board::dma_stub(u32 dmaChannel)
{
    return core_dma_stub(dmaChannel);
}
*/
//-----------------------------------------------------------------------------

u32 board::brd_reg_peek_dir( u32 trd, u32 reg )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_reg_peek_dir( trd, reg );
}

//-----------------------------------------------------------------------------

u32 board::brd_reg_peek_ind( u32 trd, u32 reg )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_reg_peek_ind( trd, reg );
}

//-----------------------------------------------------------------------------

void board::brd_reg_poke_dir( u32 trd, u32 reg, u32 val )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_reg_poke_dir( trd, reg, val );
}

//-----------------------------------------------------------------------------

void board::brd_reg_poke_ind( u32 trd, u32 reg, u32 val )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_reg_poke_ind( trd, reg, val );
}

//-----------------------------------------------------------------------------

u32  board::brd_bar0_read( u32 offset )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_bar0_read( offset );
}

//-----------------------------------------------------------------------------

void board::brd_bar0_write( u32 offset, u32 val )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_bar0_write( offset, val );
}

//-----------------------------------------------------------------------------

u32  board::brd_bar1_read( u32 offset )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_bar1_read( offset );
}

//-----------------------------------------------------------------------------

void board::brd_bar1_write( u32 offset, u32 val )
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_bar1_write(offset, val);
}

//----------BRDSHELL-----------------------------------------------------------

u32 board::dma_alloc(int DmaChan, BRDctrl_StreamCBufAlloc* sSCA)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_alloc(DmaChan, sSCA);
}

//-----------------------------------------------------------------------------

u32 board::dma_allocate_memory(int DmaChan, void** pBuf, u32 blkSize, 
				u32 blkNum, u32 isSysMem, u32 dir, 
				u32 addr, BRDstrm_Stub **pStub)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_allocate_memory(DmaChan, pBuf, blkSize, 
				blkNum, isSysMem, dir, addr, pStub);
}

//-----------------------------------------------------------------------------

u32 board::dma_free_memory(int DmaChan)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_free_memory(DmaChan);
}

//-----------------------------------------------------------------------------

u32 board::dma_start(int DmaChan, int IsCycling)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_start_dma(DmaChan, IsCycling);
}

//-----------------------------------------------------------------------------

u32 board::dma_stop(int DmaChan)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_stop_dma(DmaChan);
}

//-----------------------------------------------------------------------------

u32 board::dma_state(int DmaChan, u32 msTimeout, int& state, u32& blkNum)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_state_dma(DmaChan, msTimeout, state, blkNum);
}

//-----------------------------------------------------------------------------

u32 board::dma_wait_buffer(int DmaChan, u32 msTimeout)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_wait_buffer(DmaChan, msTimeout);
}

//-----------------------------------------------------------------------------

u32 board::dma_wait_block(int DmaChan, u32 msTimeout)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_wait_block(DmaChan, msTimeout);
}

//-----------------------------------------------------------------------------

u32 board::dma_reset_fifo(int DmaChan)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_reset_fifo(DmaChan);
}

//-----------------------------------------------------------------------------

u32 board::dma_set_local_addr(int DmaChan, u32 addr)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_set_local_addr(DmaChan, addr);
}

//-----------------------------------------------------------------------------

u32 board::dma_adjust(int DmaChan, u32 mode)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_adjust(DmaChan, mode);
}

//-----------------------------------------------------------------------------

u32 board::dma_done(int DmaChan, u32 blockNumber)
{
    DEBUG_PRINT("%s()\n", __FUNCTION__);
    return core_done(DmaChan, blockNumber);
}

//-----------------------------------------------------------------------------
