/*----------------------------------------------------------------
//                                                              //
//  stdio.h                                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains defines and function prototypes for the            //
//  mini-libc library.                                          //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

/* =====  Type Definitions ============================= */
typedef unsigned int size_t;


/* =====  Printf Function Prototypes =================== */
int     printf      (const char *format, ...);
int     sprintf     (char* dst, const char *format, ...);
int     print       (char** dst, const char *format, unsigned long *varg);
int     prints      (char** dst, const char *string, int width, int pad);
int     printi      (char** dst, int i, int b, int sg, int width, int pad, int letbase);


/* =====  Memory Function Prototypes =================== */
void*   memcpy      (void *dest, const void *src, size_t count);


/* =====  String Function Prototypes =================== */
int     _outbyte    ( int );
int     _inbyte     ( int );
void    strcpy      (char*, char* );
void    strncpy     (char*, char*, int );
int     strncmp     (char*, char*, int );


/* =====  Maths Function Prototypes =================== */
int     _div        ( int, int );
