// $Id: RosPrintf.ipp 488 2013-02-16 18:49:47Z mueller $
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
  \version $Id: RosPrintf.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of RosPrintf.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*!
  \defgroup RosPrintf RosPrintf -- print format object creators
*/
//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c char value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<char> 
  RosPrintf(char value, const char* form, int width, int prec)
{
  return RosPrintfS<char>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a signed char value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<int> 
  RosPrintf(signed char value, const char* form, int width, int prec)
{
  return RosPrintfS<int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a unsigned char value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<unsigned int> 
  RosPrintf(unsigned char value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c short value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<int> 
  RosPrintf(short value, const char* form, int width, int prec)
{
  return RosPrintfS<int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a unsigned short value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<unsigned int> 
  RosPrintf(unsigned short value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c int value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<int> 
  RosPrintf(int value, const char* form, int width, int prec)
{
  return RosPrintfS<int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a unsigned int value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<unsigned int> 
  RosPrintf(unsigned int value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c long value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<long> 
  RosPrintf(long value, const char* form, int width, int prec)
{
  return RosPrintfS<long>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of an unsigned long value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<unsigned long> 
  RosPrintf(unsigned long value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned long>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c double value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<double> 
  RosPrintf(double value, const char* form, int width, int prec)
{
  return RosPrintfS<double>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a const char* value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<const char*> 
  RosPrintf(const char* value, const char* form, int width, int prec)
{
  return RosPrintfS<const char*>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c const void* value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<const void*> 
  RosPrintf(const void* value, const char* form, int width, int prec)
{
  return RosPrintfS<const void*>(value, form, width, prec);
}

} // end namespace Retro
