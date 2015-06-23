

#define _USE_MATH_DEFINES

#include <math.h>
#include <stdio.h>
#include <fcntl.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "utypes.h"
//#include "useful.h"
#include "wb_teststrmout.h"
#include "cl_wbpex.h"



#define BUFSIZEPKG 62

#define TRDIND_MODE0					0x0
#define TRDIND_MODE1					0x9
#define TRDIND_MODE2					0xA
#define TRDIND_SPD_CTRL					0x204
#define TRDIND_SPD_ADDR					0x205
#define TRDIND_SPD_DATA					0x206


WB_TestStrmOut::WB_TestStrmOut( BRDCHAR* fname, CL_WBPEX *fotr )
{
    lc_status=0;

    Terminate=0;
    BlockRd=0;
    BlockOk=0;
    BlockError=0;
    TotalError=0;

    pBrd=fotr;

    SetDefault();
    GetParamFromFile( fname );
    CalculateParams();

    //	pDds=NULL;

    isFirstCallStep=true;

    SetSignalInit();
}

WB_TestStrmOut::~WB_TestStrmOut()
{
    pBrd->StreamDestroy( tr0.Strm );

}

void WB_TestStrmOut::Prepare( void )
{


    PrepareAdm();

    tr0.trd=trdNo;
    tr0.Strm=strmNo;
    pBrd->StreamInit( tr0.Strm, CntBuffer, SizeBuferOfBytes, tr0.trd, 2, isCycle, isSystem, isAgreeMode );

}

void WB_TestStrmOut::Start( void )
{
    int res = pthread_attr_init(&attrThread_);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_attr_setdetachstate(&attrThread_, PTHREAD_CREATE_JOINABLE);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_create(&hThread, &attrThread_, ThreadFunc, this);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }
}

void WB_TestStrmOut::Stop( void )
{
    if( isTest )
        TestCtrlStop( &tr0 );

    Terminate=1;
    lc_status=3;
}

void WB_TestStrmOut::Step( void )
{


    if( isTest )
        TestCtrlReadStatus( &tr0 );

    U32 status = 0;// pBrd->RegPeekDir( tr0.trd, 0 ) & 0xFFFF;
    BRDC_fprintf( stderr, "%6s %3d %10d %10d %10d %10d  %9.1f %10.1f     0x%.4X  \r", "TRD :", tr0.trd, tr0.BlockWr, tr0.BlockRd, tr0.BlockOk, tr0.BlockError, tr0.VelocityCurrent, tr0.VelocityAvarage, status );




}

int WB_TestStrmOut::isComplete( void )
{
    if( (lc_status==4)  )
        return 1;
    return 0;
}

void WB_TestStrmOut::GetResult( void )
{
    //if(pkg_in.BlockRd!=0 && pkg_in.BlockError!=0)
    //	printf("%s\n", pkg_in.testBuf.report_word_error());

    if( isTest )
    {
        BRDC_fprintf( stderr, "\n\nРезультат передачи данных через тетраду %d \n", trdNo );
        TestCtrlResult( &tr0 );
    }
    BRDC_fprintf( stderr, "\n\n" );
}

void* WB_TestStrmOut::ThreadFunc( void*   lpvThreadParm )
{
    WB_TestStrmOut *test=(WB_TestStrmOut*)lpvThreadParm;
    UINT ret;
    if( !test )
        return 0;
    ret=test->Execute();
    return (void*)ret;
}



