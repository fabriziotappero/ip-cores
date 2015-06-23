// $Id: RtclRw11Cpu.ipp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-04-02   502   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11Cpu.ipp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation (inline) of RtclRw11Cpu.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& RtclRw11Cpu::Server() 
{
  return Obj().Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& RtclRw11Cpu::Connect() 
{
  return Obj().Connect();
}

} // end namespace Retro
