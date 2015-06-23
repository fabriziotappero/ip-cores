// $Id: Rw11Virt.ipp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-02-16   489   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Virt.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of Rw11Virt.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Unit& Rw11Virt::Unit() const
{
  return *fpUnit;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cntl& Rw11Virt::Cntl() const
{
  return fpUnit->CntlBase();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cpu& Rw11Virt::Cpu() const
{
  return fpUnit->Cpu();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11& Rw11Virt::W11() const
{
  return fpUnit->W11();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& Rw11Virt::Server() const
{
  return fpUnit->Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& Rw11Virt::LogFile() const
{
  return fpUnit->LogFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& Rw11Virt::Stats() const
{
  return fStats;
}

} // end namespace Retro
