// $Id: RlinkPacketBuf.ipp 604 2014-11-16 22:33:09Z mueller $
//
// Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-11-15   604   2.0    re-organize for rlink v4
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBuf.ipp 604 2014-11-16 22:33:09Z mueller $
  \brief   Implemenation (inline) of class RlinkPacketBuf.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::PktSize() const
{
  return fPktBuf.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::SetFlagBit(uint32_t mask)
{
  fFlags |= mask;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkPacketBuf::Flags() const
{
  return fFlags;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBuf::TestFlag(uint32_t mask) const
{
  return (fFlags & mask) != 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkPacketBuf::Stats() const
{
  return fStats;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::ClearFlagBit(uint32_t mask)
{
  fFlags &= ~mask;
  return;
}

} // end namespace Retro
