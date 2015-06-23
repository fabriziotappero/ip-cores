// $Id: Rw11UnitRK11.cpp 659 2015-03-22 23:15:51Z mueller $
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
// 2013-04-20   508   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitRK11.cpp 659 2015-03-22 23:15:51Z mueller $
  \brief   Implemenation of Rw11UnitRK11.
*/

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "Rw11CntlRK11.hpp"

#include "Rw11UnitRK11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitRK11::Rw11UnitRK11(Rw11CntlRK11* pcntl, size_t index)
  : Rw11UnitDiskBase<Rw11CntlRK11>(pcntl, index),
    fRkds(0)
{
  // setup disk geometry: only rk05 supported, no rk05f !
  fType    = "rk05";
  fEnabled = true;
  fNCyl    = 203;
  fNHead   =   2;
  fNSect   =  12;
  fBlksize = 512;
  fNBlock  = fNCyl*fNHead*fNSect;
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitRK11::~Rw11UnitRK11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitRK11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitRK11 @ " << this << endl;
  os << bl << "  fRkds:           " << fRkds    << endl;

  Rw11UnitDiskBase<Rw11CntlRK11>::Dump(os, ind, " ^");
  return;
}
  
} // end namespace Retro
