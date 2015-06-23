// $Id: Rw11UnitTerm.ipp 508 2013-04-20 18:43:28Z mueller $
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
// 2013-04-20   508   1.0.1  add 7bit and non-printable masking; add log file
// 2013-04-13   504   1.0    Initial version
// 2013-03-02   493   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTerm.ipp 508 2013-04-20 18:43:28Z mueller $
  \brief   Implemenation (inline) of Rw11UnitTerm.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetTo7bit(bool to7bit)
{
  fTo7bit = to7bit;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetToEnpc(bool toenpc)
{
  fToEnpc = toenpc;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetTi7bit(bool ti7bit)
{
  fTi7bit = ti7bit;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::To7bit() const
{
  return fTo7bit;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::ToEnpc() const
{
  return fToEnpc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::Ti7bit() const
{
  return fTi7bit;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11UnitTerm::Log() const
{
  return fLogFname;
}

} // end namespace Retro
