// $Id: RlinkPort.ipp 666 2015-04-12 21:17:54Z mueller $
//
// Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-04-11   666   1.3    add fXon, XonEnable()
// 2013-05-01   513   1.2.1  fTraceLevel now uint32_t
// 2013-02-23   492   1.2    use RparseUrl
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPort.ipp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation (inline) of RlinkPort.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPort::IsOpen() const
{
  return fIsOpen;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Retro::RparseUrl& RlinkPort::Url() const
{
  return fUrl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPort::XonEnable() const
{
  return fXon;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RlinkPort::FdRead() const
{
  return fFdRead;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RlinkPort::FdWrite() const
{
  return fFdWrite;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPort::SetLogFile(const boost::shared_ptr<RlogFile>& splog)
{
  fspLog = splog;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPort::SetTraceLevel(uint32_t level)
{
  fTraceLevel = level;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkPort::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkPort::Stats() const
{
  return fStats;
}

} // end namespace Retro
