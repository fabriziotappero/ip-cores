/*
 *  Copyright © 2003..2010 : Henk van Kampen <henk@mediatronix.com>
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

/*! \file
 * Implements a closed hash table, with linear probing, with an increment of 1
 */

#include <malloc.h>
#include <stdio.h>
#include <ctype.h>
#include <stdint.h>
#include <string.h>

#include "pbTypes.h"
#include "pbSymbols.h"
#include "pbOpcodes.h"
#include "pbDirectives.h"

// our symbol table
#define SIZE 4096UL
static symbol_t symbols[ SIZE ] ;

//! \fn static uint32_t hash( const char * text )
//  \brief hash function, free after Donald Knuth
//  \param text string to hash
static uint32_t hash( const char * text ) {
	uint64_t r = 0 ;
	int i ;

	if ( text != NULL ) {
		for ( i = 0 ; i < strlen( text ) ; i += 1 )
			r ^= 0x9E3779B1 * text[ i ] ;
		return r & ( SIZE - 1 ) ;
	} else
		return 0xFFFFFFFF ;
}

// add all known words, our keywords

static void add_keyword( const symbol_t * sym ) {
	add_symbol( sym->type, sym->subtype, sym->text, sym->value ) ;
}

void init_symbol( void ) {
	int h ;

	// clear table
	for ( h = 0 ; h < SIZE ; h += 1 ) {
		symbols[ h ].type = tNONE ;
		symbols[ h ].text = NULL ;
		symbols[ h ].value = 0 ;
	}
	// add keywords
	for ( h = 0 ; h < sizeof( opcodes ) / sizeof(symbol_t) ; h += 1 )
		add_keyword( &opcodes[ h ] ) ;
	for ( h = 0 ; h < sizeof( conditions ) / sizeof(symbol_t) ; h += 1 )
		add_keyword( &conditions[ h ] ) ;
	for ( h = 0 ; h < sizeof( indexes ) / sizeof(symbol_t) ; h += 1 )
		add_keyword( &indexes[ h ] ) ;
	for ( h = 0 ; h < sizeof( directives ) / sizeof(symbol_t) ; h += 1 )
		add_keyword( &directives[ h ] ) ;
	for ( h = 0 ; h < sizeof( registers ) / sizeof(symbol_t) ; h += 1 )
		add_keyword( &registers[ h ] ) ;
}

// find a symbol, returns the found symbol, or NULL
symbol_t * find_symbol( const char * text, bool bUpper ) {
	int h, p ;
	char buf[ 256 ], *s ;

	if (!text)
		return NULL ;

	// uppercase only?
	strcpy( buf, text ) ;
	for ( s = buf ; bUpper && *s != '\0' ; s++ )
		*s = toupper( *s ) ;

	// compute 1st entry
	p = hash( buf ) ;
	if ( p == 0xFFFFFFFF )
		return NULL ;
	// if empty spot, not found
	if ( symbols[ p ].text == NULL )
		return NULL ;
	// if text is equal, found
	if ( strcmp( symbols[ p ].text, buf ) == 0 )
		return &symbols[ p ] ;
	// else maybe next entry
	for ( h = ( p + 1 ) & ( SIZE - 1 ) ; h != p ; h = ( h + 1 ) & ( SIZE - 1 ) ) {
		if ( symbols[ h ].text == NULL )
			return NULL ;
		if ( strcmp( symbols[ h ].text, buf ) == 0 )
			return &symbols[ h ] ;
	}
	return NULL ; // unlikely
}

// add a symbol, rehashing is by linear probing
// returns false if we want to add an already known symbol
bool add_symbol( const type_e type, const subtype_e subtype, const char * text, const uint32_t value ) {
	int p = hash( text ) ;
	int h = p ;

	if ( p == 0xFFFFFFFF )
		return false ;
	do {
		if ( symbols[ h ].text == NULL ) { // if empty spot, put it here
			symbols[ h ].type = type ;
			symbols[ h ].subtype = subtype ;
			symbols[ h ].text = strdup( text ) ;
			symbols[ h ].value = value ;
			return true ;
		} else if ( strcmp( symbols[ h ].text, text ) == 0 ) { // if text is equal, already there?
			if ( symbols[ h ].type == type && symbols[ h ].subtype == subtype && symbols[ h ].value == value )
				return false ; // really same?
		}
		h = ( h + 1 ) & ( SIZE - 1 ) ; // wrap
	} while ( h != p ) ; // full ?
	return false ;
}

// debug
void dump_map( void ) {
	int h = 0 ;
	int count = 0 ;

	for ( h = 0 ; h < SIZE ; h += 1 )
		if ( symbols[ h ].type != tNONE && symbols[ h ].text != NULL )
			printf(
					"%d-%d: %s, %d, %d, %d\n", h, count += 1, symbols[ h ].text, symbols[ h ].value, symbols[ h ].type,
					symbols[ h ].subtype ) ;
}

// free any allocated storage
void free_symbol( void ) {
	int h ;

	for ( h = 0 ; h < SIZE ; h += 1 ) {
		symbols[ h ].type = tNONE ;
		if ( symbols[ h ].text != NULL )
			free( symbols[ h ].text ) ;
		symbols[ h ].text = NULL ;
		symbols[ h ].value = 0 ;
	}
}

