// $Id: Rw11UnitTapeBase.ipp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTapeBase.ipp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation (inline) of Rw11UnitTapeBase.
*/

#include "Rw11UnitTapeBase.hpp"

/*!
  \class Retro::Rw11UnitTapeBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitTapeBase<TC>::Rw11UnitTapeBase(TC* pcntl, size_t index)
  : Rw11UnitTape(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitTapeBase<TC>::~Rw11UnitTapeBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitTapeBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitTapeBase<TC>::Dump(std::ostream& os, int ind, 
                                const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTapeBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitTape::Dump(os, ind, " ^");
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitTapeBase<TC>::AttachDone()
{
  // transfer, if defined, wprot and capacity from unit to virt
  if (WProt()) Virt()->SetWProt(true);
  if (Capacity()!=0 && Virt()->Capacity()==0) Virt()->SetCapacity(Capacity());
  Cntl().UnitSetup(Index());
  return;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitTapeBase<TC>::DetachDone()
{
  Cntl().UnitSetup(Index());
  return;
}

} // end namespace Retro
