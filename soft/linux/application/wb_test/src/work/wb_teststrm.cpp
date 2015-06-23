
#define __VERBOSE__

#include <stdio.h>
#include <fcntl.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include "utypes.h"
#include "wb_teststrm.h"
#include "cl_wbpex.h"
#include "sys/time.h"
//#include "useful.h"

#define BUFSIZEPKG 62

#define TRDIND_MODE0					0x0
#define TRDIND_MODE1					0x9
#define TRDIND_MODE2					0xA
#define TRDIND_SPD_CTRL					0x204
#define TRDIND_SPD_ADDR					0x205
#define TRDIND_SPD_DATA					0x206

#define TRDIND_TESTSEQ					0x0C
#define TRDIND_CHAN						0x10
#define TRDIND_FSRC						0x13
#define TRDIND_GAIN						0x15
#define TRDIND_CONTROL1					0x17
#define TRDIND_DELAY_CTRL				0x1F


long GetTickCount(void)
{
    struct timeval tv;
    struct timezone tz;
    gettimeofday(&tv, &tz);
    long ret=tv.tv_sec*1000 + tv.tv_usec/1000;
    return ret;
}

WB_TestStrm::WB_TestStrm( char* fname,  CL_WBPEX *pex )
{
    lc_status=0;

    Terminate=0;

    pBrd=pex;

    SetDefault();
    GetParamFromFile( fname );
    CalculateParams();

    isFirstCallStep=true;
}

WB_TestStrm::~WB_TestStrm()
{
    pBrd->StreamDestroy( rd0.Strm );

}

void WB_TestStrm::Prepare( void )
{


    PrepareWb();

    rd0.trd=0;
    rd0.Strm=strmNo;
    pBrd->StreamInit( rd0.Strm, CntBuffer, SizeBuferOfBytes, 0, 1, isCycle, isSystem, isAgreeMode );

}

void WB_TestStrm::Start( void )
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

void WB_TestStrm::Stop( void )
{
    Terminate=1;
    lc_status=3;
}

void WB_TestStrm::Step( void )
{


    rd0.testBuf.check_result( &rd0.BlockOk , &rd0.BlockError, NULL, NULL, NULL );

    long currentTime = GetTickCount();
    int min, sec_all, sec;
    sec_all= currentTime-rd0.time_start;
    sec_all/=1000;
    sec=sec_all%60;
    min=sec_all/60;


    U32 status = pBrd->wb_block_read( 1, 0x10 );
    rd0.BlockWr = pBrd->wb_block_read( 1, 0x11 );
    U32 sig = pBrd->wb_block_read( 1, 0x12 );

    BRDC_fprintf( stdout, "%6s %3d %10d %10d %10d %10d  %9.1f %10.1f     0x%.4X  0x%.8X  %u:%.2u \r", "TRD :", rd0.trd, rd0.BlockWr, rd0.BlockRd, rd0.BlockOk, rd0.BlockError, rd0.VelocityCurrent, rd0.VelocityAvarage, status, sig, min, sec );




}

int WB_TestStrm::isComplete( void )
{
    if( lc_status==4 )
        return 1;
    return 0;
}

void WB_TestStrm::GetResult( void )
{
    BRDC_fprintf( stderr, "\n\nResult of receiving data \n"  );

    BRDC_fprintf( stderr, "\n Recieved blocks :   %d \n",  rd0.BlockRd );
    BRDC_fprintf( stderr,   " Correct blocks  :   %d \n",  rd0.BlockOk );
    BRDC_fprintf( stderr,   " Incorrect blocks:   %d \n",  rd0.BlockError );
    BRDC_fprintf( stderr,   " Total errors    :   %d \n\n", rd0.TotalError );
    BRDC_fprintf( stderr,   " Speed           :   %.1f [Mbytes/s] \n", rd0.VelocityAvarage );

    long currentTime = GetTickCount();
    int min, sec_all, sec;
    sec_all= currentTime-rd0.time_start;
    sec_all/=1000;
    sec=sec_all%60;
    min=sec_all/60;

    BRDC_fprintf( stderr,   " Time of test    :   %d min %.2d sec\n\n", min, sec );


    if(rd0.BlockRd!=0 && rd0.BlockError==0)
    {
        BRDC_fprintf( stderr,"All data is correct. No error\n" );
    } else if( rd0.BlockRd==0 )
    {
        BRDC_fprintf( stderr,"Error - data is not received \n" );

    } else
    {
        BRDC_fprintf( stderr,"List of error:\n" );
        BRDC_fprintf( stderr,"%s\n", rd0.testBuf.report_word_error());
    }

    BRDC_fprintf( stderr, "\n\n" );
}

