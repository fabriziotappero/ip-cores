/*
 *  Copyright © 2003..2010 : Henk van Kampen <henk@mediatronix.com>
 *
 *	This file is part of pBlazASM.
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
 *  along with pBlazASM.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdlib.h>
#include <string.h>

//!
// operating system dependent filename processing functions
//
char * basename( const char * path ) {
	char * ptr = strrchr( path, '\\' ) ;
	return ptr ? ptr + 1 : (char *) path ;
}

char * filename( const char * path ) {
	char * ptr = strrchr( path, '\\' ) ;
	char * b = strdup( ptr ? ptr + 1 : (char *) path ) ;
	char * p = strrchr( b, '.' ) ;
	if ( p != NULL )
		*p = '\0' ;
	return b ;
}

char * dirname( const char * path ) {
	char * newpath ;
	const char * slash ;
	int length ;

	slash = strrchr( path, '\\' ) ;
	if ( slash == 0 ) {
		path = "." ;
		length = 1 ;
	} else {
		while ( slash > path && *slash == '\\' )
			slash -= 1 ;
		length = slash - path + 1 ;
	}
	newpath = (char *) malloc( length + 1 ) ;
	if ( newpath == 0 )
		return 0 ;
	strncpy( newpath, path, length ) ;
	newpath[ length ] = 0 ;
	return newpath ;
}
