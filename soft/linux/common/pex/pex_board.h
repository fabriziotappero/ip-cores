
#ifndef __PEX_BOARD_H__
#define __PEX_BOARD_H__

#ifndef __BOARD__H__
    #include "board.h"
#endif
#ifndef _STREAMLL_H_
    #include "streamll.h"
#endif
#ifndef _PEXIOCTL_H_
    #include "pexioctl.h"
#endif
#ifndef _AMBPEXREGS_H_
    #include "ambpexregs.h"
#endif

#include <vector>
#include <string>
#include <stdint.h>

//-----------------------------------------------------------------------------

//class dma_memory;

//-----------------------------------------------------------------------------
#define MAX_NUMBER_OF_DMACHANNELS 4
//-----------------------------------------------------------------------------

class pex_board : public board {

private:
    int fd;
    u32 *bar0;
    u32 *bar1;
    struct board_info bi;
    void core_pause(int ms);

    //dma_memory *m_dma;

    AMB_MEM_DMA_CHANNEL *m_Descr[MAX_NUMBER_OF_DMACHANNELS];
    u32                  m_DescrSize[MAX_NUMBER_OF_DMACHANNELS];

public:
    pex_board();
    virtual ~pex_board();

    int core_open(const char *name);
    int core_init();
    int core_reset();
    int core_close();
    int core_load_dsp();
    int core_load_pld();
    int core_board_info();
    int core_pld_info();
    int core_resource();
    void core_delay(int ms);

    u32 core_alloc(int DmaChan, BRDctrl_StreamCBufAlloc* sSCA);
    u32 core_allocate_memory(int DmaChan, void** pBuf, u32 blkSize, 
			     u32 blkNum, u32 isSysMem, u32 dir, 
			     u32 addr, BRDstrm_Stub **pStub);
    u32 core_free_memory(int DmaChan);
    u32 core_start_dma(int DmaChan, int IsCycling);
    u32 core_stop_dma(int DmaChan);
    u32 core_state_dma(int DmaChan, u32 msTimeout, int& state, u32& blkNum);
    u32 core_wait_buffer(int DmaChan, u32 msTimeout);
    u32 core_wait_block(int DmaChan, u32 msTimeout);
    u32 core_reset_fifo(int DmaChan);
    u32 core_set_local_addr(int DmaChan, u32 addr);
    u32 core_adjust(int DmaChan, u32 mode);
    u32 core_done(int DmaChan, u32 blockNumber);

    u32 core_reg_peek_dir( u32 trd, u32 reg );
    u32 core_reg_peek_ind( u32 trd, u32 reg );
    void core_reg_poke_dir( u32 trd, u32 reg, u32 val );
    void core_reg_poke_ind( u32 trd, u32 reg, u32 val );
    u32  core_bar0_read( u32 offset );
    void core_bar0_write( u32 offset, u32 val );
    u32  core_bar1_read( u32 offset );
    void core_bar1_write( u32 offset, u32 val );

    void core_block_write( u32 nb, u32 reg, u32 val );
    u32  core_block_read( u32 nb, u32 reg );
};


#endif //__PEX_BOARD_H__
