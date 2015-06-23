// $Id: RlinkContext.ipp 660 2015-03-29 22:10:16Z mueller $
//
// Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-03-28   660   1.1    add SetStatus(Value|Mask)()
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkContext.ipp 660 2015-03-29 22:10:16Z mueller $
  \brief   Implemenation (inline) of class RlinkContext.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::SetStatus(uint8_t stat, uint8_t statmsk)
{
  fStatusVal = stat;
  fStatusMsk = statmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::SetStatusValue(uint8_t stat)
{
  fStatusVal = stat;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::SetStatusMask(uint8_t statmsk)
{
  fStatusMsk = statmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkContext::StatusValue() const
{
  return fStatusVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkContext::StatusMask() const
{
  return fStatusMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkContext::StatusIsChecked() const
{
  return fStatusMsk != 0xff;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkContext::StatusCheck(uint8_t val) const
{
  return (val|fStatusMsk) == (fStatusVal|fStatusMsk);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::IncErrorCount(size_t inc)
{
  fErrCnt += inc;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::ClearErrorCount()
{
  fErrCnt = 0;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkContext::ErrorCount() const
{
  return fErrCnt;
}

} // end namespace Retro