void* WB_TestStrm::ThreadFunc( void* lpvThreadParm )
{
    WB_TestStrm *test=(WB_TestStrm*)lpvThreadParm;
    UINT ret;
    if( !test )
        return 0;
    ret=test->Execute();
    return (void*)ret;
}

//! Установка параметров по умолчанию
void WB_TestStrm::SetDefault( void )
{
    int ii=0;

    array_cfg[ii++]=STR_CFG(  0, "CntBuffer",			"16", (U32*)&CntBuffer, "число буферов стрима" );
    array_cfg[ii++]=STR_CFG(  0, "CntBlockInBuffer",	"512",  (U32*)&CntBlockInBuffer, "Число блоков в буфере" );
    array_cfg[ii++]=STR_CFG(  0, "SizeBlockOfWords",	"2048",  (U32*)&SizeBlockOfWords, "Размер блока в словах" );
    array_cfg[ii++]=STR_CFG(  0, "isCycle",				"1",  (U32*)&isCycle, "1 - Циклический режим работы стрима" );
    array_cfg[ii++]=STR_CFG(  0, "isSystem",			"1",  (U32*)&isSystem, "1 - выделение системной памяти" );
    array_cfg[ii++]=STR_CFG(  0, "isAgreeMode",			"0",  (U32*)&isAgreeMode, "1 - согласованный режим" );

    array_cfg[ii++]=STR_CFG(  0, "strmNo",	"0",  (U32*)&strmNo, "Номер стрма" );
    array_cfg[ii++]=STR_CFG(  0, "isTest",	"0",  (U32*)&isTest, "0 - нет, 1 - проверка псевдослучайной последовательности, 2 - проверка тестовой последовательности" );


    array_cfg[ii++]=STR_CFG(  0, "FifoRdy",		"0",  (U32*)&isFifoRdy, "1 - генератор тестовой последовательности анализирует флаг готовности FIFO" );

    array_cfg[ii++]=STR_CFG(  0, "Cnt1",	"0",  (U32*)&Cnt1, "Число тактов записи в FIFO, 0 - постоянная запись в FIFO" );

    array_cfg[ii++]=STR_CFG(  0, "Cnt2",	"0",  (U32*)&Cnt2, "Число тактов паузы при записи в FIFO" );

    array_cfg[ii++]=STR_CFG(  0, "DataType",	"0",  (U32*)&DataType, "Тип данных при фиксированном типе блока, 6 - счётчик, 8 - псевдослучайная последовательность" );

    array_cfg[ii++]=STR_CFG(  0, "DataFix",	"0",  (U32*)&DataFix, "1 - фиксированный тип блока, 0 - данные в блоке записят от номера блока" );


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
void WB_TestStrm::CalculateParams( void )
{
    SizeBlockOfBytes = SizeBlockOfWords * 4;						// Размер блока в байтах
    SizeBuferOfBytes	= CntBlockInBuffer * SizeBlockOfBytes  ;	// Размер буфера в байтах
    SizeStreamOfBytes	= CntBuffer * SizeBuferOfBytes;				// Общий размер буфера стрима

    ShowParam();
}

//! Отображение параметров
void WB_TestStrm::ShowParam( void )
{
    TF_WorkParam::ShowParam();

    //BRDC_fprintf( stderr, "Size buffer: %d MB\n\n", SizeStreamOfBytes/(1024*1024) );

}


U32 WB_TestStrm::Execute( void )
{
    rd0.testBuf.buf_check_start( 32, 64 );

    pBrd->wb_block_write( 1, 8, 1 );

    pBrd->StreamStart( rd0.Strm );

    U32 val;
    val=pBrd->wb_block_read( 1, 0 );
    BRDC_fprintf( stderr, "ID=0x%.4X \n", val );

    val=pBrd->wb_block_read( 1, 1 );
    BRDC_fprintf( stderr, "VER=0x%.4X \n", val );

    val=pBrd->wb_block_read( 1, 8 );
    BRDC_fprintf( stderr, "GEN_CTRL=0x%.4X \n", val );

    pBrd->wb_block_write( 1, 8, 0 );

    BlockMode = DataType <<8;
    BlockMode |= DataFix <<7;


    U32 size = SizeBlockOfWords/1024;
    //if( isTestCtrl )
    {
        pBrd->wb_block_write( 1, 9, size );
        pBrd->wb_block_write( 1, 8, BlockMode | 0x20 );
    }


    val=pBrd->wb_block_read( 1, 8 );
    BRDC_fprintf( stderr, "GEN_CTRL=0x%.4X \n", val );

    rd0.time_last=rd0.time_start=GetTickCount();


    for( ; ; )
    {
        if( Terminate )
        {
            break;
        }

        ReceiveData( &rd0 );
        //Sleep( 100 );
    }

    pBrd->StreamStop( rd0.Strm );
    Sleep( 10 );

    lc_status=4;
    return 1;
}




void WB_TestStrm::ReceiveData(  ParamExchange *pr )
{
    U32 *ptr;
    U32 *ptrBlock;
    U32 mode=0;
    mode |= pr->DataType<<8;
    mode |= pr->DataFix<<7;

    int ret;
    int kk;


    for( kk=0; kk<16; kk++ )
    {
        ret=pBrd->StreamGetBuf( pr->Strm, &ptr );
        //ret=0;
        if( ret )
        { // check buffer

                for( unsigned ii=0; ii<CntBlockInBuffer; ii++ )
                {
                    ptrBlock=ptr+ii*SizeBlockOfWords;

                    if( 1==isTest )
                        pr->testBuf.buf_check_psd( ptrBlock, SizeBlockOfWords );
                    //int a=0;
                    else if( 2==isTest )
                        pr->testBuf.buf_check( ptrBlock, pr->BlockRd, SizeBlockOfWords, BlockMode );
                    else if( 4==isTest )
                        pr->testBuf.buf_check_inv( ptrBlock, SizeBlockOfWords );

                    pr->BlockRd++;
                }
                if( isAgreeMode )
                {
                    pBrd->StreamGetBufDone( pr->Strm );
                }

        } else
        {
            //Sleep( 0 );
            pr->freeCycle++;
            break;
        }
    }
    //Sleep( 0 );

    long currentTime = GetTickCount();
    if( (currentTime - pr->time_last)>4000 )
    {
        float t1 = currentTime - pr->time_last;
        float t2 = currentTime - pr->time_start;
        float v = 1000.0*(pr->BlockRd-pr->BlockLast)*SizeBlockOfBytes/t1;
        v/=1024*1024;
        pr->VelocityCurrent=v;

        v = 1000.0*(pr->BlockRd)*SizeBlockOfBytes/t2;
        v/=1024*1024;
        pr->VelocityAvarage=v;
        pr->time_last = currentTime;
        pr->BlockLast = pr->BlockRd;
        pr->freeCycleZ=pr->freeCycle;
        pr->freeCycle=0;

    }

}


void WB_TestStrm::PrepareWb( void )
{
/*
    BRDC_fprintf( stderr, "\nPrepare TEST_GENERATE\n" );



    BlockMode = DataType <<8;
    BlockMode |= DataFix <<7;

    //if( isTestCtrl )
    {
        pBrd->wb_block_write( 1, 9, 1 );
        pBrd->wb_block_write( 1, 8, BlockMode );
    }
*/

}