//! Установка параметров по умолчанию
void WB_TestStrmOut::SetDefault( void )
{
    int ii=0;

    array_cfg[ii++]=STR_CFG(  0, "CntBuffer",			"16", (U32*)&CntBuffer, "число буферов стрима" );
    array_cfg[ii++]=STR_CFG(  0, "CntBlockInBuffer",	"512",  (U32*)&CntBlockInBuffer, "Число блоков в буфере" );
    array_cfg[ii++]=STR_CFG(  0, "SizeBlockOfWords",	"2048",  (U32*)&SizeBlockOfWords, "Размер блока в словах" );
    array_cfg[ii++]=STR_CFG(  0, "isCycle",				"1",  (U32*)&isCycle, "1 - Циклический режим работы стрима" );
    array_cfg[ii++]=STR_CFG(  0, "isSystem",			"0",  (U32*)&isSystem, "1 - выделение системной памяти" );
    array_cfg[ii++]=STR_CFG(  0, "isAgreeMode",			"0",  (U32*)&isAgreeMode, "1 - согласованный режим" );

    array_cfg[ii++]=STR_CFG(  0, "trdNo",	"4",  (U32*)&trdNo, "Номер тетрады" );
    array_cfg[ii++]=STR_CFG(  0, "strmNo",	"0",  (U32*)&strmNo, "Номер стрма" );
    array_cfg[ii++]=STR_CFG(  0, "isSdram",	"0",  (U32*)&isSdram, "1 - тетрада SDRAM" );
    array_cfg[ii++]=STR_CFG(  0, "isTest",	"0",  (U32*)&isTest, "0 - нет, 1 - проверка псевдослучайной последовательности" );

    array_cfg[ii++]=STR_CFG(  0, "DataType",	"0",  (U32*)&tr0.DataType, "Тип данных при фиксированном типе блока, 6 - счётчик, 8 - псевдослучайная последовательность" );

    array_cfg[ii++]=STR_CFG(  0, "DataFix",	"0",  (U32*)&tr0.DataFix, "1 - фиксированный тип блока, 0 - данные в блоке записят от номера блока" );



    max_item=ii;

    {
	char str[1024];
        for( unsigned ii=0; ii<max_item; ii++ )
	{
            sprintf( str, "%s  %s", array_cfg[ii].name, array_cfg[ii].def );
            GetParamFromStr( str );
	}


    }

}

//! Расчёт параметров
void WB_TestStrmOut::CalculateParams( void )
{
    SizeBlockOfBytes = SizeBlockOfWords * 4;						// Размер блока в байтах
    SizeBuferOfBytes	= CntBlockInBuffer * SizeBlockOfBytes  ;	// Размер буфера в байтах
    SizeStreamOfBytes	= CntBuffer * SizeBuferOfBytes;				// Общий размер буфера стрима

    ShowParam();
}

//! Отображение параметров
void WB_TestStrmOut::ShowParam( void )
{
    TF_WorkParam::ShowParam();

    BRDC_fprintf( stderr, "Общий размер буфера стрима: %d МБ\n\n", SizeStreamOfBytes/(1024*1024) );

}


U32 WB_TestStrmOut::Execute( void )
{
    tr0.testBuf.buf_check_start( 32, 64 );

    { // Начальное заполнение кольцевого буфера
        U32 ii, kk, mode;
        U32 *ptr, *ptrBlock;
        mode = (tr0.DataFix << 7) | (tr0.DataType<<8);
        for( kk=0; kk<CntBuffer; kk++ )
        {
            ptr=pBrd->StreamGetBufByNum( tr0.Strm, kk );
            for( ii=0; ii<CntBlockInBuffer; ii++ )
            {

                ptrBlock=ptr+ii*SizeBlockOfWords;

                if( isTest )
                    tr0.testBuf.buf_set( ptrBlock, tr0.BlockWr, SizeBlockOfWords, mode );
                else
                    SetSignal( ptrBlock );

                tr0.BlockWr++;

            }
        }

        TestCtrlStart( &tr0 );
    }




    //pBrd->RegPokeInd( tr0.trd, 0, 0x2030 );


    pBrd->StreamStart( tr0.Strm );




    tr0.BlockLast=tr0.BlockStart=tr0.BlockWr;

    //pBrd->RegPokeInd( tr0.trd, 0, 0x2038 );

    Sleep( 100 );



    tr0.time_last=tr0.time_start=0;//GetTickCount();


    for( ; ; )
    {
        if( Terminate )
        {
            break;
        }

        SendData( &tr0 );

    }
    //pBrd->RegPokeInd( tr0.trd, 0, 2 );
    Sleep( 200 );

    //pBrd->StreamStop( tr0.Strm );
    Sleep( 10 );


    lc_status=4;
    return 1;
}




