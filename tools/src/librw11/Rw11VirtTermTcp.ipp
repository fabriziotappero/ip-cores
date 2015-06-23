// $Id: Rw11VirtTermTcp.ipp 508 2013-04-20 18:43:28Z mueller $
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
// 2013-04-20   508   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTermTcp.ipp 508 2013-04-20 18:43:28Z mueller $
  \brief   Implemenation (inline) of Rw11VirtTermTcp.
*/

#include "Rw11VirtTermTcp.hpp"

/*!
  \class Retro::Rw11VirtTermTcp
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTermTcp::Connected() const
{
  return fFd > 2;
}

} // end namespace Retro
