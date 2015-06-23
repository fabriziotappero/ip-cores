// $Id: RtclRw11Unit.ipp 504 2013-04-13 15:37:24Z mueller $
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
  \version $Id: RtclRw11Unit.ipp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation (inline) of RtclRw11Unit.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclGetList& RtclRw11Unit::GetList()
{
  return fGets;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclSetList& RtclRw11Unit::SetList()
{
  return fSets;
}

} // end namespace Retro
