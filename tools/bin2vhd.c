/* 
 * RISE microprocessor bin2vhd utility
 * Copyright (c) 2006 Christian Walter <wolti@sil.at>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * File: $Id: bin2vhd.c,v 1.2 2007-01-25 21:08:25 cwalter Exp $
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <assert.h>

#define PROGNAME                "bin2vhd"
#define VHDL_ENTITY_NAME        "pgrom"
#define VHDL_ARCHITECTURE_NAME  "pgrom_rtl"

#define ADDRESS_BITS            16
#define DATA_BITS               16
#define IS_SYNCHRONOUS          0
#define PC_INCREMENT            2

#define NELEMS( x )             ( sizeof( x )/ sizeof( x[0] ) )

void            vPrintUsage( void );
void            vWriteEntity( FILE * pxOutputFile );
void            vWriteArchitectureHeader( FILE * pxOutputFile );
void            vWriteArchitectureData( FILE * pxOutputFile, const unsigned char *pucData,
                                        int iNBytes );
void            vWriteArchitectureFooter( FILE * pxOutputFile );
const char     *pcData2Hex( unsigned int uiHexValue );
const char     *pcAddress2Hex( unsigned int uiHexValue );

int
main( int argc, char **argv )
{
    int             iExitStatus = EXIT_FAILURE;
    FILE           *pxInputFile, *pxOutputFile;
    unsigned char   arucBuffer[80];
    size_t          xNBytesRead;
    size_t          xNBytesOffset;

    if( argc != 3 )
    {
        vPrintUsage(  );
    }
    else if( ( pxInputFile = fopen( argv[1], "r" ) ) == NULL )
    {
        fprintf( stderr, "%s: can't open input file %s: %s\n", PROGNAME, argv[1],
                 strerror( errno ) );
    }
    else if( ( pxOutputFile = fopen( argv[2], "w" ) ) == NULL )
    {
        fprintf( stderr, "%s: can't open input file %s: %s\n", PROGNAME, argv[1],
                 strerror( errno ) );
    }
    else
    {
        assert( ( DATA_BITS % 8 ) == 0 );
        assert( ( ADDRESS_BITS % 8 ) == 0 );
        vWriteEntity( pxOutputFile );

        vWriteArchitectureHeader( pxOutputFile );
        xNBytesOffset = 0;
        do
        {
            xNBytesRead = fread( &arucBuffer[xNBytesOffset], 1,
                                 NELEMS( arucBuffer ) - xNBytesOffset, pxInputFile );
            if( xNBytesRead > 0 )
            {
                xNBytesOffset = xNBytesRead % ( DATA_BITS / 8 );
                vWriteArchitectureData( pxOutputFile, arucBuffer, xNBytesRead - xNBytesOffset );
            }
        }
        while( xNBytesRead > 0 );
        vWriteArchitectureFooter( pxOutputFile );

        ( void )fclose( pxOutputFile );
        ( void )fclose( pxInputFile );

    }
}

void
vPrintUsage(  )
{
    fprintf( stderr, "Usage:\n" );
    fprintf( stderr, "  bin2vhd source dest\n" );
}

void
vWriteEntity( FILE * pxOutputFile )
{
    fprintf( pxOutputFile, "library IEEE;\n" );
    fprintf( pxOutputFile, "use IEEE.STD_LOGIC_1164.all;\n" );
    fprintf( pxOutputFile, "use IEEE.NUMERIC_STD.all;\n" );
    fprintf( pxOutputFile, "entity %s is\n", VHDL_ENTITY_NAME );
    fprintf( pxOutputFile, "port (\n" );
    fprintf( pxOutputFile, "  clk   : in std_logic;\n" );
    fprintf( pxOutputFile, "  addr  : in std_logic_vector(%d downto 0 );\n", ( ADDRESS_BITS - 1 ) );
    fprintf( pxOutputFile, "  data  : out std_logic_vector(%d downto 0 ) );\n", ( DATA_BITS - 1 ) );
    fprintf( pxOutputFile, "end %s;\n", VHDL_ENTITY_NAME );
    fprintf( pxOutputFile, "\n" );
}

void
vWriteArchitectureHeader( FILE * pxOutputFile )
{
    fprintf( pxOutputFile, "architecture %s of %s is\n", VHDL_ARCHITECTURE_NAME, VHDL_ENTITY_NAME );
    fprintf( pxOutputFile, "  signal sig_data_next :  std_logic_vector(%d downto 0 );\n",
             ( DATA_BITS - 1 ) );
    if( IS_SYNCHRONOUS )
    {
        fprintf( pxOutputFile, "  signal sig_data_int :  std_logic_vector(%d downto 0 ) );\n",
                 ( DATA_BITS - 1 ) );
        fprintf( pxOutputFile, "begin\n" );
        fprintf( pxOutputFile, "  data <= sig_data_int\n" );
        fprintf( pxOutputFile, "process (clk)\n" );
        fprintf( pxOutputFile, "  if clk'event and clk = '1' then\n" );
        fprintf( pxOutputFile, "    sig_data_int <= sig_data_next;\n" );
        fprintf( pxOutputFile, "  end if;\n" );
        fprintf( pxOutputFile, "end process;\n" );
    }
    else
    {
        fprintf( pxOutputFile, "begin\n" );
        fprintf( pxOutputFile, "  data <= sig_data_next;\n" );
    }
    fprintf( pxOutputFile, "\n" );
    fprintf( pxOutputFile, "  process( addr )\n" );
    fprintf( pxOutputFile, "  begin\n" );
    fprintf( pxOutputFile, "    case addr is\n" );
}

void
vWriteArchitectureData( FILE * pxOutputFile, const unsigned char *pucData, int iNBytes )
{
    static char     arucBuffer[( DATA_BITS / 4 ) + 1];
    static unsigned int uiProgrammCounter = 0;
    int             iBytePos, i;

    for( iBytePos = 0; iBytePos < iNBytes; )
    {
        for( i = 0; i < ( DATA_BITS / 4 ); i += 2, iBytePos++ )
        {
            sprintf( &arucBuffer[i], "%02X", pucData[iBytePos] );
        }
        fprintf( pxOutputFile, "      when x\"%s\" => sig_data_next <= x\"%*s\";\n",
                 pcAddress2Hex( uiProgrammCounter ), DATA_BITS / 4, arucBuffer );
        uiProgrammCounter += PC_INCREMENT;
    }
}

void
vWriteArchitectureFooter( FILE * pxOutputFile )
{
    fprintf( pxOutputFile, "      when others  => sig_data_next <= ( others => '0' );\n" );
    fprintf( pxOutputFile, "    end case;\n" );
    fprintf( pxOutputFile, "  end process;\n" );
    fprintf( pxOutputFile, "\n" );
    fprintf( pxOutputFile, "end %s;", VHDL_ARCHITECTURE_NAME );
}

const char     *
pcAddress2Hex( unsigned int uiHexValue )
{
    static char     arucBuffer[ADDRESS_BITS / 4 + 1];

    snprintf( arucBuffer, NELEMS( arucBuffer ), "%0*x", DATA_BITS / 4, uiHexValue );
    return arucBuffer;
}
