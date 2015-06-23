// $Id: Rstats.ipp 488 2013-02-16 18:49:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rstats.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of Rstats.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rstats::Set(size_t ind, double val)
{
  fValue.at(ind) = val;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rstats::Inc(size_t ind, double val)
{
  fValue.at(ind) += val;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rstats::Size() const
{
  return fValue.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline double Rstats::Value(size_t ind) const
{
  return fValue.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rstats::Name(size_t ind) const
{
  return fName.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rstats::Text(size_t ind) const
{
  return fText.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline double Rstats::operator[](size_t ind) const
{
  return fValue.at(ind);
}

//------------------------------------------+-----------------------------------
/*! 
  \relates Rstats
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const Rstats& obj)
{
  obj.Print(os);
  return os;
}

} // end namespace Retro
