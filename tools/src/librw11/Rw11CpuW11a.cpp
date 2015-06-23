// $Id: Rw11CpuW11a.cpp 621 2014-12-26 21:20:05Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-03-03   494   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CpuW11a.cpp 621 2014-12-26 21:20:05Z mueller $
  \brief   Implemenation of Rw11CpuW11a.
*/

#include "librtools/RosFill.hpp"

#include "Rw11CpuW11a.hpp"

using namespace std;

/*!
  \class Retro::Rw11CpuW11a
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CpuW11a::Rw11CpuW11a()
  : Rw11Cpu("w11a")
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CpuW11a::~Rw11CpuW11a()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CpuW11a::Setup(size_t ind, uint16_t base, uint16_t ibase)
{
  fIndex = ind;
  fBase  = base;
  fIBase = ibase;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CpuW11a::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CpuW11a @ " << this << endl;
  Rw11Cpu::Dump(os, ind, " ^");
  return;
}
  
} // end namespace Retro