void WB_TestStrmOut::SendData(  ParamExchange *pr )
{
    U32 *ptr;
    U32 *ptrBlock;
    U32 mode=0;
    mode |= pr->DataType<<8;
    mode |= pr->DataFix<<7;

    int ret;
    int kk;

    //pr->BlockRd++;
    //Sleep( 10 );
    //return;


    for( kk=0; kk<16; kk++ )
    {
        ret=pBrd->StreamGetBuf( pr->Strm, &ptr );
        if( ret )
        { // Заполнение буфера стрима
            for( unsigned ii=0; ii<CntBlockInBuffer; ii++ )
            {
                ptrBlock=ptr+ii*SizeBlockOfWords;

                if( isTest )
                    pr->testBuf.buf_set( ptrBlock, pr->BlockWr, SizeBlockOfWords, mode );
                /*
				else
					SetSignal( ptrBlock );
				*/
                pr->BlockWr++;
                if( isAgreeMode )
                {
                    pBrd->StreamGetBufDone( pr->Strm );
                }

            }
        } else
        {
            //Sleep( 0 );
            pr->freeCycle++;
            //break;
        }
    }
    //Sleep( 0 );

/*
    U32 currentTime = GetTickCount();
    if( (currentTime - pr->time_last)>4000 )
    {
        float t1 = currentTime - pr->time_last;
        float t2 = currentTime - pr->time_start;
        float v = 1000.0*(pr->BlockWr-pr->BlockLast)*SizeBlockOfBytes/t1;
        v/=1024*1024;
        pr->VelocityCurrent=v;

        v = 1000.0*(pr->BlockWr-pr->BlockStart)*SizeBlockOfBytes/t2;
        v/=1024*1024;
        pr->VelocityAvarage=v;
        pr->time_last = currentTime;
        pr->BlockLast = pr->BlockWr;
        pr->freeCycleZ=pr->freeCycle;
        pr->freeCycle=0;
	
    }
    //Sleep(1);
*/

}


void WB_TestStrmOut::PrepareAdm( void )
{
    U32 trd=trdNo;
    U32 id, id_mod, ver;
    BRDC_fprintf( stderr, "\nПодготовка тетрады\n" );


    //id = pBrd->RegPeekInd( trd, 0x100 );
    //id_mod = pBrd->RegPeekInd( trd, 0x101 );
    //ver = pBrd->RegPeekInd( trd, 0x102 );


    //BRDC_fprintf( stderr, "\nТетрада %d  ID: 0x%.2X MOD: %d  VER: %d.%d \n\n",
//            trd, id, id_mod, (ver>>8) & 0xFF, ver&0xFF );





}




//! Запуск проверки в тетраде TestCtrl
void WB_TestStrmOut::TestCtrlStart( ParamExchange *pr )
{
/*
    U32 trd=1;

    U32 check_size=SizeBlockOfBytes/4096;
    U32 check_ctrl= (pr->DataFix<<7) | (pr->DataType<<8);

    pBrd->RegPokeInd( trd, 0x0F, 1 );

    pBrd->RegPokeInd( trd, 0x1C, 1 ); // Reset
    Sleep( 10 );
    pBrd->RegPokeInd( trd, 0x1C, 0 );
    Sleep( 10 );
    pBrd->RegPokeInd( trd, 0x1D, check_size );
    pBrd->RegPokeInd( trd, 0x1C, check_ctrl | 0x20 );
*/

}



