// $Id: Rw11UnitDiskBase.ipp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-04-14   506   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitDiskBase.ipp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation (inline) of Rw11UnitDiskBase.
*/

#include "Rw11UnitDiskBase.hpp"

/*!
  \class Retro::Rw11UnitDiskBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitDiskBase<TC>::Rw11UnitDiskBase(TC* pcntl, size_t index)
  : Rw11UnitDisk(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitDiskBase<TC>::~Rw11UnitDiskBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitDiskBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitDiskBase<TC>::Dump(std::ostream& os, int ind, 
                                const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDiskBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitDisk::Dump(os, ind, " ^");
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitDiskBase<TC>::AttachDone()
{
  Virt()->Setup(BlockSize(), NBlock());
  Cntl().UnitSetup(Index());
  return;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitDiskBase<TC>::DetachDone()
{
  SetWProt(false);
  Cntl().UnitSetup(Index());
  return;
}

} // end namespace Retro
