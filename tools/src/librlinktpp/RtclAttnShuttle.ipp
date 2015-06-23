// $Id: RtclAttnShuttle.ipp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-03-01   493   1.0    Initial version
// 2013-01-14   475   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclAttnShuttle.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of class RtclAttnShuttle.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RtclAttnShuttle::Mask() const
{
  return fMask;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Obj* RtclAttnShuttle::Script() const
{
  return fpScript;
}

} // end namespace Retro

