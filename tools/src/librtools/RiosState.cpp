// $Id: RiosState.cpp 488 2013-02-16 18:49:47Z mueller $
//
// Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-01-30   357   1.0    Adopted from CTBioState
// 2006-04-16     -   -      Last change on CTBioState
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RiosState.cpp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation of RiosState.
*/

#include "RiosState.hpp"

using namespace std;

/*!
  \class Retro::RiosState
  \brief Stack object for ostream state. **
*/

//------------------------------------------+-----------------------------------
// all method definitions in namespace Retro
namespace Retro {

//! Construct with stream.

RiosState::RiosState(ios& stream)
  : fStream(stream)
{
  fOldFlags     = fStream.flags();
  fOldPrecision = -1;
  fOldFill      =  0;
  fCtype        =  0;
}

//------------------------------------------+-----------------------------------
//! Construct from stream and format.

RiosState::RiosState(ios& stream, const char* form, int prec)
  : fStream(stream)
{
  fOldFlags     = fStream.flags();
  fOldPrecision = -1;
  fOldFill      =  0;
  SetFormat(form, prec);
}

//------------------------------------------+-----------------------------------
//! Destructor.

RiosState::~RiosState()
{
  fStream.flags(fOldFlags);
  if (fOldPrecision >= 0) fStream.precision(fOldPrecision);
  if (fOldFill      != 0) fStream.fill(fOldFill);
}

//------------------------------------------+-----------------------------------
//! Setup format.

void RiosState::SetFormat(const char* form, int prec)
{
  bool	  b_plus      = false;
  bool	  b_minus     = false;
  bool	  b_point     = false;
  bool	  b_dollar    = false;
  bool	  b_internal  = false;
  char	  c_ctype     = 0;
  char	  c_fill      = 0;
  char	  c;

  if (form == 0) form = "";	    // allow null as format

  for (c = *form++; ; c = *form++) {
    if (c == '+') { b_plus   = true; continue;}
    if (c == '-') { b_minus  = true; continue;}
    if (c == '.') { b_point  = true; continue;}
    if (c == '$') { b_dollar = true; continue;}
    break;
  }

  if (c != 0 && isalpha(c)) { c_ctype = c; c = *form++; }
  if (c != 0) c_fill = c;

  if (prec >= 0) {
    int i_old_precision = fStream.precision(prec);
    if (fOldPrecision < 0) fOldPrecision = i_old_precision;
  }
  if (c_fill != 0) {
    char c_old_fill = fStream.fill(c_fill);
    if (fOldFill == 0) fOldFill = c_old_fill;
  }

  fCtype = c_ctype;

  switch(c_ctype) {
    case 'd':
	b_internal = !b_minus & (c_fill == '0');
	fStream.setf(ios::dec,ios::basefield);
	break;
    case 'o':
	b_internal = !b_minus & (c_fill == '0');
	fStream.setf(ios::oct,ios::basefield);
	break;
    case 'x':
    case 'X':
	b_internal = !b_minus & (c_fill == '0');
	fStream.setf(ios::hex,ios::basefield);
	if (isupper(c_ctype)) fStream.setf(ios::uppercase);
	break;
    case 'g':
    case 'G':
	b_internal = !b_minus & (c_fill == '0');
	fStream.setf(ios_base::fmtflags(0),ios::floatfield);
	if (isupper(c_ctype)) fStream.setf(ios::uppercase);
	break;
    case 'f':
	b_internal = !b_minus & (c_fill == '0');
	fStream.setf(ios::fixed,ios::floatfield);
	break;
    case 'e':
    case 'E':
	b_internal = !b_minus & (c_fill == '0');
	fStream.setf(ios::scientific,ios::floatfield);
	if (isupper(c_ctype)) fStream.setf(ios::uppercase);
	break;
    case 's':
    case 'p':
    case 'c':
	break;
  }

  {
    ios_base::fmtflags l_flags = ios_base::fmtflags(0);
    if (b_plus)   l_flags |= ios::showpos;
    if (b_point)  l_flags |= ios::showpoint;
    if (b_dollar) l_flags |= ios::showbase;
    fStream.setf(l_flags);
    fStream.setf(b_internal ? ios::internal : 
                   (b_minus ? ios::left : ios::right), ios::adjustfield);
  }
}

} // end namespace Retro
