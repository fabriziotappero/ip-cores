// $Id: Rw11Cntl.ipp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Cntl.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of Rw11Cntl.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11Cntl::SetCpu(Rw11Cpu* pcpu)
{
  fpCpu = pcpu;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cpu& Rw11Cntl::Cpu() const
{
  return *fpCpu;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11& Rw11Cntl::W11() const
{
  return fpCpu->W11();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& Rw11Cntl::Server() const
{
  return fpCpu->Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& Rw11Cntl::Connect() const
{
  return fpCpu->Connect();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& Rw11Cntl::LogFile() const
{
  return fpCpu->LogFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11Cntl::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11Cntl::Name() const
{
  return fName;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Cntl::Base() const
{
  return fBase;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rw11Cntl::Lam() const
{
  return fLam;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Cntl::Enable() const
{
  return fEnable;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rw11Probe& Rw11Cntl::ProbeStatus() const
{
  return fProbe;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Cntl::IsStarted() const
{
  return fStarted;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11Cntl::SetTraceLevel(uint32_t level)
{
  fTraceLevel = level;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t Rw11Cntl::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& Rw11Cntl::Stats() const
{
  return fStats;
}

} // end namespace Retro
