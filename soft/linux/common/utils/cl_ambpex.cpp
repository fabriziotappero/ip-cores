//---------------------------------------------------------------------------

#include <stdio.h>
#include <stdint.h>
#include <sys/select.h>

#ifndef __PEX_BOARD_H__
#include "pex_board.h"
#endif
#ifndef __BOARD_H__
#include "board.h"
#endif

#include	"ctrlstrm.h"
#include	"cl_ambpex.h"

//---------------------------------------------------------------------------

void Sleep( int ms );

//-----------------------------------------------------------------------------
//!  Инициализация модуля
U32  CL_AMBPEX::init( void )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
    // сброс прошивки ПЛИС
    RegPokeInd( 0, 0, 1 );
    Sleep( 100 );
    RegPokeInd( 0, 0, 0 );
    Sleep( 100 );

    return 0;
}

//-----------------------------------------------------------------------------
//!  Завершение работы с модулем
void  CL_AMBPEX::cleanup( void )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
}

//-----------------------------------------------------------------------------
//! Открываем модуль
CL_AMBPEX::CL_AMBPEX(const char *devname)
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    m_pBoard = new pex_board();

    if(devname) {
        m_pBoard->brd_open(devname);
    } else {
        m_pBoard->brd_open("/dev/pexdrv0");
    }

    m_pBoard->brd_init();
    m_pBoard->brd_board_info();
    m_pBoard->brd_pld_info();
}

//-----------------------------------------------------------------------------

CL_AMBPEX::~CL_AMBPEX()
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
}

//-----------------------------------------------------------------------------

void    CL_AMBPEX::RegPokeInd( S32 trdNo, S32 rgnum, U32 val )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
    m_pBoard->brd_reg_poke_ind( trdNo, rgnum, val );
}

//-----------------------------------------------------------------------------

U32    CL_AMBPEX::RegPeekInd( S32 trdNo, S32 rgnum )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
    U32 ret;
    ret=m_pBoard->brd_reg_peek_ind( trdNo, rgnum );
    return ret;
}

//-----------------------------------------------------------------------------

void    CL_AMBPEX::RegPokeDir( S32 trdNo, S32 rgnum, U32 val )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
    m_pBoard->brd_reg_poke_dir( trdNo, rgnum, val );
}

//-----------------------------------------------------------------------------

U32    CL_AMBPEX::RegPeekDir( S32 trdNo, S32 rgnum )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);
    U32 ret;
    ret=m_pBoard->brd_reg_peek_dir( trdNo, rgnum );
    return ret;
}

//-----------------------------------------------------------------------------

int CL_AMBPEX::StreamInit( U32 strm, U32 cnt_buf, U32 size_one_buf_of_bytes, U32 trd, U32 dir, U32 cycle, U32 system, U32 agree_mode )
{
    if( strm>1 )
        return 1;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=0 )
        return 1;

    pStrm->cnt_buf                  = cnt_buf;
    pStrm->size_one_buf_of_bytes    = size_one_buf_of_bytes;
    pStrm->trd                      = trd;
    pStrm->cycle                    = cycle;
    pStrm->system                   = system;

    pStrm->indexDma=-1;
    pStrm->indexPc=-1;
    pStrm->agree_mode=agree_mode;

    StreamDestroy( strm );

    __int64 size=cnt_buf*(__int64)size_one_buf_of_bytes/(1024*1024);

    if( system ) {

        BRDC_fprintf( stderr, _BRDC("Allocation memory: \r\n")
                      _BRDC(" Type of buffer:    system memory\r\n")
                      _BRDC(" Buffer size: %lld MB\r\n"), size );
    } else {

        BRDC_fprintf( stderr, _BRDC("Allocation memory: \r\n")
                      _BRDC(" Type of buffer:    userspace memory\r\n")
                      _BRDC(" Buffer size: %lld MB  (%dx%d MB)\r\n"), size, cnt_buf, size_one_buf_of_bytes/(1024*1024) );
    }

    BRDctrl_StreamCBufAlloc sSCA = {
        dir,
        system,
        cnt_buf,
        size_one_buf_of_bytes,
        (void**)&pStrm->pBlk[0],
        NULL,
    };

    u32 err = m_pBoard->dma_alloc( strm, &sSCA );
    if(err != 0) {
	throw( "Error allocate stream memory\n" );
	return -1;
    }

    pStrm->pStub=sSCA.pStub;
    if(!pStrm->pStub) {
        throw( "Error allocate stream memory\n" );
    } else {
        printf( "Allocate stream memory - Ok\n" );
    }
    /*
    for(int j=0; j<sSCA.blkNum; j++) {
        fprintf(stderr, "%s(): pBlk[%d] = %p\n", __FUNCTION__, j, pStrm->pBlk[j]);
    }
    fprintf(stderr, "%s(): pStub = %p\n", __FUNCTION__, pStrm->pStub);

    fprintf(stderr, "%s(): Press enter...\n", __FUNCTION__);
    getchar();
*/
    m_pBoard->dma_set_local_addr( strm, trd );

    // Перевод на согласованный режим работы
    if( agree_mode ) {

        err = m_pBoard->dma_adjust(strm, 1);
        BRDC_fprintf( stderr, _BRDC("Stream working in adjust mode\n"));

    } else {

        BRDC_fprintf( stderr, _BRDC("Stream working in regular mode\n"));
    }

    m_pBoard->dma_stop(strm);
    m_pBoard->dma_reset_fifo(strm);
    m_pBoard->dma_reset_fifo(strm);

    pStrm->status=1;

    return 0;
}

