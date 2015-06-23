#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "utypes.h"
#include "tf_workparam.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//

TF_WorkParam::TF_WorkParam(void)
{

    max_item=0;
    memset( this, 0, sizeof( TF_WorkParam ) );

    SetDefault();
}

TF_WorkParam::~TF_WorkParam(void)
{
    U32 ii=0;

    // Освобождение памяти от строковых параметров
    for( ii=0; ii<max_item; ii++ )
    {
        if( array_cfg[ii].is_float==2 ) 
        {
            STR_CFG *cfg=array_cfg+ii;
            char **ptr=(char**)cfg->ptr;

            char *ps=*ptr;
            if( ps!=NULL )
                free( ps );
        }
    }
}

//! Установка параметров по умолчанию
void TF_WorkParam::SetDefault( void )
{

    U32 ii=0;

    // Освобождение памяти от строковых параметров
    for( ii=0; ii<max_item; ii++ )
    {
        if( array_cfg[ii].is_float==2 ) 
        {
            STR_CFG *cfg=array_cfg+ii;
            char **ptr=(char**)cfg->ptr;

            char *ps=*ptr;
            if( ps!=NULL )
                free( ps );
        }
    }


    ii=0;

    max_item=ii;

    {
	char str[1024];
        for( U32 ii=0; ii<max_item; ii++ )
	{
            sprintf( str, "%s  %s", array_cfg[ii].name, array_cfg[ii].def );
            GetParamFromStr( str );
	}


    }


}


//! Получение параметров из файла инициализации
void TF_WorkParam::GetParamFromFile( BRDCHAR* fname )
{

    FILE *in;

    in=BRDC_fopen( fname, _BRDC("rt") );
    if( in==NULL ) {
        BRDC_printf( _BRDC("Can't open configuration file: %s\r\n"), fname );
        return;
    }
    BRDC_printf( _BRDC("\r\nRead parameters from file: %s\r\n\r\n"), fname );

    char str[512];

    for( ; ; ) {
        if( fgets( str, 510, in )==NULL ) {
            break;
        }
        str[510]=0;
        GetParamFromStr( str );
    }
    log_out( "\r\n" );
    fclose( in );
}

//! Получение параметра из строки
U32 TF_WorkParam::GetParamFromStr( char* str )
{
    char name[256], val[256];
    U32 ii;
    int ret;
    U32 len=strlen( str )+1;
    ret=sscanf( str, "%128s %128s", name, val );
    if( ret==2 ) {
        for( ii=0; ii<max_item; ii++ ) {
            if( strcmp( array_cfg[ii].name, name )==0 ) {
                if( array_cfg[ii].is_float==0 ) {
                    sscanf( val, "%i", array_cfg[ii].ptr );
                } else if( array_cfg[ii].is_float==1 ) {
                    sscanf( val, "%g", (float*)array_cfg[ii].ptr );
                } else if( array_cfg[ii].is_float==2 ) {

                    {

                        STR_CFG *cfg=array_cfg+ii;
                        char **ptr=(char**)cfg->ptr;

                        char *ps=*ptr;
                        if( ps!=NULL )
                            free( ps );
                        ps = (char*)malloc( 128 );
                        //*(cfg->ptr)=(U32)ps;
                        sprintf( ps, "%s", val );

                    }
                } else if( array_cfg[ii].is_float==3 ) {
                    U32 v;
                    bool *p=(bool*)(array_cfg[ii].ptr);
                    sscanf( val, "%d", &v );
                    if( v ) {
                        *p=true;
                    } else {
                        *p=false;
                    }
                }
                break;
            }
        }
    }
    return len;
}


//! Расчёт параметров
void TF_WorkParam::CalculateParams( void )
{
    ShowParam();
}


//! Сохранение параметров в памяти
U32 TF_WorkParam::PutParamToMemory( char* ptr, U32 max_size )
{
    char str[256];
    int len;
    int total=0;
    U32 ii;
    STR_CFG *cfg;
/*
    *((U32*)ptr)=max_item;
    total=4;

    for( ii=0; ii<max_item; ii++ )
    {
        cfg=array_cfg+ii;
        str[0]=0;
        switch( cfg->is_float )
        {
        case 0: sprintf( str, "%s  %d \r\n", cfg->name, *(cfg->ptr) ); break;
        case 1:
            {
                float* v=(float*)(cfg->ptr);
                sprintf( str, "%s  %g \r\n", cfg->name, *v ); break;
            }
            break;
        case 2:
            {
                if( *(cfg->ptr)==0 )
                {
                    sprintf( str, "%s  \r\n", cfg->name );
                } else
                {
                    sprintf( str, "%s  %s \r\n", cfg->name,(char*)(*cfg->ptr) );
                }

            }
            break;

        }
        len=strlen( str )+1;
        if( (total+len)<(S32)max_size )
        {
            strcpy( ptr+total, str );
            total+=len;
        }
    }
*/    
    return total;
}

//! Получение параметров из памяти
void TF_WorkParam::GetParamFromMemory( char* ptr )
{
    char *src=ptr;
    U32 len;
    U32 n;
    n=*((U32*)ptr);
    U32 ii;
    int total=4;
/*
    for( ii=0; ii<n; ii++ )
    {
        src=ptr+total;
        len=GetParamFromStr( src );
        total+=len;
    }
*/
}


//! Отображение параметров
void TF_WorkParam::ShowParam( void )
{
    U32 ii;
    STR_CFG  *item;
    log_out( "\r\n\r\n\r\nParameters:\r\n\r\n" );
    for( ii=0; ii<max_item; ii++ )
    {
        item=array_cfg+ii;
        if( item->is_float==2 ) 
        {

            char **ptr=(char**)item->ptr;
            char *ps=*ptr;
            log_out( "%s  %s\r\n", item->name, ps );
        } else if( item->is_float==0 )
        {
            U32 ps=*((U32*)item->ptr);
            log_out( "%s  %d\r\n", item->name, ps );
        } else if( item->is_float==1 )
        {
            float ps=*((float*)item->ptr);
            log_out( "%s  %g\r\n", item->name, ps );
        } else if( item->is_float==3 )
        {
            U32 ps=*((U32*)item->ptr);
            if( ps ) log_out( "%s  %s\r\n", item->name, "true" );
            else log_out( "%s  %s\r\n", item->name, "false" );
        }
    }
    log_out( "\r\n\r\n\r\n" );

}


void TF_WorkParam::log_out( const char* format, ... )
{

    char buffer[2048];

    va_list marker;
    va_start( marker, format );
    vsprintf( buffer, format, marker );
    va_end( marker );

    printf( "%s", buffer );

}
