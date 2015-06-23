// $Id: Rw11UnitLP11.cpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitLP11.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of Rw11UnitLP11.
*/

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "Rw11CntlLP11.hpp"

#include "Rw11UnitLP11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitLP11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitLP11::Rw11UnitLP11(Rw11CntlLP11* pcntl, size_t index)
  : Rw11UnitStreamBase<Rw11CntlLP11>(pcntl, index)
{
  SetAttachOpts("?wonly");                  // use write only (output) streams
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitLP11::~Rw11UnitLP11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitLP11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitLP11 @ " << this << endl;
  Rw11UnitStreamBase<Rw11CntlLP11>::Dump(os, ind, " ^");
  return;
}
  
} // end namespace Retro
