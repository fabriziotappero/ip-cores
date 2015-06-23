// $Id: Rw11Virt.cpp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Virt.cpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation of Rw11Virt.
*/

#include "librtools/RosFill.hpp"

#include "Rw11Virt.hpp"

using namespace std;

/*!
  \class Retro::Rw11Virt
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11Virt::Rw11Virt(Rw11Unit* punit)
  : fpUnit(punit),
    fUrl(),
    fStats()
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11Virt::~Rw11Virt()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Virt::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Virt @ " << this << endl;

  os << bl << "  fpUnit:          " << fpUnit << endl;
  fUrl.Dump(os, ind+2, "fUrl: ");
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}


} // end namespace Retro
