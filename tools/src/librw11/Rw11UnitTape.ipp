// $Id: Rw11UnitTape.ipp 686 2015-06-04 21:08:08Z mueller $
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
  \version $Id: Rw11UnitTape.ipp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation (inline) of Rw11UnitTape.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11UnitTape::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTape::Enabled() const
{
  return fEnabled;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTape::WProt() const
{
  return Virt() ? Virt()->WProt() : fWProt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitTape::Capacity() const
{
  return Virt() ? Virt()->Capacity() : fCapacity;
}


} // end namespace Retro
