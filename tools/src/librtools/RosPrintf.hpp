// $Id: RosPrintf.hpp 357 2011-01-31 08:00:13Z mueller $
//
// Copyright 2000-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-01-30   357   1.0    Adopted from CTBprintf
// 2000-12-18     -   -      Last change on CTBprintf
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosPrintf.hpp 357 2011-01-31 08:00:13Z mueller $
  \brief   Declaration of RosPrintf functions.

  For a detailed description of the usage of the \c RosPrintf system
  look into \ref using_rosprintf.
*/

#ifndef included_Retro_RosPrintf
#define included_Retro_RosPrintf 1

#include "RosPrintfS.hpp"

namespace Retro {
  
  RosPrintfS<char>   RosPrintf(char value, const char* form=0, 
                               int width=0, int prec=0);

  RosPrintfS<int>    RosPrintf(signed char value, const char* form=0, 
                               int width=0, int prec=0);
  RosPrintfS<unsigned int> RosPrintf(unsigned char value, const char* form=0, 
                                     int width=0, int prec=0);

  RosPrintfS<int>    RosPrintf(short value, const char* form=0,
                               int width=0, int prec=0);
  RosPrintfS<unsigned int> RosPrintf(unsigned short value, const char* form=0,
                                     int width=0, int prec=0);

  RosPrintfS<int>    RosPrintf(int value, const char* form=0, 
                               int width=0, int prec=0);
  RosPrintfS<unsigned int> RosPrintf(unsigned int value, const char* form=0,
                                     int width=0, int prec=0);

  RosPrintfS<long>    RosPrintf(long value, const char* form=0, 
                                int width=0, int prec=0);
  RosPrintfS<unsigned long> RosPrintf(unsigned long value, const char* form=0,
                                      int width=0, int prec=0);

  RosPrintfS<double>   RosPrintf(double value, const char* form=0, 
                                 int width=0, int prec=0);

  RosPrintfS<const char*> RosPrintf(const char* value, const char* form=0, 
                                    int width=0, int prec=0);

  RosPrintfS<const void*> RosPrintf(const void* value, const char* form=0, 
                                    int width=0, int prec=0);

} // end namespace Retro

// implementation is all inline
#include "RosPrintf.ipp"

#endif
