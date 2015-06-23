// $Id: Rw11Rdma.ipp 627 2015-01-04 11:36:37Z mueller $
//
// Copyright 20154- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-01-04   627   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Rdma.ipp 627 2015-01-04 11:36:37Z mueller $
  \brief   Implemenation (inline) of Rw11Rdma.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cntl& Rw11Rdma::CntlBase() const
{
  return *fpCntlBase;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cpu& Rw11Rdma::Cpu() const
{
  return fpCntlBase->Cpu();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11& Rw11Rdma::W11() const
{
  return fpCntlBase->W11();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& Rw11Rdma::Server() const
{
  return fpCntlBase->Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& Rw11Rdma::Connect() const
{
  return fpCntlBase->Connect();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& Rw11Rdma::LogFile() const
{
  return fpCntlBase->LogFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11Rdma::ChunkSize() const
{
  return fChunksize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Rdma::IsActive() const
{
  return fStatus != kStatusDone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& Rw11Rdma::Stats() const
{
  return fStats;
}

} // end namespace Retro
