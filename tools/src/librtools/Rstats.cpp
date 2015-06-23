// $Id: Rstats.cpp 492 2013-02-24 22:14:47Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-03   481   1.0.2  use Rexception
// 2011-03-06   367   1.0.1  use max from algorithm
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rstats.cpp 492 2013-02-24 22:14:47Z mueller $
  \brief   Implemenation of Rstats .
*/

#include <algorithm>

#include "Rstats.hpp"

#include "RosFill.hpp"
#include "RosPrintf.hpp"
#include "Rexception.hpp"

using namespace std;

/*!
  \class Retro::Rstats
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rstats::Rstats()
  : fValue(),
    fName(),
    fText(),
    fHash(0),
    fFormat("f"),
    fWidth(12),
    fPrec(0)
{}

//------------------------------------------+-----------------------------------
//! Copy constructor

Rstats::Rstats(const Rstats& rhs)
  : fValue(rhs.fValue),
    fName(rhs.fName),
    fText(rhs.fText),
    fHash(rhs.fHash),
    fFormat(rhs.fFormat),
    fWidth(rhs.fWidth),
    fPrec(rhs.fPrec)
{}

//------------------------------------------+-----------------------------------
//! Destructor
Rstats::~Rstats()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Define(size_t ind, const std::string& name, 
                    const std::string& text)
{
  // update hash
  for (size_t i=0; i<name.length(); i++) 
    fHash = 69069*fHash + (uint32_t) name[i];
  for (size_t i=0; i<text.length(); i++) 
    fHash = 69069*fHash + (uint32_t) text[i];

  // in case it's the 'next' counter use push_back
  if (ind == Size()) {
    fValue.push_back(0.);
    fName.push_back(name);
    fText.push_back(text);

  // otherwise resize and set
  } else {
    if (ind >= Size()) {
      fValue.resize(ind+1);
      fName.resize(ind+1);
      fText.resize(ind+1);
    }
    fValue[ind] = 0.;
    fName[ind]  = name;
    fText[ind]  = text;
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::SetFormat(const char* format, int width, int prec)
{
  fFormat = format;
  fWidth  = width;
  fPrec   = prec;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Print(std::ostream& os, const char* format,
                   int width, int prec) const
{
  if (format == 0 || format[0]==0) {
    format = fFormat.c_str();
    width  = fWidth;
    prec   = fPrec;
  }
  
  for (size_t i=0; i<Size(); i++) {
    os << RosPrintf(fValue[i], format, width, prec)
       << " : " << fText[i] << endl;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rstats @ " << this << endl;

  size_t maxlen=8;
  for (size_t i=0; i<Size(); i++) maxlen = max(maxlen, fName[i].length());
  
  for (size_t i=0; i<Size(); i++) {
    os << bl << "  " << fName[i] << ":" << RosFill(maxlen-fName[i].length()+1)
       << RosPrintf(fValue[i], "f", 12)
       << "  '" << fText[i] << "'" << endl;
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rstats& Rstats::operator=(const Rstats& rhs)
{
  if (&rhs == this) return *this;

  // in case this is freshly constructed, copy full context
  if (Size() == 0) {
    fValue  = rhs.fValue;
    fName   = rhs.fName;
    fText   = rhs.fText;
    fHash   = rhs.fHash;
    fFormat = rhs.fFormat;
    fWidth  = rhs.fWidth;
    fPrec   = rhs.fPrec;

  // otherwise check hash and copy only values
  } else {
    if (Size() != rhs.Size() || fHash != rhs.fHash) {
      throw Rexception("Rstats::oper=()",
                       "Bad args: assign incompatible stats");
    }
    fValue = rhs.fValue;
  }

  return *this;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rstats& Rstats::operator-(const Rstats& rhs)
{
  if (Size() != rhs.Size() || fHash != rhs.fHash) {
    throw Rexception("Rstats::oper-()",
                     "Bad args: subtract incompatible stats");
  }

  for (size_t i=0; i<fValue.size(); i++) {
    fValue[i] -= rhs.fValue[i];
  }
  return *this;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rstats& Rstats::operator*(double rhs)
{
  for (size_t i=0; i<fValue.size(); i++) {
    fValue[i] *= rhs;
  }
  return *this;
}

} // end namespace Retro
