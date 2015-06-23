//---------------------------------------------------------------------------

#ifndef TF_CheckItem_CL_WBPEXH
#define TF_CheckItem_CL_WBPEXH

#include "utypes.h"
#include "board.h"
#include "time.h"
#include "ctrlstrm.h"

//#include <string.h>

class board;

class  CL_WBPEX
{


public:

    //!  Инициализация модуля
    virtual U32  init( void );

    //!  Завершение работы с модулем
    virtual void  cleanup( void );


    int StreamInit( U32 strm, U32 cnt_buf, U32 size_one_buf_of_bytes, U32 loc_wb_adr, U32 dir, U32 cycle, U32 system, U32 agree_mode );

    void StreamDestroy( U32 strm );

    U32* StreamGetBufByNum( U32 strm, U32 numBuf );

    void StreamStart( U32 strm );

    void StreamStop( U32 strm );

    int StreamGetBuf( U32 strm, U32** ptr );

    int StreamGetIndexDma( U32 strm );

    int StreamGetNextIndex( U32 strm, U32 index );

    void StreamGetBufDone( U32 strm );

    // Доступ к регистрам

    //! Запись в регистр блока на шине WB
    void wb_block_write( U32 nb, U32 reg, U32 val );

    //! Чтение из регистра блока на шине WB
    U32 wb_block_read( U32 nb, U32 reg );


    CL_WBPEX();


private:


    //! Указатель на модуль
    board  *m_pBoard;


    struct StreamParam
    {
        U32 status;
        U32 strm;
        U32 cnt_buf;
        U32 size_one_buf_of_bytes;
        U32 loc_wb_adr;
        U32 cycle;
        U32 system;
        U32 dir;

        U32 indexDma;
        U32 indexPc;
        U32 agree_mode;

        //BRD_Handle  hStream;
        BRDstrm_Stub	*pStub;
        U08 *pBlk[256];         //!< Массив указателей на блоки памяти

        StreamParam()
        {
            //memset( this, 0, sizeof( StreamParam ) );
        };
    };

    StreamParam  m_streamParam[2];


};

void Sleep( int ms );
//---------------------------------------------------------------------------
#endif
