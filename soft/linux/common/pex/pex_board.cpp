
#ifndef __PEX_BOARD_H__
#include "pex_board.h"
#endif

//-----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------

pex_board::pex_board()
{
    fd = -1;
    bar0 = bar1 = NULL;
    memset(&bi, 0, sizeof(bi));
    //m_dma = new dma_memory();
}

//-----------------------------------------------------------------------------

pex_board::~pex_board()
{
    //if(m_dma) delete m_dma;
    core_close();
}

//-----------------------------------------------------------------------------

int pex_board::core_open(const char *name)
{
    int error = 0;

    if(fd > 0)
        return 0;

    fd = open(name, S_IROTH | S_IWOTH );
    if(fd < 0) {
        std::cerr << __FUNCTION__ << "(): " << " error open device: " << name << endl;
        goto do_out;
    }

    error = core_board_info();
    if(error < 0) {
        std::cerr << __FUNCTION__ << "(): " << " error get board info" << endl;
        goto do_close;
    }

    bar0 = (u32*)mmap(NULL, bi.Size[0], PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)bi.PhysAddress[0]);
    if( bar0 == MAP_FAILED ) {
        std::cerr << __FUNCTION__ << "(): " << " error map bar0 address" << endl;
        error = -EINVAL;
        goto do_close;
    }

    bar1 = (u32*)mmap(NULL, bi.Size[1], PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)bi.PhysAddress[1]);
    if( bar1== MAP_FAILED ) {
        std::cerr << __FUNCTION__ << "(): " << " error map bar1 address" << endl;
        error = -EINVAL;
        goto do_unmap_bar0;
    }

    std::cout << "Map BAR0: 0x" << hex << bi.PhysAddress[0] << " -> " << bar0 << dec << endl;
    std::cout << "Map BAR1: 0x" << hex << bi.PhysAddress[1] << " -> " << bar1 << dec << endl;

    return 0;

do_unmap_bar0:
    munmap(bar0, bi.Size[0]);

do_close:
    close(fd);

do_out:
    return error;
}

//-----------------------------------------------------------------------------

