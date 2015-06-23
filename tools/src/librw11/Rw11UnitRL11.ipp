// $Id: Rw11UnitRL11.ipp 653 2015-03-01 12:53:01Z mueller $
//
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitRL11.ipp 653 2015-03-01 12:53:01Z mueller $
  \brief   Implemenation (inline) of Rw11UnitRL11.
*/

#include "Rw11UnitRL11.hpp"

/*!
  \class Retro::Rw11UnitRL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRL11::SetRlsta(uint16_t rlsta)
{
  fRlsta = rlsta;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRL11::SetRlpos(uint16_t rlpos)
{
  fRlpos = rlpos;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRL11::Rlsta() const
{
  return fRlsta;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRL11::Rlpos() const
{
  return fRlpos;
}

} // end namespace Retro