//! Остановка проверки в тетраде TestCtrl
void WB_TestStrmOut::TestCtrlStop( ParamExchange *pr )
{
/*
    U32 trd=1;

    U32 check_ctrl= (pr->DataFix<<7) | (pr->DataType<<8);

    pBrd->RegPokeInd( trd, 0x1C, check_ctrl ); // Останов
*/
}

//! Чтение текущего состояния тетрады TestCtrl
void WB_TestStrmOut::TestCtrlReadStatus( ParamExchange *pr )
{
/*
    U32 trd=1;
    U32 block_rd, block_ok, block_error, total_error;

    U32 reg_l, reg_h;

    reg_l = pBrd->RegPeekInd( trd, 0x210 );
    reg_h = pBrd->RegPeekInd( trd, 0x211 );
    block_rd = (reg_l&0xFFFF) | (reg_h<<16);

    reg_l = pBrd->RegPeekInd( trd, 0x212 );
    reg_h = pBrd->RegPeekInd( trd, 0x213 );
    block_ok = (reg_l&0xFFFF) | (reg_h<<16);

    reg_l = pBrd->RegPeekInd( trd, 0x214 );
    reg_h = pBrd->RegPeekInd( trd, 0x215 );
    block_error = (reg_l&0xFFFF) | (reg_h<<16);

    reg_l = pBrd->RegPeekInd( trd, 0x216 );
    reg_h = pBrd->RegPeekInd( trd, 0x217 );
    total_error = (reg_l&0xFFFF) | (reg_h<<16);

    pr->BlockRd=block_rd;
    pr->BlockOk=block_ok;
    pr->BlockError=block_error;
    pr->TotalError=total_error;

*/

}


