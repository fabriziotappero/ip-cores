
/*
#ifndef __PEX_H__
    #include "pex.h"
#endif
*/

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>
//#include <conio.h>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------
/*
int main(int argc, char *argv[])
{

    if(argc == 1) {
        std::cerr << "usage: %s <device name>" << argv[0] << endl;
        return -1;
    }

    std ::cout << "Start testing device " << argv[1] << endl;

    board *brd = new pex_board();

    brd->brd_open(argv[1]);
    brd->brd_init();
    brd->brd_board_info();
    brd->brd_pld_info();

    for(int i=0; i<16; i++)
        std ::cout << "BAR0[" << i << "] = 0x" << hex << brd->brd_bar0_read(i) << dec << endl;

    brd->brd_close();

    delete brd;


    return 0;
}
*/
// FP_PEX8_TEST.cpp : Defines the entry point for the console application.
//
#include <locale.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

#include "cl_wbpex.h"
//#include "tf_test.h"
//#include "tf_teststrm.h"
//#include "tf_teststrmout.h"
//#include "useful.h"
#include "wb_teststrm.h"
#include "wb_teststrmout.h"

CL_WBPEX    g_Board;

U32 isTwoTest=0;

static volatile int exit_flag = 0;

void signa_handler(int signo)
{
    exit_flag = 1;
}


void ShowWishboneInfo( CL_WBPEX *pBrd );

//
//=== Console
//
//HANDLE	hConsoleOut;


int BRDC_main(int argc, BRDCHAR* argv[])
{
    // анализ командной строки
    setlocale( LC_ALL, "Russian" );
    signal(SIGINT, signa_handler);

    TF_Test  *pTest=NULL;
    TF_Test  *pTest2=NULL;

    BRDCHAR* fname = argv[1];
    BRDCHAR* fname2=NULL;
    if( argc<2 )
    {
        fname=(BRDCHAR*)_BRDC("");
    }
    if( argc==3 )
    {
        fname2=argv[2];
    }


    try
    {
        CL_WBPEX *pBrd = &g_Board;

        int ret=pBrd->init();

        if( 0==ret )
        {
            BRDC_fprintf( stderr, _BRDC("Board PEXDRV open succesfully\n") );



        } else
        {
            BRDC_fprintf( stderr, _BRDC("Error during open PEXDRV: ret=0x%.8X\n"), ret );
            //getch();
            exit(-1);
        }

        ShowWishboneInfo( pBrd );


        if( fname[0]=='o' )
            pTest = new WB_TestStrmOut( fname, pBrd );
        else
            pTest = new WB_TestStrm( fname, pBrd );

        Sleep( 10 );

        if( fname2 )
        {
            isTwoTest=1;
            if( fname2[0]=='o' )
                pTest2 = new WB_TestStrmOut( fname2, pBrd );
            else
                pTest2 = new WB_TestStrm( fname2, pBrd );
        }

        pTest->Prepare();
        if( pTest2 )
            pTest2->Prepare();

        Sleep( 10 );
        pTest->Start();
        Sleep( 10 );
        if( pTest2 )
            pTest2->Start();

        //int key;
        int isFirstCallStep=1;
        int isStopped = 0;
        for( ; ; )
        {


            if( exit_flag )
            {
                if(!isStopped) {
                    pTest->Stop();
                    if( pTest2 ) {
                        pTest2->Stop();
                    }
                    BRDC_fprintf( stderr, _BRDC("\n\nCancel\n") );
                    isStopped = 1;
                }
            }

            if( exit_flag )
            {
                if(isStopped) {

                    if( pTest->isComplete() ) {

                        if( pTest2 ) {
                            if( pTest2->isComplete() )
                                break;
                        } else {
                            break;
                        }
                    }
                }
            }


            //SetConsoleCursorPosition(hConsoleOut, rCursorPosition);
            if( isFirstCallStep || isTwoTest )
            {

              BRDC_fprintf( stdout, _BRDC("%10s %10s %10s %10s %10s %10s %10s %10s  %-10s  %-6s\n"), _BRDC(""), _BRDC("BLOCK_WR"), _BRDC("BLOCK_RD"), _BRDC("BLOCK_OK"), _BRDC("BLOCK_ERR"), _BRDC("SPD_CURR"), _BRDC("SPD_AVR"), _BRDC("STATUS"), _BRDC("SIG"), _BRDC("TIME"));
              BRDC_fprintf( stdout, _BRDC("\n"));
            }

            if (isFirstCallStep)
            {
                //CONSOLE_SCREEN_BUFFER_INFO csbInfo;
                //hConsoleOut = GetStdHandle( STD_OUTPUT_HANDLE );
                //GetConsoleScreenBufferInfo(hConsoleOut, &csbInfo);
                //rCursorPosition=csbInfo.dwCursorPosition;
                isFirstCallStep=false;

            }

            pTest->Step();
            if( isTwoTest )
                BRDC_fprintf( stderr, "\n" );
            if( pTest2 )
                pTest2->Step();
            if( isTwoTest )
                BRDC_fprintf( stderr, "\n\n" );

            Sleep( 400 );

            fflush( stdout );
        }
        pTest->GetResult();
        if( pTest2 )
            pTest2->GetResult();


        delete pTest; pTest=NULL;
        delete pTest2; pTest2=NULL;

    }
    catch( BRDCHAR* str )
    {
        BRDC_fprintf( stderr, _BRDC("Err: %s \n"), str );
    }
    catch( ... )
    {
        BRDC_fprintf( stderr, _BRDC("Неизвестная ошибка выполнения программы\n") );
    }


    BRDC_fprintf( stderr, "\n Press any key\n" );
    //getch();

//}
    return 0;
//#endif
}



