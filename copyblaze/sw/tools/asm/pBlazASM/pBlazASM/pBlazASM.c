/*
 *  Copyright © 2003..2008 : Henk van Kampen <henk@mediatronix.com>
 *
 *	This file is part of pBlazASM.
 *
 *  pBlazASM is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  pBlazASM is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with pBlazASM.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * pBlaze assembler
 * @file pBlazASM.c
 * @author Henk van Kampen
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <unistd.h>

#include "pbTypes.h"
#include "pbParser.h"
#include "pbLibgen.h"

#ifdef TCC
#include "getopt.h"
#endif

/**
 * usage prints usage text
 * @param text application name
 */
static void usage( char * text ) {
	printf( "\n%s - %s\n", text, "Picoblaze Assembler V1.2" ) ;
	printf( "\nUSAGE:\n" ) ;
	printf( "   pBlazASM [-m[<MEMfile>]] [-l[<LSTfile>]] [-k] [-v] [-f] <input file> <input file> <input file> ...\n"
		"   where:\n"
		"         -m/-M   creates a MEM file (not in combo with -x)\n"
		"         -x/-X   creates a HEX file (not in combo with -m)\n"
		"         -l      creates a LST file\n"
		"         -k      to select KCPSM mode with limited expression handling\n"
		"         -v      generates verbose reporting\n"
		"         -f      with -l creates a list file without code, to replace the source\n" ) ;
	printf( "\nNote: All (max 255) input files are assembled to one output.\n" ) ;
}

/**
 * main entry
 * processes command line and
 * calls actual assembler()
 */
int main( int argc, char **argv ) {
	char * src_filenames[ 256 ] =
		{ NULL } ;
	char mem_filename[ 256 ] =
		{ 0 } ;
	char list_filename[ 256 ] =
		{ 0 } ;
	char * pfile, *ppath ;
	int result = 0 ;
	int nInputfile = 0 ;

	// KCPSM mode, accepts 'NAMEREG' etc
	bool bKCPSM_mode = false ;
	bool bList_mode = true ;
	bool bOptErr = false ;
	bool bWantMEM = false ;
	bool bWantHEX = false ;
	bool bWantLST = false ;
	bool bVerbose = false ;
	bool bWantZEROs = false ;

	extern char * optarg ;
	extern int optind, optopt ;
	int optch ;

	while ( ( optch = getopt( argc, argv, "fhkl::m::M::vx::X::" ) ) != -1 ) {
		switch ( optch ) {
		case 'f' :
			bList_mode = false ;
			break ;
		case 'h' :
			bOptErr = true ;
			break ;
		case 'm' :
			if ( bWantHEX ) {
				fprintf( stderr, "? conflicting option -%c\n", optch ) ;
				bOptErr = true ;
			} else {
				bWantMEM = true ;
				if ( optarg != NULL )
					strcpy( mem_filename, optarg ) ;
		    }
			break ;
		case 'x' :
			if ( bWantMEM ) {
				fprintf( stderr, "? conflicting option -%c\n", optch ) ;
				bOptErr = true ;
			} else {
				bWantHEX = true ;
				if ( optarg != NULL )
					strcpy( mem_filename, optarg ) ;
			}
			break ;
		case 'M' :
			if ( bWantHEX ) {
				fprintf( stderr, "? conflicting option -%c\n", optch ) ;
				bOptErr = true ;
			} else {
				bWantMEM = true ;
				bWantZEROs = true ;
				if ( optarg != NULL )
					strcpy( mem_filename, optarg ) ;
		    }
			break ;
		case 'X' :
			if ( bWantMEM ) {
				fprintf( stderr, "? conflicting option -%c\n", optch ) ;
				bOptErr = true ;
			} else {
				bWantHEX = true ;
				bWantZEROs = true ;
				if ( optarg != NULL )
					strcpy( mem_filename, optarg ) ;
			}
			break ;
		case 'l' :
			bWantLST = true ;
			if ( optarg != NULL )
				strcpy( list_filename, optarg ) ;
			break ;
		case 'k' :
			bKCPSM_mode = true ;
			break ;
		case 'v' :
			bVerbose = true ;
			break ;
		case ':' :
			fprintf( stderr, "? missing option -%c\n", optopt ) ;
			bOptErr = true ;
			break ;
		default :
			fprintf( stderr, "? unknown option -%c\n", optopt ) ;
			bOptErr = true ;
			break ;
		}
	}

	if ( bOptErr ) {
		usage( basename( argv[ 0 ] ) ) ;
		result = -1 ;
		goto finally ;
	}

	if ( bVerbose && bKCPSM_mode )
		fprintf( stdout, "! KCPSM3 compatible mode selected\n" ) ;

	if ( argv[ optind ] == NULL ) {
		fprintf( stderr, "? source file(s) missing\n" ) ;
		usage( basename( argv[ 0 ] ) ) ;
		result = -1 ;
		goto finally ;
	}

	for ( nInputfile = 0 ; argv[ optind ] != NULL && nInputfile < 256 ; nInputfile += 1, optind += 1 ) {
		src_filenames[ nInputfile ] = calloc( strlen( argv[ optind ] ) + 16, sizeof(char) ) ;
		strcpy( src_filenames[ nInputfile ], argv[ optind ] ) ;

		if ( strrchr( src_filenames[ nInputfile ], '.' ) == NULL )
			strcat( src_filenames[ nInputfile ], ".psm" ) ;
		if ( bVerbose )
			fprintf( stdout, "! Sourcefile: %s\n", src_filenames[ nInputfile ] ) ;
	}

	if ( bWantMEM || bWantHEX ) {
		if ( strlen( mem_filename ) == 0 ) {
			pfile = filename( src_filenames[ nInputfile - 1 ] ) ;
			ppath = dirname( src_filenames[ nInputfile - 1 ] ) ;
			strcpy( mem_filename, ppath ) ;
			strcat( mem_filename, "/" ) ;
			strcat( mem_filename, pfile ) ;
			strcat( mem_filename, bWantHEX ? ".hex" : ".mem" ) ;
			free( ppath ) ;
			free( pfile ) ;
		}
		if ( strrchr( mem_filename, '.' ) == NULL )
			strcat( mem_filename, bWantHEX ? ".hex" : ".mem" ) ;
		if ( bVerbose )
			fprintf( stdout, "! MEM file: %s\n", mem_filename ) ;
	}

	if ( bWantLST ) {
		if ( strlen( list_filename ) == 0 ) {
			pfile = filename( src_filenames[ nInputfile - 1 ] ) ;
			ppath = dirname( src_filenames[ nInputfile - 1 ] ) ;
			strcpy( list_filename, ppath ) ;
			strcat( list_filename, "/" ) ;
			strcat( list_filename, pfile ) ;
			strcat( list_filename, ".lst" ) ;
			free( ppath ) ;
			free( pfile ) ;
		}
		if ( strrchr( list_filename, '.' ) == NULL )
			strcat( list_filename, ".lst" ) ;
		if ( bVerbose )
			fprintf( stdout, "! LST file: %s\n", list_filename ) ;
	}

	if ( assembler( src_filenames, mem_filename, list_filename, bKCPSM_mode, bList_mode, bWantHEX, bWantZEROs ) )
		result = 0 ;
	else
		result = -1 ;

	finally: {
		int i ;

		for ( i = 0 ; i < nInputfile ; i += 1 ) {
			free( src_filenames[ i ] ) ;
		}
	}
	exit( result ) ;
}
