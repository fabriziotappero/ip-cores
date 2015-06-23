// $Id: Rw11VirtDisk.ipp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-03-03   494   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtDisk.ipp 509 2013-04-21 20:46:20Z mueller $
  \brief   Implemenation (inline) of Rw11VirtDisk.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11VirtDisk::Setup(size_t blksize, size_t nblock)
{
  fBlkSize = blksize;
  fNBlock  = nblock;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11VirtDisk::BlockSize() const
{
  return fBlkSize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11VirtDisk::NBlock() const
{
  return fNBlock;
}

} // end namespace Retro
