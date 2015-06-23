/******************************************************************************
 * Standard Definitions                                                       *
 ******************************************************************************
 * Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
#ifndef _STDDEF_H
#define _STDDEF_H

#ifndef NULL
#define NULL ( (void *) 0 )
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#define isdigit(c) ( (c >= '0') && (c <= '9') )
#define islower(c) ( (c >= 'a') && (c <= 'z') )
#define isupper(c) ( (c >= 'A') && (c <= 'Z') )
#define isalpha(c) ( islower(c) || isupper(c) )
#define isalnum(c) ( isalpha(c) || isdigit(c) )

#define tolower(c) ( isupper(c) ? (c + 0x20) : c )
#define toupper(c) ( islower(c) ? (c - 0x20) : c )

typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned long uint;

#endif