int pex_board::core_init()
{
    uint16_t temp = 0;
    uint16_t blockId = 0;
    uint16_t blockVer = 0;
    uint16_t deviceID = 0;
    uint16_t deviceRev = 0;
    int i = 0;

    fprintf(stderr,"%s()\n", __FUNCTION__);

    blockId =  core_block_read( 0, 0 );
    blockVer = core_block_read( 0, 1 );

    fprintf(stderr,"%s(): BlockID = 0x%X, BlockVER = 0x%X.\n", __FUNCTION__, blockId, blockVer);

    deviceID = core_block_read(  0, 2 );
    deviceRev = core_block_read( 0, 3 );

    fprintf(stderr,"%s(): DeviceID = 0x%X, DeviceRev = 0x%X.\n", __FUNCTION__, deviceID, deviceRev);

    temp = core_block_read( 0, 4 );
    int m_BlockCnt = core_block_read( 0, 5 );

    if( m_BlockCnt>8 ) {
        m_BlockCnt=8;
    }

    fprintf(stderr,"%s(): PldVER = 0x%X.\n", __FUNCTION__, temp);
    fprintf(stderr,"%s(): Block count = %d.\n", __FUNCTION__, m_BlockCnt);

    // определим какие каналы ПДП присутствуют и их характеристики:
    // направление передачи данных, размер FIFO, максимальный размер блока ПДП

    FIFO_ID FifoId;
    int m_DmaFifoSize[4] = {0};
    int m_MaxDmaSize[4] = {0};
    int m_DmaDir[4] = {0};
    int m_DmaChanMask = 0;

    for(int iBlock = 0; iBlock < m_BlockCnt; iBlock++)
    {
        uint16_t block_id = 0;

        block_id=core_block_read( iBlock, 0 );
        block_id &=0xFFF;

        if(block_id == PE_EXT_FIFO_ID)
        {
            u32 resource_id = 0;
            uint16_t iChan = core_block_read( iBlock, 3 );
            m_DmaChanMask |= (1 << iChan);
            FifoId.AsWhole = core_block_read( iBlock, 2 );
            m_DmaFifoSize[iChan] = FifoId.ByBits.Size;
            m_DmaDir[iChan] = FifoId.ByBits.Dir;
            m_MaxDmaSize[iChan] = 0x40000000; // макс. размер ПДП пусть будет 1 Гбайт
            resource_id = core_block_read( iBlock, 4 ); // RESOURCE
            fprintf(stderr,"%s(): Channel(ID) = %d(0x%x), FIFO size = %d Bytes, DMA Dir = %d, Max DMA size = %d MBytes, resource = 0x%x.\n", __FUNCTION__,
                    iChan, block_id, m_DmaFifoSize[iChan] * 4, m_DmaDir[iChan], m_MaxDmaSize[iChan] / 1024 / 1024, resource_id);
        }
    }

    // подготовим к работе ПЛИС ADM
    fprintf(stderr,"%s(): Prepare ADM PLD.\n", __FUNCTION__);
    core_block_write( 0, 8, 0);
    core_delay(100);	// pause ~ 100 msec
    for(i = 0; i < 10; i++)
    {
        core_block_write( 0, 8, 1);
        core_delay(100);	// pause ~ 100 msec
        core_block_write( 0, 8, 3);
        core_delay(100);	// pause ~ 100 msec
        core_block_write( 0, 8, 7);
        core_delay(100);	// pause ~ 100 msec
        temp = core_block_read( 0, 010 ) & 0x01;
        if(temp)
            break;
    }
    core_block_write( 0, 8, 0xF );
    core_delay(100);	// pause ~ 100 msec

    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_reset()
{
    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_close()
{
    if(bar0) {
        munmap(bar0, bi.Size[0]);
        bar0 = NULL;
    }
    if(bar1) {
        munmap(bar1, bi.Size[1]);
        bar1 = NULL;
    }

    close(fd);
    fd = -1;


    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_load_dsp()
{
    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_load_pld()
{
    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_board_info()
{
    int error = ioctl(fd, IOCTL_PEX_BOARD_INFO, &bi);
    if(error < 0) {
        std::cerr << __FUNCTION__ << "(): " << " error get board info" << endl;
        return -1;
    }
/*
    fprintf(stderr, "VENDOR ID: 0x%X\n", bi.vendor_id);
    fprintf(stderr, "DEVICE ID: 0x%X\n", bi.device_id);
    fprintf(stderr, "BAR0: 0x%zX\n", bi.PhysAddress[0]);
    fprintf(stderr, "SIZE: 0x%zX\n", bi.Size[0]);
    fprintf(stderr, "BAR1 0x%zX\n", bi.PhysAddress[1]);
    fprintf(stderr, "SIZE: 0x%zX\n", bi.Size[1]);
    fprintf(stderr, "IRQ: 0x%zX\n", bi.InterruptVector);
*/
    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_pld_info()
{
    u32 d = 0;
    u32 d1 = 0;
    u32 d2 = 0;
    u32 d3 = 0;
    u32 d4 = 0;
    u32 d5 = 0;
    int ii = 0;

    if(!bar1)
        return -1;

    fprintf(stderr," Firmware PLD ADM\n" );
    core_reg_poke_dir(0, 1, 1);
    core_reg_poke_dir(0, 1, 1);

    d=core_reg_peek_ind( 0, 0x108 );
    if( d==0x4953 ) {
        fprintf(stderr, " SIG = 0x%.4X - Ok\n", d );
    } else {
        fprintf(stderr, " SIG = 0x%.4X - Error, waiting 0x4953\n", d );
        return -1;
    }

    d=core_reg_peek_ind(  0, 0x109 );  fprintf(stderr, " ADM interface version:  %d.%d\n", d>>8, d&0xFF );
    d=core_reg_peek_ind(  0, 0x110 ); d1=core_reg_peek_ind(  0, 0x111 );
    fprintf(stderr,  " Base module: 0x%.4X  v%d.%d\n", d, d1>>8, d1&0xFF );

    d=core_reg_peek_ind(  0, 0x112 ); d1=core_reg_peek_ind(  0, 0x113 );
    fprintf(stderr,  " Submodule: 0x%.4X  v%d.%d\n", d, d1>>8, d1&0xFF );

    d=core_reg_peek_ind(  0, 0x10B );  fprintf(stderr,  " Firmware modificaton:  %d \n", d );
    d=core_reg_peek_ind(  0, 0x10A );  fprintf(stderr,  " Firmware version:       %d.%d\n", d>>8, d&0xFF );
    d=core_reg_peek_ind(  0, 0x114 );  fprintf(stderr,  " Firmware build number: 0x%.4X\n", d );

    fprintf(stderr,  "\n Information about the tetrads:\n\n" );
    for( ii=0; ii<8; ii++ ) {

        const char *str;

        d=core_reg_peek_ind(  ii, 0x100 );
        d1=core_reg_peek_ind(  ii, 0x101 );
        d2=core_reg_peek_ind(  ii, 0x102 );
        d3=core_reg_peek_ind(  ii, 0x103 );
        d4=core_reg_peek_ind(  ii, 0x104 );
        d5=core_reg_peek_ind(  ii, 0x105 );

        switch( d ) {
        case 1: str="TRD_MAIN         "; break;
        case 2: str="TRD_BASE_DAC     "; break;
        case 3: str="TRD_PIO_STD      "; break;
        case 0:    str=" -            "; break;
        case 0x47: str="SBSRAM_IN     "; break;
        case 0x48: str="SBSRAM_OUT    "; break;
        case 0x12: str="DIO64_OUT     "; break;
        case 0x13: str="DIO64_IN      "; break;
        case 0x14: str="ADM212x200M   "; break;
        case 0x5D: str="ADM212x500M   "; break;
        case 0x41: str="DDS9956       "; break;
        case 0x4F: str="TEST_CTRL     "; break;
        case 0x3F: str="ADM214x200M   "; break;
        case 0x40: str="ADM216x100    "; break;
        case 0x2F: str="ADM28x1G      "; break;
        case 0x2D: str="TRD128_OUT    "; break;
        case 0x4C: str="TRD128_IN     "; break;
        case 0x30: str="ADMDDC5016    "; break;
        case 0x2E: str="ADMFOTR2G     "; break;
        case 0x49: str="ADMFOTR3G     "; break;
        case 0x67: str="DDS9912       "; break;
        case 0x70: str="AMBPEX5_SDRAM "; break;
        case 0x71: str="TRD_MSG       "; break;
        case 0x72: str="TRD_TS201     "; break;
        case 0x73: str="TRD_STREAM_IN "; break;
        case 0x74: str="TRD_STREAM_OUT"; break;
        case 0xA0: str="TRD_ADC       "; break;
        case 0xA1: str="TRD_DAC       "; break;
        case 0x91: str="TRD_EMAC      "; break;


        default: str="UNKNOWN"; break;
        }
        fprintf(stderr,  " %d  0x%.4X %s ", ii, d, str );
        if( d>0 ) {
            fprintf(stderr,  " MOD: %-2d VER: %d.%d ", d1, d2>>8, d2&0xFF );
            if( d3 & 0x10 ) {
                fprintf(stderr,  "FIFO IN   %dx%d\n", d4, d5 );
            } else if( d3 & 0x20 ) {
                fprintf(stderr,  "FIFO OUT  %dx%d\n", d4, d5 );
            } else {
                fprintf(stderr,  "\n" );
            }
        } else {
            fprintf(stderr,  "\n" );
        }

    }

    return 0;
}

//-----------------------------------------------------------------------------

int pex_board::core_resource()
{
    return 0;
}

//-----------------------------------------------------------------------------

void pex_board::core_delay(int ms)
{
    struct timeval tv = {0, 0};
    tv.tv_usec = 1000*ms;

    select(0,NULL,NULL,NULL,&tv);
}

//-----------------------------------------------------------------------------

u32 pex_board::core_reg_peek_dir( u32 trd, u32 reg )
{
    if( (trd>15) || (reg>3) )
        return -1;

    u32 offset = trd*0x4000 + reg*0x1000;
    u32 ret = *(bar1 + offset/4);

    return ret;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_reg_peek_ind( u32 trd, u32 reg )
{
    if( (trd>15) || (reg>0x3FF) )
        return -1;

    u32 status;
    u32 Status  = trd*0x4000;
    u32 CmdAdr  = trd*0x4000 + 0x2000;
    u32 CmdData = trd*0x4000 + 0x3000;
    u32 ret;

    bar1[CmdAdr/4] = reg;

    for( int ii=0; ; ii++ ) {

        status = bar1[Status/4];
        if( status & 1 )
            break;

        if( ii>10000 )
            core_delay( 1 );
        if( ii>20000 ) {
            return 0xFFFF;
        }
    }

    ret = bar1[CmdData/4];
    ret &= 0xFFFF;

    return ret;
}

//-----------------------------------------------------------------------------

void pex_board::core_reg_poke_dir( u32 trd, u32 reg, u32 val )
{
    if( (trd>15) || (reg>3) )
        return;

    u32 offset = trd*0x4000+reg*0x1000;

    bar1[offset/4]=val;
}

//-----------------------------------------------------------------------------

void pex_board::core_reg_poke_ind( u32 trd, u32 reg, u32 val )
{
    if( (trd>15) || (reg>0x3FF) )
        return;

    u32 status;
    u32 Status  = trd*0x4000;
    u32 CmdAdr  = trd*0x4000 + 0x2000;
    u32 CmdData = trd*0x4000 + 0x3000;

    bar1[CmdAdr/4] = reg;

    for( int ii=0; ; ii++ ) {

        status = bar1[Status/4];
        if( status & 1 )
            break;

        if( ii>10000 )
            core_delay( 1 );
        if( ii>20000 ) {
            return;
        }
    }

    bar1[CmdData/4] = val;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_bar0_read( u32 offset )
{
    return bar0[2*offset];
}

//-----------------------------------------------------------------------------

void pex_board::core_bar0_write( u32 offset, u32 val )
{
    bar0[2*offset] = val;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_bar1_read( u32 offset )
{
    return bar1[2*offset];
}

//-----------------------------------------------------------------------------

void pex_board::core_bar1_write( u32 offset, u32 val )
{
    bar1[2*offset] = val;
}

//-----------------------------------------------------------------------------

void pex_board::core_block_write( u32 nb, u32 reg, u32 val )
{
    if( (nb>7) || (reg>31) )
        return;

    *(bar0+nb*64+reg*2)=val;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_block_read( u32 nb, u32 reg )
{
    if( (nb>7) || (reg>31) )
        return -1;

    u32 ret = 0;

    ret=*(bar0+nb*64+reg*2);
    if( reg<8 )
        ret&=0xFFFF;

    return ret;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_alloc(int DmaChan, BRDctrl_StreamCBufAlloc* sSCA)
{
    m_DescrSize[DmaChan] = sizeof(AMB_MEM_DMA_CHANNEL) + (sSCA->blkNum - 1) * sizeof(void*);
    m_Descr[DmaChan] = (AMB_MEM_DMA_CHANNEL*) new u8[m_DescrSize[DmaChan]];

    m_Descr[DmaChan]->DmaChanNum = DmaChan;
    m_Descr[DmaChan]->Direction = sSCA->dir;
    m_Descr[DmaChan]->LocalAddr = 0;
    m_Descr[DmaChan]->MemType = sSCA->isCont;
    m_Descr[DmaChan]->BlockCnt = sSCA->blkNum;
    m_Descr[DmaChan]->BlockSize = sSCA->blkSize;
    m_Descr[DmaChan]->pStub = NULL;

    for(u32 iBlk = 0; iBlk < sSCA->blkNum; iBlk++) {
            m_Descr[DmaChan]->pBlock[iBlk] = NULL;
    }

    if( ioctl(fd, IOCTL_AMB_SET_MEMIO, m_Descr[DmaChan]) < 0 ) {
        fprintf(stderr, "%s(): Error allocate memory\n", __FUNCTION__ );
        return -1;
    }

    for(u32 iBlk = 0; iBlk < m_Descr[DmaChan]->BlockCnt; iBlk++) {

        void *MappedAddress = mmap( NULL,
                                    m_Descr[DmaChan]->BlockSize,
                                    PROT_READ | PROT_WRITE,
                                    MAP_SHARED,
                                    fd,
                                    (off_t)m_Descr[DmaChan]->pBlock[iBlk] );

        if(MappedAddress == MAP_FAILED) {
            fprintf(stderr, "%s(): Error map memory\n", __FUNCTION__ );
            return -1;
        }

        fprintf(stderr,"%d: %p -> %p\n", iBlk, (void*)m_Descr[DmaChan]->pBlock[iBlk], MappedAddress);

        //сохраним отображенный в процесс физический адрес текущего блока
        m_Descr[DmaChan]->pBlock[iBlk] = MappedAddress;
        sSCA->ppBlk[iBlk] = MappedAddress;
/*
        u32 *buffer = (u32*)MappedAddress;
        for(u32 jj=0; jj<m_Descr[DmaChan]->BlockSize/4; jj+=0x100) {
            fprintf(stdout,"%x ", buffer[jj]);
        }
        fprintf(stdout,"\n");
*/
    }

    if(m_Descr[DmaChan]->pStub) {

        void *StubAddress = mmap( NULL,
                                  sizeof(AMB_STUB),
                                  PROT_READ | PROT_WRITE,
                                  MAP_SHARED,
                                  fd,
                                  (off_t)m_Descr[DmaChan]->pStub );

        if(StubAddress == MAP_FAILED) {
            fprintf(stderr, "%s(): Error map stub\n", __FUNCTION__ );
            return -1;
        }

        fprintf(stderr,"Stub: %p -> %p\n", (void*)m_Descr[DmaChan]->pStub, StubAddress);

        m_Descr[DmaChan]->pStub = StubAddress;
        sSCA->pStub = (BRDstrm_Stub*)m_Descr[DmaChan]->pStub;
    }

    //сохраним информацию в буфере пользователя
    sSCA->blkNum = m_Descr[DmaChan]->BlockCnt;

    return 0;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_allocate_memory(int DmaChan,
				    void** pBuf,
				    u32 blkSize,
				    u32 blkNum,
				    u32 isSysMem,
				    u32 dir,
				    u32 addr,
				    BRDstrm_Stub **pStub )
{
    m_DescrSize[DmaChan] = sizeof(AMB_MEM_DMA_CHANNEL) + (blkNum - 1) * sizeof(void*);
    m_Descr[DmaChan] = (AMB_MEM_DMA_CHANNEL*) new u8[m_DescrSize[DmaChan]];

    m_Descr[DmaChan]->DmaChanNum = DmaChan;
    m_Descr[DmaChan]->Direction = dir;
    m_Descr[DmaChan]->LocalAddr = addr;
    m_Descr[DmaChan]->MemType = isSysMem;
    m_Descr[DmaChan]->BlockCnt = blkNum;
    m_Descr[DmaChan]->BlockSize = blkSize;
    m_Descr[DmaChan]->pStub = NULL;

    for(u32 iBlk = 0; iBlk < blkNum; iBlk++) {
            m_Descr[DmaChan]->pBlock[iBlk] = NULL;
    }

    if( ioctl(fd, IOCTL_AMB_SET_MEMIO, m_Descr[DmaChan]) < 0 ) {
        fprintf(stderr, "%s(): Error allocate memory\n", __FUNCTION__ );
        return -1;
    }

    for(u32 iBlk = 0; iBlk < blkNum; iBlk++) {

        void *MappedAddress = mmap( NULL,
                                    m_Descr[DmaChan]->BlockSize,
                                    PROT_READ | PROT_WRITE,
                                    MAP_SHARED,
                                    fd,
                                    (off_t)m_Descr[DmaChan]->pBlock[iBlk] );

        if(MappedAddress == MAP_FAILED) {
            fprintf(stderr, "%s(): Error map memory\n", __FUNCTION__ );
            return -1;
        }

        fprintf(stderr,"%d: %p -> %p\n", iBlk, (void*)m_Descr[DmaChan]->pBlock[iBlk], MappedAddress);

        //сохраним отображенный в процесс физический адрес текущего блока
        m_Descr[DmaChan]->pBlock[iBlk] = MappedAddress;
    }

    if(m_Descr[DmaChan]->pStub) {

        void *StubAddress = mmap( NULL,
                                  sizeof(AMB_STUB),
                                  PROT_READ | PROT_WRITE,
                                  MAP_SHARED,
                                  fd,
                                  (off_t)m_Descr[DmaChan]->pStub );

        if(StubAddress == MAP_FAILED) {
            fprintf(stderr, "%s(): Error map stub\n", __FUNCTION__ );
            return -1;
        }

        fprintf(stderr,"Stub: %p -> %p\n", (void*)m_Descr[DmaChan]->pStub, StubAddress);

        m_Descr[DmaChan]->pStub = StubAddress;
    }

    *pBuf = &m_Descr[DmaChan]->pBlock[0];
    *pStub = (BRDstrm_Stub*)m_Descr[DmaChan]->pStub;

    return 0;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_free_memory(int DmaChan)
{
    for(u32 iBlk = 0; iBlk < m_Descr[DmaChan]->BlockCnt; iBlk++) {

        munmap( m_Descr[DmaChan]->pBlock[iBlk], m_Descr[DmaChan]->BlockSize );
    }

    munmap( m_Descr[DmaChan]->pStub, sizeof(AMB_STUB) );

    if(ioctl(fd, IOCTL_AMB_FREE_MEMIO, m_Descr[DmaChan]) < 0) {
        fprintf(stderr, "%s(): Error free memory\n", __FUNCTION__ );
        return -1;
    }

    delete m_Descr[DmaChan];
    m_Descr[DmaChan] = NULL;

    return 0;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_start_dma(int DmaChan, int IsCycling)
{

fprintf(stderr, "%s(): DmaChan=%d IsCycling=%d \n", __FUNCTION__, DmaChan, IsCycling );
    if(m_Descr[DmaChan])
    {
        AMB_START_DMA_CHANNEL StartDescrip;
        StartDescrip.DmaChanNum = DmaChan;
        StartDescrip.IsCycling = IsCycling;

        fprintf(stderr, "%s(): IOCTL_AMB_START_MEMIO  ", __FUNCTION__ );

        if (ioctl(fd,IOCTL_AMB_START_MEMIO,&StartDescrip) < 0) {
            fprintf(stderr, "%s(): Error start DMA\n", __FUNCTION__ );
            return -1;
        }
        fprintf(stderr, " %s - OK \n", __FUNCTION__ );
    }
    return 0;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_stop_dma(int DmaChan)
{
    if(m_Descr[DmaChan])
    {
        AMB_STUB* pStub = (AMB_STUB*)m_Descr[DmaChan]->pStub;
        if(pStub->state == STATE_RUN)
        {
            AMB_STATE_DMA_CHANNEL StateDescrip;
            StateDescrip.DmaChanNum = DmaChan;
            StateDescrip.Timeout = 0;//pState->timeout; останавливает немедленно (в 0-кольце оставлю пока возможность ожидания)

            if (ioctl(fd, IOCTL_AMB_STOP_MEMIO, &StateDescrip) < 0) {
                fprintf(stderr, "%s(): Error stop DMA\n", __FUNCTION__ );
                return -1;
            }
        }
    }
    return 0;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_state_dma(int DmaChan, u32 msTimeout, int& state, u32& blkNum)
{
    AMB_STATE_DMA_CHANNEL StateDescrip;
    StateDescrip.DmaChanNum = DmaChan;
    StateDescrip.Timeout = msTimeout;

    if (0 > ioctl(fd, IOCTL_AMB_STATE_MEMIO, &StateDescrip)) {
        fprintf(stderr, "%s(): Error state DMA\n", __FUNCTION__ );
        return -1;
    }
    blkNum = StateDescrip.BlockCntTotal;
    state = StateDescrip.DmaChanState;

    return 0;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_wait_buffer(int DmaChan, u32 msTimeout)
{
    AMB_STATE_DMA_CHANNEL WaitDmaDescr;
    WaitDmaDescr.DmaChanNum = DmaChan;
    WaitDmaDescr.Timeout = msTimeout;

    if(m_Descr[DmaChan])
    {
        if (0 > ioctl(fd, IOCTL_AMB_WAIT_DMA_BUFFER, &WaitDmaDescr)) {
            fprintf(stderr, "%s(): Error wait buffer DMA\n", __FUNCTION__ );
            return -1;
        }
    }

    return 0;
}

//-----------------------------------------------------------------------------

u32  pex_board::core_wait_block(int DmaChan, u32 msTimeout)
{
    AMB_STATE_DMA_CHANNEL WaitDmaDescr;
    WaitDmaDescr.DmaChanNum = DmaChan;
    WaitDmaDescr.Timeout = msTimeout;

    if(m_Descr[DmaChan])
    {
        if (0 > ioctl(fd, IOCTL_AMB_WAIT_DMA_BLOCK, &WaitDmaDescr)) {
            fprintf(stderr, "%s(): Error wait block DMA\n", __FUNCTION__ );
            return -1;
        }
    }

    return 0;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_reset_fifo(int DmaChan)
{
    AMB_SET_DMA_CHANNEL DmaParam;
    DmaParam.DmaChanNum = DmaChan;
    DmaParam.Param = 0;

    if(m_Descr[DmaChan])
    {
        if (0 > ioctl(fd, IOCTL_AMB_RESET_FIFO, &DmaParam)) {
            fprintf(stderr, "%s(): Error reset FIFO\n", __FUNCTION__ );
            return -1;
        }
    }

    return 0;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_set_local_addr(int DmaChan, u32 addr)
{
    AMB_SET_DMA_CHANNEL DmaParam;
    DmaParam.DmaChanNum = DmaChan;
    DmaParam.Param = addr;

fprintf(stderr, "%s(): DmaChan=%d addr=0x%.8X \n", __FUNCTION__, DmaChan, addr );


    if(m_Descr[DmaChan])
    {
        if (0 > ioctl(fd, IOCTL_AMB_SET_SRC_MEM, &DmaParam)) {
            fprintf(stderr, "%s(): Error set source for DMA\n", __FUNCTION__ );
            return -1;
        }


       DmaParam.Param = m_Descr[DmaChan]->Direction;

          if (0 > ioctl(fd, IOCTL_AMB_SET_DIR_MEM, &DmaParam)) {
              fprintf(stderr, "%s(): Error set dir for DMA\n", __FUNCTION__ );
              return -1;
          }


    }

    return 0;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_adjust(int DmaChan, u32 mode)
{
    AMB_SET_DMA_CHANNEL DmaParam;
    DmaParam.DmaChanNum = DmaChan;
    DmaParam.Param = mode;

    if(m_Descr[DmaChan])
    {
        if (0 > ioctl(fd, IOCTL_AMB_ADJUST, &DmaParam)) {
            fprintf(stderr, "%s(): Error adjust DMA\n", __FUNCTION__ );
            return -1;
        }
    }

    return 0;
}

//-----------------------------------------------------------------------------

u32 pex_board::core_done(int DmaChan, u32 blockNumber)
{
    AMB_SET_DMA_CHANNEL DmaParam;
    DmaParam.DmaChanNum = DmaChan;
    DmaParam.Param = blockNumber;

    if(m_Descr[DmaChan])
    {
        if (0 > ioctl(fd, IOCTL_AMB_DONE, &DmaParam)) {
            fprintf(stderr, "%s(): Error done DMA\n", __FUNCTION__ );
            return -1;
        }
    }

    return 0;
}

//-----------------------------------------------------------------------------
