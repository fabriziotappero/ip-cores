
/*
#ifndef __PEX_H__
    #include "pex.h"
#endif
*/

#include "board.h"
#include "pex_board.h"

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------

#include <locale.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

#include "cl_ambpex.h"
#include "tf_test.h"
#include "tf_teststrm.h"
#include "tf_teststrmout.h"

#define DEVICE_NAME "/dev/pexdrv0"

CL_AMBPEX *pBrd = NULL;
U32 isTwoTest=0;
static volatile int exit_flag = 0;

void signa_handler(int signo)
{
    exit_flag = 1;
}

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
        pBrd = new CL_AMBPEX(DEVICE_NAME);

        int ret=pBrd->init();

        if( 0==ret )
        {
            BRDC_fprintf( stderr, _BRDC("Module "DEVICE_NAME" successfuly opened\n") );


            for( int trd=0; trd<8; trd++ )
                pBrd->RegPokeInd( trd, 0, 1 );

            for( int trd=0; trd<8; trd++ )
                for( int ii=1; ii<32; ii++ )
                    pBrd->RegPokeInd( trd, ii, 0 );

            for( int trd=0; trd<8; trd++ )
                pBrd->RegPokeInd( trd, 0, 0 );



        } else
        {
            BRDC_fprintf( stderr, _BRDC("Error open module "DEVICE_NAME": ret=0x%.8X\n"), ret );
            exit(-1);
        }

        if( fname[0]=='o' )
            pTest = new TF_TestStrmOut( fname, pBrd );
        else
            pTest = new TF_TestStrm( fname, pBrd );

        Sleep( 10 );

        if( fname2 )
        {
            isTwoTest=1;
            if( fname2[0]=='o' )
                pTest2 = new TF_TestStrmOut( fname2, pBrd );
            else
                pTest2 = new TF_TestStrm( fname2, pBrd );
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

            if( (isFirstCallStep && pTest->isDmaStart) || isTwoTest )
            {

                BRDC_fprintf( stderr, _BRDC("\n%10s %10s %10s %10s %10s %10s %10s %10s %10s\n"), _BRDC(""), _BRDC("BLOCK_WR"), _BRDC("BLOCK_RD"), _BRDC("BLOCK_OK"), _BRDC("BLOCK_ERR"), _BRDC("SPD_CURR"), _BRDC("SPD_AVR"), _BRDC("STATUS"), _BRDC("TIME"));
                BRDC_fprintf( stderr, _BRDC("\n"));
		
                if (isFirstCallStep)
                {
                    isFirstCallStep=false;
                }
		
            }


            if( false==isFirstCallStep )
            {
                pTest->Step();
                if( isTwoTest )
                    BRDC_fprintf( stderr, "\n" );
                if( pTest2 )
                    pTest2->Step();
                if( isTwoTest )
                    BRDC_fprintf( stderr, "\n" );
            }

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

    BRDC_fprintf( stderr, "Exit program\n" );

    return 0;
}
