// $Id: RerrMsg.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-02-06   359   1.1    use references in interface
// 2011-01-15   356   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RerrMsg.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of RerrMsg.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RerrMsg::SetMeth(const std::string& meth)
{
  fMeth = meth;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RerrMsg::SetText(const std::string& text)
{
  fText = text;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RerrMsg::Meth() const
{
  return fMeth;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RerrMsg::Text() const
{
  return fText;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RerrMsg::operator std::string() const
{
  return Message();
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RerrMsg
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const RerrMsg& obj)
{
  os << obj.Message();
  return os;
}

} // end namespace Retro
