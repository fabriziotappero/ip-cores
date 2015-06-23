//---------------------------------------------------------------------------

#ifndef TF_CheckItem_CL_AMBPEXH
#define TF_CheckItem_CL_AMBPEXH

#include "utypes.h"
#include "board.h"
#include "time.h"
#include "ctrlstrm.h"

class  CL_AMBPEX
{


public:
    // virtual char* GetName( void );  //!< Возвращает название класса

    //!  Инициализация модуля
    virtual U32  init( void );

    //!  Завершение работы с модулем
    virtual void  cleanup( void );


    int StreamInit( U32 strm, U32 cnt_buf, U32 size_one_buf_of_bytes, U32 trd, U32 dir, U32 cycle, U32 system, U32 agree_mode );

    void StreamDestroy( U32 strm );

    U32* StreamGetBufByNum( U32 strm, U32 numBuf );

    void StreamStart( U32 strm );

    void StreamStop( U32 strm );

    int StreamGetBuf( U32 strm, U32** ptr );

    int StreamGetIndexDma( U32 strm );

    int StreamGetNextIndex( U32 strm, U32 index );

    void StreamGetBufDone( U32 strm );

    // Доступ к регистрам

    //! Запись в косвенно адресуемый регистр
    void RegPokeInd( S32 trdNo, S32 rgnum, U32 val );

    //! Чтение из косвенно адресуемого регистра
    U32 RegPeekInd( S32 trdNo, S32 rgnum );

    //! Запись в прямой регистр
    void RegPokeDir( S32 trdNo, S32 rgnum, U32 val );

    //! Чтение из прямого регистра
    U32 RegPeekDir( S32 trdNo, S32 rgnum );


    CL_AMBPEX(const char *devname);
    virtual ~CL_AMBPEX();


private:
    //! Указатель на модуль
    board  *m_pBoard;


    struct StreamParam
    {
        U32 status;
        U32 strm;
        U32 cnt_buf;
        U32 size_one_buf_of_bytes;
        U32 trd;
        U32 cycle;
        U32 system;
        U32 dir;

        U32 indexDma;
        U32 indexPc;
        U32 agree_mode;

        BRDstrm_Stub	*pStub;

        U08 *pBlk[256];         //!< Массив указателей на блоки памяти

        StreamParam()
        {
            //memset( this, 0, sizeof( StreamParam ) );
        };
    };

    StreamParam  m_streamParam[2];


};

void Sleep(int ms);

//---------------------------------------------------------------------------

#endif
