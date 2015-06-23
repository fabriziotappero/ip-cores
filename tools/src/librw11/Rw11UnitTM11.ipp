// $Id: Rw11UnitTM11.ipp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTM11.ipp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation (inline) of Rw11UnitTM11.
*/

#include "Rw11UnitTM11.hpp"

/*!
  \class Retro::Rw11UnitTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTM11::SetTmds(uint16_t tmds)
{
  fTmds = tmds;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitTM11::Tmds() const
{
  return fTmds;
}

} // end namespace Retro