//! Получение результата в тетраде TestCtrl
void WB_TestStrmOut::TestCtrlResult( ParamExchange *pr )
{
/*
    U32 trd=1;
    U32 block_rd, block_ok, block_error, total_error;

    U32 reg_l, reg_h;

    reg_l = pBrd->RegPeekInd( trd, 0x210 );
    reg_h = pBrd->RegPeekInd( trd, 0x211 );
    block_rd = (reg_l&0xFFFF) | (reg_h<<16);

    reg_l = pBrd->RegPeekInd( trd, 0x212 );
    reg_h = pBrd->RegPeekInd( trd, 0x213 );
    block_ok = (reg_l&0xFFFF) | (reg_h<<16);

    reg_l = pBrd->RegPeekInd( trd, 0x214 );
    reg_h = pBrd->RegPeekInd( trd, 0x215 );
    block_error = (reg_l&0xFFFF) | (reg_h<<16);

    reg_l = pBrd->RegPeekInd( trd, 0x216 );
    reg_h = pBrd->RegPeekInd( trd, 0x217 );
    total_error = (reg_l&0xFFFF) | (reg_h<<16);

    pr->BlockRd=block_rd;
    pr->BlockOk=block_ok;
    pr->BlockError=block_error;
    pr->TotalError=total_error;

    BRDC_fprintf( stderr, "\n Число принятых   блоков: %d \n",  block_rd );
    BRDC_fprintf( stderr, " Число правильных блоков: %d \n", block_ok );
    BRDC_fprintf( stderr, " Число ошибочных  блоков: %d \n", block_error );
    BRDC_fprintf( stderr, " Общее число ошибок:      %d \n\n", total_error );

    if( total_error>0 )
    {
        BRDC_fprintf( stderr, " Список ошибок:\n" );
        int cnt=total_error;
        if( cnt>16 )
            cnt=16;

        int ii;
        U32 block, adr, _adr;
        __int64 data_ex, data_in;
        __int64 r0, r1, r2, r3;

        BRDC_fprintf( stderr, "%5s %10s %10s %20s %20s   \n", "N", "Блок", "Адрес", "Ожидается", "Принято" );
        for( ii=0; ii<cnt; ii++ )
        {
            adr=(ii<<4) + 0; pBrd->RegPokeInd( trd, 0x218, adr ); r0 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 1; pBrd->RegPokeInd( trd, 0x218, adr ); r1 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 2; pBrd->RegPokeInd( trd, 0x218, adr ); r2 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 3; pBrd->RegPokeInd( trd, 0x218, adr ); r3 = pBrd->RegPeekInd( trd, 0x219 );
            data_in = ((r3&0xFFFF)<<48) | ((r2&0xFFFF)<<32) | ((r1&0xFFFF)<<16) | (r0&0xFFFF);

            adr=(ii<<4) + 4; pBrd->RegPokeInd( trd, 0x218, adr ); r0 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 5; pBrd->RegPokeInd( trd, 0x218, adr ); r1 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 6; pBrd->RegPokeInd( trd, 0x218, adr ); r2 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 7; pBrd->RegPokeInd( trd, 0x218, adr ); r3 = pBrd->RegPeekInd( trd, 0x219 );
            data_ex = ((r3&0xFFFF)<<48) | ((r2&0xFFFF)<<32) | ((r1&0xFFFF)<<16) | (r0&0xFFFF);

            adr=(ii<<4) + 8; pBrd->RegPokeInd( trd, 0x218, adr ); r0 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 9; pBrd->RegPokeInd( trd, 0x218, adr ); r1 = pBrd->RegPeekInd( trd, 0x219 );
            _adr = ((r1&0xFFFF)<<16) | (r0&0xFFFF);

            adr=(ii<<4) + 10; pBrd->RegPokeInd( trd, 0x218, adr ); r0 = pBrd->RegPeekInd( trd, 0x219 );
            adr=(ii<<4) + 11; pBrd->RegPokeInd( trd, 0x218, adr ); r1 = pBrd->RegPeekInd( trd, 0x219 );
            block = ((r1&0xFFFF)<<16) | (r0&0xFFFF);

            //BRDC_fprintf( stderr, "%5d %10d %10d     %.16ll64X     %.16ll64X \n", ii, block, _adr, data_ex, data_in );
            BRDC_fprintf( stderr, "%5d %10d %10d     %.llX     %.llX \n", ii, block, _adr, (long long)data_ex, (long long)data_in );
        }
	
        BRDC_fprintf( stderr, "\n" );
    }

*/

}

static U32 fa_data[4096];

//! Заполнение блока синусом
void WB_TestStrmOut::SetSignalInit( void )
{
    int ii;
    float v, arg;
    int   d;
    for( ii=0; ii<4096; ii++ )
    {
        arg=2*M_PI*ii/4096;
        v=10000*sin( arg );
        d=v;
        fa_data[ii]=d;
    }

    fa_cnt_re=0;
    fa_cnt_im=0x40000000;
    fa_inc_re=0x1000000;
    fa_inc_im=fa_inc_re;

}


//! Заполнение блока синусом
void WB_TestStrmOut::SetSignal( U32* ptr )
{
    int re, im;
    unsigned ii;
    int adr_re;
    int adr_im;
    U32 data;
    U32 *dst=ptr;

    fa_cnt_re=0;
    fa_cnt_im=0x40000000;
    fa_inc_re=0x4000000;
    fa_inc_im=fa_inc_re;

    U32 d=0x4000000/(SizeBlockOfWords/2);

    for( ii=0; ii<(SizeBlockOfWords); ii++ )
    {
        adr_re=(fa_cnt_re>>20) & 0x0FFF;
        adr_im=(fa_cnt_im>>20) & 0x0FFF;
        re=fa_data[adr_re];
        im=fa_data[adr_im];
        data = (im<<16) | (re&0xFFFF);
        *dst++=data;

        fa_cnt_re+=fa_inc_re;
        fa_cnt_im+=fa_inc_im;

        fa_inc_re-=d;
        fa_inc_im=fa_inc_re;
    }


}
