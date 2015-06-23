//---------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>

#include	"board.h"
//#include	"brderr.h"
//#include	"ctrlstrm.h"
//#include        "ctrlreg.h"
//#include        "useful.h"
//#include	"cl_wbpex.h"

#ifndef __PEX_BOARD_H__
    #include "pex_board.h"
#endif

#ifndef __BOARD_H__
    #include "board.h"
#endif

#include "cl_wbpex.h"
#include "sys/select.h"
//BRD_Handle g_hBrd=0;

//!  Инициализация модуля
U32  CL_WBPEX::init( void )
{
    //S32 err;
    //S32 num;

    /*
    if( g_hBrd<=0)
    {
        BRDC_fprintf( stderr, _BRDC("\r\nМодуль не найден\r\n") );
        return 1;
    } else {
        BRDC_fprintf( stderr, _BRDC("BRD_open() - Ok\r\n") );
        BRD_getInfo(1, &info );
    }
    */

    board *brd = new pex_board();
    m_pBoard = brd;

    brd->brd_open( "/dev/pexdrv0" );
    brd->brd_init();
    brd->brd_board_info();
    //brd->brd_pld_info();

    // сброс прошивки ПЛИС
    return 0;
}

//!  Завершение работы с модулем
void  CL_WBPEX::cleanup( void )
{
    //S32 ret;
    //ret=BRD_cleanup();

}




// Доступ к регистрам 



CL_WBPEX::CL_WBPEX()
{

}



int CL_WBPEX::StreamInit( U32 strm, U32 cnt_buf, U32 size_one_buf_of_bytes, U32 trd, U32 dir, U32 cycle, U32 system, U32 agree_mode )
{
    if( strm>1 )
        return 1;

    DEBUG_PRINT("CL_AMBPEX::%s( cycle=%d)\n", __FUNCTION__, cycle );

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=0 )
        return 1;

    pStrm->cnt_buf                  = cnt_buf;
    pStrm->size_one_buf_of_bytes    = size_one_buf_of_bytes;
    //pStrm->trd                      = trd;
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
                      _BRDC(" Buffer size: %lld MB  (%dx%d MB)\r\n\r\n"), size, cnt_buf, size_one_buf_of_bytes/(1024*1024) );
    } else {

        BRDC_fprintf( stderr, _BRDC("Allocation memory: \r\n")
                      _BRDC(" Type of buffer:    userspace memory\r\n")
                      _BRDC(" Buffer size: %lld MB  (%dx%d MB)\r\n\r\n"), size, cnt_buf, size_one_buf_of_bytes/(1024*1024) );
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
    m_pBoard->dma_set_local_addr( strm, 0x3000 );

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

int CL_WBPEX::StreamGetNextIndex( U32 strm, U32 index )
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

void CL_WBPEX::StreamDestroy( U32 strm )
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

U32* CL_WBPEX::StreamGetBufByNum( U32 strm, U32 numBuf )
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

void CL_WBPEX::StreamStart( U32 strm )
{
    if( strm>1 )
        return;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=1 )
        return;

    U32 val;

    //val=RegPeekInd( pStrm->trd, 0 );
    m_pBoard->dma_stop(strm);


    pStrm->indexDma=-1;
    pStrm->indexPc=-1;

    val=pStrm->cycle; // 0 - однократный режим, 1 - циклический

    m_pBoard->dma_start(strm, val);
}

void CL_WBPEX::StreamStop( U32 strm )
{
    if( strm>1 )
        return;

    DEBUG_PRINT("CL_AMBPEX::%s()\n", __FUNCTION__);

    StreamParam *pStrm= m_streamParam+strm;

    //RegPokeInd( pStrm->trd, 0, 2 );

    m_pBoard->dma_stop(strm);
    m_pBoard->dma_reset_fifo(strm);

    //RegPokeInd( pStrm->trd, 0, 0 );

}

int CL_WBPEX::StreamGetBuf( U32 strm, U32** ptr )
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

int CL_WBPEX::StreamGetIndexDma( U32 strm )
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

void CL_WBPEX::StreamGetBufDone( U32 strm )
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

/*
void Sleep( int ms )
{
    struct timeval tv = {0, 0};
    tv.tv_usec = 1000*ms;

    select(0,NULL,NULL,NULL,&tv);

}
*/



//! Запись в регистр блока на шине WB
void CL_WBPEX::wb_block_write( U32 nb, U32 reg, U32 val )
{
    if( (nb>1) || (reg>31) )
        return;
    m_pBoard->brd_bar1_write( nb*0x2000/8+reg, val );
}

//! Чтение из регистра блока на шине WB
U32 CL_WBPEX::wb_block_read( U32 nb, U32 reg )
{
    U32 ret;
    if( (nb>1) || (reg>31) )
        return -1;
    ret=m_pBoard->brd_bar1_read( nb*0x2000/8+reg );
    return ret;
}


