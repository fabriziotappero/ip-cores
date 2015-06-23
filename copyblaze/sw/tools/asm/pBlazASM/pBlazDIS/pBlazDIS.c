/*
 *  Copyright © 2003..2010 : Henk van Kampen <henk@mediatronix.com>
 *
 *	This file is part of pBlazDIS.
 *
 *  pBlazMRG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  pBlazDIS is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with pBlazDIS.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>

#include "pbTypes.h"
#include "pbLibgen.h"

#ifdef TCC
#include "getopt.h"
#endif

#define MEMSIZE 4096

uint32_t Code[ MEMSIZE ] ;

static void usage( char * text ) {
	printf( "\n%s - %s\n", text, "Picoblaze Disassembler utility V1.0" ) ;
	printf( "\nUSAGE:\n" ) ;
	printf( "   pBlazDIS [-6] [-v] <MEM inputfile> <PSM outputfile>\n" ) ;
}

bool loadMEM( const char * strMEMfile ) {
	int i, j, addr ;
	uint32_t code ;
	char line[ 256 ], *p ;
	FILE * infile = NULL ;

	infile = fopen( strMEMfile, "r" ) ;
	if ( infile == NULL ) {
		fprintf( stderr, "? Unable to open MEM file '%s'", strMEMfile ) ;
		return false ;
	}

	for ( i = 0 ; i < MEMSIZE ; i++ )
		Code[ i ] = 0 ;

	for ( addr = -1 ; addr < MEMSIZE + 128 && fgets( line, sizeof( line ), infile ) != NULL; ) {
		if ( ( p = strchr( line, '@' ) ) != NULL ) {
			if ( sscanf( ++p, "%X", &addr ) != 1 ) {
				fprintf( stderr, "? Error in address in MEM file '%s'", strMEMfile ) ;
				return false ;
			}
		} else {
			if ( addr == -1 ) {
				fprintf( stderr, "? Missing address in MEM file '%s', assuming 0", strMEMfile ) ;
				addr = 0 ;
				// return false ;
			}
			sscanf( line, "%X", &code ) ;
			Code[ addr ] = code ;
			addr += 1 ;
		}
	}

	fclose( infile ) ;
	return true ;
}

static uint32_t DestReg( const int code ) {
	return ( code >> 8 ) & 0xF ;
}

static uint32_t SrcReg( const int code ) {
	return ( code >> 4 ) & 0xF ;
}

static uint32_t Constant( const int code ) {
	return code & 0xFF ;
}

static uint32_t Address10( const int code ) {
	return code & 0x3FF ;
}

static uint32_t Address12( const int code ) {
	return code & 0xFFF ;
}

static const char * Condition( const int code ) {
	const char * Conditions[ 4 ] = { "Z", "NZ", "C", "NC" } ;
	return  Conditions[ ( code >> 10 ) & 0x3 ] ;
}

static bool writePSM3( const char * strPSMfile ) {
	FILE * outfile = NULL ;
	int pc = 0 ;
	uint32_t c = 0 ;
	enum {
		stIDLE, stCODE, stDATA
	} state = stIDLE ;

	outfile = fopen( strPSMfile, "w" ) ;
	if ( outfile == NULL ) {
		fprintf( stderr, "? Unable to open output file '%s'", strPSMfile ) ;
		return false ;
	}
	for ( pc = 0 ; pc < 1024 ; ) {
		c = Code[ pc ] & 0x3FFFF ;
		switch ( state ) {
		case stIDLE :
			if ( c != 0 ) {
				switch ( pc ) {
				case 0x380 :
				    fprintf( outfile, "\n\t.SCR\t0x%.3X\n", pc ) ;
					state = stDATA ;
					break ;
				default :
				    fprintf( outfile, "\n\t.ORG\t0x%.3X\n", pc ) ;
					state = stCODE ;
				}
			} else
				pc += 1 ;
			break ;
		case stCODE :
			if ( c != 0 ) {
				switch ( c ) {
				case 0x00000 ... 0x00FFF :
					fprintf( outfile, "\tMOVE\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x01000 ... 0x01FFF :
					fprintf( outfile, "\tMOVE\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x0A000 ... 0x0AFFF :
					fprintf( outfile, "\tAND \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x0B000 ... 0x0BFFF :
					fprintf( outfile, "\tAND \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x0C000 ... 0x0CFFF :
					fprintf( outfile, "\tOR  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x0D000 ... 0x0DFFF :
					fprintf( outfile, "\tOR  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x0E000 ... 0x0EFFF :
					fprintf( outfile, "\tXOR \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x0F000 ... 0x0FFFF :
					fprintf( outfile, "\tXOR \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x12000 ... 0x12FFF :
					fprintf( outfile, "\tTEST\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x13000 ... 0x13FFF :
					fprintf( outfile, "\tTEST\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x18000 ... 0x18FFF :
					fprintf( outfile, "\tADD \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x19000 ... 0x19FFF :
					fprintf( outfile, "\tADD \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x1A000 ... 0x1AFFF :
					fprintf( outfile, "\tADDC\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x1B000 ... 0x1BFFF :
					fprintf( outfile, "\tADDC\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x1C000 ... 0x1CFFF :
					fprintf( outfile, "\tSUB \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x1D000 ... 0x1DFFF :
					fprintf( outfile, "\tSUB \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x1E000 ... 0x1EFFF :
					fprintf( outfile, "\tSUBC\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x1F000 ... 0x1FFFF :
					fprintf( outfile, "\tSUBC\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x14000 ... 0x14FFF :
					fprintf( outfile, "\tCOMP\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x15000 ... 0x15FFF :
					fprintf( outfile, "\tCOMP\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x20000 ... 0x20FFF :
					switch ( c & 0xF ) {
					case 0x2 :
						fprintf( outfile, "\tRL  \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0x6 :
						fprintf( outfile, "\tSL0 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0x7 :
						fprintf( outfile, "\tSL1 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0x0 :
						fprintf( outfile, "\tSLA \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0x4 :
						fprintf( outfile, "\tSLX \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;

					case 0xC :
						fprintf( outfile, "\tRR  \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0xE :
						fprintf( outfile, "\tSR0 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0xF :
						fprintf( outfile, "\tSR1 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0x8 :
						fprintf( outfile, "\tSRA \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;
					case 0xA :
						fprintf( outfile, "\tSRX \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
						break ;

					default :
						fprintf( outfile, "\tINST\t0x%.5X\t; 0x%.5X\n", c, c ) ;
					}
					break ;

				case 0x34000 ... 0x34FFF :
					fprintf( outfile, "\tJUMP\t0x%.3X\t; 0x%.5X\n", Address10( c ), c ) ;
					break ;
				case 0x35000 ... 0x35FFF :
					fprintf( outfile, "\tJUMP\t%s, 0x%.3X\t; 0x%.5X\n", Condition( c ), Address10( c ), c ) ;
					break ;

				case 0x30000 ... 0x30FFF :
					fprintf( outfile, "\tCALL\t0x%.3X\t; 0x%.5X\n", Address10( c ), c ) ;
					break ;
				case 0x31000 ... 0x31FFF :
					fprintf( outfile, "\tCALL\t%s, 0x%.3X\t; 0x%.5X\n", Condition( c ), Address10( c ), c ) ;
					break ;

				case 0x2A000 ... 0x2AFFF :
					fprintf( outfile, "\tRET\t \t; 0x%.5X\n", c ) ;
					break ;
				case 0x2B000 ... 0x2BFFF :
					fprintf( outfile, "\tRET\t%s \t; 0x%.5X\n", Condition( c ), c ) ;
					break ;

				case 0x2E000 ... 0x2EFFF :
					fprintf( outfile, "\tST  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x2F000 ... 0x2FFFF :
					fprintf( outfile, "\tST  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x06000 ... 0x06FFF :
					fprintf( outfile, "\tLD  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x07000 ... 0x07FFF :
					fprintf( outfile, "\tLD  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x2C000 ... 0x2CFFF :
					fprintf( outfile, "\tOUT \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x2D000 ... 0x2DFFF :
					fprintf( outfile, "\tOUT \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x04000 ... 0x04FFF :
					fprintf( outfile, "\tIN  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x05000 ... 0x05FFF :
					fprintf( outfile, "\tIN  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x3C000 :
					fprintf( outfile, "\tDINT\t \t; 0x%.5X\n", c ) ;
					break ;
				case 0x3C001 :
					fprintf( outfile, "\tEINT\t \t; 0x%.5X\n", c ) ;
					break ;
				case 0x38000 :
					fprintf( outfile, "\tRETI\tDISABLE\t; 0x%.5X\n", c ) ;
					break ;
				case 0x38001 :
					fprintf( outfile, "\tRETI\tENABLE\t; 0x%.5X\n", c ) ;
					break ;

				default :
					fprintf( outfile, "\tINST\t0x%.5X\t; 0x%.5X\n", c, c ) ;
				}
				pc += 1 ;
			} else
				state = stIDLE ;
			break ;
		case stDATA :
			if ( c != 0 ) {
				fprintf( outfile, "\t.BYT\t0x%.2X, 0x%.2X\t; 0x%.5X\n", c & 0xFF, ( c >> 8 ) & 0xFF, c ) ;
				pc += 1 ;
			} else
				state = stIDLE ;
			break ;
		}
	}
	fclose( outfile ) ;
	return true ;
}

static bool writePSM6( const char * strPSMfile ) {
	FILE * outfile = NULL ;
	int pc = 0 ;
	uint32_t c = 0 ;
	enum {
		stIDLE, stCODE, stDATA
	} state = stIDLE ;

	outfile = fopen( strPSMfile, "w" ) ;
	if ( outfile == NULL ) {
		fprintf( stderr, "? Unable to open output file '%s'", strPSMfile ) ;
		return false ;
	}
	for ( pc = 0 ; pc < MEMSIZE ; ) {
		c = Code[ pc ] & 0x3FFFF ;
		switch ( state ) {
		case stIDLE :
			if ( c != 0 ) {
				switch ( pc ) {
				case 0x380 :
				    fprintf( outfile, "\n\t.SCR\t0x%.3X\n", pc ) ;
					state = stDATA ;
					break ;
				default :
				    fprintf( outfile, "\n\t.ORG\t0x%.3X\n", pc ) ;
					state = stCODE ;
				}
			} else
				pc += 1 ;
			break ;
		case stCODE :
			if ( c != 0 ) {
				switch ( c ) {
				case 0x00000 ... 0x00FFF :
					fprintf( outfile, "\tMOVE\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x01000 ... 0x01FFF :
					fprintf( outfile, "\tMOVE\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x16000 ... 0x16FFF :
					fprintf( outfile, "\tSTAR\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x02000 ... 0x02FFF :
					fprintf( outfile, "\tAND \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x03000 ... 0x03FFF :
					fprintf( outfile, "\tAND \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x04000 ... 0x04FFF :
					fprintf( outfile, "\tOR  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x05000 ... 0x05FFF :
					fprintf( outfile, "\tOR  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x06000 ... 0x06FFF :
					fprintf( outfile, "\tXOR \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x07000 ... 0x07FFF :
					fprintf( outfile, "\tXOR \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x0C000 ... 0x0CFFF :
					fprintf( outfile, "\tTEST\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x0D000 ... 0x0DFFF :
					fprintf( outfile, "\tTEST\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x0E000 ... 0x0EFFF :
					fprintf( outfile, "\tTSTC\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x0F000 ... 0x0FFFF :
					fprintf( outfile, "\tTSTC\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x10000 ... 0x10FFF :
					fprintf( outfile, "\tADD \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x11000 ... 0x11FFF :
					fprintf( outfile, "\tADD \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x12000 ... 0x12FFF :
					fprintf( outfile, "\tADDC\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x13000 ... 0x13FFF :
					fprintf( outfile, "\tADDC\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x18000 ... 0x18FFF :
					fprintf( outfile, "\tSUB \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x19000 ... 0x19FFF :
					fprintf( outfile, "\tSUB \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x1A000 ... 0x1AFFF :
					fprintf( outfile, "\tSUBC\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x1B000 ... 0x1BFFF :
					fprintf( outfile, "\tSUBC\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x1C000 ... 0x1CFFF :
					fprintf( outfile, "\tCOMP\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x1D000 ... 0x1DFFF :
					fprintf( outfile, "\tCOMP\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x1E000 ... 0x1EFFF :
					fprintf( outfile, "\tCMPC\ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x1F000 ... 0x1FFFF :
					fprintf( outfile, "\tCMPC\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x14000 ... 0x14FFF :
					if ( c & 0xF0 ) {
						fprintf( outfile, "\tCORE\ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
					} else
						switch ( c & 0xF ) {
						case 0x2 :
							fprintf( outfile, "\tRL  \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0x6 :
							fprintf( outfile, "\tSL0 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0x7 :
							fprintf( outfile, "\tSL1 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0x0 :
							fprintf( outfile, "\tSLA \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0x4 :
							fprintf( outfile, "\tSLX \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;

						case 0xC :
							fprintf( outfile, "\tRR  \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0xE :
							fprintf( outfile, "\tSR0 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0xF :
							fprintf( outfile, "\tSR1 \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0x8 :
							fprintf( outfile, "\tSRA \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;
						case 0xA :
							fprintf( outfile, "\tSRX \ts%X   \t; 0x%.5X\n", DestReg( c ), c ) ;
							break ;

						default :
							fprintf( outfile, "\tINST\t0x%.5X\t; 0x%.5X\n", c, c ) ;
						}
					break ;

				case 0x22000 ... 0x22FFF :
					fprintf( outfile, "\tJUMP\t0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x32000 ... 0x32FFF :
					fprintf( outfile, "\tJUMP\tZ, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x36000 ... 0x36FFF :
					fprintf( outfile, "\tJUMP\tNZ, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x3A000 ... 0x3AFFF :
					fprintf( outfile, "\tJUMP\tC, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x3E000 ... 0x3EFFF :
					fprintf( outfile, "\tJUMP\tNC, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x26000 ... 0x26FFF :
					fprintf( outfile, "\tJUMP\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x20000 ... 0x20FFF :
					fprintf( outfile, "\tCALL\t0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x30000 ... 0x30FFF :
					fprintf( outfile, "\tCALL\tZ, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x34000 ... 0x34FFF :
					fprintf( outfile, "\tCALL\tNZ, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x38000 ... 0x38FFF :
					fprintf( outfile, "\tCALL\tC, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x3C000 ... 0x3CFFF :
					fprintf( outfile, "\tCALL\tNC, 0x%.3X\t; 0x%.5X\n", Address12( c ), c ) ;
					break ;
				case 0x24000 ... 0x24FFF :
					fprintf( outfile, "\tCALL\ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;

				case 0x25000 ... 0x25FFF :
					fprintf( outfile, "\tRET\t \t; 0x%.5X\n", c ) ;
					break ;
				case 0x31000 ... 0x31FFF :
					fprintf( outfile, "\tRET\t%s \t; 0x%.5X\n", "Z", c ) ;
					break ;
				case 0x35000 ... 0x35FFF :
					fprintf( outfile, "\tRET\t%s \t; 0x%.5X\n", "NZ", c ) ;
					break ;
				case 0x39000 ... 0x39FFF :
					fprintf( outfile, "\tRET\t%s \t; 0x%.5X\n", "C", c ) ;
					break ;
				case 0x3D000 ... 0x3DFFF :
					fprintf( outfile, "\tRET\t%s \t; 0x%.5X\n", "NC", c ) ;
					break ;
				case 0x21000 ... 0x21FFF :
					fprintf( outfile, "\tRET \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;


				case 0x2E000 ... 0x2EFFF :
					fprintf( outfile, "\tST  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x2F000 ... 0x2FFFF :
					fprintf( outfile, "\tST  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x0A000 ... 0x0AFFF :
					fprintf( outfile, "\tLD  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x0B000 ... 0x0BFFF :
					fprintf( outfile, "\tLD  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x2C000 ... 0x2CFFF :
					fprintf( outfile, "\tOUT \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x2D000 ... 0x2DFFF :
					fprintf( outfile, "\tOUT \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;
				case 0x2B000 ... 0x2BFFF :
					fprintf( outfile, "\tOUTK\t0x%.2X, 0x%X\t; 0x%.5X\n", ( c >> 4 ) & 0xFF, c & 0xF, c ) ;
					break ;

				case 0x08000 ... 0x08FFF :
					fprintf( outfile, "\tIN  \ts%X, s%X\t; 0x%.5X\n", DestReg( c ), SrcReg( c ), c ) ;
					break ;
				case 0x09000 ... 0x09FFF :
					fprintf( outfile, "\tIN  \ts%X, 0x%.2X\t; 0x%.5X\n", DestReg( c ), Constant( c ), c ) ;
					break ;

				case 0x28000 :
					fprintf( outfile, "\tDINT\t \t; 0x%.5X\n", c ) ;
					break ;
				case 0x28001 :
					fprintf( outfile, "\tEINT\t \t; 0x%.5X\n", c ) ;
					break ;
				case 0x29000 :
					fprintf( outfile, "\tRETI\tDISABLE\t; 0x%.5X\n", c ) ;
					break ;
				case 0x29001 :
					fprintf( outfile, "\tRETI\tENABLE\t; 0x%.5X\n", c ) ;
					break ;

				case 0x37000 :
					fprintf( outfile, "\tBANK\tA\t; 0x%.5X\n", c ) ;
					break ;
				case 0x37001 :
					fprintf( outfile, "\tBANK\tB\t; 0x%.5X\n", c ) ;
					break ;

				default :
					fprintf( outfile, "\tINST\t0x%.5X\t; 0x%.5X\n", c, c ) ;
				}
				pc += 1 ;
			} else
				state = stIDLE ;
			break ;
		case stDATA :
			if ( c != 0 ) {
				fprintf( outfile, "\t.BYT\t0x%.2X, 0x%.2X\t; 0x%.5X\n", c & 0xFF, ( c >> 8 ) & 0xFF, c ) ;
				pc += 1 ;
			} else
				state = stIDLE ;
			break ;
		}
	}
	fclose( outfile ) ;
	return true ;
}

int main( int argc, char *argv[] ) {
	char mem_filename[ 256 ] = { '\0' } ;
	char psm_filename[ 256 ] = { '\0' } ;

	bool bOptErr = false ;
	bool bKCPSM6 = false ;
	bool bVerbose = false ;

	extern char * optarg ;
	extern int optind, optopt, opterr ;
	int optch ;

	opterr = -1 ;
	while ( ( optch = getopt( argc, argv, "hv6" ) ) != -1 ) {
		switch ( optch ) {
		case 'h' :
			bOptErr = true ;
			break ;
		case '6' :
			bKCPSM6 = true ;
			break ;
		case 'v' :
			bVerbose = true ;
			break ;
		default :
			fprintf( stderr, "? unknown option: -%c\n", optopt ) ;
			bOptErr = true ;
			break ;
		}
	}

	if ( bOptErr ) {
		usage( basename( argv[ 0 ] ) ) ;
		exit( -1 ) ;
	}

	// source filename
	if ( argv[ optind ] == NULL ) {
		fprintf( stderr, "? source file missing\n" ) ;
		usage( basename( argv[ 0 ] ) ) ;
		exit( -1 ) ;
	}
	strcpy( mem_filename, argv[ optind++ ] ) ;
	if ( strrchr( mem_filename, '.' ) == NULL )
		strcat( mem_filename, ".mem" ) ;
	if ( bVerbose )
		printf( "! MEM file: %s\n", mem_filename ) ;

	// output filename
	if ( argv[ optind ] == NULL ) {
		strcpy( psm_filename, filename( mem_filename ) ) ;
	} else {
		strcpy( psm_filename, argv[ optind++ ] ) ;
	}
	if ( strrchr( psm_filename, '.' ) == NULL )
		strcat( psm_filename, ".psm" ) ;
	if ( bVerbose )
		printf( "! output file: %s\n", psm_filename ) ;

	if ( loadMEM( mem_filename ) ) {
		if ( bKCPSM6 )
			writePSM6( psm_filename ) ;
		else
			writePSM3( psm_filename ) ;
		exit( 0 ) ;
	} else
		exit( -2 ) ;
}
