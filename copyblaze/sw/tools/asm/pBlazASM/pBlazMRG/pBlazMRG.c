/*
 *  Copyright © 2003..2010 : Henk van Kampen <henk@mediatronix.com>
 *
 *	This file is part of pBlazMRG.
 *
 *  pBlazMRG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  pBlazMRG is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with pBlazMRG.  If not, see <http://www.gnu.org/licenses/>.
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

#define MAXMEM	4096

uint32_t Code[ 4096 ] ;

static void usage( char * text ) {
	printf( "\n%s - %s\n", text, "Picoblaze Assembler merge utility V1.1" ) ;
	printf( "\nUSAGE:\n" ) ;
	printf( "   pBlazMRG [-v] [-s<MEM data inputfile] -e<entity_name> <MEM code inputfile> <TPL inputfile> <ROM outputfile>\n" ) ;
}

bool loadMEM( const char * strCodefile, const char * strDatafile ) {
	int i, addr ;
	uint32_t code ;
	char line[ 256 ], *p ;
	FILE * infile = NULL ;

	for ( i = 0 ; i < MAXMEM; i++ )
		Code[ i ] = 0 ;

	infile = fopen( strCodefile, "r" ) ;
	if ( infile == NULL ) {
		fprintf( stderr, "? Unable to open code MEM file '%s'", strCodefile ) ;
		return false ;
	}

	for ( addr = -1 ; addr < MAXMEM && fgets( line, sizeof( line ), infile ) != NULL; ) {
		if ( ( p = strchr( line, '@' ) ) != NULL ) {
			if ( sscanf( ++p, "%X", &addr ) != 1 ) {
				fprintf( stderr, "? Missing address in code MEM file '%s'", strCodefile ) ;
				return false ;
			}
		} else {
			if ( addr == -1 ) {
				fprintf( stderr, "? Missing address in code MEM file '%s'", strCodefile ) ;
				return false ;
			}
			sscanf( line, "%X", &code ) ;
			Code[ addr ] = code ;

			addr += 1 ;
		}
	}

	fclose( infile ) ;

	if (strlen( strDatafile ) == 0 )
		return true ;

	infile = fopen( strDatafile, "r" ) ;
	if ( infile == NULL ) {
		fprintf( stderr, "? Unable to open data SCR file '%s'", strDatafile ) ;
		return false ;
	}

	for ( addr = -1 ; addr < MAXMEM && fgets( line, sizeof( line ), infile ) != NULL; ) {
		if ( ( p = strchr( line, '@' ) ) != NULL ) {
			if ( sscanf( ++p, "%X", &addr ) != 1 ) {
				fprintf( stderr, "? Missing address in data SCR file '%s'", strDatafile ) ;
				return false ;
			}
		} else {
			if ( addr == -1 ) {
				fprintf( stderr, "? Missing address in data SCR file '%s'", strDatafile ) ;
				return false ;
			}
			sscanf( line, "%X", &code ) ;
			if ( addr & 1 )
				Code[ addr / 2 ] |= ( Code[ addr / 2 ] & 0x001FF ) | ( ( code & 0xFF ) << 8 ) ;
			else
				Code[ addr / 2 ] |= ( Code[ addr / 2 ] & 0x3FF00 ) | ( ( code & 0xFF ) << 0 ) ;

			addr += 1 ;
		}
	}

	fclose( infile ) ;

// debug values
//for ( i = 0 ; i < MAXMEM; i++ )
//Code[ i ] = i | ( i << 6 ) | ( i << 12 ) ;

	return true ;
}

bool mergeTPL( const char * strTPLfile, const char * strROMfile, const char * strEntity ) {
	FILE * infile = NULL ;
	FILE * outfile = NULL ;
	enum {
		stIDLE, stCOPY, stMERGE
	} state = stIDLE ;
	char buffer[ 65 ] ;
	uint32_t code, line, bit ;
	int c ;
	int p = 0 ;
	int i ;

	infile = fopen( strTPLfile, "r" ) ;
	if ( infile == NULL ) {
		fprintf( stderr, "? Unable to open template file '%s'", strTPLfile ) ;
		return false ;
	}

	outfile = fopen( strROMfile, "w" ) ;
	if ( outfile == NULL ) {
		fprintf( stderr, "? Unable to open output file '%s'", strROMfile ) ;
		fclose( infile ) ;
		return false ;
	}

	while ( ( c = fgetc( infile ) ) != EOF ) {
		switch ( state ) {
		case stIDLE :
			buffer[ 0 ] = '\0' ;
			if ( c == '{' ) {
				state = stMERGE ;
				p = 0 ;
			}
			break ;

		case stCOPY :
			if ( c == '{' ) {
				state = stMERGE ;
				p = 0 ;
			} else {
				fputc( c, outfile ) ;
			}
			break ;

		case stMERGE :
			if ( c != '}' ) {
				if ( p < 64 ) {
					buffer[ p++ ] = c ;
					buffer[ p ] = '\0' ;
				}
			} else if ( strlen( buffer ) > 0 ) {
				// BYTE based INITs
				if ( strncmp( "[8:0]_INIT_", buffer, 11 ) == 0 ) {
					sscanf( buffer, "[8:0]_INIT_%02X", &line ) ;
					if ( line < 128 )
						for ( i = 31 ; i >= 0; i-- ) {
							fprintf( outfile, "%02X", ( Code[ line * 32 + i ] >> 0 ) & 0xFF ) ;
						}
					state = stCOPY ;
				// parity bits
				} else if ( strncmp( "[8:0]_INITP_", buffer, 12 ) == 0 ) {
					// accumulate all bits 8
					sscanf( buffer, "[8:0]_INITP_%02X", &line ) ;
					if ( line < 16 )
						for ( i = 31 ; i >= 0; i-- ) {
							code  =  ( Code[ ( line * 32 + i ) * 8 + 0 ] >> 8 ) & 0x01 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 1 ] >> 8 ) & 0x01 ) << 1 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 2 ] >> 8 ) & 0x01 ) << 2 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 3 ] >> 8 ) & 0x01 ) << 3 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 4 ] >> 8 ) & 0x01 ) << 4 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 5 ] >> 8 ) & 0x01 ) << 5 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 6 ] >> 8 ) & 0x01 ) << 6 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 7 ] >> 8 ) & 0x01 ) << 7 ;
							fprintf( outfile, "%02X", code ) ;
						}
					state = stCOPY ;

				} else if ( strncmp( "[17:9]_INIT_", buffer, 12 ) == 0 ) {
					sscanf( buffer, "[17:9]_INIT_%02X", &line ) ;
					if ( line < 128 )
						for ( i = 31 ; i >= 0; i-- ) {
							fprintf( outfile, "%02X", ( Code[ line * 32 + i ] >> 9 ) & 0xFF ) ;
						}
					state = stCOPY ;
				// parity bits
				} else if ( strncmp( "[17:9]_INITP_", buffer, 13 ) == 0 ) {
					// accumulate all bits 17
					sscanf( buffer, "[17:9]_INITP_%02X", &line ) ;
					if ( line < 16 )
						for ( i = 31 ; i >= 0; i-- ) {
							code  =  ( Code[ ( line * 32 + i ) * 8 + 0 ] >> 17 ) & 0x01 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 1 ] >> 17 ) & 0x01 ) << 1 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 2 ] >> 17 ) & 0x01 ) << 2 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 3 ] >> 17 ) & 0x01 ) << 3 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 4 ] >> 17 ) & 0x01 ) << 4 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 5 ] >> 17 ) & 0x01 ) << 5 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 6 ] >> 17 ) & 0x01 ) << 6 ;
							code |= (( Code[ ( line * 32 + i ) * 8 + 7 ] >> 17 ) & 0x01 ) << 7 ;
							fprintf( outfile, "%02X", code ) ;
						}
					state = stCOPY ;

				// WORD based INITs
				} else if ( strncmp( "INIT_", buffer, 5 ) == 0 ) {
					sscanf( buffer, "INIT_%02X", &line ) ;
					if ( line < 128 )
						for ( i = 15 ; i >= 0; i-- ) {
							fprintf( outfile, "%04X", ( Code[ line * 16 + i ] >> 0 ) & 0xFFFF ) ;
						}
					state = stCOPY ;
				// parity bits
				} else if ( strncmp( "INITP_", buffer, 6 ) == 0 ) {
					sscanf( buffer, "INITP_%02X", &line ) ;
					if ( line < 16 )
						for ( i = 31 ; i >= 0; i-- ) {
							code  =  ( Code[ ( line * 32 + i ) * 4 + 0 ] >> 16 ) & 0x03 ;
							code |= (( Code[ ( line * 32 + i ) * 4 + 1 ] >> 16 ) & 0x03 ) << 2 ;
							code |= (( Code[ ( line * 32 + i ) * 4 + 2 ] >> 16 ) & 0x03 ) << 4 ;
							code |= (( Code[ ( line * 32 + i ) * 4 + 3 ] >> 16 ) & 0x03 ) << 6 ;
							fprintf( outfile, "%02X", code ) ;
						}
					state = stCOPY ;

				// bit based INITs
				} else if ( strncmp( "INIT64_", buffer, 6 ) == 0 ) {
					sscanf( buffer, "INIT64_%d", &bit ) ;
					if ( bit < 18 ) {
						for ( i = 15 ; i >= 0 ; i -= 1 ) {
							code  = ( ( ( Code[ i * 4 + 0 ] >> bit ) & 1 ) << 0 ) ;
							code |=	( ( ( Code[ i * 4 + 1 ] >> bit ) & 1 ) << 1 ) ;
							code |=	( ( ( Code[ i * 4 + 2 ] >> bit ) & 1 ) << 2 ) ;
							code |=	( ( ( Code[ i * 4 + 2 ] >> bit ) & 1 ) << 3 ) ;
							fprintf( outfile, "%1X", code ) ;
						}
					}
					state = stCOPY ;
				} else if ( strncmp( "INIT128_", buffer, 6 ) == 0 ) {
					sscanf( buffer, "INIT128_%d", &bit ) ;
					if ( bit < 18 ) {
						for ( i = 31 ; i >= 0 ; i -= 1 ) {
							code  = ( ( ( Code[ i * 4 + 0 ] >> bit ) & 1 ) << 0 ) ;
							code |=	( ( ( Code[ i * 4 + 1 ] >> bit ) & 1 ) << 1 ) ;
							code |=	( ( ( Code[ i * 4 + 2 ] >> bit ) & 1 ) << 2 ) ;
							code |=	( ( ( Code[ i * 4 + 2 ] >> bit ) & 1 ) << 3 ) ;
							fprintf( outfile, "%1X", code ) ;
						}
					}
					state = stCOPY ;
				} else if ( strncmp( "INIT256_", buffer, 8 ) == 0 ) {
					sscanf( buffer, "INIT256_%d", &bit ) ;
					if ( bit < 18 ) {
						for ( i = 63 ; i >= 0 ; i -= 1 ) {
							code  = ( ( ( Code[ i * 4 + 0 ] >> bit ) & 1 ) << 0 ) ;
							code |=	( ( ( Code[ i * 4 + 1 ] >> bit ) & 1 ) << 1 ) ;
							code |=	( ( ( Code[ i * 4 + 2 ] >> bit ) & 1 ) << 2 ) ;
							code |=	( ( ( Code[ i * 4 + 2 ] >> bit ) & 1 ) << 3 ) ;
							fprintf( outfile, "%1X", code ) ;
						}
					}
					state = stCOPY ;

				} else if ( strcmp( "psmname", buffer ) == 0 ) {
					fprintf( outfile, "%s", strEntity ) ;
					state = stCOPY ;
				} else if ( strcmp( "name", buffer ) == 0 ) {
					fprintf( outfile, "%s", strEntity ) ;
					state = stCOPY ;
				} else if ( strcmp( "tool", buffer ) == 0 ) {
					fprintf( outfile, "pBlazMRG" ) ;
					state = stCOPY ;
				} else if ( strcmp( "timestamp", buffer ) == 0 ) {
					char date_str[9], time_str[9] ;

					_strdate( date_str ) ;
					_strtime( time_str ) ;
					fprintf( outfile, "%s %s", date_str, time_str ) ;
					state = stCOPY ;
				} else if ( strcmp( "begin template", buffer ) == 0 ) {
					state = stCOPY ;
				} else
					state = stIDLE ;
			} else
				state = stIDLE ;
			break ;
		}
	}

	fclose( outfile ) ;
	fclose( infile ) ;

	return true ;
}

int main( int argc, char *argv[] ) {
	char code_filename[ 256 ] = { '\0' } ;
	char data_filename[ 256 ] = { '\0' } ;
	char tpl_filename[ 256 ] = { '\0' } ;
	char rom_filename[ 256 ] = { '\0' } ;
	char entity_name[ 256 ] = { '\0' } ;

	bool bOptErr = false ;
	bool bVerbose = false ;

	extern char * optarg ;
	extern int optind, optopt ;
	int optch ;

	opterr = -1 ;
	while ( ( optch = getopt( argc, argv, ":e:hs:v" ) ) != -1 ) {
		switch ( optch ) {
		case 'e' :
			if ( optarg != NULL )
				strcpy( entity_name, optarg ) ;
			else
				bOptErr = true ;
			break ;
		case 's' :
			if ( optarg != NULL )
				strcpy( data_filename, optarg ) ;
			else
				bOptErr = true ;
			break ;
		case 'h' :
			bOptErr = true ;
			break ;
		case 'v' :
			bVerbose = true ;
			break ;
		case ':' :
			fprintf( stderr, "? missing option: -%c\n", optopt ) ;
			bOptErr = true ;
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
	strcpy( code_filename, argv[ optind++ ] ) ;
	if ( strrchr( code_filename, '.' ) == NULL )
		strcat( code_filename, ".mem" ) ;
	if ( bVerbose )
		printf( "! code MEM file: %s\n", code_filename ) ;

	if ( strlen( entity_name ) == 0 ) {
		strcpy( entity_name, filename( code_filename ) ) ;
	}
	if ( bVerbose )
		printf( "! entity name: %s\n", entity_name ) ;

	if ( strlen( data_filename ) > 0 ) {
		if ( strrchr( data_filename, '.' ) == NULL )
			strcat( data_filename, ".mem" ) ;
		if ( bVerbose )
			printf( "! dataMEM file: %s\n", data_filename ) ;
	}

	// template filename
	if ( argv[ optind ] == NULL ) {
		strcpy( tpl_filename, "template.vhd" ) ;
	} else {
		strcpy( tpl_filename, argv[ optind++ ] ) ;
	}
	if ( strrchr( tpl_filename, '.' ) == NULL )
		strcat( tpl_filename, ".vhd" ) ;
	if ( bVerbose )
		printf( "! template file: %s\n", tpl_filename ) ;

	// output filename
	if ( argv[ optind ] == NULL ) {
		strcpy( rom_filename, filename( code_filename ) ) ;
	} else {
		strcpy( rom_filename, argv[ optind++ ] ) ;
	}
	if ( strrchr( rom_filename, '.' ) == NULL )
		strcat( rom_filename, ".vhd" ) ;
	if ( bVerbose )
		printf( "! output file: %s\n", rom_filename ) ;

	if ( loadMEM( code_filename, data_filename ) ) {
		mergeTPL( tpl_filename, rom_filename, entity_name ) ;
		exit( 0 ) ;
	} else
		exit( -2 ) ;
}
