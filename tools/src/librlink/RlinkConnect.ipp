// $Id: RlinkConnect.ipp 666 2015-04-12 21:17:54Z mueller $
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
// 2015-04-12   666   2.2    add LinkInit,LinkInitDone; transfer xon
// 2015-01-06   631   2.1    full rlink v4 implementation
// 2013-03-05   495   1.2.1  add Exec() without emsg (will send emsg to LogFile)
// 2013-02-23   492   1.2    use scoped_ptr for Port; Close allways allowed
//                           use RlinkContext, add Context(), Exec(..., cntx)
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-02-03   481   1.0.1  add SetServer(),Server()
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkConnect.ipp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation (inline) of RlinkConnect.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::IsOpen() const
{
  return fpPort && fpPort->IsOpen();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkPort* RlinkConnect::Port() const
{
  return fpPort.get();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::LinkInitDone() const
{
  return fLinkInitDone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkContext& RlinkConnect::Context()
{
  return fContext;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkConnect::SetServer(RlinkServer* pserv)
{
  fpServ = pserv;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer* RlinkConnect::Server() const
{
  return fpServ;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline bool RlinkConnect::Exec(RlinkCommandList& clist, RerrMsg& emsg)
{
  return Exec(clist, fContext, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline void RlinkConnect::Exec(RlinkCommandList& clist)
{
  Exec(clist, fContext);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline uint32_t RlinkConnect::SysId() const
{
  return fSysId;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t RlinkConnect::RbufSize() const
{
  return fRbufSize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t RlinkConnect::BlockSizeMax() const
{
  return (fRbufSize-kRbufBlkDelta)/2;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t RlinkConnect::BlockSizePrudent() const
{
  return (fRbufSize-kRbufPrudentDelta)/2;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapInsert(const std::string& name, uint16_t addr)
{
  return fAddrMap.Insert(name, addr);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapErase(const std::string& name)
{
  return fAddrMap.Erase(name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapErase(uint16_t addr)
{
  return fAddrMap.Erase(addr);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkConnect::AddrMapClear()
{
  return fAddrMap.Clear();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkAddrMap& RlinkConnect::AddrMap() const
{
  return fAddrMap;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::Stats() const
{
  return fStats;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::SndStats() const
{
  return fSndPkt.Stats();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::RcvStats() const
{
  return fRcvPkt.Stats();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::LogBaseAddr() const
{
  return fLogBaseAddr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::LogBaseData() const
{
  return fLogBaseData;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::LogBaseStat() const
{
  return fLogBaseStat;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::PrintLevel() const
{
  return fPrintLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::DumpLevel() const
{
  return fDumpLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& RlinkConnect::LogFile() const
{
  return *fspLog;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const boost::shared_ptr<RlogFile>& RlinkConnect::LogFileSPtr() const
{
  return fspLog;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::string RlinkConnect::LogFileName() const
{
  return LogFile().Name();
}


} // end namespace Retro
