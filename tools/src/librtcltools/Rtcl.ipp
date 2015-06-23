// $Id: Rtcl.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-02-26   364   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtcl.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of Rtcl.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Obj* Rtcl::NewLinesObj(std::ostringstream& sos)
{
  return NewLinesObj(sos.str());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtcl::SetResult(Tcl_Interp* interp, std::ostringstream& sos)
{
  SetResult(interp, sos.str());
  return;
}


} // end namespace Retro