//-----------------------------------------------------------------------------

int CL_AMBPEX::StreamGetNextIndex( U32 strm, U32 index )
{
    if( strm>1 )
        return 0;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;
    int n=index+1;
    if( (U32)n>=pStrm->cnt_buf )
        n=0;
    return n;
}

//-----------------------------------------------------------------------------

void CL_AMBPEX::StreamDestroy( U32 strm )
{
    if( strm>1 )
        return;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status==0 )
        return;

    StreamStop( strm );

    m_pBoard->dma_free_memory( strm );

    pStrm->status=0;
}

//-----------------------------------------------------------------------------

U32* CL_AMBPEX::StreamGetBufByNum( U32 strm, U32 numBuf )
{
    if( strm>1 )
        return NULL;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=1 )
        return NULL;

    U32 *ptr;
    if( numBuf>=pStrm->cnt_buf )
        return NULL;
    ptr=(U32*)(pStrm->pBlk[numBuf]);
    return ptr;
}

//-----------------------------------------------------------------------------

void CL_AMBPEX::StreamStart( U32 strm )
{
    if( strm>1 )
        return;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=1 )
        return;

    U32 val;

    val=RegPeekInd( pStrm->trd, 0 );
    m_pBoard->dma_stop(strm);


    pStrm->indexDma=-1;
    pStrm->indexPc=-1;

    val=pStrm->cycle; // 0 - однократный режим, 1 - циклический

    m_pBoard->dma_start(strm, val);
}

//-----------------------------------------------------------------------------

void CL_AMBPEX::StreamStop( U32 strm )
{
    if( strm>1 )
        return;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;

    RegPokeInd( pStrm->trd, 0, 2 );

    m_pBoard->dma_stop(strm);
    m_pBoard->dma_reset_fifo(strm);

    RegPokeInd( pStrm->trd, 0, 0 );
}

//-----------------------------------------------------------------------------

int CL_AMBPEX::StreamGetBuf( U32 strm, U32** ptr )
{
    U32 *buf;
    int ret=0;

    if( strm>1 )
        return 0;

    StreamParam *pStrm= m_streamParam+strm;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    if( pStrm->indexPc==pStrm->indexDma )
    {
        pStrm->indexDma = StreamGetIndexDma( strm );
    }
    if( pStrm->indexPc!=pStrm->indexDma )
    {
        pStrm->indexPc=StreamGetNextIndex( strm, pStrm->indexPc );
        buf = StreamGetBufByNum( strm, pStrm->indexPc );
        *ptr = buf;
        ret=1;
        StreamGetBufDone( strm );
    }
    return ret;
}

//-----------------------------------------------------------------------------

int CL_AMBPEX::StreamGetIndexDma( U32 strm )
{
    if( strm>1 )
        return -1;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;

    if(!pStrm->pStub) {
        //fprintf(stderr, "%s(): pStub is %p\n", __FUNCTION__, pStrm->pStub);
        return 0;
    }

    int lastBlock = pStrm->pStub->lastBlock;

    //fprintf(stderr, "%s(): lastBlock = %d\n", __FUNCTION__, lastBlock);

    return lastBlock;
}

//-----------------------------------------------------------------------------

void CL_AMBPEX::StreamGetBufDone( U32 strm )
{
    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    if( strm>1 )
        return;

    StreamParam *pStrm= m_streamParam+strm;
    S32 err;
    static U32 err_code=0;

    if( pStrm->agree_mode )
    {
        //fprintf(stderr, "%s(): Press enter to continue block %d...\n", __FUNCTION__, pStrm->indexPc);
        //getchar();
        err = m_pBoard->dma_done(strm, pStrm->indexPc);
        if(!err)
            err_code++; // Ошибка перевода в согласованный режим
    }
}

//-----------------------------------------------------------------------------

void Sleep( int ms )
{
    struct timeval tv = {0, 0};
    tv.tv_usec = 1000*ms;

    select(0,NULL,NULL,NULL,&tv);
}

//-----------------------------------------------------------------------------
