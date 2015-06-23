// $Id: RosPrintfS.cpp 531 2013-08-16 19:34:32Z mueller $
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
// 2011-02-25   364   1.0.1  allow NULL ptr for const char*, output <NULL>
// 2011-01-30   357   1.0    Adopted from CTBprintfS
// 2000-10-29     -   -      Last change on CTBprintfS
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosPrintfS.cpp 531 2013-08-16 19:34:32Z mueller $
  \brief   Implemenation of RosPrintfS .
*/

#include <iomanip>

#include "RiosState.hpp"
#include "RosPrintfS.hpp"

using namespace std;

/*!
  \class RosPrintfS
  \brief Print object for scalar values . **
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*!
  \brief Constructor.

  \param value  value to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

template <class T>
RosPrintfS<T>::RosPrintfS(T value, const char* form, int width, int prec)
  : RosPrintfBase(form, width, prec),
    fValue(value)
{}

//------------------------------------------+-----------------------------------
template <class T>
void RosPrintfS<T>::ToStream(std::ostream& os) const
{
  RiosState iostate(os, fForm, fPrec);
  os << setw(fWidth) << fValue;
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<char>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 0 || ctype == 'c') {
    os << fValue;
  } else {
    os << (int) fValue;
  }
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<int>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 'c') {
    os << (char) fValue;
  } else {
    os << fValue;
  }
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<const char *>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 'p') {
    os << (const void*) fValue;
  } else {
    os << (fValue?fValue:"<NULL>");
  }
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<const void *>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 0 || ctype == 'p') {
    os << fValue;
  } else {
    os << (unsigned long) fValue;
  }
}

//!! Note:
//!!  1.  This specialization is printing signed and unsigned char types and
//!!	  implements the `c' conversion format,

// finally do an explicit instantiation of the required RosPrintfS

template class RosPrintfS<char>;
template class RosPrintfS<int>;
template class RosPrintfS<unsigned int>;
template class RosPrintfS<long>;
template class RosPrintfS<unsigned long>;
template class RosPrintfS<double>;

template class RosPrintfS<const char *>;
template class RosPrintfS<const void *>;

} // end namespace Retro
