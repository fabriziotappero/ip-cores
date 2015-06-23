// $Id: Rw11UnitTermBase.ipp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-03-03   494   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTermBase.ipp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation (inline) of Rw11UnitTermBase.
*/

#include "Rw11UnitTermBase.hpp"

/*!
  \class Retro::Rw11UnitTermBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitTermBase<TC>::Rw11UnitTermBase(TC* pcntl, size_t index)
  : Rw11UnitTerm(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitTermBase<TC>::~Rw11UnitTermBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitTermBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline void Rw11UnitTermBase<TC>::WakeupCntl()
{
  fpCntl->Wakeup();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitTermBase<TC>::Dump(std::ostream& os, int ind, 
                                const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTermBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitTerm::Dump(os, ind, " ^");
  return;
} 

} // end namespace Retro
