// $Id: Rw11UnitRHRP.ipp 680 2015-05-14 13:29:46Z mueller $
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
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitRHRP.ipp 680 2015-05-14 13:29:46Z mueller $
  \brief   Implemenation (inline) of Rw11UnitRHRP.
*/

#include "Rw11UnitRHRP.hpp"

/*!
  \class Retro::Rw11UnitRHRP
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRHRP::Rpdt() const
{
  return fRpdt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitRHRP::IsRmType() const
{
  return fRpdt & kDTE_M_RM;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRHRP::SetRpds(uint16_t rpds)
{
  fRpds = rpds;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRHRP::Rpds() const
{
  return fRpds;
}

} // end namespace Retro