void ShowWishboneInfo( CL_WBPEX *pBrd )
{


    {
        U32 d, d1, d2, d3, d4, d5, ii;
        U32 block_id, block_id_mod;
        U32 block_ver_major, block_ver_minor;
        const char *str;

        BRDC_fprintf( stderr, _BRDC("FPGA WB\r\n")  );


/*
        d=pBrd->RegPeekInd( 0, 0x108 );
        if( d==0x4953 ) {
            BRDC_fprintf( stderr, _BRDC("  SIG= 0x%.4X - Ok	\n"), d );
        } else {
            BRDC_fprintf( stderr, _BRDC("  SIG= 0x%.4X - Ошибка, ожидается 0x4953	\n"), d );
            throw( 1 );
        }

        d=pBrd->RegPeekInd( 0, 0x109 );  BRDC_fprintf( stderr, "   Версия интерфейса ADM:  %d.%d\n", d>>8, d&0xFF );
        d=pBrd->RegPeekInd( 0, 0x110 ); d1=pBrd->RegPeekInd( 0, 0x111 );
        BRDC_fprintf( stderr, "   Базовый модуль: 0x%.4X  v%d.%d\n", d, d1>>8, d1&0xFF );

        d=pBrd->RegPeekInd( 0, 0x112 ); d1=pBrd->RegPeekInd( 0, 0x113 );
        BRDC_fprintf( stderr, "   Субмодуль:      0x%.4X  v%d.%d\n", d, d1>>8, d1&0xFF );

        d=pBrd->RegPeekInd( 0, 0x10B );  BRDC_fprintf( stderr, "   Модификация прошивки ПЛИС:  %d \n", d );
        d=pBrd->RegPeekInd( 0, 0x10A );  BRDC_fprintf( stderr, "   Версия прошивки ПЛИС:       %d.%d\n", d>>8, d&0xFF );
        d=pBrd->RegPeekInd( 0, 0x114 );  BRDC_fprintf( stderr, "   Номер сборки прошивки ПЛИС: 0x%.4X\n", d );
*/

        BRDC_fprintf( stderr, "\nWB block info:\n\n" );
        for( ii=0; ii<2; ii++ ) {

            d= pBrd->wb_block_read( ii, 0 );
                block_id = d & 0xFFF; block_id_mod=(d>>12) & 0xF;

           d1=pBrd->wb_block_read( ii, 1 );
                block_ver_major=(d1>>8) & 0xFF;
                block_ver_minor=d1&0xFF;
            /*
            d2=pBrd->RegPeekInd( ii, 0x102 );
            d3=pBrd->RegPeekInd( ii, 0x103 );
            d4=pBrd->RegPeekInd( ii, 0x104 );
            d5=pBrd->RegPeekInd( ii, 0x105 );
            */

            switch( d ) {
                case 0x1A: str="TEST_CHECK    "; break;
                case 0x1B: str="TEST_GENERATE "; break;


            default: str="UNKNOW        "; break;
            }
            //BRDC_fprintf( stderr, " %d  0x%.8X 0x%.8X \n", ii, d, d1 );
	    
            BRDC_fprintf( stderr, " %d  0x%.4X %s ", ii, block_id, str );
            if( block_id>0 ) {
                BRDC_fprintf( stderr, " MOD: %-2d VER: %d.%d \n", block_id_mod, block_ver_major, block_ver_minor );
            } else {
                BRDC_fprintf( stderr, "\n" );
            }

        }


        BRDC_fprintf( stderr, "\r\n" );

    }
}

